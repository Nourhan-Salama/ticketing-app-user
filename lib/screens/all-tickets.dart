import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Helper/drop-down-creat-new.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/Widgets/tickets-view.dart';
import 'package:final_app/cubits/tickets/get-ticket-cubits.dart';
import 'package:final_app/cubits/tickets/ticket-state.dart';
import 'package:final_app/util/responsive-helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllTickets extends StatefulWidget {
  static const routeName = '/all-tickets';

  @override
  State<AllTickets> createState() => _AllTicketsState();
}

class _AllTicketsState extends State<AllTickets> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketsCubit>().fetchTickets(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'allTickets'.tr()),
      body: BlocBuilder<TicketsCubit, TicketsState>(
        builder: (context, state) {
          if (state is TicketsLoading && state is! TicketsLoaded) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TicketsError) {
            return Center(child: Text(state.message));
          } else if (state is TicketsEmpty) {
            return Column(
              children: [
                CustomDropDownCreateButton(), // Add dropdown here too
                Expanded(
                  child: Center(child: Text('noTicketsFound'.tr())),
                ),
              ],
            );
          } else if (state is TicketsLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 16,
                    tablet: 24,
                    desktop: 32,
                  ),
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    )),
                    TextField(
                      onChanged: (value) {
                        context.read<TicketsCubit>().searchTickets(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'searchHint'.tr(),
                        prefixIcon: Icon(Icons.search),
                        
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    )),
                    CustomDropDownCreateButton(),
                    SizedBox(
                        height: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    )),
                    if (state.tickets.isEmpty)
                      Center(child: Text('no_tickets_to_show'.tr()))
                    else
                      TicketsList(
                        tickets: state.tickets,
                        hasMore: state.hasMore,
                        currentPage: state.currentPage,
                        lastPage: state.lastPage,
                        isFiltered: state.isFiltered,
                      ),
                    SizedBox(
                        height: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    )),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
