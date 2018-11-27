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
%%% Created : 26. 十一月 2018 下午 15:09
%%%-------------------------------------------------------------------

-module(game_center_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-include("game_center.hrl").
-include("logger.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	create_ets(?ETS_LIST),
	{ok, CenterNode} = application:get_env(game_center, center_node),
	{ok, Http_Port} = application:get_env(game_center, http_port),
	{ok, Tcp_Port} = application:get_env(game_center, tcp_port),
	{ok, ListenNum} = application:get_env(game_center, listen_num),
	{ok, _} = start_http_link(Http_Port),
	{ok, Pid} = game_center_sup:start_link([Tcp_Port, ListenNum]),
	connect_node(CenterNode),
	{ok, Pid}.

stop(_State) ->
	?INFO("**** stop game center! ****~n", []),
	try
		disconnect_node()
	catch
		Error ->
			?ERROR("STOP ERROR: ~p~n", [Error])
	after
		?INFO("stop node ok: ~p~n", [node()]),
		init:stop()
	end.


%% 初始化ets表
create_ets([]) ->
	?INFO("create ets ok ...~n", []);
create_ets([{Tab, Cfg} | EtsList]) ->
	case ets:info(Tab) of
		undefined ->
			?DEBUG("create ets ~p ...~n", [Tab]),
			ets:new(Tab, Cfg),
			create_ets(EtsList);
		_ ->
			create_ets(EtsList)
	end.

%% http链接
start_http_link(Http_Port) ->
	?INFO("cowboy start http link ...~n", []),
	Routes = [
		{'_', [
			{"/", game_center_http_receiver, []}
		]}
	],
	Dispatch = cowboy_router:compile(Routes),
	cowboy:start_http(http, 100, [{port, Http_Port}], [{env, [{dispatch, Dispatch}]}]).

connect_node(CenterNode) ->
	case net_adm:ping(CenterNode) of
		pong ->
			timer:sleep(500),
			?INFO("ping center node ok", []),
			ok;
		pang ->
			?WARNING("ping node pang, Node:~p~n", [CenterNode]),
			timer:sleep(1000),
			connect_node(CenterNode)
	end.

disconnect_node() ->
	lists:foreach(
		fun(Node) ->
			?INFO("disconnect node:~p", [Node]),
			erlang:disconnect_node(Node)
		end, nodes()).


















