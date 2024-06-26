import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_radius_cluster/src/controller/radius_cluster_controller.dart';
import 'package:flutter_map_radius_cluster/src/map_camera_extension.dart';

import '../radius_cluster_layer.dart';
import '../state/radius_cluster_state.dart';

class FixedOverlay extends StatelessWidget {
  final MapCamera camera;
  final RadiusClusterController controller;
  final FixedOverlayBuilder searchButtonBuilder;

  const FixedOverlay({
    super.key,
    required this.camera,
    required this.controller,
    required this.searchButtonBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final radiusClusterState = RadiusClusterState.of(context);
    return _unrotated(
      searchButtonBuilder(context, controller, radiusClusterState),
    );
  }

  Widget _unrotated(Widget overlay) {
    if (camera.rotationRad == 0) return overlay;

    final sizeChangeDueToRotation = camera.sizeChangeDueToRotation;
    return Positioned.fill(
      top: sizeChangeDueToRotation.y / 2,
      bottom: sizeChangeDueToRotation.y / 2,
      left: sizeChangeDueToRotation.x / 2,
      right: sizeChangeDueToRotation.x / 2,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateZ(-camera.rotationRad),
        child: overlay,
      ),
    );
  }
}
