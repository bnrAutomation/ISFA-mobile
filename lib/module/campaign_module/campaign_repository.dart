import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign_response_values.dart';
import 'package:i_densfa/module/campaign_module/new_models/filled_campaign_list.dart';
import 'package:i_densfa/module/campaign_module/new_models/response_model.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/campaign_module/new_models/question_section.dart';
import 'package:i_densfa/module/campaign_module/services/campaign_offline_service.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Custom exception for offline submissions
class OfflineSubmissionException implements Exception {
  final String message;
  final String submissionId;
  
  OfflineSubmissionException(this.message, {required this.submissionId});
  
  @override
  String toString() => message;
}

class CampaignRepository {
  final userId = AppStorage().userDetail?.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final client = CustomHttpBaseClient.instance;
  final CampaignOfflineService _offlineService = CampaignOfflineService();
  bool _offlineInitialized = false;
  final Map<String, XFile?> _compressedImageCache = {};
  
  // Initialize offline service
  Future<void> initOfflineService() async {
    if (_offlineInitialized) return;
    await _offlineService.init();
    _offlineInitialized = true;
  }

  Future<List<String>> getFilledCampaign(String storeId) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();
    
    if (!isOnline) {
      final cached = await _offlineService.getCachedFilledCampaigns(storeId);
      if (cached != null) {
        return cached;
      }
      return [];
    }
    try {
      final response = await client.get(
        Uri.parse(URLConstants.getAllClientCampaigns)
        .replace(
            queryParameters: {'userId': userId.toString(), "storeId": storeId}),
            headers: {'Content-Type': 'application/json',"Authorization": "Bearer ${AppStorage().authToken}"});
      if (response.statusCode == 200) {
        final filledCampaigns = FilledCampaignList.fromRawJson(response.body)
            .userCampaignResponses;
        // Cache the data
        await _offlineService.cacheFilledCampaigns(storeId, filledCampaigns);
        return filledCampaigns;
      } else {
        throw getErrorMessage(response);
      }
    } catch (e) {
      final cached = await _offlineService.getCachedFilledCampaigns(storeId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<AllCampaignModel>> getCampaignsForStore(String storeId,
      {bool silentSessionExpiry = false}) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();
    
    if (!isOnline) {
      final cached = await _offlineService.getCachedCampaignsForStore(storeId);
      if (cached != null) {
        return cached;
      }
      throw Exception('No internet connection and no cached data available');
    }
    
    try {
      final uri = Uri.parse(URLConstants.getAllCampaigns)
      .replace(
          queryParameters: {'userId': userId.toString(), "storeId": storeId});
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        final campaigns = (json.decode(response.body) as List)
            .map((e) => AllCampaignModel.fromJson(e))
            .where((element) => element.status == "PUBLISHED")
            .where((element) => !element.isNegative())
            .toList();
        
        // Cache the data
        await _offlineService.cacheCampaignsForStore(storeId, campaigns);
        
        campaigns.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        return campaigns;
      } else {
        throw getErrorMessage(response);
      }
    } catch (e) {
      // If online request fails, try cache
      final cached = await _offlineService.getCachedCampaignsForStore(storeId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<CampaignQuestionSectionModel>> getSections(
      {required String campaignUuid, bool silentSessionExpiry = false}) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();
    
    if (!isOnline) {
      final cached = await _offlineService.getCachedSections(campaignUuid);
      if (cached != null) {
        return cached;
      }
      throw Exception('No internet connection and no cached data available');
    }
    
    try {
      final response = await client.get(
        Uri.parse("${URLConstants.getAllCampaignsList}/$campaignUuid/section"),
      );
      if (response.statusCode == 200) {
        final sections = (json.decode(response.body) as List)
            .map((e) => CampaignQuestionSectionModel.fromJson(e))
            .toList();
        // Cache the data
        await _offlineService.cacheSections(campaignUuid, sections);
        
        return sections;
      } else {
        throw getErrorMessage(response);
      }
    } catch (e) {
      final cached = await _offlineService.getCachedSections(campaignUuid);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }
  Future<List<CampaignQuestionModel>> getQuestions(
      {required String campaignUuid,
      required String sectionUuid,
      bool silentSessionExpiry = false}) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();
    
    if (!isOnline) {
      final cached = await _offlineService.getCachedQuestions(campaignUuid, sectionUuid);
      if (cached != null) {
        return cached;
      }
      throw Exception('No internet connection and no cached data available');
    }
    
    try {
      final response = await client.get(Uri.parse("${URLConstants.getAllCampaignsList}/$campaignUuid/section/$sectionUuid/question"));
      if (response.statusCode == 200) {
        final questions = (json.decode(response.body) as List)
            .map((e) => CampaignQuestionModel.fromJson(e))
            .toList();
        
        // Cache the data
        await _offlineService.cacheQuestions(campaignUuid, sectionUuid, questions);
        
        return questions;
      } else {
        throw getErrorMessage(response);
      }
    } catch (e) {
      final cached = await _offlineService.getCachedQuestions(campaignUuid, sectionUuid);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<ResponseModel> saveCampaignAnswers(Map<String, dynamic> bodyMap) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();
    
    if (!isOnline) {
      // Queue for offline submission
      final campaignUuid = bodyMap['campaignUuid'] as String;
      final storeId = bodyMap['storeId'] as int? ?? 0;
      
      final submissionId = await _offlineService.queueSubmission(
        requestBody: bodyMap,
        campaignUuid: campaignUuid,
        storeId: storeId,
      );
      
      throw OfflineSubmissionException(
        'Campaign saved offline. Will be submitted when online.',
        submissionId: submissionId,
      );
    }
    
    // Online submission
    final response = await client.post(
      Uri.parse("${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/client/campaign/${bodyMap['campaignUuid']}/response")
          .replace(queryParameters: {'userId': userId.toString()}),
      body: jsonEncode(bodyMap),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return ResponseModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }
  
  // Get offline service instance for bloc access
  CampaignOfflineService get offlineService => _offlineService;

  Future<bool> hasStoreBeenVisitedToday(int storeId) async {
    await initOfflineService();

    if (kDebugMode) {
      debugPrint(
          AppStorage().userDetail?.configuration.requiredMultiStore.toString());
    }
    // If multi-store restriction is disabled, never block
    if (!(AppStorage().userDetail?.configuration.requiredMultiStore ?? false)) {
      return false;
    }

    final today = DateTime.now();
    final isOnline = await _offlineService.isOnline();

    // Try cached value first (what server told us earlier today)
    final cachedStatus = await _offlineService.getCachedStoreVisitStatus(storeId, today);

    if (!isOnline) {
      // OFFLINE: if we have a cached 'already visited' from server for today, respect it.
      // Otherwise, assume not visited (can't know about other FOS while offline).
      return cachedStatus ?? false;
    }

    // ONLINE: always ask server, then cache today's result
    try {
      final uri = Uri.parse(URLConstants.campaignExists)
          .replace(queryParameters: {'storeId': storeId.toString()});
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        final visited = jsonDecode(response.body) as bool;

        // Cache today's result for offline use
        await _offlineService.cacheStoreVisitStatus(storeId, today, visited);

        return visited;
      } else {
        throw getErrorMessage(response);
      }
    } catch (e) {
      // If API fails online, fall back to cached value if present
      if (cachedStatus != null) {
        return cachedStatus;
      }
      // As a last resort, don't block
      return false;
    }
  }

  Future<SavedCampaignDataModel?> savedCampaignResponse(
      String campaignUuid) async {
    final response = await client.get(
      Uri.parse(
          "${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId/campaign/$campaignUuid?filterBy=date&unit=120"),
    );
    if (response.statusCode == 200) {
      final dataJson = jsonDecode(response.body);
      if (dataJson == null) {
        throw getErrorMessage(response);
      } else {
        return SavedCampaignDataModel.fromJson(dataJson);
      }
    } else {
      throw getErrorMessage(response);
    }
  }

  /// Fetches previously submitted campaign responses for prefill.
  /// Returns an empty list on any failure so campaign load is never blocked.
  /// Each item may include [CampaignResponseValuesSubmission.createdDate].
  Future<List<CampaignResponseValuesSubmission>> getCampaignResponseValues({
    required String campaignUuid,
    required int storeId,
  }) async {
    try {
      final isOnline = await _offlineService.isOnline();
      if (!isOnline) return [];

      final response = await client.get(
        Uri.parse(URLConstants.getCampaignResponseValues).replace(
          queryParameters: {
            'userId': userId.toString(),
            'storeId': storeId.toString(),
            'campaignUuid': campaignUuid,
          },
        ),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null) return [];
        return parseCampaignResponseValuesSubmissions(decoded);
      }
      return [];
    } catch (e) {
      debugPrint('getCampaignResponseValues failed: $e');
      return [];
    }
  }

  /// Fetches section fill status from response-values (Outlet Onboarding).
  /// Returns an empty list on any failure so campaign load is never blocked.
  Future<List<CampaignSectionFillStatus>> getCampaignSectionFillStatuses({
    required String campaignUuid,
    required int storeId,
  }) async {
    try {
      final isOnline = await _offlineService.isOnline();
      if (!isOnline) return [];

      final response = await client.get(
        Uri.parse(URLConstants.getFilledSection).replace(
          queryParameters: {
            'userId': userId.toString(),
            'storeId': storeId.toString(),
            'campaignUuid': campaignUuid,
          },
        ),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null) return [];
        return parseCampaignSectionFillStatuses(decoded);
      }
      return [];
    } catch (e) {
      debugPrint('getCampaignSectionFillStatuses failed: $e');
      return [];
    }
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
    request.fields.addAll({"activity": "campaign"});
    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();
    if (response.statusCode == 201) {
      return jsonDecode(body)['imageUrl'];
    } else {
      throw getErrorMessageSteam(response, body);
    }
  }

  Future<bool> addSagment(List<dynamic> request, String campaignUuid,
      int storeid, String uuId) async {
    var body = {
      //"responseUuid": uuId,
      "resposneUuid": uuId,
      "campaignUuid": campaignUuid,
      "storeId": storeid,
      "campaignResponse": request
    };

    final response = await client.post(
      Uri.parse(
          "${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/client/campaign/$campaignUuid/OSMM/response"),
      body: jsonEncode(body),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> saveActivationOrEnrolment(
      Map<String, dynamic> bodyMap, String id) async {
    final response = await client.put(
      Uri.parse("${URLConstants.baseURLStart}/iSFA/mechanic/$id"),
      body: jsonEncode(bodyMap),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

    Future<bool> saveISPVisit(Map<String, String> bodyMap) async {
    final response = await client.post(
      Uri.parse("${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/record"),
      body: jsonEncode(bodyMap),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> saveRetailerVisit(Map<String, String> bodyMap) async {
    final response = await client.post(
      Uri.parse("${URLConstants.baseURLStart}/iSFA/api/kpi"),
      body: jsonEncode(bodyMap),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> saveRecruiter(Map<String, String> bodyMap) async {
    final response = await client.post(
      Uri.parse("${URLConstants.baseURLStart}/iSFA/recruiter"),
      body: jsonEncode(bodyMap),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> saveMechanic(Map<String, dynamic> bodyMap) async {
    final response = await client.post(
      Uri.parse("${URLConstants.baseURLStart}/iSFA/mechanic"),
      body: jsonEncode(bodyMap),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<RecruiterModel>> getRecruiters(String retailerName, String mechanicName, bool isMasterData,
      {bool silentSessionExpiry = false}) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();

    if (!isOnline) {
      // Offline: use cached recruiters if available.
      final cached = await _offlineService.getCachedRecruiters();
      if (cached != null) {
        return cached;
      }
      // No cache – return empty list to avoid blocking offline flow.
      return [];
    }

    final uri =
        Uri.parse("${URLConstants.baseURLStart}/iSFA/recruiter/$userId");
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final data  = (json.decode(response.body) as List)
          .map((e) => RecruiterModel.fromJson(e)).toList();

      final recruiters = isMasterData? data : (mechanicName.isNotEmpty ? data:  (retailerName.isNotEmpty?
       data.where((retailer) =>
            retailer.counterName.toLowerCase().trim() ==
            retailerName.toLowerCase().trim()).toList(): data));
      
      // Cache for offline usage.
      await _offlineService.cacheRecruiters(recruiters);

      return recruiters;
    } else {
      throw getErrorMessage(response,
          suppressSessionPopup: silentSessionExpiry);
    }
  }
  
  Future<List<ProductInfo>> getProductList(String type, String from) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();

    if (!isOnline) {
      // Offline: use cached products for this type if available.
      final cached = await _offlineService.getCachedProducts(type);
      if (cached != null) {
        return cached;
      }
      return [];
    }

    ///iSFA/mechanic/all
    final uri = Uri.parse(
        "${URLConstants.baseURLStart}/iSFA/recruiter/product?subSegment=$type&type=$from");
    final response = await get(uri, headers: {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${AppStorage().authToken}',
    });
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];

      final infos = decoded
          .map((e) => ProductInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      await _offlineService.cacheProducts(type, infos);

      // Existing UI usage expects a list of product names.
      return infos
         ;
    } else {
      return [];
    }
  }
  
  Future<List<MechanicModel>> getMechanics(String selectedMechanicName, String selectedMechanicContact) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();

    if (!isOnline) {
      // Offline: use cached mechanics if available.
      final cached = await _offlineService.getCachedMechanics();
      if (cached != null) {
        return cached;
      }
      return [];
    }

    final uri = Uri.parse("${URLConstants.baseURLStart}/iSFA/mechanic/$userId");
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final mechanics = (json.decode(response.body) as List)
          .map((e) => MechanicModel.fromJson(e))
          .toList();

    (json.decode(response.body) as List)
        .map((e) => MechanicModel.fromJson(e))
        .where((e) =>
            e.mechanicName.toLowerCase().trim() ==
            selectedMechanicName.toLowerCase().trim() &&  e.mechanicNumber.toLowerCase().trim() ==
            selectedMechanicContact.toLowerCase().trim())
        .toList();


      // Cache for offline usage.
      await _offlineService.cacheMechanics(mechanics);

      return   selectedMechanicName.isEmpty ? 
      mechanics: 
       mechanics.where((e) =>
            e.mechanicName.toLowerCase().trim() ==
            selectedMechanicName.toLowerCase().trim() &&  e.mechanicNumber.toLowerCase().trim() ==
            selectedMechanicContact.toLowerCase().trim()).toList();
      
    } else {
      return [];
    }
  }

  Future<String> _getExternalStoragePath() async {
    if (Platform.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getExternalStorageDirectory())?.path ?? "";
    }
  }

  Future<XFile?> compressImage(String file, {int? reduceSize}) async {
    // Avoid recompressing the same source file within a session
    if (_compressedImageCache.containsKey(file)) {
      return _compressedImageCache[file];
    }

    final now = DateTime.now();
    final formattedDate = DateFormat("yyyyMMdd'T'HH:mm:ss").format(now);

    final directory =
        "${await _getExternalStoragePath()}/${AppStorage().userDetail?.id}_campaign_${formattedDate}_${basename(file)}";
    int size = reduceSize ?? 90;
    final img = await FlutterImageCompress.compressAndGetFile(
      file,
      directory,
      quality: size,
    );
    final listImg = await img?.readAsBytes();
    if ((listImg?.lengthInBytes ?? 0) / 1024.0 > 400) {
      return await compressImage(file, reduceSize: size - 10);
    }
    if (img != null) {
      _compressedImageCache[file] = img;
    }
    return img;
  }

  /// Pre-sync all campaign data for a store (campaigns, sections, questions, master data)
  /// This should be called when online to enable full offline access
  Future<void> preSyncCampaignsForStore(String storeId) async {
    await initOfflineService();
    final isOnline = await _offlineService.isOnline();
    
    if (!isOnline) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot pre-sync: device is offline');
      }
      return;
    }
    
    try {
      if (kDebugMode) {
        debugPrint('🔄 Starting pre-sync for store: $storeId');
      }
      
      // Pre-sync uses silentSessionExpiry so 401 does not show session-expired popup
      const silentSessionExpiry = true;

      // 1. Get and cache all campaigns for this store
      final campaigns = await getCampaignsForStore(storeId,
          silentSessionExpiry: silentSessionExpiry);
      if (kDebugMode) {
        debugPrint('✅ Cached ${campaigns.length} campaigns');
      }
      
      // 2. Pre-load master data (mechanics, recruiters) - needed for dropdowns
      try {
        final mechanics = await getMechanics("","");
        await _offlineService.cacheMechanics(mechanics);
        if (kDebugMode) {
          debugPrint('✅ Cached ${mechanics.length} mechanics');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Failed to cache mechanics: $e');
        }
      }
      
      try {
        final recruiters = await getRecruiters("","",false,
            silentSessionExpiry: silentSessionExpiry);
        await _offlineService.cacheRecruiters(recruiters);
        if (kDebugMode) {
          debugPrint('✅ Cached ${recruiters.length} recruiters');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Failed to cache recruiters: $e');
        }
      }
      
      // 3. For each campaign, get all sections and questions
      int totalSections = 0;
      int totalQuestions = 0;
      
      for (final campaign in campaigns) {
        try {
          // Get all sections for this campaign
          final sections = await getSections(
              campaignUuid: campaign.uuid,
              silentSessionExpiry: silentSessionExpiry);
          totalSections += sections.length;
          if (kDebugMode) {
            debugPrint(
                '  📋 Campaign "${campaign.name}": ${sections.length} sections');
          }
          
          // For each section, get all questions
          for (final section in sections) {
            try {
              final questions = await getQuestions(
                campaignUuid: campaign.uuid,
                sectionUuid: section.uuid,
                silentSessionExpiry: silentSessionExpiry,
              );
              totalQuestions += questions.length;
              
              // Check if this section needs product lists (ISP/record sales)
              if (['isp', 'record sales'].contains(section.name.toLowerCase())) {
                // Try to pre-load common product types if questions mention them
                for (final question in questions) {
                  if (question.question.toLowerCase().contains('product type')) {
                    // Extract product types from options if available
                    final options = question.options;
                    if (options.isNotEmpty) {
                      final productTypes = options.split(',');
                      for (final type in productTypes) {
                        try {
                          final trimmedType = type.trim();
                          if (trimmedType.isNotEmpty) {
                            final from = campaign.name.toLowerCase() == 'isp'
                                ? 'isp'
                                : 'mechanic';
                            await getProductList(trimmedType, from);
                          }
                        } catch (e) {
                          // Skip if product list fails
                        }
                      }
                    }
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint(
                    '    ⚠️ Failed to load questions for section "${section.name}": $e');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                '  ⚠️ Failed to load sections for campaign "${campaign.name}": $e');
          }
        }
      }
      
      if (kDebugMode) {
        debugPrint(
            '✅ Pre-sync completed: $totalSections sections, $totalQuestions questions cached');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Pre-sync failed: $e');
      }
      rethrow;
    }
  }
}
