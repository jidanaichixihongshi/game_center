%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 十一月 2018 下午 14:23
%%%-------------------------------------------------------------------

-define(CONFIG_FILE_DIR, "config/sys.config").                %% 配置文件


-define(HIBERNATE_TIMEOUT, 90000).                            %% 心跳
-define(AUTH_TIMEOUT, 12000).                                  %% 验证超时
-define(DATA_OVERTIME, 6000).                                  %% 过时消息

%% 用户状态
-define(STATUS_OFFLINE, 0).             %% 离线
-define(STATUS_ONLINE, 1).              %% 在线
-define(STATUS_LOGGING, 2).             %% 正在登陆
-define(STATUS_INCREMENT, 3).						%% 增量更新
-define(STATUS_REGISTERING, 4).         %% 正在注册

%% 消息流转标志位
-define(SIGN0, 0).                                      %% 节点消息
-define(SIGN1, 1).                                      %% c2s消息
-define(SIGN2, 2).                                      %% s2c消息

%% 消息类型
-define(MT_101, 101).           %% 心跳消息
-define(MT_102, 102).           %% 注册相关
-define(MT_103, 103).           %% 登录消息
-define(MT_104, 104).           %% 系统推送
-define(MT_107, 107).           %% im聊天消息

-define(MT_117, 117).           %% 群操作相关
-define(MT_118, 118).           %% 群增量

-define(MT_121, 121).           %% 查询消息


%% ETS表配置
-define(PUBLIC_STORAGE_ETS, public_storage_ets).              %% 公共临时存储ETS

-define(ETS_READ_CONCURRENCY, {read_concurrency, true}).      %% 并发读
-define(ETS_WRITE_CONCURRENCY, {write_concurrency, true}).    %% 并发写

-define(ETS_LIST, [
	{public_storage_ets, [set, public, named_table, ?ETS_READ_CONCURRENCY, ?ETS_WRITE_CONCURRENCY]}
]).


%% game_center_c2s
%% 用户数据
-record(user_data, {
	uid,                          %% 用户id（唯一性）
	nickname,                     %% 昵称
	avatar,                       %% 头像
	level,                        %% 用户等级
	version,                      %% 客户端版本
	device,                       %% 客户端类型
	device_id,                    %% 设备id
	app_id,
	token,
	location,                      %% 登录地点
	login_time,                   %% 登录时间
	phone                         %% 电话
}).

-record(client_state, {
	uid,
	node,
	status,
	proxy,
	socket,
	ip,
	port,
	sockmod,
	user_data = #user_data{},    %% 用户详细信息
	retry_times
}).









