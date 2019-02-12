%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 2:44 PM
%%%-------------------------------------------------------------------
-module(ring).
-author("fno").

%% API
-export([start/3]).

-export([master/3,loop/2]).

start(ProcNum,MsgNum,Message)->
  spawn(ring,master,[ProcNum,MsgNum,Message]).

master(ProcNum,MsgNum,Message)->
  Pid = start_slaves(ProcNum,self()),
%  io:format("Process:~p initiating~n",[Pid]),
  master_loop(MsgNum,Message,Pid).

start_slaves(1,Pid)->
  io:format("[last]Process:~p number: ~p initiating~n",[Pid,1]),
  Pid;

start_slaves(ProcNum, Pid) ->
  NewPid = spawn(ring,loop,[ProcNum,Pid]),
  io:format("Process:~p number: ~p initiating~n",[Pid,ProcNum]),
  start_slaves(ProcNum-1,NewPid).

loop(ProcNum,Pid)->
  receive
    stop->
      io:format("Process:~p terminating~n",[ProcNum]),
      Pid ! stop;
    Message ->
      io:format("Process:~p [~p] received: ~p~n",[ProcNum,Pid,Message]),
      Pid ! Message,
      loop(ProcNum,Pid)
  end.

master_loop(0,_Message,Pid)->
  io:format("Process:1 terminating~n"),
  Pid ! stop;

master_loop(MsgNum, Message, Pid) ->
  io:format("sending to process: ~p~n",[Pid]),
  Pid ! Message,
  receive
    Message->
      io:format("[m]Process:1 received:~p~n",[Message]),
      master_loop(MsgNum-1,Message,Pid)
  end.