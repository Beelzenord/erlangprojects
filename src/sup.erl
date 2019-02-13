%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 7:49 PM
%%%-------------------------------------------------------------------
-module(sup).
-author("fno").

%% API
-export([start/1,stop/1,start_child/4]).

-export([init/0]).


%%% @doc Starts an Erlang Process Supervisor
-spec start(atom()) -> {ok, pid()}.
start(Name) ->
  Pid = spawn(sup, init, []),
  register(Name, Pid),
  {ok, Pid}.
%%%
-spec stop(pid() | atom()) -> ok.
stop(Name) ->
  Name ! stop,
  ok.
%%% @doc Given a
%%% and monitor it. If it terminates abnormally, the child is
%%% restarted.
-spec start_child(atom(), atom(), atom(), [term()]) -> {ok, pid()}.
start_child(Name, Module, Function, Args) ->
  Name ! {start_child, self(), Module, Function, Args},
  receive
    {ok, Pid} -> {ok, Pid}

  end.
%%% @doc Initialises the supervisor state
-spec init() -> ok.
init() ->
  process_flag(trap_exit, true),
  loop([]).
%%% loop([child()]) -> ok.
%%% child() = {pid(), restar_count(), mod(), func(), [args()]}.
%%% restart_count() = integer(). number of times the child has restarted
%%% mod() = atom(). the module where the spawned function is located
%%% func() = atom(). the function spawned
%%% args() = term(). the arguments passed to the function
%%% The supervisor loop which handles the incoming client requests
%%% and EXIT signals from supervised children.
-type child() :: {pid(), non_neg_integer(), atom(), atom(), [term()]}.
-spec loop([child()]) -> ok.
loop(Children) ->
  receive
    {start_child, ClientPid, Mod, Func, Args} ->
      Pid = spawn_link(Mod, Func, Args),
      ClientPid ! {ok, Pid},
      loop([{Pid, 1, Mod, Func, Args}|Children]);
    {'EXIT', Pid, normal} ->
      NewChildren = lists:keydelete(Pid, 1, Children),
      loop(NewChildren);
    {'EXIT', Pid, Reason} ->
      NewChildren = lists:keydelete(Pid, 1, Children),
      {value, Child} = lists:keysearch(Pid, 1, Children),
      {Pid, Count, Mod, Func, Args} = Child,
      error_message(Pid, Count, Reason, Mod, Func, Args),
      NewPid = spawn_link(Mod, Func, Args),
      loop([{NewPid, Count + 1, Mod, Func, Args}|NewChildren]);
    stop ->
      kill_children(Children)
end.
%%% Kills all the children in the supervision tree.
-spec kill_children([child()]) -> ok.
kill_children([{Pid, _Count, _Mod, _Func, _Args}|Children]) ->
  exit(Pid, kill),
  kill_children(Children);
kill_children([]) ->
  ok.
%%% Prints an error message for the child which died.
-spec error_message(pid(), non_neg_integer(), term(), atom(), atom(), [term()])
      -> ok.
error_message(Pid, Count, Reason, Mod, Func, Args) ->
  io:format("~50c~n",[$-]),
  io:format("Error: Process ~p Terminated ~p time(s)~n",[Pid, Count]),
  io:format("       Reason for termination:~p~n",[Reason]),
  io:format("       Restarting with ~p:~p/~p~n",[Mod,Func,length(Args)]),
  io:format("~50c~n",[$-]).