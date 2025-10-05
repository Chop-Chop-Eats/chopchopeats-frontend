

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../../home/models/home_models.dart';

class CategoryServices {
  Future<TotalWithChefItem> getDiamondArea(DiamondAreaQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.getDiamondAreaApi,
      queryParameters: query.toJson(),
    );
    Logger.info('CategoryServices', 'getDiamondArea response: ${response.data}');
    return TotalWithChefItem.fromJson(response.data);
  }
}