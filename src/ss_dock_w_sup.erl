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
-export([start_link/0,start_child/2, update/2]).
-export([init/0]).

%Starts a supervisor process called supRef that performs init
start_link()->
  SupPid = spawn(ss_dock_w_sup,init,[]),
  register(supRef, SupPid),
  {ok,supRef}.

%Starts off with an empty list
init()->
  loop([], 0).

%Feeds the supervisor with relevant info about it's state
update(Pid, Occupied) ->
  supRef ! {update, Pid, Occupied}.

%Client sends a message to the superivisor about starting a new child process
start_child(Total,Occupied)->
  supRef ! {start_child,Total,Occupied,self()},
  receive
    {ok,Pid} -> {ok,Pid}
  end.



%Main loop, with the list of children and a unique number for the newly created child
loop(Children, EndNumber) ->
  receive
    %receive update from child
    {update, Pid, Occupied}->
      OldValues = lists:keyfind(Pid, 1, Children),
      OldTotal = element(2, OldValues),
      OldRef = element(4, OldValues),
      %To preserve integrity we delete the reference to an old child and add it again, in case something happens
      NewChildren = lists:keydelete(Pid, 1, Children),
      UpdatedChildren = lists:append([{Pid, OldTotal, Occupied, OldRef}], NewChildren),
      loop(UpdatedChildren, EndNumber);

     %we start a child here
    {start_child,Total,Occupied,ClientPid}->
      %Create new docking station and keep reference to it
      UniqueID = list_to_atom("Ref"++integer_to_list(EndNumber)),
      RefAndPid = spawn_monitor(ss_docking_station, init, [Total,Occupied,UniqueID]),
      %returns a tuple, first item is ref
      Pid = element(1, RefAndPid),
      %Link name to this id
      register(UniqueID, Pid),
      %Return reference to the process
      ClientPid ! {ok, UniqueID},
      NewChildren = lists:append([{Pid, Total, Occupied, UniqueID}], Children),
      loop(NewChildren, EndNumber+1);
      %handle the removal of a child process
      %Retrieve old values from crashed docking station
    {'DOWN', Ref, process, Pid, Reason}->
      OldValues = lists:keyfind(Pid, 1, Children),
      OldTotal = element(2, OldValues),
      OldOccupied = element(3, OldValues),
      OldRef = element(4, OldValues),%Remove old references
      NewChildren = lists:keydelete(Pid, 1, Children),%Restart station
      RefAndPid = spawn_monitor(ss_docking_station, init, [OldTotal,OldOccupied,OldRef]),
      NewPid = element(1, RefAndPid),
      register(OldRef, NewPid),
      %Add station to supervisor
      UpdatedChildren = lists:append([{NewPid, OldTotal, OldOccupied, OldRef}], NewChildren),
      loop(UpdatedChildren, EndNumber+1)
  end.