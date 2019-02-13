%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Feb 2019 3:00 PM
%%%-------------------------------------------------------------------
-module(db_sup).
-author("fno").
-behavior(supervisor).
%% API
-export([start_link/0,init/1,stop/0]).


start_link()->
  supervisor:start_link({local,?MODULE},?MODULE,no_args).

init(no_args)->
  {ok,{{rest_for_one,5,2000},[child(dbt,[])]}}.

stop()->
  exit(whereis(?MODULE),shutdown).

child(Module,Args)->
  {Module,{Module,start_link,Args},permanent, 2000, worker, [Module]}.