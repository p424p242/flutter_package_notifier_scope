import 'package:example/notifiers/counter.notifier.dart';
import 'package:example/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:notifier_scope/notifier_scope.dart';

class CounterCard extends StatelessWidget {
  const CounterCard({
    super.key,
    required this.title,
    required this.notifier,
  });

  final String title;
  final NotifierScope<CounterNotifier> notifier;

  @override
  Widget build(BuildContext context) {
    return _buildCardContent(context);
  }

  Widget _buildCardContent(BuildContext context) {
    return NotifierBuilder(
      (context) => Card(
        margin: EdgeInsets.all(context.mediumSpacing),
        elevation: context.mediumElevation,
        shape: RoundedRectangleBorder(borderRadius: context.largeBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(context.largeSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: context.titleLarge.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.mediumSpacing),
              Container(
                padding: EdgeInsets.all(context.mediumSpacing),
                decoration: BoxDecoration(
                  color: context.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: context.mediumBorderRadius,
                  border: Border.all(
                    color: context.secondaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${notifier.instance.state.count ?? "Not initialized"}',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: context.mediumSpacing),
              if (notifier.instance.state.isIncrementing)
                SizedBox(
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.primaryColor,
                      ),
                    ),
                  ),
                ),
              if (!notifier.instance.state.isIncrementing)
                ElevatedButton(
                  onPressed: () => notifier.instance.increment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: context.mediumBorderRadius),
                    padding: EdgeInsets.symmetric(horizontal: context.extraLargeSpacing, vertical: context.mediumSpacing),
                  ),
                  child: Text(
                    'Increment',
                    style: context.buttonStyle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}