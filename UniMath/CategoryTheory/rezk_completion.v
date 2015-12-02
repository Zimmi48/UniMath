
(** **********************************************************

Benedikt Ahrens, Chris Kapulkin, Mike Shulman

january 2013


************************************************************)


(** **********************************************************

Contents : Rezk completion

 - Construction of the Rezk completion via Yoneda

 - Universal property of the Rezk completion

************************************************************)


Require Import UniMath.Foundations.Basics.All.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.category_hset.
Require Import UniMath.CategoryTheory.yoneda.
Require Import UniMath.CategoryTheory.sub_precategories.
Require Import UniMath.CategoryTheory.equivalences.
Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.precomp_fully_faithful.
Require Import UniMath.CategoryTheory.precomp_ess_surj.

Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).

(** * Construction of the Rezk completion via Yoneda *)

Section rezk.

Variable A : precategory.
Hypothesis hsA: has_homsets A.

Definition Rezk_completion : category.
Proof.
  exists (full_img_sub_precategory (yoneda A hsA)).
  apply is_category_full_subcat.
  apply is_category_functor_category.
Defined.

Definition Rezk_eta : functor A Rezk_completion.
Proof.
  apply (functor_full_img (yoneda A hsA)).
Defined.

Lemma Rezk_eta_is_fully_faithful : fully_faithful Rezk_eta.
Proof.
  apply (functor_full_img_fully_faithful_if_fun_is _ _ (yoneda A hsA)).
  apply yoneda_fully_faithful.
Defined.

Lemma Rezk_eta_essentially_surjective : essentially_surjective Rezk_eta.
Proof.
  apply (functor_full_img_essentially_surjective _ _ (yoneda A hsA)).
Defined.

End rezk.

(** * Universal property of the Rezk completion *)

Definition functor_from (C : precategory) : UU
  := Σ D : category, functor C D.

Coercion target_category (C : precategory) (X : functor_from C) : category := pr1 X.
Definition func_functor_from {C : precategory} (X : functor_from C) : functor C X := pr2 X.

Definition is_initial_functor_from (C : precategory) (X : functor_from C) : UU
  := ∀ X' : functor_from C,
     ∃! H : functor X X',
       functor_composite (func_functor_from X) H = func_functor_from X'.

Section rezk_universal_property.

Variables A : precategory.
Hypothesis hsA: has_homsets A.

Section fix_a_category.

Variable C : precategory.
Hypothesis Ccat : is_category C.

Lemma pre_comp_rezk_eta_is_fully_faithful :
    fully_faithful (pre_composition_functor A (Rezk_completion A hsA) C
                (pr2 (pr2 (Rezk_completion A hsA))) (pr2 Ccat) ((Rezk_eta A hsA))).
Proof.
  apply pre_composition_with_ess_surj_and_fully_faithful_is_fully_faithful.
  apply Rezk_eta_essentially_surjective.
  apply Rezk_eta_is_fully_faithful.
Defined.

Lemma pre_comp_rezk_eta_is_ess_surj :
   essentially_surjective (pre_composition_functor A (Rezk_completion A hsA) C
   (pr2 (pr2 (Rezk_completion A hsA))) (pr2 Ccat)
   (Rezk_eta A hsA)).
Proof.
  apply pre_composition_essentially_surjective.
  apply Rezk_eta_essentially_surjective.
  apply Rezk_eta_is_fully_faithful.
Defined.

Theorem Rezk_eta_Universal_Property :
  isweq (pre_composition_functor A (Rezk_completion A hsA) C
   (pr2 (pr2 (Rezk_completion A hsA))) (pr2 Ccat) (Rezk_eta A hsA)).
Proof.
  apply (adj_equiv_of_cats_is_weq_of_objects _ _ (functor_category_has_homsets _ _ _  )
                                         (functor_category_has_homsets _ _ _ )).
  - apply is_category_functor_category;
    assumption.
  - apply is_category_functor_category;
    assumption.
  - pose (T:=@rad_equivalence_of_precats
           [Rezk_completion A hsA, C, pr2 Ccat]
           [A, C, pr2 Ccat]
           (is_category_functor_category _ _ _ )
           _
           (pre_comp_rezk_eta_is_fully_faithful)
           (pre_comp_rezk_eta_is_ess_surj)).
  apply T.
Defined.

Definition Rezk_weq : [Rezk_completion A hsA, C] (pr2 Ccat) ≃ [A, C] (pr2 Ccat)
  := weqpair _ Rezk_eta_Universal_Property.

End fix_a_category.

Lemma Rezk_initial_functor_from : is_initial_functor_from A
      (tpair _ (Rezk_completion A hsA) (Rezk_eta A hsA)).
Proof.
  intro D.
  destruct D as [D F].
  set (T:= Rezk_eta_Universal_Property D (pr2 D)).
  apply T.
Defined.

Lemma path_to_ctr (A' : UU) (B : A' -> UU) (isc : iscontr (total2 (fun a => B a)))
           (a : A') (p : B a) : a = pr1 (pr1 isc).
Proof.
  exact (maponpaths pr1 (pr2 isc (tpair _ a p))).
Defined.

Definition Rezk_completion_endo_is_identity (D : functor_from A)
           (DH : is_initial_functor_from A D)
  : ∀ X : functor D D, functor_composite (func_functor_from D) X = func_functor_from D
        ->
        X = functor_identity D.
Proof.
  intros X H.
  set (DH' := DH D).
  pathvia (pr1 (pr1 DH')).
  - apply path_to_ctr.
    apply H.
  - apply pathsinv0.
    apply path_to_ctr.
    apply functor_identity_right.
Defined.

(*
Definition Rezk_completion_unique_functor (D D' : functor_from A)
      (DH : is_initial_functor_from A D) (D'H : is_initial_functor_from A D') :
  is_left_adjoint  (pr1 (pr1 (DH D'))).
Proof.
  refine (tpair _ _ _ ).
  - apply (D'H D).
  - simpl.
    destruct (DH D') as [X H]. simpl.
    destruct (D'H D) as [X' H']. simpl.
    destruct X as [F H1].
    destruct X' as [F' H2]. simpl in *.
    set (TD:=Rezk_completion_endo_is_identity D DH).
    set (TD':=Rezk_completion_endo_is_identity D' D'H).
    destruct D as [D FF].
    destruct D' as [D' FF'].
    simpl in *.
    refine (tpair _ _ _ ). simpl.
    + refine (tpair _ _ _ ). simpl.
      set (TD1 := TD (functor_composite F F')).
      set (T:=Rezk_completion_endo_is_identity D DH).
    de
  apply (DH D').
Defined.



  : unit.
      (X : initial_functor_from A
*)

End rezk_universal_property.
