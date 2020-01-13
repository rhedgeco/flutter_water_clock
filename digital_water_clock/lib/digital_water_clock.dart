import 'dart:async';

import 'package:digital_water_clock/bucket_controller.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flare_flutter/flare_actor.dart';

enum _ThemeElements {
  backgroundColor,
  text,
  foreground,
}

final _lightTheme = {
  _ThemeElements.backgroundColor: Color(0xFF81B3FE),
  _ThemeElements.text: Color(0xFFFFFFFF),
};

final _darkTheme = {
  _ThemeElements.backgroundColor: Color(0xFF101010),
  _ThemeElements.text: Color(0xFFFFFFFF),
};

/// Based on the original google digital clock
class DigitalWaterClock extends StatefulWidget {
  const DigitalWaterClock(this.model);

  final ClockModel model;

  @override
  _DigitalWaterClockState createState() => _DigitalWaterClockState();
}

class _DigitalWaterClockState extends State<DigitalWaterClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  static final BucketController bucket3Controller = BucketController(
    bucketSize: 6.5,
    bucketLevels: 2,
  );
  static final BucketController bucket2Controller = BucketController(
    bucketSize: 3,
    bucketLevels: 3,
    targetBucket: bucket3Controller,
  );
  static final BucketController bucket1Controller = BucketController(
    bucketSize: 1.5,
    bucketLevels: 10,
    targetBucket: bucket2Controller,
  );

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalWaterClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 3.5;
    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_ThemeElements.text],
      fontFamily: 'Blow',
      fontSize: fontSize,
    );

    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.biggest.width; // capture area width for layouts
          double height = constraints.biggest.height; // capture area height for layouts
          return Stack(
            children: <Widget>[
              Positioned(
                right: width * -0.08, // arbitrary positioning for scene
                top: height * -0.15,
                width: width/2,
                height: height,
                child: Padding( // using padding to cut off bottom of water stream #PleaseDontHateMe
                  padding: EdgeInsets.only(bottom: height * 0.49),
                  child: FlareActor(
                    "assets/bucket.flr",
                    alignment: Alignment.topRight,
                    fit: BoxFit.fitWidth,
                    controller: bucket1Controller,
                  ),
                ),
              ),
              Positioned(
                right: width * -0.09, // arbitrary positioning for scene
                top: height * -0.055,
                width: width/1.4,
                height: height,
                child: Padding( // using padding to cut off bottom of water stream #PleaseDontHateMe
                  padding: EdgeInsets.only(bottom: height * 0.0),
                  child: FlareActor(
                    "assets/bucket.flr",
                    alignment: Alignment.topRight,
                    fit: BoxFit.fitWidth,
                    controller: bucket2Controller,
                  ),
                ),
              ),
              Positioned(
                right: width * 0.08, // arbitrary positioning for scene
                top: height * 0.38,
                width: width/1.4,
                height: height,
                child: FlareActor(
                  "assets/bucket.flr",
                  alignment: Alignment.topRight,
                  fit: BoxFit.fitWidth,
                  controller: bucket3Controller,
                ),
              ),
              RaisedButton(
                child: Text("Fill Bucket 1"),
                onPressed: () {
                  bucket1Controller.incrementLevel();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
