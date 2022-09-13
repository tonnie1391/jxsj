-- 文件名　：dts_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-13
-- 描  述  ：大逃杀gc

if (not MODULE_GC_SERVER) then
	return 0;
end

function DaTaoSha:EnterReadyMap(tbPlayerList, nLevel)		
	local nEnterReadyId, nFlag = self:GetReadyMapId(tbPlayerList, nLevel);	
	for _, nPlayerId in ipairs(tbPlayerList) do
		if self.tbCD_EnterReady[nPlayerId] and GetTime() - self.tbCD_EnterReady[nPlayerId][2] <= 600 and self.tbCD_EnterReady[nPlayerId][1] >= 2 then
			GlobalExcute{"DaTaoSha:CD_ReadyPK", tbPlayerList, nPlayerId};
			return 0;
		end
	end
	if nEnterReadyId == 0 then
		GlobalExcute{"DaTaoSha:MapStateFull", tbPlayerList};
		return 0;
	end
	GlobalExcute{"DaTaoSha:EnterReadyMap", nEnterReadyId, tbPlayerList, nFlag};
end

function DaTaoSha:Open()	
	self:Msg2Global(2);
	GlobalExcute{"DaTaoSha:CycAsk"};
end

function DaTaoSha:Msg2Global1()
	self:Msg2Global(1);
end

function DaTaoSha:Msg2Global3()
	self:Msg2Global(3);
end

function DaTaoSha:Close()
	self:OnRefreshLadder_GC()
	GlobalExcute{"DaTaoSha:CloseCycAsk"};
end

function DaTaoSha:CreaseNum(nMapId, nGroupId,  nId)
	self.tbAllPlayerList[nMapId].nCount = self.tbAllPlayerList[nMapId].nCount + 1;
	self.tbAllPlayerList[nMapId].tbGroupList = self.tbAllPlayerList[nMapId].tbGroupList or {};
	self.tbAllPlayerList[nMapId].tbGroupList[nGroupId] = self.tbAllPlayerList[nMapId].tbGroupList[nGroupId] or {};
	self.tbAllPlayerList[nMapId].tbGroupId = self.tbAllPlayerList[nMapId].tbGroupId or {};
	self.tbAllPlayerList[nMapId].tbGroupId[nId] = nGroupId;
	table.insert(self.tbAllPlayerList[nMapId].tbGroupList[nGroupId], nId);		
end

function DaTaoSha:DecreaseNum(nMapId, nGroupId,  nId)	
	self.tbAllPlayerList[nMapId].tbGroupList = self.tbAllPlayerList[nMapId].tbGroupList or {};
	self.tbAllPlayerList[nMapId].tbGroupList[nGroupId] = self.tbAllPlayerList[nMapId].tbGroupList[nGroupId] or {};
	for i, nPlayerId in ipairs( DaTaoSha.tbAllPlayerList[nMapId].tbGroupList[nGroupId]) do
		if nPlayerId == nId then
			self.tbCD_EnterReady[nPlayerId] = self.tbCD_EnterReady[nPlayerId] or {0, GetTime()};
			if GetTime() - self.tbCD_EnterReady[nPlayerId][2] <= 600 then
				self.tbCD_EnterReady[nPlayerId][1] = self.tbCD_EnterReady[nPlayerId][1] + 1;
			else
				self.tbCD_EnterReady[nPlayerId] = {1, GetTime()};
			end
			table.remove(DaTaoSha.tbAllPlayerList[nMapId].tbGroupList[nGroupId], i);
			self.tbAllPlayerList[nMapId].nCount = self.tbAllPlayerList[nMapId].nCount - 1 ;
			break;
		end
	end
	self.tbAllPlayerList[nMapId].tbGroupId = self.tbAllPlayerList[nMapId].tbGroupId or {};
	self.tbAllPlayerList[nMapId].tbGroupId[nId] = nil;
end

function DaTaoSha:ClearPlayerGrouplist(nMapId)
	for nLevel = self.MACTH_PRIM, self.MACTH_ADV do
		if self.MACTH_TYPE[nLevel] then
			for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do
				self.tbAllPlayerList[nMapId] =  {};
				self.tbAllPlayerList[nMapId].tbGroupId = {};
				self.tbAllPlayerList[nMapId].tbGroupList = {};	
				self.tbAllPlayerList[nMapId].tbRange = {};
				self.tbAllPlayerList[nMapId].nLevel = nLevel;
				self.tbAllPlayerList[nMapId].nCount = 0;
			end
		end
	end
end

function DaTaoSha:ResetPlayerTable()
	GlobalExcute{"DaTaoSha:ResetPlayerTable", self.tbAllPlayerList};
end

function DaTaoSha:DecreasemoreNum(nMapId, tbPkPlayList)
	local nGroupId = 0;
	for _, tbPlayer in ipairs(tbPkPlayList) do 				
		for i, nPlayerId in ipairs (tbPlayer) do	
			nGroupId = self.tbAllPlayerList[nMapId].tbGroupId[nPlayerId] or 0;
			self:DecreaseNum(nMapId, nGroupId,  nPlayerId);
			
			if self.tbCD_EnterReady[nPlayerId] then
				if self.tbCD_EnterReady[nPlayerId][1] <= 1 then
					self.tbCD_EnterReady[nPlayerId] = nil;
				else
					self.tbCD_EnterReady[nPlayerId][1] = self.tbCD_EnterReady[nPlayerId][1] - 1;
				end
			end
		end
	end	
end

-- 
function DaTaoSha:Award(nPlayerId, nScore)
	if GLOBAL_AGENT then
--		szGateWay, nAddScore
		GC_AllExcute({"BeautyHero:UpdateHelpTable",  tb16thPlayer});
	end
end

function DaTaoSha:AddLadderScore_GA(szName, szGateWay, nAddHonor)
	if GLOBAL_AGENT then
		GC_AllExcute({"DaTaoSha:AddLadderScore_GC",  szName, szGateWay, nAddHonor});
	end
end

--
function DaTaoSha:AddLadderScore_GC(szName, szGateWay, nAddHonor)
	if GetGatewayName() ~= szGateWay then
		return;
	end
	
	local nCurHonor = PlayerHonor:GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_LADDER1, 0);
	PlayerHonor:SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_LADDER1, 0, nAddHonor + nCurHonor);
--	pPlayer.Msg(string.format("恭喜你%s<color=yellow>%s<color>，获得<color=yellow>%d<color>点积分",szTmp,szTips,nAddHonor));
end

function DaTaoSha:OnRefreshLadder_GA()
	if GLOBAL_AGENT then
		GC_AllExcute({"DaTaoSha:OnRefreshLadder_GC"});
	end
end

function DaTaoSha:OnRefreshLadder_GC()
	if tonumber(GetLocalDate("%Y%m%d")) > self.nEndTime then
		return;
	end
	PlayerHonor:OnSchemeUpdateHanWuHonorLadder();
end

function DaTaoSha:AddGameResult_GC(nPlayerId, nAwardType)
	local nTskId = DaTaoSha.DEF_AWARD_TSK[nAwardType].nGlobal;
	if not nTskId then
		return;
	end
	local nRes = GetPlayerSportTask(nPlayerId, DaTaoSha.GBTSKG_DATAOSHA, nTskId) or 0;
	SetPlayerSportTask(nPlayerId, DaTaoSha.GBTSKG_DATAOSHA, nTskId, nRes + 1);	
end

function DaTaoSha:Msg2Global(nNum)
	if  not GLOBAL_AGENT then
		return;
	end 
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < self.nStatTime or nNowDate > self.nEndTime then
		return;
	end
	--周六下午不开
	local nWeek = tonumber(GetLocalDate("%w"));
	local nTime = tonumber(GetLocalDate("%H%M"));	
	if nWeek  == 6 and nTime > 1400 then
		return;
	end
	if not nNum or not self.tbMsg2Global[nNum] then
		return;
	end
	Dialog:GlobalNewsMsg_Center(self.tbMsg2Global[nNum]);
	Dialog:GlobalMsg2SubWorld_Center(self.tbMsg2Global[nNum]);
	Dialog:GlobalNewsMsg_GC(self.tbMsg2Global[nNum]);
	Dialog:GlobalMsg2SubWorld(self.tbMsg2Global[nNum]);
end

--清排行榜
function DaTaoSha:ClearLadder()
	local nBatch = KGblTask.SCGetDbTaskInt(DBTASK_DATAOSHA_BATCH);
	if nBatch ~= self.nBatch then		
		local nType = Ladder:GetType(0, 2, 2, 9);
		Ladder:ClearTotalLadderData(nType, PlayerHonor.HONOR_CLASS_LADDER1, 0, 1);
		DelShowLadder(nType);
		KGblTask.SCSetDbTaskInt(DBTASK_DATAOSHA_BATCH, self.nBatch);	
	end
end

function DaTaoSha:RegisterScheduleTask()
	for nTask, tbTime in pairs(self.TIME_SCHTASK) do
		local szFun = "Msg2Global"..nTask;
		local nTaskId = KScheduleTask.AddTask("DaTaoSha", "DaTaoSha", szFun);
		assert(nTaskId > 0);
		for nTaskEx, nTime in pairs(tbTime) do
			-- 时间执行点注册
			KScheduleTask.RegisterTimeTask(nTaskId, nTime, nTaskEx);
		end
	end	
end

--23:55刷新排行榜
function DaTaoSha:RegisterScheduleTask_GC()
	local nTaskId = KScheduleTask.AddTask("DaTaoSha", "DaTaoSha", "OnRefreshLadder_GC");
	KScheduleTask.RegisterTimeTask(nTaskId, 2355, 1);
end

if GLOBAL_AGENT then
	GCEvent:RegisterGCServerStartFunc(DaTaoSha.RegisterScheduleTask, DaTaoSha);
else
	GCEvent:RegisterGCServerStartFunc(DaTaoSha.RegisterScheduleTask_GC, DaTaoSha);
	GCEvent:RegisterAllServerStartFunc(DaTaoSha.ClearLadder, DaTaoSha);
end
