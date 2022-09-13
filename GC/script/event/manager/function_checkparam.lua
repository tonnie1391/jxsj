Require("\\script\\event\\manager\\define.lua");
local tbFun = EventManager.tbFun;

--已保证当前me为玩家
tbFun.tbLimitParamFun =
{
	CheckTaskDay 		= "CheckTaskDay", 		--Day天最多只能领取MaxCount次:需要2个任务变量param:dddd
	CheckTask			= "CheckTask", 			--任务变量>=几时返回不通过;需要1个任务变量param:dd
	CheckTaskLt			= "CheckTaskLt", 		--任务变量<几时返回不通过;需要1个任务变量param:dd
	CheckTaskEq			= "CheckTaskEq", 		--任务变量~=几时返回不通过;需要1个任务变量param:dd	
	CheckTaskCurTime	= "CheckTaskCurTime", 	--检查任务变量和当前时间比较
	CheckTaskGotoEvent 	= "CheckTaskGotoEvent", --跳到当前大活动的某个小活动事件；不再执行下面函数
	SetTaskOneDay		= "CheckTaskOneDay",	--检查每天一次；需要1个任务变量 param:d
	CheckTaskDateMsg	= "CheckTaskDateMsg",	--任务变量检查不满足条件是提示。
	CheckGTaskDay 		= "CheckGTaskDay", 		--Day天最多只能领取MaxCount次:需要2个任务变量param:dddd
	CheckGTask			= "CheckGTask", 		--任务变量>=几时返回不通过;需要1个任务变量param:dd
	CheckGTaskLt		= "CheckGTaskLt", 		--任务变量<几时返回不通过;需要1个任务变量param:dd
	CheckGTaskEq		= "CheckGTaskEq", 		--任务变量==几时返回不通过;需要1个任务变量param:dd	
	CheckGTaskCurTime	= "CheckGTaskCurTime", 	--检查任务变量和当前时间比较
	CheckGTaskGotoEvent = "CheckGTaskGotoEvent",--跳到当前大活动的某个小活动事件；
	
	CheckExp 		= "CheckExp", 			--整次获得最多只能获得经验上限, 需要1个任务变量param:dd
	CheckExpDay		= "CheckExpDay", 		--Day天最多只能获得经验上限为ExpLimit, 需要2个任务变量param:dddd
	CheckMonthPay	= "CheckMonthPay", 		--本月累计充值达到n元,param:d
	CheckMonthPay_VN	= "CheckMonthPay_VN", 		--本月累计充值达到n越南盾,param:d
	CheckLevel		= "CheckLevel",			--达到nLevel等级玩家,param:d
	CheckAboveLevel	= "CheckAboveLevel",	--低于nLevel等级玩家,param:d
	CheckFaction 	= "CheckFaction",		--限制等于该门派玩家,门派ID查表得,param:d
	CheckCamp 		= "CheckCamp",			--阵营限制,param:d
	CheckWeiWang	= "CheckWeiWang",		--江湖威望达到n，param:d
	CheckFreeBag	= "CheckFreeBag",		--检查背包空间
	CheckSex		= "CheckSex",			--检查性别(0,男性,1女性)
	CheckExt		= "CheckExt",			--检查每个累计充值扩展点高四位是否等于某值,等于返回失败,已激活
	CheckItemInBag	= "CheckItemInBag",		--检查身上是否有物品param:g,d,p,l,n,bool :bool ==0为身上要有物品条件通过
	CheckItemInAll	= "CheckItemInAll",		--检查身上,储物箱是否有物品g,d,p,l,n,bool:bool ==0为身上要有物品条件通过
	CheckInMapType	= "CheckInMapType",		--检查所在地图类型
	CheckInMapLevel = "CheckInMapLevel",	--检查所在地图等级
	CheckNpcAtNear	= "CheckNpcAtNear",		--检查npc是否在附近
	CheckLuaScript	= "CheckLuaScript",		--自定义脚本；
	CheckBindMoneyMax= "CheckBindMoneyMax",	--检查绑定银两上限
	CheckMoneyMax	= "CheckMoneyMax",		--检查银两上限
	
	CheckMoneyHonor = "CheckMoneyHonor",	--检查财富荣誉
	CheckHonorGrade = "CheckHonorGrade",	--检查荣誉等级
	CheckMantleLevel = "CheckMantleLevel",		--检查披风等级	
	CheckChopLevel = "CheckChopLevel", 		--检查官印等级
	CheckMaskType = "CheckMaskType",		--检查面具
	CheckNpcTaskEq	= "CheckNpcTaskEq",		--检查npc临时变量等于（npc消失后清除）
	CheckNpcTaskGt	= "CheckNpcTaskGt",		--检查npc临时变量等于（npc消失后清除）
	CheckNpcTaskLt	= "CheckNpcTaskLt",		--检查npc临时变量等于（npc消失后清除）
	CheckNpcLevel		= "CheckNpcLevel",			--检查npc等级
	CheckNpcType		= "CheckNpcType",			--检查npc类型0普通，1精英，2首领
	CheckNpcIsBeLongMe	= "CheckNpcIsBeLongMe",	--检查npc是不是属于自己
	CheckNpcSeries	= "CheckNpcSeries",			--检查npc五行1 金，2 木，3 水，4 火，5土
	CheckInKin		= "CheckInKin",			--检查是否在某个家族中
	CheckInTong		= "CheckInTong",		--检查是否在某个帮会中
	CheckHaveKin	= "CheckHaveKin",		--检查是否有家族
	CheckHaveTong	= "CheckHaveTong",		--检查是否有帮会
	CheckFuliJingHuoWeiWang="CheckFuliJingHuoWeiWang",--检查是否达到福利精活的江湖威望
	CheckPayIsAction= "CheckPayIsAction",	--检查是否激活充值
	CheckIsSubPlayer= "CheckIsSubPlayer",	--判断是否是子服玩家
	
	--自动检查
	SetAwardId		= "CheckEventAward", 	--奖励表路径,param:string
	SetAwardIdUi	= "CheckEventAwardUi",	--给予界面奖励表路径,param:string	
	GoToEvent		= "CheckGoToEvent",		--事件跳转，跳转完回调回来会继续往下执行
	GoToOtherEvent	= "CheckGoToOtherEvent",--事件跳转到其他事件，跳转完回调回来会继续往下执行
	AddItem 		= "CheckAddItem",			--获得物品
	AddEquit 		= "CheckAddEquit",			--加装备(按内存中对应的表加载)
	AddBaseMoney 	= "CheckAddBaseMoney",		--生产效率绑定银两
	CoinBuyHeShiBi 	= "CheckCoinBuyHeShiBi",	--检测是否够资格购买和石壁；
	DelItem			= "CheckDelItem",			--删除物品
	AddXiulianTime 	= "CheckAddXiulianTime",	--自检增加修炼时间
	AddBindMoney	= "CheckBindMoneyMax",	  	--检查绑定银两上限
	AddMoney		= "CheckMoneyMax",		  	--检查银两上限		
	AddGlbBindMoney	= "CheckAddGlbBindMoney",	  	--检查跨服绑银上限
	CostMoney		= "CheckCostMoney",			--扣除银两
	CostBindMoney	= "CheckCostBindMoney",		--扣除绑定银两
	CostBindCoin	= "CheckCostBindCoin",		--扣除绑定金币
	CostGlbBindMoney= "CheckCostGlbBindMoney",	--扣除跨服绑银
	CostJingLi		= "CheckCostJingLi",			--扣除精力
	CostHuoLi		= "CheckCostHuoLi",			--扣除活力
	AddExBindCoinByPay 	= "CheckExBindCoinByPay",--充值领取绑金（按一定比率返回）
	AddRandomAwards		= "CheckAddRandomAwards",--随机获得奖励
	SetPayAction		= "CheckSetPayAction",	 --检查是否已激活充值
	AddNpcInNear		= "CheckAddNpcInNear",		--检查附近是不是有npc了
	DelNpc			= "CheckDelNpc",	--检查是不是有选择的npc
	AddConsume		= "CheckAddConsume",	--增加奇珍阁消耗积分
	AddZhenYuan		= "CheckAddZhenYuan",	--增加真元
		
	-- 检查	
	CheckRandom 		= "CheckRandom",		-- 检查几率
	CheckAddXiulianTime = "CheckAddXiulianTime",-- 检查增加修炼时间
	CheckTimeFrame 		= "CheckTimeFrame",     -- 检查时间轴
	CheckTimeDate		= "CheckTimeDate",		--检查开服多少天

	CheckLoginTimeSpace = "CheckLoginTimeSpace",-- 检查与上一次登陆时间间隔N小时以上
	CheckLastLoginDate	= "CheckLastLoginDate",	-- 检查上次登陆时间段时间否在指定日期内
	CheckISCanGetRepute = "CheckISCanGetRepute",-- 检查是不是激活了江湖威望的领取
	CheckDisDayTime		= "CheckDisDayTime",	-- 检查时间区间xx时xx分之间
	CheckDisDayTimeEx		= "CheckDisDayTimeEx",	-- 检查时间区间xx月xx日xx时xx分之间
	CheckLinkTaskCount	= "CheckLinkTaskCount",	-- 检查义军任务次数是否大于等于某值
	--CoinBuyItem 		= "CheckCoinBuyItem",	-- 检测是否够资格购买奇珍阁道具的资格；
	CheckSpeTitle		= "CheckSpeTitle",		-- 检查是否有特殊称号
	CheckRoute			= "CheckRoute",			-- 检查门派路线
	CheckTodayJoinKinGame		= "CheckTodayJoinKinGame",			-- 检查今天是否参加了家族关卡
	CheckSongJinBattleCount		= "CheckSongJinBattleCount",			-- 检查今天是否参加了家族关卡
	CheckKinLead		= "CheckKinLead",		--检查在家族中的地位
	CheckKinMember	= "CheckKinMember",	--检查家族人数是否达到多少个
	CheckOnlineTime	= "CheckOnlineTime",	--检查玩家在线时间是否达到多少秒
	CheckRoleCreateDate	= "CheckRoleCreateDate",	--检查玩家建立角色的时间在某个日期之内
	CheckExtPoint			= "CheckExtPoint",			--判断4号扩展点（越南ip bonus）	
	CheckPayCardValue	= "CheckPayCardValue",		--检查玩家剩余可用的冲值额度
	CheckEventTimes		= "CheckEventTimes",	--检查活动玩家参加或者完成次数
	CheckJoinEvent		= "CheckJoinEvent",		--检查玩家是否参加或者完成某些活动
	CheckXoYoGameGrade	= "CheckXoYoGameGrade", --检查逍遥谷名次
	CheckDailyJoinGuessGame			= "CheckDailyJoinGuessGame",		-- 检查今日是否参加过灯谜活动，条件是领取过奖励的都算
	CheckDailyJoinBaiHuTangCount	= "CheckDailyJoinBaiHuTangCount",	-- 检查今日参加白虎堂次数
	CheckDailyJoinMenPaiJingJi		= "CheckDailyJoinMenPaiJingJi",		-- 检查今天是否参加过门派竞技
	CheckDailyJoinArmyCampCount		= "CheckDailyJoinArmyCampCount",	-- 检查今天参加门派竞技的次数
	CheckDailyJoinXoyoGame			= "CheckDailyJoinXoyoGame",			-- 检查今天是否参加过逍遥谷
	CheckDailyJoinLingTuBattle		= "CheckDailyJoinLingTuBattle",		-- 检查今天是否参加过领土战
	CheckDailyJoinWllsCount			= "CheckDailyJoinWllsCount",		-- 检查今天参加联赛次数
	CheckDailyJoinJiaZuJIngjiCount	= "CheckDailyJoinJiaZuJIngjiCount",	-- 检查今天参加家族竞技次数
	CheckMonthJoinWllsCount			= "CheckMonthJoinWllsCount",		-- 检查本月参加武林联赛次数
	CheckMonthJoinJiaZuJIngjiCount	= "CheckMonthJoinJiaZuJIngjiCount",	-- 检查本月参加家族竞技次数
	CheckMonthJoinWllsPoint			= "CheckMonthJoinWllsPoint",		-- 检查本月联赛积分
	CheckMonthJoinJiaZuJingjiPoint	= "CheckMonthJoinJiaZuJingjiPoint",	-- 检查本月家族竞技积分
	CheckActiveNum	= "CheckActiveNum",		--检查活跃度值
};

--和玩家无关的检查，无需保证当前me为玩家
tbFun.tbLimitParamFunWithOutPlayer =
{
	CheckLuaScriptNoMe  = "CheckLuaScript",	--设置脚本
	CheckGDate			= "CheckGDate",		--活动总时间判断YYYYmmddHHMM或YYYYmmdd
	CheckWeek			= "CheckWeek",		--检查周几
	CheckWeekEx			= "CheckWeekEx",		--周几到周几之间判断
	
}

--条件判断 START----------------------------

--表，类型(nCheckType -  nil:普通的检查,检查函数都执行;  1:选项检查函数,选项变灰使用 2:表示eventId partId找不到时不报错) 
function tbFun:CheckParam(tbParam, nCheckType)
	if tbParam== nil then
		tbParam = {};
	end
	
	local nFlagW, szMsgW = self:CheckParamWithOutPlayer(tbParam, nCheckType);
	if nFlagW ~= 0 then
		return nFlagW, szMsgW;
	end
	
	local tbTaskPacth = self:GetParam(tbParam, "SetTaskBatch", 1);
	local nTaskPacth = 0;
	for _, nT in pairs(tbTaskPacth) do
		local nTempId = tonumber(nT) or 0;
		if nTempId > nTaskPacth then
			nTaskPacth = nTempId
		end
	end
	local nFlag = nil;
	if nCheckType == 2 then
		nFlag = 1;
	end
	local nEventId 	= tonumber(self:GetParam(tbParam, "__nEventId",nFlag)[1]);
	local nPartId 	= tonumber(self:GetParam(tbParam, "__nPartId",nFlag)[1]);	
	EventManager:GetTempTable().BASE_nTaskBatch = nTaskPacth;
	EventManager:GetTempTable().CurEventId = nEventId;
	EventManager:GetTempTable().CurPartId  = nPartId;
	local nReFlag = 0;
	local szReMsg = nil;	
	for nParam, szParam in ipairs(tbParam) do
		local nSit = string.find(szParam, ":");
		if nSit and nSit > 0 then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if self.tbLimitParamFun[szFlag] ~= nil then
				local fncExcute = self[self.tbLimitParamFun[szFlag]];
				if fncExcute then
					local nFlag, szMsg = fncExcute(self, szContent, tbParam, nCheckType, nTaskPacth);
					if nFlag and nFlag ~= 0 then
						nReFlag = nFlag;
						szReMsg = szMsg;
						break;
						--条件不符合.
					end;
				end
			end
		end
	end
	EventManager:GetTempTable().BASE_nTaskBatch = 0;
	EventManager:GetTempTable().nCurEventId = 0;
	EventManager:GetTempTable().nCurPartId  = 0;
	return nReFlag, szReMsg;
end

function tbFun:CheckParamWithOutPlayer(tbParam, nCheckType)
	if tbParam== nil then
		tbParam = {};
	end
	local tbTaskPacth = self:GetParam(tbParam, "SetTaskBatch", 1);
	local nTaskPacth = 0;
	for nParam, szParam in ipairs(tbParam) do
		local nSit = string.find(szParam, ":");
		if nSit and nSit > 0 then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if self.tbLimitParamFunWithOutPlayer[szFlag] ~= nil then
				local fncExcute = self[self.tbLimitParamFunWithOutPlayer[szFlag]];
				if fncExcute then
					local nFlag, szMsg = fncExcute(self, szContent, tbParam, nCheckType, nTaskPacth);
					if nFlag and nFlag ~= 0 then
						return nFlag, szMsg;
						--条件不符合.
					end;
				end
			end
		end
	end
	return 0;
end

-- tbNotParam = { 是放置不需要判断的函数
--	["CheckFreeBag"] = 1,	
--};
function tbFun:CheckParamEx(tbParam, tbNeedParam, nCheckType)
	if tbParam== nil then
		tbParam = {};
	end
	
	local nFlagW, szMsgW = self:CheckParamWithOutPlayer(tbParam, nCheckType);
	if nFlagW ~= 0 then
		return nFlagW, szMsgW;
	end
	
	tbNeedParam = tbNeedParam or {};
	
	local tbTaskPacth = self:GetParam(tbParam, "SetTaskBatch", 1);
	local nTaskPacth = 0;
	for _, nT in pairs(tbTaskPacth) do
		local nTempId = tonumber(nT) or 0;
		if nTempId > nTaskPacth then
			nTaskPacth = nTempId
		end
	end
	local nFlag = nil;
	if nCheckType == 2 then
		nFlag = 1;
	end
	local nEventId 	= tonumber(self:GetParam(tbParam, "__nEventId",nFlag)[1]);
	local nPartId 	= tonumber(self:GetParam(tbParam, "__nPartId",nFlag)[1]);	
	EventManager:GetTempTable().BASE_nTaskBatch = nTaskPacth;
	EventManager:GetTempTable().CurEventId = nEventId;
	EventManager:GetTempTable().CurPartId  = nPartId;
	local nReFlag = 0;
	local szReMsg = nil;	
	for nParam, szParam in ipairs(tbParam) do
		local nSit = string.find(szParam, ":");
		if nSit and nSit > 0 then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if self.tbLimitParamFun[szFlag] ~= nil and tbNeedParam[szFlag] then
				local fncExcute = self[self.tbLimitParamFun[szFlag]];
				if fncExcute then
					local nFlag, szMsg = fncExcute(self, szContent, tbParam, nCheckType, nTaskPacth);
					if nFlag and nFlag ~= 0 then
						nReFlag = nFlag;
						szReMsg = szMsg;
						break;
						--条件不符合.
					end;
				end
			end
		end
	end
	EventManager:GetTempTable().BASE_nTaskBatch = 0;
	EventManager:GetTempTable().nCurEventId = 0;
	EventManager:GetTempTable().nCurPartId  = 0;
	return nReFlag, szReMsg;
end

--TaskDay:MaxCount, TaskId1, TaskId1	--每天最多只能领取MaxCount次:需要2个任务变量
function tbFun:CheckTaskDay(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam = self:SplitStr(szParam);
	
	local nMaxCount = tonumber(tbParam[1]);
	local nTaskId1 = tonumber(tbParam[2]);
	local nTaskId2 = tonumber(tbParam[3]);
	local szReturnMsg = tbParam[4] or "你今天参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[5]) or 0;
	
	local nTask1 = EventManager:GetTask(nTaskId1, nTaskPacth);
	local nTask2 = EventManager:GetTask(nTaskId2, nTaskPacth);
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	if (nNowDay > nTask2) then
		EventManager:SetTask(nTaskId1, 0);
		EventManager:SetTask(nTaskId2, nNowDay);
	end
	nTask1 = EventManager:GetTask(nTaskId1, nTaskPacth);
	if nTask1 >= nMaxCount and nMaxCount ~= 0 then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

--Task:MaxCount;TaskId									--整次活动只能领取MaxCount次;需要1个任务变量
function tbFun:CheckTask(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam = self:SplitStr(szParam);

	local nMaxCount = tonumber(tbParam[2]);
	local nTaskId1  = tonumber(tbParam[1]);
	local szReturnMsg = tbParam[3] or "你参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	local nTask1 = EventManager:GetTask(nTaskId1, nTaskPacth);
	if nTask1 >= nMaxCount then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckTaskDateMsg(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam = self:SplitStr(szParam);

	local nMaxCount = tonumber(tbParam[2]);
	local nTaskId1  = tonumber(tbParam[1]);
	local szReturnMsg = tbParam[3] or "你参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	local nTask1 = EventManager:GetTask(nTaskId1, nTaskPacth);
	local szDateMsg = os.date("<color=yellow>%Y年%m月%d日 %H时%M分<color>", nTask1);
	szReturnMsg = string.format(szReturnMsg, szDateMsg);
	if nTask1 >= nMaxCount then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckTaskLt(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam = self:SplitStr(szParam);

	local nMaxCount = tonumber(tbParam[2]);
	local nTaskId1  = tonumber(tbParam[1]);
	local szReturnMsg = tbParam[3] or "你参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	local nTask1 = EventManager:GetTask(nTaskId1, nTaskPacth);
	if nTask1 < nMaxCount and nMaxCount ~= 0 then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;	
end

function tbFun:CheckTaskEq(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam = self:SplitStr(szParam);

	local nMaxCount = tonumber(tbParam[2]);
	local nTaskId1  = tonumber(tbParam[1]);
	local szReturnMsg = tbParam[3] or "你参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	local nTask1 = EventManager:GetTask(nTaskId1, nTaskPacth);
	if nTask1 ~= nMaxCount then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end


--TaskDay:MaxCount, TaskId1, TaskId1	--每天最多只能领取MaxCount次:需要2个任务变量
function tbFun:CheckGTaskDay(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam = self:SplitStr(szParam);
	
	local nMaxCount = tonumber(tbParam[1]);
	local nGroupId = tonumber(tbParam[2]); 
	local nTaskId1 = tonumber(tbParam[3]);
	local nTaskId2 = tonumber(tbParam[4]);
	local szReturnMsg = tbParam[5] or "你今天参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[6]) or 0;
	
	local nTask1 = me.GetTask(nGroupId, nTaskId1);
	local nTask2 = me.GetTask(nGroupId, nTaskId2);
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	if (nNowDay > nTask2) then
		me.SetTask(nGroupId, nTaskId1, 0);
		me.SetTask(nGroupId, nTaskId2, nNowDay);
	end
	nTask1 = me.GetTask(nGroupId, nTaskId1);
	if nTask1 >= nMaxCount and nMaxCount ~= 0 then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

--Task:MaxCount;TaskId									--整次活动只能领取MaxCount次;需要1个任务变量
function tbFun:CheckGTask(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	
	local nGroupId  = tonumber(tbParam[1]);
	local nTaskId1  = tonumber(tbParam[2]);
	local nMaxCount = tonumber(tbParam[3]);
	local szReturnMsg = tbParam[4] or "你参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[5]) or 0;
	local nTask1 = me.GetTask(nGroupId, nTaskId1);
	if nTask1 >= nMaxCount and nMaxCount ~= 0 then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckGTaskLt(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	
	local nGroupId  = tonumber(tbParam[1]);
	local nTaskId1  = tonumber(tbParam[2]);
	local nMaxCount = tonumber(tbParam[3]);
	local szReturnMsg = tbParam[4] or "你参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[5]) or 0;
	local nTask1 = me.GetTask(nGroupId, nTaskId1);
	if nTask1 < nMaxCount and nMaxCount ~= 0 then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;	
end

function tbFun:CheckGTaskEq(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	
	local nGroupId  = tonumber(tbParam[1]);
	local nTaskId1  = tonumber(tbParam[2]);
	local nMaxCount = tonumber(tbParam[3]);
	local szReturnMsg = tbParam[4] or "你参加的次数已达上限";
	local nEventPartId 	= tonumber(tbParam[5]) or 0;
	local nTask1 = me.GetTask(nGroupId, nTaskId1);
	if nTask1 ~= nMaxCount then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end



--
function tbFun:CheckMonthPay(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nMonthPayLimit = tonumber(tbParam[1]) or 0;
	local szReturnMsg 	= tbParam[2];
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if not nMonthPayLimit then
		print("【活动系统出错】MonthPay参数不对。");
		return 1;
	end
	szReturnMsg = szReturnMsg or string.format("您当月累计%s为<color=yellow>%s%s<color>，当月累计%s达到<color=yellow>%s%s<color>才能参加本次活动。", IVER_g_szPayName, me.GetExtMonthPay(1), IVER_g_szPayUnit, IVER_g_szPayName, nMonthPayLimit * IVER_g_nPayDouble, IVER_g_szPayUnit);
	if me.GetExtMonthPay() < nMonthPayLimit then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckMonthPay_VN(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nMonthPayLimit = tonumber(tbParam[1]) or 0;
	local szReturnMsg 	= tbParam[2];
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if not nMonthPayLimit then
		print("【活动系统出错】MonthPay参数不对。");
		return 1;
	end
	szReturnMsg = szReturnMsg or string.format("您当月累计%s为<color=yellow>%s%s<color>，当月累计%s达到<color=yellow>%s%s<color>才能参加本次活动。", IVER_g_szPayName, me.GetExtMonthPay(1), IVER_g_szPayUnit, IVER_g_szPayName, nMonthPayLimit * IVER_g_nPayDouble, IVER_g_szPayUnit);
	if me.GetExtMonthPay_VN() < nMonthPayLimit then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckGDate(szParam)
	local tbParam = Lib:SplitStr(szParam, ",");
	local nStartDate = tonumber(tbParam[1]);
	local nEndDate = tonumber(tbParam[2]);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nStartDate == -1 then
		return 1, "本活动已经暂时关闭。";
	end
	if nStartDate == 0 and nEndDate == 0 then
		return 0;
	end
	if nStartDate == 0 and nEndDate ~= 0 then
		if nEndDate < nNowDate then
			return 1, "本活动已经结束。";
		end
	end
	if nStartDate ~= 0 and nEndDate == 0 then
		if nStartDate > nNowDate then
			return 1, "本活动还没开始。";
		end
	end
	if nStartDate ~= 0 and nEndDate ~= 0 then
		if nNowDate < nStartDate or nNowDate > nEndDate then
			return 1, "不在活动期间。";
		end
	end 
	return 0;
end

function tbFun:CheckLevel(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);

	local nLevelParam = tonumber(tbParam[1]);
	local szReturnMsg = tbParam[2];
	if not tbParam[2] or tbParam[2] == "" then
		szReturnMsg = tbParam[2] or string.format("您的等级没达到要求，需要达到%s级。", nLevelParam);
	end
	
	
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.nLevel < nLevelParam then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckAboveLevel(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);

	local nLevelParam = tonumber(tbParam[1]);
	local szReturnMsg = tbParam[2];
	if not tbParam[2] or tbParam[2] == "" then
		szReturnMsg = tbParam[2] or string.format("您的等级没达到要求，需要低于%s级。", nLevelParam);
	end
	
	
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.nLevel >= nLevelParam then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckFaction(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szReturnMsg = tbParam[2] or "您的门派不满足要求。";
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.nFaction == tonumber(tbParam[1]) then
		return 0;
	elseif me.nFaction ~= 0 and tonumber(tbParam[1]) == 13 then
		return 0;
	end
	return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
end

function tbFun:CheckCamp(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szReturnMsg = tbParam[2] or "您的阵营不满足要求。";
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.GetCamp() == tonumber(tbParam[1]) then
		return 0;
	end
	return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);	
end

function tbFun:CheckWeek(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szReturnMsg = tbParam[2] or "现在不是活动期间。";
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if tonumber(GetLocalDate("%w")) == tonumber(tbParam[1]) then
		return 0;
	end
	return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
end

function tbFun:CheckWeekEx(szParam)
	local tbParam = self:SplitStr(szParam);
	local nStartDate = tonumber(tbParam[1]) or 0;
	local nEndDate = tonumber(tbParam[2]) or 0;
	local szReturnMsg = tbParam[3] or "现在不是活动期间。";
	local nNowDate = tonumber(GetLocalDate("%w"));	
	if nNowDate == 0 then
		nNowDate = 7;
	end
	if nNowDate >= nStartDate and nNowDate <= nEndDate then
		return 0;
	end
	--if nNowDate < nStartDate or nNowDate > nEndDate then
	return 1, szReturnMsg;
	--end	
	--return 0;
end

function tbFun:CheckEventAward(nParam)
	nParam = tonumber(nParam);
	if not nParam then
		return 1, "奖励表不存在";
	end
	if not self.AwardList[nParam] then
		return 1, "奖励表不存在";
	end

	local nCount = 0;
	local nMoney = 0;
	local nBindMoney = 0;
	for ni, tbItem in ipairs(self.AwardList[nParam].tbAward) do
		if tbItem.nRandRate == 0 and tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			if tbItem.nNeedBagFree > 0 then
				nCount = nCount + tbItem.nNeedBagFree;
			else
				nCount = nCount + tbItem.nAmount;
			end
		end
		if tbItem.nRandRate == 0 and tbItem.nJxMoney > 0 then
			nMoney = nMoney + tbItem.nJxMoney;
		end
		if tbItem.nRandRate == 0 and tbItem.nJxBindMoney > 0 then
			nBindMoney = nBindMoney + tbItem.nJxBindMoney;
		end		
	end
	
	if nBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		return 1, "你的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。";
	end
	
	if nMoney + me.nCashMoney > me.GetMaxCarryMoney() then
		return 1, "你的身上的银两即将达到上限，请清理一下身上的银两。";
	end	
	
	local nCFlag, szCMsg = self:_CheckItemFree(me, nCount)
	if nCFlag == 1 then
		return 1, szCMsg;
	end	
	
	for ni, tbItem in ipairs(self.AwardList[nParam].tbMareial) do
		local nFlag, szMsg = self:_CheckItem(me, tbItem)
		if nFlag == 1 then
			return 1, szMsg;
		end
	end
	
	return 0;
end

function tbFun:CheckEventAwardUi(szParam)
	local tbParam = self:SplitStr(szParam);
	local nParam = tonumber(tbParam[1]);
	if not nParam then
		return 1, "奖励表不存在";
	end
	if not self.AwardList[nParam] then
		return 1, "奖励表不存在";
	end

	local nCount = 0;
	local nMoney = 0;
	local nBindMoney = 0;
	for ni, tbItem in ipairs(self.AwardList[nParam].tbAward) do
		if tbItem.nRandRate == 0 and tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			local tbItemInfo = {};
			if self:TimerOutCheck(tbItem.szTimeLimit) == 1 then
				tbItemInfo.bTimeOut = 1;
			end
			
			if tbItem.nBind > 0 then
				tbItemInfo.bForceBind = tbItem.nBind;
			end			
			local nFreeCount = KItem.GetNeedFreeBag(tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel, tbItemInfo, (tbItem.nAmount or 1))
			nCount = nCount + nFreeCount;
		end
		if tbItem.nRandRate == 0 and tbItem.nJxMoney > 0 then
			nMoney = nMoney + tbItem.nJxMoney;
		end
		if tbItem.nRandRate == 0 and tbItem.nJxBindMoney > 0 then
			nBindMoney = nBindMoney + tbItem.nJxBindMoney;
		end	
	end
	
	if nBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		return 1, "你的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。";
	end
	
	if nMoney + me.nCashMoney > me.GetMaxCarryMoney() then
		return 1, "你的身上的银两即将达到上限，请清理一下身上的银两。";
	end	
	
	local nCFlag, szCMsg = self:_CheckItemFree(me, nCount)
	if nCFlag == 1 then
		return 1, szCMsg;
	end
	
	for ni, tbItem in ipairs(self.AwardList[nParam].tbMareial) do
		local nFlag, szMsg = self:_CheckItem1(me, tbItem)
		if nFlag == 1 then
			return 1, szMsg;
		end
	end
	return 0;
end

function tbFun:_CheckItem(pPlayer, tbItem)
	if tbItem.nJxMoney ~= 0 then
		if pPlayer.nCashMoney < tbItem.nJxMoney then
			return 1, "对不起，您身上的银两不足。";
		end
	end
	
	if tbItem.nJxBindMoney ~= 0 then
		if pPlayer.GetBindMoney() < tbItem.nJxBindMoney then
			return 1, "对不起，您身上的银两不足。";
		end
	end
	
	if tbItem.nJxCoin ~= 0 then
		if pPlayer.nBindingCoinMoney < tbItem.nJxCoin then
			return 1, string.format("对不起，您的绑定%s不足。", IVER_g_szCoinName);
		end
	end
	
	if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
		local nCount = pPlayer.GetItemCountInBags(tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel, tbItem.nSeries);
		if nCount < tbItem.nAmount then
			return 1, "对不起，您的物品不足。";
		end
	end	
	return 0;
end

function tbFun:_CheckItem1(pPlayer, tbItem)
	if tbItem.nJxMoney ~= 0 then
		if pPlayer.nCashMoney < tbItem.nJxMoney then
			return 1, "对不起，您身上的银两不足。";
		end
	end
	
	if tbItem.nJxBindMoney ~= 0 then
		if pPlayer.GetBindMoney() < tbItem.nJxBindMoney then
			return 1, "对不起，您身上的银两不足。";
		end
	end
	
	if tbItem.nJxCoin ~= 0 then
		if pPlayer.nBindingCoinMoney < tbItem.nJxCoin then
			return 1, string.format("对不起，您的绑定%s不足。", IVER_g_szCoinName);
		end
	end
	return 0;
end

function tbFun:_CheckItemFree(pPlayer, nCount)
	if nCount > 0 and pPlayer.CountFreeBagCell() < nCount then
		return 1, string.format("对不起，您身上的背包空间不足，需要%s格背包空间。", nCount);
	end
	return 0;
end

function tbFun:CheckWeiWang(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nWeiWangLimit = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tonumber(tbParam[2]) or string.format("您的江湖威望不足%s点，不能参加本次活动。", nWeiWangLimit);
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.nPrestige < nWeiWangLimit then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckAddItem(szParam)
	local tbParam 	= self:SplitStr(szParam);
	local tbItem 	= self:SplitStr(tbParam[1]);
	local nG	  	= tonumber(tbItem[1]) or 0;
	local nD		= tonumber(tbItem[2]) or 0;
	local nP		= tonumber(tbItem[3]) or 0;
	local nL		= tonumber(tbItem[4]) or 0;
	local nCount	= tonumber(tbParam[2]) or 0;
	local nBind		= tonumber(tbParam[3]) or 0;
	local nTimeOut	= tonumber(tbParam[4] or 0);
	if nG > 0 and nD > 0 and nP > 0 and nL > 0 then
		local nNeed = KItem.GetNeedFreeBag(nG, nD, nP, nL, {bTimeOut=nTimeOut}, nCount);
		if me.CountFreeBagCell() < nNeed then
			return 1, string.format("对不起，您身上的背包空间不足，需要%s格背包空间。", nNeed);
		end
	end
	return 0;
end

function tbFun:CheckAddEquit(szParam)
	local tbParam 	= self:SplitStr(szParam);
	local nFaction	= tonumber(tbParam[1]) or 0;
	local nRouteId	= tonumber(tbParam[2]) or 0;
	local nSex	= tonumber(tbParam[3]) or 0;
	local nPartId= tonumber(tbParam[4]) or -1;
	local nBind	= tonumber(tbParam[5]) or 1;	
	local nTimeOut	= tonumber(tbParam[6]) or 0;	
	local nEnhanceTime = tonumber(tbParam[7]) or 0;
	if nFaction == 0 then
		nFaction = me.nFaction;
	end
	if nRouteId == 0 then
		nRouteId = me.nRouteId;
	end
	if nSex <= 0 then
		nSex = me.nSex + 1;
	end
	
	if nEnhanceTime < 0 and nEnhanceTime > 16 then
		return 1, "error nEnhanceTime";
	end
	
	local tbAward = {};
	if not EventManager.tbOther.tbEquitList or not EventManager.tbOther.tbEquitList[nFaction] or not EventManager.tbOther.tbEquitList[nFaction][nRouteId] or 
	    not EventManager.tbOther.tbEquitList[nFaction][nRouteId][nSex] then
		print("【活动系统出错】装备表不存在。");
		return 1; 
	end
	tbAward = EventManager.tbOther.tbEquitList[nFaction][nRouteId][nSex];
	if nPartId > 0 then
		if me.CountFreeBagCell() < 1 then
			return 1, "对不起，您身上的背包空间不足，需要1格背包空间。";
		end
	elseif nPartId == 0 then
		if me.CountFreeBagCell() < #tbAward then
			return 1, string.format("对不起，您身上的背包空间不足，需要%s格背包空间。", #tbAward);
		end
	end
	return 0;
end

function tbFun:CheckFreeBag(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nCount	= tonumber(tbParam[1]);
	local szReturnMsg = tbParam[2] or string.format("对不起，您身上的背包空间不足，需要%s格背包空间。", nCount);
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.CountFreeBagCell() < nCount then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckBindMoneyMax(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nCount	= tonumber(tbParam[1]);
	local szReturnMsg = tbParam[2] or string.format("对不起，您身上的绑定银两将达上限，请先整理身上的绑定银两。");
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.GetBindMoney() + nCount > me.GetMaxCarryMoney() then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckMoneyMax(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nCount	= tonumber(tbParam[1]);
	local szReturnMsg = tbParam[2] or string.format("对不起，您身上的银两将达上限，请先整理身上的银两。");
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if me.nCashMoney + nCount > me.GetMaxCarryMoney() then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckAddGlbBindMoney(szParam, tbGParam)
	local tbParam 		= self:SplitStr(szParam);
	local nValue		= tonumber(tbParam[1]) or 0;
	local szReturnMsg 	= tbParam[2] or string.format("对不起，您身上的跨服专用银两将达上限，请先整理身上的跨服专用银两。");
	if GLOBAL_AGENT then
		if me.nBindMoney + nValue > me.GetMaxCarryMoney() then
			return 1, szReturnMsg;
		end
	end
	if not GLOBAL_AGENT then
		local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
		if nCurrentMoney + nValue > me.GetMaxCarryMoney() then
			return 1, szReturnMsg;
		end
	end
	return 0;
end

function tbFun:CheckMoneyHonor(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nHonor	= tonumber(tbParam[1]);
	local szReturnMsg = tbParam[2] or string.format("对不起，您的财富荣誉没达到%s点。", nHonor);
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if PlayerHonor:GetPlayerHonorByName(me.szName, 8, 0)< nHonor then
		EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		return 1, szReturnMsg;
	end	
	return 0;
end

function tbFun:CheckHonorGrade(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nHonor	= tonumber(tbParam[1]);
	local nType = tonumber(tbParam[2]) or 1;
	local szReturnMsg = tbParam[3] or "对不起，您的荣誉等级没达到需求的等级。";	
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	if nType == 1 and me.GetHonorLevel() >= nHonor then
		return 0;		
	end
	if nType == 2 and me.GetHonorLevel() == nHonor then
		return 0;	
	end
	if nType == 3 and me.GetHonorLevel() <= nHonor then
		return 0;	
	end
	EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	return 1, szReturnMsg;
end

function tbFun:CheckMantleLevel(szParam, tbGParam)	
	local tbParam 	= self:SplitStr(szParam);
	local nLevel	= tonumber(tbParam[1]);	
	local nType = tonumber(tbParam[2]) or 1;
	local szReturnMsg = tbParam[3] or "对不起，您身上的披风没有达到需求的等级。";
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if nType == 1 and pItem and pItem.nLevel >= nLevel  then
		return 0;
	end
	if nType == 2 and pItem and pItem.nLevel == nLevel then
		return 0;	
	end
	if nType == 3 and pItem and pItem.nLevel <= nLevel then
		return 0;	
	end	
	EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	return 1, szReturnMsg;	
end

function tbFun:CheckChopLevel(szParam, tbGParam)
	local tbName = {"知事", "司马", "太守", "少卿", "上卿", "国公", "丞相", "皇帝"}
	local tbParam 	= self:SplitStr(szParam);
	local nLevel	= tonumber(tbParam[1]) or 0;	
	if nLevel <= 0 or nLevel > #tbName then
		return 1, "异常情况";
	end
	local szReturnMsg = tbParam[2] or string.format("对不起，您身上的官印没有达到%s官印。", tbName[nLevel]);
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_CHOP, 0);
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if not pItem or pItem.nLevel < nLevel then		
		EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		return 1, szReturnMsg;
	end	
	return 0;
end

function tbFun:CheckMaskType(szParam, tbGParam)	
	local tbParam 	= self:SplitStr(szParam);
	local szGDPL	= tbParam[1] or "";	
	if szGDPL == "" then
		return 1, "异常情况";
	end
	local szReturnMsg = tbParam[2] or "对不起，您身上没有佩戴需求的面具。";
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MASK, 0);
	local nEventPartId 	= tonumber(tbParam[3]) or 0;	
	if not pItem then
		EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		return 1, szReturnMsg;
	end
	local szItemGDPL = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	if szItemGDPL ~= szGDPL then
		EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckSex(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nSex = tonumber(tbParam[1]);
	local szReturnMsg = tbParam[2] or string.format("对不起，只有%s玩家才能领取。", Env.SEX_NAME[nSex]);
	local nEventPartId 	= tonumber(tbParam[3]) or 0;
	if not Env.SEX_NAME[nSex] then
		print("【活动系统】Sex参数错误");
		return 1;
	end
	if nSex ~= me.nSex then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckExt(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nBit		= tonumber(tbParam[1]);
	local nExt 		= tonumber(tbParam[2]);
	local szReturnMsg = tbParam[3] or "你的帐号已经被激活";
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	if me.GetActiveValue(nBit) ~= nExt then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckItemInBag(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local szItem 	= tbParam[1];
	local nCount 	= tonumber(tbParam[2]) or 1;
	local bInOrOut 	= tonumber(tbParam[3]) or 0;
	local szReturnMsg 	= tbParam[4] or string.format("你拥有的%s不满足要求。", KItem.GetNameById(unpack(tbItem)));
	local nEventPartId 	= tonumber(tbParam[5]) or 0;	
	local tbItem 	= self:SplitStr(szItem);
	local nBagCount = me.GetItemCountInBags(unpack(tbItem)) or 0;
	if bInOrOut == 0 then
		if nBagCount < nCount then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	else
		if nBagCount >= nCount then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end
	return 0;
end

function tbFun:CheckItemInAll(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local szItem 	= tbParam[1];
	local nCount 	= tonumber(tbParam[2]);
	local bInOrOut 	= tonumber(tbParam[3]) or 0;
	local szReturnMsg 	= tbParam[4];
	local nEventPartId 	= tonumber(tbParam[5]) or 0;	
	local tbItem 	= self:SplitStr(szItem);
	local tbFind = me.FindItemInBags(unpack(tbItem));
	local tbFind2 = me.FindItemInRepository(unpack(tbItem));
	if bInOrOut == 0 then
		if #tbFind + #tbFind2 <  nCount then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	else
		if #tbFind + #tbFind2 >=  nCount then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end
	return 0;
end

function tbFun:CheckInMapType(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local szType 	= tbParam[1];
	local bInOrOut 	= tonumber(tbParam[2]) or 0;
	local szReturnMsg 	= tbParam[3];
	local nEventPartId 	= tonumber(tbParam[4]) or 0;	
	
	local nMapIndex = SubWorldID2Idx(me.nMapId);
	local nMapTemplateId = SubWorldIdx2MapCopy(nMapIndex);
	local szMapType = GetMapType(nMapTemplateId);
	if bInOrOut == 0 then	--必须在szType类型的地图
		if szType ~= szMapType then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	else
		if szType == szMapType then --必须不在szType类型的地图
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end	
	end

	return 0;
end

function tbFun:CheckInMapLevel(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nLevel 	= tbParam[1];
	local bInOrOut 	= tonumber(tbParam[2]) or 0;
	local szReturnMsg 	= tbParam[3];
	local nEventPartId 	= tonumber(tbParam[4]) or 0;	
	
	local nMapIndex = SubWorldID2Idx(me.nMapId);
	local nMapTemplateId = SubWorldIdx2MapCopy(nMapIndex);
	local nMapLevel = GetMapLevel(nMapTemplateId);
	if bInOrOut == 0 then --必须在nMapLevel等级以上的地图（包括nMapLevel）
		if nMapLevel < nLevel then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	elseif bInOrOut == 1 then --必须等于nMapLevel等级的地图
		if nMapLevel ~= nLevel then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end		
	else
		--必须小于nMapLevel等级的地图（不包括nMapLevel）
		if nMapLevel >= nLevel then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end

	return 0;
end


function tbFun:CheckDialogNpcAtNear(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local szReturnMsg 	= tbParam[1] or string.format("你附近有%s在，必须附近没有其他对话npc才行", pNpc.szName);
	local nEventPartId 	= tonumber(tbParam[2]) or 0;	
	
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end
	return 0;
end


function tbFun:CheckNpcAtNear(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nNpcId 	= tonumber(tbParam[1]) or 0;
	local bBeLong 	= tonumber(tbParam[2]) or 0;
	local szReturnMsg 	= tbParam[3] or "你附近找不到你想要的npc";
	local nEventPartId 	= tonumber(tbParam[4]) or 0;	
	local nFind = 0;
	local tbNpcList = KNpc.GetAroundNpcList(me, 20);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == nNpcId then
			if bBeLong == 1 then
				if pNpc.GetTempTable("Npc").EventManager then
					if pNpc.GetTempTable("Npc").EventManager.nBeLongPlayerId == me.nId then
						nFind = 1;
						break
					end
				end
			else
				nFind = 1;
				break;
			end
		end
	end	
	if nFind == 0 then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
	end
	return 0;
end

function tbFun:CheckTaskCurTime(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam 	= self:SplitStr(szParam);
	local nTaskId 	= tonumber(tbParam[1]) or 0;
	local nSec 		= tonumber(tbParam[2]) or 0;
	local nType 	= tonumber(tbParam[3]) or 0;
	local szReturnMsg 	= tbParam[4] or "";
	local nEventPartId 	= tonumber(tbParam[5]) or 0;	
	if EventManager:GetTask(nTaskId, nTaskPacth) == 0 then
		return 0;
	end
	if nType == 0 then --如果在n秒内的情况，不满足
		if EventManager:GetTask(nTaskId, nTaskPacth) + nSec > GetTime() then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end
	if nType == 1 then --如果在n秒外的情况，不满足
		if EventManager:GetTask(nTaskId, nTaskPacth) + nSec < GetTime() then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end
	return 0;
end

--跳转，不往下执行
function tbFun:CheckTaskGotoEvent(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam 	= self:SplitStr(szParam);
	local nTaskId 	= tonumber(tbParam[1]) or 0;
	local nValue 	= tonumber(tbParam[2]) or 0;
	local nType 	= tonumber(tbParam[3]) or 0;
	local nEventPartId 	= tonumber(tbParam[4]) or 0;
	local nEventId 	= tonumber(self:GetParam(tbGParam, "__nEventId")[1]);
	local nPartId 	= tonumber(self:GetParam(tbGParam, "__nPartId")[1]);
	if nEventPartId == nPartId then
		print("【活动系统】Error!!!CheckTaskGotoEvent重复调用自己");
		return 0;
	end
	if nType == 0 then--等于
		if EventManager:GetTask(nTaskId, nTaskPacth) == nValue then
			return EventManager:GotoEventPartTable(nEventId, nEventPartId, nCheckType, nil, 2);
		end
	end
	if nType == 1 then--小于
		if EventManager:GetTask(nTaskId, nTaskPacth) < nValue then
			return EventManager:GotoEventPartTable(nEventId, nEventPartId, nCheckType, nil, 2);
		end
	end
	if nType == 2 then--大于
		if EventManager:GetTask(nTaskId, nTaskPacth) > nValue then
			return EventManager:GotoEventPartTable(nEventId, nEventPartId, nCheckType, nil, 2);
		end		
	end	
	return 0;
end

function tbFun:CheckGTaskCurTime(szParam, tbGParam)
	local tbParam 	= self:SplitStr(szParam);
	local nGroupId 	= tonumber(tbParam[1]) or 0;
	local nTaskId 	= tonumber(tbParam[2]) or 0;
	local nSec 		= tonumber(tbParam[3]) or 0;
	local nType 	= tonumber(tbParam[4]) or 0;
	local szReturnMsg 	= tbParam[5] or "";
	local nEventPartId 	= tonumber(tbParam[6]) or 0;	
	if me.GetTask(nGroupId, nTaskId) == 0 then
		return 0;
	end
	if nType == 0 then --如果在n秒内的情况，不满足
		if me.GetTask(nGroupId, nTaskId) + nSec > GetTime() then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end
	if nType == 1 then --如果在n秒外的情况，不满足
		if me.GetTask(nGroupId, nTaskId) + nSec < GetTime() then
			return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam);
		end
	end
	return 0;
end

function tbFun:CheckGTaskGotoEvent(szParam, tbGParam, nCheckType)
	local tbParam 	= self:SplitStr(szParam);
	local nGroupId 	= tonumber(tbParam[1]) or 0;
	local nTaskId 	= tonumber(tbParam[2]) or 0;
	local nValue 	= tonumber(tbParam[3]) or 0;
	local nType 	= tonumber(tbParam[4]) or 0;
	local nEventPartId 	= tonumber(tbParam[5]) or 0;
	local nEventId 	= tonumber(self:GetParam(tbGParam, "__nEventId")[1]);
	local nPartId 	= tonumber(self:GetParam(tbGParam, "__nPartId")[1]);
	if nEventPartId == nPartId then
		print("【活动系统】Error!!!CheckTaskGotoEvent重复调用自己");
		return 0;
	end
	if nType == 0 then--等于
		if me.GetTask(nGroupId, nTaskId) == nValue then
			return EventManager:GotoEventPartTable(nEventId, nEventPartId, nCheckType);
		end
	end
	if nType == 1 then--小于
		if me.GetTask(nGroupId, nTaskId) < nValue then
			return EventManager:GotoEventPartTable(nEventId, nEventPartId, nCheckType);
		end
	end
	if nType == 2 then--大于
		if me.GetTask(nGroupId, nTaskId) > nValue then
			return EventManager:GotoEventPartTable(nEventId, nEventPartId, nCheckType);
		end		
	end	
	return 0;
end

function tbFun:CheckLuaScript(szParam, tbGParam, nCheckType)
	local tbParam = self:SplitStr(szParam);
	local szScript = tbParam[1];
	local nEventPartId 	= tonumber(tbParam[2]) or 0;	
	
	szScript = string.gsub(szScript, "<enter>", "\n");
	szScript = string.gsub(szScript, "<tab>", "\t");
	local nReturn, szReturnMsg = loadstring(szScript)();
	if nReturn == 1 then
		return EventManager:CheckGotoEventPartTable(nEventPartId, szReturnMsg, tbGParam, nCheckType);
	end
	return nReturn;
end

function tbFun:CheckAddBaseMoney(szParam, tbGParam, nCheckType)
	local tbParam = self:SplitStr(szParam);
	local nMoney  = tonumber(tbParam[1]) or 0;
	local nType   = tonumber(tbParam[2]) or 0;
	local nLimit  = tonumber(tbParam[3]) or 0 ;
	local nAdd = math.floor(nMoney * me.GetProductivity() / 100);
	if nLimit > 0 and nAdd > nLimit then
		nAdd = nLimit;
	end
	if nType == 1 then
	 	local nMoneyInBag = me.nCashMoney;
	 	local szType = "银两";	
	 	if nMoneyInBag + nAdd > me.GetMaxCarryMoney() then
			return 1, string.format("您身上的%s将要达到上限，请整理后再来领取。", szType);
		end
	elseif nType == 7 then
		local nMoneyInBag = me.GetBindMoney();
		local szType = "绑定银两";
	 	if nMoneyInBag + nAdd > me.GetMaxCarryMoney() then
			return 1, string.format("您身上的%s将要达到上限，请整理后再来领取。", szType);
		end			
	end
	return 0;
end

function tbFun:CheckCoinBuyHeShiBi(szParam, tbGParam, nCheckType)
	if SpecialEvent.BuyHeShiBi:Check() == 0 then
		return 1;
	end
	return 0;
end

function tbFun:CheckGoToEvent(szParam, tbGParam, nCheckType)
	local tbParam = self:SplitStr(szParam);
	local nEventPartId 	= tonumber(tbParam[1]) or 0;

	if nEventPartId > 0 then
		local nEventId 	= tonumber(self:GetParam(tbGParam, "__nEventId")[1]);
		local nPartId 	= tonumber(self:GetParam(tbGParam, "__nPartId")[1]);
		if nEventPartId == nPartId then
			print("【活动系统】Error!!!CheckTaskGotoEvent重复调用自己");
			return 0;
		end
		return EventManager:GotoEventPartTable(nEventId, nEventPartId, 1);
	end
end

function tbFun:CheckGoToOtherEvent(szParam, tbGParam, nCheckType)
	local tbParam = self:SplitStr(szParam);
	local nEventEId 	= tonumber(tbParam[1]) or 0;
	local nEventPartId 	= tonumber(tbParam[2]) or 0;
	if nEventPartId > 0 then
		local nEventId 	= tonumber(self:GetParam(tbGParam, "__nEventId")[1]);
		local nPartId 	= tonumber(self:GetParam(tbGParam, "__nPartId")[1]);
		if nEventEId == nEventId and nEventPartId == nPartId then
			print("【活动系统】Error!!!CheckTaskGotoEvent重复调用自己");
			return 0;
		end
		return EventManager:GotoEventPartTable(nEventEId, nEventPartId, 1);
	end	
end

function tbFun:CheckNpcTaskEq(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szKey 		= tbParam[1] or 0;
	local nTskValue 	= tonumber(tbParam[2]) or 0;
	local szReturnMsg 	= tbParam[3] or "你的条件不满足。";
	if not him then
		return 1, szReturnMsg;
	end
	local tbTable = him.GetTempTable("Npc");
	tbTable.EventManager = tbTable.EventManager or {};
	tbTable.EventManager.tbTask = tbTable.EventManager.tbTask or {};
	tbTable.EventManager.tbTask[szKey] = tbTable.EventManager.tbTask[szKey] or {};
	local nValue = tonumber(tbTable.EventManager.tbTask[szKey][me.nId]) or 0;
	if nTskValue ~= nValue then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckNpcTaskGt(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szKey 		= tbParam[1] or 0;
	local nTskValue 	= tonumber(tbParam[2]) or 0;
	local szReturnMsg 	= tbParam[3] or "你的条件不满足。";
	if not him then
		return 1, szReturnMsg;
	end
	local tbTable = him.GetTempTable("Npc");
	tbTable.EventManager = tbTable.EventManager or {};
	tbTable.EventManager.tbTask = tbTable.EventManager.tbTask or {};
	tbTable.EventManager.tbTask[szKey] = tbTable.EventManager.tbTask[szKey] or {};
	local nValue = tonumber(tbTable.EventManager.tbTask[szKey][me.nId]) or 0;
	if nTskValue >= nValue then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckNpcLevel(szParam, tbGParam)	
	local tbParam = self:SplitStr(szParam);	
	local nLevel 	= tonumber(tbParam[1]) or 0;	
	local nType 	= tonumber(tbParam[2]) or 1;
	if not him then
		return 1;
	end	
	local nNpcLevel = him.nLevel;	
	if nType == 1 then
		if nNpcLevel < nLevel then
			return 1;
		end
	elseif nType == 2 then
		if nNpcLevel ~= nLevel then
			return 1;
		end
	else
		if nNpcLevel > nLevel then
			return 1;
		end
	end
	return 0;
end

function tbFun:CheckNpcType(szParam,tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nType 	= tonumber(tbParam[1]) or 0;	
	if not him then
		return 1;
	end	
	local nNpcType = him.GetNpcType();	
	if nNpcType ~= nType then
		return 1;
	end
	return 0;
end

function tbFun:CheckNpcSeries(szParam,tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nType 	= tonumber(tbParam[1]) or 0;	
	if not him then
		return 1;
	end	
	if him.nSeries ~= nType then
		return 1;
	end
	return 0;
end

function tbFun:CheckNpcTaskLt(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szKey 		= tbParam[1] or 0;
	local nTskValue 	= tonumber(tbParam[2]) or 0;
	local szReturnMsg 	= tbParam[3] or "你的条件不满足。";
	if not him then
		return 1, szReturnMsg;
	end
	local tbTable = him.GetTempTable("Npc");
	tbTable.EventManager = tbTable.EventManager or {};
	tbTable.EventManager.tbTask = tbTable.EventManager.tbTask or {};
	tbTable.EventManager.tbTask[szKey] = tbTable.EventManager.tbTask[szKey] or {};
	local nValue = tonumber(tbTable.EventManager.tbTask[szKey][me.nId]) or 0;	
	if nTskValue <= nValue then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckNpcIsBeLongMe()
	local tbParam = self:SplitStr(szParam);	
	local szReturnMsg 	= tbParam[1] or "你的条件不满足。";	
	if not him then
		return 1, "你的目标不正确！";
	end
	local tbTable = him.GetTempTable("Npc").EventManager;
	if not tbTable then
		return 1, szReturnMsg;
	end
	local nBeLongPlayerId = him.GetTempTable("Npc").EventManager.nBeLongPlayerId;
	if not nBeLongPlayerId or nBeLongPlayerId ~= me.nId then
		return 1, szReturnMsg;
	end
	return 0;
end

-- by zhangjinpin@kingsoft
function tbFun:CheckAddXiulianTime(szParam, tbGParam)	
	
	local tbParam = self:SplitStr(szParam);
	local nTime = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "你领取后修炼珠的总时间超过了上限！";	
	
	local tbXiuLianZhu = Item:GetClass("xiulianzhu");
	if tbXiuLianZhu:GetReTime() + nTime > 14 then
		return 1, szReturnMsg;
	end
	
	return 0;
end

function tbFun:CheckRandom(szParam, tbGParam)
	
	local tbParam = self:SplitStr(szParam);
	local nMin = tonumber(tbParam[1]) or 1;
	local nMax = tonumber(tbParam[2]) or 1;
	local szReturnMsg = tbParam[3] or "你的条件不满足。";	
	
	local nRandom = MathRandom(1, nMax);
	if nRandom > nMin then
		return 1, szReturnMsg;
	end
	
	return 0;
end

function tbFun:CheckFuliJingHuoWeiWang(szParam, tbGParam)
	local nPrestigeKe = KGblTask.SCGetDbTaskInt(DBTASK_JINGHUOFULI_KE);
	local nPrestige = Player.tbBuyJingHuo:GetTodayPrestige();
	if nPrestigeKe > 0 then
		nPrestige = nPrestigeKe;
	end
	if (nPrestige <= 0) then
		return 1, "还没进行全区威望排名，无法知道今天的优惠威望要求，请等排名后再来吧";
	end
	if (me.nPrestige < nPrestige) then
		return 1, "你的江湖威望不足<color=red>"..nPrestige.."点<color>。";
	end
	return 0;
end

function tbFun:CheckAddNpcInNear()
	local tbNpcList = KNpc.GetAroundNpcList(me, 5);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nKind == 4 then
			if not him or him.dwId ~= pNpc.dwId then
				return 1, "在这会把<color=green>".. pNpc.szName.."<color>给挡住了，还是挪个地方吧。";
			end
		end
	end
	return 0;
end

function tbFun:CheckTimeFrame(szParam, tbGParam)	
	local tbParam = self:SplitStr(szParam);
	local szClass = tbParam[1];
	local nReqState = tonumber(tbParam[2]) or 1;
	local szReturnMsg = tbParam[3] or "你的条件不满足。";	
	local nCurState = TimeFrame:GetState(szClass);
	if nCurState == nReqState then 
		return 0;	
	end
	return 1 , szReturnMsg;
end

function tbFun:CheckTimeDate(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "你的条件不满足。";
	local nSec = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nNowTime = GetTime();
	if nNowTime < nSec then
		return 1 , szReturnMsg;
	end
	if math.floor((nNowTime - nSec) / 24 / 3600) >= nCount then
		return 0;	
	end
	return 1 , szReturnMsg;
end

function tbFun:CheckExBindCoinByPay(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nTaskId = tonumber(tbParam[1]) or 0;
	local nMinMoney = tonumber(tbParam[2]) or 0;
	local nMaxMoney = tonumber(tbParam[3]) or 0;
	local nRate = tonumber(tbParam[4]) or 0;
	local nPay = me.GetExtMonthPay();
	if nMaxMoney < nPay and nMaxMoney ~= 0 then
		nPay = nMaxMoney;
	end
	local nCount = math.floor((nPay - nMinMoney)/ 50);
	if nCount == 0 then
		return 1,  string.format("充值超过%s才可以领取(超过的部分每50返回%s％)。", nMinMoney, nRate);
	end
	if EventManager:GetTask(nTaskId) >= nCount then
		return 1,  string.format("赠送的%s绑定金币已经成功领取完毕，继续充值才可以再次领奖(超过的部分每50返回%s％)。", nCount*50 * nRate, nRate);
	end
	return 0;
end

function tbFun:CheckInKin(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szKins = tbParam[1];
	local tbKins = Lib:SplitStr(szKins, "&");
	local nFigure = tonumber(tbParam[2]) or 0;
	local szReturnMsg = tbParam[3] or "对不起，您的条件不满足。";
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		return 1, "对不起，您不是家族成员。";
	end
	
	if nFigure > 0 and Kin:HaveFigure(nKinId, nKinMemId, nFigure) ~= 1 then
		return 1, "对不起，您的家族权限条件不够。";
	end	
	local cKin = KKin.GetKin(nKinId);
	local szKinName = cKin.GetName();	
	for _, szKin in pairs(tbKins) do
		if szKin == szKinName then
			return 0;
		end
	end
	return 1, szReturnMsg;
end

function tbFun:CheckInTong(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local szTongs = tbParam[1];
	local tbTongs = Lib:SplitStr(szTongs, "&");
	local nFigure = tonumber(tbParam[2]) or 0;
	local szReturnMsg = tbParam[3] or "对不起，您的条件不满足。";
	local nTongId = me.dwTongId;
	if nTongId == nil or nTongId <= 0 then
		return 1, "对不起，您不是帮会成员。";
	end
	
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 1, "对不起，您不是帮会成员。";
	end
	
	local szTongName = cTong.GetName();
	
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		return 1, "对不起，您不是帮会成员。";
	end
	
	if nFigure > 0 and Kin:HaveFigure(nKinId, nKinMemId, nFigure) ~= 1 then
		return 1, "对不起，您的家族权限条件不够。";
	end	
	for _, szTongs in pairs(tbTongs) do
		if szTongs == szTongName then
			return 0;
		end
	end
	return 1, szReturnMsg;	
end

function tbFun:CheckHaveKin(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nFigure = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "对不起，您不是家族成员。";
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		return 1, szReturnMsg;
	end
	if nFigure > 0 and Kin:HaveFigure(nKinId, nKinMemId, nFigure) ~= 1 then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckHaveTong(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local nFigure = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "对不起，您不是帮会成员。";
	local nTongId = me.dwTongId;
	if nTongId == nil or nTongId <= 0 then
		return 1, szReturnMsg;
	end
	
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 1, szReturnMsg;
	end
	
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		return 1, szReturnMsg;
	end
	
	if nFigure > 0 and Kin:HaveFigure(nKinId, nKinMemId, nFigure) ~= 1 then
		return 1, szReturnMsg;
	end	

	return 0;		
end

function tbFun:CheckLoginTimeSpace(szParam)
	local tbParam = self:SplitStr(szParam);
	local nNumber = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "您登陆间隔的小时数不足当前检查的小时数！";
	local nLastLoginTime = me.GetTask(2063, 16) or 0;
	local nData = me.GetTask(2063, 17) or 0;
	if nData - nLastLoginTime < nNumber*3600 then
		return 1, szReturnMsg;
	end
	if nLastLoginTime == 0 or nData == 0 then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckLastLoginDate(szParam)
	local tbParam = self:SplitStr(szParam);
	local nStartDate = tonumber(tbParam[1]) or 0;
	local nEndDate = tonumber(tbParam[2]) or 0;
	local nIsInOrOut =  tonumber(tbParam[3]) or 0;
	local szReturnMsg = tbParam[4] or "你上次登陆的时间不满足要求。";
	local nLastLoginTime = me.GetTask(2063, 16) or 0;
	local nLastDate = tonumber(os.date("%Y%m%d%H%M", nLastLoginTime));
	if nIsInOrOut == 0 then
		if nLastDate >= nStartDate and nLastDate <= nEndDate then
			return 0;
		end
		return 1, szReturnMsg;
	else
		if nLastDate >= nStartDate and nLastDate <= nEndDate then
			return 1, szReturnMsg;
		end
		return 0;		
	end
	return 0;
end

function tbFun:CheckISCanGetRepute(szParam)
	local tbParam = self:SplitStr(szParam);
	local szReturnMsg = tbParam[1] or "您还没有激活领取江湖威望，可以到礼官那里去激活！";
	if SpecialEvent.ChongZhiRepute:CheckISCanGetRepute() == 0 then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckDelItem(szParam)
	local tbParam 	= self:SplitStr(szParam);
	local szItem	= tbParam[1];
	local nCount	= tonumber(tbParam[2]) or 1;
	local tbItem 	= self:SplitStr(szItem);
	local nBagCount = me.GetItemCountInBags(unpack(tbItem)) or 0;
	if nBagCount < nCount then
		return 1, string.format("你身上背包中的物品<color=yellow>%s<color>数量不足<color=red>%s个<color>。", KItem.GetNameById(unpack(tbItem)), nCount);
	end
	return 0;
end

function tbFun:CheckTaskOneDay(szParam, tbGParam, nCheckType, nTaskPacth)
	local tbParam 	= self:SplitStr(szParam);
	local nTaskId	= tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "你今天已经参加过本次活动，每天只能参加一次。";
	if EventManager:GetTask(nTaskId) >= tonumber(os.date("%Y%m%d", GetTime())) then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckDisDayTime(szParam, tbGParam)
	local tbParam 		= self:SplitStr(szParam);
	local nTimeStart	= tonumber(tbParam[1]) or 0;
	local nTimeEnd		= tonumber(tbParam[2]) or 0;
	local nTime = tonumber(os.date("%H%M", GetTime()));
	local szReturnMsg 	= tbParam[3] or string.format("必须在%s - %s 这段时间内才开启活动。", Lib:HourMinNumber2TimeDesc(nTimeStart), Lib:HourMinNumber2TimeDesc(nTimeEnd));
	if nTimeEnd > nTimeStart then
		if nTime >= nTimeStart and nTime <= nTimeEnd then
			return 0;
		end
	end
	if nTimeEnd < nTimeStart then
		if nTime >= nTimeEnd and nTime <= nTimeStart then
			return 0;
		end		
	end
	return 1, szReturnMsg;
end

function tbFun:CheckDisDayTimeEx(szParam, tbGParam)
	local tbParam 		= self:SplitStr(szParam);
	local nTimeStart	= tonumber(tbParam[1]) or 0;
	local nTimeEnd		= tonumber(tbParam[2]) or 0;
	local nTime = tonumber(os.date("%m%d%H%M", GetTime()));
	local nYear = tonumber(os.date("%Y", GetTime()));
	local nTimeStartEx = Lib:GetDate2Time(nYear*100000000 + nTimeStart);
	local nTimeEndEx = Lib:GetDate2Time(nYear*100000000 + nTimeEnd);
	local szReturnMsg 	= tbParam[3] or string.format("必须在%s - %s 这段时间内才开启活动。", os.date("%m月%d日%H：%M", nTimeStartEx), os.date("%m月%d日%H：%M", nTimeEndEx));
	if nTimeEnd > nTimeStart then
		if nTime >= nTimeStart and nTime <= nTimeEnd then
			return 0;
		end
	end
	if nTimeEnd < nTimeStart then
		if nTime >= nTimeEnd and nTime <= nTimeStart then
			return 0;
		end		
	end
	return 1, szReturnMsg;
end

function tbFun:CheckLinkTaskCount(szParam)
	local tbParam 		= self:SplitStr(szParam);
	local nCount		= tonumber(tbParam[1]) or 0;
	local szReturnMsg	= tbParam[2] or string.format("你今天参加义军任务的次数还没达到%s次。", nCount);
	local nNum = LinkTask:GetTaskNum_PerDay();
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));  -- 获取日期：XXXX/XX/XX 格式
	local nOldDate = LinkTask:GetTask(LinkTask.TSK_DATE);
	if nNowDate ~= nOldDate then
		return 1, szReturnMsg;
	end
	if nNum < nCount then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckCostMoney(szParam)
	local tbParam 		= self:SplitStr(szParam);
	local nValue		= tonumber(tbParam[1]) or 0;
	if me.nCashMoney < nValue then
		return 1, string.format("你身上的银两不足%s两", nValue);
	end
	return 0;
end

function tbFun:CheckCostBindMoney(szParam)
	local tbParam 		= self:SplitStr(szParam);
	local nValue		= tonumber(tbParam[1]) or 0;
	if me.GetBindMoney() < nValue then
		return 1, string.format("你身上的绑定银两不足%s两", nValue);
	end
	return 0;	
end

function tbFun:CheckCostBindCoin(szParam)
	local tbParam 		= self:SplitStr(szParam);
	local nValue		= tonumber(tbParam[1]) or 0;
	if me.nBindCoin < nValue then
		return 1, string.format("你身上的绑定金币不足%s两", nValue);
	end
	return 0;
end

function tbFun:CheckCostJingLi(szParam)
	local tbParam 		= self:SplitStr(szParam);
	local nValue		= tonumber(tbParam[1]) or 0;
	if me.dwCurMKP < nValue then
		return 1, string.format("你的精力不足%s点", nValue);
	end
	return 0;
end

function tbFun:CheckCostHuoLi(szParam)
	local tbParam 		= self:SplitStr(szParam);
	local nValue		= tonumber(tbParam[1]) or 0;
	if me.dwCurGTP < nValue then
		return 1, string.format("你的活力不足%s点", nValue);
	end
	return 0;
end

function tbFun:CheckCostGlbBindMoney(szParam)
	local tbParam 		= self:SplitStr(szParam);
	local nValue		= tonumber(tbParam[1]) or 0;
	if me.GetGlbBindMoney() < nValue then
		return 1, string.format("你身上的跨服绑银不足%s两", nValue);
	end
	return 0;	
end

--function tbFun:CheckCoinBuyItem(szParam, tbGParam, nCheckType)
--	local tbParam = self:SplitStr(szParam);
--	local nNum = tonumber(tbParam[1]) or 0;
--	if nNum <= 0 or SpecialEvent.BuyItem:Check(nNum) == 0 then
--		return 1;
--	end
--	return 0;
--end

--随机对应索引名
tbFun.tbRandomAwardsParamName = 
{
		[1] = {"nGenre", "nDetail", "nParticular", "nLevel", "nAmount", "nBind", "szTimeLimit", "nSeries", "nEnhance"};
		[2] = {"nJxMoney"},
		[3] = {"nJxBindMoney"},
		[4] = {"nJxCoin"},
		[5] = {"nMKP"},
		[6] = {"nGTP"},
		[7] = {"nExp"},
		[8] = {"nExpBase"},
		[9] = {"nSkillId", "nSkillLevel", "nSkillTime"},
};
function tbFun:CheckAddRandomAwards(szParam, tbGParam)
	local tbParam = self:SplitStr(szParam);
	local tbParamName = self.tbRandomAwardsParamName;
	local nNeedBagFree = 0;
	local nNeedMoney = 0;
	local nNeedBindMoney = 0;
	
	for nPi=2, #tbParam do
		local szItemParam = tbParam[nPi];
		local tbTemp = self:SplitStr(szItemParam);
		local nType = tonumber(tbTemp[2]) or 0;
		if tonumber(tbTemp[1]) and tonumber(tbTemp[1]) > 0 and tbParamName[nType] then
			local tbItemTemp = {};
			for ni, szKey in ipairs(tbParamName[tonumber(tbTemp[2])]) do
				local tbTempParam1 = self:SplitStr(tbTemp[3]);
				tbItemTemp[szKey] = tonumber(tbTempParam1[ni]) or 0;
			end
			if nType == 1 and tbItemTemp.nGenre then
				local nCount = KItem.GetNeedFreeBag(tbItemTemp.nGenre, tbItemTemp.nDetail, tbItemTemp.nParticular, tbItemTemp.nLevel, {bTimeOut=tbItemTemp.szTimeLimit}, tbItemTemp.nAmount);
				if nCount > nNeedBagFree then
					nNeedBagFree = nCount;
				end
			end
			if nType == 2 and tbItemTemp.nJxMoney then
				if tbItemTemp.nJxMoney > nNeedMoney then
					nNeedMoney = tbItemTemp.nJxMoney;
				end
			end
			if nType == 3 and tbItemTemp.nJxBindMoney then
				if tbItemTemp.nJxBindMoney > nNeedBindMoney then
					nNeedBindMoney = tbItemTemp.nJxBindMoney;
				end
			end
		end
	end

	if nNeedBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		return 1, "你的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。";
	end
	
	if nNeedMoney + me.nCashMoney > me.GetMaxCarryMoney() then
		return 1, "你的身上的银两即将达到上限，请清理一下身上的银两。";
	end	
	
	local nCFlag, szCMsg = self:_CheckItemFree(me, nNeedBagFree)
	if nCFlag == 1 then
		return 1, szCMsg;
	end

end

function tbFun:CheckPayIsAction(szParam)
	local nExtType = tonumber(self:SplitStr(szParam)[1]) or 0;
	if nExtType <=0 or nExtType >3 then
		return 1, "出现异常，不能激活！";
	end	
	local nState = me.GetPayActionState(nExtType);
	if nState == 1 then
		return 0;
	end
	return 1, "当前角色未激活本月的领奖资格，不能领奖！";
end

function tbFun:CheckSetPayAction(szParam)
	local nExtType = tonumber(self:SplitStr(szParam)[1]) or 0;
	if nExtType <=0 or nExtType >3 then
		return 1, "出现异常，不能激活！";
	end	
	local nState = me.GetPayActionState(nExtType);
	if nState == 1 then
		return 1, "你的角色已激活过了资格，不能重复激活！";
	end
	
	if nState == 2 then
		return 1, "账号下其他角色已激活了资格，不能再激活了！";
	end	
	
	if nState ~= 0 then
		return 1, "出现异常，不能激活！";
	end
	return 0
end

function tbFun:CheckDelNpc(szParam)	
	if not him then
		return 1, "你好像没有目标。";
	end
	return 0;	
end

function tbFun:CheckRoute(szParam)
	local tbParam = self:SplitStr(szParam);
	local nRoute = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "你的门派路线不符合要求。";
	if me.nRouteId > 0 and nRoute == 3 then
		return 0;
	end
	if nRoute ~= me.nRouteId then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckSpeTitle(szParam)
	local tbParam = self:SplitStr(szParam);
	local szSpeTitle = tbParam[1] or "";
	local szReturnMsg = tbParam[2] or string.format("必须拥有%s称号才有资格。", szSpeTitle);
	if me.FindSpeTitle(szSpeTitle) ~= 1 then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckTodayJoinKinGame(szParam)
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "你今天还没参加过家族关卡，不能领奖。";
	local nFlag = me.GetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_NOW_WEEK_TIME);
	if (nFlag > 0) then
		return 0;
	end
	return 1, szMsg;
end

function tbFun:CheckSongJinBattleCount(szParam)
	local tbParam = self:SplitStr(szParam);
	local nLow = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("你的今天参加宋金次数不足，不能领取奖励。");
	local nCount = me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_DAY_JOIN_COUNT);
	
	if (nCount >= nLow) then
		return 0;
	end
	
	return 1, szMsg;
end

function tbFun:CheckExtPoint(szParam)
	local tbParam = self:SplitStr(szParam);
	local szReturnMsg = tbParam[1] or string.format("您的机子上并没有CSM软件。", szSpeTitle);
	if me.GetExtPoint(4) ~= 1 then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckPayCardValue(szParam)
	local tbParam 	= self:SplitStr(szParam);
	local nNeedValue = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or string.format("您的可用充值点数不足%s点！", nNeedValue);
	if nNeedValue <= 0 then
		return 1, "出现异常！";
	end
	local nExPay = me.GetExtMonthPay();
	local nAleadyUsePay = me.GetTask(2137,2);
	if nExPay - nAleadyUsePay < nNeedValue then
		return 1, szReturnMsg;
	end
	return 0;
end	

function tbFun:CheckEventTimes(szParam)
	local tbParam 	= self:SplitStr(szParam);
	local nType = tonumber(tbParam[1]) or 0;
	local nLimitTimes = tonumber(tbParam[2]) or 0;
	local nTypeTimes = tonumber(tbParam[3]) or 0;
	local szReturnMsg = tbParam[4] or "你不满足条件！";
	if nType <= 0 or nLimitTimes <= 0 or nTypeTimes <= 0 then
		return 1, "出现异常！";
	end
	if not SpecialEvent.tbPJoinEventTimes.tbEventTimes[nType] then
		return 1, "出现异常！";
	end
	local nPlayerTimes = me.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.tbEventTimes[nType]);
	if nTypeTimes == 1 then		--小于等于
		if nPlayerTimes <= nLimitTimes then
			return 0;
		end
	elseif nTypeTimes == 2 then	--等于
		if nPlayerTimes == nLimitTimes then
			return 0;
		end
	elseif nTypeTimes == 3 then	--大于等于
		if nPlayerTimes >= nLimitTimes then
			return 0;
		end
	end
	return 1, szReturnMsg;
end

function tbFun:CheckJoinEvent(szParam)
	local tbParam 	= self:SplitStr(szParam);
	local nType = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or "你不满足条件！";
	if nType <= 0 then
		return 1, "出现异常！";
	end
	local nFlag = me.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.tbJoinEvent[nType]);
	if nFlag ~= 1 then
		return 1, szReturnMsg;
	end
	return 0;
end	

function tbFun:CheckXoYoGameGrade(szParam)
	local tbParam = self:SplitStr(szParam);
	local nLevel	= tonumber(tbParam[1]) or 0;
	local nGrade	= tonumber(tbParam[2]) or 0;
	local nType	= tonumber(tbParam[3]) or 1;
	local szReturnMsg = tbParam[4] or "你不满足条件！";
	if nLevel < 1 or nLevel > 5 or nGrade < 1 or nGrade > 10 or not XoyoGame.LevelDesp[nLevel] then
		return 1, "出现异常";
	end
	if XoyoGame.LevelDesp[nLevel][1] ~= 1 then 
		return 1, "该难度还没有开启。";
	end
	if not XoyoGame.tbXoyoRank[nLevel] or #XoyoGame.tbXoyoRank[nLevel] == 0 then
		return 1, szReturnMsg;
	end
	for nRank, tbInfo in ipairs(XoyoGame.tbXoyoRank[nLevel]) do
		if nType == 2 and nRank == nGrade then
			for _, szName in ipairs(tbInfo.tbMember) do
				if szName == me.szName then
					return 0;
				end
			end
		elseif nType == 1 and nRank <= nGrade then
			for _, szName in ipairs(tbInfo.tbMember) do
				if szName == me.szName then
					return 0;
				end
			end
		end
	end
	return 1,szReturnMsg;
end

function tbFun:CheckKinLead(szParam)
	local tbPositionInKin = {[1] = "族长",[2] = "副族长",[3] = "正式成员",[4] = "记名成员", [5] = "荣誉成员"}
	local tbParam = self:SplitStr(szParam);
	local nPosition	= tonumber(tbParam[1]) or 0;
	if not tbPositionInKin[nPosition] then
		return 1, "请联系GM。";
	end
	local szReturnMsg = tbParam[2] or string.format("您在家族中不是%s。", tbPositionInKin[nPosition]);
	if me.dwKinId == 0 then
		return 1, "您没有家族。";
	end
	if me.nKinFigure == nPosition then
		return 0;	
	end
	return 1, szReturnMsg;
end

function tbFun:CheckKinMember(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or string.format("您的家族成员不足%s人。", nCount);
	if me.dwKinId == 0 then
		return 1, "您没有家族。";
	end	
	local pKin = KKin.GetKin(me.dwKinId);
	if not pKin then		
		return 1, "您没有家族。";
	end
	local nRegular, nSigned, nRetire = pKin.GetMemberCount();
	local nMemberCount = nRegular + nSigned + nRetire;
	if nMemberCount < nCount then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckOnlineTime(szParam)
	local tbParam = self:SplitStr(szParam);
	local nTime = tonumber(tbParam[1]) or 0;
	local szReturnMsg = tbParam[2] or string.format("您今天的上线时间不足%s秒。", nTime);
	local nOnlineTime = 0;
	local nNowTime = GetTime();
	local nLastLogInTime = me.GetTask(2063, 2);
	local nTodayTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d")));
	if nTodayTime <= nLastLogInTime  then
		nOnlineTime = me.GetTask(2063,21) + nNowTime - nLastLogInTime;
	else
		nOnlineTime = nNowTime - nTodayTime;
	end	
	if nOnlineTime < nTime then
		return 1, szReturnMsg;
	end
	return 0;
end

function tbFun:CheckRoleCreateDate(szParam)
	local tbParam = self:SplitStr(szParam);
	local nDate = tonumber(tbParam[1]) or 0;
	local nType = tonumber(tbParam[2]) or 1;
	local szReturnMsg = tbParam[3];
	local nCreatDate = me.GetRoleCreateDate();
	if nType == 1 then
		if nCreatDate < nDate then
			return 1, szReturnMsg or string.format("您创建角色的时间不在%s之内。", nDate);
		end
	elseif nType == 2 then
		if nCreatDate ~= nDate then
			return 1, szReturnMsg or string.format("您创建角色的时间不在%s。", nDate);
		end
	elseif nType == 3 then
		if nCreatDate > nDate then
			return 1, szReturnMsg or string.format("您创建角色的时间不在%s之前。", nDate);
		end
	end
	return 0;
end

function tbFun:CheckIsSubPlayer(szParam)
	local tbParam = self:SplitStr(szParam);
	local nType = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or "对不起，你不符合资格。";

		--要求是子服玩家
	if nType == 1 then
		if me.IsSubPlayer() ~= 1 then
			return 1, szMsg;
		end
	else
		--要求不是子服玩家
		if me.IsSubPlayer() == 1 then
			return 1, szMsg;
		end
	end
	return 0;	
end

-- 台湾版用
-- 当日是否参加过灯谜活动（台湾版）
function tbFun:CheckDailyJoinGuessGame(szParam)
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "你今天还没参加过灯谜活动，不能领奖。";
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_DENGMI);
	if (nFlag > 0) then
		return 0;
	end
	return 1, szMsg;
end

-- 当日参加过几次白虎堂
function tbFun:CheckDailyJoinBaiHuTangCount(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你今天参加白虎堂的次数不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_BAIHUTANG);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

-- 当日是否参加门派竞技
function tbFun:CheckDailyJoinMenPaiJingJi(szParam)
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "你今天还没参加过门派竞技，不能领奖。";
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_MENPAIJINGJI);
	if (nFlag > 0) then
		return 0;
	end
	return 1, szMsg;
end

-- 当日完成了几次军营任务
function tbFun:CheckDailyJoinArmyCampCount(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你今天参加军营任务的次数不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_JUNYINGRENWU);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

-- 当日是否参加过逍遥谷
function tbFun:CheckDailyJoinXoyoGame(szParam)
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "你今天还没参加过逍遥谷，不能领奖。";
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_XOYOGAME);
	if (nFlag > 0) then
		return 0;
	end
	return 1, szMsg;
end

-- 当日是否参加过领土战
function tbFun:CheckDailyJoinLingTuBattle(szParam)
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "你今天还没参加过领土战，不能领奖。";
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_LINGTUZHAN);
	if (nFlag > 0) then
		return 0;
	end
	return 1, szMsg;
end

-- 当日参加武林联赛的次数
function tbFun:CheckDailyJoinWllsCount(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你今天参加武林联赛的次数不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_WLLS);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

-- 当月参加武林联赛的次数
function tbFun:CheckMonthJoinWllsCount(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你本月参加武林联赛的次数不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_MonthCount(me, Player.EVENT_JOIN_RECORD_WLLS);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

-- 当月参加联赛的积分
function tbFun:CheckMonthJoinWllsPoint(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你本月参加武林联赛的积分不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_MonthPoint(me, Player.EVENT_JOIN_RECORD_WLLS);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

-- 当日参加家族竞技的次数
function tbFun:CheckDailyJoinJiaZuJIngjiCount(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你今天参加家族竞技的次数不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_JIAZUJINGJI);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

-- 当月参加家族竞技的次数
function tbFun:CheckMonthJoinJiaZuJIngjiCount(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你本月参加家族竞技的次数不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_MonthCount(me, Player.EVENT_JOIN_RECORD_JIAZUJINGJI);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

-- 当月家族竞技的积分
function tbFun:CheckMonthJoinJiaZuJingjiPoint(szParam)
	local tbParam = self:SplitStr(szParam);
	local nCount = tonumber(tbParam[1]) or 0;
	local szMsg = tbParam[2] or string.format("对不起，你本月参加家族竞技积分不足%s，不能领取奖励。", nCount);
	local nFlag = Player:GetJoinRecord_MonthPoint(me, Player.EVENT_JOIN_RECORD_JIAZUJINGJI);
	if (nFlag >= nCount) then
		return 0;
	end
	return 1, szMsg;
end

function tbFun:CheckAddZhenYuan(szParam)
	local tbParam 	= self:SplitStr(szParam);
	local nId= tonumber(tbParam[1]) or -1;
	local nLevel= tonumber(tbParam[2]) or 0;
	local nEquiped	= tonumber(tbParam[3]) or 0;	
	local nPotential1	= tonumber(tbParam[4]) or 0;	
	local nPotential2	= tonumber(tbParam[5]) or 0;	
	local nPotential3	= tonumber(tbParam[6]) or 0;	
	local nPotential4 	= tonumber(tbParam[7]) or 0;
	--真元类型：宝玉=193,夏小倩=182,莺莺=194,木超=181,紫苑=177,秦仲=178,叶静=246
	local tbZType = {[193] = 1,[182] = 1,[194] = 1,[181] = 1,[177] = 1,[178] = 1,[246] = 1};
	if not tbZType[nId] then
		return 1, "真元id不对。";
	end
	if nPotential1 <= 0 or nPotential2 <= 0 or nPotential3 <= 0 or nPotential4 <= 0 then
		return 1, "每个属性必须要有星级。";
	end
	if nPotential1 > 14 or nPotential2 > 14 or nPotential3 > 14 or nPotential4 > 14 then
		return 1, "每个星级最多到7星。";
	end
	if me.CountFreeBagCell() < 1 then
		return 1, "对不起，您身上的背包空间不足，需要1格背包空间。";
	end
	return 0;
end

function tbFun:CheckAddConsume(szParam)
	local tbParam = self:SplitStr(szParam);
	local nItConsumed = tonumber(tbParam[1]) or 0;
	local bAdd = tonumber(tbParam[2]) or 0;
	if nItConsumed <= 0 then
		return 1, "消耗积分数值不对。";
	end
	if bAdd == 1 then
		Spreader:IbShopGetConsume();
		if Spreader:GetConsumeMoney() < nItConsumed then
			return 1, "对不起，您的消耗积分不足。";
		end
	end
	return 0;
end

function tbFun:CheckActiveNum(szParam)
	local tbParam = self:SplitStr(szParam);
	local nType = tonumber(tbParam[1]) or 0;
	local nCount = tonumber(tbParam[2]) or 0;
	local szErrorMsg = tbParam[3] or "";
	if nType ~= 1 and nType ~= 2 then
		return 1,"类型不对";
	end
	if nCount <= 0 then
		return 1,"数量不对";
	end
	
	if nType == 1 and SpecialEvent.ActiveGift:GetActiveNum() < nCount then
		if szErrorMsg == "" then
			szErrorMsg = "每天的活跃度不足"..nCount.."点。";
		end
		return 1, szErrorMsg;
	end
	if nType == 2 and SpecialEvent.ActiveGift:GetMonthActive() < nCount then
		if szErrorMsg == "" then
			szErrorMsg = "每月的活跃度不足"..nCount.."点。";
		end
		return 1, szErrorMsg;
	end
	return 0;
end

---条件判断 END ------------
