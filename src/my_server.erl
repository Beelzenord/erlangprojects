%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Feb 2019 23:21
%%%-------------------------------------------------------------------
-module(my_server).
-author("fno").
-behaviour(gen_server).
%% API
-export([start_link/0,add/3,read/2,match/2,remove/2,read_all/1,stop/1]).
-export([init/1,handle_call/3]).

%%% Client API
start_link() ->
  gen_server:start_link(?MODULE, [], []).



%Client: add node to database
add(Pid, Value,Key) ->
  gen_server:call(Pid, {add_node, Value,Key}).
%Client: perform read from database
read(Pid,Key)->
  gen_server:call(Pid,{read_node,Key}).
%Client: read the current state of the database
read_all(Pid)->
  gen_server:call(Pid,{read_tree}).
%Client: perform match on the given, value
match(Pid,Value)->
  gen_server:call(Pid,{match_node,Value}).
%Client: perform delete on the given node.
remove(Pid,Key)->
  gen_server:call(Pid,{remove_node,Key}).

stop(Pid)->
  gen_server:call(Pid,terminate).

%Server: makes new database
init([]) -> {ok, dbt:empty()}.


handle_call({add_node,Value,Key},_From,Db)->
  {reply,updating,dbt:write(Key,Value,Db)};
handle_call({read_node,Key},_From,Db)->
  Response = dbt:read(Key,Db),
  if
    Response == undefined->
    {reply,{error,undefined},Db};
    true->
      {reply,dbt:read(Key,Db),Db}
  end;
 % {reply,dbt:read(Key,Db),Db};
handle_call({read_tree},_From,Db)->
  {reply,Db,Db};
handle_call({match_node,Value},_From,Db)->
  Response = dbt:match(Value,Db),
  if
    Response =:= []->
     {reply,{error,no_match},Db};
    true->
       {reply,Response,Db}
  end;
handle_call({remove_node,Key},_From,Db)->
  {reply,ok,dbt:delete(Key,Db)};

handle_call(terminate, _From, Db) ->
  {stop, normal, ok, Db}.





