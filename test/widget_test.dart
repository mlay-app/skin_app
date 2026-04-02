import 'package:flutter_test/flutter_test.dart';

import 'package:skin_app/app/app.dart';

void main() {
  testWidgets('Home page renders expected controls', (WidgetTester tester) async {
    await tester.pumpWidget(const SkinApp());
    await tester.pumpAndSettle();

    expect(find.text('脱毛仪测试 App'), findsOneWidget);
    expect(find.text('请求蓝牙/定位权限'), findsOneWidget);
    expect(find.text('读取蓝牙适配器状态'), findsOneWidget);
  });
}
