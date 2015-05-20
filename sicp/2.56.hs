import Text.Printf
import Text.ParserCombinators.Parsec
import Data.Functor
import Control.Applicative ((*>), (<*))
import Control.Monad hiding (sequence)
import Data.Traversable (sequence)
import Prelude hiding (sequence)

type Var = String

data Expr = Sum Expr Expr
          | Prod Expr Expr
          | Exp Expr Expr
          | I Integer
          | V Var
          deriving Eq


plainLit :: Expr -> String
plainLit a@(V _) = show a
plainLit a@(I _) = show a
plainLit exp = printf "(%s)" $ show exp


instance Show Expr where
  show (I i)
    | i < 0     = "(" ++ show i ++ ")"
    | otherwise = show i
  show (V x) = x
  show (Prod s@(Sum _ _) t@(Sum _ _)) = "(" ++ show s ++ ")*" ++
                                        "(" ++ show t ++ ")"
  show (Prod s@(Sum _ _) c) = "(" ++ show s ++ ")*" ++ show c
  show (Prod a s@(Sum _ _)) = show a ++ "*(" ++ show s ++ ")"
  show (Prod a b) = show a ++ "*" ++ show b
  show (Sum  a b) = show a ++ "+" ++ show b
  show (Exp  a b) = printf "%s^%s" (plainLit a) (plainLit b)


derivative :: Expr -> Var -> Expr
derivative (Sum  u v) x = mkS (derivative u x) (derivative v x)
derivative (Prod u v) x = mkS udv vdu
  where udv = mkP u $ derivative v x
        vdu = mkP v $ derivative u x
derivative (I _) _ = I 0
derivative (V x') x = I $ if x == x' then 1 else 0 -- partial derivative


mkS :: Expr -> Expr -> Expr
mkS (I 0) a = a
mkS a (I 0) = a
mkS (I a) (I b) = I (a + b)
mkS a b
  | a == b    = mkP (I 2) a
  | otherwise = Sum a b


mkP :: Expr -> Expr -> Expr
mkP (I 1) a = a
mkP a (I 1) = a
mkP (I 0) _ = I 0
mkP _ (I 0) = I 0
mkP (I a) (I b) = I (a*b)
mkP a b
  | a == b    = mkE a (I 2)
  | otherwise = Prod a b


mkE :: Expr -> Expr -> Expr
mkE _ (I 0) = I 1
mkE (I 0) _ = I 0
mkE (I 1) _ = I 1
mkE (I a) (I b) = I (a ^ b)
mkE a (I 1) = a
mkE a b = Exp a b


myParser :: Parser Expr
myParser    = sm  `chainl1` (char '+' >> return mkS)
  where sm  = pro `chainl1` (char '*' >> return mkP)
        pro = ter `chainl1` (char '^' >> return mkE)
        ter =     char '(' *> myParser <* char ')'
              <|> (I . read) <$> many1 digit
              <|> (V         <$> many1 lower)

parseExpr :: String -> Maybe Expr
parseExpr s = case parse (myParser <* eof) "" s of
               Left x  -> Nothing
               Right a -> Just a

showDer :: String -> Var -> IO ()
showDer s v = do
  sequence $ (print . flip derivative v) <$> parseExpr s
  return ()


main :: IO ()
main = do
  showDer "2*x+3" "x"
  showDer "x^3-x^2-x" "x"
