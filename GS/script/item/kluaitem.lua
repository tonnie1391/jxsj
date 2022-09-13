-- 对C导出的Item对象进行封装
if MODULE_GC_SERVER then
	return
end

local self;		-- 提供以下函数用的UpValue

-------------------------------------------------------------------------------
-- for both server & client


function _KLuaItem.CanUse(pPlayer)
	return KItem.CanPlayerUseItem(pPlayer, self);
end

function _KLuaItem.IsTTKEquip()
	if self.nGenre == 1 and self.nDetail <= 11 then
		return 1;
	end
	
	return 0;
end

-- 获取活动定制的字符串信息
function _KLuaItem.GetEventCustomString()
	local nType = self.nCustomType;
	if nType == KItem.CUSTOM_TYPE_EVENT then
		return self.szCustomString;
	end
	return nil;
end

-- 判断某个道具是不是同伴装备
function _KLuaItem.IsPartnerEquip()
	local bRet = 1;
	
	bRet = self.IsEquip();		-- 必须得先是装备
	if (bRet == 1) then
		if (self.nDetail >= Item.EQUIP_PARTNERWEAPON and self.nDetail <= Item.EQUIP_PARTNERAMULET) then
			bRet = 1;
		else
			bRet = 0;
		end
	end
	
	return bRet;
end

function _KLuaItem.IsZhenYuan()
	local bRet = 1;
	
	bRet = self.IsEquip();
	if (bRet == 1) then
		if self.nDetail == Item.EQUIP_ZHENYUAN then
			bRet = 1;
		else
			bRet = 0;
		end
	end
	
	return bRet;
end

function _KLuaItem.GetStoneType()
	if self.nGenre ~= Item.STONEITEM then
		return 0;
	else
		return self.nDetail;
	end
end

function _KLuaItem.IsExEquip()
	if self.nGenre == Item.EQUIP_PURPLEEX then
		return 1;
	end
	
	return 0;
end

function _KLuaItem.IsCastStuff()
	if self.nGenre ~= Item.SCRIPTITEM then
		return 0;
	end
	
	if self.nDetail ~= Item.SCRIPTITEM_CASTSTUFF then
		return 0;
	end
	
	return 1;
end
-------------------------------------------------------------------------------
-- for server

-- 从指定角色身上删除自己
function _KLuaItem.Delete(pPlayer, nWay)
	return	KItem.DelPlayerItem(pPlayer, self, (nWay or 100));
end

function _KLuaItem.GetForbidType()
	return KItem.GetOtherForbidType(self.nGenre, self.nDetail, self.nParticular, self.nLevel);
end

function _KLuaItem.Equal(g,d,p,l)
	g = g or 0;
	
	if d and p and l then
		if self.nGenre == g and self.nDetail == d and self.nParticular == p and self.nLevel == l then
			return 1;
		else
			return 0;
		end
	end
	
	if d and p then
		if self.nGenre == g and self.nDetail == d and self.nParticular == p then
			return 1;
		else
			return 0;
		end
	end
	
	if d then
		if self.nGenre == g and self.nDetail == d then
			return 1;
		else
			return 0;
		end
	end
	
	if self.nGenre == g then
		return 1;
	else
		return 0;
	end
end

function _KLuaItem.SzGDPL(szSep)
	szSep = szSep or ",";
	return string.format("%d%s%d%s%d%s%d", self.nGenre, szSep, self.nDetail, szSep, self.nParticular, szSep, self.nLevel);
end

function _KLuaItem.TbGDPL()
	return {self.nGenre, self.nDetail, self.nParticular, self.nLevel};
end

-------------------------------------------------------------------------------
-- for client

-- 获得自己的Tip信息
function _KLuaItem.GetTip(nState, szBindType)
	local pIt = it;
	it = self;
	local szTitle, szTip, szView = Item:GetTip(self.szClass, nState, szBindType);
	it = pIt;
	return	szTitle, szTip, szView;
end

-- 获得自己的对比Tip信息（装备有效,非装备道具与GetTip无异）
function _KLuaItem.GetCompareTip(nState, szBindType)
	local pIt = it;
	it = self;
	local szTitle, szTip, szView, szCmpTitle, szCmpTip, szCmpView = Item:GetCompareTip(self.szClass, nState, szBindType);
	it = pIt;
	return	szTitle, szTip, szView, szCmpTitle, szCmpTip, szCmpView;
end

-- 获得自己的性别需取
function _KLuaItem.GetSex()
	local tbReq = self.GetReqAttrib();
	for i, tbTmp in ipairs(tbReq) do
		if tbTmp then
			if tbTmp.nReq == 8 then
				return tbTmp.nValue;
			end		
		end
	end
	return nil;
end

-- 计算除去原始的装备战斗力
function _KLuaItem.CalcExtraFightPower(nEnhance, nRefine)
	if self.IsEquip() == 0 then
		return 0;
	end
	local nXiShu = Item.tbEnhanceOfEquipPos[self.nEquipPos] or 1;	
	local nEnhancePower, nRefinePower;
	if nEnhance then
		nEnhancePower = Item.tbEnhanceFightPower[nEnhance];
	else
		nEnhancePower = Item.tbEnhanceFightPower[self.nEnhTimes];
	end
	if nRefine then
		nRefinePower = Item.tbRefineFightPower[nRefine];
	else
		nRefinePower = Item.tbRefineFightPower[self.nRefineLevel];
		if self.IsExEquip() == 1 then
			local nExRefineLev = self.GetEquipExValue(Item.ITEM_TASKVAL_EX_SUBID_ExRefLevel);
			local tbRefineSetting = Item:GetExternSetting("refine",1); 
			local tbInfo = tbRefineSetting:GetExEquipRefineInfo(self.nDetail, nExRefineLev);
			nRefinePower = nRefinePower + (tbInfo and tbInfo.nAddFightPower or 0);	
		end
	end
	return nEnhancePower * nXiShu + nRefinePower;
end

-- 计算装备战斗力
function _KLuaItem.CalcFightPower(nEnhance, nRefine)
	return self.nFightPower + self.CalcExtraFightPower() + self.CalcStoneFightPower() + self.CalcExFightPower();
end


function _KLuaItem.CalcStoneFightPower()
	local nFightPower = 0;
	for i = 1, Item.nMaxHoleCount do
		local nHoleType, nValue = self.GetHoleStone(i);
		if nHoleType ~= 0 and nValue ~= 0 then
			local tbStoneGDPL = Item.tbStone:ParseStoneInfoInHole(nValue);
			nFightPower = nFightPower + Item.tbStone:GetFightPower(tbStoneGDPL);
		end
	end
	
	return nFightPower;
end

function _KLuaItem.CalcExFightPower()
	if self.IsExEquip() == 0 then
		return 0;
	end
	-- 精铸和ex炼化的战斗力提升
	local nCastLevel = self.GetEquipExValue(Item.ITEM_TASKVAL_EX_SUBID_CastLevel);
	local nEnhId = Item:GetExCastEnhId(self.nDetail, nCastLevel);
	local nFightPower = KItem.GetExCastAddFightPower(nEnhId) or 0;	
	
--	local nExRefineLev = self.GetEquipExValue(Item.ITEM_TASKVAL_EX_SUBID_ExRefLevel);
--	local tbRefineSetting = Item:GetExternSetting("refine",1); 
--	local tbInfo = tbRefineSetting:GetExEquipRefineInfo(self.nDetail, nExRefineLev);
--	nFightPower = nFightPower + (tbInfo and tbInfo.nAddFightPower or 0);	
	
	return nFightPower;
end