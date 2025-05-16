import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TimeSlotPicker extends StatefulWidget {
  final Function(int hours, int minutes)? onTimeChanged;
  final bool is24HourFormat;
  final int initialHour;
  final int initialMinute;

  const TimeSlotPicker({
    super.key,
    this.onTimeChanged,
    this.is24HourFormat = true,
    this.initialHour = 8,
    this.initialMinute = 0,
  });

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  late final FixedExtentScrollController _hoursController;
  late final FixedExtentScrollController _minutesController;
  
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedMinute = widget.initialMinute;
    
    _hoursController = FixedExtentScrollController(initialItem: _selectedHour);
    _minutesController = FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 시간 선택
        SizedBox(
          width: 120,
          height: 200,
          child: _buildHourPicker(),
        ),
        
        // 콜론
        // 시간 콜론 (중앙의 :)
        Container(
          margin: EdgeInsets.only(top: 30),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child:  SvgPicture.asset(
            'assets/images/colon.svg', // 경로 확인!
            width: 9,
            height: 35,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
        
        // 분 선택
        SizedBox(
          width: 120,
          height: 200,
          child: _buildMinutePicker(),
        ),
      ],
    );
  }

  Widget _buildHourPicker() {
    return ListWheelScrollView.useDelegate(
      controller: _hoursController,
      itemExtent: 80,
      perspective: 0.005,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (int index) {
        setState(() {
          _selectedHour = index;
          if (widget.onTimeChanged != null) {
            widget.onTimeChanged!(_selectedHour, _selectedMinute);
          }
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.is24HourFormat ? 24 : 12,
        builder: (context, index) {
          final hour = widget.is24HourFormat ? index : (index == 0 ? 12 : index);
          final hourText = hour.toString().padLeft(2, '0');
          
          final bool isSelected = index == _selectedHour;
          final double fontSize = isSelected ? 66 : 50;
          final FontWeight fontWeight = FontWeight.bold;
          
          return Center(
            child: Text(
              hourText,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMinutePicker() {
    return ListWheelScrollView.useDelegate(
      controller: _minutesController,
      itemExtent: 80,
      perspective: 0.005,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (int index) {
        setState(() {
          _selectedMinute = index;
          if (widget.onTimeChanged != null) {
            widget.onTimeChanged!(_selectedHour, _selectedMinute);
          }
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 60,
        builder: (context, index) {
          final minuteText = index.toString().padLeft(2, '0');
          
          final bool isSelected = index == _selectedMinute;
          final double fontSize = isSelected ? 66 : 50;
          final FontWeight fontWeight = FontWeight.bold;
          
          return Center(
            child: Text(
              minuteText,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          );
        },
      ),
    );
  }
} 