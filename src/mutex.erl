%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 4:40 PM
%%%-------------------------------------------------------------------
-module(mutex).
-author("fno").

%% API
-export([start/0,wait/0,signal/0]).

-export([free/0]).

start()->
  register(mutex,spawn(mutex,free,[])).

wait()->
  mutex ! {wait,self()},
  receive
    ok->ok
  end.

signal()->
  mutex ! {signal,self()},
  receive
    yep->up
  end.

free()->
  receive
    {wait,Pid}->
      Pid ! ok,
      busy(Pid)
  end.


busy(Pid) ->
  receive
    {signal,Pid}->
      Pid ! yep,
      free()
  end.