-- 文件名　：chefu2.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-13 11:37:53
-- 功能描述：结婚相关npc（提供对话选项的教育npc）

local tbNpc = Npc:GetClass("chefu3");

function tbNpc:OnDialog()
	local szMsg = "万里之遥，瞬间到达，来，我们走！";
	local tbOpt = {
		{"返回江津村", self.Transfer, self},		
		{"以后再来看吧"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:Transfer()
	Marry.tbMissionList[me.nMapId]:KickPlayer(me, 1);
	me.SetLogoutRV(0);
end