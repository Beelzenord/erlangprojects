-module(simple_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link(simple_sup, []),
  io:format("Does this execute").

init(_Args) ->
  SupFlags = #{strategy => simple_one_for_one,
    intensity => 0,
    period => 1},
  ChildSpecs = [#{id => call,
    start => {call, start_link, []},
    shutdown => brutal_kill}],
  {ok, {SupFlags, ChildSpecs}}.