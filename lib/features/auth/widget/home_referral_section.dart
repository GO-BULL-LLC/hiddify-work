import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/features/auth/notifier/auth_notifier.dart';
import 'package:hiddify/features/auth/widget/referral_widget.dart';
import 'package:hiddify/features/auth/widget/subscription_info_widget.dart';
import 'package:hiddify/features/auth/widget/server_list_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Section to show on home page for referral system, subscription and servers
class HomeReferralSection extends HookConsumerWidget {
  const HomeReferralSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    final userSession = authState.valueOrNull;
    if (userSession == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Subscription info (FREE tier, Trial, Comfort, Pro)
        const SubscriptionInfoWidget(),

        // Server list with locked/unlocked status
        const ServerListWidget(),

        // Referral section
        if (userSession.referral != null) _buildReferralSection(context, theme, userSession.referral!),
      ],
    );
  }

  Widget _buildReferralSection(BuildContext context, ThemeData theme, Referral referral) {
    // Show referral code card if user has one
    if (!referral.canApply) {
      return ReferralInfoCard(referral: referral);
    }

    // Show "apply referral code" button if user can still apply one
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            FluentIcons.gift_24_filled,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Вас пригласили?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Получите бонус за использование реферального кода',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ApplyReferralDialog(),
                );
              },
              icon: const Icon(FluentIcons.ticket_diagonal_24_filled),
              label: const Text(
                'Ввести код',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
