-module(game_center_client_app).

-include("common.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start(_StartType, _StartArgs) ->
	create_ets(),
	game_center_client_sup:start_link().

stop(_State) ->
	io:format("stop landlords server!~n", []),
	ok.


create_ets() ->
	ets:new(?CLIENT_PUBLIC_ETS, [named_table, public, set, {read_concurrency, true}, {write_concurrency, true}]).





