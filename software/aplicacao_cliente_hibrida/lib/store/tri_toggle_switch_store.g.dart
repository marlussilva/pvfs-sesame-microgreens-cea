// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tri_toggle_switch_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TriToggleSwitchStore on _TriToggleSwitchStoreBase, Store {
  late final _$statusAtom =
      Atom(name: '_TriToggleSwitchStoreBase.status', context: context);

  @override
  bool get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(bool value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$currentIndexAtom =
      Atom(name: '_TriToggleSwitchStoreBase.currentIndex', context: context);

  @override
  int get currentIndex {
    _$currentIndexAtom.reportRead();
    return super.currentIndex;
  }

  @override
  set currentIndex(int value) {
    _$currentIndexAtom.reportWrite(value, super.currentIndex, () {
      super.currentIndex = value;
    });
  }

  late final _$ioTDataAtom =
      Atom(name: '_TriToggleSwitchStoreBase.ioTData', context: context);

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

  late final _$inscreverAsyncAction =
      AsyncAction('_TriToggleSwitchStoreBase.inscrever', context: context);

  @override
  Future<void> inscrever(String topic) {
    return _$inscreverAsyncAction.run(() => super.inscrever(topic));
  }

  late final _$disconnectAsyncAction =
      AsyncAction('_TriToggleSwitchStoreBase.disconnect', context: context);

  @override
  Future<void> disconnect() {
    return _$disconnectAsyncAction.run(() => super.disconnect());
  }

  late final _$_TriToggleSwitchStoreBaseActionController =
      ActionController(name: '_TriToggleSwitchStoreBase', context: context);

  @override
  void setStatus(bool v) {
    final _$actionInfo = _$_TriToggleSwitchStoreBaseActionController
        .startAction(name: '_TriToggleSwitchStoreBase.setStatus');
    try {
      return super.setStatus(v);
    } finally {
      _$_TriToggleSwitchStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIndex(int index) {
    final _$actionInfo = _$_TriToggleSwitchStoreBaseActionController
        .startAction(name: '_TriToggleSwitchStoreBase.setIndex');
    try {
      return super.setIndex(index);
    } finally {
      _$_TriToggleSwitchStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIotData(IoTData v) {
    final _$actionInfo = _$_TriToggleSwitchStoreBaseActionController
        .startAction(name: '_TriToggleSwitchStoreBase.setIotData');
    try {
      return super.setIotData(v);
    } finally {
      _$_TriToggleSwitchStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendCommandMqtt(String command, String topic, double value) {
    final _$actionInfo = _$_TriToggleSwitchStoreBaseActionController
        .startAction(name: '_TriToggleSwitchStoreBase.sendCommandMqtt');
    try {
      return super.sendCommandMqtt(command, topic, value);
    } finally {
      _$_TriToggleSwitchStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
status: ${status},
currentIndex: ${currentIndex},
ioTData: ${ioTData}
    ''';
  }
}
