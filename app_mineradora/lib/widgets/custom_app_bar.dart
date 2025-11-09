import 'package:flutter/material.dart';
import 'package:app_mineradora/models/user.dart';
import 'package:app_mineradora/services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final User user;
  final VoidCallback onSync;
  final bool isSyncing;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.user,
    required this.onSync,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: isSyncing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.sync),
            onPressed: isSyncing ? null : onSync,
            tooltip: 'Sincronizar dados',
          ),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Text(
                user.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              child: const Text('Sair'),
              onTap: () async {
                await AuthService.instance.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}