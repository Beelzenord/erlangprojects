%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Feb 2019 12:54 PM
%%%-------------------------------------------------------------------
-module(dbt).
-author("fno").

%% API

-export([empty/0,write/3,read/2,delete/2,deleteNode/2,findSmallest/1,readAll/1,findParent/1,match/2,countNode/1,countEmpty/1]).
-export([countOccupied/1]).

%%Node begins with empty tuple
empty()->
  {empty}.

%%New node begins with two empty sub-trees
write(Key,Value,{empty})->
  {Key,Value,{empty},{empty}};
% If the key matches, it's value will be replaced while keeping the left/right subtree references
write(NewKey,Value,{CurrentKey,_,LeftValue,Right_Value}) when NewKey =:= CurrentKey ->
  {CurrentKey,Value,LeftValue,Right_Value};
%% traverse the left subtree when it's key value is less than the root key
write(NewKey,Value,{CurrentKey,Current_Value,LeftValue,Right_Value}) when NewKey < CurrentKey ->
  {CurrentKey,Current_Value,write(NewKey,Value,LeftValue),Right_Value};
%% Traverse the right subtree when the key value is higher than the root key
write(NewKey,Value,{CurrentKey,Current_Value,LeftValue,Right_Value}) when NewKey > CurrentKey ->
  {CurrentKey,Current_Value,LeftValue,write(NewKey,Value,Right_Value)}.


delete(_,{empty})->
  {empty};
%We return a reconstructed tree if we find a target
delete(Target, {CurrentKey,Value,LeftBranch,RightValue}) ->
  NewNode = deleteNode(Target,{CurrentKey,Value,LeftBranch,RightValue}),
  NewNode.

%We found the Target
deleteNode(TargetKey,{Current_Key,_,LeftBranch,RightValue})when TargetKey == Current_Key->
  if
    (LeftBranch == {empty} andalso RightValue == {empty})->
      {empty};  % No subtree - we can safely remove the node
    LeftBranch == {empty} ->
      RightValue; % One subtree - we replace the node with the non-empty tree
    RightValue == {empty} ->
      LeftBranch;
    true-> % the node-to-be-deleted has two subtres
      {RightToNodeDeleted,RValue,RLeft,RRight} = RightValue,
      if
      % if the right Node of the to-be-deleted node has no left node then we replace the to-be-deleted node
      % with that node.
        (RLeft == {empty})->
          {RightToNodeDeleted,RValue,LeftBranch,RRight};
        true->
          %%we'll find the smallest node on the right side of the to-be-deleted node
          {OtherKey,OtherValue,OtherLeft,OtherRight} = findSmallest(RightValue),
          %Make the the parent left subtree point to the right of the to-be-deleted node
          %while the smallest node will take the place of the to-be-deleted node
          Tmp = {ParentKey,ParentValue,_,ParentRight} = findParent(RightValue),
          Tmp= {ParentKey,ParentValue, {OtherKey,OtherValue,OtherLeft,OtherRight},ParentRight},
          %Now the smallest node exists in two places, we need to be rid of it.
          Deleted2 = {OtherKey,OtherValue,LeftBranch, deleteNode(OtherKey,RightValue)},
          Deleted2 %%hehehe
      end

  end;

%traverse the left subtree
deleteNode(TargetKey,{CurrentKey,CurrentValue,CurrentLeft,CurrentRight}) when TargetKey > CurrentKey ->
  {CurrentKey,CurrentValue,CurrentLeft,deleteNode(TargetKey,CurrentRight)};
%traverse the right subtree
deleteNode(Target,{CurrentKey,CurrentValue,CurrentLeft,CurrentRight}) when Target < CurrentKey ->
  {CurrentKey,CurrentValue,deleteNode(Target,CurrentLeft),CurrentRight};
%no node found
deleteNode(_,{empty})->
  {empty}.
%find the second smallest node on a subtree - essential for delete method
findParent({Key,Value,Left,Right})->
  {_,_,TempL,_} = Left,

  if TempL == {empty} ->
    {Key,Value,Left,Right};
    TempL /= {empty}->
      findParent(Left)
  end.

%finds the smallest node
findSmallest({_,_,Left,_})when Left /= {empty}->
  findSmallest(Left);

findSmallest({Key,Value,Left,Right}) ->
  {Key,Value,Left,Right}.


readAll(Tuple)->
  Tuple.

read(_,{empty})->
  undefined;
%Key matches, returns the key and the value
read(Key, {NodeKey,Value,_,_}) when Key ==  NodeKey->
  {ok, {Key,Value}};
%Key is smaller than the current node, we traverse the left subtree
read(Key, {NodeKey, _,LeftKey, _}) when Key < NodeKey ->
  read(Key, LeftKey);
%Key is bigger than the current node, we traverse the right subtree
read(Key, {_, _, _, RightKey})  ->
  read(Key, RightKey).
%the element matches, we put the Value in the list and continue the search for matching values on both subtrees
match(Value, {_, Value, LeftNode, RightNode}) ->
  [Value |  match(Value,LeftNode) ++ match(Value,RightNode)];
%a little divide an conquer, we traverse both subtrees to fill up a list
match(Element, {_, _, LeftNode, RightNode}) ->
  match(Element, LeftNode) ++ match(Element, RightNode);

%went to empty node
match(_, {empty}) ->
  [].



countNode({empty})->
  0;
countNode({_,_,Left,Right})->
  1 + countNode(Left) + countNode(Right).

countEmpty({empty})->
  0;

countEmpty({_,Value,Left,Right})->
  if
    Value == "Empty"->
      Count = 1 + countEmpty(Left) + countEmpty(Right),
      Count;
    Value == "Occupied"->
      Count2 = countEmpty(Left) + countEmpty(Right),
      Count2
  end.

countOccupied({empty})->
  0;

countOccupied({_,Value,Left,Right})->
  if
    Value == "Occupied"->
      Count = 1 + countOccupied(Left) + countOccupied(Right),
      Count;
    Value == "Empty"->
      Count2 = countOccupied(Left) + countOccupied(Right),
      Count2
  end.

