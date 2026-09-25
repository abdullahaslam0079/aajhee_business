import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilWrapper(
      designSize: kIsWeb ? const Size(1440, 900) : const Size(360, 690),
      child: _buildMaterialApp(context, router),
    );
  }

  Widget _buildMaterialApp(BuildContext context, GoRouter router) {
    return MaterialApp.router(
      title: 'Aajhee Business',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#1F1F21'),
      darkTheme: buildDarkTheme(primaryColorHex: '#CFCFD4'),
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child ?? const SizedBox.shrink();
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}
