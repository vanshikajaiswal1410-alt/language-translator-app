import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TranslatorScreen(),
    );
  }
}

class TranslatorScreen extends StatefulWidget {

  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {

  TextEditingController controller = TextEditingController();

  final translator = GoogleTranslator();
  FlutterTts tts = FlutterTts();

  late stt.SpeechToText speech;

  bool isListening = false;

  String output = "";

  String fromLang = 'en';
  String toLang = 'hi';

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();

    tts.setSpeechRate(0.5);
    tts.setPitch(1);
  }

  Future translateText() async {

    if (controller.text.isEmpty) return;

    var translation = await translator.translate(
      controller.text,
      from: fromLang,
      to: toLang,
    );

    setState(() {
      output = translation.text;
    });
  }

  void swapLanguage() {

    setState(() {

      if (fromLang == 'en') {
        fromLang = 'hi';
        toLang = 'en';
      } else {
        fromLang = 'en';
        toLang = 'hi';
      }

    });

  }

  // SPEAK FUNCTION

  void speak() async {

    if (output.isEmpty) return;

    bool isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(output);

    if (isHindi) {
      await tts.setLanguage("hi-IN");
    } else {
      await tts.setLanguage("en-US");
    }

    await tts.speak(output);
  }

  // COPY FUNCTION

  void copyText() {

    Clipboard.setData(ClipboardData(text: output));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied")),
    );

  }

  // START LISTENING

  void startListening() async {

    bool available = await speech.initialize();

    if (available) {

      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {

          setState(() {
            controller.text = result.recognizedWords;
          });

        },
      );
    }
  }

  void stopListening() {

    speech.stop();

    setState(() {
      isListening = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Hindi ↔ English Translator"),
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type or Speak...",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: swapLanguage,
                  child: Text("Swap Language"),
                ),

                SizedBox(width: 20),

                ElevatedButton(
                  onPressed: translateText,
                  child: Text("Translate"),
                ),

              ],
            ),

            SizedBox(height: 30),

            Container(
              padding: EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Text(
                output,
                style: TextStyle(fontSize: 20),
              ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton(
                  icon: Icon(Icons.volume_up),
                  onPressed: speak,
                ),

                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: copyText,
                ),

                IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                  onPressed: () {
                    if (isListening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },
                ),

              ],
            )

          ],
        ),
      ),
    );
  }
}