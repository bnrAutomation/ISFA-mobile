import 'package:flutter/material.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class ActiveCampaign extends StatelessWidget {
  final CampaignDetailModel detail;
  const ActiveCampaign({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            // borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1.0, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                  offset: Offset(
                    1.0, // Move to right 5  horizontally
                    1.0, // Move to bottom 5 Vertically
                  ))
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(detail.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  SmoothStarRating(
                      allowHalfRating: false,
                      onRatingChanged: (v) {},
                      starCount: 5,
                      rating: 3.4,
                      size: 20.0,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_border_outlined,
                      color: Colors.amber,
                      borderColor: Colors.amber,
                      spacing: 0.0)
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text("Status : ",
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text("Public",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Duration: ",
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                          "${detail.startDate.toStringFormat('dd MM yyyy')} - ${detail.endDate.toStringFormat('dd MM yyyy')}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                    ],
                  ),

                  Text("View➜",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600)),
                  // IconButton(
                  //     onPressed: () => {}, icon: Icon(Icons.forward_outlined))
                ],
              )
            ],
          ),
        ));
  }
}
