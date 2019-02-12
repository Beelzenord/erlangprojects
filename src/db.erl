-module(db).
-export([new/0, write/3, delete/2, read/2, match/2, destroy/1]).
 -export_type([db/0]).
 -type db() :: list().

 %% @doc Create a new database
 -spec new() -> db().
new() ->
  [].

 %% @doc Insert a new element in the database
 -spec write(Key::term(), Val::term(), db()) -> db().
write(Key, Element, []) ->
  [{Key, Element}];
 write(Key, Element, [{Key, _} | Db]) ->
 [{Key, Element}|Db];
 write(Key, Element, [Current | Db]) ->
 [Current | write(Key, Element, Db)].

delete(Key, [{Key, _Element}|Db]) ->
  Db;
delete(Key, [Tuple|Db]) ->
  [Tuple|delete(Key, Db)];
delete(_Key, []) ->
  [].
%% @doc Retrieve the first element in the database with a matching key
-spec read(Key::term(), db()) -> {ok, term()} | {error, instance}.
read(Key, [{Key, Element}|_Db]) ->
  {ok, Element};
read(Key, [_Tuple|Db]) ->
  read(Key, Db);
read(_Key, []) ->
  {error, instance}.
%% @doc Return all the keys whose values match the given element.
-spec match(Val::term(), db()) -> [term()].
match(Element, [{Key, Element}|Db]) ->
  [Key|match(Element, Db)];
match(Element, [_Tuple|Db]) ->
  match(Element, Db);
match(_Key, []) ->
  [].
%% @doc Deletes the database.
-spec destroy(db()) -> ok.
destroy(_Db) ->
  ok.