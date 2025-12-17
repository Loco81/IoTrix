import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_codecs/base_codecs.dart';
import 'package:showcaseview/showcaseview.dart';

import '/Utils/classes.dart';




class SendersPage extends StatefulWidget {
  const SendersPage({super.key});

  @override
  State<SendersPage> createState() => _SendersPageState();
}

class _SendersPageState extends State<SendersPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: homeItemsChanged, 
      builder: (BuildContext context, t, child) {
        if(homeItems.isNotEmpty) {
          if(firstOpened['helpButton']??true) {
            Future.delayed(Duration(seconds: 1), () {
              // ignore: use_build_context_synchronously
              ShowCaseWidget.of(context).startShowCase([showcase_homeItem, showcase_helpButton]);
            });
          }
        }
        return Stack(
          children: [
            Center(child: Image.asset('assets/IoTrix.png', color: Theme.of(context).colorScheme.primary.withAlpha(sentMqtt ? 70 : 12,),),),
            Showcase(
              key: showcase_homeItem,
              title: sentences.SC_ITEM,
              titleAlignment: Alignment.center,
              titleTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(220), fontSize: 55.sp),
              description: sentences.SC_ITEM_DES,
              descriptionTextDirection: sentences.direction,
              descTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 44.sp),
              targetBorderRadius: BorderRadius.circular(60.sp),
              targetPadding: EdgeInsets.all(15.sp),
              tooltipBackgroundColor: Theme.of(context).cardColor,
              tooltipPadding: EdgeInsets.all(30.sp),
              tooltipBorderRadius: BorderRadius.circular(40.sp),
              disposeOnTap: false,
              onTargetClick: () async {
                firstOpened['homeItem'] = false;
                await localStorage.setItem('firstOpened', firstOpened);
              },
              onBarrierClick: () async {
                firstOpened['homeItem'] = false;
                await localStorage.setItem('firstOpened', firstOpened);
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50.sp,)
                    ] +
                    homeItems.map<Widget>((innerList) {   // [itemId, itemName, tileNumber, icon, server, username, password, topic, message, localIp, localPort, mode]
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: runningSenders[innerList[0]]!=null 
                            ? null 
                            : () {
                              if(innerList[11]=='online') {
                                if(innerList[4]!='') {
                                  Timer.run(()=> sendMqttCommand(context, innerList[0], innerList[4], innerList[5], innerList[6], innerList[7], innerList[8]));
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(sentences.EDIT_ITEM_ONLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                      elevation: 0,
                                    ),
                                  );
                                }
                              }
                              else if(innerList[11]=='local') {
                                if(innerList[9]!='' && innerList[10]!='') {
                                  Timer.run(()=> sendUdpCommand(context, innerList[0], innerList[9], innerList[10], innerList[8]));
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(sentences.EDIT_ITEM_OFFLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                      elevation: 0,
                                    ),
                                  );
                                }
                              }
                            },
                            onLongPress: runningSenders[innerList[0]]!=null
                            ? ()=> ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                    child: Text(sentences.PENDING_ITEM, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                  elevation: 0,
                                ),
                              )
                            : () async {
                              HapticFeedback.mediumImpact();
                              if(innerList[11]=='online') {
                                if(innerList[9]!='' && innerList[10]!='') {
                                  for(int i=0; i<homeItems.length; i++) {
                                    if(innerList[0]==homeItems[i][0]) {
                                      homeItems[i][11] = 'local';
                                    }
                                  }
                                  DateTime dateNow = DateTime.now();
                                  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!Item ${innerList[0]} switched to local mode');
                                  kotlinShortcutMethodChannelSender.createShortcut(innerList[0], innerList[1], innerList[3], innerList[4], innerList[5], innerList[6], innerList[7], innerList[8], innerList[9], innerList[10], 'local');
                                  kotlinTileMethodChannelSender.createTile(int.parse(innerList[2]), innerList[1], innerList[3], innerList[4], innerList[5], innerList[6], innerList[7], innerList[8], innerList[9], innerList[10], 'local');
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(sentences.EDIT_ITEM_OFFLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                      elevation: 0,
                                    ),
                                  );
                                }
                              }
                              else if(innerList[11]=='local') {
                                if(innerList[4]!='') {
                                  for(int i=0; i<homeItems.length; i++) {
                                    if(innerList[0]==homeItems[i][0]) {
                                      homeItems[i][11] = 'online';
                                    }
                                  }
                                  DateTime dateNow = DateTime.now();
                                  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!Item ${innerList[0]} switched to online mode');
                                  kotlinShortcutMethodChannelSender.createShortcut(innerList[0], innerList[1], innerList[3], innerList[4], innerList[5], innerList[6], innerList[7], innerList[8], innerList[9], innerList[10], 'online');
                                  kotlinTileMethodChannelSender.createTile(int.parse(innerList[2]), innerList[1], innerList[3], innerList[4], innerList[5], innerList[6], innerList[7], innerList[8], innerList[9], innerList[10], 'online');
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(sentences.EDIT_ITEM_ONLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                      elevation: 0,
                                    ),
                                  );
                                }
                              }
                              await localStorage.setItem('homeItems', homeItems);
                              setState(() {});
                            },
                            child: Transform.scale(
                              scale: runningSenders[innerList[0]]!=null ? 0.93 : 1,
                              child: Container(
                                width: 0.92.sw,
                                height: 500.sp,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withAlpha(55),
                                  borderRadius: BorderRadius.circular(70.sp),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withAlpha(100),
                                      blurRadius: 50.sp
                                    )
                                  ]
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 39.sp,),
                                            Stack(
                                              alignment: AlignmentDirectional.center,
                                              children: [
                                                Container(
                                                  width: 420.sp,
                                                  height: 420.sp,
                                                  decoration: ShapeDecoration(
                                                    color: Theme.of(context).cardColor.withAlpha(220),
                                                    shape: ContinuousRectangleBorder(
                                                      borderRadius: BorderRadius.circular(180.sp),
                                                    ),
                                                    shadows: [
                                                      BoxShadow(
                                                        color: Theme.of(context).colorScheme.primary.withAlpha(120),
                                                        blurRadius: 62.sp
                                                      )
                                                    ]
                                                  ),
                                                ),
                                                Container(
                                                  width: 350.sp,
                                                  height: 350.sp,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(image: AssetImage('assets/${innerList[3]}.png'), fit: BoxFit.fitHeight,),
                                                  )
                                                ),
                                              ]
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: 590.w,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  SizedBox(
                                                    width: 260.w,
                                                    child: Text('${innerList[1]}', style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 50.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 24, 135, 226), overflow: TextOverflow.ellipsis), maxLines: 1, textAlign: TextAlign.center,),
                                                  ),
                                                  SizedBox(
                                                    width: 270.w,
                                                    child: Text('${innerList[0]}', style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 46.sp, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor), maxLines: 1, textAlign: TextAlign.center,),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SizedBox(
                                                  width: 250.w,
                                                  child: Text('${innerList[7]}', style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 46.sp, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, overflow: TextOverflow.ellipsis), maxLines: 1, textAlign: TextAlign.center,),
                                                ),
                                                Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary.withAlpha(200), size: 100.sp,),
                                                SizedBox(
                                                  width: 250.w,
                                                  child: Text('${innerList[8]}', style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 46.sp, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, overflow: TextOverflow.ellipsis), maxLines: 1, textAlign: TextAlign.center,),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 120.sp,
                                              height: 430.sp,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary.withAlpha(40),
                                                borderRadius: BorderRadius.circular(35.sp),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context).colorScheme.primary.withAlpha(90),
                                                    blurRadius: 25.sp
                                                  )
                                                ]
                                              ),
                                              clipBehavior: Clip.none,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if(runningSenders[innerList[0]]==null) {
                                                        HapticFeedback.mediumImpact();
                                                        customDialog(
                                                          context, 
                                                          sentences.WARNING, 
                                                          languageValue=='English' ? 'Do you want to delete ${innerList[1]} (ID: ${innerList[0]})?' : 'آیا میخواهید ${innerList[1]} (${innerList[0]}) را حذف کنید؟',
                                                          [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: ()=> Navigator.pop(context), 
                                                                  child: Text(sentences.NO, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 55.sp))
                                                                ),
                                                                SizedBox(width: 20.sp,),
                                                                ElevatedButton(
                                                                  onPressed: () async {
                                                                    kotlinShortcutMethodChannelSender.removeShortcut(innerList[0]);
                                                                    kotlinTileMethodChannelSender.removeTile(int.parse(innerList[2]));
                                                                    for(int i=0; i<homeItems.length; i++) {
                                                                      if(homeItems[i][0]==innerList[0]) {
                                                                        homeItems.removeAt(i);
                                                                      }
                                                                    }
                                                                    await localStorage.setItem('homeItems', homeItems);
                                                                    homeItemsChanged.value = !homeItemsChanged.value;
                                                                    DateTime dateNow = DateTime.now();
                                                                    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!The ${innerList[1]} (${innerList[0]}) item was deleted successfully');
                                                                    // ignore: use_build_context_synchronously
                                                                    Navigator.pop(context);
                                                                  }, 
                                                                  child: Text(sentences.YES, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 55.sp))
                                                                ),
                                                                SizedBox(width: 40.sp,),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      else {
                                                        customDialog(
                                                          context, 
                                                          sentences.ERROR, 
                                                          sentences.PENDING_ITEM, 
                                                          [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  }, 
                                                                  child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 55.sp))
                                                                ),
                                                                SizedBox(width: 40.sp,),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      height: 140.sp,
                                                      width: 140.sp,
                                                      child: Center(child: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 100.sp,),)
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if(runningSenders[innerList[0]]==null) {
                                                        HapticFeedback.mediumImpact();
                                                        showAddHomeItem(context, [innerList[1], innerList[4], innerList[5], innerList[6], innerList[7], innerList[8], innerList[9], innerList[10]], innerList[0], int.parse(innerList[2]), false, innerList[3], innerList[11]);
                                                      }
                                                      else {
                                                        customDialog(
                                                          context, 
                                                          sentences.ERROR, 
                                                          sentences.PENDING_ITEM, 
                                                          [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  }, 
                                                                  child: Text(sentences.OK, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 55.sp))
                                                                ),
                                                                SizedBox(width: 40.sp,),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      height: 140.sp,
                                                      width: 140.sp,
                                                      child: Center(child: Icon(Icons.edit_note_rounded, color: Colors.grey[350], size: 100.sp,),)
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      HapticFeedback.mediumImpact();
                                                      DateTime dateNow = DateTime.now();
                                                      showShareDialog(context, 'iotrix://${String.fromCharCodes(base58BitcoinEncode(Uint8List.fromList(jsonEncode(<dynamic>['sender', '${dateNow.year}-${dateNow.month}-${dateNow.day}']+innerList).codeUnits)).runes.toList().reversed)}', innerList[0], innerList[1]);
                                                    },
                                                    child: SizedBox(
                                                      height: 140.sp,
                                                      width: 140.sp,
                                                      child: Center(child: Icon(Icons.share, color: const Color.fromARGB(255, 18, 137, 255), size: 85.sp,),),
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 39.sp,),
                                          ]
                                        ),
                                      ],
                                    ),
                                    Center(  
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 250.w,
                                            height: 70.sp,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(34.sp)),
                                              color: innerList[11]=='local' ? Colors.red.withAlpha(230) : Colors.blueAccent.withAlpha(230),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: innerList[11]=='local' ? Colors.red.withAlpha(200) : Colors.blueAccent.withAlpha(200),
                                                  blurRadius: 20.sp
                                                )
                                              ]
                                            ),
                                            child: Center(
                                              child: Text(innerList[11].toUpperCase(), style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 36.sp, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor), maxLines: 1, textAlign: TextAlign.center,),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 22.sp,),
                        ],
                      );
                    }).toList()
                  ),
                ),
              ),
            )
          ]
        );
      }
    );
  }
}