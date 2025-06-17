import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Widgets/drawer.dart';
import 'package:final_app/cubits/createNewTicket/creat-new-cubit.dart';
import 'package:final_app/cubits/createNewTicket/create-new-state.dart';
import 'package:final_app/models/service-model.dart';
import 'package:final_app/models/section-model.dart';
import 'package:final_app/models/ticket-model.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/Helper/app-bar.dart';

class CreateNewScreen extends StatelessWidget {
  static const routeName = '/create-new';
  final TicketModel? ticket;

  const CreateNewScreen({super.key, this.ticket});

  InputDecoration getFieldDecoration({
    required BuildContext context,
    required String labelText,
    required String hintText,
    String? errorText,
    String? successText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
    
      errorStyle: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 12,
      ),
      suffixIcon: successText != null && errorText == null
          ? Icon(Icons.check_circle, color: Colors.green, size: 20)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateNewCubit(ticket: ticket),
      child: Scaffold(
        appBar: CustomAppBar(
            title: ticket != null ? 'Edit Ticket'.tr() : 'Create New Ticket'.tr()),
        body: BlocConsumer<CreateNewCubit, CreateNewState>(
          listener: (context, state) {
            if (state.submissionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.submissionError!),
                  backgroundColor: ColorsHelper.LightGrey,
                ),
              );
            }
            if (state.isSuccess) {
              Navigator.pushReplacementNamed(context, '/all-tickets');
            }
          },
          builder: (context, state) {
            if (state.services.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: context.read<CreateNewCubit>().formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    // Title Field
                    TextFormField(
                      controller:
                          context.read<CreateNewCubit>().titleController,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'title'.tr(),
                        hintText: 'enterTitle'.tr(),
                        successText: state.titleSuccess,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Services Dropdown
                    DropdownButtonFormField<ServiceModel>(
                      value: state.selectedService,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'service'.tr(),
                        hintText: 'selectService'.tr(),
                        //errorText: state.serviceError,
                        successText: state.serviceSuccess,
                      ),
                      items: state.services.map((ServiceModel service) {
                        return DropdownMenuItem<ServiceModel>(
                          value: service,
                          child: Text(service.name),
                        );
                      }).toList(),
                      onChanged: (ServiceModel? newValue) {
                        context.read<CreateNewCubit>().selectService(newValue);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Sections Dropdown
                    DropdownButtonFormField<SectionModel>(
                      value: state.selectedSection,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'Section'.tr(),
                        hintText: state.isSectionsLoading 
                            ? 'Loading sections...' 
                            : state.sections.isEmpty 
                                ? 'Select service first'
                                : 'selectSection'.tr(),
                       // errorText: state.sectionError,
                        successText: state.sectionSuccess,
                      ),
                      items: state.sections.map((SectionModel section) {
                        return DropdownMenuItem<SectionModel>(
                          value: section,
                          child: Text(section.name),
                        );
                      }).toList(),
                      onChanged: state.isSectionsLoading || state.sections.isEmpty
                          ? null
                          : (SectionModel? newValue) {
                              context.read<CreateNewCubit>().selectSection(newValue);
                            },
                    ),

                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller:
                          context.read<CreateNewCubit>().descriptionController,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'description'.tr(),
                        hintText: 'typeDescription'.tr(),
                       // errorText: state.descriptionError,
                        successText: state.descriptionSuccess,
                      ),
                      maxLines: 5,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (context
                            .read<CreateNewCubit>()
                            .formKey
                            .currentState!
                            .validate()) {
                          context.read<CreateNewCubit>().submitForm(context);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: state.isButtonEnabled && !state.isLoading
                          ? () {
                              if (context
                                  .read<CreateNewCubit>()
                                  .formKey
                                  .currentState!
                                  .validate()) {
                                context
                                    .read<CreateNewCubit>()
                                    .submitForm(context);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        backgroundColor: ColorsHelper.darkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: state.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              ticket != null
                                  ? 'upDateTicket'.tr()
                                  : 'submitTicket'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
// import 'package:easy_localization/easy_localization.dart';
// import 'package:final_app/Widgets/drawer.dart';
// import 'package:final_app/cubits/createNewTicket/creat-new-cubit.dart';
// import 'package:final_app/cubits/createNewTicket/create-new-state.dart';
// import 'package:final_app/models/service-model.dart';
// import 'package:final_app/models/ticket-model.dart';
// import 'package:final_app/util/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:final_app/Helper/app-bar.dart';

// class CreateNewScreen extends StatelessWidget {
//   static const routeName = '/create-new';
//   final TicketModel? ticket;

//   const CreateNewScreen({super.key, this.ticket});

//   InputDecoration getFieldDecoration({
//     required BuildContext context,
//     required String labelText,
//     required String hintText,
//     String? errorText,
//     String? successText,
//   }) {
//     return InputDecoration(
//       labelText: labelText,
//       hintText: hintText,
//       errorText: errorText,
    
//       errorStyle: TextStyle(
//         color: Theme.of(context).colorScheme.error,
//         fontSize: 12,
//       ),
//       suffixIcon: successText != null && errorText == null
//           ? Icon(Icons.check_circle, color: Colors.green, size: 20)
//           : null,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.blue),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//       ),
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => CreateNewCubit(ticket: ticket),
//       child: Scaffold(
//         appBar: CustomAppBar(
//             title: ticket != null ? 'Edit Ticket'.tr() : 'Create New Ticket'.tr()),
//         body: BlocConsumer<CreateNewCubit, CreateNewState>(
//           listener: (context, state) {
//             if (state.submissionError != null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(state.submissionError!),
//                   backgroundColor: ColorsHelper.LightGrey,
//                 ),
//               );
//             }
//             if (state.isSuccess) {
//               Navigator.pushReplacementNamed(context, '/all-tickets');
//             }
//           },
//           builder: (context, state) {
//             if (state.services.isEmpty) {
//               return Center(child: CircularProgressIndicator());
//             }
            
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: context.read<CreateNewCubit>().formKey,
//                 child: ListView(
//                   children: [
//                     const SizedBox(height: 16),
//                     // Title Field
//                     TextFormField(
//                       controller:
//                           context.read<CreateNewCubit>().titleController,
//                       decoration: getFieldDecoration(
//                         context: context,
//                         labelText: 'title'.tr(),
//                         hintText: 'enterTitle'.tr(),
//                         successText: state.titleSuccess,
//                       ),
//                       textInputAction: TextInputAction.next,
//                     ),
//                     const SizedBox(height: 16),

//                     // Services Dropdown
//                     DropdownButtonFormField<ServiceModel>(
//                       value: state.selectedService,
//                       decoration: getFieldDecoration(
//                         context: context,
//                         labelText: 'service'.tr(),
//                         hintText: 'selectService'.tr(),
//                         successText: state.serviceSuccess,
//                       ),
//                       items: state.services.map((ServiceModel service) {
//                         return DropdownMenuItem<ServiceModel>(
//                           value: service,
//                           child: Text(service.name),
//                         );
//                       }).toList(),
//                       onChanged: (ServiceModel? newValue) {
//                         context.read<CreateNewCubit>().selectService(newValue);
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // sections Dropdown
//                         DropdownButtonFormField<ServiceModel>(
//                       value: state.selectedService,
//                       decoration: getFieldDecoration(
//                         context: context,
//                         labelText: 'Section'.tr(),
//                         hintText: 'selectSection'.tr(),
//                         successText: state.serviceSuccess,
//                       ),
//                       items: state.services.map((ServiceModel service) {
//                         return DropdownMenuItem<ServiceModel>(
//                           value: service,
//                           child: Text(service.name),
//                         );
//                       }).toList(),
//                       onChanged: (ServiceModel? newValue) {
//                         context.read<CreateNewCubit>().selectService(newValue);
//                       },
//                     ),

//                       const SizedBox(height: 16),

//                     // Description Field
//                     TextFormField(
//                       controller:
//                           context.read<CreateNewCubit>().descriptionController,
//                       decoration: getFieldDecoration(
//                         context: context,
//                         labelText: 'description'.tr(),
//                         hintText: 'typeDescription'.tr(),
//                         successText: state.descriptionSuccess,
//                       ),
//                       maxLines: 5,
//                       textInputAction: TextInputAction.done,
//                       onFieldSubmitted: (_) {
//                         if (context
//                             .read<CreateNewCubit>()
//                             .formKey
//                             .currentState!
//                             .validate()) {
//                           context.read<CreateNewCubit>().submitForm(context);
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 24),

//                     // Submit Button
//                     ElevatedButton(
//                       onPressed: state.isButtonEnabled && !state.isLoading
//                           ? () {
//                               if (context
//                                   .read<CreateNewCubit>()
//                                   .formKey
//                                   .currentState!
//                                   .validate()) {
//                                 context
//                                     .read<CreateNewCubit>()
//                                     .submitForm(context);
//                               }
//                             }
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 32),
//                         backgroundColor: ColorsHelper.darkBlue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         minimumSize: Size(double.infinity, 50),
//                       ),
//                       child: state.isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               ticket != null
//                                   ? 'upDateTicket'.tr()
//                                   : 'submitTicket'.tr(),
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
