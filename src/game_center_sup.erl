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
%%% Created : 26. 十一月 2018 下午 15:13
%%%-------------------------------------------------------------------

-module(game_center_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link([Port, ListenNum]) ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, [Port, ListenNum]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([Port, ListenNum]) ->
	{ok, Redis} = application:get_env(game_center, redis),
	PoolSpecs =
		lists:map(
			fun({Name, PoolArgs, WorkerArgs}) ->
				poolboy:child_spec(Name, PoolArgs, WorkerArgs)
			end, Redis),

	{ok, {{one_for_one, 5, 10}, [
		ranch:child_spec(game_center_receiver, ListenNum, ranch_tcp, [{port, Port}], game_center_receiver, []),
		?CHILD(mod_system_monitor, worker),
		?CHILD(mod_reloader, worker)
	] ++ PoolSpecs}}.





















