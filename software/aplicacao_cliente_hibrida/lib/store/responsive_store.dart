import 'package:mobx/mobx.dart';
part 'responsive_store.g.dart';

class ResponsiveStore = _ResponsiveStoreBase with _$ResponsiveStore;

abstract class _ResponsiveStoreBase with Store {
  @observable
  double screenWidth = 0;
  @observable
  double screenHeight = 0;

  @action
  void setScreenSize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
  }
}
