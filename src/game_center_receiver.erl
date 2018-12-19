%%%-------------------------------------------------------------------
%%% * ━━━━━━神兽出没━━━━━━
%%% * 　　　┏┓　　　┏┓
%%% * 　　┏┛┻━━━┛┻┓
%%% * 　　┃　　　　　　　┃
%%% * 　　┃　　　━　　　┃
%%% * 　　┃　┳┛　┗┳　┃
%%% * 　　┃　　　　　　　┃
%%% * 　　┃　　　┻　　　┃
%%% * 　　┃　　　　　　　┃
%%% * 　　┗━┓　　　┏━┛
%%% * 　　　　┃　　　┃ 神兽保佑
%%% * 　　　　┃　　　┃ 代码无bug　　
%%% * 　　　　┃　　　┗━━━┓
%%% * 　　　　┃　　　　　　　┣┓
%%% * 　　　　┃　　　　　　　┏┛
%%% * 　　　　┗┓┓┏━┳┓┏┛
%%% * 　　　　　┃┫┫　┃┫┫
%%% * 　　　　　┗┻┛　┗┻┛
%%% * ━━━━━━感觉萌萌哒━━━━━━
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 十一月 2018 下午 14:11
%%%-------------------------------------------------------------------
-module(game_center_receiver).
-author("cw").

-behavior(gen_server).
-behavior(ranch_protocol).

%% API
-export([start_link/4]).

-export([
	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-include("game_center.hrl").
-include("protobuf_pb.hrl").
-include("logger.hrl").

-record(receiver_state, {
	ref,
	c2s_pid :: pid(),
	socket :: inet:socket(),
	transport,
	opts,
	last_recv_time
}).


%% API.
start_link(Ref, Socket, Transport, Opts) ->
	gen_server:start_link(?MODULE, [Ref, Socket, Transport, Opts], []).

%% gen_server.
%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
init([Ref, Socket, Transport, Opts]) ->
	erlang:process_flag(trap_exit, true),
	ok = proc_lib:init_ack({ok, self()}),
	ok = ranch:accept_ack(Ref),
	ok = Transport:setopts(Socket, [{active, once}, {packet, 4}]),
	{ok, Pid} = game_center_c2s:start_link({ranch_tcp, Socket, self()}, []),
	?INFO("landlords_c2s init, socket: ~p~n", [Socket]),
	State = #receiver_state{
		ref = Ref,
		c2s_pid = Pid,
		socket = Socket,
		transport = Transport,
		opts = Opts
	},
	gen_server:enter_loop(?MODULE, [], State, ?HIBERNATE_TIMEOUT).


handle_call(Request, _From, State) ->
	?DEBUG("handle_call message ~p ~n", [Request]),
	{reply, ok, State, ?HIBERNATE_TIMEOUT}.
handle_cast(Request, State) ->
	?DEBUG("handle_cast message ~p ~n", [Request]),
	{noreply, State, ?HIBERNATE_TIMEOUT}.


%% handle socket data
handle_info({tcp, Socket, Data}, State) ->
	Transport = State#receiver_state.transport,
	Transport:setopts(Socket, [{active, once}]),
	%% 要不要把消息存进内存呢？
	Msg = mod_proto:unpacket(Data),
	NewState = process_msg(Msg, State),
	{noreply, NewState, ?HIBERNATE_TIMEOUT};

%% timout function
handle_info(timeout, State) ->
	{stop, normal, State};
handle_info(Info, State) ->
	?WARNING("unused info : ~p~n", [Info]),
	{noreply, State, ?HIBERNATE_TIMEOUT}.

terminate(Reason, State) ->
	#receiver_state{c2s_pid = C2SPid, socket = Socket} = State,
	?INFO("socket ~p terminate, reason: ~p~n", [Socket, Reason]),
	%% 清除连接
	%% 设置定时器
	mod_proc:is_proc_alive(C2SPid) == true andalso gen_fsm:send_event(C2SPid, closed),
	gen_tcp:close(Socket),
	ok.

code_change(_OldVsn, State, _Extra) ->
	?INFO("Module ~p changed ...~n", [?MODULE]),
	{ok, State}.


%% ACK
process_msg(#proto{mt = ?MT_101, sig = ?SIGN1, router = Router, ts = MTimestamp} = Msg,
	#receiver_state{transport = Mod, socket = Socket} = State) ->
	MsTimestamp = lib_time:get_mstimestamp(),
	case MTimestamp + ?DATA_OVERTIME > MsTimestamp of
		true ->
			?DEBUG("recv ~p ack ok ... ...~n", [State#receiver_state.socket]),
			NewRouter = mod_msg:transform_router(Router),
			AskMsg = mod_msg:reply_create(?MT_101, ?SIGN2, NewRouter, <<"">>),  %% ASK
			{ok, ProtoMsg} = mod_proto:packet(AskMsg),
			game_center_c2s:tcp_send(Mod, Socket, ProtoMsg),
			State#receiver_state{last_recv_time = MsTimestamp};
		_ ->
			?WARNING("recv overtime msg,~p~n ", [Msg]),
			State#receiver_state{last_recv_time = MsTimestamp}
	end;
process_msg(Msg, #receiver_state{c2s_pid = C2SPid} = State) when is_pid(C2SPid) ->
	?INFO("receive tcp msg ::: ~p~n", [Msg]),
	MsTimestamp = lib_time:get_mstimestamp(),
	catch
		gen_fsm:send_event(C2SPid, Msg),
	State#receiver_state{last_recv_time = MsTimestamp};
process_msg(Msg, State) ->
	MsTimestamp = lib_time:get_mstimestamp(),
	?WARNING("message unrecognized :: ~p~n", [Msg]),
	State#receiver_state{last_recv_time = MsTimestamp}.












