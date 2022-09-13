------------------------------------------------------
-- 文件名　：potential.lua
-- 创建者　：zhaoyu
-- 创建时间：2009-12-11 17:19:40
-- 描  述  ：
------------------------------------------------------

Partner.tbVALUE_RANGE =
{
	[0] = function()
		return MathRandom(13, 15);
	end,
	[1] = function()
		return MathRandom(18, 20);
	end;
};

--按比例，给目标同伴加一个潜能点
function Partner:AddOnePotential(nIndex)
	--local pPlayerPartner = me.GetPartner();
	local pPartner = me.GetPartner(nIndex);
	if pPartner == nil then
		assert(false);
		return;
	end
	local nTId = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_PotentialTemp);
	local tbAttrib = {
		nStrength		= { nIndex = 0, nCurrent = pPartner.GetAttrib(0),	nTempRate = self.tbPotentialTemp[nTId].nStrength },
		nDexterity	= { nIndex = 1, nCurrent = pPartner.GetAttrib(1),	nTempRate = self.tbPotentialTemp[nTId].nDexterity },
		nVitality		= { nIndex = 2, nCurrent = pPartner.GetAttrib(2),		nTempRate = self.tbPotentialTemp[nTId].nVitality },
		nEnergy		= { nIndex = 3, nCurrent = pPartner.GetAttrib(3),		nTempRate = self.tbPotentialTemp[nTId].nEnergy },
	}; 
	local nMinRate = 100000;--足够大的数，求最小值
	local szAttribKey;
	for _k, _v in pairs(tbAttrib) do
		if _v.nTempRate ~= 0 then
			_v.nRate = _v.nCurrent / _v.nTempRate;
			if _v.nRate < nMinRate then
				nMinRate = _v.nRate;
				szAttribKey = _k;
			end
		end
	end
	local nAttribIndex = tbAttrib[szAttribKey].nIndex;
	local nAttrib = pPartner.GetAttrib(nAttribIndex);
	pPartner.SetAttrib(nAttribIndex, nAttrib + 1);
end

--按比例，给目标同伴加nValue个潜能点
function Partner:AddPotential(nIndex, nValue)
	--local pPlayerPartner = me.GetPartner();
	local pPartner = me.GetPartner(nIndex);
	if pPartner == nil then
		assert(false);
		return;
	end
	local nPotential = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_PotentialPoint);
	if nValue > nPotential then
		assert(false);
		return;
	end
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_PotentialPoint, nPotential - nValue);
	for i = 1, nValue do
		self:AddOnePotential(nIndex);	
	end
end

--无条件给同伴按模板加nValue潜能点，不考虑已有的加点，也不影响其他任何变量
function Partner:AddPotential_Pure(nIndex, nValue)
	local pPartner = me.GetPartner(nIndex);
	if pPartner == nil then
		assert(false);
		return;
	end
	local nTId = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_PotentialTemp);
	local nAmountRate = self.tbPotentialTemp[nTId].nStrength + self.tbPotentialTemp[nTId].nDexterity + self.tbPotentialTemp[nTId].nVitality + self.tbPotentialTemp[nTId].nEnergy;
	local tbAttrib = {
		nStrength		= { nIndex = 0, nRate = self.tbPotentialTemp[nTId].nStrength / nAmountRate },
		nDexterity	= { nIndex = 1, nRate = self.tbPotentialTemp[nTId].nDexterity / nAmountRate },
		nVitality		= { nIndex = 2, nRate = self.tbPotentialTemp[nTId].nVitality / nAmountRate },
		nEnergy		= { nIndex = 3, nRate = self.tbPotentialTemp[nTId].nEnergy / nAmountRate },
	}; 
	local nAddedValue = 0;
	for _k, _v in pairs(tbAttrib) do
		if _v.nRate ~= 0 then
			local nCurValue = math.ceil(_v.nRate * nValue);
			if nAddedValue + nCurValue > nValue then
				nCurValue = nValue - nAddedValue;
			end
			pPartner.SetAttrib(_v.nIndex, nCurValue);
			nAddedValue = nAddedValue + nCurValue;
		end
	end
end

--如果目标同伴剩余潜能点为0，则给目标随机增加总潜能点个数
function Partner:GeneratePotential(nIndex)
	--local pPlayerPartner = me.GetPartner();
	local pPartner = me.GetPartner(nIndex);
	if pPartner == nil or pPartner.GetValue(self.emKPARTNERATTRIBTYPE_PotentialPoint) ~= 0 then
		assert(false);
		return;
	end
	local nRandom = Random(2);
	local nPotential = self.tbVALUE_RANGE[nRandom]();
	pPartner.SetValue(self.emKPARTNERATTRIBTYPE_PotentialPoint, nPotential);
	return nPotential;
end

--对小数四舍五入
function Partner:Round(dValue)
	return math.floor(dValue + 0.5);
end

--升级时调用，加当前等级应该加的潜能点
function Partner:CaclulatePotential(nIndex)
	--local pPlayerPartner = me.GetPartner();
	local pPartner = me.GetPartner(nIndex);
	if pPartner == nil then
		assert(false);
		return;
	end
	local nLevel = pPartner.GetValue(2); -- ！！！2改成宏
	local nPotential = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_PotentialPoint);
	local nPotentialTempId = pPartner.GetValue(self.emKPARTNERATTRIBTYPE_PotentialTemp);
	if nLevel % 10 == 0 then
		self:AddPotential(nIndex, nPotential); --如果是10的整数级，就把剩余的点全加了
		self:GeneratePotential(nIndex); -- 重新生成下10级的潜能点总数
	elseif nLevel == 1 then
		local nInitPotential = MathRandom(self.POTENTIAL_MIN, self.POTENTIAL_MAX); --初始潜能点随机范围
		pPartner.SetValue(self.emKPARTNERATTRIBTYPE_PotentialPoint, nInitPotential);
		pPartner.SetAttrib(0, 0);
		pPartner.SetAttrib(1, 0);
		pPartner.SetAttrib(2, 0);
		pPartner.SetAttrib(3, 0);
		self:AddPotential(nIndex, nInitPotential);
		nPotential = self:GeneratePotential(nIndex); -- 生成下10级的潜能点总数
		self:AddPotential(nIndex, self:Round(nPotential / 10)); --加从0升到1级的潜能点
	else
		self:AddPotential(nIndex, self:Round(nPotential / (11 - (nLevel % 10))));
	end
end
