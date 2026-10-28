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

Warp Factory builds the comoving warp-shell metric at this mass and these radii, then replaces the shift with the mix. The Eulerian null, weak, strong, and dominant maps are read on the transverse grid. A point is clean when all four worst/peak ratios are under `1e-3`, the serious fraction is 0, the integrated energy is positive, and the peak shift equals the requested speed.

The scored grid at the clean point has `N = 160` and spacing `h = 166.790 m`. The same metric at `N = 320` (`h = 83.395 m`) fails the clean bar: the weak ratio at the central cavity sample is 1.476×10⁻³. That log is `data/dial_mix_fine.txt`.

The center census in `data/dial_center.txt` repeats both grids with the shift amplitude set to 0. The negative cavity cells are the four diagonal samples at `r = h / √2`. With the shift off, the 83.4 m weak ratio at that sample is 1.481×10⁻³, and the weak ratio times the sample radius is 0.0886 m on the coarse grid and 0.0873 m on the fine grid. One spacing farther out, the minimum weak ratio is positive on both grids.

## What was varied

Same body, same mass, same smoother. The ordinary compact sigmoid is clean at 0.075c and fails at 0.08c on the side of the wall. The blend `s(1 + p - s)` is clean through 0.095c and fails at 0.10c on the outer limb. The mix above is clean at 0.095c and at 0.10c on the 166.8 m grid. The same mix at 0.11c fails in the outer wall. Later joins that tried to hand the tail to the sigmoid also failed, and they lost the 0.10c pass with them. On the 166.8 m grid the pass remains the mix at 0.10c. The same metric at 83.4 m fails the weak ratio at the cavity center.
