%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 六月 2018 11:36
%%%-------------------------------------------------------------------

-compile([{parse_transform, lager_transform}]).

-define(DEBUG(Format, Args), lager:debug(Format, Args)).
-define(INFO(Format, Args), lager:info(Format, Args)).
-define(WARNING(Format, Args), lager:warning(Format, Args)).
-define(ERROR(Format, Args), lager:error(Format, Args)).
-define(CRITICAL(Format, Args), lager:critical(Format, Args)).


-define(PRINTF(Format, Args), io_lib:format(Format, Args)).
-define(PRINTF(Args), io_lib:format(Args)).






