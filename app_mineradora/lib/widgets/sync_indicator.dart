import 'package:flutter/material.dart';

class SyncIndicator extends StatelessWidget {
  final bool isSyncing;
  final int pendingCount;
  final VoidCallback onTap;

  const SyncIndicator({
    super.key,
    required this.isSyncing,
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSyncing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSyncing ? Colors.blue : (pendingCount > 0 ? Colors.orange : Colors.green),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    pendingCount > 0 ? Icons.cloud_upload : Icons.cloud_done,
                    size: 16,
                    color: Colors.white,
                  ),
            const SizedBox(width: 4),
            Text(
              pendingCount > 0 ? '$pendingCount pendente(s)' : 'Sincronizado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}