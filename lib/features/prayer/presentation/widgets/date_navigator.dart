import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../cubit/selected_date_cubit.dart';
import '../cubit/selected_date_state.dart';

/// Day stepper above the prayer list. Forward is hidden once the user reaches
/// today — you cannot record a prayer you have not prayed yet.
class DateNavigator extends StatelessWidget {
  const DateNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: BlocBuilder<SelectedDateCubit, SelectedDateState>(
        builder: (context, state) {
          final cubit = context.read<SelectedDateCubit>();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: cubit.goToPreviousDay,
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 24.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  DateFormatter.toArabicLabel(state.date),
                  style: AppTextStyles.dateLabel,
                ),
              ),
              if (cubit.canGoForward)
                IconButton(
                  onPressed: cubit.goToNextDay,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 24.sp,
                    color: AppColors.textTertiary,
                  ),
                )
              else
                SizedBox(height: 24.h, width: 48.w),
            ],
          );
        },
      ),
    );
  }
}
