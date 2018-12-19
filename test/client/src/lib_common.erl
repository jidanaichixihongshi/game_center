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
%%% Created : 30. 十一月 2018 下午 17:26
%%%-------------------------------------------------------------------
-module(lib_common).
-author("cw").

-compile(export_all).


%% 元组列表转换成maps
to_maps(L) when is_list(L) ->
	lists:foldl(
		fun({K, V}, Acc) -> Acc#{K => V} end, #{}, L);
to_maps(_) ->
	#{}.


%% 哈希值计算
get_hash(Term, Range) ->
	erlang:phash(Term, Range).

%% 获取时间戳（13位）
-spec get_mstimestamp() -> integer().
get_mstimestamp() ->
	{MegaSecs, Secs, MicroSecs} = os:timestamp(),
	MegaSecs * 1000000 * 1000 + Secs * 1000 + MicroSecs div 1000.





















