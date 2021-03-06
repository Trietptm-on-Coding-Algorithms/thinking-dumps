module DFSTest where

import BFS
import GenericGraph hiding (bounds)
import Control.Monad (liftM2)
import Test.QuickCheck
import Data.Maybe (fromJust)


{-
exampleGraph:

  +-1--2--3--4
  +-+   \    |
         +---5

-}

edges :: [Edge Int]
edges = [(1,1), (1,2), (2,3), (2,5), (3,4), (4,5)]

bounds :: Bounds Int
bounds = liftM2 (,) (foldl1 min) (foldl1 max) $
         (map fst edges) ++ (map snd edges)

exampleGraph :: GenericGraph Int
exampleGraph = buildG bounds (edges ++ rev edges)
  where rev      = map (\(a,b) -> (b,a))


prop_SearchEqvTraverse :: Property
prop_SearchEqvTraverse =
  forAll inBounds $ \beg ->
  forAll inBounds $ \end ->
  let sResult = beg : (fromJust $ bfsSearch exampleGraph beg end)
      tResult = bfsTraverse exampleGraph beg
  in sResult == (takeWhile (/=end) tResult) ++ [end]
  where inBounds = choose bounds


main :: IO ()
main = do quickCheck (bfsTraverse exampleGraph (1::Int) == [1,2,3,5,4])
          quickCheck (bfsTraverse exampleGraph (2::Int) == [2,1,3,5,4])
          quickCheck (bfsTraverse exampleGraph (3::Int) == [3,2,4,1,5])
--          this does not always stand
--          quickCheck prop_SearchEqvTraverse
