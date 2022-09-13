-- 文件名  : room_gs.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-21 10:25:38
-- 描述    : 战后系统 房间管理 GS

if (MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\fightafter\\room_def.lua");

local RoomMgr = FightAfter.tbRoom;

function RoomMgr:ApplyFreeRoom()
	local nApplyRoomId = self:__GetFreeRoomId();

	-- 满了的话随机给一个
	if nApplyRoomId == 0 then
		local nRandom = MathRandom(#self.tbUseIdx);
		nApplyRoomId = self.tbUseIdx[nRandom];
	end
	
	return nApplyRoomId;
end

function RoomMgr:SetRoomFree(nRoomId)
	self:__SetFreeRoom(nRoomId);
	return 0;
end

function RoomMgr:NewWorld(pPlayer,nRoomId)
	local tbRoom = self.tbRoomList[nRoomId];
	if not tbRoom then
		print("[ERR], RoomMgr:NewWorld", nRoomId);
		return;
	end
	pPlayer.GetTempTable("FightAfter").nRoomId = nRoomId;	
	pPlayer.NewWorld(tbRoom.nMapId,tbRoom.tbPoint.nNpcX + 1, tbRoom.tbPoint.nNpcY - 1);
end

--申请空余房间
function RoomMgr:__GetFreeRoomId()	
	if #self.tbFreeIdx == 0 then
	--	print("[WRN]RoomMgr_GS: NO Free Room in GS!");
		return 0;
	end	
	
	local nApplyRoomId = self.tbFreeIdx[#self.tbFreeIdx];		
	self.tbUseIdx[#self.tbUseIdx + 1] = nApplyRoomId;	
	self.tbFreeIdx[#self.tbFreeIdx]   = nil;	
	self.tbId2Index[nApplyRoomId]     = #self.tbUseIdx;
	
	return nApplyRoomId;
end

--释放一个房间
function RoomMgr:__SetFreeRoom(nRoomId)	
	local tbRoom = self.tbRoomList[nRoomId];
	if not tbRoom then
		print("[ERR],  RoomMgr:__SetFreeRoom", nRoomId);
		return;
	end	
	
	self.tbFreeIdx[#self.tbFreeIdx + 1] = nRoomId;	
	local nIndex = self.tbId2Index[nRoomId];
	if not nIndex or nIndex == 0 then
		print("[ERR]RoomMgr_GS:__SetFreeRoom: Index Error!", nRoomId);
		return;	
	end
	
	self.tbUseIdx[nIndex] = self.tbUseIdx[#self.tbUseIdx];	
	self.tbUseIdx[#self.tbUseIdx] = nil;
	self.tbId2Index[nRoomId] = 0;    --FREE 之后要清0
end