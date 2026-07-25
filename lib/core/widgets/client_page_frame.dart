import 'package:flutter/material.dart';

class ClientPageFrame extends StatelessWidget {
  const ClientPageFrame({
    required this.child,
    super.key,
    this.title,
    this.actions = const [],
    this.maxWidth = 560,
  });

  final Widget child;
  final String? title;
  final List<Widget> actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 6, color: scheme.primary),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                        minHeight: constraints.maxHeight - 60,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
