import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/config_option/overview/config_options_page.dart';
import 'package:hiddify/features/home/widget/home_page.dart';
import 'package:hiddify/features/profile/overview/profiles_overview_page.dart';
import 'package:hiddify/features/stats/widget/side_bar_stats_overview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract interface class RootScaffold {
  static final stateKey = GlobalKey<ScaffoldState>();

  static bool canShowDrawer(BuildContext context) => Breakpoints.small.isActive(context);
}

class AdaptiveRootScaffold extends HookConsumerWidget {
  AdaptiveRootScaffold(this.navigator, {super.key});

  final Widget navigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final selectedIndex = getCurrentIndex(context);

    final destinations = [
      NavigationDestination(
        icon: const Icon(FluentIcons.power_20_filled),
        label: t.home.pageTitle,
      ),
      NavigationDestination(
        icon: const Icon(Icons.switch_account_rounded),
        label: t.profile.overviewPageTitle,
      ),
      NavigationDestination(
        icon: const Icon(FluentIcons.document_text_20_filled),
        label: t.logs.pageTitle,
      ),
      NavigationDestination(
        icon: const Icon(FluentIcons.settings_20_filled),
        label: t.config.pageTitle,
      ),
      NavigationDestination(
        icon: const Icon(FluentIcons.info_20_filled),
        label: t.about.pageTitle,
      ),
    ];
    final pageController = usePageController();
    final notchController = useNotchBottomBarController();
    final theme = Theme.of(context);
    final mobileDestinations = [
      (
        icon: Icon(
          FluentIcons.home_24_filled,
          color: theme.colorScheme.secondary,
        ),
        activeIcon: Icon(
          FluentIcons.home_24_filled,
          color: theme.colorScheme.primary,
        ),
        label: t.home.pageTitle,
        page: const HomePage(),
      ),
      // (
      //   icon: const Icon(FluentIcons.filter_20_filled),
      //   label: t.proxies.pageTitle,
      //   page: const ProxiesOverviewPage(),
      // ),
      (
        icon: Icon(
          Icons.switch_account_rounded,
          color: theme.colorScheme.secondary,
        ),
        activeIcon: Icon(Icons.switch_account_rounded, color: theme.colorScheme.primary),
        label: t.profile.overviewPageTitle,
        page: const ProfilesOverviewModal(),
      ),
      (
        icon: Icon(
          FluentIcons.settings_20_filled,
          color: theme.colorScheme.secondary,
        ),
        activeIcon: Icon(FluentIcons.settings_20_filled, color: theme.colorScheme.primary),
        label: t.config.pageTitle,
        page: ConfigOptionsPage(),
      ),
      // (
      //   icon: const Icon(FluentIcons.info_20_filled),
      //   label: t.about.pageTitle,
      //   page: const AboutPage(),
      // ),
    ];

    return _CustomAdaptiveScaffold(
      pageController: pageController,
      notchController: notchController,
      mobiledestinations: mobileDestinations,
      selectedIndex: selectedIndex,
      onSelectedIndexChange: (index) {
        RootScaffold.stateKey.currentState?.closeDrawer();
        switchTab(index, context);
      },
      destinations: destinations,
      drawerDestinationRange: useMobileRouter ? (5, null) : (0, null),
      bottomDestinationRange: (0, 5),
      useBottomSheet: useMobileRouter,
      sidebarTrailing: const Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SideBarStatsOverview(),
        ),
      ),
      body: navigator,
    );
  }
}

class _CustomAdaptiveScaffold extends HookConsumerWidget {
  _CustomAdaptiveScaffold({
    required this.pageController,
    required this.mobiledestinations,
    required this.notchController,
    required this.selectedIndex,
    required this.onSelectedIndexChange,
    required this.destinations,
    required this.drawerDestinationRange,
    required this.bottomDestinationRange,
    this.useBottomSheet = false,
    this.sidebarTrailing,
    required this.body,
  });

  final int selectedIndex;
  final Function(int) onSelectedIndexChange;
  final List<NavigationDestination> destinations;
  final List<({Icon icon, Icon activeIcon, String label, Widget page})> mobiledestinations;

  final (int, int?) drawerDestinationRange;
  final (int, int?) bottomDestinationRange;
  final bool useBottomSheet;
  final Widget? sidebarTrailing;
  final Widget body;
  final PageController pageController;
  final NotchBottomBarController notchController;
  List<NavigationDestination> destinationsSlice((int, int?) range) => destinations.sublist(range.$1, range.$2);

  int? selectedWithOffset((int, int?) range) {
    final index = selectedIndex - range.$1;
    return index < 0 || (range.$2 != null && index > (range.$2! - 1)) ? null : index;
  }

  void selectWithOffset(int index, (int, int?) range) => onSelectedIndexChange(index + range.$1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final isBottomBarTap = useState(false);

    void onPageChanged(int index) {
      currentIndex.value = index;
      if (isBottomBarTap.value) return;
      notchController.jumpTo(index);
    }

    final theme = Theme.of(context);

    return Scaffold(
      key: RootScaffold.stateKey,
      drawer: Breakpoints.small.isActive(context) && destinationsSlice(drawerDestinationRange).isNotEmpty
          ? Drawer(
              width: (MediaQuery.sizeOf(context).width * 0.88).clamp(1, 304),
              child: NavigationRail(
                extended: true,
                selectedIndex: selectedWithOffset(drawerDestinationRange),
                destinations: destinationsSlice(drawerDestinationRange).map((dest) => AdaptiveScaffold.toRailDestination(dest)).toList(),
                onDestinationSelected: (index) => selectWithOffset(index, drawerDestinationRange),
              ),
            )
          : null,
      body: AdaptiveLayout(
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.medium: SlotLayout.from(
              key: const Key('primaryNavigation'),
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                selectedIndex: selectedIndex,
                destinations: destinations.map((dest) => AdaptiveScaffold.toRailDestination(dest)).toList(),
                onDestinationSelected: onSelectedIndexChange,
              ),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('primaryNavigation1'),
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                extended: true,
                selectedIndex: selectedIndex,
                destinations: destinations.map((dest) => AdaptiveScaffold.toRailDestination(dest)).toList(),
                onDestinationSelected: onSelectedIndexChange,
                trailing: sidebarTrailing,
              ),
            ),
          },
        ),
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('body'),
              inAnimation: AdaptiveScaffold.fadeIn,
              outAnimation: AdaptiveScaffold.fadeOut,
              builder: (context) => PageView(
                controller: pageController,
                // physics: const NeverScrollableScrollPhysics(),
                onPageChanged: onPageChanged,
                children: mobiledestinations.map((dest) => dest.page).toList(),
              ),
            ),
          },
        ),
      ),
      bottomNavigationBar: useBottomSheet && Breakpoints.small.isActive(context)
          ? AnimatedNotchBottomBar(
              kBottomRadius: 32,

              kIconSize: 24,
              notchBottomBarController: notchController,
              // color: Colors.white,
              color: theme.colorScheme.secondaryContainer,
              showLabel: true,
              notchColor: theme.colorScheme.secondaryContainer,
              // removeMargins: false,
              // showTopRadius: false,
              // bottomBarWidth: 500,
              // durationInMilliSeconds: 600,
              bottomBarItems: mobiledestinations
                  .map((dest) => BottomBarItem(
                        inActiveItem: dest.icon,
                        activeItem: dest.activeIcon,
                        itemLabel: dest.label,
                      ))
                  .toList(),
              onTap: (index) {
                isBottomBarTap.value = true;
                pageController.jumpToPage(
                  index,
                  // duration: const Duration(milliseconds: 300),
                  // curve: Curves.easeInOut,
                );

                Future.delayed(Duration(milliseconds: 600), () {
                  isBottomBarTap.value = false;
                });
              },
              // shadowElevation: 1
              // ,
              showBlurBottomBar: true,
            )
          : null,
    );
  }
}

PageController usePageController() {
  return use(const _PageControllerHook());
}

class _PageControllerHook extends Hook<PageController> {
  const _PageControllerHook();

  @override
  _PageControllerHookState createState() => _PageControllerHookState();
}

class _PageControllerHookState extends HookState<PageController, _PageControllerHook> {
  late final PageController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = PageController();
  }

  @override
  PageController build(BuildContext context) => _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

NotchBottomBarController useNotchBottomBarController() {
  return use(const _NotchBottomBarControllerHook());
}

class _NotchBottomBarControllerHook extends Hook<NotchBottomBarController> {
  const _NotchBottomBarControllerHook();

  @override
  _NotchBottomBarControllerHookState createState() => _NotchBottomBarControllerHookState();
}

class _NotchBottomBarControllerHookState extends HookState<NotchBottomBarController, _NotchBottomBarControllerHook> {
  late final NotchBottomBarController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = NotchBottomBarController();
  }

  @override
  NotchBottomBarController build(BuildContext context) => _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
