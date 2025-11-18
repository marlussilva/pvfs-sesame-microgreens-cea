// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responsive_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ResponsiveStore on _ResponsiveStoreBase, Store {
  late final _$screenWidthAtom =
      Atom(name: '_ResponsiveStoreBase.screenWidth', context: context);

  @override
  double get screenWidth {
    _$screenWidthAtom.reportRead();
    return super.screenWidth;
  }

  @override
  set screenWidth(double value) {
    _$screenWidthAtom.reportWrite(value, super.screenWidth, () {
      super.screenWidth = value;
    });
  }

  late final _$screenHeightAtom =
      Atom(name: '_ResponsiveStoreBase.screenHeight', context: context);

  @override
  double get screenHeight {
    _$screenHeightAtom.reportRead();
    return super.screenHeight;
  }

  @override
  set screenHeight(double value) {
    _$screenHeightAtom.reportWrite(value, super.screenHeight, () {
      super.screenHeight = value;
    });
  }

  late final _$_ResponsiveStoreBaseActionController =
      ActionController(name: '_ResponsiveStoreBase', context: context);

  @override
  void setScreenSize(double width, double height) {
    final _$actionInfo = _$_ResponsiveStoreBaseActionController.startAction(
        name: '_ResponsiveStoreBase.setScreenSize');
    try {
      return super.setScreenSize(width, height);
    } finally {
      _$_ResponsiveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
screenWidth: ${screenWidth},
screenHeight: ${screenHeight}
    ''';
  }
}
