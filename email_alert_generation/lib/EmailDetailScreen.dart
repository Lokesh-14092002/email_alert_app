import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class EmailDetailsScreen extends StatefulWidget {
  final String subject;
  final String from;
  final String date;
  final String body;

  const EmailDetailsScreen({
    Key? key,
    required this.subject,
    required this.from,
    required this.date,
    required this.body,
  }) : super(key: key);

  @override
  _EmailDetailsScreenState createState() => _EmailDetailsScreenState();
}

class _EmailDetailsScreenState extends State<EmailDetailsScreen> {
  FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  String translatedText = ''; // Variable to store translated text
  final translator = GoogleTranslator();
  String selectedLanguage = 'hi'; // Default language is Hindi

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedLanguage = ''; // Set default value to 'Select Language'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Email Details',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Subject:', widget.subject),
              _buildDetailItem('From:', widget.from),
              _buildDetailItem('Date:', widget.date),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Body:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!isSpeaking) {
                            _speak(widget.body);
                          } else {
                            flutterTts.stop();
                          }
                          setState(() {
                            isSpeaking = !isSpeaking;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.brown, // Background color
                        onPrimary: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Button padding
                        elevation: 4, // Elevation
                      ),

                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSpeaking ? Icons.stop : Icons.volume_up,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                isSpeaking ? 'Stop' : 'Read Aloud',
                                style: TextStyle(fontSize: 15),
                              ),

                            ]
                        )
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      widget.body,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Translate button and Select Language Dropdown
              if (translatedText.isEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _translateBody(widget.body, selectedLanguage);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.brown, // Background color
                          onPrimary: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9), // Button padding
                        ),
                        child: Text('Translate',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLanguage = newValue!;
                          });
                        },
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text('Select Language'), // Hint to select a language
                          ),
                          ...<String>['hi', 'mr'] // Languages: Hindi, Marathi
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value == 'hi' ? 'Hindi' : 'Marathi'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 10),
              // Display translated text if available
              if (translatedText.isNotEmpty) ...[
                _buildTranslatedTextCard(
                  title: 'Translated Text to',
                  translatedText: translatedText,
                  selectedLanguage: selectedLanguage == 'hi' ? 'Hindi' : 'Marathi',
                  onClose: () {
                    setState(() {
                      translatedText = '';
                    });
                  },
                ),
                SizedBox(height: 20),
                // Translate button and Select Language Dropdown
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _translateBody(widget.body, selectedLanguage);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.brown, // Background color
                          onPrimary: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9), // Button padding
                        ),
                        child: Text('Translate',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLanguage = newValue!;
                          });
                        },
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text('Select Language'), // Hint to select a language
                          ),
                          ...<String>['hi', 'mr'] // Languages: Hindi, Marathi
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value == 'hi' ? 'Hindi' : 'Marathi'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslatedTextCard({
    required String title,
    required String translatedText,
    required String selectedLanguage,
    required VoidCallback onClose,
  }) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$title $selectedLanguage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                translatedText,
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: onClose,
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  // Function to translate the body
  void _translateBody(String text, String languageCode) async {
    var translation = await translator.translate(text, to: languageCode);
    setState(() {
      translatedText = translation.text;
    });
  }

  void _speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(text);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 17),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
