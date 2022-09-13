-------------------------------------------------------
-- 文件名　：atlantis_map.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-09 11:44:11
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

-- map
local tbMap = Atlantis.Map or {};
Atlantis.Map = tbMap;

function tbMap:OnEnter2()
	if Atlantis:CheckCanEnter() ~= 1 and me.GetCamp() ~= 6 then
		me.NewWorld(unpack(Atlantis.MAP_CITY_POS));
		return 0;	
	end
	Atlantis:AddPlayer(me);
end

function tbMap:OnLeave(szParam)
	Atlantis:RemovePlayer(me);
end
-- end

-- trap
local tbTrap = Atlantis.Trap or {};
Atlantis.Trap = tbTrap;

function tbTrap:OnPlayer()
	if self.nMapX and self.nMapY and self.nFightState then
		if self.nFightState == 1 then
			Player:AddProtectedState(me, Atlantis.SUPER_TIME);
			me.SetTask(Atlantis.TASK_GID, Atlantis.TASK_PROTECT, 1);
			Atlantis:SendMessage(me, Atlantis.MSG_BOTTOM, "Bạn đã bước chân vào sa mạc rộng lớn.");
			Atlantis:SendMessage(me, Atlantis.MSG_CHANNEL, "Bạn đã bước chân vào sa mạc rộng lớn.");
		else
			if Atlantis:CheckHaveSuper(me.szName) == 1 then
				Atlantis:SendMessage(me, Atlantis.MSG_MIDDLE, "Thần khí sát khí quá nặng nề, không thể mang vào doanh trại!");
				return 0;
			end
			Atlantis:SendMessage(me, Atlantis.MSG_BOTTOM, "Đến doanh trại, vẫn còn rất an toàn!");
			me.SetTask(Atlantis.TASK_GID, Atlantis.TASK_PROTECT, 0);
			Atlantis:PlayerLostEquip(me);
		end
		me.NewWorld(me.nMapId, self.nMapX, self.nMapY);
		me.SetFightState(self.nFightState);
	end
end
-- end

function Atlantis:LinkMapTrap()
	local tbMap = Map:GetClass(self.MAP_ID);
	for szFunMap, _ in pairs(self.Map) do
		tbMap[szFunMap] = self.Map[szFunMap];
	end
	for szTrapName, tbInfo in pairs(self.MAP_TRAP_POS) do
		local tbTrap = tbMap:GetTrapClass(szTrapName);
		tbTrap.nMapX = tbInfo[1];
		tbTrap.nMapY = tbInfo[2];
		tbTrap.nFightState = tbInfo[3];
		for szFunTrap in pairs(self.Trap) do
			tbTrap[szFunTrap] = self.Trap[szFunTrap];
		end
	end
end

Atlantis:LinkMapTrap();
