import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:hiddify/features/auth/notifier/auth_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Widget to display server list with locked/unlocked status
class ServerListWidget extends HookConsumerWidget {
  const ServerListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    final userSession = authState.valueOrNull;
    final servers = userSession?.servers;

    if (servers == null || servers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  FluentIcons.server_24_filled,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Серверы',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Server list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: servers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final server = servers[index];
              return _ServerTile(server: server);
            },
          ),
        ],
      ),
    );
  }
}

class _ServerTile extends StatelessWidget {
  final Server server;

  const _ServerTile({required this.server});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = server.locked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () {
                // Show upgrade dialog for locked servers
                _showUpgradeDialog(context, server);
              }
            : () {
                // TODO: Connect to server
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Подключение к ${server.name}')),
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Country flag or icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLocked
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    isLocked
                        ? FluentIcons.lock_closed_24_filled
                        : FluentIcons.location_24_filled,
                    color: isLocked
                        ? theme.colorScheme.outline
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Server info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      server.country,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.lock_closed_16_filled,
                        size: 12,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  FluentIcons.checkmark_circle_24_filled,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, Server server) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          FluentIcons.lock_closed_24_filled,
          color: theme.colorScheme.error,
          size: 48,
        ),
        title: const Text('Доступно на платном тарифе'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              server.lockMessage ??
                  'Этот сервер доступен только на платном тарифе.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Сервер: ${server.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to upgrade screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Переход на страницу тарифов'),
                ),
              );
            },
            icon: const Icon(FluentIcons.arrow_up_24_filled),
            label: const Text('Улучшить тариф'),
          ),
        ],
      ),
    );
  }
}
