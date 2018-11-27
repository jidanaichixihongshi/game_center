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
-module(game_center_auth).
-author("cw").

-behavior(gen_fsm).

%% API
-export([]).


-include("game_center.hrl").
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
	wait_for_auth/2
]).

-record(auth_state, {
	uid,
	nickname,
	pwd,
	token,
	node,
	status,
	proxy,
	socket,
	ip,
	port,
	sockmod,
	retry_times
}).

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
	StateData = #auth_state{
		status = ?STATUS_LOGGING,
		node = node(),
		socket = Socket,
		ip = Address,
		port = Port,
		sockmod = SockMod,
		retry_times = 0},
	{ok, wait_for_auth, StateData, ?AUTH_TIMEOUT}.

wait_for_auth(Proto, StateData) ->
	fsm_next_state(wait_for_auth, StateData);
wait_for_auth(closed, StateData) ->
	{stop, normal, StateData};
wait_for_auth(stop, StateData) ->
	{stop, normal, StateData}.


handle_event(Event, StateName, StateData) ->
	?WARNING("undefined event : ~p~n", [Event]),
	fsm_next_state(StateName, StateData).

handle_sync_event(_Event, _From, StateName, StateData) ->
	fsm_reply(ok, StateName, StateData).

handle_info({fsm_next_state, NewStateName}, _StateName, StateData) ->
	?DEBUG("fsm_next_state~n",[]),
	fsm_next_state(NewStateName, StateData);
handle_info(Event, StateName, StateData) ->
	?WARNING("undefined event : ~p~n", [Event]),
	fsm_next_state(StateName, StateData).



terminate(Reason, _StateName, StateData) ->
	#auth_state{
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
fsm_next_state(wait_for_auth, #auth_state{retry_times = TetryTimes} = StateData) when TetryTimes > 1 ->
	{stop, normal, StateData};
fsm_next_state(wait_for_auth, #auth_state{retry_times = TetryTimes} = StateData) ->
	{next_state, wait_for_auth, StateData#auth_state{retry_times = TetryTimes + 1}, ?AUTH_TIMEOUT};
fsm_next_state(StateName, StateData) ->
	{next_state, StateName, StateData, ?AUTH_TIMEOUT}.


%% fsm_reply: Generate the reply FSM tuple with different timeout,
%% depending on the future state
fsm_reply(Reply, StateName, StateData) ->
	{reply, Reply, StateName, StateData, ?AUTH_TIMEOUT}.











