import 'package:flutter/foundation.dart';

import '../data/local_storage.dart';

/// Estado de sessão do app (RF07).
///
/// O login é local e proposital: o enunciado pede navegação condicional e
/// gestão de sessão, não autenticação contra servidor. As credenciais ficam
/// em `shared_preferences` — em um app real isso exigiria hash e um backend,
/// e é exatamente o que o bônus de autenticação real substituiria.
class AuthProvider extends ChangeNotifier {
  final LocalStorage _storage;

  String? _user;
  bool _isSubmitting = false;
  String? _errorMessage;

  AuthProvider(this._storage) : _user = _storage.sessionUser;

  String? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Valida os campos e abre a sessão. O atraso curto existe para que o
  /// `CircularProgressIndicator` do RF09 seja visível no login, que de outro
  /// modo resolveria instantaneamente.
  Future<bool> login(String user, String password) async {
    final trimmed = user.trim();

    if (trimmed.isEmpty || password.isEmpty) {
      _errorMessage = 'Preencha usuário e senha.';
      notifyListeners();
      return false;
    }
    if (password.length < 4) {
      _errorMessage = 'A senha precisa ter pelo menos 4 caracteres.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _storage.saveSession(trimmed);

    _user = trimmed;
    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _storage.clearSession();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
