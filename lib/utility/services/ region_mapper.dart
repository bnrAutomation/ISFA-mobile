// lib/utils/region_mapper.dart

enum Region {
  north,
  south,
  east,
  west,
  center,
  northEast,
  northWest,
  southEast,
  southWest,
}

class RegionMapper {
  // India's bounding box
  static const double minLat = 8.0;
  static const double maxLat = 37.0;
  static const double minLng = 68.0;
  static const double maxLng = 97.0;

  /// Returns the Region enum for a given lat/lng
  static Region getRegion(double lat, double lng) {
    final latRatio = (lat - minLat) / (maxLat - minLat);
    final lngRatio = (lng - minLng) / (maxLng - minLng);

    final isNorth = latRatio > 0.66;
    final isSouth = latRatio < 0.33;
    final isEast = lngRatio > 0.66;
    final isWest = lngRatio < 0.33;

    if (isNorth && isEast) return Region.northEast;
    if (isNorth && isWest) return Region.northWest;
    if (isSouth && isEast) return Region.southEast;
    if (isSouth && isWest) return Region.southWest;
    if (isNorth) return Region.north;
    if (isSouth) return Region.south;
    if (isEast) return Region.east;
    if (isWest) return Region.west;
    return Region.center;
  }

  /// Returns a human-readable name for the region
  static String getRegionName(double lat, double lng) {
    final region = getRegion(lat, lng);
    return regionToString(region);
  }

  static String regionToString(Region region) {
    switch (region) {
      case Region.north:
        return 'North';
      case Region.south:
        return 'South';
      case Region.east:
        return 'East';
      case Region.west:
        return 'West';
      case Region.center:
        return 'Center';
      case Region.northEast:
        return 'North East';
      case Region.northWest:
        return 'North West';
      case Region.southEast:
        return 'South East';
      case Region.southWest:
        return 'South West';
    }
  }
}