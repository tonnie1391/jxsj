-- 文件名　：fuben_mission.lua
-- 创建者　：zounan
-- 创建时间：2009-12-17 09:43:45
-- 描  述  ：副本MISSION
Require("\\script\\mission\\lockmis_base.lua");



CFuben.FubenMission	= CFuben.FubenMission or Lib:NewClass(Mission.LockMis);
local BaseGame = CFuben.FubenMission;

-- 初始化 
function BaseGame:InitGameEx(nMapId, nPlayerId, nFubenId,tbDerivedRoom)
	self:InitGame(nMapId,tbDerivedRoom);
	self.nPlayerId = nPlayerId;
	self.nFubenId = nFubenId;
	self.tbMisCfg = 
	{
		nDeathPunish   = 1,
		nPkState       = Player.emKPK_STATE_PRACTISE,
--		nOnDeath 	   = 1,        -- 死亡脚本可用
--		nOnKillNpc 	   = 1,        -- NPC死亡函数		
		nFightState	   = 1,
		nForbidStall   = 1,        -- 禁止摆摊
	};		
	self.tbLockMisCfg = CFuben.tbLockMis[nFubenId].tbLockMisCfg;	
	self.tbMisCfg.nOnDeath = self.tbLockMisCfg.nOnDeath or 0;
end

--读取文件配置
--[[
function BaseGame:LoadMisFile(szPath)
--	local tbLockMisCfg = self:LoadMisFile(szPath);
--	self.tbLockMisCfg = tbLockMisCfg;	
--	self.tbLockMisCfg = CFuben.tbLockMisFile:LoadMisFile(szPath);
end
--]]

--回调
function BaseGame:OnLockMisJoin(nGroupId)
end

function BaseGame:OnLockMisLeave(nGroupId, szReason)
	local nMapId = CFuben.FubenData[self.nPlayerId][3];
	local nPosX = CFuben.FubenData[self.nPlayerId][6];
	local nPosY = CFuben.FubenData[self.nPlayerId][7];
	me.NewWorld(nMapId, nPosX, nPosY);
	CFuben:OnLeave(self.nPlayerId);
--	if self.nPlayerCount <= 0 and self.nIsGameOver ~= 1 then
--		self:GameLose();
--	end
end


--玩家死亡回调
function BaseGame:OnDeath(pKillerNpc) 
	--如果死亡无法进入，直接走这里流程
	if self.tbLockMisCfg.nDeathLeaveCanBack == 1 then
		self:RecordDeathLeavePlayer(me.nId);
		self:KickPlayer(me);
		return 1;
	end
	if not self.tbLockMisCfg.tbNpcPoint["playerbirth"] then
		print("NO BIRTH");
		return;
	end
	local nRandom = #self.tbLockMisCfg.tbNpcPoint["playerbirth"];
	local nX = self.tbLockMisCfg.tbNpcPoint["playerbirth"][nRandom][1];
	local nY = self.tbLockMisCfg.tbNpcPoint["playerbirth"][nRandom][2];	
	me.SetTmpDeathPos(self.nMapId, nX, nY);
	me.ReviveImmediately(0);
	me.SetFightState(1);
	--self:KickPlayer(me);
end

--记录死亡离开的玩家
function BaseGame:RecordDeathLeavePlayer(nId)
	local nTempMapId = CFuben.FubenData[self.nPlayerId][1];
	local nDynMapId = CFuben.FubenData[self.nPlayerId][2];
	CFuben.tbMapList[nTempMapId][nDynMapId].DeathPlayerList[nId] = 1;
end

function BaseGame:OnGameClose()	
	--掉副本关闭接口
	local nTempMapId = CFuben.FubenData[self.nPlayerId][1];
	CFuben:Close(nTempMapId, self.nMapId, self.nPlayerId);
end


 --pNpc.AddLifePObserver(90)
 --local tbNpc = Npc:GetClass("animal");
-- local tbNpc = Npc:GetClass("dataosha_baoming");
-- function tbNpc:OnLifePercentReduceHere(nPercent)
-- end

