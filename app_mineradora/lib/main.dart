import 'package:flutter/material.dart';
import 'package:app_mineradora/screens/login_screen.dart';
import 'package:app_mineradora/screens/operator_screen.dart';
import 'package:app_mineradora/screens/pointer_screen.dart';
import 'package:app_mineradora/services/auth_service.dart';
import 'package:app_mineradora/models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mineradora Areal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: AuthService.instance.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // Redirecionar com base no perfil do usuário
          if (user.idPerfil == 4) { // PERFIL_OPERADOR
            return OperatorScreen(user: user);
          } else if (user.idPerfil == 5) { // PERFIL_APONTADOR
            return PointerScreen(user: user);
          } else {
            // Se o usuário tiver um perfil não suportado, redirecionar para login
            AuthService.instance.logout();
            return const LoginScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}