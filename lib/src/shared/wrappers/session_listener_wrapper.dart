import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';

import 'package:aajhee_business/src/features/auth/presentation/providers/session_provider.dart';


class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
      }
    });

    // ref.listen only fires on changes. On web, auth can resolve before this
    // widget mounts, leaving the HTML splash background stuck as a white screen.
    if (session.status != SessionStatus.unknown) {
      FlutterNativeSplash.remove();
    }

    return child;
  }
}
