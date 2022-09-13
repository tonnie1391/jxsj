-- 文件名  : room_file.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-21 14:32:34
-- 描述    : 战后系统 读取房间数据


if (MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\fightafter\\room_def.lua");

local RoomMgr = FightAfter.tbRoom;

function RoomMgr:Init()
	local tbFile = Lib:LoadTabFile(self.ROOM_FILEPATH);
	if not tbFile then
		print("[ERR] FightAfter LoadMapInfo Error", self.ROOM_FILEPATH);
		return;
	end
	
	local tbPoint = {};	
	for nId, tbParam in ipairs(tbFile) do
		local tbInfo  = {};

		tbInfo.nNpcX = math.floor((tonumber(tbParam.TRAPX))/32);
		tbInfo.nNpcY = math.floor((tonumber(tbParam.TRAPY))/32);

--		tbInfo.nTransferX = tbInfo.nNpcX - 1;
--		tbInfo.nTransferY = tbInfo.nNpcY - 1;		

		table.insert(tbPoint, tbInfo);
	end	
	
	self.nRoomNumPerMap = #tbPoint;
	self.nMapCount	    = 0;
	self.tbRoomList     = {};
--	self.tbMapList      = {};

	self.tbUseIdx   = {};
	self.tbFreeIdx  = {};
	self.tbRoomInfo = {};
	self.tbId2Index = {};
	
	for _, nMapId in ipairs(self.MAP_LIST) do
		if IsMapLoaded(nMapId) == 1 then
--			table.insert(self.tbMapList,nMapId);
			self.nMapCount = self.nMapCount + 1;
			for nIndex, tbInfo in ipairs(tbPoint) do
				self.tbRoomList[#self.tbRoomList + 1] = {};
				self.tbRoomList[#self.tbRoomList].tbPoint  = tbInfo; 
				self.tbRoomList[#self.tbRoomList].nCount   = 0;
				self.tbRoomList[#self.tbRoomList].nMapId   = nMapId;
				self.tbFreeIdx[#self.tbFreeIdx + 1] 	   = #self.tbRoomList; -- 一开始的话是空的
				self.tbId2Index[#self.tbRoomList]		   = 0;
				KNpc.Add2(self.DIALOG_NPC, 90, -1, nMapId, tbInfo.nNpcX, tbInfo.nNpcY,0,0,0,1);
			end	
		end		
	end	
		
end

ServerEvent:RegisterServerStartFunc(FightAfter.tbRoom.Init, FightAfter.tbRoom);