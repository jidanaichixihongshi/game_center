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
%%% Created : 27. 十一月 2018 下午 12:46
%%%-------------------------------------------------------------------
-module(game_center_http_receiver).
-author("cw").

%% API
-export([
	init/3,
	handle/2,
	terminate/3]).
-include("logger.hrl").

init(_Transport, Req, []) ->
	?DEBUG("cowboy server init ...~n",[]),
	{ok, Req, undefined}.

handle(Req, State) ->
	?INFO("************ ~p~n",[logtest]),
	{ok, Req2} = cowboy_req:reply(200, [], <<"Hello World reloader !">>, Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.








