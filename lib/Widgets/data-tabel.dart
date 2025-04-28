import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/screens/create-new.dart';
import 'package:final_app/util/colors.dart';
import 'package:final_app/util/responsive-helper.dart';
import 'package:flutter/material.dart';

class DataTableWidget extends StatefulWidget {
  final TicketModel? ticket;
  final String title;
  final String userName;
  final String status;
  final Color statusColor;
  final bool showDivider;

  const DataTableWidget({
    this.ticket,
    super.key,
    required this.title,
    required this.userName,
    required this.status,
    required this.statusColor,
    this.showDivider = false,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  // Removed async/await to prevent deactivated widget error
  void _handleEditPressed(BuildContext context) {
  final navigator = Navigator.of(context);
  if (widget.ticket == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ Ticket not found.')),
    );
    return;
  }

  navigator.push(
    MaterialPageRoute(
      builder: (_) => CreateNewScreen(ticket: widget.ticket),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final textScale = ResponsiveHelper.textScaleFactor(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.responsiveTextSize(
                        context,
                        isMobile ? 14 : 16,
                      ) *
                      textScale,
                  color: Colors.black87,
                ),
              ),
              SizedBox(
                  height: ResponsiveHelper.responsiveValue(
                context: context,
                mobile: 4,
                tablet: 6,
                desktop: 8,
              )),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: ColorsHelper.LightGrey,
                    size: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                  SizedBox(
                      width: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  )),
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: ColorsHelper.LightGrey,
                      fontSize: ResponsiveHelper.responsiveTextSize(
                            context,
                            isMobile ? 12 : 14,
                          ) *
                          textScale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.responsiveValue(
                context: context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
              vertical: ResponsiveHelper.responsiveValue(
                context: context,
                mobile: 4,
                tablet: 6,
                desktop: 8,
              ),
            ),
            decoration: BoxDecoration(
              color: widget.statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
            ),
            child: Center(
              child: Text(
                widget.status,
                style: TextStyle(
                  color: widget.statusColor,
                  fontSize: ResponsiveHelper.responsiveTextSize(
                        context,
                        isMobile ? 12 : 14,
                      ) *
                      textScale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: ResponsiveHelper.responsiveValue(
                context: context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              color: Colors.black,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _handleEditPressed(context);
              } else if (value == 'delete') {
                // Handle delete action
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}