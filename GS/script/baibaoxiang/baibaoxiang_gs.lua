-------------------------------------------------------
-- 文件名　：baibaoxiang.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-04-06 20:46:39
-- 文件描述：
-------------------------------------------------------

Require("\\script\\baibaoxiang\\baibaoxiang_def.lua");

-- on-off switch
function Baibaoxiang:CheckState()
	return self.bOpen;
end

function Baibaoxiang:_SetState(bOpen)
	self.bOpen = bOpen;
end

function Baibaoxiang:CheckChangeBack()
	return self.bOpenChangeBack;
end

function Baibaoxiang:_SetChangeBack(bOpen)
	self.bOpenChangeBack = bOpen;
end

-- init
function Baibaoxiang:Init()
	
	if self:CheckState() ~= 1 then
		return;
	end
	
	-- read rate
	local tbMap1 = Lib:LoadTabFile(self.RATE_START_PATH);
	local tbMap2 = Lib:LoadTabFile(self.RATE_NORMAL_PATH);
	
	if not tbMap1 or not tbMap2 then
		return;
	end
	
	-- save
	self.tbRateStart = tbMap1;
	self.tbRateNormal = tbMap2;
end

-- 32 bits(0-31)：[ type:3(1-5) | level:2(1-3) ]，last 2 bits save random(3)

-- save one round result
function Baibaoxiang:SetRoundResult(pPlayer, nRound, nType, nLevel, nRandGrid)
	
	if nRound < 1 or nRound > 6 then
		return;
	end
	
	-- task
	local nTask = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_RESULT);
	
	-- offset
	local nIndex = (nRound - 1) * 5;
		
	nTask = Lib:SetBits(nTask, nType, nIndex, nIndex + 2);
	nTask = Lib:SetBits(nTask, nLevel, nIndex + 3, nIndex + 4); 
	nTask = Lib:SetBits(nTask, nRandGrid, 30, 31); 

	-- save new task
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_RESULT, nTask);
end

-- get first result
function Baibaoxiang:GetStartResult(pPlayer)

	local i = 0;
	local nAdd = 0;
	local nRand = 0;
	local nIndex = 0;

	-- random
	nRand = MathRandom(1, 10000);

	-- get field
	for i = 1, #self.tbRateStart do
		nAdd = nAdd + self.tbRateStart[i].Rate;
		if nAdd >= nRand then
			nIndex = i;
			break;
		end
	end
	
	-- find nil return
	if nIndex == 0 then
		return 0;
	end
	
	-- num type
	local nType = self.tbAwardConType[self.tbRateStart[nIndex].Type];
	
	-- num level
	local nLevel = tonumber(self.tbRateStart[nIndex].Level);
	
	-- save to current task
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TYPE, nType);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL, nLevel);
	
	-- result
	return 1, nType, nLevel;
end

-- get advanced result
function Baibaoxiang:GetNormalResult(pPlayer, nTimes)
	
	-- get total
	local nLevel = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL);
	local nType = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TYPE);
	
	-- no level or type box
	if nLevel <= 0 or nType == 5 then
		return 0;
	end

	local i = 0;
	local nAdd = 0;
	local nRand = 0;
	local nIndex = 0;
	
	-- random
	nRand = MathRandom(1, 10000);
	
	-- no match level
	if not self.tbRateNormal[nLevel] then
		return 0;
	end 
	
	-- fill 3 rate
	local tbRate = {
		self.tbRateNormal[nLevel].Level_1_Rate,
		self.tbRateNormal[nLevel].Level_2_Rate,
		self.tbRateNormal[nLevel].Level_3_Rate,
	};
	
	-- cac multiple
	local nAwardNum = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_COIN) / 2;
	
	-- add rate
	--if nLevel == 4 then
	--	tbRate[3] = tbRate[3] * nAwardNum;
	--elseif nLevel == 5 then
	--	tbRate[2] = tbRate[2] * nAwardNum;
	--	tbRate[3] = tbRate[3] * nAwardNum;
	--end
	
	-- get index
	for i = 1, 3 do
		nAdd = nAdd + tbRate[i];
		if nAdd >= nRand then
			nIndex = i;
			break;
		end
	end
	
	-- have match index
	if nIndex > 0 then
		
		-- cac total level
		local nTotalLevel = nLevel + nIndex;

		-- switch overflow
		if nTotalLevel > self.MAX_LEVEL then
			
			-- set max level 6
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL, self.MAX_LEVEL);
			
			-- set overflow flag
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_OVERFLOW, 1);
		
		else
			-- set current total level
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL, nTotalLevel);	
		end
	
		return 1, nType, nIndex;
		
	-- not found
	else
		-- so build a new map
		local tbRandMap = {};
		
		for i = 1, 4 do
			
			-- checkout now type
			if nType ~= i then
				table.insert(tbRandMap, {i, 1});
				table.insert(tbRandMap, {i, 1});
				table.insert(tbRandMap, {i, 1});
				table.insert(tbRandMap, {i, 2});
				table.insert(tbRandMap, {i, 3});
			end
		end
		
		-- run a real random
		local nRandom = MathRandom(1, #tbRandMap);
		
		-- load type & level
		local nRandType = tbRandMap[nRandom][1];
		local nRandLevel = tbRandMap[nRandom][2]; 
		
		-- clear total type & level
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TYPE, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL, 0);
		
		return 2, nRandType, nRandLevel;
	end
end

-- check client get result
function Baibaoxiang:CheckAllowGetResult(pPlayer, nCoin)
	if (GLOBAL_AGENT) then
		return 0;
	end
	
	if self:CheckState() ~= 1 then
		return 0;
	end
	
	local nInterval = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_INTERVAL);
	
	if GetTime() - nInterval < 3 then
		return 0;
	end
	
	-- cac multiple
	local nAwardNum = nCoin / 2;
	
	-- only 3 type
	if nAwardNum ~= 1 and nAwardNum ~= 5 and nAwardNum ~= 25 then	
		return 0;
	end
	
	-- check overflow
	local bOverflow = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_OVERFLOW);
	
	if bOverflow == 1 then
		return 0;
	end

	-- check times
	local nTimes = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TIMES);
	local bContinue = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_CONTINUE);	
	
	if nTimes > 0 and bContinue == 0 then
		return 0;
	end
	
	-- check coin. the last step 
	local nTaskCoin = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_COIN);
	
	if nTaskCoin <= 0 then

		-- find coin in bags
		local nFind = pPlayer.GetItemCountInBags(18, 1, 325, 1);
	
		-- check num
		if nFind < nCoin then	
			return 0;
		end
		
		-- consume item
		-- todo: return
		local bRet = pPlayer.ConsumeItemInBags(tonumber(nCoin), 18, 1, 325, 1);
		
		-- log
		self:_Log(pPlayer, "扣除贝壳："..nCoin);
	
		-- set coin
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_COIN, nCoin);
		
		-- call gc deal
		GCExcute({"Baibaoxiang:AddCoin_GC", pPlayer.nId, tonumber(nCoin) * 2});	
	end
	
	-- can get result
	return 1;
end

-- client to server event
function Baibaoxiang:GetResult(pPlayer, nCoin)
	
	-- options
	local bOK = self:CheckAllowGetResult(pPlayer, nCoin);
	
	if bOK ~= 1 then
		pPlayer.Msg("Hiện giờ không thể sử dụng Bách Bảo Rương.");
		return;
	end
	
	-- interval
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_INTERVAL, GetTime());
	
	-- overflow flag
	local bOverflow = 0;
	
	-- result table
	local tbResult = {};
	
	-- get play times
	local nTimes = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TIMES);	
	
	-- first time
	if nTimes <= 0 then
		
		-- get first result
		local bOK, nType, nLevel = self:GetStartResult(pPlayer);
		
		-- failed(error condition, need log)
		if bOK ~= 1 then
			self:_Reset(pPlayer);
			return;
		end
			
		local nRandGrid = 0;
		
		-- box 1/2
		if nType == 5 then
			nRandGrid = MathRandom(1, 2);
		-- level 1/3
		elseif nLevel == 1 then
			nRandGrid = MathRandom(1, 3);
		end
		
		-- save one time award
		self:SetRoundResult(pPlayer, 1, nType, nLevel, nRandGrid);
	
		-- save times
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TIMES, 1);
		
		-- box type over
		if nType == 5 then
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_CONTINUE, 0);
		else
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_CONTINUE, 1);
		end
		
		-- to client
		tbResult.Type = nType;
		tbResult.Level = nLevel;
		tbResult.Times = 1;
		tbResult.Grid = nRandGrid;
		
	-- times(n)
	else
		
		-- cac current time
		local nCurrTimes = nTimes + 1;

		-- get result
		local bOK, nType, nLevel = self:GetNormalResult(pPlayer);
		
		-- failed(error condition, need log)
		if bOK <= 0 then
			self:_Reset(pPlayer);
			return;
		end
		
		local nRandGrid = 0;
		
		-- box 1/2
		if nType == 5 then
			nRandGrid = MathRandom(1, 2);
		-- level 1/3
		elseif nLevel == 1 then
			nRandGrid = MathRandom(1, 3);
		end
		
		-- save one time award
		self:SetRoundResult(pPlayer, nCurrTimes, nType, nLevel, nRandGrid);
			
		-- same type
		if bOK == 1 then
			
			local nTotalLevel = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL);
			
			if nTotalLevel == 6 then
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_CONTINUE, 0);
			else	
				-- can continue		
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_CONTINUE, 1);
			end
			
			-- save times
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TIMES, nCurrTimes);
					
		-- different type
		elseif bOK == 2 then
			
			-- direct reset
			self:_Reset(pPlayer);
		end
		
		-- to client
		tbResult.Type = nType;
		tbResult.Level = nLevel;
		tbResult.Times = nCurrTimes;
		tbResult.Grid = nRandGrid;
	end
	
	-- call client script
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_BAIBAOXIANG", "OnRecvResult", tbResult});
end

-- check get award
function Baibaoxiang:CheckAllowGetAward(pPlayer, nType)
	if (GLOBAL_AGENT) then
		return 0;
	end

	if self:CheckState() ~= 1 then
		return 0;
	end
	
	local nInterval = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_INTERVAL);
	
	if GetTime() - nInterval < 3 then
		return 0;
	end
	
	-- cac multiple
	local nAwardNum = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_COIN) / 2;
	
	-- check level
	local nAwardLevel = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL);
	
	if nAwardLevel <= 0 then
		return 0;
	end
		
	-- check type
	local nAwardType = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TYPE);
	
	if not self.tbAwardType[nAwardType] then
		return 0;
	end
		
	-- check overflow space
	local nSpaceGC = 0;
	local bOverflow = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_OVERFLOW);	
	
	if bOverflow == 1 then
		local nCaichi = KGblTask.SCGetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI) / 100;
		
		nSpaceGC = math.floor(nCaichi / 2000) + 1;
		
		-- max 20 space
		if nSpaceGC > 20 then
			nSpaceGC = 20;
		end
	end
	
	-- check space
	if nType == 1 then
	
		-- get award index
		local szAwardType = self.tbAwardType[nAwardType];
		local nAward = self.tbAwardValue[szAwardType][nAwardLevel];
	
		-- xuanjing or box
		if nAwardType == 1 or nAwardType == 5 then
			if pPlayer.CountFreeBagCell() < nAwardNum + nSpaceGC then
				Dialog:SendBlackBoardMsg(pPlayer, "Hành trang không đủ "..tostring(nAwardNum + nSpaceGC).." ô trống.");
				return 0;
			end
			
		-- money
		elseif nAwardType == 3 then
			if nAward * nAwardNum + pPlayer.nCashMoney > pPlayer.GetMaxCarryMoney() then
				Dialog:SendBlackBoardMsg(pPlayer, "Số tiền được mang theo vượt quá giới hạn cho phép, hãy sắp xếp và thử lại.");
				return 0;
			end
		end
		
		-- extra check
		if pPlayer.CountFreeBagCell() < nSpaceGC then
			Dialog:SendBlackBoardMsg(pPlayer, "Hành trang không đủ "..tostring(nSpaceGC).." ô trống.");
			return 0;
		end
		
	-- coin
	elseif nType == 2 then
		
		-- box type
		if nAwardType == 5 then 
			return 0;
		end
		
		local nAward = self.tbAwardValue["贝壳"][nAwardLevel];
		local nSpace = math.floor(nAward * nAwardNum / 1000) + 1;

		if pPlayer.CountFreeBagCell() < nSpace + nSpaceGC then
			local szMsg = string.format("Hành trang không đủ %s ô trống.", nSpace + nSpaceGC);
			Dialog:SendBlackBoardMsg(pPlayer, szMsg);
			return 0
		end
		
	-- unknwon type
	else
		return 0;
	end
	
	-- can get award
	return 1;
end

-- client to server event
function Baibaoxiang:GetAward(pPlayer, nType)
	
	-- check allow
	local bOK = self:CheckAllowGetAward(pPlayer, nType);
	
	if bOK ~= 1 then
		return;
	end
	
	-- interval
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_INTERVAL, GetTime());
	
	-- get multiple
	local nAwardNum = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_COIN) / 2;
	
	-- get level & type
	local nAwardLevel = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL);
	local nAwardType = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TYPE);
	
	-- get award
	if nType == 1 then
		
		-- get award index
		local szAwardType = self.tbAwardType[nAwardType];
		local nAward = self.tbAwardValue[szAwardType][nAwardLevel];
	
		-- xuanjing
		if nAwardType == 1 then
			local i = 0;
			for i = 1, nAwardNum do
				pPlayer.AddItem(18, 1, 1, nAward);
			end
			
			-- channel
			if nAwardLevel >= 4 then
				pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] nhận được từ bách bảo rương <color=yellow>"
					..nAwardNum.."<color> huyền tinh "..nAward.."");
				Player:SendMsgToKinOrTong(pPlayer, "Nhận được từ bách bảo rương "..nAwardNum.." huyền tinh "..nAward..".", 0);
			end
			
			-- log
			self:_Log(pPlayer, "获得" .. nAward .. "级玄晶" .. nAwardNum .. "个");
			
		-- jinghuo
		elseif nAwardType == 2 then
			pPlayer.ChangeCurMakePoint(nAward * nAwardNum);
			pPlayer.ChangeCurGatherPoint(nAward * nAwardNum);
			
			-- channel
			if nAwardLevel >= 4 then
				pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] nhận được từ bách bảo rương <color=yellow>"
					..(nAward * nAwardNum).."<color> tinh hoạt lực");
				Player:SendMsgToKinOrTong(pPlayer, " nhận được từ bách bảo rương "..(nAward * nAwardNum).." tinh hoạt lực", 0);
			end
			
			-- need channel msg 
			pPlayer.Msg(string.format("Bạn nhận được <color=yellow>%s<color> tinh lực", nAward * nAwardNum));
			pPlayer.Msg(string.format("Bạn nhận được <color=yellow>%s<color> hoạt lực", nAward * nAwardNum));
			
			-- log
			self:_Log(pPlayer, "获得" .. (nAward * nAwardNum) .. "点精活");
			
		-- money
		elseif nAwardType == 3 then
			pPlayer.Earn(nAward * nAwardNum, Player.emKEARN_BAIBAOXIANG_MONEY);
			
			-- channel
			if nAwardLevel >= 4 then
				pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] nhận được từ bách bảo rương<color=yellow>"
					..(nAward * nAwardNum).."<color> lượng bạc!");
				Player:SendMsgToKinOrTong(pPlayer, " nhận được từ bách bảo rương "..(nAward * nAwardNum).." lượng bạc!", 0);
			end	
			
			-- log
			self:_Log(pPlayer, "获得" .. (nAward * nAwardNum) .. "银两");
			
		-- bind money
		elseif nAwardType == 4 then
			pPlayer.AddBindCoin(nAward * nAwardNum, Player.emKBINDCOIN_ADD_BAIBAOXIANG);
			
			-- channel
			if nAwardLevel >= 4 then
				pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] nhận được từ bách bảo rương <color=yellow>"
					..(nAward * nAwardNum)..string.format("<color> %s", IVER_g_szCoinName));
				Player:SendMsgToKinOrTong(pPlayer, " nhận được từ bách bảo rương "..(nAward * nAwardNum)..string.format(" %s", IVER_g_szCoinName), 0);
			end	
			
			-- log
			self:_Log(pPlayer, "获得" .. (nAward * nAwardNum) .. "绑金");
			
		-- box
		elseif nAwardType == 5 then
			local i = 0;
			for i = 1, nAwardNum do
				pPlayer.AddItem(18, 1, 324, 1);
			end
			pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] nhận được từ bách bảo rương <color=yellow>"
				..(nAward * nAwardNum).."<color> rương");
			Player:SendMsgToKinOrTong(pPlayer, " nhận được từ bách bảo rương "..(nAward * nAwardNum).." rương", 0);
					
			-- log
			self:_Log(pPlayer, "获得" .. (nAward * nAwardNum) .. "个箱子");
		end
		
		local bOverflow = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_OVERFLOW);	
		
		-- check overflow
		if bOverflow == 1 then
				
			-- lock player
			pPlayer.AddWaitGetItemNum(1);
			
			-- call gc deal
			GCExcute({"Baibaoxiang:GetCoin_GC", pPlayer.nId});	
		end
	
	-- get coin
	elseif nType == 2 then
		
		-- box type forbidden
		if nAwardType == 5 then
			return;
		end
		
		-- num
		local nAward = self.tbAwardValue["贝壳"][nAwardLevel];
	
		-- give coin
		pPlayer.AddStackItem(18, 1, 325, 1, nil, nAward * nAwardNum);
		
		if nAwardLevel >= 4 then
			pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] nhận được từ bách bảo rương <color=yellow>"
				..(nAward * nAwardNum).."<color> Vỏ sò vàng!");
			Player:SendMsgToKinOrTong(pPlayer, " nhận được từ bách bảo rương "..(nAward * nAwardNum).." Vỏ sò vàng !", 0);
		end
				
		-- log
		self:_Log(pPlayer, "获得" .. (nAward * nAwardNum) .. "个金贝壳");		
			
		local bOverflow = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_OVERFLOW);	
		
		-- check overflow
		if bOverflow == 1 then
				
			-- lock player
			pPlayer.AddWaitGetItemNum(1);
			
			-- call gc deal
			GCExcute({"Baibaoxiang:GetCoin_GC", pPlayer.nId});	
		end
	
	-- unknwon type
	else
		return;
	end
	
	-- call client
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_BAIBAOXIANG", "OnReset"});
	
	-- reset
	self:_Reset(pPlayer);
end

-- gc callback
function Baibaoxiang:GetCoin_GS(nPlayerID, nCoin)
	
	-- get obj by player id
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
	
	-- offline?
	if not pPlayer then
		return;
	end
	
	-- stack item
	pPlayer.AddStackItem(18, 1, 325, 1, nil, nCoin);
	
	-- unlock
	pPlayer.AddWaitGetItemNum(-1);
	
	-- channel
	local szMsg = string.format("Người chơi <color=green>%s<color> nhận được thái tri từ bách bảo rương %s vỏ sò vàng ! Thật may mắn.", pPlayer.szName, nCoin);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	
	pPlayer.SendMsgToFriend("Hảo hữu của bạn [<color=green>"..pPlayer.szName.."<color>] nhận được thái tri từ bách bảo rương <color=yellow>"
		..nCoin.."<color> vỏ sò vàng");
		
	Player:SendMsgToKinOrTong(pPlayer, " nhận được thái tri từ bách bảo rương "..nCoin.." vỏ sò vàng", 0);
	
	-- add news to help
	self:UpdateHelpTable(pPlayer, nCoin);
	
	-- log
	local nLeft = math.floor(KGblTask.SCGetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI) / 100);
	local szLog = "从彩池获得" .. nCoin .. "贝壳，彩池剩余贝壳：" .. nLeft;
	self:_Log(pPlayer, szLog);
end

-- c2s function
function Baibaoxiang:OnPlayerGetAward(nType)
	self:GetAward(me, nType);
end

function Baibaoxiang:OnPlayerGetResult(nCoin)
	self:GetResult(me, nCoin)
end

-- reset
function Baibaoxiang:_Reset(pPlayer)
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_LEVEL, 0);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TIMES, 0);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_TYPE, 0);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_COIN, 0);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_RESULT, 0);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_CONTINUE, 0);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BAIBAOXIANG_OVERFLOW, 0);
end

-- log
function Baibaoxiang:_Log(pPlayer, szLog)

	-- log
	Dbg:WriteLog("Baibaoxiang", "百宝箱", pPlayer.szAccount, pPlayer.szName, szLog);
			
	-- service log
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "使用百宝箱，" .. szLog);	
end

-- help table
function Baibaoxiang:UpdateHelpTable(pPlayer, nCoin)

	-- time
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	
	local i = 0;
	local szMsg = "";
	local tbMap = {};
	local nCount = 0;
	
	-- fill text
	local szDate = os.date("%Y年%m月%d日 %H:%M:%S", GetTime());
	local szTxt = "<color=cyan>" .. szDate .. "\n" .."<color=yellow>" .. pPlayer.szName 
		.. " <color=green>在百宝箱的彩池中获得" .. "<color=yellow> " .. nCoin 
		.. " <color=green>" .. "枚金贝壳！<color>";
	
	-- get help
	local tbHelp = Task.tbHelp.tbNewsList[21];
	
	-- nil then clear count
	if not tbHelp then
		nCount = 0;
	else
		-- get msg key
		local szHelp = Task.tbHelp.tbNewsList[21].szMsg;
		
		-- no msg or ""
		if not szHelp or #szHelp < 1 then
			nCount = 0;
		else
			-- split to table
			tbMap = Lib:SplitStr(szHelp, "\n\n");
			nCount = #tbMap;
		end
	end
    
    -- max 10 no hole
	if nCount == 10 then
		
		-- roll up 
		for i = 1, 8 do 
			tbMap[i] = tbMap[i + 1];
			local nStart, nEnd = string.find(tbMap[i], ". ");
			tbMap[i] = string.sub(tbMap[i], 1, nStart - 2) .. i .. ". " .. string.sub(tbMap[i], nEnd + 1);
		end
		
		-- 9 special for 2 pos
		tbMap[9] = tbMap[10];
		local nStart, nEnd = string.find(tbMap[9], ". ");
		tbMap[9] = string.sub(tbMap[9], 1, nStart - 3) .. "9. " .. string.sub(tbMap[9], nEnd + 1);
		
		-- 10 final
		tbMap[10] = "<color=pink>10. " .. szTxt;
	else
		-- add to last
		tbMap[nCount + 1] = "<color=pink>" .. (nCount + 1).. ". " .. szTxt;
	end

	-- contract to msg
	for i = 1, #tbMap - 1 do
	   szMsg = szMsg .. tbMap[i] .. "\n\n";
	end             
	
	-- last cut "\n\n"
	szMsg = szMsg .. tbMap[#tbMap];
	
	-- call addnews
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_BAIBAOXIANG, "百宝箱爆机榜", szMsg, nEndTime, nAddTime);
end

-- only for test
function Baibaoxiang:ClearHelpTable()
	
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_BAIBAOXIANG, "百宝箱爆机榜", "", nEndTime, nAddTime);
end

function Baibaoxiang:OnChangeBack(nType, tbItem)
	
	local tbType = 
	{
		[1] = {18, 1, 325, 1},
		[2] = {22, 1, 61, 1},
		[3] = {18, 1, 337, 1},
	};
	
	if not tbType[nType] then
		return 0;
	end
	
	local nExCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		
		if szKey == string.format("%s,%s,%s,%s", unpack(tbType[nType])) then
			nExCount = nExCount + pItem.nCount;
		end
	end
	
	if nExCount <= 0 then
		Dialog:Say("请放入正确的物品。");
		return 0;
	end
	
	local nExTempCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		if szKey == string.format("%s,%s,%s,%s", unpack(tbType[nType])) then
			me.DelItem(pItem);
			nExTempCount = nExTempCount + pItem.nCount;
		end
		if nExTempCount >= nExCount then
			break;
		end
	end
	
	if nType == 1 then
		
		me.AddStackItem(18, 1, 205, 1, nil, nExCount * 2);
		
		me.ChangeCurMakePoint(nExCount * 225); 	-- jingli
		me.Msg(string.format("Nhận được <color=yellow>%s<color> tinh lực", nExCount * 225));
		
		me.ChangeCurGatherPoint(nExCount * 200); 	-- huoli		
		me.Msg(string.format("Nhận được <color=yellow>%s<color> hoạt lực", nExCount * 200));
		
	elseif nType == 2 then
		me.AddStackItem(18, 1, 205, 1, nil, nExCount);
		me.ChangeCurGatherPoint(nExCount * 100); 	-- huoli
		me.Msg(string.format("Nhận được <color=yellow>%s<color> hoạt lực", nExCount * 100));
	
	elseif nType == 3 then
		me.AddStackItem(18, 1, 205, 1, nil, nExCount * 200);
		me.ChangeCurGatherPoint(nExCount * 20000); 	-- huoli
		me.Msg(string.format("Nhận được <color=yellow>%s<color> hoạt lực", nExCount * 20000));
	end
end

if (not MODULE_GAMESERVER) then
	return 0;
end

-- call init
Baibaoxiang:Init();
