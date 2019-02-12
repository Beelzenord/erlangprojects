%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Feb 2019 7:10 PM
%%%-------------------------------------------------------------------
-module(serverside).
-author("fno").
-behaviour(gen_server).
%% API
-export([start_link/0, init/1, handle_call/3, terminate/2]).
-export([attach/1, detach/0, lookup_id/1, lookup_phone/1]).

start_link() ->
  gen_server:start_link({local, serverside}, serverside, [], []).

init(_Args) ->
  io:format("here "),
  {ok, dbt:empty()}.

%% @doc Attaches the phone from the given PhoneNumber.
-spec attach(PhoneNumber::term()) -> ok.
attach(PhoneNumber) ->
  gen_server:call(hlr, {attach, self(), PhoneNumber}).

%% @doc Detaches the phone.
-spec detach() -> ok.
detach() ->
  gen_server:call(serverside, {detach, self()}).

%% @doc Checks the database for the PhoneNumber.
-spec lookup_id(PhoneNumber::term()) -> {ok, term()} | {error, invalid}.
lookup_id(PhoneNumber) ->
  gen_server:call(serverside, {lookup_id, self(), PhoneNumber}).

%% @doc Checks the database for the Pid.
lookup_phone(Pid) ->
  gen_server:call(serverside, {lookup_phone, self(), Pid}).

handle_call({attach, _Pid, PhoneNumber}, {From, _Ref}, Db) ->
  {reply, ok, dbt:write(From, PhoneNumber, Db)};

handle_call({detach, _Pid}, {From, _Ref}, Db) ->
  {reply, ok, dbt:delete(From, Db)};

handle_call({lookup_id, _Pid, PhoneNumber}, _From, Db) ->
  {reply, dbt:findElement(PhoneNumber, Db), Db};

handle_call({lookup_phone, _Pid, Key}, _From, Db) ->
  {reply, dbt:read(Key, Db), Db}.

terminate(_Reason, _DB) ->
  ok.

