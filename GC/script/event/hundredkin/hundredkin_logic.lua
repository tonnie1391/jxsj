
if not SpecialEvent.HundredKin then
	SpecialEvent.HundredKin = {};
end

local HundredKin = SpecialEvent.HundredKin;

local tbSort =
{
	__lt = function(tbA, tbB)
		if tbA.nKey == tbB.nKey then
			return tbA.nKey2 < tbB.nKey2
		end 
		return tbA.nKey > tbB.nKey;
	end
};

-- 排序，将家族信息读入table，实现即时排名
function HundredKin:SortKin()
	local itor = KKin.GetKinItor();
	if not itor then
		return 0;
	end
	self.nJour = 0;
	self.tbSortKin = {};
	self.tbKinInfo = {};
	local pKin = itor.GetCurKin()
	while pKin do
		local tbKin = {}
		tbKin.nKinId = itor.GetCurKinId()
		tbKin.nKey = pKin.GetHundredKinScore();
		tbKin.szName = pKin.GetName();
		if tbKin.nKey == 0 then			-- 没积分的家族暂时按nKinId排序
			tbKin.nKey2 = tbKin.nKinId;
		else
			tbKin.nKey2 = pKin.GetHundredKinJour();
			-- 获取最大的流水值
			if tbKin.nKey2 > self.nJour then
				self.nJour = tbKin.nKey2;
				
			end
		end
		setmetatable(tbKin, tbSort);
		table.insert(self.tbSortKin, tbKin)
		pKin = itor.NextKin();
	end
	table.sort(self.tbSortKin);
	for i = 1, #self.tbSortKin do
		local tbInfo = {}
		self.tbKinInfo[self.tbSortKin[i].nKinId] = tbInfo;
		tbInfo.nSort = i;
		tbInfo.nScore = self.tbSortKin[i].nKey;
		tbInfo.szName = self.tbSortKin[i].szName;
	end
end

function HundredKin:CheckKinSortTable()
	if not self.tbSortKin then
		self:SortKin();
	end
end

-- 更新单个家族排名（每次增加积分都要调用）
function HundredKin:UpdateHundredKin(nKinId)
	self:CheckKinSortTable();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	if self.tbKinInfo == nil then  
		return 0;
	end
	if self.tbKinInfo[nKinId] == nil then
		self:AddKin(nKinId)
	end
	self.tbKinInfo[nKinId].nScore = pKin.GetHundredKinScore()
	local i = self.tbKinInfo[nKinId].nSort - 1;
	while i > 0 do
		local nCompareKin = self.tbSortKin[i].nKinId
		if self.tbKinInfo[nKinId].nScore > self.tbKinInfo[nCompareKin].nScore then
			self.tbKinInfo[nKinId].nSort = i;
			self.tbKinInfo[nCompareKin].nSort = i + 1;
			self.tbSortKin[i].nKinId = nKinId;
			self.tbSortKin[i + 1].nKinId = nCompareKin;
			i = i - 1;
		else
			i = 0;
		end
	end
end

function HundredKin:AddKin(nKinId)
	if self.tbKinInfo[nKinId] then
		return 1;
	end
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		self.tbKinInfo[nKinId] = {}
		self.tbKinInfo[nKinId].szName = pKin.GetName();
		self.tbKinInfo[nKinId].nSort = #self.tbSortKin + 1;
		self.tbKinInfo[nKinId].nScore = pKin.GetHundredKinScore()
		self.tbSortKin[self.tbKinInfo[nKinId].nSort] = {}
		self.tbSortKin[self.tbKinInfo[nKinId].nSort].nKinId = nKinId;
	end
end

function HundredKin:GetKinSort(nKinId)
	self:CheckKinSortTable();
	if not self.tbKinInfo[nKinId] then
		self:AddKin(nKinId);
	end
	return self.tbKinInfo[nKinId].nSort, self.tbKinInfo[nKinId].nScore, self.tbKinInfo[nKinId].szName;
end

function HundredKin:GetTensKin()
	self:CheckKinSortTable();
	local tbTens = {};
	for i = 1, 10 do
		if self.tbSortKin and self.tbSortKin[i] then
			local info = {};
			local nSort, nScore, szName = self:GetKinSort(self.tbSortKin[i].nKinId);
			info.szName = szName;
			info.nScore = nScore;
			tbTens[i] = info;
		end
	end
	return tbTens;
end

