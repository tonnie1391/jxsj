------------------------------------------------------
-- 文件名　：cast.lua
-- 创建者　：dengyong
-- 创建时间：2012-02-14 15:39:55
-- 描  述  ：装备精铸脚本
------------------------------------------------------

-- 精铸
function Item:Cast(tbItemList)
	-- 1装备，1图纸
	local pEquip, pStuff = self:AnaylizeCastItemList(tbItemList);
	if not pEquip or not pStuff then
		return 0;
	end	
	
	local nRes, var = self:CheckCanCast(pEquip, pStuff);
	if nRes ~= 1 then
		me.Msg(var);
		return 0;
	end
	
	local nCastLevel = var;
	local nEnhId = self:GetExCastEnhId(pEquip.nDetail, nCastLevel);
	if nEnhId == 0 then
		return;
	end
	
	--  需要扣钱么？？？？
	if me.DelItem(pStuff) ~= 1 then
		return 0;
	end
	
	local nOldEnhId = pEquip.GetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_ENHID);
	local nOldCast = pEquip.GetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_CastLevel);
	local szOldName = pEquip.szName;
		
	pEquip.SetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_ENHID, nEnhId);
	pEquip.SetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_CastLevel, nCastLevel);
	
	self:RefreshEquipHoleLevel(pEquip);		-- 可能需要提高孔的等级
	
	local nRet = pEquip.Regenerate(
		pEquip.nGenre, 
		pEquip.nDetail,
		pEquip.nParticular, 
		pEquip.nLevel,
		pEquip.nSeries,
		pEquip.nEnhTimes,
		pEquip.nLucky,
		pEquip.GetGenInfo(),
		0,
		pEquip.dwRandSeed,
		pEquip.nStrengthen);
		
	if nRet ~= 1 then
		pEquip.SetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_ENHID, nOldEnhId);
		pEquip.SetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_CastLevel, nOldCast);
		local szLog = string.format("强化属性ID被重置为%d，精铸等级被重置为%d", nOldEnhId, nOldCast);
		Dbg:WriteLog("Cast", "角色名:"..me.szName, "帐号:"..me.szAccount, "Regenerate道具失败, "..szLog);
		return 0;
	end
	
	pEquip.Bind(1);	-- 强制绑定
	me.Msg(string.format("精铸成功！你已将<color=yellow>%s<color>精铸为<color=yellow>%s<color>", szOldName, pEquip.szName));
	local szMsg = string.format("将<color=yellow>%s<color>成功精铸为<color=green>%s<color>，瞬间武艺精进！", szOldName, pEquip.szName);
	me.SendMsgToFriend("您的好友<color=green>"..me.szName.."<color>"..szMsg);
	Player:SendMsgToKinOrTong(me, szMsg, 1);
	
	-- 埋啊埋啊埋了个点
	StatLog:WriteStatLog("stat_info", "dragon_soul", "perfect_found", me.nId, pEquip.SzGDPL("_"));
	
	return 1;	
end

function Item:AnaylizeCastItemList(tbItemList)
	local pEquip, pStuff;
	
	for _, pItem in pairs(tbItemList) do
		if pItem.IsCastStuff() == 1 then
			if pStuff then
				return;
			end
			pStuff = pItem;
		elseif pItem.IsExEquip() == 1 then
			if pEquip then
				return;
			end
			pEquip = pItem;
		else
			me.Msg("只能放入卓越或以上品质的龙魂系列装备和对应部件的更高阶的精铸石方可精铸！");
			return;
		end	
	end
	
	return pEquip, pStuff;
end

-- 检查是否满足精铸的条件
function Item:CheckCanCast(pEquip, pStuff)
	-- 要可精铸的装备
	if pEquip.nGenre ~= self.EQUIP_PURPLEEX or pEquip.nEquipCategory == 0 then
		return 0, "该类型装备不能精铸！";
	end
	
	-- 检查图纸是否合法
	if pStuff.IsCastStuff() ~= 1 then
		return 0, "请放入正确的精铸石！";
	end
	
	-- 位置要匹配
	if pEquip.nDetail ~= pStuff.GetExtParam(1) then
		return 0, "精铸石与装备不匹配！";
	end
	
	-- 图纸的等级要高于当前精铸等级
	local nEquipCastLevel = pEquip.GetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_CastLevel);
	local nStuffCastLevel = pStuff.GetExtParam(2);
	if nEquipCastLevel >= nStuffCastLevel then
		return 0, "精铸石的精铸等级高于装备的精铸等级才可精铸！";
	end	
	
	return 1, nStuffCastLevel;
end

