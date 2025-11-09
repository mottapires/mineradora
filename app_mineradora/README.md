# App Mineradora Areal

Aplicativo mobile para controle de entrada e saída de veículos de uma mineradora, com sincronização offline.

## Funcionalidades

- Login com perfis diferenciados (Operador e Apontador)
- Registro de carregamentos (Operador)
- Registro de saídas (Apontador)
- Armazenamento local para funcionamento offline
- Sincronização automática quando há conexão com a internet
- Detecção automática de conectividade
- Interface adaptada para ambientes com pouca conectividade

## Tecnologias

- Flutter
- SQLite (sqflite)
- HTTP Client
- Flutter Secure Storage
- Connectivity Plus

## Estrutura do Projeto

```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── loading_record.dart
│   └── unloading_record.dart
├── services/
│   ├── database_service.dart
│   ├── api_service.dart
│   └── auth_service.dart
├── screens/
│   ├── login_screen.dart
│   ├── operator_screen.dart
│   └── pointer_screen.dart
├── widgets/
│   ├── custom_app_bar.dart
│   └── sync_indicator.dart
└── utils/
    └── constants.dart
```

## Configuração

1. Instale as dependências:
   ```
   flutter pub get
   ```

2. Execute o aplicativo:
   ```
   flutter run
   ```

## Compilação

Para gerar o APK:
```
flutter build apk
```

Para gerar o App Bundle:
```
flutter build appbundle
```

## Deploy

O aplicativo pode ser compilado e distribuído usando:

1. **GitHub Actions** (gratuito) - Configuração automática via workflow
2. **Codemagic** (500 minutos gratuitos por mês)
3. **FlutterFlow** (opção alternativa)

## Considerações sobre a API

O aplicativo se comunica com a API existente do sistema web. Os endpoints utilizados são:
- `/api/login.php` - Autenticação de usuários
- `/api/operador-sync.php` - Sincronização de registros de operador
- `/api/apontador-sync.php` - Sincronização de registros de apontador
- `/api/get_config.php` - Obtenção de configurações do sistema

## Funcionamento Offline

O aplicativo armazena todos os registros localmente no SQLite e os sincroniza com o servidor quando há conectividade. 
Os dados permanecem disponíveis mesmo sem internet, garantindo continuidade das operações em ambientes com 
conectividade instável.