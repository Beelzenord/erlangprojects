%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 11:02 PM
%%%-------------------------------------------------------------------
-module(ss_docking_station).
-author("fno").

%% API
-export([start_link/3,secure_scooter/1,release_scooter/1,get_info/1,break/0]).
-export([init/3,makeList/3,write/4,makeBinary/4,idle/1,exit_station/1]).
-record(docking_point,{id,state,name}).

start_link(Total,Occupied, _)when Occupied > Total->
  {error, "Number of occupied docking points cannot exceed the number of actual docking points"};

start_link(Total,Occupied, Name)->
  register(Name,spawn(ss_docking_station,init,[Total,Occupied,Name])).

exit_station(Name)->
  Name ! {exitStation, self()},
  receive
    {ok, Reason} -> {ok, Reason}
  end.

get_info(Name)->
  Name ! {getinfo,self()},
  receive
    {ok,List}-> List
  end.


secure_scooter(Name)->
  Name ! {secure,self()},
receive
  {ok} -> {ok};
  {error,full} -> {error,full}
  end.

release_scooter(Name)->
  Name ! {release,self()},
receive
  {ok} -> {ok};
  {error,empty} -> {error,empty}
  end.

init(Total,Occupied,_)->
  Db = makeBinary(Total,Occupied,"Empty",dbt:empty()),
  handleState(Db).

makeList(Total,Occupied,Name)->
  %Db = dbt:empty(),
  write(Total,Occupied,Name,[]).

break()->
  {goodbye}.

idle(Db)->
 % io:format("~p",[List]),
  receive
    {exitStation, Pid} ->
      io:format("from child, exiting.. ~p", [Pid]),
      Pid ! {ok, abnormal},
      exit(abnormal);
    {getinfo,Pid}->
      io:format("Process info: ~p", [get()]),
      List = [{total,dbt:countNode(Db)},{occupied,dbt:countOccupied(Db)},{free,dbt:countEmpty(Db)}],
      Pid ! {ok,List},
      supRef !
      idle(Db);
    {secure,Pid}->
      Returned = dbt:match("Empty",Db),
      if
         Returned =:=  {error,nonexisting}  ->
         Pid ! {error,full},
         handleState(Db);
       true ->
         Key = lists:nth(1,Returned),
         Db1 = dbt:write(Key,"Occupied",Db),
         io:format("updated ~p~n",[Db1]),
         Pid ! {ok},
         handleState(Db1)
      end;
      {release,Pid}->

        ReturnedOccupied = dbt:match("Occupied",Db),
        if
          ReturnedOccupied =:=  {error,nonexisting}  ->
            Pid ! {error,empty},
            handleState(Db);
          true->
            KeyOccupied = lists:nth(1,ReturnedOccupied),
            Db2 = dbt:write(KeyOccupied,"Empty",Db),
            io:format("updated to empty ~p~n",[Db2]),
            Pid ! {ok},
            handleState(Db2)
         end
  end.
  %receive

handleState(Db) ->
    IsItFull = dbt:match("Occupied", Db),
    IsItEmpty = dbt:match("Empty",Db),
    if
      IsItFull =:= {error,nonexisting} ->
      %  io:format("{error,empty}"),
        empty(Db);
      IsItEmpty =:= {error,nonexisting} ->
     %   io:format("{error,full}"),
        full(Db);
      true ->
      %  io:format("Is in idle"),
        idle(Db)
    end.

full(Db)->
 % io:format("~p",[List]),
  receive
    {exitStation, Pid} ->
      io:format("from child, exiting.. ~p", [Pid]),
      Pid ! {ok, abnormal},
      exit(abnormal);
    {getinfo,Pid}->
      List = [{total,dbt:countNode(Db)},{occupied,dbt:countOccupied(Db)},{free,dbt:countEmpty(Db)}],
      Pid ! {ok,List},
      full(Db);
    {secure,Pid}->
      Pid ! {error,full},
      full(Db);
    {release,Pid}->
      ReturnedOccupied = dbt:match("Occupied",Db),
      if
        ReturnedOccupied =:=  {error,nonexisting}  ->
          Pid ! {error,empty},
          handleState(Db);
        true->
          KeyOccupied = lists:nth(1,ReturnedOccupied),
          Db2 = dbt:write(KeyOccupied,"Empty",Db),
          io:format("updated to empty ~p~n",[Db2]),
          Pid ! {ok},
          handleState(Db2)
      end
  end.
  %receive


empty(Db)->
 % io:format("~p",[List]),
  receive
    {exitStation, Pid} ->
      io:format("from child, exiting.. ~p", [Pid]),
      Pid ! {ok, abnormal},
      exit(abnormal);
    {getinfo,Pid}->
      List = [{total,dbt:countNode(Db)},{occupied,dbt:countOccupied(Db)},{free,dbt:countEmpty(Db)}],
      Pid ! {ok,List},
      empty(Db);
    {secure,Pid}->
      ReturnedEmpty = dbt:match("Empty",Db),
      Key = lists:nth(1,ReturnedEmpty),
      Db1 = dbt:write(Key,"Occupied",Db),
      Pid ! {ok},
      handleState(Db1);
    {release, Pid} ->
      Pid ! {error, empty},
      empty(Db)
  end.
  %receive


makeBinary(0,0,_,Db)->
  Db;

makeBinary(Total,Occupied,State,Db)when Occupied=:=0->
  DbTemp = dbt:write(Total,"Empty",Db),
  makeBinary(Total-1,Occupied,State,DbTemp);

makeBinary(Total,Occupied,State,Db)when Occupied/=0->
  DbTemp = dbt:write(Total,"Occupied",Db),
  makeBinary(Total-1,Occupied-1,State,DbTemp).


write(0,0,_,List)->
  List;
write(Total,Occupied,Name, List)when Occupied /= 0 ->
  [#docking_point{id = Total,state = "Occupied",name = Name}|write(Total-1,Occupied-1,Name,List)];
write(Total,Occupied,Name, List)when Occupied =:= 0 ->
  [#docking_point{id = Total,state = "Empty",name = Name}|write(Total-1,Occupied,Name,List)].


