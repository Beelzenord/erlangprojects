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
-export([start_link/3,init/3,makeList/2,new/0,write/3,idle/1,book/0]).
-record(docking_point,{id,state}).

start_link(Total,Occupied, Name)->
  register(dockStation,spawn(ss_docking_station,init,[Total,Occupied,Name])).
 % makeList(Total,Occupied).

book()->
  dockStation ! {reserve,self()},
receive
    ok -> done
  end.

init(Total,Occupied,_)->
  List =makeList(Total,Occupied),
  idle(List).

new()->
  [].

makeList(Total,Occupied)->

  write(Total,Occupied,[]).



idle(List)->
  io:format("Rick and Morty ~p",[List]),
  receive
    {reserve,Pid}->
      Pid ! ok
  end.
  %receive






write(0,0,List)->
  List;
write(Total,Occupied, List)when Occupied /= 0 ->
  [#docking_point{id = Total,state = "Occupied"}|write(Total-1,Occupied-1,List)];
write(Total,Occupied, List)when Occupied =:= 0 ->
  [#docking_point{id = Total,state = "Empty"}|write(Total-1,Occupied,List)].

