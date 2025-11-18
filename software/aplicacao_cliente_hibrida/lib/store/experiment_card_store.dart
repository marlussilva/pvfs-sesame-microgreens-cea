import 'package:mobx/mobx.dart';
part 'experiment_card_store.g.dart';

class ExperimentCardStore = _ExperimentCardStoreBase with _$ExperimentCardStore;

abstract class _ExperimentCardStoreBase with Store {
  @observable
  String textLoading = "";
  @action
  void setTextLoading(String v) => textLoading = v;
  @observable
  bool showGraphs = false;
  @observable
  bool isGeneratingGraphs = false;

  @action
  void setShowGraphs(bool v) => showGraphs = v;

  @action
  void setIsGeneratingGraphs(bool v) => isGeneratingGraphs = v;
}
