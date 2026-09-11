# Authentication Feature

Система авторизации для Go-Bull с интеграцией API на `up-bull.space/api/v1`.

## Функциональность

### 1. FREE Tier (2026-09-11)
- Новый тариф для неплатящих пользователей
- `subscription.plan.code="free"`, `status="active"`, `expires_at=null`
- **НЕ показывать "подписка истекла"** для FREE тарифа
- Доступ к одному бесплатному серверу (Варшава)
- Остальные серверы: `locked:true`, `lock_reason:"paid_required"`, `available:false`
- UI показывает апселл "Доступно на платном тарифе" (текст в `lock_message`)
- Тарифная сетка: **free < trial(=Комфорт) < comfort < pro**

### 2. Регистрация по коду из email
- Двухшаговая регистрация
- Шаг 1: Ввод email и запрос кода (POST `/api/v1/auth/register/request-code`)
- Шаг 2: Ввод кода и пароля (POST `/api/v1/auth/register`)
- Недоступна на Android TV (только мобильные устройства и планшеты)

### 2. Вход
- Стандартная авторизация по email/password
- POST `/api/v1/auth/login`

### 3. Реферальная система
- Показ своего реферального кода с возможностью поделиться
- Применение реферального кода при первой регистрации
- POST `/api/v1/referral/apply`

### 4. Кнопка поддержки
- Показывается на экранах входа и регистрации
- URL берется из `/api/v1/app-config` (поле `support_url`)

## Структура

```
lib/features/auth/
├── models/
│   └── auth_models.dart          # Модели данных (freezed)
├── data/
│   ├── auth_api_client.dart      # API клиент (Dio)
│   └── auth_repository.dart      # Репозиторий с логикой
├── notifier/
│   └── auth_notifier.dart        # State management (Riverpod)
├── widget/
│   ├── register_screen.dart           # Экран регистрации
│   ├── login_screen.dart              # Экран входа
│   ├── referral_widget.dart           # Виджеты реферальной системы
│   ├── subscription_info_widget.dart  # Виджет информации о тарифе
│   ├── server_list_widget.dart        # Список серверов с lock status
│   └── home_referral_section.dart     # Секция на главном экране
└── README.md
```

## Интеграция с роутером

В `app_router.dart` добавлена проверка авторизации:
1. Если пользователь не авторизован → редирект на `/login`
2. Если авторизован → проверка подписки go_bull

Новые маршруты:
- `/register` - регистрация
- `/login` - вход

## API Endpoints

### Без авторизации:
- `GET /api/v1/app-config` - конфигурация приложения
- `POST /api/v1/auth/register/request-code` - запрос кода регистрации
- `POST /api/v1/auth/register` - регистрация
- `POST /api/v1/auth/login` - вход

### С авторизацией (Bearer token):
- `GET /api/v1/session` - информация о сессии + referral + subscription + servers
  - `subscription`: план (free/trial/comfort/pro), статус, дата истечения
  - `servers`: список серверов с полями locked/lock_reason/lock_message
- `POST /api/v1/referral/apply` - применить реферальный код

## Headers

Все запросы к API содержат:
- `X-Device-Platform`: `android`
- `X-Hwid`: уникальный ID устройства
- `X-App-Lang`: `ru`
- `X-App-Build`: версия приложения

## Генерация кода

После изменения моделей запустите:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Это сгенерирует:
- `auth_models.freezed.dart`
- `auth_models.g.dart`
- `auth_repository.g.dart`
- `auth_notifier.g.dart`
