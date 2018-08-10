# Minimax with alpha-beta pruning

This library implements Minimax algorithm with alpha-beta pruning that is useful for searching a "best move" in the search tree. It is useful for example as part of AI decision maker in the various games. For more details about this algorithm see https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning.

## Library description

There are two important parts. Structure `Node` that represents a node of the search tree, and function `minimax` that implements the algorithm for searching "best move" over this tree.

### Node

Node represents a solving problem's state (e.g. a game position). The node in this library has follows structure:

```elm
type alias Node position move =
  { nodeType : NodeType       -- MIN or MAX, it alternates throughout search tree levels (root is MAX, nodes at second level are MIN, nodes at third level are MAX, etc.)
  , position : position       -- it tells what a solving problem's state is represented by this Node
  , move : Maybe move         -- last move (an egde to nearest parent's node, or to best "move" node for root)  
  , value : IntegerExt Int    -- value of node (IntegerExt extends Int about positive/negative infinity)
  , alpha : IntegerExt Int    -- alpha (IntegerExt extends Int about positive/negative infinity)
  , beta : IntegerExt Int     -- beta (IntegerExt extends Int about positive/negative infinity)
  , depth : Int               -- depth of node (root node has 1)
  }
```
`Node` is parametrized by
  
`position` - represents a solving problem's state (node value)
`move` - represents something that move from one Node to another Node (edge value)

### minimax


```elm
minimax : (Node position move -> move -> position) -> (Node position move -> Int) ->  (Node position move -> List move) -> position -> Int -> Node position move
minimax moveFunc valueFunc possibleMovesFunc initPosition maxDepth =
```

where

`moveFunc` - is a function that takes a node and one of its edges, and returns the following node
`valueFunc` - returns value of node
`possibleMoveFunc` - returns all possible edges from given node
`initPosition` - defines a root of search tree
`maxDepth` - tells how deep the algorithm can dive into the search tree (i.e. max height of tree)

function returns a root `Node` with "best move" in the field move.

If we want to use minimax for looking for a best move in some game then we can look at five minimax parameters as

`moveFunc` - represents how change the game position from some position to another position by a game move.
`valueFunc` - represents some heuristic for computing the value of a position in game.
`possibleMoveFunc` - tells which moves are possible for a game position.
`initPosition` - defines a start position.
`maxDepth` - search tree can grows very quickly for some difficult games, so stop it at certain level is very good idea.

## Example of usage

For demonstration how to use `Minimax` give a simple game called Nim (https://en.wikipedia.org/wiki/Nim)

> Wiki says: Nim is a mathematical game of strategy in which two players take turns removing objects from distinct heaps. On each turn, a player must remove at least one object, and may remove any number of objects provided they all come from the same heap. The goal of the game is to be the player who removes the last object.

We use simplified variation of this game. Suppose there is only one heap with five coins and players can takes one to three coins.

Define the `game position` as a number of coins on the Heap and the `game move` as a number of coins taken from the Heap. Look at image for idea how looks the search tree for this game.

![Search tree for simplified game NIM](docs/minimax-nim.png)

### How we implement "arguments" for minimax function?

#### moveFunc

Move function is very simply. A game move is defined by a number of coins taken from the Heap
So we implement move function as the arithmetic minus

```elm
moveFunc : Node Int Int -> Int -> Int
moveFunc node taken =
  node.position - taken
```

### valueFunc

What heuristic? If Heap is empty then game is over. Who's winner? It depends on node's depth. If depth is even then we win the game (oponents cannot take any coin, green nodes in the image) it's good for us so let's rate these nodes some positive integer (e.g. 10). If depth is odd we lose (we cannot take any coin, red nodes in the image) these nodes let's have value 0. If Heap is not empty then game is in progress (white nodes in the image), it means that max depth is not enough (we don't see all leafs in the search tree). Consider some neutral value for these nodes  (e.g 5).

```elm
valueFunc : Node Int Int -> Int
valueFunc node =
  if (node.position == 0) then
    if (node.depth % 2 == 0) then
      10
    else
      0
  else
    5
```

### possibleMoveFunc

By the game rules we can take max three coins, but we cannot take more coins than actually on Heap are.

```elm
possibleMovesFunc : Int -> List Int
possibleMovesFunc count =
  case count of
    0 -> []		-- no move
    1 -> [1] 		-- only one coin can be taken
    2 -> [1, 2]		-- one or two coins can be taken
    _ -> [1, 2, 3]	-- one or two or three coins can be taken
```

### initPosition

We said that our Heap includes only five coins.    

```elm
initPosition : Int
initPosition =
  5
```

### maxDepth
  
Six level is enough.
  
```elm
maxDepth : Int
maxDepth =
  6
```

### call minimax
    
For determining the "best move" call minimax by follows

```elm
minimax moveFunc valueFunc possibleMoveFunc startPosition maxDepth
```

Result is

```elm
{ nodeType = Max
, position = 5
, move = Just 1     -- <=  best move is taking only one coin
, value = Pos_Inf
, alpha = Neg_Inf
, beta = Pos_Inf
, depth = 0
}
```

## Note 

This implementation you find in `tests/NimTest.elm`.

For another example how to use this library see `tests/SimpleTreeTest.elm`.

## Source

https://github.com/jirichmiel/minimax.git
