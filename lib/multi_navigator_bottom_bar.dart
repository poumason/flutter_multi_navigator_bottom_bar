library multi_navigator_bottom_bar;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBarTab {
  final WidgetBuilder routePageBuilder;
  final WidgetBuilder initPageBuilder;
  final WidgetBuilder tabIconBuilder;
  final WidgetBuilder tabTitleBuilder;
  final GlobalKey<NavigatorState> _navigatorKey;

  BottomBarTab({
    @required this.initPageBuilder,
    @required this.tabIconBuilder,
    this.tabTitleBuilder,
    this.routePageBuilder,
    GlobalKey<NavigatorState> navigatorKey,
  }) : _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
}

class MultiNavigatorBottomBar extends StatefulWidget {
  final int currentTabIndex;
  final List<BottomBarTab> tabs;
  final PageRoute pageRoute;
  final ValueChanged<int> onTap;
  final Widget Function(Widget) pageWidgetDecorator;

  MultiNavigatorBottomBar(
      {@required this.currentTabIndex,
      @required this.tabs,
      this.onTap,
      this.pageRoute,
      this.pageWidgetDecorator});

  @override
  State<StatefulWidget> createState() =>
      _MultiNavigatorBottomBarState(currentTabIndex);
}

class _MultiNavigatorBottomBarState extends State<MultiNavigatorBottomBar> {
  int currentIndex;

  _MultiNavigatorBottomBarState(this.currentIndex);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => !await widget
            .tabs[currentIndex]._navigatorKey.currentState
            .maybePop(),
        child: Scaffold(
          body: widget.pageWidgetDecorator == null
              ? _buildPageBody()
              : widget.pageWidgetDecorator(_buildPageBody()),
          bottomNavigationBar: _buildBottomBar(),
        ),
      );

  Widget _buildPageBody() {
    List<Widget> navigators = [];
    for (BottomBarTab tab in widget.tabs) {
      navigators.add(_buildOffstageNavigator(tab));
    }

    return Stack(children: navigators);
  }

  Widget _buildOffstageNavigator(BottomBarTab tab) {
    return Offstage(
      offstage: widget.tabs.indexOf(tab) != currentIndex,
      child: TabPageNavigator(
        navigatorKey: tab._navigatorKey,
        initPage: tab.initPageBuilder(context),
        pageRoute: widget.pageRoute,
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      items: widget.tabs
          .map((tab) => BottomNavigationBarItem(
                icon: tab.tabIconBuilder(context),
                title: tab.tabTitleBuilder(context),
              ))
          .toList(),
      onTap: widget.onTap ?? (index) => setState(() => currentIndex = index),
      currentIndex: currentIndex,
    );
  }
}

class TabPageNavigator extends StatelessWidget {
  TabPageNavigator(
      {@required this.navigatorKey, @required this.initPage, this.pageRoute});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget initPage;
  final PageRoute pageRoute;

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onGenerateRoute: (routeSettings) =>
            pageRoute ??
            MaterialPageRoute(
              builder: (context) =>
                  _defaultPageRouteBuilder(routeSettings.name)(context),
            ),
        observers: [HeroController()],
      );

  WidgetBuilder _defaultPageRouteBuilder(String routName, {String heroTag}) {
    return (context) => initPage;
  }
}
