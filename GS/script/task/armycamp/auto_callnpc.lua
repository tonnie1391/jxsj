Task.ArmyCamp = Task.ArmyCamp or {};
Task.ArmyCamp.tbFun = Task.ArmyCamp.tbFun or {};
local tbFun = Task.ArmyCamp.tbFun;	-- 函数列表
local ArmyCamp = Task.ArmyCamp;
ArmyCamp.tbTempRecord = ArmyCamp.tbTempRecord or {};	-- 临时变量存放
local tbInfo = 
{
	[1] = -- 大工匠招小怪
	{
		npcid = 4002, 
		trigger = "AddLifePObserver:50,1",
		triggerevent = 
		{
			[1] = {'AddNpc:1,"\\setting\\task\\armycamp\\npc_4002_50_1.txt",0,"Các ngươi định náo loạn ở đây sao?"', "AddSkillState:1332,10,0,10800,0,0,1,0", 'SendBlackBoardMsg:"Một nhóm Tiểu Công Tượng tràn vào, mau thu phục họ!"'},
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:1,6,0"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1332,0", 'SendBlackBoardMsg:"Thợ Cả nổi giận rồi!"'},
		},
		failureevent = 
		{
			[1] = {},
		},
	},
	[2] = -- 大工匠招小怪
	{
		npcid = 4002, 
		trigger = "AddLifePObserver:50,1",
		triggerevent = 
		{
			[1] = {'AddNpc:2,"\\setting\\task\\armycamp\\npc_4002_50_2.txt",0,"Các ngươi định náo loạn ở đây sao?"', "AddSkillState:1332,10,0,10800,0,0,1,0", 'SendBlackBoardMsg:"Một nhóm Tiểu Công Tượng tràn vào, mau thu phục họ!"'},
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:2,6,0"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1332,0", 'SendBlackBoardMsg:"Thợ Cả nổi giận rồi!"'},
		},
		failureevent = 
		{
			[1] = {},
		},
	},
	[3] = -- 大工匠招小怪
	{
		npcid = 4002, 
		trigger = "AddLifePObserver:50,1",
		triggerevent = 
		{
			[1] = {'AddNpc:3,"\\setting\\task\\armycamp\\npc_4002_50_3.txt",0,"Các ngươi định náo loạn ở đây sao?"', "AddSkillState:1332,10,0,10800,0,0,1,0", 'SendBlackBoardMsg:"Một nhóm Tiểu Công Tượng tràn vào, mau thu phục họ!"'},
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:3,6,0"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1332,0", 'SendBlackBoardMsg:"Thợ Cả nổi giận rồi!"'},
		},
		failureevent = 
		{
			[1] = {},
		},
	},
	[4] = -- 百人阵
	{
		npcid = 7312,
		trigger = "OpenStart:0",
		triggerevent = 
		{
			[1] = {'AddNpc:1,"\\setting\\task\\armycamp\\npc_7312_100_1.txt",0,"对付你们，不必我亲自出手。"', "AddSkillState:1332,10,0,10800,0,0,1,0", },
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:1,12,0"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1332,0", 'SendChat:"好吧，让我亲自终结你们！"', 'SendBlackBoardMsg:"白无为：让我亲自来会会你们！"'},
		},
		failureevent = 
		{
			[1] = {},		
		},	
	},
	[5] = -- 白无为狂暴
	{
		npcid = 7312,
		trigger = "AddLifePObserver:70,1",
		triggerevent = 
		{
			[1] = {'AddNpc:3,"\\setting\\task\\armycamp\\npc_7312_70_3.txt",0,"我没有朋友，他们就是我的朋友，别掉以轻心了！"', "AddSkillState:1080,3,0,10800,0,0,1,0", "AddSkillState:1079,7,0,1620,0,0,1,0", 'SendBlackBoardMsg:"迅速制服白氏傀儡，打击白无为的气焰"'},
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:3,2,20"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1080,0","RemoveSkillState:1079,0",  'SendBlackBoardMsg:"白无为的实力削弱了"'},
		},
		failureevent = 
		{
			[1] = {},	
		},
	},
	[6] = -- 白无为第二次狂暴
	{
		npcid = 7312,
		trigger = "AddLifePObserver:30,1",
		triggerevent = 
		{
			[1] = {'AddNpc:4,"\\setting\\task\\armycamp\\npc_7312_30_4.txt",0,"我没有朋友，他们就是我的朋友，别掉以轻心了！"', "AddSkillState:1080,3,0,10800,0,0,1,0", "AddSkillState:1079,7,0,1620,0,0,1,0", 'SendBlackBoardMsg:"白氏傀儡复生，迅速将其制服"'},
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:4,2,20"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1080,0","RemoveSkillState:1079,0",  'SendBlackBoardMsg:"白无为的实力再次被削弱了"'},
		},
		failureevent = 
		{
			[1] = {},	
		},
	},
	[7] = -- 碧吴使招小怪
	{
		npcid = 4127,
		trigger = "AddLifePObserver:50,1",
		triggerevent = 
		{
			[1] = {'AddNpc:1,"\\setting\\task\\armycamp\\npc_4127_50_1.txt",0,"们的到来只是计划中的一个污点，很快便会消失不见。"', "AddSkillState:1080,10,0,10800,0,0,1,0", "AddSkillState:1079,7,0,1620,0,0,1,0",  'SendBlackBoardMsg:"碧蜈使进入狂暴，必须迅速制服凶猛的碧水蜈"'},
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:1,4,30"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1080,0","RemoveSkillState:1079,0", 'SendBlackBoardMsg:"碧蜈使的狂暴解除了"', },
		},
		failureevent = 
		{
			[1] = {},	
		},
	},
	[8] = -- 混天豹招小怪
	{
		npcid = 7318,
		trigger = "AddLifePObserver:60,1",
		triggerevent = 
		{
			[1] = {'AddNpc:1,"\\setting\\task\\armycamp\\npc_7318_60_1.txt",0,"恩，我闻到了新鲜的味道，赏给你们吧，孩子们"', "AddSkillState:1332,10,0,10800,0,0,1,2", 'SendBlackBoardMsg:"阴森的獠牙，一群猛兽出现了"',},
		}, 
		condition = 
		{
			[1] = {{"CheckKillCount:1,13,0"},},	
		},
		successevent = 
		{
			[1] = {"RemoveSkillState:1332,0",'SendChat:"看来你们也不是一无是处，那就继续陪你们玩玩"',},
		},
		failureevent = 
		{
			[1] = {},	
		},
	},
	
};

--tbFun.tbTriggerFun = 
--{
--	AddLifePObserver = "AddLifePObserver",	-- 增加血量百分比观察点
--	OpenStart = "OpenStart",	--直接开启参数延迟
--};

tbFun.tbTriggerEventFun = 
{
	AddNpc = "AddNpc",	-- 所属批次，npc配置文件路径，延迟，喊话内容
	CastSkill = "CastSkill",	-- 技能id，技能等级，延迟，喊话内容
	AddSkillState = "AddSkillState",-- 技能id，技能等级，状态类型，持续时间，死亡是否保留，是否强制替换，时间类型（0:给定的是具体时间yymmddhhss 1:给定的是持续时间），延迟
	RemoveSkillState = "RemoveSkillState",-- 技能id， 延迟
	TaskActTalk	= "TaskActTalk",	-- 说话内容
	SendBlackBoardMsg = "SendBlackBoardMsg",
	SendChat = "SendChat",
};

tbFun.tbCheckEventfun = 
{
	CheckKillCount = "CheckKillCount",-- 批次，数量，时间  （是否在规定时间内杀次所属批次的数量的npc）
};

tbFun.tbSuccessEventFun = 
{
	CastSkill = "CastSkill",
	AddSkillState = "AddSkillState",
	RemoveSkillState = "RemoveSkillState",	
	TaskActTalk	= "TaskActTalk",	-- 说话内容
	SendBlackBoardMsg = "SendBlackBoardMsg",
	SendChat = "SendChat",
};

tbFun.tbFailureEventFun = 
{
	CastSkill = "CastSkill",
	AddSkillState = "AddSkillState",
	RemoveSkillState = "RemoveSkillState",	
	TaskActTalk	= "TaskActTalk",	-- 说话内容	
	SendBlackBoardMsg = "SendBlackBoardMsg",
	SendChat = "SendChat",
};

function Task.ArmyCamp:StartTrigger(nNpcId, nIndex)
	local szParam = tbInfo[nIndex].trigger
	local nSit = string.find(szParam, ":");
	if nSit and nSit > 0 then
		local szFlag = string.sub(szParam, 1, nSit - 1);
		local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
		if szFlag == "AddLifePObserver" then
			self.tbFun:AddLifePObserver(szContent, nNpcId, nIndex);
		elseif szFlag == "OpenStart" then
			self.tbFun:OpenStart(szContent, nNpcId, nIndex);
		end
	end
	return 0;
end

function tbFun:SplitStr(szParam)
	 if not szParam then
		 return {};
	 end
	 local nAssert = 0;
	 local t = {};
	 while self:SplitStrMatch(szParam) and nAssert < 100000 do
	    nAssert = nAssert + 1;
	    t[#t+1], szParam = self:SplitStrMatch(szParam)
	 end
     return t;
end

function tbFun:SplitStrMatch(szParam)
	szParam = string.gsub(szParam, "\\\"","<doublequ>");
	local nStart_n, nEnd_n, szRet_n, sz_n =  string.find(szParam, "(-?%d+)(.*)")
    local nStart_sz, nEnd_sz, szR_sz, sz_sz =  string.find(szParam, "(%b\"\")(.*)")
    if nStart_n and (nStart_sz and nStart_n < nStart_sz or not nStart_sz) then
    	return tonumber(szRet_n), sz_n
    else
    	if szR_sz then
    		szR_sz = string.gsub(szR_sz, "\"(.*)\"", "%1")
    		szR_sz = string.gsub(szR_sz,"<doublequ>", "\"");
    	end

    	return szR_sz, sz_sz
    end
end

function tbFun:OpenStart(szParam, nNpcId, nIndex)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local nDelay = tonumber(tbParam[1]) or 0;
	ArmyCamp.tbTempRecord[nNpcId] = ArmyCamp.tbTempRecord[nNpcId] or{};	-- 用来记录该npc的信息
	ArmyCamp.tbTempRecord[nNpcId][nIndex] = ArmyCamp.tbTempRecord[nNpcId][nIndex] or {}; -- 用索引区分同一npc不同血量的状态
	ArmyCamp.tbTempRecord[nNpcId].nIndex = nIndex;
	if nDelay > 0 then
		Timer:Register(nDelay * 18, self.OpenStartCallBack, self, nNpcId, nIndex, 1);
		return 1;
	end
	self:OpenStartCallBack(nNpcId, nIndex, 1);
	return 1;
end

function tbFun:OpenStartCallBack(nNpcId, nIndex, nFloor)
	self:ExcuteTriggerEventFun(nNpcId, nIndex, nFloor);
	return 0;
end

function tbFun:AddLifePObserver(szParam, nNpcId, nIndex)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local nPercent = tonumber(tbParam[1]) or 0;
	local nTimes = tonumber(tbParam[2]) or 0;
	if nPercent <= 0 or nPercent > 100 then 
		return 0;
	end
	ArmyCamp.tbTempRecord[nNpcId] = ArmyCamp.tbTempRecord[nNpcId] or{};	-- 用来记录该npc的信息
	ArmyCamp.tbTempRecord[nNpcId][nIndex] = ArmyCamp.tbTempRecord[nNpcId][nIndex] or {}; -- 用索引区分同一npc不同血量的状态
	ArmyCamp.tbTempRecord[nNpcId].nIndex = nIndex;
	ArmyCamp.tbTempRecord[nNpcId][nIndex].nTimes = 0;	-- 已触发次数
	--pNpc.AddLifePObserver(nPercent);
	Npc:RegPNpcLifePercentReduce(pNpc, nPercent, self.OnLifePercentReduceHere, self, nNpcId, nIndex, 1, nPercent, nTimes);
	return 1;
end

-- 统一血量百分比触发回调接口
function tbFun:OnLifePercentReduceHere(nNpcId, nIndex, nFloor, nObserverPercent, nTimes, nPercent)
	if him.dwId ~= nNpcId then
		return 0;
	end
	if not ArmyCamp.tbTempRecord[nNpcId][nIndex] then
		return 0;
	end
	local tbData = ArmyCamp.tbTempRecord[nNpcId][nIndex];
	tbData.nTimes = tbData.nTimes + 1;
	if nTimes > 0 and tbData.nTimes > nTimes then	--
		return 0;
	end
	return self:ExcuteTriggerEventFun(nNpcId, nIndex, nFloor);
end

function tbFun:ExcuteTriggerEventFun(nNpcId, nIndex, nFloor)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbTrigger = tbInfo[nIndex].triggerevent[nFloor];
	if not tbTrigger then
		ArmyCamp.tbTempRecord[nNpcId][nIndex] = nil;
		return 0;
	end
	local nReFlag = 1;
	local szReMsg = nil;
	for nParam, szParam in ipairs(tbTrigger) do
		local nSit = string.find(szParam, ":");
		if nSit and nSit > 0 then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if self.tbTriggerEventFun[szFlag] ~= nil then
				local fncExcute = self[self.tbTriggerEventFun[szFlag]];
				if fncExcute then
					local nFlag, szMsg = fncExcute(self, szContent, nNpcId, nIndex, nFloor);
					if not nFlag or nFlag ~= 1 then
						ArmyCamp.tbTempRecord[nNpcId][nIndex] = nil;
						return nFlag, szMsg;
					end
				end
			end
		end
	end
	return nReFlag, szReMsg;
end

function tbFun:ExcuteSuccessEventFun(nNpcId, nIndex, nFloor)
	local tbEvent = tbInfo[nIndex].successevent[nFloor];
	if not tbEvent then
		return self:ExcuteTriggerEventFun(nNpcId, nIndex, nFloor+1); -- 该层无事件直接触发下一层
	end
	local nReFlag = 0;
	local szReMsg = nil;
	for nParam, szParam in ipairs(tbEvent) do
		local nSit = string.find(szParam, ":");
		if nSit and nSit > 0 then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if self.tbSuccessEventFun[szFlag] ~= nil then
				local fncExcute = self[self.tbSuccessEventFun[szFlag]];
				if fncExcute then
					local nFlag, szMsg = fncExcute(self, szContent, nNpcId, nIndex, nFloor);
					if not nFlag or nFlag ~= 1 then
						ArmyCamp.tbTempRecord[nNpcId][nIndex] = nil;
						return -1, "有成功事件未执行成功";
					end
				end
			end
		end
	end
	-- 成功执行下一层触发时间
	return self:ExcuteTriggerEventFun(nNpcId, nIndex, nFloor+1);
end

function tbFun:ExcuteFailureEventFun(nNpcId, nIndex, nFloor)
	local tbEvent = tbInfo[nIndex].failureevent[nFloor];
	if not tbEvent then
		ArmyCamp.tbTempRecord[nNpcId][nIndex] = nil;
		return 1;
	end
	local nReFlag = 1;
	local szReMsg = nil;
	for nParam, szParam in ipairs(tbEvent) do
		local nSit = string.find(szParam, ":");
		if nSit and nSit > 0 then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if self.tbFailureEventFun[szFlag] ~= nil then
				local fncExcute = self[self.tbFailureEventFun[szFlag]];
				if fncExcute then
					local nFlag, szMsg = fncExcute(self, szContent, nNpcId, nIndex, nFloor);
					if not nFlag or nFlag ~= 1 then
						ArmyCamp.tbTempRecord[nNpcId][nIndex] = nil;
						return -1, "有失败事件未执行成功";
					end
				end
			end
		end
	end
	ArmyCamp.tbTempRecord[nNpcId][nIndex] = nil;
	return nReFlag, szReMsg;
end

-- 检查调用指定检查函数检查是否成功
function tbFun:ExcuteCheckEvent(nNpcId, nIndex, nFloor, szNeedFlag)
	if not self.tbCheckEventfun[szNeedFlag] then	-- 会调用指定的检查条件
		return 0;
	end
	if not ArmyCamp.tbTempRecord[nNpcId] or not ArmyCamp.tbTempRecord[nNpcId][nIndex] then
		return 0;
	end
	ArmyCamp.tbTempRecord[nNpcId][nIndex].CheckRes = ArmyCamp.tbTempRecord[nNpcId][nIndex].CheckRes or {};
	ArmyCamp.tbTempRecord[nNpcId][nIndex].CheckRes[nFloor] = ArmyCamp.tbTempRecord[nNpcId][nIndex].CheckRes[nFloor] or 0;
	if ArmyCamp.tbTempRecord[nNpcId][nIndex].CheckRes[nFloor] ~= 0 then
		return 0;
	end
	local nReFlag = 0;
	local szReMsg = nil;
	local tbEvent = tbInfo[nIndex].condition[nFloor];
	for _, tbParam in ipairs(tbEvent) do
		for nParam, szParam in ipairs(tbParam) do
			local nSit = string.find(szParam, ":");
			if nSit and nSit > 0 then
				local szFlag = string.sub(szParam, 1, nSit - 1);
				if szFlag == szNeedFlag then
					local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
					if self.tbCheckEventfun[szFlag] ~= nil then
						local fncExcute = self[self.tbCheckEventfun[szFlag]];
						if fncExcute then
							local nFlag, szMsg = fncExcute(self, szContent, nNpcId, nIndex, nFloor);
							if nFlag and nFlag == 1 then	-- 成功
								ArmyCamp.tbTempRecord[nNpcId][nIndex].CheckRes[nFloor] = 1;
								return self:ExcuteSuccessEventFun(nNpcId, nIndex, nFloor);
							elseif nFlag and nFlag == -1 then	-- 失败
								ArmyCamp.tbTempRecord[nNpcId][nIndex].CheckRes[nFloor] = -1;
								return self:ExcuteFailureEventFun(nNpcId, nIndex, nFloor);
							end
						end
					end
				end
			end
		end
	end
	return nReFlag, szReMsg;
end

function tbFun:AddNpc(szParam, nNpcId, nIndex, nFloor)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local nBatch = tonumber(tbParam[1]) or 0;
	local szFilePath = tbParam[2] or "";
	local nDelay = tonumber(tbParam[3]) or 0;
	local szChat = tbParam[4] or "";
	if szChat ~= "" then 
		pNpc.SendChat(szChat);
	end
	if nDelay > 0 then
		Timer:Register(nDelay * 18, self.AddNpcCallBack, self, nNpcId, nIndex, nFloor, nBatch, szFilePath);
		return 1;
	end
	self:AddNpcCallBack(nNpcId, nIndex, nFloor, nBatch, szFilePath);
	return 1
end

function tbFun:AddNpcCallBack(nNpcId, nIndex, nFloor, nBatch, szFilePath)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nMapId = pNpc.GetWorldPos();
	local tbNpcFile = Lib:LoadTabFile(szFilePath);
	if not tbNpcFile then
		print("加载文件失败");
		return 0;
	end
	for _, tbTemp in ipairs(tbNpcFile) do
		local pXiaoGuai =  KNpc.Add2(tonumber(tbTemp["templateid"]), tonumber(tbTemp["level"]), tonumber(tbTemp["serires"]), nMapId, tonumber(tbTemp["posx"])/32, tonumber(tbTemp["posy"])/32, tonumber(tbTemp["revive"]), tonumber(tbTemp["boss"]));
		if pXiaoGuai then
			Npc:RegPNpcOnDeath(pXiaoGuai, self.OnDeath, self, nNpcId, nIndex, nFloor, nBatch);
		end
	end 
	 ArmyCamp.tbTempRecord[nNpcId]["AddNpc"] = ArmyCamp.tbTempRecord[nNpcId]["AddNpc"] or {};	-- 同一npc不同索引的npc记载同一个表上，注意用批次区分
	 ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nBatch] = ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nBatch] or {};
	 ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nBatch].nStartTime = GetTime();
	 ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nBatch].nKillCount = 0;
	 return 0;
end

-- 统一死亡回调,调用CheckKillCount检查是否满足条件
function tbFun:OnDeath(nNpcId, nIndex, nFloor, nBatch)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if not ArmyCamp.tbTempRecord[nNpcId] then
		return 0;
	end
	ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nBatch].nKillCount = ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nBatch].nKillCount + 1;
	self:ExcuteCheckEvent(nNpcId, nIndex, nFloor, "CheckKillCount");
end

-- 检查是否满足杀怪条件
function tbFun:CheckKillCount(szParam, nNpcId, nIndex, nFloor)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local nNeedBatch = tonumber(tbParam[1]) or 0;
	local nNeedCount = tonumber(tbParam[2]) or 0;
	local nLimitTime = tonumber(tbParam[3]) or 0;
	
	if not ArmyCamp.tbTempRecord[nNpcId] or not ArmyCamp.tbTempRecord[nNpcId]["AddNpc"] or not ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nNeedBatch]  then
		return 0;
	end
	local tbBatchInfo = ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nNeedBatch];
	if nLimitTime and nLimitTime > 0 then	-- 时间过期失败
		if GetTime() - tbBatchInfo.nStartTime > nLimitTime then
			return -1;
		end
	end
	if not nNeedCount or nNeedCount <= 0 then
		return 1;
	end 
	if ArmyCamp.tbTempRecord[nNpcId]["AddNpc"][nNeedBatch].nKillCount >= nNeedCount then
		return 1;
	end
	return 0;
end

-- 成功事件回调
function tbFun:CastSkill(szParam, nNpcId, nIndex, nFloor)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local nSkillId = tonumber(tbParam[1]) or 0;
	local nSkillLevel = tonumber(tbParam[2]) or 0;
	local nDelay = tonumber(tbParam[3]) or 0;
	if nDelay <= 0 then
		pNpc.CastSkill(nSkillId, nSkillLevel, -1, pNpc.nIndex);
	else
		Timer:Register(nDelay * 18, self.CastSkillDelay, self, nNpcId, nSkillId, nSkillLevel);
	end
	return 1;
end

-- 延迟放技能
function tbFun:CastSkillDelay(nNpcId, nSkillId, nSkillLevel)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.CastSkill(nSkillId, nSkillLevel, -1, pNpc.nIndex);
	return 0;
end

function tbFun:AddSkillState(szParam, nNpcId, nIndex, nFloor)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local nSkillId = tonumber(tbParam[1]) or 0;
	local nSkillLevel = tonumber(tbParam[2]) or 0;
	local nStateType = tonumber(tbParam[3]) or 0;
	local nDurTime = tonumber(tbParam[4]) or 0;
	local nIsNoClearOnDeath = tonumber(tbParam[5]) or 0;
	local nForce = tonumber(tbParam[6]) or 0;
	local nTrueTimeConver = tonumber(tbParam[7]) or 0;
	local nDelay = tonumber(tbParam[8]) or 0;
	if nDelay <= 0 then
		pNpc.AddSkillState(nSkillId, nSkillLevel, nStateType, nDurTime, nIsNoClearOnDeath, nForce, nTrueTimeConver);
	else
		Timer:Register(nDelay * 18, self.AddSkillStateDelay, self, nNpcId, nSkillId, nSkillLevel, nStateType, nDurTime, nIsNoClearOnDeath, nForce, nTrueTimeConver);
	end
	return 1;
end

function tbFun:AddSkillStateDelay(nNpcId, nSkillId, nSkillLevel, nStateType, nDurTime, nIsNoClearOnDeath, nForce, nTrueTimeConver)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.AddSkillState(nSkillId, nSkillLevel, nStateType, nDurTime, nIsNoClearOnDeath, nForce, nTrueTimeConver);
	return 0;
end

function tbFun:RemoveSkillState(szParam, nNpcId, nIndex, nFloor)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local nSkillId = tonumber(tbParam[1]) or 0;
	local nDelay = tonumber(tbParam[2]) or 0;
	if nDelay <= 0 then
		pNpc.RemoveSkillState(nSkillId);
	else
		Timer:Register(nDelay * 18, self.RemoveSkillStateDelay, self, nNpcId, nSkillId);
	end
	return 1;
end

function tbFun:RemoveSkillStateDelay(nNpcId, nSkillId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.RemoveSkillState(nSkillId);
	return 0;
end

function tbFun:TaskActTalk(szParam, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "";
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk(szMsg);
		Setting:RestoreGlobalObj();
	end
	return 1;
end

-- 黑条提示
function tbFun:SendBlackBoardMsg(szParam, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "";
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbPlayList, _ = KPlayer.GetMapPlayer(nSubWorld);
	if not tbPlayList then
		return 1;
	end
	for _, teammate in ipairs(tbPlayList) do
		Dialog:SendBlackBoardMsg(teammate, szMsg);
	end
	return 1;
end

-- npc喊话
function tbFun:SendChat(szParam, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbParam = self:SplitStr(szParam);
	local szMsg = tbParam[1] or "";
	pNpc.SendChat(szMsg);
	return 1;
end

-- npc死亡时清空数据
function Task.ArmyCamp:ClearData(nNpcId)
	if not Task.ArmyCamp.tbTempRecord then
		return;
	end
	Task.ArmyCamp.tbTempRecord[nNpcId] = nil;
end