# Results

Scored in an Octave port of Warp Factory, upstream commit `03b10cb`. Date of the clean log: 2026-10-28. Pin AEB2AD.

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

A larger Fuchs-type shell in this same port, 50–110 m at compactness 1/3, fails at 0.10c with null ratio 1.11. The 0.10c pass is the condensate shell, not that smaller hull.

The mass here is about 1.66 solar masses, about 1,740 Jupiter masses. Fuchs's published mass is about 2.37 Jupiter masses. Both are the positive mass of the shell in the metric. Neither run is a built device, and neither is faster than light.

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
