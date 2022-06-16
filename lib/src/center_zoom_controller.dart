import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_radius_cluster/flutter_map_radius_cluster.dart';
import 'package:latlong2/latlong.dart';

import 'center_zoom_tween.dart';

class CenterZoomController {
  final TickerProvider _vsync;
  final MapState mapState;
  AnimationController? _zoomController;
  CurvedAnimation? _animation;
  double? _velocity;
  static const distanceCalculator = Distance();

  CenterZoomController({
    required TickerProvider vsync,
    required this.mapState,
    required AnimationOptions animationOptions,
  }) : _vsync = vsync {
    this.animationOptions = animationOptions;
  }

  set animationOptions(AnimationOptions animationOptions) {
    _zoomController?.stop(canceled: false);
    _zoomController?.dispose();

    if (animationOptions is AnimationOptionsAnimate) {
      _zoomController = AnimationController(
        vsync: _vsync,
        duration: animationOptions.duration,
      );
      _animation = CurvedAnimation(
        parent: _zoomController!,
        curve: animationOptions.curve,
      );
      _velocity = animationOptions.velocity;
    } else if (animationOptions is AnimationOptionsNoAnimation) {
      _velocity = null;
      _zoomController = null;
      _animation = null;
    }
  }

  void dispose() {
    _zoomController?.dispose();
    _zoomController = null;
  }

  void moveTo(CenterZoom centerZoom) {
    if (_zoomController == null) {
      mapState.move(
        centerZoom.center,
        centerZoom.zoom,
        source: MapEventSource.custom,
      );
    } else {
      _animateTo(centerZoom);
    }
  }

  void _animateTo(CenterZoom centerZoom) {
    final begin = CenterZoom(
      center: mapState.center,
      zoom: mapState.zoom,
    );
    final end = CenterZoom(
      center: LatLng(centerZoom.center.latitude, centerZoom.center.longitude),
      zoom: centerZoom.zoom,
    );
    final centerZoomTween = CenterZoomTween(begin: begin, end: end);

    if (_velocity != null) _setDynamicDuration(_velocity!, begin, end);

    final listener = _movementListener(centerZoomTween);
    _zoomController!.addListener(listener);
    _zoomController!.forward().then((_) {
      _zoomController!
        ..removeListener(listener)
        ..reset();
    });
  }

  void _setDynamicDuration(double velocity, CenterZoom begin, CenterZoom end) {
    final pixelsTranslated =
        mapState.project(begin.center).distanceTo(mapState.project(end.center));
    final portionOfScreenTranslated =
        pixelsTranslated / ((mapState.size.x + mapState.size.y) / 2);
    final translateVelocity =
        ((portionOfScreenTranslated * 400) * velocity).round();

    final zoomDistance = (begin.zoom - end.zoom).abs();
    final zoomVelocity = 100 + (velocity * 175 * zoomDistance).round();

    _zoomController!.duration =
        Duration(milliseconds: min(max(translateVelocity, zoomVelocity), 2000));
  }

  VoidCallback _movementListener(Tween<CenterZoom> centerZoomTween) {
    return () {
      final centerZoom = centerZoomTween.evaluate(_animation!);
      mapState.move(
        centerZoom.center,
        centerZoom.zoom,
        source: MapEventSource.custom,
      );
    };
  }
}
