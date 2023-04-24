
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import 'package:text_to_speech/text_to_speech.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var results = 'result';
  late var _openAI;
  final bool isRead = false;
  TextEditingController textEditingController = TextEditingController();
  final qnaList = {
    'What is Digitech Solution?': 'Digitech building 2006 years',
    'When was Digitech Solution founded?': 'Digitech was founded in 2006',
    // add more Q&A pairs as needed
  };
  onSend(ChatMessage message) async {
    setState(() {
      messages.insert(0, message);
    });
    checkQnA(message.text);
  }

  void checkQnA(String message) async {
    String? response;
    qnaList.forEach((question, answer) {
      if (message.toLowerCase().contains(question.toLowerCase())) {
        response = answer;
      }
    });
    if (response != null) {
      ChatMessage msg = ChatMessage(
          user: openGpt, createdAt: DateTime.now(), text: response!);
      setState(() {
        messages.insert(0, msg);
      });
    } else {
      final request = CompleteText(
          prompt: message, model: Model.kTextDavinci3, maxTokens: 1000);
      await _openAI.onCompletion(request: request).then((response) {
        ChatMessage msg = ChatMessage(
            user: openGpt,
            createdAt: DateTime.now(),
            text: response!.choices.first.text);
        setState(() {
          messages.insert(0, msg);
        });
      });
    }
  }

  // Future<void> _getImage(ImageSource source) async{
  //   final pickedFile = await ImagePicker().pickImage(source: source);
  //   if(pickedFile != null){
  //     // covert image to text
  //     String text = await recogn
  //   }
  // }

  List<ChatMessage> messages = [];
  ChatUser user = ChatUser(id: "1", firstName: "Le", lastName: "Vi");
  ChatUser openGpt =
      ChatUser(id: "2", firstName: "Digitech", lastName: "Solutions");
  late TextToSpeech tts;
  bool isTTS = false;

  @override
  void initState() {
    _openAI = OpenAI.instance.build(
        token: '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',
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 20),
            connectTimeout: const Duration(seconds: 20)),
        isLog: true);
    tts = TextToSpeech();
    ChatMessage welcomeDigitech = ChatMessage(
        user: openGpt, createdAt: DateTime.now(), text: 'Digitech chào bạn');
    messages.add(welcomeDigitech);

    super.initState();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Digitech ChatBot"),centerTitle: true,actions: [
              InkWell(
                onTap: (){
                  setState(() {
                    if(isTTS){
                      isTTS = false;
                      tts.stop();
                    }else{
                      isTTS = true;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(isTTS ? Icons.record_voice_over : Icons.voice_over_off_sharp),
                ),
              )
      ],
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DashChat(
                currentUser: user,
                onSend: (ChatMessage message) {
                  onSend(message.text as ChatMessage);
                },
                messages: messages,
                readOnly: true,
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "type anything here.."),
                    ),
                  ),
                )),
                ElevatedButton(onPressed: (){
                }, child: Icon(Icons.mic),style: ElevatedButton.styleFrom(shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
                    backgroundColor: Colors.greenAccent),),
                ElevatedButton(
                  onPressed: () async {
                    performAction();
                  },
                  child: Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      backgroundColor: Colors.greenAccent),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
  performAction()async{
    ChatMessage msg = ChatMessage(
        user: user,
        createdAt: DateTime.now(),
        text: textEditingController.text);
    setState(() {
      messages.insert(0, msg);
    });
    final request = CompleteText(
        prompt: textEditingController.text,
        model: Model.kTextDavinci3,
        maxTokens: 1000);
    textEditingController.clear();
    await _openAI
        .onCompletion(request: request)
        .then((response) {
      ChatMessage msg = ChatMessage(
          user: openGpt,
          createdAt: DateTime.now(),
          text: response!.choices.first.text!.trim());
      setState(() {
        messages.insert(0, msg);
        // textEditingController.clear();
      });
      if(isTTS){
        tts.speak(response!.choices.first.text!.trim());
      }
    });
  }
}
