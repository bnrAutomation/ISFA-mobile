import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

class CampaignListItem extends StatelessWidget {
  final AllCampaignModel item;
  final bool isfilled;
  const CampaignListItem(
      {super.key, required this.item, required this.isfilled});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 1.sw, height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                  ),
                  // AppStorage().userDetail?.companyName.toLowerCase() ==
                  //         "samsung"
                  (AppStorage()
                              .userDetail
                              ?.configuration
                              .requiresAllFillCampigned ??
                          false)
                      ? Text(
                          isfilled ? "Filled" : "Pending",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isfilled ? Colors.green : Colors.red),
                        )
                      : const SizedBox(),
                  const SizedBox(width: 10)
                ],
              ),
              Text(
                "Description : ${item.description}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "From : ",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    item.startDate.toStringFormat("d MMM yyyy"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "To : ",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    item.endDate.toStringFormat("d MMM yyyy"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              SizedBox(width: 1.sw, height: 5),
            ],
          )),
    );
  }
}
