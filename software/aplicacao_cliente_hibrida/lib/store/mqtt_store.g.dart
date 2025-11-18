// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MqttStore on _MqttStoreBase, Store {
  Computed<bool>? _$isConnectedComputed;

  @override
  bool get isConnected =>
      (_$isConnectedComputed ??= Computed<bool>(() => super.isConnected,
              name: '_MqttStoreBase.isConnected'))
          .value;

  late final _$latestMessageAtom =
      Atom(name: '_MqttStoreBase.latestMessage', context: context);

  @override
  String get latestMessage {
    _$latestMessageAtom.reportRead();
    return super.latestMessage;
  }

  @override
  set latestMessage(String value) {
    _$latestMessageAtom.reportWrite(value, super.latestMessage, () {
      super.latestMessage = value;
    });
  }

  late final _$ioTDataAtom =
      Atom(name: '_MqttStoreBase.ioTData', context: context);

  @override
  IoTData? get ioTData {
    _$ioTDataAtom.reportRead();
    return super.ioTData;
  }

  @override
  set ioTData(IoTData? value) {
    _$ioTDataAtom.reportWrite(value, super.ioTData, () {
      super.ioTData = value;
    });
  }

  late final _$valueAtom = Atom(name: '_MqttStoreBase.value', context: context);

  @override
  String get value {
    _$valueAtom.reportRead();
    return super.value;
  }

  @override
  set value(String value) {
    _$valueAtom.reportWrite(value, super.value, () {
      super.value = value;
    });
  }

  late final _$connectAsyncAction =
      AsyncAction('_MqttStoreBase.connect', context: context);

  @override
  Future<bool> connect(String username, String password) {
    return _$connectAsyncAction.run(() => super.connect(username, password));
  }

  late final _$subscribeAsyncAction =
      AsyncAction('_MqttStoreBase.subscribe', context: context);

  @override
  Future<void> subscribe(String topic) {
    return _$subscribeAsyncAction.run(() => super.subscribe(topic));
  }

  late final _$publishAsyncAction =
      AsyncAction('_MqttStoreBase.publish', context: context);

  @override
  Future<void> publish(String topic, String message) {
    return _$publishAsyncAction.run(() => super.publish(topic, message));
  }

  late final _$disconnectAsyncAction =
      AsyncAction('_MqttStoreBase.disconnect', context: context);

  @override
  Future<void> disconnect() {
    return _$disconnectAsyncAction.run(() => super.disconnect());
  }

  late final _$_MqttStoreBaseActionController =
      ActionController(name: '_MqttStoreBase', context: context);

  @override
  void setIotData(IoTData data) {
    final _$actionInfo = _$_MqttStoreBaseActionController.startAction(
        name: '_MqttStoreBase.setIotData');
    try {
      return super.setIotData(data);
    } finally {
      _$_MqttStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValue(String v) {
    final _$actionInfo = _$_MqttStoreBaseActionController.startAction(
        name: '_MqttStoreBase.setValue');
    try {
      return super.setValue(v);
    } finally {
      _$_MqttStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
latestMessage: ${latestMessage},
ioTData: ${ioTData},
value: ${value},
isConnected: ${isConnected}
    ''';
  }
}
