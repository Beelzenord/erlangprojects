%%%-------------------------------------------------------------------
%%% @author fno
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2019 3:58 PM
%%%-------------------------------------------------------------------
-module(crossring).
-author("fno").

%% API
-export([start/3]).

-export([master/3,loop/2]).

start(ProcNum,MsgNum,Message)->
  spawn(crossring,master,[ProcNum,MsgNum,Message]).

master(ProcNum,Msg,Msg)->
  ProcLim = round(ProcNum/2),
  {MidPid,FirstPid} = start_slaves(ProcNum,ProcLim,self()),
  master_loop(Msg,{first_half,Msg},FirstPid,MidPid).
  
start_slaves(1,_,Pid)->
  Pid;
start_slaves(ProcNum,ProcLim,Pid)->
  MidPid = spawn(crossring,loop,[ProcNum,Pid]),
  {MidPid,start_slaves(ProcNum-1,ProcLim,self())};

start_slaves(ProcNum, ProcLim, Pid) ->
  NewPid = spawn(crossring,loop,[ProcNum,Pid]),
  start_slaves(ProcNum-1,ProcLim,NewPid).

loop(ProcNum,Pid)->
  receive
    stop->
      io:format("Process: ~p terminating~n",[ProcNum]),
      Pid!stop;
    {Part,Message}->
      io:format("Process: ~p received: ~p~n",[ProcNum,Message]),
      Pid ! {Part,Message},
      loop(ProcNum,Pid)
  end.
master_loop(0,_Message,FirstPid,MidPid)->
  io:format("Process: 1 terminating~n"),
  MidPid ! FirstPid ! stop;
master_loop(MsgNum, {first_half,Message}, FirstPid, MidPid) ->
  FirstPid ! {first_half,Message},
  receive
    {first_half,Message}->
      io:format("Process: 1 received: ~p halfway through~n",[Message]),
      master_loop(MsgNum,{second_half,Message},FirstPid,MidPid)
  end;

master_loop(MsgNum,{second_half,Message},FirstPid,MidPid)->
  MidPid ! {second_half,Message},
  receive
    {second_half,Message}->
      io:format("Process: 1 received: ~p~n",[Message]),
      master_loop(MsgNum-1,{first_half,Message},FirstPid,MidPid)
  end.