
import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/repository/auth_service.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService = new AuthService();

  LoginCubit(initialState) : super(initialState);

  Future<void> login({required final String email, required final String password}) async {
    emit(LoginFormLoadingState());
    try {
      final String accessToken = await _authService.login(email: email, password: password);
      _authService.persistToken(token: accessToken);
      emit(LoginResultState(success: true));
    } catch(error){
      print(error);
      emit(LoginResultState(success: false));
    }
  }
}

class LoginState {}
class LoginFormState extends LoginState {}
class LoginFormLoadingState extends LoginState {}
class LoginResultState extends LoginState {
  final bool success;

  LoginResultState({required this.success});
}
