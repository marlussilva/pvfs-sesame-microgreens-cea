import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';

part 'locale_store.g.dart';

class LocaleStore = _LocaleStore with _$LocaleStore;

abstract class _LocaleStore with Store {
  @observable
  Locale locale = Locale('en', '');

  @action
  void changeLocale(Locale newLocale) {
    locale = newLocale;
  }
}
