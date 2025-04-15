// create_new_screen.dart
import 'package:final_app/util/responsive-helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/creat-new-cubit.dart';
import 'package:final_app/Helper/custom-textField.dart';
import 'package:final_app/Helper/large-textfield.dart';
import 'package:final_app/Helper/Custom-big-button.dart';
import 'package:final_app/Helper/app-bar.dart';
import 'package:final_app/Widgets/drawer.dart';

class CreateNewScreen extends StatelessWidget {
  static const routeName = '/create-new';

  @override
  Widget build(BuildContext context) {
    //  final isMobile = ResponsiveHelper.isMobile(context);
    //  final screenWidth = ResponsiveHelper.screenWidth(context);
    return BlocProvider(
      create: (_) => CreateNewCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const MyDrawer(),
        appBar: CustomAppBar(title: 'Create New'),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.responsiveValue(
              context: context,
              mobile: 16,
              tablet: 24,
              desktop: 32,
            ),
            vertical: 20,
          ),
          child: BlocBuilder<CreateNewCubit, bool>(
            builder: (context, isEnabled) {
              final cubit = context.read<CreateNewCubit>();
              return ListView(
                children: [
                  Expanded(
                    child: Column(children: [
                      Form(
                        child: Column(
                          children: [
                            SizedBox(
                              height: ResponsiveHelper.responsiveValue(
                                context: context,
                                mobile: 16,
                                tablet: 24,
                                desktop: 32,
                              ),
                            ),
                            CustomTextField(
                              label: "First Name",
                              controller: cubit.controllers['firstName']!,
                              onChanged: (_) => cubit.checkFields(),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.responsiveValue(
                                context: context,
                                mobile: 16,
                                tablet: 24,
                                desktop: 32,
                              ),
                            ),
                            CustomTextField(
                              label: "Last Name",
                              controller: cubit.controllers['lastName']!,
                              onChanged: (_) => cubit.checkFields(),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.responsiveValue(
                                context: context,
                                mobile: 16,
                                tablet: 24,
                                desktop: 32,
                              ),
                            ),
                            CustomTextField(
                              label: "Email",
                              controller: cubit.controllers['email']!,
                              onChanged: (_) => cubit.checkFields(),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.responsiveValue(
                                context: context,
                                mobile: 16,
                                tablet: 24,
                                desktop: 32,
                              ),
                            ),
                            CustomTextField(
                              label: "Department",
                              controller: cubit.controllers['department']!,
                              dropdownItems: ['IT', 'Software', 'Hardware'],
                              onChanged: (_) => cubit.checkFields(),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.responsiveValue(
                                context: context,
                                mobile: 16,
                                tablet: 24,
                                desktop: 32,
                              ),
                            ),
                            RichTextEditor(
                              controller: cubit.controllers['richText']!,
                              onChanged: (_) => cubit.checkFields(),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.responsiveValue(
                                context: context,
                                mobile: 16,
                                tablet: 24,
                                desktop: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  SubmitButton(
                    buttonText: 'Submit',
                    isEnabled: isEnabled,
                    onPressed: () => cubit.submitForm(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
