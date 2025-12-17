// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

import '/Utils/classes.dart';




class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    List<String> themeDropdownItems = [sentences.SYSTEM, sentences.MANUAL];
    return Center(
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 0.67.sw,
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(320.sp),
                ),
                shadows: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(80),
                    blurRadius: 62.sp
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 50.sp,),
                  Text(sentences.APPEARANCE, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 60.sp),),
                  SizedBox(height: 50.sp,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sentences.THEME, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),),
                      SizedBox(width: 10.sp,),
                      Transform.scale(
                        scale: 3.6.sp, 
                        child: ThemeModer()
                      )
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(sentences.COLOR, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),),
                    SizedBox(width: 40.sp,),
                    DropdownButton(
                        value: themeDropdownValue,
                        items: themeDropdownItems.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(240), fontSize: 52.sp),
                        borderRadius: BorderRadius.circular(60.sp),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue == sentences.MANUAL) {
                              setColorMode(
                                  'manual', () => showColorPicker(context), context);
                            } else {
                              setColorMode(
                                  'system', () => showColorPicker(context), context);
                            }
                          });
                        }
                    ),
                    Container(
                      width: 55.sp,
                      height: 55.sp,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(17.sp)),
                          color: Theme.of(context).colorScheme.primary.withAlpha(160),
                      ),
                    )
                  ]),
                  SizedBox(height: 20.sp,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sentences.LANGUAGE, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),),
                      SizedBox(width: 40.sp,),
                      Transform.scale(
                        scale: 4.5.sp,
                        child: GestureDetector(
                          child: Image.asset('assets/$languageValue.png', scale: 3),
                          onTap: () => setState(() {changeLanguage();})
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 70.sp,),
                ],
              ),
            ),
            SizedBox(height: 40.sp,),
            Container(
              width: 0.67.sw,
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(310.sp),
                ),
                shadows: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(80),
                    blurRadius: 62.sp
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 50.sp,),
                  Text(sentences.SECURITY, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 60.sp),),
                  SizedBox(height: 50.sp,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(sentences.LOGIN_PIN, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),),
                      Transform.scale(
                        scale: 2.5.sp,
                        child: CupertinoSwitch(
                          value: isPasswordOn,
                          activeTrackColor: Theme.of(context).colorScheme.primary.withAlpha(140),
                          onChanged: (value) async {
                            if(value) {
                              screenLockCreate(
                                context: context,
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
                                onConfirmed: (p) async {
                                  await secureStorage.write(key: 'password', value: p);
                                  Navigator.pop(context);
                                  showCreatePasscodeQuestion(context, setState);
                                }
                              );
                            }
                            else {
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
                                onUnlocked: () async {
                                  await secureStorage.write(key: 'isPasswordOn', value: 'false');
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    isPasswordOn = value;
                                    Navigator.pop(context);
                                  });
                                  DateTime dateNow = DateTime.now();
                                  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!App login pin turned off');
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ]
                  ),
                  SizedBox(height: 60.sp,),
                ]
              ),
            ),
          ]
        ),
      ),
    );
  }

  void showColorPicker(BuildContext parentContext) {
    List color = [255, 0, 255, 200];
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
                title: Text(
                  sentences.PICK_COLOR,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 80.sp)
                ),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: Color.fromARGB(255, 0, 255, 200),
                    colorPickerWidth: 1000.sp,
                    paletteType: PaletteType.hueWheel,
                    onColorChanged: (value) => color = [
                      (value.a*255).toInt(),
                      (value.r*255).toInt(),
                      (value.g*255).toInt(),
                      (value.b*255).toInt()
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      child: Text(sentences.PICK_COLOR_OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 55.sp),),
                      onPressed: () =>
                        setThemeColor(mounted, color, parentContext),
                    )
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
}