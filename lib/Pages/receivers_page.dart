// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_codecs/base_codecs.dart';
import 'package:is_valid/is_valid.dart';
import 'package:showcaseview/showcaseview.dart';

import '/Utils/classes.dart';




class ReceiversPage extends StatefulWidget {
  const ReceiversPage({super.key});

  @override
  State<ReceiversPage> createState() => _ReceiversPageState();
}

class _ReceiversPageState extends State<ReceiversPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: receiverItemsChanged, 
      builder: (BuildContext context, t, child) {
        if(receiverItems.isNotEmpty) {
          if(firstOpened['receiverItem']??true) {
            Future.delayed(Duration(seconds: 1), () {
              ShowCaseWidget.of(context).startShowCase([showcase_receiverItem]);
            });
          }
        }
        return Stack(
          children: [
            Center(child: Image.asset('assets/IoTrix.png', color: Theme.of(context).colorScheme.primary.withAlpha(12),),),
            Showcase(
              key: showcase_receiverItem,
              title: sentences.SC_RECEIVER,
              titleAlignment: Alignment.center,
              titleTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withAlpha(220), fontSize: 55.sp),
              description: sentences.SC_RECEIVER_DES,
              descriptionTextDirection: sentences.direction,
              descTextStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 44.sp),
              targetBorderRadius: BorderRadius.circular(60.sp),
              targetPadding: EdgeInsets.all(15.sp),
              tooltipBackgroundColor: Theme.of(context).cardColor,
              tooltipPadding: EdgeInsets.all(30.sp),
              tooltipBorderRadius: BorderRadius.circular(40.sp),
              disposeOnTap: false,
              onTargetClick: () async {
                firstOpened['receiverItem'] = false;
                await localStorage.setItem('firstOpened', firstOpened);
              },
              onBarrierClick: () async {
                firstOpened['receiverItem'] = false;
                await localStorage.setItem('firstOpened', firstOpened);
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50.sp,)
                    ] +
                    receiverItems.map<Widget>((innerList) {   // [itemId, itemName, icon, server, username, password, topic, localIp, localPort, mode]
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: runningReceivers[innerList[0]]!=null   // If receiver exists
                            ? (() {
                                if(runningReceivers[innerList[0]]![1]) {   // If receiver is connected to server and running
                                  HapticFeedback.mediumImpact();
                                  runningReceivers[innerList[0]]![3].stopReceiving(innerList[0]);
                                }
                            })
                            : () async {   // Create and start receiver
                                if(innerList[9]=='online') {
                                  if(innerList[3]!='') {
                                    Timer.run(() {
                                      runningReceivers[innerList[0]] = ['', false, false, ReceiveMqttCommand()];   // message, isConnected, isReceivedMessage, Class
                                      runningReceivers[innerList[0]]![3].startReceiving(context, innerList[0], innerList[3], innerList[4], innerList[5], innerList[6]);
                                    });
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Center(
                                          child: Text(sentences.EDIT_RECEIVER_ONLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                        elevation: 0,
                                      ),
                                    );
                                  }
                                }
                                else if(innerList[9]=='local') {
                                  if(innerList[8]!='') {
                                    if(! await isVpnActive()) {
                                      if(IsValid.validateIP4Address(await getLocalIp())) {
                                        Timer.run(() {
                                          runningReceivers[innerList[0]] = ['', false, false, ReceiveUdpCommand()];   // message, isConnected, isReceivedMessage, Class
                                          runningReceivers[innerList[0]]![3].startReceiving(context, innerList[0], innerList[7], innerList[8]);
                                        });
                                      }
                                      else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Center(
                                              child: Text(sentences.NETWORK_ERROR, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                            ),
                                            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                            elevation: 0,
                                          ),
                                        );
                                      }
                                    }
                                    else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Center(
                                            child: Text(sentences.VPN_ERROR, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                          ),
                                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                          elevation: 0,
                                        ),
                                      );
                                    }
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Center(
                                          child: Text(sentences.EDIT_RECEIVER_OFFLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                        elevation: 0,
                                      ),
                                    );
                                  }
                                }
                            },
                           onLongPress: runningReceivers[innerList[0]]!=null
                            ? ()=> ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                    child: Text(sentences.RUNNING_RECEIVER, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                  elevation: 0,
                                ),
                              )
                            : () async {
                              HapticFeedback.mediumImpact();
                              if(innerList[9]=='online') {
                                if(innerList[8]!='') {
                                  for(int i=0; i<receiverItems.length; i++) {
                                    if(innerList[0]==receiverItems[i][0]) {
                                      receiverItems[i][9] = 'local';
                                    }
                                  }
                                  DateTime dateNow = DateTime.now();
                                  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!Receiver ${innerList[0]} switched to local mode');
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(sentences.EDIT_RECEIVER_OFFLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                      elevation: 0,
                                    ),
                                  );
                                }
                              }
                              else if(innerList[9]=='local') {
                                if(innerList[3]!='') {
                                  for(int i=0; i<receiverItems.length; i++) {
                                    if(innerList[0]==receiverItems[i][0]) {
                                      receiverItems[i][9] = 'online';
                                    }
                                  }
                                  DateTime dateNow = DateTime.now();
                                  logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!Receiver ${innerList[0]} switched to online mode');
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Center(
                                        child: Text(sentences.EDIT_RECEIVER_ONLINE, style: TextStyle(color: Theme.of(context).cardColor, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 50.sp, fontWeight: FontWeight.bold),), 
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100), 
                                      elevation: 0,
                                    ),
                                  );
                                }
                              }
                              await localStorage.setItem('receiverItems', receiverItems);
                              setState(() {});
                            },
                            child: Transform.scale(
                              scale: runningReceivers[innerList[0]]!=null ? (runningReceivers[innerList[0]]![1] ? 1 : 1.04) : 1,
                              child: Container(
                                width: 0.92.sw,
                                height: 500.sp,
                                decoration: BoxDecoration(
                                  color: runningReceivers[innerList[0]]!=null ? (runningReceivers[innerList[0]]![2] ? Colors.green : (runningReceivers[innerList[0]]![1] ? Colors.orangeAccent : Theme.of(context).colorScheme.primary.withAlpha(55))) : Theme.of(context).colorScheme.primary.withAlpha(55),
                                  borderRadius: BorderRadius.circular(70.sp),
                                  boxShadow: [
                                    BoxShadow(
                                      color: runningReceivers[innerList[0]]!=null ? (runningReceivers[innerList[0]]![2] ? Colors.green : (runningReceivers[innerList[0]]![1] ? Colors.orangeAccent : Theme.of(context).colorScheme.primary.withAlpha(100))) : Theme.of(context).colorScheme.primary.withAlpha(100),
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
                                                    image: DecorationImage(image: AssetImage('assets/${innerList[2]}.png'), fit: BoxFit.fitHeight,),
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
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                SizedBox(
                                                  width: 600.w,
                                                  child: Text('${innerList[6]}', style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 46.sp, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, overflow: TextOverflow.ellipsis), maxLines: 1, textAlign: TextAlign.center,),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                SizedBox(
                                                  width: 550.w,
                                                  child: Text('${sentences.ITEM_MESSAGE}:  ${runningReceivers[innerList[0]]!=null ? runningReceivers[innerList[0]]![0] : ""}', textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 46.sp, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, overflow: TextOverflow.ellipsis), maxLines: 1, textAlign: TextAlign.center,),
                                                ),
                                                SizedBox(width: 20.w),
                                                GestureDetector(
                                                  onTap: runningReceivers[innerList[0]]==null ? null : () async {
                                                    HapticFeedback.mediumImpact();
                                                    await Clipboard.setData(ClipboardData(text:  runningReceivers[innerList[0]]!=null ? runningReceivers[innerList[0]]![0] : ''));
                                                  },
                                                  child: Icon(Icons.copy, size: 70.sp, color: Theme.of(context).cardColor.withAlpha(160),),
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
                                                      HapticFeedback.mediumImpact();
                                                      if(runningReceivers[innerList[0]]==null) {
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
                                                                    for(int i=0; i<receiverItems.length; i++) {
                                                                      if(receiverItems[i][0]==innerList[0]) {
                                                                        receiverItems.removeAt(i);
                                                                      }
                                                                    }
                                                                    await localStorage.setItem('receiverItems', receiverItems);
                                                                    receiverItemsChanged.value = !receiverItemsChanged.value;
                                                                    DateTime dateNow = DateTime.now();
                                                                    logger.setLog('${dateNow.year}-${dateNow.month}-${dateNow.day}\n${dateNow.hour}:${dateNow.minute}:${dateNow.second}!!normal!!The ${innerList[1]} (${innerList[0]}) receiver was deleted successfully');
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
                                                          sentences.RUNNING_RECEIVER, 
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
                                                      HapticFeedback.mediumImpact();
                                                      if(runningReceivers[innerList[0]]==null) {
                                                        showAddReceiver(context, [innerList[1], innerList[3], innerList[4], innerList[5], innerList[6], innerList[7], innerList[8]], innerList[0], false, innerList[2], innerList[9]);
                                                      }
                                                      else {
                                                        customDialog(
                                                          context, 
                                                          sentences.ERROR, 
                                                          sentences.RUNNING_RECEIVER, 
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
                                                      // loco
                                                      showShareDialog(context, 'iotrix://${String.fromCharCodes(base58BitcoinEncode(Uint8List.fromList(jsonEncode(<dynamic>['receiver', '${dateNow.year}-${dateNow.month}-${dateNow.day}']+innerList).codeUnits)).runes.toList().reversed)}', innerList[0], innerList[1]);
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
                                              color: innerList[9]=='local' ? Colors.red.withAlpha(230) : Colors.blueAccent.withAlpha(230),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: innerList[9]=='local' ? Colors.red.withAlpha(200) : Colors.blueAccent.withAlpha(200),
                                                  blurRadius: 20.sp
                                                )
                                              ]
                                            ),
                                            child: Center(
                                              child: Text(innerList[9].toUpperCase(), style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontSize: 36.sp, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor), maxLines: 1, textAlign: TextAlign.center,),
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
            ),
          ]
        );
      }
    );
  }
}