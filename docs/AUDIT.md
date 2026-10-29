# Audit, 2026-10-29

The chain from the pin through the wall, the mix, and the Warp Factory score was checked again. No scored claim changed.

## What was checked

The live pin still hashes to AEB2AD. The relaxation length from the transport coefficients is `ell = 0.8573494832025231`, and the stored cavity is `R2 * (1 - ell)`. The compactness-1/2 mass in `data/shell_env.txt` matches the constants that wrote that file. Warp Factory's constants put the same mass at Rs/R2 = 0.500021.

The first number in `data/shell_env.txt`, 4.655124×10²⁴ kg, is a 110 m wall at that same density and the same wall fraction. The scorers read the radii and the mass. They do not use the first number.

The mix is the join already proved in `lean/WarpMix.lean`. On 2,116 pairs of the unit square the scored `1e-8` gate moves the join by at most 1.25×10⁻¹⁷. Cabin `(1, 1)` is 1. Surface `(0, 0)` is 0. Lean 4.31.0 accepts the file from the FSOT-2.1-Lean checkout. The proof does not evaluate the Einstein tensor. The energy conditions stay with Warp Factory.

The integrated energy is 1.231 times the compactness mass on the 9.81 km body (4.0651×10³⁰ / 3.303043×10³⁰) and 1.231 times the compactness mass on the 20 m shell. The factor is the pressure and the curved volume in the solver integral. It is the same factor at both sizes.

Every stored CLEAN and FAIL line has its shift within 1.5×10⁻³ of the requested speed, and every CLEAN line has serious fraction 0.

## The clean flag

`dial_fuchs_size.m` and `dial_cabin_gap.m` already required the peak shift to equal the requested speed. `dial_mix.m`, `dial_mix_fine.m`, and `dial_flatball.m` printed the shift and did not require it inside the clean flag. They now do. The stored logs already passed that test, so no label changed. The logs were not regenerated.

## Fresh 20 m runs

`octave/dial_audit_bar.m` scores the same mix on the same N = 120 grid as `dial_fuchs_size.m`. The log is `data/dial_audit_bar.txt`.

| Case | Energy | Dominant / peak | Where | Result |
| --- | ---: | ---: | --- | --- |
| Compactness 1/2, shift off | 8.3144×10²⁷ kg | 1.95×10⁻⁵ | exterior, 26.47 m | clean |
| Compactness 1/2, 0.10c | 8.2868×10²⁷ kg | 1.92×10⁻⁵ | exterior, 26.47 m | clean |
| Compactness 1/3, shift off | 5.1495×10²⁷ kg | 1.71×10⁻⁵ | exterior, 26.47 m | clean |

The 0.10c line matches `data/dial_fuchs_size.txt` on energy, the four ratios, the serious fraction, the shift, and the cell that holds the dominant ratio. The wall-clock seconds differ. With the shift off, the same matter is already under the bar. Turning the shift on at 0.10c moves the energy from 8.3144×10²⁷ kg to 8.2868×10²⁷ kg and leaves the violation in the exterior skirt.

That is a confirmation of the record. It is not a lighter shell and not a new speed. The 0.11c failure at compactness 1/2, dominant ratio 0.177 in the outer wall, is unchanged. Their 10 m cabin remains clean at 0.04c and over the bar at 0.06c.

## What this is

Inside this Eulerian Warp Factory test, the FSOT wall at 20 m is clean at 0.10c, five times the published Fuchs 0.02c pass, at 1.5 times that mass. Their cabin is clean at 0.04c. The run is a coast at constant speed. It is not a built device, and it is not faster than light.
