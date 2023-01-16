import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

// ignore: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import 'package:htmlapp/result_screen.dart';

class HtmlEditorExample extends StatefulWidget {
  const HtmlEditorExample({Key? key}) : super(key: key);

  @override
  _HtmlEditorExampleState createState() => _HtmlEditorExampleState();
}

class _HtmlEditorExampleState extends State<HtmlEditorExample> {
  String result = '';
  final HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('HTML Editor'),
          elevation: 0,
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  if (kIsWeb) {
                    controller.reloadWeb();
                  } else {
                    controller.editorController!.reload();
                  }
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.toggleCodeView();
          },
          child: const Text(r'<\>',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HtmlEditor(
                controller: controller,
                htmlEditorOptions: const HtmlEditorOptions(
                  hint: 'Your text here...',
                  shouldEnsureVisible: true,
                  darkMode: false,
                  //initialText: "<p>text content initial, if any</p>",
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.belowEditor,
                  //by default
                  toolbarType: ToolbarType.nativeScrollable,
                  //by default
                  onButtonPressed:
                      (ButtonType type, bool? status, Function? updateStatus) {
                    return true;
                  },
                  onDropdownChanged: (DropdownType type, dynamic changed,
                      Function(dynamic)? updateSelectedItem) {
                    return true;
                  },
                  mediaLinkInsertInterceptor: (String url, InsertFileType type) {
                    return true;
                  },
                  mediaUploadInterceptor:
                      (PlatformFile file, InsertFileType type) async {
                    return true;
                  },
                ),
                otherOptions: const OtherOptions(height: 550),
                callbacks: Callbacks(
                    onBeforeCommand: (String? currentHtml) {},
                    onChangeContent: (String? changed) {},
                    onChangeCodeview: (String? changed) {},
                    onChangeSelection: (EditorSettings settings) {},
                    onDialogShown: () {},
                    onEnter: () {},
                    onFocus: () {},
                    onBlur: () {},
                    onBlurCodeview: () {},
                    onInit: () {},
                    onImageUploadError: (FileUpload? file, String? base64Str, UploadError error) {},
                    onKeyDown: (int? keyCode) {},
                    onKeyUp: (int? keyCode) {},
                    onMouseDown: () {},
                    onMouseUp: () {},
                    onPaste: () {},
                    onScroll: () {}),
                plugins: [
                  SummernoteAtMention(
                      getSuggestionsMobile: (String value) {
                        var mentions = <String>['test1', 'test2', 'test3'];
                        return mentions
                            .where((element) => element.contains(value))
                            .toList();
                      },
                      mentionsWeb: ['test1', 'test2', 'test3'],
                      onSelect: (String value) {}),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.undo();
                      },
                      child: const Text('Undo',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.clear();
                      },
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        var txt = await controller.getText();
                        if (txt.contains('src=\"data:')) {
                          txt =
                              '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                        }
                        setState(() {
                          result = txt;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResultPage(
                                        result: result,
                                      )));
                        });
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.redo();
                      },
                      child: const Text(
                        'Redo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(result),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.disable();
                      },
                      child: const Text('Disable',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.enable();
                      },
                      child: const Text(
                        'Enable',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertText('Google');
                      },
                      child: const Text('Insert Text',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertHtml(
                            '''<p style="color: blue">Google in blue</p>''');
                      },
                      child: const Text('Insert HTML',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.insertLink(
                            'Google linked', 'https://google.com', true);
                      },
                      child: const Text(
                        'Insert Link',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertNetworkImage(
                            'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
                            filename: 'Google network image');
                      },
                      child: const Text(
                        'Insert network image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
