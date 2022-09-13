-- 文件名　：xijiuhuasa.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-21 09:27:40
-- 功能描述：婚礼道具（喜酒和撒花）
-- modify by zhangjinpin@kingsoft 2010-01-21

local tbXiJiu = Item:GetClass("marry_xijiu");

tbXiJiu.EXP_RADIO = 1;		-- 每次敬酒，经验增加
tbXiJiu.MAX_RANGE = 20;		-- 敬酒效果的影响范围20

function tbXiJiu:CanUse(pItem)
	local szErrMsg = "";
	if (0 == Marry:CheckWeddingMap(me.nMapId)) then
		szErrMsg = "你没有处在典礼场地当中，不能使用该物品。";
		return 0, szErrMsg;
	end
	
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId) or {};
	local bIsCurMapItem = 0;	-- 是否是当前地图可以使用的物品
	for _, szName in pairs(tbCoupleName) do
		if (szName == pItem.szCustomString) then
			bIsCurMapItem = 1;
			break;
		end
	end
	if (0 == bIsCurMapItem) then
		szErrMsg = "这个物品与当前举行典礼的二位侠侣不匹配，不能使用！";
		return 0, szErrMsg;
	end	
	
	return 1;
end

function tbXiJiu:OnUse()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local bCanUse, szErrMsg = self:CanUse(it);
	if (0 == bCanUse) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return;
	end
	
	me.CastSkill(1559, 1, -1, me.GetNpc().nIndex);
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, self.MAX_RANGE);
	for _, pPlayer in pairs(tbPlayerList) do
		if (pPlayer) then
			pPlayer.AddExp(pPlayer.GetBaseAwardExp() * self.EXP_RADIO);
		end
	end
	return 1;
end

--==============================================================================

local tbShouPengHua = Item:GetClass("marry_shoupenghua");

tbShouPengHua.MONEY_ADD = 100;	-- 新人每次撒花，给周围玩家增加100两银两
tbShouPengHua.MAX_RANGE = 20;	-- 撒花效果的影响范围20

function tbShouPengHua:CanUse(pItem)
	local szErrMsg = "";
	if (0 == Marry:CheckWeddingMap(me.nMapId)) then
		szErrMsg = "你没有处在典礼场地当中，不能使用该物品。";
		return 0, szErrMsg;
	end
	
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId) or {};
	local bIsCurMapItem = 0;	-- 是否是当前地图可以使用的物品
	for _, szName in pairs(tbCoupleName) do
		if (szName == pItem.szCustomString) then
			bIsCurMapItem = 1;
			break;
		end
	end
	if (0 == bIsCurMapItem) then
		szErrMsg = "这个物品与当前举行典礼的二位侠侣不匹配，不能使用！";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbShouPengHua:OnUse()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local bCanUse, szErrMsg = self:CanUse(it);
	if (0 == bCanUse) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return;
	end
	
	me.CastSkill(1559, 1, -1, me.GetNpc().nIndex);
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, self.MAX_RANGE);
	for _, pPlayer in pairs(tbPlayerList) do
		if (pPlayer) then
			pPlayer.AddBindMoney(self.MONEY_ADD, Player.emKBINDMONEY_ADD_MARRY);
		end
	end
	return 1;
end
