import 'models.dart';

abstract class DataItemPrototype {
  Future<DataItem> processAndPrepareDataItem();
}
