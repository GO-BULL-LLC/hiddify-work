import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hiddify/features/auth/data/auth_repository.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:hiddify/features/auth/notifier/auth_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Widget to display user's referral code and share link
class ReferralInfoCard extends HookConsumerWidget {
  final Referral referral;

  const ReferralInfoCard({
    required this.referral,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FluentIcons.people_24_filled,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Реферальная программа',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Referral code
            Text(
              'Ваш код:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    referral.code,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.copy_24_filled),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: referral.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Код скопирован')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Приглашено',
                    value: '${referral.invitedCount}',
                    icon: FluentIcons.people_add_24_filled,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Бонус',
                    value: '${referral.bonusPercent}%',
                    icon: FluentIcons.gift_24_filled,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Share.share(
                    'Присоединяйся к Go-Bull! Используй мой реферальный код: ${referral.code}\n\n${referral.shareLink}',
                    subject: 'Приглашение в Go-Bull',
                  );
                },
                icon: const Icon(FluentIcons.share_24_filled),
                label: const Text(
                  'Поделиться',
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
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Dialog to apply referral code
class ApplyReferralDialog extends HookConsumerWidget {
  const ApplyReferralDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final codeController = useTextEditingController();
    final isLoading = useState<bool>(false);
    final errorMessage = useState<String?>(null);

    Future<void> applyCode() async {
      if (codeController.text.isEmpty) {
        errorMessage.value = 'Введите реферальный код';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        final repo = await ref.read(authRepositoryProvider.future);
        await repo.applyReferral(codeController.text.trim());

        // Refresh session to get updated referral status
        await ref.read(authStateProvider.notifier).refreshSession();

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Реферальный код применен!')),
          );
        }
      } on ApiError catch (e) {
        errorMessage.value = e.message;
      } catch (e) {
        errorMessage.value = 'Ошибка при применении кода';
      } finally {
        isLoading.value = false;
      }
    }

    return AlertDialog(
      title: const Text('Реферальный код'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Вас пригласили? Введите реферальный код:'),
          const SizedBox(height: 16),
          TextField(
            controller: codeController,
            enabled: !isLoading.value,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Код',
              hintText: 'ABC123',
              prefixIcon: const Icon(FluentIcons.ticket_diagonal_24_filled),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              errorText: errorMessage.value,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: isLoading.value ? null : applyCode,
          child: isLoading.value
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Применить'),
        ),
      ],
    );
  }
}
