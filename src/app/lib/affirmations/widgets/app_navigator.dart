import 'package:app/affirmations/blocs/apptab/apptab_bloc.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:app/positive_affirmations_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppNavigator extends StatefulWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  AppNavigator({
    Key? key,
    required this.activeTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _AppNavigatorState(activeTab: activeTab, onTabSelected: onTabSelected);
}

class _AppNavigatorState extends State<AppNavigator>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  _AppNavigatorState({
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  Tab _mapNavigationBarItem(AppTab tab, AppTab currentTab) {
    switch (tab) {
      case AppTab.affirmations:
        return Tab(
          key: PositiveAffirmationsKeys.homeTab,
          icon: FaIcon(
            currentTab == AppTab.affirmations
                ? FontAwesomeIcons.solidHeart
                : FontAwesomeIcons.heart,
            key: PositiveAffirmationsKeys.homeTabIcon,
            color: currentTab == AppTab.affirmations
                ? PositiveAffirmationsTheme.highlightColor
                : Colors.black,
          ),
          child: Text(
            'Affirmations',
            key: PositiveAffirmationsKeys.homeTabLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: currentTab == AppTab.affirmations
                  ? PositiveAffirmationsTheme.highlightColor
                  : Colors.black,
            ),
          ),
        );
      case AppTab.profile:
        return Tab(
          key: PositiveAffirmationsKeys.profileTab,
          icon: FaIcon(
            currentTab == AppTab.profile
                ? FontAwesomeIcons.solidUserCircle
                : FontAwesomeIcons.userCircle,
            key: PositiveAffirmationsKeys.profileTabIcon,
            color: currentTab == AppTab.profile
                ? PositiveAffirmationsTheme.highlightColor
                : Colors.black,
          ),
          child: Text(
            'Profile',
            key: PositiveAffirmationsKeys.profileTabLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: currentTab == AppTab.profile
                  ? PositiveAffirmationsTheme.highlightColor
                  : Colors.black,
            ),
          ),
        );
      default:
        return const Tab(
          icon: Text(
            'Affirmations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApptabBloc, AppTab>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        _tabController?.index = AppTab.values.indexOf(state);
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: Colors.grey.withOpacity(0.05),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              onTabSelected(AppTab.values[index]);
            },
            isScrollable: false,
            tabs: AppTab.values.map((tab) {
              return _mapNavigationBarItem(tab, state);
            }).toList(),
          ),
        );
      },
    );
  }
}
