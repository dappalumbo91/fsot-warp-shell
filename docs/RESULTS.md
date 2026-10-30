# Results

Scored in an Octave port of Warp Factory, upstream commit `03b10cb`. Date of the clean log: 2026-10-28. Pin AEB2AD.

The published positive-mass pass is 0.02c. This condensate shell is clean at 0.10c on the 166.8 m grid. The 83.4 m grid is clean at the same speed after cells inside the flat ball are restored to zero stress-energy. The 0.11c join fails in the outer wall. At the published 20 m outer radius the FSOT wall is also clean at 0.10c when the compactness is 1/2.

## Clean point

Grid spacing 166.790 m. Log `data/dial_mix.txt`.

| | 0.10c | 0.095c |
| --- | ---: | ---: |
| Null worst/peak | 6.534×10⁻⁴ | 6.459×10⁻⁴ |
| Weak | 7.887×10⁻⁴ | 7.856×10⁻⁴ |
| Strong | 6.558×10⁻⁴ | 6.488×10⁻⁴ |
| Dominant | 6.822×10⁻⁶ | 6.830×10⁻⁶ |
| Serious fraction | 0 | 0 |
| Energy | 4.0651×10³⁰ kg | 4.0664×10³⁰ kg |
| Shift | 0.100 | 0.095 |
| Verdict | CLEAN | CLEAN |

The 0.10c tight cell for the null, weak, and strong ratios is the cavity stencil at r = 117.94 m. The dominant ratio's worst cell is in the exterior at r = 12,993 m. On the printed side ray from 4.25 km to 8.92 km, every dominant ratio is 0. The shift at the center is 0.10c. `S(0) = 1` and `S(R2) = 0`.

## The edge at 0.11c

Same shell, same join, same grid. Log `data/dial_mix_11.txt`.

| | 0.11c |
| --- | ---: |
| Null, weak, and strong | 3.398×10⁻² at r = 7766.92 m |
| Dominant | 0.1746 at r = 7759.76 m |
| Serious fraction | 0.0119 |
| Energy | 4.0623×10³⁰ kg |
| Shift | 0.110 |
| Verdict | FAIL |

The break is in the outer wall, about 88° off the boost axis.

## Against the published Warp Factory pass

Fuchs, Helmerich, Bobrick, Sellers, Melcher, and Martire, Class. Quantum Grav. 41 (2024) 095013, arXiv:2405.02709. Their published positive-mass pass is a 10–20 m shell, mass 4.49×10²⁷ kg, compactness 1/3, shift 0.02c. This port reproduces that point as its W1 example.

| | Published pass | This shell |
| --- | ---: | ---: |
| Cavity / outer radius | 10 m / 20 m | 1,399.567 m / 9,811.159 m |
| Mass | 4.49×10²⁷ kg | 3.303043×10³⁰ kg |
| Unsmoothed density | 1.531×10²³ kg/m³ | 8.374×10¹⁷ kg/m³ |
| Clean speed | 0.02c | 0.10c |
| Radius ratio | 1 | 491 |
| Mass ratio | 1 | 736 |
| Density ratio | 1.83×10⁵ | 1 |
| Speed ratio | 1 | 5 |

A larger Fuchs-type shell in this same port, 50–110 m at compactness 1/3, fails at 0.10c with null ratio 1.11. The condensate 0.10c pass is the 9.81 km body. The 20 m scores below use the same join on a smaller radius, and the density rises with that shrink.

## At the published outer radius

Log `data/dial_fuchs_size.txt`. Outer radius 20 m. The FSOT wall has inner radius 2.85 m. Mass is compactness times R2·c²/(2G), with Warp Factory's c and G. The grid keeps the fraction used on the 110 m article, spacing 0.455 m.

| Compactness | Mass | Speed | Result |
| --- | ---: | ---: | --- |
| 1/3 | 4.489×10²⁷ kg | 0.06c | clean, dominant 1.70×10⁻⁵, energy 5.142×10²⁷ kg |
| 1/3 | 4.489×10²⁷ kg | 0.10c | fail, dominant 0.453 at 9.78 m |
| 1/2 | 6.733×10²⁷ kg | 0.10c | clean, null 1.07×10⁻⁵, weak 2.16×10⁻⁵, dominant 1.92×10⁻⁵, serious fraction 0, energy 8.287×10²⁷ kg, shift 0.10 |
| 1/2 | 6.733×10²⁷ kg | 0.11c | fail, dominant 0.177 at 15.70 m |

Compactness 1/3 is the published mass. The clean speed there is 0.06c. Compactness 1/2 is 1.5 times that mass, about 3.55 Jupiter masses, and it is clean at 0.10c. The wall volume is 3.34×10⁴ m³, so the density is 2.02×10²³ kg/m³, about 1.3 times the published density and about 2.4×10⁵ times the condensate. The 0.11c break is 0.785 of the radius, the same fraction as 7.72 km on the condensate body, and the dominant ratio is 0.177 on both.

## Lighter compactness, same wall

Logs `data/dial_mass_down.txt` and `data/dial_mass_down_16.txt`, dated 2026-10-29. Same mix, same builder lapse, same 20 m FSOT wall. The reference row is the compactness-1/2 shell above: mass 6.733×10²⁷ kg, density 2.015×10²³ kg/m³. Density falls in proportion to compactness. The smaller radius in the last column is that same compactness resized so the density matches the reference. It is not a second grid score. The ratios do not depend on the radius.

| Compactness | Mass at 20 m | Density / reference | 0.04c | 0.06c | Same density as the reference |
| --- | ---: | ---: | --- | --- | --- |
| 1/4 | 3.366×10²⁷ kg | 0.500 | clean, dominant 1.60×10⁻⁵, energy 3.737×10²⁷ kg | fail, dominant 0.224 at 15.72 m | 14.14 m, 2.380×10²⁷ kg |
| 1/5 | 2.693×10²⁷ kg | 0.400 | clean, dominant 1.54×10⁻⁵, energy 2.936×10²⁷ kg | fail, dominant 0.422 at 15.72 m | 12.65 m, 1.703×10²⁷ kg |
| 1/6 | 2.244×10²⁷ kg | 0.333 | fail, dominant 0.215 at 15.76 m | not scored | 11.55 m, 1.296×10²⁷ kg |

At compactness 1/5 and 0.04c the outer shoulder still has dominant margin +0.209 at 15.70 m, flux −0.465. At compactness 1/6 that shoulder is −0.209, flux −0.553, and the inner shoulder at 9.78 m is −0.131. One fifth is the light clean flat wall. The one-sixth mass is clean at 0.04c with the placement in the next sections. The 0.10c machine remains compactness 1/2. The 11.55 m resize on the failed flat row is the uniform density match. It is not a passing shell.

## One-sixth mass moved onto the slope

Same total mass, 2.244×10²⁷ kg, same mix, same outer radius. The flat wall fails where the shift slope is steep, so the mass was placed on that slope and returned to the same total. Peak density stays under the compactness-1/2 wall.

| Placement | Peak density / reference | 9.78 m | 15.70 m | Verdict |
| --- | ---: | ---: | ---: | --- |
| Flat wall | 0.333 | −0.131 | −0.209 | fail, dominant 0.215 at 15.76 m |
| Mass on the mix slope | 0.653 | +0.291 | +0.179 | fail, dominant 0.078 at 2.96 m |
| Wall plus the slope | 0.422 | +0.177 | −0.077 | fail, dominant 0.131 at 16.15 m |
| Larger of wall and slope | 0.504 | +0.149 | −0.143 | fail, dominant 0.197 at 16.15 m |

The slope placement clears both shoulders. At the inner edge the shift is still 0.995 and the density is 0.093 of peak, under a flux of 0.118. Putting wall density back under that edge, either by adding it to the slope or by taking the larger of the two profiles, reopens the outer shoulder before the edge reaches zero. Logs `data/dial_sixth_push.txt`, `data/dial_sixth_cover.txt`, and `data/dial_sixth_max.txt`.

## One-sixth mass across the bend window

Same total mass, 2.244×10²⁷ kg, same mix, same 20 m wall. Dated 2026-10-29.

The slope placement already carries a side notch at 16.5 m, dominant 0.031, 16 cells. The foot at 2.96 m is worse, 0.081, so the notch was not the reported cell. Joining the wall to the slope and smoothing afterward clears the foot and deepens the notch to 0.042. Log `data/dial_sixth_band.txt`.

Restoring the uniform wall only inside the crossing, and paying the excess from the negative-curvature side, clears the foot. The dominant ratio inside 8 m is 0. The notch remains at 16.67 m, dominant 0.028, the same absolute size as on the slope. Crossing 8.01 m, curvature flip 12.97 m, payment scale 0.952, peak density 0.649 of the half-compact wall. Log `data/dial_sixth_inner.txt`.

Holding the slope up to the straight chord from the steepest point, 12.97 m, out to the shell face clears the notch. At 16.5 m the dominant margin is +0.083. The steepest slope then fails, dominant 0.216 at 12.96 m, 38° off the boost. The chord at 19 m is 23 times the real slope, and the mass fraction outside 18 m rises from 0.071 to 0.146. Log `data/dial_sixth_chord.txt`.

The strongest bend is at 15.71 m. Curvature takes 2.74 m to climb from the steepest slope to that bend. The chord in the clean run covers only that same distance on the far side, out to 18.45 m, and the slope is followed again after that. The foot stays the wall. Payment scale 0.945. Peak density 1.264×10²³ kg/m³, 0.627 of the half-compact wall. Mass fractions: 0.056 inside 8 m, 0.322 from 8 m to 13 m, 0.538 from 13 m to 18 m, 0.084 outside 18 m.

| | Bend window |
| --- | ---: |
| Null | 6.79×10⁻⁵ at 23.92 m |
| Strong | 1.89×10⁻⁴ at 23.54 m |
| Dominant | 1.61×10⁻⁴ at 23.65 m |
| Serious fraction | 0 |
| Energy | 2.379×10²⁷ kg |
| Shift | 0.04 |
| Verdict | clean |

The side ray is positive through the wall: +0.055 at 2.85 m, +0.210 at 9.78 m, +0.454 at 12 m, +0.165 at 15.70 m, +0.071 at 17.52 m. At 16.5 m the side minimum is +0.042. Log `data/dial_sixth_bend.txt`.

At this fixed 20 m radius the shell is 1.182 Jupiter masses. The uniform one-fifth wall at the same radius is 1.419 Jupiter masses. The peak here is 0.627 of the half-compact density, above the uniform one-fifth density and under that ceiling. Resizing this shape so the peak equals the ceiling, same profile, gives an outer radius of 15.84 m and a mass of 1.777×10²⁷ kg, 0.936 Jupiter. That is a scale of the scored shell, not a second grid. The uniform one-fifth wall, resized so its own density equals the ceiling, remains 12.65 m and 0.897 Jupiter. The 0.10c shell remains compactness 1/2.

## Where that window stops

Same placement, dated 2026-10-30. Compactness 1/7 is mass 1.924×10²⁷ kg, 1.013 Jupiter, peak density 0.538 of the half-compact wall. The mass fractions match the one-sixth pass. The side from 16.0 m to 17.5 m is negative. Dominant 0.118 at 16.59 m, flux −0.249. The foot inside 8 m is negative again, worst 0.033. Log `data/dial_seventh_bend.txt`.

Drawing the chord to the shell face and applying it only inside the window raises the raw weight at 16.67 m from 1.26 to 1.75. The notch at 17.5 m comes back positive. The band at 16.5 m stays at −0.099. The worst cell moves to 8.84 m, dominant 0.122, and the side ray at 9.78 m is −0.070. Log `data/dial_seventh_clip.txt`.

The one-sixth window at 0.06c fails across the side. Dominant 0.222 at 16.14 m, null 0.102, serious fraction 0.076. The side ray is negative at 2.85 m, 9.78 m, and 15.70 m. The middle at 12 m stays at +0.376. Log `data/dial_sixth_bend_06.txt`.

The light clean shell remains the one-sixth bend window at 0.04c.

## Audit of the 20 m shell

Log `data/dial_audit_bar.txt`, dated 2026-10-29. Same mix, same N = 120 grid. A fresh 0.10c run at compactness 1/2 reproduces the line above: energy 8.2868×10²⁷ kg, dominant ratio 1.92×10⁻⁵ in the exterior at 26.47 m, shift 0.10, clean. With the shift off, compactness 1/2 is clean at energy 8.3144×10²⁷ kg, dominant 1.95×10⁻⁵, and compactness 1/3 is clean at energy 5.1495×10²⁷ kg, dominant 1.71×10⁻⁵. Both parked violations sit at 26.47 m. The smoothed density on this grid ends at 26.57 m. The check is written out in [AUDIT.md](AUDIT.md).

## What is left of the cabin

Log `data/dial_cabin_vacuum.txt`. Same mass smooth as the metric builder: four passes, span 7,160 samples, 3.29 m on this grid. The shift smooth is two passes of 1.84 m. No energy-condition score.

| Shell | Density first exceeds 0 | Density reaches 1% of the wall | Shift falls below 0.9999 | At the unsmoothed inner radius |
| --- | ---: | ---: | ---: | --- |
| FSOT wall, inner radius 2.85 m | 0.18 m | 0.42 m | 1.52 m, density already 21% | density 49% of the wall, shift 0.994 |
| Their cabin, inner radius 10 m | 3.43 m | 5.72 m | 8.47 m, density already 22% | density 50% of the wall, shift 0.978 |

On their cabin at 9.78 m the density is 46% of the wall and the shift is 0.985. That is the fringe whose dominant margin is +0.012 at the clean 0.04c point and −0.19 at 0.06c. The thick wall passes at 0.10c with half the wall density already on while the shift is still 0.994. The empty center does not grow unless the whole shell grows, and the mass grows with the radius.

## Their cabin

Log `data/dial_cabin_gap.txt`. Their empty cabin is half the outer radius. At compactness 1/3 that geometry fails at 0.04c. At compactness 1/2, R1 = 10 m, R2 = 20 m, mass 6.733×10²⁷ kg, the same mix is clean at 0.04c: null 1.11×10⁻⁵, weak 2.23×10⁻⁵, dominant 1.97×10⁻⁵, serious fraction 0, energy 8.160×10²⁷ kg, shift 0.04. At 0.06c it fails in the outer wall, dominant ratio 0.352 at 17.51 m, flux −0.608, radial stress 0.033. At 0.10c that cell is dominant 0.678.

The legacy cabin, R1 = 50 m at R2 = 110 m, is clean at 0.04c and fails at 0.06c, dominant ratio 0.248 at 94.8 m. Their cabin holds twice the published speed at this compactness. The 0.10c cabin on a 20 m ship remains the FSOT wall.

The condensate mass is about 1.66 solar masses, about 1,740 Jupiter masses. Fuchs's published mass is about 2.37 Jupiter masses. The 20 m compactness-1/2 mass is about 3.55 Jupiter masses. Each figure is the positive mass of that shell in the metric. Each run is a scored coast in the solver.

At 0.10c a coast from Earth to the Moon is about 13 seconds, and a coast to a close Mars is about half an hour. The metric is already at constant speed. It does not model the acceleration.

## Resolution stress

The profile is sampled at about 0.225 m and smoothed over about 450 m. Changing `N` changes the metric grid, not that profile. Log `data/dial_mix_fine.txt`, `N = 320`, spacing 83.395 m, same 0.10c mix. Runtime 200.5 s.

| | 83.4 m |
| --- | ---: |
| Null | 7.016×10⁻⁴ at r = 58.97 m, cavity |
| Weak | 1.476×10⁻³ at r = 58.97 m, cavity |
| Strong | 7.016×10⁻⁴ at the same cell |
| Dominant | 5.506×10⁻⁷ at r = 13,017 m, exterior |
| Serious fraction | 0.0000 |
| Energy | 4.0657×10³⁰ kg |
| Shift | 0.100 |
| Verdict | FAIL |

The weak ratio is the central cavity sample. The side ray from 4.21 km to 8.97 km still prints dominant ratio 0. The 166.8 m pass is the clean record. The 83.4 m grid does not meet the same bar. The two grids are drawn in `figures/resolution.png`.

## Origin samples

Log `data/dial_center.txt`. Same mix. The shift amplitude is 0 or 0.10. The only negative cavity cells are four diagonal samples at `r = h / √2`, 45° off the boost axis. `n` is the cell count in the bin. The weak column is the minimum weak ratio in that bin.

| Grid | Shift | Origin cells | Origin weak ratio | Next ring weak ratio | Wall weak ratio |
| --- | --- | ---: | ---: | ---: | ---: |
| 166.8 m | off | 4 | −7.515×10⁻⁴ | +1.309×10⁻² | +0.249 |
| 166.8 m | 0.10c | 4 | −7.887×10⁻⁴ | +9.651×10⁻³ | +0.0168 |
| 83.4 m | off | 4 | −1.481×10⁻³ | +4.047×10⁻⁴ | +0.249 |
| 83.4 m | 0.10c | 4 | −1.476×10⁻³ | +3.339×10⁻⁴ | +0.0155 |

Peak energy density is 7.526×10³⁴ J/m³ with the shift off and 7.621×10³⁴ J/m³ at 0.10c. With the shift off, the origin weak ratio equals the energy-density ratio, and that ratio times the sample radius is 0.0886 m at 118 m and 0.0873 m at 59 m. The campaign bar on the 83.4 m grid fails on those four samples in both shift settings. The figure is `figures/center.png`.

The mass smoother leaves an exterior skirt. Its worst weak ratio is −7.94×10⁻⁶ at 166.8 m and −4.06×10⁻⁷ at 83.4 m. Both sit far under the clean bar, and the fine grid makes the skirt smaller.

## Flat ball restored

Log `data/dial_flatball.txt`. The flat ball is r < 87.55 m. Cells inside it are set to stress-energy zero. Cells outside keep the Cartesian difference.

| Grid | Shift | Cells restored | Weak ratio after | Where the worst cell sits | Verdict |
| --- | --- | ---: | ---: | --- | --- |
| 166.8 m | off | 0 | 7.515×10⁻⁴ | r = 118 m, the raw center sample | CLEAN |
| 166.8 m | 0.10c | 0 | 7.887×10⁻⁴ | r = 118 m, the raw center sample | CLEAN |
| 83.4 m | off | 4 | 4.057×10⁻⁷ | r = 12,979 m, exterior skirt | CLEAN |
| 83.4 m | 0.10c | 4 | 4.006×10⁻⁷ | r = 12,979 m, exterior skirt | CLEAN |

The corrected 0.10c line on the 83.4 m grid is null 1.971×10⁻⁷, weak 4.006×10⁻⁷, strong 1.971×10⁻⁷, dominant 5.506×10⁻⁷, serious fraction 0, energy 4.0657×10³⁰ kg, shift 0.10. The dominant ratio is the same cell the raw score already reported in the exterior. The figure is `figures/flatball.png`.

The same restoration at 0.11c on the 166.8 m grid finds no cell inside the ball. The failure stays at r = 7,766.92 m, dominant ratio 0.1746, serious fraction 0.0119, energy 4.0623×10³⁰ kg. Log `data/dial_flatball_11.txt`.

On the 83.4 m grid the same 0.11c join restores the four flat-ball cells and still fails. Dominant ratio 0.177 at r = 7,719.54 m, null ratio 3.549×10⁻² at r = 7,727.65 m, serious fraction 0.0111, energy 4.0628×10³⁰ kg, shift 0.11. Log `data/dial_flatball_11_fine.txt`. The wall break is stable under the finer grid.
