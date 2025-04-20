//correct without api

import 'package:final_app/cubits/creat-new-cubit.dart';
import 'package:final_app/cubits/create-new-state.dart';
import 'package:final_app/models/service-model.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/Helper/app-bar.dart';

class CreateNewScreen extends StatefulWidget {
  static const routeName = '/create-new';

  @override
  _CreateNewScreenState createState() => _CreateNewScreenState();
}

class _CreateNewScreenState extends State<CreateNewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CreateNewCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CreateNewCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

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
      helperText: errorText == null ? successText : null,
      helperStyle: TextStyle(
        color: Colors.green,
        fontSize: 12,
      ),
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
      create: (_) => _cubit,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Create New Ticket'),
        body: BlocConsumer<CreateNewCubit, CreateNewState>(
          listener: (context, state) {
            if (state.submissionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.submissionError!),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.isSuccess) {
              Navigator.pushReplacementNamed(context, '/all-tickets');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _cubit.firstNameController,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        successText: state.firstNameSuccess,
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _cubit.validateFields(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cubit.lastNameController,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        successText: state.lastNameSuccess,
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _cubit.validateFields(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cubit.emailController,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        successText: state.emailSuccess,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _cubit.validateFields(),
                    ),
                    const SizedBox(height: 16),

                    // New Dropdown: Services
                    DropdownButtonFormField<ServiceModel>(
                      value: state.selectedService,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'Service',
                        hintText: 'Select service',
                        successText: state.serviceSuccess,
                        errorText: state.serviceError,
                      ),
                      items: state.services.map((ServiceModel service) {
                        return DropdownMenuItem<ServiceModel>(
                          value: service,
                          child: Text(service.name),
                        );
                      }).toList(),
                      onChanged: (ServiceModel? newValue) {
                        _cubit.selectService(newValue);
                      },
                    ),
                    const SizedBox(height: 16),

                    // New Field: Title
                    TextFormField(
                      controller: _cubit.titleController,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'Title',
                        hintText: 'Enter ticket title',
                        successText: state.titleSuccess,
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _cubit.validateFields(),
                    ),
                    const SizedBox(height: 16),

                    // Department Dropdown
                    DropdownButtonFormField<String>(
                      value: _cubit.departmentController.text.isEmpty
                          ? null
                          : _cubit.departmentController.text,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'Department',
                        hintText: 'Select department',
                        successText: state.departmentSuccess,
                      ),
                      items: ['IT', 'Software', 'Hardware'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        _cubit.departmentController.text = newValue ?? '';
                        _cubit.validateFields();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _cubit.descriptionController,
                      decoration: getFieldDecoration(
                        context: context,
                        labelText: 'Description',
                        hintText: 'Type description',
                        successText: state.descriptionSuccess,
                      ),
                      maxLines: 5,
                      onChanged: (_) => _cubit.validateFields(),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: state.isButtonEnabled && !state.isLoading
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                _cubit.submitForm(context);
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
                          : const Text(
                              'Submit Ticket',
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
