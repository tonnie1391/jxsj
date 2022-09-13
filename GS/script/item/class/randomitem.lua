-------------------------------------------------------------------
--File: 	randomitem.lua
--Author: 	sunduoliang
--Date: 	2008-2-28 11:30:24
--Describe:	获取随机物品，通用脚本
--第一个扩展参数代表随机表中的第几组
--第二个扩展参数代表箱子有效期，1代表当天24：00消失, 2代表7天后消失（有需要再自定义）
--第三个扩展参数代表任务组
--第四个扩展参数代表任务Id
--第五个扩展参数代表领取奖励后需设置任务组，Id的值;
--第六个扩展参数代表任务id表示日期
--第七个扩展参数代表任务id表示每天的次数
--第八个扩展参数代表宏参数表示每天最多开启的次数
--第九个扩展参数代表任务id表示总共的次数
--第十个扩展参数代表宏参数表示总共最多开启的次数
--只挂服务端

local tbRandomItem = Item:GetClass("randomitem");
local SZITEMFILE = "\\setting\\item\\001\\other\\randomitem.txt";
function tbRandomItem:OnUse()	
	if self.tbItemList == nil then
		self.tbItemList = self:GetItemList();
	end
	local nkind = tonumber(it.GetExtParam(1));
	local nTaskGroupId = tonumber(it.GetExtParam(3));
	local nTaskpId = tonumber(it.GetExtParam(4));
	local nTaskValue = tonumber(it.GetExtParam(5));
	local nTaskData = tonumber(it.GetExtParam(6));
	local nTaskTimes = tonumber(it.GetExtParam(7));
	local nTaskTimes_Max = tonumber(it.GetExtParam(8));
	local nTaskTimes_All = tonumber(it.GetExtParam(9));
	local nTaskTimes_All_Max = tonumber(it.GetExtParam(10));
	
	local nRet, szMsg = self:CheckCost(nkind);
	if nRet ~= 1 then
		me.Msg(szMsg or "Mở thất bại!");
		return 0;
	end	

	return self:SureOnUse(nkind, nTaskGroupId, nTaskpId, nTaskValue, nTaskData, nTaskTimes, nTaskTimes_Max, nTaskTimes_All, nTaskTimes_All_Max)
end

function tbRandomItem:SureOnUse(nkind, nTaskGroupId, nTaskpId, nTaskValue, nTaskData, nTaskTimes, nTaskTimes_Max, nTaskTimes_All, nTaskTimes_All_Max)
	--任务变量检测  每天的和总共的
	if self:CheckTask(nTaskGroupId, nTaskData, nTaskTimes, nTaskTimes_Max, nTaskTimes_All, nTaskTimes_All_Max) == 0 then		
		return 0;
	end	
	local nBagCellNeeded = 0; -- 所需背包空间
	local tbTask = {nTaskGroupId, nTaskpId, nTaskValue, nTaskTimes, nTaskTimes_All};
	local nMaxProbability = self.tbItemList[nkind].nMaxProp;
	local nRate = Random(nMaxProbability) + 1;
	local nRateSum = 0;
	local nMustGet = 0; -- 100%概率的item个数
	local nNeedMax = 0;
	
	local nBindMoney = 0; 	-- 可能获得的最大绑银数量
	local nMaxRandomBindMoney = 0; 	-- 随机获得的最大绑银数量
	local nMoney = 0;		-- 可能获得的最大银两数量
	local nMaxRandomMoney = 0;		--随机获得的对打银两数量
	
	for nitem=1, #self.tbItemList[nkind] do
		local tbItem = self.tbItemList[nkind][nitem];
		if tbItem and tbItem.nProbability == 0 then
			local nFreeCount = 1;
			if tbItem.nGenre ~= 0 and tbItem.nDetailType ~= 0 and tbItem.nParticularType ~= 0 then
				local tbItemInfo = {};
				if tbItem.szTimeLimit and tbItem.szTimeLimit ~= "" then
					tbItemInfo.bTimeOut = 1;
					if tonumber(tbItem.szTimeLimit) and  tonumber(tbItem.szTimeLimit) <= 0 then
						tbItemInfo.bTimeOut = nil;
					end
				end
				if tbItem.nBind > 0 then
					tbItemInfo.bForceBind = tbItem.nBind;
				end
				nFreeCount = KItem.GetNeedFreeBag(tbItem.nGenre, tbItem.nDetailType, tbItem.nParticularType, tbItem.nLevel, tbItemInfo, (tbItem.nAmount or 1))
				nBagCellNeeded = nBagCellNeeded + nFreeCount;
			end
			nMustGet = nMustGet + nFreeCount;
			
			nBindMoney = nBindMoney + tbItem.nBindMoney;
			nMoney = nMoney + tbItem.nMoney;
		end
		if tbItem and tbItem.nProbability > 0 then
			if tbItem.nGenre ~= 0 and tbItem.nDetailType ~= 0 and tbItem.nParticularType ~= 0 then
				local tbItemInfo = {};
				if tbItem.szTimeLimit and tbItem.szTimeLimit ~= "" then
					tbItemInfo.bTimeOut = 1;
				end
				if tbItem.nBind > 0 then
					tbItemInfo.bForceBind = tbItem.nBind;
				end
				local nFreeCount = KItem.GetNeedFreeBag(tbItem.nGenre, tbItem.nDetailType, tbItem.nParticularType, tbItem.nLevel, tbItemInfo, (tbItem.nAmount or 1));
				if nNeedMax < nFreeCount then
					nNeedMax = nFreeCount;
				end
			end
			
			if tbItem.nBindMoney > nMaxRandomBindMoney  then
				nMaxRandomBindMoney = tbItem.nBindMoney;
			end
			
			if tbItem.nMoney > nMaxRandomMoney then
				nMaxRandomMoney = tbItem.nMoney;
			end
		end		
	end

	nBindMoney = nBindMoney + nMaxRandomBindMoney;
	nMoney = nMoney + nMaxRandomMoney;
	
	-- 检查绑银
	if me.GetBindMoney() + nBindMoney > me.GetMaxCarryMoney() then
		me.Msg("Lượng Bạc khóa đã đạt mức tối đa, không thể nhận thêm!");
		return 0;
	end
	
	-- 检查银两
	if me.nCashMoney + nMoney > me.GetMaxCarryMoney() then
		me.Msg("Lượng Bạc đã đạt mức tối đa, không thể nhận thêm!");
		return 0;
	end
	
	if self:CheckItemFree(me, nBagCellNeeded + nNeedMax) == 0 then
		return 0;
	end
	
	self:SetTask(tbTask);
	self:FinishAchievement(nkind);
	
	if nMustGet > 0 then
		for nitem=1, #self.tbItemList[nkind] do
			local tbItem = self.tbItemList[nkind][nitem];
			if tbItem and tbItem.nProbability == 0 then
				if self:GetItem(me, tbItem, tbTask, nMustGet) == 0 then
					Dbg:WriteLog("Random Item that bai",  me.szName, string.format("Loai: %s, So luong: %s", nkind, nitem));
					return 1;
				else
					self:WriteLog(me.nId, nkind, nitem);-- 写Log，记录获得的物品
				end
			end
		end
	end
	
	for nitem=1, #self.tbItemList[nkind] do
		nRateSum = nRateSum + self.tbItemList[nkind][nitem].nProbability;
		if nRate <= nRateSum and self.tbItemList[nkind][nitem].nProbability ~= -1 then
			if self:GetItem(me, self.tbItemList[nkind][nitem], tbTask, nMustGet) == 0 then
				Dbg:WriteLog("Random Item that bai",  me.szName, string.format("Loai: %s, So luong: %s", nkind, nitem));
				return 1;
			else
				self:WriteLog(me.nId, nkind, nitem);-- 写Log，记录获得的物品
				return 1;
			end
		end
	end
	return 1; -- 如果该随机物品表只有概率为0的必得物品.
end

-- 写Log，记录randomitem被后获得的物品
-- nPlayerId: 获得道具的玩家ID
-- nClassParamID: 物品ExtParam1
-- nId: 组内ID
function tbRandomItem:WriteLog(nPlayerId, nClassParamID, nId)
	local tbItem = self.tbItemList[nClassParamID][nId];
	local szContent = string.format("%s,%s,%s,%s,%s", nClassParamID, nId, tbItem.szDesc, tbItem.nProbability, tbItem.szName);
	StatLog:WriteStatLog("stat_info", "randombox", "open_award", nPlayerId, szContent);
end

function tbRandomItem:SetTask(tbTask)
	if tbTask[1] and tbTask[1] ~= 0 and tbTask[4] and tbTask[4] ~= 0 then
		me.SetTask(tbTask[1],tbTask[4], me.GetTask(tbTask[1],tbTask[4]) + 1);
	end
	if tbTask[1] and tbTask[1] ~= 0 and tbTask[5] and tbTask[5] ~= 0 then
		me.SetTask(tbTask[1],tbTask[5], me.GetTask(tbTask[1],tbTask[5]) + 1);
	end
end

function tbRandomItem:FinishAchievement(nkind)
	if (not nkind or nkind <= 0) then
		return;
	end
	
	-- 军饷袋
	if (nkind == 7 or nkind == 15 or nkind == 23) then
		Achievement:FinishAchievement(me, 233);
		Achievement:FinishAchievement(me, 239);
	end
end

function tbRandomItem:GetItem(pPlayer, tbitem, tbTask, nMustGet)
	--if self:CheckItemFree(pPlayer, 1) == 0 then
	--	return 0;
	--end
	if tbitem.nBindMoney ~= 0 then
		pPlayer.AddBindMoney(tbitem.nBindMoney, Player.emKBINDMONEY_ADD_RANDOMITEM);
		local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color> bạc khóa", tbitem.nBindMoney);
		pPlayer.Msg(szAnnouce);
		KStatLog.ModifyAdd("bindjxb", "[RandomItem]"..(tbitem.szDesc or "Khong xac dinh"), "Toan bo", tbitem.nBindMoney);
	end
	if tbitem.nMoney ~= 0 then
		local nAddMoney = pPlayer.Earn(tbitem.nMoney, Player.emKEARN_RANDOM_ITEM);
		local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color> bạc", tbitem.nMoney);
		pPlayer.Msg(szAnnouce);
		if nAddMoney == 1 then
			Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName,  string.format("Ngau nhien %s bac", tbitem.nMoney));
			KStatLog.ModifyAdd("jxb", "[RandomItem]"..(tbitem.szDesc or "Khong xac dinh"), "Toan bo", tbitem.nMoney);
		else
			Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName,  string.format("Bac dat gioi han, Ngau nhien %s bac", tbitem.nMoney));
		end
	end
	if tbitem.nCoin ~= 0 then
		local nAddCoin = pPlayer.AddBindCoin(tbitem.nCoin, Player.emKBINDCOIN_ADD_RANDOM_ITEM); -- 只会加绑金
		local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color> %s khóa", tbitem.nCoin, IVER_g_szCoinName);
		pPlayer.Msg(szAnnouce);
		if nAddCoin == 1 then
			KStatLog.ModifyAdd("bindcoin", "[RandomItem]"..(tbitem.szDesc or "Khong xac dinh"), "Toan bo", tbitem.nCoin);
			Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName,  string.format("Ngau nhien %s %s khóa", tbitem.nCoin, IVER_g_szCoinName));
		else
			Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName,  string.format("Bac %s dat gioi han, Ngau nhien %s %s khoa that bai", IVER_g_szCoinName, tbitem.nCoin, IVER_g_szCoinName));
		end
	end
	if tbitem.nGenre ~= 0 and tbitem.nDetailType ~= 0 and tbitem.nParticularType ~= 0 then
		local nCount = tonumber(tbitem.nAmount) or 1;
		
		-- by zhangjinpin@kingsoft
		local tbItemInfo = {};
		tbItemInfo.nSeries = tbitem.nSeries;
		tbItemInfo.nEnhTimes = tbitem.nEnhTimes;
		
		if tbitem.szTimeLimit and tbitem.szTimeLimit ~= "" then
			tbItemInfo.bTimeOut = 1;
		end
		
		if tbitem.nBind > 0 then
			tbItemInfo.bForceBind = tbitem.nBind;
		end
		
		local nActualCount = 0;			
		if tbItemInfo.bTimeOut ~= 1 then
			local nAddCount, szItemName = pPlayer.AddStackItem(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, nCount);
			if nAddCount > 0 then
				local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color>", szItemName);
				pPlayer.Msg(szAnnouce);
				Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Random Item thanh cong%s", szItemName));
			else
				local szMsg = string.format("Random Item that bai，物品ID：%s,%s,%s", tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType);
				Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, szMsg);
				return 0;
			end
			nActualCount = nAddCount;
		else
			for i= 1, nCount do
				local pItem = pPlayer.AddItemEx(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, Player.emKITEMLOG_TYPE_JOINEVENT);
				if pItem then
					if tbitem.szTimeLimit ~= "" then
						self:LimitTime(pPlayer, tbitem.szTimeLimit, pItem);
					end
					local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color>", pItem.szName);
					pPlayer.Msg(szAnnouce);
					Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Random Item thanh cong%s", pItem.szName));
					nActualCount = nActualCount + 1;
				else
					local szMsg = string.format("Random Item that bai，物品ID：%s,%s,%s", tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType);
					Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, szMsg);
					return 0;
				end
			end
		end
		local szRItemName = "未知物品";
		local nExtParam = 0;
		if it then
			szRItemName = it.szName;
			nExtParam = it.GetExtParam(1);
		end
		local szKey = string.format("%s(randomitem id = %d)", szRItemName,nExtParam);
		Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, szKey, {tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbitem.nBind, nActualCount});
	end
	
	if tbitem.nExp ~= 0 then
		pPlayer.AddExp(tbitem.nExp)
		local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color>经验",tbitem.nExp);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Ngau nhien %s经验", tbitem.nExp));
	end
	
	if tbitem.nBaseExp ~= 0 then
		pPlayer.AddExp(me.GetBaseAwardExp() * tbitem.nBaseExp);
		local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color>经验", me.GetBaseAwardExp() * tbitem.nBaseExp);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Ngau nhien %s经验", me.GetBaseAwardExp() * tbitem.nBaseExp));
	end
		
	if tbitem.nMKP ~= 0 then
		pPlayer.ChangeCurMakePoint(tbitem.nMKP)
		local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color>精力",tbitem.nMKP);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Ngau nhien %s精力", tbitem.nMKP));
	end
	
	if tbitem.nGTP ~= 0 then
		pPlayer.ChangeCurGatherPoint(tbitem.nGTP)
		local szAnnouce = string.format("Bạn nhận được <color=yellow>%s<color>活力",tbitem.nGTP);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Ngau nhien %s活力", tbitem.nGTP));		
	end
	
	if (tbitem.varLuaScriptFun and tbitem.varLuaScriptFun ~= "") then
		local varResult = self:GetVar(tbitem.varLuaScriptFun);
		local bSucc = 0;
		if (varResult and type(varResult) == "number" and varResult == 1) then
			bSucc = 1;	
		elseif (varResult and type(varResult) == "table") then
			local pAddItem = me.AddItemEx(unpack(varResult));
			if pAddItem then
				-- RandomItem了石头数据埋点 todo zjq 这里的日志可以去掉，随机宝石不使用这种方式
--				if pAddItem.GetStoneType() ~= 0 then
--					-- 数据埋点
--					StatLog:WriteStatLog("stat_info", "baoshixiangqian", "drop", pPlayer.nId, 
--						string.format("%d_%d_%d_%d,%d_%d_%d_%d", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, 
--											pAddItem.nGenre, pAddItem.nDetail, pAddItem.nParticular, pAddItem.nLevel));
--				end
				
				bSucc = 1;	
			end			
		end
		
		if bSucc == 1 then
			Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Ngau nhien %s，执行了脚本函数，成功", tbitem.varLuaScriptFun));	
		else
			Dbg:WriteLog("Random Item thanh cong",  pPlayer.szName, string.format("Ngau nhien %s，执行了脚本函数，失败", tbitem.varLuaScriptFun));	
		end
	end
	
	if tbTask[1] and tbTask[2] and tbTask[3] then
		if tbTask[1] ~= 0 and tbTask[2] ~= 0 then
			pPlayer.SetTask(unpack(tbTask));
		end		
	end
	local nStep = 1;
	if nMustGet <= 0 then
		nStep = 2;
	end

	if tbitem.nAnnounce == 1 then
		local szMsg = string.format("%s打开%s获得一个%s,真是鸿运当头呀！", pPlayer.szName, tbitem.szDesc, tbitem.szName);
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		--Player:SendMsgToKinOrTong(pPlayer, "打开"..tbitem.szDesc.."获得了"..tbitem.szName.."。", 1);
	end
		
	if tbitem.nFriendMsg == 1 then
		pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]打开"..tbitem.szDesc..
			"获得了<color=yellow>"..tbitem.szName.."<color>。");		
	end

	if tbitem.nKinOrTongMsg == 1 then
		local szMsg = string.format("%s打开%s获得一个%s！", pPlayer.szName, tbitem.szDesc, tbitem.szName);
		Player:SendMsgToKinOrTong(pPlayer, "打开"..tbitem.szDesc.."获得了"..tbitem.szName.."。", 1);
	end
	return 1;
end

function tbRandomItem:CheckItemFree(pPlayer, nCount)
	if pPlayer.CountFreeBagCell() < nCount then
		local szAnnouce = "Hành trang không đủ ，请留出"..nCount.."格空间再试。";
		pPlayer.Msg(szAnnouce);
		return 0;
	end
	return 1;
end

--玩家当天次数和总次数的限制
function tbRandomItem:CheckTask(nTaskGroupId, nTaskData, nTaskTimes, nTaskTimes_Max, nTaskTimes_All, nTaskTimes_All_Max)	
	if not nTaskGroupId or nTaskGroupId == 0 then
		return 1;
	end
	if nTaskData and nTaskTimes and nTaskTimes_Max and nTaskData ~= 0 and nTaskTimes ~= 0 and nTaskTimes_Max ~= 0 then		
		local nDate = me.GetTask(nTaskGroupId, nTaskData);
		local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
		if nDate ~= nNowDate then
			me.SetTask(nTaskGroupId, nTaskData, nNowDate);
			me.SetTask(nTaskGroupId, nTaskTimes, 0);
		end	
		local nTimes = me.GetTask(nTaskGroupId, nTaskTimes);			
		if nTimes >= nTaskTimes_Max then
			me.Msg("您今天已经开启了足够多了，还是明天再开吧！");
			return 0;
		end
	end
	if nTaskTimes_All and nTaskTimes_All_Max and nTaskTimes_All_Max ~= 0 and nTaskTimes_All ~= 0 then
		local nTimesAll = me.GetTask(nTaskGroupId, nTaskTimes_All);		
		if nTimesAll >= nTaskTimes_All_Max then
			me.Msg("您已经开了足够多了，机会还是留给别人吧！");
			return 0;
		end
	end
	return 1;
end

function tbRandomItem:LimitTime(pPlayer, szParam, pItem)
	if szParam == nil then
		return 1;
	end
	if not pItem then
		return 0;
	end
	if tonumber(szParam) ~= nil then
		local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + tonumber(szParam) * 60);
		pPlayer.SetItemTimeout(pItem,szDate);
	else
		local tbStr = Lib:SplitStr(szParam, "/");
		if #tbStr == 3 then
			--当天H:M:S消失
			local nNowDate = GetLocalDate("%Y/%m/%d");
			local szTime = string.format("%s/%s", nNowDate, szParam);
			pPlayer.SetItemTimeout(pItem,szTime);
		elseif #tbStr == 4 then
			--d天后H:M:S消失
			if tonumber(tbStr[1]) > 0 then
				local nNowDate = GetLocalDate("%Y/%m");
				local nHour = tonumber(GetLocalDate("%H"));
				local nMin = tonumber(GetLocalDate("%M"));
				local nSecond = tonumber(GetLocalDate("%S"));
				local nLastTime = 24 * 3600 - (nHour * 3600 + nMin *60 + nSecond);
				local nLastTime2 = tonumber(tbStr[2]) * 3600 + tonumber(tbStr[3]) * 60 + tonumber(tbStr[4]);
				local nLimitTime = nLastTime + ((tonumber(tbStr[1]) - 1)* 24 * 3600) + nLastTime2;
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + nLimitTime);
				pPlayer.SetItemTimeout(pItem,szDate);
			else
				local nNowDate = GetLocalDate("%Y/%m/%d");
				local szTime = string.format("%s/%s/%s/%s", nNowDate, tonumber(tbStr[2]), tonumber(tbStr[3]), tonumber(tbStr[4]));
				pPlayer.SetItemTimeout(pItem,szTime);				
			end			
		elseif #tbStr == 6 then
			--Y-m-d H:M:S后消失
			pPlayer.SetItemTimeout(pItem,szParam);
		end
	end
	return 0;
end

function tbRandomItem:InitGenInfo()
	-- 设定有效期限
	local nkind = tonumber(it.GetExtParam(2));
	if nkind == 1 then
		local nDate = tonumber(GetLocalDate("%Y%m%d2400"));
		local nSec = Lib:GetDate2Time(nDate);
		it.SetTimeOut(0, nSec);
	elseif nkind == 2 then
		it.SetTimeOut(0, GetTime() + 3600 * 24 * 7);
	end
	return	{ };
end

--修改某一项的权重值(测试指令)
function tbRandomItem:SetRate(nRate, nClassParamID, nPosNo)
	if nRate <= 0 then
		me.Msg("你设的概率值不对！");
		return;
	end
	if not self.tbItemList[nClassParamID] or not self.tbItemList[nClassParamID][nPosNo] then
		me.Msg("指向的随机物品的概率表不对！");
		return;
	end
	self.tbItemList[nClassParamID].nMaxProp = self.tbItemList[nClassParamID].nMaxProp + nRate - self.tbItemList[nClassParamID][nPosNo].nProbability;
	self.tbItemList[nClassParamID][nPosNo].nProbability = nRate;
end

function tbRandomItem:GetItemList()
	
	local tbsortpos = Lib:LoadTabFile(SZITEMFILE);
	local nLineCount = #tbsortpos;
	local tbClassItemList = {};
	
	for nLine=2, nLineCount do
		local nClassParamID = tonumber(tbsortpos[nLine].ClassParamID);
		local nProbability = tonumber(tbsortpos[nLine].Probability) or 0;
		local szName = tbsortpos[nLine].Name;
		local szDesc = tbsortpos[nLine].Desc;
		local nBindMoney = tonumber(tbsortpos[nLine].BindMoney) or 0;
		local nMoney = tonumber(tbsortpos[nLine].Money) or 0;
		local nGenre = tonumber(tbsortpos[nLine].Genre) or 0;
		local nDetailType = tonumber(tbsortpos[nLine].DetailType)or 0;
		local nParticularType = tonumber(tbsortpos[nLine].ParticularType) or 0;
		local nLevel = tonumber(tbsortpos[nLine].Level)or 0;
		local nSeries = tonumber(tbsortpos[nLine].Series) or 0;
		local nEnhTimes = tonumber(tbsortpos[nLine].EnhTimes) or 0;
		local nAmount = tonumber(tbsortpos[nLine].Amount) or 1;
		local nExp = tonumber(tbsortpos[nLine].Exp) or 0;
		local nBaseExp = tonumber(tbsortpos[nLine].BaseExp) or 0;
		local nMKP = tonumber(tbsortpos[nLine].MKP) or 0;
		local nGTP = tonumber(tbsortpos[nLine].GTP) or 0;
		local szTimeLimit = tbsortpos[nLine].TimeLimit;
		local nBind = tonumber(tbsortpos[nLine].Bind) or 0;
		local nCoin = tonumber(tbsortpos[nLine].Coin) or 0;
		local nAnnounce = tonumber(tbsortpos[nLine].Announce) or 0;
		local nFriendMsg = tonumber(tbsortpos[nLine].FriendMsg) or 0;
		local nKinOrTongMsg = tonumber(tbsortpos[nLine].KinOrTongMsg) or 0;
		local varLuaScriptFun = tbsortpos[nLine].LuaScriptFun;
		
		local tbCost = {};
		if tbsortpos[nLine].Cost then
			local _szType, _Value = self:GetSplitValue(tbsortpos[nLine].Cost);		
			tbCost[_szType] = _Value;
		end
		
		if tbClassItemList[nClassParamID] == nil then
			tbClassItemList[nClassParamID] = {};
			tbClassItemList[nClassParamID].nMaxProp = 0;
			tbClassItemList[nClassParamID].tbCost = tbCost;
		end
		local nPosNo = (#tbClassItemList[nClassParamID]+ 1);
		tbClassItemList[nClassParamID][nPosNo] = {};
		tbClassItemList[nClassParamID][nPosNo].nProbability = nProbability;
		tbClassItemList[nClassParamID][nPosNo].szName = szName;
		tbClassItemList[nClassParamID][nPosNo].nBindMoney = nBindMoney;
		tbClassItemList[nClassParamID][nPosNo].nMoney = nMoney;
		tbClassItemList[nClassParamID][nPosNo].nGenre = nGenre;
		tbClassItemList[nClassParamID][nPosNo].nDetailType = nDetailType;
		tbClassItemList[nClassParamID][nPosNo].nParticularType = nParticularType;
		tbClassItemList[nClassParamID][nPosNo].nLevel = nLevel;
		tbClassItemList[nClassParamID][nPosNo].nSeries = nSeries;
		tbClassItemList[nClassParamID][nPosNo].nEnhTimes = nEnhTimes;
		tbClassItemList[nClassParamID][nPosNo].nAmount = nAmount;
		tbClassItemList[nClassParamID][nPosNo].nExp = nExp;
		tbClassItemList[nClassParamID][nPosNo].nBaseExp = nBaseExp;
		tbClassItemList[nClassParamID][nPosNo].nMKP = nMKP;
		tbClassItemList[nClassParamID][nPosNo].nGTP = nGTP;
		tbClassItemList[nClassParamID][nPosNo].szTimeLimit = szTimeLimit;
		tbClassItemList[nClassParamID][nPosNo].nBind = nBind;
		tbClassItemList[nClassParamID][nPosNo].nCoin = nCoin;
		tbClassItemList[nClassParamID][nPosNo].nAnnounce = nAnnounce;
		tbClassItemList[nClassParamID][nPosNo].nFriendMsg = nFriendMsg;
		tbClassItemList[nClassParamID][nPosNo].nKinOrTongMsg = nKinOrTongMsg;
		tbClassItemList[nClassParamID][nPosNo].szDesc = szDesc;
		tbClassItemList[nClassParamID][nPosNo].varLuaScriptFun = varLuaScriptFun;

		if nProbability >= 0 then
			tbClassItemList[nClassParamID].nMaxProp =
			tbClassItemList[nClassParamID].nMaxProp + nProbability;
		end
	end
	return tbClassItemList;
end

local function fnStrValue(szVal)
	print(szVal);
	local varType = loadstring(szVal);
	print(type(varType));
	if type(varType) == "function" then
		return varType();
	else
		print(">>tbRandomItem:fnStrValue type error>>>>>>>");
		return varType;
	end
end

function tbRandomItem:GetVar(var, varDefault)
	local szType = type(var);
	local varResult = nil;
	if (szType == "function") then
		local bOk, varRet = Lib:CallBack({var});
		if (bOk) then
			varResult = varRet;
		end
	elseif(szType == "string") then	
	 	varResult = string.gsub(var, "<%%(.-)%%>", fnStrValue);
	elseif(szType == "number") then
		varResult = var;	
	else
		print("【Error】tbRandomItem:GetStrVal",var);--,debug.traceback());
	end
	return varResult or varDefault;
end

function tbRandomItem:CheckCost(nKind)
	if not self.tbItemList[nKind] then
		return 0;
	end
	
	local tbCost = self.tbItemList[nKind].tbCost;
	if not tbCost or Lib:CountTB(tbCost) == 0 then
		return 1;  -- 不需要消耗
	end
	
	local nRet = 1;
	local szNeed = "必须要有以下东西才能打开这个箱子：";
	for szType, tbInfo in pairs(tbCost) do
		if szType == "item" then
			-- {g,d,p,l,0,nCount}
			local szItemName = KItem.GetItemBaseProp(unpack(tbInfo)).szName;
			local nCount = tbInfo[6];
			
			szNeed = szNeed..string.format("<color=yellow>%s%d个<color>，", szItemName, nCount);
			if nRet == 1 then
				nRet = me.GetItemCountInBags(tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4]) >= nCount and 1 or 0;
			end			
		elseif szType == "money" then
			szNeed = szNeed..string.format("<color=yellow>银两%d两<color>，", tbInfo[1]);	
			if nRet == 1 then
				nRet = me.CashMoney >= tbInfo[1] and 1 or 0;
			end				
		elseif szType == "bindmoney" then
			szNeed = szNeed..string.format("<color=yellow>绑定银两%d两<color>，", tbInfo[1]);
			if nRet == 1 then
				nRet = me.GetBindMoney() >= tbInfo[1] and 1 or 0;
			end		
		elseif szType == "bindcoint" then
			szNeed = szNeed..string.format("<color=yellow>银两%d两<color>，", tbInfo[1]);
			if nRet == 1 then
				nRet = me.nBindCoin >= tbInfo[1] and 1 or 0;
			end		
		end
	end
	szNeed = szNeed.."请确保你身上有足够的东西！";
	
	-- 检查满足条件后，扣除物品
	if nRet == 1 then
		for szType, tbInfo in pairs(tbCost) do
			if szType == "item" then
				-- {g,d,p,l,0,nCount}
				if me.ConsumeItemInBags2(tbInfo[6], tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4]) ~= 0 then
					nRet = 0;
					break;
				end	
			elseif szType == "money" then
				if me.CostMoney(tbInfo[1]) ~= 1 then
					nRet = 0;
					break;
				end				
			elseif szType == "bindMoney" then
				if me.CostBindMoney(tbInfo[1]) ~= 1 then
					nRet = 0;
					break;
				end			
			elseif szType == "bindCoint" then
				if me.AddBindCoin(-tbInfo[1]) ~= 1 then
					nRet = 0;
					break;
				end			
			end
		end
	end	
	
	return nRet, szNeed;
end

function tbRandomItem:GetSplitValue(szStr)
	szStr = Lib:ClearStrQuote(szStr);
	local nSit = string.find(szStr, "=");
	if nSit ~= nil then
		local szFlag = string.sub(szStr, 1, nSit - 1);
		local szContent = string.sub(szStr, nSit + 1, string.len(szStr));
		if tonumber(szContent) then
			return szFlag, tonumber(szContent);
		end
		local tbLit = Lib:SplitStr(szContent, ",");
		for nId, nNum in ipairs(tbLit) do
			tbLit[nId] = tonumber(nNum);
		end
		return szFlag, tbLit;
	end
	return "", "";
end

tbRandomItem.tbItemList = tbRandomItem:GetItemList()