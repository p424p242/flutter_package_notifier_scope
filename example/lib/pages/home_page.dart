import 'package:example/notifiers/theme_mode.notifier.dart';
import 'package:example/pages/page_1.dart';
import 'package:example/pages/page_2.dart';
import 'package:example/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:notifier_scope/notifier_scope.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      (context) => Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          title: const Text('Notifier Scope Demo'),
          actions: [
            IconButton(
              icon: Icon(
                themeModeNotifier.instance.state.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => themeModeNotifier.instance.toggleThemeMode(),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: context.mediumElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: context.largeBorderRadius,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.largeSpacing),
                    child: Column(
                      children: [
                        Text('Notifier Scope Demo', style: context.titleLarge),
                        SizedBox(height: context.mediumSpacing),
                        Text(
                          'This example demonstrates the difference between global and scoped notifiers:',
                          textAlign: TextAlign.center,
                          style: context.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          'Counter A: Global notifier (shared state)',
                          context,
                        ),
                        _buildFeatureItem(
                          'Counter B: Scoped notifier (independent state)',
                          context,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildSimpleButton(
                  context: context,
                  text: "Go to Page 1",
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Page1()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSimpleButton(
                  context: context,
                  text: "Go to Page 2",
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Page2()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.extraSmallSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 8, color: context.primaryColor),
          SizedBox(width: context.smallSpacing),
          Expanded(child: Text(text, style: context.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildSimpleButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.primaryColor,
        foregroundColor: context.onPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: context.mediumBorderRadius,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.extraLargeSpacing,
          vertical: context.mediumSpacing,
        ),
      ),
      child: Text(text, style: context.buttonStyle),
    );
  }
}
