-- 文件名　：questionnaires.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-12-17 09:47:03
-- 描述　  ：调查问卷
if not MODULE_GAMESERVER then
	return 0;	
end

SpecialEvent.Questionnaires = SpecialEvent.Questionnaires or {};
local tbQuest = SpecialEvent.Questionnaires;
tbQuest.EventId = 23;
tbQuest.tbData  = tbQuest.tbData or {};

function tbQuest:OnLogin()
	local tbInfo = self:GetQuestFirstInfo();
	if tbInfo then
		--打开客户端界面
		me.GetTempTable("SpecialEvent").tbQuestionnaires = tbInfo;
		me.CallClientScript({"SpecialEvent.Questionnaires:OnOpen", tbInfo.szUrl});
	end
end

function tbQuest:GetQuestFirstInfo()
	for nEventId , tbPart  in pairs(self.tbData) do
		if nEventId == self.EventId then
	  		for nPartId , tbInfo in pairs(tbPart) do
	        	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));    
	        	if tbInfo.nStartDate <= nCurDate and (tbInfo.nEndDate == 0 or tbInfo.nEndDate >= nCurDate) then
        			local nCanNoOpenType = 0;
        			if tbInfo.nQuestType == 1 then
        				--读名单表
        				if self:IsInPlayerList(nEventId, nPartId, me.szName) == 0 then
        					nCanNoOpenType = 1;
        				end
        			end
        			
        			local nCanNoOpenLimit = EventManager.tbFun:CheckParam(tbInfo.tbQuestParam);
        			if nCanNoOpenType ~= 1 and nCanNoOpenLimit ~= 1 then
        				local szUrl 	= EventManager.tbFun:GetParam(tbInfo.tbQuestParam, "LinkQuestUrl", 1)[1];
        				local szParam   = EventManager.tbFun:GetParam(tbInfo.tbQuestParam, "CheckTaskEq", 1)[1];
        				local nTaskId 	= tonumber(EventManager.tbFun:SplitStr(szParam)[1]);
        				szUrl = EventManager.tbFun:SplitStr(szUrl)[1];
        				if szUrl and nTaskId then
        					return {tbParam=tbInfo.tbQuestParam, nTaskId = nTaskId, szUrl = szUrl};
        				end
        			end
	        	end
			end	
		end
	end
end

function tbQuest:OnAnswer(nStaus)
	local tbQuest = me.GetTempTable("SpecialEvent").tbQuestionnaires;
	if not tbQuest then
		me.Msg("很抱歉，您填写的调查问卷提交失败。");
		return 0;
	end
	
	local nQuestTask = tonumber(tbQuest.nTaskId);
	if nStaus ~= 1 or not nQuestTask then
		me.Msg("很抱歉，您填写的调查问卷提交失败。");
		return 0;
	end
	EventManager.tbFun:ExeParam(tbQuest.tbParam);
	--EventManager:SetTask(nQuestTask, 1);	--多设置一次，确保变量给设置上。
	me.GetTempTable("SpecialEvent").tbQuestionnaires = nil;
	me.Msg("<color=yellow>非常感谢您的参与，有了您的支持和鼓励我们会做得更好。<color>");
	Dialog:SendBlackBoardMsg(me, "非常感谢您的参与，有了您的支持和鼓励我们会做得更好。");
end

function tbQuest:GetData(nEventId, nPartId, nStartDate, nEndDate, nQuestType, tbQuestParam)
	self.tbData[nEventId] = self.tbData[nEventId] or {};
	self.tbData[nEventId][nPartId] = self.tbData[nEventId][nPartId] or {};
	self.tbData[nEventId][nPartId].nStartDate 	= nStartDate;
	self.tbData[nEventId][nPartId].nEndDate 	= nEndDate;
	self.tbData[nEventId][nPartId].nQuestType	= nQuestType;
	self.tbData[nEventId][nPartId].tbQuestParam = tbQuestParam;
end

function tbQuest:IsInPlayerList(nEventId, nPartId, szName)
	local tbBuf = self:GetGblBuf();
	if not tbBuf or not tbBuf[nEventId] or not tbBuf[nEventId][nPartId] or not tbBuf[nEventId][nPartId][szName] then
		return 0;
	end
	return 1;
end

function tbQuest:OnRecConnectMsg(nEventId, nPartId, szName)
	local tbBuf = self:GetGblBuf();
	tbBuf[nEventId] = tbBuf[nEventId] or {};
	tbBuf[nEventId][nPartId] = tbBuf[nEventId][nPartId] or {};
	tbBuf[nEventId][nPartId][szName] = 1;
end

PlayerEvent:RegisterOnLoginEvent(SpecialEvent.Questionnaires.OnLogin, SpecialEvent.Questionnaires)