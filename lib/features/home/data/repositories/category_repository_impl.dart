import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/news_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remoteDataSource);

  final NewsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<CategoryEntity>>> getCategories({
    bool forceRefresh = false,
  }) async {
    try {
      final List<CategoryEntity> items =
          await _remoteDataSource.fetchCategories(
        forceRefresh: forceRefresh,
      );
      return Ok<List<CategoryEntity>>(items);
    } on Object catch (error, stackTrace) {
      return Err<List<CategoryEntity>>(ErrorMapper.map(error, stackTrace));
    }
  }
}
