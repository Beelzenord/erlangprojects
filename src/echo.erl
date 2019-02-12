%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 2:25 PM
%%%-------------------------------------------------------------------
-module(echo).
-author("fno").

%% API
-export([start/0,stop/0,print/1,listen/0]).

start()->
  register(echo,spawn(echo,listen,[])),
  ok.

print(Message)->
  echo ! {print,Message},
  ok.

stop()->
  echo ! stop,
  ok.

listen()->
  receive
    {print,Msg}->
      io:format("~p~n",[Msg]),
      listen();
    stop->
      true
  end.
