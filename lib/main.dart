import 'package:poc_app/views/todo_list_view.dart';
import 'reusable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class SliderData {
  double value = 0.0;
}

Future<List> logix() async {
  var file = await rGetFile();
  await rSaveDataToDb(file);
  int todaysDateIndex = await addTodaysData(file);
  return [file, todaysDateIndex];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: mAppTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: mAppBarTitle));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: logix(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return TodoListView(
              file: snapshot.data[0],
              todaysDateIndex: snapshot.data[1],
              title: widget.title);
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(mSecondaryAppTitle),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }
      },
    );
  }
}
