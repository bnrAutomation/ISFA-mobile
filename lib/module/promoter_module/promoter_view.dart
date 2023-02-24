import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoterView extends StatelessWidget {
  const PromoterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0XFF003D5B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Promoter",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: Column(children: [
        ClipRRect(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  color: Colors.grey.shade100,
                  alignment: Alignment.center,
                  child: Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpo1BfypXH0JcsdyjZI_w3rK-T4utQ_RAVjBx5ELNHpuN9fUdPBNuwjLjSxaVfCpXhsRQ&usqp=CAU",
                    fit: BoxFit.fitWidth,
                  )),
              Container(
                color: const Color(0xffBFD1DF),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chroma Store",
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.person, size: 12),
                        const SizedBox(width: 8),
                        Text('Retailer', style: GoogleFonts.inter(fontSize: 10))
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.placemark, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              '9, 6 Number Bus stop, No 6 Locality, Shiv Nagar, Bhopal, Madhya Pradesh 462011, India, Bhopal, MP',
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                              style: GoogleFonts.inter(fontSize: 10)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0.5, 0.2),
                              blurRadius: 2.0,
                              blurStyle: BlurStyle.normal),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.navigation_rounded,
                              color: Colors.amber,
                              size: 44,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Navigate to store",
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                    height: 10,
                  ),
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0.5, 0.2),
                              blurRadius: 2.0,
                              blurStyle: BlurStyle.normal),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.amber,
                              size: 44,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Check-In to site",
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                    height: 10,
                  ),
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0.5, 0.2),
                              blurRadius: 2.0,
                              blurStyle: BlurStyle.normal),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.amber,
                              size: 44,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Start Campaign",
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 2.0,
                              blurStyle: BlurStyle.normal,
                              offset: Offset(0.5, 0.2)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.amber,
                              size: 44,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Inventory",
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                    height: 10,
                  ),
                  InkWell(
                    onTap: () => {},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0.5, 0.2),
                              blurRadius: 2.0,
                              blurStyle: BlurStyle.normal),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.feedback_outlined,
                              color: Colors.amber,
                              size: 44,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Feedback",
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ]),
    );
  }
}
