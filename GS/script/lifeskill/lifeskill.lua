
-- 生活技能脚本类
Require("\\script\\lifeskill\\define.lua");

-------------------------------------------------------------------------
-- [C/S]系统启动的时候初始化
function LifeSkill:OnInit()
	local nSkillCount	= self:LoadAllSkill();
	local nRecipeCount	= self:LoadAllRecipe();
	self:DbgOut(string.format("LifeSkill System Inited! %d Skill(s) and %d Recipe(s) loaded!", nSkillCount, nRecipeCount));
end


function LifeSkill:_OnLogin()
	local nSkillCount = self:LoadSkill();
	local nRecipeCount = self:LoadRecipe();

	-- 加上那些可以自动添加的配方	
	local tbPlayerLifeSkills = self:GetMyLifeSkill(me);
	for _, tbSkill in pairs(tbPlayerLifeSkills.tbLifeSkills) do
		for _, tbBelongRecipe in pairs(self.tbLifeSkillDatas[tbSkill.nSkillId].tbRecipeDatas) do
			if ((self:HasLearnRecipe(me, tbBelongRecipe.ID) ~= 1) and tbBelongRecipe.AutoAppend == 1 and tbBelongRecipe.SkillLevel <= tbSkill.nLevel and tbBelongRecipe.Storage == 0) then
				self:AddRecipe(me, tbBelongRecipe.ID);
			end
		end		
	end

	
	--增加活动配方
	--if me.nLevel >= 20 then
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	for nRecipeId, tbEventRecipe in pairs(self.tbStorageDatas) do -- 都是不存盘的活动配方
		if (not tbEventRecipe.nAutoAppend or tbEventRecipe.nAutoAppend == 1) then
			if tbEventRecipe.nStartDate == 0 and tbEventRecipe.nEndDate == 0 then
				self:AddRecipe(me, nRecipeId, 0, 0);-- 登录时候不同步
			elseif nNowDate >= tbEventRecipe.nStartDate and nNowDate < tbEventRecipe.nEndDate then
				self:AddRecipe(me, nRecipeId, 0, 0);
			end
		end
	end
	--end

	self:DbgOut(string.format(me.szName.." %d Skill (s) and %d Recipe(s) Loaded!", nSkillCount, nRecipeCount));

end

function LifeSkill:_OnLogout()
	if (MODULE_GAMESERVER) then
		local nSkillCount = 0;
		local nRecipeCount = 0;
		
		local tbPlayerLifeSkills = self:GetMyLifeSkill(me);
		for _, tbSkill in pairs(tbPlayerLifeSkills.tbLifeSkills) do
			me.SaveAddLifeSkill(tbSkill.nSkillId, tbSkill.nLevel, tbSkill.nExp);
			nSkillCount = nSkillCount + 1;
			for _, tbRecipe in pairs(tbSkill.tbRecipes) do
				me.SaveAddRecipe(tbRecipe.nRecipeId);
				nRecipeCount = nRecipeCount + 1;
			end
		end
		
		self:DbgOut(string.format(me.szName.." %d Skill (s) and %d Recipe(s) Saveed!", nSkillCount, nRecipeCount));
		
	end
end


-------------------------------------------------------------------------
function LifeSkill:LoadSkill()
	local tbSkillList = me.GetLifeSkillList();
	if (not tbSkillList or #tbSkillList == 0) then
		return 0;
	end
	
	for _, tbSkill in ipairs(tbSkillList) do
		self:NewSkill(me, tbSkill.nSkillId, tbSkill.nLevel, tbSkill.nExp);
	end
	
	return #tbSkillList;
end


-------------------------------------------------------------------------
function LifeSkill:NewSkill(pPlayer, nSkillId, nLevel, nCurExp)
	local tbSkillData = self.tbLifeSkillDatas[nSkillId];
	if (not tbSkillData) then
		pPlayer.Msg("Chưa biết kỹ năng sống - ".. nSkillId);
		return nil;
	end
	
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	if (tbPlayerLifeSkills.tbLifeSkills[nSkillId]) then
		pPlayer.Msg("Kỹ năng lặp lại - "..tbPlayerLifeSkills.tbLifeSkills[nSkillId].tbSkillData.Name);
		return nil;
	end
	
	local tbLifeSkill = Lib:NewClass(self._tbSkillClassBase);
	
	tbLifeSkill.nSkillId	= nSkillId;
	tbLifeSkill.nLevel		= nLevel;
	tbLifeSkill.nExp		= nCurExp or 0;
	tbLifeSkill.tbSkillData = tbSkillData;
	tbLifeSkill.tbRecipes	= {};
	tbLifeSkill.me			= pPlayer;
	
	tbPlayerLifeSkills.tbLifeSkills[nSkillId]	= tbLifeSkill;
	
	return tbLifeSkill;
end


-------------------------------------------------------------------------
function LifeSkill:LoadRecipe()
	local tbRecipeList = me.GetRecipeList();
	if (not tbRecipeList or #tbRecipeList == 0) then
		return 0;
	end
	
	for _, nRecipeId in ipairs(tbRecipeList) do
		self:NewRecipe(me, nRecipeId);
	end
	
	return #tbRecipeList;
end

-------------------------------------------------------------------------
function LifeSkill:NewRecipe(pPlayer, nRecipeId)
	local tbRecipeData = self.tbRecipeDatas[nRecipeId];
	if (not tbRecipeData) then
		pPlayer.Msg("Chưa biết phối phương - "..nRecipeId);
		return nil;
	end
	
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[tbRecipeData.Belong];
	if (not tbSkill) then
		pPlayer.Msg("Chưa có kỹ năng liên quan - "..tbRecipeData.Belong..","..tbRecipeData.Name);
		return nil;
	end
	
	if (tbSkill.tbRecipes[nRecipeId]) then
--		pPlayer.Msg("重复配方 - "..tbRecipeData.Name);
		return nil;
	end
	local tbRecipe = Lib:NewClass(self._tbRecipeClassBase);
	
	tbRecipe.nRecipeId = nRecipeId;
	tbRecipe.tbRecipeData = tbRecipeData;
	tbRecipe.tbSkillData =  self.tbLifeSkillDatas[tbRecipeData.Belong];
	tbSkill.tbRecipes[nRecipeId] = tbRecipe;
	
	return tbRecipe;
end


-------------------------------------------------------------------------
-- 为玩家添加一个技能
function LifeSkill:AddLifeSkill(pPlayer, nSkillId, nLevel)
	local tbLifeSkill = LifeSkill:NewSkill(pPlayer, nSkillId, nLevel);
	if (not tbLifeSkill) then
		return;
	end
	pPlayer.SaveAddLifeSkill(tbLifeSkill.nSkillId, tbLifeSkill.nLevel, tbLifeSkill.nExp); -- 数据存到程序中去
	self:AddRecipeForLevelChange(pPlayer, nSkillId, nLevel);
	self:AddTitleForLevelChange(pPlayer, nSkillId, nLevel);
end


-------------------------------------------------------------------------
-- 删除玩家一个技能
function LifeSkill:RemoveLifeSkill(pPlayer, nSkillId)
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nSkillId];
	if (not tbSkill) then
		pPlayer.Msg("Chưa có kỹ năng này:",nSkillId);
		return;
	end
	
	for _, tbRecipe in pairs(tbSkill.tbRecipes) do
		self:RemoveRecipe(pPlayer, tbRecipe.nRecipeId);
	end
	
	tbPlayerLifeSkills[nSkillId] = nil;
	pPlayer.SaveDelLifeSkill(nSkillId);
	pPlayer.Msg("Hủy kỹ năng sống thành công!");
end


-------------------------------------------------------------------------
-- 为玩家添加一个配方
function LifeSkill:AddRecipe(pPlayer, nRecipeId, nMsg, nSync)
	nSync = nSync or 1;
	local nBelongSkillId = self:GetBelongSkillId(nRecipeId);
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nBelongSkillId];
	local tbRecipeData = self.tbRecipeDatas[nRecipeId];
	local nStorageRecipeId = nil;
	if self.tbStorageDatas[nRecipeId] then
		nStorageRecipeId = 1;
	end
	if (not tbRecipeData) then
		if not nStorageRecipeId then
			pPlayer.Msg("Chưa có phối phương này");
		end
		return;
	end
	
	if (not tbSkill) then
		if not nStorageRecipeId then
			pPlayer.Msg("Chưa học kỹ năng liên quan, không thể học phối phương này!");
		end
		return;
	end
	
	if (tbRecipeData.SkillLevel > tbSkill.nLevel) then
		if not nStorageRecipeId then
			pPlayer.Msg("Cấp kỹ năng chưa đủ, không thể học phối phương này");
		end
		return;
	end
	
	local tbRecipe = LifeSkill:NewRecipe(pPlayer, nRecipeId);
	
	if (not tbRecipe) then
		return;
	end
	
	pPlayer.SaveAddRecipe(nRecipeId, nSync);
	if nMsg ~= 0 then
		pPlayer.Msg("Thêm thành công 1 phối phương:"..tbRecipe.tbRecipeData.Name);
	end
	return 1;
end


-------------------------------------------------------------------------
-- 删除玩家一个配方
function LifeSkill:RemoveRecipe(pPlayer, nRecipeId)
	local nBelongSkillId = self:GetBelongSkillId(nRecipeId);
	if (self:HasLearnSkill(pPlayer, nBelongSkillId) ~= 1) then
		pPlayer.Msg("Hủy phối phương bị lỗi, chưa có phối phương thuộc kỹ năng liên quan!");
		return;
	end
	
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nBelongSkillId];
	if (not tbSkill.tbRecipes[nRecipeId]) then
		pPlayer.Msg("Hủy phối phương thất bại, phối phương chỉ định không tồn tại:", nRecipeId)
	end
	
	tbSkill.tbRecipes[nRecipeId] = nil;
	pPlayer.SaveDelRecipe(nRecipeId);
	pPlayer.Msg("Hủy phối phương thành công!");
end


-------------------------------------------------------------------------
-- 为指定技能添加经验
function LifeSkill:AddSkillExp(pPlayer, nSkillId, nExp)

	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nSkillId];
	if (not tbSkill) then
		return;
	end
	
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	tbSkill.nExp  = tbSkill.nExp + nExp;
	local szName  = self.tbLifeSkillDatas[nSkillId].Name;
	pPlayer.Msg("Bạn nhận được "..nExp.." kinh nghiệm \""..szName.."\"");
	
	local nGene = tbSkill.tbSkillData.Gene;
	local nAddExp = 0;
	if (nGene == 0) then --制造经验
		nAddExp = pPlayer.GetTask(StatLog.StatTaskGroupId , 8) + nExp;
		pPlayer.SetTask(StatLog.StatTaskGroupId , 8, nAddExp);
	else	-- 加工
		nAddExp = pPlayer.GetTask(StatLog.StatTaskGroupId , 7) + nExp;
		pPlayer.SetTask(StatLog.StatTaskGroupId , 7, nAddExp);
	end
	
	-- TODO:liuchang 处理最高等级
	local nNextLevel = tbSkill.nLevel + 1;
	
	while (true) do
		if (nNextLevel > tbSkill.tbSkillData.nMaxLevel) then
			nNextLevel = tbSkill.tbSkillData.nMaxLevel;
			break;
		else
			if (self:CanLevelUp(nSkillId, nNextLevel, tbSkill.nExp) == 1) then
				if (self:SetSkillLevel(pPlayer, nSkillId, nNextLevel) == 1) then
					tbSkill.nExp = tbSkill.nExp - self:GetLevelUpExp(nSkillId, nNextLevel);
					nNextLevel = nNextLevel + 1;
				else
					return;
				end
			else
				break;
			end
		end;
	end;		

	if (tbSkill.nExp > self:GetLevelUpExp(nSkillId, nNextLevel)) then
		tbSkill.nExp = self:GetLevelUpExp(nSkillId, nNextLevel);
	end
	
	pPlayer.SaveLifeSkillExp(nSkillId, tbSkill.nExp);

end

-------------------------------------------------------------------------

-- 获取师徒成就
function LifeSkill:GetAchievement(pPlayer, nLevel)
	if (not pPlayer or nLevel <= 0) then
		return;
	end
	if (nLevel >= 30) then
		Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.LIFISKILL_30);
	elseif (nLevel >= 20) then
		Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.LIFISKILL_20);
	end
end

-------------------------------------------------------------------------
-- 设定等级
function LifeSkill:SetSkillLevel(pPlayer, nSkillId, nLevel)
	if (not nLevel or nLevel <= 0) then
		nLevel = 1;
	end
	
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nSkillId];
	if (not tbSkill) then
		return nil;
	end
	
	if (tbSkill.nLevel == tbSkill.tbSkillData.MaxLevel) then
		return 0;
	end
	
	tbSkill.nLevel = nLevel;
	if (tbSkill.nLevel > tbSkill.tbSkillData.MaxLevel) then
		tbSkill.nLevel = tbSkill.tbSkillData.MaxLevel;
	end
	
	pPlayer.SaveLifeSkillLevel(nSkillId, tbSkill.nLevel);

	self:AddRecipeForLevelChange(pPlayer, nSkillId, nLevel);
	
	self:AddTitleForLevelChange(pPlayer, nSkillId, nLevel);
	
	self:GetAchievement(pPlayer, nLevel);
	
	local nGene = tbSkill.tbSkillData.Gene;
	--写Log
	local bMax = 1;
	for iSkillId, vtbSkill in pairs(tbPlayerLifeSkills.tbLifeSkills) do
		if (vtbSkill.nGene == nGene and nLevel < vtbSkill.nLevel) then
			bMax = 0;
			break;
		end
	end	
	if bMax == 1 then
		if (nGene == 0) then
			KStatLog.ModifyField("roleinfo", pPlayer.szName, "Kỹ năng sống cao nhất", tbSkill.tbSkillData.Name);
			KStatLog.ModifyField("roleinfo", pPlayer.szName, "Cấp kỹ năng sống cao nhất", nLevel);
			--KStatLog.ModifyMax("roleinfo", pPlayer.szName, "制造系技能等级", nLevel)
		else
			--KStatLog.ModifyField("roleinfo", pPlayer.szName, "等级最高的加工系技能", tbSkill.tbSkillData.Name)
			--KStatLog.ModifyMax("roleinfo", pPlayer.szName, "加工系技能等级", nLevel)
		end
	end
		
	return 1;
end



-------------------------------------------------------------------------
-- 返回指定等级需要的经验(只考虑单级)
function LifeSkill:GetLevelUpExp(nSkillId, nLevel)
	return self.tbLifeSkillDatas[nSkillId].tbSkillExpMap[nLevel];
end


-------------------------------------------------------------------------
-- 返回增加指定经验是否可以升级
function LifeSkill:CanLevelUp(nSkillId, nLevel, nExp)
	local nNeedExp = self:GetLevelUpExp(nSkillId, nLevel);
	if (not nExp or not nNeedExp) then
		print("LifeSkillExpError", nSkillId, nLevel, nExp);
		return 0;
	end
	if (nExp >= nNeedExp) then
		return 1;
	end
	
	return 0;
end


-------------------------------------------------------------------------
-- 获得指定技能的等级
function LifeSkill:GetSkillLevel(pPlayer, nSkillId)
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nSkillId];
	if (not tbSkill) then
		return 0;
	end
	
	return tbSkill.nLevel;
end


-------------------------------------------------------------------------
-- 返回指定技能当前经验
function LifeSkill:GetSkillCurExp(pPlayer, nSkillId)
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nSkillId];
	if (not tbSkill) then
		return 0;
	end
	
	return tbSkill.nExp;
end


-------------------------------------------------------------------------
-- 是否学习过某种技能
function LifeSkill:HasLearnSkill(pPlayer, nSkillId)
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	if (tbPlayerLifeSkills.tbLifeSkills[nSkillId]) then
		return 1;
	else
		return 0;
	end
end


-------------------------------------------------------------------------
-- 获得知道配方所属技能
function LifeSkill:GetBelongSkillId(nRecipeId)
	return self.tbRecipeDatas[nRecipeId].Belong;
end


-------------------------------------------------------------------------
-- 返回是否学过指定配方
function LifeSkill:HasLearnRecipe(pPlayer, nRecipeId)
	if not self.tbRecipeDatas[nRecipeId] then   -- 有可能为空 zounan
		Setting:SetGlobalObj(pPlayer);
		Player:ProcessIllegalProtocol("LifeSkill:HasLearnRecipe","nRecipeId", nRecipeId);
		Setting:RestoreGlobalObj();
		return 0;
	end
	local nBelongSkillId = self.tbRecipeDatas[nRecipeId].Belong;
	local tbPlayerLifeSkills = self:GetMyLifeSkill(pPlayer);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nBelongSkillId];
	if (not tbSkill) then
		return 0;
	end
	if (tbSkill.tbRecipes[nRecipeId]) then
		return 1;
	else
		return 0;
	end
end

function LifeSkill:WriteStatLog(nPlayerId, nCost, szProductedItemName, nGeneralSkillId, nDetailSkillId, nSkillLevel)
	
	-- 精活消耗，格式：精力,活力
	local szCostDesc = "";
	if nGeneralSkillId == 0 then
		szCostDesc = string.format("%s,%s", 0,  nCost);
	elseif nGeneralSkillId == 1 then
		szCostDesc = string.format("%s,%s", nCost, 0);
	end
	
	-- 产出和技能信息
	local szProductDesc = string.format("%s,%s,%s,%s,%s",  szCostDesc, szProductedItemName, nGeneralSkillId,  nDetailSkillId, nSkillLevel);

	StatLog:WriteStatLog("stat_info", "jinghuoxiaohao", "lifeskill", nPlayerId, szProductDesc);
end


-------------------------------------------------------------------------
-- 制造物品
function LifeSkill:MakeProduct(nRecipeId)
	if me.IsAccountLock() ~= 0 then
		me.Msg("Tài khoản đang khóa, không thề thực hiện thao tác này!");
		Account:OpenLockWindow(me);
		return;
	end
	if (self:HasLearnRecipe(me, nRecipeId) ~= 1) then
		me.Msg("Chưa học phối phương chỉ định!");
		me.SynProduceResult(nRecipeId, 0);
		return;
	end
	
	if (me.nFightState > 0) then
		me.Msg("Trạng thái chiến đấu không thể dùng kỹ năng sống.");
		me.SynProduceResult(nRecipeId, 0);
		return 0;
	end
	
	if (me.GetNpc().nDoing ~= Npc.DO_STAND) then
		me.Msg("Chỉ trạng thái đứng im mới được dùng kỹ năng sống.");
		me.SynProduceResult(nRecipeId, 0);
		return 0;
	end
	
	--活动配方
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if self.tbStorageDatas[nRecipeId] then
		if self.tbStorageDatas[nRecipeId].nStartDate > 0 and self.tbStorageDatas[nRecipeId].nEndDate > 0 then
			if nNowDate < self.tbStorageDatas[nRecipeId].nStartDate or nNowDate >= self.tbStorageDatas[nRecipeId].nEndDate then
				me.Msg("Phối phương này là hoạt động phối phương, bây giờ không còn hiệu lực.");
				me.SynProduceResult(nRecipeId, 0);
				return 0;
			end
		end
	end
	
	
	local tbRecipeData = self.tbRecipeDatas[nRecipeId];
	for _,stuff in ipairs(tbRecipeData.tbStuffSet) do
		if (stuff.nCount and stuff.nCount > 0) then
			
			local nCount = me.GetItemCountInBags(stuff.tbItem[1], stuff.tbItem[2], stuff.tbItem[3], stuff.tbItem[4], stuff.tbItem[5], LifeSkill:GetBindType(stuff.nBind));
			if (nCount < stuff.nCount) then
				me.Msg("Nguyên liệu thiếu, không thể chế tạo.");
				me.SynProduceResult(nRecipeId, 0);
				return 0;
			end
		end
	end
	
	local tbPlayerLifeSkills = self:GetMyLifeSkill(me);
	local nBelongSkillId = self:GetBelongSkillId(nRecipeId);
	local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nBelongSkillId];
	local nGene = tbSkill.tbSkillData.Gene;
	
	if (nGene == 1) then
		if (me.dwCurGTP < tbRecipeData.Cost) then
			me.Msg("Hoạt lực không đủ, không thể hợp thành vật phẩm");
			me.SynProduceResult(nRecipeId, 0);
			return;
		end
	elseif (nGene == 0) then -- 制造系
		if (me.dwCurMKP < tbRecipeData.Cost) then
			me.Msg("Tinh lực không đủ, không thể chế tạo vật phẩm");
			me.SynProduceResult(nRecipeId, 0);
			return 0;
		end 
	else
		print("Loại kỹ năng sống không được ngoài 0,1", nGene);
		assert(false);
	end
	
	local nInterval = tbRecipeData.MakeTime;
	
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_BUYITEM,
		Player.ProcessBreakEvent.emEVENT_SELLITEM,
	}
	local szMsg = "";
	if (nGene == 0) then
		szMsg = "Chế tạo"..tbRecipeData.Name;
	elseif(nGene == 1) then 
		szMsg = "Hợp thành"..tbRecipeData.Name;
	end

	GeneralProcess:StartProcess(szMsg, nInterval, {self.OnMakeProductResult, self, nRecipeId, 0}, {self.OnMakeProductResult, self, nRecipeId, 1}, tbEvent);
	
end

function LifeSkill:OnMakeProductResult(nRecipeId, bBreak)

	if (bBreak == 1) then
		me.Msg("Bị gián đoạn.");
		me.SynProduceResult(nRecipeId, 0);
		return;	
	end
	
	if (self:HasLearnRecipe(me, nRecipeId) == 0) then
		me.Msg("Chưa học phối phương này làm sao chế tạo thành công.");
		me.SynProduceResult(nRecipeId, 0);
		return;
	end
	
	local tbRecipeData = self.tbRecipeDatas[nRecipeId];
	
	local tbSkillData  = self.tbLifeSkillDatas[tbRecipeData.Belong];
	local szLifeSkillType = "";
	
	if (tbSkillData.nGene == 0) then
		szLifeSkillType = "Hợp thành"..tbRecipeData.Name;
	elseif(tbSkillData.nGene == 1) then
		szLifeSkillType = "Gia công"..tbRecipeData.Name;
	end
	
	--活动配方
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if self.tbStorageDatas[nRecipeId] then
		if self.tbStorageDatas[nRecipeId].nStartDate > 0 and self.tbStorageDatas[nRecipeId].nEndDate > 0 then
			if nNowDate < self.tbStorageDatas[nRecipeId].nStartDate or nNowDate >= self.tbStorageDatas[nRecipeId].nEndDate then
				me.Msg("Phối phương này là hoạt động phối phương, bây giờ không còn hiệu lực.");
				me.SynProduceResult(nRecipeId, 0);
				return 0;
			end
		end
	end
	
	local nCanProduct, tbFunExecute, szExtendInfo, tbTempProductSet = SpecialEvent.ExtendAward:DoCheck("LifeSkill", me, nRecipeId)
	local tbProductSet = tbRecipeData.tbProductSet;
	if nCanProduct == 1 and tbTempProductSet and #tbTempProductSet > 0 then
		tbProductSet = tbTempProductSet;
		if szExtendInfo and szExtendInfo ~= "" then
			me.Msg(szExtendInfo);
		end
	end
	
	local nPercent = MathRandom(100);
	local tbFinalProduct = nil;
	for _, tbProduct in ipairs(tbProductSet) do
		nPercent = nPercent - tbProduct.nRate;
		local tbItem = tbProduct.tbItem;
		local tbBaseProp = KItem.GetItemBaseProp(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
		if (nPercent <= 0) and tbBaseProp then
			local bBind = LifeSkill:GetBindType(tbProduct.nBind);
			if bBind == -1 then
				bBind = KItem.IsItemBindByBindType(tbBaseProp.nBindType);
			end
			tbFinalProduct =
			{
				nGenre		= tbItem[1],
				nDetail		= tbItem[2],
				nParticular	= tbItem[3],
				nLevel		= tbItem[4],
				nSeries		= (tbBaseProp.nSeries > 0) and tbBaseProp.nSeries or tbItem[6],
				bBind		= bBind,
				nLucky		= tbItem[5],
				nCount		= 1,
			}; 
			break;
		end
	end
	
	if (tbFinalProduct) then
		if (me.CanAddItemIntoBag(tbFinalProduct) ~= 1) then
			me.Msg("Túi đã đầy.");
			me.SynProduceResult(nRecipeId, 0);
			return;
		end
	end	
	
	-- 判断材料是否足够
	for _, stuff in ipairs(tbRecipeData.tbStuffSet) do
		if (stuff.nCount and stuff.nCount > 0) then
			local nCount = me.GetItemCountInBags(stuff.tbItem[1], stuff.tbItem[2], stuff.tbItem[3], stuff.tbItem[4], stuff.tbItem[5], LifeSkill:GetBindType(stuff.nBind));
			if (nCount < stuff.nCount) then
				me.Msg("Nguyên liệu không đủ. "..szLifeSkillType.." thất bại");
				me.SynProduceResult(nRecipeId, 0);
				return;
			end
		end
	end
	
	local nCost = 0;
	for _, stuff in ipairs(tbRecipeData.tbStuffSet) do
		if (stuff.nCount and stuff.nCount > 0) then
			local bRet;
			if LifeSkill:GetBindType(stuff.nBind) >= 0 then
				bRet = me.ConsumeItemInBags2(stuff.nCount, stuff.tbItem[1], stuff.tbItem[2], stuff.tbItem[3], stuff.tbItem[4], stuff.tbItem[5], LifeSkill:GetBindType(stuff.nBind));
			else
				bRet = me.ConsumeItemInBags(stuff.nCount, stuff.tbItem[1], stuff.tbItem[2], stuff.tbItem[3], stuff.tbItem[4], stuff.tbItem[5]);
			end
			
			if (bRet ~= 0) then
				me.Msg("Trừ nguyên liệu thất bại.");
				me.SynProduceResult(nRecipeId, 0);
				return;
			end
			-- 获得材料所需的精活
			local nStuffCost = self.tbCost[stuff.tbItem[1]..","..stuff.tbItem[2]..","..stuff.tbItem[3]..","..stuff.tbItem[4]]
			if nStuffCost then
				nCost = nCost + stuff.nCount * nStuffCost / Spreader.ExchangeRate_Gold2JingHuo
			end
		end
	end
	
	local nGene = tbSkillData.Gene;
	if (tbSkillData.Gene == 1) then
		if (me.dwCurGTP < tbRecipeData.Cost) then
			me.Msg("Hoạt lực không đủ.");
			me.SynProduceResult(nRecipeId, 0);
			return;
		end
		me.ChangeCurGatherPoint(-tbRecipeData.Cost);
	elseif(tbSkillData.Gene == 0) then
		if (me.dwCurMKP < tbRecipeData.Cost) then
			me.Msg("Tinh lực không đủ.");
			me.SynProduceResult(nRecipeId, 0);
			return;
		end
		me.ChangeCurMakePoint(-tbRecipeData.Cost);
		if tbRecipeData.Consume == 1 then
			nCost = nCost + tbRecipeData.Cost / Spreader.ExchangeRate_Gold2JingHuo; -- 记录ibvalue
		else
			nCost = 0;		-- 箱子
			-- Spreader:OnMakeBox(nRecipeId)
		end
	end
	
	if (tbFinalProduct) then
		-- 加物品
		local tbItemInfo = {
				nSeries = tbFinalProduct.nSeries,
				nLucky = tbFinalProduct.nLucky,
			};
		if tbFinalProduct.bBind >= 0 then
		 	tbItemInfo.bForceBind = tbFinalProduct.bBind;
		end
		
		local pItem = me.AddItemEx(tbFinalProduct.nGenre, tbFinalProduct.nDetail, tbFinalProduct.nParticular, tbFinalProduct.nLevel, tbItemInfo, Player.emKITEMLOG_TYPE_PRODUCE);

		if pItem then
			
			pItem.nBuyPrice = pItem.nBuyPrice + nCost;
			pItem.SetCustom(Item.CUSTOM_TYPE_MAKER, me.szName);		-- 记录制造者名字
			pItem.Sync();
		
			local nLevelDec = math.floor(me.nLevel / 10);
			local szLevelRang = (nLevelDec * 10 + 1) .. "~" .. (nLevelDec * 10 + 10);
			-- 记录价值量
			--KStatLog.ModifyAdd("LifeSkillStat", szLevelRang, "通过生活技能制造的道具价值总量", pItem.nValue);
			

			-- 生活技能消耗技能埋点log
			local tbPlayerLifeSkills = self:GetMyLifeSkill(me);
			local nBelongSkillId = self:GetBelongSkillId(nRecipeId);
			local tbSkill = tbPlayerLifeSkills.tbLifeSkills[nBelongSkillId];
			self:WriteStatLog(me.nId, tbRecipeData.Cost, pItem.szName, tbSkillData.Gene, tbSkillData.ID, tbSkill.nLevel);
			
			-- 加经验
			self:AddSkillExp(me, self:GetBelongSkillId(nRecipeId), tbRecipeData.ExpGain);
			
			me.Msg(szLifeSkillType.."Thành công.")
		else

			me.Msg(szLifeSkillType.."Thất bại.")

		end

	else

		me.Msg(szLifeSkillType.."Thất bại.")

	end
	--制作等级大于5级成品（40级给的是5级）
	if tbRecipeData.SkillLevel >= 40 and tbSkillData.Gene == 0 then
		SpecialEvent.ActiveGift:AddCounts(me, 46);
	end
	me.SynProduceResult(nRecipeId, 1);

end


-------------------------------------------------------------------------
function LifeSkill:OnLogout()
	self:SaveAllSkill();
	self:SaveAllRecipe();	
end


-------------------------------------------------------------------------
-- 取得当前玩家生活技能数据
function LifeSkill:GetMyLifeSkill(pPlayer)
	local tbPlayerData		= pPlayer.GetTempTable("LifeSkill");
	local tbPlayerLifeSkill	= tbPlayerData.tbLifeSkill;
	if (not tbPlayerLifeSkill) then
		tbPlayerLifeSkill	= {
			tbLifeSkills	= {},
		};
		tbPlayerData.tbLifeSkill	= tbPlayerLifeSkill;
	end
	
	return tbPlayerLifeSkill;
end


-------------------------------------------------------------------------
-- 玩家升级为其添加生活技能
function LifeSkill:AddSkillWhenPlayerLevelUp(nLevel)
	if (MODULE_GAMESERVER) then
		if (nLevel == 20) then
			for i=1, 11 do
				self:AddLifeSkill(me, i, 1)
			end
		end
	end
end


function LifeSkill:AddRecipeForLevelChange(pPlayer, nSkillId, nSkillLevel)
	-- 加上那些可以自动添加的配方
	for _, tbBelongRecipe in pairs(self.tbLifeSkillDatas[nSkillId].tbRecipeDatas) do
		if (tbBelongRecipe.AutoAppend == 1 and tbBelongRecipe.SkillLevel <= nSkillLevel and tbBelongRecipe.Storage == 0) then
			self:AddRecipe(pPlayer, tbBelongRecipe.ID);
		end
	end
	
	--增加活动配方
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	for nRecipeId, tbEventRecipe in pairs(self.tbStorageDatas) do
		if (not tbEventRecipe.nBelong or tbEventRecipe.nBelong == nSkillId) 
			and (not tbEventRecipe.nAutoAppend or tbEventRecipe.nAutoAppend == 1) then
			if tbEventRecipe.nStartDate == 0 and tbEventRecipe.nEndDate == 0 then
				self:AddRecipe(me, nRecipeId, 1, 0);
			elseif nNowDate >= tbEventRecipe.nStartDate and nNowDate < tbEventRecipe.nEndDate then
				self:AddRecipe(me, nRecipeId, 1, 0);
			end
		end
	end	
	
end


function LifeSkill:AddTitleForLevelChange(pPlayer, nSkillId, nSkillLevel)
	if (LifeSkill.tbLifeSkillLevelForTitle[nSkillId] and LifeSkill.tbLifeSkillLevelForTitle[nSkillId][nSkillLevel]) then
		local tbTitle = LifeSkill.tbLifeSkillLevelForTitle[nSkillId][nSkillLevel];
		pPlayer.AddTitle(tbTitle[1] or 0, tbTitle[2] or 0, tbTitle[3] or 0, tbTitle[4] or 0);
	end

end

-- 获取指定生活技能不存盘的配方列表
function LifeSkill:GetSkillFixRecipes(nSkillId, nSkillLevel)
	local tbRecipes = {};
	for _, tbBelongRecipe in pairs(self.tbLifeSkillDatas[nSkillId].tbRecipeDatas) do
		if  tbBelongRecipe.AutoAppend == 1 and tbBelongRecipe.SkillLevel <= nSkillLevel and tbBelongRecipe.Storage ~= 0 then
			local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
			if (self.tbStorageDatas[tbBelongRecipe.ID].nStartDate == 0 and self.tbStorageDatas[tbBelongRecipe.ID].nEndDate == 0) or (nNowDate >= self.tbStorageDatas[tbBelongRecipe.ID].nStartDate and nNowDate < self.tbStorageDatas[tbBelongRecipe.ID].nEndDate) then
				table.insert(tbRecipes, tbBelongRecipe.ID);
			end
		end
	end	
	return tbRecipes;	
end
-------------------------------------------------------------------------
-- 供调试用
function LifeSkill:ShowMySkill(pPlayer)
	local tbPlayerLifeSkills = LifeSkill:GetMyLifeSkill(pPlayer);
	if (tbPlayerLifeSkills) then
		for _, tbSkill in pairs(tbPlayerLifeSkills.tbLifeSkills) do
			pPlayer.Msg(tbSkill.tbSkillData.Name.."Cấp: "..tbSkill.nLevel..". Kinh nghiệm: "..tbSkill.nExp);
			if (tbSkill.tbRecipes) then
				for _, tbRecipe in pairs(tbSkill.tbRecipes) do
					pPlayer.Msg("    "..tbRecipe.tbRecipeData.Name)
				end
			end
		end
	end
end

--获得绑定类型(0为绑定和不绑定都可, 1-绑定, 2-不绑定)
function LifeSkill:GetBindType(nBind)
	if nBind == 0 then
		return -1;
	end
	if nBind == 1 then
		return 1;
	end
	if nBind == 2 then
		return 0;
	end
	return -1;
end


-- 注册通用上线事件
PlayerEvent:RegisterGlobal("OnLogin", LifeSkill._OnLogin, LifeSkill);

-- 注册离线事件
PlayerEvent:RegisterGlobal("OnLogout", LifeSkill._OnLogout, LifeSkill)
