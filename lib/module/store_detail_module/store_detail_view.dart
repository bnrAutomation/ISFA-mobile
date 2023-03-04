import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StoreDetailView extends StatelessWidget {
  const StoreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            headerStoreInfo(context),
            scheduledCalls(context),
            StoreDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.article),
                      const SizedBox(width: 8),
                      Text("Recent Notes(0)",
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                      "Make note of your important discussion with the sub dealer",
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: StoreDetailCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.stacked_line_chart_rounded),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Stage",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("Select Stage",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: Theme.of(context).primaryColor)),
                          ],
                        ),
                        Icon(
                          Icons.border_color,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    ),
                  ),
                ),
                // const SizedBox(width: 8),
                Expanded(
                  child: StoreDetailCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Class",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("Other",
                                style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            StoreDetailCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.credit_card),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Available Credit",
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text("\$ 0.0",
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ],
              ),
            ),
            StoreDetailCard(
              child: ListTile(
                title: Text("Sub Dealer History",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).primaryColor)),
                subtitle: Row(
                  children: [
                    Text("Last Activity:",
                        style: Theme.of(context).textTheme.titleSmall),
                    Text("Compaign, 28 Feb 2023",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.grey)),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor),
              ),
            ),
            StoreDetailCard(
              child: ListTile(
                title: Text("More",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).primaryColor)),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  StoreDetailCard scheduledCalls(BuildContext context) {
    return StoreDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded),
              Text("\tScheduled Visits and calls",
                  style: Theme.of(context).textTheme.bodyMedium)
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("28 Feb 2023",
                style: Theme.of(context).textTheme.labelMedium),
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  shape:
                      const RoundedRectangleBorder(side: BorderSide(width: 2))),
              onPressed: null,
              child: Text("Beatplan",
                  style: Theme.of(context).textTheme.bodyMedium)),
          const Divider(),
          TextButton(
              onPressed: () {},
              child: Text("View all",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).primaryColor)))
        ],
      ),
    );
  }

  AspectRatio headerStoreInfo(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 2,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
                imageUrl: 'https://picsum.photos/200/300',
                fit: BoxFit.fitWidth),
          ),
          const ColoredBox(
            color: Colors.black12,
            child: SizedBox.expand(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.keyboard_backspace,
                              color: Colors.white)),
                      const Spacer(),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.location_off_outlined,
                            color: Colors.white,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.call,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  const Spacer(),
                  Text("Shree Sai Mangala Enterprise",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white)),
                  Text(
                      "PLOT NO.77, BLOCK NO 179/1, SYNO-159/11, GABBARMATA MANDIR GALI, KADODARA, SURAT, Surat, Gujarat, Surat, Surat, India 123456",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.white)),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Text("Metro",
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  Text(
                    "7 km Away",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class StoreDetailCard extends StatelessWidget {
  final Widget child;

  const StoreDetailCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
