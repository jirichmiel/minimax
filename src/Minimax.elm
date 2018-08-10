module Minimax exposing (NodeType(..), IntegerExt(..), Node, minimax)

{-| This library implements minimax algorithm with alpha-beta pruning. 

For details about algorithm see https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning.


For exmaple of usage see https://github.com/jirichmiel/minimax/blob/master/README.md.

# Basic stuff
@docs Node, minimax

# Second stuff
@docs NodeType, IntegerExt

-}

{-| Represents a node type.
-}
type NodeType 
  = Min
  | Max

{-| It extends standard Number about positive/negative infinity.
-}
type IntegerExt a
  = Pos_Inf
  | Neg_Inf
  | Number a

type alias MinimaxParams position move =
  { maxDepth : Int
  , valueFunc : Node position move -> Int
  , moveFunc : Node position move -> move -> position
  , possibleMovesFunc : Node position move -> List move
  } 

{-| Represents a node in the search tree.

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

-}
type alias Node position move =
  -- node state
  { nodeType : NodeType
  , position : position
  , move : Maybe move
  , value : IntegerExt Int
  , alpha : IntegerExt Int
  , beta : IntegerExt Int
  , depth : Int
  }

{-| Run minimax and returns Node represents "best move" over the search tree.

  `(Node position move -> move -> position)` as `moveFunc` - is a function that takes a node and one of its edges, and returns the following node.

  `(Node position move -> Int)` as `valueFunc` - returns value of node.

  `(Node position move -> List move)` as `possibleMoveFunc` - returns all possible edges from given node.

  `position` as `initPosition` - defines a root of search tree.
    
  `Int` as `maxDepth` - tells how deep the algorithm can dive into the search tree (i.e. max height of tree).

-}
minimax : (Node position move -> move -> position) -> (Node position move -> Int) ->  (Node position move -> List move) -> position -> Int -> Node position move
minimax moveFunc valueFunc possibleMovesFunc initPosition maxDepth =
  minimax_ (minimaxParams moveFunc valueFunc possibleMovesFunc initPosition maxDepth) (myDebug_ "FORWARD TO NODE"
    -- initial state - root of minimax tree
    { nodeType = Max
    , position = initPosition
    , move = Nothing
    , value = Neg_Inf
    , alpha = Neg_Inf
    , beta = Pos_Inf
    , depth = 0
    })

minimaxParams : (Node position move -> move -> position) -> (Node position move -> Int) ->  (Node position move -> List move) -> position -> Int -> MinimaxParams position move
minimaxParams moveFunc valueFunc possibleMovesFunc initPosition maxDepth =
    { maxDepth = maxDepth
    , valueFunc = valueFunc
    , moveFunc = moveFunc
    , possibleMovesFunc = possibleMovesFunc
    } 

minimax_ : MinimaxParams p m -> Node p m -> Node p m
minimax_ minimaxParams node =
  if (node.depth == minimaxParams.maxDepth) then
    -- end recursion, we don't want to dive further, compute the node value by position that is holded
    myDebug_ "LEAF VALUE" (leafValue minimaxParams node)
  else
    case node.nodeType of
      -- node with highest value wins
      Max -> (myDebug_ "WINNER MAX" (nodeValue minimaxParams node sortDescending))
      -- node with lowest value wins
      Min -> (myDebug_ "WINNER MIN" (nodeValue minimaxParams node sortAscending))

leafValue : MinimaxParams p m -> Node p m -> Node p m
leafValue minimaxParams node =
  let
    value = Number (minimaxParams.valueFunc node)
  in
  -- setup it to node and also as alpha/beta constraints
  { node | value = value, alpha = value, beta = value }

nodeValue : MinimaxParams p m -> Node p m -> (Node p m -> Node p m -> Order) -> Node p m
nodeValue minimaxParams node sortFunc =
  let
    firstNode_
      = descendants minimaxParams node (myDebug_ "POSSIBLE MOVES" (minimaxParams.possibleMovesFunc node))
      |> List.sortWith sortFunc
      |> List.head
  in
    case firstNode_ of
      Nothing -> node
      Just firstNode -> { node 
        | value = firstNode.value
        , alpha = firstNode.alpha
        , beta = firstNode.beta
        , move = if (firstNode.depth == 1) then firstNode.move else node.move -- transfer move to up only for first child, we looking for a move between root and first child
      }

descendants : MinimaxParams p m -> Node p m -> List m -> List (Node p m)
descendants minimaxParams node moves =
  if (not (less node.alpha node.beta)) then
    -- alpha/beta prunning
    myDebug_ "PRUNING" []
  else
    case moves of
      -- no moves => no descendants
      [] -> []
      -- processing descendants
      (move :: restMoves) ->
        -- calling merge is recursive step to wide (by next sibling)
        -- calling minimax_ is recursive step into the depth
        merge minimaxParams node (minimax_ minimaxParams (myDebug_ "FORWARD TO NODE" { node
          | nodeType = swapType node.nodeType                           -- the node type alternates
          , position = minimaxParams.moveFunc node move                 -- compute new position (old position + move)
          , move = Just move                                            -- remember move to parent
          , value = if (node.nodeType == Max) then Pos_Inf else Neg_Inf -- init value for Max descendant is Min thus +Inf
          , alpha = node.alpha                                          -- alpha is inherited
          , beta = node.beta                                            -- beta is inherited
          , depth = node.depth + 1                                      -- step into the depth
        })) restMoves

merge : MinimaxParams p m -> Node p m -> Node p m -> List m -> List (Node p m)
merge minimaxParams parent previousSibling moves =
  let 
    alpha = if (parent.nodeType == Max) then max parent.alpha previousSibling.alpha else parent.alpha
    beta = if (parent.nodeType == Min) then min parent.beta previousSibling.beta else parent.beta
  in 
    previousSibling :: descendants minimaxParams { parent | alpha = alpha, beta = beta } moves

-- HELPER FUNCTIONS

swapType : NodeType -> NodeType
swapType t =
  case t of
    Min -> Max
    Max -> Min

sortDescending : Node p m -> Node p m -> Order
sortDescending node1 node2 =
  sortAscending node2 node1

sortAscending : Node p m -> Node p m -> Order
sortAscending node1 node2 =
  if (less node1.value node2.value) then
    LT
  else if (equals node1.value node2.value) then
    EQ
  else
    GT

max : IntegerExt Int -> IntegerExt Int -> IntegerExt Int
max a b =
  if (great a b) then
    a
  else
    b

min : IntegerExt Int -> IntegerExt Int -> IntegerExt Int
min a b =
  if (less a b) then
    a
  else
    b

less : IntegerExt Int -> IntegerExt Int -> Bool
less a b =
  not (great a b) && not (equals a b)

equals : IntegerExt Int -> IntegerExt Int -> Bool
equals a b =
  a == b
   
great : IntegerExt Int -> IntegerExt Int -> Bool
great a b = 
  case a of
    Pos_Inf ->
      b /= Pos_Inf
    
    Neg_Inf ->
      False

    Number x ->
      case b of
        Neg_Inf -> True
        Number y -> (x > y)
        Pos_Inf -> False


myDebug_ : String -> a -> a
myDebug_ text object =
  object
  --Debug.log text object