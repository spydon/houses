import 'package:sun_study/sun_study.dart';

const study = SunStudy(
  title: 'Kästavägen 6',
  area: 'Glömsta, Huddinge',
  package: 'kastavagen_6',
  notes: [
    'The sun position uses the solar position algorithm from the US National '
        'Oceanic and Atmospheric Administration for 59.232° north, 17.939° east, '
        'in Swedish time with summer time.',
    'Ground heights come from the Lantmäteriet 1 meter elevation model.',
    'Tree and hedge heights come from the Swedish Forest Agency tree height '
        'map, measured by airborne laser scanning on 26 March 2020. Every tree '
        'taller than 5 meters is raised by 1.5 meters for six seasons of growth.',
    'Bushes the 2020 scan found where the lawn is now are removed.',
    'Buildings are blocks, and pitched roofs step up from the eaves to the '
        'ridge. The heights of the neighboring buildings come from the 2020 '
        'laser scan.',
    'The house was built in 2021, after the scan, so its height is an '
        'estimate from its shadow in the aerial photo: 5.5 meters to the eaves '
        'and 7.5 meters to the ridge.',
    'The aerial photo is the latest Lantmäteriet orthophoto, brightened so '
        'the shade is easier to read.',
    'A spot counts as sunny when the sun is visible from 1 meter above the '
        'ground, about the eye height of someone sitting down.',
    'Tree crowns are treated as solid. Leafless deciduous trees let some light '
        'through from October to May, so those months can be a little brighter '
        'than shown.',
  ],
  credits: 'Aerial photo and elevation data © Lantmäteriet. Tree heights © Skogsstyrelsen. Building outlines © OpenStreetMap contributors.',
);
