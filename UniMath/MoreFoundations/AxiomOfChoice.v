(** * Axiom of choice *)

Require Export UniMath.MoreFoundations.DecidablePropositions.

(** ** Preliminaries  *)

Lemma pr1_issurjective {X : hSet} {P : X -> UU} :
  (∏ x : X, ∥ P x ∥) -> issurjective (pr1 : (∑ x, P x) -> X).
(* move upstream later *)
Proof.
  intros ne x. simple refine (hinhuniv _ (ne x)).
  intros p. apply hinhpr.
  exact ((x,,p),,idpath _).
Defined.

(** ** Characterize equivalence relations on [bool] *)

Definition eqrel_on_bool (P:hProp) : eqrel boolset.
(* an equivalence relation on bool amounts to a single proposition *)
Proof.
  set (ifb := bool_rect (λ _:bool, hProp)).
  exists (λ x y, ifb (ifb htrue P y) (ifb P htrue y) x).
  repeat split.
  { intros x y z a b.
    induction x.
    - induction z.
      + exact tt.
      + induction y.
        * exact b.
        * exact a.
    - induction z.
      + induction y.
        * exact a.
        * exact b.
      + exact tt. }
  { intros x. induction x; exact tt. }
  { intros x y a. induction x; induction y; exact a. }
Defined.

Lemma eqrel_on_bool_iff (P:hProp) (E := eqrel_on_bool P) (f := setquotpr E) : f true = f false <-> P.
Proof.
  split.
  { intro q. change (E true false). apply (invmap (weqpathsinsetquot _ _ _)).
    change (f true = f false). exact q. }
  { intro p. apply iscompsetquotpr. exact p. }
Defined.

(** ** Statements of Axiom of Choice *)

Local Open Scope logic.

Local Open Scope set.

(** We write these axioms as types rather than as axioms, which would assert them to be true, to
    force them to be mentioned as explicit hypotheses whenever they are used. *)

Definition AxiomOfChoice : hProp := ∀ (X:hSet), ischoicebase X.

Definition AxiomOfChoice_surj : hProp :=
  ∀ (X:hSet) (Y:UU) (f:Y→X), issurjective f ⇒ ∃ g, ∀ x, f (g x) = x.
(** Notice that the equation above is a proposition only because X is a set, which is not required
    in the previous formulation.  The notation for "=" currently in effect uses [eqset] instead of
    [paths].  *)

(** ** Implications between forms of the Axiom of Choice *)

Lemma AC_impl2 : AxiomOfChoice <-> AxiomOfChoice_surj.
Proof.
  split.
  - intros AC X Y f surj.
    use (squash_to_prop (AC _ _ surj) (propproperty _)).
    intro s.
    use hinhpr.
    use tpair.
    + exact (λ y, hfiberpr1 f y (s y)).
    + exact (λ y, hfiberpr2 f y (s y)).
  - intros AC X P ne.
    use (hinhuniv _ (AC X _ _ (pr1_issurjective ne))).
    intros sec. use hinhpr. intros x.
    induction (pr2 sec x). exact (pr2 (pr1 sec x)).
Defined.

(** ** The Axiom of Choice implies the Law of the Excluded Middle  *)

(** This result is covered in the HoTT book, is due to Radu Diaconescu, "Axiom of choice and
    complementation", Proceedings of the American Mathematical Society, 51 (1975) 176–178, and was
    first mentioned on page 4 in F. W. Lawvere, "Toposes, algebraic geometry and logic (Conf.,
    Dalhousie Univ., Halifax, N.S., 1971)", pp. 1–12, Lecture Notes in Math., Vol. 274, Springer,
    Berlin, 1972.

    The idea is to define an equivalence relation E on bool by setting [E true false := P], to use
    AC to split the surjection f from bool to its quotient Y by E with a function g, and to observe
    bool has decidable equality, and thus so does Y, because then Y is a retract of bool, to use
    that to decide whether [f true = f false], and thus to decide P. *)

Theorem AC_to_LEM : AxiomOfChoice -> LEM.
Proof.
  intros AC P.
  set (f := setquotpr _ : bool -> setquotinset (eqrel_on_bool P)).
  assert (q := pr1 AC_impl2 AC _ _ f (issurjsetquotpr _)).
  apply (squash_to_prop q).
  { apply isapropdec, propproperty. }
  intro sec. induction sec as [g h].
  (* reduce decidability of P to decidability of [f true = f false] *)
  apply (logeq_dec (eqrel_on_bool_iff P)).
  (* a retract of a type with decidable equality has decidable equality *)
  apply (retract_dec f g h isdeceqbool).
Defined.


