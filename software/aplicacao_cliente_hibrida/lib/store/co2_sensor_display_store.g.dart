// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'co2_sensor_display_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Co2SensorDisplayStore on _Co2SensorDisplayStoreBase, Store {
  late final _$currentIotDataAtom =
      Atom(name: '_Co2SensorDisplayStoreBase.currentIotData', context: context);

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
      AsyncAction('_Co2SensorDisplayStoreBase.connectMqtt', context: context);

  @override
  Future<void> connectMqtt() {
    return _$connectMqttAsyncAction.run(() => super.connectMqtt());
  }

  late final _$inscreverAsyncAction =
      AsyncAction('_Co2SensorDisplayStoreBase.inscrever', context: context);

  @override
  Future<void> inscrever(String topic) {
    return _$inscreverAsyncAction.run(() => super.inscrever(topic));
  }

  late final _$_Co2SensorDisplayStoreBaseActionController =
      ActionController(name: '_Co2SensorDisplayStoreBase', context: context);

  @override
  void setIotData(IoTData d) {
    final _$actionInfo = _$_Co2SensorDisplayStoreBaseActionController
        .startAction(name: '_Co2SensorDisplayStoreBase.setIotData');
    try {
      return super.setIotData(d);
    } finally {
      _$_Co2SensorDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendCommandMqtt(String command, String topic, double value) {
    final _$actionInfo = _$_Co2SensorDisplayStoreBaseActionController
        .startAction(name: '_Co2SensorDisplayStoreBase.sendCommandMqtt');
    try {
      return super.sendCommandMqtt(command, topic, value);
    } finally {
      _$_Co2SensorDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disconnect() {
    final _$actionInfo = _$_Co2SensorDisplayStoreBaseActionController
        .startAction(name: '_Co2SensorDisplayStoreBase.disconnect');
    try {
      return super.disconnect();
    } finally {
      _$_Co2SensorDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentIotData: ${currentIotData}
    ''';
  }
}
