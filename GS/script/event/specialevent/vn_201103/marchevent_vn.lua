-- 文件名　：marchevent_vn.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-03-22 14:48:39
--vn 201103活动，最好吃的菜，活跃礼盒

SpecialEvent.tbMarchEvent_vn = SpecialEvent.tbMarchEvent_vn or {};
local tbMarchEvent_vn = SpecialEvent.tbMarchEvent_vn;
tbMarchEvent_vn.nOpenDate = 20110411		--开始日期
tbMarchEvent_vn.nCloseDate = 20110428		--结束日期

tbMarchEvent_vn.nHorseCount = 5;			--最好吃的菜马牌总数
tbMarchEvent_vn.tbHorse_BX = {1, 12, 35, 4};	--奔宵马GDPL
tbMarchEvent_vn.nRandom = 1;				--翻羽马的概率（1-100000）
tbMarchEvent_vn.tbHorse_FY = {1, 12, 33, 4};	--翻羽马GDPL
tbMarchEvent_vn.nDayMiBing = 5;			--每天米饼数
tbMarchEvent_vn.nAllMiBing = 50;			--总米饼数
tbMarchEvent_vn.nDayZongZi = 10;			--每天粽子数
tbMarchEvent_vn.nAllZongZi = 100;			--总粽子数
tbMarchEvent_vn.nAllLiHe = 100;			--礼盒总数

tbMarchEvent_vn.tbHorse = {[1] = {1000,30}, [2] = {1800,60}};	--买马需要魂石数量和时间
tbMarchEvent_vn.nSkillId = 892;			--强化优惠

--task
tbMarchEvent_vn.TASK_GID 			= 2147;		--任务组
tbMarchEvent_vn.TASK_TASKID_MB		= 26;		--米饼数量
tbMarchEvent_vn.TASK_TASKID_MB_DAY	= 27;		--米饼日期
tbMarchEvent_vn.TASK_TASKID_MB_ALL	= 28;		--米饼总
tbMarchEvent_vn.TASK_TASKID_ZZ		= 29;		--粽子数量
tbMarchEvent_vn.TASK_TASKID_ZZ_DAY	= 30;		--粽子日期
tbMarchEvent_vn.TASK_TASKID_ZZ_ALL	= 31;		--粽子总
tbMarchEvent_vn.TASK_TASKID_LH		= 32;		--活跃礼盒数量
tbMarchEvent_vn.TASK_TASKID_LH_DAY	= 33;		--活跃礼盒日期
tbMarchEvent_vn.TASK_TASKID_LH_ALL	= 34;		--活跃礼盒总
tbMarchEvent_vn.TASK_TASKID_HORSE	= 35;			--买马



if MODULE_GC_SERVER then

tbMarchEvent_vn.Global_Pici = 1;		--全局变量批次

--越南活动全局变量重置

function tbMarchEvent_vn:GCStartFunction()
	local nFlag = KGblTask.SCGetDbTaskInt(DBTASK_VN_TASKID_PICI);
	if nFlag ~= self.Global_Pici then
		KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_LAST_DAY, 0);
		KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_ALL_COUNT, 0);
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_YH, 0);
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_YH, 0);
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_LAST_DAY_GP, 0);
		KGblTask.SCSetDbTaskInt(DBTASK_VN_BENXIAO_ALL_COUNT_GP, 0);
	end
end

--GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbMarchEvent_vn.GCStartFunction,SpecialEvent.tbMarchEvent_vn);


function tbMarchEvent_vn:IsGetHorse(nPlayerId)
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = KGblTask.SCGetDbTaskInt(DATASK_VN_BENXIAO_LAST_DAY);
	local nAllCount = KGblTask.SCGetDbTaskInt(DATASK_VN_BENXIAO_ALL_COUNT) + 1;
	if nNowDate ~= nDate and nAllCount <= self.nHorseCount then
		GlobalExcute{"SpecialEvent.tbMarchEvent_vn:OnSpecialAward",nPlayerId, 1};
		KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_LAST_DAY, nNowDate);
		KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_ALL_COUNT, nAllCount);
	else
		GlobalExcute{"SpecialEvent.tbMarchEvent_vn:OnSpecialAward",nPlayerId};
	end
end

end

if MODULE_GAMESERVER then

function tbMarchEvent_vn:OnSpecialAward(nPlayerId, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	pPlayer.AddWaitGetItemNum(-1);
	if nFlag then
		local pItem = pPlayer.AddItem(unpack(self.tbHorse_FY));
		if pItem then			
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, string.format("%s食用粽子获得一个%s，真是鸿运当头呀！", pPlayer.szName, pItem.szName));
			Dbg:WriteLog("[越南3月活动]食用粽子获得翻羽马");
		end
	end	
end

function tbMarchEvent_vn:OnDialog_YH()
	local nTotalCount = me.GetTask(self.TASK_GID,26);	
	local nTodayCount = me.GetTask(2143,25);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate ~= me.GetTask(2143,24) then
		nTodayCount = 0;
	end
	
	local szMsg = string.format("你今天已经点燃了%s个烟花，活动期间你总共点燃了%s个烟花",nTodayCount, nTotalCount);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbMarchEvent_vn:OnDialog()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCount_BM = me.GetTask(self.TASK_GID, self.TASK_TASKID_MB);
	local nAllCount_BM = me.GetTask(self.TASK_GID, self.TASK_TASKID_MB_ALL);
	local nCount_ZZ = me.GetTask(self.TASK_GID, self.TASK_TASKID_ZZ);
	local nAllCount_ZZ = me.GetTask(self.TASK_GID, self.TASK_TASKID_ZZ_ALL);
	if nNowDate ~= me.GetTask(self.TASK_GID, self.TASK_TASKID_MB_DAY) then
		nCount_BM = 0;
	end
	if nNowDate ~= me.GetTask(self.TASK_GID, self.TASK_TASKID_ZZ_DAY) then
		nCount_ZZ = 0;
	end
	
	local szMsg = string.format("今天你已经使用了<color=yellow>%s<color>个米饼<color=yellow>%s<color>个粽子\n活动期间你总共使用了<color=yellow>%s<color>个米饼<color=yellow>%s<color>个粽子。", nCount_BM, nCount_ZZ, nAllCount_BM, nAllCount_ZZ);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbMarchEvent_vn:OnDialog_LiHe()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCount = me.GetTask(self.TASK_GID, self.TASK_TASKID_LH);
	local nAllCount = me.GetTask(self.TASK_GID, self.TASK_TASKID_LH_ALL);
	if nNowDate ~= me.GetTask(self.TASK_GID, self.TASK_TASKID_LH_DAY) then
		nCount = 0;
	end
	
	local szMsg = string.format("你今天已经兑换了<color=yellow>%s<color>个活跃礼盒,活动期间你总共兑换了<color=yellow>%s<color>个活跃礼盒。", nCount, nAllCount);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbMarchEvent_vn:OnDialog_Horse(nType)
	local nFlag, szReturnMsg = self:CheckCanBuyHorse();
	if nFlag == 0 then
		Dialog:Say(szReturnMsg);
		return;
	end
	if not nType then		
		local szMsg = "在我这里你可以用魂石购买奔宵马牌\n<color=red>注：每人只有一次机会购买。<color>\n";
		local tbOpt = {};
		for i, tbHorseInfo in ipairs(self.tbHorse) do
			szMsg = szMsg..string.format("方案%s:价格<color=yellow>%s<color>魂石，%s天有效期。\n", i, tbHorseInfo[1], tbHorseInfo[2]);
			table.insert(tbOpt, {"购买方案"..i, self.OnDialog_Horse, self, i})
		end
		table.insert(tbOpt, {"Ta hiểu rồi"});
		Dialog:Say(szMsg, tbOpt);
		return;
	end	
	Dialog:OpenGift(szMsg, nil ,{self.OnOpenGiftOk, self, nType});
end

function tbMarchEvent_vn:CheckCanBuyHorse()
	local nAllCount_LH = me.GetTask(self.TASK_GID, self.TASK_TASKID_LH_ALL);
	if nAllCount_LH < self.nAllLiHe then
		return 0, "你好像没有资格购买奔宵马。";
	end
	local nFlag = me.GetTask(self.TASK_GID, self.TASK_TASKID_HORSE);
	if nFlag == 1 then
		return 0, "每个人只有一次机会。";
	end
	return 1;
end

function tbMarchEvent_vn:OnOpenGiftOk(nType, tbItemObj)
	local nFlag, szReturnMsg = self:CheckCanBuyHorse();
	if nFlag == 0 then
		me.Msg(szReturnMsg);
		return 0;
	end
	if Lib:CountTB(tbItemObj) <= 0 then
		me.Msg("请放入物品!");
		return 0;
	end
	local nCount = 0;
	for _, pItem in pairs(tbItemObj) do		
		local szFollowCryStal 	= "18,1,205,1";
		local szItem		= string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if szFollowCryStal ~= szItem then
			me.Msg("存在不符合的物品!");
			return 0;
		end;
		if pItem[1].IsBind() == 1 then
			me.Msg("请放入不绑定的魂石。");
			return 0;
		end
		nCount = nCount + pItem[1].nCount;
	end
	if nCount ~= self.tbHorse[nType][1] then
		me.Msg("你放入的物品数量不对!");
		return 0;
	end
	
	for _, pItem in pairs(tbItemObj) do		
		pItem[1].Delete(me);
	end	
	
	local pItem = me.AddItem(unpack(self.tbHorse_BX));
	if pItem then
		pItem.SetTimeOut(0, GetTime() + 24*3600*self.tbHorse[nType][2]);
		pItem.Sync();
		me.SetTask(self.TASK_GID, self.TASK_TASKID_HORSE, 1);
		me.Msg(string.format("你花费<color=yellow>%s<color>魂石购买了一匹奔宵马。", self.tbHorse[nType][1]));
		Dbg:WriteLog(string.format("[越南3月活动]花费%s魂石购买了一匹奔宵马", self.tbHorse[nType][1]));
	end
	return 1;
end

end
