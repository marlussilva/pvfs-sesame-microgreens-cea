// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_card_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ExperimentCardStore on _ExperimentCardStoreBase, Store {
  late final _$textLoadingAtom =
      Atom(name: '_ExperimentCardStoreBase.textLoading', context: context);

  @override
  String get textLoading {
    _$textLoadingAtom.reportRead();
    return super.textLoading;
  }

  @override
  set textLoading(String value) {
    _$textLoadingAtom.reportWrite(value, super.textLoading, () {
      super.textLoading = value;
    });
  }

  late final _$showGraphsAtom =
      Atom(name: '_ExperimentCardStoreBase.showGraphs', context: context);

  @override
  bool get showGraphs {
    _$showGraphsAtom.reportRead();
    return super.showGraphs;
  }

  @override
  set showGraphs(bool value) {
    _$showGraphsAtom.reportWrite(value, super.showGraphs, () {
      super.showGraphs = value;
    });
  }

  late final _$isGeneratingGraphsAtom = Atom(
      name: '_ExperimentCardStoreBase.isGeneratingGraphs', context: context);

  @override
  bool get isGeneratingGraphs {
    _$isGeneratingGraphsAtom.reportRead();
    return super.isGeneratingGraphs;
  }

  @override
  set isGeneratingGraphs(bool value) {
    _$isGeneratingGraphsAtom.reportWrite(value, super.isGeneratingGraphs, () {
      super.isGeneratingGraphs = value;
    });
  }

  late final _$_ExperimentCardStoreBaseActionController =
      ActionController(name: '_ExperimentCardStoreBase', context: context);

  @override
  void setTextLoading(String v) {
    final _$actionInfo = _$_ExperimentCardStoreBaseActionController.startAction(
        name: '_ExperimentCardStoreBase.setTextLoading');
    try {
      return super.setTextLoading(v);
    } finally {
      _$_ExperimentCardStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setShowGraphs(bool v) {
    final _$actionInfo = _$_ExperimentCardStoreBaseActionController.startAction(
        name: '_ExperimentCardStoreBase.setShowGraphs');
    try {
      return super.setShowGraphs(v);
    } finally {
      _$_ExperimentCardStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsGeneratingGraphs(bool v) {
    final _$actionInfo = _$_ExperimentCardStoreBaseActionController.startAction(
        name: '_ExperimentCardStoreBase.setIsGeneratingGraphs');
    try {
      return super.setIsGeneratingGraphs(v);
    } finally {
      _$_ExperimentCardStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
textLoading: ${textLoading},
showGraphs: ${showGraphs},
isGeneratingGraphs: ${isGeneratingGraphs}
    ''';
  }
}
