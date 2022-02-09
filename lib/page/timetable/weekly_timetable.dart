import 'package:flutter/material.dart';
import '../../entity/edu/timetable.dart';
import 'package:kite/page/timetable/bottom_sheet.dart';

class WeeklyTimetable extends StatefulWidget {
  List<Course> courseList = <Course>[];

  // index1 -- 周数  index2 -- 天数
  Map<int, List<List<int>>> dailyCourseList = {};
  List<List<String>> dateTableList = [];

  WeeklyTimetable({Key? key, required this.courseList, required this.dailyCourseList, required this.dateTableList})
      : super(key: key);

  @override
  _WeeklyTimetableState createState() => _WeeklyTimetableState();
}

class _WeeklyTimetableState extends State<WeeklyTimetable> {
  late Size _deviceSize;
  static const double gridAspectRatioHeight = 1 / 1.7;
  late double singleGridHeight;
  late double singleGridWidth;

  final PageController _pageController = PageController(initialPage: 0, viewportFraction: 1.0);

  List<Course?> parsedCurrDayCourseList = [];
  // 周次 日期x7 月份
  final List<String> num2word = [
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "日",
  ];

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    singleGridHeight = _deviceSize.width * 2 / 23 / gridAspectRatioHeight;
    singleGridWidth = _deviceSize.width * 3 / 23;
    return PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        // index 从0开始
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Expanded(flex: 1, child: _buildDateTable(index)),
              Expanded(
                  flex: 10,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: ScrollController(),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildLeftSectionColumn(),
                        ),
                        Expanded(flex: 21, child: _buildCourseGrid(index))
                      ],
                    ),
                  )),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDateTable(int weekIndex) {
    List<String> currWeek = widget.dateTableList[weekIndex];
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          return index == 0
              ? SizedBox(
                  width: _deviceSize.width * 2 / 23,
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(color: Colors.black12, width: 0.8),
                              right: BorderSide(color: Colors.black12, width: 0.8))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (weekIndex + 1).toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                          const Text(
                            "周",
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      )))
              : SizedBox(
                  width: _deviceSize.width * 3 / 23,
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(color: Colors.black12, width: 0.8),
                              right: BorderSide(color: Colors.black12, width: 0.8))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "周" + num2word[index - 1],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            currWeek[index - 1],
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      )),
                );
        });
  }

  Widget _buildLeftSectionColumn() {
    return GridView.builder(
        shrinkWrap: true,
        //  防止滚动超出边界
        // physics: const ClampingScrollPhysics(),
        itemCount: 11,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: gridAspectRatioHeight),
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: Center(
                child: Text(
                  (index + 1).toInt().toString(),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                // border: Border.all(color: Colors.black12, width: 0.5),
                border: Border(
                  top: BorderSide(color: Colors.black12, width: 0.8),
                  right: BorderSide(color: Colors.black12, width: 0.8),
                ),
              ));
        });
  }

  Widget _buildCourseGrid(int weekIndex) {
    return SizedBox(
      width: singleGridWidth * 7,
      height: singleGridHeight * 11,
      child: ListView.builder(
        itemCount: 7,
        padding: const EdgeInsets.fromLTRB(1, 0, 0, 0),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          List<Course> currDayCourseList = _getCourseListByWeekAndDay(weekIndex, index);
          Map<int, Course> parsedCourseMap = _parseCurrDayCourseList(currDayCourseList);
          List<double> parsedCardHeight = _getGridHeightList(parsedCourseMap);
          return SizedBox(
              width: singleGridWidth,
              height: singleGridHeight * 11,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: parsedCardHeight.length,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _buildCourseCard(parsedCardHeight, parsedCourseMap, index);
                },
              ));
        },
      ),
    );
  }

  Widget _buildCourseCard(List<double> parsedCardHeight, Map<int, Course> parsedCourseMap, int heightIndex) {
    Course? course = parsedCurrDayCourseList[heightIndex];
    return Container(
      width: singleGridWidth,
      height: parsedCardHeight[heightIndex],
      alignment: const Alignment(0, 0),
      child: course != null
          ? InkWell(
              onTapDown: (TapDownDetails tapDownDetails) {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return CourseBottomSheet(_deviceSize, widget.courseList, course.courseName.toString(), course.courseId.toString(),
                          course.dynClassId.toString(), course.campus.toString());
                    },
                    context: context);
              },
              onTap: () {
              },
              child: Container(
                width: singleGridWidth - 3,
                height: parsedCardHeight[heightIndex] - 4,
                decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    border: Border(
                      top: BorderSide(color: Colors.lightBlueAccent, width: 1),
                      right: BorderSide(color: Colors.lightBlueAccent, width: 1),
                      left: BorderSide(color: Colors.lightBlueAccent, width: 1),
                      bottom: BorderSide(color: Colors.lightBlueAccent, width: 1),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName.toString(),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400,color: Colors.white),
                    ),
                    Text(
                      course.place.toString(),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400,color: Colors.white),
                    ),
                    Text(
                      course.teacher.toString(),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.white),
                    )
                  ],
                )
              ),
            )
          : SizedBox(
              width: singleGridWidth - 3,
              height: parsedCardHeight[heightIndex] - 4,
            ),
    );
  }

  List<Course> _getCourseListByWeekAndDay(int weekIndex, int dayIndex) {
    print("this is getCourseListByWeekAndDay");
    List<Course> res = <Course>[];
    for (var i in widget.dailyCourseList[weekIndex]![dayIndex]) {
      res.add(widget.courseList[i]);
    }
    res.sort((a, b) => (a.timeIndex!).compareTo(b.timeIndex!));
    return res;
  }

  List<double> _getGridHeightList(Map<int, Course> parsedCurrCourseList) {
    List<double> res = [];
    parsedCurrDayCourseList.clear();
    int i = 1;
    while (i <= 11) {
      if (parsedCurrCourseList.containsKey(i)) {
        // 此处hour保存已经变为当前课程有几节
        res.add(parsedCurrCourseList[i]!.hour * singleGridHeight);
        parsedCurrDayCourseList.add(parsedCurrCourseList[i]!);
        i += parsedCurrCourseList[i]!.hour;
      } else {
        res.add(singleGridHeight);
        parsedCurrDayCourseList.add(null);
        i++;
      }
    }
    return res;
  }

  Map<int, Course> _parseCurrDayCourseList(List<Course> currDayCourseList) {
    Map<int, Course> parsedCourseList = {};
    for (Course course in currDayCourseList) {
      int timeIndex = course.timeIndex!;
      // 除去首个0
      timeIndex = timeIndex >> 1;
      int count = 1;
      bool isConstant = false;
      bool isAddSectionLength = false;
      int startSection = 0;
      while (timeIndex != 0) {
        if ((timeIndex & 1) == 1 && isConstant == false) {
          startSection = count;
          parsedCourseList[startSection] = course;
          isConstant = true;
        } else if (isConstant && (timeIndex & 1) == 0) {
          // hour里面放持续节次
          parsedCourseList[startSection]!.hour = count - startSection;
          isConstant = false;
          isAddSectionLength = true;
        }
        timeIndex = timeIndex >> 1;
        count++;
      }
      if (!isAddSectionLength) {
        parsedCourseList[startSection]!.hour = count - startSection;
      }
    }
    return parsedCourseList;
  }
}
