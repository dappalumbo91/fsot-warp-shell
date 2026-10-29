# Copyright 2026 Damian Arthur Palumbo
# SPDX-License-Identifier: Apache-2.0
"""Check the mix join, the shell arithmetic, and the scored log.

The pin check runs when FSOT_VENDOR points at a directory that contains
fsot_compute.py and fsot_dynamics.py (the FSOT 2.1 AEB2AD vendor tree).
The algebra, the shell file, and the two scored logs do not need it.
data/dial_mix_fine.txt is checked as a recorded failure, not as a pass.
data/dial_flatball_11_fine.txt is the 0.11c wall on the 83.4 m grid, also a recorded failure.
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
FINE = ROOT / "data" / "dial_mix_fine.txt"
CENTER = ROOT / "data" / "dial_center.txt"
FLAT = ROOT / "data" / "dial_flatball.txt"
FLAT11 = ROOT / "data" / "dial_flatball_11_fine.txt"
SIZE = ROOT / "data" / "dial_fuchs_size.txt"
CABIN = ROOT / "data" / "dial_cabin_gap.txt"
AUDIT = ROOT / "data" / "dial_audit_bar.txt"
VACUUM = ROOT / "data" / "dial_cabin_vacuum.txt"
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


def fine_log() -> None:
    text = FINE.read_text(encoding="utf-8")
    check(
        "83.4 m summary is the recorded failure",
        "E=4.0657e+30 nec=7.016e-04 dec=5.506e-07 ser=0.0000 shift=1.000e-01 FAIL" in text,
        "dial_mix_fine.txt",
    )
    check(
        "83.4 m weak ratio is the cavity sample",
        "weak worst/peak=1.476e-03 at r=58.97 m (cavity)" in text,
        "dial_mix_fine.txt",
    )


def center_log() -> None:
    text = CENTER.read_text(encoding="utf-8")
    check("center census finished", "center census done" in text, "dial_center.txt")
    check("83.4 m shift off misses at the origin", "-1.480697e-03" in text and "== center N=320 v=0.00" in text, "dial_center.txt")
    check("83.4 m shift on matches the fine log", "-1.476078e-03" in text and "== center N=320 v=0.10" in text, "dial_center.txt")
    check("166.8 m shift off origin sample", "-7.515213e-04" in text and "== center N=160 v=0.00" in text, "dial_center.txt")


def flat_log() -> None:
    text = FLAT.read_text(encoding="utf-8")
    check("flat ball finished", "flat ball done" in text, "dial_flatball.txt")
    check(
        "83.4 m 0.10c restored is clean",
        "null=1.970669e-07 weak=4.005914e-07 strong=1.970669e-07 dom=5.506012e-07" in text
        and "CLEAN" in text,
        "dial_flatball.txt",
    )
    check("166.8 m restores no cells", "== raw N=160 v=0.10  minWeak=-7.886762e-04 nFlat=0" in text, "dial_flatball.txt")
    check("83.4 m restores four cells", "== raw N=320 v=0.10  minWeak=-1.476078e-03 nFlat=4" in text, "dial_flatball.txt")


def flat11_log() -> None:
    text = FLAT11.read_text(encoding="utf-8")
    check("0.11c fine flat ball finished", "flat ball done" in text, "dial_flatball_11_fine.txt")
    check(
        "83.4 m 0.11c wall is the recorded failure",
        "null=3.549428e-02 weak=3.549428e-02 strong=3.549428e-02 dom=1.771462e-01" in text
        and "FAIL" in text,
        "dial_flatball_11_fine.txt",
    )
    check(
        "83.4 m 0.11c restores four cells",
        "== raw N=320 v=0.11  minWeak=-3.549428e-02 nFlat=4" in text,
        "dial_flatball_11_fine.txt",
    )


def size_log() -> None:
    text = SIZE.read_text(encoding="utf-8")
    check("20 m size log finished", "fuchs size done" in text, "dial_fuchs_size.txt")
    check(
        "20 m compactness 1/3 is clean at 0.06c",
        "E=5.1417e+27 null=9.336e-06 weak=1.890e-05 strong=9.336e-06 dom=1.700e-05 ser=0.0000 shift=6.000e-02 CLEAN" in text,
        "dial_fuchs_size.txt",
    )
    check(
        "20 m compactness 1/2 is clean at 0.10c",
        "E=8.2868e+27 null=1.067e-05 weak=2.158e-05 strong=1.067e-05 dom=1.923e-05 ser=0.0000 shift=1.000e-01 CLEAN" in text,
        "dial_fuchs_size.txt",
    )
    check(
        "20 m compactness 1/2 fails at 0.11c",
        "null=3.567e-02 weak=3.567e-02 strong=3.567e-02 dom=1.771e-01" in text and "shift=1.100e-01 FAIL" in text,
        "dial_fuchs_size.txt",
    )


def cabin_log() -> None:
    text = CABIN.read_text(encoding="utf-8")
    check("cabin log finished", "cabin gap done" in text, "dial_cabin_gap.txt")
    check(
        "their cabin at compactness 1/2 is clean at 0.04c",
        "E=8.1598e+27 null=1.106e-05 weak=2.232e-05 strong=1.106e-05 dom=1.970e-05 ser=0.0000 shift=4.000e-02 CLEAN" in text,
        "dial_cabin_gap.txt",
    )
    check(
        "their cabin fails at 0.06c",
        "null=1.421e-01 weak=1.421e-01 strong=1.421e-01 dom=3.517e-01" in text and "shift=6.000e-02 FAIL" in text,
        "dial_cabin_gap.txt",
    )


def _summary_line(text: str, marker: str) -> str:
    lines = text.splitlines()
    start = next(i for i, line in enumerate(lines) if line.startswith(f"== {marker}"))
    for line in lines[start + 1 :]:
        if line.startswith("E=") or line.startswith("null="):
            return line
        if line.startswith("== "):
            break
    raise RuntimeError(marker)


def _physics(line: str) -> str:
    import re

    return re.sub(r"\s+[0-9.]+s$", "", line)


def audit_log() -> None:
    text = AUDIT.read_text(encoding="utf-8")
    check("audit bar finished", "audit bar done" in text, "dial_audit_bar.txt")
    parked_half = _summary_line(text, "C=0.500 v=0.00")
    parked_third = _summary_line(text, "C=0.333 v=0.00")
    live = _summary_line(text, "C=0.500 v=0.10")
    stored = _summary_line(SIZE.read_text(encoding="utf-8"), "C=0.500 v=0.10")
    check(
        "parked compactness 1/2 is clean at v=0",
        "CLEAN" in parked_half and "shift=0.000e+00" in parked_half,
        parked_half,
    )
    check(
        "parked compactness 1/3 is clean at v=0",
        "CLEAN" in parked_third and "shift=0.000e+00" in parked_third,
        parked_third,
    )
    check(
        "fresh 0.10c line matches the stored score",
        _physics(live) == _physics(stored),
        _physics(live),
    )


def vacuum_log() -> None:
    text = VACUUM.read_text(encoding="utf-8")
    check("cabin vacuum finished", "cabin vacuum done" in text, "dial_cabin_vacuum.txt")
    check(
        "FSOT wall density stays under 1 percent out to 0.42 m",
        "usable cabin, rho<1% peak and S>0.999, out to r=0.4169 m" in text,
        "dial_cabin_vacuum.txt",
    )
    check(
        "their cabin stays under 1 percent out to 5.72 m",
        "usable cabin, rho<1% peak and S>0.999, out to r=5.7242 m" in text,
        "dial_cabin_vacuum.txt",
    )
    check(
        "mass smooth ends at 26.57 m",
        "last rho>0 at r=26.5724 m" in text,
        "dial_cabin_vacuum.txt",
    )


def shift_bar() -> None:
    """Every stored verdict has to carry the speed it claims."""
    import re

    n = 0
    for path in sorted((ROOT / "data").glob("*.txt")):
        if path.name == "shell_env.txt":
            continue
        v = None
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.startswith("== ") and "v=" in line:
                v = float(re.search(r"v=([0-9.]+)", line).group(1))
            if "shift=" not in line or ("CLEAN" not in line and "FAIL" not in line):
                continue
            same = re.search(r"v=([0-9.]+)", line)
            speed = float(same.group(1)) if same else v
            shift = float(re.search(r"shift=([0-9.eE+-]+)", line).group(1))
            n += 1
            if speed is None or abs(shift - speed) > 1.5e-3:
                check("shift matches speed", False, f"{path.name}: shift={shift} v={speed}")
                return
            if "CLEAN" in line:
                ser = re.search(r"ser=([0-9.eE+-]+)", line)
                if ser and float(ser.group(1)) != 0.0:
                    check("clean serious fraction", False, path.name)
                    return
    check("stored shift matches the requested speed", True, f"{n} verdicts")


def shell_fields() -> None:
    """Field 1 is the 110 m condensate wall. The scorer uses fields 2–4."""
    m110, r2, r1, mass = (float(x) for x in SHELL.read_text(encoding="utf-8").split())
    vol = 4.0 / 3.0 * math.pi * (r2**3 - r1**3)
    rho = mass / vol
    r_small = 110.0
    r1_small = r_small * (1.0 - ELL_BAKED)
    vol110 = 4.0 / 3.0 * math.pi * (r_small**3 - r1_small**3)
    check(
        "field 1 is the 110 m wall at this density",
        abs(m110 - rho * vol110) / abs(m110) < 1e-9,
        f"m110={m110:.6e}",
    )
    e_big = 4.0651e30
    e_20 = 8.2868e27
    m_20 = 0.5 * 20.0 * C_WF * C_WF / (2.0 * G_WF)
    check("energy over mass agrees across scales", abs((e_big / mass) - (e_20 / m_20)) < 5e-3, f"{e_big / mass:.4f} and {e_20 / m_20:.4f}")


def main() -> int:
    algebra()
    shell_file()
    shell_fields()
    pin()
    log()
    fine_log()
    center_log()
    flat_log()
    flat11_log()
    size_log()
    cabin_log()
    audit_log()
    vacuum_log()
    shift_bar()
    print(f"RESULT  {len(failures)} failures")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
