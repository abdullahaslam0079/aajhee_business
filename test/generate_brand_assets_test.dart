import 'package:flutter_test/flutter_test.dart';

import '../tool/generate_brand_assets.dart' as generator;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates business brand assets', () async {
    await generator.main();
  });
}
