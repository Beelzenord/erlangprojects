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
-export([start_link/0,start_child/2,init_child/1, update/2]).
-export([init/0]).

start_link()->
  SupPid = spawn(ss_dock_w_sup,init,[]),
  register(supRef, SupPid),
  {ok,supRef}.
init()->
  %process_flag(trap_exit, true),
  %{ok, {{one_for_one, 6, 3600}, []}},
  loop([], 0).

update(Pid, Occupied) ->
  supRef ! {update, Pid, Occupied}.

start_child(Total,Occupied)->
  supRef ! {start_child,Total,Occupied,self()},
  receive
    {ok,Pid} -> {ok,Pid}
  end.

init_child(Args)->
  io:format("my list ~p",[Args]).

loop(Children, EndNumber) ->
  receive
    {update, Pid, Occupied}->
      OldValues = lists:keyfind(Pid, 1, Children),
      OldTotal = element(2, OldValues),
      OldRef = element(4, OldValues),
      NewChildren = lists:keydelete(Pid, 1, Children),
      UpdatedChildren = lists:append([{Pid, OldTotal, Occupied, OldRef}], NewChildren),
      io:format("Updating occupied... ~p", [Occupied]),
      loop(UpdatedChildren, EndNumber);

    {start_child,Total,Occupied,ClientPid}->
      %Create new docking station and keep reference to it
      UniqueID = list_to_atom("Ref"++integer_to_list(EndNumber)),
      RefAndPid = spawn_monitor(ss_docking_station, init, [Total,Occupied,UniqueID]), %returns a tuple, first item is ref
      Pid = element(1, RefAndPid),

      %Link name to this id
      register(UniqueID, Pid),

      %Return reference to the process
      ClientPid ! {ok, UniqueID},
      loop([Children]++[{Pid, Total, Occupied, UniqueID}], EndNumber+1);
    {'DOWN', Ref, process, Pid, Reason}->
      %erlang:demonitor(Ref),

      %Retrieve old values from crashed docking station
      OldValues = lists:keyfind(Pid, 1, Children),
      io:format("Pid: ~p", [Pid]),
      io:format("OldRef: ~p", [OldValues]),
      OldTotal = element(2, OldValues),
      OldOccupied = element(3, OldValues),
      OldRef = element(4, OldValues),

      %Remove old references
      NewChildren = lists:keydelete(Pid, 1, Children),
      %unregister(OldRef),

      %Restart station
      RefAndPid = spawn_monitor(ss_docking_station, init, [OldTotal,OldOccupied,OldRef]),
      NewPid = element(1, RefAndPid),
      register(OldRef, NewPid),

      %Add station to supervisor
      UpdatedChildren = lists:append([{NewPid, OldTotal, OldOccupied, OldRef}], NewChildren),

      loop(UpdatedChildren, EndNumber+1)
  end.