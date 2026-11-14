import 'package:get/get.dart';
import '../../../data/models/user_session.dart';
import '../../../data/repositories/auth_repository.dart';

class FormKibController extends GetxController {
  final AuthRepository _authRepository;

  FormKibController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final RxBool isTampilUnit = false.obs;
  final RxBool isTampilSubUnit = false.obs;
  final RxBool isTampilUpb = false.obs;

  final RxBool isTampilStringUnit = false.obs;
  final RxBool isTampilStringSubUnit = false.obs;
  final RxBool isTampilStringUpb = false.obs;

  final Rx<UserSession> session = const UserSession().obs;

  @override
  void onInit() {
    super.onInit();
    loadSession();
  }

  Future<void> loadSession() async {
    final s = await _authRepository.getSession();
    if (s != null) {
      session.value = s;
      _evaluateVisibility(s.level);
    }
  }

  void _evaluateVisibility(String level) {
    if (level == '0' || level == '1' || level == '2') {
      isTampilUnit.value = true;
    }
    if (level == '0' || level == '1' || level == '2' || level == '3') {
      isTampilSubUnit.value = true;
    }
    if (level == '0' || level == '1' || level == '2' || level == '3' || level == '4') {
      isTampilUpb.value = true;
    }
    if (level == '3' || level == '4') {
      isTampilStringUnit.value = true;
    }
    if (level == '4') {
      isTampilStringSubUnit.value = true;
    }
  }
}

