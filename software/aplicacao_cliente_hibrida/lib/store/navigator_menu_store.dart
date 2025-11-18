import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
part 'navigator_menu_store.g.dart';

class NavigatorMenuStore = _NavigatorMenuStoreBase with _$NavigatorMenuStore;

abstract class _NavigatorMenuStoreBase with Store {
  @observable
  int value = 0;

  void setValue(int v) => value = v;
}
