import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/Utils/classes.dart';




class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: logsChanged,
          builder: (context, t, child)=> Column(
            spacing: 40.sp,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
              SizedBox()
            ] + logs.map<Widget>((log) {
              List<String> splittedLog = log.split('!!');
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 40.w,),
                  SizedBox(
                    width: 340.w,
                    child: Text(splittedLog[0], overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(190), fontFamily: 'Audiowide', fontSize: 36.sp),),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(splittedLog[2], overflow: TextOverflow.ellipsis, style: TextStyle(color: splittedLog[1]=='normal' ? Theme.of(context).hintColor : (splittedLog[1]=='green' ? Colors.green : Colors.redAccent), fontFamily: 'AveriaLibre', fontSize: 44.sp),),
                    ),
                  ),
                  SizedBox(width: 40.w,),
                ],
              );
            }).toList() + <Widget>[
              SizedBox(height: 20.sp,)
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(sentences.LOGS, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 78.sp),),
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
          icon: Icon(Icons.close_rounded, size: 100.sp,),
          onPressed: ()=> Navigator.pop(context),
        ),
      )
    );
  }
}