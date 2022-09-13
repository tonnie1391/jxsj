-------------------------------------------------------------------
--File: uniondef.lua
--Author: zhengyuhua
--Date: 2009-6-6 15:17
--Describe: 联盟定义
-------------------------------------------------------------------
if not Union then --调试需要
	Union = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

local preEnv = _G	--保存旧的环境
setfenv(1, Union)	--设置当前环境为Union

MAX_TONG_NUM = 5 -- 最大帮会数限制
MAX_TONG_DOMAIN_NUM  = 1 -- 帮会最大领土数限制

preEnv.setfenv(1, preEnv)	--恢复全局环境