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
%%% Created : 29. 六月 2018 13:33
%%%-------------------------------------------------------------------
-module(mod_msg).
-auth("cw").

-include("common.hrl").
-include("protobuf_pb.hrl").

-export([
	request_create/4,
	mid_create/1,
	data_create/4,
	router_create/2]).


-spec request_create(integer(), integer(), #router{}, binary()) -> #proto{}.
request_create(Mt, Sig, Router, Data) when is_binary(Data) ->
	#proto{
		mt = Mt,
		sig = Sig,
		router = Router,
		data = Data,
		ts = lib_common:get_mstimestamp()
	};
request_create(Mt, Sig, Router, Data) ->
	BinData = term_to_binary(Data),
	request_create(Mt, Sig, Router, BinData).

%% "hash(Uid)_mstimestamp()"
mid_create(Uid) ->
	HashV = lib_common:get_hash(Uid, ?UID_HASH_RANGE),
	MsTimesstamp = lib_common:get_mstimestamp(),
	integer_to_list(HashV) ++ "_" ++ integer_to_list(MsTimesstamp).


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



%% -----------------------------------------------------------------------------
%% internal function
%% -----------------------------------------------------------------------------













