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
-export([start_link/3,init/3,makeList/3,new/0,write/4,idle/1,secure_scooter/1]).
-record(docking_point,{id,state,name}).

start_link(Total,Occupied, Name)->
  register(Name,spawn(ss_docking_station,init,[Total,Occupied,Name])).
 % makeList(Total,Occupied).

secure_scooter(Name)->
  Name ! {reserve,self()},
receive
    ok -> done
  end.

init(Total,Occupied,Name)->
  List =makeList(Total,Occupied,Name),
  idle(List).

new()->
  [].

makeList(Total,Occupied,Name)->
  %Db = dbt:empty(),
  write(Total,Occupied,Name,[]).

idle(List)->
  io:format("~p",[List]),
  receive
    {reserve,Pid}->
      Returned = lookup(List),
      if
         Returned =:= false ->
           Pid ! {error,full};
          true ->
            Pid ! ok
      end


  end.
  %receive


lookup(List) ->
  io:format("Looking..."),
  Item = (lists:search(fun(X) -> X#docking_point.state == "Empty" end, List)),
  ListValue = tuple_to_list(Item),
  Extracted = lists:nth(2, ListValue),
  TestPoint = Extracted#docking_point,
 % A = lists:map(fun tuple_to_list/1, A1),
  io:format("we found ~p",[Extracted]),
  if
    Item == false ->
    {error,full};
    true ->
      io:format("we found ~p",[Item]),
      io:format("code"),
      ExtractedPreviousPoint = Extracted#docking_point{state = "Occupied"},
      lists:delete(Extracted, List),
      lists:append([ExtractedPreviousPoint], List), {ok},
      io:format("Print list again... ~p",[List])

  end.


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




write(0,0,_,List)->
  List;
write(Total,Occupied,Name, List)when Occupied /= 0 ->
  [#docking_point{id = Total,state = "Occupied",name = Name}|write(Total-1,Occupied-1,Name,List)];
write(Total,Occupied,Name, List)when Occupied =:= 0 ->
  [#docking_point{id = Total,state = "Empty",name = Name}|write(Total-1,Occupied,Name,List)].

