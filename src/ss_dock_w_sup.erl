%%%-------------------------------------------------------------------
%%% @author fno and Jacob
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Feb 2019 4:06 PM
%%%-------------------------------------------------------------------
-module(ss_dock_w_sup).
-author("fno").
-behavior(supervisor).

%% API
-export([start_link/0,start_child/2,init_child/1]).
-export([init/0,exit_child/1]).

start_link()->
  %SupRef= supervisor:start_link({local, ss_dock_w_sup}, ?MODULE, []),
 % supervisor:start_link(ss_dock_w_sup, []),
 % SupRef = erlang:monitor(process, Pid),
   %  Pid = spawn(ss_dock_w_sup,init,[]),
  register(supRef,spawn(ss_dock_w_sup,init,[])),
  {ok,supRef}.
init()->
  io:format("initialising"),
  process_flag(trap_exit, true),
  %{ok, {{one_for_one, 6, 3600}, []}},
  loop([], 0).

start_child(Total,Occupied)->
  supRef ! {start_child,Total,Occupied,self()},
  receive
    {ok,Pid} -> {ok,Pid}
  end.

exit_child(Pid)->
  supRef ! {'EXIT',Pid,normal}.


init_child(Args)->
  io:format("my list ~p",[Args]).

loop(Children, EndNumber) ->
  receive
    {start_child,Total,Occupied,ClientPid}->
      RefToDb = list_to_atom("Ref"++integer_to_list(EndNumber)),
      Pid = spawn_link(ss_docking_station, start_link, [Total,Occupied,RefToDb]),
      io:format("Pid ~p",[Pid]),
      [Children|Pid],
      ClientPid ! {ok, RefToDb},
      loop([Children], EndNumber+1);
    {'EXIT',Pid,normal}->

      NewChildren = lists:keydelete(Pid, 1, Children),
     % Pid = spawn_link(ss_docking_station, start_link, [Total,Occupied,RefToDb]),
      loop([NewChildren], EndNumber)
     % loop([{Pid, 1, Mod, Func, Args}|Children]);
     % io:format("received ~p and ",[Total])
  end.