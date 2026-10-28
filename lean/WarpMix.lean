/-
Copyright 2026 Damian Arthur Palumbo
SPDX-License-Identifier: Apache-2.0
-/

import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.FieldSimp
import Mathlib.Order.Defs.LinearOrder
import Mathlib.Analysis.SpecialFunctions.Sqrt

/-
Algebra of the 0.10c mix join. Not part of `lean_lib FSOT`.

This file proves the shift algebra on the unit square. The Einstein tensor
and the energy conditions stay with `data/dial_mix.txt`.
Ship speed is only the amplitude. The pin is not an input of these proofs.
-/

namespace WarpMix

noncomputable section

/-- `s * (1 + p - s)`. `s` is the compact sigmoid, `p` the pressure fraction. -/
def blend (s p : ℝ) : ℝ := s * (1 + p - s)

/-- Full blend while the sigmoid is at least the pressure; otherwise the ratio. -/
def weight (s p : ℝ) : ℝ :=
  if 0 < p then min 1 (s / p) else 1

/-- Blend with the extra piece scaled by `weight`. -/
def cap (s p : ℝ) : ℝ := s * (1 + (p - s) * weight s p)

/-- Scored join. The sigmoid weights the blend against the cap. -/
def mix (s p : ℝ) : ℝ := s * blend s p + (1 - s) * cap s p

/-- Octave gate in `dial_mix.m`: pressure at or below `1e-8` keeps weight 1. -/
def pressureFloor : ℝ := 1 / 100000000

def weightScored (s p : ℝ) : ℝ :=
  if pressureFloor < p then min 1 (s / p) else 1

def capScored (s p : ℝ) : ℝ := s * (1 + (p - s) * weightScored s p)

def mixScored (s p : ℝ) : ℝ := s * blend s p + (1 - s) * capScored s p

def clamped (s p : ℝ) : ℝ := max 0 (min 1 (mix s p))

theorem blend_expand (s ds p : ℝ) :
    blend (s + ds) p = blend s p + (1 + p - 2 * s) * ds - ds ^ 2 := by
  unfold blend
  ring

theorem blend_slope_ge_one (s p : ℝ) : 1 ≤ 1 + p - 2 * s ↔ 2 * s ≤ p := by
  constructor <;> intro h <;> linarith

theorem blend_nonneg {s p : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hp0 : 0 ≤ p) :
    0 ≤ blend s p := by
  unfold blend
  have hrest : 0 ≤ 1 + p - s := by linarith
  exact mul_nonneg hs0 hrest

theorem blend_le_peak {s p : ℝ} :
    blend s p ≤ ((1 + p) / 2) ^ 2 := by
  unfold blend
  have h : ((1 + p) / 2) ^ 2 - s * (1 + p - s) = (s - (1 + p) / 2) ^ 2 := by ring
  linarith [sq_nonneg (s - (1 + p) / 2)]

theorem blend_le_one {s p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) : blend s p ≤ 1 := by
  have hx : (1 + p) / 2 ≤ 1 := by linarith
  have hx0 : 0 ≤ (1 + p) / 2 := by linarith
  have hsq : ((1 + p) / 2) ^ 2 ≤ 1 := by
    have hmul : (1 + p) / 2 * ((1 + p) / 2) ≤ 1 * 1 := mul_le_mul hx hx hx0 (by norm_num)
    rw [← pow_two, mul_one] at hmul
    exact hmul
  exact blend_le_peak.trans hsq

theorem weight_one_of_ge {s p : ℝ} (hp : 0 < p) (hs : p ≤ s) : weight s p = 1 := by
  unfold weight
  rw [if_pos hp, min_eq_left]
  rw [le_div_iff₀ hp]
  linarith

theorem cap_eq_blend_of_ge {s p : ℝ} (hp : 0 < p) (hs : p ≤ s) :
    cap s p = blend s p := by
  unfold cap blend
  rw [weight_one_of_ge hp hs]
  ring

theorem mix_eq_blend_of_ge {s p : ℝ} (hp : 0 < p) (hs : p ≤ s) :
    mix s p = blend s p := by
  unfold mix
  rw [cap_eq_blend_of_ge hp hs]
  ring

theorem cap_eq_blend_of_zero {s : ℝ} : cap s 0 = blend s 0 := by
  have hw : weight s 0 = 1 := by
    unfold weight
    rw [if_neg (lt_irrefl (0 : ℝ))]
  unfold cap blend
  rw [hw]
  ring

theorem blend_sub_cap {s p : ℝ} (hp : 0 < p) (hs : s ≤ p) :
    blend s p - cap s p = s * (p - s) ^ 2 / p := by
  have hw : weight s p = s / p := by
    unfold weight
    rw [if_pos hp, min_eq_right]
    rw [div_le_iff₀ hp]
    linarith
  unfold blend cap
  rw [hw]
  have hne : p ≠ 0 := ne_of_gt hp
  apply (eq_div_iff hne).2
  field_simp [hne]
  ring

theorem blend_sub_cap_nonneg {s p : ℝ} (hs0 : 0 ≤ s) (hp : 0 < p) (hs : s ≤ p) :
    0 ≤ blend s p - cap s p := by
  rw [blend_sub_cap hp hs]
  positivity

theorem blend_sub_cap_le_sq {s p : ℝ} (hs0 : 0 ≤ s) (hp : 0 < p) (hs : s ≤ p) :
    blend s p - cap s p ≤ p ^ 2 := by
  rw [blend_sub_cap hp hs]
  have hsq : (p - s) ^ 2 ≤ p ^ 2 := by
    have hspan : 0 ≤ p - s := by linarith
    have hle : p - s ≤ p := by linarith
    nlinarith
  have hmul : s * (p - s) ^ 2 ≤ p * p ^ 2 := mul_le_mul hs hsq (sq_nonneg _) hp.le
  have hdiv : s * (p - s) ^ 2 / p ≤ p * p ^ 2 / p :=
    div_le_div_of_nonneg_right hmul hp.le
  have hid : p * p ^ 2 / p = p ^ 2 := mul_div_cancel_left₀ (p ^ 2) hp.ne'
  linarith

theorem mix_sub_cap_factor {s p : ℝ} : mix s p - cap s p = s * (blend s p - cap s p) := by
  unfold mix
  ring

theorem blend_sub_mix_factor {s p : ℝ} :
    blend s p - mix s p = (1 - s) * (blend s p - cap s p) := by
  unfold mix
  ring

theorem cap_le_mix_le_blend {s p : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hp0 : 0 ≤ p) :
    cap s p ≤ mix s p ∧ mix s p ≤ blend s p := by
  by_cases hp : p = 0
  · subst hp
    have hc : cap s 0 = blend s 0 := cap_eq_blend_of_zero
    have hm : mix s 0 = blend s 0 := by
      unfold mix
      rw [hc]
      ring
    constructor
    · linarith
    · linarith
  · have hppos : 0 < p := lt_of_le_of_ne hp0 (Ne.symm hp)
    rcases le_or_gt p s with hs | hs
    · rw [cap_eq_blend_of_ge hppos hs, mix_eq_blend_of_ge hppos hs]
      exact ⟨le_rfl, le_rfl⟩
    · have hsle : s ≤ p := le_of_lt hs
      have hdiff : 0 ≤ blend s p - cap s p := blend_sub_cap_nonneg hs0 hppos hsle
      have hcap : mix s p - cap s p = s * (blend s p - cap s p) := mix_sub_cap_factor
      have hblend : blend s p - mix s p = (1 - s) * (blend s p - cap s p) := blend_sub_mix_factor
      have hone : 0 ≤ 1 - s := by linarith
      have hleft : 0 ≤ mix s p - cap s p := by
        rw [hcap]
        exact mul_nonneg hs0 hdiff
      have hright : 0 ≤ blend s p - mix s p := by
        rw [hblend]
        exact mul_nonneg hone hdiff
      constructor
      · linarith
      · linarith

theorem cap_nonneg {s p : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ cap s p := by
  by_cases hp : p = 0
  · subst hp
    rw [cap_eq_blend_of_zero]
    exact blend_nonneg hs0 hs1 hp0
  · have hppos : 0 < p := lt_of_le_of_ne hp0 (Ne.symm hp)
    rcases le_or_gt p s with hs | hs
    · rw [cap_eq_blend_of_ge hppos hs]
      exact blend_nonneg hs0 hs1 hp0
    · have hsle : s ≤ p := le_of_lt hs
      have hw : weight s p = s / p := by
        unfold weight
        rw [if_pos hppos, min_eq_right]
        rw [div_le_iff₀ hppos]
        linarith
      unfold cap
      rw [hw]
      have hrest : 0 ≤ 1 + (p - s) * (s / p) := by
        have hspan : 0 ≤ p - s := by linarith
        have hratio : 0 ≤ s / p := div_nonneg hs0 hppos.le
        nlinarith
      exact mul_nonneg hs0 hrest

theorem mix_unit {s p : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ mix s p ∧ mix s p ≤ 1 := by
  obtain ⟨hcm, hmb⟩ := cap_le_mix_le_blend hs0 hs1 hp0
  exact ⟨le_trans (cap_nonneg hs0 hs1 hp0 hp1) hcm, le_trans hmb (blend_le_one hp0 hp1)⟩

theorem clamp_id {s p : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    clamped s p = mix s p := by
  obtain ⟨h0, h1⟩ := mix_unit hs0 hs1 hp0 hp1
  unfold clamped
  rw [min_eq_right h1, max_eq_right h0]

theorem mix_cabin : mix 1 1 = 1 := by
  have hw : weight 1 1 = 1 := weight_one_of_ge (by norm_num) (by norm_num)
  unfold mix blend cap
  rw [hw]
  ring

theorem mix_surface : mix 0 0 = 0 := by
  unfold mix
  rw [cap_eq_blend_of_zero]
  unfold blend
  ring

theorem weightScored_eq_weight {s p : ℝ} (hp : pressureFloor < p) :
    weightScored s p = weight s p := by
  have hp0 : 0 < p := by
    have hf : (0 : ℝ) < pressureFloor := by norm_num [pressureFloor]
    linarith
  unfold weightScored weight
  rw [if_pos hp, if_pos hp0]

theorem weightScored_on_floor {s p : ℝ} (hp : p ≤ pressureFloor) : weightScored s p = 1 := by
  unfold weightScored
  rw [if_neg (by
    intro h
    exact absurd hp (not_le_of_gt h))]

theorem capScored_eq_blend_on_floor {s p : ℝ} (hp : p ≤ pressureFloor) :
    capScored s p = blend s p := by
  unfold capScored blend
  rw [weightScored_on_floor hp]
  ring

theorem mixScored_eq_blend_on_floor {s p : ℝ} (hp : p ≤ pressureFloor) :
    mixScored s p = blend s p := by
  unfold mixScored
  rw [capScored_eq_blend_on_floor hp]
  ring

theorem pressureFloor_sq : pressureFloor ^ 2 = 1 / 10000000000000000 := by
  unfold pressureFloor
  norm_num

/-- Below the scored pressure gate the two joins differ by at most `1e-16`. -/
theorem scored_close {s p : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    |mixScored s p - mix s p| ≤ 1 / 10000000000000000 := by
  rcases lt_or_ge pressureFloor p with hf | hf
  · have heq : mixScored s p = mix s p := by
      unfold mixScored mix capScored cap
      rw [weightScored_eq_weight (s := s) hf]
    rw [heq, sub_self, abs_zero]
    norm_num
  · have hsc : mixScored s p = blend s p := mixScored_eq_blend_on_floor hf
    rcases lt_or_eq_of_le hp0 with hppos | hp
    · rcases le_or_gt p s with hs | hs
      · have hm : mix s p = blend s p := mix_eq_blend_of_ge hppos hs
        rw [hsc, hm, sub_self, abs_zero]
        norm_num
      · have hsle : s ≤ p := le_of_lt hs
        have hdiff : mixScored s p - mix s p = (1 - s) * (blend s p - cap s p) := by
          rw [hsc, blend_sub_mix_factor]
        have hspan : 0 ≤ blend s p - cap s p := blend_sub_cap_nonneg hs0 hppos hsle
        have hpos : 0 ≤ mixScored s p - mix s p := by
          rw [hdiff]
          nlinarith
        have hle : mixScored s p - mix s p ≤ p ^ 2 := by
          rw [hdiff]
          have hshrink : (1 - s) * (blend s p - cap s p) ≤ blend s p - cap s p := by
            nlinarith
          linarith [blend_sub_cap_le_sq hs0 hppos hsle]
        rw [abs_of_nonneg hpos]
        have hsq : p ^ 2 ≤ pressureFloor ^ 2 := by
          have hfactor : pressureFloor ^ 2 - p ^ 2 = (pressureFloor - p) * (pressureFloor + p) := by
            ring
          nlinarith
        rw [pressureFloor_sq] at hsq
        linarith
    · subst hp
      have hm : mix s 0 = blend s 0 := by
        unfold mix
        rw [cap_eq_blend_of_zero]
        ring
      rw [hsc, hm, sub_self, abs_zero]
      norm_num

/-- The wall is one relaxation length. -/
theorem wall_one_length (R1 R2 ell : ℝ) : R1 = R2 * (1 - ell) ↔ R2 - R1 = ell * R2 := by
  constructor <;> intro h <;> linarith

theorem relaxation_sq {kappa gamma ell : ℝ} (hg : 0 < gamma) (hk : 0 ≤ kappa) (he : 0 ≤ ell) :
    ell = Real.sqrt (kappa / gamma) ↔ ell ^ 2 = kappa / gamma := by
  have hnonneg : 0 ≤ kappa / gamma := div_nonneg hk hg.le
  constructor
  · intro h
    rw [h, Real.sq_sqrt hnonneg]
  · intro h
    rw [← h, Real.sqrt_sq he]

/-- Printed clean bar from `dial_mix.txt`. These rationals are the printed digits. -/
structure CleanBar where
  nullWorst : ℚ
  weakWorst : ℚ
  strongWorst : ℚ
  dominantWorst : ℚ
  serious : ℚ
  energy : ℚ
  shift : ℚ
  requested : ℚ

def CleanBar.passes (b : CleanBar) : Prop :=
  b.nullWorst < 1 / 1000 ∧
    b.weakWorst < 1 / 1000 ∧
      b.strongWorst < 1 / 1000 ∧
        b.dominantWorst < 1 / 1000 ∧
          b.serious = 0 ∧ 0 < b.energy ∧ b.shift = b.requested

def mix010 : CleanBar where
  nullWorst := 6534 / 10000000
  weakWorst := 7887 / 10000000
  strongWorst := 6558 / 10000000
  dominantWorst := 6822 / 1000000000
  serious := 0
  energy := 40651 * 10 ^ 26
  shift := 1 / 10
  requested := 1 / 10

def mix0095 : CleanBar where
  nullWorst := 6459 / 10000000
  weakWorst := 7856 / 10000000
  strongWorst := 6488 / 10000000
  dominantWorst := 6830 / 1000000000
  serious := 0
  energy := 40664 * 10 ^ 26
  shift := 95 / 1000
  requested := 95 / 1000

theorem mix010_passes : mix010.passes := by
  unfold CleanBar.passes mix010
  norm_num

theorem mix0095_passes : mix0095.passes := by
  unfold CleanBar.passes mix0095
  norm_num

end

end WarpMix
