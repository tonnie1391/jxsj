-------------------------------------------------------
-- 文件名　：youlongmibao_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-10-29 14:30:51
-- 文件描述：
-------------------------------------------------------

Require("\\script\\event\\youlongmibao\\youlongmibao_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

-- 系统开关
function Youlongmibao:CheckState()
	return self.bOpen;
end

function Youlongmibao:SetState(bOpen)
	self.bOpen = bOpen;
end

-- 初始化
function Youlongmibao:Init()
	
	if self:CheckState() ~= 1 then
		return 0;
	end
	
	-- 读取概率表
	local tbRate = Lib:LoadTabFile(self.TYPE_RATE_PATH);
	if not tbRate then 
		return 0;
	end
	
	-- 概率表
	Lib:SmashTable(tbRate)
	self.tbRate = tbRate;
	
	self.nWeight = 0; 			-- 计算表现概率权值
	self.RandMax = 0; 			-- 随机概率
	self.tbHappyEgg = nil;		-- 开心蛋
	self.tbServerUseRate = {};	-- 物品表
	
	for _, tbRow in pairs(self.tbRate) do
		
		self.nWeight = self.nWeight + tonumber(tbRow.Weight);
		self.RandMax = self.RandMax + tonumber(tbRow.Rate);
		
		-- 服务器奖励物品
		local nServerCountUse 	= tonumber(tbRow.ServerCountUse) or 0;
		if nServerCountUse > 0 then
			table.insert(self.tbServerUseRate, tbRow);
		end
		
		-- 开心蛋
		if Youlongmibao.ITEM_HAPPYEGG == tbRow.Id then
			self.tbHappyEgg = tbRow;
		end
	end
	
	-- 玩家数据表
	self.tbPlayerList = self.tbPlayerList or {};
	self.tbPlayerBindTypeList = self.tbPlayerBindTypeList or {};
end

function Youlongmibao:CheckItemValid(pPlayer, tbInfo)
	if self:GetLastBindType(pPlayer) == 0 then
		return 1;
	end
	local nIndex = tonumber(tbInfo.Index);
	for _, nExcludeId in pairs(self.tbExcludeBind) do
		if nExcludeId == nIndex then
			return 0;
		end
	end
	return 1;
end

-- 生成25个随机物品列表
function Youlongmibao:GetItemList(pPlayer)
	
	if not self.tbRate then
		return nil;
	end
	
	-- 4个真的，21个假的
	local tbReal = {};
	local tbRateTemp = {};
	local tbItemList = {tbTimes = {}, tbResult = {}};
	
	-- 个人累计次数(中奖清0)
	local nSumCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_COUNT);
	
	local bTaskCountNoUse = 0;		-- 是否有限制次数奖励
	local bServerCountUse = 0;		-- 是否有服务器次数奖励
	local nTaskCountNoUseMax = 0;	-- 最大单个限制次数
	local nServerCountUseMax = 0;	-- 最大服务器限制次数
	local nRandMax = 0; 			-- 总概率
	local bHappyerEgg = 0; 			-- 开心蛋
	
	for i = 1, #self.tbRate do
		
		-- 使用次数要大于需求次数才出现。
		local nTaskCountNoUse = tonumber(self.tbRate[i].TaskCountNoUse) or 0;
		local nServerCountUse = tonumber(self.tbRate[i].ServerCountUse) or 0;
				
		if nSumCount >= nTaskCountNoUse then
			table.insert(tbRateTemp, self.tbRate[i]);
			nRandMax = nRandMax + tonumber(self.tbRate[i].Rate);
		end
		
		-- 单个限制最大次数
		if nTaskCountNoUse > 0 and nTaskCountNoUseMax < nTaskCountNoUse then
			nTaskCountNoUseMax = nTaskCountNoUse;
		end
		
		-- 记录服务器最大必出限制
		if nServerCountUse > 0 and nServerCountUseMax < nServerCountUse then
			nServerCountUseMax = nServerCountUse;
		end
	end
	
	-- 先生成4个真奖励，并随机插入到4/25位置上
	for i = 1, self.MAX_TIMES do
		
		-- 通用随机算法
		local nRepeatTimes = 0;
		local nIndex = 0;
		repeat
			local nAdd = 0;
			local nRand = MathRandom(1, nRandMax);
			nRepeatTimes = nRepeatTimes + 1;
			for j = 1, #tbRateTemp do
				nAdd = nAdd + tbRateTemp[j].Rate;
				if nAdd >= nRand then
					nIndex = j;
					break;
				end
			end
		until self:CheckItemValid(pPlayer, tbRateTemp[nIndex]) == 1 or nRepeatTimes >= 100; -- 防止死循环

		-- 保存Name和Id
		tbReal[i] = self:PutItemIntoList(tbRateTemp[nIndex]);

		--记录是否出现了要求次数需求的物品
		local nTaskCountNoUse = tonumber(tbRateTemp[nIndex].TaskCountNoUse) or 0;
		local nServerCountUse = tonumber(tbRateTemp[nIndex].ServerCountUse) or 0;
		
		-- 是否有限制大奖
		if nTaskCountNoUse > 0 then
			bTaskCountNoUse = 1;
		end
		
		-- 是否服务器大奖
		if nServerCountUse > 0 then
			bServerCountUse = 1;
		end
		
		-- 是否有蛋
		if tbRateTemp[nIndex].Id == self.ITEM_HAPPYEGG then
			bHappyerEgg = 1;
		end
		
		-- 随机插入
		local nGrid = MathRandom(1, self.MAX_GRID);
		while tbItemList.tbResult[nGrid] do
			nGrid = MathRandom(1, self.MAX_GRID);
		end
		
		-- 保存位置索引
		tbItemList.tbResult[nGrid] = tbReal[i];
		tbItemList.tbTimes[i] = nGrid;
	end
	
	-- 生成21个表现物品
	for i = 1, self.MAX_GRID do
		
		-- 通用随机算法
		local nAdd = 0;
		local nIndex = 0;
		local nRand = MathRandom(1, self.nWeight);
		
		for j = 1, #self.tbRate do
			nAdd = nAdd + self.tbRate[j].Weight;
			if nAdd >= nRand then
				nIndex = j;
				break;
			end
		end
		-- 找到空位
		if not tbItemList.tbResult[i] then
			tbItemList.tbResult[i] = self:PutItemIntoList(self.tbRate[nIndex]);
		end
	end
	
	-- 前5次必得开心蛋
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_HAPPY_EGG) == 0 then
		if nSumCount >= 1 and bHappyerEgg == 0 and self.tbHappyEgg then
			local nOutTime = MathRandom(1, self.MAX_TIMES);
			local nOutIndex = tbItemList.tbTimes[nOutTime];
			tbItemList.tbResult[nOutIndex] = self:PutItemIntoList(self.tbHappyEgg);			
		end
	end
	
	-- 服务器全局次数大奖
	local nServerSumCount = KGblTask.SCGetDbTaskInt(DBTASK_YOULONGMIBAO_COUNT);	
	if bTaskCountNoUse == 0 and nServerSumCount >= nServerCountUseMax then
		if bServerCountUse == 0 then
			local tbRand = self.tbServerUseRate[MathRandom(1, #self.tbServerUseRate)];
			local nOutTime = MathRandom(1, self.MAX_TIMES);
			local nOutIndex = tbItemList.tbTimes[nOutTime];
			tbItemList.tbResult[nOutIndex] = self:PutItemIntoList(tbRand);
		end
		-- 不管是否被领，都要清掉
		KGblTask.SCSetDbTaskInt(DBTASK_YOULONGMIBAO_COUNT, 0);
	end
	
	return tbItemList;
end

-- 设置item表数据
function Youlongmibao:PutItemIntoList(tbRand)
	local tbItemList = 
	{
		Name = tbRand.Name, 
		Id = tbRand.Id;
		Level = tbRand.Level;
		BindType = tbRand.BindType;
		Timeout = tbRand.Timeout;
		SystemMsg = tbRand.SystemMsg;
		TongMsg = tbRand.TongMsg;
		FriendMsg = tbRand.FriendMsg;
		ChangeCoin = tbRand.ChangeCoin;
	};
	return tbItemList;
end

-- 判断是否能开始游戏
function Youlongmibao:CheckGameStart(pPlayer)
	
	if self:CheckState() ~= 1 then
		return 0;
	end
	
	-- 有奖励未领
	if self:CheckGetAward(pPlayer) == 1 then
		Dialog:SendBlackBoardMsg(pPlayer, "Bạn chưa nhận thưởng, không thế tiếp tục.");
		return 0;
	end
	
	-- 4次限制
	if self.tbPlayerList[pPlayer.nId] then	
		local nTimes = self.tbPlayerList[pPlayer.nId].nTimes;
		if nTimes >= self.MAX_TIMES then
			Dialog:SendBlackBoardMsg(pPlayer, "Đã khiên chiến 4 lần rồi, hãy chọn thử lại");
			return 0;
		end
	end
	
	return 1;
end

-- 开始一轮游戏，最多4次奖励
function Youlongmibao:GameStart(pPlayer)

	local bOK = self:CheckGameStart(pPlayer);
	if bOK ~= 1 then
		return 0;
	end
		
	-- 申请一块玩家数据表(第一次)
	-- 得到25个随机物品，设置次数及领奖标记
	if not self.tbPlayerList[pPlayer.nId] then
		self.tbPlayerList[pPlayer.nId] = {};
		self.tbPlayerList[pPlayer.nId].nTimes = 1;
		self.tbPlayerList[pPlayer.nId].tbGetAward = {0,0,0,0};
		self.tbPlayerList[pPlayer.nId].tbItemList = self:GetItemList(pPlayer);
	else
		-- 次数加1
		self.tbPlayerList[pPlayer.nId].nTimes = self.tbPlayerList[pPlayer.nId].nTimes + 1;	
	end
	
	-- 调用客户端ui脚本，返回物品列表
	self.tbPlayerList[pPlayer.nId].tbItemList.tbResult.nStep = 1;
	pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_YOULONGMIBAO"});
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_YOULONGMIBAO", "OnGetResult", self.tbPlayerList[pPlayer.nId].tbItemList.tbResult});
	
	-- add 2010-4-28
	-- 1. 记录未领取的游龙古币值
	-- 2. 生成奖励后，记录本地log
	local nTimes = self.tbPlayerList[pPlayer.nId].nTimes;
	local nGrid = self.tbPlayerList[pPlayer.nId].tbItemList.tbTimes[nTimes];
	local tbItem = self.tbPlayerList[pPlayer.nId].tbItemList.tbResult[nGrid];
	local nChangeCoin = tonumber(tbItem.ChangeCoin) or 0;
	local nDeposit = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DEPOSIT_COIN);
	
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_DEPOSIT_COIN, nDeposit + nChangeCoin);
	Dbg:WriteLog("游龙密室", string.format("[游龙密室]%s生成奖励：%s", pPlayer.szName, tbItem.Name));
end

-- 中止游戏
function Youlongmibao:GameStop(pPlayer)
	if self.tbPlayerList[pPlayer.nId] then
		self.tbPlayerList[pPlayer.nId] = nil;
	end
	if self.tbPlayerBindTypeList[pPlayer.nId] then
		self.tbPlayerBindTypeList[pPlayer.nId] = nil;
	end
end

-- 界面被关闭后，恢复数据，要先CheckHaveAward
function Youlongmibao:RecoverAward(pPlayer)
	pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_YOULONGMIBAO"});
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_YOULONGMIBAO", "OnGetResult", self.tbPlayerList[pPlayer.nId].tbItemList.tbResult});
end

-- 领奖前置判断
function Youlongmibao:CheckGetAward(pPlayer)
	
	if self:CheckState() ~= 1 then
		return 0;
	end
	
	if not self.tbPlayerList[pPlayer.nId] then
		return 0;
	end
	
	local nTimes = self.tbPlayerList[pPlayer.nId].nTimes;
	if nTimes > self.MAX_TIMES then
		return 0;
	end
	
	local nGet = self.tbPlayerList[pPlayer.nId].tbGetAward[nTimes];
	if nGet ~= 0 then
		return 0;
	end

	return 1;
end

-- 显示结果
function Youlongmibao:ShowAward(pPlayer)
	
	local bOK = self:CheckGetAward(pPlayer);
	if bOK ~= 1 then
		Dialog:SendBlackBoardMsg(pPlayer, "Bạn không có phần thưởng để nhận.");
		return 0;
	end
	
	-- 取当前次数，奖励，物品Id
	local nTimes = self.tbPlayerList[pPlayer.nId].nTimes;
	local nGrid = self.tbPlayerList[pPlayer.nId].tbItemList.tbTimes[nTimes];
	local tbItem = self.tbPlayerList[pPlayer.nId].tbItemList.tbResult[nGrid];
	
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_YOULONGMIBAO", "OnShowAward", tbItem});
	self:ShowDetail(pPlayer);
	
	--如果是中了大奖（游龙阁声望符），推送SNS通知
	--Index参见配置表\setting\event\youlongmibao\youlongmibao_rate.txt
	-- if tonumber(tbItem.Level) == 5 and pPlayer.GetTask(2056, 12) == 0 then
		-- local szPopupMessage = "您的运气真是太好啦！\n把获得<color=yellow>游龙阁大奖<color>的消息<color=yellow>截图<color>分享给朋友们吧！";
		-- local szTweet = string.format("#剑侠世界# 人品大爆发，游龙阁爆机啦！我获得了%s！", tbItem.Name);
		-- Sns:NotifyClientNewTweet(pPlayer, szPopupMessage, szTweet);
	-- end
end

-- 领取奖励
function Youlongmibao:GetAward(pPlayer, nType)
	
	local bOK = self:CheckGetAward(pPlayer);
	if bOK ~= 1 then
		Dialog:SendBlackBoardMsg(pPlayer, "Bạn không có phần thưởng để nhận.");
		return 0;
	end
	
	if pPlayer.CountFreeBagCell() < 1 then
		Dialog:SendBlackBoardMsg(pPlayer, "Hành trang đã đầy, vui lòng sắp xếp rồi thử lại.");
		return 0;
	end
	
	-- 取当前次数，奖励，物品Id
	local nTimes = self.tbPlayerList[pPlayer.nId].nTimes;
	local nGrid = self.tbPlayerList[pPlayer.nId].tbItemList.tbTimes[nTimes];
	local tbItem = self.tbPlayerList[pPlayer.nId].tbItemList.tbResult[nGrid];
	local tbItemId = Lib:SplitStr(tbItem.Id, ",");
	local nBindType = tonumber(tbItem.BindType) or 0;
	local nTimeOut = tonumber(tbItem.Timeout) or 0;
	local nChangeCoin = tonumber(tbItem.ChangeCoin) or 0;
	local szItemName = tostring(tbItem.Name) or "";
	
	-- 中了大奖清掉个人累计次数
	for _, tbUseRateItem in pairs(self.tbServerUseRate) do
		if tbUseRateItem.Id == tbItem.Id then
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_COUNT, 0);
			break;
		end
	end
	
	-- 开心蛋标记
	if tbItem.Id == Youlongmibao.ITEM_HAPPYEGG then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_HAPPY_EGG, 1);
	end
	
	-- 标记领奖
	self.tbPlayerList[pPlayer.nId].tbGetAward[nTimes] = 1;
	local tbItemInfo ={};
	
	if nTimeOut > 0 then
		tbItemInfo.bTimeOut = 1;
	end
	
	if nBindType > 0 then
		tbItemInfo.bForceBind = nBindType;
	end

	-- 给与物品
	if nType == 1 then
		
		local pItem = pPlayer.AddItemEx(tonumber(tbItemId[1]), tonumber(tbItemId[2]), tonumber(tbItemId[3]), tonumber(tbItemId[4]), tbItemInfo, Player.emKITEMLOG_TYPE_JOINEVENT);
		if pItem then
			
			-- 加上时限
			if nTimeOut > 0 then
				pPlayer.SetItemTimeout(pItem, nTimeOut, 0);
				pItem.Sync();
			end
			
			if self:GetLastBindType(pPlayer) == 1 then
				pItem.Bind(1);
			end
			
			-- 客服和本地log
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[游龙密室]获得物品：%s", pItem.szName));
			Dbg:WriteLog("游龙密室", string.format("[游龙密室]%s获得物品：%s", pPlayer.szName, pItem.szName));
			
			-- 频道公告
			if pPlayer.GetTask(2056, 12) == 0 then
				if tonumber(tbItem.SystemMsg) and tonumber(tbItem.SystemMsg) == 1 then
					local szMsg = "[<color=yellow>"..pPlayer.szName.."<color>] tiến vào Mật thất Du long nhận được <color=yellow>"..pItem.szName.."<color>。";			
					KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
				end
				if tonumber(tbItem.TongMsg) and tonumber(tbItem.TongMsg) == 1 then
					local szMsg = "<color>] tiến vào Mật thất Du long nhận được <color=yellow>"..pItem.szName.."<color>。";
					Player:SendMsgToKinOrTong(pPlayer, szMsg, 1);
				end
				if tonumber(tbItem.FriendMsg) and tonumber(tbItem.FriendMsg) == 1 then
					local szMsg = "Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] tiến vào Mật thất Du long nhận được <color=yellow>"..pItem.szName.."<color>。";
					pPlayer.SendMsgToFriend(szMsg);
				end
				
				-- 帮助锦囊
				if tonumber(tbItem.Level) >= 5 then
					self:UpdateHelpTable(pPlayer, pItem.szName);
				end
			end
			
			-- add 领取奖励时扣除记录古币值
			local nDeposit = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DEPOSIT_COIN) - nChangeCoin;
			if nDeposit < 0 then
				nDeposit = 0;
			end
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_DEPOSIT_COIN, nDeposit);
			
			-- stat log
			StatLog:WriteStatLog("stat_info", "youlongge", "receive", pPlayer.nId, szItemName, 0);
		end
		
	-- 给与古币
	elseif nType == 2 then
		
		pPlayer.AddStackItem(tonumber(self.ITEM_COIN[1]), tonumber(self.ITEM_COIN[2]), tonumber(self.ITEM_COIN[3]), tonumber(self.ITEM_COIN[4]), nil, nChangeCoin);
		
		-- 客服和本地log
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[游龙密室]获得古币：%s", nChangeCoin));
		Dbg:WriteLog("游龙密室", string.format("[游龙密室]%s获得古币：%s", pPlayer.szName, nChangeCoin));
		
		-- 频道公告
		if pPlayer.GetTask(2056, 12) == 0 then
			if tonumber(tbItem.SystemMsg) and tonumber(tbItem.SystemMsg) == 1 then
				local szMsg = "[<color=yellow>"..pPlayer.szName.."<color>] tiến vào Mật thất Du long nhận được <color=yellow>"..nChangeCoin.."<color> Tiền Du Long.";			
				KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
			end
			if tonumber(tbItem.TongMsg) and tonumber(tbItem.TongMsg) == 1 then
				local szMsg = "<color>] tiến vào Mật thất Du long nhận được <color=yellow>"..nChangeCoin.."<color> Tiền Du Long.";
				Player:SendMsgToKinOrTong(pPlayer, szMsg, 1);
			end
			if tonumber(tbItem.FriendMsg) and tonumber(tbItem.FriendMsg) == 1 then
				local szMsg = "Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>] tiến vào Mật thất Du long nhận được <color=yellow>"..nChangeCoin.."<color> Tiền Du Long.";
				pPlayer.SendMsgToFriend(szMsg);
			end
			
			-- 帮助锦囊
			if tonumber(tbItem.Level) >= 5 then
				self:UpdateHelpTable(pPlayer, string.format("%s Tiền Du Long", nChangeCoin));
			end
		end
		
		-- add 领取奖励时扣除记录古币值
		local nDeposit = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DEPOSIT_COIN) - nChangeCoin;
		if nDeposit < 0 then
			nDeposit = 0;
		end
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_DEPOSIT_COIN, nDeposit);
		
		-- stat log
		StatLog:WriteStatLog("stat_info", "youlongge", "receive", pPlayer.nId, szItemName, nChangeCoin);
		
	-- 非法类型
	else
		pPlayer.Msg("Giải thưởng không đúng, xin vui lòng xóa các plug-in hoặc các công cụ của bên thứ ba và thử lại.");
		return 0;
	end
	
	-- 置空这个格子
	self.tbPlayerList[pPlayer.nId].tbItemList.tbResult[nGrid] = nil;
	
	-- 调客户端ui脚本
	if self.tbPlayerList[pPlayer.nId].nTimes >= 4 then
		self.tbPlayerList[pPlayer.nId].tbItemList.tbResult.nStep = 3;
	else
		self.tbPlayerList[pPlayer.nId].tbItemList.tbResult.nStep = 2;
	end
	
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_YOULONGMIBAO", "OnGetResult", self.tbPlayerList[pPlayer.nId].tbItemList.tbResult});
end

function Youlongmibao:GetLastBindType(pPlayer)
	return self.tbPlayerBindTypeList[pPlayer.nId];
end

function Youlongmibao:SetLastBindType(pPlayer, bBind)
	self.tbPlayerBindTypeList[pPlayer.nId] = bBind;
end

function Youlongmibao:UseZhanShu(pPlayer, nUseBindType, G, D, P, L)
	local nLastBindType = self:GetLastBindType(pPlayer);
	local bRet = pPlayer.ConsumeItemInBags(1, G, D, P, L);
	if bRet ~= 0 then
		return 0;
	end
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 27);		--游龙比武活跃度
	-- set state
	self:SetLastBindType(pPlayer, nUseBindType);
	if nLastBindType and nLastBindType ~= nUseBindType then
		pPlayer.Msg("Hãy khiêu chiến lại.")
		self:GameStop(pPlayer);
	end
	return 1;
end

-- 继续挑战
function Youlongmibao:Continue(pPlayer)
	
	if self:CheckGameStart(pPlayer) ~= 1 then
		return 0;
	end	

	if not self.Manager.tbRoomMgr.tbMapMgr[pPlayer.nTemplateMapId] then
		pPlayer.Msg("Gặp Tiểu Long Nữ mới có thể khiêu chiến.");
		return 0;
	end
	
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_YOULONGGESWITCH) == 1 then
		Setting:SetGlobalObj(pPlayer);
		local nFlag = Player:CheckTask(Youlongmibao.TASK_GROUP_ID, Youlongmibao.TASK_ATTEND_DATE, "%Y%m%d", Youlongmibao.TASK_ATTEND_NUM, 10);
		if nFlag == 0 then
			Dialog:SendBlackBoardMsg(pPlayer, "Ngày mai hãy đến khiêu chiến!");			
			Setting:RestoreGlobalObj();
			return;
		end
		Setting:RestoreGlobalObj();
	end
	
	-- 两次挑战要间隔20秒
	local nInterval = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_INTERVAL);
	local nDailyAttendTimes = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DAILY_NO_INTERVAL_TIMES);
	
	local nCanYoulongCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CAN_YOULONG_COUNT);

	if (nCanYoulongCount <= 0) then
		Dialog:SendBlackBoardMsg(pPlayer, string.format("Số lần tích lũy trong ngày đã dùng hết."));
		return 0;
	end
	
	if (nDailyAttendTimes > self.NO_TIME_MAX_NUM) and (GetTime() - nInterval < self.MAX_INTERVAL) then
		Dialog:SendBlackBoardMsg(pPlayer, "Hãy đợi Tiểu Long Nữ nghỉ ngơi 1 lúc đã!");
		return 0;
	end
	
	-- 判断战书
	local nFind = pPlayer.GetItemCountInBags(self.ITEM_ZHANSHU[1], self.ITEM_ZHANSHU[2], self.ITEM_ZHANSHU[3], self.ITEM_ZHANSHU[4]);
	nFind = nFind + pPlayer.GetItemCountInBags(self.ITEM_ZHANSHU_BIND[1], self.ITEM_ZHANSHU_BIND[2], self.ITEM_ZHANSHU_BIND[3], self.ITEM_ZHANSHU_BIND[4]);
	if nFind <= 0 then
		Dialog:SendBlackBoardMsg(pPlayer, "Không có chiến thư, không thể tiến hành khiêu chiến.");
		return 0;
	end
	
	local tbZhanShuItems = me.FindItemInBags(self.ITEM_ZHANSHU[1], self.ITEM_ZHANSHU[2], self.ITEM_ZHANSHU[3], self.ITEM_ZHANSHU[4]);
	local tbBindZhanShuItems = me.FindItemInBags(self.ITEM_ZHANSHU_BIND[1], self.ITEM_ZHANSHU_BIND[2], self.ITEM_ZHANSHU_BIND[3], self.ITEM_ZHANSHU_BIND[4]);
	if #tbZhanShuItems > 0 and # tbBindZhanShuItems > 0 then
		pPlayer.Msg("Chỉ để 1 loại chiến thư trên người!")
		return 0;
	end
	
	local bRet;
	if #tbZhanShuItems > 0 then
		bRet = self:UseZhanShu(pPlayer, 0, self.ITEM_ZHANSHU[1], self.ITEM_ZHANSHU[2], self.ITEM_ZHANSHU[3], self.ITEM_ZHANSHU[4]);
	else
		bRet = self:UseZhanShu(pPlayer, 1, self.ITEM_ZHANSHU_BIND[1], self.ITEM_ZHANSHU_BIND[2], self.ITEM_ZHANSHU_BIND[3], self.ITEM_ZHANSHU_BIND[4]);
	end

	if bRet ~= 1 then
		return 0;
	end
	
	pPlayer.CallClientScript({"UiManager:CloseWindow", "UI_YOULONGMIBAO"});
	
	-- 开始战斗
	self:StartFight(pPlayer);
end

-- 重新开始
function Youlongmibao:Restart(pPlayer)
	
	-- 有奖励未领
	if self:CheckGetAward(pPlayer) == 1 then
		Dialog:SendBlackBoardMsg(pPlayer, "Bạn chưa nhận thưởng, không thể khiêu chiến.");
		return 0;
	end
	
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_YOULONGGESWITCH) == 1 then
		Setting:SetGlobalObj(pPlayer);
		local nFlag = Player:CheckTask(Youlongmibao.TASK_GROUP_ID, Youlongmibao.TASK_ATTEND_DATE, "%Y%m%d", Youlongmibao.TASK_ATTEND_NUM, 10);
		if nFlag == 0 then
			Dialog:SendBlackBoardMsg(pPlayer, "Hôm nay đã khiêu chiến đủ rồi!");			
			Setting:RestoreGlobalObj();
			return;
		end
		Setting:RestoreGlobalObj();
	end
	
	pPlayer.CallClientScript({"UiManager:CloseWindow", "UI_YOULONGMIBAO"});
	
	self:GameStop(pPlayer);
	self:Continue(pPlayer);
end

-- 离开密室
function Youlongmibao:PlayerLeave(pPlayer)
	
	pPlayer.CallClientScript({"UiManager:CloseWindow", "UI_YOULONGMIBAO"});
	
	Youlongmibao.Manager:DelNpc(me);
	Youlongmibao.Manager:KickPlayer(me);
end

-- 开始战斗
function Youlongmibao:StartFight(pPlayer)
	
	local nTimes = 1;
	if self.tbPlayerList[pPlayer.nId] then
		nTimes = self.tbPlayerList[pPlayer.nId].nTimes + 1;
	end
	
	Dialog:SendBlackBoardMsg(pPlayer, string.format("Bắt đầu khiêu chiến lượt thứ %s.", nTimes));
	
	--参加游龙累积次数
	local nTimes = pPlayer.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_YOULONG);
	pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_YOULONG, nTimes + 1);

	
	-- 召唤战斗npc
	Youlongmibao.Manager:DelNpc(pPlayer);
	Youlongmibao.Manager:AddFightNpc(pPlayer);
	
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_COUNT, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_COUNT) + 1);
	KGblTask.SCSetDbTaskInt(DBTASK_YOULONGMIBAO_COUNT, KGblTask.SCGetDbTaskInt(DBTASK_YOULONGMIBAO_COUNT) + 1);
	
	local nCanYoulongCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CAN_YOULONG_COUNT) - 1;
	if (nCanYoulongCount < 0) then
		nCanYoulongCount = 0;
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CAN_YOULONG_COUNT, nCanYoulongCount);
	
	
	-- 记录时间
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_YOULONG_INTERVAL, GetTime());
	
	-- VN 加每天次数  by jiazhenwei
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_YOULONGGESWITCH) == 1 then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_NUM, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_NUM) + 1);
	end
	-- VN
	
	-- 记录每天玩家打游龙战书的次数
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_DAILY_NO_INTERVAL_TIMES, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DAILY_NO_INTERVAL_TIMES) + 1);
	
	-- 游龙周活动
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_NUM_EVENT);
	local nBatch = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BATCH);
	if nBatch ~= self.nBatch then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BATCH, self.nBatch);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_NUM_EVENT, 0);
		nCount = 0;
	end
	if nDate >= self.nEventStarDay and nDate <= self.nEventEndDay and nCount < self.nMaxAttendNum then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_NUM_EVENT, nCount + 100);
	end
	-- 游龙周活动
	
	pPlayer.SetFightState(1);
end

-- 兑换物品
function Youlongmibao:OnChallenge(tbItem)
	
	if self:CheckState() ~= 1 then
		Dialog:Say("Tính năng này chưa mở.");
		return 0;
	end
	
	local nExCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		
		if szKey == string.format("%s,%s,%s,%s", unpack(self.ITEM_YUEYING)) then
			nExCount = nExCount + pItem.nCount;
		end
	end
	
	if nExCount <= 0 then
		Dialog:Say("Xin vui lòng chọn chính xác.");
		return 0;
	end
	
	if me.CountFreeBagCell() < (math.ceil(nExCount/100)) then
		Dialog:Say(string.format("Hành trang của bạn đã đầy, sắp xếp %s ô trống rồi thử lại.", math.ceil(nExCount/100)));
		return 0;		
	end
	
	local nExTempCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		if szKey == string.format("%s,%s,%s,%s", unpack(self.ITEM_YUEYING)) then
			nExTempCount = nExTempCount + pItem.nCount;
			me.DelItem(pItem);
		end
		if nExTempCount >= nExCount then
			break;
		end
	end
	
	local nAddCount = me.AddStackItem(self.ITEM_ZHANSHU[1], self.ITEM_ZHANSHU[2], self.ITEM_ZHANSHU[3], self.ITEM_ZHANSHU[4], nil, nExTempCount);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_MOONSTONE, string.format("[游龙密室][月影之石]%s个换取[战书：游龙密室]%s个", nExTempCount, nAddCount));
	Dbg:WriteLog("游龙密室", me.szName, string.format("[游龙密室][月影之石]%s个换取[战书：游龙密室]%s个",nExCount, nAddCount));
	StatLog:WriteStatLog("stat_info", "youlongge", "buy", me.nId, "月影之石", nExTempCount, nAddCount);
	StatLog:WriteStatLog("stat_info", "yueyingxiaohao", "exchange", me.nId, nExTempCount, "游龙战书", nAddCount);
end

-- 游龙阁声望令交换
function Youlongmibao:OnShengwang(nType, tbItem)

	local tbLing = {18, 1, 534, 1};
	local tbType =
	{
		[1] = {18, 1, 529, 1},
		[2] = {18, 1, 529, 2},
		[3] = {18, 1, 529, 3},
		[4] = {18, 1, 529, 4},
		[5] = {18, 1, 529, 5},
		[6] = {18, 1, 529, 6},
		[7] = {18, 1, 529, 8},
		[8] = {18, 1, 529, 7},
		[9] = {18, 1, 529, 9},
	};
	
	if not tbType[nType] then
		return 0;
	end
	
	local nExCount = 0;
	local nLingCount = 0;
	local nFlag = 0;
	
	for _, tbItem in pairs(tbItem) do
		
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		
		for i = 1, #tbType do 
			if szKey == string.format("%s,%s,%s,%s", unpack(tbType[i])) then
				nExCount = nExCount + pItem.nCount;
			end
			if szKey == string.format("%s,%s,%s,%s", unpack(tbType[nType])) then
				nFlag = nFlag + pItem.nCount;
			end
		end
		
		if szKey == string.format("%s,%s,%s,%s", unpack(tbLing)) then
			nLingCount = nLingCount + pItem.nCount;
		end
	end
	
	if nExCount ~= 1 or nLingCount ~= 1 or nFlag > 0 then
		Dialog:Say("Hãy đặt vật phẩm vào!");
		return 0;
	end
	
	local nExTempCount = 0;	
	for _, tbItem in pairs(tbItem) do
		
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		
		for i = 1, #tbType do 
			if szKey == string.format("%s,%s,%s,%s", unpack(tbType[i])) then
				me.DelItem(pItem);
				nExTempCount = nExTempCount + pItem.nCount;
			end
		end
		
		if nExTempCount >= nExCount then
			break;
		end
	end
	
	local nLingTempCount = 0;
	for _, tbItem in pairs(tbItem) do
		
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		
		if szKey == string.format("%s,%s,%s,%s", unpack(tbLing)) then
			nLingTempCount = nLingTempCount + pItem.nCount;
			me.DelItem(pItem);
		end
		
		if nLingTempCount >= nLingCount then
			break;
		end
	end
	
	me.AddItem(unpack(tbType[nType]));
end

-- 声望令兑换小牌子
function Youlongmibao:OnChangeCoin(tbItem, nSure)
	
	local tbItemList = 
	{
		{{18, 1, 529, 1}, 8000},
		{{18, 1, 529, 2}, 8000},
		{{18, 1, 529, 3}, 8000},
		{{18, 1, 529, 4}, 8000},
		{{18, 1, 529, 5}, 8000},
		{{18, 1, 529, 6}, 8000},
		{{18, 1, 529, 7}, 8000},
		{{18, 1, 529, 8}, 8000},
		{{18, 1, 529, 9}, 8000},
		{{18, 1, 1251, 1}, 800},
		{{18, 1, 1251, 2}, 800},
		{{18, 1, 1251, 3}, 800},
		{{18, 1, 1251, 4}, 800},
		{{18, 1, 1251, 5}, 800},
		{{18, 1, 1251, 6}, 800},
		{{18, 1, 1251, 7}, 800},
		{{18, 1, 1251, 8}, 800},
		{{18, 1, 1251, 9}, 800},
	};

	local nValue = 0;
	for _, tbData in pairs(tbItem) do
		local pItem = tbData[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		for _, tbInfo in pairs(tbItemList) do
			if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[1])) then
				nValue = nValue + tbInfo[2];
			end
		end
	end
	
	if nValue <= 0 then
		Dialog:Say("Hãy đặt vật phẩm chính xác.");
		return 0;
	end
	
	local nNeed = KItem.GetNeedFreeBag(self.ITEM_COIN[1], self.ITEM_COIN[2], self.ITEM_COIN[3], self.ITEM_COIN[4], nil, nValue);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s chỗ trống.", nNeed));
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("Bạn sẽ nhận được tổng cộng <color=yellow>%s Tiền Du Long<color>?", nValue);
		local tbOpt =
		{
			{"<color=yellow>Xác nhận<color>", self.OnChangeCoin, self, tbItem, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nCount = 0;	
	for _, tbData in pairs(tbItem) do
		local pItem = tbData[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		for _, tbInfo in pairs(tbItemList) do
			if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[1])) then
				me.DelItem(pItem);
				nCount = nCount + tbInfo[2];
			end
		end
	end
	
	me.AddStackItem(self.ITEM_COIN[1], self.ITEM_COIN[2], self.ITEM_COIN[3], self.ITEM_COIN[4], nil, nCount);
end

-- help
function Youlongmibao:UpdateHelpTable(pPlayer, szItemName)

	-- time
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	
	local szMsg = "";
	local tbMap = {};
	local nCount = 0;
	
	-- fill text
	local szDate = os.date("%H:%M:%S - Ngày:%d Tháng:%m Năm:%Y", GetTime());
	local szTxt = string.format("<color=cyan>%s\n<color=yellow>%s <color=green> tiến vào Mật thất Du long nhận được <color=yellow> %s<color>", szDate, pPlayer.szName, szItemName);
	
	-- get help
	local tbHelp = Task.tbHelp.tbNewsList[Task.tbHelp.NEWSKEYID.NEWS_YOULONGMIBAO];
	
	-- nil then clear count
	if not tbHelp then
		nCount = 0;
	else
		-- get msg key
		local szHelp = Task.tbHelp.tbNewsList[Task.tbHelp.NEWSKEYID.NEWS_YOULONGMIBAO].szMsg;
		
		-- no msg or ""
		if not szHelp or #szHelp < 1 or KGblTask.SCGetDbTaskInt(DBTASK_YOULONGMIBAO_BIG_AWARD) == 0 then
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
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_YOULONGMIBAO, "游龙秘宝奇珍榜", szMsg, nEndTime, nAddTime);
	
	-- global task
	KGblTask.SCSetDbTaskInt(DBTASK_YOULONGMIBAO_BIG_AWARD, KGblTask.SCGetDbTaskInt(DBTASK_YOULONGMIBAO_BIG_AWARD) + 1);
end

-- only for test
function Youlongmibao:ClearHelpTable()
	
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_YOULONGMIBAO, "游龙秘宝奇珍榜", "", nEndTime, nAddTime);
end

function Youlongmibao:ShowDetail(pPlayer)
	if jbreturn:IsPermitIp(pPlayer) == 1 and self.tbPlayerList[pPlayer.nId] then
		local tbTimes = self.tbPlayerList[pPlayer.nId].tbItemList.tbTimes;
		local nCount = KGblTask.SCGetDbTaskInt(DBTASK_YOULONGMIBAO_COUNT);
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_SUPERSCRIPT", "OnRecvData", tbTimes, nCount});
	end
end

-- check maptype
function Youlongmibao:CheckMap()
	
	local szMapClass = GetMapType(me.nMapId) or "";
	
	if szMapClass ~= "youlongmishi" then
		return 0;
	end
	
	return 1;
end

-- c2s function
function Youlongmibao:OnPlayerGameStart()
	
	if self:CheckMap() ~= 1 then
		return;
	end
	
	self:GameStart(me);
end

function Youlongmibao:OnPlayerGetAward(nType)
	
	if self:CheckMap() ~= 1 then
		return;
	end
	
	local tbVaildType = {[1] = 1, [2] = 1};
	if not tbVaildType[nType] then
		me.Msg("Giải thưởng không đúng, xin vui lòng xóa các plug-in hoặc các công cụ của bên thứ ba và thử lại.");
		return;
	end
	
	self:GetAward(me, nType);
end

function Youlongmibao:OnPlayerContinue()
	
	if self:CheckMap() ~= 1 then
		return;
	end
	
	self:Continue(me);
end

function Youlongmibao:OnPlayerRestart()
	
	if self:CheckMap() ~= 1 then
		return;
	end
	
	self:Restart(me);
end

function Youlongmibao:OnPlayerLeave()
	
	if self:CheckMap() ~= 1 then
		return;
	end
	
	self:PlayerLeave(me);
end

function Youlongmibao:OnPlayerShowAward()
	
	if self:CheckMap() ~= 1 then
		return;
	end
	
	self:ShowAward(me);
end

function Youlongmibao:OnDailyEvent_Youlongge()
	-- 每天清空游龙战书次数
	me.SetTask(self.TASK_GROUP_ID, self.TASK_DAILY_NO_INTERVAL_TIMES, 0);
	self:RefreshCanYoulongCount(me);
end

function Youlongmibao:RefreshCanYoulongCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	local nNowTime	= GetTime();
	local nLastTime	= pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CAN_YOULONG_COUNT_REFRESHTIME);
	
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nLastDay	= Lib:GetLocalDay(nLastTime);

	if (nLastDay >= nNowDay) then
		return 0;
	end
	
	local nCanYoulongCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CAN_YOULONG_COUNT);
	
	nCanYoulongCount = nCanYoulongCount + self.MAX_DAILY_COUNT * (nNowDay - nLastDay);
	
	if (nCanYoulongCount > self.MAX_CAN_YOULONG_COUNT) then
		nCanYoulongCount = self.MAX_CAN_YOULONG_COUNT;
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CAN_YOULONG_COUNT, nCanYoulongCount);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CAN_YOULONG_COUNT_REFRESHTIME, nNowTime);
end

-- call init
Youlongmibao:Init();

PlayerSchemeEvent:RegisterGlobalDailyEvent({Youlongmibao.OnDailyEvent_Youlongge, Youlongmibao});
