import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/consts.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:app/positive_affirmations_theme.dart';
import 'package:app/reaffirmation/bloc/reaffirmation_bloc.dart';

class ReaffirmationFormNavigator extends StatefulWidget {
  ReaffirmationFormNavigator();

  @override
  State<StatefulWidget> createState() => _ReaffirmationFormNavigatorState();
}

class _ReaffirmationFormNavigatorState extends State<ReaffirmationFormNavigator>
    with SingleTickerProviderStateMixin {
  _ReaffirmationFormNavigatorState();

  TabController? _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }

  Widget _mapNavigationBarItem(
      ReaffirmationFormTab tab, ReaffirmationFormTab currentTab) {
    return BlocBuilder<ReaffirmationBloc, ReaffirmationState>(
      builder: (context, state) {
        switch (tab) {
          case ReaffirmationFormTab.note:
            return Tab(
              key: PositiveAffirmationsKeys.reaffirmationFormNoteTab,
              child: Text(
                PositiveAffirmationsConsts.reaffirmationFormNoteTabTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: currentTab == ReaffirmationFormTab.note
                      ? PositiveAffirmationsTheme.highlightColor
                      : Colors.black,
                ),
              ),
            );
          case ReaffirmationFormTab.font:
            return Tab(
              key: PositiveAffirmationsKeys.reaffirmationFormFontTab,
              child: Text(
                PositiveAffirmationsConsts.reaffirmationFormFontTabTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: currentTab == ReaffirmationFormTab.font
                      ? PositiveAffirmationsTheme.highlightColor
                      : Colors.black,
                ),
              ),
            );
          case ReaffirmationFormTab.stamp:
            return Tab(
              key: PositiveAffirmationsKeys.reaffirmationFormStampTab,
              child: Text(
                PositiveAffirmationsConsts.reaffirmationFormStampTabTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: currentTab == ReaffirmationFormTab.stamp
                      ? PositiveAffirmationsTheme.highlightColor
                      : Colors.black,
                ),
              ),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaffirmationBloc, ReaffirmationState>(
      buildWhen: (previous, current) => previous.tab != current.tab,
      builder: (context, state) {
        _tabController?.index = ReaffirmationFormTab.values.indexOf(state.tab);
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: Colors.grey.withOpacity(0.05),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              BlocProvider.of<ReaffirmationBloc>(context)
                  .add(TabUpdated(tab: ReaffirmationFormTab.values[index]));
              // onTabSelected(ReaffirmationFormTab.values[index]);
            },
            isScrollable: false,
            tabs: ReaffirmationFormTab.values.map((tab) {
              return _mapNavigationBarItem(tab, state.tab);
            }).toList(),
          ),
        );
      },
    );
  }
}
