-- 文件名　：event_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-08-31 11:04:32
-- 功能    ：新服活动201109


if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\specialevent\\newgateevent\\event_def.lua");

SpecialEvent.tbNewGateEvent = SpecialEvent.tbNewGateEvent or {};
local tbNewGateEvent = SpecialEvent.tbNewGateEvent;

---------------------------老剑侠征战新疆土-----------------------------------------
tbNewGateEvent.nCount = 0;

function tbNewGateEvent:BindAccount(nPlayerId, szAccount)
	if self.tbOldListBuff[szAccount] then
		GlobalExcute({"SpecialEvent.tbNewGateEvent:BindFail", nPlayerId});
	else		
		self.tbOldListBuff[szAccount] = 1;
		self.nCount = self.nCount + 1;
		if self.nCount >= 100 then
			self:SaveBuff();			--每绑定一百个人存一次buff
			self.nCount = 0;
		end
		GlobalExcute({"SpecialEvent.tbNewGateEvent:BindSucess", nPlayerId, szAccount});
	end	
end	

--存buff
function tbNewGateEvent:SaveBuff()
	SetGblIntBuf(GBLINTBUF_NEWGATEEVENT, 0, 1, self.tbOldListBuff);
end

--读buff
function tbNewGateEvent:LoadBuffer_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_NEWGATEEVENT, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbOldList = tbBuffer;
	end
end

GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.tbNewGateEvent.SaveBuff, SpecialEvent.tbNewGateEvent);
GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbNewGateEvent.LoadBuffer_GC, SpecialEvent.tbNewGateEvent);

-------------------------------------开学有礼--------------------------------------
function tbNewGateEvent:GetStudentAward(nPlayerId, nType, nFlag)
	local nDetal = 1;
	local nCardCount = Lib:CountTB(SpecialEvent.tbLaXin2010.tbCardInfo.tbUnused[self.tbItemType[nType]] or {});
	if nFlag or nCardCount <= 0 then
		nDetal = 2;
	end
	local tbAward = self.tbStudentAward[nType][nDetal];
	local nRate = MathRandom(100);
	local nRateEx = 0;
	for i, tb in ipairs(tbAward) do
		nRateEx = nRateEx + tb[3];
		if nRate <= nRateEx then
			GlobalExcute({"SpecialEvent.tbNewGateEvent:GetStudentSucess", nPlayerId, nType, nDetal, i});
			return;
		end
	end
end

-------------------------------------百家争鸣--------------------------------------
--写威望排名100
function tbNewGateEvent:GetAwardList(tbKinId2Index)
	local nCount = 0;
	for dwKinId, nGrade in pairs(tbKinId2Index) do
		if nCount >= 100 then
			break;
		end
		if nGrade  <= 100 then
			local nLevel = 5;
			if nGrade <= 10 then
				nLevel = 1;
			elseif nGrade <= 50 then
				nLevel = 3;
			end
			local pKin = KKin.GetKin(dwKinId);
			if (pKin) then
				self.tbKinAward[dwKinId] = {nLevel, nGrade};
				local cMemberIt = pKin.GetMemberItor();
				local cMember = cMemberIt.GetCurMember();
				local nMemberCount = 0;	
				while (cMember and nMemberCount <= 100) do
					local nFigure = cMember.GetFigure();
					local nPlayerId = cMember.GetPlayerId();
					local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
					if nFigure == 1 then		--族长
						self.tbKinAward[szPlayerName] = {nLevel, nGrade};						
						local nCount = 1;
						if nGrade <= 10 then
							nCount = 3;
						elseif nGrade <= 50 then
							nCount = 2;
						end
						for i = 1, nCount do
							StatLog:WriteStatLog("stat_info", "tuiguang", "apply", nPlayerId, 4);
						end						
					elseif nFigure <= 3 then	--正式成员
						self.tbKinAward[szPlayerName] = {nLevel + 1, nGrade};
					end
					nMemberCount = nMemberCount + 1;
					cMember = cMemberIt.NextMember();
				end
			end
			nCount = nCount + 1;
		end
	end
	SetGblIntBuf(GBLINTBUF_NEWGATEKINAWARD, 0, 1, self.tbKinAward);
	GlobalExcute({"SpecialEvent.tbNewGateEvent:LoadBufferKin_GS"});
end

--存buff
function tbNewGateEvent:SetKinAward(dwKinId)
	self.tbKinAward[dwKinId][1] = 0;
	GlobalExcute({"SpecialEvent.tbNewGateEvent:SetKinAward", dwKinId});
	SetGblIntBuf(GBLINTBUF_NEWGATEKINAWARD, 0, 1, self.tbKinAward);
end

--读buff
function tbNewGateEvent:LoadKinBuffer_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_NEWGATEKINAWARD, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbKinAward = tbBuffer;
	end
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbNewGateEvent.LoadKinBuffer_GC, SpecialEvent.tbNewGateEvent);

--写金牌家族排名100
function tbNewGateEvent:WriteKinInfo(tbKinDaliyDate)	
	local szFile = "\\log\\gamecenter\\goldkinaward.txt";
	local szMsg = "家族名\t族长\t成员\n";
	KFile.WriteFile(szFile, szMsg);
	if (not tbKinDaliyDate) then
		print("[KIN] ERROR WriteKinInfo 没有家族数据");
		return 0;
	end
	for i =1, 100 do
		if not tbKinDaliyDate[i] then
			break;
		end
		local szKinName = tbKinDaliyDate[i].szKinName;
		local dwKinId = KKin.GetKinNameId(szKinName);		
		local pKin = KKin.GetKin(dwKinId);
		if (pKin) then
			local cMemberIt = pKin.GetMemberItor();
			local cMember = cMemberIt.GetCurMember();
			local nMemberCount = 0;				
			while (cMember and nMemberCount <= 100) do
				local nFigure = cMember.GetFigure();
				local nPlayerId = cMember.GetPlayerId();
				local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
				if nMemberCount == 0 then
					szMsg = szPlayerName;
				else
					if nFigure == 1 then		--族长
						szMsg = szPlayerName.."\t"..szMsg
					elseif nFigure <= 3 then	--正式成员
						szMsg = szMsg.."\t"..szPlayerName;
					end
				end
				nMemberCount = nMemberCount + 1;
				cMember = cMemberIt.NextMember();
			end
			szMsg = szKinName.."\t"..szMsg .. "\n";
			KFile.AppendFile(szFile, szMsg);
			szMsg = "";
		end		
	end	
	return 1;
end

