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
%%% Created : 27. 十一月 2018 下午 20:41
%%%-------------------------------------------------------------------
-module(mod_msg).
-author("cw").

-include("common.hrl").
-include("protobuf_pb.hrl").

%% API
-export([
	transform_router/1,
	reply_create/4,
	mid_create/1,
	data_create/4,
	router_create/6,
	router_create/2,
	check_timestamp/1
]).

-define(TimestampOverTime, 6000).                                  %% 超时消息

transform_router(#router{from = From, fdevice = FD, fserver = FS, to = To, tdevice = TD, tserver = TS}) ->
	#router{from = To, fdevice = TD, fserver = TS, to = From, tdevice = FD, tserver = FS}.

-spec reply_create(integer(), integer(), #router{}, binary()) -> #proto{}.
reply_create(Mt, Sig, Router, Data) when is_binary(Data) ->
	#proto{
		mt = Mt,
		sig = Sig,
		router = Router,
		data = Data,
		ts = lib_time:get_mstimestamp()
	};
reply_create(Mt, Sig, Router, Data) ->
	BinData = term_to_binary(Data),
	reply_create(Mt, Sig, Router, BinData).

%% "hash(Uid)_mstimestamp()"
mid_create(Uid) ->
	HashV = lib_random:get_hash(Uid, ?UID_HASH_RANGE),
	MsTimesstamp = lib_time:get_mstimestamp(),
	lib_change:to_list(HashV) ++ "_" ++ lib_change:to_list(MsTimesstamp).

data_create(Dt, Mid, Child, Extend) when is_binary(Child), is_binary(Extend) ->
	#data{
		dt = Dt,
		mid = Mid,
		children = Child,
		extend = Extend
	};
data_create(Dt, Mid, Child, Extend) when is_binary(Child) ->
	BinExtend = term_to_binary(Extend),
	data_create(Dt, Mid, Child, BinExtend);
data_create(Dt, Mid, Child, Extend) ->
	BinChild = term_to_binary(Child),
	data_create(Dt, Mid, BinChild, Extend).

-spec router_create(binary(), binary(), binary(), binary(), binary(), binary()) -> #router{}.
router_create(From, FDevice, FServer, To, TDevice, TServer) ->
	#router{
		from = From,
		fdevice = FDevice,
		fserver = FServer,
		to = To,
		tdevice = TDevice,
		tserver = TServer}.
router_create(From, To) when is_binary(From), is_binary(To) ->
	router_create(From, <<"">>, <<"">>, To, <<"">>, <<"">>);
router_create(From, To) when is_binary(From) ->
	BinTo = term_to_binary(To),
	router_create(From, BinTo);
router_create(From, To) ->
	BinFrom = term_to_binary(From),
	router_create(BinFrom, To).


check_timestamp(Timestamp) ->
	MsTimestamp = lib_time:get_mstimestamp(),
	Timestamp + ?TimestampOverTime > MsTimestamp.











