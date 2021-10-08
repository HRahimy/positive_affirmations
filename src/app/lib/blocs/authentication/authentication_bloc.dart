import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends HydratedBloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(const AuthenticationState.unknown());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationStatusChanged) {
      yield _mapAuthenticationStatusChangedToState(event, state);
    } else if (event is AuthenticationLogoutRequested) {
      yield AuthenticationState.unauthenticated();
    }
  }

  AuthenticationState _mapAuthenticationStatusChangedToState(
      AuthenticationStatusChanged event, AuthenticationState state) {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        return const AuthenticationState.unauthenticated();
      case AuthenticationStatus.authenticated:
        return AuthenticationState.authenticated();
      default:
        return AuthenticationState.unknown();
    }
  }

  @override
  AuthenticationState? fromJson(Map<String, dynamic> json) {
    final AuthenticationStatus status = AuthenticationStatus
        .values[json[AuthenticationState.fieldStatus] as int];

    switch (status) {
      case AuthenticationStatus.unauthenticated:
        return const AuthenticationState.unauthenticated();
      case AuthenticationStatus.authenticated:
        return AuthenticationState.authenticated();
      default:
        return AuthenticationState.unknown();
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthenticationState state) => {
        AuthenticationState.fieldStatus: state.status.index,
      };
}