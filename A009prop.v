Require Export A007logic.

Definition even (n:nat) : Prop :=
  evenb n = true.



Inductive ev : nat -> Prop :=
  | ev0  : ev 0
  | evSS : forall n : nat, ev n -> ev (S (S n)).



Theorem double_even : forall n,
  ev (double n).
Proof.
  intro.
  induction n.
  simpl. apply ev0.
  simpl. apply evSS. exact IHn.
Qed.


Theorem ev__even : forall n,
                    ev n -> even n.
Proof.
  intros.
  induction H.
  simpl.
  reflexivity.
  unfold even in IHev. unfold even. simpl. assumption.
Qed.

Theorem ev_sum : forall n m,
   ev n -> ev m -> ev (n+m).
Proof.
  intros.
  induction H.
  simpl. assumption.
  simpl. apply evSS. assumption.
Qed.

Inductive beautiful : nat -> Prop :=
| b_0 : beautiful 0
| b_3 : beautiful 3
| b_5 : beautiful 5
| b_sum : forall m n : nat,
            beautiful m -> beautiful n ->
            beautiful (m + n).

Theorem beautiful_8 : beautiful 8.
Proof.
  replace (8) with (3 + 5).
  apply b_sum.
  apply b_3.
  apply b_5.
  reflexivity.
Qed.

Theorem beautiful_8' : beautiful 8.
Proof.
  replace (8) with ((5 + 3) + 0).
  apply b_sum.
  apply b_sum.
  apply b_5.
  apply b_3.
  apply b_0.
  reflexivity.
Qed.

Theorem beautiful_plus_eight:
  forall n, beautiful n -> beautiful (8+n).
Proof.
  intros.
  apply b_sum.
  apply beautiful_8.
  assumption.
Qed.

Theorem b_times2:
  forall n, beautiful n -> beautiful (2 * n).
Proof.
  simpl.
  intros.
  rewrite plus_assoc.
  apply b_sum.
  apply b_sum.
  assumption. assumption.
  apply b_0.
Qed.

Theorem b_timesm:
  forall n m, beautiful n -> beautiful (m * n).
Proof.
  intros.
  induction m.
  simpl. apply b_0.
  simpl. apply b_sum.
  assumption.
  assumption.
Qed.

Inductive gorgeous : nat -> Prop :=
  g_0 : gorgeous 0
| g_plus3 : forall n, gorgeous n -> gorgeous (3+n)
| g_plus5 : forall n, gorgeous n -> gorgeous (5+n).

Theorem gorgeous_plus13: forall n,
                           gorgeous n -> gorgeous (13+n).
Proof.
  intros.
  replace 13 with (3 + 5 + 5).
  replace (3 + 5 + 5 + n) with (3 + (5 + (5 + n))).
  apply g_plus3. apply g_plus5. apply g_plus5.
  assumption.
  reflexivity.
  reflexivity.
Qed.


Theorem gorgeous__beautiful : forall n,
                                gorgeous n -> beautiful n.
Proof.
  intros.
  induction H.
  Case "0".
  apply b_0.
  Case "3 + n".
  apply b_sum. apply b_3. assumption.
  Case "5 + n".
  apply b_sum. apply b_5. assumption.
Qed.


Theorem gorgeous_sum : forall n m,
                         gorgeous n -> gorgeous m -> gorgeous (n + m).
Proof.
  intros.
  induction H.
  Case "0". simpl. assumption.
  Case "3+n". rewrite <- plus_assoc. apply g_plus3. assumption.
  Case "5+n". rewrite <- plus_assoc. apply g_plus5. assumption.
Qed.

Theorem beautiful__gorgeous :
  forall n, beautiful n -> gorgeous n.
Proof.
  intros.
  induction H.
  SCase "0". apply g_0.
  SCase "3". apply g_plus3 with (n:=0). apply g_0.
  SCase "5". apply g_plus5. apply g_0.
  SCase "m + n". apply gorgeous_sum; assumption.
Qed.

Lemma helper_g_times2 :
  forall x y z, x + (z + y)= z + x + y.
Proof.
  intros.
  rewrite plus_assoc.
  replace (x + z) with (z + x). reflexivity.
  rewrite plus_comm. reflexivity.
Qed.

Theorem g_times2:
  forall n, gorgeous n -> gorgeous (2 * n).
Proof.
   intros n H. simpl.
   induction H.

   Case "0".
   simpl. apply g_0.

   Case "3 + n".
   rewrite <- helper_g_times2.
   apply gorgeous_sum. assumption.
   apply g_plus3. rewrite <- plus_assoc. apply g_plus3.
   rewrite plus_comm. simpl. assumption.

   Case "5 + n".
   rewrite <- helper_g_times2.
   apply gorgeous_sum. assumption.
   apply g_plus5. rewrite <- plus_assoc. apply g_plus5.
   rewrite plus_comm. simpl. assumption.
Qed.


Theorem ev_minus2: forall n,
  ev n -> ev (pred (pred n)).
Proof.
  intros.
(*(* the induction way *)
  induction H.
  simpl. apply ev0.
  simpl. apply H.
*)
  (* the inversion way *)
  inversion H.
  simpl. apply ev0.
  simpl. assumption.

  (* ex: Why not `destruct`?
     because destruct does not introduce the inductive rule for
      ev n -> ev (S (S n))
     therefore the second goal will be `ev (S (S n))` while without an
     assumption of `ev n`, which is not provable.
  *)
 Qed.

Theorem SSev__even : forall n,
  ev (S (S n)) -> ev n.
Proof.
  intros.
  inversion H.
  assumption.
Qed.

Theorem SSSSev__even : forall n,
  ev (S (S (S (S n)))) -> ev n.
Proof.
  intros.
  inversion H.
  inversion H1.
  assumption.
Qed.

Theorem even5_nonsense :
  ev 5 -> 2 + 2 = 9.
Proof.
  intros.
  inversion H. inversion H1. inversion H3.
Qed.

Lemma ev_n__nev_Sn : forall n, ev n -> ~(ev (S n)).

Theorem ev_ev__ev : forall n m,
  ev (n+m) -> ev n -> ev m.
Proof.
  intros.
  induction H0.

  simpl in H. assumption.

  simpl in H. inversion H.
  apply IHev in H2. assumption.
Qed.

Theorem ev_plus_plus : forall n m p,
  ev (n+m) -> ev (n+p) -> ev (m+p).
Proof.
  intros.
  apply ev_sum with (n := n + p) in H.
  replace (n + p + (n + m)) with (double n + m + p) in H.
  rewrite <- plus_assoc in H.
  apply ev_ev__ev with (m := m + p) in H. assumption.

  (* disgusting.... *)
  assert (forall n' m', double n' + m' + m' = double (n' + m')).
  clear. intros. rewrite double_plus.
  replace (n' + n' + m' + m') with ((n' + m') + (n' + m')).
  rewrite <- double_plus. reflexivity.
  rewrite <- plus_assoc. replace (m' + (n' + m')) with (n' + m' + m').
  rewrite plus_assoc. rewrite plus_assoc. reflexivity.
  rewrite plus_comm. reflexivity.
  rewrite H1. apply double_even.

  rewrite double_plus.
  rewrite plus_assoc. rewrite <- plus_assoc with (m := p).
  rewrite <- plus_comm with (m := p) (n := n).
  rewrite plus_assoc. rewrite <- plus_assoc with (m := p).
  rewrite plus_comm with (m := m) (n := p).
  rewrite plus_assoc. reflexivity.

  assumption.
Qed.


Inductive pal {X : Type} : list X -> Prop :=
  | c : forall l, l = rev l -> pal l.

Lemma cons_app: forall {X} (x : X) xs, x :: xs = [x] ++ xs.
Proof. auto. Qed.
Lemma snoc_app: forall {X} (x : X) xs, snoc xs x = xs ++ [x].
Proof.
  intros. induction xs. reflexivity.
  simpl. apply f_equal. assumption.
Qed.
Lemma rev__xs_x: forall {X} (x : X) xs, rev (xs ++ [x]) = [x] ++ rev xs.
Proof.
  intros. induction xs. reflexivity.
  simpl. rewrite snoc_app. rewrite snoc_app.
  rewrite IHxs.
  replace (x :: rev xs ++ [x0]) with ([x] ++ rev xs ++ [x0]).
  replace (([x] ++ rev xs) ++ [x0]) with ([x] ++ rev xs ++ [x0]).
  reflexivity.
  auto. auto.
Qed.


Goal forall {X : Type} (l : list X), pal (l ++ rev l).
Proof.
  induction l.
  simpl. apply c. reflexivity.

  apply c. simpl.
  inversion IHl. subst.

  rewrite cons_app.
  rewrite snoc_app.
  rewrite snoc_app.
  replace (rev (l ++ rev l ++ [x])) with ([x] ++ rev (l ++ rev l)).
  replace ([x] ++ rev (l ++ rev l)) with ([x] ++ l ++ rev l).
  symmetry.
  (* Why can't I rewrite the goal by app_assoc?!!! Fork!!! *)
Abort.

Goal forall l, pal l -> l = rev l.
