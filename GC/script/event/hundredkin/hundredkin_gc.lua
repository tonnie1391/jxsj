if not MODULE_GC_SERVER then
	return;
end

if not SpecialEvent.HundredKin then
	SpecialEvent.HundredKin = {};
end

local HundredKin = SpecialEvent.HundredKin;

function HundredKin:AddHundredKinScore_GC(nKinId, nPlayerId, nScore, nMyScore)
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0;
	end
	local nCurSroce = pKin.GetHundredKinScore();
	pKin.SetHundredKinScore(nCurSroce + nScore);
	self:UpdateHundredKin(nKinId);
	self.nJour = self.nJour + 1;
	pKin.SetHundredKinJour(self.nJour);
	GlobalExcute{"SpecialEvent.HundredKin:AddHundredKinScore_GS2", nKinId, nPlayerId, nCurSroce + nScore, nScore, self.nJour, nMyScore};
end

function HundredKin:SetHundredKinAward_GC(nKinId, nRet)
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0;
	end
	pKin.SetHundredKinAward(nRet);		-- 标记已经领过族长的奖励了
	GlobalExcute{"SpecialEvent.HundredKin:SetHundredKinAward_GS2", nKinId, nRet};
end


function HundredKin:SetHundredKinAwardCount_GC(nKinId, nRet)
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0;
	end
	pKin.SetHundredKinAwardCount(nRet);		-- 标记已经领过族长的奖励了
	GlobalExcute{"SpecialEvent.HundredKin:SetHundredKinAwardCount_GS2", nKinId, nRet};
end


function HundredKin:ClearKinData()
	if tonumber(GetLocalDate("%Y%m%d")) < self.CLEAR_DATE then
		local itor = KKin.GetKinItor();
		if not itor then
			return 0;
		end
		local pKin = itor.GetCurKin()
		while pKin do
			pKin.SetHundredKinJour(0);
			pKin.SetHundredKinScore(0);
			pKin.SetHundredKinAward(0);
			pKin.SetHundredKinAwardCount(0);
			pKin = itor.NextKin();
		end
	end
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.HundredKin.ClearKinData, SpecialEvent.HundredKin);
