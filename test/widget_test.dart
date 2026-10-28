import 'dart:io';

import 'package:computer_store_sys/database/database_helper.dart';
import 'package:computer_store_sys/main.dart';
import 'package:computer_store_sys/widgets/computer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

Future<void> pumpDatabaseTasks(WidgetTester tester, {int cycles = 4}) async {
  await tester.runAsync(() async {
    await Future.wait<Object>([
      DatabaseHelper.instance.getBrands(),
      DatabaseHelper.instance.getCategories(),
      DatabaseHelper.instance.getComputers(),
    ]);
  });
  for (var index = 0; index < cycles; index++) {
    await tester.pump(const Duration(milliseconds: 150));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
  }
  await tester.pump();
}

void main() {
  late Directory testDatabaseDirectory;

  setUpAll(() async {
    DatabaseHelper.ensureInitialized();
    testDatabaseDirectory = await Directory.systemTemp.createTemp(
      'computer_store_sys_test_',
    );
    await DatabaseHelper.instance.configureDatabasePathForTesting(
      p.join(testDatabaseDirectory.path, DatabaseHelper.databaseName),
    );
    await DatabaseHelper.instance.deleteDatabaseForTesting();
    await DatabaseHelper.instance.database;
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
    await DatabaseHelper.instance.configureDatabasePathForTesting(null);
    if (testDatabaseDirectory.existsSync()) {
      await testDatabaseDirectory.delete(recursive: true);
    }
  });

  test(
    'SQLite seeds, JOIN filters, and aggregate statistics are correct',
    () async {
      final database = DatabaseHelper.instance;
      final brands = await database.getBrands();
      final categories = await database.getCategories();
      final computers = await database.getAllComputers();

      expect(brands, hasLength(5));
      expect(categories.map((item) => item.categoryName), <String>[
        'Component',
        'Desktop',
        'Laptop',
      ]);
      expect(computers, hasLength(15));
      expect(computers.every((item) => item.brandName.isNotEmpty), isTrue);
      expect(computers.every((item) => item.categoryName.isNotEmpty), isTrue);

      final asus = brands.singleWhere((brand) => brand.brandName == 'ASUS');
      final filtered = await database.getComputers(
        keyword: 'gaming',
        brandId: asus.id,
        categoryId: categories
            .singleWhere((category) => category.categoryName == 'Laptop')
            .id,
        featuredOnly: true,
        priceOption: 'Greater than 1000',
      );
      expect(filtered, isNotEmpty);
      expect(
        filtered.every(
          (item) =>
              item.brandName == 'ASUS' &&
              item.categoryName == 'Laptop' &&
              item.productName.toLowerCase().contains('gaming') &&
              item.isFeatured &&
              item.price > 1000,
        ),
        isTrue,
      );

      final oneTerabyte = await database.getComputers(storageOption: '1 TB');
      expect(oneTerabyte, isNotEmpty);
      expect(
        oneTerabyte.every(
          (item) => item.storage == 1000 || item.storage == 1024,
        ),
        isTrue,
      );
      final twoTerabytesOrMore = await database.getComputers(
        storageOption: '2 TB+',
      );
      expect(twoTerabytesOrMore, isNotEmpty);
      expect(twoTerabytesOrMore.every((item) => item.storage >= 2000), isTrue);

      final statistics = await database.getStatistics();
      expect(statistics['totalProducts'], 15);
      expect(statistics['totalRevenue'], greaterThan(0));
      expect(statistics['totalInventoryValue'], greaterThan(0));
      expect(await database.getBrandStatistics(), hasLength(5));
      expect(await database.getCategoryStatistics(), hasLength(3));
      expect(await database.getBestSellingProduct(), isNotNull);
      expect(await database.getMostExpensiveProduct(), isNotNull);
      expect(await database.getTopBrand(), isNotNull);
      expect(await database.getLowStockProducts(), isNotEmpty);
      expect(
        await database.getFeaturedStatistics(),
        contains('totalFeaturedRevenue'),
      );
    },
  );

  testWidgets('six-tab shell, product detail, and exact delete dialogs work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ComputerStoreApp());
    await tester.runAsync(() async {
      await Future.wait<Object>([
        DatabaseHelper.instance.getBrands(),
        DatabaseHelper.instance.getCategories(),
        DatabaseHelper.instance.getComputers(),
      ]);
    });
    await pumpDatabaseTasks(tester);

    for (final label in const [
      'Store',
      'Add Computer',
      'Brands',
      'Categories',
      'Statistics',
      'Featured',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(ComputerCard), findsWidgets);

    await tester.tap(find.byType(ComputerCard).first);
    await pumpDatabaseTasks(tester);
    expect(find.text('Computer Detail'), findsOneWidget);
    expect(find.text('Business Calculations'), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);
    expect(find.text('Featured'), findsWidgets);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to delete this product?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Brands'));
    await pumpDatabaseTasks(tester);
    await tester.tap(find.byTooltip('Brand actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to delete this brand?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Delete'));
    await pumpDatabaseTasks(tester);
    expect(
      find.text(
        'This brand cannot be deleted because it is currently used by one or more products.',
      ),
      findsOneWidget,
    );
  });
}
