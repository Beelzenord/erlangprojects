%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 8:39 PM
%%%-------------------------------------------------------------------
-module(funs).
-author("fno").
-record(dockingpoint,{state}).
%% API
-export([print/1,smaller/2,print_even/1,concatenate/1,sum/1]).

print(N)->
  List = lists:seq(1,N),
  Print = fun(X) -> io:format("~p~n",[X]) end,
  lists:foreach(Print,List).

smaller(List,Size)->
  Filter = fun(X) when X > Size -> false;
    (_X) ->true
           end,
  lists:filter(Filter,List).

print_even(N)->
  Filter = fun(X) -> X rem 2 == 0 end,
  List = lists:seq(1,N),
  FilteredList = lists:filter(Filter,List),
  Print = fun(X)-> io:format("~p~n",[X]) end,
  lists:foreach(Print,FilteredList).

concatenate(ListOfLists)->
  Concatenate = fun(X,Buffer)->Buffer ++ X end,
  lists:foldl(Concatenate,[],ListOfLists).

sum(ListOfInts)->
  Sum = fun(Integer,Buffer)->Buffer + Integer end,
  lists:foldl(Sum,0,ListOfInts).