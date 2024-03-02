import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'EmailDetailScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cron/cron.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'key1',
        channelName: 'Proto Coders Point',
        channelDescription: "Notification example",
        defaultColor: Color(0XFF9050DD),
        ledColor: Colors.white,
        playSound: true,
        enableLights: true,
        enableVibration: true,
      )
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int unreadCount = 0;
  List<Map<String, String>> unreadEmails = [];
  List<Map<String, String>> allEmails = [];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      fetchData(); //1 minute timer
    });
    checkNotificationPermission();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> checkNotificationPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enable Notifications"),
            content: Text("Please enable notifications using application settings to receive mail alerts."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchData() async {
    try {
      final responseUnreadCount = await http.get(Uri.parse('http://10.0.2.2:8000/api/unread_count'));
      final Map<String, dynamic> dataUnreadCount = json.decode(responseUnreadCount.body);
      setState(() {
        unreadCount = dataUnreadCount['unread_count'];
      });

      final responseUnreadEmails = await http.get(Uri.parse('http://10.0.2.2:8000/api/unread_emails'));
      final List<dynamic> dataUnreadEmails = json.decode(responseUnreadEmails.body);
      setState(() {
        unreadEmails = List<Map<String, String>>.from(dataUnreadEmails.map((dynamic item) {
          return Map<String, String>.from(item);
        }));
      });

      final responseAllEmails = await http.get(Uri.parse('http://10.0.2.2:8000/api/all_emails'));
      final List<dynamic> dataAllEmails = json.decode(responseAllEmails.body);
      setState(() {
        allEmails =
        List<Map<String, String>>.from(dataAllEmails.map((dynamic item) {
          return Map<String, String>.from(item);
        }));
      });

      // Schedule notification
      final cron = Cron();
      //every 1 minutes push notification will be shown and for seconds sixth (count right to left) star into the Schedule.parse('* * * * * *')
      cron.schedule(Schedule.parse('*/1 * * * *'), () async {
        if (unreadCount > 0) {
          await AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 1,
                  channelKey: 'key1',
                  title: 'Email Alert',
                  body: 'You have Important or $unreadCount Unread emails'));
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Unread Count: $unreadCount',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 20), // Add space between unread count and unread emails
          const Text('Unread Emails:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          unreadEmails.isEmpty
              ? Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              'No unread Emails',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: unreadEmails.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      '${index + 1}. ${unreadEmails[index]['Subject']!}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('From: ${unreadEmails[index]['From']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailDetailsScreen(
                            subject: unreadEmails[index]['Subject']!,
                            from: unreadEmails[index]['From']!,
                            date: unreadEmails[index]['Date']!,
                            body: unreadEmails[index]['Body']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10), // Add space between unread emails and all emails
          const Text(
            'All Emails:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allEmails.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('${index + 1}. ${allEmails[index]['Subject']!}'),
                    subtitle: Text('From: ${allEmails[index]['From']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailDetailsScreen(
                            subject: allEmails[index]['Subject']!,
                            from: allEmails[index]['From']!,
                            date: allEmails[index]['Date']!,
                            body: allEmails[index]['Body']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
