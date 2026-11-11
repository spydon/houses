# Abrahamsbergsvägen 18

Sun and shade in the backyard at Abrahamsbergsvägen 18 in Högmora, Huddinge
(property Högmora 4:112).

The page shows a satellite image of the lot with the shade drawn on top for any
day of the year and any time of day. Tap the image to check a spot, or pick one
of the preset spots: the pool, the terrace along the house and the west deck.

## Results

Direct sun on the 15th of each month, in Swedish time, seen from 1 meter above
the ground:

| Month     | Sunrise | Sunset | Pool                                                                       | Terrace by the house                                                       | West deck                                  |
| --------- | ------- | ------ | -------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------ |
| January   | 08:31   | 15:23  | none                                                                       | none                                                                       | none                                       |
| February  | 07:25   | 16:40  | none                                                                       | none                                                                       | none                                       |
| March     | 06:06   | 17:49  | 08:07 to 08:17 (0.2 hours)                                                 | 08:44 to 08:55 (0.3 hours)                                                 | 08:26 to 08:51, 09:53 to 10:14 (1.0 hours) |
| April     | 05:35   | 20:02  | 07:46 to 11:10 (3.4 hours)                                                 | 09:55 to 12:10 (2.3 hours)                                                 | 08:18 to 12:03, 15:12 to 15:31 (4.1 hours) |
| May       | 04:17   | 21:13  | 07:13 to 12:08 (4.9 hours)                                                 | 10:03 to 13:13, 13:38 to 13:48, 17:50 to 18:00 (3.6 hours)                 | 07:45 to 13:09, 14:19 to 16:35 (7.8 hours) |
| June      | 03:34   | 22:03  | 06:43 to 12:31, 18:02 to 18:16 (6.1 hours)                                 | 10:09 to 14:23, 16:50 to 18:03 (5.5 hours)                                 | 07:31 to 13:18, 13:56 to 17:22 (9.3 hours) |
| July      | 04:00   | 21:47  | 07:05 to 12:31, 18:14 to 18:25 (5.7 hours)                                 | 10:11 to 13:31, 13:45 to 14:01, 14:14 to 14:30, 17:01 to 18:07 (5.0 hours) | 07:38 to 13:24, 14:18 to 17:26 (8.9 hours) |
| August    | 05:07   | 20:36  | 07:39 to 11:30 (3.9 hours)                                                 | 10:05 to 12:36 (2.6 hours)                                                 | 08:11 to 12:41, 15:09 to 15:42 (5.0 hours) |
| September | 06:18   | 19:07  | 07:50 to 08:03, 08:55 to 09:22, 10:03 to 10:13, 10:34 to 10:54 (1.5 hours) | 09:39 to 10:00, 10:41 to 11:56 (1.6 hours)                                 | 08:37 to 11:07 (2.5 hours)                 |
| October   | 07:27   | 17:40  | none                                                                       | none                                                                       | none                                       |
| November  | 07:43   | 15:22  | none                                                                       | none                                                                       | none                                       |
| December  | 08:40   | 14:46  | none                                                                       | none                                                                       | none                                       |

The forest on the ridge south and southwest of the lot is the main obstacle.
Its trees are 16 to 25 meters tall and stand 8 to 16 meters from the pool, so
from the pool they block everything between south and west up to about 55 to
65 degrees above the horizon. The sun in Stockholm never climbs higher than
54 degrees, so the backyard gets its sun in the morning and around midday
from April to September and no direct sun at all from October to February.
The house blocks the early morning sun from the east and northeast up to
about 20 degrees.

## Data

| Source                                                                               | Used for                                 |
| ------------------------------------------------------------------------------------ | ---------------------------------------- |
| Lantmäteriet 1 meter elevation model, through Mapterhorn terrain tiles               | Ground height                            |
| Skogsstyrelsen tree height map, laser scanned on 26 March 2020                       | Tree heights, plus 1.5 meters of growth  |
| Lantmäteriet orthophoto and the satellite image in `assets/backyard.jpg`             | Cleared areas, buildings, georeferencing |
| Solar position algorithm from the US National Oceanic and Atmospheric Administration | Sun position                             |

Trees that stood where the house, the pool and the neighbor's house are today
have been removed from the 2020 scan. The house is modeled as a 7.5 meter block,
the neighboring houses as 6.5 to 7.5 meter blocks and the roofed patio south of
the pool as 2.8 meters.

## Regenerating the data

The scripts in `tool` rebuild `assets/surface_model.json` with Python 3.12,
numpy, rasterio, pyproj, pillow, requests, inflate64, imagecodecs, matplotlib
and opencv. Run them in order from the `tool` directory. Put the satellite
image in `tool/input/backyard.png` and the cover photo in
`tool/input/cover.png` first. Step 3 streams the 6.5 gigabyte tree height file for
Stockholm county and keeps only the rows around the house, which takes about
eight minutes.
