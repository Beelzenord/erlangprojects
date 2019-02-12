%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 7:49 PM
%%%-------------------------------------------------------------------
-module(sup).
-author("fno").

%% API
-export([start/1,stop/1,start_child/4]).

-export([init/0]).
start(Name)->
  Pid = spawn(sup,init,[]),
  register(Name,Pid),
  {ok,Pid}.

stop(Name)->
  Name ! stop,
  ok.

start_child(Name,Module,Funtion,Args)->
  Name ! {start_child,self(),Module,Funtion,Args},
  receive
    {ok,Pid} -> {ok,Pid}
  end.

init()->
  process_flag(trap_exit,true),
  loop([]).

loop(Children)->
  receive
    {start_child,ClientPid,Mod,Func,Args}->
      Pid = spawn_link(Mod,Func,Args),
      ClientPid ! {ok,Pid},
      loop([{Pid,1,Mod,Func,Args}|Children]);
    {'Exit',Pid,normal}->
      NewChildren = lists:keydelete(Pid,1,Children),
      loop(NewChildren);
    {'Exit',Pid,Reason}->
      NewChildren = lists:keydelete(Pid,1,Children),
      {value,Child} = lists:keysearch(Pid,1,Children),
      {Pid,Count,Mod,Func,Args} = Child,
      error_message(Pid,Count,Reason,Mod,Func,Args),
      NewPid = spawn_link(Mod,Func,Args),
      loop([{NewPid,Count+1,Mod,Func,Args}|NewChildren]);
    stop->
      kill_children(Children)
  end.

kill_children([{Pid,_Count,_Mod,_Func,_Args}|Children])->
  exit(Pid,kill),
  kill_children(Children);

kill_children([])->
  ok.

error_message(Pid, Count, Reason, Mod, Func, Args) ->
  io:format("~50c~n",[$-]),
  io:format("Error: Process ~p Terminated ~p time(s)~n",[Pid, Count]),
  io:format("       Reason for termination:~p~n",[Reason]),
  io:format("       Restarting with ~p:~p/~p~n",[Mod,Func,length(Args)]),
  io:format("~50c~n",[$-]).