// ignore_for_file: avoid_print, library_private_types_in_public_api, non_constant_identifier_names, use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:base_codecs/base_codecs.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:udp/udp.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:is_valid/is_valid.dart';

import 'language.dart';
import '/Pages/main_page.dart';




final LocalStorage localStorage = LocalStorage('IoTrix');
final FlutterSecureStorage secureStorage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true, preferencesKeyPrefix: 'IoTrix_'));

Language sentences = Language();
List gettedTheme = [];   // To store theme data
ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);   // System/Light/Dark
ValueNotifier<bool> themeColorChanged = ValueNotifier(false);   // For theme changed setState
ValueNotifier<bool> mainPageToggleChanged = ValueNotifier(false);   // For mainPage toggle changed setState
String themeDropdownValue = sentences.SYSTEM;
late Icon themeModeIcon;
late String languageValue;   // English/Persian
bool isPasswordOn = false;   // App login pincode state
Map<String, dynamic> firstOpened = {};   // For showCase widgets and user guide

KotlinShortcutMethodChannelSender kotlinShortcutMethodChannelSender = KotlinShortcutMethodChannelSender();
KotlinTileMethodChannelSender kotlinTileMethodChannelSender = KotlinTileMethodChannelSender();
List<dynamic> homeItems = [];
List<dynamic> receiverItems = [];
ValueNotifier<bool> homeItemsChanged = ValueNotifier(false);   // For items page setState
ValueNotifier<bool> receiverItemsChanged = ValueNotifier(false);   // For receivers page setState
Map<String, bool> runningSenders = {};
Map<String, List> runningReceivers = {};
bool sentMqtt = false;   // Sets to true if message successfully sent and sets false again
String scanStatus = '';   // Sets to "found" if local network scanner finda an item
int selectedTile = -1;   // -1 to none, otherwise 1 to 6
List<dynamic> logs = [];
ValueNotifier<bool> logsChanged = ValueNotifier(false);   // For logs page setState
final DebouncedLogger logger = DebouncedLogger(   // To add logs and control logs lengh and saving process
  delay: Duration(seconds: 3),   // Save last logs after ? seconds if there is no another log
  firstAction: (String log) {   // Calls when the setLog called
    logs.add(log);
    int len = logs.length;
    if (len > 400) {   // Max logs number
      logs = logs.sublist(len - 400);
    }
    logsChanged.value = !logsChanged.value;
  },
  timerAction: () async {   // // Calls ? seconds after the setLog called
    await localStorage.setItem('logs', logs);
  }
);

final GlobalKey showcase_pages = GlobalKey();
final GlobalKey showcase_addButton = GlobalKey();
final GlobalKey showcase_addHomeItem = GlobalKey();
final GlobalKey showcase_homeItem = GlobalKey();
final GlobalKey showcase_receiverItem = GlobalKey();
final GlobalKey showcase_helpButton = GlobalKey();



Future<void> getStorageData() async {
  await localStorage.ready;

  gettedTheme = [
    await localStorage.getItem('a') ?? 255,
    await localStorage.getItem('r') ?? 0,
    await localStorage.getItem('g') ?? 255,
    await localStorage.getItem('b') ?? 200,
    await localStorage.getItem('theme') ?? 'manual',   // manual/system
    await localStorage.getItem('brightness') ?? 'light',   // light/dark/system
    await localStorage.getItem('language') ?? 'english',   // english/persian
  ];

  if (gettedTheme[5] == 'light') {
    themeMode.value = ThemeMode.light;
    themeModeIcon = const Icon(Icons.brightness_5, size: 28);
  } else if (gettedTheme[5] == 'dark') {
    themeMode.value = ThemeMode.dark;
    themeModeIcon = const Icon(Icons.brightness_2_rounded, size: 28);
  } else if (gettedTheme[5] == 'system') {
    themeMode.value = ThemeMode.system;
    themeModeIcon = const Icon(Icons.brightness_4, size: 28);
  }

  if (gettedTheme[6] == 'english') {
    languageValue='English';
    sentences.setLanguage(languageValue);
  } else {
    languageValue='Persian';
    sentences.setLanguage(languageValue);
  }

  if (gettedTheme[4] == 'system') {
    themeDropdownValue = sentences.SYSTEM;
  } else {
    themeDropdownValue = sentences.MANUAL;
  }

  isPasswordOn = bool.parse(await secureStorage.read(key: 'isPasswordOn') ?? 'false');
  homeItems = await localStorage.getItem('homeItems') ?? [];
  receiverItems = await localStorage.getItem('receiverItems') ?? [];
  logs = await localStorage.getItem('logs') ?? [];

  firstOpened = await localStorage.getItem('firstOpened') ?? {'pages':true, 'addButton':true, 'addHomeItem':true, 'homeItem':true, 'receiverItem':true, 'helpButton':true};
  // firstOpened = {'pages':true, 'addButton':true, 'addHomeItem':true, 'homeItem':true, 'receiverItem':true, 'helpButton':true};   // For test
}

void setThemeMode(currentmode) async {
  HapticFeedback.mediumImpact();
  if (currentmode == ThemeMode.system) {
    themeMode.value = ThemeMode.light;
    themeModeIcon = const Icon(Icons.brightness_5, size: 28);
    await localStorage.setItem('brightness', 'light');
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App theme changed to light mode');
  } else if (currentmode == ThemeMode.light) {
    themeMode.value = ThemeMode.dark;
    themeModeIcon = const Icon(Icons.brightness_2_rounded, size: 28);
    await localStorage.setItem('brightness', 'dark');
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App theme changed to dark mode');
  } else if (currentmode == ThemeMode.dark) {
    themeMode.value = ThemeMode.system;
    themeModeIcon = const Icon(Icons.brightness_4, size: 28);
    await localStorage.setItem('brightness', 'system');
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App theme changed to auto mode');
  }
}

void setColorMode(mode, colorPicker, context) async {
  if (mode == 'system') {
    await localStorage.setItem('theme', 'system');
    themeDropdownValue = sentences.SYSTEM;
    gettedTheme[4] = mode;
    themeColorChanged.value = !themeColorChanged.value;
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App color changed to system color');
  } else {
    colorPicker();
  }
}

void setThemeColor(mounted, color, context) async {
  Navigator.pop(context);
  await localStorage.setItem('a', color[0]);
  await localStorage.setItem('r', color[1]);
  await localStorage.setItem('g', color[2]);
  await localStorage.setItem('b', color[3]);
  await localStorage.setItem('theme', 'manual');
  DateTime dateNow = DateTime.now();
  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App color changed to ARGB ${color[0]}, ${color[1]}, ${color[2]}, ${color[3]}');

  if (!mounted) return;
  themeDropdownValue = sentences.MANUAL;
  gettedTheme[0] = color[0];
  gettedTheme[1] = color[1];
  gettedTheme[2] = color[2];
  gettedTheme[3] = color[3];
  gettedTheme[4] = 'manual';
  themeColorChanged.value = !themeColorChanged.value;
}

void changeLanguage() async {
  HapticFeedback.mediumImpact();
  String currentMode = themeDropdownValue==sentences.SYSTEM ? 'system' : 'manual';
  languageValue=='English' ? languageValue='Persian' : languageValue='English';
  sentences.setLanguage(languageValue);
  themeDropdownValue = currentMode=='system' ? sentences.SYSTEM : sentences.MANUAL;
  await localStorage.setItem('language', languageValue.toLowerCase());
  DateTime dateNow = DateTime.now();
  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App language changed to $languageValue');
}

void showAbout(BuildContext context) {
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(400.sp),
                side: BorderSide.none,
              ),
              title: Text(sentences.ABOUT, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 86.sp),),
              content: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60.sp,
                          height: 60.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withAlpha(200),
                            boxShadow: [BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withAlpha(140),
                              blurRadius: 5,
                              offset: Offset.zero
                            )]
                          ),
                        ),
                        SizedBox(width: 4,),
                        Text(sentences.ABOUT_SUBJECT, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 56.sp),),
                        SizedBox(width: 4,),
                        Container(
                          width: 60.sp,
                          height: 60.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withAlpha(200),
                            boxShadow: [BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withAlpha(140),
                              blurRadius: 5,
                              offset: Offset.zero
                            )]
                          ),
                        ),
                      ],
                    ),
                    Text(sentences.ABOUT_DESCRIPTION, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp), textDirection: sentences.direction,),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Image.asset('assets/Gmail.png', width: 170.sp),
                      onTap: () => urlLauncher(
                          'mailto:hosseinbahiraei81@gmail.com?subject=${sentences.MAIL_SUB}&body=${sentences.MAIL_BOD}'),
                    ),
                    SizedBox(width: 24.w),
                    GestureDetector(
                      child: Image.asset('assets/LocoSite.png', width: 170.sp,),
                      onTap: () => urlLauncher('https://Loco81.ir'),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Center(child: Text(sentences.VERSION, style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 45.sp),))
              ],
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

void showImportItem(BuildContext context) {
  TextEditingController itemLink = TextEditingController(text: '');
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              contentPadding: EdgeInsets.all(100.sp),
              titlePadding: EdgeInsets.fromLTRB(160.sp, 80.sp, 160.sp, 0),
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(340.sp),
                side: BorderSide.none,
              ),
              title: Text(sentences.IMPORT_ITEM, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 76.sp),),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      textDirection: sentences.direction,
                      children: [
                        Text(sentences.FIRST_WAY, textAlign: TextAlign.center, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 48.sp),),
                        Text(sentences.SCAN, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                      ],
                    ),
                    SizedBox(height: 30.sp,),
                    QRViewExample(),
                    Divider(),
                    SizedBox(height: 60.sp,),
                    Row(
                      textDirection: sentences.direction,
                      children: [
                        Text(sentences.SECONT_WAY, textAlign: TextAlign.center, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 48.sp),),
                        Text(sentences.SELECT_FILE, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                      ],
                    ),
                    SizedBox(height: 25.sp,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(30.sp),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(30.sp)
                        )
                      ),
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        final result = await FilePicker.platform.pickFiles(
                          dialogTitle: 'Select .iotrix file',
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['iotrix'],
                        );

                        if (result == null) {
                          print("User canceled.");
                          return;
                        }

                        final file = File(result.files.single.path!);
                        final content = await file.readAsString();

                      
                        HapticFeedback.mediumImpact();
                        Navigator.of(context, rootNavigator: true).pop();
                        try {
                          itemReceived(context, content.split('//').last);
                        }
                        catch(e) {
                          customDialog(
                            context, 
                            sentences.ERROR, 
                            sentences.IMPORT_ERROR, 
                            [],
                          );
                        }
                      },
                      child: Text(sentences.SELECT, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontWeight: FontWeight.bold, fontSize: 42.sp),),
                    ),
                    SizedBox(height: 60.sp,),
                    Divider(),
                    SizedBox(height: 60.sp,),
                    Row(
                      textDirection: sentences.direction,
                      children: [
                        Text(sentences.THIRD_WAY, textAlign: TextAlign.center, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 48.sp),),
                        Text(sentences.PASTE_LINK, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 580.sp,
                          child: TextField(
                            controller: itemLink,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: sentences.LINK,
                              labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                              alignLabelWithHint: true,
                            ),
                            onSubmitted: (n) async {
                              if(itemLink.text!='') {
                                HapticFeedback.mediumImpact();
                                Navigator.of(context, rootNavigator: true).pop();
                                try {
                                  itemReceived(context, itemLink.text.split('//').last);
                                }
                                catch(e) {
                                  customDialog(
                                    context, 
                                    sentences.ERROR, 
                                    sentences.LINK_ERROR, 
                                    [],
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 50.sp,),
                        Column(
                          children: [
                            SizedBox(height: 65.sp,),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.mediumImpact();
                                    try {itemLink.text = (await Clipboard.getData('text/plain'))!.text!;}
                                    catch(e) {/**/}
                                  },
                                  child: Icon(Icons.paste_rounded, size: 80.sp, color: Theme.of(context).colorScheme.primary.withAlpha(230),),
                                ),
                                SizedBox(width: 28.sp,),
                                GestureDetector(
                                  onTap: () async {
                                    if(itemLink.text!='') {
                                      HapticFeedback.mediumImpact();
                                      Navigator.of(context, rootNavigator: true).pop();
                                      try {
                                        itemReceived(context, itemLink.text.split('//').last);
                                      }
                                      catch(e) {
                                        customDialog(
                                          context, 
                                          sentences.ERROR, 
                                          sentences.LINK_ERROR, 
                                          [],
                                        );
                                      }
                                    }
                                  },
                                  child: Icon(Icons.check_circle_outline_rounded, size: 80.sp, color: Theme.of(context).colorScheme.primary.withAlpha(230),),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                )
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool cameraPaused = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 800.w,
          width: 800.w,
          child: _buildQrView(context),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.all(0),
              icon: FutureBuilder(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  return Icon((snapshot.data??false) ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: (snapshot.data??false) ? Colors.orangeAccent : Theme.of(context).colorScheme.primary.withAlpha(220), size: 85.sp,);
                },
              ),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await controller?.toggleFlash();
                setState(() {});
              },
            ),
            IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.flip_camera_android_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 85.sp,),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await controller?.flipCamera();
                setState(() {});
              },
            ),
            IconButton(
              padding: EdgeInsets.all(0),
              icon: FutureBuilder(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  return Icon(cameraPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 85.sp,);
                },
              ),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                cameraPaused ? (await controller?.resumeCamera()) : (await controller?.pauseCamera());
                setState(() {
                  cameraPaused = !cameraPaused;
                });
              },
            ),
          ],
        ),
      ]
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).colorScheme.primary.withAlpha(255), 
        borderRadius: 30.sp, 
        borderLength: 100.sp, 
        borderWidth: 35.sp, 
        cutOutSize: 550.sp,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      controller.stopCamera();
      Navigator.of(context, rootNavigator: true).pop();
      try {
        itemReceived(context, scanData.code!.split('//').last);
      }
      catch(e) {
        customDialog(
          context, 
          sentences.ERROR, 
          sentences.IMPORT_ERROR, 
          [],
        );
      }
    });
  }
}

void showAddHomeItem(BuildContext context, List<String> args, String id, int tileNumber, bool slideAnimation, String icon, String mode) {
  selectedTile = -1;
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              contentPadding: EdgeInsets.all(100.sp),
              titlePadding: EdgeInsets.fromLTRB(160.sp, 80.sp, 160.sp, 0),
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(370.sp),
                side: BorderSide.none,
              ),
              title: Text(sentences.ADD_ITEM, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 80.sp),),
              content: ShowAddHomeItemContentWidget(args: args, id: id, tileNumber: tileNumber, icon: icon, slideAnimation: slideAnimation, mode: mode,)
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

class ShowAddHomeItemContentWidget extends StatefulWidget {
  final List<String> args;
  final String id;
  final int tileNumber;
  final bool slideAnimation;
  final String icon;
  final String mode;

  const ShowAddHomeItemContentWidget({
    super.key,
    required this.args,
    required this.id,
    required this.tileNumber,
    required this.slideAnimation,
    required this.icon,
    required this.mode,
  });

  @override
  _ShowAddHomeItemContentWidgetState createState() => _ShowAddHomeItemContentWidgetState();
}

class _ShowAddHomeItemContentWidgetState extends State<ShowAddHomeItemContentWidget> {
  int addItemPagelistToggleValue = 0;
  late TextEditingController _name;
  late bool _hasSsl;
  late TextEditingController _brokerUrl;
  late TextEditingController _brokerPort;
  late TextEditingController _userName;
  late TextEditingController _password;
  late TextEditingController _topic;
  late TextEditingController _message;
  late TextEditingController _localIp;
  late TextEditingController _localPort;
  late String _id;
  late int _tileNumber;
  late bool _autoSlideshow;
  late String _icon;
  late String _mode;

  late bool vpnActivated;
  late String localIp;
  late CarouselSliderController _iconsController;
  bool _passwordHidden = true;

  @override
  void initState() {
    super.initState();
    if(widget.id=='') {_id = randomId(6);} else {_id=widget.id;}
    _tileNumber = widget.tileNumber;
    _name = TextEditingController(text: widget.args[0]);
    _hasSsl = bool.parse(widget.args[1].split('!!')[0]);
    _brokerUrl = TextEditingController(text: widget.args[1].split('!!')[1]);
    _brokerPort = TextEditingController(text: widget.args[1].split('!!')[2]);
    _userName = TextEditingController(text: widget.args[2]);
    _password = TextEditingController(text: widget.args[3]);
    _topic = TextEditingController(text: widget.args[4]);
    _message = TextEditingController(text: widget.args[5]);
    _localIp = TextEditingController(text: widget.args[6]);
    _localPort = TextEditingController(text: widget.args[7]);
    _autoSlideshow = widget.slideAnimation;
    _icon = widget.icon;
    _iconsController = CarouselSliderController();
    _mode = widget.mode;

    if(_autoSlideshow) {
      Future.delayed(Duration(seconds: 1), (){
        setState(() {
          _autoSlideshow = false;
        });
      });
    }

    void getLocalIpHint() async {
      vpnActivated = await isVpnActive();
      if(!vpnActivated) {
        localIp = await getLocalIp();
        localIp = '${localIp.substring(0, localIp.lastIndexOf('.') + 1)}?';
      }
      else {
        localIp = sentences.VPN_ERROR;
      }
    }
    getLocalIpHint();

    if(firstOpened['addHomeItem']??true) {
      Future.delayed(Duration(seconds: 1), () {
        ShowCaseWidget.of(context).startShowCase([showcase_addHomeItem]);
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _brokerUrl.dispose();
    _brokerPort.dispose();
    _userName.dispose();
    _password.dispose();
    _topic.dispose();
    _message.dispose();
    _localIp.dispose();
    _localPort.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      _iconsController.stopAutoPlay();
                      _iconsController.previousPage();
                    },
                    child: Icon(Icons.chevron_left_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 100.sp,),
                  ),
                  SizedBox(width: 360.sp, height: 300.sp,
                    child: CarouselSlider(
                      carouselController: _iconsController,
                      options: CarouselOptions(
                        initialPage: int.parse(_icon.substring(1))-1,
                        viewportFraction: 1,
                        autoPlay: _autoSlideshow,
                        pauseAutoPlayOnTouch: true,
                        pauseAutoPlayInFiniteScroll: true,
                        pauseAutoPlayOnManualNavigate: true,
                        enableInfiniteScroll: true,
                        autoPlayInterval: Duration(milliseconds: 150),
                        autoPlayAnimationDuration: Duration(milliseconds: 150),
                        onPageChanged: (index, reason) {
                          HapticFeedback.mediumImpact();
                          _icon = 'i${index+1}';
                        },
                      ),
                      items: [1,2,3,4,5,6,7,8,9,10,11,12,13,14].map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: 400.sp,
                              height: 300.sp,
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                image: DecorationImage(image: AssetImage('assets/i$i.png'), fit: BoxFit.fitHeight,),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _iconsController.stopAutoPlay();
                      _iconsController.nextPage();
                    },
                    child: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 100.sp,),
                  )
                ]
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 350.sp,
                    child: TextField(
                      controller: _name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: sentences.ITEM_NAME_HINT,
                        label: Center(child: Text(sentences.ITEM_NAME)),
                        labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 75.sp,),
                  Text('${sentences.QUICK_TILE}:  ${selectedTile==-1 ? (_tileNumber==0 ? sentences.NONE : _tileNumber) : (selectedTile==0 ? sentences.NONE : selectedTile)}', textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 36.sp),),
                  SizedBox(height: 4.sp,),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact;
                      showSelectTile(context, _id, setState);
                    },
                    child: Container(
                      width: 250.sp,
                      height: 70.sp,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(70),
                        borderRadius: BorderRadius.circular(17.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withAlpha(90),
                            blurRadius: 30.sp
                          )
                        ]
                      ),
                      child: Center(child: Text(sentences.CHANGE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 35.sp),),),
                    ),
                  ),
                ],
              )
            ],
          ),
          CustomAnimatedToggle(
            values: [sentences.ONLINE, sentences.OFFLINE],
            pageValue: addItemPagelistToggleValue,
            onToggleCallback: (value) {
              setState(() {
                addItemPagelistToggleValue = value;
              });
            },
            buttonColor: Theme.of(context).colorScheme.primary.withAlpha(115),
            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(38),
            textColor: const Color(0xFFFFFFFF),
            activeFontSize: 35.sp,
            inactiveFontSize: 27.sp,
            totalHeight: 130.sp,
            switchHeight: 100.sp,
            activeSwitchWidth: 455.w,
            activeSwitchHeight: 94.sp,
          ),
          GestureDetector(
            onHorizontalDragEnd: (info) {
              if(info.primaryVelocity! > 0) {
                  addItemPagelistToggleValue = 0;
              }
              else if(info.primaryVelocity! < 0) {
                  addItemPagelistToggleValue = 1;              
              }
              setState(() {});
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                addItemPagelistToggleValue==0
                ? [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _hasSsl = !_hasSsl;
                          });
                        },
                        child: Container(
                          width: 130.sp,
                          height: 130.sp,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(34.sp),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withAlpha(90),
                                blurRadius: 4.sp
                              )
                            ]
                          ),
                          child: Center(
                            child: Text(_hasSsl ? 'SSL' : 'TCP', style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 44.sp),),
                          )
                        ),
                      ),
                      SizedBox(
                        width: 450.w,
                        height: 195.sp,
                        child: Showcase(
                          key: showcase_addHomeItem,
                          overlayOpacity: 0,
                          title: sentences.SC_ADD_ITEM,
                          titleAlignment: Alignment.center,
                          titleTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(220), fontSize: 55.sp),
                          description: sentences.SC_ADD_ITEM_DES,
                          descriptionTextDirection: sentences.direction,
                          descTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 44.sp),
                          targetBorderRadius: BorderRadius.circular(1000.sp),
                          targetPadding: EdgeInsets.all(0),
                          tooltipBackgroundColor: Theme.of(context).cardColor.withAlpha(200),
                          tooltipPadding: EdgeInsets.all(30.sp),
                          tooltipBorderRadius: BorderRadius.circular(40.sp),
                          disposeOnTap: false,
                          tooltipPosition: TooltipPosition.bottom,
                          toolTipMargin: 10,
                          onTargetClick: () async {
                            firstOpened['addHomeItem'] = false;
                            await localStorage.setItem('firstOpened', firstOpened);
                          },
                          onBarrierClick: () async {
                            firstOpened['addHomeItem'] = false;
                            await localStorage.setItem('firstOpened', firstOpened);
                          },
                          child: TextField(
                            controller: _brokerUrl,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: sentences.ITEM_URL_HINT,
                              labelText: sentences.ITEM_URL,
                              labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                              alignLabelWithHint: true,
                              prefix: GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  customDialog(
                                    context, 
                                    sentences.ITEM_URL, 
                                    sentences.ITEM_URL_HELP, 
                                    []
                                  );
                                },
                                child: Icon(Icons.help_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 70.sp,),
                              )
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 240.w,
                        height: 195.sp,
                        child: TextField(
                          controller: _brokerPort,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: sentences.ITEM_PORT_HINT,
                            labelText: sentences.ITEM_PORT,
                            labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                            alignLabelWithHint: true,
                          ),
                        ),
                      )
                    ],
                  ),
                  TextField(
                    controller: _userName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: sentences.ITEM_USERNAME_HINT,
                      labelText: sentences.ITEM_USERNAME,
                      labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      alignLabelWithHint: true,
                    ),
                  ),
                  TextField(
                    controller: _password,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                    textInputAction: TextInputAction.next,
                    obscureText: _passwordHidden,
                    decoration: InputDecoration(
                      hintText: sentences.ITEM_PASSWORD_HINT,
                      labelText: sentences.ITEM_PASSWORD,
                      labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      alignLabelWithHint: true,
                      suffix: GestureDetector(
                        onTap: () => setState(() {
                          HapticFeedback.mediumImpact();
                          _passwordHidden = !_passwordHidden;
                        }),
                        child: Icon(
                          _passwordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                          color: Theme.of(context).colorScheme.primary.withAlpha(220),
                          size: 85.sp,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _topic,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: sentences.ITEM_TOPIC_HINT,
                      labelText: sentences.ITEM_TOPIC,
                      labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      alignLabelWithHint: true,
                    ),
                  ),
                ]
                : [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 600.w,
                        child: TextField(
                          controller: _localIp,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: localIp,
                            labelText: sentences.ITEM_IP,
                            labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 250.w,
                        child: TextField(
                          controller: _localPort,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: sentences.ITEM_LOCAL_PORT_HINT,
                            labelText: sentences.ITEM_PORT,
                            labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                            alignLabelWithHint: true,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 100.sp),
                  Text(sentences.ITEM_LOCAL_HELP, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 47.sp,),),
                  SizedBox(height: 40.sp),
                  GestureDetector(
                    onTap: scanStatus!=''
                    ? null
                    : () {
                      scanNetwork(context, setState, _localPort.text, _localIp);
                    },
                    child: Container(
                      width: languageValue=='Persian' ? 450.w : 630.w,
                      height: 110.sp,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(55),
                        borderRadius: BorderRadius.circular(25.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withAlpha(100),
                            blurRadius: 35.sp
                          )
                        ]
                      ),
                      child: scanStatus=='scanning'
                      ? SizedBox(
                        width: 100.sp,
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Theme.of(context).cardColor,
                          size: 80.sp
                        )
                      )
                      : (
                        scanStatus=='found'
                        ? Center(child: Icon(Icons.done_outline_rounded, color: Theme.of(context).cardColor, size: 70.sp,),)
                        : Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(sentences.SEARCH_NETWORK, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 40.sp),),
                            SizedBox(width: 10.w),
                            Icon(Icons.youtube_searched_for_rounded, color: Theme.of(context).cardColor, size: 70.sp,)
                          ],
                        )
                      )
                    ),
                  ),
                  SizedBox(height: 50.sp),
                ]
            ),
          ),
          TextField(
            controller: _message,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: sentences.ITEM_MESSAGE_HINT,
              labelText: sentences.ITEM_MESSAGE,
              labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
              alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: 70.sp,),
          GestureDetector(
            onTap: () async {
              bool isNew = true;
              if(_name.text!='' && !_brokerUrl.text.contains('!!') && !_brokerPort.text.contains('!!') && (_localIp.text!='' ? IsValid.validateIP4Address(_localIp.text) : true) && (_localPort.text!='' ? (int.tryParse(_localPort.text)==null ? false : true) : true) && (_brokerPort.text!='' ? (int.tryParse(_brokerPort.text)==null ? false : true) : true)) {
                HapticFeedback.mediumImpact();
                if(selectedTile!=-1) {
                  kotlinTileMethodChannelSender.removeTile(_tileNumber);
                  for(int i=0; i<homeItems.length; i++) {
                    if(homeItems[i][2]==selectedTile.toString()) {
                      homeItems[i][2] = '0';
                    }
                  }
                }
                kotlinShortcutMethodChannelSender.createShortcut(_id, _name.text, _icon, '$_hasSsl!!${_brokerUrl.text}!!${_brokerPort.text}', _userName.text, _password.text, _topic.text, _message.text, _localIp.text, _localPort.text, _mode);
                kotlinTileMethodChannelSender.createTile(selectedTile==-1 ? _tileNumber : selectedTile, _name.text, _icon, '$_hasSsl!!${_brokerUrl.text}!!${_brokerPort.text}', _userName.text, _password.text, _topic.text, _message.text, _localIp.text, _localPort.text, _mode);
                for(int i=0; i<homeItems.length; i++) {
                  if(_id==homeItems[i][0]) {
                    homeItems[i] = [_id, _name.text, selectedTile==-1 ? _tileNumber.toString() : selectedTile.toString(), _icon, '$_hasSsl!!${_brokerUrl.text}!!${_brokerPort.text}', _userName.text, _password.text, _topic.text, _message.text, _localIp.text, _localPort.text, _mode];
                    isNew = false;
                    DateTime dateNow = DateTime.now();
                    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!The ${_name.text} ($_id) item was edited successfully');
                    break;
                  }
                }
                if(isNew) {
                  homeItems.add([_id, _name.text, selectedTile==-1 ? _tileNumber.toString() : selectedTile.toString(), _icon, '$_hasSsl!!${_brokerUrl.text}!!${_brokerPort.text}', _userName.text, _password.text, _topic.text, _message.text, _localIp.text, _localPort.text, _mode]);
                  DateTime dateNow = DateTime.now();
                  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!The ${_name.text} ($_id) item was added successfully');
                }
                await localStorage.setItem('homeItems', homeItems);
                homeItemsChanged.value = !homeItemsChanged.value;
                Navigator.pop(context);
                pagelistToggleValue = 0;
                mainPageToggleChanged.value = !mainPageToggleChanged.value;   // For setState
              }
            },
            child: Container(
              width: 0.92.sw,
              height: 150.sp,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(80),
                borderRadius: BorderRadius.circular(45.sp),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(100),
                    blurRadius: 50.sp
                  )
                ]
              ),
              child: Center(
                child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 52.sp),)
              ),
            )
          ),
        ]
      ),
    );
  }
}

void showAddReceiver(BuildContext context, List<String> args, String id, bool slideAnimation, String icon, String mode) {
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              contentPadding: EdgeInsets.all(100.sp),
              titlePadding: EdgeInsets.fromLTRB(160.sp, 80.sp, 160.sp, 0),
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(370.sp),
                side: BorderSide.none,
              ),
              title: Text(sentences.ADD_RECEIVER, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 80.sp),),
              content: ShowAddReceiverContentWidget(args: args, id: id, icon: icon, slideAnimation: slideAnimation, mode: mode)
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

class ShowAddReceiverContentWidget extends StatefulWidget {
  final List<String> args;
  final String id;
  final bool slideAnimation;
  final String icon;
  final String mode;

  const ShowAddReceiverContentWidget({
    super.key,
    required this.args,
    required this.id,
    required this.slideAnimation,
    required this.icon,
    required this.mode,
  });

  @override
  _ShowAddReceiverContentWidgetState createState() => _ShowAddReceiverContentWidgetState();
}

class _ShowAddReceiverContentWidgetState extends State<ShowAddReceiverContentWidget> {
  int addReceiverPagelistToggleValue = 0;
  late TextEditingController _name;
  late bool _hasSsl;
  late TextEditingController _brokerUrl;
  late TextEditingController _brokerPort;
  late TextEditingController _userName;
  late TextEditingController _password;
  late TextEditingController _topic;
  late TextEditingController _localIp;
  late TextEditingController _localPort;
  late String _id;
  late bool _autoSlideshow;
  late String _icon;
  late String _mode;

  late CarouselSliderController _iconsController;
  bool _passwordHidden = true;

  @override
  void initState() {
    super.initState();
    if(widget.id=='') {_id = randomId(6);} else {_id=widget.id;}
    _name = TextEditingController(text: widget.args[0]);
    _hasSsl = bool.parse(widget.args[1].split('!!')[0]);
    _brokerUrl = TextEditingController(text: widget.args[1].split('!!')[1]);
    _brokerPort = TextEditingController(text: widget.args[1].split('!!')[2]);
    _userName = TextEditingController(text: widget.args[2]);
    _password = TextEditingController(text: widget.args[3]);
    _topic = TextEditingController(text: widget.args[4]);
    _localIp = TextEditingController(text: widget.args[5]);
    _localPort = TextEditingController(text: widget.args[6]);
    _autoSlideshow = widget.slideAnimation;
    _icon = widget.icon;
    _iconsController = CarouselSliderController();
    _mode = widget.mode;

    if(_autoSlideshow) {
      Future.delayed(Duration(seconds: 1), (){
        setState(() {
          _autoSlideshow = false;
        });
      });
    }

    void getLocalIpHint() async {
      _localIp.text = await getLocalIp();
    }
    getLocalIpHint();
  }

  @override
  void dispose() {
    _name.dispose();
    _brokerUrl.dispose();
    _brokerPort.dispose();
    _userName.dispose();
    _password.dispose();
    _topic.dispose();
    _localIp.dispose();
    _localPort.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _iconsController.stopAutoPlay();
                    _iconsController.previousPage();
                  },
                  child: Icon(Icons.chevron_left_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 100.sp,),
                ),
                SizedBox(width: 360.sp, height: 300.sp,
                  child: CarouselSlider(
                    carouselController: _iconsController,
                    options: CarouselOptions(
                      initialPage: int.parse(_icon.substring(1))-1,
                      viewportFraction: 1,
                      autoPlay: _autoSlideshow,
                      pauseAutoPlayOnTouch: true,
                      pauseAutoPlayInFiniteScroll: true,
                      pauseAutoPlayOnManualNavigate: true,
                      enableInfiniteScroll: true,
                      autoPlayInterval: Duration(milliseconds: 150),
                      autoPlayAnimationDuration: Duration(milliseconds: 150),
                      onPageChanged: (index, reason) {
                        HapticFeedback.mediumImpact();
                        _icon = 'i${index+1}';
                      },
                    ),
                    items: [1,2,3,4,5,6,7,8,9,10,11,12,13,14].map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: 400.sp,
                            height: 300.sp,
                            margin: EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage('assets/i$i.png'), fit: BoxFit.fitHeight,),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _iconsController.stopAutoPlay();
                    _iconsController.nextPage();
                  },
                  child: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 100.sp,),
                )
              ]
            ),
            SizedBox(
              width: 350.sp,
              child: TextField(
                controller: _name,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: sentences.ITEM_NAME_HINT,
                  label: Center(child: Text(sentences.ITEM_NAME)),
                  labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
        CustomAnimatedToggle(
          values: [sentences.ONLINE, sentences.OFFLINE],
          pageValue: addReceiverPagelistToggleValue,
          onToggleCallback: (value) {
            setState(() {
              addReceiverPagelistToggleValue = value;
            });
          },
          buttonColor: Theme.of(context).colorScheme.primary.withAlpha(115),
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(38),
          textColor: const Color(0xFFFFFFFF),
          activeFontSize: 35.sp,
          inactiveFontSize: 27.sp,
          totalHeight: 130.sp,
          switchHeight: 100.sp,
          activeSwitchWidth: 455.w,
          activeSwitchHeight: 94.sp,
        ),
        GestureDetector(
          onHorizontalDragEnd: (info) {
            if(info.primaryVelocity! > 0) {
                addReceiverPagelistToggleValue = 0;
            }
            else if(info.primaryVelocity! < 0) {
                addReceiverPagelistToggleValue = 1;              
            }
            setState(() {});
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
              addReceiverPagelistToggleValue==0
              ? [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _hasSsl = !_hasSsl;
                        });
                      },
                      child: Container(
                        width: 130.sp,
                        height: 130.sp,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(34.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withAlpha(90),
                              blurRadius: 4.sp
                            )
                          ]
                        ),
                        child: Center(
                          child: Text(_hasSsl ? 'SSL' : 'TCP', style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 44.sp),),
                        )
                      ),
                    ),
                    SizedBox(
                      width: 450.w,
                      child: TextField(
                        controller: _brokerUrl,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: sentences.ITEM_URL_HINT,
                          labelText: sentences.ITEM_URL,
                          labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          alignLabelWithHint: true,
                          prefix: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              customDialog(
                                context, 
                                sentences.ITEM_URL, 
                                sentences.ITEM_URL_HELP, 
                                []
                              );
                            },
                            child: Icon(Icons.info_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(220), size: 70.sp,),
                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 240.w,
                      child: TextField(
                        controller: _brokerPort,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: sentences.ITEM_PORT_HINT,
                          labelText: sentences.ITEM_PORT,
                          labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          alignLabelWithHint: true,
                        ),
                      ),
                    )
                  ],
                ),
                TextField(
                  controller: _userName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: sentences.ITEM_USERNAME_HINT,
                    labelText: sentences.ITEM_USERNAME,
                    labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                    alignLabelWithHint: true,
                  ),
                ),
                TextField(
                  controller: _password,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                  textInputAction: TextInputAction.next,
                  obscureText: _passwordHidden,
                  decoration: InputDecoration(
                    hintText: sentences.ITEM_PASSWORD_HINT,
                    labelText: sentences.ITEM_PASSWORD,
                    labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                    alignLabelWithHint: true,
                    suffix: GestureDetector(
                      onTap: () => setState(() {
                        HapticFeedback.mediumImpact();
                        _passwordHidden = !_passwordHidden;
                      }),
                      child: Icon(
                        _passwordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                        color: Theme.of(context).colorScheme.primary.withAlpha(220),
                        size: 85.sp,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _topic,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: sentences.ITEM_TOPIC_HINT,
                    labelText: sentences.ITEM_TOPIC,
                    labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                    alignLabelWithHint: true,
                  ),
                ),
              ]
              : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 600.w,
                      child: TextField(
                        controller: _localIp,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: sentences.IP_AUTO,
                          labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 250.w,
                      child: TextField(
                        controller: _localPort,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: sentences.RECEIVER_LOCAL_PORT_HINT,
                          labelText: sentences.ITEM_PORT,
                          labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          alignLabelWithHint: true,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 100.sp),
                Text(sentences.RECEIVER_LOCAL_HELP, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 47.sp,),),
                SizedBox(height: 40.sp),
              ]
          )
        ),
        SizedBox(height: 25.sp,),
        GestureDetector(
          onTap: () async {
            bool isNew = true;
            if(_name.text!='' && !_brokerUrl.text.contains('!!') && !_brokerPort.text.contains('!!') && (_localPort.text!='' ? (int.tryParse(_localPort.text)==null ? false : true) : true) && (_brokerPort.text!='' ? (int.tryParse(_brokerPort.text)==null ? false : true) : true)) {
              HapticFeedback.mediumImpact();
              for(int i=0; i<receiverItems.length; i++) {
                if(_id==receiverItems[i][0]) {
                  receiverItems[i] = [_id, _name.text, _icon,'$_hasSsl!!${_brokerUrl.text}!!${_brokerPort.text}', _userName.text, _password.text, _topic.text, _localIp.text, _localPort.text, _mode];
                  isNew = false;
                  DateTime dateNow = DateTime.now();
                  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!The ${_name.text} ($_id) receiver was edited successfully');
                  break;
                }
              }
              if(isNew) {
                receiverItems.add([_id, _name.text, _icon, '$_hasSsl!!${_brokerUrl.text}!!${_brokerPort.text}', _userName.text, _password.text, _topic.text, _localIp.text, _localPort.text, _mode]);
                DateTime dateNow = DateTime.now();
                logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!The ${_name.text} ($_id) receiver was added successfully');
              }
              await localStorage.setItem('receiverItems', receiverItems);
              receiverItemsChanged.value = !receiverItemsChanged.value;
              Navigator.pop(context);
              pagelistToggleValue = 1;
              mainPageToggleChanged.value = !mainPageToggleChanged.value;   // For setState
            }
          },
          child: Container(
            width: 0.92.sw,
            height: 150.sp,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(70),
              borderRadius: BorderRadius.circular(45.sp),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(90),
                  blurRadius: 40.sp
                )
              ]
            ),
            child: Center(
              child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 52.sp),)
            ),
          )
        ),
      ]
    ));
  }
}

void showShareDialog(BuildContext context, String itemHash, itemId, itemName) {
  TextEditingController itemLink = TextEditingController(text: itemHash);
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(400.sp),
                side: BorderSide.none,
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80.sp,
                    height: 80.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withAlpha(180),
                      boxShadow: [BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withAlpha(120),
                        blurRadius: 5,
                        offset: Offset.zero
                      )]
                    ),
                  ),
                  SizedBox(width: 5,),
                  Text(sentences.SHARE, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 86.sp, fontWeight: FontWeight.bold),),
                  SizedBox(width: 5,),
                  Container(
                    width: 80.sp,
                    height: 80.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withAlpha(180),
                      boxShadow: [BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withAlpha(120),
                        blurRadius: 5,
                        offset: Offset.zero
                      )]
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 900.sp,
                    height: 900.sp,
                    decoration: ShapeDecoration(
                      color: Theme.of(context).cardColor,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(310.sp)
                      ),
                      shadows: [BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withAlpha(70),
                        blurRadius: 60.sp,
                        offset: Offset.zero
                      )],
                    ),
                    child: PrettyQrView.data(
                      data: itemHash,
                      decoration: PrettyQrDecoration(
                        image: const PrettyQrDecorationImage(
                          image: AssetImage('assets/IoTrix_Gif_Qr.gif'),
                          filterQuality: FilterQuality.low,
                          scale: 0.2
                        ),
                        quietZone: PrettyQrQuietZone.pixels(80.sp),
                        shape: PrettyQrShape.custom(
                          PrettyQrSquaresSymbol(
                            density: 0.5,
                            rounding: 0.8,
                            color: Theme.of(context).cardColor.r>0.5 ? Colors.black : Colors.white,
                          ),
                          finderPattern: PrettyQrSmoothSymbol(
                            color: Theme.of(context).cardColor.r>0.5 ? Theme.of(context).colorScheme.primary.withAlpha(200) : Theme.of(context).colorScheme.primary.withAlpha(230),
                            roundFactor: 1
                          ),
                          alignmentPatterns: PrettyQrSmoothSymbol(
                            color: Theme.of(context).cardColor.r>0.5 ? Theme.of(context).colorScheme.primary.withAlpha(105) : Theme.of(context).colorScheme.primary.withAlpha(140),
                            roundFactor: 1
                          ),
                          timingPatterns: PrettyQrSmoothSymbol(
                            color: Theme.of(context).cardColor.r>0.5 ? Theme.of(context).colorScheme.primary.withAlpha(230) : Theme.of(context).colorScheme.primary.withAlpha(255),
                            roundFactor: 1
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50.sp,),
                  SizedBox(
                    width: 860.sp,
                    child: Text(
                      languageValue=='English' ? 'Your friend can import your $itemName (id: $itemId) item by scanning this qr code, opening the file you shared, or pasting the sharing link into their IoTrix app (valid today)' : 'دوست شما می‌تواند آیتم $itemName (ID: $itemId) شما را با اسکن این بارکد، باز کردن فایلی را که به اشتراک گذاشته‌اید یا جای‌گذاری لینک اشتراک‌گذاری در برنامه آی‌او‌تریکس خود وارد کند (فقط امروز معتبر است)', 
                      textAlign: TextAlign.center, 
                      textDirection: sentences.direction,
                      style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 46.sp,),
                    ),
                  ),
                  SizedBox(height: 40.sp,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 620.sp,
                        child: TextField(
                          controller: itemLink,
                          readOnly: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: sentences.LINK,
                            labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 50.sp,),
                      Column(
                        children: [
                          SizedBox(height: 65.sp,),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  await Clipboard.setData(ClipboardData(text: itemHash));
                                },
                                child: Icon(Icons.copy, size: 80.sp, color: Theme.of(context).colorScheme.primary.withAlpha(230),),
                              ),
                              SizedBox(width: 28.sp,),
                              GestureDetector(
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  try {
                                    final tempDir = await getTemporaryDirectory();
                                    final dir = Directory('${tempDir.path}/share');
                                    if (!await dir.exists()) {
                                      await dir.create(recursive: true);
                                    }
                                    final file = File('${dir.path}/$itemName.iotrix');
                                    await file.writeAsBytes(itemHash.codeUnits);
                                    await SharePlus.instance.share(
                                      ShareParams(
                                        files: [XFile(file.path)],
                                        subject: 'IoTrix',
                                        text: languageValue=='English' ? 'You can add my $itemName to your app by opening this file or pasting the link below into the IoTrix app\n(valid today)\n\n$itemHash\n\n\nDownload IoTrix:\nhttps://Loco81.ir/skills/IoTrix?lang=en' : 'شما می‌توانید با باز کردن این فایل یا جای‌گذاری لینک زیر در برنامه آی‌او‌تریکس، $itemName من را به برنامه خود اضافه کنید\n(فقط امروز معتبر است)\n\n$itemHash\n\n\nدانلود آی‌او‌تریکس:\nhttps://Loco81.ir/skills/IoTrix?lang=fa',
                                      ),
                                    );
                                  }
                                  catch(e) {
                                    DateTime dateNow = DateTime.now();
                                    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to share item $itemId: $e');
                                  }
                                },
                                child: Icon(Icons.share, size: 80.sp, color: Theme.of(context).colorScheme.primary.withAlpha(230),),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  )
                ],
              )
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

void showCreatePasscodeQuestion(BuildContext context, setState) {
  TextEditingController questionController = TextEditingController(text: '');
  TextEditingController answerController = TextEditingController(text: '');
  void getLastQuestion() async {
     questionController.text = await secureStorage.read(key: 'question') ?? '';
  }
  getLastQuestion();
  
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(400.sp),
                side: BorderSide.none,
              ),
              title: Text(sentences.RECOVERY_QUESTION, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 62.sp),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 700.sp,
                    child: TextField(
                      controller: questionController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: sentences.QUESTION_HINT,
                        label: Center(child: Text(sentences.WRITE_QUESTION)),
                        labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 700.sp,
                    child: TextField(
                      controller: answerController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        label: Center(child: Text(sentences.WRITE_ANSWER)),
                        labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        alignLabelWithHint: true,
                      ),
                      onSubmitted: (n) async {
                        if(questionController.text!='' && answerController.text!='') {
                          await secureStorage.write(key: 'question', value: questionController.text.toLowerCase());
                          await secureStorage.write(key: 'answer', value: answerController.text.toLowerCase());
                          await secureStorage.write(key: 'isPasswordOn', value: 'true');
                          isPasswordOn = true;
                          HapticFeedback.mediumImpact();
                          setState((){});
                          Navigator.pop(context);
                          DateTime dateNow = DateTime.now();
                          logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App login pin turned on');
                        }
                      },
                    ),
                  )
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(20.sp),
                      ),
                      onPressed: () async {
                        if(questionController.text!='' && answerController.text!='') {
                          await secureStorage.write(key: 'question', value: questionController.text.toLowerCase());
                          await secureStorage.write(key: 'answer', value: answerController.text.toLowerCase());
                          await secureStorage.write(key: 'isPasswordOn', value: 'true');
                          isPasswordOn = true;
                          HapticFeedback.mediumImpact();
                          setState((){});
                          Navigator.pop(context);
                          DateTime dateNow = DateTime.now();
                          logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App login pin turned on');
                        }
                      },
                      child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

void showAnswerPasscodeQuestion(BuildContext context) {
  String question = '';
  TextEditingController answerController = TextEditingController(text: '');
  void getQuestion() async {
     question = (await secureStorage.read(key: 'question') ?? '').capitalize();
  }
  getQuestion();
  
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(400.sp),
                side: BorderSide.none,
              ),
              title: Text(sentences.RECOVERY_QUESTION, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 62.sp),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(question, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),),
                  SizedBox(
                    width: 700.sp,
                    child: TextField(
                      controller: answerController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily:sentences. FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        label: Center(child: Text(sentences.ANSWER)),
                        labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                        alignLabelWithHint: true,
                      ),
                      onSubmitted: (n) async {
                        if(answerController.text!='') {
                          if(answerController.text.toLowerCase()==(await secureStorage.read(key: 'answer') ?? '')) {
                            await secureStorage.write(key: 'isPasswordOn', value: 'false');
                            isPasswordOn = false;
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            Navigator.pop(context);
                            DateTime dateNow = DateTime.now();
                            logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App login pin turned off');
                          }
                          else {
                            HapticFeedback.mediumImpact();
                            Future.delayed(Duration(milliseconds: 80), ()=> HapticFeedback.mediumImpact());
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(20.sp),
                      ),
                      onPressed: () async {
                        if(answerController.text!='') {
                          if(answerController.text.toLowerCase()==(await secureStorage.read(key: 'answer') ?? '')) {
                            await secureStorage.write(key: 'isPasswordOn', value: 'false');
                            isPasswordOn = false;
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                          else {
                            HapticFeedback.mediumImpact();
                            Future.delayed(Duration(milliseconds: 80), ()=> HapticFeedback.mediumImpact());
                          }
                        }
                      },
                      child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

void showSelectTile(BuildContext context, id, setState) {
  ValueNotifier stateChanged = ValueNotifier(false);
  List<List<String>> tilesData = [[], [], [], [], [], []];
  List<Color> tilesColors = [];
  int sTile = 0;

  for(int i=0; i<6; i++) {
    tilesColors.add(Color.fromARGB(255, 160, 160, 160));
  }
  for(int i=0; i<homeItems.length; i++) {
    if(homeItems[i][2]!='0') {
      tilesData[int.parse(homeItems[i][2])-1] = [homeItems[i][1], homeItems[i][3]];
      if(homeItems[i][0]==id) {
        sTile = int.parse(homeItems[i][2]);
        tilesColors[sTile-1] = Theme.of(context).colorScheme.primary.withAlpha(200);
      }
    }
  }

  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: ValueListenableBuilder(
              valueListenable: stateChanged,
              builder: (context, t, child) => AlertDialog(
                backgroundColor: Theme.of(context).cardColor,
                elevation: 22.sp,
                shadowColor: Colors.black,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(400.sp),
                  side: BorderSide.none,
                ),
                title: Text(sentences.QUICK_TILE_MANAGER, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 60.sp),),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: sentences.direction,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if(sTile==1) {
                              sTile = 0;
                              tilesColors[0] = Color.fromARGB(255, 160, 160, 160);
                            }
                            else {
                              sTile = 1;
                              for(int i=0; i<6; i++) {
                                if(i==0) {
                                  tilesColors[i] = Theme.of(context).colorScheme.primary.withAlpha(200);
                                }
                                else {
                                  tilesColors[i] = Color.fromARGB(255, 160, 160, 160);
                                }
                              }
                            }
                            stateChanged.value = !stateChanged.value;
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 220.sp,
                                height: 220.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tilesColors[0],
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 150.sp,
                                    height: 150.sp,
                                    child: Image.asset('assets/${tilesData[0].isEmpty ? "IoTrix_Tile" : tilesData[0][1]}.png', color: const Color.fromARGB(255, 230, 230, 230),),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 230.sp,
                                child: Text('1: ${tilesData[0].isEmpty ? sentences.EMPTY : tilesData[0][0]}', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                              ),
                            ]
                          ),
                        ),
                        SizedBox(width: 30.sp,),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if(sTile==2) {
                              sTile = 0;
                              tilesColors[1] = Color.fromARGB(255, 160, 160, 160);
                            }
                            else {
                              sTile = 2;
                              for(int i=0; i<6; i++) {
                                if(i==1) {
                                  tilesColors[i] = Theme.of(context).colorScheme.primary.withAlpha(200);
                                }
                                else {
                                  tilesColors[i] = Color.fromARGB(255, 160, 160, 160);
                                }
                              }
                            }
                            stateChanged.value = !stateChanged.value;
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 220.sp,
                                height: 220.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tilesColors[1],
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 150.sp,
                                    height: 150.sp,
                                    child: Image.asset('assets/${tilesData[1].isEmpty ? "IoTrix_Tile" : tilesData[1][1]}.png', color: const Color.fromARGB(255, 230, 230, 230),),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 230.sp,
                                child: Text('2: ${tilesData[1].isEmpty ? sentences.EMPTY : tilesData[1][0]}', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                              ),
                            ]
                          ),
                        ),
                        SizedBox(width: 30.sp,),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if(sTile==3) {
                              sTile = 0;
                              tilesColors[2] = Color.fromARGB(255, 160, 160, 160);
                            }
                            else {
                              sTile = 3;
                              for(int i=0; i<6; i++) {
                                if(i==2) {
                                  tilesColors[i] = Theme.of(context).colorScheme.primary.withAlpha(200);
                                }
                                else {
                                  tilesColors[i] = Color.fromARGB(255, 160, 160, 160);
                                }
                              }
                            }
                            stateChanged.value = !stateChanged.value;
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 220.sp,
                                height: 220.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tilesColors[2],
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 150.sp,
                                    height: 150.sp,
                                    child: Image.asset('assets/${tilesData[2].isEmpty ? "IoTrix_Tile" : tilesData[2][1]}.png', color: const Color.fromARGB(255, 230, 230, 230),),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 230.sp,
                                child: Text('3: ${tilesData[2].isEmpty ? sentences.EMPTY : tilesData[2][0]}', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                              ),
                            ]
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.sp,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: sentences.direction,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if(sTile==4) {
                              sTile = 0;
                              tilesColors[3] = Color.fromARGB(255, 160, 160, 160);
                            }
                            else {
                              sTile = 4;
                              for(int i=0; i<6; i++) {
                                if(i==3) {
                                  tilesColors[i] = Theme.of(context).colorScheme.primary.withAlpha(200);
                                }
                                else {
                                  tilesColors[i] = Color.fromARGB(255, 160, 160, 160);
                                }
                              }
                            }
                            stateChanged.value = !stateChanged.value;
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 220.sp,
                                height: 220.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tilesColors[3],
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 150.sp,
                                    height: 150.sp,
                                    child: Image.asset('assets/${tilesData[3].isEmpty ? "IoTrix_Tile" : tilesData[3][1]}.png', color: const Color.fromARGB(255, 230, 230, 230),),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 230.sp,
                                child: Text('4: ${tilesData[3].isEmpty ? sentences.EMPTY : tilesData[3][0]}', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                              ),
                            ]
                          ),
                        ),
                        SizedBox(width: 30.sp,),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if(sTile==5) {
                              sTile = 0;
                              tilesColors[4] = Color.fromARGB(255, 160, 160, 160);
                            }
                            else {
                              sTile = 5;
                              for(int i=0; i<6; i++) {
                                if(i==4) {
                                  tilesColors[i] = Theme.of(context).colorScheme.primary.withAlpha(200);
                                }
                                else {
                                  tilesColors[i] = Color.fromARGB(255, 160, 160, 160);
                                }
                              }
                            }
                            stateChanged.value = !stateChanged.value;
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 220.sp,
                                height: 220.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tilesColors[4],
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 150.sp,
                                    height: 150.sp,
                                    child: Image.asset('assets/${tilesData[4].isEmpty ? "IoTrix_Tile" : tilesData[4][1]}.png', color: const Color.fromARGB(255, 230, 230, 230),),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 230.sp,
                                child: Text('5: ${tilesData[4].isEmpty ? sentences.EMPTY : tilesData[4][0]}', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                              ),
                            ]
                          ),
                        ),
                        SizedBox(width: 30.sp,),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if(sTile==6) {
                              sTile = 0;
                              tilesColors[5] = Color.fromARGB(255, 160, 160, 160);
                            }
                            else {
                              sTile = 6;
                              for(int i=0; i<6; i++) {
                                if(i==5) {
                                  tilesColors[i] = Theme.of(context).colorScheme.primary.withAlpha(200);
                                }
                                else {
                                  tilesColors[i] = Color.fromARGB(255, 160, 160, 160);
                                }
                              }
                            }
                            stateChanged.value = !stateChanged.value;
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 220.sp,
                                height: 220.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tilesColors[5],
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 150.sp,
                                    height: 150.sp,
                                    child: Image.asset('assets/${tilesData[5].isEmpty ? "IoTrix_Tile" : tilesData[5][1]}.png', color: const Color.fromARGB(255, 230, 230, 230),),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 230.sp,
                                child: Text('6: ${tilesData[5].isEmpty ? sentences.EMPTY : tilesData[5][0]}', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                              ),
                            ]
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100.sp,),
                    Text(sentences.QUICK_TILE_HELP, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 45.sp),),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(20.sp)
                        ),
                        onPressed: () {
                          selectedTile = sTile;
                          setState((){});
                          Navigator.pop(context);
                        },
                        child: Text('${sentences.DONE} (${sTile==0 ? sentences.NO_TILE : "${sentences.TILE} $sTile"})', textAlign: TextAlign.center, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 45.sp),),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

void customDialog(BuildContext context, subject, str, List<Widget> actions) {
  showGeneralDialog(
    barrierColor: Theme.of(context).colorScheme.primary.withAlpha(90),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.sp,
              contentPadding: EdgeInsets.all(100.sp),
              titlePadding: EdgeInsets.fromLTRB(160.sp, 80.sp, 160.sp, 0),
              shadowColor: Theme.of(context).colorScheme.primary.withAlpha(255),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(300.sp),
                side: BorderSide.none,
              ),
              title: subject=='' ? null : Text(subject, textAlign: TextAlign.center, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 58.sp),),
              content: Text(str, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 48.sp), textDirection: sentences.direction,),
              actions: actions.isEmpty ? null : actions,
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

class ThemeModer extends StatelessWidget {
  const ThemeModer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, ThemeMode currentMode, _) {
        return IconButton(
          icon: themeModeIcon,
          color: Theme.of(context).colorScheme.primary.withAlpha(160),
          onPressed: () {
            setThemeMode(themeMode.value);
          },
        );
      },
    );
  }
}

Future<void> urlLauncher(url) async {
  url = Uri.parse(url);
  try {
    await launchUrl(url);
  }
  // ignore: empty_catches
  catch (e) {}
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    try {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    // ignore: empty_catches
    catch (e) {}
  }

  (context as Element).visitChildren(rebuild);
}

class CustomAnimatedToggle extends StatefulWidget {
  final List<String> values;
  final int pageValue;
  final ValueChanged onToggleCallback;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;
  final double activeFontSize;
  final double inactiveFontSize;
  final double totalHeight;
  final double switchHeight;
  final double activeSwitchWidth;
  final double activeSwitchHeight;

  const CustomAnimatedToggle({super.key, 
    required this.values,
    this.pageValue = 0,
    required this.onToggleCallback,
    this.backgroundColor = const Color(0xFFe7e7e8),
    this.buttonColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF000000),
    required this.activeFontSize,
    required this.inactiveFontSize,
    required this.totalHeight,
    required this.switchHeight,
    required this.activeSwitchWidth,
    required this.activeSwitchHeight,
  });
  @override
  _CustomAnimatedToggleState createState() => _CustomAnimatedToggleState();
}

class _CustomAnimatedToggleState extends State<CustomAnimatedToggle> {
  late bool pageValue;

  @override
  Widget build(BuildContext context) {
    pageValue = widget.pageValue==0 ? true : false;
    return Container(
      height: widget.totalHeight,
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              pageValue = !pageValue;
              var index = 0;
              if (!pageValue) {
                index = 1;
              }
              widget.onToggleCallback(index);
              setState(() {});
            },
            child: Container(
              height: widget.switchHeight,
              decoration: ShapeDecoration(
                color: widget.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.sp),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.values.length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: Text(
                      widget.values[index],
                      style: TextStyle(
                        fontFamily: sentences.FONTFAMILY_SUBJECT, 
                        fontWeight: FontWeight.bold, 
                        fontSize: widget.inactiveFontSize,
                        color: Color.fromARGB(150, 95, 95, 95),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment:
                pageValue ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34.sp),
                ),
              ),
              child: 
                Container(
                  width: widget.activeSwitchWidth,
                  height: widget.activeSwitchHeight,
                  decoration: ShapeDecoration(
                    color: widget.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34.sp),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    pageValue ? widget.values[0] : widget.values[1],
                    style: TextStyle(
                      fontFamily: sentences.FONTFAMILY_SUBJECT, 
                      fontWeight: FontWeight.bold, 
                      fontSize: widget.activeFontSize,
                      color: widget.textColor,
                    ),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}

class KotlinShortcutMethodChannelSender {
  static const _platform = MethodChannel('com.LoCo.iotrix/shortcuts');

  Future<void> createShortcut(id, name, icon, brokerUrl, userName, password, topic, message, localIp, localPort, mode) async {
    try {
      List<String> splt = brokerUrl.split('!!');
      await _platform.invokeMethod('createShortcut', {
        'id': id,
        'name': name,
        'icon': icon,
        'brokerUrl': '${splt[0]=="true" ? "ssl://" : "tcp://"}${splt[1]}:${splt[2]}',
        'userName': userName,
        'password': password,
        'topic': topic.toLowerCase(),
        'message': message.toLowerCase(),
        'localIp': localIp,
        'localPort': localPort,
        'mode': mode,
      });
      debugPrint('Shortcut created!');
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!$name event shortcut created/updated');
    } on PlatformException catch (e) {
      debugPrint("Error creating shortcut: ${e.message}");
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to create/update event shortcut for $name: ${e.message}');
    }
  }

  Future<void> removeShortcut(id) async {
    try {
      await _platform.invokeMethod('removeShortcut', {
        'id': id,
      });
      debugPrint('Shortcut removed!');
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!Event shortcut removed for item $id');
    } on PlatformException catch (e) {
      debugPrint("Error removing shortcut: ${e.message}");
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to remove event shortcut for item $id: ${e.message}');
    }
  }
}

class KotlinTileMethodChannelSender {
  static const _platform = MethodChannel('com.LoCo.iotrix/quicktile');

  Future<void> createTile(tileNumber, name, icon, brokerUrl, userName, password, topic, message, localIp, localPort, mode) async {
    try {
      List<String> splt = brokerUrl.split('!!');
      await _platform.invokeMethod('addOrUpdateTile', {
        'tileNumber': tileNumber,
        'title': name,
        'icon': icon,
        'brokerUrl': '${splt[0]=="true" ? "ssl://" : "tcp://"}${splt[1]}:${splt[2]}',
        'userName': userName,
        'password': password,
        'topic': topic.toLowerCase(),
        'message': message.toLowerCase(),
        'localIp': localIp,
        'localPort': localPort,
        'mode': mode,
      });
      debugPrint('Tile created!');
      if(tileNumber!=0) {
        DateTime dateNow = DateTime.now();
        logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!$name tile created/updated on tile $tileNumber');
      }
    } on PlatformException catch (e) {
      debugPrint("Error creating tile: ${e.message}");
      if(tileNumber!=0) {
        DateTime dateNow = DateTime.now();
        logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to create/update tile $tileNumber for $name: ${e.message}');
      }
    }
  }

  Future<void> removeTile(tileNumber) async {
    try {
      await _platform.invokeMethod('removeTile', {
        'tileNumber': tileNumber,
      });
      debugPrint('Tile removed!');
      if(tileNumber!=0) {
        DateTime dateNow = DateTime.now();
        logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!tile $tileNumber cleared');
      }
    } on PlatformException catch (e) {
      debugPrint("Error removing tile: ${e.message}");
      if(tileNumber!=0) {
        DateTime dateNow = DateTime.now();
        logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to clear tile $tileNumber: ${e.message}');
      }
    }
  }
}

void itemReceived(context, String itemHash) {
  try {
    List<String> item = (jsonDecode(String.fromCharCodes(base58BitcoinDecode(String.fromCharCodes(itemHash.runes.toList().reversed)))) as List<dynamic>).cast<String>();
    DateTime dateNow = DateTime.now();
    String now = '${dateNow.year}-${dateNow.month}-${dateNow.day}';
    if(item[1]==now) {
      if(item[0]=='sender') {
        showAddHomeItem(context, [item[3], item[6], item[7], item[8], item[9], item[10], item[11], item[12]], item[2], 0, false, item[5], item[13]);
      }
      else if(item[0]=='receiver') {
        showAddReceiver(context, [item[3], item[5], item[6], item[7], item[8], item[9], item[10]], item[2], false, item[4], item[11]);
      }
    }
    else {
      customDialog(
        context, 
        sentences.ERROR, 
        languageValue=='English' ? 'Unable to import item! it expried on ${item[1]}' : 'نمی‌توان آیتم را وارد کرد!  آیتم در تاریخ ${item[1]} منقضی شده است',
        [],
      );
    }
  }
  catch(e) {
    customDialog(
      context, 
      sentences.ERROR, 
      sentences.IMPORT_ERROR, 
      []
    );
  }
}

String randomId(digits) {
  Random random = Random();
  String n = '';
  for(int i=0; i<digits; i++) {
    n+=random.nextInt(10).toString();
  }
  return n;
}

Future<void> sendMqttCommand(context, String itemId, String server, String userName, String password, String topic, String message) async {
  runningSenders[itemId] = false;   // isSentMessage
  homeItemsChanged.value = !homeItemsChanged.value;

  late MqttServerClient client;
  try {
    client = MqttServerClient(server.split('!!')[1], 'IoTrix_$itemId');
    client.port = int.parse(server.split('!!').last);
  }
  catch(e) {
    runningSenders.remove(itemId);
    homeItemsChanged.value = !homeItemsChanged.value;
    customDialog(
      context, 
      sentences.ERROR, 
      sentences.MQTT_ERROR, 
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: ()=> Navigator.pop(context),
              child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 55.sp))
            ),
            SizedBox(width: 40.sp,),
          ],
        ),
      ],
    );
    return;
  }
  client.logging(on: false);
  client.keepAlivePeriod = 20;
  client.onDisconnected = () {
    print('Disconnected');
    runningSenders.remove(itemId);
    homeItemsChanged.value = !homeItemsChanged.value;
  };

  try {
    await client.connect(userName, password);
    print('Connected to MQTT broker');
  } catch (e) {
    print('Connection failed: $e');
    client.disconnect();
    runningSenders.remove(itemId);
    homeItemsChanged.value = !homeItemsChanged.value;
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to connect to ${server.split('!!')[1]} in item $itemId: $e');
    return;
  }

  final builder = MqttClientPayloadBuilder();
  builder.addString(message.toLowerCase());

  client.publishMessage(topic.toLowerCase(), MqttQos.atLeastOnce, builder.payload!);
  print('Sent command.');
  HapticFeedback.mediumImpact();
  runningSenders[itemId] = true;
  sentMqtt = true;
  homeItemsChanged.value = !homeItemsChanged.value;
  await Future.delayed(const Duration(milliseconds: 70), (){
    runningSenders[itemId] = false;
    sentMqtt = false;
    homeItemsChanged.value = !homeItemsChanged.value;
  });

  await Future.delayed(const Duration(milliseconds: 500));
  client.disconnect();
  runningSenders.remove(itemId);
  homeItemsChanged.value = !homeItemsChanged.value;
  DateTime dateNow = DateTime.now();
  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!green!!MQTT message sent to ${server.split('!!')[1]} successfully: $message');
}

class ReceiveMqttCommand {
  late MqttServerClient _client;

  Future<void> startReceiving(context, String itemId, String server, String userName, String password, String topic) async {
    receiverItemsChanged.value = !receiverItemsChanged.value;
    try {
      _client = MqttServerClient(server.split('!!')[1], 'IoTrix_Receiver_$itemId');
      _client.port = int.parse(server.split('!!').last);
    }
    catch(e) {
      runningReceivers.remove(itemId);
      receiverItemsChanged.value = !receiverItemsChanged.value;
      customDialog(
        context, 
        sentences.ERROR, 
        sentences.MQTT_RECEIVE_ERROR, 
        [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 55.sp))
              ),
              SizedBox(width: 40.sp,),
            ],
          ),
        ],
      );
      return;
    }
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);

    _client.onConnected = () {
      print('Receiver Connected');
    };
    _client.onDisconnected = () {
      print('Receiver Disconnected');
      runningReceivers.remove(itemId);
      receiverItemsChanged.value = !receiverItemsChanged.value;
    };
    _client.onSubscribed = (topic) {
      print('Receiver Subscribed to $topic');
      runningReceivers[itemId]![1] = true;
      receiverItemsChanged.value = !receiverItemsChanged.value;
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!Receiver $itemId connected to MQTT broker successfully');
    };

    final connMess = MqttConnectMessage()
        .withClientIdentifier('IoTrix_Receiver_$itemId')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMess;

    try {
      await _client.connect(userName, password);
    } 
    catch (e) {
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Receiver $itemId MQTT connection failed: $e');
      _client.disconnect();
      runningReceivers.remove(itemId);
      receiverItemsChanged.value = !receiverItemsChanged.value;
      return;
    }

    _client.subscribe(topic.toLowerCase(), MqttQos.atLeastOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

      HapticFeedback.mediumImpact();
      runningReceivers[itemId]![0] = payload;
      runningReceivers[itemId]![2] = true;
      receiverItemsChanged.value = !receiverItemsChanged.value;
      await Future.delayed(const Duration(milliseconds: 140), (){
        runningReceivers[itemId]![2] = false;
        receiverItemsChanged.value = !receiverItemsChanged.value;
      });
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!green!!MQTT message received from receiver $itemId: $payload');
    });
  }
  
  void stopReceiving(itemId) {
    try {
      _client.disconnect();
      runningReceivers.remove(itemId);
      receiverItemsChanged.value = !receiverItemsChanged.value;
    }
    catch(e) {
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to stop MQTT receiver $itemId: $e');
    }
  }
}

void sendUdpCommand(context, String itemId, String ip, String port, String message) async {
  runningSenders[itemId] = false;   // isSentMessage
  homeItemsChanged.value = !homeItemsChanged.value;
  try {
    var sender = await UDP.bind(Endpoint.any(port: Port(8182)));

    await sender.send(
      message.toLowerCase().codeUnits,
      Endpoint.unicast(
        InternetAddress(ip),  // Local broadcast ip
        port: Port(int.parse(port)),  // UDP ESP8266 port
      ),
    );
    runningSenders[itemId] = true;
    sentMqtt = true;
    homeItemsChanged.value = !homeItemsChanged.value;
    HapticFeedback.mediumImpact();
    sender.close();
    await Future.delayed(const Duration(milliseconds: 70), () {
      runningSenders[itemId] = false;
      sentMqtt = false;
      homeItemsChanged.value = !homeItemsChanged.value;
    });

    runningSenders.remove(itemId);
    homeItemsChanged.value = !homeItemsChanged.value;

    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!green!!UDP message sent to $ip:$port successfully: $message');
  }
  catch(e) {
    runningSenders.remove(itemId);
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to send UDP message to $ip:$port! $e');
  }
  runningSenders.remove(itemId);
  sentMqtt = false;
  homeItemsChanged.value = !homeItemsChanged.value;
}

class ReceiveUdpCommand {
  late RawDatagramSocket socket;

  Future<void> startReceiving(context, String itemId, String localIp, String localPort) async {
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, int.parse(localPort));
      runningReceivers[itemId]![1] = true;
      receiverItemsChanged.value = !receiverItemsChanged.value;
      socket.broadcastEnabled = true;

      socket.listen((event) async {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            final String fromIp = datagram.address.address;
            final String msg = String.fromCharCodes(datagram.data);
            HapticFeedback.mediumImpact();
            if(msg.substring(0, 7)=='localip') {
              try {
                DateTime dateNow = DateTime.now();
                logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!receiver $itemId was scanned by ${msg.split('/')[1].split(':')[0]} on the network!');
                sendUdpCommand(context, itemId, msg.split('/')[1].split(':')[0], msg.split('/')[1].split(':')[1], localIp);
              }
              catch(e) {
                print(e);
                DateTime dateNow = DateTime.now();
                logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!receiver $itemId was scanned by another device on the network!');
              }
            }
            else {
              runningReceivers[itemId]![0] = msg;
              runningReceivers[itemId]![2] = true;
              receiverItemsChanged.value = !receiverItemsChanged.value;
              await Future.delayed(const Duration(milliseconds: 140), (){
                runningReceivers[itemId]![2] = false;
                receiverItemsChanged.value = !receiverItemsChanged.value;
              });
              print("Response from $fromIp: $msg");
              DateTime dateNow = DateTime.now();
              logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!green!!Message received from $fromIp on receiver $itemId: $msg');
            }
          }
        }
      });
    }
    catch(e) {
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to listen to the receiver $itemId! $e');
      try {
        socket.close();
        runningReceivers.remove(itemId);
        receiverItemsChanged.value = !receiverItemsChanged.value;
      }
      catch(e) {
        DateTime dateNow = DateTime.now();
        logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to stop receiver $itemId! $e');
      }
    }
  }
  
  void stopReceiving(itemId) {
    try {
      socket.close();
      runningReceivers.remove(itemId);
      receiverItemsChanged.value = !receiverItemsChanged.value;
    }
    catch(e) {
      DateTime dateNow = DateTime.now();
      logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to stop receiver $itemId! $e');
    }
  }
}

bool isPrivateIp(String ip) {
  return ip.startsWith('192.168.') ||
         ip.startsWith('10.') ||
         ip.startsWith('172.16.') || ip.startsWith('172.17.') ||
         ip.startsWith('172.18.') || ip.startsWith('172.19.') ||
         ip.startsWith('172.20.') || ip.startsWith('172.21.') ||
         ip.startsWith('172.22.') || ip.startsWith('172.23.') ||
         ip.startsWith('172.24.') || ip.startsWith('172.25.') ||
         ip.startsWith('172.26.') || ip.startsWith('172.27.') ||
         ip.startsWith('172.28.') || ip.startsWith('172.29.') ||
         ip.startsWith('172.30.') || ip.startsWith('172.31.');
}

Future<bool> isVpnActive() async {
  final interfaces = await NetworkInterface.list();
  for (var interface in interfaces) {
    final name = interface.name.toLowerCase();
    if (name.contains('tun') || name.contains('ppp') || name.contains('vpn') || name.contains('wg')) {
      return true;
    }
  }
  return false;
}

Future<void> scanNetwork(context, setState, String p, TextEditingController ipTextField) async {
  try{
    if(p!='') {
      List<String> foundedItems = [];
      int port = int.parse(p);
      final RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8182);
      socket.broadcastEnabled = true;

      final String localIp = await getLocalIp();
      if(localIp=='') {
        return;
      }
      else {
        scanStatus = 'scanning';
        setState((){});
      }
      final String subnet = localIp.substring(0, localIp.lastIndexOf('.') + 1);

      print("Subnet: $subnet");
      print("Start scanning...");

      socket.listen((event) async {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            final String fromIp = datagram.address.address;
            final String msg = String.fromCharCodes(datagram.data);

            ipTextField.text = msg;
            foundedItems.add(msg);
            scanStatus = 'found';
            try {
              setState((){});
            }
            catch(e) {/**/}
            print("Response from $fromIp: $msg");
          }
        }
      });

      for (int i = 1; i <= 255; i++) {
        final String targetIp = "$subnet$i";
        // if(targetIp==localIp) continue;
        socket.send(
          Uint8List.fromList("localip/$localIp:8182".codeUnits),
          InternetAddress(targetIp),
          port,
        );
      }

      await Future.delayed(Duration(seconds: 3));

      socket.close();
      scanStatus = '';
      foundedItems = foundedItems.toSet().toList();
      if(foundedItems.length>1) {
        ipTextField.text = '';
        customDialog(
          context, 
          sentences.FOUND_ITEMS, 
          sentences.CLICK_ON_ITEM,
          [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: foundedItems.map<Widget>((ip) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ipTextField.text = ip;
                              Navigator.pop(context);

                            },
                            child: Container(
                              width: 520.w,
                              height: 100.sp,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withAlpha(80),
                                borderRadius: BorderRadius.circular(20.sp),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withAlpha(100),
                                    blurRadius: 30.sp
                                  )
                                ]
                              ),
                              child: Center(
                                child: Text(ip, maxLines: 1, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 52.sp, overflow: TextOverflow.ellipsis),),
                              )
                            ),
                          ),
                          SizedBox(height: 24.sp,),
                        ]
                      ),
                    );
                }).toList()
              ), 
            ),
          ]
        );
      }
      try {
        setState((){});
      }
      catch(e) {/**/}
      return;
    }
  }
  catch(e) {
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to scan network! $e');
  }
}

Future<String> getLocalIp() async {
  try {
    // Local WiFi
    List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    if (result[0] == ConnectivityResult.wifi || result[0] == ConnectivityResult.ethernet) {
      try {
        return (await NetworkInfo().getWifiIP().timeout(Duration(seconds: 1), onTimeout: () => ''))!;
      } catch (e) {/**/}
    }
    // Local Hotspot
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (isPrivateIp(addr.address) && addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
    return '';
  }
  catch(e) {
    DateTime dateNow = DateTime.now();
    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!red!!Failed to get phone local IP! $e');
  }
  return '';
}

class DebouncedLogger {
  Timer? _timer;
  final Duration delay;
  final Function firstAction;
  final Function timerAction;

  DebouncedLogger({
    required this.delay,
    required this.firstAction,
    required this.timerAction,
  });

  void setLog(String log) {
    firstAction(log);

    // If timer is active, cancel it
    _timer?.cancel();

    // Create new timer
    _timer = Timer(delay, () {
      timerAction();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}