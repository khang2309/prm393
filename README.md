# ComputerStoreSys — PRM393 Lab 3

Flutter + SQLite application for managing computer products, brands, product
categories, filters, sorting, and business statistics.

## Main features

- Six persistent tabs: Store, Add Computer, Brands, Categories, Statistics,
  and Featured.
- Complete Brand, Category, and Computer CRUD with validation and protected
  foreign-key deletion.
- Real-time product/brand/category search.
- Combined filters for brand, category, featured status, stock, RAM, storage,
  and price.
- Sorting by price, sold quantity, product name, brand name, and stock.
- SQLite aggregate statistics by store, brand, category, and featured status.
- Product detail calculations for revenue, inventory value, and total units.
- Seed data: 5 brands, 3 categories, and 15 computers.

## Project structure

```text
lib/
  database/   SQLite schema, seed data, JOIN queries, aggregates
  models/     Immutable Brand, ProductCategory, and Computer models
  services/   UI-facing store service
  screens/    Store, forms, management, detail, and statistics screens
  widgets/    Reusable product card
```

The local database is named `ComputerStoreDB.db`.

## Run and verify

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Build an Android debug APK with:

```bash
flutter build apk --debug
```

The generated APK is written to
`build/app/outputs/flutter-apk/app-debug.apk`.
