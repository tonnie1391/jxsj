
-- 召唤道具 
-- zhengyuhua

local tbItem = Item:GetClass("domainzhaohuan")

function tbItem:OnUse()
	if Item:IsBindItemUsable(it, me.dwTongId) ~= 1 then
		return 0;
	end
	if Domain:GetBattleState() ~= Domain.BATTLE_STATE then
		me.Msg("现在不是征战期，不能使用召唤令牌");
		return 0;
	end
	local nMapId, nX, nY = me.GetWorldPos()
	local bFight = Domain:HasBattleRight(me.dwTongId, nMapId);
	if bFight ~= 1 then
		me.Msg("你不在征战的区域内，无法使用召唤令牌");
		return 0;
	end
	local tbOpenState = Domain:GetOpenStateTable();
	if not tbOpenState then
		return 0;	
	end
	local nTemplateId = it.GetExtParam(1);
	if Domain.tbGame[me.nMapId] then
		local pNpc = Domain.tbGame[me.nMapId]:AddTongNpc(nTemplateId, tbOpenState.nNpcLevel, me.dwTongId, nX, nY, 0, 2)
		if pNpc then
			local pOwner = KUnion.GetUnion(me.dwUnionId) or KTong.GetTong(me.dwTongId);
			if pOwner then
				pNpc.SetTitle(pOwner.GetName());
			end
			return 1;
		end
	end
	return 0;
end

-- TODO
function tbItem:GetTip(nState)
	local nOwnerTongId = KLib.Number2UInt(it.GetGenInfo(Item.TASK_OWNER_TONGID, 0));
	if nState == Item.TIPS_SHOP then
		return "<color=gold>Đạo cụ này sau khi mua sẽ <color=red>khóa với Bang hội<color>, người chơi Bang hội khác không thể sử dụng!<color>";
	elseif nOwnerTongId == 0 then
		return "<color=gold>Đạo cụ không khóa với Bang hội, ai cũng có thể sử dụng<color>";
	elseif nOwnerTongId == me.dwTongId then
		return "<color=gold>Đạo cụ đã khóa với Bang hội của bạn, Bang hội khác không thể sử dụng<color>";
	else
		return "<color=red>Đạo cụ này đã khóa với Bang hội khác, bạn không thể sử dụng!<color>"
	end
end
