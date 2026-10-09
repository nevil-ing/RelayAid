class MapConfiguration {
  const MapConfiguration({
    this.tileUrl = const String.fromEnvironment(
      'MAP_TILE_URL',
      defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),
    this.attribution = const String.fromEnvironment(
      'MAP_TILE_ATTRIBUTION',
      defaultValue: 'OpenStreetMap contributors',
    ),
    this.attributionUrl = const String.fromEnvironment(
      'MAP_TILE_ATTRIBUTION_URL',
      defaultValue: 'https://www.openstreetmap.org/copyright',
    ),
  });

  final String tileUrl;
  final String attribution;
  final String attributionUrl;
  static const userAgent = 'com.nevilingutu.relayaid';
}
