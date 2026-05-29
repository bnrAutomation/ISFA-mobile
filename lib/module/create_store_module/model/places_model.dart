import 'dart:convert';

PlacesModel placesModelFromJson(String str) =>
    PlacesModel.fromJson(json.decode(str));
    
    
class PlacesModel {
  List<dynamic>? htmlAttributions;
  List<Result>? results;
  String? status;

  PlacesModel({
    this.htmlAttributions,
    this.results,
    this.status,
  });

  factory PlacesModel.fromJson(Map<String, dynamic> json) => PlacesModel(
        htmlAttributions:
            List<dynamic>.from(json["html_attributions"].map((x) => x)),
        results: json["results"] == null
            ? []
            : List<Result>.from((json["results"]??[]).map((x) => Result.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "html_attributions":
            List<dynamic>.from(htmlAttributions!.map((x) => x)),
        "results": List<dynamic>.from(results!.map((x) => x.toJson())),
        "status": status,
      };
}

class Result {
  String? businessStatus;
  String? formattedAddress;
  Geometry? geometry;
  String? icon;
  String? iconBackgroundColor;
  String? iconMaskBaseUri;
  String? name;

  // List<Photo>? photos;
  String? placeId;

  double? rating;
  String? reference;
  List<String>? types;
  int? userRatingsTotal;

  Result({
    this.businessStatus,
    this.formattedAddress,
    this.geometry,
    this.icon,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    this.name,
    // this.photos,
    this.placeId,
    this.rating,
    this.reference,
    this.types,
    this.userRatingsTotal,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        businessStatus: json["business_status"],
        formattedAddress: json["formatted_address"],
        geometry: json["geometry"] == null
            ? null
            : Geometry.fromJson(json["geometry"]),
        icon: json["icon"],
        iconBackgroundColor: json["icon_background_color"],
        iconMaskBaseUri: json["icon_mask_base_uri"],
        name: json["name"],
        // photos: json["photos"] == null
        //     ? []
        //     : List<Photo>.from(json["photos"].map((x) => Photo.fromJson(x))),
        placeId: json["place_id"],
        rating: json["rating"] == null ? 0.0 : json["rating"].toDouble(),
        reference: json["reference"],
        types: List<String>.from(json["types"].map((x) => x)),
        userRatingsTotal: json["user_ratings_total"],
      );

  Map<String, dynamic> toJson() => {
        "business_status": businessStatus,
        "formatted_address": formattedAddress,
        "geometry": geometry?.toJson(),
        "icon": icon,
        "icon_background_color": iconBackgroundColor,
        "icon_mask_base_uri": iconMaskBaseUri,
        "name": name,
      //  "photos": List<dynamic>.from(photos!.map((x) => x.toJson())),
        "place_id": placeId,
        "rating": rating,
        "reference": reference,
        "types": List<dynamic>.from(types!.map((x) => x)),
        "user_ratings_total": userRatingsTotal,
      };
}


class Geometry {
  Locations? location;
  Viewport? viewport;

  Geometry({
    this.location,
    this.viewport,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        location: Locations.fromJson(json["location"]),
        viewport: Viewport.fromJson(json["viewport"]),
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "viewport": viewport?.toJson(),
      };
}

class Locations {
  double? lat;
  double? lng;

  Locations({
    this.lat,
    this.lng,
  });

  factory Locations.fromJson(Map<String, dynamic> json) => Locations(
        lat: json["lat"].toDouble(),
        lng: json["lng"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Viewport {
  Locations? northeast;
  Locations? southwest;

  Viewport({
    this.northeast,
    this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
        northeast: Locations.fromJson(json["northeast"]),
        southwest: Locations.fromJson(json["southwest"]),
      );

  Map<String, dynamic> toJson() => {
        "northeast": northeast?.toJson(),
        "southwest": southwest?.toJson(),
      };
}
