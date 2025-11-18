// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$EnvironmentStore on _EnvironmentStore, Store {
  late final _$statusAtom =
      Atom(name: '_EnvironmentStore.status', context: context);

  @override
  ConnectionStatus get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(ConnectionStatus value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$environmentsAtom =
      Atom(name: '_EnvironmentStore.environments', context: context);

  @override
  ObservableList<Map<String, dynamic>> get environments {
    _$environmentsAtom.reportRead();
    return super.environments;
  }

  @override
  set environments(ObservableList<Map<String, dynamic>> value) {
    _$environmentsAtom.reportWrite(value, super.environments, () {
      super.environments = value;
    });
  }

  late final _$environmentSelectedAtom =
      Atom(name: '_EnvironmentStore.environmentSelected', context: context);

  @override
  Environment? get environmentSelected {
    _$environmentSelectedAtom.reportRead();
    return super.environmentSelected;
  }

  @override
  set environmentSelected(Environment? value) {
    _$environmentSelectedAtom.reportWrite(value, super.environmentSelected, () {
      super.environmentSelected = value;
    });
  }

  late final _$environmentDataAtom =
      Atom(name: '_EnvironmentStore.environmentData', context: context);

  @override
  EnvironmentData? get environmentData {
    _$environmentDataAtom.reportRead();
    return super.environmentData;
  }

  @override
  set environmentData(EnvironmentData? value) {
    _$environmentDataAtom.reportWrite(value, super.environmentData, () {
      super.environmentData = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_EnvironmentStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$fetchEnvironmentsAsyncAction =
      AsyncAction('_EnvironmentStore.fetchEnvironments', context: context);

  @override
  Future<void> fetchEnvironments() {
    return _$fetchEnvironmentsAsyncAction.run(() => super.fetchEnvironments());
  }

  late final _$addEnvironmentAsyncAction =
      AsyncAction('_EnvironmentStore.addEnvironment', context: context);

  @override
  Future<void> addEnvironment(Map<String, dynamic> environment) {
    return _$addEnvironmentAsyncAction
        .run(() => super.addEnvironment(environment));
  }

  late final _$updateEnvironmentAsyncAction =
      AsyncAction('_EnvironmentStore.updateEnvironment', context: context);

  @override
  Future<void> updateEnvironment(String id, Map<String, dynamic> environment) {
    return _$updateEnvironmentAsyncAction
        .run(() => super.updateEnvironment(id, environment));
  }

  late final _$deleteEnvironmentAsyncAction =
      AsyncAction('_EnvironmentStore.deleteEnvironment', context: context);

  @override
  Future<void> deleteEnvironment(String id) {
    return _$deleteEnvironmentAsyncAction
        .run(() => super.deleteEnvironment(id));
  }

  late final _$_EnvironmentStoreActionController =
      ActionController(name: '_EnvironmentStore', context: context);

  @override
  void setConnectionStatus(ConnectionStatus v) {
    final _$actionInfo = _$_EnvironmentStoreActionController.startAction(
        name: '_EnvironmentStore.setConnectionStatus');
    try {
      return super.setConnectionStatus(v);
    } finally {
      _$_EnvironmentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEnvironmentSelected(Environment v) {
    final _$actionInfo = _$_EnvironmentStoreActionController.startAction(
        name: '_EnvironmentStore.setEnvironmentSelected');
    try {
      return super.setEnvironmentSelected(v);
    } finally {
      _$_EnvironmentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEnvironmentData(EnvironmentData d) {
    final _$actionInfo = _$_EnvironmentStoreActionController.startAction(
        name: '_EnvironmentStore.setEnvironmentData');
    try {
      return super.setEnvironmentData(d);
    } finally {
      _$_EnvironmentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateLocalEnvironmentDirectly(
      Map<String, dynamic> updatedEnvironment) {
    final _$actionInfo = _$_EnvironmentStoreActionController.startAction(
        name: '_EnvironmentStore._updateLocalEnvironmentDirectly');
    try {
      return super._updateLocalEnvironmentDirectly(updatedEnvironment);
    } finally {
      _$_EnvironmentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _removeLocalEnvironment(String id) {
    final _$actionInfo = _$_EnvironmentStoreActionController.startAction(
        name: '_EnvironmentStore._removeLocalEnvironment');
    try {
      return super._removeLocalEnvironment(id);
    } finally {
      _$_EnvironmentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$_EnvironmentStoreActionController.startAction(
        name: '_EnvironmentStore.dispose');
    try {
      return super.dispose();
    } finally {
      _$_EnvironmentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
status: ${status},
environments: ${environments},
environmentSelected: ${environmentSelected},
environmentData: ${environmentData},
isLoading: ${isLoading}
    ''';
  }
}
