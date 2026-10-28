# Copyright 2026 Damian Arthur Palumbo
# SPDX-License-Identifier: Apache-2.0
"""Check the mix join, the shell arithmetic, and the scored log.

The pin check runs when FSOT_VENDOR points at a directory that contains
fsot_compute.py and fsot_dynamics.py (the FSOT 2.1 AEB2AD vendor tree).
The algebra, the shell file, and data/dial_mix.txt do not need it.
"""

from __future__ import annotations

import hashlib
import math
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT / "data" / "shell_env.txt"
LOG = ROOT / "data" / "dial_mix.txt"
C_ROUTE = 2.99792e8
G_ROUTE = 6.674e-11
C_WF = 2.99792458e8
G_WF = 6.67430e-11
ELL_BAKED = 0.8573494832025231
PIN_PREFIX = "aeb2adad6e80f487"

failures: list[str] = []


def check(name: str, ok: bool, detail: str) -> None:
    print(f"{'PASS' if ok else 'FAIL'}  {name}  {detail}")
    if not ok:
        failures.append(f"{name}: {detail}")


def blend(s: float, p: float) -> float:
    return s * (1.0 + p - s)


def weight(s: float, p: float) -> float:
    return min(1.0, s / p) if p > 0.0 else 1.0


def cap(s: float, p: float) -> float:
    return s * (1.0 + (p - s) * weight(s, p))


def mix(s: float, p: float) -> float:
    return s * blend(s, p) + (1.0 - s) * cap(s, p)


def mix_scored(s: float, p: float) -> float:
    w = min(1.0, s / p) if p > 1e-8 else 1.0
    c = s * (1.0 + (p - s) * w)
    return s * blend(s, p) + (1.0 - s) * c


def algebra() -> None:
    ss = [i / 40 for i in range(41)] + [0.0, 1e-12, 1e-9, 5e-9, 1e-8]
    ps = [i / 40 for i in range(41)] + [0.0, 1e-12, 5e-9, 1e-8, 1e-8 + 1e-12]
    peak_gap = 0.0
    n = 0
    for s in ss:
        for p in ps:
            n += 1
            b, c, m = blend(s, p), cap(s, p), mix(s, p)
            gap = abs(mix_scored(s, p) - m)
            peak_gap = max(peak_gap, gap)
            peak = ((1.0 + p) / 2.0) ** 2
            if not (-1e-12 <= b <= min(1.0, peak) + 1e-12 and c - 1e-12 <= m <= b + 1e-12 and -1e-12 <= m <= 1 + 1e-12):
                check("algebra", False, f"s={s} p={p}")
                return
            if p > 1e-8 and s <= p and abs((b - c) - s * (p - s) ** 2 / p) > 1e-9:
                check("blend-cap", False, f"s={s} p={p}")
                return
            allow = (p * p if 0.0 < p <= 1e-8 else 0.0) + 1e-14
            if gap > allow:
                check("floor", False, f"s={s} p={p} gap={gap}")
                return
    check("algebra grid", True, f"{n} pairs, max scored gap {peak_gap:.3e}")
    check("cabin and surface", mix(1, 1) == 1 and mix(0, 0) == 0, "mix(1,1)=1, mix(0,0)=0")


def shell_file() -> None:
    _, r2, r1, mass = (float(x) for x in SHELL.read_text(encoding="utf-8").split())
    check("wall is one ell", abs(r1 - r2 * (1.0 - ELL_BAKED)) / r1 <= 2e-12, f"R1={r1:.6e}")
    mass_route = 0.5 * r2 * C_ROUTE * C_ROUTE / (2.0 * G_ROUTE)
    check("compactness 1/2 mass", abs(mass - mass_route) / mass <= 2e-12, f"M={mass:.6e}")
    compact = 2.0 * G_WF * mass / (C_WF * C_WF * r2)
    print(f"INFO  Warp Factory compactness Rs/R2={compact:.9f}")
    check("WF compactness near 1/2", 0.499 <= compact <= 0.501, f"{compact:.9f}")


def pin() -> None:
    vendor = os.environ.get("FSOT_VENDOR", "")
    if not vendor:
        guess = ROOT.parent / "FSOT-2.1-Lean" / "vendor"
        vendor = str(guess) if (guess / "fsot_compute.py").exists() else ""
    if not vendor:
        print("SKIP  pin  set FSOT_VENDOR to the AEB2AD vendor directory")
        return
    pin_path = Path(vendor) / "fsot_compute.py"
    digest = hashlib.sha256(pin_path.read_bytes()).hexdigest()
    check("pin AEB2AD", digest.startswith(PIN_PREFIX), digest[:16])
    sys.path.insert(0, vendor)
    import fsot_dynamics as fd

    kappa = fd.bleed_rate() * fd.f(fd.A_BLEED)
    gamma = abs(fd.f(fd.CHAOS)) + fd.f(fd.PSI_CON) * fd.f(fd.POOF)
    ell = math.sqrt(kappa / gamma)
    print(f"INFO  kappa={kappa:.16e} gamma={gamma:.16e} ell={ell:.16e}")
    check("ell matches shell", abs(ell - ELL_BAKED) <= 5e-16, f"delta={ell - ELL_BAKED:.3e}")


def log() -> None:
    text = LOG.read_text(encoding="utf-8")
    lines = text.splitlines()
    check("profile ends", "S(0)=1.00000" in lines[2] and "S(R2)=0.00000" in lines[2], lines[2])
    summary = "E=4.0651e+30 nec=6.534e-04 dec=6.822e-06 ser=0.0000 shift=1.000e-01 CLEAN"
    check("0.10 summary", summary in text, summary)
    start = next(i for i, line in enumerate(lines) if line.startswith("== mix v=0.10"))
    rows = []
    for line in lines[start + 1 :]:
        if line.startswith("== "):
            break
        parts = line.split()
        if len(parts) == 6 and parts[0][:1].isdigit():
            rows.append(parts)
    doms = {row[4] for row in rows}
    check("0.10 limb dominant", bool(rows) and doms == {"0.0000"}, f"{len(rows)} rows {sorted(doms)}")


def main() -> int:
    algebra()
    shell_file()
    pin()
    log()
    print(f"RESULT  {len(failures)} failures")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
