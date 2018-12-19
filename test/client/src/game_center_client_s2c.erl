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
%%% Created : 30. 十一月 2018 下午 14:16
%%%-------------------------------------------------------------------
-module(game_center_client_s2c).
-author("cw").

-behavior(gen_server).

-include("../include/common.hrl").
-include("protobuf_pb.hrl").

-export([start_link/0]).

%% API
-export([
	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-export([tcp_send/2]).

%% API.
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
	{ok, {IP, Port}} = application:get_env(landlords_client, addrs),
	case gen_tcp:connect(IP, Port, ?TCP_OPTIONS) of
		{ok, Socket} ->
			{ok, Uid} = application:get_env(game_center_client, uid),
			{ok, Password} = application:get_env(game_center_client, password),
			{ok, Phone} = application:get_env(game_center_client, phone),
			{ok, Version} = application:get_env(game_center_client, version),
			{ok, Device} = application:get_env(game_center_client, device),
			timer:send_interval(?HEART_BREAK_TIME, heartbeat),
			erlang:send_after(1000, self(), start_auth),
			State = #state{
				uid = Uid,
				passwd = Password,
				token = 100,
				phone = Phone,
				version = Version,
				device = Device,
				appid = 1,
				ip = IP,
				port = Port,
				socket = Socket,
				status = connect},
			ets:insert(?CLIENT_PUBLIC_ETS, {state, State}),
			{ok, State};
		{error, Reason} ->
			io:format("-------------connect error~n", []),
			{error, Reason}
	end.

handle_call(Request, _From, State) ->
	io:format("handle_call message ~p ~n", [Request]),
	{reply, ok, State}.

handle_cast(Request, State) ->
	io:format("handle_cast message ~p ~n", [Request]),
	{noreply, State}.


handle_info(heartbeat, #state{uid = Uid} = State) ->
	Router = mod_msg:router_create(Uid, <<"">>),
	AckMsg = mod_msg:request_create(101, 1, Router, <<"">>),  %% ACK
	{ok, ProtoMsg} = mod_proto:packet(AckMsg),
	tcp_send(State#state.socket, ProtoMsg),
	{noreply, State};
handle_info(start_auth, State) ->
	#state{uid = Uid,
		passwd = Psd,
		token = Token,
		phone = Phone,
		version = Vsn,
		device = Device,
		appid = AppId} = State,
	UserInfo = #{uid => Uid,
		device => Device,
		password =>Psd,
		token =>Token,
		phone =>Phone,
		version=>Vsn,
		device =>Device,
		location => <<"beijing">>,
		appid =>AppId},

	Child = maps:to_list(UserInfo),
	Mid = mod_msg:mid_create(Uid),
	Data = mod_msg:data_create(103, Mid, Child, <<"">>),
	Router = mod_msg:router_create(Uid, <<"">>),
	Auth = mod_msg:request_create(103, 1, Router, Data),
	tcp_send(State#state.socket, Auth),
	{noreply, State};

handle_info({send_msg, Msg}, State = #state{socket = Socket}) ->
	case mod_msg:packet(Msg) of
		{ok, Data} ->
			case gen_tcp:send(Socket, Data) of
				ok ->
					io:format("send msg to server :: ~p~n", [Msg]);
				Error ->
					io:format("Error: ~p~n", [Error])
			end;
		{error, _} ->
			io:format("msg : ~p packet error!~n", [Msg])
	end,
	{noreply, State};
handle_info({tcp, Socket, Data}, State) ->
	inet:setopts(Socket, [{active, once}]),
	Msg = mod_proto:unpacket(Data),
	NewState = handle_msg(Msg, State),
	{noreply, NewState};
handle_info({tcp_error, _, Reason}, State) ->
	io:format("------------------------------tcp_error~n", []),
	{stop, Reason, State};
handle_info(timeout, State) ->
	io:format("------------------------------timeout~n", []),
	{stop, normal, State};
handle_info(stop, State) ->
	io:format("------------------------------stop~n", []),
	{stop, normal, State};
handle_info(Info, State) ->
	io:format("undefined msg ~p~n", [Info]),
	{noreply, State}.

terminate(Reason, State) ->
	ets:delete(?CLIENT_PUBLIC_ETS, state),
	Socket = State#state.socket,
	io:format("socket ~p terminate, reason: ~p ~n", [Socket, Reason]),
	gen_tcp:close(Socket),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


tcp_send(Socket, Msg) ->
	io:format("tcp send msg : ~p~n", [Msg]),
	case gen_tcp:send(Socket, Msg) of
		{error, Reason} ->
			io:format("send msg Error, reason :: ~p~n", [Reason]);
		_ ->
			io:format("send msg ok ...~n", [])
	end.


%% ASK
handle_msg(#proto{mt = 101, sig = 2, ts = MTimestamp} = Msg, State) ->
	MsTimestamp = lib_common:get_mstimestamp(),
	case MTimestamp + 6000 > MsTimestamp of
		true ->
			State;
		_ ->
			io:format("recv overtime msg,~p~n ", [Msg]),
			State
	end;
handle_msg(Msg, #state{socket = Socket} = State) ->
	io:format("receive tcp msg ::: ~p~n", [Msg]),
	MsTimestamp = lib_common:get_mstimestamp(),
	catch
		gen_fsm:send_event(Socket, Msg),
	State;
handle_msg(Msg, State) ->
	MsTimestamp = lib_common:get_mstimestamp(),
	io:format("message unrecognized :: ~p~n", [Msg]),
	State.

























