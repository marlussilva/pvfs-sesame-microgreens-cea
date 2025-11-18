// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_chart_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GenericChartStore on _GenericChartStore, Store {
  late final _$spotsAtom =
      Atom(name: '_GenericChartStore.spots', context: context);

  @override
  ObservableList<FlSpot> get spots {
    _$spotsAtom.reportRead();
    return super.spots;
  }

  @override
  set spots(ObservableList<FlSpot> value) {
    _$spotsAtom.reportWrite(value, super.spots, () {
      super.spots = value;
    });
  }

  late final _$xLabelsAtom =
      Atom(name: '_GenericChartStore.xLabels', context: context);

  @override
  ObservableList<String> get xLabels {
    _$xLabelsAtom.reportRead();
    return super.xLabels;
  }

  @override
  set xLabels(ObservableList<String> value) {
    _$xLabelsAtom.reportWrite(value, super.xLabels, () {
      super.xLabels = value;
    });
  }

  late final _$minXAtom =
      Atom(name: '_GenericChartStore.minX', context: context);

  @override
  double get minX {
    _$minXAtom.reportRead();
    return super.minX;
  }

  @override
  set minX(double value) {
    _$minXAtom.reportWrite(value, super.minX, () {
      super.minX = value;
    });
  }

  late final _$maxXAtom =
      Atom(name: '_GenericChartStore.maxX', context: context);

  @override
  double get maxX {
    _$maxXAtom.reportRead();
    return super.maxX;
  }

  @override
  set maxX(double value) {
    _$maxXAtom.reportWrite(value, super.maxX, () {
      super.maxX = value;
    });
  }

  late final _$minYAtom =
      Atom(name: '_GenericChartStore.minY', context: context);

  @override
  double get minY {
    _$minYAtom.reportRead();
    return super.minY;
  }

  @override
  set minY(double value) {
    _$minYAtom.reportWrite(value, super.minY, () {
      super.minY = value;
    });
  }

  late final _$maxYAtom =
      Atom(name: '_GenericChartStore.maxY', context: context);

  @override
  double get maxY {
    _$maxYAtom.reportRead();
    return super.maxY;
  }

  @override
  set maxY(double value) {
    _$maxYAtom.reportWrite(value, super.maxY, () {
      super.maxY = value;
    });
  }

  late final _$chartStartTimeAtom =
      Atom(name: '_GenericChartStore.chartStartTime', context: context);

  @override
  DateTime get chartStartTime {
    _$chartStartTimeAtom.reportRead();
    return super.chartStartTime;
  }

  @override
  set chartStartTime(DateTime value) {
    _$chartStartTimeAtom.reportWrite(value, super.chartStartTime, () {
      super.chartStartTime = value;
    });
  }

  late final _$chartEndTimeAtom =
      Atom(name: '_GenericChartStore.chartEndTime', context: context);

  @override
  DateTime get chartEndTime {
    _$chartEndTimeAtom.reportRead();
    return super.chartEndTime;
  }

  @override
  set chartEndTime(DateTime value) {
    _$chartEndTimeAtom.reportWrite(value, super.chartEndTime, () {
      super.chartEndTime = value;
    });
  }

  late final _$consultGraphicsAsyncAction =
      AsyncAction('_GenericChartStore.consultGraphics', context: context);

  @override
  Future<void> consultGraphics(String mqttTopic) {
    return _$consultGraphicsAsyncAction
        .run(() => super.consultGraphics(mqttTopic));
  }

  late final _$_GenericChartStoreActionController =
      ActionController(name: '_GenericChartStore', context: context);

  @override
  void setChartStartTime(DateTime startTime) {
    final _$actionInfo = _$_GenericChartStoreActionController.startAction(
        name: '_GenericChartStore.setChartStartTime');
    try {
      return super.setChartStartTime(startTime);
    } finally {
      _$_GenericChartStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChartEndTime(DateTime endTime) {
    final _$actionInfo = _$_GenericChartStoreActionController.startAction(
        name: '_GenericChartStore.setChartEndTime');
    try {
      return super.setChartEndTime(endTime);
    } finally {
      _$_GenericChartStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
spots: ${spots},
xLabels: ${xLabels},
minX: ${minX},
maxX: ${maxX},
minY: ${minY},
maxY: ${maxY},
chartStartTime: ${chartStartTime},
chartEndTime: ${chartEndTime}
    ''';
  }
}
