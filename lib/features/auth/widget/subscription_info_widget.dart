import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:hiddify/features/auth/notifier/auth_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Widget to display subscription info on home page
class SubscriptionInfoWidget extends HookConsumerWidget {
  const SubscriptionInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    final userSession = authState.valueOrNull;
    if (userSession?.subscription == null) return const SizedBox.shrink();

    final subscription = userSession!.subscription!;
    final plan = subscription.plan;

    // Plan colors and icons
    final (planColor, planIcon, planLabel) = _getPlanStyle(plan.code, theme);

    // Check if subscription is expired (only for non-free plans)
    final isExpired = subscription.expiresAt != null &&
        subscription.expiresAt!.isBefore(DateTime.now());

    // For FREE tier: never show expiration, always show as active
    final isFree = plan.code == 'free';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            planColor.withOpacity(0.15),
            planColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: planColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Plan icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: planColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              planIcon,
              color: planColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Plan info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      planLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: planColor,
                      ),
                    ),
                    if (isFree) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'БЕСПЛАТНО',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                if (isFree)
                  // FREE tier: show upgrade prompt
                  Text(
                    'Доступ к одному серверу',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                else if (isExpired)
                  // Expired paid subscription
                  Row(
                    children: [
                      Icon(
                        FluentIcons.warning_24_filled,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Подписка истекла',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  )
                else if (subscription.expiresAt != null)
                  // Active paid subscription with expiry date
                  Text(
                    'До ${DateFormat('dd.MM.yyyy').format(subscription.expiresAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                else
                  // Active subscription without expiry
                  Text(
                    'Активна',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),

          // Upgrade button for free tier
          if (isFree)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to pricing/upgrade screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Обновление до платного тарифа'),
                  ),
                );
              },
              icon: const Icon(FluentIcons.arrow_up_24_filled, size: 16),
              label: const Text(
                'Улучшить',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getPlanStyle(String planCode, ThemeData theme) {
    switch (planCode.toLowerCase()) {
      case 'free':
        return (
          theme.colorScheme.outline,
          FluentIcons.star_24_regular,
          'Бесплатный'
        );
      case 'trial':
        return (
          theme.colorScheme.tertiary,
          FluentIcons.timer_24_filled,
          'Пробный (Комфорт)'
        );
      case 'comfort':
        return (
          theme.colorScheme.primary,
          FluentIcons.checkmark_circle_24_filled,
          'Комфорт'
        );
      case 'pro':
        return (
          const Color(0xFFFFD700), // Gold
          FluentIcons.crown_24_filled,
          'Профессиональный'
        );
      default:
        return (
          theme.colorScheme.primary,
          FluentIcons.info_24_filled,
          planCode
        );
    }
  }
}
