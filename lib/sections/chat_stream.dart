import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:lojisyel/widgets/chat_input_box.dart';
import 'package:lottie/lottie.dart';

class SectionStreamChat extends StatefulWidget {
  const SectionStreamChat({super.key});

  @override
  State<SectionStreamChat> createState() => _SectionStreamChatState();
}

class _SectionStreamChatState extends State<SectionStreamChat> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);
  final List<Content> chats = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: chats.isNotEmpty
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      reverse: true,
                      child: ListView.builder(
                        itemBuilder: chatItem,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chats.length,
                        reverse: false,
                      ),
                    ),
                  )
                : const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Welcome to Lojisyel!',style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),
                    Text('How can we help you today?'),
                  ],
                ))),
        if (loading)
          Container(
            padding: const EdgeInsets.all(4),
            height: 50,
            width: 50,
            child: Lottie.asset('assets/lottie/ai.json'),
          ),
        ChatInputBox(
          controller: controller,
          onSend: () {
            if (controller.text.isNotEmpty) {
              final searchedText = controller.text;
              chats.add(
                  Content(role: 'user', parts: [Parts(text: searchedText)]));
              controller.clear();
              loading = true;

              gemini.streamChat(chats).listen((value) {
                loading = false;
                setState(() {
                  if (chats.isNotEmpty &&
                      chats.last.role == value.content?.role) {
                    chats.last.parts!.last.text =
                        '${chats.last.parts!.last.text}${value.output}';
                  } else {
                    chats.add(Content(
                        role: 'model', parts: [Parts(text: value.output)]));
                  }
                });
              });
            }
          },
        ),
      ],
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final Content content = chats[index];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        color: content.role == 'model'
            ? const Color(0xff6096ba).withAlpha(250)
            : const Color(0xff829cbc),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(content.role?.toLowerCase() == "user"
                      ? Icons.account_circle_rounded
                      : Icons.smart_toy_outlined),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(content.role =="model"? "Lojisyel":"User"),
                ],
              ),
              Markdown(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  data: content.parts?.lastOrNull?.text ??
                      'cannot generate data!'),
            ],
          ),
        ),
      ),
    );
  }
}
