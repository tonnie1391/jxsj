-- 文件名　：npc_baiqiuling_fight.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-28 14:10:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\nianshouseige\\nianshousiege_def.lua");
SpecialEvent.NianShouSiege = SpecialEvent.NianShouSiege or {};
local tbNianShouSiege = SpecialEvent.NianShouSiege or {};

local tbNpc = Npc:GetClass("chunjieqiuyi_fight");

function tbNpc:OnDeath()
	if him.dwId == tbNianShouSiege.nNpcFightQiuYiId then
		local tbNianShou = Npc:GetClass("nianshou_2011")
		local pNpc = KNpc.GetById(tbNianShouSiege.nNianShouId);
		if pNpc then
			pNpc.GetTempTable("Npc").tbNianShou.nBeHitActive = 0;	-- 白秋林死了，不再接受攻击
			if pNpc.GetTempTable("Npc").tbNianShou.nTimerId_BiSha then
				Timer:Close(pNpc.GetTempTable("Npc").tbNianShou.nTimerId_BiSha);
				pNpc.GetTempTable("Npc").tbNianShou.nTimerId_BiSha = nil;
			end
			tbNianShou:PromptPlayer(tbNianShouSiege.nNianShouId);
			Timer:Register(4 * 18, tbNianShou.ChatWithBaiQiuLing, tbNianShou, tbNianShouSiege.nNianShouId);	
			StatLog:WriteStatLog("stat_info", "chunjie2011", "animal", 0, 1);
		end
		tbNianShouSiege.nNpcFightQiuYiId = nil;
	end
end