import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/ui/registration_form2.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';

import '../util/functions.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  RegistrationFormState createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                'SgelaAI',
                style: myTextStyle(context, Theme.of(context).primaryColor, 24,
                    FontWeight.w900),
              ),
              gapW16,
              Text(
                'Registration: 1 of 2',
                style: myTextStyleMedium(context),
              ),
            ],
          ),
        ),
        body: ScreenTypeLayout.builder(
          mobile: (_) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyForm(
                  onNext: (map) {
                    pp('$mm Next pressed ... check that all fields are filled in: $map');
                    bool filledIn = false;
                    int cnt = 0;
                    if (map['orgName'] != null) {
                      cnt++;
                    }
                    if (map['adminFirstName'] != null) {
                      cnt++;
                    }
                    if (map['adminLastName'] != null) {
                      cnt++;
                    }
                    if (map['email'] != null) {
                      cnt++;
                    }
                    if (cnt == 4) {
                      filledIn = true;
                    }
                    if (filledIn) {
                      NavigationUtils.navigateToPage(
                          context: context,
                          widget: RegistrationForm2(variables: map));
                    }
                  },
                ),
              )),
            );
          },
        ));
  }

  static const mm = '🌀🌀🌀🌀🌀RegistrationForm';
}

class MyForm extends StatelessWidget {
  const MyForm({super.key, required this.onNext});

  final Function(Map<String, dynamic>) onNext;

  FormGroup buildForm() => fb.group(<String, Object>{
        'email': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        'orgName': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        'adminFirstName': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        'adminLastName': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
      });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ReactiveFormBuilder(
          form: buildForm,
          builder: (context, form, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  gapH32,
                  ReactiveTextField<String>(
                    formControlName: 'orgName',
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The Organization must not be empty',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Organization Name',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.7),
                      errorStyle: TextStyle(height: 0.7),
                    ),
                  ),
                  gapH16,
                  ReactiveTextField<String>(
                    formControlName: 'adminFirstName',
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The Administrator first name must not be empty',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Administrator First Name',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.7),
                      errorStyle: TextStyle(height: 0.7),
                    ),
                  ),
                  gapH16,
                  ReactiveTextField<String>(
                    formControlName: 'adminLastName',
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The Administrator surname must not be empty',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Administrator Surname',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.7),
                      errorStyle: TextStyle(height: 0.7),
                    ),
                  ),
                  gapH16,
                  ReactiveTextField<String>(
                    formControlName: 'email',
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The email must not be empty',
                      ValidationMessage.email: (_) =>
                          'The email value must be a valid email',
                      'unique': (_) => 'This email is already in use',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.7),
                      errorStyle: TextStyle(height: 0.7),
                    ),
                  ),
                  gapH32,
                  gapH32,
                  ElevatedButton(
                    style: const ButtonStyle(
                      elevation: MaterialStatePropertyAll(8.0),
                    ),
                    onPressed: () {
                      if (form.valid) {
                        pp(form.value);
                      } else {
                        form.markAllAsTouched();
                      }
                      _onNext(form, context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Next',
                        style: myTextStyleMediumLarge(context, 24),
                      ),
                    ),
                  ),
                  gapH32,
                ],
              ),
            );
          }),
    );
  }

  _onNext(FormGroup formGroup, BuildContext context) {
    pp('$mm _onNext: formGroup.value : ${formGroup.value}');
    onNext(formGroup.value);
  }

  static const mm = '🌍🌍🌍RegistrationForm1';
}
