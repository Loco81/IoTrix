import 'package:flutter/material.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/Utils/classes.dart';
import 'senders_page.dart';
import 'receivers_page.dart';
import 'settings_page.dart';




List<Widget> pageList = [
  const MainPage(),
  const SettingsPage()
];
List<Widget> togglePageList = [
  SendersPage(),
  ReceiversPage()
];
int pagelistToggleValue = 0;
int pagelistNavigationValue = 0;



class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: mainPageToggleChanged,
      builder: (context, t, child) =>  Column(
        children: [
          Showcase(
            key: showcase_pages,
            title: sentences.SC_PAGES,
            titleAlignment: Alignment.center,
            titleTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(220), fontSize: 55.sp),
            description: sentences.SC_PAGES_DES,
            descriptionTextDirection: sentences.direction,
            descTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 44.sp),
            targetBorderRadius: BorderRadius.circular(42.sp),
            targetPadding: EdgeInsets.all(0),
            tooltipBackgroundColor: Theme.of(context).cardColor,
            tooltipPadding: EdgeInsets.all(30.sp),
            tooltipBorderRadius: BorderRadius.circular(40.sp),
            disposeOnTap: false,
            onTargetClick: () async {
              firstOpened['pages'] = false;
              await localStorage.setItem('firstOpened', firstOpened);
            },
            onBarrierClick: () async {
              firstOpened['pages'] = false;
              await localStorage.setItem('firstOpened', firstOpened);
            },
            child: CustomAnimatedToggle(
              values: [sentences.ITEMS, sentences.RECEIVERS],
              pageValue: pagelistToggleValue,
              onToggleCallback: (value) {
                setState(() {
                  pagelistToggleValue = value;
                });
              },
              buttonColor: Theme.of(context).colorScheme.primary.withAlpha(115),
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(38),
              textColor: const Color(0xFFFFFFFF),
              activeFontSize: 50.sp,
              inactiveFontSize: 46.sp,
              totalHeight: 140.sp,
              switchHeight: 105.sp,
              activeSwitchWidth: 680.w,
              activeSwitchHeight: 110.sp,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (info) {
                if(info.primaryVelocity! > 0) {
                    pagelistToggleValue = 0;
                }
                else if(info.primaryVelocity! < 0) {
                    pagelistToggleValue = 1;              
                }
                setState(() {});
              },
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: togglePageList.elementAt(pagelistToggleValue)
              ),
            ),
          ),
        ],
      ),
    );
  }
}