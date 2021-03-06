{-# LANGUAGE TypeSynonymInstances #-}
-- This is a note playing with the concepts to deepen my understanding
-- while reading the paper: Functional Programming with Bananas,
-- Lenses, Evelopes and Barbed Wire by Erik Meijer, et al.
--

import Data.Functor


-- catamorphism, like foldr
cata :: b -> (a -> b -> b) -> ([a] -> b)
cata b' _ []     = b'
cata b' f (a:as) = f a (cata b' f as)

length'cata :: [a] -> Int
length'cata = cata 0 (const (+1))

filter'cata :: (a -> Bool) -> [a] -> [a]
filter'cata p = cata [] foo
  where foo a as = if p a then a : as else as


-- anamorphism, like unfoldr
ana :: (b -> (a,b)) -> (b -> Bool) -> b -> [a]
ana g p b
  | p b       = []
  | otherwise =  a : ana g p b'
  where (a, b') = g b

zip'ana :: ([a], [b]) -> [(a,b)]
zip'ana = ana g p
  where p (as,bs)         = null as || null bs
        -- acutally g is not non-exhaused because our p ensures the
        -- completeness
        g ((a:as),(b:bs)) = ((a,b), (as,bs))

iter'ana :: (a -> a) -> a -> [a]
iter'ana f = ana g (const False)
  where g a = (a, f a)


hylo :: b -> (a -> b -> b) -> (c -> (a,c)) -> (c -> Bool) -> (c -> b)
hylo b f g p c
  | p c       = b
  | otherwise = let (a, c') = g c
                in f a (hylo b f g p c')

hylo' :: b -> (a -> b -> b) -> (c -> (a,c)) -> (c -> Bool) -> (c -> b)
hylo' b f g p = cata b f . ana g p


fac'hylo :: Int -> Int
fac'hylo = hylo 1 (*) g p
  where g c  = (c, c - 1) -- (c, c')
        p c' = c' == 0

data Fix f = In (f (Fix f))
data List a l = Nil | Cons a l
type ListF a  = Fix (List a)

instance Functor (List a) where
  fmap f Nil        = Nil
  fmap f (Cons a l) = Cons a (f l)

hsToLst :: [a] -> ListF a
hsToLst []     = In Nil
hsToLst (x:xs) = In (Cons x (hsToLst xs))

lstToHs :: ListF a -> [a]
lstToHs (In Nil) = []
lstToHs (In (Cons x xs)) = x : lstToHs xs

data Number n = Zero | Succ n
type NumberF = Fix Number

instance Functor Number where
  fmap f Zero     = Zero
  fmap f (Succ n) = Succ (f n)

hsToInt :: Int -> NumberF
hsToInt 0 = In Zero
hsToInt n = In (Succ (hsToInt $ n - 1))

intToHs :: NumberF -> Int
intToHs (In Zero) = 0
intToHs (In (Succ n)) = succ (intToHs n)

para :: b -> (a -> [a] -> b -> b) -> ([a] -> b)
para b f []     = b
para b f (a:as) = f a as (para b f as)

paraGen :: (Functor f) => (f (Fix f, b) -> b) -> (Fix f -> b)
paraGen f (In as) = f (fmap keepCopy as)
  where keepCopy a = (a, paraGen f a)

-- Error: Insufficient IQ
-- fac'para :: NumberF -> Int
-- fac'para = paraGen f 1
--   where f (n, m) = _
