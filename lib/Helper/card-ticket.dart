import 'package:flutter/material.dart';
import 'package:final_app/util/colors.dart';
import 'package:final_app/util/responsive-helper.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final num percentage;
  final bool isLoading;
  final IconData icon;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    this.isLoading = false,
    required this.icon,
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
      mobile: constraints.maxWidth * 0.45, // Reduced from 0.6
      tablet: constraints.maxWidth * 0.5,   // Reduced from 0.55
      desktop: constraints.maxWidth * 0.45, // Reduced from 0.5
    );

    final titleFontSize = ResponsiveHelper.responsiveTextSize(
      context,
      ResponsiveHelper.responsiveValue(
        context: context,
        mobile: 12, // Reduced from 14
        tablet: 14, // Reduced from 16
        desktop: 16, // Reduced from 18
      ),
    );

    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.responsiveValue(
          context: context,
          mobile: 6, // Reduced from 8
          tablet: 8, // Reduced from 12
          desktop: 10, // Reduced from 16
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: progressSize,
              maxWidth: progressSize,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: progressSize,
                  height: progressSize,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(ColorsHelper.darkBlue),
                    strokeWidth: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 6, // Reduced from 8
                      tablet: 7,
                      desktop: 8,
                    ),
                  ),
                ),
                Text(
                  "${percentage.toInt()}%",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveTextSize(
                      context,
                      ResponsiveHelper.responsiveValue(
                        context: context,
                        mobile: 14, // Reduced from 18
                        tablet: 16, // Reduced from 20
                        desktop: 18, // Reduced from 22
                      ),
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveValue(
            context: context,
            mobile: 4, // Reduced from 8
            tablet: 6, // Reduced from 12
            desktop: 8, // Reduced from 16
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
                      fontSize: titleFontSize, // Using reduced font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 2, // Reduced from 4
                  tablet: 4,
                  desktop: 6,
                )),
                Icon(
                  icon,
                  color: ColorsHelper.LightGrey,
                  size: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 16, // Reduced from 20
                    tablet: 20, // Reduced from 24
                    desktop: 24, // Reduced from 28
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveValue(
            context: context,
            mobile: 2, // Reduced from 4
            tablet: 4,
            desktop: 6,
          )),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveTextSize(
                context,
                ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 14, // Reduced from 16
                  tablet: 16, // Reduced from 18
                  desktop: 18, // Reduced from 20
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
