
-- 装备，打孔/宝石镶嵌/剥离

------------------------------------------------------------------------------------------
-- initialize

-- 判断一个孔是否特殊孔
function Item:IsSpecialHole(dwHoleInfo)
	if (KLib.GetByte(dwHoleInfo, 2) == Item.nSpecialHole) then
		return 1;
	else
		return 0;
	end
end

function Item:GetHoleLevel(dwHoleInfo)
	return KLib.GetByte(dwHoleInfo, 1);
end

-- 申请装备打孔,服务器用
-- nMode:打孔模式（普通/高级）, nHoleId（孔ID）, nUpgrad（是否特殊孔）
function Item:MakeHole(pEquip, nMode, nHoleId, nUpgrad)
	local bRet, szMsg, nQuality, nFeeQuality = self:CanMakeHole(pEquip, nMode, nHoleId, nUpgrad);
	if (bRet == 0) then
		me.Msg(szMsg);
		return 0;
	end
	local nHoleLevel = Item.tbEquipHoleLevel[nQuality or 100] or 1;		-- 得到应该打孔的等级
	if (nUpgrad == 1) then
		if (me.ConsumeItemInBags(1, unpack(self.tbMakeHolePaper)) ~= 0) then	-- 扣除金刚钻，是否应该先扣了才打孔？
			return 0;
		end
	else
		if (nHoleId == 3) then
			local tbCon = Item.EQUIPPOS_MAKEHOLE_KIN_SKILLLEVEL[pEquip.nEquipPos];
			if (not tbCon) then
				return 0;
			end
			if (me.DecreaseKinSkillOffer(tbCon[2]) == 0 ) then		-- 扣除功勋值
				return 0;
			end
		end
		if (me.CostMoney(Item.tbMakeHoleMoney[nFeeQuality][nHoleId], Player.emKPAY_MAKEHOLE) ~= 1) then-- 扣除费用	
			return 0;
		end
	end	
	if (pEquip.MakeHole(nHoleId, nHoleLevel, nUpgrad) == 1) then
		Item:GetClass("equip"):UpdateValue();			-- 更新下财富荣誉
		PlayerHonor:UpdataEquipWealth(me, pEquip.nEquipPos);			-- 更新最大财富价值
		pEquip.Sync();			-- 同步道具
		-- 记录引导任务的任务变量
		if (nUpgrad == 1) then
			if (me.GetTask(1026, 3) == 0) then
				me.SetTask(1026, 3, 1);
			end
		else
			if (me.GetTask(1026, 1) == 0) then
				me.SetTask(1026, 1, 1);
			end
		end
		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "punching", me.nId, string.format("%d_%d_%d_%d", 
								pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel), 
								nHoleId, nUpgrad, nHoleLevel);
		
		local szMsg = "";
		if (nUpgrad == 0) then
			szMsg = "在"..pEquip.szName.."上打了一个普通孔。";
		else
			szMsg = "在"..pEquip.szName.."上打了一个特殊孔。";
		end
		Player:SendMsgToKinOrTong(me, szMsg, 0);
		me.SendMsgToFriend("Hảo hữu [<color=yellow>"..me.szName.."<color>]" .. szMsg);		

		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szMsg);		-- 客服日志							
		return 1;
	else
		-- 返还东西
		return 0;
	end
end

-- 镶嵌合法性检测，服务器客户端公用
-- nMode:打孔模式（普通/高级）, nHoleId（孔ID）, nUpgrad（是否特殊孔）
function Item:CanMakeHole(pEquip, nMode, nHoleId, nUpgrad)
	local szMsg = "";
	if (Item.tbStone:GetOpenDay() == 0) then
		return 0, "宝石系统没有开放。";
	end
	if (TimeFrame:GetState("OpenLevel89") ~= 1) then
		return 0, "没有开放89级，不能打孔。";
	end
	if (TimeFrame:GetState("OpenLevel99") ~= 1 and nHoleId > 1) then
		return 0, "没有开放99级，只能打一个孔。";
	end
	if (TimeFrame:GetState("OpenLevel150") ~= 1 and nHoleId > 2) then
		return 0, "没有开放150级，只能打两个孔。";
	end
	
	if (pEquip == nil or pEquip.IsEquip() ~= 1) then			-- 必须是装备
		szMsg = "必须是装备才能打孔";
		return 0, szMsg;
	end
	-- 装备等级和质量限制
	local tbBaseProp = KItem.GetEquipBaseProp(pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel);
	if (pEquip.nLevel < Item.nEquipHoleMinLevel or tbBaseProp.nQualityPrefix < Item.nEquipHoleMinQuality) then
		szMsg = "只能对等级在" .. Item.nEquipHoleMinLevel .. "级（含）并且质量为优秀（含）以上的装备进行打孔。";
		return 0, szMsg;
	end
	local nMaxHoleCount = Item.tbEquipHoleCount[pEquip.nLevel];
	if (nMaxHoleCount == nil or nMaxHoleCount < nHoleId) then			-- 校验装备可以打孔的数量
		szMsg = "装备的打孔数量已经到上限。";
		return 0, szMsg;
	end
	if (nHoleId == 3 and nMode ~= Item.HOLE_MODE_MAKEHOLEEX) then		-- 必须是高级打孔才可以打第三个孔
		szMsg = "必须在家族领地的夏菲烟那才能打第三个孔。";
		return 0, szMsg;
	end
	local dwHoleInfo, _ = pEquip.GetHoleStone(nHoleId);
	if (dwHoleInfo ~= 0) then											-- 装备已经打孔过了
		if (nUpgrad == 1) then											-- 升级孔
			if (pEquip.nLevel < Item.nCanMakeSupuerHoleLevel) then
				szMsg = "装备等级必须在"..Item.nCanMakeSupuerHoleLevel.."级以上才能打特殊孔。";
				return 0, szMsg;
			end
			if (nHoleId ~= 1) then		-- 必须第一个孔才能升级
				szMsg = "特殊孔为第一个孔。";
				return 0, szMsg;
			else
				-- 判断玩家身上是否有金刚钻
				if (me.GetItemCountInBags(unpack(self.tbMakeHolePaper)) <= 0) then
					szMsg = "您背包里没有金刚钻。";
					return 0, szMsg;
				end
			end
			if (self:IsSpecialHole(dwHoleInfo) == 1) then	-- 已经升级过
				szMsg = "该装备已经打过特殊孔了。"
				return 0, szMsg;
			end
		else
			szMsg = "已经打过这个孔了。";
			return 0, szMsg;
		end
	else	-- 没打孔，判断前面的孔是否已经打过
		if (nHoleId > 1) then
			local dwH = pEquip.GetHoleStone(nHoleId - 1);
			if (dwH == 0) then
				return 0, "必须先打第".. (nHoleId-1) .."个孔后才能打这个孔";
			end
		end
	end
	
	-- 第三个孔，家园宝石商人
	if (nHoleId == 3 and nMode == Item.HOLE_MODE_MAKEHOLEEX) then
		-- 判断是否有家族
		if (me.dwKinId == 0) then
			return 0, "打第三个孔需要在家族领地里面，请先加入家族。";
		end
		-- 判断身份
		local nFigure = me.nKinFigure;
		if (nFigure == 4) then
			return 0, "记名成员暂时不能给装备打孔。";
		end
		local tbCon = Item.EQUIPPOS_MAKEHOLE_KIN_SKILLLEVEL[pEquip.nEquipPos];
		if (not tbCon) then
			return 0, "装备类型不正确";
		end
		
		-- 判断家族技能等级
		local nSkillLevel = Kin:GetSkillLevel(me.dwKinId, unpack(tbCon[1]));
		if (nSkillLevel <= 0) then
			return 0, Item.EQUIPPOS_NAME[pEquip.nEquipPos] .. "的打孔技能没有开。";
		end
		-- 判断功勋值
		if (me.GetKinSkillOffer() < tbCon[2]) then
			return 0, "您的家族功勋值不够，打孔需要" .. tbCon[2] .. "点功勋值";
		end
	end
	-- 费用判断
	if (nUpgrad ~= 1 and me.nCashMoney < Item.tbMakeHoleMoney[tbBaseProp.nQualityPrefix][nHoleId]) then
		szMsg = "打孔需要花费"..Item:FormatMoney(Item.tbMakeHoleMoney[tbBaseProp.nQualityPrefix][nHoleId]).."银两，您的银两不够。";
		return 0, szMsg;
	end
	return 1, "", self:GetEquipQualityForHole(pEquip);
end

-- 镶嵌宝石,服务器用
function Item:EnchaseStone(pEquip, nHoleId, pStone)
	if (not pEquip or not pStone) then
		return 0;
	end
	if (self:CanEnchaseStone(pEquip, nHoleId, pStone) ~= 1) then
		return 0;
	end
	-- 如果有宝石，需要剥离，保存下信息
	local dwHoleInfo, dwStone = pEquip.GetHoleStone(nHoleId);
	if (dwStone ~= 0) then
		if (me.CountFreeBagCell() < 1) then
			return 0;			-- 背包空间不足
		else
			if (self:DoPeelStone(pEquip, nHoleId) ~= 1) then		-- 先剥离原来宝石
				return 0;
			end
		end		
	end
	
	local nG = pStone.nGenre;
	local nD = pStone.nDetail;
	local nP = pStone.nParticular;
	local nL = pStone.nLevel;
	
	local szStoneName = pStone.szName;
	local tbProp = pStone.GetStoneProp();
	local nSpecial = tbProp.nSpecial;	--是否是特殊宝石
	-- 删除要镶嵌的宝石宝石
	if (me.DelItem(pStone, Player.emKLOSEITEM_ENCHASESTONE) ~= 1) then
		return 0;
	end
	-- 镶嵌宝石
	if (pEquip.EnchaseStone(nG, nD, nP, nL, nHoleId) ~= 1) then
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "错误：把"..szStoneName.."镶嵌到"..pEquip.szName);
		return 0;				-- 镶嵌失败，有可能会丢失原有宝石，不太可能发生的情况
	end
	pEquip.Bind(1);			-- 镶嵌了宝石的装备，一律绑定？
	pEquip.Sync();
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "把"..szStoneName.."镶嵌到"..pEquip.szName);
	self:FinishStoneAchievement(nSpecial);	--宝石相关成就
	if (me.GetTask(1026, 2) == 0) then		--任务系统用
		me.SetTask(1026, 2, 1);
	end
	return 1;
end

-- 剥离宝石, 服务器用
function Item:DoPeelStone(pEquip, nHoleId)
	if (not pEquip) then
		return 0;
	end
	local _, dwStone = pEquip.GetHoleStone(nHoleId);
	if (dwStone ~= 0) then
		pEquip.PeelStone(nHoleId);
		local nG = Lib:LoadBits(dwStone, 0, 7);
		local nD = Lib:LoadBits(dwStone, 8, 11);
		local nP = Lib:LoadBits(dwStone, 12, 23);
		local nL = Lib:LoadBits(dwStone, 24, 31);
		-- 创建宝石给玩家，只有一个，不用判断空间了
		local pStone = me.AddItemEx(nG, nD, nP, nL, {bForceBind = 1}, Player.emKITEMLOG_TYPE_PEELSTONE);
		if (not pStone) then
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("从%s上剥取宝石失败：%s,%s,%s,%s", pEquip.szName, nG, nD, nP, nL));
			return 0;			-- 给玩家添加宝石失败，记录日志？
		end
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "从"..pEquip.szName.."上剥取"..pStone.szName);
		return 1;
	end
	return 0;
end

--- 剥离宝石, 服务器用
function Item:PeelStone(pEquip, bHoleId1, bHoleId2, bHoleId3)
	local nNeedFreeBagCell = bHoleId1 + bHoleId2 + bHoleId3;
	if (me.nFightState == 1) then		-- 战斗状态不能剥离
		me.Msg("战斗状态下不能镶嵌/剥离宝石。");
		return 0;
	end
	
	if (me.CountFreeBagCell() < nNeedFreeBagCell) then
		me.Msg("Hành trang không đủ chỗ trống.");
		return 0;			-- 背包空间不足
	end
	local nRet = 0;
	if (bHoleId1 == 1) then
		nRet = nRet + self:DoPeelStone(pEquip, 1);
	end
	if (bHoleId2 == 1) then
		nRet = nRet + self:DoPeelStone(pEquip, 2);
	end
	if (bHoleId3 == 1) then
		nRet = nRet + self:DoPeelStone(pEquip, 3);
	end
	pEquip.Sync();
	if (nRet ~= nNeedFreeBagCell) then
		return 0;
	else
		return 1;
	end
end

-- 判断一个装备是否可以进行镶嵌的可能,客户端用，用于UI和obj的判断
function Item:CheckCanEnchaseStone(pEquip, nExpectPos)
	if (Item.tbStone:GetOpenDay() == 0) then
		return 0, "Chức năng chưa mở.";
	end
	if (me.nFightState == 1) then		-- 战斗状态不能剥离
		return 0, "Trạng thái chiến đấu không thể thao tác.";
	end

	if (not pEquip or pEquip.IsEquip() ~= 1 or pEquip.nLevel < Item.nEquipHoleMinLevel) then			
		return	0, "Chỉ có thể đặt vào trang bị cấp "..Item.nEquipHoleMinLevel.." hoặc cấp "..Item.nEquipHoleMinLevel.." trở lên.";
	else
		if (nExpectPos) then
			if (nExpectPos ~= pEquip.nEquipPos) then
				return 0, "Loại trang bị không phù hợp!";
			end
		end
		local tbBaseProp = KItem.GetEquipBaseProp(pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel);
		if (tbBaseProp == nil or tbBaseProp.nQualityPrefix < Item.nEquipHoleMinQuality) then
			return 0, "Chỉ có thể đặt vào trang bị phẩm chất "..Item.nEquipHoleMinQuality.." hoặc "..Item.nEquipHoleMinQuality.." trở lên.";
		end
	end

	return 1;
end

-- 是否能在装备的某个孔上镶嵌宝石，服务器客户端公用
function Item:CanEnchaseStone(pEquip, nHoleId, pStone)
	-- 判断这个孔是否能够放入宝石
	local szMsg = "";
	if (Item.tbStone:GetOpenDay() == 0) then
		return 0, "宝石系统没有开放。";
	end

	if (me.nFightState == 1) then
		return 0, "战斗状态下不能镶嵌宝石。";
	end
	
	if (nHoleId < 1 or nHoleId > Item.nMaxHoleCount) then
		return 0, "孔ID有误。";
	end
	-- 必须是装备和宝石
	if (pEquip.IsEquip() ~= 1) then
		return 0, "必须放入装备才能镶嵌宝石。";
	end
	
	-- 必须是宝石
 	if (pStone.GetStoneType() ~= Item.STONE_PRODUCT) then
 		return 0, "只能用宝石镶嵌。";
 	end
 	
	local dwHoleInfo, dwHoleStone = pEquip.GetHoleStone(nHoleId);
	if (dwHoleInfo == 0) then				-- 没打孔
		szMsg = "请先打孔再放宝石。";
		return 0, szMsg;
	end
	-- 判断宝石类型是否与装备一致
	local tbProp = pStone.GetStoneProp();
	if (not tbProp) then
		return 0, "宝石属性错误。";
	end
	
	-- 宝石位置与装备位置是否匹配
	if (tbProp.tbMatchEquipPos[pEquip.nEquipPos + 1] ~= 1) then
		return 0, "宝石的类型与装备不匹配，无法镶嵌。";
	end
	
	-- 判断是否特殊宝石
	if (tbProp.nSpecial == 1) then
		if (self:IsSpecialHole(dwHoleInfo) ~= 1) then			-- 不是特殊孔
			return 0, "特殊宝石只能镶嵌在特殊孔上面。";
		end
	end

	-- 判断孔的等级是否够放下宝石
	if (KLib.GetByte(dwHoleInfo, 1) < pStone.nLevel) then
		if (pStone.nLevel == 4) then
			szMsg = "该宝石只能镶嵌在装备品质为卓越及以上的装备上。";
		elseif (pStone.nLevel == 5) then
			szMsg = "该宝石只能镶嵌在装备品质为史诗及以上的装备上。";
		else
			szMsg = "宝石等级太高，无法镶嵌到该装备上。";
		end
		return 0, szMsg;
	end
	
	return 1;
end

-- 如果没有精铸过的，就取装备本身品质；如果精铸过的，要取装备本身品德和精铸品质中的大者
-- 返回值有两个：孔等级品质、打孔收费品质
function Item:GetEquipQualityForHole(pEquip, nCastLevel)
	local tbBaseProp = KItem.GetEquipBaseProp(pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel);
	local nEquipQuality = tbBaseProp.nQualityPrefix;
	
	if not nCastLevel then
		nCastLevel = pEquip.GetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_CastLevel);
	end
	local nCastQuality = self.tbCastLevelToQuality[nCastLevel] or 0;
	if self.tbEquipHoleLevel[nEquipQuality] > (self.tbEquipHoleLevel[nCastQuality] or 0) then
		return nEquipQuality, nEquipQuality;
	else
		return nCastQuality, nEquipQuality;
	end
end

-- 升级某件装备所有孔的等级
function Item:RefreshEquipHoleLevel(pEquip)
	local nHoleCount = pEquip.GetHoleCount();
	if ( nHoleCount == 0) then
		return;
	end
	
	local nQuality = self:GetEquipQualityForHole(pEquip);
	local nHoleLevel = Item.tbEquipHoleLevel[nQuality or 100] or 1;
	
	for i = 1, nHoleCount do
		local dwHoleInfo = pEquip.GetHoleStone(i);
		if nHoleLevel > self:GetHoleLevel(dwHoleInfo) then
			pEquip.MakeHole(i, nHoleLevel, self:IsSpecialHole(dwHoleInfo));
		end
	end
end

------------------------------------------------------------------------------------------
