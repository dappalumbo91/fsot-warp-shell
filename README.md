# FSOT warp shell

**Author:** Damian Arthur Palumbo  
**License:** Apache-2.0  
**Pin:** FSOT 2.1 AEB2AD, from [FSOT-2.1-Lean](https://github.com/dappalumbo91/FSOT-2.1-Lean)

A constant-speed warp shell, scored in Warp Factory. On a 166.8 m grid the Eulerian energy conditions stay under the clean bar at **0.10c**. The published Warp Factory pass, Fuchs et al. 2024, is **0.02c** on a 10–20 m shell. This shell is 491 times larger in outer radius, 736 times heavier, and about 1.8×10⁵ times less dense.

The 83.4 m grid misses that bar. The miss is four samples at 59 m, the diagonal cells closest to the origin. With the shift removed, their weak ratio is 1.481×10⁻³. With the shift at 0.10c it is 1.476×10⁻³. One grid spacing farther out, the weak ratio is positive. The wall is quiet on both grids. This is a simulation of a coast at constant speed.

![Eulerian speeds](figures/speed_limit.png)

The green marks are under the clean bar. The red marks are over it. The top row is the published pass. The middle row is a larger copy of that kind of shell, scored in this port, which fails at 0.10c. The bottom row is the FSOT condensate shell: clean at 0.095c and 0.10c, failed at 0.11c.

## The shell

| | Published pass | This record |
| --- | ---: | ---: |
| Paper | Fuchs et al., Class. Quantum Grav. 41 (2024) 095013 | this repository |
| Radii | 10 m to 20 m | 1.40 km to 9.81 km |
| Mass | 4.49×10²⁷ kg | 3.303×10³⁰ kg (about 1.66 solar masses) |
| Density | 1.53×10²³ kg/m³ | 8.37×10¹⁷ kg/m³ |
| Clean speed | 0.02c | 0.10c on a 166.8 m grid |
| Finer grid |  | 83.4 m, four origin samples, weak ratio 1.476×10⁻³ |

The clean speed on the 166.8 m grid is 5 times the published pass. Both masses are the positive mass of the shell in the metric.

![Scale](figures/scale_contrast.png)

![Geometry](figures/geometry.png)

The wall thickness is one FSOT relaxation length, `ell = 0.8573494832025231`, from the live transport coefficients. The mass is the compactness-1/2 mass of that body. The shift profile is a join of the compact sigmoid and the pressure fraction. Ship speed only sets the amplitude. The algebra of that join is proved in Lean 4. The Einstein tensor is the Warp Factory log, not the Lean file.

## What the solver reports at 0.10c

Clean means all four worst/peak ratios under 1×10⁻³, serious fraction 0, positive integrated energy, and a shift equal to the requested speed.

| Ratio | 0.10c | Clean bar |
| --- | ---: | ---: |
| Null | 6.534×10⁻⁴ | 1×10⁻³ |
| Weak | 7.887×10⁻⁴ | 1×10⁻³ |
| Strong | 6.558×10⁻⁴ | 1×10⁻³ |
| Dominant | 6.822×10⁻⁶ | 1×10⁻³ |
| Serious fraction | 0 | 0 |
| Energy | 4.0651×10³⁰ kg | positive |
| Shift | 0.100c | 0.100c |

![Conditions](figures/conditions.png)

![Limb](figures/limb.png)

At 0.11c on the same join the dominant ratio is 0.175 in the outer wall and the point fails.

The resolution stress uses the same profile at `N = 320`, spacing 83.395 m (`data/dial_mix_fine.txt`). Null 7.016×10⁻⁴, weak 1.476×10⁻³, strong 7.016×10⁻⁴, dominant 5.506×10⁻⁷, serious fraction prints 0, energy 4.0657×10³⁰ kg, shift 0.10. The weak ratio is the central cavity sample at 59 m, so the same clean bar returns FAIL. Along the side ray the dominant ratio is still 0. The 0.10c pass stands on the 166.8 m grid. It does not stand on the 83.4 m grid.

![Resolution](figures/resolution.png)

## The origin samples

`data/dial_center.txt` scores the same mix with the shift removed and with the shift at 0.10c, on both grids. The negative cavity cells are the four diagonal samples at `r = h / √2`. Every other cavity bin has a positive minimum.

| Grid | Shift | Origin-sample weak ratio | Next ring, one spacing out |
| --- | --- | ---: | ---: |
| 166.8 m | off | −7.515×10⁻⁴ | +1.309×10⁻² |
| 166.8 m | 0.10c | −7.887×10⁻⁴ | +9.651×10⁻³ |
| 83.4 m | off | −1.481×10⁻³ | +4.047×10⁻⁴ |
| 83.4 m | 0.10c | −1.476×10⁻³ | +3.339×10⁻⁴ |

With the shift off, the weak ratio times the sample radius is 0.0886 m at 118 m and 0.0873 m at 59 m. The two points sit on that line. The 0.10c shift moves the coarse sample from −7.515×10⁻⁴ to −7.887×10⁻⁴ and the fine sample from −1.481×10⁻³ to −1.476×10⁻³. On the 83.4 m grid the wall's worst weak ratio is +1.55×10⁻². The smoothed mass outside the body leaves a skirt of order 10⁻⁶ on the coarse grid and 10⁻⁷ on the fine grid.

![Origin samples](figures/center.png)

Full tables are in [docs/RESULTS.md](docs/RESULTS.md). How the shell and the shift are built is in [docs/METHOD.md](docs/METHOD.md).

## Reproduce

Algebra, shell arithmetic, and the stored 0.10c log:

```bash
python python/stress_mix.py
python python/figures.py
```

The pin check runs when `vendor/fsot_compute.py` from FSOT-2.1-Lean is available. Point `FSOT_VENDOR` at that directory, or clone FSOT-2.1-Lean next to this repository. The script checks that the file still hashes to pin AEB2AD and that `ell` matches the shell.

The Lean proof uses Lean 4.31.0 and Mathlib v4.31.0, from a checkout that already has those built:

```bash
lake env lean lean/WarpMix.lean
```

Run that from the FSOT-2.1-Lean repository so Mathlib resolves. The file is not part of the published `FSOT` library.

The metric score uses the Octave port of [Warp Factory](https://github.com/NerdsWithAttitudes/WarpFactory) at commit `03b10cb`. Copy `octave/dial_mix.m` into that port's `fsot_warp` directory. Set `SHELL_ENV` to `data/shell_env.txt` and `OUT` to a writable directory. The clean log from that script is `data/dial_mix.txt`. `octave/dial_mix_fine.m` is the same join at `N = 320`. Its log is `data/dial_mix_fine.txt`. `octave/dial_center.m` is the shift-off census. Its log is `data/dial_center.txt`.

## Limits

The metric is a coast at constant speed. Acceleration is not in the run. The test is Warp Factory's Eulerian energy conditions, sampled on the solver's observer set. On the 166.8 m grid the 0.10c mix is under the clean bar. On the 83.4 m grid the campaign bar fails on four origin samples, and the shift-off run fails on those same samples. A stricter all-observer standard published later has not been run on this shell. 0.11c on this join fails in the outer wall.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
