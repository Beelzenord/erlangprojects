%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 7:37 PM
%%%-------------------------------------------------------------------
-module(mutex2).
-author("fno").

%% API
-export([start/0,wait/0,signal/0]).

-export([init/0]).

start()->
  register(mutex2,spawn(mutex2,init,[])).

init()->
  process_flag(trap_exit,true),
  free().

wait()->
  mutex2 ! {wait,self()},
  receive
    ok->ok
  end.

signal()->
  mutex2 ! {wait,self()},
  ok.

free()->
  receive
    {'EXIT', Pid, _Reason} ->
      free();
    {wait,Pid}->
      link(Pid),
      Pid ! ok,
      busy(Pid)
  end.

busy(Pid)->
  receive
    {'Exit',Pid,_Reason}->
      free();
    {signal,Pid}->
      unlink(Pid),
      free()
  end.