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
%%% Created : 26. 十一月 2018 下午 14:23
%%%-------------------------------------------------------------------

-define(CONFIG_FILE_DIR, "config/sys.config").                %% 配置文件


-define(HIBERNATE_TIMEOUT, 90000).                            %% 心跳
-define(AUTH_TIMEOUT, 6000). 																	%% 验证超时

%% 用户状态
-define(STATUS_OFFLINE, 0).             %% 离线
-define(STATUS_ONLINE, 1).              %% 在线
-define(STATUS_LOGGING, 2).             %% 正在登陆
-define(STATUS_REGISTERING, 3).         %% 正在注册


%% ETS表配置
-define(PUBLIC_STORAGE_ETS, public_storage_ets).              %% 公共临时存储ETS

-define(ETS_READ_CONCURRENCY, {read_concurrency, true}).      %% 并发读
-define(ETS_WRITE_CONCURRENCY, {write_concurrency, true}).    %% 并发写

-define(ETS_LIST, [
	{public_storage_ets, [set, public, named_table, ?ETS_READ_CONCURRENCY, ?ETS_WRITE_CONCURRENCY]}
]).












