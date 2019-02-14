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
  SupPid = spawn(ss_dock_w_sup,init,[]),
  register(supRef, SupPid),
  {ok,supRef}.
init()->
  %process_flag(trap_exit, true),
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

      io:format(" Me before creating child ~p", [self()]),
      UniqueID = list_to_atom("Ref"++integer_to_list(EndNumber)),
      Pid = spawn_monitor(ss_docking_station, init, [Total,Occupied,UniqueID]), %returns a tuple, first item is ref
      RefToDb = element(1, Pid),

      io:format(" Me after creating child ~p", [self()]),
      ClientPid ! {ok, RefToDb},
      loop([Children]++[{RefToDb, Total, Occupied, UniqueID}], EndNumber+1);
    {'DOWN', Ref, process, Pid2, Reason}->
%      erlang:demonitor(Ref),

      %Retrieve old values from crashed docking station
%      OldRef = lists:keyfind(Pid, 1, Children),
%      io:format("oldref: ~p", [OldRef]),
%      OldTotal = element(2, OldRef),
%      OldOccupied = element(3, OldRef),
%      OldID = element(4, OldRef),
%      io:format("Pid: ~p", [Pid]),
%      io:format("OldID: ~p", [OldID]),

      %Remove old reference
%      NewChildren = lists:keydelete(Pid, 1, Children),

      %Restart station
%      NewPid = spawn_link(ss_docking_station, init, [OldTotal,OldOccupied,OldID]),

      %Add station to supervisor
%      UpdatedChildren = lists:append([{NewPid, OldTotal, OldOccupied, OldID}], NewChildren),
%      io:format("before loop: "),

      loop(Children, EndNumber)
  end.