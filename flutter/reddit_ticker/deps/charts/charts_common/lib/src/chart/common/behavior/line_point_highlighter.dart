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

import 'dart:collection' show LinkedHashMap;
import 'dart:math' show max, min, Point, Rectangle;

import 'package:meta/meta.dart';

import '../../../common/color.dart' show Color;
import '../../../common/graphics_factory.dart' show GraphicsFactory;
import '../../../common/math.dart' show NullablePoint;
import '../../../common/style/style_factory.dart' show StyleFactory;
import '../../../common/symbol_renderer.dart'
    show CircleSymbolRenderer, SymbolRenderer;
import '../../cartesian/axis/axis.dart'
    show ImmutableAxis, domainAxisKey, measureAxisKey;
import '../../cartesian/cartesian_chart.dart' show CartesianChart;
import '../../layout/layout_view.dart'
    show
        LayoutPosition,
        LayoutView,
        LayoutViewConfig,
        LayoutViewPaintOrder,
        ViewMeasuredSizes;
import '../base_chart.dart' show BaseChart, LifecycleListener;
import '../chart_canvas.dart' show ChartCanvas, getAnimatedColor;
import '../processed_series.dart' show ImmutableSeries;
import '../selection_model/selection_model.dart'
    show SelectionModel, SelectionModelType;
import 'chart_behavior.dart' show ChartBehavior;

/// Chart behavior that monitors the specified [SelectionModel] and renders a
/// dot for selected data.
///
/// Vertical or horizontal follow lines can optionally be drawn underneath the
/// rendered dots. Follow lines will be drawn in the combined area of the chart
/// draw area, and the draw area for any layout components that provide a
/// series draw area (e.g. [SymbolAnnotationRenderer]).
///
/// This is typically used for line charts to highlight segments.
///
/// It is used in combination with SelectNearest to update the selection model
/// and expand selection out to the domain value.
class LinePointHighlighter<D> implements ChartBehavior<D> {
  final SelectionModelType selectionModelType;

  /// Default radius of the dots if the series has no radius mapping function.
  ///
  /// When no radius mapping function is provided, this value will be used as
  /// is. [radiusPaddingPx] will not be added to [defaultRadiusPx].
  final double defaultRadiusPx;

  /// Additional radius value added to the radius of the selected data.
  ///
  /// This value is only used when the series has a radius mapping function
  /// defined.
  final double radiusPaddingPx;

  /// Whether or not to draw horizontal follow lines through the selected
  /// points.
  ///
  /// Defaults to drawing no horizontal follow lines.
  final LinePointHighlighterFollowLineType showHorizontalFollowLine;

  /// Whether or not to draw vertical follow lines through the selected points.
  ///
  /// Defaults to drawing a vertical follow line only for the nearest datum.
  final LinePointHighlighterFollowLineType showVerticalFollowLine;

  /// The dash pattern to be used for drawing the line.
  ///
  /// To disable dash pattern (to draw a solid line), pass in an empty list.
  /// This is because if dashPattern is null or not set, it defaults to [1,3].
  final List<int>? dashPattern;

  /// Whether or not follow lines should be drawn across the entire chart draw
  /// area, or just from the axis to the point.
  ///
  /// When disabled, measure follow lines will be drawn from the primary measure
  /// axis to the point. In RTL mode, this means from the right-hand axis. In
  /// LTR mode, from the left-hand axis.
  final bool drawFollowLinesAcrossChart;

  /// Renderer used to draw the highlighted points.
  final SymbolRenderer symbolRenderer;

  late BaseChart<D> _chart;

  late _LinePointLayoutView<D> _view;

  late LifecycleListener<D> _lifecycleListener;

  /// Store a map of data drawn on the chart, mapped by series name.
  ///
  /// [LinkedHashMap] is used to render the series on the canvas in the same
  /// order as the data was provided by the selection model.
  // ignore: prefer_collection_literals, https://github.com/dart-lang/linter/issues/1649
  var _seriesPointMap = LinkedHashMap<String, _AnimatedPoint<D>>();

  // Store a list of points that exist in the series data.
  //
  // This list will be used to remove any [_AnimatedPoint] that were rendered in
  // previous draw cycles, but no longer have a corresponding datum in the new
  // data.
  final _currentKeys = <String>[];

  LinePointHighlighter(
      {SelectionModelType? selectionModelType,
      double? defaultRadiusPx,
      double? radiusPaddingPx,
      LinePointHighlighterFollowLineType? showHorizontalFollowLine,
      LinePointHighlighterFollowLineType? showVerticalFollowLine,
      List<int>? dashPattern,
      bool? drawFollowLinesAcrossChart,
      SymbolRenderer? symbolRenderer})
      : selectionModelType = selectionModelType ?? SelectionModelType.info,
        defaultRadiusPx = defaultRadiusPx ?? 4.0,
        radiusPaddingPx = radiusPaddingPx ?? 2.0,
        showHorizontalFollowLine =
            showHorizontalFollowLine ?? LinePointHighlighterFollowLineType.none,
        showVerticalFollowLine = showVerticalFollowLine ??
            LinePointHighlighterFollowLineType.nearest,
        dashPattern = dashPattern ?? [1, 3],
        drawFollowLinesAcrossChart = drawFollowLinesAcrossChart ?? true,
        symbolRenderer = symbolRenderer ?? CircleSymbolRenderer() {
    _lifecycleListener =
        LifecycleListener<D>(onAxisConfigured: _updateViewData);
  }

  @override
  void attachTo(BaseChart<D> chart) {
    _chart = chart;

    _view = _LinePointLayoutView<D>(
        chart: chart,
        layoutPaintOrder: LayoutViewPaintOrder.linePointHighlighter,
        showHorizontalFollowLine: showHorizontalFollowLine,
        showVerticalFollowLine: showVerticalFollowLine,
        dashPattern: dashPattern,
        drawFollowLinesAcrossChart: drawFollowLinesAcrossChart,
        symbolRenderer: symbolRenderer);

    if (chart is CartesianChart) {
      // Only vertical rendering is supported by this behavior.
      assert((chart as CartesianChart).vertical);
    }

    chart.addView(_view);

    chart.addLifecycleListener(_lifecycleListener);
    chart
        .getSelectionModel(selectionModelType)
        .addSelectionChangedListener(_selectionChanged);
  }

  @override
  void removeFrom(BaseChart<D> chart) {
    chart.removeView(_view);
    chart
        .getSelectionModel(selectionModelType)
        .removeSelectionChangedListener(_selectionChanged);
    chart.removeLifecycleListener(_lifecycleListener);
  }

  void _selectionChanged(SelectionModel<D> selectionModel) {
    _chart.redraw(skipLayout: true, skipAnimation: true);
  }

  void _updateViewData() {
    _currentKeys.clear();

    final selectedDatumDetails =
        _chart.getSelectedDatumDetails(selectionModelType);

    // Create a new map each time to ensure that we have it sorted in the
    // selection model order. This preserves the "nearestDetail" ordering, so
    // that we render follow lines in the proper place.
    // ignore: prefer_collection_literals
    final newSeriesMap = LinkedHashMap<String, _AnimatedPoint<D>>();

    for (final detail in selectedDatumDetails) {
      if (detail == null) {
        continue;
      }

      final series = detail.series!;
      final Object? datum = detail.datum;

      final domainAxis = series.getAttr(domainAxisKey) as ImmutableAxis<D>;
      final measureAxis = series.getAttr(measureAxisKey) as ImmutableAxis<num>;

      final lineKey = series.id;

      final radiusPx = (detail.radiusPx != null)
          ? detail.radiusPx!.toDouble() + radiusPaddingPx
          : defaultRadiusPx;

      final pointKey = '${lineKey}::${detail.domain}::${detail.measure}';

      // If we already have a point for that key, use it.
      _AnimatedPoint<D> animatingPoint;
      if (_seriesPointMap.containsKey(pointKey)) {
        animatingPoint = _seriesPointMap[pointKey]!;
      } else {
        // Create a new point and have it animate in from axis.
        final point = _DatumPoint<D>(
            datum: datum,
            domain: detail.domain,
            series: series,
            x: domainAxis.getLocation(detail.domain),
            y: measureAxis.getLocation(0.0));

        animatingPoint = _AnimatedPoint<D>(
            key: pointKey, overlaySeries: series.overlaySeries)
          ..setNewTarget(_PointRendererElement<D>(
            point: point,
            color: detail.color,
            fillColor: detail.fillColor,
            radiusPx: radiusPx,
            measureAxisPosition: measureAxis.getLocation(0.0),
            strokeWidthPx: detail.strokeWidthPx,
            symbolRenderer: detail.symbolRenderer,
          ));
      }

      newSeriesMap[pointKey] = animatingPoint;

      // Create a new line using the final point locations.
      final point = _DatumPoint<D>(
          datum: datum,
          domain: detail.domain,
          series: series,
          x: detail.chartPosition!.x,
          y: detail.chartPosition!.y);

      // Update the set of points that still exist in the series data.
      _currentKeys.add(pointKey);

      // Get the point element we are going to setup.
      final pointElement = _PointRendererElement<D>(
        point: point,
        color: detail.color,
        fillColor: detail.fillColor,
        radiusPx: radiusPx,
        measureAxisPosition: measureAxis.getLocation(0.0),
        strokeWidthPx: detail.strokeWidthPx,
        symbolRenderer: detail.symbolRenderer,
      );

      animatingPoint.setNewTarget(pointElement);
    }

    // Animate out points that don't exist anymore.
    _seriesPointMap.forEach((String key, _AnimatedPoint<D> point) {
      if (_currentKeys.contains(point.key) != true) {
        point.animateOut();
        newSeriesMap[point.key] = point;
      }
    });

    _seriesPointMap = newSeriesMap;
    _view.seriesPointMap = _seriesPointMap;
  }

  @override
  String get role => 'LinePointHighlighter-$selectionModelType';
}

class _LinePointLayoutView<D> extends LayoutView {
  @override
  final LayoutViewConfig layoutConfig;

  final LinePointHighlighterFollowLineType showHorizontalFollowLine;

  final LinePointHighlighterFollowLineType showVerticalFollowLine;

  final BaseChart<D> chart;

  final List<int>? dashPattern;

  late Rectangle<int> _drawAreaBounds;

  Rectangle<int> get drawBounds => _drawAreaBounds;

  final bool drawFollowLinesAcrossChart;

  final SymbolRenderer symbolRenderer;

  @override
  GraphicsFactory? graphicsFactory;

  /// Store a map of series drawn on the chart, mapped by series name.
  ///
  /// [LinkedHashMap] is used to render the series on the canvas in the same
  /// order as the data was given to the chart.
  LinkedHashMap<String, _AnimatedPoint<D>>? _seriesPointMap;

  _LinePointLayoutView({
    required this.chart,
    required int layoutPaintOrder,
    required this.showHorizontalFollowLine,
    required this.showVerticalFollowLine,
    required this.symbolRenderer,
    required this.dashPattern,
    required this.drawFollowLinesAcrossChart,
  }) : layoutConfig = LayoutViewConfig(
            paintOrder: LayoutViewPaintOrder.linePointHighlighter,
            position: LayoutPosition.DrawArea,
            positionOrder: layoutPaintOrder);

  set seriesPointMap(LinkedHashMap<String, _AnimatedPoint<D>>? value) {
    _seriesPointMap = value;
  }

  @override
  ViewMeasuredSizes? measure(int maxWidth, int maxHeight) {
    return null;
  }

  @override
  void layout(Rectangle<int> componentBounds, Rectangle<int> drawAreaBounds) {
    _drawAreaBounds = drawAreaBounds;
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    final _seriesPointMap = this._seriesPointMap;
    if (_seriesPointMap == null) {
      return;
    }

    // Clean up the lines that no longer exist.
    if (animationPercent == 1.0) {
      final keysToRemove = <String>[];

      _seriesPointMap.forEach((String key, _AnimatedPoint<D> point) {
        if (point.animatingOut) {
          keysToRemove.add(key);
        }
      });

      keysToRemove.forEach(_seriesPointMap.remove);
    }

    final points = <_PointRendererElement<D>>[];
    _seriesPointMap.forEach((String key, _AnimatedPoint<D> point) {
      points.add(point.getCurrentPoint(animationPercent));
    });

    // Build maps of the position where the follow lines should stop for each
    // selected data point.
    final endPointPerValueVertical = <int, int>{};
    final endPointPerValueHorizontal = <int, int>{};

    for (final pointElement in points) {
      if (pointElement.point.x == null || pointElement.point.y == null) {
        continue;
      }
      final point = pointElement.point.toPoint();

      final roundedX = point.x.round();
      final roundedY = point.y.round();

      // Get the Y value closest to the top of the chart for this X position.
      if (endPointPerValueVertical[roundedX] == null) {
        endPointPerValueVertical[roundedX] = roundedY;
      } else {
        // In the nearest case, we rely on the selected data always starting
        // with the nearest point. In this case, we don't care about the rest of
        // the selected data positions.
        if (showVerticalFollowLine !=
            LinePointHighlighterFollowLineType.nearest) {
          endPointPerValueVertical[roundedX] =
              min(endPointPerValueVertical[roundedX]!, roundedY);
        }
      }

      // Get the X value closest to the "end" side of the chart for this Y
      // position.
      if (endPointPerValueHorizontal[roundedY] == null) {
        endPointPerValueHorizontal[roundedY] = roundedX;
      } else {
        // In the nearest case, we rely on the selected data always starting
        // with the nearest point. In this case, we don't care about the rest of
        // the selected data positions.
        if (showHorizontalFollowLine !=
            LinePointHighlighterFollowLineType.nearest) {
          endPointPerValueHorizontal[roundedY] =
              max(endPointPerValueHorizontal[roundedY]!, roundedX);
        }
      }
    }

    var shouldShowHorizontalFollowLine = showHorizontalFollowLine ==
            LinePointHighlighterFollowLineType.all ||
        showHorizontalFollowLine == LinePointHighlighterFollowLineType.nearest;

    var shouldShowVerticalFollowLine = showVerticalFollowLine ==
            LinePointHighlighterFollowLineType.all ||
        showVerticalFollowLine == LinePointHighlighterFollowLineType.nearest;

    // Keep track of points for which we've already drawn lines.
    final paintedHorizontalLinePositions = <num>[];
    final paintedVerticalLinePositions = <num>[];

    final drawBounds = chart.drawableLayoutAreaBounds;

    final rtl = chart.context.isRtl;

    // Draw the follow lines first, below all of the highlight shapes.
    for (final pointElement in points) {
      if (pointElement.point.x == null || pointElement.point.y == null) {
        continue;
      }
      final point = pointElement.point.toPoint();

      final roundedX = point.x.round();
      final roundedY = point.y.round();

      // Draw the horizontal follow line.
      if (shouldShowHorizontalFollowLine &&
          !paintedHorizontalLinePositions.contains(roundedY)) {
        int leftBound;
        int rightBound;

        if (drawFollowLinesAcrossChart) {
          // RTL and LTR both go across the whole draw area.
          leftBound = drawBounds.left;
          rightBound = drawBounds.left + drawBounds.width;
        } else {
          final x = endPointPerValueHorizontal[roundedY]!;

          // RTL goes from the point to the right edge. LTR goes from the left
          // edge to the point.
          leftBound = rtl ? x : drawBounds.left;
          rightBound = rtl ? drawBounds.left + drawBounds.width : x;
        }

        canvas.drawLine(
            points: [
              Point<num>(leftBound, point.y),
              Point<num>(rightBound, point.y),
            ],
            stroke: StyleFactory.style.linePointHighlighterColor,
            strokeWidthPx: 1.0,
            dashPattern: dashPattern);

        if (showHorizontalFollowLine ==
            LinePointHighlighterFollowLineType.nearest) {
          shouldShowHorizontalFollowLine = false;
        }

        paintedHorizontalLinePositions.add(roundedY);
      }

      // Draw the vertical follow line.
      if (shouldShowVerticalFollowLine &&
          !paintedVerticalLinePositions.contains(roundedX)) {
        final topBound = drawFollowLinesAcrossChart
            ? drawBounds.top
            : endPointPerValueVertical[roundedX]!;

        canvas.drawLine(
            points: [
              Point<num>(point.x, topBound),
              Point<num>(point.x, drawBounds.top + drawBounds.height),
            ],
            stroke: StyleFactory.style.linePointHighlighterColor,
            strokeWidthPx: 1.0,
            dashPattern: dashPattern);

        if (showVerticalFollowLine ==
            LinePointHighlighterFollowLineType.nearest) {
          shouldShowVerticalFollowLine = false;
        }

        paintedVerticalLinePositions.add(roundedX);
      }

      if (!shouldShowHorizontalFollowLine && !shouldShowVerticalFollowLine) {
        break;
      }
    }

    // Draw the highlight shapes on top of all follow lines.
    for (final pointElement in points) {
      if (pointElement.point.x == null || pointElement.point.y == null) {
        continue;
      }
      final point = pointElement.point.toPoint();

      final bounds = Rectangle<double>(
          point.x - pointElement.radiusPx,
          point.y - pointElement.radiusPx,
          pointElement.radiusPx * 2,
          pointElement.radiusPx * 2);

      // Draw the highlight dot. Use the [SymbolRenderer] from the datum if one
      // is defined.
      (pointElement.symbolRenderer ?? symbolRenderer).paint(canvas, bounds,
          fillColor: pointElement.fillColor,
          strokeColor: pointElement.color,
          strokeWidthPx: pointElement.strokeWidthPx);
    }
  }

  @override
  Rectangle<int> get componentBounds => _drawAreaBounds;

  @override
  bool get isSeriesRenderer => false;
}

class _DatumPoint<D> extends NullablePoint {
  final dynamic datum;
  final D? domain;
  final ImmutableSeries<D>? series;

  _DatumPoint({
    this.datum,
    this.domain,
    this.series,
    double? x,
    double? y,
  }) : super(x, y);

  factory _DatumPoint.from(_DatumPoint<D> other, [double? x, double? y]) {
    return _DatumPoint<D>(
        datum: other.datum,
        domain: other.domain,
        series: other.series,
        x: x ?? other.x,
        y: y ?? other.y);
  }
}

class _PointRendererElement<D> {
  _DatumPoint<D> point;
  Color? color;
  Color? fillColor;
  double radiusPx;
  double? measureAxisPosition;
  double? strokeWidthPx;
  SymbolRenderer? symbolRenderer;

  _PointRendererElement({
    required this.point,
    required this.color,
    required this.fillColor,
    required this.radiusPx,
    required this.measureAxisPosition,
    required this.strokeWidthPx,
    required this.symbolRenderer,
  });

  _PointRendererElement<D> clone() {
    return _PointRendererElement<D>(
      point: point,
      color: color,
      fillColor: fillColor,
      measureAxisPosition: measureAxisPosition,
      radiusPx: radiusPx,
      strokeWidthPx: strokeWidthPx,
      symbolRenderer: symbolRenderer,
    );
  }

  void updateAnimationPercent(_PointRendererElement<D> previous,
      _PointRendererElement<D> target, double animationPercent) {
    final targetPoint = target.point;
    final previousPoint = previous.point;

    final x = _lerpDouble(previousPoint.x, targetPoint.x, animationPercent);

    final y = _lerpDouble(previousPoint.y, targetPoint.y, animationPercent);

    point = _DatumPoint<D>.from(targetPoint, x, y);

    color = getAnimatedColor(previous.color!, target.color!, animationPercent);

    fillColor = getAnimatedColor(
        previous.fillColor!, target.fillColor!, animationPercent);

    radiusPx =
        _lerpDouble(previous.radiusPx, target.radiusPx, animationPercent)!;

    final targetStrokeWidthPx = target.strokeWidthPx;
    final previousStrokeWidthPx = previous.strokeWidthPx;
    if (targetStrokeWidthPx != null && previousStrokeWidthPx != null) {
      strokeWidthPx =
          ((targetStrokeWidthPx - previousStrokeWidthPx) * animationPercent) +
              previousStrokeWidthPx;
    } else {
      strokeWidthPx = null;
    }
  }

  /// Linear interpolation for doubles.
  ///
  /// If either [a] or [b] is null, return null.
  /// This is different than Flutter's lerpDouble method, we want to return null
  /// instead of assuming it is 0.0.
  double? _lerpDouble(double? a, double? b, double t) {
    if (a == null || b == null) return null;
    return a + (b - a) * t;
  }
}

class _AnimatedPoint<D> {
  final String key;
  final bool overlaySeries;

  _PointRendererElement<D>? _previousPoint;
  late _PointRendererElement<D> _targetPoint;
  _PointRendererElement<D>? _currentPoint;

  // Flag indicating whether this point is being animated out of the chart.
  bool animatingOut = false;

  _AnimatedPoint({required this.key, required this.overlaySeries});

  /// Animates a point that was removed from the series out of the view.
  ///
  /// This should be called in place of "setNewTarget" for points that represent
  /// data that has been removed from the series.
  ///
  /// Animates the height of the point down to the measure axis position
  /// (position of 0).
  void animateOut() {
    final newTarget = _currentPoint!.clone();

    // Set the target measure value to the axis position for all points.
    final targetPoint = newTarget.point;

    final newPoint = _DatumPoint<D>.from(targetPoint, targetPoint.x,
        newTarget.measureAxisPosition!.roundToDouble());

    newTarget.point = newPoint;

    // Animate the radius to 0 so that we don't get a lingering point after
    // animation is done.
    newTarget.radiusPx = 0.0;

    setNewTarget(newTarget);
    animatingOut = true;
  }

  void setNewTarget(_PointRendererElement<D> newTarget) {
    animatingOut = false;
    _currentPoint ??= newTarget.clone();
    _previousPoint = _currentPoint!.clone();
    _targetPoint = newTarget;
  }

  _PointRendererElement<D> getCurrentPoint(double animationPercent) {
    if (animationPercent == 1.0 || _previousPoint == null) {
      _currentPoint = _targetPoint;
      _previousPoint = _targetPoint;
      return _currentPoint!;
    }

    _currentPoint!.updateAnimationPercent(
        _previousPoint!, _targetPoint, animationPercent);

    return _currentPoint!;
  }
}

/// Type of follow line(s) to draw.
enum LinePointHighlighterFollowLineType {
  /// Draw a follow line for only the nearest point in the selection.
  nearest,

  /// Draw no follow lines.
  none,

  /// Draw a follow line for every point in the selection.
  all,
}

/// Helper class that exposes fewer private internal properties for unit tests.
@visibleForTesting
class LinePointHighlighterTester<D> {
  final LinePointHighlighter<D> behavior;

  LinePointHighlighterTester(this.behavior);

  int getSelectionLength() => behavior._seriesPointMap.length;

  bool isDatumSelected(D datum) => behavior._seriesPointMap.values
      .any((point) => point._currentPoint!.point.datum == datum);
}
