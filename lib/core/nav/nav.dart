// ignore_for_file: strict_raw_type, argument_type_not_assignable
// ignore_for_file: inference_failure_on_untyped_parameter

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/auth/base_auth_user_provider.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/fotos_anuais/fotos_anuais.page.dart';
import 'package:sentimento_app/ui/pages/gallery/gallery.page.dart';
import 'package:sentimento_app/ui/pages/goals/goals.page.dart';
import 'package:sentimento_app/ui/pages/home/home.page.dart';
import 'package:sentimento_app/ui/pages/journal/journal.page.dart';
import 'package:sentimento_app/ui/pages/login/login.page.dart';
import 'package:sentimento_app/ui/pages/main/main.page.dart';
import 'package:sentimento_app/ui/pages/profile/profile.page.dart';
import 'package:sentimento_app/ui/pages/settings/settings.page.dart';
import 'package:sentimento_app/ui/pages/stats/stats.page.dart';
import 'package:sentimento_app/ui/pages/gym/gym_list_page.dart';
import 'package:sentimento_app/ui/pages/gym/gym_register_page.dart';
import 'package:sentimento_app/ui/pages/gym/gym_manager_page.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';

// Project imports:

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  bool get showingSplashImage => showSplashImage;
  String? _redirectLocation;

  /// Determine the current user's state.
  Future<void> initializePersistedState() async {}

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(final String loc) =>
      _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  // ignore: avoid_positional_boolean_parameters, use_setters_to_change_properties
  void updateNotifyOnAuthChange(final bool notify) =>
      notifyOnAuthChange = notify;

  void update(final BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(final AppStateNotifier appStateNotifier) => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: appStateNotifier,
  navigatorKey: appNavigatorKey,
  errorBuilder: (final context, final state) => appStateNotifier.loggedIn
      ? const MainPageWidget()
      : const LoginPageWidget(),
  routes: [
    FFRoute(
      name: '_initialize',
      path: '/',
      builder: (final context, final _) => appStateNotifier.loggedIn
          ? const MainPageWidget()
          : const LoginPageWidget(),
    ),
    FFRoute(
      name: MainPageWidget.routeName,
      path: MainPageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const MainPageWidget(),
    ),
    FFRoute(
      name: HomePageWidget.routeName,
      path: HomePageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const HomePageWidget(),
    ),
    FFRoute(
      name: JournalPageWidget.routeName,
      path: JournalPageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const JournalPageWidget(),
    ),
    FFRoute(
      name: StatsPageWidget.routeName,
      path: StatsPageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const StatsPageWidget(),
    ),
    FFRoute(
      name: ProfilePageWidget.routeName,
      path: ProfilePageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const ProfilePageWidget(),
    ),
    FFRoute(
      name: SettingsPageWidget.routeName,
      path: SettingsPageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const SettingsPageWidget(),
    ),
    FFRoute(
      name: GoalsPageWidget.routeName,
      path: GoalsPageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const GoalsPageWidget(),
    ),
    FFRoute(
      name: GalleryPageWidget.routeName,
      path: GalleryPageWidget.routePath,
      requireAuth: true,
      builder: (final context, final params) => const GalleryPageWidget(),
    ),
    FFRoute(
      name: 'FotosAnuais',
      path: '/fotosAnuais',
      requireAuth: true,
      builder: (final context, final params) => const FotosAnuaisPage(),
    ),
    FFRoute(
      name: GymListPage.routeName,
      path: GymListPage.routePath,
      requireAuth: true,
      builder: (final context, final params) => const GymListPage(),
    ),
    FFRoute(
      name: GymRegisterPage.routeName,
      path: GymRegisterPage.routePath,
      requireAuth: true,
      builder: (final context, final params) {
        final extra = params.state.extra;
        GymExercisesRow? exercise;
        bool isDuplication = false;

        if (extra is GymExercisesRow) {
          exercise = extra;
        } else if (extra is Map) {
          exercise = extra['exercise'] as GymExercisesRow?;
          isDuplication = (extra['isDuplication'] ?? false) as bool;
        }

        return GymRegisterPage(
          exercise: exercise,
          isDuplication: isDuplication,
        );
      },
    ),
    FFRoute(
      name: GymManagerPage.routeName,
      path: GymManagerPage.routePath,
      requireAuth: true,
      builder: (final context, final params) => const GymManagerPage(),
    ),
    FFRoute(
      name: 'Login',
      path: '/login',
      builder: (final context, final params) => const LoginPageWidget(),
    ),
  ].map((final r) => r.toRoute(appStateNotifier)).toList(),
);

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
    entries
        .where((final e) => e.value != null)
        .map((final e) => MapEntry(e.key, e.value!)),
  );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    final String name,
    // ignore: avoid_positional_boolean_parameters
    final bool mounted, {
    final Map<String, String> pathParameters = const <String, String>{},
    final Map<String, String> queryParameters = const <String, String>{},
    final Object? extra,
    final bool ignoreRedirect = false,
  }) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
      ? null
      : goNamed(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
        );

  Future<T?>? pushNamedAuth<T extends Object?>(
    final String name,
    // ignore: avoid_positional_boolean_parameters
    final bool mounted, {
    final Map<String, String> pathParameters = const <String, String>{},
    final Map<String, String> queryParameters = const <String, String>{},
    final Object? extra,
    final bool ignoreRedirect = false,
  }) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
      ? null
      : pushNamed<T>(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
        );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  // ignore: avoid_positional_boolean_parameters
  void prepareAuthEvent([final bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
      ? null
      : appState.updateNotifyOnAuthChange(false);
  // ignore: avoid_positional_boolean_parameters
  bool shouldRedirect(final bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(final String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra is Map<String, dynamic> ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(final MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() =>
      Future.wait(
            state.allParams.entries.where(isAsyncParam).map((
              final param,
            ) async {
              final doc = await asyncParams[param.key]!(
                param.value,
              ).onError((final _, final __) => null);
              if (doc != null) {
                futureParamValues[param.key] = doc;
                return true;
              }
              return false;
            }),
          )
          .onError((final _, final __) => [false])
          .then((final v) => v.every((final e) => e));

  dynamic getParam<T>(
    final String paramName,
    final ParamType type, {
    final bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(param, type, isList);
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(final AppStateNotifier appStateNotifier) => GoRoute(
    name: name,
    path: path,
    redirect: (final context, final state) {
      if (appStateNotifier.shouldRedirect) {
        final redirectLocation = appStateNotifier.getRedirectLocation();
        appStateNotifier.clearRedirectLocation();
        return redirectLocation;
      }

      if (requireAuth && !appStateNotifier.loggedIn) {
        appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
        return '/login';
      }
      return null;
    },
    pageBuilder: (final context, final state) {
      fixStatusBarOniOS16AndBelow(context);
      final ffParams = FFParameters(state, asyncParams);
      final page = ffParams.hasFutures
          ? FutureBuilder(
              future: ffParams.completeFutures(),
              builder: (final context, final _) => builder(context, ffParams),
            )
          : builder(context, ffParams);
      final child = page;

      final transitionInfo = state.transitionInfo;
      return transitionInfo.hasTransition
          ? CustomTransitionPage(
              key: state.pageKey,
              child: child,
              transitionDuration: transitionInfo.duration,
              transitionsBuilder:
                  (
                    final context,
                    final animation,
                    final secondaryAnimation,
                    final child,
                  ) =>
                      PageTransition(
                        type: transitionInfo.transitionType,
                        duration: transitionInfo.duration,
                        reverseDuration: transitionInfo.duration,
                        alignment: transitionInfo.alignment,
                        child: child,
                      ).buildTransitions(
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ),
            )
          : MaterialPage(key: state.pageKey, child: child);
    },
    routes: routes,
  );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() =>
      const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  // ignore: avoid_positional_boolean_parameters
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(final BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(final Widget child, {final String? errorRoute}) =>
      Provider.value(value: RootPageContext(true, errorRoute), child: child);
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final lastMatch = routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
