import 'package:flutter/material.dart';
import 'package:final_app/util/colors.dart';
import 'package:final_app/util/responsive-helper.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final num percentage;
  final bool isLoading;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.responsiveValue(
          context: context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isLoading) {
              return _buildLoadingState(context);
            }
            return _buildContent(context, constraints);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.responsiveValue(
            context: context,
            mobile: 16,
            tablet: 24,
            desktop: 32,
          ),
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(ColorsHelper.darkBlue),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    final progressSize = ResponsiveHelper.responsiveValue(
      context: context,
      mobile: constraints.maxWidth * 0.6,
      tablet: constraints.maxWidth * 0.55,
      desktop: constraints.maxWidth * 0.5,
    );

    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.responsiveValue(
          context: context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: progressSize,
                height: progressSize,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(ColorsHelper.darkBlue),
                  strokeWidth: 8,
                ),
              ),
              Text(
                "${percentage.toInt()}%",
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.responsiveValue(
            context: context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveTextSize(
                        context,
                        ResponsiveHelper.responsiveValue(
                          context: context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 4,
                  tablet: 6,
                  desktop: 8,
                )),
                Icon(
                  Icons.airplane_ticket,
                  color: ColorsHelper.LightGrey,
                  size: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveValue(
            context: context,
            mobile: 4,
            tablet: 6,
            desktop: 8,
          )),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(
                context,
                ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

