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

-export([empty/0,write/3,read/2,delete/2,deleteNode/2,findSmallest/1,readAll/1,findParent/1,match/2]).

empty()->
  {empty}.


write(Key,Value,{empty})->
  io:format("[1]Numberempty~n"),
  {Key,Value,{empty},{empty}};
%Replace the key
write(NewKey,Value,{CurrentKey,_,LeftValue,Right_Value}) when NewKey =:= CurrentKey ->
  {CurrentKey,Value,LeftValue,Right_Value};
%% travers the left subtree
write(NewKey,Value,{CurrentKey,Current_Value,LeftValue,Right_Value}) when NewKey < CurrentKey ->
  io:format("[1]Number<~n"),
  {CurrentKey,Current_Value,write(NewKey,Value,LeftValue),Right_Value};

write(NewKey,Value,{CurrentKey,Current_Value,LeftValue,Right_Value}) when NewKey > CurrentKey ->
  io:format("[1]Number~n"),
  {CurrentKey,Current_Value,LeftValue,write(NewKey,Value,Right_Value)}.


delete(_,{empty})->
  {empty};

delete(Target, {CurrentKey,Value,LeftBranch,RightValue}) ->
  NewNode = deleteNode(Target,{CurrentKey,Value,LeftBranch,RightValue}),
  NewNode.


deleteNode(TargetKey,{Current_Key,_,LeftBranch,RightValue})when TargetKey == Current_Key->
  if
    (LeftBranch == {empty} andalso RightValue == {empty})->
      %    io:write("emptying"),
      {empty};
    LeftBranch == {empty} ->
      RightValue;
    RightValue == {empty} ->
      LeftBranch;
    true->
      {RightToNodeDeleted,RValue,RLeft,RRight} = RightValue,
      if
      % if the  right subtree of the to be deleted node has no left node then th
        (RLeft == {empty})->
          {RightToNodeDeleted,RValue,LeftBranch,RRight};
        true->
          %%find the smallest on the right side of the to-be-deleted node
          {OtherKey,OtherValue,OtherLeft,OtherRight} = findSmallest(RightValue),%C
          Tmp = {ParentKey,ParentValue,_,ParentRight} = findParent(RightValue),%E
          %Make the the parant left subtree point to the right of the to-be-deleted node
          Tmp= {ParentKey,ParentValue, {OtherKey,OtherValue,OtherLeft,OtherRight},ParentRight},
          %Deleted = {Current_Key,Current_Value,LeftBranch,RightValue},
          %{Current_Key} = {OtherValue},
          Deleted2 = {OtherKey,OtherValue,LeftBranch, deleteNode(OtherKey,RightValue)},
          Deleted2

      % {OtherKey,OtherValue,OtherLeft,deleteNode(OtherKey,OtherRight)}

      %
      % DecLeft = LeftBranch
      end
  % NodeToMove = RightValue,
  %   ParentOfNode = {Key,Value,LeftBranch,RightValue}
  %take the smallest node on the right subtree
  %   {TempKey,TempValue,TempLeft,TempRight} = findSmallest(RightValue),
  %   TempLeft = LeftBranch
  end;

deleteNode(TargetKey,{CurrentKey,CurrentValue,CurrentLeft,CurrentRight}) when TargetKey > CurrentKey ->
  {CurrentKey,CurrentValue,CurrentLeft,deleteNode(TargetKey,CurrentRight)};

deleteNode(Target,{CurrentKey,CurrentValue,CurrentLeft,CurrentRight}) when Target < CurrentKey ->
  io:format("Less than invoked"),
  {CurrentKey,CurrentValue,deleteNode(Target,CurrentLeft),CurrentRight};

deleteNode(_,{empty})->
  {empty}.

findParent({Key,Value,Left,Right})->
  {_,_,TempL,_} = Left,

  if TempL == {empty} ->
    {Key,Value,Left,Right};
    TempL /= {empty}->
      findParent(Left)
  end.


findSmallest({_,_,Left,_})when Left /= {empty}->
  findSmallest(Left);

findSmallest({Key,Value,Left,Right}) ->
  {Key,Value,Left,Right}.


%{TempKey,TmpValue,TmpLeft,TempRight}= read(Key,{CurrentKey,Value,LeftValue,Right}),
%Val = red
%{CurrentKey = LeftValue}.
% read(Key,{CurrentKey,Value,LeftValue,Right}).


%%db:read(ola, Db3).
readAll(Tuple)->
  Tuple.

read(_,{empty})->
  undefined;
read(Key, {Key,Value,Left,Right}) ->
  {ok, {Key,Value,Left,Right}};
% {ok,{Key,Value}};
read(Key, {NodeKey, _,LeftKey, _}) when Key < NodeKey ->
  io:format("executing less than "),
  read(Key, LeftKey);
read(Key, {_, _, _, RightKey})  ->
  io:format("executing "),
  read(Key, RightKey).

match(_,{empty})->
  {empty};

match(Value, {Key,T_Value,_,_})when Value =:= T_Value->
  [Key,T_Value];
match(Value,{_,T_Value,Left,Right})when Value /=T_Value->
  LeftAlt = match(Value,Left),
  RightAlt = match(Value,Right),
  if
    LeftAlt == {empty} andalso RightAlt == {empty}->
      {error,nonexisting};
    LeftAlt /= {empty} andalso RightAlt == {empty}->
      LeftAlt;
    LeftAlt == {empty} andalso RightAlt /= {empty}->
      RightAlt;
    true->
      LeftAlt ++ RightAlt

  end.