
Require("\\script\\event\\collectcard\\define.lua")
local CollectCard = SpecialEvent.CollectCard;

function CollectCard:LoadBaoXiang()
	self.BaoXiangFile = {};
	local tbFile = Lib:LoadTabFile(self.FILE_BAOXIANG);
	if not tbFile then
		return
	end
	for i = 2, #tbFile do
		local nTypeId =  tonumber(tbFile[i].Type_Id) or 0;
		if self.BaoXiangFile[nTypeId] == nil then
			self.BaoXiangFile[nTypeId]={};
			self.BaoXiangFile[nTypeId].FixItem = {};
			self.BaoXiangFile[nTypeId].RateItem = {};
			self.BaoXiangFile[nTypeId].MaxRate = 0;
		end
		local nGenre = tonumber(tbFile[i].Genre) or 0;
		local nDetailType = tonumber(tbFile[i].DetailType) or 0;
		local nParticularType = tonumber(tbFile[i].ParticularType) or 0;
		local nLevel = tonumber(tbFile[i].Level) or 0;
		local nMoney = tonumber(tbFile[i].Money) or 0;
		local nRate = tonumber(tbFile[i].Rate) or 0;
		--local nTimeLimit = tonumber(tbFile[i].TimeLimit) or 0;
		local tbTemp = 
		{
			nGenre = nGenre,
			nDetailType = nDetailType,
			nParticularType = nParticularType,
			nLevel = nLevel,
			nMoney = nMoney,
			nRate = nRate,
			--nTimeLimit = nTimeLimit,
		}
		if nRate == 0 then
			table.insert(self.BaoXiangFile[nTypeId].FixItem, tbTemp)
		else
			table.insert(self.BaoXiangFile[nTypeId].RateItem, tbTemp)
		end
		self.BaoXiangFile[nTypeId].MaxRate = self.BaoXiangFile[nTypeId].MaxRate + nRate;
	end
end

CollectCard:LoadBaoXiang();

