
local tbItem = Item:GetClass("gumufuxiuling");

function tbItem:OnUse()
	local nFlag, szMsg = self:IsCanUse(me);
	if (nFlag ~= 1) then
		me.Msg(szMsg);
		return 0;
	end
	
	Dialog:Say("古墓辅修令可以将您的古墓好友度提升至最高级，以达到辅修古墓派的资格，你确定现在使用吗？",
			{
				{"确定现在使用", self.OnSureUse, self, it.dwId},
				{"Để ta suy nghĩ thêm"},
			}
		);
end

function tbItem:IsCanUse(pPlayer)
	if (pPlayer.nFaction <= 0) then
		return 0, "您还没有加入门派，不能使用此道具！";
	end
	
	if (pPlayer.nLevel < 100) then
		return 0, "您还没有达到100级，不能使用此道具！";
	end
	
	if (pPlayer.CheckLevelLimit(1,4) == 1) then
		return 0, "您的古墓派好友度已经达到最高级，不能使用此道具！";
	end
	
	local nMainFaction = Faction:GetOriginalFaction(pPlayer);
	if (nMainFaction <= 0) then
		if (pPlayer.nFaction == Env.FACTION_ID_GUMU) then
			return 0, "您的主修门派是古墓派，不需要通过使用此道具来获得辅修机会！";
		end
	else
		if (nMainFaction == Env.FACTION_ID_GUMU) then
			return 0, "您的主修门派是古墓派，不需要通过使用此道具来获得辅修机会！";
		end
	end
	return 1;
end

function tbItem:OnSureUse(dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		me.Msg("道具不存在");
		return 0;
	end

	local nFlag, szMsg = self:IsCanUse(me);
	if (nFlag ~= 1) then
		me.Msg(szMsg);
		return 0;
	end
	
	local nCount = pItem.nCount - 1;
	if nCount == 0 then
		local nRetCode = me.DelItem(pItem);	-- 直接删除不用手动添加消耗记录
		if (1 ~= nRetCode) then
			Dbg:WriteLog("gumufuxiuling", "Item Delete Failed!",me.nId,me.szName);
			return 0;
		end
	else
		local pOwnner = pItem.GetOwner()
		if not pOwnner or pOwnner.nId ~= me.nId then
			return 0;
		end
		local nRetCode = pItem.SetCount(nCount, Item.emITEM_DATARECORD_REMOVE);
		if (1 ~= nRetCode) then
			Dbg:WriteLog("gumufuxiuling", "Item setCount Failed!",me.nId,me.szName);
			return 0;
		end
	end
	
	local nFlag = Player:AddRepute(me, 1, 4, 3000);
	
	if (2 == nFlag) then
		me.Msg(string.format("您获得<color=yellow>%s点<color>古墓友好度。", 3000));
	elseif (1 == nFlag) then
		me.Msg("您已经达到古墓友好度最高等级！");
	end
	Dbg:WriteLog("gumufuxiuling", "OnSureUse ", me.szName);
end
