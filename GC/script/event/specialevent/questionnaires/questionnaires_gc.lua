-- 文件名　：questionnaires.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-12-17 09:47:03
-- 描述　  ：调查问卷

if not MODULE_GC_SERVER then
	return 0;	
end

SpecialEvent.Questionnaires = SpecialEvent.Questionnaires or {};
local tbQuest = SpecialEvent.Questionnaires;

function tbQuest:SendDataGC(nEventId, nPartId, nStartDate, nEndDate, nQuestType, tbQuestParam)
	GlobalExcute({"SpecialEvent.Questionnaires:GetData", nEventId, nPartId, nStartDate, nEndDate, nQuestType, tbQuestParam});
end

function tbQuest:GCStartEvent()
	if not self.tbGblBuf then
		self.tbGblBuf = self.tbGblBuf or {};
		local tbBuff = GetGblIntBuf(GBLINTBUF_QUEST_PLIAYERLIST, 0);
		if tbBuff and type(tbBuff) == "table" then
			self.tbGblBuf = tbBuff;
		end
	end
end

function tbQuest:OnRecConnectEvent(nConnectId)
	local tbBuf = self:GetGblBuf();
	for nEventId, tbPart in pairs(tbBuf) do
		for nPartId, tbPlayerList in pairs(tbPart) do
			self:OnRecPlayerList(nConnectId, nEventId, nPartId);
		end
	end
end

function tbQuest:OnRecPlayerList(nConnectId, nEventId, nPartId)
	local tbBuf = self:GetGblBuf();
	if tbBuf[nEventId] and tbBuf[nEventId][nPartId] then
		for szName in pairs(tbBuf[nEventId][nPartId]) do
			GSExcute(nConnectId, {"SpecialEvent.Questionnaires:OnRecConnectMsg", nEventId, nPartId, szName});
		end
	end
end

function tbQuest:KingEyesLoadFile(nEventId, nPartId, szPath)
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		print("SpecialEvent.Questionnaires:KingEyesLoadFile文件加载错误~~~", szPath);
		return;
	end
	local tbBuf = self:GetGblBuf();
	tbBuf[nEventId] = tbBuf[nEventId] or {};
	tbBuf[nEventId][nPartId] = tbBuf[nEventId][nPartId] or {};
	for nId, tbParam in ipairs(tbFile) do	
		local szGateWay = EventManager.tbFun:ClearString(tbParam.Gatewayname) or "";
		local szRoleName = EventManager.tbFun:ClearString(tbParam.Rolename) or "";
		if string.upper(szGateWay) == string.upper(GetGatewayName()) then
			tbBuf[nEventId][nPartId][szRoleName] = 1;
		end
	end
	self:SetGblBuf(tbBuf);
	self:OnRecPlayerList(-1, nEventId, nPartId);
end

GCEvent:RegisterGS2GCServerStartFunc(SpecialEvent.Questionnaires.OnRecConnectEvent, SpecialEvent.Questionnaires);

