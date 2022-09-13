-- 文件名　：fuben.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-7
-- 描  述  ：

-- 副本道具脚本

local tbFuBen= Item:GetClass("fuben_enter");

function tbFuBen:OnUse()	
	local tbOpt = {};
	local szMsg = "\n副本进入令牌，带您进入队长开启的副本！";
	tbOpt = {
			{"跟随队长去探险", Npc:GetClass("dataosha_city").OnEnter, Npc:GetClass("dataosha_city"), me.nId},
			{"取消"},
		};
	Dialog:Say(szMsg, tbOpt);
	return;
end
	