-- 文件名　：battle.lua
-- 创建者　：LQY
-- 创建时间：2012-07-19 13:45:58
-- 说　　明：战场地图

Require("\\script\\mission\\newbattle\\newbattle_def.lua");
local tbBattleMap = NewBattle.BattleMap or {}
NewBattle.BattleMap = tbBattleMap

function tbBattleMap:OnEnter2(szParam)
	if not NewBattle.Mission or NewBattle.Mission:IsOpen()==0 then 
		--Mission没开传出去！
		NewBattle:MovePlayerOut(me);
		return; 
	end;
	local i,tbPlayer = NewBattle:FindPlayer(me.nId);
	if i == 0 then 
		--传出去！
		NewBattle:MovePlayerOut(me);
		return;
	end
	--
	--DEBUG BEGIN
	if NewBattle.__DEBUG then
	 	me.Msg("进入MISSION")
	end
	--
	--DEBUG END	
	
	NewBattle.Mission:JoinPlayer(me, tbPlayer.nPower);
end

function tbBattleMap:OnLeave(szParam)
	me.SetTask(NewBattle.TK_PLAYERCARRIERSKILLS_TASKGROUP, NewBattle.TK_PLAYERISINNEWBATTLE, 0);
	me.Msg("Đã rời khỏi chiến trường!");
	if not NewBattle.Mission or NewBattle.Mission:IsOpen() == 0 then 
		return;
	end
	NewBattle:PlayerLeave(me);
	NewBattle.Mission:KickPlayer(me);
end

local tbTrap = NewBattle.Trap or {};
NewBattle.Trap = tbTrap;

function tbTrap:OnPlayer()
	local nPower = self.nPower;
	if self.szType == "CHUKOU" then
		if 	NewBattle.nBattle_State ~= NewBattle.BATTLE_STATES.FIGHT and NewBattle.nBattle_State ~= NewBattle.BATTLE_STATES.FINISH then
			me.NewWorld(NewBattle.Mission.nMapId, unpack(NewBattle:GetRandomPoint(NewBattle.POS_BRON[NewBattle.POWER_ENAME[nPower]])));
			NewBattle:SendMsg2Player(me,"Thời gian chưa đến, không thể rời khỏi Đại Doanh",NewBattle.SYSTEMBLACK_MSG);
		end
		return;
	end	
	if self.szType == "CHUANSONG" then
		local nPower = NewBattle.Mission:GetPlayerGroupId(me);
		local szPoint = "";
		local nFight  = 0;
		if self.szParm == "dh" then
			szPoint = "POS_READY";
			nFight = 0;
		elseif self.szParm == "hd" then
			szPoint = "POS_BRON";
			nFight = 1;
		end
		if nPower == self.nPower then
			if me.IsInCarrier() == 1 then
				me.Msg("前方道路狭窄，战车无法通行。请先下车！");
			else
				me.SetFightState(nFight);
				Player:AddProtectedState(me, NewBattle.PLAYERPROTECTEDTIME);
				me.NewWorld(NewBattle.Mission.nMapId, unpack(NewBattle:GetRandomPoint(NewBattle[szPoint][NewBattle.POWER_ENAME[nPower]])));
			end
		else
			me.Msg("前方枪林弹雨，不能通行。");
		end
		return;
	end
end

--link Map和Trap点
function NewBattle:LinkMapTrap()
	local tbTraps = 
	{
		["daying3_yewai1"] 		= {"CHUKOU", 2},
		["daying3_yewai2"] 		= {"CHUKOU", 2},
		["daying1_yewai1"]  	= {"CHUKOU", 1},
		["daying1_yewai2"]  	= {"CHUKOU", 1},	
		["daying1_houying1_1"]	= {"CHUANSONG", 1 ,"dh"},	
		["daying1_houying1_2"]	= {"CHUANSONG", 1 ,"dh"},	
		["daying3_houying3_1"]	= {"CHUANSONG", 2 ,"dh"},	
		["daying3_houying3_2"]	= {"CHUANSONG", 2 ,"dh"},	
		["houying1_daying1"]	= {"CHUANSONG", 1 ,"hd"},	
		["houying3_daying3"]	= {"CHUANSONG", 2 ,"hd"},	
	};
	
	for _, tbMapId in pairs(self.TB_MAP_BATTLE) do
		for _, nMapId in pairs(tbMapId) do
			local tbMap = Map:GetClass(nMapId);
			for szFunMap, _ in pairs(self.BattleMap) do
				tbMap[szFunMap] = self.BattleMap[szFunMap];
			end
			for szTrapName, tbData in pairs(tbTraps) do
				local tbTrap = tbMap:GetTrapClass(szTrapName);
				for szFunTrap in pairs(self.Trap) do
					tbTrap[szFunTrap] = self.Trap[szFunTrap];
				end
				tbTrap.nPower = tbData[2];
				tbTrap.szType = tbData[1];
				tbTrap.szParm = tbData[3];
			end
		end
	end
end
NewBattle:LinkMapTrap();