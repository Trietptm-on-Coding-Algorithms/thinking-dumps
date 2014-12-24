module TSPLib (
  Node,
  Edge,
  Path,
  TSPAlgorithm,
  distance,
  xRange,
  yRange,
  pathLength,
  edgeLength,
  pathToEdges,
  tracePath,
  tracePath',
  replace,
  compEdgeDist,
  nearestEdgeTo,
  furthestEdgeTo,
  parseString,
  parseStdin,
  parseFile,
  outputForGraph
  ) where

import Data.Functor
import Data.Function
import Data.List
import Control.Arrow ((>>>), (&&&), second)

import Data.Tuple

-- node
type Node = (Int, Int)
type Edge = (Node, Node)
type Path = [Node]

distance :: Node -> Node -> Double
distance (x1,y1) (x2,y2) = sqrt (fromIntegral $ (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))

xRange  :: [Node] -> (Int, Int)
xRange = (foldl1' min &&& foldl1' max) . map fst
yRange :: [Node] -> (Int, Int)
yRange = (foldl1' min &&& foldl1' max) . map snd


type TSPAlgorithm = [Node] -> [Edge]


pathLength :: Path -> Double
pathLength xs = foldl1' (+) $ zipWith distance (init xs) (tail xs)

edgeLength :: Edge -> Double
edgeLength = uncurry distance

pathToEdges :: Path -> [Edge]
pathToEdges xs = zip (init xs) (tail xs)

tracePath :: [Edge] -> Node -> Path
tracePath [] n = [n]
tracePath es n = case length edges of
                  0 -> [n]
                  1 -> let followingE = head edges
                           nextN      = snd followingE
                           restEdges  = es \\ [followingE, swap followingE]
                       in n : tracePath restEdges nextN
                  _ -> error "more than one choice"
  where edges = filter ((==n) . fst) (es ++ map swap es)


-- this version of trace path follow
tracePath' :: [Edge] -> Node -> Path
tracePath' [] n = [n]
tracePath' es n = case length edges of
                   0 -> [n]
                   _ -> let followingE = head edges
                            nextN      = snd followingE
                            restEdges  = es \\ [followingE, swap followingE]
                        in n : tracePath restEdges nextN
  where edges = filter ((==n) . fst) (es ++ map swap es)


replace :: (Eq a) => a -> [a] -> [a] -> [a]
replace x sub xs = newXs
  where index         = elemIndex x xs
        makeHole i    =  second tail . splitAt i
        connect (a,b) = a ++ sub ++ b
        newXs         = maybe xs (connect . flip makeHole xs) index


compEdgeDist :: Edge -> Edge -> Ordering
compEdgeDist = compare `on` edgeLength

nearestEdgeTo :: Node -> [Node] -> Edge
nearestEdgeTo n ms = (n, minimumBy (compare `on` distance n) ms)

furthestEdgeTo :: Node -> [Node] -> Edge
furthestEdgeTo n ms = (n, minimumBy (compare `on` distance n) ms)

parseString :: String -> [Node]
parseString =
  lines >>>
  filter (not . ("#" `isPrefixOf`)) >>>
  filter (not . null) >>>
  map words >>>
  map (map read) >>>
  filter (\x -> length x == 2) >>>
  map (\[a,b] -> (a,b))


parseStdin :: IO [Node]
parseStdin = parseString <$> getContents

parseFile :: FilePath -> IO [Node]
parseFile path = parseString <$> readFile path


outputForGraph :: [Node] -> [Edge] -> IO ()
outputForGraph ns es = do
  putStrLn $ show (length ns) ++ " " ++ show (length es)
  mapM_ (putStrLn . showNode) ns
  mapM_ (putStrLn . showEdge) es
  where showNode (a,b) = show a ++ " " ++ show b
        showEdge ((a,b),(c,d)) = show a ++ " " ++ show b ++ " " ++
                                 show c ++ " " ++ show d

main :: IO ()
main = parseStdin >>= flip outputForGraph []
