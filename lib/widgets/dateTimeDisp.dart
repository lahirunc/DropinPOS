import 'dart:async';

import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DateTimeDisp extends StatefulWidget {
  @override
  _DateTimeDispState createState() => _DateTimeDispState();
}

class _DateTimeDispState extends State<DateTimeDisp> {
  int x = 0;
  DateTime _currDate = DateTime.now();
  Timer timer;

  void _updateTime() {
    setState(() {
      _currDate = DateTime.now();
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            Text(
              '${DateFormat.jm().format(_currDate)}',
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.bold,
                color: Palette.darkGrey,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.01),
        // Date
        Row(
          children: [
            Spacer(),
            GestureDetector(
              onTap: () {
                x++;
                if (x >= 10) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Hello Lahiru!'),
                      content: Row(
                        children: [
                          Text('Who is Lahiru Mahagamage? '),
                          TextButton(
                            onPressed: () async {
                              const url =
                                  'https://www.facebook.com/people/Lahiru-Mahagamage/1040080555/';
                              try {
                                if (await canLaunch(url)) {
                                  await launch(url);
                                  await launch(
                                      'https://www.linkedin.com/in/lahiru-mahagamage/');
                                } else
                                  await launch(
                                      'https://www.linkedin.com/in/lahiru-mahagamage/');
                              } on Exception {
                                await launch(url);
                              }
                            },
                            child: Text('Click to see!'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Back'),
                        ),
                      ],
                    ),
                  );
                  x = 0;
                }
              },
              child: Text(
                '${DateFormat('EEEE').format(_currDate)}, ${_currDate.day.toString().padLeft(2, '0')} ${DateFormat.MMMM().format(_currDate).padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: screenSize.width * 0.025,
                  color: Palette.darkGrey,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
