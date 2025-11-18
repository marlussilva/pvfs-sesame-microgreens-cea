// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy_watts_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$EnergyWattsStore on _EnergyWattsStoreBase, Store {
  late final _$currentIotDataAtom =
      Atom(name: '_EnergyWattsStoreBase.currentIotData', context: context);

  @override
  IoTData? get currentIotData {
    _$currentIotDataAtom.reportRead();
    return super.currentIotData;
  }

  @override
  set currentIotData(IoTData? value) {
    _$currentIotDataAtom.reportWrite(value, super.currentIotData, () {
      super.currentIotData = value;
    });
  }

  late final _$connectMqttAsyncAction =
      AsyncAction('_EnergyWattsStoreBase.connectMqtt', context: context);

  @override
  Future<void> connectMqtt() {
    return _$connectMqttAsyncAction.run(() => super.connectMqtt());
  }

  late final _$inscreverAsyncAction =
      AsyncAction('_EnergyWattsStoreBase.inscrever', context: context);

  @override
  Future<void> inscrever(String topic) {
    return _$inscreverAsyncAction.run(() => super.inscrever(topic));
  }

  late final _$_EnergyWattsStoreBaseActionController =
      ActionController(name: '_EnergyWattsStoreBase', context: context);

  @override
  void setIotData(IoTData d) {
    final _$actionInfo = _$_EnergyWattsStoreBaseActionController.startAction(
        name: '_EnergyWattsStoreBase.setIotData');
    try {
      return super.setIotData(d);
    } finally {
      _$_EnergyWattsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendCommandMqtt(String command, String topic, double value) {
    final _$actionInfo = _$_EnergyWattsStoreBaseActionController.startAction(
        name: '_EnergyWattsStoreBase.sendCommandMqtt');
    try {
      return super.sendCommandMqtt(command, topic, value);
    } finally {
      _$_EnergyWattsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disconnect() {
    final _$actionInfo = _$_EnergyWattsStoreBaseActionController.startAction(
        name: '_EnergyWattsStoreBase.disconnect');
    try {
      return super.disconnect();
    } finally {
      _$_EnergyWattsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentIotData: ${currentIotData}
    ''';
  }
}
