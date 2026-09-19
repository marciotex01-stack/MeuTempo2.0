import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';

class PermissionHelper {
  static Future<void> verificarPermissoes(BuildContext context) async {
    bool temPermissao = await UsageStats.checkUsagePermission();

    if (!temPermissao) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('📊 Permissão Necessária'),
            content: const Text(
              'Para contabilizar o tempo de estudo, o app precisa acessar o uso dos aplicativos.\n\n'
              'Na próxima tela, selecione "Estudo → Recompensa" e ative a permissão.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  UsageStats.requestUsagePermission();
                },
                child: const Text('Conceder Permissão', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Permissão já concedida! Monitorando...')),
        );
      }
    }
  }
}
