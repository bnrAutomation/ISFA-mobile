import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/issues_management_module/issues_detail_module/issueManagementDetail/issue_management_detail_bloc.dart';
import 'package:i_densfa/module/issues_management_module/issues_detail_module/issues_management_detail_repository.dart';
import 'package:i_densfa/module/ui/app_image_picker.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/module/ui/hero_photo_view.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/image_compression_helper.dart';
import 'package:photo_view/photo_view.dart';

class IssuesDetailView extends StatelessWidget {
  final String id;
  const IssuesDetailView({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Issue Details")),
      body: RepositoryProvider(
        create: (context) => IssuesManagementDetailRepository(),
        child: BlocProvider(
          create: (context) => IssueManagementDetailBloc(context.read(), id)
            ..add(GetTicketDetailEvent()),
          child: BlocConsumer<IssueManagementDetailBloc,
              IssueManagementDetailState>(
            listener: (context, state) {
              if (state is IssueManagementDetailErroState) {
                context.showSnackBarMessage(state.message);
              }
            },
            builder: (context, state) {
              final bloc = context.read<IssueManagementDetailBloc>();
              return SingleChildScrollView(
                child: Column(children: [
                  _storeDetail(context, bloc),
                  _ticketDetail(context, bloc)
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _ticketDetail(BuildContext context, IssueManagementDetailBloc bloc) {
    return Card(
        color: Colors.white,
        margin: const EdgeInsets.all(10),
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 1.sw,
                    height: 10,
                  ),
                  Text(
                    "Issue Detail",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 1.sw,
                    height: 10,
                  ),
                  const Divider(
                    endIndent: 0.5,
                    thickness: 0.5,
                    color: Colors.amber,
                    height: 0.5,
                  ),
                  SizedBox(
                    width: 1.sw,
                    height: 5,
                  ),
                  singleStatus(context, "Ticket No.",
                      bloc.selectedTicket?.ticketNo.toString() ?? ""),
                  singleStatus(
                      context,
                      "Audit Date",
                      bloc.selectedTicket?.auditDate
                              ?.toStringFormat("dd-MMM-yyyy") ??
                          "NA"),
                  singleStatus(
                      context,
                      "Issue Date",
                      bloc.selectedTicket?.ticketDate
                              ?.toStringFormat("dd-MMM-yyyy") ??
                          "NA"),
                  singleStatus(context, "Issue Category",
                      bloc.selectedTicket?.issueCategory ?? ""),
                  singleStatus(context, "Issue Sub-Category",
                      bloc.selectedTicket?.issueSubCategory ?? ""),
                  singleStatus(context, "Issue Type",
                      bloc.selectedTicket?.question ?? ""),
                  singleStatus(
                      context,
                      "Resolution Tat Exceed Days",
                      bloc.selectedTicket?.resolutionTatExceed.toString() ??
                          "NA"),
                  singleStatus(
                      context,
                      "Response Tat Exceed Days",
                      bloc.selectedTicket?.responseTatExceedDays.toString() ??
                          "NA"),
                  singleStatus(
                      context,
                      "Due Date",
                      bloc.selectedTicket?.dueDate
                              ?.toStringFormat("dd-MMM-yyyy") ??
                          "NA"),
                  singleStatus(context, "Issue Status",
                      bloc.selectedTicket?.status ?? ""),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text("Issue Image Before/After :",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          width: 0.2.sw,
                        ),
                        Expanded(
                          flex: 1,
                          child: CustomButton(
                              buttonColor: bloc.selectedBefore
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              buttonText: "Before",
                              onPressed: () => {
                                    bloc.selectedBefore = true,
                                    bloc.add(DataChangeEvent())
                                  },
                              isLoading: false,
                              isSuccess: false),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            flex: 1,
                            child: CustomButton(
                                buttonColor: bloc.selectedBefore
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                                buttonText: "After",
                                onPressed: () => {
                                      bloc.selectedBefore = false,
                                      bloc.add(DataChangeEvent())
                                    },
                                isLoading: false,
                                isSuccess: false)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 1.sw,
                    height: 10,
                  ),
                  Row(
                    children: [
                      bloc.selectedBefore == true
                          ? InkWell(
                              onTap: ((bloc.selectedTicket?.beforeImage ?? "")
                                      .urlValid())
                                  ? () async {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              HeroPhotoViewRouteWrapper(
                                                tag: "Before Image",
                                                minScale: PhotoViewComputedScale
                                                    .contained,
                                                maxScale: PhotoViewComputedScale
                                                    .covered,
                                                imageProvider:
                                                    CachedNetworkImageProvider(
                                                  (bloc.selectedTicket
                                                              ?.beforeImage ??
                                                          "")
                                                      .trim(),
                                                ),
                                              ));
                                    }
                                  : null,
                              child: Card(
                                child: ((bloc.selectedTicket?.beforeImage ?? "")
                                        .urlValid())
                                    ? Image.network(
                                        width: 0.3.sw,
                                        height: 0.3.sw,
                                        bloc.selectedTicket?.beforeImage
                                                ?.trim() ??
                                            "")
                                    : SizedBox(
                                        width: 0.3.sw,
                                        height: 0.3.sw,
                                        child: const Center(
                                          child: Text("No before Image"),
                                        ),
                                      ),
                              ),
                            )
                          : const SizedBox(),
                      bloc.selectedBefore == false
                          ? InkWell(
                              onTap: bloc
                                      .getStatusList(
                                          bloc.selectedTicket?.status ?? "",
                                          bloc.selectedTicket?.hasReopen ??
                                              false)
                                      .contains(bloc.selectedTicket?.status)
                                  ? () async {
                                      if ((bloc.selectedTicket?.hasReopen ??
                                              false) ||
                                          bloc
                                                  .getStatusList(
                                                      bloc.selectedTicket
                                                              ?.status ??
                                                          "",
                                                      bloc.selectedTicket
                                                              ?.hasReopen ??
                                                          false)
                                                  .length ==
                                              1) {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                HeroPhotoViewRouteWrapper(
                                                  tag: "After Image",
                                                  minScale:
                                                      PhotoViewComputedScale
                                                          .contained,
                                                  maxScale:
                                                      PhotoViewComputedScale
                                                          .covered,
                                                  imageProvider:
                                                      CachedNetworkImageProvider(
                                                    (bloc.selectedTicket
                                                                ?.afterImage ??
                                                            "")
                                                        .trim(),
                                                  ),
                                                ));

                                        return;
                                      }
                                      try {
                                        AppImagePicker(context,
                                            (imageFile) async {
                                          var answer = await getImageUrlPath(
                                              imageFile.path);
                                          bloc.selectedTicket?.afterImage =
                                              answer;
                                          bloc.add(DataChangeEvent());
                                        });
                                      } catch (e) {
                                        e.toString();
                                      }
                                    }
                                  : null,
                              child: Card(
                                child: ((bloc.selectedTicket?.afterImage ?? "")
                                        .urlValid())
                                    ? Image.network(
                                        width: 0.3.sw,
                                        height: 0.3.sw,
                                        bloc.selectedTicket?.afterImage
                                                ?.trim() ??
                                            "")
                                    : SizedBox(
                                        width: 0.3.sw,
                                        height: 0.3.sw,
                                        child: const Center(
                                          child: Text("No after Image"),
                                        ),
                                      ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  (((bloc.selectedTicket?.hasReopen ?? false) ||
                          bloc.selectedStatus == 'Re-Open'))
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                        "Issue Reopen Image Before/After :",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    width: 0.2.sw,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: CustomButton(
                                        buttonColor: bloc.selectedrepronBefore
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                        buttonText: "Before",
                                        onPressed: () => {
                                              bloc.selectedrepronBefore = true,
                                              bloc.add(DataChangeEvent())
                                            },
                                        isLoading: false,
                                        isSuccess: false),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: CustomButton(
                                          buttonColor: bloc.selectedrepronBefore
                                              ? Colors.grey
                                              : Theme.of(context).primaryColor,
                                          buttonText: "After",
                                          onPressed: () => {
                                                bloc.selectedrepronBefore =
                                                    false,
                                                bloc.add(DataChangeEvent())
                                              },
                                          isLoading: false,
                                          isSuccess: false)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 1.sw,
                              height: 10,
                            ),
                            Row(
                              children: [
                                bloc.selectedrepronBefore == true
                                    ? InkWell(
                                        onTap: bloc
                                                .getStatusList(
                                                    bloc.selectedTicket
                                                            ?.status ??
                                                        "",
                                                    bloc.selectedTicket
                                                            ?.hasReopen ??
                                                        false)
                                                .contains(
                                                    bloc.selectedTicket?.status)
                                            ? () async {
                                                if ((bloc.selectedTicket
                                                            ?.hasReopen ??
                                                        false) ||
                                                    bloc
                                                            .getStatusList(
                                                                bloc.selectedTicket
                                                                        ?.status ??
                                                                    "",
                                                                bloc.selectedTicket
                                                                        ?.hasReopen ??
                                                                    false)
                                                            .length ==
                                                        1) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          HeroPhotoViewRouteWrapper(
                                                            tag:
                                                                "Before Reopen Image",
                                                            minScale:
                                                                PhotoViewComputedScale
                                                                    .contained,
                                                            maxScale:
                                                                PhotoViewComputedScale
                                                                    .covered,
                                                            imageProvider:
                                                                CachedNetworkImageProvider(
                                                              (bloc.selectedTicket
                                                                          ?.reopenBeforeImage ??
                                                                      "")
                                                                  .trim(),
                                                            ),
                                                          ));

                                                  return;
                                                }
                                                try {
                                                  AppImagePicker(context,
                                                      (imageFile) async {
                                                    var answer =
                                                        await getImageUrlPath(
                                                            imageFile.path);
                                                    bloc.selectedTicket
                                                            ?.reopenBeforeImage =
                                                        answer;
                                                    bloc.add(DataChangeEvent());
                                                  });
                                                } catch (e) {
                                                  e.toString();
                                                }
                                              }
                                            : null,
                                        child: Card(
                                          child: ((bloc.selectedTicket
                                                          ?.reopenBeforeImage ??
                                                      "")
                                                  .urlValid())
                                              ? Image.network(
                                                  width: 0.3.sw,
                                                  height: 0.3.sw,
                                                  bloc.selectedTicket
                                                          ?.reopenBeforeImage
                                                          .trim() ??
                                                      "")
                                              : SizedBox(
                                                  width: 0.3.sw,
                                                  height: 0.3.sw,
                                                  child: const Center(
                                                    child:
                                                        Text("No before Image"),
                                                  ),
                                                ),
                                        ),
                                      )
                                    : const SizedBox(),
                                bloc.selectedrepronBefore == false
                                    ? InkWell(
                                        onTap: bloc
                                                .getStatusList(
                                                    bloc.selectedTicket
                                                            ?.status ??
                                                        "",
                                                    bloc.selectedTicket
                                                            ?.hasReopen ??
                                                        false)
                                                .contains(
                                                    bloc.selectedTicket?.status)
                                            ? () async {
                                                try {
                                                  if ([
                                                        "Resolved",
                                                        "Not an issue",
                                                        "Closed"
                                                      ].contains(bloc
                                                              .selectedTicket
                                                              ?.status ??
                                                          "") ||
                                                      bloc
                                                              .getStatusList(
                                                                  bloc.selectedTicket
                                                                          ?.status ??
                                                                      "",
                                                                  bloc.selectedTicket
                                                                          ?.hasReopen ??
                                                                      false)
                                                              .length ==
                                                          1) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            HeroPhotoViewRouteWrapper(
                                                              tag:
                                                                  "After Reopen Image",
                                                              minScale:
                                                                  PhotoViewComputedScale
                                                                      .contained,
                                                              maxScale:
                                                                  PhotoViewComputedScale
                                                                      .covered,
                                                              imageProvider:
                                                                  CachedNetworkImageProvider(
                                                                (bloc.selectedTicket
                                                                            ?.reopenAfterImage ??
                                                                        "")
                                                                    .trim(),
                                                              ),
                                                            ));

                                                    return;
                                                  }
                                                  AppImagePicker(context,
                                                      (imageFile) async {
                                                    var answer =
                                                        await getImageUrlPath(
                                                            imageFile.path);
                                                    bloc.selectedTicket
                                                            ?.reopenAfterImage =
                                                        answer;
                                                    bloc.add(DataChangeEvent());
                                                  });
                                                } catch (e) {
                                                  e.toString();
                                                }
                                              }
                                            : null,
                                        child: Card(
                                          child: ((bloc.selectedTicket
                                                          ?.reopenAfterImage ??
                                                      "")
                                                  .urlValid())
                                              ? Image.network(
                                                  width: 0.3.sw,
                                                  height: 0.3.sw,
                                                  bloc.selectedTicket
                                                          ?.reopenAfterImage
                                                          .trim() ??
                                                      "")
                                              : SizedBox(
                                                  width: 0.3.sw,
                                                  height: 0.3.sw,
                                                  child: const Center(
                                                    child:
                                                        Text("No after Image"),
                                                  ),
                                                ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : const SizedBox(),
                  Row(
                    children: [
                      Text("Status Action :",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(
                        width: 10,
                      ),
                      bloc
                              .getStatusList(bloc.selectedTicket?.status ?? "",
                                  bloc.selectedTicket?.hasReopen ?? false)
                              .contains(bloc.selectedTicket?.status)
                          ? DropdownButton<String>(
                              isExpanded: false,
                              value: bloc.selectedStatus,
                              items: bloc
                                  .getStatusList(
                                      bloc.selectedTicket?.status ?? "",
                                      bloc.selectedTicket?.hasReopen ?? false)
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                bloc.selectedStatus = value;
                                bloc.add(DataChangeEvent());
                              },
                            )
                          : Row(
                              children: [
                                ["admin", "stakeholder"].contains(AppStorage()
                                        .userDetail
                                        ?.role
                                        .toLowerCase())
                                    ? SizedBox(
                                        width: 0.4.sw,
                                        child: BlocConsumer<
                                            IssueManagementDetailBloc,
                                            IssueManagementDetailState>(
                                          listener: (context, state) {},
                                          builder: (context, state) {
                                            return CustomButton(
                                                buttonText: "Accept Issue",
                                                onPressed: () => {
                                                      bloc.add(
                                                          AcceptIssueEvent())
                                                    },
                                                isLoading:
                                                    state is AcceptIssueLoading,
                                                isSuccess: state
                                                    is AcceptIssueSuccess);
                                          },
                                        ),
                                      )
                                    : Text(
                                        (bloc.selectedTicket?.status ?? "")
                                            .toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                              ],
                            )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  bloc
                              .getStatusList(bloc.selectedTicket?.status ?? "",
                                  bloc.selectedTicket?.hasReopen ?? false)
                              .contains(bloc.selectedTicket?.status) &&
                          bloc.selectedTicket?.status != bloc.selectedStatus
                      ? BlocConsumer<IssueManagementDetailBloc,
                          IssueManagementDetailState>(
                          listener: (context, state) async {
                            if (state is SubmitStatusSuccessfully) {
                              await Future.delayed(const Duration(seconds: 1));
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                          },
                          builder: (context, state) {
                            return CustomButton(
                                buttonText: "Submit",
                                onPressed: () =>
                                    {bloc.add(SubmitTicketEvent())},
                                isLoading: state is SubmitStatusLoading,
                                isSuccess: state is SubmitStatusSuccessfully);
                          },
                        )
                      : const SizedBox()
                ])));
  }

  Widget _storeDetail(BuildContext context, IssueManagementDetailBloc bloc) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 1.sw,
              height: 10,
            ),
            Text(
              "Store Info.",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(
              width: 1.sw,
              height: 10,
            ),
            const Divider(
              endIndent: 0.5,
              thickness: 0.5,
              color: Colors.amber,
              height: 0.5,
            ),
            SizedBox(
              width: 1.sw,
              height: 5,
            ),
            singleStatus(context, "Store Code",
                bloc.selectedTicket?.storeCode.toString() ?? ""),
            singleStatus(
                context, "Store Name", bloc.selectedTicket?.storeName ?? ""),
            singleStatus(
                context,
                "Store Visit",
                bloc.selectedTicket?.ticketDate
                        ?.toStringFormat("dd-MMM-yyyy") ??
                    "NA")
          ],
        ),
      ),
    );
  }

  Widget singleStatus(BuildContext context, String title, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Row(
          children: [
            Text("$title :",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 5,
            ),
            Flexible(
                child:
                    Text(value, style: Theme.of(context).textTheme.titleSmall))
          ],
        ));
  }

  Future<String> getImageUrlPath(String imagePath) async {
    XFile? filePath = (await compressImage(imagePath));
    final url = Uri.parse(URLConstants.saveCampaignImage);
    final request = MultipartRequest('POST', url);
    request.headers
        .addAll({'Authorization': 'Bearer ${AppStorage().authToken}'});
    final multipartFile = await MultipartFile.fromPath(
      'image',
      filePath!.path,
      contentType: MediaType('image', 'webp'),
    );
    request.files.add(multipartFile);
    request.fields.addAll({"activity": "issusmanagement"});

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 201) {
      return jsonDecode(body)['imageUrl'];
    } else {
      final bod = jsonDecode(body);
      final String mess = bod['message'] ?? bod["error"];
      throw mess;
    }
  }


  Future<XFile?> compressImage(String file, {int? reduceSize}) async {
    return await ImageCompressionHelper.instance.compressImageAsXFile(
      file,
      'ticket',
      quality: reduceSize,
    );
  }
}
