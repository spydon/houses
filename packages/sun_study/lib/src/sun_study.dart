import 'package:flutter/widgets.dart';

class SunStudy {
  const SunStudy({
    required this.title,
    required this.area,
    required this.package,
    required this.notes,
    required this.credits,
  });

  final String title;
  final String area;
  final String package;
  final List<String> notes;
  final String credits;

  String get modelAssetKey => 'packages/$package/assets/surface_model.json';

  ImageProvider get cover => AssetImage('assets/cover.jpg', package: package);

  ImageProvider get photo =>
      AssetImage('assets/backyard.jpg', package: package);
}
