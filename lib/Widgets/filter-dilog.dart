import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  int? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _enableTimeFilter = false;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('filter_tickets'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Filter
            Text('ticket_status'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text('Pending'.tr()),
                  selected: _selectedStatus == 0,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 0 : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('inProgress'.tr()),
                  selected: _selectedStatus == 1,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 1 : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('Resolved'.tr()),
                  selected: _selectedStatus == 1,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 1 : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('Closed'.tr()),
                  selected: _selectedStatus == 1,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 1 : null;
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 20),

            // Date Range
            Text('date_range'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(_startDate == null
                        ? 'select_start_date'.tr()
                        : DateFormat.yMd().format(_startDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const Icon(Icons.arrow_forward),
                Expanded(
                  child: ListTile(
                    title: Text(_endDate == null
                        ? 'select_end_date'.tr()
                        : DateFormat.yMd().format(_endDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),

            // Time Range
            SwitchListTile(
              title: Text('time_filter'.tr()),
              value: _enableTimeFilter,
              onChanged: (value) => setState(() => _enableTimeFilter = value),
            ),
            if (_enableTimeFilter) ...[
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(_startTime == null
                          ? 'select_start_time'.tr()
                          : _startTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                  Expanded(
                    child: ListTile(
                      title: Text(_endTime == null
                          ? 'select_end_time'.tr()
                          : _endTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'status': _selectedStatus,
              'startDate': _startDate,
              'endDate': _endDate,
              'startTime': _startTime,
              'endTime': _endTime,
              'enableTime': _enableTimeFilter,
            });
          },
          child: Text('apply'.tr()),
        ),
      ],
    );
  }
}
