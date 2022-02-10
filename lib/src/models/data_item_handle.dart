import 'models.dart';

abstract class DataItemHandle {
  Future<List<DataItem>> createDataItemsFromFileHandle();
}
