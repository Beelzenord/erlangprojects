%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Feb 2019 4:27 PM
%%%-------------------------------------------------------------------
-module(server).
-author("fno").
-behavior(gen_server).

%-record(data,{db,locker,buff}).
%% API
-export([start_link/0,init/1,write/2]).
-export([handle_call/3,handle_cast/2]).
start_link()->
  gen_server:start_link({local,server},server,[],[]).

init(_Args) ->
  %Data = #data{db=db:new(),locker = none,buff=[]},
  Db = dbt:empty(),
  {ok, Db}.


write(Key, Element) ->
   gen_server:cast(?MODULE, {write,self(),Key,Element}).


handle_call({attach, _Pid, PhoneNumber}, {From, _Ref}, Db) ->
  {reply, ok, db:write(From, PhoneNumber, Db)}.

handle_cast(_, _) ->
  io:format("hi").





