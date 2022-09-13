-------------------------------------------------------------------
--Describe:	增加奖励基金道具

local tbJiangLi = Item:GetClass("jiangli");
tbJiangLi.ADD_GREAT_BOUNS = 1000000;
function tbJiangLi:OnUse()
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		me.Msg("您没有帮会，不能使用该道具！");
		return 0;
	end
	if Tong:AddGreatBonus_GS(me.dwTongId, tbJiangLi.ADD_GREAT_BOUNS) == 0 then
		me.Msg("您的帮会的奖励基金已经到达上限了");
		return 0;
	end
	me.Msg("您向帮会的奖励基金充了<color=yellow>"..(tbJiangLi.ADD_GREAT_BOUNS/10000).."万<color>");
	KTong.Msg2Tong(me.dwTongId, me.szName.."增加了帮会奖励基金<color=green>"..(tbJiangLi.ADD_GREAT_BOUNS/10000).."万<color>");
	return 1;
end
