// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gaussian_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GaussianStore on _GaussianStore, Store {
  Computed<double>? _$horaDecimalInicioComputed;

  @override
  double get horaDecimalInicio => (_$horaDecimalInicioComputed ??=
          Computed<double>(() => super.horaDecimalInicio,
              name: '_GaussianStore.horaDecimalInicio'))
      .value;
  Computed<int>? _$segundosInicioComputed;

  @override
  int get segundosInicio =>
      (_$segundosInicioComputed ??= Computed<int>(() => super.segundosInicio,
              name: '_GaussianStore.segundosInicio'))
          .value;
  Computed<double>? _$horaDecimalFimComputed;

  @override
  double get horaDecimalFim =>
      (_$horaDecimalFimComputed ??= Computed<double>(() => super.horaDecimalFim,
              name: '_GaussianStore.horaDecimalFim'))
          .value;
  Computed<int>? _$segundosFimComputed;

  @override
  int get segundosFim =>
      (_$segundosFimComputed ??= Computed<int>(() => super.segundosFim,
              name: '_GaussianStore.segundosFim'))
          .value;
  Computed<double>? _$deltaHoraDecimalComputed;

  @override
  double get deltaHoraDecimal => (_$deltaHoraDecimalComputed ??=
          Computed<double>(() => super.deltaHoraDecimal,
              name: '_GaussianStore.deltaHoraDecimal'))
      .value;
  Computed<double>? _$deltaHoraSegundosComputed;

  @override
  double get deltaHoraSegundos => (_$deltaHoraSegundosComputed ??=
          Computed<double>(() => super.deltaHoraSegundos,
              name: '_GaussianStore.deltaHoraSegundos'))
      .value;
  Computed<List<FlSpot>>? _$gaussianCurveComputed;

  @override
  List<FlSpot> get gaussianCurve => (_$gaussianCurveComputed ??=
          Computed<List<FlSpot>>(() => super.gaussianCurve,
              name: '_GaussianStore.gaussianCurve'))
      .value;
  Computed<List<FlSpot>>? _$normalizedGaussianCurveComputed;

  @override
  List<FlSpot> get normalizedGaussianCurve =>
      (_$normalizedGaussianCurveComputed ??= Computed<List<FlSpot>>(
              () => super.normalizedGaussianCurve,
              name: '_GaussianStore.normalizedGaussianCurve'))
          .value;
  Computed<List<FlSpot>>? _$calculoIntensidadeComputed;

  @override
  List<FlSpot> get calculoIntensidade => (_$calculoIntensidadeComputed ??=
          Computed<List<FlSpot>>(() => super.calculoIntensidade,
              name: '_GaussianStore.calculoIntensidade'))
      .value;
  Computed<double>? _$integralDliComputed;

  @override
  double get integralDli =>
      (_$integralDliComputed ??= Computed<double>(() => super.integralDli,
              name: '_GaussianStore.integralDli'))
          .value;
  Computed<double>? _$calculoICEComputed;

  @override
  double get calculoICE =>
      (_$calculoICEComputed ??= Computed<double>(() => super.calculoICE,
              name: '_GaussianStore.calculoICE'))
          .value;

  late final _$ioTDataAtom =
      Atom(name: '_GaussianStore.ioTData', context: context);

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

  late final _$horarioInicioAtom =
      Atom(name: '_GaussianStore.horarioInicio', context: context);

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
      Atom(name: '_GaussianStore.horarioFim', context: context);

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

  late final _$miAtom = Atom(name: '_GaussianStore.mi', context: context);

  @override
  double get mi {
    _$miAtom.reportRead();
    return super.mi;
  }

  @override
  set mi(double value) {
    _$miAtom.reportWrite(value, super.mi, () {
      super.mi = value;
    });
  }

  late final _$sigmaAtom = Atom(name: '_GaussianStore.sigma', context: context);

  @override
  double get sigma {
    _$sigmaAtom.reportRead();
    return super.sigma;
  }

  @override
  set sigma(double value) {
    _$sigmaAtom.reportWrite(value, super.sigma, () {
      super.sigma = value;
    });
  }

  late final _$intesidadeMaximaAtom =
      Atom(name: '_GaussianStore.intesidadeMaxima', context: context);

  @override
  double get intesidadeMaxima {
    _$intesidadeMaximaAtom.reportRead();
    return super.intesidadeMaxima;
  }

  @override
  set intesidadeMaxima(double value) {
    _$intesidadeMaximaAtom.reportWrite(value, super.intesidadeMaxima, () {
      super.intesidadeMaxima = value;
    });
  }

  late final _$intesidadeMinimaAtom =
      Atom(name: '_GaussianStore.intesidadeMinima', context: context);

  @override
  double get intesidadeMinima {
    _$intesidadeMinimaAtom.reportRead();
    return super.intesidadeMinima;
  }

  @override
  set intesidadeMinima(double value) {
    _$intesidadeMinimaAtom.reportWrite(value, super.intesidadeMinima, () {
      super.intesidadeMinima = value;
    });
  }

  late final _$inicioAtom =
      Atom(name: '_GaussianStore.inicio', context: context);

  @override
  double get inicio {
    _$inicioAtom.reportRead();
    return super.inicio;
  }

  @override
  set inicio(double value) {
    _$inicioAtom.reportWrite(value, super.inicio, () {
      super.inicio = value;
    });
  }

  late final _$deltaAtom = Atom(name: '_GaussianStore.delta', context: context);

  @override
  double get delta {
    _$deltaAtom.reportRead();
    return super.delta;
  }

  @override
  set delta(double value) {
    _$deltaAtom.reportWrite(value, super.delta, () {
      super.delta = value;
    });
  }

  late final _$inscreverAsyncAction =
      AsyncAction('_GaussianStore.inscrever', context: context);

  @override
  Future<void> inscrever(String topic) {
    return _$inscreverAsyncAction.run(() => super.inscrever(topic));
  }

  late final _$disconnectAsyncAction =
      AsyncAction('_GaussianStore.disconnect', context: context);

  @override
  Future<void> disconnect() {
    return _$disconnectAsyncAction.run(() => super.disconnect());
  }

  late final _$_GaussianStoreActionController =
      ActionController(name: '_GaussianStore', context: context);

  @override
  void setIotData(IoTData v) {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.setIotData');
    try {
      return super.setIotData(v);
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendCommandMqtt(String command, String topic, String value) {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.sendCommandMqtt');
    try {
      return super.sendCommandMqtt(command, topic, value);
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHorarioInicio(DateTime horario) {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.setHorarioInicio');
    try {
      return super.setHorarioInicio(horario);
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHorarioFim(DateTime horario) {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.setHorarioFim');
    try {
      return super.setHorarioFim(horario);
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIntensidadeMaxima(double v) {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.setIntensidadeMaxima');
    try {
      return super.setIntensidadeMaxima(v);
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIntensidadeMinima(double v) {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.setIntensidadeMinima');
    try {
      return super.setIntensidadeMinima(v);
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String sendGrausMQTT() {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.sendGrausMQTT');
    try {
      return super.sendGrausMQTT();
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String decimalParaHorario(double decimal) {
    final _$actionInfo = _$_GaussianStoreActionController.startAction(
        name: '_GaussianStore.decimalParaHorario');
    try {
      return super.decimalParaHorario(decimal);
    } finally {
      _$_GaussianStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
ioTData: ${ioTData},
horarioInicio: ${horarioInicio},
horarioFim: ${horarioFim},
mi: ${mi},
sigma: ${sigma},
intesidadeMaxima: ${intesidadeMaxima},
intesidadeMinima: ${intesidadeMinima},
inicio: ${inicio},
delta: ${delta},
horaDecimalInicio: ${horaDecimalInicio},
segundosInicio: ${segundosInicio},
horaDecimalFim: ${horaDecimalFim},
segundosFim: ${segundosFim},
deltaHoraDecimal: ${deltaHoraDecimal},
deltaHoraSegundos: ${deltaHoraSegundos},
gaussianCurve: ${gaussianCurve},
normalizedGaussianCurve: ${normalizedGaussianCurve},
calculoIntensidade: ${calculoIntensidade},
integralDli: ${integralDli},
calculoICE: ${calculoICE}
    ''';
  }
}
