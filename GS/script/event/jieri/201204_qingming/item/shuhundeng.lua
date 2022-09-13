--
-- FileName: shuhundeng.lua
-- Author: lgy&lqy
-- Time: 2012/3/22 11:30
-- Comment: 赎魂灯
--
if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");
local tbQingMing2012 = SpecialEvent.tbQingMing2012;
local tbItem = Item:GetClass("qingming_shuhundeng_2012");

function tbItem:OnUse()
	local szMsg = "  <color=yellow>冥踪杳杳不可期，引灯赎魂莫相离。<color>\n\n 你可以直接使用赎魂灯来放灯祭祀。\n(赎魂灯是用幽冥灯且消耗<color=yellow>精力、活力各300<color>所合成所得。)\n在祭祀的时候，\n<color=blue>放飞赎魂灯可以获得比幽冥灯更多的奖励。<color>";
	local tbOpt = {
		{"使用赎魂灯",self.UseThis, self,me.nId,it.dwId},
		{"Để ta suy nghĩ lại"}
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

-- 使用赎魂灯
function tbItem:UseThis(nPlayerId, nItemId)

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		pPlayer.Msg("你使用的赎魂灯不知道怎么的不见了。");
		return;
	end

	local bOk, szErrorMsg = tbQingMing2012:CanUseShuHunDeng(pPlayer);
	if bOk == 0 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg, {"Ta hiểu rồi"});
		end 
		return;
	end
	
	--完成祭祀
	tbQingMing2012:FinishJiSi(pPlayer, pItem, "ShuHunDeng");
end
