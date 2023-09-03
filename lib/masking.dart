// Icon Attributions:
// https://icons8.com/icon/25534/checked-checkbox
// https://icons8.com/icons/set/good
// https://icons8.com/icons/set/thumbs-down
// https://icons8.com/icons/set/nothing

//numbers
const int mScrollCount = 20;
const int mBodyRowHeight = 18;
const int mHeaderRowHeight = 12;

//texts
const String mAppTitle = 'Purple - A Lifestyle Management App';
const String mSecondaryAppTitle = 'No Data Available';
const String mAppBarTitle = 'BePurple';
const String mHeaderC1Text = 'Time';

//path to icons in assets folder
const String mHeaderC2Text = 'assets/icons/mood.png';
const String mHeaderC3Text = 'assets/icons/food.png';
const String mHeaderC4Text = 'assets/icons/spending.png';
const String mBodyC2Text = 'assets/icons/okay.png';
const String mBodyC3Text = 'assets/icons/good.png';
const String mBodyC4Text = 'assets/icons/poor.png';
const String mDefaultText = 'assets/icons/default.png';

//file name
const String mFileName = 'data.json';

//method
String mFormatString(int index) {
  final hour = DateTime.now().hour;
  int hourIndex = hour + index;
  String formattedTime =
      (hourIndex == 12 ? hourIndex : hourIndex % 12).toString() +
          (hourIndex % 24 > 11 ? " PM" : " AM");
  return formattedTime;
}
