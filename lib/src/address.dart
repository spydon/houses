import 'package:abrahamsbergsvagen_18/abrahamsbergsvagen_18.dart'
    as abrahamsbergsvagen_18;
import 'package:flutter/widgets.dart';

class Address {
  const Address({
    required this.title,
    required this.area,
    required this.description,
    required this.path,
    required this.cover,
    required this.page,
  });

  final String title;
  final String area;
  final String description;
  final String path;
  final ImageProvider cover;
  final Widget page;
}

const addresses = [
  Address(
    title: abrahamsbergsvagen_18.title,
    area: abrahamsbergsvagen_18.area,
    description: 'Sun and shade by the pool and on the decks, hour by hour through the year.',
    path: '/abrahamsbergsvagen-18',
    cover: abrahamsbergsvagen_18.cover,
    page: abrahamsbergsvagen_18.SunPage(),
  ),
];
