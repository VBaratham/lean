/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
import data.rbtree.basic
universe u

/- TODO(Leo): remove after we cleanup stdlib simp lemmas -/
local attribute [-simp] or.comm or.left_comm or.assoc and.comm and.left_comm and.assoc

namespace rbnode
variables {α : Type u} {lt : α → α → Prop}

lemma mem_of_min_eq (lt : α → α → Prop) [is_irrefl α lt] {a : α} {t : rbnode α} : t.min = some a → mem lt a t :=
begin
   induction t,
   { intros, contradiction },
   all_goals {
     cases lchild; simp [rbnode.min]; intro h,
     { injection h, subst val, simp [mem, irrefl_of lt a] },
     all_goals { rw [mem], simp [ih_1 h] } }
end

lemma mem_of_max_eq (lt : α → α → Prop) [is_irrefl α lt] {a : α} {t : rbnode α} : t.max = some a → mem lt a t :=
begin
   induction t,
   { intros, contradiction },
   all_goals {
     cases rchild; simp [rbnode.max]; intro h,
     { injection h, subst val, simp [mem, irrefl_of lt a] },
     all_goals { rw [mem], simp [ih_2 h] } }
end

variables [decidable_rel lt] [is_strict_weak_order α lt]

lemma eq_leaf_of_min_eq_none {t : rbnode α} : t.min = none → t = leaf :=
begin
  induction t,
  { intros, refl },
  all_goals {
    cases lchild; simp [rbnode.min]; intro h,
    { contradiction },
    all_goals { have := ih_1 h, contradiction } }
end

lemma eq_leaf_of_max_eq_none {t : rbnode α} : t.max = none → t = leaf :=
begin
  induction t,
  { intros, refl },
  all_goals {
    cases rchild; simp [rbnode.max]; intro h,
    { contradiction },
    all_goals { have := ih_2 h, contradiction } }
end

lemma min_is_minimal {a : α} {t : rbnode α} : ∀ {lo hi}, is_searchable lt t lo hi → t.min = some a → ∀ {b}, mem lt b t → a ≈[lt] b ∨ lt a b :=
begin
  induction t,
  { simp [strict_weak_order.equiv], intros _ _ hs hmin b, contradiction },
  all_goals {
    cases lchild; intros lo hi hs hmin b hmem,
    { simp [rbnode.min] at hmin, injection hmin, subst val,
      simp [mem] at hmem, cases hmem with heqv hmem,
      { left, exact heqv.swap },
      { have := lt_of_mem_right hs (by constructor) hmem,
        right, assumption } },
    all_goals {
      cases hs, simp [rbnode.min] at hmin,
      rw [mem] at hmem, blast_disjs,
      { exact ih_1 hs₁ hmin hmem },
      { have hmm       := mem_of_min_eq lt hmin,
        have a_lt_val  := lt_of_mem_left hs (by constructor) hmm,
        have a_lt_b    := lt_of_lt_of_incomp a_lt_val hmem.swap,
        right, assumption },
      { have hmm       := mem_of_min_eq lt hmin,
        have a_lt_b    := lt_of_mem_left_right hs (by constructor) hmm hmem,
        right, assumption } } }
end

lemma max_is_maximal {a : α} {t : rbnode α} : ∀ {lo hi}, is_searchable lt t lo hi → t.max = some a → ∀ {b}, mem lt b t → a ≈[lt] b ∨ lt b a :=
begin
  induction t,
  { simp [strict_weak_order.equiv], intros _ _ hs hmax b, contradiction },
  all_goals {
    cases rchild; intros lo hi hs hmax b hmem,
    { simp [rbnode.max] at hmax, injection hmax, subst val,
      simp [mem] at hmem, cases hmem with hmem heqv,
      { have := lt_of_mem_left hs (by constructor) hmem,
        right, assumption },
      { left, exact heqv.swap } },
    all_goals {
      cases hs, simp [rbnode.max] at hmax,
      rw [mem] at hmem, blast_disjs,
      { have hmm       := mem_of_max_eq lt hmax,
        have a_lt_b    := lt_of_mem_left_right hs (by constructor) hmem hmm,
        right, assumption },
      { have hmm       := mem_of_max_eq lt hmax,
        have val_lt_a  := lt_of_mem_right hs (by constructor) hmm,
        have a_lt_b    := lt_of_incomp_of_lt hmem val_lt_a,
        right, assumption },
      { exact ih_2 hs₂ hmax hmem } } }
end

end rbnode
