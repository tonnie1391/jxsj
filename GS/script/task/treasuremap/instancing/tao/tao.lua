
Require("\\script\\task\\treasuremap\\treasuremap.lua");

local tbInstancing = TreasureMap:GetInstancingBase(254);

tbInstancing.szName = "陶朱公疑冢";

-- 第一次打开副本时调用，这个时候里面肯定没有别的队伍
function tbInstancing:OnNew()
	local tbInfo = TreasureMap:GetTreasureInfo(self.nTreasureId);	
	assert(tbInfo.InstancingMapId == self.nMapTemplateId);
	
	local tbStele_1	= {{1616, 3111}, {1618, 3113}, {1620, 3115}};
	local tbStele_2	= {{1663, 3045}, {1665, 3047}, {1667, 3049}};

	
	self.tbStele_1_Idx	= {};
	self.tbStele_2_Idx	= {};
	
	for i=1, #tbStele_1 do
		local pNpc		= KNpc.Add2(2707, 1, -1, self.nTreasureMapId, tbStele_1[i][1], tbStele_1[i][2]);
		pNpc.szName		= " ";
		table.insert(self.tbStele_1_Idx, pNpc.dwId);
	end;
	
	for i=1, #tbStele_2 do
		local pNpc		= KNpc.Add2(2707, 1, -1, self.nTreasureMapId, tbStele_2[i][1], tbStele_2[i][2]);
		pNpc.szName		= " ";
		table.insert(self.tbStele_2_Idx, pNpc.dwId);
	end;
	
	-- 新增任务 NPC （石碑）
	KNpc.Add2(2730, 1, -1, self.nTreasureMapId, 1576, 3167);		
end

-- 队伍开启一个副本的时候调用，这个时候里面可能有别的队伍
function tbInstancing:OnOpen()

end

-- 副本的限制时间到的时候调用
function tbInstancing:OnDelete()

end
