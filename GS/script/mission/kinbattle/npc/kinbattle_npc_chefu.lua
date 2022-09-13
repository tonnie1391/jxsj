-------------------------------------------------------
-- 文件名　：kinbattle_npc_chefu.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-07 16:48:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

local tbNpc = Npc:GetClass("kinbattle_npc_chefu");

function tbNpc:OnDialog()
	local szMsg = "战斗场地很大，我可以送你们去以下几个地点，<color=green>建议本家族成员自行商议好集结地点<color>。";
	local tbOpt = 
	{
		{"区域一", self.TransferToBattle, self, 1},
		{"区域二", self.TransferToBattle, self, 2},
		{"区域三", self.TransferToBattle, self, 3},
		{"区域四", self.TransferToBattle, self, 4},
		{"离开战场", self.OnLeaveSay, self,},
		{"Kết thúc đối thoại",}	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:TransferToBattle(nIndex)
	if GetMapType(me.nMapId) ~= "kinbattlezhunbei" then
		return 0;
	end
	nIndex = nIndex or 1;
	local tbPlayerInfo = KinBattle:GetPlayerInfo(me);
	if not tbPlayerInfo then
		me.NewWorld(unpack(KinBattle.DEFAULT_POS));
	end
	local tbMission = tbPlayerInfo.tbMission;
	if not tbMission then
		me.NewWorld(unpack(KinBattle.DEFAULT_POS));
		return 0;
	end
	if tbMission:GetGameState() == 1 then
		Dialog:Say("还在准备中，请稍后。");
		return 0;
	end
	local nRemainTime = tbPlayerInfo:GetTranRemainTime();
	if nRemainTime > 0 then
		local szMsg = string.format("还是先休整一下吧，请耐心等待%s秒", nRemainTime);
		Dialog:Say(szMsg);
		return;
	end
	local tbCamp = tbPlayerInfo.tbCamp;
	tbCamp:TransToBattle(me, nIndex);
end

function tbNpc:OnLeaveSay()
	if GetMapType(me.nMapId) ~= "kinbattlezhunbei" then
		return 0;
	end
	local tbOpt = 
	{
		{"Xác nhận", self.LeaveBattle, self},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say("家族战中离开战场后可通过与各大城市的公平子对话再次进入。你确定要离开战场吗？ ", tbOpt);
end

function tbNpc:LeaveBattle()
	if GetMapType(me.nMapId) ~= "kinbattlezhunbei" then
		return 0;
	end
	local tbPlayerInfo = KinBattle:GetPlayerInfo(me);
	local tbMission = tbPlayerInfo.tbMission;
	tbMission:KickPlayer(me);
end