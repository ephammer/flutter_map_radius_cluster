import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_radius_cluster/src/controller/radius_cluster_controller.dart';
import 'package:provider/provider.dart';

import '../map_calculator.dart';
import '../radius_cluster_layer_options.dart';
import '../state/radius_cluster_state.dart';

class FixedOverlay extends StatelessWidget {
  final MapCalculator mapCalculator;
  final RadiusClusterController controller;
  final FixedOverlayBuilder searchButtonBuilder;

  const FixedOverlay({
    Key? key,
    required this.mapCalculator,
    required this.controller,
    required this.searchButtonBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radiusClusterState = context.watch<RadiusClusterState>();
    return _unrotated(
      searchButtonBuilder(context, controller, radiusClusterState),
    );
  }

  Widget _unrotated(Widget overlay) {
    if (mapCalculator.mapState.rotationRad == 0) return overlay;

    final mapState = mapCalculator.mapState;
    final CustomPoint<num> size = mapState.size;
    final sizeChangeDueToRotation =
        size - (mapState.originalSize ?? mapState.size) as CustomPoint<double>;
    return Positioned.fill(
      top: sizeChangeDueToRotation.y / 2,
      bottom: sizeChangeDueToRotation.y / 2,
      left: sizeChangeDueToRotation.x / 2,
      right: sizeChangeDueToRotation.x / 2,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateZ(-mapState.rotationRad),
        child: overlay,
      ),
    );
  }
}
