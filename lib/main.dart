// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Utils/classes.dart';
import 'Pages/main_page.dart';
import 'Pages/logs_page.dart';
import 'Pages/help_page.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();   // Keeps screen on
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);   // Just portrait
  await getStorageData();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(builder: (context) =>
      ValueListenableBuilder(
        valueListenable: themeColorChanged,
        builder: (context, value, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;
              if (gettedTheme[4]=='system')
              {
                if (lightDynamic != null && darkDynamic != null) {
                lightColorScheme = lightDynamic.harmonized();
                darkColorScheme = darkDynamic.harmonized();
                } else {
                  lightColorScheme = ColorScheme.fromSeed(
                    seedColor: const Color.fromARGB(255, 0, 255, 200),
                    brightness: Brightness.light,
                  );
                  darkColorScheme = ColorScheme.fromSeed(
                    seedColor: const Color.fromARGB(255, 0, 255, 200),
                    brightness: Brightness.dark,
                  );
                }
              } else {
                lightColorScheme = ColorScheme.fromSeed(
                  seedColor: Color.fromARGB(gettedTheme[0], gettedTheme[1], gettedTheme[2], gettedTheme[3]),
                  brightness: Brightness.light,
                );
                darkColorScheme = ColorScheme.fromSeed(
                  seedColor: Color.fromARGB(gettedTheme[0], gettedTheme[1], gettedTheme[2], gettedTheme[3]),
                  brightness: Brightness.dark,
                );
              }

              return ValueListenableBuilder<ThemeMode>(
                valueListenable: themeMode,
                
                builder: (context, ThemeMode currentMode, _) {
                  return ScreenUtilInit(
                    designSize: Size(1440, 3088),   // Tested on S23U
                    builder: (_, child) =>  MaterialApp(
                      home: const HomePage(),
                      debugShowCheckedModeBanner: false,
                      title: 'LoCo',
                      theme: ThemeData(
                        colorScheme: lightColorScheme,
                        useMaterial3: true,
                      ),
                      darkTheme: ThemeData(
                        colorScheme: darkColorScheme,
                        useMaterial3: true,
                      ),
                      themeMode: currentMode,
                    )
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    themeColorChanged.removeListener(()=> setState(() {}));
    themeColorChanged.addListener(()=> setState(() {}));

    if(isPasswordOn) {
      void askPassword() async {
        screenLock(
          context: context,
          correctString: await secureStorage.read(key: 'password') ?? '0000',
          canCancel: true,
          config: ScreenLockConfig(
            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
            textStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 30.sp),
            titleTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 60.sp),
            buttonStyle: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(69, 118, 118, 118),
            )
          ),
          cancelButton: Icon(Icons.cancel, size: 85.sp,),
          footer: GestureDetector(
            onTap: ()=> showAnswerPasscodeQuestion(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 80.sp,),
                Text(sentences.FORGOT_PIN, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp),),
              ],
            )
          ),
          onUnlocked: () {
            Navigator.pop(context);
          },
          onCancelled: () => exit(0),
        );
      }
      askPassword();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MethodChannel('com.LoCo.iotrix/deeplink').setMethodCallHandler((call) async {   // For importing items from file or qr code
        if (call.method == 'onDeepLink') {
          try {
            final String url = call.arguments;
            itemReceived(context, url.split('//').last);
          }
          catch(e) {
            customDialog(
              context, 
              sentences.ERROR, 
              sentences.IMPORT_ERROR, 
              [],
            );
          }
        }
      });
      if(firstOpened['addButton']??true) {
        Future.delayed(Duration(seconds: 1), () {
          ShowCaseWidget.of(context).startShowCase([showcase_pages, showcase_addButton]);
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation = Tween<Offset>(
              begin: _index > _previousIndex 
                  ? const Offset(-1.0, 0.0)   // If _index increased, Left to Right
                  : const Offset(1.0, 0.0),   // If _index decreased, Right to Left
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          child: pageList.elementAt(_index),
        ),
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: sentences.APPNAME,
            builder: (context, value, child) {
              return Text(sentences.APPNAME.text, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 78.sp),);
            }
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(80.sp)),
          ),
          shadowColor: Theme.of(context).colorScheme.primary.withAlpha(80),
          elevation: 36.sp,
          toolbarHeight: 200.sp,
          leading: IconButton(
            padding: EdgeInsets.all(40.sp),
            icon: Icon(Icons.info_outline, size: 100.sp,),
            onPressed: () => showAbout(context),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Showcase(
                  key: showcase_helpButton,
                  title: sentences.SC_HELP_BUTTON,
                  titleAlignment: Alignment.center,
                  titleTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(220), fontSize: 55.sp),
                  description: sentences.SC_HELP_BUTTON_DES,
                  descriptionTextDirection: sentences.direction,
                  descTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 44.sp),
                  targetBorderRadius: BorderRadius.circular(200.sp),
                  targetPadding: EdgeInsets.all(5.sp),
                  tooltipBackgroundColor: Theme.of(context).cardColor,
                  tooltipPadding: EdgeInsets.all(30.sp),
                  tooltipBorderRadius: BorderRadius.circular(40.sp),
                  disposeOnTap: false,
                  onTargetClick: () async {
                    firstOpened['helpButton'] = false;
                    await localStorage.setItem('firstOpened', firstOpened);
                  },
                  onBarrierClick: () async {
                    firstOpened['helpButton'] = false;
                    await localStorage.setItem('firstOpened', firstOpened);
                  },
                  child: OpenContainer(
                    transitionType: ContainerTransitionType.fade,
                    transitionDuration: Duration(milliseconds: 350),
                    closedElevation: 0,
                    closedShape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(280.sp)),
                    clipBehavior: Clip.none,
                    closedColor: Colors.transparent,
                    openColor: Colors.transparent,
                    tappable: true,
                    onClosed: (data) {
                    },
                    closedBuilder: (context, openContainer) {
                      return IconButton(
                        padding: EdgeInsets.all(40.sp),
                        icon: Icon(Icons.help_outline_rounded, size: 100.sp,),
                        onPressed: openContainer,
                      );
                    },
                    openBuilder: (context, _) {
                      return HelpPage();
                    },
                  ),
                ),
                OpenContainer(
                  transitionType: ContainerTransitionType.fade,
                  transitionDuration: Duration(milliseconds: 350),
                  closedElevation: 0,
                  closedShape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(280.sp)),
                  clipBehavior: Clip.none,
                  closedColor: Colors.transparent,
                  openColor: Colors.transparent,
                  tappable: true,
                  onClosed: (data) {
                  },
                  closedBuilder: (context, openContainer) {
                    return IconButton(
                      padding: EdgeInsets.all(40.sp),
                      icon: Icon(Icons.library_books_outlined, size: 100.sp,),
                      onPressed: openContainer,
                    );
                  },
                  openBuilder: (context, _) {
                    return LogsPage();
                  },
                ),
              ]
            ),
          ]
        ),
        bottomNavigationBar: CircleNavBar(
          activeIcons: [
            Icon(Icons.speed_rounded, size: 130.sp),
            Icon(CupertinoIcons.settings, size: 130.sp)
          ],
          inactiveIcons: [
            Icon(Icons.speed_rounded, size: 100.sp),
            Icon(CupertinoIcons.settings, size: 100.sp)
          ],
          color: Theme.of(context).colorScheme.primary.withAlpha(40),
          circleColor: Theme.of(context).colorScheme.primary.withAlpha(40),
          height: 240.sp,
          circleWidth: 240.sp,
          activeIndex: _index,
          onTap: (v) {
            setState(() {
              _previousIndex = _index;
              _index = v;
              pagelistNavigationValue = v;
            });
          },
          //tabCurve: ,
          padding: EdgeInsets.only(left: 50.w, right: 50.w, bottom: 60.sp, top: 20.sp),
          cornerRadius: BorderRadius.only(
            topLeft: Radius.circular(90.sp),
            topRight: Radius.circular(90.sp),
            bottomRight: Radius.circular(90.sp),
            bottomLeft: Radius.circular(90.sp),
          ),
          shadowColor: Theme.of(context).colorScheme.primary.withAlpha(75),
          circleShadowColor: Theme.of(context).colorScheme.primary.withAlpha(75),
          elevation: 60.sp,
          tabCurve: Curves.easeOutBack,
          iconCurve: Curves.easeInOutBack,
          iconDurationMillSec: 950,
          tabDurationMillSec: 1000,
        ),
        floatingActionButton: pagelistNavigationValue!=0 ? null : 
          Showcase(
            key: showcase_addButton,
            title: sentences.SC_ADD_BUTTON,
            titleAlignment: Alignment.center,
            titleTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(220), fontSize: 55.sp),
            description: sentences.SC_ADD_BUTTON_DES,
            descriptionTextDirection: sentences.direction,
            descTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 44.sp),
            targetBorderRadius: BorderRadius.circular(70.sp),
            targetPadding: EdgeInsets.all(130.sp),
            tooltipBackgroundColor: Theme.of(context).cardColor,
            tooltipPadding: EdgeInsets.all(30.sp),
            tooltipBorderRadius: BorderRadius.circular(40.sp),
            disposeOnTap: false,
            onTargetClick: () async {
              firstOpened['addButton'] = false;
              await localStorage.setItem('firstOpened', firstOpened);
            },
            onBarrierClick: () async {
              firstOpened['addButton'] = false;
              await localStorage.setItem('firstOpened', firstOpened);
            },
            child: SpeedDialFabWidget(
              secondaryIconsList: [
                Icons.download_rounded,
                Icons.library_add_outlined,
              ],
              secondaryIconsText: [
                sentences.IMPORT_ITEM,
                sentences.ADD_ITEM,
              ],
              secondaryIconsOnPress: [
                () async {
                  if(await Permission.camera.isPermanentlyDenied) {
                    customDialog(
                      context, 
                      sentences.ERROR, 
                      sentences.PERMISSION_ERROR2, 
                      [],
                    );
                  }
                  else if(!await Permission.camera.isGranted) {
                    await Permission.camera.request();
                    if(await Permission.camera.isGranted) {
                      showImportItem(context);
                    }
                    else {
                      customDialog(
                        context, 
                        sentences.ERROR, 
                        sentences.PERMISSION_ERROR, 
                        [],
                      );
                    }
                  }
                  else if(await Permission.camera.isGranted){
                    showImportItem(context);
                  }
                },
                () {
                  if(pagelistToggleValue==0) {
                    showAddHomeItem(context, ['','false!!!!','','','','','','8181'], '', 0, true, 'i1', 'online');   // [name, hasSsl !! brokerUrl, username, password, topic, message, localIp, localPort] , id, tileNumber, iconsSlideAnimation, icon, mode
                  }
                  else {
                    showAddReceiver(context, ['','false!!!!','','','','','8181'], '', true, 'i1', 'online');   // [name, hasSsl !! brokerUrl, username, password, topic, localIp, localPort] , id, iconsSlideAnimation, icon, mode
                  }
                }
              ],
              primaryIconExpand: Icons.add_rounded,
              secondaryBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(80),
              secondaryForegroundColor: Colors.white,
              primaryBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(80),
              primaryForegroundColor: Colors.white,
            ),
          ),
      ),
    );
  }
}