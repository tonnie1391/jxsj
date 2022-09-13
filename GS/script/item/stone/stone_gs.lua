------------------------------------------------------
-- 文件名　：stone_gs.lua
-- 创建者　：dengyong
-- 创建时间：2011-05-30 11:39:20
-- 描  述  ：宝石服务端脚本
------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\item\\stone\\define.lua");

Item.tbStone = Item.tbStone or {};
local tbStone = Item.tbStone;

--------------------------------------------宝石业务：升级、兑换、拆解-----------------------------------------------

function tbStone:UpgradePrepared()
	me.CallClientScript({"Item.tbStone:ServerUpgradePrepared"})
end

function tbStone:SyncOperationResult(nOperationType, nResult)
	me.CallClientScript({"Item.tbStone:SyncOperationResult", nOperationType, nResult});
end

-- 升级, TODO:背包空间判断
function tbStone:Upgrade(dwGemId, dwId, nHolePos)
	if (Item.tbStone:GetOpenDay() == 0) then
		me.Msg("Hệ thống bảo thạch chưa mở.");
		return 2;
	end
	if (me.nFightState == 1) then
		me.Msg("Không thể tiến hành trong trạng thái chiến đấu.");
		return 2;
	end
	
	local pGemStone = KItem.GetObjById(dwGemId);	-- 用来升级的原石
	local pOperate = KItem.GetObjById(dwId);		-- 要升级的宝石或者装备
	
	if not pOperate or not pGemStone then
		return 2;
	end
	
	if pGemStone.GetStoneType() ~= Item.STONE_GEM then
		me.Msg("Không thể sử dụng Nguyên thạch để nâng cấp.");
		return 2;
	end

	local szInfo = string.format("%d_%d_%d_%d", pGemStone.nGenre, pGemStone.nDetail, pGemStone.nParticular, pGemStone.nLevel);

	if pOperate.IsEquip() == 1 then
		if (not nHolePos or nHolePos <= 0 or nHolePos > Item.nMaxHoleCount) then	
			me.Msg("Hãy chọn Bảo thạch để nâng cấp");	
			return 2;
		end
		
		local nRet = self:IsFillInStone(pOperate, nHolePos);
		if nRet == -1 then
			me.Msg("Trang bị chưa đục lỗ không thể nâng cấp");
			return 2;
		elseif nRet == 0 then
			me.Msg("Không có bảo thạch nào trong lỗ, không thể nâng cấp!")
			return 2;
		end
		
		local nHoleType, nStone = pOperate.GetHoleStone(nHolePos);
		local nHoleLevel, nSpecial = self:ParseHoleType(nHoleType);
		local tbGDPL = self:ParseStoneInfoInHole(nStone);
		local bRet, szErrorMsg = self:CanUpgrade(tbGDPL, pGemStone);
		if  bRet ~= 1 then
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szErrorMsg});
			me.Msg(szErrorMsg);
			return 2;
		end
		
		if tbGDPL[4] >= nHoleLevel then
			me.Msg("Cấp độ Bảo thạch không thể cao hơn cấp độ của lỗ bảo thạch");
			return 2;
		end		
		
		if (tbGDPL[4] >= self.STONE_LEVEL_MAX) then
			me.Msg("Bảo thạch đã đạt cấp tối đa!");
			return 2;
		end
		
		local tbGemGDPL = pGemStone.TbGDPL();
		local tbOperateGDPL = pOperate.TbGDPL();
		if pGemStone.Delete(me, 150) ~= 1 then
			Dbg:WriteLog("Stone", "Upgrade", me.szAccount, me.szName, 
				string.format("删除原石(%d_%d_%d_%d)失败！", unpack(tbGemGDPL)));
			return 0;
		end

		if (pOperate.EnchaseStone(tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4] + 1, nHolePos) ~= 1) then
			Dbg:WriteLog("Stone", "Upgrade", me.szAccount, me.szName, 
			string.format("删除原石(%d_%d_%d_%d)成功，装备%s(%d_%d_%d_%d)第%d个孔内宝石升级失败！", tbGemGDPL[1], tbGemGDPL[2], tbGemGDPL[3],
				tbGemGDPL[4], pOperate.szName, tbOperateGDPL[1], tbOperateGDPL[2], tbOperateGDPL[3], tbOperateGDPL[4], nHolePos));
			return 0;
		end				
		
		-- 数据埋点
		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "upgrade", me.nId, szInfo);
		
		return 1;
		
	elseif pOperate.GetStoneType() == Item.STONE_PRODUCT then
		local tbGDPL = {pOperate.nGenre, pOperate.nDetail, pOperate.nParticular, pOperate.nLevel};
		local bRet, szErrorMsg = self:CanUpgrade(tbGDPL, pGemStone);
		if  bRet ~= 1 then
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szErrorMsg});
			me.Msg(szErrorMsg);
			return 2;
		end
				
		if pOperate.nLevel >= self.STONE_LEVEL_MAX then
			me.Msg("Bảo thạch đạt cấp tối đa!");
			return 2;
		end
		
		local bForceBind = pGemStone.IsBind() + pOperate.IsBind();
		local tbGemGDPL = pGemStone.TbGDPL();
		local tbOperateGDPL = pOperate.TbGDPL();
		if pGemStone.Delete(me, 150) ~= 1 then
			Dbg:WriteLog("Stone", "Upgrade", me.szAccount, me.szName, 
				string.format("删除原石(%d_%d_%d_%d)失败！", unpack(tbGemGDPL)));
			return 0;
		end
		
		if pOperate.Delete(me, 150) ~= 1 then
			Dbg:WriteLog("Stone", "Upgrade", me.szAccount, me.szName, 
			string.format("删除原石(%d_%d_%d_%d)成功，删除宝石(%d_%d_%d_%d)失败！", tbGemGDPL[1], tbGemGDPL[2], tbGemGDPL[3],
				tbGemGDPL[4], unpack(tbOperateGDPL)));
			return 0;
		end
		
		local pItem = me.AddItemEx(tbOperateGDPL[1], tbOperateGDPL[2], tbOperateGDPL[3], tbGemGDPL[4], {bForceBind = bForceBind});
		if not pItem then
			Dbg:WriteLog("Stone", "Upgrade", me.szAccount, me.szName, 
				string.format("删除原石(%d_%d_%d_%d)成功，删除宝石(%d_%d_%d_%d)成功，添加新宝石失败！", 
					tbGemGDPL[1], tbGemGDPL[2], tbGemGDPL[3], tbGemGDPL[4], unpack(tbOperateGDPL)));
			return 0;			
		end

		-- 数据埋点
		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "upgrade", me.nId, szInfo);
		return 1;
	end
	
	return 0;
end

-- 兑换，只能原石兑换原石
function tbStone:Exchange(nSelColor, nSelInfo, dwStoneId1, dwStoneId2, dwStoneId3)
	local pStone1 = KItem.GetObjById(dwStoneId1);
	local pStone2 = KItem.GetObjById(dwStoneId2);
	local pStone3 = KItem.GetObjById(dwStoneId3);
	
	if not pStone1 or not pStone2 or not pStone3 then
		return 0;
	end

	-- 判断两次就够了
	if self:IsExchangeFeatureMatch(pStone1, pStone2) ~= 1 or 
		self:IsExchangeFeatureMatch(pStone2, pStone3) ~= 1 then
			
		me.Msg("Hãy đạt bảo thạch cùng loại!");
		return 0;
	end

	
	if not self.tbStoneColor[nSelColor] then
		return 0;
	end
	
	local szSelColor = self.tbStoneColor[nSelColor][1];
	
	-- 获取兑换列表
	local tbList = self:GetExchangeList(pStone1);
	if not tbList or Lib:CountTB(tbList) == 0 or not tbList[szSelColor] then
		me.Msg("不可兑换！");
		return 0;
	end
	
	-- 过滤
	local tbSelList = tbList[szSelColor];
	tbSelList = self:FilterExchangeList(tbSelList, pStone1);
	tbSelList = self:FilterExchangeList(tbSelList, pStone2);
	tbSelList = self:FilterExchangeList(tbSelList, pStone3);	

	-- 格式化成了孔内宝石信息的格式，要用这个接口来解析
	local tbSelGDPL = self:ParseStoneInfoInHole(nSelInfo);
	local szSelGDPL = string.format("%d,%d,%d,%d", unpack(tbSelGDPL));
	local bLegal = 0;
	-- 这个GDPL一定要在tbList里才可以
	for _, _tbGDPL in pairs(tbSelList) do
		local _szGDPL = string.format("%d,%d,%d,%d", unpack(_tbGDPL));
		if szSelGDPL == _szGDPL then
			bLegal = 1;
			break;
		end		
	end
	
	if bLegal == 0 then
		me.Msg("不可兑换！");
		return 0;
	end	
	

	-- 指定的宝石GDPL，先记录下来，写LOG用
	local tbOrgGem1 = pStone1.TbGDPL();
	local tbOrgGem2 = pStone2.TbGDPL();
	local tbOrgGem3 = pStone3.TbGDPL();
	
	local szInfo = string.format("%d_%d_%d_%d,%d_%d_%d_%d,%d_%d_%d_%d,", pStone1.nGenre, pStone1.nDetail, pStone1.nParticular, pStone1.nLevel,
								pStone2.nGenre, pStone2.nDetail, pStone2.nParticular, pStone2.nLevel, 
								pStone3.nGenre, pStone3.nDetail, pStone3.nParticular, pStone3.nLevel);
	
	-- 删除原来的原石
	if me.DelItem(pStone1) ~= 1 then
		Dbg:WriteLog("Stone", "Exchange", me.szAccount, me.szName, 
			string.format("删除原石1(%d_%d_%d_%d)失败！", 
				tbOrgGem1[1], tbOrgGem1[2], tbOrgGem1[3], tbOrgGem1[4]));
		return 0;
	end
	
	if me.DelItem(pStone2) ~= 1 then
		Dbg:WriteLog("Stone", "Exchange", me.szAccount, me.szName, 
			string.format("删除原石1(%d_%d_%d_%d)成功，删除原石2(%d_%d_%d_%d)失败！", 
				tbOrgGem1[1], tbOrgGem1[2], tbOrgGem1[3], tbOrgGem1[4],
				tbOrgGem2[1], tbOrgGem2[2], tbOrgGem2[3], tbOrgGem2[4]));
		return 0;
	end
	
	if me.DelItem(pStone3) ~= 1 then
		Dbg:WriteLog("Stone", "Exchange", me.szAccount, me.szName, 
			string.format("删除原石1(%d_%d_%d_%d)成功，删除原石2(%d_%d_%d_%d)成功, 删除原石3(%d_%d_%d_%d)失败！", 
				tbOrgGem1[1], tbOrgGem1[2], tbOrgGem1[3], tbOrgGem1[4],
				tbOrgGem2[1], tbOrgGem2[2], tbOrgGem2[3], tbOrgGem2[4],
				tbOrgGem3[1], tbOrgGem3[2], tbOrgGem3[3], tbOrgGem3[4]));
		return 0;
	end
	
	-- 添加新原石
	local pItem = me.AddItem(unpack(tbSelGDPL));
	if not pItem then
		Dbg:WriteLog("Stone", "Exchange", me.szAccount, me.szName, 
			string.format("删除原石1(%d_%d_%d_%d)，原石2(%d_%d_%d_%d)，原石3(%d_%d_%d_%d)成功，添加新宝石(%d_%d_%d_%d)失败！", 
				tbOrgGem1[1], tbOrgGem1[2], tbOrgGem1[3], tbOrgGem1[4],
				tbOrgGem2[1], tbOrgGem2[2], tbOrgGem2[3], tbOrgGem2[4],
				tbOrgGem3[1], tbOrgGem3[2], tbOrgGem3[3], tbOrgGem3[4],
				tbSelGDPL[1], tbSelGDPL[2], tbSelGDPL[3], tbSelGDPL[4]));
		return 0;
	end

	szInfo = szInfo .. string.format("%d_%d_%d_%d", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	
	-- 数据埋点
	StatLog:WriteStatLog("stat_info", "baoshixiangqian", "exchange", me.nId, szInfo);
	
	return 1;
end

-- 拆解
function tbStone:BreakUp(dwId)
	if self:CanBreakUp(dwId, me) ~= 1 then
		return 0;
	end
	
	-- self:CanBreakUp已经检查过了，这里不用再检查了
	local pStone = KItem.GetObjById(dwId);
	local tbRes = self:GetBreakUpList(pStone);		-- 同上，也不用再判断了
		
	local szInfo = string.format("%d_%d_%d_%d", pStone.nGenre, pStone.nDetail, pStone.nParticular, pStone.nLevel);
	local tbGemGDPL = pStone.TbGDPL();
	if me.DelItem(pStone, 150) ~= 1 then
		Dbg:WriteLog("Stone", "BreakUp", me.szAccount, me.szName, 
				string.format("删除原石(%d_%d_%d_%d)失败！", unpack(tbGemGDPL)));
			return 0;
	end
	local nMoney = me.GetBindMoney();
	if (nMoney < self.BREAKUP_COST_MONEY) then
		if (me.CostBindMoney(nMoney, Player.emKPAY_BREAKUPSTONE) ~= 1) then
			Dbg:WriteLog("Stone", "BreakUp", me.szAccount, me.szName, 
				string.format("扣除%s绑银失败", nMoney));
			return 0;
		end
		if (me.CostMoney(self.BREAKUP_COST_MONEY - nMoney, Player.emKPAY_BREAKUPSTONE) ~= 1) then-- 扣除费用	
			Dbg:WriteLog("Stone", "BreakUp", me.szAccount, me.szName, 
				string.format("扣除%s银两失败", self.BREAKUP_COST_MONEY-nMoney));
			return 0;
		end
	else
		if (me.CostBindMoney(self.BREAKUP_COST_MONEY, Player.emKPAY_BREAKUPSTONE) ~= 1) then
			Dbg:WriteLog("Stone", "BreakUp", me.szAccount, me.szName, 
				string.format("扣除%s绑银失败", self.BREAKUP_COST_MONEY));
			return 0;
		end
	end
	
	me.AddStackItem(tbRes.tbGDPL[1], tbRes.tbGDPL[2], tbRes.tbGDPL[3], tbRes.tbGDPL[4], nil, tbRes.nCount);
	
	-- 数据埋点
	StatLog:WriteStatLog("stat_info", "baoshixiangqian", "breakup", me.nId, szInfo);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "拆解宝石："..szInfo);

	-- 清除申请状态
	if tbGemGDPL[4] >= self.STONE_BREAKUP_LEVEL_APPLY then
		me.SetTask(self.TASK_GID_BREAKUP, self.TASK_SUBID_BREAKUP, 0);
		me.RemoveSkillState(self.BREAKUP_STONE_SKILLID);			
	end	
	
	return 1;
end

function tbStone:NotifyOperationResult(nMode, nRes)
	me.CallClientScript({"Item.tbStone:NotifyOperationResult", nMode, nRes});
end

-- 申请解绑
function tbStone:ApplyUnBindStone(nPlayerId)
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	if pPlayer.IsAccountLock() == 1 then
		pPlayer.Msg("Tài khoản khóa không thể thao tác");
		Partner:SendClientMsg("Tài khoản khóa không thể thao tác");
		Account:OpenLockWindow(pPlayer);
		return 0;
	end
	if Account:Account2CheckIsUse(pPlayer, 6) == 0 then
		pPlayer.Msg("Sử dụng mật mã phụ không thể thao tác!");
		return 0;
	end
	pPlayer.SetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND, GetTime());
	pPlayer.AddSkillState(self.UNBIND_STONE_SKILLID, 1, 1, self.UNBIND_MAX_TIME * Env.GAME_FPS, 1, 0, 1);
	
	Dbg:WriteLog("UnBindStone", "角色名："..pPlayer.szName, "账号名："..pPlayer.szAccount, "申请解绑宝石");
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "申请宝石解绑");
	pPlayer.Msg("您成功提交了宝石解绑申请！");
end

-- 取消解绑
function tbStone:CancelUnBindStone(nPlayerId)
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	pPlayer.SetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND, 0);
	pPlayer.RemoveSkillState(self.UNBIND_STONE_SKILLID);
	
	Dbg:WriteLog("UnBindStone", "角色名："..pPlayer.szName, "账号名："..pPlayer.szAccount, "取消解绑宝石申请");
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "撤销宝石解绑申请");
	pPlayer.Msg("Hủy mở khóa thành công!");
end

-- 解绑申请状态
function tbStone:GetUnBindState(pPlayer)
	local nValue = pPlayer.GetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND);
	if nValue == 0 or nValue > GetTime() or nValue + self.UNBIND_MAX_TIME < GetTime() then
		return 0;	-- 没有申请，申请过期
	elseif nValue <= GetTime() and nValue + self.UNBIND_MIN_TIME >= GetTime() then
		return 1;	-- 有申请，尚未到可操作状态
	else
		return 2;	-- 有申请，可操作状态
	end	
end

-- 申请解绑
function tbStone:UnBindStone(nPlayerId)
	Item:SwitchBindGift_Trigger(nPlayerId, Item.SWITCHBIND_UNBIND, Item.SWITCHBIND_STONE);
end

-- 解绑后处理
function tbStone:PostUnBind(nCount)
	-- 解绑成功后，将任务变量重置
	me.SetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND, 0);
	me.RemoveSkillState(self.UNBIND_STONE_SKILLID);
	
	Dbg:WriteLog("UnBindPartEq", "角色名："..me.szName, "账号名："..me.szAccount, "成功解绑了"..nCount.."个宝石");
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("解绑%s个宝石。", nCount));
	me.Msg(string.format("您成功解绑了%s个宝石。", nCount));	
end

-- 申请拆解
function tbStone:ApplyBreakUpStone(nPlayerId)
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if pPlayer.IsAccountLock() == 1 then
		pPlayer.Msg("Tài khoản khóa không thể thao tác");
		Partner:SendClientMsg("Tài khoản khóa không thể thao tác");
		Account:OpenLockWindow(pPlayer);
		return 0;
	end
	
	if Account:Account2CheckIsUse(pPlayer, 6) == 0 then
		pPlayer.Msg("Sử dụng mật mã phụ không thể thao tác!");
		return 0;
	end
	
	pPlayer.SetTask(self.TASK_GID_BREAKUP, self.TASK_SUBID_BREAKUP, GetTime());
	pPlayer.AddSkillState(self.BREAKUP_STONE_SKILLID, 1, 1, self.BREAKUP_MAX_TIME * Env.GAME_FPS, 1, 0, 1);
	
	Dbg:WriteLog("BreakUpStone", "角色名："..pPlayer.szName, "账号名："..pPlayer.szAccount, "申请高级原石拆解");
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "申请高级原石拆解");
	pPlayer.Msg("Yêu cầu tách bảo thạch thành công!");
end

-- 取消拆解申请
function tbStone:CancelBreakUpStone(nPlayerId)
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	pPlayer.SetTask(self.TASK_GID_BREAKUP, self.TASK_SUBID_BREAKUP, 0);
	pPlayer.RemoveSkillState(self.BREAKUP_STONE_SKILLID);
	
	Dbg:WriteLog("UnBindStone", "角色名："..pPlayer.szName, "账号名："..pPlayer.szAccount, "取消高级原石拆解申请");
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "撤销高级原石拆解申请");
	pPlayer.Msg("Hủy yêu cầu tách bảo thạch thành công!");
end

-- 设置宝石功能开放时间
-- 注意，这里面存的是天数
function tbStone:SetOpenDay(nDay)
	local nOld = self:GetOpenDay();
	if nOld ~= nDay then
		KGblTask.SCSetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY, nDay);
		-- TODO：dengyong，这里会造成多次同步的问题！
		--GCExecute({"KGblTask.SCSetDbTaskInt", DBTASK_STONE_FUNCTION_OPENDAY, nDay});
		
		-- 根据宝石系统的开关情况，动态改变商会任务的奖励
		Merchant:InitFile();
	end
end

--------------------------------------------宝石随机相关-------------------------------------------------

-- 根据参数，随机生成石头或原石
-- 参数nMode：1表示低等级产出；2表示高等级产出
-- 参数nStoneType:1表示宝石，2表示原石
function tbStone:RandomStone(nMode, nStoneType, bForceSkillStone, nForceStoneLevel)
	-- 先随机是否是技能+1宝石
	local bSkillStone = bForceSkillStone or 0;   -- bForceSkillStone，是否强制技能石头
	if bForceSkillStone ~= 1 then
		bSkillStone = self:_RandomBeSkillStone(nMode);
	end
	
	local nLevel = nForceStoneLevel or 0;		-- nForceStoneLevel，是否指定石头等级
	if nLevel <= 0 then
		nLevel = self:_RandomStoneLevel(nMode, bSkillStone);
	end
	
	-- 避免出错，再强制处理一次，技能石头只能是1级
	nLevel = bSkillStone == 1 and 1 or nLevel;	-- 技能石头，只能是5级	
	-- 技能石头只能是成品石头
	nStoneType = bSkillStone == 1 and Item.STONE_PRODUCT or nStoneType;
		
	if not nLevel then
		return;
	end
	
	local tbGDP = self:_RandomStonePropId(bSkillStone, nStoneType);
	if not tbGDP then
		return;
	end

	table.insert(tbGDP, #tbGDP + 1, nLevel);
	return tbGDP;	-- tbGDPL	
end

-- 另外一种随机规则
-- 初级产出做特殊设定：如果等级是1级产出宝石，否则是原石
-- 高级产出跟第一种随机规则相同
function tbStone:RandomStone2(nMode, nStoneType)
	if nMode == self.STONE_PRODUCE_LEVEL_HIGH then
		return self:RandomStone(nMode, nStoneType);
	elseif nMode == self.STONE_PRODUCE_LEVEL_LOW then
		-- 初级产出要先随机石头等级，且不产出技能石头
		local nLevel = self:_RandomStoneLevel(nMode);
		if not nLevel then
			return;
		end

		local nStoneType = Item.STONE_GEM;
		if nLevel == 1 then
			nStoneType = Item.STONE_PRODUCT;
		end

		-- 不产出技能石头
		return self:RandomStone(nMode, nStoneType, 0, nLevel);
	end
end

-- 随机是否技能加1石头
function tbStone:_RandomBeSkillStone(nMode)
	-- 只有高级产出才可能出技能石头
	if nMode < self.STONE_PRODUCE_LEVEL_HIGH then
		return 0;
	end
	
	-- 1/300的概率为技能+1石头
	if MathRandom(self.RAND_RATE_SKILLSTONE) >= self.RAND_RATE_SKILLSTONE then
		return 1;
	end
	
	return 0;
end

-- 随机石头等级
function tbStone:_RandomStoneLevel(nMode, bSkillStone)
	if bSkillStone == 1 then
		return 1;	-- 技能石头只能是5级
	end
	
	local tbNowList = self:GetCurrLevelRandList();
	
	local tb = tbNowList[nMode];
	if not tb then
		return 1;	-- 传入错误的参数返回最低级？
	end

	local nSumRate = 0;
	for _, nRate in pairs(tb) do
		nSumRate = nSumRate + nRate * 100;
	end
	
	local nRand = MathRandom(nSumRate) / 100;
	for nLevel, nRate in pairs(tb) do
		nRand = nRand - nRate;
		if nRand <= 0 then
			return nLevel;
		end
	end
	
	-- 出错了？？返回最低级吧？？
	--return 1;
end

-- 随机得到G、D、P
function tbStone:_RandomStonePropId(bSkillStone, nStoneType)
	local tb = self.tbRandInfo[nStoneType];
	if not tb or not tb[bSkillStone] then
		return;
	end	
	
	tb = tb[bSkillStone];
	
	local nSumRate = 0;
	for _, tbInfo in pairs(tb) do
		nSumRate = nSumRate + tbInfo[1];
	end
	
	local nRand = MathRandom(nSumRate);
	for _, tbInfo in pairs(tb) do
		nRand = nRand - tbInfo[1];
		if nRand <= 0 then
			return {unpack(tbInfo, 2, 4)};
		end
	end
end

-- 记录一条宝石的随机信息
function tbStone:RecordRandInfo(nStyle, nId, g, d, p, nRate)
	if (nStyle == 4) then		-- 打怪经验的宝石，忽略掉
		return;
	end
	if not self.tbRandInfo then
		self.tbRandInfo = {};
	end
	
	if not self.tbRandInfo[d] then
		self.tbRandInfo[d] = {};
	end
	
	if not self.tbRandInfo[d][nStyle] then
		self.tbRandInfo[d][nStyle] = {};
	end
	
	table.insert(self.tbRandInfo[d][nStyle], {nRate, g, d, p, nId});
end

-- 获取当前宝石随机序列
function tbStone:GetCurrLevelRandList()
	-- 需要根据天数成长。成长规则是，随机序列中等级最低的权重每过一天衰减一，高级产出的其它等级权重不变，低级产出的次低
	-- 级权重加1；当最低等级的权重衰减至0时，随机序列中的等级各成长一级，各权重等于初始权重。然后重复上面步骤
	local nOpenDay = self:GetOpenDay();
	local nNowDay = Lib:GetLocalDay(GetTime());
	-- 如果时间不对，也返回默认值？？
	if nOpenDay <= 0 or nNowDay <= nOpenDay then
		return self.tbStoneLevelRandomSeed;
	end
	
	local tbNowList = {};
	
	for nMode, tbValue in pairs(self.tbStoneLevelRandomSeed) do
		if (nMode == Item.tbStone.STONE_PRODUCE_LEVEL_LOW) then
			-- comm 暂停低级宝石的概率变化，固定在2012.4.24这个时间点上
			tbNowList[nMode] = self:CalcRandListReduction(tbValue, 287, nMode, Lib:GetMaxTbKey(tbValue));
		else
			tbNowList[nMode] = self:CalcRandListReduction(tbValue, nNowDay - nOpenDay, nMode, Lib:GetMaxTbKey(tbValue));
		end
	end
	
	return tbNowList;
end

-- 计算等级随机权重衰减
function tbStone:CalcRandListReduction(tb, nBalanceDay, nMode, nMaxLevel)
	local nMinLevel = 100;		-- 一个足够大的值，远大于系统当前的最大宝石等级
	for nLevel, nDay in pairs(tb) do
		if nMinLevel > nLevel then
			nMinLevel = nLevel;
		end
	end
	
	local tbRet = {};
	
	local _nBalanceDay = nBalanceDay - tb[nMinLevel];
	if _nBalanceDay >= 0 then
		-- 所有的等级概率成长1级
		for nLevel, nDay in pairs(tb) do
			if (nLevel + 1 <= nMaxLevel) then
				tbRet[nLevel + 1] = nDay;
			end
		end
		tbRet[nMinLevel] = nil;		-- 不再成长等级
		
		-- 不成长等级
--		tbRet = _nBalanceDay == 0 and tbRet or self:CalcRandListReduction(tbRet, _nBalanceDay, nMode, nMaxLevel);
	else		
		tbRet =  Lib:CopyTB1(tb);
		local nOffset = 1 * nBalanceDay;							-- 高级产出衰减
		if (nMode == self.STONE_PRODUCE_LEVEL_LOW) then
			if (self.SUBSECTION_DATE >= nBalanceDay) then			-- 调整低级产出的权重
				nOffset = nBalanceDay / 3;
			else
				local nSpec = tbRet[nMinLevel] - self.SUBSECTION_DATE / 3;	-- 253
				local nDiv = tbRet[nMinLevel] - self.SUBSECTION_DATE;		-- 73
				nOffset = (self.SUBSECTION_DATE / 3) + ((nBalanceDay - self.SUBSECTION_DATE) * (nSpec / nDiv));
			end
		end
		-- 最低等级的权重衰减N天
		tbRet[nMinLevel] = tbRet[nMinLevel] - nOffset;
		-- 低级产出的，次低等级的权重还要成长N
		if nMode == self.STONE_PRODUCE_LEVEL_LOW then
			tbRet[nMinLevel + 1] = tbRet[nMinLevel + 1] + nOffset;
		end
	end
	
	return tbRet;
end

-- 全用随机道具的时候随机到宝石的时候调用到这里
-- 是为了减少在随机道具的配置表配置信息才增加这个函数的
function tbStone:__RandItemGetStone(nMode, nStoneType, bForceSkillStone, nForceStoneLevel)	
	local tbGDPL = self:RandomStone(nMode, nStoneType, bForceSkillStone, nForceStoneLevel);
	if not tbGDPL then
		return nil;
	end
	
	return me.AddItemEx(unpack(tbGDPL));
end

function tbStone:__RandItemGetStone2()
	return me.AddItemEx(unpack(Item.tbStone.tbStonePatch2));
end

-- 发送公告
function tbStone:BrodcastMsg(szRes, pStone)
	if (not pStone or pStone.GetStoneType() == 0) then		-- 不是石头
		return;
	end
	local nMsgLevel = pStone.GetExtParam(2);		-- 获取公告类型
	if (nMsgLevel < 3) then
		return;
	end
	local szMsg = " tại "..szRes.." nhận được <color=yellow>"..pStone.szName .. "<color>, thật may mắn";
	if (nMsgLevel >= 3) then			-- 好友家族帮会
		Player:SendMsgToKinOrTong(me, szMsg, 0);
		Player:SendMsgToKinOrTong(me, szMsg, 1);
		me.SendMsgToFriend("Hảo hữu [<color=yellow>"..me.szName.."<color>] " .. szMsg);		
	end
	if (nMsgLevel == 4) then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, "Chúc mừng "..me.szName..szMsg);
	elseif (nMsgLevel >= 5) then
		Dialog:GlobalNewsMsg("Chúc mừng "..me.szName..szMsg);
	end
end

