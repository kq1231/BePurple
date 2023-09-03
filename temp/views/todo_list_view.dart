import 'dart:convert';
import 'package:purple/reusable.dart';

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

  List<List<List<double>>> hourlyRowData = [];
  List<String> labels = ["Poor", "Okay", "Good"];
  List titles = ["Resources", "Readiness", "Expenses"];
  bool showedCurrentDate = false;

  // We only want to load the data of today's date at first.
  // Then we will add to it as we scroll up or down.
  // For this, we create a map to store the required data.
  Map data = {};
  List dateList = [];

  // Keep track of the index of the first and last item displayed
  // on the screen. They will change as the user scrolls up or down.
  List<int> trackingIndices = [0, 0];

  // This function adds data to our map called "data". [See line 29]
  // The function is used by the controller.
  void addData(int dateIndex, dynamic fileData, String location) {
    // ignore: no_leading_underscores_for_local_identifiers
    var dates = fileData.keys.toList();
    // If the user scrolls to the !very! bottom, it means it's the
    // 'end' of the page.
    if (location == "end") {
      // We can add next date's data.
      data.addAll({
        dates[trackingIndices[0]]: fileData[dates[widget.currentDateIndex]]
      });
      dateList.add(dates[trackingIndices[0]]);
    } else if (location == "start") {
      // Else we add the previous date's data to the map called 'data'.
      data = {
        dates[trackingIndices[0]]: fileData[dates[widget.currentDateIndex]],
        ...data
      };
      dateList = [dates[trackingIndices[0]], ...dateList];
    }
    trackingIndices[0] = dateIndex;
  }

  @override
  void initState() {
    super.initState();
    dynamic fileData = jsonDecode(widget.file.readAsStringSync());

    // Tracking indices will initially be today's date index
    // This is because we will only start from that index
    trackingIndices[0] = widget.currentDateIndex;
    trackingIndices[1] = widget.currentDateIndex;
    addData(widget.currentDateIndex, fileData, "end");

    _scrollController.addListener(() async {
      // Check if the user has scrolled to the !very! bottom.
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // This if condition below checks if the data already exists or not.
        // If it does, it will just display it.
        // Else, it will update the database file [.json].
        if (trackingIndices[0] > 0 &&
            trackingIndices[0] < fileData.keys.toList().length - 1) {
          trackingIndices[0]++;
          // Notice that we increment the trackingIndex if we
          // reach the end of the page.
          // Then we add the data.
          addData(trackingIndices[0], fileData, "end");
          setState(() {});
        } else {
          // Here we create & add the data to the db if not already present.
          await rAddDataToDb(await rGetFile());
          setState(() {
            fileData = jsonDecode(widget.file.readAsStringSync());
          });
          trackingIndices[0] += 1;
          addData(trackingIndices[0], fileData, "end");
        }
        // This condition below is for scrolling to the !very! top.
      } else if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        if (trackingIndices[1] > 0) {
          trackingIndices[1]--;
          addData(trackingIndices[1], fileData, "start");
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
    if (dateList.length - hourlyRowData.length != 0) {
      for (int i = 0; i < dateList.length - hourlyRowData.length; i++) {
        hourlyRowData.add(List.generate(24, (index) => [0.0, 0.0, 0.0]));
      }
    }

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
                itemCount: data.keys.length,
                itemBuilder: (context, index) {
                  String date = dateList[index];
                  List<String> times = List<String>.from(data[date]);

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
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text(
                                              "${dateList[index]}   ${times[timeIndex]}",
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
                                                          value: hourlyRowData[
                                                                  index]
                                                              [timeIndex][i],
                                                          divisions: 2,
                                                          label: labels[
                                                              hourlyRowData[
                                                                          index]
                                                                      [
                                                                      timeIndex][i]
                                                                  .round()],
                                                          onChanged: (newValue) {
                                                            setState(() {
                                                              hourlyRowData[
                                                                          index]
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
                                        ],
                                      );
                                    },
                                  );
                                });
                          },
                          child: RowContainer(
                            col1Text: time,
                            col2Text: mDefaultText,
                            col3Text: mDefaultText,
                            col4Text: mDefaultText,
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
