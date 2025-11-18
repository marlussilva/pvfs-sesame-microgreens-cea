// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iot_data_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$IotDataStore on _IotDataStoreBase, Store {
  late final _$iotDataListAtom =
      Atom(name: '_IotDataStoreBase.iotDataList', context: context);

  @override
  ObservableList<Map<String, dynamic>> get iotDataList {
    _$iotDataListAtom.reportRead();
    return super.iotDataList;
  }

  @override
  set iotDataList(ObservableList<Map<String, dynamic>> value) {
    _$iotDataListAtom.reportWrite(value, super.iotDataList, () {
      super.iotDataList = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_IotDataStoreBase.isLoading', context: context);

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

  late final _$errorMessageAtom =
      Atom(name: '_IotDataStoreBase.errorMessage', context: context);

  @override
  String get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$fetchIotDataByTimestampAndTopicAsyncAction = AsyncAction(
      '_IotDataStoreBase.fetchIotDataByTimestampAndTopic',
      context: context);

  @override
  Future<void> fetchIotDataByTimestampAndTopic(
      DateTime startTimestamp, DateTime endTimestamp, String mqttTopic) {
    return _$fetchIotDataByTimestampAndTopicAsyncAction.run(() => super
        .fetchIotDataByTimestampAndTopic(
            startTimestamp, endTimestamp, mqttTopic));
  }

  late final _$convertIotDataListToCsvAsyncAction = AsyncAction(
      '_IotDataStoreBase.convertIotDataListToCsv',
      context: context);

  @override
  Future<String> convertIotDataListToCsv() {
    return _$convertIotDataListToCsvAsyncAction
        .run(() => super.convertIotDataListToCsv());
  }

  late final _$saveCsvToFileAsyncAction =
      AsyncAction('_IotDataStoreBase.saveCsvToFile', context: context);

  @override
  Future<File> saveCsvToFile(String csvString) {
    return _$saveCsvToFileAsyncAction.run(() => super.saveCsvToFile(csvString));
  }

  @override
  String toString() {
    return '''
iotDataList: ${iotDataList},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
