# Copyright 2026 Damian Arthur Palumbo
# SPDX-License-Identifier: Apache-2.0
"""Figures for the FSOT warp-shell record.

Every mark comes from data/ or from the published Fuchs et al. 2024 shell.
Run from the repository root: python python/figures.py
"""

from __future__ import annotations

import math
from pathlib import Path

import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
FIG = ROOT / "figures"

# Fuchs, Helmerich, Bobrick, Sellers, Melcher, Martire,
# Class. Quantum Grav. 41 (2024) 095013, arXiv:2405.02709.
FUCHS = dict(name="Fuchs et al. 2024", r1=10.0, r2=20.0, mass=4.49e27, speed=0.02)
C_WF = 2.99792458e8
G_WF = 6.67430e-11
M_SUN = 1.98847e30
M_JUP = 1.89813e27
PASS = "#1b7f4e"
FAIL = "#b03348"
INK = "#1c2833"
CUT = "#5c6b73"


def read_shell():
    m110, r2, r1, mass = (float(x) for x in (DATA / "shell_env.txt").read_text().split())
    return m110, r2, r1, mass


def read_block(path: Path, marker: str):
    lines = path.read_text(encoding="utf-8").splitlines()
    start = next(i for i, line in enumerate(lines) if line.startswith(marker))
    block = []
    for line in lines[start:]:
        if block and line.startswith("== "):
            break
        block.append(line)
    return block


def ratios(block):
    out = {}
    for line in block:
        for key in ("null", "weak", "strong", "dominant"):
            token = f"{key} worst/peak="
            if line.startswith(token):
                out[key] = float(line.split("=", 1)[1].split()[0])
    return out


def limb(block):
    rows = []
    for line in block:
        parts = line.split()
        if len(parts) == 6 and parts[0][:1].isdigit():
            r, gtx, t01, t11, dom, nul = (float(x) for x in parts)
            rows.append((r, gtx, t01, t11, dom, nul))
    return rows


def style():
    plt.rcParams.update(
        {
            "font.size": 11,
            "axes.labelsize": 12,
            "axes.titlesize": 13,
            "figure.facecolor": "white",
            "axes.facecolor": "white",
            "savefig.dpi": 160,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "axes.edgecolor": INK,
            "axes.labelcolor": INK,
            "xtick.color": INK,
            "ytick.color": INK,
            "text.color": INK,
        }
    )


def save(fig, name):
    FIG.mkdir(exist_ok=True)
    fig.savefig(FIG / f"{name}.png", bbox_inches="tight")
    fig.savefig(FIG / f"{name}.svg", bbox_inches="tight")
    plt.close(fig)


def fig_speed():
    # Rows are solver cases. Marks are scored speeds.
    rows = [
        ("Fuchs et al. 2024\n10–20 m shell", [(0.02, "pass")]),
        ("This port, Fuchs-type\n50–110 m, compactness 1/3", [(0.10, "fail")]),
        ("FSOT condensate shell\n1.40–9.81 km", [(0.095, "pass"), (0.10, "pass"), (0.11, "fail")]),
    ]
    fig, ax = plt.subplots(figsize=(8.8, 4.8), layout="constrained")
    # After invert_yaxis, negative dy sits visually above the marker.
    label_at = {(0, 0.02): -0.32, (1, 0.10): -0.32, (2, 0.095): -0.32, (2, 0.10): 0.36, (2, 0.11): -0.32}
    for i, (label, marks) in enumerate(rows):
        ax.plot([0, 0.12], [i, i], color="#d5dde3", lw=6, solid_capstyle="round", zorder=0)
        for speed, status in marks:
            color = PASS if status == "pass" else FAIL
            ax.scatter([speed], [i], s=90, color=color, zorder=2)
            ax.text(speed, i + label_at[(i, speed)], f"{speed:.3g}c", ha="center", va="center", fontsize=9, color=color)
    ax.set_yticks(range(len(rows)))
    ax.set_yticklabels([r[0] for r in rows])
    ax.set_xlabel("Shift speed    clean bar: four ratios under 1e-3, serious fraction 0, positive energy")
    ax.set_xlim(0, 0.125)
    ax.set_ylim(-0.7, 2.7)
    ax.invert_yaxis()
    ax.set_title("Eulerian Warp Factory speeds")
    ax.scatter([], [], color=PASS, label="Under the clean bar")
    ax.scatter([], [], color=FAIL, label="Over the clean bar")
    ax.legend(frameon=False, loc="center left", bbox_to_anchor=(1.01, 0.5))
    save(fig, "speed_limit")


def fig_scale(r1, r2, mass):
    vol = 4.0 / 3.0 * math.pi * (r2**3 - r1**3)
    rho = mass / vol
    fvol = 4.0 / 3.0 * math.pi * (FUCHS["r2"] ** 3 - FUCHS["r1"] ** 3)
    frho = FUCHS["mass"] / fvol
    labels = ["Outer radius (m)", "Mass (kg)", "Shell density (kg/m³)"]
    ours = [r2, mass, rho]
    theirs = [FUCHS["r2"], FUCHS["mass"], frho]
    fig, axes = plt.subplots(1, 3, figsize=(9.2, 4.0))
    for ax, label, a, b in zip(axes, labels, ours, theirs):
        ax.bar([0, 1], [b, a], color=["#8aa0b2", "#1f4e79"])
        ax.set_yscale("log")
        ax.set_xticks([0, 1])
        ax.set_xticklabels(["Fuchs\n10–20 m", "This shell\n9.81 km"], fontsize=9)
        ax.set_title(label, fontsize=11)
        ax.tick_params(axis="y", labelsize=8)
    fig.suptitle("Same kind of positive-mass shell, different scale", y=1.02)
    fig.text(
        0.01,
        -0.02,
        f"This shell is {r2 / FUCHS['r2']:.0f}× larger in radius, {mass / FUCHS['mass']:.0f}× heavier, and {frho / rho:.1e}× less dense. Speed is 5× the published pass.",
        fontsize=8,
        color=CUT,
    )
    save(fig, "scale_contrast")
    return rho, frho


def fig_conditions():
    a = ratios(read_block(DATA / "dial_mix.txt", "== mix v=0.10"))
    b = ratios(read_block(DATA / "dial_mix_11.txt", "== mix v=0.11"))
    keys = ["null", "weak", "strong", "dominant"]
    fig, ax = plt.subplots(figsize=(7.6, 4.4))
    import numpy as np

    x = np.arange(len(keys))
    w = 0.36
    ax.bar(x - w / 2, [a[k] for k in keys], w, color=PASS, label="0.10c")
    ax.bar(x + w / 2, [b[k] for k in keys], w, color=FAIL, label="0.11c")
    ax.axhline(1e-3, color=INK, ls="--", lw=1, label="Clean bar 1e-3")
    ax.set_yscale("log")
    ax.set_xticks(x)
    ax.set_xticklabels([k.capitalize() for k in keys])
    ax.set_ylabel("Worst violation / peak |energy density|")
    ax.set_title("Energy-condition ratios on the same shell")
    ax.legend(frameon=False)
    ax.set_ylim(1e-6, 1)
    save(fig, "conditions")


def fig_limb():
    rows = limb(read_block(DATA / "dial_mix.txt", "== mix v=0.10"))
    r = [row[0] / 1000 for row in rows]
    gtx = [row[1] for row in rows]
    t01 = [row[2] for row in rows]
    t11 = [row[3] for row in rows]
    fig, ax = plt.subplots(figsize=(8.2, 4.6), layout="constrained")
    ax.plot(r, gtx, color="#1f4e79", lw=2, label="Shift g_tx")
    ax.plot(r, t01, color="#c47b00", lw=2, label="Momentum flux / peak")
    ax.plot(r, t11, color="#3d6b4f", lw=2, label="Radial stress / peak")
    ax.axhline(0, color="#b7c3cc", lw=1)
    ax.set_xlabel("Radius along the side ray (km)")
    ax.set_ylabel("Fraction of peak")
    ax.set_title("0.10c limb at 166.8 m. Dominant ratio is 0 on this ray.\nWorst dominant cell is outside the body, 6.8e-6.")
    ax.legend(frameon=False, loc="upper right")
    save(fig, "limb")


def fig_resolution():
    coarse = ratios(read_block(DATA / "dial_mix.txt", "== mix v=0.10"))
    fine = ratios(read_block(DATA / "dial_mix_fine.txt", "== mix fine v=0.10"))
    keys = ["null", "weak", "strong", "dominant"]
    fig, ax = plt.subplots(figsize=(7.6, 4.6), layout="constrained")
    import numpy as np

    x = np.arange(len(keys))
    w = 0.36
    ax.bar(x - w / 2, [coarse[k] for k in keys], w, color=PASS, label="166.8 m, under the bar")
    ax.bar(x + w / 2, [fine[k] for k in keys], w, color="#1f4e79", label="83.4 m, same metric")
    ax.axhline(1e-3, color=INK, ls="--", lw=1, label="Clean bar 1e-3")
    ax.set_yscale("log")
    ax.set_xticks(x)
    ax.set_xticklabels([k.capitalize() for k in keys])
    ax.set_ylabel("Worst violation / peak |energy density|")
    ax.set_title("Same 0.10c mix. 83.4 m crosses the bar\non the weak ratio at the cavity center.")
    ax.legend(frameon=False)
    ax.set_ylim(1e-8, 3e-2)
    save(fig, "resolution")


def fig_center():
    text = (DATA / "dial_center.txt").read_text(encoding="utf-8").splitlines()
    cases = []
    current = None
    for line in text:
        if line.startswith("== center "):
            parts = line.split()
            # == center N=160 v=0.00 h=166.790 ...
            n = int(parts[2].split("=")[1])
            v = float(parts[3].split("=")[1])
            h = float(parts[4].split("=")[1])
            current = {"n": n, "v": v, "h": h, "bins": {}}
            cases.append(current)
        elif current is not None and line.startswith("r<h"):
            cols = line.split()
            current["bins"]["center"] = float(cols[4])
        elif current is not None and line.startswith("h..2h"):
            cols = line.split()
            current["bins"]["next"] = float(cols[4])
    fig, ax = plt.subplots(figsize=(8.2, 4.6), layout="constrained")
    import numpy as np

    x = np.arange(len(cases))
    weak = [c["bins"]["center"] for c in cases]
    colors = [FAIL if w < -1e-3 else PASS for w in weak]
    ax.bar(x, weak, color=colors, width=0.62)
    ax.axhline(-1e-3, color=INK, ls="--", lw=1, label="Clean bar, −1e-3")
    ax.axhline(0, color="#b7c3cc", lw=1)
    labels = []
    for c in cases:
        speed = "shift off" if c["v"] == 0 else "0.10c"
        labels.append(f"{c['h']:.1f} m\n{speed}")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylabel("Weak ratio at the four origin samples")
    ax.set_ylim(-2.0e-3, 0.4e-3)
    ax.set_title("Fine-grid miss sits on the origin samples.\nOne spacing outward, the weak ratio is positive.")
    ax.legend(frameon=False, loc="lower left")
    save(fig, "center")


def fig_flatball():
    raw = ratios(read_block(DATA / "dial_mix_fine.txt", "== mix fine v=0.10"))
    text = (DATA / "dial_flatball.txt").read_text(encoding="utf-8").splitlines()
    corr_line = next(s for s in text if "flat N=320 v=0.10" in s)
    corr = text[text.index(corr_line) + 1]
    vals = {}
    for tok in corr.split():
        if "=" in tok:
            k, v = tok.split("=")
            vals[k] = float(v)
    keys = ["null", "weak", "strong", "dom"]
    labels = ["Null", "Weak", "Strong", "Dominant"]
    fig, ax = plt.subplots(figsize=(7.6, 4.6), layout="constrained")
    import numpy as np

    x = np.arange(4)
    w = 0.36
    raw_y = [raw["null"], raw["weak"], raw["strong"], raw["dominant"]]
    cor_y = [vals["null"], vals["weak"], vals["strong"], vals["dom"]]
    ax.bar(x - w / 2, raw_y, w, color=FAIL, label="Raw difference")
    ax.bar(x + w / 2, cor_y, w, color=PASS, label="Flat ball restored")
    ax.axhline(1e-3, color=INK, ls="--", lw=1)
    ax.set_yscale("log")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylabel("Worst violation / peak |energy density|")
    ax.set_title("83.4 m grid at 0.10c.\nFour flat-ball cells restored to zero.")
    ax.legend(frameon=False)
    ax.set_ylim(1e-8, 3e-2)
    save(fig, "flatball")


def fig_geometry(r1, r2):
    fig, ax = plt.subplots(figsize=(8.6, 2.8))
    ax.barh(0, r2 / 1000, color="#1f4e79", height=0.45, label="Wall")
    ax.barh(0, r1 / 1000, color="#d6e4f0", height=0.45, label="Cavity")
    ax.plot([r2 / 1000, 13.4], [0, 0], color="#8aa0b2", lw=8, solid_capstyle="butt")
    ax.set_yticks([])
    ax.set_xlabel("Radius (km)")
    ax.set_xlim(0, 13.6)
    ax.set_ylim(-1.05, 1.15)
    ax.set_title("Shell the 0.10c shift sits on")
    ax.text(r1 / 2000, 0.55, "cavity\n1.40 km", ha="center", va="bottom", fontsize=9)
    ax.text((r1 + r2) / 2000, 0.55, "wall, one relaxation length\n8.41 km thick", ha="center", va="bottom", fontsize=9)
    ax.text(11.7, 0.55, "exterior", ha="center", va="bottom", fontsize=9, color=CUT)
    ax.legend(frameon=False, ncol=2, loc="lower right")
    save(fig, "geometry")


def main():
    style()
    _, r2, r1, mass = read_shell()
    rho, frho = fig_scale(r1, r2, mass)
    fig_speed()
    fig_conditions()
    fig_resolution()
    fig_center()
    fig_flatball()
    fig_limb()
    fig_geometry(r1, r2)
    compact = 2 * G_WF * mass / (C_WF * C_WF * r2)
    print(f"R1={r1:.3f} R2={r2:.3f} M={mass:.6e}")
    print(f"rho={rho:.6e} fuchs_rho={frho:.6e} density_ratio={frho / rho:.6e}")
    print(f"mass_ratio={mass / FUCHS['mass']:.3f} radius_ratio={r2 / FUCHS['r2']:.3f}")
    print(f"solar={mass / M_SUN:.3f} jupiter={mass / M_JUP:.1f} Rs/R2={compact:.6f}")


if __name__ == "__main__":
    main()
