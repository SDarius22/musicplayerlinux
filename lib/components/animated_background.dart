import 'package:flutter/material.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:provider/provider.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? normalColor;
  final Decoration? foregroundDecoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;


  AnimatedBackground({super.key, double? width,
    double? height,
    BoxConstraints? constraints, this.child, this.alignment, this.padding, this.normalColor, this.foregroundDecoration, this.margin, this.transform, this.transformAlignment, this.clipBehavior = Clip.none})
      : assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(constraints == null || constraints.debugAssertIsValid()),
        constraints =
        (width != null || height != null)
            ? constraints?.tighten(width: width, height: height)
            ?? BoxConstraints.tightFor(width: width, height: height)
            : constraints;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.initController(this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return AnimatedBuilder(
          animation: appState.gradientAnimation,
          builder: (context, child) {
            final color1 = Color.lerp(appState.darkColor, Color(0xFF0E0E0E), appState.gradientAnimation.value)!;
            final color2 = Color.lerp(Color(0xFF0E0E0E), appState.darkColor, appState.gradientAnimation.value)!;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: widget.alignment,
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [color2, color1],
                  stops: const [0.0, 1.0],
                ),
              ),
              foregroundDecoration: widget.foregroundDecoration,
              constraints: widget.constraints,
              margin: widget.margin,
              transform: widget.transform,
              transformAlignment: widget.transformAlignment,
              clipBehavior: widget.clipBehavior,
              child: widget.child,
            );
          },
        );
      },
    );
  }
}
