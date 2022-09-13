-- 文件名  : oldplayerback_gs.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-30 17:04:00
-- 描述    :  老玩家回归

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\specialevent\\oldplayerback\\oldplayerback_def.lua");

SpecialEvent.tbOldPlayerBack = SpecialEvent.tbOldPlayerBack or {};
local tbOldPlayerBack = SpecialEvent.tbOldPlayerBack or {};

function tbOldPlayerBack:SaveBuffer_GC()	
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0, 1, self.tbOldPlayerInfo);
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0, 1, self.tbOldPlayerInfo2);
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0, 1, self.tbOldPlayerInfo3);
	GlobalExcute({"SpecialEvent.tbOldPlayerBack:LoadBuffer_GS"});
end

function tbOldPlayerBack:SaveBuffer2_GC(nType, szAccount, nAwardInfo, nTypeEx)
	if not nType or not szAccount then
		return;
	end
	if nType == 1 then
		if not self.tbOldPlayerInfo[1][szAccount] then
			return;
		end		
		if nTypeEx and nAwardInfo then
			self.tbOldPlayerInfo[1][szAccount][nTypeEx] = nAwardInfo;
		else
			self.tbOldPlayerInfo[1][szAccount][7] = 1;
		end
	else
		if self.tbOldPlayerInfo[2][szAccount] then
			self.tbOldPlayerInfo[2][szAccount][5] = 1;
		elseif self.tbOldPlayerInfo2[szAccount] then
			self.tbOldPlayerInfo2[szAccount][5] = 1;
		elseif self.tbOldPlayerInfo3[szAccount] then
			self.tbOldPlayerInfo3[szAccount][5] = 1;
		end		
	end	
	GlobalExcute{"SpecialEvent.tbOldPlayerBack:SaveBuffer2_GS", nType, szAccount, nAwardInfo, nTypeEx};
	if not self.SaveTime then
		self.SaveTime = GetTime();
	end
	if GetTime() > self.SaveTime + 25200 then
		self:CloseFunction();
		self.SaveTime = GetTime();
	end
end

function tbOldPlayerBack:CloseFunction()
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0, 1, self.tbOldPlayerInfo);
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0, 1, self.tbOldPlayerInfo2);
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0, 1, self.tbOldPlayerInfo3);
end

function tbOldPlayerBack:LoadBuffer_GC()	
	--buff重用
	if (EventManager.IVER_bOpenPlayerCallBack == 0) then
		return;
	end
	
	local nFlag = KGblTask.SCGetDbTaskInt(DBTASK_OLDPLAYERBACK_TIMES);
	--活动结束后把buf清掉
	if nFlag == self.GTASK_BUFF + 1 then
		return;
	end
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate > self.nCloseDate[1] and nCurDate > self.nCloseDate[2] and nFlag == self.GTASK_BUFF then
		SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0, 1, {});
		SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0, 1, {});
		SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0, 1, {});
		KGblTask.SCSetDbTaskInt(DBTASK_OLDPLAYERBACK_TIMES, self.GTASK_BUFF + 1);
		return;
	end
	if nFlag ~= self.GTASK_BUFF then
		self:ReadOldPlayerBack();
		KGblTask.SCSetDbTaskInt(DBTASK_OLDPLAYERBACK_TIMES, self.GTASK_BUFF);
		return;
	end
	local tbBuffer = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0);
	local tbBuffer2 = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0);
	local tbBuffer3 = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbOldPlayerInfo = tbBuffer;
		self.tbOldPlayerInfo[1] = self.tbOldPlayerInfo[1] or {};
		self.tbOldPlayerInfo[2] = self.tbOldPlayerInfo[2] or {};
	end
	if tbBuffer2 and type(tbBuffer2) == "table" then
		self.tbOldPlayerInfo2 = tbBuffer2;
	end
	if tbBuffer3 and type(tbBuffer3) == "table" then
		self.tbOldPlayerInfo3 = tbBuffer3;
	end
end

function tbOldPlayerBack:SetKinMemberTask(dwKinId, nPlayerId)
	local cKin = KKin.GetKin(dwKinId)
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	while cMember do
		local nFigure = cMember.GetFigure();
		local nBatch = cMember.GetOldPlayerBackBatch();
		if nBatch ~= self.nBatch then
			cMember.SetOldPlayerBack(0);
			cMember.SetOldPlayerBackBatch(self.nBatch);
		end
		if nFigure <= Kin.FIGURE_REGULAR and cMember.GetPlayerId() ~= nPlayerId then
			cMember.AddOldPlayerBack(1);
		end
		cMember = cMemberIt.NextMember();
	end
	GlobalExcute({"SpecialEvent.tbOldPlayerBack:SetKinMemberTask", dwKinId, nPlayerId});
	return 0;
end

function tbOldPlayerBack:ReadOldPlayer2NewGate(szFileName)	
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【老玩家前往新服】读取文件错误，文件不存在",szFileName);
		return;
	end	
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then			
			local szOldAccount = string.lower(tbParam.OldAccount or "");
			local nPayCount = tonumber(tbParam.PayCount) or 0;
			local nConsumeCount = tonumber(tbParam.ConsumeCount) or 0;
			local szNewAccount = string.lower(tbParam.NewAccount or "");
			local nTimecoe = tonumber(tbParam.Timecoe) or 0;
			local szGateway  = tbParam.Gateway or "";
			if not self.tbOldPlayerInfo then
				self.tbOldPlayerInfo = {};
			end
			if not self.tbOldPlayerInfo[1] then
				self.tbOldPlayerInfo[1] = {};
			end
			local nPayCountRel = nPayCount;
			if nPayCount > nConsumeCount then
				nPayCountRel = nConsumeCount;
			end
			--去掉账号中的空格
			szOldAccount = Lib:ClearBlank(szOldAccount);
			szNewAccount = Lib:ClearBlank(szNewAccount);	
			if nTimecoe <= 0 then
				nTimecoe = 1.5;
			elseif nTimecoe <= 5 then
				nTimecoe = 1;
			else
				nTimecoe = 0.5;
			end
			if szOldAccount ~= "" and nPayCount > 0 and nPayCountRel >= self.nCoinNeed and szNewAccount ~= "" and szGateway ~= "" and GetGatewayName() == szGateway then
				if not self.tbOldPlayerInfo[1][szNewAccount] then
					self.tbOldPlayerInfo[1][szNewAccount] = {szGateway, nPayCountRel, szOldAccount, self.nAwardState, self.nAwardState, nTimecoe, 0};
				else
					self.tbOldPlayerInfo[1][szNewAccount] = {szGateway, nPayCountRel, szOldAccount, self.tbOldPlayerInfo[1][szNewAccount][4], self.tbOldPlayerInfo[1][szNewAccount][5], nTimecoe, self.tbOldPlayerInfo[1][szNewAccount][7]};
				end
			end
		end
	end
	self:SaveBuffer_GC();
	return 1;
end

function tbOldPlayerBack:ReadOldPlayerBack()	
	local szFileName = "\\setting\\event\\specialevent\\oldpbackaccountlist.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local szOldAccount = string.lower(tbParam.OldAccount or "");		
			szOldAccount = Lib:ClearBlank(szOldAccount);
			local nPayCount = math.ceil(tonumber(tbParam.PayCount) or 0);
			local nTimecoe = tonumber(tbParam.Timecoe) or 0;
			local nConsumeCount = math.ceil(tonumber(tbParam.ConsumeCount) or 0);
			if not self.tbOldPlayerInfo then
				self.tbOldPlayerInfo = {};
			end
			if not self.tbOldPlayerInfo[2] then
				self.tbOldPlayerInfo[2] = {};
			end
			local nPayCountRel = nPayCount;
			if nPayCount > nConsumeCount then
				nPayCountRel = nConsumeCount;
			end
			local bIsOldPlayerOct = 0;
			if self.tbOldPlayerBackOct[szOldAccount] then
				bIsOldPlayerOct = 1;
			end			
			if nTimecoe <= 0 then
				nTimecoe = 1.5;
			elseif nTimecoe <= 5 then
				nTimecoe = 1;
			else
				nTimecoe = 0.5;
			end			
			if szOldAccount ~= "" and nPayCountRel >= self.nCoinNeed then
				if nId <= 80000 then
					self.tbOldPlayerInfo[2][szOldAccount] = {nPayCountRel, nTimecoe, nPayCount, nConsumeCount, 0, bIsOldPlayerOct};
				elseif nId <= 160000 then
					self.tbOldPlayerInfo2[szOldAccount] = {nPayCountRel, nTimecoe, nPayCount, nConsumeCount, 0, bIsOldPlayerOct};
				else
					self.tbOldPlayerInfo3[szOldAccount] = {nPayCountRel, nTimecoe, nPayCount, nConsumeCount, 0, bIsOldPlayerOct};
				end
			end
		end
	end
	self:SaveBuffer_GC();
	return 1;	
end

function tbOldPlayerBack:ReadOldPlayerBackOct()
	local szFileName = "\\setting\\event\\specialevent\\oldplayerbackoct.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local szAccount = string.lower(tbParam.Account or "");
			--去掉账号中的空格
			szAccount = Lib:ClearBlank(szAccount);
			if szAccount ~= "" then
				self.tbOldPlayerBackOct[szAccount] = 1;
			end
		end
	end
	return 1;
end

-- 老玩家回归合服buf合并，当出现两边都有名单时才把玩家放进去
function tbOldPlayerBack:MergeMainAndSubBuf(tbSubBuf, tbSubBuf1, tbSubBuf2)
	print("CombinSubZoneAndMainZone tbOldPlayerBack:MergeMainAndSubBuf start");
	local tbMainBuffer = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0) or {};
	local tbMainBuffer1 = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0) or {};
	local tbMainBuffer2 = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0) or {};
	
	-- 老玩家转入新服
	tbSubBuf = tbSubBuf or {};
	tbMainBuffer[1] = tbMainBuffer[1] or {};
	tbSubBuf[1] = tbSubBuf[1] or {};
	for szAccount, tbInfo in pairs(tbSubBuf[1]) do
		if (tbMainBuffer[1][szAccount]) then
			if (tbMainBuffer[1][szAccount][7] ~= tbInfo[7]) then
				tbMainBuffer[1][szAccount][7] = 1;
			end
		else
			tbMainBuffer[1][szAccount] = tbInfo;
		end
	end
	-- 老玩家回归
	tbSubBuf[2] = tbSubBuf[2] or {};
	tbMainBuffer[2] = tbMainBuffer[2] or {};
	for szAccount, tbData in pairs(tbSubBuf[2]) do
		if (tbMainBuffer[2][szAccount]) then
			if (tbMainBuffer[2][szAccount][5] ~= tbData[5]) then
				tbMainBuffer[2][szAccount][5] = 1;
			end
		else
			tbMainBuffer[2][szAccount] = tbData;
		end
	end

	self.tbOldPlayerInfo = tbMainBuffer;
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0, 1, self.tbOldPlayerInfo);


	for szAccount, tbData in pairs(tbSubBuf1) do
		if (tbMainBuffer1[szAccount]) then
			if (tbMainBuffer1[szAccount][5] ~= tbData[5]) then
				tbMainBuffer1[szAccount][5] = 1;
			end
		else
			tbMainBuffer1[szAccount] = tbData;
		end		
	end
	self.tbOldPlayerInfo2 = tbMainBuffer1;
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0, 1, self.tbOldPlayerInfo2);

	for szAccount, tbData in pairs(tbSubBuf2) do
		if (tbMainBuffer2[szAccount]) then
			if (tbMainBuffer2[szAccount][5] ~= tbData[5]) then
				tbMainBuffer2[szAccount][5] = 1;
			end
		else
			tbMainBuffer2[szAccount] = tbData;
		end		
	end
	self.tbOldPlayerInfo3 = tbMainBuffer2;
	SetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0, 1, self.tbOldPlayerInfo3);

	print("CombinSubZoneAndMainZone tbOldPlayerBack:MergeMainAndSubBuf end");
end


GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbOldPlayerBack.LoadBuffer_GC, SpecialEvent.tbOldPlayerBack);
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.tbOldPlayerBack.CloseFunction, SpecialEvent.tbOldPlayerBack);
tbOldPlayerBack:ReadOldPlayerBackOct();

--test指令
--加入类型(1转新服，2老玩家)，充值额度，消耗额度，老账号，新账号， 系数，是不是已经是老玩家(0不是 or 1是)
function tbOldPlayerBack:__Test_AddDate(nType, nPayCount, nConsumeCount, szOldAccount,szNewAccount, nTimecoe, bIsAlreadyOldPlayer)
	if not nType or not nPayCount or not nConsumeCount or not szOldAccount or not szNewAccount or not  nTimecoe or not bIsAlreadyOldPlayer then
   		print("参数不对");
		return;
	end
	local nPayCountRel = nPayCount;
	if nPayCount > nConsumeCount then
		nPayCountRel = nConsumeCount;
	end
	if nType == 1 then
		self.tbOldPlayerInfo[1][szNewAccount] = {GetGatewayName(), nPayCountRel, szOldAccount, self.nAwardState, self.nAwardState, 1, 0};
	elseif nType == 2 then
		self.tbOldPlayerInfo[2][szOldAccount] = {nPayCountRel, nTimecoe, nPayCount, nConsumeCount, 0, bIsAlreadyOldPlayer};
	end
	self:SaveBuffer_GC();
	return;
end
