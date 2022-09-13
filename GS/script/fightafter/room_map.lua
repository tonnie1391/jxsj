-- 文件名  : room_map.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-21 14:18:24
-- 描述    : 战后系统 房间地图

if (MODULE_GC_SERVER) then
	return 0;
end
Require("\\script\\fightafter\\room_def.lua");

local tbMap = {};
local RoomMgr = FightAfter.tbRoom;

-- 定义玩家进入事件
function tbMap:OnEnter()
	me.SetLogoutRV(1);	
	local nRoomId = me.GetTempTable("FightAfter").nRoomId;
	if not nRoomId then
		print("[ERR]RoomMap:OnEnter: valid player!");
		return;			
	end
	
	local tbRoom = RoomMgr.tbRoomList[nRoomId];
	if not tbRoom then
		print("[ERR]RoomMap:OnEnter: Room is not Exit!",nRoomId);
		return;
	end
	
	tbRoom.nCount = tbRoom.nCount + 1;
end

-- 定义玩家离开事件
function tbMap:OnLeave()	
	local nRoomId = me.GetTempTable("FightAfter").nRoomId;
	if not nRoomId then
		print("[ERR]RoomMap:OnLeave: valid player!");
		return;			
	end
	local tbRoom  =	RoomMgr.tbRoomList[nRoomId];
	if not tbRoom then
		print("[ERR]RoomMap:OnLeave: Room is not Exit!",nRoomId);
		return;	
	end
	
	tbRoom.nCount = tbRoom.nCount - 1;	
	--当房间没人的话则可以清空啦
	if tbRoom.nCount <= 0 then
		RoomMgr:SetRoomFree(nRoomId);
	end
	
	me.GetTempTable("FightAfter").nRoomId = 0;	
end
	
for _, nMapId in ipairs(RoomMgr.MAP_LIST) do
	local tbRoomMap = Map:GetClass(nMapId);
	for szFnc in pairs(tbMap) do
		tbRoomMap[szFnc] = tbMap[szFnc];
	end
end

