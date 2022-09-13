-- 通用奖励相关处理

-- 取得当前玩家对话相关的临时Table
function GeneralAward:GetMyAward()
	local tbPlayerData		= me.GetTempTable("GeneralAward");
	local tbPlayerAward		= tbPlayerData.tbAward;
	if (not tbPlayerAward) then
		tbPlayerAward	= {
		};
		tbPlayerData.tbAward	= tbPlayerAward;
	end;
	
	return tbPlayerAward;
end;

-- S
function GeneralAward:SendAskAward(szMsg, tbAwards, tbCallBack)
	local tbPlayerAward = self:GetMyAward();
	tbPlayerAward.tbAwards = tbAwards;
	tbPlayerAward.tbCallBack = tbCallBack;
	me.CallClientScript({"GeneralAward:AskAward", szMsg, tbAwards})
end;

-- C
--打开通用奖励面板
-- CallClientScript({"GeneralAward:AskAward", "奖励总描述", tbS2CAward})
function GeneralAward:AskAward(szMsg, tbAward)
	-- 弹奖励面板，用户选了以后会传给服务端
	me.SetChainTaskAward(tbAward)
	CoreEventNotify(UiNotify.emCOREEVENT_TASK_AWARD, 0, szMsg);		-- 0代表无任务ID的任务
end;

-- S
function GeneralAward:OnAward(nChoice)
	local tbPlayerAward		= self:GetMyAward().tbAwards;
	
	if (not tbPlayerAward) or (tbPlayerAward == {}) then
		return;
	end;
	
	self:GetMyAward().tbAwards = nil;
	if tbPlayerAward.tbOpt then
		if (nChoice < 0 or nChoice > #tbPlayerAward.tbOpt) then
			print("[GeneralAward]: award paramer error!")
			return;
		end
	end
	
	local nNeedFreeBag = 0;
	
	-- 可选奖励
	if (tbPlayerAward.tbOpt and tbPlayerAward.tbOpt[nChoice]) then
		nNeedFreeBag = nNeedFreeBag + self:NeedFreeBagCount(tbPlayerAward.tbOpt[nChoice]);
	end;

	-- 固定奖励
	for _, tbAward in pairs(tbPlayerAward.tbFix) do
		nNeedFreeBag = nNeedFreeBag + self:NeedFreeBagCount(tbAward);
	end;
	-- 随机奖励
	local nMaxNeedBag = 0;
	if (tbPlayerAward.tbRandom) then
		for _, tbAward in pairs(tbPlayerAward.tbRandom) do
			local nTemp = self:NeedFreeBagCount(tbAward);
			if (nTemp > nMaxNeedBag) then
				nMaxNeedBag = nTemp;
			end
		end
	end
	nNeedFreeBag = nNeedFreeBag + nMaxNeedBag;
	if me.CountFreeBagCell() < nNeedFreeBag then
		Dialog:Say("Hành trang không đủ chỗ trống，请清理背包！")
		return;
	end
	
	-- 可选奖励
	--print("Start Give tbOpt: "..nChoice);
	if (tbPlayerAward.tbOpt and tbPlayerAward.tbOpt[nChoice]) then
		self:GiveAward(tbPlayerAward.tbOpt[nChoice]);
	end;
	-- 固定奖励
	--print("Start Give tbFix!");
	for _, tbAward in pairs(tbPlayerAward.tbFix) do
		--print("Giving tbFix!");
		self:GiveAward(tbAward);
	end;
	-- 随机奖励
	if (tbPlayerAward.tbRandom) then
		local nRand	= MathRandom();
		local nSum	= 0;
		for _, tbAward in pairs(tbPlayerAward.tbRandom) do
			nSum	= nSum + tbAward.nRate;
			if (nSum > nRand) then
				self:GiveAward(tbAward);
				break;
			end
		end
	end
	
	if (self:GetMyAward().tbCallBack) then
		Lib:CallBack(self:GetMyAward().tbCallBack);
	end
end

-- S
-- 计算所需背包空间
function GeneralAward:NeedFreeBagCount(tbAward)
	local szType	= tbAward.szType;
	local varValue	= tbAward.varValue;
	
	local nNeedFreeBag = 0;
	local nNum		= tonumber(tbAward.szAddParam1) or 1;
	if (szType == "item") then
		nNeedFreeBag = nNeedFreeBag + KItem.GetNeedFreeBag(varValue[1], varValue[2], varValue[3], varValue[4], nil, nNum);
	elseif (szType == "arrary") then
		for _, tbOneAward in ipairs(varValue) do
			nNeedFreeBag = nNeedFreeBag + self:NeedFreeBagCount(tbOneAward);
		end;
	end
	return nNeedFreeBag;
end

--S
-- 给与一组奖励
function GeneralAward:GiveAward(tbAward)
--	print("给奖励",me.szName)
	local szType	= tbAward.szType;
	local varValue	= tbAward.varValue;
	local szStatLogName = tbAward.szStatLogName;
	local nNum		= tonumber(tbAward.szAddParam1) or 1;
	if (szType == "exp") then
			
		--me.AddExp(varValue);
		local nExp = me.AddExp2(varValue,"task");
		if nExp > 0 then
			me.Msg("Nhận được <color=green>"..nExp.."<color> điểm kinh nghiệm!");
		end
		--KStatLog.ModifyAdd("LinkTask", me.szName, "获得总经验", varValue);
		
	elseif (szType=="linktask_cancel") then
		
		local nCancel = LinkTask:GetTask(LinkTask.TSK_CANCELNUM);
			nCancel = nCancel + 1;
			LinkTask:SetTask(LinkTask.TSK_CANCELNUM, nCancel);
			me.Msg("Nhận được 1 cơ hội hủy nhiệm vụ. Tổng số cơ hội hủy: <color=yellow>"..nCancel.."<color>");
			--KStatLog.ModifyAdd("LinkTask", me.szName, "选择取消机会次数", 1);
			
	elseif (szType == "money") then				
		me.Earn(varValue, Player.emKEARN_YIJUN);
		me.Msg("Nhận được <color=yellow>"..varValue.."<color> lượng bạc!");
		--KStatLog.ModifyAdd("LinkTask", me.szName, "获得银两总数", varValue);
		--KStatLog.ModifyAdd("jxb", "[产出]任务链", "总量", varValue);
		if szStatLogName then
			KStatLog.ModifyAdd("jxb", "[产出]"..szStatLogName, "总量", varValue);
		end
		
		self:TskProduceLog(Task.TSKPRO_LOG_TYPE_MONEY, varValue);
	elseif (szType == "bindmoney") then
		--越南防沉迷，david
		if (me.GetTiredDegree() == 1) then
			varValue = math.floor(varValue*0.5);
		end;
		
		--me.AddBindMoney(varValue, Player.emKBINDMONEY_ADD_YIJUN);
		local nBindMoneyEx = me.AddBindMoney2(varValue, "task", Player.emKBINDMONEY_ADD_YIJUN);
		if nBindMoneyEx > 0 then
			me.Msg("Nhận được <color=yellow>"..nBindMoneyEx.."<color> lượng bạc khóa!");
		end
		if szStatLogName then
			KStatLog.ModifyAdd("bindjxb", "[产出]"..szStatLogName, "总量", varValue);
		end
--		KStatLog.ModifyAdd("jxb", "[产出]任务链", "总量", varValue);
		
		self:TskProduceLog(Task.TSKPRO_LOG_TYPE_BINDMONEY, varValue);
				
	elseif (szType == "linktask_repute") then
		varValue[3] = math.floor(varValue[3] * 5);
		me.AddRepute(unpack(varValue));
		me.Msg("Nhận được Danh vọng Nghĩa quân <color=green>"..varValue[3].."<color> điểm!");
		
	elseif (szType == "title") then
		--AddTitle(unpack(tbAward.varValue))
	elseif (szType == "taskvalue") then
		me.SetTask(unpack(varValue));
	elseif (szType == "item") then
		local nXJCount, bBind = 0, 0;
		local nXJLevel = varValue[4];
		for i=1, nNum do
			local pItem = self:AddItem(me, varValue);
			if pItem and pItem.szClass == "xuanjing" then
				bBind = pItem.IsBind();
				nXJCount = nXJCount + pItem.nCount;
			end
		end
		Item:InsertXJRecordMemory(Item.emITEM_XJRECORD_TASK, Item.LINKTASK_XJLOG_ID, nXJLevel, (bBind == 1) and nXJCount or 0,
			(bBind == 0) and nXJCount or 0)
		
		me.Msg(string.format("Bạn nhận được %s vật phẩm phần thưởng!", nNum));
		
	elseif (szType == "gatherpoint") then
				
		TaskAct:AddGatherPoint(tonumber(varValue));
		me.Msg("Nhận được <color=green>"..varValue.."<color> điểm Hoạt lực!");
		
	elseif (szType == "makepoint") then
		
		TaskAct:AddMakePoint(tonumber(varValue));
		me.Msg("Nhận được <color=green>"..varValue.."<color> điểm Tinh lực!");
		
	elseif (szType == "arrary") then
		for _, tbOneAward in ipairs(varValue) do
			self:GiveAward(tbOneAward);
		end;
	end;
end;


-- 加物品
function GeneralAward:AddItem(pPlayer, tbItemId)
	local tbId	= {unpack(tbItemId)};
	if (tbId[4] == 0) then
		tbId[4]	= 1;
	end;
	if (tbId[5] == -1) then
		tbId[5]	= 0;
	end;
	tbId[7]		= tbId[6];
	tbId[6]		= 0;
	tbId[8]		= 0;
	tbId[9]		= 0;
	tbId[10]	= 0;
	
	local nBind = 0;
	if tbId[11] then
		nBind = tbId[11];
		table.remove(tbId, 11);
	end;
	
	local pItem = pPlayer.AddItem(unpack(tbId));
	
	if pItem and nBind ~= 0 then
		pItem.Bind(nBind);
	end;
	return pItem;
end;

function GeneralAward:TskProduceLog(nType, nValue)
	local tbAwardType = {
		[Task.TSKPRO_LOG_TYPE_MONEY] = "money",
		[Task.TSKPRO_LOG_TYPE_BINDMONEY] = "bindmoney",
		[Task.TSKPRO_LOG_TYPE_BINDCOIN] = "bindcoin",
		};
	
	-- 任务链任务（义军任务）的任务id是0，只好特殊对待
	local nTaskId = 0;
	local nSubTaskId = 0;
	local nTskProType = Task.emTskProType_Linktask;
	local szAwardType = tbAwardType[nType] or "";
	
	local szLog = string.format("%s,%s,%s,%s,%s", nTaskId, nSubTaskId, nTskProType, szAwardType, nValue);
	StatLog:WriteStatLog("stat_info", "taskproduct", "currency", me.nId, szLog);
end
