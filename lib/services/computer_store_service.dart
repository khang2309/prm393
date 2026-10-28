import '../database/database_helper.dart';
import '../models/brand.dart';
import '../models/computer.dart';
import '../models/computer_filter_options.dart';
import '../models/product_category.dart';

class ComputerStoreService {
  ComputerStoreService._(this._database);

  static final ComputerStoreService instance = ComputerStoreService._(
    DatabaseHelper.instance,
  );

  final DatabaseHelper _database;

  Future<List<Brand>> getBrands({String query = ''}) =>
      _database.getBrands(query: query);

  Future<bool> isBrandNameUnique(String name, {int? excludeId}) =>
      _database.isBrandNameUnique(name, excludeId: excludeId);

  Future<int> insertBrand(Brand brand) => _database.insertBrand(brand);

  Future<int> updateBrand(Brand brand) => _database.updateBrand(brand);

  Future<int> getBrandUsageCount(int brandId) =>
      _database.getBrandUsageCount(brandId);

  Future<int> deleteBrand(int id) => _database.deleteBrand(id);

  Future<List<ProductCategory>> getCategories({String query = ''}) =>
      _database.getCategories(query: query);

  Future<bool> isCategoryNameUnique(String name, {int? excludeId}) =>
      _database.isCategoryNameUnique(name, excludeId: excludeId);

  Future<int> insertCategory(ProductCategory category) =>
      _database.insertCategory(category);

  Future<int> updateCategory(ProductCategory category) =>
      _database.updateCategory(category);

  Future<int> getCategoryUsageCount(int categoryId) =>
      _database.getCategoryUsageCount(categoryId);

  Future<int> deleteCategory(int id) => _database.deleteCategory(id);

  Future<List<Computer>> getComputers({
    String keyword = '',
    int? brandId,
    int? categoryId,
    bool featuredOnly = false,
    String? stockStatus,
    String? ramOption,
    String? storageOption,
    String? priceOption,
    String sortOption = ComputerFilterOptions.sortNameAsc,
  }) {
    return _database.getComputers(
      keyword: keyword,
      brandId: brandId,
      categoryId: categoryId,
      featuredOnly: featuredOnly,
      stockStatus: stockStatus,
      ramOption: ramOption,
      storageOption: storageOption,
      priceOption: priceOption,
      sortOption: sortOption,
    );
  }

  Future<Computer?> getComputerById(int id) => _database.getComputerById(id);

  Future<bool> isProductNameUnique(String name, {int? excludeId}) =>
      _database.isProductNameUnique(name, excludeId: excludeId);

  Future<int> insertComputer(Computer computer) =>
      _database.insertComputer(computer);

  Future<int> updateComputer(Computer computer) =>
      _database.updateComputer(computer);

  Future<int> deleteComputer(int id) => _database.deleteComputer(id);

  Future<Map<String, num>> getStatistics() => _database.getStatistics();

  Future<List<Map<String, Object?>>> getBrandStatistics() =>
      _database.getBrandStatistics();

  Future<List<Map<String, Object?>>> getCategoryStatistics() =>
      _database.getCategoryStatistics();

  Future<Map<String, Object?>?> getBestSellingProduct() =>
      _database.getBestSellingProduct();

  Future<Map<String, Object?>?> getMostExpensiveProduct() =>
      _database.getMostExpensiveProduct();

  Future<List<Map<String, Object?>>> getLowStockProducts() =>
      _database.getLowStockProducts();

  Future<Map<String, Object?>?> getTopBrand() => _database.getTopBrand();

  Future<Map<String, num>> getFeaturedStatistics() =>
      _database.getFeaturedStatistics();
}
