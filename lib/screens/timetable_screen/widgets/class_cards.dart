import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ClassCard extends StatefulWidget {
  const ClassCard({super.key, required String className});

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 130,
            decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        SizerUtil.deviceType == DeviceType.tablet ? 40 : 10),
                    bottomLeft: Radius.circular(
                        SizerUtil.deviceType == DeviceType.tablet ? 40 : 10))),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Maths Class',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                Divider(
                  thickness: 1.5,
                  color: Colors.black54,
                ),
                Row(
                  children: [
                    Text(
                      '09:00AM - 10:00AM',
                      style: TextStyle(fontSize: 19, color: Colors.black),
                    )
                  ],
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
