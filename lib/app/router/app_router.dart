import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/assistant/domain/models/verified_fact.dart';
import '../../features/assistant/presentation/screens/assistant_home_screen.dart';
import '../../features/assistant/presentation/screens/conversation_history_screen.dart';
import '../../features/assistant/presentation/screens/conversation_screen.dart';
import '../../features/assistant/presentation/screens/verified_result_detail_screen.dart';
import '../../features/assistant/presentation/screens/voice_input_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/documents/presentation/screens/document_capture_screen.dart';
import '../../features/documents/presentation/screens/document_guidance_screen.dart';
import '../../features/forms/domain/models/assisted_form.dart';
import '../../features/forms/presentation/screens/form_guidance_screen.dart';
import '../../features/forms/presentation/screens/form_review_screen.dart';
import '../../features/handoff/presentation/screens/human_handoff_screen.dart';
import '../../features/life_events/domain/models/life_event.dart';
import '../../features/life_events/presentation/screens/life_event_plan_screen.dart';
import '../../features/life_events/presentation/screens/life_events_screen.dart';
import '../../features/services_directory/domain/models/government_service.dart';
import '../../features/services_directory/presentation/screens/service_detail_screen.dart';
import '../../features/services_directory/presentation/screens/services_directory_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/accessibility_screen.dart';
import '../../features/settings/presentation/screens/language_preference_screen.dart';
import '../../features/settings/presentation/screens/offline_mode_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/voice_settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../shell/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/onboarding/language',
        builder: (context, state) =>
            const LanguagePreferenceScreen(isOnboarding: true),
      ),

      // Shell: bottom-nav surfaces
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _fadePage(
              state,
              const AssistantHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/services',
            pageBuilder: (context, state) => _fadePage(
              state,
              const ServicesDirectoryScreen(),
            ),
          ),
          GoRoute(
            path: '/life-events',
            pageBuilder: (context, state) => _fadePage(
              state,
              const LifeEventsScreen(),
            ),
          ),
          GoRoute(
            path: '/activity',
            pageBuilder: (context, state) => _fadePage(
              state,
              const ActivityScreen(),
            ),
          ),
        ],
      ),

      // Full-screen routes (outside the shell)
      GoRoute(
        path: '/assistant/conversation/:threadId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra is Map<String, Object?>
              ? state.extra as Map<String, Object?>
              : const <String, Object?>{};
          return ConversationScreen(
            initialPrompt: extra['prompt'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/assistant/voice',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VoiceInputScreen(),
      ),
      GoRoute(
        path: '/assistant/verified',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final fact = state.extra as VerifiedFact;
          return VerifiedResultDetailScreen(fact: fact);
        },
      ),
      GoRoute(
        path: '/conversations',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConversationHistoryScreen(),
      ),
      GoRoute(
        path: '/services/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          final service = extra is GovernmentService
              ? extra
              : ServicesCatalogue.all.firstWhere(
                  (s) => s.id == state.pathParameters['id'],
                  orElse: () => ServicesCatalogue.all.first,
                );
          return ServiceDetailScreen(service: service);
        },
      ),
      GoRoute(
        path: '/life-events/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          final event = extra is LifeEvent
              ? extra
              : LifeEventsCatalogue.all.firstWhere(
                  (e) => e.id == state.pathParameters['id'],
                  orElse: () => LifeEventsCatalogue.all.first,
                );
          return LifeEventPlanScreen(event: event);
        },
      ),
      GoRoute(
        path: '/forms/start',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FormGuidanceScreen(),
      ),
      GoRoute(
        path: '/forms/review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, Object?>;
          final form = extra['form'] as AssistedForm;
          final values = (extra['values'] as Map).cast<String, String>();
          return FormReviewScreen(form: form, values: values);
        },
      ),
      GoRoute(
        path: '/documents',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DocumentGuidanceScreen(),
      ),
      GoRoute(
        path: '/documents/capture',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra is Map<String, Object?>
              ? state.extra as Map<String, Object?>
              : const <String, Object?>{};
          return DocumentCaptureScreen(
            documentType: (extra['documentType'] as String?) ?? 'Document',
          );
        },
      ),
      GoRoute(
        path: '/handoff',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HumanHandoffScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LanguagePreferenceScreen(),
      ),
      GoRoute(
        path: '/settings/voice',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VoiceSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/accessibility',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccessibilityScreen(),
      ),
      GoRoute(
        path: '/settings/offline',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OfflineModeScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
