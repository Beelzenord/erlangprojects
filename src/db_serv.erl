%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Mar 2019 23:08
%%%-------------------------------------------------------------------
-module(db_serv).
-author("fno").


-export([start/0,add/2,remove/1,stop_server/0]).
-export([init/0,read/1,match/1]).


%we start a server process called db_serv, that executes init
start()->
  register(db_serv, spawn(db_serv, init, [])).

%Client: add a node the the database on the server-side
add(Key,Value)->
  db_serv ! {add_node,Key,Value,self()},
  receive
    {reply,Db}->{ok,Db};
    {error}->{error,ok}
  end.

%Client: remove the node by the Key.
remove(Key)->
  db_serv ! {remove,Key,self()},
  receive
    {reply,Db}->{ok,Db};
    {error}->{error,ok}
  end.
%Client: Read a node by Key, returns an error if no node is found
read(Key)->
  db_serv ! {read_node,Key,self()},
  receive
    {reply,Db}->Db;
    {error,Reason}->{error,Reason}
  end.
%Client: Read a node by Value, returns an error if it returns an empty list
match(Value)->
  db_serv ! {match_node,Value,self()},
  receive
    {reply,Node}->{ok,Node};
    {error,Reason}->{error,Reason}
  end.

stop_server()->
  db_serv ! {stop_server,self()},
  receive
    {ok}->{ending}
  end.


% Server: starts a database enters a recursive loop
init()->
  Db = dbt:empty(),
  listen(Db).


%%server: listen to client commands
listen(Db)->
  receive
    {add_node, Key,Value,Pid} ->
      UpgradedDB = doWrite(Key,Value,Db),
      sendToClient(Pid,UpgradedDB),
      listen(UpgradedDB);
    {read_node,Key,Pid}->
      handleRead(Pid,Db,Key),
      listen(Db);
    {match_node,Value,Pid}->
      handleMatch(Pid,Db,Value),
      listen(Db);
    {remove,Key,Pid}->
      UpgradedDB = doRemove(Key,Db),
      sendToClient(Pid,UpgradedDB),
      listen(UpgradedDB);
    {stop_server,Pid}->
      Pid ! {ok}
  end.
%Server: performs match operation, sends an error message if it can't find a match
handleMatch(Pid,Db,Value)->
  Response = dbt:match(Value,Db),
  if
    Response == []->
      sendError(Pid,no_entry);
    true->
      sendToClient(Pid,Response)
  end.
%Server: performs a read operation, sends an error message if it can't find the key
handleRead(Pid,Db,Key)->
  Response = dbt:read(Key,Db),
  if
     Response == undefined->
       sendError(Pid,undedefined);
    true ->
      sendToClient(Pid,Response)
  end.
% Server: performs the database write operation .
doWrite(Key, Value,Db) ->
  dbt:write(Key,Value,Db).
% Server: performs the delete operation on the database
doRemove(Key,Db) ->
  dbt:delete(Key,Db).
%Server: sends a feedback to the client
sendToClient(Pid,Db)->
  Pid ! {reply,Db}.
%Server: sends an error message to the client
sendError(Pid, Reason)->
  Pid ! {error,Reason}.