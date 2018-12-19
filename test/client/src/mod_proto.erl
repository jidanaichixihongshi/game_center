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
%%% Created : 27. 十一月 2018 下午 18:47
%%%-------------------------------------------------------------------
-module(mod_proto).
-author("cw").

%% API
-export([
	packet/1,
	unpacket/1
]).

-include("../../../include/error.hrl").
-include("protobuf_pb.hrl").

%% ------------------------------------------------------------------------------------------
%% 消息包编解码
%% ------------------------------------------------------------------------------------------
%% 打包客户端消息
packet(Msg) when is_tuple(Msg) ->
	packet_msg(Msg);
packet(Msg) ->
	{error, Msg}.

packet_msg(Msg) ->
	EMsg = list_to_binary(encode(Msg)),
	{ok, <<0:16, EMsg/binary>>}.

%% 编码
encode(Msg) when is_tuple(Msg) ->
	protobuf_pb:encode(Msg);
encode(Msg) ->
	{error, Msg}.


%% 解包客户端消息
unpacket(Data) when is_binary(Data) ->
	<<0:16, BinMsg/binary>> = Data,
	Msg = protobuf_pb:decode(proto, BinMsg),
	Msg#proto{
		data = binary_to_term(Msg#proto.data)
	};
unpacket(_Data) ->
	{error, ?ERROR_101}.

























