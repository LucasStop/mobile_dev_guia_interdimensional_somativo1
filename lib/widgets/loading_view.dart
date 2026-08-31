import 'package:flutter/material.dart';

/// Estado de carregamento (RF09), usado em toda espera de rede.
class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({super.key, this.message = 'Carregando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            // liveRegion faz o leitor de tela anunciar a espera, em vez de
            // deixar o usuário diante de uma tela que parece vazia (RF10).
            Semantics(
              liveRegion: true,
              child: Text(message, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
