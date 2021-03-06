
Require Export A013sflib.

Module AExp.

Inductive aexp : Type :=
  | ANum : nat -> aexp
  | APlus : aexp -> aexp -> aexp
  | AMinus : aexp -> aexp -> aexp
  | AMult : aexp -> aexp -> aexp.

Inductive bexp : Type :=
  | BTrue : bexp
  | BFalse : bexp
  | BEq : aexp -> aexp -> bexp
  | BLe : aexp -> aexp -> bexp
  | BNot : bexp -> bexp
  | BAnd : bexp -> bexp -> bexp.

Fixpoint aeval (e : aexp) : nat :=
  match e with
    | ANum n => n
    | APlus a b => (aeval a) + (aeval b)
    | AMinus a b => (aeval a) - (aeval b)
    | AMult a b => (aeval a) * (aeval b)
  end.

(* SearchAbout (bool). *)

Fixpoint beval (e : bexp) : bool :=
  match e with
    | BTrue => true
    | BFalse => false
    | BEq a b => beq_nat (aeval a) (aeval b)
    | BLe a b => ble_nat (aeval a) (aeval b)
    | BNot a => negb (beval a)
    | BAnd a b => andb (beval a) (beval b)
  end.


Fixpoint optimize_0plus (a:aexp) : aexp :=
  match a with
  | ANum n =>
      ANum n
  | APlus (ANum 0) e2 =>
      optimize_0plus e2
  | APlus e1 e2 =>
      APlus (optimize_0plus e1) (optimize_0plus e2)
  | AMinus e1 e2 =>
      AMinus (optimize_0plus e1) (optimize_0plus e2)
  | AMult e1 e2 =>
      AMult (optimize_0plus e1) (optimize_0plus e2)
  end.

Example test_optimize_0plus:
  optimize_0plus (APlus (ANum 2)
                        (APlus (ANum 0)
                               (APlus (ANum 0) (ANum 1))))
  = APlus (ANum 2) (ANum 1).
Proof. reflexivity. Qed. (* 2 + (0 + (0 + 1)) *)


Theorem optimize_0plus_sound: forall a,
  aeval (optimize_0plus a) = aeval a.
Proof.
  intros.
  induction a.

  Case "ANum". reflexivity.
  Case "APlus".
    destruct a1.
    SCase "ANum".
      destruct n.
      SSCase "n == 0". assumption.
      SSCase "n <> 0". simpl. rewrite IHa2. reflexivity.
    SCase "APlus".
      simpl in IHa1. simpl. rewrite IHa1. rewrite IHa2. reflexivity.
    SCase "AMinus".
      simpl in IHa1. simpl. rewrite IHa1. rewrite IHa2. reflexivity.
    SCase "AMult".
      simpl in IHa1. simpl. rewrite IHa1. rewrite IHa2. reflexivity.
  Case "AMinus".
    simpl. rewrite IHa1. rewrite IHa2. reflexivity.
  Case "AMult".
    simpl. rewrite IHa1. rewrite IHa2. reflexivity.
Qed.

(*
Theorem optimize_0plus_sound': forall a,
  aeval (optimize_0plus a) = aeval a.
Proof.
  intros.
  induction a; try (simpl; rewrite IHa1; rewrite IHa2; reflexivity).
  reflexivity.
  destruct a1; try (simpl in IHa1; simpl; rewrite IHa1; rewrite IHa2; reflexivity).
  destruct n; [assumption | simpl; rewrite IHa2; reflexivity].
Qed.

Theorem optimize_0plus_sound'': forall a,
  aeval (optimize_0plus a) = aeval a.
Proof.
  intros.
  induction a; try (simpl; rewrite IHa1; rewrite IHa2; reflexivity); try reflexivity.
  destruct a1; try (simpl; simpl in IHa1; rewrite IHa1; rewrite IHa2; reflexivity).
  destruct n; simpl; rewrite IHa2; reflexivity.
Qed.
*)

Tactic Notation "aexp_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "ANum" | Case_aux c "APlus"
  | Case_aux c "AMinus" | Case_aux c "AMult" ].

Fixpoint optimize_0plus_b (b : bexp) : bexp :=
  match b with
    | BTrue => BTrue
    | BFalse => BFalse
    | BEq a b => BEq (optimize_0plus a) (optimize_0plus b)
    | BLe a b => BLe (optimize_0plus a) (optimize_0plus b)
    | BNot BTrue => BFalse
    | BNot BFalse => BTrue
    | BNot a => BNot (optimize_0plus_b a)
    | BAnd BTrue BFalse => BFalse
    | BAnd BFalse _ => BFalse
    | BAnd BTrue b => (optimize_0plus_b b)
    | BAnd a b => BAnd (optimize_0plus_b a) (optimize_0plus_b b)
  end.

Theorem optimize_0plus_b_sound : forall b,
  beval (optimize_0plus_b b) = beval b.
Proof.
  intro.
  induction b;
    try reflexivity;
    try (simpl; repeat rewrite optimize_0plus_sound; reflexivity);
    try (destruct b;
         try reflexivity;
         try (simpl; repeat rewrite optimize_0plus_sound; reflexivity);
         try (simpl; simpl in IHb; rewrite IHb; reflexivity)).
  Case "BAnd b1 b2".
  destruct b1; destruct b2;
      try reflexivity;
      try (simpl; repeat rewrite optimize_0plus_sound; reflexivity);
      try (simpl; simpl in IHb2; rewrite IHb2;
           try repeat rewrite optimize_0plus_sound;
           reflexivity);
      try (simpl; simpl in IHb1; rewrite IHb1; try repeat rewrite optimize_0plus_sound;
           reflexivity);
      try (simpl; simpl in IHb1; rewrite IHb1; simpl in IHb2; rewrite IHb2; reflexivity).
Qed.



Fixpoint optimize_0plus' (a:aexp) : aexp :=
  match a with
  | ANum n => ANum n
  | APlus (ANum 0) e2 => optimize_0plus' e2
  | APlus e1 (ANum 0) => optimize_0plus' e1
  | APlus e1 e2 => APlus (optimize_0plus' e1) (optimize_0plus' e2)
  | AMinus e1 (ANum 0) => optimize_0plus' e1
  | AMinus e1 e2 => AMinus (optimize_0plus' e1) (optimize_0plus' e2)
  | AMult (ANum 0) e2 => ANum 0
  | AMult e1 (ANum 0) => ANum 0
  | AMult (ANum 1) e2 => optimize_0plus' e2
  | AMult e1 (ANum 1) => optimize_0plus' e1
  | AMult e1 e2 => AMult (optimize_0plus' e1) (optimize_0plus' e2)
  end.


Theorem optimize_0plus_sound': forall a,
  aeval (optimize_0plus' a) = aeval a.
Proof.
  intros.
  induction a; try reflexivity.
  Case "APlus".
    destruct a1;
      try destruct n; [simpl; assumption
                       | destruct a2; try (destruct n0;
                                         try (simpl; rewrite plus_0_r; reflexivity);
                                         try (simpl; reflexivity))
                       | .. ].
admit. (* 懶得寫完 *)
Admitted.


Example silly_presburger_example : forall m n o p,
  m + n <= n + o /\ o + 3 = p + 3 ->
  m <= p.
Proof.
  intros.
  omega.
Qed.


Module aevalR_first_try.

Reserved Notation "e '||' n" (at level 50, left associativity).

Inductive aevalR : aexp -> nat -> Prop :=
  | E_ANum : forall (n: nat), (ANum n) || n
  | E_APlus : forall (e1 e2: aexp) (n1 n2: nat),
      e1 || n1 -> e2 || n2 -> (APlus e1 e2) || (n1 + n2)
  | E_AMinus: forall (e1 e2: aexp) (n1 n2: nat),
      e1 || n1 -> e2 || n2 -> (AMinus e1 e2) || (n1 - n2)
  | E_AMult : forall (e1 e2: aexp) (n1 n2: nat),
      e1 || n1 -> e2 || n2 -> (AMult e1 e2) || (n1 * n2)
  where "e '||' n" := (aevalR e n) : type_scope.

Tactic Notation "aevalR_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "E_ANum" | Case_aux c "E_APlus"
  | Case_aux c "E_AMinus" | Case_aux c "E_AMult" ].

Theorem aeval_iff_aevalR : forall a n,
  (a || n) <-> aeval a = n.
Proof.
  intros. split.

  Case "->". intros H; induction H; subst; reflexivity.
  Case "<-".
  generalize dependent n.
  aevalR_cases (induction a) SCase;
    intros; subst; simpl; constructor;
    try apply IHa1; try apply IHa2; try reflexivity.
Qed.

(*
Fixpoint beval (e : bexp) : bool :=
  match e with
    | BTrue => true
    | BFalse => false
    | BEq a b => beq_nat (aeval a) (aeval b)
    | BLe a b => ble_nat (aeval a) (aeval b)
    | BNot a => negb (beval a)
    | BAnd a b => andb (beval a) (beval b)
  end.
*)

Reserved Notation "e '//' b" (at level 50, left associativity).

Inductive bevalR : bexp -> bool -> Prop :=
  | E_BTrue : BTrue // true
  | E_BFalse : BFalse // false
  | E_BEq : forall (a b : aexp) (a' b' : nat),
              a || a' -> b || b' -> BEq a b // beq_nat a' b'
  | E_BLe : forall a b a' b',
              a || a' -> b || b' -> BLe a b // ble_nat a' b'
  | E_BNot : forall a a', a // a' -> BNot a // negb a'
  | E_BAnd : forall a b a' b',
               a // a' -> b // b' -> BAnd a b // andb a' b'
  where "e '//' b" := (bevalR e b) : type_scope.



Theorem beval_iff_bevalR : forall a b,
  (a // b) <-> beval a = b.
Proof.
  intros. split; intros.

  Case "->".
    induction H;
    try (apply aeval_iff_aevalR in H; apply aeval_iff_aevalR in H0);
    subst; reflexivity.

  Case "<-".
    generalize dependent b.
    induction a;
    intros; subst; constructor; try (apply aeval_iff_aevalR; reflexivity);
    try (apply IHa; reflexivity);
    try (apply IHa1; reflexivity);
    try (apply IHa2; reflexivity).
Qed.

End aevalR_first_try.
End AExp.


(* To show how relational definitions are preferrable to computational definitions
   in the condition of non-deterministic cases.
*)
Module aevalR_division.

Inductive aexp : Type :=
  | ANum : nat -> aexp
  | APlus : aexp -> aexp -> aexp
  | AMinus : aexp -> aexp -> aexp
  | AMult : aexp -> aexp -> aexp
  | ADiv : aexp -> aexp -> aexp. (* <--- new *)

Inductive aevalR : aexp -> nat -> Prop :=
  | E_ANum : forall (n:nat),
      (ANum n) || n
  | E_APlus : forall (a1 a2: aexp) (n1 n2 : nat),
      (a1 || n1) -> (a2 || n2) -> (APlus a1 a2) || (n1 + n2)
  | E_AMinus : forall (a1 a2: aexp) (n1 n2 : nat),
      (a1 || n1) -> (a2 || n2) -> (AMinus a1 a2) || (n1 - n2)
  | E_AMult : forall (a1 a2: aexp) (n1 n2 : nat),
      (a1 || n1) -> (a2 || n2) -> (AMult a1 a2) || (n1 * n2)
  | E_ADiv : forall (a1 a2: aexp) (n1 n2 n3: nat),
      (a1 || n1) -> (a2 || n2) -> (mult n2 n3 = n1) -> (ADiv a1 a2) || n3

where "a '||' n" := (aevalR a n) : type_scope.

End aevalR_division.

Module aevalR_extended.
Inductive aexp : Type :=
  | AAny : aexp (* <--- NEW *)
  | ANum : nat -> aexp
  | APlus : aexp -> aexp -> aexp
  | AMinus : aexp -> aexp -> aexp
  | AMult : aexp -> aexp -> aexp.


Inductive aevalR : aexp -> nat -> Prop :=
  | E_Any : forall (n:nat),
      AAny || n (* <--- new *)
  | E_ANum : forall (n:nat),
      (ANum n) || n
  | E_APlus : forall (a1 a2: aexp) (n1 n2 : nat),
      (a1 || n1) -> (a2 || n2) -> (APlus a1 a2) || (n1 + n2)
  | E_AMinus : forall (a1 a2: aexp) (n1 n2 : nat),
      (a1 || n1) -> (a2 || n2) -> (AMinus a1 a2) || (n1 - n2)
  | E_AMult : forall (a1 a2: aexp) (n1 n2 : nat),
      (a1 || n1) -> (a2 || n2) -> (AMult a1 a2) || (n1 * n2)

where "a '||' n" := (aevalR a n) : type_scope.

End aevalR_extended.

Module Id.

Inductive id : Type :=
  Id : nat -> id.

Theorem eq_id_dec : forall id1 id2 : id, {id1 = id2} + {id1 <> id2}.
Proof.
  intros.
  destruct id1, id2.
  destruct (eq_nat_dec n n0).
  subst. left. reflexivity.
  right. intro. inversion H.  apply n1 in H1. contradiction.
Qed.

Lemma eq_id : forall (T:Type) x (p q:T),
              (if eq_id_dec x x then p else q) = p.
Proof.
  intros.
  destruct (eq_id_dec x x).
  reflexivity.
  apply ex_falso_quodlibet. apply n. reflexivity.
Qed.

Lemma neq_id : forall (T:Type) x y (p q:T), x <> y ->
               (if eq_id_dec x y then p else q) = q.
Proof.
  intros.
  destruct (eq_id_dec x y).
  apply H in e. inversion e.
  reflexivity.
Qed.

End Id.

Definition state := id -> nat.

Definition empty_state : state :=
  fun _ => 0.

Definition update (st : state) (x : id) (n : nat) : state :=
  fun x' => if eq_id_dec x x' then n else st x'.

Theorem update_eq : forall n x st,
  (update st x n) x = n.
Proof.
  intros.
  unfold update.
  apply eq_id.
Qed.


Theorem update_neq : forall x2 x1 n st,
  x2 <> x1 ->
  (update st x2 n) x1 = (st x1).
Proof.
  unfold update.
  intros.
  apply neq_id. assumption.
Qed.

Theorem update_example : forall (n:nat),
  (update empty_state (Id 2) n) (Id 3) = 0.
Proof.
  intros. unfold update.
  simpl. unfold empty_state.
  reflexivity.
Qed.


Theorem update_shadow : forall n1 n2 x1 x2 (st : state),
   (update (update st x2 n1) x2 n2) x1 = (update st x2 n2) x1.
Proof.
  intros.
  destruct (eq_id_dec x2 x1); unfold update.

  subst. rewrite eq_id. symmetry. apply eq_id.
  rewrite neq_id; [rewrite neq_id; [symmetry; apply neq_id; assumption
                                   | assumption]
                  | assumption].
Qed.

Theorem update_same : forall n1 x1 x2 (st : state),
  st x1 = n1 ->
  (update st x1 n1) x2 = st x2.
Proof.
  intros.
  destruct (eq_id_dec x1 x2); unfold update.

  subst. apply eq_id.
  subst. apply neq_id. assumption.
Qed.


Theorem update_permute : forall n1 n2 x1 x2 x3 st,
  x2 <> x1 ->
  (update (update st x2 n1) x1 n2) x3 = (update (update st x1 n2) x2 n1) x3.
Proof.
  intros.
  destruct (eq_id_dec x2 x3).

  Case "x2 == x3".
  unfold update. subst. repeat rewrite eq_id. apply neq_id.
  intro. symmetry in H0. apply H in H0. contradiction.

  destruct (eq_id_dec x1 x3).
  Case "x2 <> x3, x1 == x3".
  subst. unfold update. repeat rewrite eq_id. symmetry. apply neq_id. assumption.

  Case "x2 <> x3 <> x1".
  subst. unfold update. repeat rewrite neq_id; try reflexivity; try assumption.
Qed.

Inductive aexp : Type :=
  | ANum : nat -> aexp
  | AId : id -> aexp (* <----- NEW *)
  | APlus : aexp -> aexp -> aexp
  | AMinus : aexp -> aexp -> aexp
  | AMult : aexp -> aexp -> aexp.

Tactic Notation "aexp_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "ANum" | Case_aux c "AId" | Case_aux c "APlus"
  | Case_aux c "AMinus" | Case_aux c "AMult" ].

Definition X : id := Id 0.
Definition Y : id := Id 1.
Definition Z : id := Id 2.

(* The definition of bexps is the same as before (using the new aexps) *)
Inductive bexp : Type :=
  | BTrue : bexp
  | BFalse : bexp
  | BEq : aexp -> aexp -> bexp
  | BLe : aexp -> aexp -> bexp
  | BNot : bexp -> bexp
  | BAnd : bexp -> bexp -> bexp.

Tactic Notation "bexp_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "BTrue" | Case_aux c "BFalse" | Case_aux c "BEq"
  | Case_aux c "BLe" | Case_aux c "BNot" | Case_aux c "BAnd" ].

Fixpoint aeval (st : state) (a : aexp) : nat :=
  match a with
  | ANum n => n
  | AId x => st x (* <----- NEW *)
  | APlus a1 a2 => (aeval st a1) + (aeval st a2)
  | AMinus a1 a2 => (aeval st a1) - (aeval st a2)
  | AMult a1 a2 => (aeval st a1) * (aeval st a2)
  end.

Fixpoint beval (st : state) (b : bexp) : bool :=
  match b with
  | BTrue => true
  | BFalse => false
  | BEq a1 a2 => beq_nat (aeval st a1) (aeval st a2)
  | BLe a1 a2 => ble_nat (aeval st a1) (aeval st a2)
  | BNot b1 => negb (beval st b1)
  | BAnd b1 b2 => andb (beval st b1) (beval st b2)
  end.

Example aexp1 :
  aeval (update empty_state X 5)
        (APlus (ANum 3) (AMult (AId X) (ANum 2)))
  = 13.
Proof. reflexivity. Qed.

Example bexp1 :
  beval (update empty_state X 5)
        (BAnd BTrue (BNot (BLe (AId X) (ANum 4))))
  = true.
Proof. reflexivity. Qed.

Inductive com : Type :=
  | CSkip : com
  | CAss : id -> aexp -> com
  | CSeq : com -> com -> com
  | CIf : bexp -> com -> com -> com
  | CWhile : bexp -> com -> com.

Tactic Notation "com_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "SKIP" | Case_aux c "::=" | Case_aux c ";;"
  | Case_aux c "IFB" | Case_aux c "WHILE" ].

Notation "'SKIP'" :=
  CSkip.
Notation "x '::=' a" :=
  (CAss x a) (at level 60).
Notation "c1 ;; c2" :=
  (CSeq c1 c2) (at level 80, right associativity).
Notation "'WHILE' b 'DO' c 'END'" :=
  (CWhile b c) (at level 80, right associativity).
Notation "'IFB' c1 'THEN' c2 'ELSE' c3 'FI'" :=
  (CIf c1 c2 c3) (at level 80, right associativity).

Definition fact_in_coq : com :=
  Z ::= AId X;;
  Y ::= ANum 1;;
  WHILE BNot (BEq (AId Z) (ANum 0)) DO
    Y ::= AMult (AId Y) (AId Z);;
    Z ::= AMinus (AId Z) (ANum 1)
  END.

Definition plus2 : com :=
  X ::= (APlus (AId X) (ANum 2)).


Definition XtimesYinZ : com :=
  Z ::= (AMult (AId X) (AId Y)).

Definition subtract_slowly_body : com :=
  Z ::= AMinus (AId Z) (ANum 1) ;;
  X ::= AMinus (AId X) (ANum 1).

Definition subtract_slowly : com :=
  WHILE BNot (BEq (AId X) (ANum 0)) DO
    subtract_slowly_body
  END.

Definition subtract_3_from_5_slowly : com :=
  X ::= ANum 3 ;;
  Z ::= ANum 5 ;;
  subtract_slowly.

Definition loop : com :=
  WHILE BTrue DO
    SKIP
  END.


Fixpoint ceval_fun_no_while (st : state) (c : com) : state :=
  match c with
    | SKIP => st
    | x ::= a1 => update st x (aeval st a1)
    | c1 ;; c2 => let st' := ceval_fun_no_while st c1
                  in ceval_fun_no_while st' c2
    | IFB b THEN c1 ELSE c2 FI => if (beval st b)
                                  then ceval_fun_no_while st c1
                                  else ceval_fun_no_while st c2
    | WHILE b DO c END => st (* bogus *)
  end.

(*
Fixpoint my_ceval_fun (st : state) (c : com) : state :=
  match c with
    | SKIP => st
    | x ::= a1 => update st x (aeval st a1)
    | c1 ;; c2 => let st' := my_ceval_fun st c1
                  in my_ceval_fun st' c2
    | IFB b THEN c1 ELSE c2 FI => if (beval st b)
                                  then my_ceval_fun st c1
                                  else my_ceval_fun st c2
    | WHILE b DO c' END => if (beval st b)
                           then let st' := my_ceval_fun st c'
                                in my_ceval_fun st' c
                           else st
  end. (* Error: Cannot guess decreasing argument of fix. *)
*)


Reserved Notation "c1 '/' st '||' st'" (at level 40, st at level 39).

Inductive ceval : com -> state -> state -> Prop :=
  | E_Skip : forall st,
      SKIP / st || st
  | E_Ass : forall st a1 n x,
      aeval st a1 = n ->
      (x ::= a1) / st || (update st x n)
  | E_Seq : forall c1 c2 st st' st'',
      c1 / st || st' ->
      c2 / st' || st'' ->
      (c1 ;; c2) / st || st''
  | E_IfTrue : forall st st' b c1 c2,
      beval st b = true ->
      c1 / st || st' ->
      (IFB b THEN c1 ELSE c2 FI) / st || st'
  | E_IfFalse : forall st st' b c1 c2,
      beval st b = false ->
      c2 / st || st' ->
      (IFB b THEN c1 ELSE c2 FI) / st || st'
  | E_WhileEnd : forall b st c,
      beval st b = false ->
      (WHILE b DO c END) / st || st
  | E_WhileLoop : forall st st' st'' b c,
      beval st b = true ->
      c / st || st' ->
      (WHILE b DO c END) / st' || st'' ->
      (WHILE b DO c END) / st || st''

  where "c1 '/' st '||' st'" := (ceval c1 st st').

Tactic Notation "ceval_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "E_Skip" | Case_aux c "E_Ass" | Case_aux c "E_Seq"
  | Case_aux c "E_IfTrue" | Case_aux c "E_IfFalse"
  | Case_aux c "E_WhileEnd" | Case_aux c "E_WhileLoop" ].


Example ceval_example2:
    (X ::= ANum 0;; Y ::= ANum 1;; Z ::= ANum 2) / empty_state ||
    (update (update (update empty_state X 0) Y 1) Z 2).
Proof.
  apply E_Seq with (update empty_state X 0). constructor. reflexivity.
  apply E_Seq with (update (update empty_state X 0) Y 1);
    constructor; simpl; reflexivity.
Qed.


Definition pup_to_n : com :=
  Y ::= ANum 0;;
  WHILE (BNot (BEq (AId X) (ANum 0))) DO
    Y ::= APlus (AId Y) (AId X);;
    X ::= AMinus (AId X) (ANum 1)
  END.

Theorem pup_to_2_ceval :
  pup_to_n / (update empty_state X 2) ||
    update (update (update (update (update (update empty_state
      X 2) Y 0) Y 2) X 1) Y 3) X 0.
Proof.
  unfold pup_to_n.
  apply E_Seq with (update (update empty_state X 2) Y 0).
  constructor. reflexivity.

  apply E_WhileLoop with (update (update (update (update empty_state X 2) Y 0) Y 2) X 1).
  reflexivity. apply E_Seq with (update (update (update empty_state X 2) Y 0) Y 2);
               try (constructor; reflexivity).

  apply E_WhileLoop with (update (update
           (update (update (update (update empty_state X 2) Y 0) Y 2) X 1) Y
           3) X 0).
  reflexivity.
  apply E_Seq with
    (update (update (update (update (update empty_state X 2) Y 0) Y 2) X 1) Y 3);
    try (constructor; reflexivity).

  apply E_WhileEnd. reflexivity.
Qed.


Theorem ceval_deterministic: forall c st st1 st2,
     c / st || st1 ->
     c / st || st2 ->
     st1 = st2.
Proof.
  intros. generalize dependent st2.
  ceval_cases (induction H) Case;
    (* Skip & Ass *)
    try (intros; subst; inversion H0; subst; reflexivity).

  (* Seq *)
  intros. inversion H1. subst.
  apply IHceval1 in H4. subst.
  apply IHceval2 in H7. subst. reflexivity.

  (* If True *)
  intros. inversion H1; subst.
  apply IHceval in H8. assumption.
  destruct (beval st b). inversion H7. inversion H.

  (* If False *)
  intros. inversion H1; subst.
  destruct (beval st b). inversion H. inversion H7.
  apply IHceval in H8. assumption.

  (* While End *)
  intros. inversion H0; subst. reflexivity.
  destruct (beval st b). inversion H. inversion H3.

  (* While Loop *)
  intros. inversion H1; subst.
  inversion H2; subst.
    destruct (beval st2 b). inversion H8. inversion H.
    apply IHceval1 in H6. subst. apply IHceval2 in H10. assumption.
  inversion H2; subst.
    destruct (beval st2 b). inversion H10. inversion H.
    apply IHceval1 in H8. subst. apply IHceval2 in H12. assumption.
Qed.


Theorem plus2_spec : forall st n st',
  st X = n ->
  plus2 / st || st' ->
  st' X = n + 2.
Proof.
  unfold plus2.
  intros.
  inversion H0. subst. clear.
  unfold update. reflexivity.
Qed.

Theorem xtimesyinz_spec : forall st n m st',
  st X = n ->
  st Y = m ->
  XtimesYinZ / st || st' ->
  st' Z = n * m.
Proof.
  unfold XtimesYinZ. intros. inversion H1. subst. clear.
  unfold update. reflexivity.
Qed.

Theorem loop_never_stops : forall st st',
  ~(loop / st || st').
Proof.
  intros st st' contra. unfold loop in contra.
  remember (WHILE BTrue DO SKIP END) as loopdef eqn:Heqloopdef.
  induction contra; try inversion Heqloopdef.
  subst. inversion H.
  subst. apply IHcontra2. reflexivity.
Qed.

Fixpoint no_whiles (c : com) : bool :=
  match c with
  | SKIP => true
  | _ ::= _ => true
  | c1 ;; c2 => andb (no_whiles c1) (no_whiles c2)
  | IFB _ THEN ct ELSE cf FI => andb (no_whiles ct) (no_whiles cf)
  | WHILE _ DO _ END => false
  end.

Inductive no_whilesR : com -> Prop :=
  | nwSKip : no_whilesR SKIP
  | nwAss : forall x a, no_whilesR (x ::= a)
  | nwSeq : forall a b, no_whilesR a -> no_whilesR b -> no_whilesR (a ;; b)
  | nwIf : forall b c1 c2, no_whilesR c1
                         -> no_whilesR c2
                         -> no_whilesR (IFB b THEN c1 ELSE c2 FI).

Theorem no_whiles_eqv:
   forall c, no_whiles c = true <-> no_whilesR c.
Proof.
  intros. split; intro.
  Case "->".
    induction c; try constructor;
      try (inversion H;
           try (apply IHc1; apply andb_true_elim1 in H1);
           try (apply IHc2; apply andb_true_elim2 in H1);
           assumption).

  Case "<-".
    induction H; try reflexivity; try (simpl; apply andb_true_intro; split; assumption).
Qed.

Theorem no_whiles_terminating :
  forall c, no_whilesR c ->
            forall st, exists st', c / st || st'.
Proof.
  intros. generalize dependent st.
  induction H; intro.

  Case "Skip".
    exists st. constructor.
  Case "Ass".
    exists (update st x (aeval st a)).
    constructor. reflexivity.

  Case "Seq".
    specialize IHno_whilesR1 with st.
    inversion IHno_whilesR1 as [st'].
    specialize IHno_whilesR2 with st'.
    inversion IHno_whilesR2 as [st''].
    exists st''. apply E_Seq with st'; assumption.

  Case "If".
    specialize IHno_whilesR1 with st.
    specialize IHno_whilesR2 with st.
    inversion IHno_whilesR1 as [stt].
    inversion IHno_whilesR2 as [stf].
    destruct (beval st b) eqn:eq.
    exists stt. apply E_IfTrue; assumption.
    exists stf. apply E_IfFalse; assumption.
Qed.

(* stack compiler *)
Inductive sinstr : Type :=
| SPush : nat -> sinstr
| SLoad : id -> sinstr
| SPlus : sinstr
| SMinus : sinstr
| SMult : sinstr.

Fixpoint s_execute (st : state) (stack : list nat)
                   (prog : list sinstr)
                 : list nat :=
  match prog with
    | nil => stack
    | (x :: xs) =>
      match x with
        | SPush a => s_execute st (a :: stack) xs
        | SLoad a => s_execute st (st a :: stack) xs
        | SPlus => match stack with
                     | (a::b::stack') => s_execute st ((b + a)::stack') xs
                     | _ => stack (* error *)
                   end
        | SMinus => match stack with
                      | (a::b::stack') => s_execute st ((b - a)::stack') xs
                      | _ => stack (* error *)
                    end
        | SMult => match stack with
                     | (a::b::stack') => s_execute st ((b * a)::stack') xs
                     | _ => stack (* error *)
                   end
      end
  end.


Example s_execute1 :
     s_execute empty_state []
       [SPush 5; SPush 3; SPush 1; SMinus]
   = [2; 5].
Proof. unfold s_execute. reflexivity. Qed.

Example s_execute2 :
     s_execute (update empty_state X 3) [3;4]
       [SPush 4; SLoad X; SMult; SPlus]
   = [15; 4].
Proof. unfold s_execute. reflexivity. Qed.

Fixpoint s_compile (e : aexp) : list sinstr :=
  match e with
    | ANum n => [SPush n]
    | AId i => [SLoad i]
    | APlus a b => (s_compile a) ++ (s_compile b) ++ [SPlus]
    | AMinus a b => (s_compile a) ++ (s_compile b) ++ [SMinus]
    | AMult a b => (s_compile a) ++ (s_compile b) ++ [SMult]
  end.

Example s_compile1 :
    s_compile (AMinus (AId X) (AMult (ANum 2) (AId Y)))
  = [SLoad X; SPush 2; SLoad Y; SMult; SMinus].
Proof. reflexivity. Qed.


Lemma s_compile_correct_aux1 :
  forall st e stack prog,
    s_execute st stack (s_compile e ++ prog) = s_execute st (aeval st e :: stack) prog.
Proof.
  induction e; try reflexivity; try (simpl; intros);
  try (repeat rewrite <- app_assoc; rewrite IHe1; rewrite IHe2; reflexivity).
Qed.

Lemma s_compile_correct_aux2 :
  forall st e1 e2 a1 a2 op,
    aeval st e1 = a1 ->
    aeval st e2 = a2 ->
    s_execute st [] (s_compile e1 ++ s_compile e2 ++ [op]) =
    s_execute st [a2 ; a1] [op].
Proof.
  intros. rewrite <- H. rewrite <- H0.
  repeat rewrite s_compile_correct_aux1.
  reflexivity.
Qed.

(*
  IHe1 : s_execute st [] (s_compile e1) = [aeval st e1]
  IHe2 : s_execute st [] (s_compile e2) = [aeval st e2]
  ============================
   s_execute st [] (s_compile e1 ++ s_compile e2 ++ [SPlus]) =
   [aeval st e1 + aeval st e2]
*)

Theorem s_compile_correct : forall (st : state) (e : aexp),
  s_execute st [] (s_compile e) = [ aeval st e ].
Proof.
  intros.
  induction e;
  simpl;
  try rewrite (s_compile_correct_aux2 st e1 e2 (aeval st e1) (aeval st e2));
  reflexivity.
Qed.


Module BreakImp.

Inductive com : Type :=
  | CSkip : com
  | CBreak : com
  | CAss : id -> aexp -> com
  | CSeq : com -> com -> com
  | CIf : bexp -> com -> com -> com
  | CWhile : bexp -> com -> com.

Tactic Notation "com_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "SKIP" | Case_aux c "BREAK" | Case_aux c "::=" | Case_aux c ";"
  | Case_aux c "IFB" | Case_aux c "WHILE" ].

Notation "'SKIP'" :=
  CSkip.
Notation "'BREAK'" :=
  CBreak.
Notation "x '::=' a" :=
  (CAss x a) (at level 60).
Notation "c1 ;; c2" :=
  (CSeq c1 c2) (at level 80, right associativity).
Notation "'WHILE' b 'DO' c 'END'" :=
  (CWhile b c) (at level 80, right associativity).
Notation "'IFB' c1 'THEN' c2 'ELSE' c3 'FI'" :=
  (CIf c1 c2 c3) (at level 80, right associativity).

Inductive status : Type :=
  | SContinue : status
  | SBreak : status.

Reserved Notation "c1 '/' st '||' s '/' st'"
                  (at level 40, st, s at level 39).

Inductive ceval : com -> state -> status -> state -> Prop :=
  | E_Skip : forall st,
      CSkip / st || SContinue / st
  | E_Break : forall st,
      CBreak / st || SBreak / st
  | E_Ass : forall i a st,
      (i ::= a) / st || SContinue / (update st i (aeval st a))
  | E_Seq_Break : forall st st' c1,
      c1 / st || SBreak / st' -> forall c2,
      (c1 ;; c2) / st || SBreak / st'
  | E_Seq_Cont : forall st st'  c1,
      c1 / st  || SContinue / st' -> forall c2 s st'',
      c2 / st' || s / st'' ->
      (c1 ;; c2) / st || s / st''
  | E_If_True : forall b st st' s ift iff,
      beval st b = true ->
      ift / st || s / st' ->
      IFB b THEN ift ELSE iff FI / st || s / st'
  | E_If_False : forall b st st' s ift iff,
      beval st b = false ->
      iff / st || s / st' ->
      IFB b THEN ift ELSE iff FI / st || s / st'
  | E_While_Stop : forall b c st,
      beval st b = false ->
      WHILE b DO c END / st || SContinue / st
  | E_While_Cont : forall b c st st' st'',
      c / st || SContinue / st' ->
      beval st b = true ->
      WHILE b DO c END / st' || SContinue / st'' ->
      WHILE b DO c END / st || SContinue / st''
  | E_While_Break : forall b c st st',
      c / st || SBreak / st' ->
      beval st b = true ->
      WHILE b DO c END / st || SContinue / st'
  where "c1 '/' st '||' s '/' st'" := (ceval c1 st s st').


Tactic Notation "ceval_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "E_Skip" |
    Case_aux c "E_Break" |
    Case_aux c "E_Ass" |
    Case_aux c "E_Seq_Break" |
    Case_aux c "E_Seq_Cont" |
    Case_aux c "E_If_True" |
    Case_aux c "E_If_False" |
    Case_aux c "E_While_Stop" |
    Case_aux c "E_While_Cont" |
    Case_aux c "E_While_Break" ].

Theorem break_ignore : forall c st st' s,
     (BREAK;; c) / st || s / st' ->
     st = st'.
Proof.
  intros.
  inversion H; subst.

  inversion H5. reflexivity.
  inversion H2.
Qed.


Theorem while_continue : forall b c st st' s,
  (WHILE b DO c END) / st || s / st' ->
  s = SContinue.
Proof.
  intros.
  inversion H; subst; reflexivity.
Qed.

Theorem while_stops_on_break : forall b c st st',
  beval st b = true ->
  c / st || SBreak / st' ->
  (WHILE b DO c END) / st || SContinue / st'.
Proof.
  intros.
  apply E_While_Break; assumption.
Qed.

Theorem while_break_true : forall b c st st',
  (WHILE b DO c END) / st || SContinue / st' ->
  beval st' b = true ->
  exists st'', c / st'' || SBreak / st'.
Proof.
  intros.
  remember (WHILE b DO c END) as loopdef eqn:Heqloopdef.
  induction H; inversion Heqloopdef; subst.

  Case "E_While_Stop".
    destruct (beval st b); try inversion H; try inversion H0.
  Case "E_While_Cont".
    apply IHceval2. reflexivity. assumption.
  Case "E_While_Break".
    exists st. assumption.
Qed.

Lemma beval_deterministic : forall b st r r',
     beval st b = r' ->
     beval st b = r ->
     r = r'.
Proof.
  intros b st r r'.
  induction b; simpl; intros; subst; reflexivity.
Qed.

Theorem ceval_deterministic: forall (c:com) st st1 st2 s1 s2,
     c / st || s1 / st1 ->
     c / st || s2 / st2 ->
     st1 = st2 /\ s1 = s2.
Proof.
  intros.

  generalize dependent s2.
  generalize dependent st2.
  ceval_cases (induction H) Case; intros.

  (* Skip *)
  inversion H0; subst; split; reflexivity.

  (* Break *)
  inversion H0; subst; split; reflexivity.

  (* Ass *)
  inversion H0; subst; split; reflexivity.

  (* Seq_Break *)
  inversion H0; subst. split; try reflexivity.
    apply IHceval with SBreak; assumption.
    apply IHceval in H3; inversion H3; inversion H2.

  (* Seq_Cont *)
  inversion H1; subst.
    split; apply IHceval1 in H7; inversion H7; inversion H3.
    split; apply IHceval1 in H4; inversion H4; subst;
           apply IHceval2 in H8; inversion H8; subst; reflexivity.

  (* If_True *)
  inversion H1; subst.
    split; apply IHceval in H9; inversion H9; assumption.
    split; apply (beval_deterministic b st true false H8) in H; inversion H.

  (* If_False *)
  inversion H1; subst.
    split; apply (beval_deterministic b st false true H8) in H; inversion H.
    split; apply IHceval in H9; inversion H9; assumption.

  (* While_Stop *)
  inversion H0; subst; split; try reflexivity.
    apply (beval_deterministic b st true false H) in H4; inversion H4.
    apply (beval_deterministic b st true false H) in H7; inversion H7.

  (* While_Cont *)
  inversion H2; subst.
    apply (beval_deterministic b st2 true false H8) in H0; inversion H0.
    apply IHceval1 in H5. inversion H5. subst. apply IHceval2 in H10. assumption.
    apply IHceval1 in H5; inversion H5; inversion H4.

  (* While_Stop *)
  inversion H1; subst.
    apply (beval_deterministic b st2 true false H7) in H0; inversion H0.
    apply IHceval in H4; inversion H4; inversion H3.
    apply IHceval in H4; inversion H4; subst; split; reflexivity.
Qed.

End BreakImp.


Module ShortCircuit.

Fixpoint beval (st : state) (b : bexp) : bool :=
  match b with
  | BTrue => true
  | BFalse => false
  | BEq a1 a2 => beq_nat (aeval st a1) (aeval st a2)
  | BLe a1 a2 => ble_nat (aeval st a1) (aeval st a2)
  | BNot b1 => negb (beval st b1)
  | BAnd b1 b2 => if beval st b1
                  then beval st b2
                  else false
  end.

End ShortCircuit.

Module ForLoop.

Inductive com : Type :=
  | CSkip : com
  | CAss : id -> aexp -> com
  | CSeq : com -> com -> com
  | CIf : bexp -> com -> com -> com
  | CWhile : bexp -> com -> com
  | CFor : com -> bexp -> com -> com -> com.

Tactic Notation "com_cases" tactic(first) ident(c) :=
  first;
  [ Case_aux c "SKIP" | Case_aux c "::=" | Case_aux c ";;"
  | Case_aux c "IFB" | Case_aux c "WHILE" | Case_aux c "FOR" ].

Notation "'SKIP'" :=
  CSkip.
Notation "x '::=' a" :=
  (CAss x a) (at level 60).
Notation "c1 ;; c2" :=
  (CSeq c1 c2) (at level 80, right associativity).
Notation "'IFB' c1 'THEN' c2 'ELSE' c3 'FI'" :=
  (CIf c1 c2 c3) (at level 80, right associativity).
Notation "'WHILE' b 'DO' c 'END'" :=
  (CWhile b c) (at level 80, right associativity).
Notation "'FOR' '(' a ';' b ';' c ')' 'DO' d 'END'" :=
  (CFor a b c d) (at level 80, right associativity).

Inductive ceval : com -> state -> state -> Prop :=
  | E_Skip : forall st,
      SKIP / st || st
  | E_Ass : forall st a1 n x,
      aeval st a1 = n ->
      (x ::= a1) / st || (update st x n)
  | E_Seq : forall c1 c2 st st' st'',
      c1 / st || st' ->
      c2 / st' || st'' ->
      (c1 ;; c2) / st || st''
  | E_IfTrue : forall st st' b c1 c2,
      beval st b = true ->
      c1 / st || st' ->
      (IFB b THEN c1 ELSE c2 FI) / st || st'
  | E_IfFalse : forall st st' b c1 c2,
      beval st b = false ->
      c2 / st || st' ->
      (IFB b THEN c1 ELSE c2 FI) / st || st'
  | E_WhileEnd : forall b st c,
      beval st b = false ->
      (WHILE b DO c END) / st || st
  | E_WhileLoop : forall st st' st'' b c,
      beval st b = true ->
      c / st || st' ->
      (WHILE b DO c END) / st' || st'' ->
      (WHILE b DO c END) / st || st''
  | E_ForBegin : forall a b c d st st' st'',
      a / st || st' ->
      beval st' b = true ->
      (FOR (a ; b ; c) DO d END) / st' || st'' ->
      (FOR (a ; b ; c) DO d END) / st  || st''
  | E_ForBeginFail : forall a b c d st st',
      a / st || st' ->
      beval st' b = false ->
      (FOR (a ; b ; c) DO d END) / st  || st'
  | E_ForEnd : forall a b c d st,
      beval st b = false ->
      (FOR (a ; b ; c) DO d END) / st || st
  | E_ForLoop : forall a b c d st st' st'' st''',
      beval st b = true ->
      d / st || st' ->
      c / st' || st'' ->
      (FOR (a ; b ; c) DO d END) / st'' || st''' ->
      (FOR (a ; b ; c) DO d END) / st || st'''
  where "c1 '/' st '||' st'" := (ceval c1 st st').

End ForLoop.

(* End of Imp *)