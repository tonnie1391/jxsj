--Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua");
Require("\\script\\task\\treasuremap2\\treasuremap2_mission.lua");

TreasureMap2.tbTreasurePos   = TreasureMap2.tbTreasurePos or {};
TreasureMap2.InstancingMgr   = TreasureMap2.InstancingMgr or {};
TreasureMap2.tbInstancingLib = TreasureMap2.tbInstancingLib or {};

--改成以副本ID的形式
function TreasureMap2:GetInstancingBase(nTreasureId)
	if (not TreasureMap2.tbInstancingLib[nTreasureId]) then
		TreasureMap2.tbInstancingLib[nTreasureId] = Lib:NewClass(self.Mission);
	end
	
	return TreasureMap2.tbInstancingLib[nTreasureId];
end

function TreasureMap2:AwardWeiWang(pPlayer, nWeiWang, nGongXian)
	-- by zhangjinpin@kingsoft
	if pPlayer.nLevel >= 80 then
		return;
	end
--	pPlayer.AddKinReputeEntry(nWeiWang, "TreasureMap2");
	pPlayer.AddKinReputeEntry(nWeiWang, "treasuremap");
end

function TreasureMap2:AwardXinDe(pPlayer, nXinDe)
	Setting:SetGlobalObj(pPlayer);
	Task:AddInsight(nXinDe);
	Setting:RestoreGlobalObj();
end

function TreasureMap2:AddFriendFavor(tbTeamList, nMapId, nFavor)
	if (not tbTeamList) then
		return;
	end
	
	for i = 1, #tbTeamList do
		for j = i + 1, #tbTeamList do
			if (tbTeamList[i].nMapId == nMapId and tbTeamList[j].nMapId == nMapId and 
				tbTeamList[i].IsFriendRelation(tbTeamList[j].szName) == 1) then
					Relation:AddFriendFavor(tbTeamList[i].szName, tbTeamList[j].szName, nFavor);
					tbTeamList[i].Msg(string.format("Bạn và <color=yellow>%s<color> tăng độ thân mật lên %d điểm.", tbTeamList[j].szName, nFavor));
					tbTeamList[j].Msg(string.format("Bạn và <color=yellow>%s<color> tăng độ thân mật lên %d điểm.", tbTeamList[i].szName, nFavor));
				end
		end
	end
end



TreasureMap2.nAdviceRange 				= 300;	-- 局部消息范围



function TreasureMap2:GetDirection(tbOrigin, tbTarget)
	local tbStr = {"Tây Nam", "Nam", "Đông Nam", "Đông", "Đông Bắc", "Bắc", "Tây Bắc", "Tây"};
	
	local nX	= tbOrigin[2] - tbTarget[2];
	local nY	= tbTarget[1] - tbOrigin[1];
	
	local nDeg	= math.atan2(tbOrigin[2] - tbTarget[2], tbTarget[1] - tbOrigin[1]);
	local nDirection = math.floor(nDeg*4/math.pi+4.5);
	
	if (nDirection <= 0) then
		nDirection = nDirection + 8;
	end;
	
	-- 具体的距离，取整数
	local nDistance = math.floor(math.sqrt(nX*nX + nY*nY));
	
	return tbStr[nDirection], nDistance;
end;


-- 给附近的玩家发送一条信息
function TreasureMap2:NotifyAroundPlayer(pPlayer, szMsg)
	local tbPlayerList = KPlayer.GetAroundPlayerList(pPlayer.nId, TreasureMap.nAdviceRange);
	if tbPlayerList then
		for _, player in ipairs(tbPlayerList) do
			player.Msg(szMsg);
		end
	end
end

-- 对副本各种剧情任务的处理 没用了
function TreasureMap2:InstancingTask(pPlayer, MapId)
	if self.TSK_INS_TBTASK[MapId] then
		if pPlayer.GetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][1]) == 1 then
			pPlayer.SetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][1], 2, 1);
		end;
		
		if pPlayer.GetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][2]) == 1 then
			pPlayer.SetTask(self.TSKGID, self.TSK_INS_TBTASK[MapId][2], 2, 1);
		end;
	end;
end;

-- 碧落谷申请马牌掉落结果函数
-- tbInstancKey = {nMapId, nCaptainId, nStartTime}
function TreasureMap2:OnHorseApplyRequest_biluogu(tbInstancKey, nResult)
	if nResult ~= 1 then
		return;
	end

	local tbInstance = self:GetInstancing(tbInstancKey[1]);
	if tbInstance.nCaptainId ~= tbInstancKey[2] or 
		tbInstance.nStartTime ~= tbInstancKey[3] then
		return;
	end
	if tbInstance.AddHorse then
		tbInstance:AddHorse();
	end
end

function TreasureMap2:_Debug(...)
	print ("[Treasure Map]: ", unpack(arg));
end


