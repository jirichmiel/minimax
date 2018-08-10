module SimpleTreeTest exposing (..)

import Minimax exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

suite : Test
suite =
  describe "SimpleTreeTes.elm"
  
  [ 
    test "MiniMax Test Depth 4." <|
      \() ->
        Expect.equal (nodeEquals (Minimax.minimax moveFunc valueFunc possibleMovesFunc "" 4) (Just '0') (Number 4)) True

  , test "MiniMax Test Depth 2." <|
      \() ->
        Expect.equal (nodeEquals (Minimax.minimax moveFunc valueFunc possibleMovesFunc "" 2) (Just '0') (Number 4)) True

  , test "MiniMax Test Depth 1." <|
      \() ->
        Expect.equal (nodeEquals (Minimax.minimax moveFunc valueFunc possibleMovesFunc "" 1) (Just '1') (Number 5)) True

  , test "MiniMax Test Depth 2. No possible moves" <|
      \() ->
        Expect.equal (nodeEquals (Minimax.minimax moveFunc valueFunc possibleMovesFuncEmpty "" 2) Nothing Neg_Inf) True
  ] 

--                  4 (5)                         max
--                 /  \ 
--                /    \
--               /      \
--              /        \
--             /          \
--            /            \
--           /              \
--          /                \
--         4 (3)             2 (5)                min
--        / \              / |  \
--       /   \            /  |   \
--      /     \          /   |    \
--     /       \        /    |     \
--    6         4       3    2      3             max
--  /   \     /   \     |    |    /   \
-- 5    6    4    1     3    2   3     1          min
--/ \   |    |   / \   / \  / \  |   / | \
--8 5   6    4   1 2   3 5  6 2  3   5 7 1        max

nodeEquals : Node String Char -> Maybe Char -> IntegerExt Int -> Bool
nodeEquals node move value =
  (node.move == move) && (node.value == value)

moveFunc : Node String Char -> Char -> String
moveFunc node move =
  node.position ++ String.fromChar move

valueFunc : Node String Char -> Int
valueFunc node =
  case node.position of
    ""     -> 5

    "0"    -> 3
    "1"    -> 5

    "00"   -> 6
    "01"   -> 4
    "10"   -> 3
    "11"   -> 1
    "12"   -> 2

    "000"  -> 5
    "001"  -> 6
    "010"  -> 4
    "011"  -> 1
    "100"  -> 3
    "110"  -> 2
    "120"  -> 3
    "121"  -> 1

    "0000" -> 8
    "0001" -> 5 
    "0010" -> 6 
    "0100" -> 4 
    "0110" -> 1 
    "0111" -> 2
    "1000" -> 3
    "1001" -> 5 
    "1100" -> 6 
    "1101" -> 2 
    "1200" -> 3 
    "1210" -> 5 
    "1211" -> 7 
    "1212" -> 1
    _ -> 0

possibleMovesFuncEmpty : Node String Char -> List Char
possibleMovesFuncEmpty node =
  []

possibleMovesFunc : Node String Char -> List Char
possibleMovesFunc node =
  case node.position of
    ""    -> ['0', '1']
    "0"   -> ['0', '1']
    "00"  -> ['0', '1']
    "000" -> ['0', '1']
    "001" -> ['0']
    "01"  -> ['0', '1']
    "010" -> ['0']
    "011" -> ['0', '1']
    "1"   -> ['0', '1' , '2']
    "10"  -> ['0']
    "100" -> ['0', '1']
    "11"  -> ['0']
    "110" -> ['0', '1']
    "12"  -> ['0', '1' ]
    "120" -> ['0']
    "121" -> ['0', '1' , '2']
    _ -> []