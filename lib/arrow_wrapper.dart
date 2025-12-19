import 'package:flutter/material.dart';


enum ArrowPosition { top, bottom, left, right }


class ArrowWrapper extends StatefulWidget {
  final Widget widget;
  final void Function(ArrowPosition position) onArrowPressed;

  /// Arrows that should NOT be shown
  final List<ArrowPosition> hiddenArrows;

  const ArrowWrapper({
    super.key,
    required this.widget,
    required this.onArrowPressed,
    this.hiddenArrows = const [],
  });

  @override
  State<ArrowWrapper> createState() => _ArrowWrapperState();
}

class _ArrowWrapperState extends State<ArrowWrapper> {
  bool _hovering = false;

  bool _showArrow(ArrowPosition position) {
    return !widget.hiddenArrows.contains(position);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(50),
            child: widget.widget,
          ),
      
          /// Arrows
          if (_hovering) ...[
            // Top arrow
            if (_showArrow(ArrowPosition.top))
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: ArrowButton(
                    icon: Icons.arrow_upward,
                    position: ArrowPosition.top,
                    onTap: () =>
                        widget.onArrowPressed(ArrowPosition.top),
                  ),
                ),
              ),
      
            // Bottom arrow
            if (_showArrow(ArrowPosition.bottom))
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: ArrowButton(
                    icon: Icons.arrow_downward,
                    position: ArrowPosition.bottom,
                    onTap: () =>
                        widget.onArrowPressed(ArrowPosition.bottom),
                  ),
                ),
              ),
      
            // Left arrow
            if (_showArrow(ArrowPosition.left))
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ArrowButton(
                    icon: Icons.arrow_back,
                    position: ArrowPosition.left,
                    onTap: () =>
                        widget.onArrowPressed(ArrowPosition.left),
                  ),
                ),
              ),
      
            // Right arrow
            if (_showArrow(ArrowPosition.right))
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ArrowButton(
                    icon: Icons.arrow_forward,
                    position: ArrowPosition.right,
                    onTap: () =>
                        widget.onArrowPressed(ArrowPosition.right),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// --------------------------------------------
/// ArrowButton
/// --------------------------------------------


class ArrowButton extends StatefulWidget {
  final IconData icon;
  final ArrowPosition position;
  final VoidCallback? onTap;

  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final EdgeInsets padding;

  const ArrowButton({
    super.key,
    required this.icon,
    required this.position,
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.iconColor = Colors.blue,
    this.iconSize = 36,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  State<ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<ArrowButton>
    with TickerProviderStateMixin {  // Changed from SingleTickerProviderStateMixin
  bool _isHovered = false;

  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final AnimationController _hoverController;
  late final Animation<double> _scale;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _slide = Tween<Offset>(
      begin: _getStartOffset(widget.position),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  Offset _getStartOffset(ArrowPosition position) {
    switch (position) {
      case ArrowPosition.left:
        return const Offset(-0.25, 0);
      case ArrowPosition.right:
        return const Offset(0.25, 0);
      case ArrowPosition.top:
        return const Offset(0, -0.25);
      case ArrowPosition.bottom:
        return const Offset(0, 0.25);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setState(() => _isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverController.reverse();
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: ScaleTransition(
                scale: _scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.icon,
                    color: _isHovered ? Colors.green : widget.iconColor,
                    size: widget.iconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
