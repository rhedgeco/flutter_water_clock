import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controls.dart';

class BucketController extends FlareControls {
  double _tipTime = double.infinity;
  double _riseTime = 5.0;
  double _currentRise = 0.0;
  int _currentLevel = 0;
  int _lastLevel = 0;

  FlutterActorArtboard _artboard;
  FlareAnimationLayer _tip;
  FlareAnimationLayer _idleWater;
  FlareAnimationLayer _waterLevel;

  ActorNode _bucketSizeNode;

  double bucketSize = 1.0;
  int bucketLevels = 60;
  BucketController targetBucket;

  BucketController({this.bucketSize, this.bucketLevels, this.targetBucket});

  void forceLevel(int level) {
    _waterLevel.time = level/bucketLevels * _waterLevel.duration;
  }

  void _rise(double delay, double time) {
    new Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
      _lastLevel = _currentLevel;
      _currentLevel = _currentLevel + 1;
      _riseTime = time;
      _currentRise = 0.0;
    });
  }

  void setPour() {
    _rise(1, 0.85);
  }

  void incrementLevel() {
    _rise(0, 0.1);
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _artboard = artboard;
    _tip = FlareAnimationLayer()
      ..animation = _artboard.getAnimation("bucket_tip")
      ..mix = 0.0;
    _idleWater = FlareAnimationLayer()
      ..animation = _artboard.getAnimation("idle_water")
      ..mix = 1.0;
    _waterLevel = FlareAnimationLayer()
      ..animation = _artboard.getAnimation("water_level")
      ..mix = 1.0;
    _bucketSizeNode = _artboard.getNode("BucketScale");
    _bucketSizeNode.scaleX = bucketSize;
    _bucketSizeNode.scaleY = bucketSize;

    _waterLevel.time = _currentLevel * _waterLevel.duration;
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    // Animate constant water animation
    _idleWater.time = (_idleWater.time + elapsed) % _idleWater.duration;
    _idleWater.apply(artboard);

    if (_waterLevel.time >= 29.99 && _tipTime >= _tip.duration) {
      _currentLevel = 0;
      _lastLevel = 0;
      _waterLevel.time = 0.0;
      _tipTime = 0.0;
      if (targetBucket != null) targetBucket.setPour();
    }

    _tipTime = _tipTime + elapsed;
    if (_tipTime > _tip.duration) {
      _tip.mix = 0.0;
      _waterLevel.mix = 1.0;
      if (_currentRise <= _riseTime) {
        _currentRise += elapsed;
        _waterLevel.time = _lerpDouble(
          _lastLevel / bucketLevels * _waterLevel.duration,
          _currentLevel / bucketLevels * _waterLevel.duration,
          _currentRise / _riseTime,
        );
      }
    } else {
      _tip.mix = 1.0;
      _waterLevel.mix = 0.0;
      _waterLevel.time = 0.0;
    }

    _tip.time = _tipTime;
    _tip.apply(artboard);

    _waterLevel.apply(artboard);

    return true;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  double _lerpDouble(double a, double b, double value) {
    return ((b - a) * value) + a;
  }
}
