-- 文件名　：chaqizhi_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 17:08:20
--插旗

if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\vn_201104\\chaqizhi_def.lua");

SpecialEvent.tbChaQi2011 = SpecialEvent.tbChaQi2011 or {};
local tbChaQi2011 = SpecialEvent.tbChaQi2011;

-- 种下一棵树
-- return pNpc
function tbChaQi2011:PlantTree(nPlayerId, szPlayerName, nTreeIndex, nMapId, x, y)	
	local nNpcId = self.tbTree[nTreeIndex][1];
	
	local pNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y)
	
	if not pNpc then
		return 0;
	end

	self:SetTreePlantingState(szPlayerName, 1);
	
	local tbTemp = pNpc.GetTempTable("Npc");
	local nTimerId_Exp, nTimerId_Die;
	
	if nTreeIndex < self.INDEX_BIG_TREE then
		nTimerId_Exp = Timer:Register(self.EXP_TIME * Env.GAME_FPS, self.GiveExp, self, nPlayerId, pNpc.dwId, nMapId, x, y);
	end
	nTimerId_Die = Timer:Register(self.tbTree[nTreeIndex][2]* Env.GAME_FPS, self.TreeDie, self, pNpc.dwId);
	
	tbTemp.tbChaQi2011 = {
		["nPlayerId"] = nPlayerId,
		["szPlayerName"] = szPlayerName,
		["nTreeIndex"]  = nTreeIndex; 
		["nTimerId_Exp"] = nTimerId_Exp;
		["nTimerId_Die"] = nTimerId_Die;		
		};
		
	pNpc.szName = szPlayerName .. "的" .. pNpc.szName;	
	return 0, pNpc;
end

--能否种树判断
function tbChaQi2011:CanPlantTree(pPlayer)
	--pos	
	if "city" ~= GetMapType(pPlayer.nMapId) then	
		return 0, "只有在城市才可以插旗帜！";
	end
	
	--task
	local nRes, szKind, nNum = self:IsTreeCountOk(pPlayer);
	if nRes == 0 then
		if szKind == "TOTAL" then
			return 0, string.format("我已经插了%d旗帜了，还是给他人留点地方吧。", nNum);
		elseif szKind == "TODAY" then
			return 0, string.format("我今天已经插了%d旗帜了，还是休息下，明天再说吧。", nNum);
		end
	end
	
	--挡npc
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, "在这种会把<color=green>".. pNpc.szName.."<color>给挡住了，还是挪个地方吧。";
		end
	end
	
	--是否种树判断
	for i = 1, 7 do
		if self.tbPlantInfo[i] and self.tbPlantInfo[i][pPlayer.szName] then
			return 0, " 恐怕你有旗帜在激活中...";
		end
	end
	local tbFind = pPlayer.FindItemInBags(unpack(self.tbQIZhi));
	if not tbFind[1] then
		return 0, "你需要有一个旗帜才能插旗。";
	end
	return 1;
end

--种下第一棵树
function tbChaQi2011:Plant1stTree(pPlayer, dwItemId)
	local nRes = self:CanPlantTree(pPlayer);
	if nRes == 0 then 
		return 0;
	end
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return 0;
	end	
	local nMapId, x, y = pPlayer.GetWorldPos();
	local _, pNpc = self:PlantTree(pPlayer.nId, pPlayer.szName,1, nMapId, x, y);
	if pNpc then
		pItem.Delete(pPlayer);
		pPlayer.ConsumeItemInBags2(1, self.tbQIZhi[1], self.tbQIZhi[2], self.tbQIZhi[3], self.tbQIZhi[4]);
		pPlayer.SetTask(self.TASKGID, self.TASK_COUNT_PLANT, pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT) + 1);
		local nTreeCountTotal = pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT_ALL) + 1;
		pPlayer.SetTask(self.TASKGID, self.TASK_COUNT_PLANT_ALL,  nTreeCountTotal);
		if nTreeCountTotal >= self.nMaxPlantAll then
			me.AddTitle(unpack(self.tbTitle));
			me.SetCurTitle(unpack(self.tbTitle));
			me.Msg("恭喜你树立了100只旗帜，获得威震天下称号。");
		end
		Dialog:SendBlackBoardMsg(pPlayer, "你树立了一个功勋旗帜。");
		return 1;
	end
	return 0;
end

-- 判断玩家植树数量是否符合要求
function tbChaQi2011:IsTreeCountOk(pPlayer)
	--task
	Setting:SetGlobalObj(pPlayer);
	local nFlag = Player:CheckTask(self.TASKGID, self.TASK_DATE, "%Y%m%d", self.TASK_COUNT_PLANT, self.nMaxPlant);
	Setting:RestoreGlobalObj();
	local nTreeCountToday = pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT);
	if nFlag == 0 then
		return 0, "TODAY", nTreeCountToday;
	end
	local nTreeCountTotal = pPlayer.GetTask(self.TASKGID, self.TASK_COUNT_PLANT_ALL);
	if nTreeCountTotal >= self.nMaxPlantAll then
		return 0, "TOTAL", nTreeCountTotal;
	end
	return 1;
end

-- 枯死了
function tbChaQi2011:TreeDie(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local nMapId, x, y = pNpc.GetWorldPos();
	local tbTreeData = pNpc.GetTempTable("Npc").tbChaQi2011;
	local nTreeIndex = tbTreeData.nTreeIndex;
	local szName = tbTreeData.szPlayerName;
	local nPlayerId = tbTreeData.nPlayerId;
	
	if tbTreeData.nTimerId_Die and Timer:GetRestTime(tbTreeData.nTimerId_Die) > 0 then
		Timer:Close(tbTreeData.nTimerId_Die);
	end
	if tbTreeData.nTimerId_Exp and Timer:GetRestTime(tbTreeData.nTimerId_Exp) > 0 then
		Timer:Close(tbTreeData.nTimerId_Exp);
	end
	pNpc.Delete();
	--种下一颗	
	self:SetTreePlantingState(szName, 0);
	if nTreeIndex ==1 then
		self:PlantTree(nPlayerId, szName, nTreeIndex + 1, nMapId, x, y);
		GlobalExcute({"SpecialEvent.tbChaQi2011:Msg2Player", nPlayerId});
	end
	return 0;
end

--全局提醒玩家操作
function tbChaQi2011:Msg2Player(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end	
	local szMsg = "你树立的旗帜已经激活，上面好像有个包裹，过去领取吧。";
	pPlayer.Msg(szMsg);
	Dialog:SendBlackBoardMsg(pPlayer, szMsg);	
end

--摘果子
function tbChaQi2011:GatherSeed(dwNpcId, nPlayerId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if pPlayer.CountFreeBagCell() < 1 then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Hành trang không đủ chỗ trống<color=yellow>1格<color>！");
		Setting:RestoreGlobalObj();
		return 0;
	end
	if self:CanGatherSeed(dwNpcId) == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, "好像有问题呀，不能领取。");
		return 0;
	end
	local pItem = pPlayer.AddItem(unpack(self.tbGongXunXiang));
	if pItem then
		pItem.SetTimeOut(0, GetTime() + 30 * 24 * 3600);
		pItem.Sync();
		pPlayer.Msg("恭喜你获得一个功勋箱。");
		Dialog:SendBlackBoardMsg(pPlayer, "恭喜你获得一个功勋箱。");
	end
	
	self:TreeDie(dwNpcId);
	return 1;
end

--自己能否摘果子
function tbChaQi2011:CanGatherSeed(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbChaQi2011 then
		return 0;
	end
	if not tbTemp.tbChaQi2011.nTreeIndex or tbTemp.tbChaQi2011.nTreeIndex <= 1 then
		return 0;
	end
	return 1;
end

-- 给予经验
function tbChaQi2011:GiveExp(nPlayerId, nNpcId, nMapId, x, y)
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nTimes = 1;
	if pPlayer and pPlayer.nMapId == nMapId and self:CheckInExpAround(pPlayer, x, y) == 1 then
		local tbMemberList, nMemberCount = pPlayer.GetTeamMemberList();
		if tbMemberList then
			for _, pMember in pairs(tbMemberList) do
				if pMember.nId ~= pPlayer.nId and pMember.nMapId == nMapId 
				and self.tbPlantInfo[GetServerId()] and self.tbPlantInfo[GetServerId()][pMember.szName] 
				and self:CheckInExpAround(pMember, x, y) == 1 then	-- 同一地图才能获得组队经验	
					nTimes = nTimes + 1;
				end
			end
		end
		local nExp = math.floor(pPlayer.GetBaseAwardExp() / 2 * self.BASE_EXP_MULTIPLE) * nTimes;
		pPlayer.CastSkill(377, 10, -1, pPlayer.GetNpc().nIndex);
		pPlayer.AddExp(nExp);
	end
	if not pNpc then
		return 0;
	end
	return;
end

-- 检测是否在指定范围内煮粽子
function tbChaQi2011:CheckInExpAround(pPlayer, x, y)
	local _, nPlayerPosX, nPlayerPosY = pPlayer.GetWorldPos();
	local nX = nPlayerPosX - x;
	local nY = nPlayerPosY - y;
	if (nX * nX + nY * nY) < (self.RANGE_EXP * self.RANGE_EXP) then
		return 1;
	end
	return 0;
end

--设置种树状态
function tbChaQi2011:SetTreePlantingState(szName, nFlag)
	local nServerId = GetServerId();
	self:SetPlantState(szName, nServerId, nFlag);
	GCExcute({"SpecialEvent.tbChaQi2011:SetPlantState",szName, nServerId, nFlag});
end

--设置种树标志
function tbChaQi2011:SetPlantState(szName, nServerId, nFlag)
	self.tbPlantInfo[nServerId] = self.tbPlantInfo[nServerId] or {};
	if nFlag == 1 then		
		self.tbPlantInfo[nServerId][szName] = GetTime();
	else
		self.tbPlantInfo[nServerId][szName] = nil;
	end
end

--同步全局数据
function tbChaQi2011:SyncData(nServerId, tbPlantInfo)
	local nLServerId = GetServerId();
	if nLServerId == nServerId then
		self.tbPlantInfo = tbPlantInfo;
	end
end

--宕机保护
function tbChaQi2011:ServerStartFunc()
	GCExcute({"SpecialEvent.tbChaQi2011:SyncData", GetServerId()});
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.tbChaQi2011.ServerStartFunc, SpecialEvent.tbChaQi2011);


