-------------------------------------------------------
-- 文件名　：driftbottle_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-11-30 15:17:39
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\driftbottle\\driftbottle_def.lua");

-- 申请新纸条
function DriftBottle:ApplyNewMsg_GS()
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local nTimes = me.GetTask(self.TASK_GID, self.TASK_VOW_TIMES);
	if nTimes >= self.MAX_DAILY_VOW then
		Dialog:SendInfoBoardMsg(me, "每人每天最多可以许下<color=yellow>2个<color>愿望，请您明天再来吧~^_^");
		return 0;
	end
	
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MAIN"});
	me.CallClientScript({"UiManager:OpenWindow", "UI_DRIFT_NEW"});
end

-- 发起新帖子
function DriftBottle:AddNewMsg_GS(szMsg)
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	-- 许愿次数
	local nTimes = me.GetTask(self.TASK_GID, self.TASK_VOW_TIMES);
	if nTimes >= self.MAX_DAILY_VOW then
		Dialog:SendInfoBoardMsg(me, "每人每天最多可以许下<color=yellow>2个<color>愿望，请您明天再来吧^_^");
		return 0;
	end
	
	local _, nFree = self:CalcBufferLength();
	if nFree <= 0 then
		Dialog:SendInfoBoardMsg(me, "对不起，树上已经挂满了纸条，无法再贴上新纸条。");
		return 0;
	end
	
	-- 文字长度
	local nLen = GetNameShowLen(szMsg);
	if nLen < self.MIN_TEXT_LENGTH or nLen > self.MAX_TEXT_LENGTH then
		Dialog:SendInfoBoardMsg(me, "纸条字数只能在<color=yellow>4至50<color>之间，且不能含有非法字符。");
		return 0;
	end
	
	-- 敏感字串
	if IsNamePass(szMsg) ~= 1 then
		Dialog:SendInfoBoardMsg(me, "纸条字数只能在<color=yellow>4至50<color>之间，且不能含有非法字符。");
		return 0;
	end
		
	me.SetTask(self.TASK_GID, self.TASK_VOW_TIMES, nTimes + 1);
	GCExcute({"DriftBottle:AddNewMsg_GC", me.szName, szMsg});
	
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_NEW"});
	me.CallClientScript({"UiManager:OpenWindow", "UI_DRIFT_MAIN"});
	
	Dialog:SendBlackBoardMsg(me, "您成功在许愿树上贴上一张纸条，点击摘下纸条可查看别人的纸条");
	me.Msg("您在心语许愿树上贴上一张纸条。");
	
	StatLog:WriteStatLog("stat_info", "shengdanjie", "wishpaper", me.nId, "pickpaper", 1);
end

-- 摘取帖子
function DriftBottle:PickMsg_GS()
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local nTimes = me.GetTask(self.TASK_GID, self.TASK_PICK_TIMES);
	if nTimes >= self.MAX_DAILY_PICK then
		Dialog:SendInfoBoardMsg(me, "每人每天最多可以摘下<color=yellow>10次<color>纸条，请您明天再来吧^_^");
		return 0;
	end
	
	me.AddWaitGetItemNum(1);
	GCExcute({"DriftBottle:PickMsg_GC", me.szName});
end

-- 摘取帖子成功
function DriftBottle:PickMsgSuccess_GS(szPlayerName, nIndex)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo then
		return 0;
	end

	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.SetTask(self.TASK_GID, self.TASK_PICK_TIMES, pPlayer.GetTask(self.TASK_GID, self.TASK_PICK_TIMES) + 1);
	
	pPlayer.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MAIN"});
	pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_DRIFT_PICK", nIndex, tbInfo});
	
	Dialog:SendBlackBoardMsg(pPlayer, "您成功摘下一张纸条！");
	pPlayer.Msg("您成功摘下一张纸条！");
	
	StatLog:WriteStatLog("stat_info", "shengdanjie", "wishpaper", pPlayer.nId, "stickpaper", 1);
end

-- 摘取帖子失败
function DriftBottle:PickMsgFailed_GS(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	pPlayer.AddWaitGetItemNum(-1);
	Dialog:SendInfoBoardMsg(pPlayer, "许愿树上现在没有空余的纸条，您可以自己<color=yellow>发起纸条<color>");
end

-- 回复帖子
function DriftBottle:ReplyMsg_GS(nIndex, szMsg)
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo or tbInfo.szOwner ~= me.szName then
		return 0;
	end
	
	if #tbInfo.tbReply >= self.MAX_REPLY_TIMES then
		Dialog:SendInfoBoardMsg(me, "该纸条留言已达<color=yellow>10条<color>，您可以看看别的纸条^_^");
		return 0;
	end
	
	-- 文字长度
	local nLen = GetNameShowLen(szMsg);
	if nLen < self.MIN_TEXT_LENGTH or nLen > self.MAX_REPLY_LENGTH then
		Dialog:SendInfoBoardMsg(me, "留言字数只能在<color=yellow>4至30<color>之间，且不能含有非法字符");
		return 0;
	end
	
	-- 敏感字串
	if IsNamePass(szMsg) ~= 1 then
		Dialog:SendInfoBoardMsg(me, "留言字数只能在<color=yellow>4至30<color>之间，且不能含有非法字符");
		return 0;
	end
	
	me.AddWaitGetItemNum(1);
	GCExcute({"DriftBottle:ReplyMsg_GC", me.szName, nIndex, szMsg});
	
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_REPLY"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_PICK"});
end

-- 回复成功
function DriftBottle:ReplyMsgSuccess_GS(szPlayerName, nIndex)

	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo then
		return 0;
	end
	
	pPlayer.AddWaitGetItemNum(-1);
	pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_DRIFT_PICK", nIndex, tbInfo, 1});
	
	Dialog:SendBlackBoardMsg(pPlayer, "您已回复成功，可点击下方按钮关注该纸条。");
	pPlayer.Msg("您成功回复了一张纸条。");
end

-- 回复失败
function DriftBottle:ReplyMsgFailed_GS(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	pPlayer.AddWaitGetItemNum(-1);
	Dialog:SendInfoBoardMsg(pPlayer, "系统繁忙，请您稍后再试。");
end

-- 放回帖子
function DriftBottle:ReturnMsg_GS(nIndex)
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo or tbInfo.szOwner ~= me.szName then
		return 0;
	end
	
	GCExcute({"DriftBottle:ReturnMsg_GC", me.szName, nIndex});
end

-- 关注帖子
function DriftBottle:MarkMsg_GS(nIndex)
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo then
		return 0;
	end
	
	for _, nTaskId in pairs(self.TASK_MASK_LIST) do
		local nValue = me.GetTask(self.TASK_GID, nTaskId);
		if nValue > 0 and nValue == nIndex then
			Dialog:SendInfoBoardMsg(me, "该纸条已经加入您的关注列表，无须再次关注。");
			return 0;
		end
	end
	
	local nFlag = 0;
	for _, nTaskId in pairs(self.TASK_MASK_LIST) do
		local nValue = me.GetTask(self.TASK_GID, nTaskId);
		if nValue == 0 then
			me.SetTask(self.TASK_GID, nTaskId, nIndex);
			nFlag = 1;
			break;
		end
	end
	
	if nFlag == 0 then
		Dialog:SendInfoBoardMsg(me, "您最多只可以关注<color=yellow>5张<color>纸条。");
		return 0;
	end
	
	Dialog:SendBlackBoardMsg(me, "该纸条已经加入您的关注列表。");
	me.Msg("您成功关注了一张纸条。");
end

-- 取消关注帖子
function DriftBottle:DemarkMsg_GS(nIndex)
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo then
		return 0;
	end
	
	local nFlag = 0;
	for _, nTaskId in pairs(self.TASK_MASK_LIST) do
		local nValue = me.GetTask(self.TASK_GID, nTaskId);
		if nValue == nIndex then
			me.SetTask(self.TASK_GID, nTaskId, 0);
			nFlag = 1;
			break;
		end
	end
	
	if nFlag == 0 then
		Dialog:SendInfoBoardMsg(me, "您没有关注过这张纸条哦。");
		return 0;
	end
	
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MARK_SHOW"});
	self:QueryMymarkMsg();

	Dialog:SendBlackBoardMsg(me, "您已经取消关注该纸条。");
	me.Msg("您已经取消关注该纸条。");
end

-- 我发起的帖子
function DriftBottle:QueryMineMsg()
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local tbMsgList = {};
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		for nKey, tbValue in pairs(self[tbInfo.szBuffer]) do
			if tbValue.szWritter == me.szName then
				local tbData = {nIndex = nKey, szHead = tbValue.szHead, tbReply = tbValue.tbReply};
				table.insert(tbMsgList, tbData);
			end
		end
	end

	if #tbMsgList <= 0 then
		Dialog:SendInfoBoardMsg(me, "您当前还未贴上任何纸条，快来<color=yellow>发起一个纸条<color>吧^_^");
		return 0;
	end
	
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MAIN"});
	me.CallClientScript({"UiManager:OpenWindow", "UI_DRIFT_MINE", tbMsgList});
end

-- 我关注的帖子
function DriftBottle:QueryMymarkMsg()
	
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	
	local tbMarkList = {};
	for _, nTaskId in pairs(self.TASK_MASK_LIST) do
		local nValue = me.GetTask(self.TASK_GID, nTaskId);
		local tbInfo = self:GetInfoByIndex(nValue);
		if tbInfo then
			local tbData = {nIndex = nValue, szHead = tbInfo.szHead, tbReply = tbInfo.tbReply};
			table.insert(tbMarkList, tbData);
		end
	end
	
	if #tbMarkList <= 0 then
		Dialog:SendInfoBoardMsg(me, "您当前还未关注过任何纸条，去<color=yellow>摘下纸条<color>看看其他人说什么吧^_^");
		return 0;
	end
	
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MAIN"});
	me.CallClientScript({"UiManager:OpenWindow", "UI_DRIFT_MARK", tbMarkList});
end

-------------------------------------------------------
-- c2s call
-------------------------------------------------------

-- 申请新纸条
function c2s:ApplyDriftApplyNewMsg()
	DriftBottle:ApplyNewMsg_GS();
end

-- 发起新纸条
function c2s:ApplyDriftAddNewMsg(szMsg)
	DriftBottle:AddNewMsg_GS(szMsg);
end

-- 摘取纸条
function c2s:ApplyDriftPickMsg()
	DriftBottle:PickMsg_GS();
end

-- 回复纸条
function c2s:ApplyDriftReplyMsg(nIndex, szMsg)
	DriftBottle:ReplyMsg_GS(nIndex, szMsg);
end

-- 放回纸条
function c2s:ApplyDriftReturnMsg(nIndex)
	DriftBottle:ReturnMsg_GS(nIndex);
end

-- 关注纸条
function c2s:ApplyDriftMarkMsg(nIndex)
	DriftBottle:MarkMsg_GS(nIndex);
end

-- 取消关注
function c2s:ApplyDriftDemarkMsg(nIndex)
	DriftBottle:DemarkMsg_GS(nIndex);
end

-- 我发起的帖子
function c2s:ApplyDriftMineMsg()
	DriftBottle:QueryMineMsg();
end

-- 我关注的帖子
function c2s:ApplyDriftMymarkMsg()
	DriftBottle:QueryMymarkMsg();
end

-------------------------------------------------------
-- buffer相关
-------------------------------------------------------

-- 载入本地global buffer
function DriftBottle:LoadBuffer_GS()
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		local tbLoadBuffer = GetGblIntBuf(tbInfo.nIndex, 0);
		if tbLoadBuffer and type(tbLoadBuffer) == "table" then
			self[tbInfo.szBuffer] = tbLoadBuffer;
		end
	end
end

-- 置空本地global buffer
function DriftBottle:ClearBuffer_GS()
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		self[tbInfo.szBuffer] = {};
	end
end

-- 连接gc时同步
function DriftBottle:SyncBuffer_GS(szBuffer, nKey, tbValue)
	if self[szBuffer] then
		self[szBuffer][nKey] = tbValue;
	end
end

-- gs启动事件
function DriftBottle:StartEvent_GS()	
	self:LoadBuffer_GS();
	self:RefreshTree();
end

function DriftBottle:RefreshTree()
	if self:CheckIsOpen() == 1 then
		for nMapId, tbPos in pairs(self.MAP_LIST) do
			if SubWorldID2Idx(nMapId) >= 0 and not self.tbTreeId[nMapId] then
				local pNpc = KNpc.Add2(self.TREE_ID, 120, -1, nMapId, tbPos[1], tbPos[2]);
				if pNpc then
					self.tbTreeId[nMapId] = pNpc.dwId;
				end
			end
		end
	else
		for nMapId, tbPos in pairs(self.MAP_LIST) do
			if SubWorldID2Idx(nMapId) >= 0 and self.tbTreeId[nMapId] then
				local pNpc = KNpc.GetById(self.tbTreeId[nMapId]);
				if pNpc then
					pNpc.Delete();
				end
			end
		end
	end
end

-- 每日事件
function DriftBottle:DailyEvent_GS()
	me.SetTask(self.TASK_GID, self.TASK_VOW_TIMES, 0);
	me.SetTask(self.TASK_GID, self.TASK_PICK_TIMES, 0);
end

-- 注册启动事件
ServerEvent:RegisterServerStartFunc(DriftBottle.StartEvent_GS, DriftBottle);
PlayerSchemeEvent:RegisterGlobalDailyEvent({DriftBottle.DailyEvent_GS, DriftBottle});
