class University {
  final String name;
  final double lat;
  final double lng;

  University({required this.name, required this.lat, required this.lng});

  static List<University> getSampleUniversities() {
    return [
      University(name: "Universidad Nacional", lat: 4.638193, lng: -74.084046),
      University(name: "Universidad de los Andes", lat: 4.602844, lng: -74.065526),
      University(name: "Pontificia Universidad Javeriana", lat: 4.627903, lng: -74.064813),
      University(name: "Universidad del Rosario", lat: 4.601046, lng: -74.066379),
      University(name: "Universidad de la Sabana", lat: 4.861578, lng: -74.032536),
    ];
  }
}
