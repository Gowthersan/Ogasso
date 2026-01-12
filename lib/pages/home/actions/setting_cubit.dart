import 'package:bloc/bloc.dart';
import 'package:ogasso_employe/services/repository/setting_service.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingService _settingService = new SettingService();

  SettingCubit(SettingState initialState) : super(initialState);

  load() async {
    final int alert = await _settingService.getAlert();
    final int warning = await _settingService.getWarning();
    emit(SettingInitial(alert: alert, warning: warning));
  }

  save({required final int alert, required final int warning}) async {
    emit(SettingLoading());
    await _settingService.saveSetting(alert: alert, warning: warning);
    await load();
  }
}

class SettingState {}

class SettingInitial extends SettingState {
  final int alert;
  final int warning;

  SettingInitial({required this.alert, required this.warning});
}

class SettingLoading extends SettingState {}
