
-- ====================== 文件信息 ======================

-- 剑侠世界随机任务 - 绘制地图志头文件
-- Edited by peres
-- 2007/08/07 PM 06:30

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

MapMaker.tbMapPos = {};

-- 构造地图册的坐标表格
function MapMaker:OnInitFile()
	
	self.tbMapPos  = Lib:NewClass(Lib.readTabFile, "\\setting\\task\\mapmaker\\map_pos.txt");
	
	local nRow = self.tbMapPos:GetRow();
	local nMapId, nMapX, nMapY, nPosIndex = 0;
	local szText = "";
	
	self:_Debug("Start load map pos info!");
	
	for i=1, nRow do
		nMapId    = self.tbMapPos:GetCellInt("MapId", i);
		
		nPosIndex = self.tbMapPos:GetCellInt("PosIndex", i);
		nMapX     = self.tbMapPos:GetCellInt("Xpos", i);
		nMapY     = self.tbMapPos:GetCellInt("Ypos", i);
		szText    = self.tbMapPos:GetCell("Text", i);
		
		if (not self.tbMapPos[nMapId]) and (nMapId ~= -1) then
			self.tbMapPos[nMapId] = {}	
		end;
		
		table.insert(self.tbMapPos[nMapId], nPosIndex, {nMapX, nMapY, szText});
		
	end;
	
	self:_Debug("Loaded map pos info finish, got "..#self.tbMapPos.." maps info!");
	
end;

function MapMaker:_Debug(...)
	print ("[MapMaker]: ", unpack(arg));
end;
