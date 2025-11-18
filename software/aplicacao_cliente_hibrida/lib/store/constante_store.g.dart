// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constante_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ConstanteStore on _ConstanteStoreBase, Store {
  Computed<double>? _$horaDecimalInicioComputed;

  @override
  double get horaDecimalInicio => (_$horaDecimalInicioComputed ??=
          Computed<double>(() => super.horaDecimalInicio,
              name: '_ConstanteStoreBase.horaDecimalInicio'))
      .value;
  Computed<int>? _$segundosInicioComputed;

  @override
  int get segundosInicio =>
      (_$segundosInicioComputed ??= Computed<int>(() => super.segundosInicio,
              name: '_ConstanteStoreBase.segundosInicio'))
          .value;
  Computed<double>? _$horaDecimalFimComputed;

  @override
  double get horaDecimalFim =>
      (_$horaDecimalFimComputed ??= Computed<double>(() => super.horaDecimalFim,
              name: '_ConstanteStoreBase.horaDecimalFim'))
          .value;
  Computed<int>? _$segundosFimComputed;

  @override
  int get segundosFim =>
      (_$segundosFimComputed ??= Computed<int>(() => super.segundosFim,
              name: '_ConstanteStoreBase.segundosFim'))
          .value;
  Computed<double>? _$deltaHoraDecimalComputed;

  @override
  double get deltaHoraDecimal => (_$deltaHoraDecimalComputed ??=
          Computed<double>(() => super.deltaHoraDecimal,
              name: '_ConstanteStoreBase.deltaHoraDecimal'))
      .value;
  Computed<double>? _$deltaHoraSegundosComputed;

  @override
  double get deltaHoraSegundos => (_$deltaHoraSegundosComputed ??=
          Computed<double>(() => super.deltaHoraSegundos,
              name: '_ConstanteStoreBase.deltaHoraSegundos'))
      .value;
  Computed<List<FlSpot>>? _$calculoIntensidadeComputed;

  @override
  List<FlSpot> get calculoIntensidade => (_$calculoIntensidadeComputed ??=
          Computed<List<FlSpot>>(() => super.calculoIntensidade,
              name: '_ConstanteStoreBase.calculoIntensidade'))
      .value;
  Computed<double>? _$horaDecimalInicioAjustadaComputed;

  @override
  double get horaDecimalInicioAjustada =>
      (_$horaDecimalInicioAjustadaComputed ??= Computed<double>(
              () => super.horaDecimalInicioAjustada,
              name: '_ConstanteStoreBase.horaDecimalInicioAjustada'))
          .value;
  Computed<double>? _$horaDecimalFimAjustadoComputed;

  @override
  double get horaDecimalFimAjustado => (_$horaDecimalFimAjustadoComputed ??=
          Computed<double>(() => super.horaDecimalFimAjustado,
              name: '_ConstanteStoreBase.horaDecimalFimAjustado'))
      .value;
  Computed<double>? _$dliComputed;

  @override
  double get dli => (_$dliComputed ??=
          Computed<double>(() => super.dli, name: '_ConstanteStoreBase.dli'))
      .value;

  late final _$intensidadeMaximaAtom =
      Atom(name: '_ConstanteStoreBase.intensidadeMaxima', context: context);

  @override
  double get intensidadeMaxima {
    _$intensidadeMaximaAtom.reportRead();
    return super.intensidadeMaxima;
  }

  @override
  set intensidadeMaxima(double value) {
    _$intensidadeMaximaAtom.reportWrite(value, super.intensidadeMaxima, () {
      super.intensidadeMaxima = value;
    });
  }

  late final _$horarioInicioAtom =
      Atom(name: '_ConstanteStoreBase.horarioInicio', context: context);

  @override
  DateTime get horarioInicio {
    _$horarioInicioAtom.reportRead();
    return super.horarioInicio;
  }

  @override
  set horarioInicio(DateTime value) {
    _$horarioInicioAtom.reportWrite(value, super.horarioInicio, () {
      super.horarioInicio = value;
    });
  }

  late final _$horarioFimAtom =
      Atom(name: '_ConstanteStoreBase.horarioFim', context: context);

  @override
  DateTime get horarioFim {
    _$horarioFimAtom.reportRead();
    return super.horarioFim;
  }

  @override
  set horarioFim(DateTime value) {
    _$horarioFimAtom.reportWrite(value, super.horarioFim, () {
      super.horarioFim = value;
    });
  }

  late final _$ioTDataAtom =
      Atom(name: '_ConstanteStoreBase.ioTData', context: context);

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

  late final _$_connectMqttAsyncAction =
      AsyncAction('_ConstanteStoreBase._connectMqtt', context: context);

  @override
  Future<bool> _connectMqtt() {
    return _$_connectMqttAsyncAction.run(() => super._connectMqtt());
  }

  late final _$inscreverAsyncAction =
      AsyncAction('_ConstanteStoreBase.inscrever', context: context);

  @override
  Future<void> inscrever(String topic) {
    return _$inscreverAsyncAction.run(() => super.inscrever(topic));
  }

  late final _$disconnectAsyncAction =
      AsyncAction('_ConstanteStoreBase.disconnect', context: context);

  @override
  Future<void> disconnect() {
    return _$disconnectAsyncAction.run(() => super.disconnect());
  }

  late final _$_ConstanteStoreBaseActionController =
      ActionController(name: '_ConstanteStoreBase', context: context);

  @override
  void setHorarioInicio(DateTime horario) {
    final _$actionInfo = _$_ConstanteStoreBaseActionController.startAction(
        name: '_ConstanteStoreBase.setHorarioInicio');
    try {
      return super.setHorarioInicio(horario);
    } finally {
      _$_ConstanteStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHorarioFim(DateTime horario) {
    final _$actionInfo = _$_ConstanteStoreBaseActionController.startAction(
        name: '_ConstanteStoreBase.setHorarioFim');
    try {
      return super.setHorarioFim(horario);
    } finally {
      _$_ConstanteStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIntensidadeMaxima(double v) {
    final _$actionInfo = _$_ConstanteStoreBaseActionController.startAction(
        name: '_ConstanteStoreBase.setIntensidadeMaxima');
    try {
      return super.setIntensidadeMaxima(v);
    } finally {
      _$_ConstanteStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIotData(IoTData v) {
    final _$actionInfo = _$_ConstanteStoreBaseActionController.startAction(
        name: '_ConstanteStoreBase.setIotData');
    try {
      return super.setIotData(v);
    } finally {
      _$_ConstanteStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendCommandMqtt(String command, String topic, String value) {
    final _$actionInfo = _$_ConstanteStoreBaseActionController.startAction(
        name: '_ConstanteStoreBase.sendCommandMqtt');
    try {
      return super.sendCommandMqtt(command, topic, value);
    } finally {
      _$_ConstanteStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String sendGrausMQTT() {
    final _$actionInfo = _$_ConstanteStoreBaseActionController.startAction(
        name: '_ConstanteStoreBase.sendGrausMQTT');
    try {
      return super.sendGrausMQTT();
    } finally {
      _$_ConstanteStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
intensidadeMaxima: ${intensidadeMaxima},
horarioInicio: ${horarioInicio},
horarioFim: ${horarioFim},
ioTData: ${ioTData},
horaDecimalInicio: ${horaDecimalInicio},
segundosInicio: ${segundosInicio},
horaDecimalFim: ${horaDecimalFim},
segundosFim: ${segundosFim},
deltaHoraDecimal: ${deltaHoraDecimal},
deltaHoraSegundos: ${deltaHoraSegundos},
calculoIntensidade: ${calculoIntensidade},
horaDecimalInicioAjustada: ${horaDecimalInicioAjustada},
horaDecimalFimAjustado: ${horaDecimalFimAjustado},
dli: ${dli}
    ''';
  }
}
