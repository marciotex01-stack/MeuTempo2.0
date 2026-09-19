import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usage_stats/usage_stats.dart';

class AppState extends ChangeNotifier {
  int _tempoEstudoNecessario = 20;
  int _tempoRecompensaGanho = 60;
  int _tempoEstudoUsado = 0;
  bool _monitoramentoAtivo = true;
  List<String> _listaAppsEstudo = ['com.duolingo', 'org.khanacademy'];
  List<String> _listaAppsJogo = ['com.roblox.client', 'com.mojang.minecraftpe'];

  int get tempoEstudoNecessario => _tempoEstudoNecessario;
  int get tempoRecompensaGanho => _tempoRecompensaGanho;
  int get tempoEstudoUsado => _tempoEstudoUsado;
  bool get monitoramentoAtivo => _monitoramentoAtivo;
  List<String> get listaAppsEstudo => _listaAppsEstudo;
  List<String> get listaAppsJogo => _listaAppsJogo;
  bool get ganhouRecompensa => _tempoEstudoUsado >= _tempoEstudoNecessario * 60;

  AppState() {
    _carregarDados();
    if (_monitoramentoAtivo) _iniciarMonitoramento();
  }

  void definirTempoEstudoNecessario(int min) {
    _tempoEstudoNecessario = min;
    _salvarDados();
    notifyListeners();
  }

  void definirTempoRecompensa(int min) {
    _tempoRecompensaGanho = min;
    _salvarDados();
    notifyListeners();
  }

  void alternarMonitoramento(bool ativo) {
    _monitoramentoAtivo = ativo;
    if (ativo) {
      _iniciarMonitoramento();
    }
    _salvarDados();
    notifyListeners();
  }

  void adicionarAppEstudo(String pacote) {
    if (!_listaAppsEstudo.contains(pacote)) {
      _listaAppsEstudo.add(pacote);
      _salvarDados();
      notifyListeners();
    }
  }

  void removerAppEstudo(String pacote) {
    _listaAppsEstudo.remove(pacote);
    _salvarDados();
    notifyListeners();
  }

  void adicionarAppJogo(String pacote) {
    if (!_listaAppsJogo.contains(pacote)) {
      _listaAppsJogo.add(pacote);
      _salvarDados();
      notifyListeners();
    }
  }

  void removerAppJogo(String pacote) {
    _listaAppsJogo.remove(pacote);
    _salvarDados();
    notifyListeners();
  }

  void zerarContador() {
    _tempoEstudoUsado = 0;
    _salvarDados();
    notifyListeners();
  }

  void _iniciarMonitoramento() async {
    // Verifica permissão e começa a verificar o tempo de uso
    _verificarUsoApps();
  }

  Future<void> _verificarUsoApps() async {
    final agora = DateTime.now();
    final inicio = agora.subtract(const Duration(hours: 24));

    try {
      final stats = await UsageStats.queryUsageStats(inicio, agora);
      int tempoTotal = 0;

      for (var uso in stats) {
        if (_listaAppsEstudo.contains(uso.packageName) && uso.totalTimeInForeground != null) {
          tempoTotal += (int.tryParse(uso.totalTimeInForeground!) ?? 0) ~/ 1000;
        }
      }

      if (tempoTotal != _tempoEstudoUsado) {
        _tempoEstudoUsado = tempoTotal;
        _salvarDados();
        notifyListeners();
      }
    } catch (e) {
      // Sem permissão ainda — aguardar
    }
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    _tempoEstudoNecessario = prefs.getInt('tempoEstudoNecessario') ?? 20;
    _tempoRecompensaGanho = prefs.getInt('tempoRecompensaGanho') ?? 60;
    _tempoEstudoUsado = prefs.getInt('tempoEstudoUsado') ?? 0;
    _monitoramentoAtivo = prefs.getBool('monitoramentoAtivo') ?? true;
    _listaAppsEstudo = prefs.getStringList('appsEstudo') ?? _listaAppsEstudo;
    _listaAppsJogo = prefs.getStringList('appsJogo') ?? _listaAppsJogo;
    notifyListeners();
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('tempoEstudoNecessario', _tempoEstudoNecessario);
    prefs.setInt('tempoRecompensaGanho', _tempoRecompensaGanho);
    prefs.setInt('tempoEstudoUsado', _tempoEstudoUsado);
    prefs.setBool('monitoramentoAtivo', _monitoramentoAtivo);
    prefs.setStringList('appsEstudo', _listaAppsEstudo);
    prefs.setStringList('appsJogo', _listaAppsJogo);
  }
}
