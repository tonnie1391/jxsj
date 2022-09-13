-- 文件名　：fuben_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-7
-- 描  述  ：

if (MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\fuben\\fuben_file.lua");
Require("\\script\\fuben\\define.lua");

--申请副本(物品申请)
function CFuben:ApplyFuBen(nItemId, nPlayerId)	
	local  pItem = KItem.GetObjById(nItemId);
	if  pItem then
		local nItemGDPL = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular,pItem.nLevel);
		local nType = self.FUBEN_EX[nItemGDPL][1];
		local nId = self.FUBEN_EX[nItemGDPL][2];
		return self:ApplyFuBenEx(nType, nId, nPlayerId);
	end
end

--申请副本(npc直接申请)	nType为副本管理表的id，nid为具体副本表对应的id号
function CFuben:ApplyFuBenEx(nType, nId, nPlayerId,tbDerivedRoom)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer  then
		local nTime =  tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
		local nNowTime = Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d"))*10000);
		if nNowTime - nTime < self.FUBEN[nType][nId].nTime * 24 * 3600 then
			pPlayer.Msg("此处还没有车夫直达，请日后再来！");
			return 0;
		end	
		if self.FubenData[nPlayerId] then
			pPlayer.Msg(string.format("您已经申请了<color=yellow>%s<color>副本，不能再申请了，请稍后再试！",self.FUBEN[self.FubenData[nPlayerId][4]][self.FubenData[nPlayerId][5]].szName)) ;
			return 0;
		end
		--组队模式需要判断队长，是不是有队伍的，其他模式默认该人已经满足要求
		if self.FUBEN[nType][nId].nGroupModel == 1 then
			local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
			if pPlayer.nTeamId == 0 then
				pPlayer.Msg("您没有队伍！");
				return 0;
			end
			local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
			if tbPlayerList[1] ~= me.nId then
				pPlayer.Msg("您不是队长！");
				return 0;
			end				
			if #tbPlayerList < self.FUBEN[nType][nId].nMinNumber or #tbPlayerList > self.FUBEN[nType][nId].nMaxNumber then
				KTeam.Msg2Team(pPlayer.nTeamId, string.format("你们队成员少于<color=yellow>%s<color>，无法开启副本！",self.FUBEN[nType][nId].nMinNumber));
				return 0;
			end
			for i = 1,#tbPlayerList do
				local pPlayerEx = KPlayer.GetPlayerObjById(tbPlayerList[i]);
				if pPlayerEx then
					if pPlayerEx.nLevel < self.FUBEN[nType][nId].nGrade or pPlayerEx.nFaction == 0 then
						KTeam.Msg2Team(pPlayerEx.nTeamId, string.format("你们队的<color=white>%s<color>等级不够，他是不能去的！",pPlayerEx.szName));
						return 0;
					end
					local nDate = pPlayerEx.GetTask(CFuben.TASKID_GROUP,CFuben.TASKID_DATE);
					local nTimes =  0;
					local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
					if  nDate ~= nNowDate then
						pPlayerEx.SetTask(CFuben.TASKID_GROUP,CFuben.TASKID_DATE,nNowDate);
						pPlayerEx.SetTask(CFuben.TASKID_GROUP,CFuben.TASKID_NTIMES + nType -1, 0);
					else
						nTimes = pPlayerEx.GetTask(CFuben.TASKID_GROUP,CFuben.TASKID_NTIMES + nType -1) or 0;
					end
					if nTimes >= self.FUBEN[nType].nCount  then
						KTeam.Msg2Team(pPlayerEx.nTeamId,string.format("%s今天的次数已经用完了！",pPlayerEx.szName));
						return 0;
					end
				end
 			end
		end
		if self:ApplyMap(pPlayer.nId,nType,nId,tbDerivedRoom) == 1 then
			pPlayer.Msg(string.format("成功申请<color=yellow>%s<color>副本！",self.FUBEN[nType][nId].szName));
			return 1;
		end
	end
end

function CFuben:IsSatisfy(nPlayerId, nCaptainId)	--进入副本条件	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then		
		if not self.FubenData[nCaptainId] then
			pPlayer.Msg("您的队伍、家族或是帮派并没有没有申请副本！");
			return 0;
		end
		local nTempMapId = self.FubenData[nCaptainId][1];
		local nMapId = self.FubenData[nCaptainId][2];
		local nType = self.FubenData[nCaptainId][4];
		local nId = self.FubenData[nCaptainId][5];
		if  CFuben.tbMapList[nTempMapId][nMapId].IsOpen == 0 then
			pPlayer.Msg("您的队伍、家族或是帮派申请的副本并没有开启！");
			return 0;
		end
		
		local nApplyedMap, nPosX, nPosY = pPlayer.GetWorldPos();
		if nApplyedMap ~=  	 self.FubenData[nCaptainId][3] then
			pPlayer.Msg(string.format("请回到申请该副本的地图<color=yellow>%s<color>，从那里进入！", GetMapNameFormId(self.FubenData[nCaptainId][3])));
			return 0;
		end
		
		if CFuben.tbMapList[nTempMapId][nMapId].DeathPlayerList[nPlayerId] == 1 then
			pPlayer.Msg("对不起，你已经从你们的副本中重伤出来了，无法再次进入！");
			return 0;
		end
		
		local nDate = pPlayer.GetTask(CFuben.TASKID_GROUP,CFuben.TASKID_DATE);
		local nTimes = 0;
		local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
		if  nDate ~= nNowDate then
			pPlayer.SetTask(CFuben.TASKID_GROUP,CFuben.TASKID_DATE,nNowDate);
			pPlayer.SetTask(CFuben.TASKID_GROUP,CFuben.TASKID_NTIMES + nType -1, 0);
		else
			nTimes = pPlayer.GetTask(CFuben.TASKID_GROUP,CFuben.TASKID_NTIMES + nType -1) or 0;
		end
		if nTimes >= self.FUBEN[nType].nCount then
			KTeam.Msg2Team(pPlayerEx.nTeamId,string.format("%s今天的次数已经用完了！",pPlayerEx.szName));
			return 0;
		end
		
		if self.FUBEN[nType][nId].nGroupModel == 1 then		--组队模式
			local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
			if #tbPlayerList < self.FUBEN[nType][nId].nMinNumber or #tbPlayerList > self.FUBEN[nType][nId].nMaxNumber then
				pPlayer.Msg(string.format("你们队成员少于<color=yellow>%s<color>，无法进入副本！",self.FUBEN[nType][nId].nMinNumber));
				return 0;
			end
			if (self.tbMapList[nTempMapId][nMapId].nCount or 0) >= self.FUBEN[nType][nId].nMaxNumber then
				pPlayer.Msg("你们队长已经带进去足够的人了，您不能再加入了");
				return 0;				
			end
		elseif self.FUBEN[nType][nId].nGroupModel == 2 then  --帮派模式
			if (self.tbMapList[nTempMapId][nMapId].nCount or 0) >= self.FUBEN[nType][nId].nMaxNumber then
				pPlayer.Msg("已经进去足够的人了，您不能再加入了");
				return 0;
			end
		elseif self.FUBEN[nType][nId].nGroupModel == 3 then		--家族模式
			if (self.tbMapList[nTempMapId][nMapId].nCount or 0) >= self.FUBEN[nType][nId].nMaxNumber then
				pPlayer.Msg("已经进去足够的人了，您不能再加入了");
				return 0;
			end
		end
		
		if pPlayer.nLevel < self.FUBEN[nType][nId].nGrade then
			pPlayer.Msg(string.format("您的等级还未达到 %s 级，这个斤两恐怕还去不了那凶险的地方啊",self.FUBEN[nType][nId].nGrade));
			return 0;
		end
	end
	return 1;
end

function CFuben:Init()
	CFuben.FubenData = {};
	for _, varFuBen in pairs(CFuben.FUBEN) do
		if type(varFuBen) == "table" then
			for _ , tbFuBen in ipairs(varFuBen) do
				local nMapId = tbFuBen.nMapId;
				CFuben.tbMapList[nMapId] = CFuben.tbMapList[nMapId] or {};
				CFuben.tbMapList[nMapId].nCount = CFuben.tbMapList[nMapId].nCount or 0;
			end
		end
 	end	
end

function CFuben:JoinGame(nPlayerId, nCaptainId)
	local nTempMapId = self.FubenData[nCaptainId][1];
	local nDyMapId = self.FubenData[nCaptainId][2];
	local nType = self.FubenData[nCaptainId][4];
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		if not self.tbMapList[nTempMapId][nDyMapId].PlayerList[nPlayerId] then	
			--joinmission		
			local nTimes = (pPlayer.GetTask(CFuben.TASKID_GROUP,CFuben.TASKID_NTIMES + nType -1) or 0) + 1;			
			pPlayer.SetTask(CFuben.TASKID_GROUP,CFuben.TASKID_NTIMES + nType -1, nTimes);
			self.tbMapList[nTempMapId][nDyMapId].PlayerList[nPlayerId] = 1;
		end
		self.tbMapList[nTempMapId][nDyMapId].nCount = self.tbMapList[nTempMapId][nDyMapId].nCount + 1;
		self.tbMapList[nTempMapId][nDyMapId].MissionList:JoinPlayer(pPlayer,1);	
	end
end

function CFuben:OnLeave(nPlayerId) --开启fb队长id
	local nTempMapId = self.FubenData[nPlayerId][1];
	local nDyMapId = self.FubenData[nPlayerId][2];
	if self.tbMapList[nTempMapId][nDyMapId].nCount >= 1 then
		self.tbMapList[nTempMapId][nDyMapId].nCount = self.tbMapList[nTempMapId][nDyMapId].nCount - 1;
	end
end

function CFuben:ApplyMap(nPlayerId,nType,nId,tbDerivedRoom)	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then		
		if self.FUBEN[nType][nId].szConditionItemName and self.FUBEN[nType][nId].szConditionItemName ~= "" then
			local tbFind = pPlayer.FindClassItemInBags(self.FUBEN[nType][nId].szConditionItemName);
			if not tbFind[1] then
				pPlayer.Msg("您身上没有开启的钥匙，是不能申请的！");
				return 0;
			end
		end
		local nPlayerMapId, nPosX, nPosY = me.GetWorldPos();	
		local szMapType = GetMapType(nPlayerMapId);
		if self.FUBEN[nType][nId].szConditionMapType and self.FUBEN[nType][nId].szConditionMapType ~= "" and self.FUBEN[nType][nId].szConditionMapType ~= szMapType then
			pPlayer.Msg(string.format("该地图不能申请此副本，请到<color=yellow>%s<color>去申请吧！",self.tbMapType[self.FUBEN[nType][nId].szConditionMapType]));
			return 0;
		end
		local nTempMapId = self.FUBEN[nType][nId].nMapId;
		if self:GetServerLoadMapCount(nTempMapId) >= self.FUBEN[nType][nId].nCount then
			pPlayer.Msg("多位英雄已闯入此地，这位侠士烦请稍候片刻。");
			return 0;
		end
		if tbDerivedRoom then
			self.FUBEN[nType][nId].tbDerivedRoom = tbDerivedRoom;
		else
			self.FUBEN[nType][nId].tbDerivedRoom = nil;
		end	
		--if SubWorldID2Idx(nTempMapId) >= 0 then
		--找闲置的地图
		if self.tbMapList[nTempMapId] then
			for nMapId, varValue in pairs(self.tbMapList[nTempMapId]) do								
				if  type(varValue) == "table" and self.tbMapList[nTempMapId][nMapId] and self.tbMapList[nTempMapId][nMapId].OnUsed ~= 1 
				and  self.tbMapList[nTempMapId][nMapId].IsServer then
					--self.tbMapList[nTempMapId][nMapId].OnUsed = 1;	--地图置为占用
					--self.FubenData[nPlayerId] = {nTempMapId, nMapId, nPlayerMapId, nPosX, nPosY};	
					GlobalExcute{"CFuben:OnLoadMap",nPlayerId,nType,nId,nPlayerMapId,nPosX,nPosY,nMapId,0};
					return 1;
				end
			end
		--分配地图
			local nTempMapId = self.FUBEN[nType][nId].nMapId;
			self.FubenData[nPlayerId] = {nTempMapId, 0, nPlayerMapId, nType, nId, nPosX, nPosY};
			if (Map:LoadDynMap(1, nTempMapId, {self.OnLoadMapFinish, self, nPlayerId, nType, nId, nPlayerMapId, nPosX, nPosY}) ~= 1) then
				print(string.format("副本地图%s加载错误！",nTempMapId));
				self:ResetMapState(nPlayerId);
				return 0;
			end			
			return 1;
		end
	end
	return 0;
end

--副本申请成功回调
function CFuben:OnLoadMapFinish(nPlayerId, nType, nId, nPlayerMapId, nPosX, nPosY,nDyMapId)
	local nTempMapId = self.FUBEN[nType][nId].nMapId;
	self.tbMapList[nTempMapId][nDyMapId] = {};
	self.tbMapList[nTempMapId][nDyMapId].IsServer = 1;
	GlobalExcute{"CFuben:OnLoadMap", nPlayerId, nType, nId, nPlayerMapId, nPosX, nPosY, nDyMapId,1};
end

function CFuben:CloseEx(nPlayerId)--开启fb队长id
	local nTempMapId = self.FubenData[nPlayerId][1];
	local nDyMapId = self.FubenData[nPlayerId][2];
	GlobalExcute{"CFuben:Close", nTempMapId, nDyMapId, nPlayerId};
end

function CFuben:GameStart(nPlayerId,nDyMapId)		
	local nTempMapId = self.FubenData[nPlayerId][1];
	local nType = self.FubenData[nPlayerId][4];
	local nId = self.FubenData[nPlayerId][5];
	local nFlag = self.tbMapList[nTempMapId].IsAddTrap;	
	self.tbMapList[nTempMapId][nDyMapId].MissionList = self.tbMapList[nTempMapId][nDyMapId].MissionList or Lib:NewClass(CFuben.FubenMission);	
	self.tbMapList[nTempMapId][nDyMapId].MissionList.nConsumeItemCount = 0;	--消耗牌子数量清0 
	self.tbMapList[nTempMapId][nDyMapId].MissionList:InitGameEx(nDyMapId,nPlayerId,self.FUBEN[nType][nId].nFubenId,self.FUBEN[nType][nId].tbDerivedRoom);
	self.tbMapList[nTempMapId][nDyMapId].MissionList:StartGame(nFlag);
	--开启mission
end

function CFuben:OnLoadMap(nPlayerId,nType,nId,nPlayerMapId,nPosX,nPosY,nDyMapId,nFlag)
	local nTempMapId = self.FUBEN[nType][nId].nMapId;
	self.tbMapList[nTempMapId][nDyMapId] = self.tbMapList[nTempMapId][nDyMapId] or {};
	self.tbMapList[nTempMapId][nDyMapId].OnUsed = 1;	--地图置为占用
	self.tbMapList[nTempMapId].nCount = self.tbMapList[nTempMapId].nCount  + 1;
	self.tbMapList[nTempMapId][nDyMapId].nCount = 0;
	self.tbMapList[nTempMapId][nDyMapId].IsOpen = 0;
	self.tbMapList[nTempMapId].IsAddTrap = nFlag;	
	self.tbMapList[nTempMapId][nDyMapId].PlayerList = {};
	self.tbMapList[nTempMapId][nDyMapId].DeathPlayerList = {};	--记录已经死亡的玩家，如果副本死亡无法进入，从这里判断
	self.FubenData[nPlayerId] = {nTempMapId, nDyMapId, nPlayerMapId, nType, nId, nPosX, nPosY};		
	--开启副本内容
	if self.FUBEN[nType][nId].nFlagAuto == 1 then
		self:GameStart(nPlayerId,nDyMapId);
		self.tbMapList[nTempMapId][nDyMapId].IsOpen = 1;
	else		
		Timer:Register(CFuben.NTIMES_END, self.ReSetFuben, self, nPlayerId);
	end
end

function CFuben:Close(nTempMapId, nDyMapId, nPlayerId)
	local nType = self.FubenData[nPlayerId][4];
	local nId = self.FubenData[nPlayerId][5];
	self.tbMapList[nTempMapId][nDyMapId].OnUsed = 0;	--重置地图
	self.tbMapList[nTempMapId].nCount = self.tbMapList[nTempMapId] .nCount  - 1;
	self.tbMapList[nTempMapId][nDyMapId].nCount = 0;
	self.tbMapList[nTempMapId][nDyMapId].IsOpen = 0;
	self.tbMapList[nTempMapId][nDyMapId].PlayerList = {};
	self.FubenData[nPlayerId] = nil;
	if self.FUBEN[nType][nId].szItemId and self.FUBEN[nType][nId].szItemId ~= "" then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local tbItem = pPlayer.FindClassItemInBags("fuben");
			for i = 1 , #tbItem do
				if string.format("%s,%s,%s,%s", tbItem[i].pItem.nGenre, tbItem[i].pItem.nDetail, tbItem[i].pItem.nParticular, tbItem[i].pItem.nLevel) == self.FUBEN[nType][nId].szItemId and tbItem[i].pItem.GetGenInfo(1) == 1 then
					pPlayer.Msg(string.format("由于您开启的副本长时间没有进入，系统自动删除过期副本的物品<color=yellow>%s<color>！",tbItem[i].pItem.szName));				
					tbItem[i].pItem.Delete(pPlayer);
				end
			end
		end
	end
end

function CFuben:ResetMapState(nPlayerId)
	self.FubenData[nPlayerId] = nil;
end

function CFuben:FindFunben(nFlag,nVarId)
	for nPlayerId,  tbFuben in pairs(self.FubenData) do
		local nTempMapId = tbFuben[1];
		local nDyMapId = tbFuben[2];	
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if nFlag == 2 then
				if pPlayer.dwKinId == nVarId then
					return 1, nPlayerId;
				end
			elseif pPlayer.dwTongId == nVarId then
				return 1, nPlayerId;				
			end			
		end		
	end
	return 0, 0;
end

function CFuben:ReSetFuben(nPlayerId)	
	if not CFuben.FubenData[nPlayerId] then
		return 0;
	end
	local nTempMapId = self.FubenData[nPlayerId][1];
	local nDyMapId = self.FubenData[nPlayerId][2];
	local nType = self.FubenData[nPlayerId][4];
	local nId = self.FubenData[nPlayerId][5];
	if self.tbMapList[nTempMapId][nDyMapId].OnUsed == 1 and self.tbMapList[nTempMapId][nDyMapId].IsOpen == 0 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg(string.format("您申请的<color=yellow>%s<color>副本由于长时间没有开启，系统自动收回！", self.FUBEN[nType][nId].szName));
		end
		self.tbMapList[nTempMapId][nDyMapId].OnUsed = 0;
		self.tbMapList[nTempMapId].nCount = self.tbMapList[nTempMapId] .nCount  - 1;
		self.FubenData[nPlayerId] = nil;
	end
	return 0;
end

function CFuben:GetServerLoadMapCount(nTempMapId)
	local nCount = 0;
	for nMapId, varValue in pairs(self.tbMapList[nTempMapId]) do								
		if type(varValue) == "table" and self.tbMapList[nTempMapId][nMapId].IsServer then
			nCount = nCount + 1;
		end
	end
	return nCount
end

function CFuben:GetGameByMapId(nTempMapId,nDyMapId)
	if not self.tbMapList[nTempMapId][nDyMapId] then
		return;
	end
	return self.tbMapList[nTempMapId][nDyMapId].MissionList;
end


--通过队伍id获取副本
function CFuben:GetGameByTeamId(nTeamId,nType,nId)
	if not nTeamId then
		return;
	end
	local tbPlayerIdList = KTeam.GetTeamMemberList(nTeamId);
	if not tbPlayerIdList or #tbPlayerIdList <= 0 then
		return;
	end
	local nCaptainId = tbPlayerIdList[1];
	local pGame = self.FubenData[nCaptainId];
	if not pGame then
		return;
	end
	local nGameType = self.FubenData[nCaptainId][4];
	local nGameId = self.FubenData[nCaptainId][5];
	if nGameType ~= nType or nId ~= nGameId then
		return;
	end
	return pGame;
end


ServerEvent:RegisterServerStartFunc(CFuben.Init, CFuben);
