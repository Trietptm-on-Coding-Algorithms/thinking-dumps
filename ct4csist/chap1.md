
## 1.1 Categories

Exercises:

#### 1. show how arbitrary set can be considered as a category

Obj(S) := all elements in S

By axiom of choice, we can pick an arbitrary element from S and assign
morphisms from it to other elements. The repeat the same process for
the rest of the elements until there is no element left. After all we
assign identity morphisms for each elements. It's obvious
to see that these morphisms follow the composition law.

The shape is like finite category.


#### 2. show arbitrary group can be considered a category

* Obj(C) := {X}
* Arr(C) := elements in G, mapping from X to X

id arrow: the identity element in G

It's not difficult to show that: `a . (b . c) = (a . b) . c` by the
definition of the assoc law of the operator `(+)` of group.

#### 3. shape of 3, 4, 5-category and their corresp to nat numbers

**3-cat:**

    a-->b
     \  |
      \ |
       vv
        c

2+1 morphisms.

**4-cat:**

    a---->b
    |\   /|
    | \ / |
    |  X  |
    | / \ |
    vv   vv
    c---->d

3+2+1 morphisms.

**5-cat:**

too complex to draw in ascii art. just omitted.

there will be 4+3+2+1 morphisms.

#### 4. complete the following spec of cat M.

* Obj(M) := Nat numbers
* M-arrow `f : m -> n` is an m-by-n matrix of real nums
* the composite `g . f` of `f : m -> n` and `g : n -> p` is the matrix prod of `f` and `g`.

the assoc law is implied by the associativity of the product of two
matrix.

the identity arrow on an object n is a n-by-n identity matrix.

#### 5. redraw arrows in FPL category

omitted.

## 1.3 mono-, epi-, and iso-morphisms

#### essential of mono and epi

So the essential on mono and epi are cancel-abilities.

* Mono <=> left  cancellation: `f . g = f . h   ==>   g = h`
* Epi  <=> right cancellation: `g . f = h . f   ==>   g = h`

When it applies to **Set**, specially for **R**s, we could imagine:

* mono: if we have `ln(g(x)) = ln(h(x))` and because `ln` never maps
  two distinct values to a same value (i.e. surjective), we could
  conclude that `g(x) = h(x)`

* non-mono: if we have `g(x)^x = h(x)^2`, because `(^2)` is not
  surjective, we cannot come out at `g = h`.

* epi: if we have `g(ln(x)) = h(ln(x))`, because `ln` is onto, that
  means `forall y \in R` there is a `x` such that `ln(x) = y`, which
  means for the complete domain of `g` and `h` they are all mapping to
  the same results. therefore we conclude that `g = h`.

* non-epi: if we have `g(x^2) = h(x^2)`, because `^2` is not onto,
  as for negative reals we can't say that `g(x)` will be still equal
  to `h(x)`. and therefore we cannot come at `g = h`.

#### about iso

the intuition of isomorphism is a `f` between two objs `A` and `B` is
that `A` and `B` has equivalent SHAPE. It means we can transform from
`A` to `B` and `B` to `A` back and forth, without losing any info.

#### ex 1. prove epic <=> onto

**epic -> onto**

by contradiction, assume we have `f : A -> B` which is not onto. there
exists `b0` such that `forall a, f a /= b0`. then suppose there is `g, h : B -> C`.

we can define a `g /= h` by the following spec:

* `g(b) := b` (forall `b`)
* `h(b) := if b == b0 then x0 else b`

with this defn, `g . f === h . f` but `g /== h` because `g(b0) /= h(b0)`.


**onto -> epic**

suppose we have an onto function, `f : A -> B`. then we have `forall
b, exists a, f a = b`. if also we have `g, h : B -> A` and
`g . f = h . f`, which becomes `forall a. g(f(a)) = h(f(a))`.
then we can conclude `forall b, g b = h b` and therefore `g = h`.

#### ex 2. transitivity of monic

`f : A -> B and g : B -> C` are monic, we want to prove
`g . f : A -> C` is also monic. Suppose `h, h' : K -> A`,

        (g .  f) . h  == (g .  f) . h'
     =>  g . (f  . h) ==  g . (f  . h') (assoc of .)
     =>  g .       h  ==  g .       h' (since f is monic)
     =>            h  ==            h' (since g is monic)


#### ex 3. trans of epic

`f : A -> B and g : B -> C` are epic, we want to prove
`g . f : A -> C` is also epic. Suppose `h, h' : C -> K`

         h . (g  . f) ==  h' . (g  . f)
     => (h .  g) . f  == (h' .  g) . f (assoc of .)
     =>  h       . f  ==  h' .       f (since g is epic)
     =>  h            ==  h'           (since f is epic)

#### ex 4. show `f^{-1}` is uniq

we prove by contradiction. suppose `f : A -> B` is iso and there are two
`f^{-1}` : `h0, h1 : B -> A` such that `h0 /= h1`.

Since `h0, h1` are inverse of `f`, we have

        h1 . f  . h0
    => (h1 . f) . h0
    =>  id      . h0
    =>            h0


       h1 .  f . h0
    => h1 . (f . h0)
    => h1 . id
    => h1

Therefore:

    h1 . f . h0 = h0 = h1

which contradicts the assumption `h0 /= h1`. therefore `f^{-1}`
cannot be two distinct functions.


#### ex 5. show f^-1 . g^-1 is the inverse of g . f

* `f : A -> B, f^-1 : B -> A`
* `g : B -> C. g^-1 : C -> B`

           (g .  f) . (f^-1  . g^-1)
        =>  g . (f  .  f^-1) . g^-1
        =>  g . id           . g^-1
        =>  g . g^-1
        =>  id

In similar way we can deduce that `(f^-1 . g^-1) . (g . f)` is
`id`. Therefore `(f^-1 . g^-1)` is the inverse of `(g . f)`.


#### ex6. find an arrow that is epic and monic but not iso

We adopt the arrow `f` for **2** category. **2** is defined as below:

* Obj(**2**): {A, B}
* Arr(**2**):
  - `f : A -> B`
  - two ids: `id_A, id_B`

`f` is epic because `h0 . f = h1 . f => h0 = h1` because there is only
one morphism satisfy positions of `h0` and `h1`: `id_B`. Similarly
`f` is monic.

But we don't have an inverse of `f` that `f^{-1} : B -> A`. Therefore
`f` is not iso.


## 1.4 initial and terminal obj

#### why 1-elem sets and empty set

First we to know what is meant by the category **Set**. It consists of objects of ALL sets, and the arrows are *total functions*. Total function is defined by:

> if we have a mapping `f : A -> B` such that `forall a : A, exists b : B, such that f a = b`, then we say `f` is a total function.

**Terminals**

So we have an arrow, a total function, from set `A` to set `B`. Now we think of what if we have only one element in `B`. How many ways are there you can define this arrow `f`?

Surely there is only one, the constant function: `f _ = b0`. In this way we define this object as a terminal.

**Initials**

What about initials? The same. Notice that we are having total functions as the morphisms, for `f : A -> B`, if we have `A` a set with 1-elements, we would have a number of `|B|` ways to define `f`. If the number of elements gets more in `A`, the situation become worse, as we would have `|B|^|A|` ways to define such morphisms. If we want the number of morphisms from `A` to any `B` to be exactly one, `|A|` must be zero, and therefore `A` must be `∅`.

This mapping is called a [empty function](https://en.wikipedia.org/wiki/Empty_function). The way it is defined and valid, according to wikipedia, is to maintain the consistency of **Set** as a category such every objects in **Set** can have an identity morphism. The empty function is also defined valid in terms of cardinal arithmetic described above.


#### intuition about init and term obj

so a terminal is denoded as **1**.

and an initial is denoted as **0**.

indicated by the cardinality of the object.

For poset `(A, <=)`, init is the greatest elem and term is the least elem.

#### why there exists unique term obj (up to iso)?

suppose we have any two term obj: `T` and `T'`. By defn, we have one and only one morph from `T` to `T'` since `T'` is a term. Similarly, we also have one and only one morph from `T'` to `T`. Therefore for ally `T` and `T'`, as far as they are both terminals, they must be isomorphic to each other.

