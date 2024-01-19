import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgela_sponsor_app/data/organization.dart';

import '../../data/branding.dart';
import '../../util/environment.dart';
import '../../util/functions.dart';

class OrgLogoWidget extends StatelessWidget {
  const OrgLogoWidget({super.key, this.branding, this.height, this.name, this.width});

  final Branding? branding;
  final double? height, width;
  final String? name;

  @override
  Widget build(BuildContext context) {
    var logoUrl = ChatbotEnvironment.sgelaLogoUrl;
    var splashUrl = ChatbotEnvironment.sgelaSplashUrl;
    if (branding != null) {
      if (branding!.logoUrl != null) {
        logoUrl = branding!.logoUrl!;
      }
      if (branding!.splashUrl != null) {
        splashUrl = branding!.splashUrl!;
      }
    }
    return SizedBox(
      height: height == null ? 36 : height!,
      width: width == null? 260: width!,
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: logoUrl,
            height: height == null ? 32 : height!,
            width: height == null ? 32*4 : (height! * 4),
          ),
          gapW4,
          name == null
              ? Flexible(
                  child: Text(
                    branding == null
                        ? defaultName
                        : '${branding!.organizationName}',
                    style: myTextStyle(context, Theme.of(context).primaryColor,
                        12, FontWeight.normal),
                  ),
                )
              : Flexible(
                  child: Text(
                    name == null
                        ? defaultName
                        : name!,
                    style: myTextStyle(context, Theme.of(context).primaryColor,
                        12, FontWeight.normal),
                  ),
                ),
        ],
      ),
    );
  }
  static const defaultName = 'SgelaAI Inc.';
}
