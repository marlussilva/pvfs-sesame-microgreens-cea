// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'luz_component_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LuzComponentStore on _LuzComponentStoreBase, Store {
  late final _$valueAtom =
      Atom(name: '_LuzComponentStoreBase.value', context: context);

  @override
  double get value {
    _$valueAtom.reportRead();
    return super.value;
  }

  @override
  set value(double value) {
    _$valueAtom.reportWrite(value, super.value, () {
      super.value = value;
    });
  }

  late final _$ioTDataAtom =
      Atom(name: '_LuzComponentStoreBase.ioTData', context: context);

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

  late final _$disconnectAsyncAction =
      AsyncAction('_LuzComponentStoreBase.disconnect', context: context);

  @override
  Future<void> disconnect() {
    return _$disconnectAsyncAction.run(() => super.disconnect());
  }

  late final _$_LuzComponentStoreBaseActionController =
      ActionController(name: '_LuzComponentStoreBase', context: context);

  @override
  void setValue(double v) {
    final _$actionInfo = _$_LuzComponentStoreBaseActionController.startAction(
        name: '_LuzComponentStoreBase.setValue');
    try {
      return super.setValue(v);
    } finally {
      _$_LuzComponentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIotData(IoTData v) {
    final _$actionInfo = _$_LuzComponentStoreBaseActionController.startAction(
        name: '_LuzComponentStoreBase.setIotData');
    try {
      return super.setIotData(v);
    } finally {
      _$_LuzComponentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendCommandMqtt(String command, String topic, double value) {
    final _$actionInfo = _$_LuzComponentStoreBaseActionController.startAction(
        name: '_LuzComponentStoreBase.sendCommandMqtt');
    try {
      return super.sendCommandMqtt(command, topic, value);
    } finally {
      _$_LuzComponentStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
value: ${value},
ioTData: ${ioTData}
    ''';
  }
}
