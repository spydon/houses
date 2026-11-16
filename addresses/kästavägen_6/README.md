# Kästavägen 6

Sun and shade in the garden at Kästavägen 6 in Glömsta, Huddinge.

The page shows the latest Lantmäteriet aerial photo of the lot, brightened, with
the shade drawn on top for any day of the year and any time of day. Tap the
image to check a spot, or pick one of the preset spots: the deck in the corner
on the west side of the house, the middle of the lawn and the north end of the
lawn.

## Results

Direct sun on the 15th of each month, in Swedish time, seen from 1 meter above
the ground:

| Month     | Sunrise | Sunset | Terrace west of the house                                  | Middle of the lawn                                          | North end of the lawn                                      |
| --------- | ------- | ------ | ---------------------------------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| January   | 08:32   | 15:24  | 11:01 to 11:39, 13:56 to 14:22 (1.1 hours)                 | 11:59 to 13:12 (1.4 hours)                                  | 09:56 to 10:54, 12:44 to 13:56 (2.2 hours)                 |
| February  | 07:25   | 16:40  | 11:09 to 11:46, 13:51 to 14:50 (1.7 hours)                 | 09:34 to 10:06, 12:03 to 13:12 (1.7 hours)                  | 09:49 to 11:04, 12:39 to 14:05 (2.7 hours)                 |
| March     | 06:06   | 17:49  | 11:09 to 11:45, 13:34 to 15:22 (2.4 hours)                 | 09:05 to 10:12, 11:47 to 13:15, 14:19 to 15:17 (3.7 hours)  | 08:46 to 11:38, 12:08 to 15:29, 15:40 to 15:53 (6.5 hours) |
| April     | 05:36   | 20:02  | 10:06 to 13:38, 13:52 to 18:08 (7.8 hours)                 | 09:15 to 11:48, 11:57 to 14:26, 14:33 to 17:46 (8.3 hours)  | 08:37 to 08:58, 09:43 to 17:43, 17:57 to 18:32 (9.0 hours) |
| May       | 04:18   | 21:13  | 09:37 to 19:04, 19:17 to 19:30, 20:01 to 20:15 (9.9 hours) | 07:32 to 18:57 (11.6 hours)                                 | 07:22 to 07:38, 07:58 to 19:22 (11.7 hours)                |
| June      | 03:35   | 22:03  | 09:29 to 20:49 (11.3 hours)                                | 06:51 to 07:09, 07:22 to 19:37, 19:57 to 20:35 (13.2 hours) | 06:47 to 19:34 (12.8 hours)                                |
| July      | 04:00   | 21:47  | 09:38 to 19:43, 19:57 to 20:26 (10.7 hours)                | 07:35 to 19:13, 19:22 to 19:36 (12.0 hours)                 | 06:56 to 07:21, 07:27 to 19:38 (12.6 hours)                |
| August    | 05:07   | 20:37  | 09:51 to 18:21, 18:27 to 19:06 (9.2 hours)                 | 08:16 to 08:39, 09:19 to 17:45, 18:39 to 18:56 (9.4 hours)  | 08:32 to 18:59 (10.5 hours)                                |
| September | 06:18   | 19:08  | 11:57 to 12:33, 14:11 to 16:07, 16:44 to 17:10 (3.1 hours) | 09:06 to 11:04, 12:26 to 14:01, 14:43 to 16:42 (5.8 hours)  | 09:37 to 17:00, 17:04 to 17:29 (7.8 hours)                 |
| October   | 07:27   | 17:40  | 11:43 to 12:18, 14:18 to 15:47 (2.1 hours)                 | 10:00 to 10:42, 12:35 to 13:41 (1.8 hours)                  | 10:06 to 11:39, 13:03 to 14:34 (3.1 hours)                 |
| November  | 07:43   | 15:22  | 10:37 to 11:15, 13:28 to 14:21 (1.6 hours)                 | 09:14 to 09:29, 11:34 to 12:46 (1.5 hours)                  | 09:26 to 10:31, 12:17 to 13:29 (2.3 hours)                 |
| December  | 08:40   | 14:47  | 10:45 to 11:24 (0.7 hours)                                 | 11:45 to 12:59 (1.3 hours)                                  | 09:45 to 10:38, 12:31 to 13:32 (2.1 hours)                 |

The lawn lies west of the house and opens towards the southwest, where the
horizon is only 10 to 17 degrees. From May to August the middle and the north
end of the lawn have sun from about half past seven in the morning until seven
or half past seven in the evening, when the trees and buildings to the west
take it. The deck sits in the corner between the main part of the house and its
southwest part, so the house holds back the sun until about half past nine,
but the deck keeps it until almost nine in the evening in June. From October
to February the sun comes through gaps between the trees south of the lot for
an hour or two a day, and the north end of the lawn, furthest from those
trees, gets the most.

## Data

| Source                                                                               | Used for                                              |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------- |
| Lantmäteriet 1 meter elevation model, through Mapterhorn terrain tiles               | Ground height                                         |
| Skogsstyrelsen tree height map, laser scanned on 26 March 2020                       | Tree and hedge heights, roof heights of the neighbors |
| Latest Lantmäteriet orthophoto, in `assets/backyard.jpg`                             | Background, outline and height of the house           |
| OpenStreetMap building outlines                                                      | Neighboring buildings                                 |
| Solar position algorithm from the US National Oceanic and Atmospheric Administration | Sun position                                          |

The house was built in 2021, after the laser scan, so its outline is traced
from the aerial photo and its height is an estimate from its shadow, compared
with the shadows of neighboring buildings that the scan measured. The main part
of the house is modeled with 5.5 meter eaves and a 7.5 meter ridge, and the
southwest part as 5.5 meters. The scan found bushes up to 2.5 meters tall where
the lawn is now, so they are removed. Trees taller than 5 meters are raised by
1.5 meters for growth since 2020. The building outlines and heights are in
`tool/buildings.json`, the preset spots in `tool/spots.json` and the other
settings in `tool/site.json`.

## Regenerating the data

Run the shared scripts in `packages/sun_study/tool/` with this directory as
the argument, as described in the README at the root of the repository.
