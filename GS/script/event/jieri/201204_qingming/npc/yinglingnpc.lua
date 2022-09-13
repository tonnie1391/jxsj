  --
-- FileName: xianglu.lua
-- Author: lgy
-- Time: 2012/3/22 17:13
-- Comment:英灵npc
--

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");

local tbQingMing2012 = SpecialEvent.tbQingMing2012;
local tbNpc= Npc:GetClass("yingling_npc_qingming2012");

function tbNpc:OnDialog()
	local szMsg = "……很好，你们在战斗的时候，也算得上进退有序，精诚团结，我很满意！这些许凡间之物便赠与尔等了。切记，孤身行与江湖，只需求得个问心无愧，但是一个人，却很难真的只是一个人而已。";
	local tbOpt = 
	{
		{"领取英灵的奖励", self.GetAward, self, me.nId, him.dwId},
		{"Ta chỉ xem qua"}
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetAward(nPlayerId, nNpcId)
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local bOk, szErrorMsg = tbQingMing2012:CanGetAwardFrom(pPlayer, pNpc);
	if bOk == 0 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	
	me.AddItem(unpack(tbQingMing2012.nYingLingKuiZengId));
	local tbTemp = pNpc.GetTempTable("Npc");
	tbTemp.tbGetPlayers[pPlayer.nId] = 1;
	Dialog:SendBlackBoardMsg(me,"你获得了英灵的馈赠");
end
