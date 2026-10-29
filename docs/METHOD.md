# How the 0.10c shell is built

This is a constant-speed metric in Warp Factory. The ship speed is the amplitude of the shift. It does not enter the shape of the shell or the shape of the shift profile.

## The shell

FSOT 2.1, pin AEB2AD, supplies the relaxation length of the scalar transport law in `vendor/fsot_dynamics.py`:

```
kappa = (POOF + SUCTION) * A_BLEED
gamma = |CHAOS| + PSI_CON * POOF
ell   = sqrt(kappa / gamma) = 0.8573494832025231
```

The wall is one relaxation length:

```
R1 = R2 * (1 - ell)
```

The outer radius is the one at which a shell of the pin's gluon-condensate density, with that wall fraction, has compactness 1/2. With the constants that wrote the shell file (`c = 2.99792e8`, `G = 6.674e-11`):

```
M = (1/2) * R2 * c² / (2 G)
```

That file is `data/shell_env.txt`:

| Quantity | Value |
| --- | --- |
| Cavity radius R1 | 1399.567 m |
| Outer radius R2 | 9811.159 m |
| Mass | 3.303043×10³⁰ kg |
| Unsmoothed density | 8.373888×10¹⁷ kg/m³ |

The first number in that file, 4.655124×10²⁴ kg, is a 110 m wall at the same density and the same wall fraction. The scorers read the radii and the mass. They do not use the first number.

On the 20 m grid the builder's mass smooth is four passes of 3.29 m, and the shift smooth is two passes of 1.84 m. `data/dial_cabin_vacuum.txt` records where that leaves the density and the shift. The unsmoothed inner radius is not the radius where the density is still zero.

Warp Factory integrates with `c = 2.99792458e8` and `G = 6.67430e-11`. Those constants put the same stored mass at Rs/R2 = 0.500021.

## The shift

Two profiles are built on the shell and smoothed twice with the solver's moving average, span 4000, before they are joined.

- `s` is the compact sigmoid: 1 in the cavity, 0 at the surface.
- `p` is the pressure fraction: 1 in the cavity, 0 outside, and `P / P(inner edge)` through the wall.

```
blend = s * (1 + p - s)
w     = min(1, s / p)    when p > 1e-8, else 1
cap   = s * (1 + (p - s) * w)
S     = s * blend + (1 - s) * cap
```

Where the sigmoid is still at least the pressure, the weight is 1, the cap equals the blend, and the mix is the blend. Below that crossing,

```
blend - cap = s * (p - s)² / p
```

so the cap sits under the mix, and the mix sits under the blend. Cabin `(1, 1)` is 1. Surface `(0, 0)` is 0. On the unit square the result is already between 0 and 1, so the closing clamp leaves it unchanged. The `1e-8` gate moves the join by at most `1e-16`.

The metric shift is `g_tx = -v S(r)` along the boost direction. `v` is the requested speed.

`lean/WarpMix.lean` proves those identities. It does not evaluate the Einstein tensor. The energy conditions are the Warp Factory witness in `data/dial_mix.txt`.

## The score

Warp Factory builds the comoving warp-shell metric at this mass and these radii, then replaces the shift with the mix. The Eulerian null, weak, strong, and dominant maps are read on the transverse grid. A point is clean when all four worst/peak ratios are under `1e-3`, the serious fraction is 0, the integrated energy is positive, and the peak shift equals the requested speed. `dial_mix.m`, `dial_mix_fine.m`, and `dial_flatball.m` apply that shift test in the clean flag, the same way `dial_fuchs_size.m` and `dial_cabin_gap.m` already did. The stored logs already satisfy it.

The scored grid at the clean point has `N = 160` and spacing `h = 166.790 m`. The raw Cartesian difference at `N = 320` (`h = 83.395 m`) puts the weak ratio at the central sample at 1.476×10⁻³. That log is `data/dial_mix_fine.txt`. The restored score is `data/dial_flatball.txt`. The same restoration at 0.11c is `data/dial_flatball_11.txt` on the 166.8 m grid and `data/dial_flatball_11_fine.txt` on the 83.4 m grid. Both fail in the outer wall.

The center census in `data/dial_center.txt` repeats both grids with the shift amplitude set to 0. The negative cavity cells are the four diagonal samples at `r = h / √2`. With the shift off, the 83.4 m weak ratio at that sample is 1.481×10⁻³, and the weak ratio times the sample radius is 0.0886 m on the coarse grid and 0.0873 m on the fine grid. One spacing farther out, the minimum weak ratio is positive on both grids.

The smoothed shell density is exactly zero for r < 87.55 m, and `B = 1` on that same interval. The shift profile is exactly 1 out past 500 m. Inside r < 87.55 m the continuum stress-energy is zero. The 83.4 m samples at 59 m lie in that ball. The 166.8 m samples at 118 m do not. `data/dial_flatball.txt` sets the stress-energy of every scored cell inside the ball back to zero and leaves every other cell on the Cartesian difference. The 166.8 m score has no such cell. The 83.4 m score then has its worst weak ratio at 4.006×10⁻⁷ in the exterior skirt.

## What was varied

Same body, same mass, same smoother. The ordinary compact sigmoid is clean at 0.075c and fails at 0.08c on the side of the wall. The blend `s(1 + p - s)` is clean through 0.095c and fails at 0.10c on the outer limb. The mix above is clean at 0.095c and at 0.10c on the 166.8 m grid. The same mix at 0.11c fails in the outer wall. Later joins that tried to hand the tail to the sigmoid also failed, and they lost the 0.10c pass with them. The pass remains the mix at 0.10c. On the 83.4 m grid the raw center sample is over the bar, and the flat-ball restoration puts that same 0.10c metric under the bar. The 0.11c failure in the outer wall is the same break on that finer grid. The same join at an outer radius of 20 m is `data/dial_fuchs_size.txt`. Compactness 1/3 there is the published mass and is clean at 0.06c. Compactness 1/2 is 1.5 times that mass and is clean at 0.10c. Their cabin, half the outer radius, is `data/dial_cabin_gap.txt`: clean at 0.04c when the compactness is 1/2, and over the bar at 0.06c. `data/dial_audit_bar.txt` repeats the 0.10c line and scores the same shell with the shift off. Both parked cases are clean. The write-up is [AUDIT.md](AUDIT.md).

The lighter 20 m runs keep that mix and that lapse and lower the compactness, so the density falls with the mass. `data/dial_mass_down.txt` is compactness 1/4 and 1/5. Both are clean at 0.04c and over the bar at 0.06c. `data/dial_mass_down_16.txt` is compactness 1/6 at 0.04c and fails on the outer shoulder. `data/dial_sixth_push.txt` places that same mass on the absolute slope of the mix. The shoulders clear and the inner edge fails. `data/dial_sixth_cover.txt` adds the wall to that slope and returns the sum to the same mass. `data/dial_sixth_max.txt` keeps the larger of the two densities and returns the total to the same mass. Both reopen the outer shoulder. `data/dial_sixth_band.txt` shows the 16.5 m notch already on the slope. `data/dial_sixth_inner.txt` restores the wall only in the foot and leaves that notch. `data/dial_sixth_chord.txt` holds the slope to a chord out to the shell face, clears the notch, and fails on the steepest slope. `data/dial_sixth_bend.txt` stops the chord one curvature-rise past the strongest bend and is clean at 0.04c at the same mass. The 0.10c pass remains compactness 1/2.
