-------------------------------------------------------
-- 文件名　：wldh_battle_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-26 08:56:24
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbBattle = Wldh.Battle;

-- 常规赛
function tbBattle:RoundStart_GS(tbGroupIndex)			
	for i = 1, #tbGroupIndex do
		local szLeagueNameSong = self.tbLeagueName[tbGroupIndex[i][1]][1];
		local szLeagueNameJin = self.tbLeagueName[tbGroupIndex[i][2]][1];	
		self:OpenBattle(i, szLeagueNameSong, szLeagueNameJin);
	end
end

function tbBattle:DivideGroup_GS(tbGroupIndex)
	self.tbGroupIndex = tbGroupIndex;
end

function tbBattle:RoundEnd_GS(nBattleIndex, tbResult)
	GCExcute({"Wldh.Battle:RoundEnd_GC", nBattleIndex, tbResult});
end

-- 总决赛
function tbBattle:FinalStart_GS(tbGroupIndex, nStep)	
	for i = 1, #tbGroupIndex do
		local szLeagueNameSong = self.tbLeagueName[tbGroupIndex[i][1]][1];	
		local szLeagueNameJin = self.tbLeagueName[tbGroupIndex[i][2]][1];
		self:OpenBattle(i, szLeagueNameSong, szLeagueNameJin, nStep);
	end
end

function tbBattle:FinalGroup_GS(tbGroupIndex, tbFinalList, nStep)
	self.tbGroupIndex = tbGroupIndex;
	self:SyncDate(tbFinalList, nStep);
end

function tbBattle:FinalEnd_GS(nBattleIndex, tbResult, nStep)
	GCExcute({"Wldh.Battle:FinalEnd_GC", nBattleIndex, tbResult, nStep});
end

function tbBattle:SyncDate(tbFinalList, nStep)
	
	self.tbFinalList = tbFinalList;
	self:UpdateFinalHelp(nStep);
	
	local nTime = 15 * 60 * Env.GAME_FPS;
	for nPlayerId, _ in pairs(self.tbSyncList or {}) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Dialog:SyncCampaignDate(pPlayer, "wldh_battle", self.tbFinalList, nTime);
		end
	end
end