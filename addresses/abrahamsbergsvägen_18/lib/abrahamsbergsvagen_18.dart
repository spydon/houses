import 'package:sun_study/sun_study.dart';

const study = SunStudy(
  title: 'Abrahamsbergsvägen 18',
  area: 'Högmora, Huddinge',
  package: 'abrahamsbergsvagen_18',
  notes: [
    'The sun position uses the solar position algorithm from the US National '
        'Oceanic and Atmospheric Administration for 59.236° north, 18.041° east, '
        'in Swedish time with summer time.',
    'Ground heights come from the Lantmäteriet 1 meter elevation model.',
    'Tree heights come from the Swedish Forest Agency tree height map, measured '
        'by airborne laser scanning on 26 March 2020. Every tree is raised by '
        '1.5 meters for six seasons of growth, and the trees that were cut for '
        'the house, the pool and the neighbor\'s house are removed.',
    'Buildings are simple blocks: the house is 7.5 meters tall, the neighboring '
        'houses 6.5 to 7.5 meters and the roofed patio south of the pool 2.8 meters.',
    'The aerial photo is the Lantmäteriet orthophoto from 2025, brightened so '
        'the shade is easier to read.',
    'A spot counts as sunny when the sun is visible from 1 meter above the '
        'ground, about the eye height of someone sitting down.',
    'The climbing net hangs from the roof edge of the house, 6.6 meters up, '
        'to two 4 meter poles on the far side of the pool. It is checked 1 '
        'meter above the middle of the net instead of 1 meter above the ground.',
    'Tree crowns are treated as solid. Leafless deciduous trees let some light '
        'through from October to May, so those months can be a little brighter '
        'than shown.',
  ],
  credits: 'Aerial photo and elevation data © Lantmäteriet. Tree heights © Skogsstyrelsen.',
);
