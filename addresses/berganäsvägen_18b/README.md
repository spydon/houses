# Berganäsvägen 18B

Sun and shade by the pool at Berganäsvägen 18B in Persudde, Trollbäcken, Tyresö.

The page shows the Lantmäteriet aerial photo of the lot, flown in 2025 and
brightened, with the shade drawn on top for any day of the year and any time of
day. Tap the image to check a spot, or pick one of the preset spots: the pool,
the terrace between the pool and the house and the west end of the pool deck.

## Results

Direct sun on the 15th of each month, in Swedish time, seen from 1 meter above
the ground:

| Month     | Sunrise | Sunset | Pool                                                                       | Terrace by the house                                       | West end of the pool                       |
| --------- | ------- | ------ | -------------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------ |
| January   | 08:31   | 15:23  | none                                                                       | none                                                       | 10:26 to 11:05, 11:17 to 11:34 (1.0 hours) |
| February  | 07:24   | 16:39  | 12:03 to 14:19 (2.3 hours)                                                 | 11:54 to 14:56, 15:12 to 15:33 (3.6 hours)                 | 09:02 to 12:44 (3.7 hours)                 |
| March     | 06:05   | 17:48  | 08:32 to 16:29 (8.0 hours)                                                 | 09:40 to 10:14, 11:48 to 16:59 (5.8 hours)                 | 08:02 to 12:50 (4.8 hours)                 |
| April     | 05:35   | 20:01  | 07:04 to 07:14, 07:42 to 07:57, 09:17 to 18:49 (10.0 hours)                | 10:27 to 11:18, 11:27 to 11:42, 12:08 to 18:12 (7.3 hours) | 07:34 to 13:53 (6.3 hours)                 |
| May       | 04:17   | 21:12  | 07:12 to 08:21, 08:27 to 18:26 (11.2 hours)                                | 10:04 to 19:30 (9.4 hours)                                 | 06:38 to 14:22 (7.8 hours)                 |
| June      | 03:34   | 22:02  | 06:48 to 18:41, 19:37 to 19:54, 20:09 to 20:29 (12.6 hours)                | 09:59 to 19:43, 20:04 to 20:21 (10.1 hours)                | 06:11 to 14:20 (8.2 hours)                 |
| July      | 03:59   | 21:46  | 07:22 to 18:41 (11.5 hours)                                                | 10:08 to 19:49 (9.7 hours)                                 | 06:29 to 14:28 (8.0 hours)                 |
| August    | 05:06   | 20:36  | 07:18 to 08:13, 09:09 to 18:46 (10.6 hours)                                | 10:23 to 18:19, 18:57 to 19:16 (8.3 hours)                 | 07:17 to 14:08 (6.9 hours)                 |
| September | 06:17   | 19:07  | 09:00 to 17:55 (8.9 hours)                                                 | 10:32 to 11:06, 12:33 to 18:12 (6.2 hours)                 | 07:48 to 08:11, 08:47 to 13:36 (5.2 hours) |
| October   | 07:26   | 17:39  | 11:06 to 11:31, 12:32 to 14:54, 15:13 to 15:54, 16:03 to 16:16 (3.8 hours) | 10:25 to 10:35, 12:25 to 16:05, 16:09 to 16:46 (4.5 hours) | 08:59 to 13:15 (4.3 hours)                 |
| November  | 07:42   | 15:21  | none                                                                       | 13:18 to 14:04 (0.8 hours)                                 | 09:59 to 12:03 (2.1 hours)                 |
| December  | 08:39   | 14:46  | none                                                                       | none                                                       | none                                       |

The pool is open to the south. The horizon there is set by the hedge 3 to 4
meters south of the pool, which stands below the retaining wall and reaches
about 20 degrees above the horizon. The house south of the pool only reaches
about 15 degrees. The sun in Stockholm climbs to 54 degrees in June, so from
May to August the pool has sun from about seven in the morning until the trees
and hedges to the west and northwest take it at about a quarter to seven in
the evening. In April and September the morning sun comes in so low from the
east that the house and the bushes south of the terrace hold it back until
about nine. From November to January the sun stays below the hedge all day.

The terrace by the house gets its sun later in the morning, when the sun has
moved past the main part of the house, and keeps it about an hour longer in
the evening. The west end of the pool deck is the opposite: it has the sun
from early morning but loses it in the early afternoon behind the tall hedge
along the road.

## Data

| Source                                                                               | Used for                                          |
| ------------------------------------------------------------------------------------ | ------------------------------------------------- |
| Lantmäteriet 1 meter elevation model, through Mapterhorn terrain tiles               | Ground height                                     |
| Skogsstyrelsen tree height map, laser scanned on 26 March 2020                       | Tree and hedge heights, roof heights of the house |
| Lantmäteriet orthophoto from 2025, in `assets/backyard.jpg`                          | Background, building outlines                     |
| OpenStreetMap building outlines                                                      | Neighboring buildings                             |
| Solar position algorithm from the US National Oceanic and Atmospheric Administration | Sun position                                      |

The 2020 laser scan also measured the roofs, so the heights of the house and
the older neighboring buildings come from it. The main part of the house is
modeled with 6 meter eaves and an 8.8 meter ridge, and the flat roofed west
part and the wing towards the pool as 3.5 meters. The house south of the pool
was built after the scan, so its 4.5 meter eaves and 7.5 meter ridge are an
estimate. Pitched roofs step up from the eaves to the ridge in four steps.
Trees taller than 5 meters are raised by 1.5 meters for growth since 2020. The
building outlines and heights are in `tool/buildings.json` and the preset spots
in `tool/spots.json`.

## Regenerating the data

The scripts in `tool` rebuild `assets/surface_model.json` with Python 3.12,
numpy, rasterio, pyproj, pillow, requests, matplotlib, inflate64
and imagecodecs. Run them in order from the `tool` directory. Step 3 streams
the 6.5 gigabyte tree height file for Stockholm county and keeps only the rows
around the house, which takes about eight minutes. Step 8 also crops the cover
image from the aerial photo.
