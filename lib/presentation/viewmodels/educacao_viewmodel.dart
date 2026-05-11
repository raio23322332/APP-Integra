import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

class EducacaoViewModel extends BaseViewModel {
  void navigateToAlunoOnline() {
    emitEvent(const OpenWebViewEvent(
      title: "Aluno Online",
      url: "https://www.seduc.pi.gov.br/acessoRapido/areaEstudante",
    ));
  }

  void navigateToProfessorOnline() {
    emitEvent(const OpenWebViewEvent(
      title: "Professor Online",
      url: "https://portal.seduc.pi.gov.br/",
    ));
  }

  void openSeducServicos() {
    emitEvent(const ShowSnackBarEvent('Abrindo Seduc...'));
    emitEvent(const NavigationEvent(AppRoutes.educacao));
  }
}
