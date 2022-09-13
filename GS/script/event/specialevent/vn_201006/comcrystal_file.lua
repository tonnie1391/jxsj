-- 文件名　：comcrystal_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-05-14 09:16:32
-- 描  述  ：越南6月合成结晶

--VN--

SpecialEvent.tbComCrystal = SpecialEvent.tbComCrystal or {};
local tbComCrystal = SpecialEvent.tbComCrystal;

function tbComCrystal:Load()
	local szFileName = "\\setting\\event\\specialevent\\comcrystal.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nIdEx = tonumber(tbParam.nId) or 1;
			local nGenre  = tonumber(tbParam.Genre) or 0;
			local nDetailType = tonumber(tbParam.DetailType) or 0;
			local nParticularType = tonumber(tbParam.ParticularType) or 0;
			local nLevel = tonumber(tbParam.Level) or 0;
			local nNum = tonumber(tbParam.nNum) or 0;
			local nMoney = tonumber(tbParam.nMoney) or 0;
			local nBindMoney = tonumber(tbParam.BindMoney) or 0;
			local nBindCoin = tonumber(tbParam.BindCoin) or 0;
			local nExp  = tonumber(tbParam.Exp) or 0;
			local nComRate = tonumber(tbParam.ComRate) or 0;
			local nGenreEx  = tonumber(tbParam.GenreEx) or 0;
			local nDetailTypeEx = tonumber(tbParam.DetailTypeEx) or 0;
			local nParticularTypeEx = tonumber(tbParam.ParticularTypeEx) or 0;
			local nLevelEx = tonumber(tbParam.LevelEx) or 0;
			local nNumEx = tonumber(tbParam.nNumEx) or 0;
			local nRate = tonumber(tbParam.nRate) or 0
			if not self.tbAword then
				self.tbAword = {};
			end			
			if not self.tbAword[nIdEx] then
				self.tbAword[nIdEx] = {};
			end
			if not self.tbComRate then
				self.tbComRate = {};
			end
			self.tbComRate[nIdEx] = nComRate;
			table.insert(self.tbAword[nIdEx],{{nGenre, nDetailType, nParticularType, nLevel}, nNum, nMoney, nBindMoney, nBindCoin, nExp, {nGenreEx, nDetailTypeEx, nParticularTypeEx, nLevelEx}, nNumEx, nRate});
		end
	end	
end

if  not MODULE_GC_SERVER then
	SpecialEvent.tbComCrystal:Load();
end
