
import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/cubits/conversations/conversation-cubit.dart';
import 'package:final_app/cubits/profile/profile-cubit.dart';
import 'package:final_app/cubits/profile/prpfile-state.dart';
import 'package:final_app/models/ticket-details-model.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class TicketDetailsScreen extends StatefulWidget {
  final TicketDetailsModel ticket;
  final TicketModel userTicket;

  const TicketDetailsScreen({
    Key? key,
    required this.ticket,
    required this.userTicket,
  }) : super(key: key);

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile when the screen opens
    context.read<ProfileCubit>().loadProfile();

  }
  Future<void> _handleChatWithManager(BuildContext context) async {
    if (widget.userTicket.manager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No manager assigned to this ticket')),
      );
      return;
    }

    final conversationsCubit = context.read<ConversationsCubit>();

    try {
      final conversation = await conversationsCubit.getOrCreateConversationWithUser(
        widget.userTicket.manager!.user.id,
      );

      if (!context.mounted) return;
        // Get current user ID from profile cubit
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is! ProfileLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not loaded')),
      );
      return;
    }

final currentUserId = profileState.userId;


      if (conversation?.id != null) {
        Navigator.pushNamed(
          context,
          '/chat-screen',
          arguments: {
            'userType': 1,
            'conversationId': conversation!.id,
            //serId': userTicket.manager!.user.id,
            'userName': widget.ticket.managerName ?? 'Manager',
            'ticketId': widget.ticket.id,
          //'': userTicket.manager!.user.id,
             'currentUserId': currentUserId,
          },
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

 Future<void> _handleChatWithUser(BuildContext context) async {
  final conversationsCubit = context.read<ConversationsCubit>();

  final technician = widget.userTicket.technician;

  if (technician == null || technician.user == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('technitian not assigned')),
    );
    return;
  }

  try {
    final conversation = await conversationsCubit.getOrCreateConversationWithUser(
      technician.user.id,
    );

    if (!context.mounted) return;
    // Get current user ID from profile cubit
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is! ProfileLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not loaded')),
      );
      return;
    }
 final currentUserId = profileState.userId;


    if (conversation?.id != null) {
      Navigator.pushNamed(
        context,
        '/chat-screen',
        arguments: {
          'userType': 3,
          'conversationId': conversation!.id,
         //userId': technician.user.id, 
          'userName': technician.user.name,
          'ticketId': widget.ticket.id,
         //receiverId': technician.user.id,
           'currentUserId': currentUserId,
        },
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء بدء المحادثة: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(title: 'ticketDetails'.tr()),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoColumn(context, screenHeight, true)),
                SizedBox(width: screenWidth * 0.05),
                Expanded(child: _buildInfoColumn(context, screenHeight, false)),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'description_label'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.ticket.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'quick_chat_label'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
       
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.userTicket.manager != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleChatWithManager(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'chat_with_manager_button'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleChatWithUser(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'chatWithTechnician'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, double screenHeight, bool leftSide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leftSide) ...[
          _buildInfoItem('ticket_id_label'.tr(), '${widget.ticket.id}'),
          SizedBox(height: screenHeight * 0.02),
          _buildStatusItem(widget.ticket.statusText, widget.ticket.statusColor),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('service_label'.tr(), widget.userTicket.service.name),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('manager_label'.tr(), widget.ticket.managerName ?? 'no_manager_text'.tr()),
        ] else ...[
          _buildInfoItem('title_label'.tr(), widget.ticket.title),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('user_label'.tr(), widget.ticket.userName),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('technician_label'.tr(), widget.ticket.technicianName ?? 'no_technician_text'.tr()),
           SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('createdAt'.tr(), DateFormat('yyyy-MM-dd ').format(widget.userTicket.createdAt)),
        ],
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'status_label'.tr(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.tr(),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}


