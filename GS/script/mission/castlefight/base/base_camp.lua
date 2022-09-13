-- 文件名  : base_camp.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-08 09:22:31
-- 描述    : 基础阵营

CastleFight.tbBaseCamp = CastleFight.tbBaseCamp or {};
local tbBaseCamp = CastleFight.tbBaseCamp;

function tbBaseCamp:Init(tbMission,nCamp, tbNpcTrap,TEMP_OBJTABLE, NPC_MOVE,BOSS_POS)
	self.nScore = 0;				-- 总积分
	self.tbPlayerEx = tbMission.tbPlayerEx;			-- 共享mission的
--	self.tbPlayerEx = {};
	self.tbNpcList	= {};
	self.tbBuildingList = {};
	self.tbBuffList	= {};
--	self.tbPlayer   = {};

--	self.nActiveTimes  = 0;
--	self.nAddMoneyFrame = 0;
	self.nCamp  = nCamp;
	self.tbObjList = Lib:NewClass(CastleFight.tbBaseObj);
	self.tbObjList:Init(TEMP_OBJTABLE);
	
	self.tbNpcTrap = tbNpcTrap;
--	self.tbNpcTrap:AttachMissionToTrap(self);
	self.tbNpcMove = NPC_MOVE;

	self.tbMission  = tbMission;
	self.nMapId = tbMission.nMapId;

	self.nSkillCount = 0;	-- 大招次数
	-- BOSS
	self.nBossId	= 0;
	self.BOSS_POS   = BOSS_POS;
end

function tbBaseCamp:OnStart()	
	-- 加一个BOSS
	local pNpc = KNpc.Add2(CastleFight.NPC_BOSS_ID,100 , -1, self.nMapId, self.BOSS_POS[1], self.BOSS_POS[2]);	
	if not pNpc then
		print("【ERR】 tbCamp:boss  is nil");
		return;
	end
	self.nBossId = pNpc.dwId;
	pNpc.GetTempTable("Npc").tbMission  = self.tbMission;
	pNpc.GetTempTable("Npc").nCamp 		= self.nCamp;
	pNpc.SetCurCamp(self.nCamp);	
end

--Camp Active
function tbBaseCamp:OnActive()	
	-- 系统造兵
	self:SysAddNpc();	
end

function tbBaseCamp:ClearNpc()
	for nNpcId, _ in pairs(self.tbBuildingList) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();			
		end
	end
	self.tbBuildingList = {};
	
	for nNpcId, _ in pairs(self.tbNpcList) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();			
		end
	end
	self.tbNpcList = {};	

	if self.nBossId ~= 0 then
		local pNpc = KNpc.GetById(self.nBossId);
		if pNpc then
			pNpc.Delete();			
		end
		self.nBossId = 0;
	end

end

function tbBaseCamp:Close()
	self:ClearNpc();
	self.tbBuffList = {};
	self.tbNpcTrap:DettachMissionToTrap();
end

-- 系统造兵
function tbBaseCamp:SysAddNpc()
	local pBuilding = nil;
	for nNpcId in pairs(self.tbBuildingList) do
		local pBuilding = KNpc.GetById(nNpcId);
		if pBuilding  then
			self:BuildingAddNpc(pBuilding);
		end
	end	
end

function tbBaseCamp:BuildingAddNpc(pBuilding)
	-- 如果在升级则 直接return 
	if CastleFight:IsBuildingUpdate(pBuilding) == 1 then
		return;
	end
	
	local tbNpcInfo = CastleFight.NPC_TEMPLATE[CastleFight:GetNpcId(pBuilding)];
	if tbNpcInfo.nProductNpc == 0 then
		return;
	end
	
	CastleFight:AddNpcFrame(pBuilding, 1);
	local nNpcCD =  CastleFight.NPC_TEMPLATE[tbNpcInfo.nProductNpc].nProductCD;
	local nFrame = CastleFight:GetNpcFrame(pBuilding);
	nFrame = nFrame % nNpcCD;
	CastleFight:SetNpcFrame(pBuilding,nFrame);
	if nFrame ~= 0 then
		return;
	end
	
--	if tbNpcInfo.nProductNpc == 0 then
--		print("【WRN】 BuildingAddNpc nProductNpc is 0", CastleFight:GetNpcId(pBuilding));
--		return;
--	end
	
	self:__BuildingAddNpc(pBuilding, CastleFight.NPC_TEMPLATE[tbNpcInfo.nProductNpc]);
end

function tbBaseCamp:__BuildingAddNpc(pBuilding, tbNpcInfo)	
	local nMapId, nX, nY = pBuilding.GetWorldPos();
	local pNpc = KNpc.Add2(tbNpcInfo.nNpcId, tbNpcInfo.nLevel, tbNpcInfo.nSeries, nMapId, nX + 1, nY + 1);
	if not pNpc then
		print("【ERR】 tbCamp:__BuildingAddNpc pNpc is nil", nMapId, nX,nY, tbNpcInfo.nNpcId);
		return;
	end
	
	self.tbNpcList[pNpc.dwId] = 1;
	pNpc.GetTempTable("Npc").tbMission = self.tbMission;
	pNpc.GetTempTable("Npc").nCamp	   = self.nCamp;
--	pNpc.GetTempTable("Npc").bBuilding = 0;
	pNpc.SetCurCamp(self.nCamp);
	CastleFight:SetNpcOwner(pNpc, CastleFight:GetNpcOwnerId(pBuilding));
	CastleFight:SetNpcId(pNpc, tbNpcInfo.nId);
	pNpc.SetNpcAI(9, 100, 0, -1, 25, 25, 25, 0, 0, 0, 0);
	pNpc.SetActiveForever(1);	
	
	CastleFight:SetNpcMoveAI(pNpc, self.nCamp,self:GetBuildingDirect(pBuilding));

	-- 造兵加积分
	self:AddPlayerScore(CastleFight:GetNpcOwnerId(pBuilding),  tbNpcInfo.nProductScore);
	
--	NPC buff TODO
--	self:BuffEffectNpc(pNpc);

	self.tbNpcTrap:AttachCharacterToTrap(pNpc);

	self:SetNpcTitle(pNpc,CastleFight:GetNpcOwnerId(pBuilding));
end

function tbBaseCamp:AddPlayerScore(nPlayerId, nAddScore)
	self.tbPlayerEx[nPlayerId].nScore = self.tbPlayerEx[nPlayerId].nScore + nAddScore;
	self.nScore = self.nScore + nAddScore;
end

function tbBaseCamp:AddCampScore(nAddScore)
	self.nScore = self.nScore + nAddScore;
end

-- 造建筑
function tbBaseCamp:CanBuildBuilding(pPlayer, nId)
	local nPos = self.tbObjList:CheckObjByPlayer(pPlayer);	
	if nPos == 0 then
		CastleFight:SendMsgAndBroadMsg(pPlayer, "Sai vị trí, xây kiến trúc trên điểm xanh lam.");
		return 0;
	end
	
	local tbNpcInfo = CastleFight.NPC_TEMPLATE[nId];
	local nCurMoney = CastleFight:GetPlayerMoney(pPlayer);
	if nCurMoney < tbNpcInfo.nProductMoney then
		CastleFight:SendMsgAndBroadMsg(pPlayer, string.format("Không đủ <color=yellow>%d<color> quân hưởng.", tbNpcInfo.nProductMoney));
		return 0;
	end
	
	if tbNpcInfo.nIsBuilding ~= 1 then
		print("!!!!!!!!!!!!!!it is not a building!!!!!!!!!!!!");
		return 0;
	end
		
	return nPos;
end

function tbBaseCamp:BuildBuilding(pPlayer, nId)
	local nPos = self:CanBuildBuilding(pPlayer, nId);
	if nPos == 0 then
		return 0;
	end
	
	-- 扣钱
	local tbNpcInfo = CastleFight.NPC_TEMPLATE[nId];
	local nCurMoney = CastleFight:GetPlayerMoney(pPlayer);
	CastleFight:SetPlayerMoney(pPlayer, nCurMoney - tbNpcInfo.nProductMoney);
	
	self.tbMission:AddPlayerBuildNum(pPlayer.nId); -- 统计
	--pPlayer.Msg(string.format("花费%s建造",tbNpcInfo.nProductMoney));

	-- ADD NPC
	self:__BuildBuilding(pPlayer.nId,nPos,nId);

	if (not self.tbMission.tbLogBuildingNum[nId]) then
		self.tbMission.tbLogBuildingNum[nId] = 0;
	end	
	self.tbMission.tbLogBuildingNum[nId] = self.tbMission.tbLogBuildingNum[nId] + 1;
	
	return 1;
end

function tbBaseCamp:__BuildBuilding(nPlayerId,nPos,nId, nLifePercent)
	nLifePercent = nLifePercent or 100;
	local tbNpcInfo = CastleFight.NPC_TEMPLATE[nId];	
	local tbPosInfo = self.tbObjList:GetObjPosInfo(nPos);
	local pNpc = KNpc.Add2(tbNpcInfo.nNpcId, tbNpcInfo.nLevel, tbNpcInfo.nSeries, self.nMapId, tbPosInfo.nX, tbPosInfo.nY);
	
	if not pNpc then
		print("【ERR】 tbCamp:__BuildBuildings pNpc is nil",  nPos, nId);
		return;
	end
	
	-- 占地
	self.tbObjList:AddObj(nPos);	

	self.tbBuildingList[pNpc.dwId] = 1;
	pNpc.GetTempTable("Npc").nPos 		= nPos;

	pNpc.GetTempTable("Npc").tbMission  = self.tbMission;
	pNpc.GetTempTable("Npc").nCamp 		= self.nCamp;
	pNpc.SetCurCamp(self.nCamp);
	pNpc.SetActiveForever(1);
	CastleFight:SetNpcId(pNpc, tbNpcInfo.nId);
	CastleFight:SetNpcOwner(pNpc, nPlayerId);
	
	-- 造建筑加积分
	self:AddPlayerScore(nPlayerId,  tbNpcInfo.nProductScore);	
	
--	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
--	if pPlayer then
--		pPlayer.Msg(pNpc.szName);
--	end
	-- 减少生命值
	if nLifePercent < 100 then
		pNpc.ReduceLife(math.floor(pNpc.nMaxLife * (100 - nLifePercent) / 100));
	end
	
	self:SetNpcTitle(pNpc, nPlayerId);
	pNpc.Sync();
	return 1;
end

--升级建筑
function tbBaseCamp:CanUpdateBuilding(pPlayer,pBuilding)
	if CastleFight:GetNpcOwnerId(pBuilding) ~= pPlayer.nId then
		CastleFight:SendMsgAndBroadMsg(pPlayer, "Không thể nâng cấp kiến trúc của người khác");
		return 0;
	end
	
	if not self.tbBuildingList[pBuilding.dwId] then
		--print("!!assert!!!!!!!!!!! CanUpdateBuilding");
		--pPlayer.Msg("");
		return 0;
	end
	local tbOldInfo = CastleFight.NPC_TEMPLATE[CastleFight:GetNpcId(pBuilding)];
	
	if tbOldInfo.nLevelUpNpc == 0 then
		CastleFight:SendMsgAndBroadMsg(pPlayer, "Không thể nâng cấp Tiêu Tháp hoặc Kiến trúc [Cao]");
		return 0;
	end
	
	local nCurMoney = CastleFight:GetPlayerMoney(pPlayer);
	if nCurMoney < tbOldInfo.nLevelUpMoney then
		CastleFight:SendMsgAndBroadMsg(pPlayer, string.format("Còn thiếu <color=yellow>%s<color> quân hưởng, cần ít nhất <color=yellow>%s<color>.", tbOldInfo.nLevelUpMoney - nCurMoney, tbOldInfo.nLevelUpMoney));
		return 0;
	end	
	
	return 1;
end

function tbBaseCamp:UpdateBuilding(pPlayer,pBuilding)
	local nRes = self:CanUpdateBuilding(pPlayer, pBuilding);
	if nRes == 0 then
		return 0;
	end
	local nPos = pBuilding.GetTempTable("Npc").nPos;
	local tbOldInfo = CastleFight.NPC_TEMPLATE[CastleFight:GetNpcId(pBuilding)];
	--if tbOldInfo.nIsBuilding ~= 1 then -- 可以考虑不要
	--	print("UpdateBuilding:!!!!!!!!!!!!!!it is not a building!!!!!!!!!!!!");
	--	return 0;
	--end	
	
	local nCurMoney = CastleFight:GetPlayerMoney(pPlayer);	
	CastleFight:SetPlayerMoney(pPlayer, nCurMoney - tbOldInfo.nLevelUpMoney);
--	pPlayer.Msg(string.format("兵营%s花费%s，升级到",pBuilding.szName,tbOldInfo.nLevelUpMoney));
	local nLifePercent = math.floor( pBuilding.nCurLife* 100 / pBuilding.nMaxLife);
	self:DelBuilding(pBuilding,1);
	self:__BuildBuilding(pPlayer.nId,nPos,tbOldInfo.nLevelUpNpc, nLifePercent);
end

-- 删除建筑
function tbBaseCamp:CanDelBuilding(pPlayer,pBuilding)
	if CastleFight:GetNpcOwnerId(pBuilding) ~= pPlayer.nId then
		return 0;
	end
	
	if not self.tbBuildingList[pBuilding.dwId] then
		-- print("!!assert!!!!!!!!!!! CanDelBuilding");
		return 0;
	end
	
	return 1;
end

function tbBaseCamp:DelBuilding(pBuilding, bDel)
	self.tbBuildingList[pBuilding.dwId] = nil;
	self.tbObjList:DelObj(pBuilding.GetTempTable("Npc").nPos);
	if bDel and bDel == 1 then
		pBuilding.Delete();
	end
end

-- 加BUFF TODO
function tbBaseCamp:AddNpcBuff(nBuffId)
	local pNpc = nil;
	local tbBuffInfo = CastleFight.BUFF_LIST[nBuffId];
	for nNpcId in pairs(self.tbNpcList) do
		pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.AddSkillState(tbBuffInfo.nId, tbBuffInfo.nLevel, 1, tbBuffInfo.nSec * Env.GAME_FPS, 1, 0, 1);
		end
	end
	self.tbBuffList[nBuffId] = GetTime();
end

function tbBaseCamp:BuffEffectNpc(pNpc)
	for nBuffId ,nStart in pairs(self.tbBuffList) do
		local tbBuffInfo = CastleFight.BUFF_LIST[nBuffId];
		if tbBuffInfo.nSec + nStart > GetTime() then
			pNpc.AddSkillState(tbBuffInfo.nId, tbBuffInfo.nLevel, 1, (nStart + tbBuffInfo.nSec - GetTime()) * Env.GAME_FPS, 1, 0, 1);
		else
			self.tbBuffList[nBuffId] = nil;
		end			
	end
end

function tbBaseCamp:GetBuildingDirect(pBuilding)
	local tbPosInfo = self.tbObjList:GetObjPosInfo(pBuilding.GetTempTable("Npc").nPos);
	return tbPosInfo.nDirect;
end

--颜色 TODO
function tbBaseCamp:StrAddPlayerColor(str,nPlayerId)
	return CastleFight:AddStrColor(str,self.tbPlayerEx[nPlayerId].nColor);
end

function tbBaseCamp:SetNpcTitle(pNpc, nPlayerId)
	local szTitle = CastleFight:AddStrColor(string.format("%s",self.tbPlayerEx[nPlayerId].szName),self.tbPlayerEx[nPlayerId].nColor);
	-- local szTitle = string.format("%s", self.tbPlayerEx[nPlayerId].szName); --, pNpc.szName);
	pNpc.SetTitle(szTitle);
end

function tbBaseCamp:AddSkillCount(nAdd)
	self.nSkillCount = self.nSkillCount + nAdd;
end

function tbBaseCamp:ConsumSkillCount(nConsum)
	self.nSkillCount = self.nSkillCount - nConsum;
end