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
%%% Created : 27. 十一月 2018 下午 16:15
%%%-------------------------------------------------------------------
-module(game_center_c2s).
-author("cw").

-behavior(gen_fsm).

%% API
-export([]).


-include("game_center.hrl").
-include("protobuf_pb.hrl").
-include("error.hrl").
-include("logger.hrl").

-export([
	start/2,
	stop/1,
	start_link/2,
	close/1,
	init/1,
	handle_event/3,
	handle_info/3,
	handle_sync_event/4,
	terminate/3,
	code_change/4
]).

-export([
	wait_for_auth/2,
	wait_for_auth2/2,
	wait_for_increment/2,
	session_established/2,
	tcp_send/3
]).


%%%----------------------------------------------------------------------
%%% API
%%%----------------------------------------------------------------------
start(SockData, _Opts) ->
	gen_fsm:start(?MODULE, [SockData], []).

start_link(SockData, _Opts) ->
	gen_fsm:start_link(?MODULE, [SockData], []).

stop(FsmRef) -> gen_fsm:send_event(FsmRef, stop).
close(FsmRef) -> gen_fsm:send_event(FsmRef, closed).

%% ----------------------------------------------------------------
%% GEN_FSM API
%% ----------------------------------------------------------------
init([]) ->
	{ok, undefined};
init([{SockMod, Socket, _SockPid}]) ->
	{ok, {Address, Port}} = inet:peername(Socket),
	StateData = #client_state{
		status = ?STATUS_LOGGING,
		node = node(),
		socket = Socket,
		ip = Address,
		port = Port,
		sockmod = SockMod,
		retry_times = 0},
	{ok, wait_for_auth, StateData, ?AUTH_TIMEOUT}.

wait_for_auth(#proto{mt = ?MT_103, sig = ?SIGN1, router = Router, data = Data, ts = Timestamp} = Msg,
	#client_state{sockmod = SockMod, socket = Socket} = StateData) ->
	#data{dt = Dt, mid = Mid, children = Child} = Data,
	AuthInfo = lib_change:to_maps(Child),
	Uid = maps:get(uid, AuthInfo),
	NotOverTime = mod_msg:check_timestamp(Timestamp),
	if
		Dt /= 0 ->
			?WARNING("auth msg error: ~p~n", [Msg]),
			NewRouter = mod_msg:transform_router(Router),
			ReplyChild = [{mid, Mid}, {code, ?ERROR_100}],
			reply_auth(SockMod, Socket, Uid, NewRouter, ReplyChild),
			fsm_next_state(wait_for_auth, StateData);
		NotOverTime ->
			{StateName, NewStateData} = authenticate(Data, AuthInfo, StateData),
			fsm_next_state(StateName, NewStateData);
		true ->
			?WARNING("overtime msg : ~p~n", [Msg]),
			NewRouter = mod_msg:transform_router(Router),
			ReplyChild = [{mid, Mid}, {code, ?ERROR_102}],
			reply_auth(SockMod, Socket, Uid, NewRouter, ReplyChild),
			fsm_next_state(wait_for_auth, StateData)
	end;
wait_for_auth(timeout, StateData) ->
	{stop, normal, StateData};
wait_for_auth(closed, StateData) ->
	{stop, normal, StateData};
wait_for_auth(stop, StateData) ->
	{stop, normal, StateData}.

wait_for_auth2(#proto{mt = ?MT_103, sig = ?SIGN1, data = Data, ts = Timestamp}, StateData) ->
	#data{dt = Dt, children = Child} = Data,
	NotOverTime = mod_msg:check_timestamp(Timestamp),
	if
		Dt /= 1 ->
			{wait_for_auth2, StateData};
		NotOverTime ->
			case lists:keyfind(code, 1, Child) of
				{code, ?ERROR_0} ->
					fsm_next_state(wait_for_increment, StateData);
				_ ->
					fsm_next_state(wait_for_auth2, StateData)
			end;
		true ->
			fsm_next_state(wait_for_auth2, StateData)
	end;
wait_for_auth2(timeout, StateData) ->
	{stop, normal, StateData};
wait_for_auth2(closed, StateData) ->
	{stop, normal, StateData};
wait_for_auth2(stop, StateData) ->
	{stop, normal, StateData}.

wait_for_increment(timeout, StateData) ->
	{stop, normal, StateData};
wait_for_increment(closed, StateData) ->
	{stop, normal, StateData};
wait_for_increment(stop, StateData) ->
	{stop, normal, StateData}.

session_established(#proto{mt = ?MT_103}, StateData) ->
	{stop, normal, StateData}.


handle_event(Event, StateName, StateData) ->
	?WARNING("undefined event : ~p~n", [Event]),
	fsm_next_state(StateName, StateData).

handle_sync_event(_Event, _From, StateName, StateData) ->
	fsm_reply(ok, StateName, StateData).

handle_info({fsm_next_state, NewStateName}, _StateName, StateData) ->
	?DEBUG("fsm_next_state~n", []),
	fsm_next_state(NewStateName, StateData);
handle_info(Event, StateName, StateData) ->
	?WARNING("undefined event : ~p~n", [Event]),
	fsm_next_state(StateName, StateData).



terminate(Reason, _StateName, StateData) ->
	#client_state{
		uid = Uid,
		proxy = ProxyPid,
		socket = _Socket,
		sockmod = _SockMod} = StateData,
	?INFO("game_center auth for ~p terminate, reason: ~p~n", [Uid, Reason]),
	case mod_proc:is_proc_alive(ProxyPid) of
		true ->
			ok;
		_ ->
			ok
	end.

code_change(_OldVsn, StateName, StateData, _Extra) ->
	?INFO("Module ~p changed ...~n", [?MODULE]),
	{ok, StateName, StateData}.


%% ----------------------------------------------------------------
%% internal api
%% ----------------------------------------------------------------
%% fsm_next_state: Generate the next_state FSM tuple with different
%% timeout, depending on the future state
fsm_next_state(wait_for_auth, #client_state{retry_times = TetryTimes} = StateData) when TetryTimes > 1 ->
	{stop, normal, StateData};
fsm_next_state(wait_for_auth, #client_state{retry_times = TetryTimes} = StateData) ->
	{next_state, wait_for_auth, StateData#client_state{retry_times = TetryTimes + 1}, ?AUTH_TIMEOUT};
fsm_next_state(wait_for_auth2, #client_state{retry_times = TetryTimes} = StateData) when TetryTimes > 1 ->
	{stop, normal, StateData};
fsm_next_state(wait_for_auth2, #client_state{retry_times = TetryTimes} = StateData) ->
	{next_state, wait_for_auth2, StateData#client_state{retry_times = TetryTimes + 1}, ?AUTH_TIMEOUT};
fsm_next_state(StateName, StateData) ->
	{next_state, StateName, StateData, ?AUTH_TIMEOUT}.


%% fsm_reply: Generate the reply FSM tuple with different timeout,
%% depending on the future state
fsm_reply(Reply, StateName, StateData) ->
	{reply, Reply, StateName, StateData, ?AUTH_TIMEOUT}.


tcp_send(Mod, Socket, Reply) ->
	case Mod:send(Socket, Reply) of
		{error, Reason} ->
			?ERROR("send msg Error, Reason :: ~p~n", [Reason]);
		_ ->
			?INFO("send tcp msg :: ~p~n", [Reply])
	end.

reply_auth(SockMod, Socket, Uid, Router, Child) ->
	NewMid = mod_msg:mid_create(Uid),
	Data = mod_msg:data_create(0, NewMid, Child, <<"">>),
	Reply = mod_msg:reply_create(?MT_103, ?SIGN2, Router, Data),
	{ok,ProtoReply} = mod_proto:packet(Reply),
	tcp_send(SockMod, Socket, ProtoReply).


authenticate(Data, AuthData, #client_state{sockmod = SockMod, socket = Socket} = StateData) ->
	Mid = Data#data.mid,
	#{uid := Uid,
		device := Device,
		token := Token,
		vsn := Vsn,
		deviceid := DeviceId,
		appid := AppId,
		location := Location,
		phone := Phone} = AuthData,
	NewRouter = mod_msg:router_create(<<"">>, Uid),
	if
		Token == 100 ->
			UserData = #user_data{
				uid = Uid,
				nickname = <<"晴天">>,
				level = 0,
				version = Vsn,
				device = Device,
				device_id = DeviceId,
				app_id = AppId,
				token = Token,
				location = Location,
				phone = Phone},
			ReplyChild = [{mid, Mid}, {code, ?ERROR_0}],
			reply_auth(SockMod, Socket, Uid, NewRouter, ReplyChild),
			NewStateData = StateData#client_state{
				uid = Uid,
				status = ?STATUS_LOGGING,
				node = node(),
				user_data = UserData},
			{wait_for_auth2, NewStateData};
		true ->
			ReplyChild = [{mid, Mid}, {code, ?ERROR_134}],
			reply_auth(SockMod, Socket, Uid, NewRouter, ReplyChild),
			{wait_for_auth, StateData}
	end.





