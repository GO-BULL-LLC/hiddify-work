import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:hiddify/features/auth/notifier/auth_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState<bool>(false);
    final errorMessage = useState<String?>(null);
    final passwordVisible = useState<bool>(false);

    final appConfig = ref.watch(appConfigNotifierProvider);

    Future<void> handleLogin() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        errorMessage.value = 'Заполните все поля';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        await ref.read(authStateProvider.notifier).login(
              emailController.text.trim(),
              passwordController.text,
            );

        if (context.mounted) {
          context.go('/');
        }
      } on ApiError catch (e) {
        errorMessage.value = e.message;
      } catch (e) {
        errorMessage.value = 'Ошибка при входе';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Logo
              Container(
                height: 120,
                alignment: Alignment.center,
                child: Icon(
                  FluentIcons.shield_checkmark_24_filled,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Go-Bull',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              Text(
                'Войдите в аккаунт',
                style: theme.textTheme.titleMedium,
              ),

              const SizedBox(height: 24),

              TextField(
                controller: emailController,
                enabled: !isLoading.value,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@mail.com',
                  prefixIcon: const Icon(FluentIcons.mail_24_filled),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                enabled: !isLoading.value,
                obscureText: !passwordVisible.value,
                onSubmitted: (_) => handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: const Icon(FluentIcons.lock_closed_24_filled),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible.value
                          ? FluentIcons.eye_24_filled
                          : FluentIcons.eye_off_24_filled,
                    ),
                    onPressed: () {
                      passwordVisible.value = !passwordVisible.value;
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  errorText: errorMessage.value,
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading.value ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Войти',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              // Support button
              if (appConfig.value?.supportUrl != null)
                OutlinedButton.icon(
                  onPressed: () {
                    launchUrl(
                      Uri.parse(appConfig.value!.supportUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  icon: const Icon(FluentIcons.chat_help_24_filled),
                  label: const Text('Поддержка'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет аккаунта? '),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      'Зарегистрироваться',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
