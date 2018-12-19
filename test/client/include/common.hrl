%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 六月 2018 17:11
%%%-------------------------------------------------------------------
-include("protobuf_pb.hrl").
-define(PROTO_CONFIG, "../../config/protobuf.proto").

-define(CLIENT_PUBLIC_ETS, game_center_client).

-define(TCP_OPTIONS, [
	binary,
	{packet, 4},
	{keepalive, false},
	{active, once}]).

-define(HEART_BREAK_TIME, 60000).  %% 心跳

%% 客户端连接状态
-record(state, {
	uid,
	nickname,
	passwd,
	token,
	phone,
	version,
	device,
	appid,
	ip,
	port,
	socket,
	status      %% 连接状态
}).

-define(CONNECT, connect).
-define(AUTH, auth).
-define(INCREMENT, increment).
-define(ONLINE, online).


-define(UID_HASH_RANGE, 10000000).





















