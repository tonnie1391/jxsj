--
-- FileName: qingmingboss.lua
-- Author: lgy
-- Time: 2012/3/22 16:53
-- Comment: 2012清明节BOSS
--

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");

local tbQingMing2012 = SpecialEvent.tbQingMing2012;
local tbNpc= Npc:GetClass("yingling_boss_qingming2012");

-- 清明节招出来的BOSS死了，那么在原地刷一个英灵npc
function tbNpc:OnDeath()

	local nMapId, nPosX, nPosY = him.GetWorldPos();
	if not nMapId or not nPosX or not nPosY then
		return;
	end
	
	local tbBoss = tbQingMing2012.tbBossNpc;
	local pNpc = KNpc.Add2(tbBoss.nNpcId, tbBoss.nLevel, -1, nMapId, nPosX, nPosY, 0, 1)
	if not pNpc then
		return;
	end

	pNpc.SetLiveTime(tbQingMing2012.nYingLingNpcLiveTime);
	
	--将当前NPC的Temp表赋给新的NPC
	local tbTempNpc = pNpc.GetTempTable("Npc");
	local tbTempHim = him.GetTempTable("Npc");
	
	tbTempNpc.nKinId = tbTempHim.nKinId;
	pNpc.szName = him.szName;
	
	--初始化一个玩家领奖表，存在NPC上
	tbTempNpc.tbGetPlayers={};
	
	local szMsg = string.format("本家族在<pos=%d,%d,%d>击败了英灵！快去领取奖励吧", nMapId, nPosX, nPosY);
	KKin.Msg2Kin(tbTempNpc.nKinId, szMsg);
end
