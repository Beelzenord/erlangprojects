%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 9:11 PM
%%%-------------------------------------------------------------------
-module(lc).
-author("fno").

%% API
-export([]).

three()->
  [X || X <- lists:seq(1,10), X rem 3 == 0].

