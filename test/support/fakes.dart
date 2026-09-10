import 'dart:async';

import 'package:mobile_dev_guia_interdimensional_somativo1/data/auth_repository.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/data/character_list_repository.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/models/character.dart';

/// Dublês de teste com a mesma interface das implementações Supabase — usados
/// nos testes de provider e de widget pra manter tudo offline.

class FakeCharacterListRepository implements CharacterListRepository {
  final List<Character> _remote;
  bool failNextWrite;

  FakeCharacterListRepository({List<Character>? seed, this.failNextWrite = false})
      : _remote = [...?seed];

  @override
  Future<List<Character>> fetchAll() async => List.unmodifiable(_remote);

  @override
  Future<void> add(Character character) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw Exception('falha simulada de rede');
    }
    _remote.add(character);
  }

  @override
  Future<void> remove(int characterId) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw Exception('falha simulada de rede');
    }
    _remote.removeWhere((c) => c.id == characterId);
  }
}

class FakeAuthRepository implements AuthRepository {
  bool _isLoggedIn;
  final _controller = StreamController<bool>.broadcast();
  String? lastPasswordResetEmail;
  String? lastResendEmail;

  FakeAuthRepository({this._isLoggedIn = true});

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  String? get userEmail => _isLoggedIn ? 'teste@example.com' : null;

  @override
  Stream<bool> get authStateChanges => _controller.stream;

  @override
  Future<SignUpResult> signUp(String email, String password) async {
    return const SignUpResult(SignUpOutcome.awaitingEmailConfirmation);
  }

  @override
  Future<void> signIn(String email, String password) async {
    _isLoggedIn = true;
    _controller.add(true);
  }

  @override
  Future<void> signOut() async {
    _isLoggedIn = false;
    _controller.add(false);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    lastPasswordResetEmail = email;
  }

  @override
  Future<void> deleteAccount() async {
    _isLoggedIn = false;
    _controller.add(false);
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    lastResendEmail = email;
  }

  void dispose() => _controller.close();
}
