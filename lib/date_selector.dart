import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final Function(String) onDateSelected;

  const DateSelector({super.key, required this.onDateSelected});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late int selectedIndex;
  late List<DateTime> dates;

  @override
  void initState() {
    super.initState();

    // Initialize with today in the center and 7 days in either direction
    DateTime today = DateTime.now();
    dates = List.generate(15, (index) => today.add(Duration(days: index - 7)));
    selectedIndex = 6; // Start one option to the left of today
  }

  void _onDateChanged(int newIndex) {
    setState(() {
      selectedIndex = newIndex;
    });

    // Pass the selected date in 'yyyy-MM-dd' format to the parent widget
    String selectedDate = DateFormat('yyyy-MM-dd').format(dates[selectedIndex]);
    widget.onDateSelected(selectedDate);
  }

  /// Get the ordinal suffix for a day
  String getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Format the date as Tue, 26th
  String formatDate(DateTime date) {
    String day = DateFormat('EEE').format(date); // Day (e.g., Tue)
    int dayOfMonth = date.day;
    getOrdinalSuffix(dayOfMonth);
    return '$day, $dayOfMonth';
  }

  @override
  Widget build(BuildContext context) {
    double barHeight = 30; // Height of the date selector bar
    double textHeight = barHeight * 0.7; // Text height is 70% of the bar height
    double tabWidth = MediaQuery.of(context).size.width / 5; // Evenly spaced tabs

    return Container(
      color: const Color(0xFF003471), // Brand color background
      height: barHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => _onDateChanged(index),
            child: Container(
              alignment: Alignment.center,
              width: tabWidth,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                index == 7
                    ? 'Today' // Display 'Today' for the center tab
                    : formatDate(dates[index]), // Format date as Tue, 26th
                style: TextStyle(
                  fontSize: textHeight * 0.6, // Adjust font size based on text height
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white, // White text for all days
                  overflow: TextOverflow.ellipsis, // Prevent text overflow
                ),
              ),
            ),
          );
        },
        controller: ScrollController(
          // Center the tab to the left of the current day
          initialScrollOffset: (tabWidth * 6) - (MediaQuery.of(context).size.width / 2),
        ),
      ),
    );
  }
}