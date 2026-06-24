import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';

import 'package:goluto_business/src/features/auth/presentation/providers/session_provider.dart';


class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
      }
    });

    return child;
  }
}
