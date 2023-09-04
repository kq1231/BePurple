import 'package:poc_app/reusable.dart';

class TodoListView extends StatefulWidget {
  final File file;
  final int currentDateIndex;
  final String title;
  const TodoListView(
      {super.key,
      required this.file,
      required this.currentDateIndex,
      required this.title});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final ScrollController _scrollController = ScrollController();

  List<List<List<double>>> vals = [];
  List<String> labels = ["Okay", "Good", "Poor"];
  List titles = ["Resources", "Readiness", "Expenses"];
  bool hasShownTodaysDate = false;
  List dates = [];
  List icons = [mBodyC2Text, mBodyC3Text, mBodyC4Text];
  dynamic fileData;
  Map renderingIndices = {"top": 0, "bottom": 0};

  @override
  void initState() {
    super.initState();
    fileData = jsonDecode(widget.file.readAsStringSync());

    dates = fileData.keys.toList();

    // Initially, we will render today's date only.
    for (String i in ["top", "bottom"]) {
      renderingIndices[i] = widget.currentDateIndex;
    }

    _scrollController.addListener(() async {
      // Check if the user has scrolled to the !very! bottom.
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Check if data is already there
        // If it isn't, add new data
        if (renderingIndices["bottom"] == dates.length - 1) {
          await rAddDataToDb(widget.file);
        }
        renderingIndices["bottom"] += 1;
        setState(() {});
      }

      // This condition below is for scrolling to the !very! top.
      else if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        // If top index is not zero, it means that
        // there is some previous data before today's date
        // so we need to show it
        if (renderingIndices["top"] != 0) {
          renderingIndices["top"] -= 1;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fileData = jsonDecode(widget.file.readAsStringSync());
    dates = fileData.keys.toList();
    // Temporary changes to file data
    // Temporary in the sense that if user presses "cancel", the changes
    // are ignored.
    var tempFileData = Map.from(fileData);

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title)),
        body: Column(children: <Widget>[
          RowContainer(
              col1Text: mHeaderC1Text,
              col2Text: mHeaderC2Text,
              col3Text: mHeaderC3Text,
              col4Text: mHeaderC4Text,
              rowType: 'header',
              rowColor: Colors.grey[300]!),
          const Divider(height: 1, color: Colors.black54),
          SizedBox(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                (MediaQuery.of(context).size.height / mBodyRowHeight) -
                64,
            width: double.infinity,
            child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    renderingIndices["bottom"] - renderingIndices["top"] + 1,
                itemBuilder: (context, index) {
                  String date =
                      dates[(index + renderingIndices["top"]).round()];

                  List<String> times =
                      List<String>.from(fileData[date]["times"]);

                  return Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(date,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: times.length,
                      itemBuilder: (context, timeIndex) {
                        String time = times[timeIndex];
                        // val is the value of the sliders for the current
                        // time | row
                        List val = fileData[dates[
                                (index + renderingIndices["top"]).round()]]
                            ["sliderStates"][timeIndex];
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, sliderSetState) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text(
                                              "${dates[(index + renderingIndices["top"]).round()]}   ${times[timeIndex]}",
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              for (int i = 0; i < 3; i++)
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Center(
                                                          child:
                                                              Text(titles[i])),
                                                      Slider(
                                                          max: 2,
                                                          value: val[i] == -1.0
                                                              ? 0.0
                                                              : val[i],
                                                          divisions: 2,
                                                          label: val[i] == -1.0
                                                              ? labels[0]
                                                              : labels[val[i]
                                                                  .round()],
                                                          onChanged:
                                                              (newValue) {
                                                            sliderSetState(() {
                                                              val[i] = newValue;
                                                              tempFileData[dates[
                                                                              (index + renderingIndices["top"]).round()]]
                                                                          [
                                                                          "sliderStates"]
                                                                      [
                                                                      timeIndex]
                                                                  [
                                                                  i] = newValue;
                                                            });
                                                          }),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    widget.file
                                                        .writeAsStringSync(
                                                            jsonEncode(
                                                                tempFileData));
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: const Text("Submit")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    tempFileData =
                                                        Map.from(fileData);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel")),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                          },
                          child: RowContainer(
                            col1Text: time,
                            col2Text: val[0] == -1.0
                                ? mDefaultText
                                : icons[val[0].round()],
                            col3Text: val[1] == -1.0
                                ? mDefaultText
                                : icons[val[1].round()],
                            col4Text: val[2] == -1.0
                                ? mDefaultText
                                : icons[val[2].round()],
                            rowType: "body",
                            rowColor: timeIndex % 2 == 0
                                ? const Color.fromARGB(233, 244, 244, 244)
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ]);
                }),
          ),
          const SizedBox(
            height: 48,
          )
        ]));
  }
}
