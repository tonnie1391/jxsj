-------------------------------------------------------
-- 文件名　：keyimen_map.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-02-22 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\keyimen\\keyimen_def.lua");

-- map
local tbMap = Keyimen.Map or {};
Keyimen.Map = tbMap;

function tbMap:OnEnter2()
	Keyimen:AddPlayer(me);
end

function tbMap:OnLeave(szParam)
	Keyimen:RemovePlayer(me);
end
-- end

-- trap
local tbTrap = Keyimen.Trap or {};
Keyimen.Trap = tbTrap;

function tbTrap:OnPlayer()
	if self.nMapX and self.nMapY and self.nFightState then
		if self.nFightState == 1 then
			local nTime = GetTime() - me.GetTask(Keyimen.TASK_GID, Keyimen.TASK_REVTIME);
			if nTime < Keyimen.REV_TIME then
				Keyimen:SendMessage(me, Keyimen.MSG_BOTTOM, string.format("Đừng nóng vội, hãy chờ %s giây nữa để tiếp tục chiến đấu.", Keyimen.REV_TIME - nTime));
				return 0;
			end
			Player:AddProtectedState(me, Keyimen.SUPER_TIME);
		end
		me.NewWorld(me.nMapId, self.nMapX, self.nMapY);
		me.SetFightState(self.nFightState);
	end
end
-- end

-- trap limit
local tbTrapLimit = Keyimen.TrapLimit or {};
Keyimen.TrapLimit = tbTrapLimit;

function tbTrapLimit:OnPlayer()
	if self.nMapId and self.nMapX and self.nMapY and Keyimen:CheckPlayer(me) == 1 then
		me.NewWorld(self.nMapId, self.nMapX, self.nMapY);
	end
end
-- end

-- trap remove
local tbTrapRemove = Keyimen.TrapRemove or {};
Keyimen.TrapRemove = tbTrapRemove;

function tbTrapRemove:OnPlayer()
	if self.nMapId and self.nMapX and self.nMapY then
		me.SetLogoutRV(0);
		me.NewWorld(self.nMapId, self.nMapX, self.nMapY);
	end
end
-- end

-- link map trap
function Keyimen:LinkMapTrap()
	for nMapId, nCamp in pairs(self.MAP_LIST) do
		local tbMap = Map:GetClass(nMapId);
		for szFunMap, _ in pairs(self.Map) do
			tbMap[szFunMap] = self.Map[szFunMap];
		end
		for szTrapName, tbInfo in pairs(self.TRAP_LIST) do
			local tbTrap = tbMap:GetTrapClass(szTrapName);
			tbTrap.nMapX = tbInfo[1];
			tbTrap.nMapY = tbInfo[2];
			tbTrap.nFightState = tbInfo[3];
			for szFunTrap in pairs(self.Trap) do
				tbTrap[szFunTrap] = self.Trap[szFunTrap];
			end
		end
	end
	for nMapId, tbTmp in pairs(self.TRAP_LIMIT) do
		for _, tbInfo in pairs(tbTmp) do
			local tbMap = Map:GetClass(nMapId);
			local tbTrap = tbMap:GetTrapClass(tbInfo[1]);
			tbTrap.nMapId = tbInfo[2][1]
			tbTrap.nMapX = tbInfo[2][2];
			tbTrap.nMapY = tbInfo[2][3];
			for szFunTrap in pairs(self.TrapLimit) do
				tbTrap[szFunTrap] = self.TrapLimit[szFunTrap];
			end
		end
	end
	for nMapId, tbInfo in pairs(self.TRAP_REMOVE) do
		local tbMap = Map:GetClass(nMapId);
		local tbTrap = tbMap:GetTrapClass(tbInfo[1]);
		tbTrap.nMapId = tbInfo[2][1]
		tbTrap.nMapX = tbInfo[2][2];
		tbTrap.nMapY = tbInfo[2][3];
		for szFunTrap in pairs(self.TrapRemove) do
			tbTrap[szFunTrap] = self.TrapRemove[szFunTrap];
		end
	end
end

Keyimen:LinkMapTrap();
