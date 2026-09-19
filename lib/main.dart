import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'permission_helper.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estudo → Recompensa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 Estudo → Recompensa 🎮')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaCrianca())),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  minimumSize: const Size(double.infinity, 120),
                ),
                child: const Text('👧 Área da Criança', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaResponsavel())),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  minimumSize: const Size(double.infinity, 120),
                  backgroundColor: Colors.green,
                ),
                child: const Text('👨‍👩‍👧 Área dos Responsáveis', style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaCrianca extends StatelessWidget {
  const TelaCrianca({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<AppState>(context);
    final minEstudo = (estado.tempoEstudoUsado ~/ 60);
    final segEstudo = estado.tempoEstudoUsado % 60;
    final minNecessario = estado.tempoEstudoNecessario;
    final minRecompensa = estado.tempoRecompensaGanho;
    final falta = (minNecessario * 60 - estado.tempoEstudoUsado);

    return Scaffold(
      appBar: AppBar(title: const Text('📚 Meu Progresso')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏱️ Tempo de Estudo Detectado', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Text(
                '${minEstudo.toString().padLeft(2, '0')}:${segEstudo.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: (estado.tempoEstudoUsado / (minNecessario * 60)).clamp(0.0, 1.0),
                minHeight: 12,
              ),
              const SizedBox(height: 20),

              falta > 0
                  ? Text(
                      'Faltam ${(falta / 60).ceil()} minutos de estudo para ganhar $minRecompensa min de jogo! 🎮',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    )
                  : Column(
                      children: [
                        const Text('🎉 PARABÉNS! VOCÊ CONSEGUIU! 🎉',
                            style: TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text('🎮 Você ganhou $minRecompensa minutos de jogo!', style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => estado.zerarContador(),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                          child: const Text('🔄 Começar Novo Ciclo', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => PermissionHelper.verificarPermissoes(context),
                icon: const Icon(Icons.security),
                label: const Text('✅ Verificar Permissões', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaResponsavel extends StatelessWidget {
  const TelaResponsavel({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('👨‍👩‍👧 Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('⏱️ Tempo de Estudo Necessário:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Slider(
            min: 5, max: 60, divisions: 11,
            label: '${estado.tempoEstudoNecessario} min',
            value: estado.tempoEstudoNecessario.toDouble(),
            onChanged: (v) => estado.definirTempoEstudoNecessario(v.toInt()),
          ),
          Text('👉 ${estado.tempoEstudoNecessario} minutos', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),

          const Text('🎮 Tempo de Recompensa (Jogo):', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Slider(
            min: 10, max: 120, divisions: 11,
            label: '${estado.tempoRecompensaGanho} min',
            value: estado.tempoRecompensaGanho.toDouble(),
            onChanged: (v) => estado.definirTempoRecompensa(v.toInt()),
          ),
          Text('👉 ${estado.tempoRecompensaGanho} minutos', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),

          const Divider(thickness: 2),
          const SizedBox(height: 20),

          SwitchListTile(
            title: const Text('📊 Monitorar aplicativos automaticamente', style: TextStyle(fontSize: 18)),
            subtitle: const Text('Conta tempo de estudo real dos apps selecionados'),
            value: estado.monitoramentoAtivo,
            onChanged: (v) => estado.alternarMonitoramento(v),
          ),
          const SizedBox(height: 20),

          const Text('📱 Apps de Estudo Permitidos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...estado.listaAppsEstudo.map((app) => ListTile(
                title: Text(app),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => estado.removerAppEstudo(app),
                ),
              )),
          ElevatedButton.icon(
            onPressed: () => estado.adicionarAppEstudo('Ex: Duolingo, Khan Academy'),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar App de Estudo'),
          ),
          const SizedBox(height: 30),

          const Text('🎮 Apps de Jogo (Recompensa):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...estado.listaAppsJogo.map((app) => ListTile(
                title: Text(app),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => estado.removerAppJogo(app),
                ),
              )),
          ElevatedButton.icon(
            onPressed: () => estado.adicionarAppJogo('Ex: Roblox, Minecraft'),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar App de Jogo'),
          ),
        ],
      ),
    );
  }
}
