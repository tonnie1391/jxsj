-- 文件名　：particularmail.lua
-- 创建者　：furuilei
-- 创建时间：2009-07-15 09:13:44
-- 功能描述：为指定的玩家发送系统邮件，并且系统邮件的邮件内容只在数据库中保存一份。
-- 			 玩家读取信件内容的时候，都是从数据库中读取的同一份内容。

if (not MODULE_GC_SERVER) then
	return;
end

Mail.tbParticularMail = {};
local tbParticularMail = Mail.tbParticularMail;
--============================================================

tbParticularMail.tbReceiverList = {};	-- {"XX" = {tbPlayerList...}},  "XX" = {}, ...}
tbParticularMail.tbMailInfo = {}; -- {"XX" = {szTitle = "XX", szContent = "XX"}, "XX" = {}, ...}
tbParticularMail.SENDONETIME = 10;	-- 每帧发送的邮件数目10封

--============================================================

-- 获取注册邮件的标识符以及需要进行的操作
-- szMailId：标识符，由区服名_+编号组成（例如：gate0101_1）
-- nOp: 需要进行的操作（1表示在数据库表当中添加新的记录，2表示已经存在该邮件，仅更新最后发送时间）
function tbParticularMail:GetValidMailInfo(szContent)
	local szPrefix = string.format("%s_", GetGatewayName());
	local tbMailInfo = GetValidMailId(szPrefix, szContent);
	return tbMailInfo.szMailId, tbMailInfo.nOp;
end

function tbParticularMail:SendParticularMail(tbReceiverList, szTitle, szContent)
	local nPlayerCount = #tbReceiverList;
	if (0 == nPlayerCount) then
		self.tbReceiverList[szContent] = nil;
		self.tbMailInfo[szContent] = nil;
		return 0;
	end
	
	local nSendCountPerFrame = 0;
	

	-- for i, szName in pairs(tbReceiverList) do
	for i = #tbReceiverList, 1, -1 do
		local szName = tbReceiverList[i];
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		if (nPlayerId and nPlayerId > 0) then
			SendMailGC(nPlayerId, szTitle, szContent);
		end
		
		tbReceiverList[i] = nil;
		nSendCountPerFrame = nSendCountPerFrame + 1;
		if (self.SENDONETIME == nSendCountPerFrame) then
			break;
		end
	end
	return 1;
end

-- 向tbReceiverList里面指定的玩家发送邮件
-- 邮件的标题以及内容在tbMailInfo当中tbMailInfo = {szTitle = "XX", szContent = "XX"};
function tbParticularMail:SendMail(tbReceiverList, tbMailInfo)	
	if (#tbReceiverList == 0) then	-- 没有指定给哪些玩家发送，不执行
		return;
	end
	if (not tbMailInfo.szTitle or not tbMailInfo.szContent) then	-- 邮件信息不完成，不执行
		return;
	end
	
	local szTitle = tbMailInfo.szTitle;
	local szContent = tbMailInfo.szContent;
	local szMailId, nOperation = self:GetValidMailInfo(szContent);
	

	if (1 == nOperation) then
		RegParticularMail(szMailId, szContent, nOperation);
		szContent = szMailId;
	elseif (2 == nOperation) then
		-- 更新操作的时候，邮件本身就是该邮件在数据库中的标识符
		RegParticularMail(szMailId, szContent, nOperation);
	end
	
	if (not self.tbReceiverList[szContent]) then
		self.tbReceiverList[szContent] = {};
	end
	Lib:MergeTable(self.tbReceiverList[szContent], tbReceiverList);
	
	if (not self.tbMailInfo[szContent]) then
		self.tbMailInfo[szContent] = {szTitle = szTitle, szContent = szContent};
	end

	Timer:Register(1, self.SendParticularMail, self, self.tbReceiverList[szContent], szTitle, szContent);
end

-- 在gc关掉的时候执行的函数
function tbParticularMail:QuickSendMail()
	if (0 == Lib:CountTB(self.tbReceiverList) or 0 == Lib:CountTB(self.tbMailInfo)) then
		return 0;
	end
	for szMailId, tbReceiverList in pairs(self.tbReceiverList) do
		if (0 == #tbReceiverList) then
			return 0;
		end
		if (not self.tbMailInfo[szMailId]) then
			return 0;
		end
		local szTitle = self.tbMailInfo[szMailId].szTitle;
		local szContent = self.tbMailInfo[szMailId].szContent;
		for i, szName in pairs(tbReceiverList) do
			local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
			if (nPlayerId and nPlayerId > 0) then
				SendMailGC(nPlayerId, szTitle, szContent);
			end
			tbReceiverList[i] = nil;
		end
		self.tbReceiverList[szMailId] = nil;
		self.tbMailInfo[szMailId] = nil;
	end
	self.tbReceiverList = {};
	self.tbMailInfo = {};
end
GCEvent:RegisterGCServerShutDownFunc(Mail.tbParticularMail.QuickSendMail, Mail.tbParticularMail);
