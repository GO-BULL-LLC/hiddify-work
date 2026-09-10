import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/auth/data/auth_repository.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:hiddify/features/auth/notifier/auth_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Check if platform is Android TV - registration not allowed
    final isAndroidTv = defaultTargetPlatform == TargetPlatform.android &&
        (PlatformUtils.isDesktop); // TV builds use desktop layout

    if (isAndroidTv) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Регистрация'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.tv_24_filled,
                  size: 80,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Регистрация недоступна на Android TV',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Зарегистрируйтесь на мобильном устройстве или планшете',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Войти'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final step = useState<int>(1);
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState<bool>(false);
    final errorMessage = useState<String?>(null);
    final passwordVisible = useState<bool>(false);

    final appConfig = ref.watch(appConfigNotifierProvider);

    Future<void> requestCode() async {
      if (emailController.text.isEmpty) {
        errorMessage.value = 'Введите email';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        final repo = await ref.read(authRepositoryProvider.future);
        await repo.requestRegistrationCode(emailController.text.trim());
        step.value = 2;
      } on ApiError catch (e) {
        errorMessage.value = e.message;
        if (e.error == 'email_taken') {
          // Redirect to login
          await Future.delayed(const Duration(seconds: 2));
          if (context.mounted) {
            context.go('/login');
          }
        }
      } catch (e) {
        errorMessage.value = 'Ошибка при отправке кода';
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> completeRegistration() async {
      if (codeController.text.isEmpty || passwordController.text.isEmpty) {
        errorMessage.value = 'Заполните все поля';
        return;
      }

      if (passwordController.text.length < 6) {
        errorMessage.value = 'Пароль должен быть не менее 6 символов';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        await ref.read(authStateProvider.notifier).register(
              email: emailController.text.trim(),
              password: passwordController.text,
              code: codeController.text.trim(),
            );

        if (context.mounted) {
          context.go('/');
        }
      } on ApiError catch (e) {
        errorMessage.value = e.message;
        if (e.error == 'code_expired' ||
            e.error == 'bad_code' ||
            e.error == 'too_many_attempts') {
          // Allow requesting new code
          await Future.delayed(const Duration(seconds: 2));
          step.value = 1;
          codeController.clear();
        }
      } catch (e) {
        errorMessage.value = 'Ошибка при регистрации';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
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

              if (step.value == 1) ...[
                // Step 1: Email input
                Text(
                  'Введите email',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
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
                    errorText: errorMessage.value,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading.value ? null : requestCode,
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
                          'Получить код',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ] else ...[
                // Step 2: Code and password input
                Text(
                  'Код отправлен на ${emailController.text}',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: codeController,
                  enabled: !isLoading.value,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Код из письма',
                    hintText: '123456',
                    prefixIcon: const Icon(FluentIcons.key_24_filled),
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
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    hintText: 'Минимум 6 символов',
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
                  onPressed: isLoading.value ? null : completeRegistration,
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
                          'Зарегистрироваться',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading.value
                      ? null
                      : () {
                          step.value = 1;
                          codeController.clear();
                          errorMessage.value = null;
                        },
                  child: const Text('Запросить код повторно'),
                ),
              ],

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

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Уже есть аккаунт? '),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Войти',
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
