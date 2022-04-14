import 'models.dart';

abstract class DataItemHandle {
  Future<List<DataItem>> getDataItems();
  int get dataItemCount;
}
