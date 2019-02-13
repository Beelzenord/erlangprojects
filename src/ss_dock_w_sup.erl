%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Feb 2019 4:06 PM
%%%-------------------------------------------------------------------
-module(ss_dock_w_sup).
-author("fno").

%% API
-export([start_link/0,start_child/2,init_child/1]).
-export([init/0]).

start_link()->
  register(supRef,spawn(ss_dock_w_sup,init,[])),
  {ok,supRef}.

init()->
  process_flag(trap_exit, true),
  loop([]).

start_child(Total,Occupied)->
  supRef ! {start_child,Total,Occupied,self()},
  receive
    {ok,Pid} -> {shheeiit,Pid}
  end.


init_child(Args)->
  io:format("my list ~p",[Args]).


loop(Children) ->
  receive
    {start_child,Total,Occupied,ClientPid}->
      Pid = spawn_link(ss_docking_station, start_link, [Total,Occupied,kth]),
      ClientPid ! {ok, Pid}
     % loop([{Pid, 1, Mod, Func, Args}|Children]);
     % io:format("received ~p and ",[Total])
  end.