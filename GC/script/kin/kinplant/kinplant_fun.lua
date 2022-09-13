-- 文件名　：kinplant_fun.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-12-05 14:40:06
-- 功能    ：

Require("\\script\\kin\\kinplant\\kinplant_def.lua");

if MODULE_GAMESERVER then
--获取数id和生存时间
function KinPlant:GetTempNpcInFo(nIndex, nTreeIndex)
	if nIndex and nTreeIndex and self.tbPlantNpcInfo[nIndex] and self.tbPlantNpcInfo[nIndex].tbTempNpcId[nTreeIndex] and 
		self.tbPlantNpcInfo[nIndex].tbTime[nTreeIndex] then
		if #self.tbPlantNpcInfo[nIndex].tbTempNpcId == nTreeIndex then
			return self.tbPlantNpcInfo[nIndex].tbTempNpcId[nTreeIndex], self.tbPlantNpcInfo[nIndex].tbTime[nTreeIndex], 1;
		else
			return self.tbPlantNpcInfo[nIndex].tbTempNpcId[nTreeIndex], self.tbPlantNpcInfo[nIndex].tbTime[nTreeIndex];
		end
	end
	return self.nTempNpcId, 0;
end

--每个人可偷的次数
function KinPlant:GetPerGetFruit(nIndex)
	if nIndex and self.tbPlantNpcInfo[nIndex] then 
		return self.tbPlantNpcInfo[nIndex].nPerGetOther;
	end
	return 0;
end

--当天最小值
function KinPlant:GetMinAwardCount(nTime, nIndex)
	local nTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d", nTime)));
	local nNowTime = Lib:GetDate2Time(GetLocalDate("%Y%m%d"));
	local nDay = math.max(math.floor((nNowTime - nTime)/24/3600), 0);
	local nMaxAwardCount = 100;
	if nIndex and self.tbPlantNpcInfo[nIndex] then
		local nDayMax =  self.tbPlantNpcInfo[nIndex].nMaxGetOther * (nDay + 1);
		nMaxAwardCount = self.tbPlantNpcInfo[nIndex].nMaxAwardCount;
		return math.max(nMaxAwardCount - nDayMax, 0);
	end
	return nMaxAwardCount;
end

--获取当前天气状况（0正常，1烈日，2下雨，3下雪）
function KinPlant:GetWeatherType(nMapId)
	if not nMapId then
		return 0;
	end
	return GetWorldWeather(nMapId);
end

--按一定规则随即健康度
function KinPlant:GetRandHeath()
	local nRate = MathRandom(100000);
	for i, tb in ipairs(self.tbChangRate) do
		if nRate < tb[1] then
			return i, tb[2];			
		end
	end
	return 0, 0;
end

--加专精等级
function KinPlant:AddRepute(pPlayer, nIndex, nGrade)
	if not self.tbPlantNpcInfo[nIndex] then
		return;
	end
	local cKin = KKin.GetKin(pPlayer.dwKinId);
	if not cKin then
		return 0
	end
	local tbRepute = self.tbPlantNpcInfo[nIndex].tbExp;
	local tbGrade = self.tbPlantNpcInfo[nIndex].tbGrade;
	if not tbRepute or not nGrade or nGrade <= 0 then
		return 0;
	end
	
	--加专精
	local nDecType = 0;		--降低的类型
	local nMaxCount = 0;	--减低的类型中的较大数值
	local nTotalCount = 0;	--总累积值
	local nFlag = nil;
	for i, nExp in ipairs(tbRepute) do
		local nCount = (self.tbMyRepute[me.GetReputeLevel(14, i)] or 0) + me.GetReputeValue(14, i);
		nTotalCount = nTotalCount + nCount;
		if nExp > 0 and tbGrade[i] == me.GetReputeLevel(14, i) then	--数值为正数，且当前专精等级和植物要求一直
			me.AddRepute(14, i, nGrade);
			nFlag = 1;
		elseif nExp < 0 then
			if nCount > nMaxCount then
				nMaxCount = nCount;
				nDecType = i;
			end
		end
	end
	--都没有符合的专精等级
	if nFlag then
		--减专精
		local nDecCount = MathRandom(math.floor(nGrade * nTotalCount / 2700));
		me.AddRepute(14, nDecType, -nDecCount);
	end
	local nMaxKinExp = self:GetMaxKinExp();
	GCExcute{"KinPlant:AddSkillExp", pPlayer.dwKinId, math.min(nGrade, nMaxKinExp - cKin.GetPlantExp()), nFlag};

	--成就
	for i =1, 3 do
		if me.GetReputeLevel(14, i) >= 2 then
			Achievement:FinishAchievement(pPlayer, 440 + 3 *( i - 1));	--耕者有其田440种瓜得瓜443姹紫嫣红446
		end
		if me.GetReputeLevel(14, i) >= 3 then
			Achievement:FinishAchievement(pPlayer, 441 + 3 *( i - 1));
		end
		if me.GetReputeLevel(14, i) >= 5 then
			Achievement:FinishAchievement(pPlayer, 442 + 3 *( i - 1));
		end
	end
end

--获取玩家种树的颗数,清理坑位
function KinPlant:GetTask(pPlayer)
	if not pPlayer then
		return self.nMaxPlantCount;
	end
	local nCount = 0;
	for i , nTaskId in ipairs(self.tbPlantTask) do
		local nNum = pPlayer.GetTask(self.TASKGID, nTaskId);
		local tbInfo = self.tbPlantInfo[pPlayer.dwKinId];
		if tbInfo and tbInfo[nNum] and tbInfo[nNum][1] == pPlayer.szName then
			nCount = nCount + 1;
		else
			pPlayer.SetTask(self.TASKGID, nTaskId, 0);
		end
	end	
	return nCount;
end

--设置玩家种植的坑
function KinPlant:AddTask(nNum, pPlayer)
	if not pPlayer or self:GetTask(pPlayer) >= self.nMaxPlantCount then
		return 0;
	end
	for i , nTaskId in ipairs(self.tbPlantTask) do
		local nNumEx = pPlayer.GetTask(self.TASKGID, nTaskId);
		if nNumEx == 0 then
			pPlayer.SetTask(self.TASKGID, nTaskId, nNum);
			break;
		end
	end
end

--获得对应的果实gdpl
function KinPlant:GetFruitItem(nIndex)
	if not self.tbPlantNpcInfo[nIndex] then
		return;
	end	
	local szFruitItem = self.tbPlantNpcInfo[nIndex].szFruitItem;
	local tbFruit = Lib:SplitStr(szFruitItem);
	tbFruit = {tonumber(tbFruit[1]), tonumber(tbFruit[2]), tonumber(tbFruit[3]), tonumber(tbFruit[4])};
	if #tbFruit ~= 4 then
		return;
	end
	return tbFruit;
end

--获取最大产量
function KinPlant:GetMaxAwardCount(nIndex)
	if not self.tbPlantNpcInfo[nIndex] then
		return 0;
	end
	return self.tbPlantNpcInfo[nIndex].nMaxAwardCount or 0;
end

--获得天气加成
function KinPlant:GetWeatherRate(nIndex, nType)
	if not self.tbPlantNpcInfo[nIndex] then
		return 0;
	end
	local tbWeather = self.tbPlantNpcInfo[nIndex].tbWeather;
	if tbWeather[nType] then
		return tbWeather[nType];
	end
	return 0;
end

--获得家族技能加成
function KinPlant:GetKinRate(dwKinId)
	local cKin = KKin.GetKin(dwKinId)
	if not cKin then
		return 1;
	end
	local nSkillLevel = self:GetSkillLevel(cKin.GetPlantExp());
	return self.tbPlantKinRate[nSkillLevel] or 0;
end

--获得家族技能最大经验值
function KinPlant:GetMaxKinExp()
	local nMaxExp = 0;
	for nLevel, nExp in pairs(self.tbPlantLevel) do
		if nExp > nMaxExp then
			nMaxExp = nExp;
		end
	end
	return nMaxExp;
end

--获得家族技能的当前等级
function KinPlant:GetSkillLevel(nSkillExp)
	local nSkillLevel = 0;
	local nMaxExp = 0;
	for nLevel, nExp in pairs(self.tbPlantLevel) do
		if nExp >= nSkillExp then
			if nMaxExp == 0 then
				nSkillLevel = nLevel;
				nMaxExp = nExp;
			elseif nMaxExp > nExp then
				nSkillLevel = nLevel;
				nMaxExp = nExp;
			end
		end
	end
	return nSkillLevel;
end

--根据果实类型数量获得奖励{[szItem] = nCount}例如：{[果实]=10}
function KinPlant:ChangeFruit(tbCount, nTimes)
	local tbValueTotal = {0, 0, 0};
	local tbTypeCount = {0, 0, 0};
	--计算三种类型价值量
	for szItem, nCountEx in pairs(tbCount) do
		local tbValue, nType = self:CalcValue(szItem, nCountEx);
		tbValueTotal[1] = tbValueTotal[1] + tbValue[1];
		tbValueTotal[2] = tbValueTotal[2] + tbValue[2];
		tbValueTotal[3] = tbValueTotal[3] + tbValue[3];
		tbTypeCount[nType] = tbTypeCount[nType] + nCountEx;
	end
	if nTimes and nTimes > 0 then
		tbValueTotal[1] = tbValueTotal[1] * nTimes;
		tbValueTotal[2] = tbValueTotal[2] * nTimes;
		tbValueTotal[3] = tbValueTotal[3] * nTimes;
	end
	--根据三种价值量计算，三种奖励
	local tbAward = self:CalcAward(tbValueTotal);
	--经验
	if tbAward[1] > 0 then
		me.AddExp(math.floor(me.GetBaseAwardExp() * tbAward[1]));
	end
	--玄晶
	if tbAward[2] then
		for nLevel, vCount in pairs(tbAward[2]) do
			if type(vCount) ~= "table" then
				me.AddStackItem(18,1,114, nLevel, nil, vCount);
			else
				local nRate = MathRandom(100);
				for nLevel, tbRateEx in pairs(vCount) do
					if tbRateEx[1] < nRate and nRate <= tbRateEx[2] then
						me.AddItem(18,1,114, nLevel);
					end
				end
			end
		end
	end
	--绑银
	if tbAward[3] > 0 then
		me.AddBindMoney(tbAward[3]);
	end
	--没有倍数即：正常上交记log
	if not nTimes then
		StatLog:WriteStatLog("stat_info", "homeland", "exchange", me.nId, tbTypeCount[1], tbTypeCount[2], tbTypeCount[3]);
	end
end

--根据果实类型数量获得奖励需要的包裹数量{[szItem] = nCount}例如：{[果实]=10}
function KinPlant:GetChangeFNeedBag(tbCount)
	local tbValueTotal = {0, 0, 0};
	for szItem, nCountEx in pairs(tbCount) do
		local tbValue = self:CalcValue(szItem, nCountEx);
		tbValueTotal[1] = tbValueTotal[1] + tbValue[1];
		tbValueTotal[2] = tbValueTotal[2] + tbValue[2];
		tbValueTotal[3] = tbValueTotal[3] + tbValue[3];
	end
	local tbAward = self:CalcAward(tbValueTotal);
	local nTotalCount = 0;
	--玄晶
	if tbAward[2] then
		for nLevel, vCount in pairs(tbAward[2]) do
			if type(vCount) ~= "table" then
				nTotalCount = nTotalCount + vCount;
			else
				nTotalCount = nTotalCount + 1;
			end
		end
	end
	return nTotalCount, tbAward;
end

--计算价值量
function KinPlant:CalcValue(szItem, nCount)
	if not self.tbPlantFruit[szItem] then
		return {0,0,0};
	end
	local tbPlantInfo = self.tbPlantNpcInfo[self.tbPlantFruit[szItem].nId];
	local nType = tbPlantInfo.nType;
	local nValue = self.nPreValue * self:GetTimeFrame() * nCount;	--总的价值量=每个道具*时间轴翻倍*总的个数
	return {nValue * self.tbValueType[nType][1] or 1, nValue * self.tbValueType[nType][2] or 1, nValue * self.tbValueType[nType][3] or 1}, nType;
end

--通过时间轴获取翻倍处理
function KinPlant:GetTimeFrame()
	local nDay = TimeFrame:GetServerOpenDay();
	for i, tb in ipairs(self.tbTimerFrame) do
		if (nDay <= tb[1]) or (nDay >= tb[1] and not self.tbTimerFrame[i+1]) then	--小于100天或者大于1200天的，都取最边上的值
			return  tb[2];
		elseif nDay > tb[1] and nDay <= self.tbTimerFrame[i+1][1] then
			return Lib.Calc:Link(nDay, {tb, self.tbTimerFrame[i+1]});
		end
	end
	return 1;
end

function KinPlant:CalcAward(tbValue)
	local nXuanjing = tbValue[2] * self.tbAward[2] / 10000;	--总玄晶价值量
	local tbXuanjing = {};
	--超过12玄的取出是几个12玄，其他的做概率处理
	if nXuanjing > self.tbXuanJingValue[8] then
		tbXuanjing[8] = math.floor(nXuanjing / self.tbXuanJingValue[8]);
		nXuanjing = math.fmod(nXuanjing ,self.tbXuanJingValue[8]);
	end
	for i, nValue in ipairs(self.tbXuanJingValue) do
		if nXuanjing >= nValue and nXuanjing < self.tbXuanJingValue[i + 1] then
			local nRate = math.floor((self.tbXuanJingValue[i + 1] - nXuanjing) / (self.tbXuanJingValue[i + 1] - self.tbXuanJingValue[i]) * 100);
			tbXuanjing[13] = {[i] = {0, nRate}, [i + 1] = {nRate, 100}};
		end
	end
	return {math.floor(tbValue[1] * self.tbAward[1] / 10000), tbXuanjing, math.floor(tbValue[3] * self.tbAward[3] / 10000)};
end
end

--增加家族种植技能经验
function KinPlant:AddSkillExp(dwKinId, nExp, nFlag)
	local cKin = KKin.GetKin(dwKinId)
	if not cKin then
		return 0;
	end
	if nExp > 0 and nFlag then
		cKin.AddPlantExp(nExp);
	end	
	local nNowWeek = tonumber(GetLocalDate("%W"));
	local nFlagEx = math.fmod(cKin.GetHandInCount() , 10);
	local nWeek = math.floor(math.fmod(cKin.GetHandInCount(), 1000) / 10);
	local nCount = math.floor(cKin.GetHandInCount() / 1000);
	if nNowWeek ~= nWeek then
		nCount = 0;
		nFlagEx = 0;
	end
	local nNum = (nCount + 1) * 1000 + nNowWeek *10 + nFlagEx;
	cKin.SetHandInCount(nNum);
	if  MODULE_GC_SERVER then
		if nCount + 1 == self.nKinMaxTreeWeekly then
			WriteStatLog_GC("stat_info", "spe_tree", "tree_quali", string.format("NONE\tNONE\t%s", cKin.GetName()));
		end
		GlobalExcute{"KinPlant:AddSkillExp", dwKinId, nExp, nFlag};
	end
	if MODULE_GAMESERVER then
		return KKinGs.KinClientExcute(dwKinId, {"Kin:AddPlantSkillExp_C2", nExp, nNum, nFlag});
	end
end

--设置领取福禄种子标志
function KinPlant:SetKinFlag(dwKinId)
	local cKin = KKin.GetKin(dwKinId)
	if not cKin then
		return 0;
	end
	cKin.SetHandInCount(cKin.GetHandInCount() + 1);
	if  MODULE_GC_SERVER then
		GlobalExcute{"KinPlant:SetKinFlag", dwKinId};
	end
	if MODULE_GAMESERVER then
		return KKinGs.KinClientExcute(dwKinId, {"Kin:SetKinFlag_C2"});
	end
end

---------------------------------------------------------------------------------------------------
--test
if MODULE_GAMESERVER then

function KinPlant:ViewMe_GS()
	if me.dwKinId <= 0 then
		me.Msg("你还没有家族，不会有家族种植数据。");
		return;
	end
	me.Msg("-------------华丽的分割线---------------");
	for i , nTaskId in ipairs(self.tbPlantTask) do
		local szMsg = "";
		local nNum = me.GetTask(self.TASKGID, nTaskId);
		if self.tbPlantInfo[me.dwKinId] and self.tbPlantInfo[me.dwKinId][nNum] then
			szMsg = szMsg.."种植位置："..nNum;
			local tbInfo = self.tbPlantInfo[me.dwKinId][nNum];
			if tbInfo[1] == me.szName then
				szMsg = szMsg.."正在生长\n";
				szMsg = szMsg .."种植阶段："..tbInfo[2].."\n";
				szMsg = szMsg .."类型："..tbInfo[3].."\n";
				szMsg = szMsg .."果子生长量："..tbInfo[4].."\n";
				szMsg = szMsg .."种植天气类型："..tbInfo[5].."\n";
				szMsg = szMsg .."健康奖励数量："..tbInfo[6].."\n";
				szMsg = szMsg .."种植时间"..os.date("%Y%m%d%H%M%S",tbInfo[7]).."\n";
			else
				szMsg = szMsg.."已经枯萎";
			end
		end
		me.Msg(szMsg);
	end
	me.Msg("-------------华丽的分割线---------------");
end


end
	
function KinPlant:ViewMe_GC(dwKinId, szName, tb, tbInfo)	
	if MODULE_GC_SERVER then
		local tbInfoEx = {};
		for i, n in ipairs(tb) do
			if self.tbPlantInfo[dwKinId] and self.tbPlantInfo[dwKinId][n] then
				tbInfoEx[n] = self.tbPlantInfo[dwKinId][n];
			end
		end
		GlobalExcute{"KinPlant:ViewMe_GC", dwKinId, szName, tb, tbInfoEx};
		return;
	end
	if MODULE_GAMESERVER then		
		if not tbInfo then
			if me.dwKinId <= 0 then
				me.Msg("你还没有家族，不会有家族种植数据。");
				return;
			end
			GCExcute({"KinPlant:ViewMe_GC",me.dwKinId, me.szName, {me.GetTask(2176, 117), me.GetTask(2176, 118),me.GetTask(2176, 119)}});
		else
			local p = KPlayer.GetPlayerByName(szName);
			if not p then
				return 0;
			end
			p.Msg("-------------华丽的分割线---------------");
			for i, tb in pairs(tbInfo) do
				local szMsg = "";
				szMsg = szMsg.."种植位置："..i;
				if tb[1] == szName then
					szMsg = szMsg.."正在生长\n";
					szMsg = szMsg .."种植阶段："..tb[2].."\n";
					szMsg = szMsg .."类型："..tb[3].."\n";
					szMsg = szMsg .."果子生长量："..tb[4].."\n";
					szMsg = szMsg .."种植天气类型："..tb[5].."\n";
					szMsg = szMsg .."健康奖励数量："..tb[6].."\n";
					szMsg = szMsg .."种植时间"..os.date("%Y%m%d%H%M%S",tb[7]).."\n";
				else
					szMsg = szMsg.."已经枯萎";
				end
				p.Msg(szMsg);
			end
			p.Msg("-------------华丽的分割线---------------");	
		end
	end
end

