
class Station {
  final String name;
  final double lat;
  final double lng;

  Station({required this.name, required this.lat, required this.lng});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Station &&
              runtimeType == other.runtimeType &&
              name.toLowerCase() == other.name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}