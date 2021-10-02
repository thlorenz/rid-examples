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

import 'dart:math';

import '../../common/color.dart' show Color;
import '../../common/math.dart' show NullablePoint;
import '../../common/symbol_renderer.dart' show SymbolRenderer;
import 'chart_canvas.dart' show FillPatternType;
import 'processed_series.dart' show ImmutableSeries;

typedef DomainFormatter<D> = String Function(D domain);
typedef MeasureFormatter = String Function(num? measure);

/// Represents processed rendering details for a data point from a series.
class DatumDetails<D> {
  final dynamic datum;

  /// The index of the datum in the series.
  final int? index;

  /// Domain value of [datum].
  final D? domain;

  /// Domain lower bound value of [datum]. This may represent an error bound, or
  /// a previous domain value.
  final D? domainLowerBound;

  /// Domain upper bound value of [datum]. This may represent an error bound, or
  /// a target domain value.
  final D? domainUpperBound;

  /// Measure value of [datum].
  final num? measure;

  /// Measure lower bound value of [datum]. This may represent an error bound,
  /// or a previous value.
  final num? measureLowerBound;

  /// Measure upper bound value of [datum]. This may represent an error bound,
  /// or a target measure value.
  final num? measureUpperBound;

  /// Measure offset value of [datum].
  final num? measureOffset;

  /// Original measure value of [datum]. This may differ from [measure] if a
  /// behavior attached to a chart automatically adjusts measure values.
  final num? rawMeasure;

  /// Original measure lower bound value of [datum]. This may differ from
  /// [measureLowerBound] if a behavior attached to a chart automatically
  /// adjusts measure values.
  final num? rawMeasureLowerBound;

  /// Original measure upper bound value of [datum]. This may differ from
  /// [measureUpperBound] if a behavior attached to a chart automatically
  /// adjusts measure values.
  final num? rawMeasureUpperBound;

  /// The series the [datum] is from.
  final ImmutableSeries<D>? series;

  /// The color of this [datum].
  final Color? color;

  /// Optional fill color of this [datum].
  ///
  /// If this is defined, then [color] will be used as a stroke color.
  /// Otherwise, [color] will be used for the fill color.
  final Color? fillColor;

  /// Optional fill pattern of this [datum].
  final FillPatternType? fillPattern;

  /// Optional area color of this [datum].
  ///
  /// This color is used for supplemental information on the series, such as
  /// confidence intervals or area skirts. If not provided, then some variation
  /// of the main [color] will be used (e.g. 10% opacity).
  final Color? areaColor;

  /// Optional dash pattern of this [datum].
  final List<int>? dashPattern;

  /// The chart position of the (domain, measure) for the [datum] from a
  /// renderer.
  final NullablePoint? chartPosition;

  /// The chart position of the (domainLowerBound, measureLowerBound) for the
  /// [datum] from a renderer.
  final NullablePoint? chartPositionLower;

  /// The chart position of the (domainUpperBound, measureUpperBound) for the
  /// [datum] from a renderer.
  final NullablePoint? chartPositionUpper;

  /// The bounding box for the chart space occupied by this datum.
  ///
  /// This is currently only populated by the bar series renderer.
  ///
  /// TODO: Fill this in for other series renderers.
  final Rectangle<int>? bounds;

  /// Distance of [domain] from a given (x, y) coordinate.
  final double? domainDistance;

  /// Distance of [measure] from a given (x, y) coordinate.
  final double? measureDistance;

  /// Relative Cartesian distance of ([domain], [measure]) from a given (x, y)
  /// coordinate.
  final double? relativeDistance;

  /// The radius of this [datum].
  final double? radiusPx;

  /// Renderer used to draw the shape of this datum.
  ///
  /// This is primarily used for point shapes on line and scatter plot charts.
  final SymbolRenderer? symbolRenderer;

  /// The stroke width of this [datum].
  final double? strokeWidthPx;

  /// Optional formatter for [domain].
  DomainFormatter<D>? domainFormatter;

  /// Optional formatter for [measure].
  MeasureFormatter? measureFormatter;

  DatumDetails(
      {this.datum,
      this.index,
      this.domain,
      this.domainFormatter,
      this.domainLowerBound,
      this.domainUpperBound,
      this.measure,
      this.measureFormatter,
      this.measureLowerBound,
      this.measureUpperBound,
      this.measureOffset,
      this.rawMeasure,
      this.rawMeasureLowerBound,
      this.rawMeasureUpperBound,
      this.series,
      this.color,
      this.fillColor,
      this.fillPattern,
      this.areaColor,
      this.dashPattern,
      this.chartPosition,
      this.chartPositionLower,
      this.chartPositionUpper,
      this.bounds,
      this.domainDistance,
      this.measureDistance,
      this.relativeDistance,
      this.radiusPx,
      this.symbolRenderer,
      this.strokeWidthPx});

  factory DatumDetails.from(DatumDetails<D> other,
      {D? datum,
      int? index,
      D? domain,
      D? domainLowerBound,
      D? domainUpperBound,
      num? measure,
      MeasureFormatter? measureFormatter,
      num? measureLowerBound,
      num? measureUpperBound,
      num? measureOffset,
      num? rawMeasure,
      num? rawMeasureLowerBound,
      num? rawMeasureUpperBound,
      ImmutableSeries<D>? series,
      Color? color,
      Color? fillColor,
      FillPatternType? fillPattern,
      Color? areaColor,
      List<int>? dashPattern,
      NullablePoint? chartPosition,
      NullablePoint? chartPositionLower,
      NullablePoint? chartPositionUpper,
      Rectangle<int>? bounds,
      DomainFormatter<D>? domainFormatter,
      double? domainDistance,
      double? measureDistance,
      double? radiusPx,
      SymbolRenderer? symbolRenderer,
      double? strokeWidthPx}) {
    return DatumDetails<D>(
        datum: datum ?? other.datum,
        index: index ?? other.index,
        domain: domain ?? other.domain,
        domainFormatter: domainFormatter ?? other.domainFormatter,
        domainLowerBound: domainLowerBound ?? other.domainLowerBound,
        domainUpperBound: domainUpperBound ?? other.domainUpperBound,
        measure: measure ?? other.measure,
        measureFormatter: measureFormatter ?? other.measureFormatter,
        measureLowerBound: measureLowerBound ?? other.measureLowerBound,
        measureUpperBound: measureUpperBound ?? other.measureUpperBound,
        measureOffset: measureOffset ?? other.measureOffset,
        rawMeasure: rawMeasure ?? other.rawMeasure,
        rawMeasureLowerBound:
            rawMeasureLowerBound ?? other.rawMeasureLowerBound,
        rawMeasureUpperBound:
            rawMeasureUpperBound ?? other.rawMeasureUpperBound,
        series: series ?? other.series,
        color: color ?? other.color,
        fillColor: fillColor ?? other.fillColor,
        fillPattern: fillPattern ?? other.fillPattern,
        areaColor: areaColor ?? other.areaColor,
        dashPattern: dashPattern ?? other.dashPattern,
        chartPosition: chartPosition ?? other.chartPosition,
        chartPositionLower: chartPositionLower ?? other.chartPositionLower,
        chartPositionUpper: chartPositionUpper ?? other.chartPositionUpper,
        bounds: bounds ?? other.bounds,
        domainDistance: domainDistance ?? other.domainDistance,
        measureDistance: measureDistance ?? other.measureDistance,
        radiusPx: radiusPx ?? other.radiusPx,
        symbolRenderer: symbolRenderer ?? other.symbolRenderer,
        strokeWidthPx: radiusPx ?? other.strokeWidthPx);
  }

  String get formattedDomain =>
      (domainFormatter != null) ? domainFormatter!(domain!) : domain.toString();

  String get formattedMeasure => (measureFormatter != null)
      ? measureFormatter!(measure)
      : measure.toString();
}
