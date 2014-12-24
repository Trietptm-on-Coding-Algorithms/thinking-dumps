module BrutalForce where

import TSPLib

import Data.List
import Data.Function
import Control.Monad


algBrutalForce :: TSPAlgorithm
algBrutalForce []     = []
algBrutalForce [a,b]  = [(a,b)]
algBrutalForce ns = pathToEdges minPath
  where allPaths = join $ map allPathsFrom ns
        allPathsFrom a = explore a (delete a ns)
        minPath = minimumBy (compare `on` pathLength) allPaths

{-
algBrutalForce' :: Set Node -> [Edge]
algBrutalForce'
-}

explore :: Node -> [Node] -> [Path]
explore n []      = [[n]]
explore n ns = map (n:) allPaths
  where allPathsFrom a = explore a (delete a ns)
        allPaths = join $ map allPathsFrom ns