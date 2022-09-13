------------------------------------------------------
-- 文件名　：zhenyuan_gs.lua
-- 创建者　：dengyong
-- 创建时间：2010-07-14 10:55:44
-- 功能    ：真元服务端逻辑
------------------------------------------------------
Require("\\script\\item\\zhenyuan\\zhenyuan_define.lua");

if MODULE_GAMESERVER then	

Item.tbZhenYuan = Item.tbZhenYuan or {};
local tbZhenYuan = Item.tbZhenYuan;

Item.tbZhenYuan.c2sFun = {};
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	Item.tbZhenYuan.c2sFun[szName] = fun;
end

-- set, get访问接口注册
-- 接口访问的形式为(以Level为例)：tbZhenYuan:GetLevel(dwId)
-- tbZhenYuan:SetLevel(dwId, nValue)
for key, _ in pairs(tbZhenYuan.tbParam) do
	local funSet = 
		function (_self, ...)
			tbZhenYuan.SetParam(_self, key, unpack(arg));
		end
	local funGen = 
		function (_self, ...)
			tbZhenYuan.GenZhenYuanInfo(_self, key, unpack(arg));
		end
		
	rawset(tbZhenYuan, "Set"..key, funSet);
	rawset(tbZhenYuan, "Gen"..key, funGen);
end

-- 第二个参数为number时，应该是道具ID；或者直接为道具对象
-- bSync表示是否在该次setgeninfo之后要同步道具信息，默认为1表示同步，0表示不需要同步
function tbZhenYuan:SetParam(szFun, varItem, nValue, bSync)
	local pItem = nil;
	if type(varItem) == "number" then
		pItem = KItem.GetObjById(varItem);
	elseif type(varItem) == "userdata" then
		pItem = varItem;
	end
	if (not pItem) then
		return;
	end
	
	bSync = bSync or 1;
	
	local tbFunParam = self.tbParam[szFun];
	local nGenInfoValue = Lib:SetBits(pItem.GetGenInfo(tbFunParam[1]), nValue, tbFunParam[2], tbFunParam[3]);
	pItem.SetGenInfo(tbFunParam[1], nGenInfoValue);
	
	if bSync == 1 then
		pItem.Sync();		-- 修改GenInfo之后，要同步给客户端
	end
end

-- 按照真元GetInfo存储结构设置数据，在生成真元之前用
function tbZhenYuan:GenZhenYuanInfo(szFun, tbGenInfo, nValue)
	if not tbGenInfo or type(tbGenInfo) ~= "table" then
		return;
	end
	
	local tbFunParam = self.tbParam[szFun];
	local nGenInfoValue = tbGenInfo[tbFunParam[1]] or 0;
	nGenInfoValue = Lib:SetBits(nGenInfoValue, nValue, tbFunParam[2], tbFunParam[3]);
	tbGenInfo[tbFunParam[1]] = nGenInfoValue;
end

-- 使用经验书，服务端逻辑
function tbZhenYuan:EatExpBook(pItem, tbExpBook)
	if not self.bOpen or self.bOpen ~= 1 then
		return;
	end
	
	if (me.IsAccountLock() == 1) then
		me.Msg("Tài khoản đang khóa, không thể thao tác!");
		return 0;
	end
	
	if not pItem or pItem.szClass ~= "zhenyuan" then
		me.Msg("Chỉ có thể đặt Chân nguyên vào!");
		return;
	end
	
	for _, pBook in pairs(tbExpBook) do
		if pBook.szClass ~= "partnerexpbook" then
			me.Msg("Chỉ có thể đặt Sách kinh nghiệm đồng hành vào!");
			return;
		end
	end
	
	local nOrgLevel = self:GetLevel(pItem);
	local bTooMany, nNewLevel, nBalanceExp = self:GetExpAdded(pItem, tbExpBook);
	if bTooMany == 1 then
		me.Msg("Đừng lãng phí Sách kinh nghiệm đồng hành!");
		return 1;	-- 虽然这里没有执行成功，但是也没有出现异常的情况，所以返回1
	end
	
	local nCount = #tbExpBook;
	for _, pItem in pairs(tbExpBook) do
		local szItemName = pItem.szName;
		local nRet = me.DelItem(pItem);		-- 扣除经验书
		if nRet ~= 1 then
			Dbg:WriteLog("ZhenyuanEnhance", "角色名:"..me.szName, "帐号:"..me.szAccount, "扣除"..szItemName.."失败");
			return 0;	-- 扣除失败，异常情况，返回0
		end
	end
	
	local nOldValue = self:GetZhenYuanValue(pItem);
	
	self:SetLevel(pItem, nNewLevel);
	self:SetCurExp(pItem, nBalanceExp);
	-- 内存计数变量
	if nNewLevel == self.MAXLEVEL then
		self.nCount_FullLevel_All = self.nCount_FullLevel_All + 1;
		local nDayTime = Lib:GetLocalDay(GetTime());
		if nDayTime ~= self.nLastDayTime then
			self.nLastDayTime = nDayTime;
			self.nCount_FullLevel_Today = 1;
			self.nCount_Refine_Today = 0;
		else
			self.nCount_FullLevel_Today = self.nCount_FullLevel_Today + 1;
		end
	end

	pItem.Regenerate(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, 
		pItem.nSeries, pItem.nEnhTimes, pItem.nLucky, pItem.GetGenInfo(),
		pItem.nVersion, pItem.dwRandSeed, pItem.nStrengthen);
	
	local szMsg = string.format("%s sử dụng %d Sách kinh nghiệm đồng hành, đẳng cấp đạt %d!", pItem.szName, nCount, nNewLevel);
	me.Msg(szMsg);		
	
	-- 等级变化，价值量发生了变化，要求修改排行榜数据
	-- 全局服不应用GUID榜
	if (nOldValue ~= self:GetZhenYuanValue(pItem) and IsGlobalServer() == false and 
		(self:GetParam1(pItem) ~= 1 or self:GetEquiped(pItem) == 1 )) then
		Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(pItem), pItem.szGUID, me.szName, self:GetZhenYuanValue(pItem)/10000);
	end
				
	-- 如果玩家真元修炼任务，则记录任务变量。
	self:CheckTaskStep(self.TASKSTEP_XIULIAN);
		
	if nNewLevel/5 ~= nOrgLevel/5 then
		local tbBaseAttrib = pItem.GetBaseAttrib();
		local tbAttribEnhanced = Item.tbZhenYuan:GetAttribEnhanced(pItem.dwId, 0);
		local tbAttrib = {};
		for i = 1, self.ATTRIB_COUNT do
			-- 加0.5做四舍五入运算
			tbAttrib[i] = self["GetAttrib"..i.."Range"](self, pItem) + 
				math.floor(self:GetAttribMapValue(tbBaseAttrib[i].szName, tbAttribEnhanced[i]) + 0.5);
		end
		
		StatLog:WriteStatLog("stat_info", "zhenyuan", "zhenyuanshengji", me.nId, 
			 string.format("%s_%s_%d_%1.0f_[%d,%d,%d,%d,%d,%d,%d,%d]",
				pItem.szName, pItem.szGUID, nNewLevel, self:GetZhenYuanValue(pItem),
				self:GetAttribPotential1(pItem), tbAttrib[1],
				self:GetAttribPotential2(pItem), tbAttrib[2],
				self:GetAttribPotential3(pItem), tbAttrib[3],
				self:GetAttribPotential4(pItem), tbAttrib[4]));

	end
	
	StatLog:WriteStatLog("stat_info", "zhenyuan", "zhenyuanjingyan", me.nId,
		string.format("%s,%s,%d,%d", pItem.szName, pItem.szGUID, self.EXPWAY_EXPBOOK, #tbExpBook * self.EXPTIMES_XIULIAN));	
	
	-- 记录修炼次数
	local nTimes = me.GetTask(self.LOG_TASK_MAIN, self.LOG_TASK_XIULIANCOUNT);
	me.SetTask(self.LOG_TASK_MAIN, self.LOG_TASK_XIULIANCOUNT, nTimes + 1);
		
	return 1;	-- 执行成功，返回1
end

-- 添加经验，第二个参数是基准时间，不是确实的经验点数
function tbZhenYuan:AddExp(pItem, nExpTime, nExpWay, pPlayer)
	-- 没有开放真元，不能历练添加经验
	if not self.bOpen or self.bOpen ~= 1 then
		return;
	end
	
	local nLevelUp, nCurExp, nUseTime, nSumExp = 0, 0, 0, 0;
	nExpWay = nExpWay or 0;
	pPlayer = pPlayer or me;
	if pPlayer.nLevel < self.ZHENYUAN_LEVEL_NEED then
		return;
	end
	
	if pItem then
		nLevelUp, nCurExp, nUseTime, nSumExp = self:CalExpFromTime(pItem, nExpTime);
		
		self:SetCurExp(pItem, nCurExp);
		local szMsg = string.format("%s tăng %d điểm kinh nghiệm", pItem.szName, nSumExp);
		
		if nLevelUp > 0 then
			self:AddLevel(pItem, nLevelUp, pPlayer);
			szMsg = szMsg..string.format(", đạt cấp độ %d", self:GetLevel(pItem));
		end
		
		StatLog:WriteStatLog("stat_info", "zhenyuan", "zhenyuanjingyan", pPlayer.nId,
			string.format("%s,%s,%d,%d", pItem.szName, pItem.szGUID, nExpWay, nExpTime));
		
		pPlayer.Msg(szMsg.."！");
		
		-- 如果玩家真元历炼任务，则记录任务变量。
		self:CheckTaskStep(self.TASKSTEP_LILIAN);
	end
	
	if nExpWay ~= 0 then
		-- 将剩余经验累积到任务变量中
		local nBalance = nExpTime;
		local nOrg = pPlayer.GetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_SUB);
		local nNew = nOrg + nBalance;
		if nNew >= self.EXPSTORE_MAX then
			nNew = self.EXPSTORE_MAX;
			pPlayer.CallClientScript({"PopoTip:ShowPopo", 28});
		end
		pPlayer.SetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_SUB, nNew);
		
		local szMsg;
		if nOrg ==self.EXPSTORE_MAX then
			szMsg = "Kinh nghiệm tích lũy đạt giới hạn, không thể tăng thêm.";
		else
			szMsg = string.format("Lần này nhận được %s phút kinh nghiệm.", 
				nExpTime, nUseTime, nExpTime - nUseTime);
		end
		
		pPlayer.Msg(szMsg);
	end

	pPlayer.CallClientScript({"Item.tbZhenYuan:NotifyLiLianResult"});

end

-- 升级
function tbZhenYuan:AddLevel(pItem, nLevelUp, pPlayer)
	local nOrgLevel = self:GetLevel(pItem);
	local nNewLevel = nLevelUp + nOrgLevel;
	local nOldValue = self:GetZhenYuanValue(pItem);
	
	self:SetLevel(pItem, nNewLevel);
	-- 内存计数变量
	if nNewLevel == self.MAXLEVEL then
		self.nCount_FullLevel_All = self.nCount_FullLevel_All + 1;
		local nDayTime = Lib:GetLocalDay(GetTime());
		if nDayTime ~= self.nLastDayTime then
			self.nLastDayTime = nDayTime;
			self.nCount_FullLevel_Today = 1;
			self.nCount_Refine_Today = 0;
		else
			self.nCount_FullLevel_Today = self.nCount_FullLevel_Today + 1;
		end
	end

	-- 满级之后，给个泡泡提示
	if nNewLevel == self.MAXLEVEL then
		pPlayer.CallClientScript({"PopoTip:ShowPopo", 27});
	end
	
	pItem.Regenerate(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, 
		pItem.nSeries, pItem.nEnhTimes, pItem.nLucky, pItem.GetGenInfo(),
		pItem.nVersion, pItem.dwRandSeed, pItem.nStrengthen);
	
	if nNewLevel/5 ~= nOrgLevel/5 and nLevelUp ~= 0 then
		local tbBaseAttrib = pItem.GetBaseAttrib();
		local tbAttribEnhanced = Item.tbZhenYuan:GetAttribEnhanced(pItem.dwId, 0);
		local tbAttrib = {};
		for i = 1, self.ATTRIB_COUNT do
			-- 加0.5做四舍五入运算
			tbAttrib[i] = self["GetAttrib"..i.."Range"](self, pItem) + 
				math.floor(self:GetAttribMapValue(tbBaseAttrib[i].szName, tbAttribEnhanced[i]) + 0.5);
		end
		
		StatLog:WriteStatLog("stat_info", "zhenyuan", "zhenyuanshengji", pPlayer.nId, 
			 string.format("%s,%s,%d,%1.0f,%d,%d,%d,%d,%d,%d,%d,%d",
				pItem.szName, pItem.szGUID, nNewLevel, self:GetZhenYuanValue(pItem),
				self:GetAttribPotential1(pItem), tbAttrib[1],
				self:GetAttribPotential2(pItem), tbAttrib[2],
				self:GetAttribPotential3(pItem), tbAttrib[3],
				self:GetAttribPotential4(pItem), tbAttrib[4]));
	end
	
	-- 升级之后，价值量属发生了改变， 需要修改排行榜数据
	-- 全局服不应用GUID榜
	if (nOldValue ~= self:GetZhenYuanValue(pItem) and IsGlobalServer() == false and
		(self:GetParam1(pItem) ~= 1 or self:GetEquiped(pItem) == 1 )) then
		Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(pItem), pItem.szGUID, pPlayer.szName, self:GetZhenYuanValue(pItem)/10000);
	end
end

-- 生成一个绑定真元
function tbZhenYuan:GenerateEx(nPartnerId)
	local nType = Partner.tbPartnerAttrib[nPartnerId].nType;
	local tbSkillCountRate = Partner.tbSkillRule[nType];
	if not tbSkillCountRate then
		return;		-- 给定同伴类型没有对应的配置
	end
	local nCountAll = Partner:RandomSkillCount(tbSkillCountRate, nType);
	local pItem = self:Generate({nPartnerId, nCountAll}, 1);
	self:SetParam1(pItem, 1);
	pItem.Bind(1);
	return pItem;
end

-- 一些判断条件应该放在外围逻辑
-- 生成一个真元，参数为要转成真元的同伴对象
function tbZhenYuan:Generate(varPartner, nParam1)
	if not self.bOpen or self.bOpen ~= 1 then
		return;
	end
	
	if not varPartner then
		return;
	end
	
	nParam1 = nParam1 or 0;

	if Partner:CanConvertToZhenYuan(varPartner) == 0 then
		me.Msg("Đồng hành có dấu ấn màu xanh mới có thể chuyển đổi thành Chân Nguyên.");
		return;
	end

	local pItem = nil;	
	local tbGDPL, nTempId, nPartnerValue, szName = Partner:GetZhenYunInfoFromPartner(varPartner);
	if not tbGDPL or not nTempId or not nPartnerValue or not szName then
		print("convert failed!");
		return;
	end
	
	-- 模拟要生成真元的GenInfo数组，在生成道具的时候传入这个数组
	-- 这里不包括初始属性的档次，因为那个是要在生成道具之后才回调，不是在之前 
	local tbGenInfo = {};		-- 要生成道具的GenInfo
	self:GenTemplateId(tbGenInfo, nTempId);		-- 模板ID
	self:GenLevel(tbGenInfo, 1);				-- 初始等级，0
	self:GenCurExp(tbGenInfo, 0);				-- 初始经验，0
	self:GenEquiped(tbGenInfo, 0);				-- 初始未装备过
	-- 生成各属性资质的价值量星级，和属性资质分配模板
	local tbPotenLevel, nAttribRateTemp = self:GenerateAttrib(tbGDPL, nTempId, nPartnerValue);
	for i, nStarLevel in pairs(tbPotenLevel) do
		local szFun = "GenAttribPotential"..i;
		self[szFun](self, tbGenInfo, nStarLevel);	-- 各属性资质的价值量星级
	end
	self:GenPotenRateTemp(tbGenInfo, nAttribRateTemp);	-- 属性资质分配模板
	

	pItem = me.AddItem(tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4], 0, 0, 0, tbGenInfo);
	if not pItem then	-- 生成道具失败，退出
		return;
	end
		
	-- 创建一个真元，要求排行榜排序
	-- 全局服务器不应用真元榜
	if nParam1 == 0 and IsGlobalServer() == false then
		Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(pItem), pItem.szGUID, me.szName, self:GetZhenYuanValue(pItem)/10000);
	end
	
	-- 同伴的信息在删除同伴的时候已经有记录了，所以这里只记录真元道具的信息
	-- 因此，查真元凝聚的LOG的时候可能需要查找两个地方
	local tbBaseAttrib = pItem.GetBaseAttrib();
	local tbAttribEnhanced = Item.tbZhenYuan:GetAttribEnhanced(pItem.dwId, 0);
	local tbAttrib = {};
	for i = 1, self.ATTRIB_COUNT do
		-- 加0.5做四舍五入运算
		tbAttrib[i] = self["GetAttrib"..i.."Range"](self, pItem) + 
			math.floor(self:GetAttribMapValue(tbBaseAttrib[i].szName, tbAttribEnhanced[i]) + 0.5);
	end
	StatLog:WriteStatLog("stat_info", "zhenyuan", "zhenyuanhuode", me.nId, 
		string.format("%s,%s,%d,%1.0f,%d,%d,%d,%d,%d,%d,%d,%d",
			pItem.szName, pItem.szGUID, 1, self:GetZhenYuanValue(pItem),
			self:GetAttribPotential1(pItem), tbAttrib[1],
			self:GetAttribPotential2(pItem), tbAttrib[2],
			self:GetAttribPotential3(pItem), tbAttrib[3],
			self:GetAttribPotential4(pItem), tbAttrib[4]
			));
	
	-- 如果玩家真元凝聚任务，则记录任务变量。
	self:CheckTaskStep(self.TASKSTEP_CONVERT)
	
	return pItem;
end

-- 属性资质选择性随机，在真元的生成流程过程中，该函数先于me.AddItem，所以这时还没有道具对象
-- 返回值，各属性资质的星级，属性资质价值量分配比例模板
function tbZhenYuan:GenerateAttrib(tbGDPL, nZhenYuanTemp, nPartnerValue)
	-- 因为同一个类型的同伴可能会对应几种不同的资质模板分配比例，所以要先获取当前用的资质分配比例
	local nAttribRateTemp = self:GetAttribPotentialRate(nZhenYuanTemp);
	local tbAttribRate = Item.tbZhenYuanSetting.tbTemplateSetting[nZhenYuanTemp].tbAttribPotenRate[nAttribRateTemp];

	local tbPotenLevel = {};
	for i = 1, self.ATTRIB_COUNT do
		-- 属性资质
		-- 在生成的时候，属性资质的价值量决定星级
		-- 在生成以后，通过属性资质的星级来获取价值量
		local nAttribPotenRate = tbAttribRate["nAttribPoten"..i.."Rate"];
		local nPotenValue = math.floor(nPartnerValue * nAttribPotenRate/100);
		local nAttribId = self:GetAttribMagicId(tbGDPL, i);
		
		local nPotenLeftMax, nPotenLeftLevel, nPotenRightMin, nPotenRightLevel = self:FindBetween(nAttribId, nPotenValue);
		local nPotenLevel;
		-- 低一级档次都为最高，直接取最高档
		if (nPotenLeftLevel == Item.tbZhenYuanSetting.ATTRIBPOTEN_COUNT) then
			nPotenLevel = nPotenLeftLevel;
		elseif (nPotenRightLevel == 1) then		-- 高一级档次为最低，直接取最低档
			nPotenLevel = nPotenRightLevel;
		elseif (nPotenRightLevel == nPotenLeftLevel) then  -- 低一档和高一档是同一档，直接取这个档次
			nPotenLevel = nPotenRightLevel;
		else	-- 需要随机，计算取高一级的档次还是低一级的档次
			-- 应该是个半闭半开的区间，所以把最大值减1，达到半闭半开的效果。
			local nRandom = MathRandom(nPotenLeftMax, nPotenRightMin - 1);
			if nRandom >= nPotenValue then
				nPotenLevel = nPotenLeftLevel;
			else
				nPotenLevel = nPotenRightLevel;
			end
		end
		
		-- 最小为1
		if nPotenLevel <= 0 then
			nPotenLevel = 1;
		end
		
		tbPotenLevel[i] = nPotenLevel;
	end
	
	return tbPotenLevel, nAttribRateTemp;
end

-- 返回值说明：当nPotenLevelMin为20时表示固定取20星
-- 当nPotenRightLevel为1时表示固定取1星
function tbZhenYuan:FindBetween(nAttribId, nPotenValue)
	local tb = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId];
	if not tb then
		assert(false);
	end
	local nPotenLeftMax, nPotenLefLevel = 0, 0;
	local nPotenRightMin, nPotenRightLevel = 0, 0;
	for i = 1, Item.tbZhenYuanSetting.ATTRIBPOTEN_COUNT do
		local nPoten = tb["StarLevel"..i.."Value"];
		if (nPoten <= nPotenValue and nPoten > nPotenLeftMax) then
			nPotenLeftMax = nPoten;
			nPotenLefLevel = i;
		elseif (nPoten >= nPotenValue and (nPoten < nPotenRightMin or nPotenRightMin == 0)) then
			nPotenRightMin = nPoten;
			nPotenRightLevel = i;
		end
	end
	
	return nPotenLeftMax, nPotenLefLevel, nPotenRightMin, nPotenRightLevel;
end

-- 生成的时候获取属性资质价值量分配比例模板
function tbZhenYuan:GetAttribPotentialRate(nZhenyuanTempl)
	local nCount = #Item.tbZhenYuanSetting.tbTemplateSetting[nZhenyuanTempl].tbAttribPotenRate;
	local nRandom = MathRandom(1, nCount);
	
	return nRandom;
end

-- 生成道具之后需要做的一些处理，目前主要是初始化初始属性随机的档次
function tbZhenYuan:EndGenerate(tbAttribRand)
	assert(it);
	for i = 1, self.ATTRIB_COUNT do
		local szFun = "SetAttrib"..i.."Range";
		self[szFun](self, it, tbAttribRand[i], 0);  -- 不同步
	end
	
	it.Sync();		-- 一次性同步
	return 1;
end

-- 炼化，被炼化的道具，用来炼化的道具，要炼化的属性对应的魔法属性ID
function tbZhenYuan:Refine(pDestItem, pSrcItem, nAttriId, bSure)
	if not self.bOpen or self.bOpen ~= 1 then
		return;
	end
	
	if (me.IsAccountLock() == 1) then
		me.Msg("Tài khoản khóa không thể thao tác!");
		return 0;
	end
	
	bSure = bSure or 0;
	
	local bDeseEquiped = self:GetEquiped(pDestItem);
	local bSrcEquiped = self:GetEquiped(pSrcItem);
	
	-- add bind to spec zhenyuan
	local bBind = pDestItem.IsBind() + pSrcItem.IsBind();
	local nSpecBind = 0;
	if self:GetParam1(pDestItem) ~= 0 or self:GetParam1(pSrcItem) ~= 0 then
		nSpecBind = 1;
	end
	
	local nRes, varMsg, nRightLevel, nLeftRate, nRightRate, nBalanceValue = self:CalcRefineInfo(pDestItem, pSrcItem, nAttriId);
	if nRes ~= 1 then
		me.Msg(varMsg);
		return 0;
	end
	
	local nLeftLevel = varMsg;
	if bSure == 0 then
		--[[
		-- 炼化结果超过1.5星的话，给玩家一个确认提示框
		if nLeftLevel == self.REFINE_MAXLEVELUP and nBalanceValue > 0 or
		   	nLeftLevel > self.REFINE_MAXLEVELUP then
	   		
	   		local szMsg = string.format("您的副真元总价值量较高！但主真元的%s资质提升不能超过%s！\n您确定要将%s作为副真元炼化吗？",
				pDestItem.GetBaseAttrib()[nDestAttribIndex], "1.5星", pSrcItem.szName);
			local tbOpt = 
			{
				{"Xác nhận", self.Refine, self, pDestItem, pSrcItem, nAttriId, 1},
				{"取消"},
			}
			Dialog:Say(szMsg, tbOpt);
			return;
	   	end]]--
	end
	
	-- 随机，判断取上限还是取下限
	local nStarLevelAdded = 0;
	local nRandom = MathRandom(1,100);
	if nRandom > nLeftRate then
		nStarLevelAdded = nRightLevel;
	else
		nStarLevelAdded = nLeftLevel;
	end
	
	-- 将主真元降等级，删除用来炼化的真元，删除之前记录相关数据，记LOG需要
	local szSrcName = pSrcItem.szName;
	local szSrcGuid = pSrcItem.szGUID;
	local nSrcAttribStar = self["GetAttribPotential"..self:GetAttribIndex(pSrcItem, nAttriId)](self, pSrcItem);
	local nSrcLevel = self:GetLevel(pSrcItem);
	local bSrcRank = self:GetRank(pSrcItem);
	local nSrcLadderId = self:GetLadderId(pSrcItem);
	-- 扣钱失败或删除失败，则炼化失败
	if (me.CostMoney(self.REFINE_COST_COUNT, Player.emKPAY_ZHENYUAN_REFINE) ~= 1 or me.DelItem(pSrcItem) ~= 1) then
		return 0;
	end
	
	-- 全局服不应用GUID榜相关操作
	if bSrcRank ~= 0 and IsGlobalServer() == false then
		Ladder.tbGuidLadder:ApplyChangeValue(nSrcLadderId, szSrcGuid, me.szName, -1);
	end
	
	-- 修改属性资质的等级
	local nDestAttribIndex = self:GetAttribIndex(pDestItem, nAttriId);
	local szFun = "GetAttribPotential"..nDestAttribIndex;
	local nOrgStarLevel = self[szFun](self, pDestItem);	-- 被炼化真元的指定属性的属性资质等级
	
	szFun = "SetAttribPotential"..nDestAttribIndex;
	self[szFun](self, pDestItem, nOrgStarLevel + nStarLevelAdded);

	-- 随机降等级
	if (nSpecBind ~= 1) then
		local nRandom = MathRandom(self.LEVELDOWN_MINLEVEL, self.LEVELDOWN_MAXLEVEL);
		self:SetLevel(pDestItem, nRandom);
	end
	
	-- 重新生成，计算相关属性
	pDestItem.Regenerate(pDestItem.nGenre, pDestItem.nDetail, pDestItem.nParticular, pDestItem.nLevel, 
		pDestItem.nSeries, pDestItem.nEnhTimes, pDestItem.nLucky, pDestItem.GetGenInfo(), 
		pDestItem.nVersion, pDestItem.dwRandSeed, pDestItem.nStrengthen);
	pDestItem.Bind(bBind);
	
	-- 炼化之后，价值量发生了变化，需要修改排行榜数据
	-- 全局服不就算GUID榜相关操作
	if (IsGlobalServer() == false) then
		if (nSpecBind == 1 and self:GetEquiped(pDestItem) ~= 1 and self:GetRank(pDestItem) ~= 0) then
			Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(pDestItem), pDestItem.szGUID, me.szName, -1);
		elseif (nSpecBind ~= 1 or self:GetEquiped(pDestItem) == 1) then
			Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(pDestItem), pDestItem.szGUID, me.szName, self:GetZhenYuanValue(pDestItem)/10000);
		end
	end
	
	-- 如果玩家真元炼化任务，则记录任务变量。
	self:CheckTaskStep(self.TASKSTEP_REFINE);
	
	-- 内存计数变量
	self.nCount_Refine_All = self.nCount_Refine_All + 1;
	local nDayTime = Lib:GetLocalDay(GetTime());
	if nDayTime ~= self.nLastDayTime then
		self.nLastDayTime = nDayTime;
		self.nCount_Refine_Today = 1;
		self.nCount_FullLevel_Today = 0;
	else
		self.nCount_Refine_Today = self.nCount_Refine_Today + 1;
	end
		
	if nStarLevelAdded > 0 then
		me.Msg(string.format("Chúc mừng! Luyện hóa %s thành công! %s tăng %0.1f sao! Cấp độ giảm %d cấp.", pDestItem.szName, 
			self:GetAttribTipName(pDestItem.GetBaseAttrib()[nDestAttribIndex].szName),	
			nStarLevelAdded/2, nRandom));
		me.Msg(string.format("%s luyện hóa thành công!", szSrcName));
		
		StatLog:WriteStatLog("stat_info", "zhenyuan", "zhenyuanlianhua", me.nId,
			string.format("%s,%s,%d,%d,%s,%s,%d,%d", pDestItem.szName, pDestItem.szGUID, 
				nAttriId, nOrgStarLevel, szSrcName, szSrcGuid, nSrcAttribStar, nSrcLevel));
		
		local tbBaseAttrib = pDestItem.GetBaseAttrib();
		local tbAttribEnhanced = Item.tbZhenYuan:GetAttribEnhanced(pDestItem, 0);
		local tbAttrib = {};
		for i = 1, self.ATTRIB_COUNT do
			-- 加0.5做四舍五入运算
			tbAttrib[i] = self["GetAttrib"..i.."Range"](self, pDestItem) + 
				math.floor(self:GetAttribMapValue(tbBaseAttrib[i].szName, tbAttribEnhanced[i]) + 0.5);
		end
		
		StatLog:WriteStatLog("stat_info", "zhenyuan", "zhenyuanlianhuaresult", me.nId,
			string.format("%s,%s,%d,%1.0f,%d,%d,%d,%d,%d,%d,%d,%d", pDestItem.szName, pDestItem.szGUID, 
				self:GetLevel(pDestItem), self:GetZhenYuanValue(pDestItem),
				self:GetAttribPotential1(pDestItem), tbAttrib[1],
				self:GetAttribPotential2(pDestItem), tbAttrib[2],
				self:GetAttribPotential3(pDestItem), tbAttrib[3],
				self:GetAttribPotential4(pDestItem), tbAttrib[4]));

		
		-- 记录炼化次数
		local nTimes = me.GetTask(self.LOG_TASK_MAIN, self.LOG_TASK_REFINECOUNT);
		me.SetTask(self.LOG_TASK_MAIN, self.LOG_TASK_REFINECOUNT, nTimes + 1);
		
		-- bind
		if nSpecBind == 1 then
			self:SetParam1(pDestItem, 1);
			pDestItem.Bind(1);
		end
		
		Dbg:WriteLog("真元系统", me.szName, "真元炼化护体情况", 
			string.format("炼化前[pDestItem(%s_%s):%d, pSrcItem(%s_%s):%d],炼化后[pDestItem(%s_%s):%d]", 
				pDestItem.szName, pDestItem.szGUID, bDeseEquiped, szSrcName, szSrcGuid, bSrcEquiped,
				pDestItem.szName, pDestItem.szGUID, self:GetEquiped(pDestItem))
			);		
		
		return 1;
	else
		return 0;
	end
end

-- 检查是否在指定任务的指定步骤
function tbZhenYuan:CheckTaskStep(nStep)	
	local nTaskMainId = tonumber(self.TASK_MAINID, 16);
	local nTaskSubId = tonumber(self.TASK_SUBID, 16);
	
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	local tbTask = tbPlayerTasks[nTaskMainId];	-- 主任务ID
	
	if tbTask and tbTask.nReferId == nTaskSubId then
		if (tbPlayerTasks[nTaskMainId].nCurStep == nStep) and self.tbTaskValue[nStep] then
			me.SetTask(self.tbTaskValue[nStep][1], self.tbTaskValue[nStep][2], 1);
		end
	end
end

-- 客户端申请使用累积的历练经验
-- nType:1表示加+1级，2表示+10级，3表示全部
function tbZhenYuan:OnClientUseLilianExp(dwId, nType)
	local szMsg = string.format("Hãy đặt <color=green>1~%d<color> Chân Nguyên vào. <enter><enter>Lưu ý: Kinh nghiệm thăng cấp 1 Chân Nguyên sẽ chia sẻ cho những Chân Nguyên còn lại! Vì vậy <color=green>hãy đặt cùng lúc %d Chân Nguyên<color>", self.LILIAN_MAX_COUNT, self.LILIAN_MAX_COUNT);
	Dialog:OpenGift(szMsg, {"Item.tbZhenYuan:LiLianCheck"}, {self.UseLiLianOK, self});
	
	if true then
		return;
	end
	
	-- 原来历练经验的使用方式，暂时关闭
	if not self.bOpen or self.bOpen ~= 1 then
		return;
	end
	
	if (me.IsAccountLock() == 1) then
		me.Msg("Tài khoản đang khóa, không thể thao tác!");
		return 0;
	end
	
	local pItem = KItem.GetObjById(dwId);
	local nLiLianTime = me.GetTask(Item.tbZhenYuan.EXPSTORE_TASK_MAIN, Item.tbZhenYuan.EXPSTORE_TASK_SUB);
	if not pItem or nLiLianTime <= 0 then
		return;
	end
	
	-- 先判断累积的经验能否满足请求
	local nCanLevelUp = self:CalExpFromTime(pItem, nLiLianTime);
	local nApplyLevelUp = (nType == 1 and 1) or (nType == 2 and 10) or 0;
	if nCanLevelUp < nApplyLevelUp then
		return;
	end
	
	-- 能够满足需求，做相应的应用
	local nNeedTime = (nApplyLevelUp == 0 and nLiLianTime) or 0;
	local nOrgLevel = self:GetLevel(pItem);
	local nLevelUp = 0;
	while nApplyLevelUp > nLevelUp do
		local nNeedExp = self:GetNeedExp(nOrgLevel + nLevelUp);
		local nBaseExp = Item.tbZhenYuanSetting.tbLevelSetting[nOrgLevel + nLevelUp].nBaseExpPerMin;
		nNeedTime = nNeedTime + math.ceil(nNeedExp/nBaseExp);
		nLevelUp = nLevelUp + 1;
	end
	
	-- 如果是全部使用的话，先将数据清0，再将剩余的记录
	nLiLianTime = nLiLianTime - nNeedTime;
	me.SetTask(Item.tbZhenYuan.EXPSTORE_TASK_MAIN, Item.tbZhenYuan.EXPSTORE_TASK_SUB, nLiLianTime);
	self:AddExp(pItem, nNeedTime);	

	me.CallClientScript({"Item.tbZhenYuan:NotifyLiLianResult"});
end
RegC2SFun("ApplyUseLilianTime", Item.tbZhenYuan.OnClientUseLilianExp);

-- 真元交易回调，交易，邮件，摆摊贩卖，摆摊购买，回购都会被当做是交易
function tbZhenYuan:OnZhenYuanTrade()
	-- 全局服不应用GUID榜相关操作
	if IsGlobalServer() or (self:GetParam1(it) == 1 and self:GetEquiped(it) ~= 1) then
		return;
	end
	
	Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(it), it.szGUID, me.szName, self:GetZhenYuanValue(it)/10000);
end

function tbZhenYuan:OnSellZhenYuan()
	-- 全局服不应用GUID榜相关操作
	if (IsGlobalServer() == false and self:GetRank(it) ~= 0) then
		Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(it), it.szGUID, me.szName, -1);
	end
end

-- 刷新某个guid的真元信息，如果guid为nil则刷新玩家所有真元
function tbZhenYuan:UpdateLadderInfo(pPlayer, szGUID)
	if not self.bOpen or self.bOpen ~= 1 or not pPlayer or IsGlobalServer() then
		return;
	end

	local tbFind = {};
	tbFind = pPlayer.FindClassItemOnPlayer("zhenyuan");		-- 背包，仓库
	Lib:MergeTable(tbFind, pPlayer.FindClassItem(Item.ROOM_EQUIP, "zhenyuan"));	-- 装备栏
	
	if not tbFind or tbFind == {} then
		return;
	end
	
	for _, tbFind in pairs(tbFind) do
		if szGUID == nil or tbFind.pItem.szGUID == szGUID then
			local nRank = Ladder.tbGuidLadder:FindByGuid(self:GetLadderId(tbFind.pItem), tbFind.pItem.szGUID);
			-- 排行榜返回的排名是从0开始的，要加1
			if nRank >= 1000 then
				nRank = -1;
			end
			self:SetRank(tbFind.pItem, nRank + 1);
			if szGUID then
				return;
			end
		end
	end
end

-- 上线设置所有真元的信息，使未上榜的上榜
function tbZhenYuan:UpdateAllZhenYuanRank(pPlayer)
	if not self.bOpen or self.bOpen ~= 1 then
		return;
	end
	
	if not pPlayer then
		return;
	end
	
	-- 全局服不应用GUID榜，真元的排名是读取任务变量的
	if IsGlobalServer() then
		local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHENYUAN_MAIN);
		if pItem then
			local nRank = pPlayer.GetTask(Player.tbFightPower.TASK_GROUP, Player.tbFightPower.TASK_ZHENYUAN_RANK[1]);
			if nRank >= 1000 then
				nRank = -1;
			end
			self:SetRank(pItem, nRank);
		end	
		
		return;
	end

	local tbFind = {};

	tbFind = pPlayer.FindClassItemOnPlayer("zhenyuan");		-- 背包，仓库
	Lib:MergeTable(tbFind, pPlayer.FindClassItem(Item.ROOM_EQUIP, "zhenyuan"));	-- 装备栏
	
	if not tbFind or tbFind == {} then
		return;
	end
	
	for _, tbFind in pairs(tbFind) do
		-- 查询排行榜信息，没入榜的排名为-1
		local nRank = Ladder.tbGuidLadder:FindByGuid(self:GetLadderId(tbFind.pItem), tbFind.pItem.szGUID);
		-- 如果没上榜，且不是未护体的内部真元，就执行上榜
		if nRank == -1 and not (self:GetParam1(tbFind.pItem) == 1 and Item.tbZhenYuan:GetEquiped(tbFind.pItem) == 0) then
			local nValue = math.floor(self:GetZhenYuanValue(tbFind.pItem) / 10000);
			Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(tbFind.pItem), tbFind.pItem.szGUID, pPlayer.szName, nValue);
		end
		if nRank >= 1000 then
			nRank = -1;
		end
		self:SetRank(tbFind.pItem, nRank + 1);
	end
	self:SafeguardLadder(tbFind);
end

function tbZhenYuan:OnLogin(bIsChangeServer)
	if bIsChangeServer == 0 then
		me.CallClientScript({"Item.tbZhenYuan:SwitchState", self.bOpen});
		self:UpdateAllZhenYuanRank(me);
	end
end

if tbZhenYuan.nStartId then
	PlayerEvent:UnRegisterGlobal("OnLogin", tbZhenYuan.nStartId);
	tbZhenYuan.nStartId = nil;
end
tbZhenYuan.nStartId = PlayerEvent:RegisterGlobal("OnLogin", Item.tbZhenYuan.OnLogin, Item.tbZhenYuan);

-- 切换绑定类型
function tbZhenYuan:SwitchBind(nPlayerId, nOpType)
	Item:SwitchBindGift_Trigger(nPlayerId, nOpType, Item.SWITCHBIND_ZHENYUAN);
end
RegC2SFun("SwitchBind", Item.tbZhenYuan.SwitchBind);

-- 申请或取消解绑申请
function tbZhenYuan:PlayerApplyUnBind(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	if pPlayer.IsAccountLock() == 1 then
		pPlayer.Msg("Tài khoản khóa, không thể thao tác!");
		return;
	end
	if Account:Account2CheckIsUse(pPlayer, 6) == 0 then
		pPlayer.Msg("Đang đăng nhập bằng mật mã phụ, không thể thao tác!");
		return 0;
	end	
	local nApplyTime = pPlayer.GetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND);
	-- 是申请解绑
	if nApplyTime == 0 or GetTime() - nApplyTime < 0 or GetTime() - nApplyTime > self.UNBIND_MAX_TIME then
		pPlayer.SetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND, GetTime());
		pPlayer.AddSkillState(self.UNBIND_BUFF_SKILLID, 1, 1, self.UNBIND_MAX_TIME * Env.GAME_FPS, 1, 0, 1);
		Dbg:WriteLog("UnBindZhenYuan", "Nhân vật: "..pPlayer.szName, "Tài khoản: "..pPlayer.szAccount, "Xin hủy mở khóa Chân Nguyên");
		pPlayer.Msg("Đã xin mở khóa Chân Nguyên!");
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "Mở khóa Chân Nguyên");
		pPlayer.CallClientScript({"Item.tbZhenYuan:UpdateHelpPage"});
	else	-- 是取消申请
		local szMsg = "";
		if GetTime() - nApplyTime < self.UNBIND_MIN_TIME then
			szMsg = string.format("Sau %0.1f giờ có thể mở khóa Chân Nguyên. Bạn muốn hủy mở khóa chứ?", 
				(self.UNBIND_MIN_TIME - GetTime() + nApplyTime)/3600);
		else
			szMsg = "Đã có thể mở khóa Chân Nguyên. Bạn chắc chắn hủy mở khóa Chân Nguyên?";
		end
	
		local tbOpt = 
		{
			{"Hủy mở khóa", Item.tbZhenYuan.CancelUnBind, Item.tbZhenYuan, nPlayerId},
			{"Để ta suy nghĩ thêm"},
		}
		Dialog:Say(szMsg, tbOpt);
	end
end
RegC2SFun("ApplyUnBind", Item.tbZhenYuan.PlayerApplyUnBind);

function tbZhenYuan:CancelUnBind()
	local pPlayer = me or KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	pPlayer.SetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND, 0);
	pPlayer.RemoveSkillState(self.UNBIND_BUFF_SKILLID);
	
	Dbg:WriteLog("UnBindZhenYuan", "Nhân vật: "..pPlayer.szName, "Tài khoản: "..pPlayer.szAccount, "取消了真元解绑申请");
	pPlayer.Msg("Hủy mở khóa Chân Nguyên thành công.");
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "撤消真元解绑申请");
	pPlayer.CallClientScript({"Item.tbZhenYuan:UpdateHelpPage"});
end

function tbZhenYuan:PostUnBind(nCount)
	me.SetTask(self.TASK_GID_UNBIND, self.TASK_SUBID_UNBIND, 0);
	me.RemoveSkillState(self.UNBIND_BUFF_SKILLID);
	
	Dbg:WriteLog("UnBindZhenYuan", "Nhân vật: "..me.szName, "Tài khoản: "..me.szAccount, "成功解绑了"..nCount.."个真元");
	me.Msg(string.format("Mở khóa thành công %s Chân Nguyên", nCount));
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("解绑%s个真元。", nCount));
	me.CallClientScript({"Item.tbZhenYuan:UpdateHelpPage"});
end

-- 这里检查要放入的道具是否是装备着的真元，如果是，不能放入
function tbZhenYuan:SwitchBind_Check(pDropItem)
	if (self:GetParam1(pDropItem) == 1) then
		return 0;
	end
	if pDropItem then
		for i = Item.EQUIPPOS_ZHENYUAN_MAIN, Item.EQUIPPOS_ZHENYUAN_SUB2 do
			local pItem = me.GetItem(Item.ROOM_EQUIP, i, 0);
			if pItem and pItem.dwId == pDropItem.dwId then
				me.Msg("Trang bị không thể khóa!");
				return 0;
			end
		end
	end
	return 1;
end

function tbZhenYuan:UseLiLianOK(tbItemObj)
	local nItemCount = Lib:CountTB(tbItemObj);
	if nItemCount > self.LILIAN_MAX_COUNT or nItemCount <= 0 then
		me.Msg("Sai số lượng!");
		return;
	end

	local nLiLianTime = me.GetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_SUB);
	if nLiLianTime <= 0 then
		me.Msg("Không đủ kinh nghiệm!");
		return;
	end

	local nLiLianUsed = 0;	
	-- 先遍历一遍，计算该次应该要使用的历练经验
	for i, tbItem in pairs(tbItemObj) do
		local pItem = tbItem[1];
		if pItem and pItem.IsZhenYuan() == 1 then
			local _, _, nTemp = self:CalExpFromTime(pItem, nLiLianTime);
			if nTemp < nLiLianUsed or nLiLianUsed == 0 then
				nLiLianUsed = nTemp;
			end
		end
	end	
	
	if nLiLianUsed <= 0 then
		return;
	end		

	-- 再遍历一次，给每个道具添加历练经验
	for i, tbItem in pairs(tbItemObj) do
		local pItem = tbItem[1];
		if pItem and pItem.IsZhenYuan() == 1 then
			self:AddExp(pItem, nLiLianUsed);
		end	
	end
	
	nLiLianTime = nLiLianTime - nLiLianUsed;
	me.SetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_SUB, nLiLianTime);	
end

-- 维护排行榜
function tbZhenYuan:SafeguardLadder(tbResult)
	-- 全局服不应用真元榜
	if (IsGlobalServer()) then
		return;
	end
	
	local nLastCheckTime = me.GetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_GUARD);
	local nTimeSpan = 3600 * 24 * 7; -- 每周维护一次
	local nNowTime = GetTime();
	if nNowTime - nLastCheckTime < nTimeSpan then
		return;
	end
	me.SetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_GUARD, nNowTime);
	local nCount = GuidLadder_GetValueCount(me.nId);
	local tbGuid = {};
	local nZhenYuanInLadder = 0;
	for _, tbFind in pairs(tbResult) do
		local nRank = self:GetRank(tbFind.pItem);
		if nRank > 0 then
			tbGuid[tbFind.pItem.szGUID] = 1;
			nZhenYuanInLadder = nZhenYuanInLadder + 1;
		end
	end
	--榜上的值比上榜的真元个数小，没问题，不检查了
	--print("上榜个数", nCount, "真元个数", nZhenYuanInLadder);
	if (nCount <= nZhenYuanInLadder) then
		return;
	end
	self:CheckPlayerZhenYuanInLadder(tbGuid);
end

function tbZhenYuan:CheckPlayerZhenYuanInLadder(tbGuid)
	local nZhenYuanKindCount = 7;
	local nRank, nValue, szGuid = 0;
	local nRepeatCount = 0;
	for nLadderId = 1, nZhenYuanKindCount do
		nRank = 0;
		nRepeatCount = 0;
		repeat
			nRepeatCount = nRepeatCount + 1;
			nRank, nValue, szGuid = GuidLadder_FindByName(nLadderId, nRank, me.szName);
			-- 排行榜上有，身上没有，要清理掉
			if nRank then
				nRank = nRank + 1;
				if not tbGuid[szGuid] then
					Ladder.tbGuidLadder:ApplyChangeValue(nLadderId, szGuid, me.szName, -1);
				end
			end
			-- 防止死循环，一个玩家身上不会有255个真元吧？！
			if nRepeatCount > 255 then
				print("CheckZhenYuanTimeout", nLadderId, nRank, me.szName);
				break;
			end
		until (not nRank);
	end
end


------------------------------------------------------------------------------------
local tbItem = Item:GetClass("partnerexpbook2");

function tbItem:OnUse()
	local pItem = me.GetItem(2, 0, 0);
	if not pItem then
		me.Msg("Hãy đặt Chân nguyên chính có thể thăng cấp vào ô đầu tiên trong Hành trang。");
		return 0;
	end
	if pItem.IsZhenYuan() ~= 1 then
		me.Msg("Hãy đặt Chân nguyên chính có thể thăng cấp vào ô đầu tiên trong Hành trang。");
		return 0;
	end
	local bParam1 = Item.tbZhenYuan:GetParam1(pItem);
	if bParam1 ~= 1 then
		me.Msg("Hãy đặt Chân nguyên chính có thể thăng cấp vào ô đầu tiên trong Hành trang。");
		return 0;
	end
	if Item.tbZhenYuan:GetLevel(pItem) == 120 then
		me.Msg("Chân nguyên đã đạt cấp tối đa.");
		return 0;
	end
	Item.tbZhenYuan:SetLevel(pItem, 120);
	if (it.nCount == 1) then
		return 1;
	else
		it.SetCount(it.nCount - 1);
		return 0;
	end
end

end  -- if MODULE_GAMESERVER then