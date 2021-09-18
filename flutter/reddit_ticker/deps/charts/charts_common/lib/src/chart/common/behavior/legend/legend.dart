// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math' show Rectangle;

import 'package:meta/meta.dart' show protected;
import 'package:intl/intl.dart';

import '../../../../common/graphics_factory.dart' show GraphicsFactory;
import '../../../cartesian/axis/spec/axis_spec.dart' show TextStyleSpec;
import '../../../layout/layout_view.dart'
    show
        LayoutPosition,
        LayoutView,
        LayoutViewConfig,
        LayoutViewPositionOrder,
        LayoutViewPaintOrder,
        ViewMeasuredSizes,
        layoutPosition;
import '../../base_chart.dart' show BaseChart, LifecycleListener;
import '../../chart_canvas.dart' show ChartCanvas;
import '../../chart_context.dart' show ChartContext;
import '../../processed_series.dart' show MutableSeries;
import '../../selection_model/selection_model.dart'
    show SelectionModel, SelectionModelType;
import '../chart_behavior.dart'
    show
        BehaviorPosition,
        ChartBehavior,
        InsideJustification,
        OutsideJustification;
import 'legend_entry.dart';
import 'legend_entry_generator.dart';

/// Legend behavior for charts.
///
/// Since legends are desired to be customizable, building and displaying the
/// visual content of legends is done on the native platforms. This allows users
/// to specify customized content for legends using the native platform (ex. for
/// Flutter, using widgets).
abstract class Legend<D> implements ChartBehavior<D>, LayoutView {
  final SelectionModelType selectionModelType;
  final legendState = LegendState<D>();
  final LegendEntryGenerator<D> legendEntryGenerator;

  /// The title text to display before legend entries.
  late String title;

  late BaseChart<D> _chart;
  late final LifecycleListener<D> _lifecycleListener;

  Rectangle<int>? _componentBounds;
  Rectangle<int>? _drawAreaBounds;

  @override
  GraphicsFactory? graphicsFactory;

  BehaviorPosition behaviorPosition = BehaviorPosition.end;
  OutsideJustification outsideJustification =
      OutsideJustification.startDrawArea;
  InsideJustification insideJustification = InsideJustification.topStart;
  LegendCellPadding? cellPadding;
  LegendCellPadding? legendPadding;

  /// Text style of the legend title text.
  TextStyleSpec? titleTextStyle;

  /// Configures the behavior of the legend when the user taps/clicks on an
  /// entry. Defaults to no behavior.
  ///
  /// Tapping on a legend entry will update the data visible on the chart. For
  /// example, when [LegendTapHandling.hide] is configured, the series or datum
  /// associated with that entry will be removed from the chart. Tapping on that
  /// entry a second time will make the data visible again.
  LegendTapHandling legendTapHandling = LegendTapHandling.hide;

  late List<MutableSeries<D>> _currentSeriesList;

  /// List of series IDs in the order the series should appear in the legend.
  /// Series that are not specified in the ordering will be sorted
  /// alphabetically at the bottom.
  List<String>? _customEntryOrder;

  /// Save this in order to check if series list have changed and regenerate
  /// the legend entries.
  List<MutableSeries<D>>? _postProcessSeriesList;

  static final _decimalPattern = NumberFormat.decimalPattern();

  /// Default measure formatter for legends.
  @protected
  String defaultLegendMeasureFormatter(num? value) {
    return (value == null) ? '' : _decimalPattern.format(value);
  }

  Legend({
    required this.selectionModelType,
    required this.legendEntryGenerator,
    TextStyleSpec? entryTextStyle,
  }) {
    _lifecycleListener = LifecycleListener(
        onPostprocess: _postProcess, onPreprocess: _preProcess, onData: onData);
    legendEntryGenerator.entryTextStyle = entryTextStyle;

    // Calling the setter will automatically use a non-null default value.
    showOverlaySeries = null;
  }

  /// Text style of the legend entry text.
  TextStyleSpec? get entryTextStyle => legendEntryGenerator.entryTextStyle;

  set entryTextStyle(TextStyleSpec? entryTextStyle) {
    legendEntryGenerator.entryTextStyle = entryTextStyle;
  }

  set customEntryOrder(List<String>? customEntryOrder) {
    _customEntryOrder = customEntryOrder;
  }

  /// Whether or not the legend show overlay series.
  ///
  /// By default this is false, the overlay series are not shown on the legend.
  ///
  /// if [showOverlaySeries] is set to null, it is changed to the default of
  /// false.
  bool get showOverlaySeries => legendEntryGenerator.showOverlaySeries;

  set showOverlaySeries(bool? showOverlaySeries) {
    legendEntryGenerator.showOverlaySeries = showOverlaySeries ?? false;
  }

  /// Resets any hidden series data when new data is drawn on the chart.
  @protected
  void onData(List<MutableSeries<D>> seriesList) {}

  /// Store off a copy of the series list for use when we render the legend.
  void _preProcess(List<MutableSeries<D>> seriesList) {
    _currentSeriesList = List.of(seriesList);
    preProcessSeriesList(seriesList);
  }

  /// Overridable method that may be used by concrete [Legend] instances to
  /// manipulate the series list.
  @protected
  void preProcessSeriesList(List<MutableSeries<D>> seriesList) {}

  /// Build LegendEntries from list of series.
  void _postProcess(List<MutableSeries<D>> seriesList) {
    // Get the selection model directly from chart on post process.
    //
    // This is because if initial selection is set as a behavior, it will be
    // handled during onData. onData is prior to this behavior's postProcess
    // call, so the selection will have changed prior to the entries being
    // generated.
    final selectionModel = chart.getSelectionModel(selectionModelType);

    // Update entries if the selection model is different because post
    // process is called on each draw cycle, so this is called on each animation
    // frame and we don't want to update and request the native platform to
    // rebuild if nothing has changed.
    //
    // Also update legend entries if the series list has changed.
    if (legendState._selectionModel != selectionModel ||
        _postProcessSeriesList != seriesList) {
      final _customEntryOrder = this._customEntryOrder;
      if (_customEntryOrder != null) {
        _currentSeriesList.sort((a, b) {
          final a_index = _customEntryOrder.indexOf(a.id);
          final b_index = _customEntryOrder.indexOf(b.id);
          if (a_index == -1) {
            if (a_index == b_index) {
              return a.displayName!.compareTo(b.displayName!);
            }
            return 1;
          } else if (b_index == -1) {
            return -1;
          }
          return a_index.compareTo(b_index);
        });
      }

      legendState._legendEntries =
          legendEntryGenerator.getLegendEntries(_currentSeriesList);

      legendState._selectionModel = selectionModel;
      _postProcessSeriesList = seriesList;
      _updateLegendEntries(seriesList: seriesList);
    }
  }

  // need to handle when series data changes, selection should be reset

  /// Update the legend state with [selectionModel] and request legend update.
  void _selectionChanged(SelectionModel<D> selectionModel) {
    legendState._selectionModel = selectionModel;
    _updateLegendEntries();
  }

  ChartContext get chartContext => _chart.context;

  /// Internally update legend entries, before calling [updateLegend] that
  /// notifies the native platform.
  void _updateLegendEntries({List<MutableSeries<D>>? seriesList}) {
    legendEntryGenerator.updateLegendEntries(legendState._legendEntries,
        legendState._selectionModel!, seriesList ?? chart.currentSeriesList);

    updateLegend();
  }

  /// Requires override to show in native platform
  void updateLegend() {}

  @override
  void attachTo(BaseChart<D> chart) {
    _chart = chart;
    chart.addLifecycleListener(_lifecycleListener);
    chart
        .getSelectionModel(selectionModelType)
        .addSelectionChangedListener(_selectionChanged);

    chart.addView(this);
  }

  @override
  void removeFrom(BaseChart<D> chart) {
    chart
        .getSelectionModel(selectionModelType)
        .removeSelectionChangedListener(_selectionChanged);
    chart.removeLifecycleListener(_lifecycleListener);

    chart.removeView(this);
  }

  @protected
  BaseChart<D> get chart => _chart;

  @override
  String get role => 'legend-$selectionModelType';

  bool get isRtl => _chart.context.chartContainerIsRtl;

  bool get isAxisFlipped => _chart.context.isRtl;

  @override
  LayoutViewConfig get layoutConfig {
    return LayoutViewConfig(
        position: _layoutPosition,
        positionOrder: LayoutViewPositionOrder.legend,
        paintOrder: LayoutViewPaintOrder.legend);
  }

  /// Get layout position from legend position.
  LayoutPosition get _layoutPosition {
    return layoutPosition(behaviorPosition, outsideJustification, isRtl);
  }

  @override
  ViewMeasuredSizes measure(int maxWidth, int maxHeight) {
    // Native child classes should override this method to return real
    // measurements.
    return ViewMeasuredSizes(preferredWidth: 0, preferredHeight: 0);
  }

  @override
  void layout(Rectangle<int> componentBounds, Rectangle<int> drawAreaBounds) {
    _componentBounds = componentBounds;
    _drawAreaBounds = drawAreaBounds;

    updateLegend();
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {}

  @override
  Rectangle<int>? get componentBounds => _componentBounds;

  @override
  bool get isSeriesRenderer => false;

  // Gets the draw area bounds for native legend content to position itself
  // accordingly.
  Rectangle<int>? get drawAreaBounds => _drawAreaBounds;
}

/// Stores legend data used by native legend content builder.
class LegendState<D> {
  late List<LegendEntry<D>> _legendEntries;
  SelectionModel<D>? _selectionModel;

  List<LegendEntry<D>> get legendEntries => _legendEntries;
  SelectionModel<D>? get selectionModel => _selectionModel;
}

/// Stores legend cell padding, in percents or pixels.
///
/// If a percent is specified, it takes precedence over a flat pixel value.
class LegendCellPadding {
  final double? bottomPct;
  final double? bottomPx;
  final double? leftPct;
  final double? leftPx;
  final double? rightPct;
  final double? rightPx;
  final double? topPct;
  final double? topPx;

  /// Creates padding in percents from the left, top, right, and bottom.
  const LegendCellPadding.fromLTRBPct(
      this.leftPct, this.topPct, this.rightPct, this.bottomPct)
      : leftPx = null,
        topPx = null,
        rightPx = null,
        bottomPx = null;

  /// Creates padding in pixels from the left, top, right, and bottom.
  const LegendCellPadding.fromLTRBPx(
      this.leftPx, this.topPx, this.rightPx, this.bottomPx)
      : leftPct = null,
        topPct = null,
        rightPct = null,
        bottomPct = null;

  /// Creates padding in percents from the top, right, bottom, and left.
  const LegendCellPadding.fromTRBLPct(
      this.topPct, this.rightPct, this.bottomPct, this.leftPct)
      : topPx = null,
        rightPx = null,
        bottomPx = null,
        leftPx = null;

  /// Creates padding in pixels from the top, right, bottom, and left.
  const LegendCellPadding.fromTRBLPx(
      this.topPx, this.rightPx, this.bottomPx, this.leftPx)
      : topPct = null,
        rightPct = null,
        bottomPct = null,
        leftPct = null;

  /// Creates cell padding where all the offsets are `value` in percent.
  ///
  /// ## Sample code
  ///
  /// Typical eight percent margin on all sides:
  ///
  /// ```dart
  /// const LegendCellPadding.allPct(8.0)
  /// ```
  const LegendCellPadding.allPct(double value)
      : this.fromLTRBPct(value, value, value, value);

  /// Creates cell padding where all the offsets are `value` in pixels.
  ///
  /// ## Sample code
  ///
  /// Typical eight-pixel margin on all sides:
  ///
  /// ```dart
  /// const LegendCellPadding.allPx(8.0)
  /// ```
  const LegendCellPadding.allPx(double value)
      : this.fromLTRBPx(value, value, value, value);

  double bottom(num height) =>
      bottomPct != null ? bottomPct! * height : bottomPx!;

  double left(num width) => leftPct != null ? leftPct! * width : leftPx!;

  double right(num width) => rightPct != null ? rightPct! * width : rightPx!;

  double top(num height) => topPct != null ? topPct! * height : topPx!;
}

/// Options for behavior of tapping/clicking on entries in the legend.
enum LegendTapHandling {
  /// No associated behavior.
  none,

  /// Hide elements on the chart associated with this legend entry.
  hide,
}
