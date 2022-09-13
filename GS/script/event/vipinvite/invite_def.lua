--
-- FileName: invite_def.lua
-- Author: hanruofei
-- Time: 2011/5/4 9:13
-- Comment: 
--

SpecialEvent.tbVipInvite = SpecialEvent.tbVipInvite or {};
local tbVipInvite = SpecialEvent.tbVipInvite;

tbVipInvite.bOpened = false;		-- 功能是否已经开启
tbVipInvite.tbData = tbVipInvite.tbData or {false};
--tbVipInvite.szTimeFrame = "OpenLevel150";  -- 服务器开放150级上限后即开启该功能
tbVipInvite.nIndexOfLevelUpItem = 439;
tbVipInvite.nWealthOrder = 60;-- 财富排名前60名的玩家有资格, 前60名的玩家会受到系统通知邮件介绍关于此功能（仅限开放150级时刻的那60名有资格的玩家，仅在此时通知一次）
tbVipInvite.nDaysFromServerStart = 150; -- 开服300天才开放这个功能