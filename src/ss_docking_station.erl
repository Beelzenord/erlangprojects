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
-export([start_link/3,init/3,makeList/3,new/0,write/4,idle/1,makeBinary/4,secure_scooter/1,release_scooter/1]).
-record(docking_point,{id,state,name}).

start_link(Total,Occupied, Name)->
  register(Name,spawn(ss_docking_station,init,[Total,Occupied,Name])).


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
 % List =makeList(Total,Occupied,Name),
  Db = makeBinary(Total,Occupied,"Empty",dbt:empty()),
  idle(Db).

new()->
  [].



makeList(Total,Occupied,Name)->
  %Db = dbt:empty(),
  write(Total,Occupied,Name,[]).

idle(Db)->
 % io:format("~p",[List]),
  receive
    {secure,Pid}->
      Returned = dbt:match("Empty",Db),
    %  io:format("Return from match ~p~n",[Returned]),
      %io:format("we have returned a ~p",[Key]),
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
      end
  end.
  %receive

handleState(Db) ->
    IsItFull = dbt:match("Occupied", Db),
    IsItEmpty = dbt:match("Empty",Db),
    if
      IsItFull =:= {error,nonexisting} ->
        io:format("{error,empty}"),
        empty(Db);
      IsItEmpty =:= {error,nonexisting} ->
        io:format("{error,full}"),
        full(Db);
      true ->
        io:format("Is in idle"),
        idle(Db)
    end.

full(Db)->
 % io:format("~p",[List]),
  receive
    {secure,Pid}->
      Pid ! {error,full},
      full(Db)
  end.
  %receive


empty(Db)->
 % io:format("~p",[List]),
  receive
    {secure,Pid}->
      ReturnedEmpty = dbt:match("Empty",Db);
    {release, Pid} ->
      Pid ! {error, empty},
      empty(Db),

      if
         ReturnedEmpty =:=  {error,nonexisting}  ->
           Pid ! {error,full};
          true ->
            Key = lists:nth(1,ReturnedEmpty),
            Db1 = dbt:write(Key,"Occupied",Db),
            io:format("updated ~p~n",[Db1]),
            Pid ! {ok},
            handleState(Db1)
      end


  end.
  %receive


makeBinary(0,0,_,Db)->
  io:format("does this print?"),
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

