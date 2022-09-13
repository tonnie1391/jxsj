--
-- FileName: limittime_gc.lua
-- Author: zhongjunqi
-- Time: 2012/7/10 09:34
-- Comment: 防沉迷系统
--

Player.tbLimitTime  = Player.tbLimitTime or {};
local tbLimitTime = Player.tbLimitTime;

-- 记录玩家注册事件，下线的时候要踢出的
tbLimitTime.nLimitTime = 10800;			-- 允许游戏的时间

