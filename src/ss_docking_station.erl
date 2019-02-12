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
-export([start_link/3,init/3,makeList/3,new/0,write/4,idle/1,makeBinary/4,secure_scooter/1]).
-record(docking_point,{id,state,name}).

start_link(Total,Occupied, Name)->
  register(Name,spawn(ss_docking_station,init,[Total,Occupied,Name])).


secure_scooter(Name)->
  Name ! {reserve,self()},
receive
  {ok} -> {done};
  {error,full} -> {filled}
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
    {reserve,Pid}->
      Returned = dbt:match("Empty",Db),
    %  io:format("Return from match ~p~n",[Returned]),
      %io:format("we have returned a ~p",[Key]),
      if
         Returned =:=  {error,nonexisting}  ->
           Pid ! {error,full};
          true ->
            Key = lists:nth(1,Returned),
            Db1 = dbt:write(Key,"Occupied",Db),
            io:format("updated ~p~n",[Db1]),
            Pid ! {ok},
            idle(Db1)
      end


  end.
  %receive




  % hasSpot(Name)
  % Val = lists:any(fun(X) -> X#docking_point.state == "Empty" end, List),
  %lists:any(fun(X) -> X#docking_point == Test end, NewState#state.clients).
  %maps:find(List,#docking_point.state="Empty")
  % Val.
  % io:format("Value ~p",[Val]).


 % Val = lists:keyfind(List, #docking_point.state = "Empty") =/= false,
 % io:format("Value ~p",Val).



 % Predicate = fun(E) -> E rem 2 == 0 end,
 % lists:keyfind(Pid, #client.pid, State#state.clients) =/= false
 % Returned = lists:keysearch("Empty", #docking_point.state, List),
 % io:format("Value ~p",Returned).

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

