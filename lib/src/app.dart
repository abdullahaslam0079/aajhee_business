import 'package:goluto_business/src/imports/core_imports.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilWrapper(
      designSize: kIsWeb ? const Size(1440, 900) : const Size(360, 690),
      child: _buildMaterialApp(context),
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp.router(
      title: 'GoLuto Business',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#1F1F21'),
      darkTheme: buildDarkTheme(primaryColorHex: '#CFCFD4'),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}
