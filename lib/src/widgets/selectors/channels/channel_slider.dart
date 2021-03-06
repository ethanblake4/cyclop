import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'hsl_selector.dart';

class ChannelSlider extends StatelessWidget {
  final Color selectedColor;

  final List<Color> colors;

  final String label;

  final ValueChanged<double> onChange;

  final ChannelValueGetter channelValueGetter;

  final ValueLabelGetter labelGetter;

  const ChannelSlider({
    Key key,
    @required this.selectedColor,
    @required this.colors,
    @required this.channelValueGetter,
    @required this.onChange,
    @required this.label,
    @required this.labelGetter,
  }) : super(key: key);

  double get channelValue => channelValueGetter(selectedColor);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(label, style: textTheme.subtitle2),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Theme(
                  data: _sliderTheme(selectedColor, colors),
                  child: Slider(
                    value: channelValue,
                    min: 0.0,
                    max: 1,
                    divisions: 100,
                    onChanged: onChange,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                width: 60,
                child: Text(
                  labelGetter != null ? labelGetter(selectedColor) : '/',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyText1,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

ThemeData _sliderTheme(Color color, List<Color> colors) =>
    ThemeData.light().copyWith(
      sliderTheme: SliderThemeData(
        trackHeight: 24,
        thumbColor: Colors.white,
        trackShape: ChannelSliderTrack(color, colors),
      ),
    );

class ChannelSliderTrack extends SliderTrackShape with BaseSliderTrackShape {
  final Color selectedColor;
  final List<Color> colors;

  const ChannelSliderTrack(this.selectedColor, this.colors);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    final Paint activePaint = Paint()..color = Colors.transparent;

    final Paint inactivePaint = Paint()
      ..shader = ui.Gradient.linear(
          Offset.zero, Offset(trackRect.width, 0), colors, _impliedStops()
          /*colorStops,*/
          );

    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final thumbRadius = 14;

    final shapeRect = RRect.fromLTRBAndCorners(
      trackRect.left - thumbRadius,
      (textDirection == TextDirection.ltr)
          ? trackRect.top - (additionalActiveTrackHeight / 2)
          : trackRect.top,
      trackRect.right + thumbRadius,
      (textDirection == TextDirection.ltr)
          ? trackRect.bottom + (additionalActiveTrackHeight / 2)
          : trackRect.bottom,
      topLeft: (textDirection == TextDirection.ltr)
          ? activeTrackRadius
          : trackRadius,
      bottomLeft: (textDirection == TextDirection.ltr)
          ? activeTrackRadius
          : trackRadius,
      topRight: (textDirection == TextDirection.ltr)
          ? activeTrackRadius
          : trackRadius,
      bottomRight: (textDirection == TextDirection.ltr)
          ? activeTrackRadius
          : trackRadius,
    );

    context.canvas.drawRRect(shapeRect, leftTrackPaint);
    context.canvas.drawRRect(shapeRect, rightTrackPaint);
  }

  List<double> _impliedStops() {
    assert(colors.length >= 2, 'colors list must have at least two colors');
    final double separation = 1.0 / (colors.length - 1);
    return List<double>.generate(
      colors.length,
      (int index) => index * separation,
      growable: false,
    );
  }
}
