import 'package:abrahamsbergsvagen_18/abrahamsbergsvagen_18.dart'
    as abrahamsbergsvagen_18;
import 'package:berganasvagen_18b/berganasvagen_18b.dart' as berganasvagen_18b;
import 'package:flutter/widgets.dart';
import 'package:sun_study/sun_study.dart';

class Address {
  const Address({
    required this.study,
    required this.description,
    required this.path,
  });

  final SunStudy study;
  final String description;
  final String path;

  String get title => study.title;
  String get area => study.area;
  ImageProvider get cover => study.cover;
}

const addresses = [
  Address(
    study: abrahamsbergsvagen_18.study,
    description: 'Sun and shade by the pool and on the decks, hour by hour through the year.',
    path: '/abrahamsbergsvagen-18',
  ),
  Address(
    study: berganasvagen_18b.study,
    description: 'Sun and shade by the pool and on the terrace, hour by hour through the year.',
    path: '/berganasvagen-18b',
  ),
];
