import 'models.dart';

abstract class DataItemUploader {
  Future<List<DataItem>> processAndPrepareDataItems();
}
