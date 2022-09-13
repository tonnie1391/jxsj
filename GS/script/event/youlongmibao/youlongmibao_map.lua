
Require("\\script\\event\\youlongmibao\\youlongmibao_mapmgr.lua");

local tbMap = Youlongmibao.tbMap or {};
Youlongmibao.tbMap = tbMap;

function tbMap:OnEnter()
	me.SetLogoutRV(1);
	me.SetFightState(1);
	Youlongmibao.Manager:AddDialogNpc(me);
end

-- 定义玩家离开事件
function tbMap:OnLeave()
	me.SetFightState(0);
	me.SetLogOutState(0);
	Youlongmibao.Manager:DelNpc(me);
	Youlongmibao.Manager:LeavePlayer(me);
	Youlongmibao.Manager:CloseSingleUi(me);
end

function Youlongmibao.Manager:LoadOneMapFun(nMapId)
	local tbBattleMap = Map:GetClass(nMapId);
	if (not tbBattleMap) then
		return;
	end
	for szFnc in pairs(Youlongmibao.tbMap) do
		tbBattleMap[szFnc] = Youlongmibao.tbMap[szFnc];
	end	
end

function Youlongmibao.Manager:LoadMapTable()
	Youlongmibao.Manager:LoadMapInfo();
	if (not self.tbRoomMgr) then
		return 0;
	end
	
	if (not self.tbRoomMgr.tbMapMgr) then
		return 0;
	end
	for nMapId, tbInfo in pairs(self.tbRoomMgr.tbMapMgr) do
		self:LoadOneMapFun(nMapId);
	end
end

Youlongmibao.Manager:LoadMapTable();
