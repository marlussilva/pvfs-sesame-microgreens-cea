import 'package:mobx/mobx.dart';
part 'automatic_selector_store.g.dart';

class AutomaticSelectorStore = _AutomaticSelectorStoreBase
    with _$AutomaticSelectorStore;

abstract class _AutomaticSelectorStoreBase with Store {
  @observable
  int lenght = 2;

  void setLenght(int v) => lenght = v;
}
