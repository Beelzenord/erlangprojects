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

%% API
-export([start_link/0,start_child/2,init_child/1]).
-export([init/0]).

start_link()->
  register(supRef,spawn(ss_dock_w_sup,init,[])),
  {ok,supRef}.
init()->
  process_flag(trap_exit, true),
  %{ok, {{one_for_one, 6, 3600}, []}},
  loop([], 0).

start_child(Total,Occupied)->
  supRef ! {start_child,Total,Occupied,self()},
  receive
    {ok,Pid} -> {ok,Pid}
  end.
init_child(Args)->
  io:format("my list ~p",[Args]).

loop(Children, EndNumber) ->
  receive
    {start_child,Total,Occupied,ClientPid}->
      %Create new docking station and keep reference to it
      UniqueID = list_to_atom("Ref"++integer_to_list(EndNumber)),
      Pid = spawn_link(ss_docking_station, init, [Total,Occupied,UniqueID]),
      ClientPid ! {ok, Pid},
      loop([Children]++[{Pid, Total, Occupied, UniqueID}], EndNumber+1);
    {'EXIT',Pid,Reason}->
      io:format("EXIT!! ~p", [Reason]),

      %Retrieve old values from crashed docking station
      OldRef = lists:keyfind(Pid, 1, Children),
      io:format("oldref: ~p", [OldRef]),
      OldTotal = element(2, OldRef),
      OldOccupied = element(3, OldRef),
      OldID = element(4, OldRef),
      io:format("Pid: ~p", [Pid]),
      io:format("OldID: ~p", [OldID]),

      %Remove old reference
      NewChildren = lists:keydelete(Pid, 1, Children),

      %Restart station
      NewPid = spawn_link(ss_docking_station, init, [OldTotal,OldOccupied,OldID]),

      %Add station to supervisor
      UpdatedChildren = lists:append([{NewPid, OldTotal, OldOccupied, OldID}], NewChildren),
      io:format("before loop: "),

      loop(Children, EndNumber)
  end.