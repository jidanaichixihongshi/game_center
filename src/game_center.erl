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
%%% Created : 26. 十一月 2018 下午 16:30
%%%-------------------------------------------------------------------
-module(game_center).
-author("cw").

%% API
-export([
	start/0,
	stop/0]).

start() ->
	Apps = [
		compiler,
		syntax_tools,
		goldrush,
		lager,
		crypto,
		asn1,
		public_key,
		ssl,
		ranch,
		protobuffs,
		eredis,
		cowlib,
		cowboy,
		game_center],
	start_app(Apps, permanent).

stop() ->
	io_lib:format("============ stop game center ============~n",[]).

start_app([], _Type) ->
	ok;
start_app([App | Apps], Type) ->
	case application:start(App, Type) of
		ok ->
			start_app(Apps, Type);
		{error, {already_started, _}} ->
			start_app(Apps, Type);
		{error, {not_started, NoApp}} ->
			Reason = io_lib:format("******** failed to start application '~p' ********~n", [NoApp]),
			exit_or_halt(Reason);
		{error, Reason} ->
			exit_or_halt(Reason)
	end.

exit_or_halt(Reason) ->
	halt(string:substr(lists:flatten(Reason), 1, 199)).













