import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/Helper/enum-helper.dart';
import 'package:final_app/cubits/otp/otp-verification-state.dart';
import 'package:final_app/util/colors.dart';
import 'package:final_app/util/responsive-helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_app/cubits/otp/otp-verification-cubit.dart';

class ResendOtpButton extends StatelessWidget {
  final String email;
  const ResendOtpButton({Key? key, required this.email, required OtpType otpType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpCubit, OtpState>(
      builder: (context, state) {
        if (state is OtpTimerRunning) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: ColorsHelper.darkBlue),
              SizedBox(width: 5),
              Text(
                " ${'resendOtp'.tr()} ${state.secondsRemaining} ${'s'.tr()}",
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
                  color: ColorsHelper.darkBlue,
                ),
              ),
            ],
          );
        }

        return TextButton(
          onPressed: () => context.read<OtpCubit>().resendOtp(),
          child: Text(
            'resendOtp'.tr(),
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
              color: ColorsHelper.darkBlue,
            ),
          ),
        );
      },
    );
  }
}
