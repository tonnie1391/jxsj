-- 文件名  : taskexp_file.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-05 15:14:04
-- 描述    : 

Require("\\script\\task\\target\\taskexp_def.lua");

Task.TaskExp = Task.TaskExp or {};
local tbTaskExp = Task.TaskExp;
tbTaskExp.Exp_szFileName = "\\setting\\task\\target\\xindeshu.txt";
tbTaskExp.Item_szFileName = "\\setting\\task\\target\\item.txt";

function tbTaskExp:Load(szFileName)
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【经验发布系统】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nLevel = tonumber(tbParam.LEVEL) or 0;
			local nXiuLian_Need = tonumber(tbParam.EXP_EMPTY) or 0;
			local nXiuLian_Get = tonumber(tbParam.EXP_FULL) or 0;
			if not self.tbExp then
				self.tbExp = {};
			end	
			if nLevel > 0 then
				self.tbExp[nLevel] = {nXiuLian_Need, nXiuLian_Get};
			end
		end
	end
end

function tbTaskExp:LoadEx(szFileName)
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【经验发布系统】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nIndex = tonumber(tbParam.Index) or 0;
			local nGenre = tonumber(tbParam.Genre) or 0;
			local nDetailType = tonumber(tbParam.DetailType) or 0;
			local nParticularType = tonumber(tbParam.ParticularType) or 0;
			local nLevel = tonumber(tbParam.Level) or 0;
			local szName = tbParam.szName or "";
			local nPer = tonumber(tbParam.Per) or 100;
			local nPerEx = tonumber(tbParam.PerEx) or 5;
			local nGenreEx = tonumber(tbParam.GenreEx) or 0;
			local nDetailTypeEx = tonumber(tbParam.DetailTypeEx) or 0;
			local nParticularTypeEx = tonumber(tbParam.ParticularTypeEx) or 0;
			local nLevelEx = tonumber(tbParam.LevelEx) or 0;
			local szNameEx = tbParam.szNameEx or "";
			local nRate = tonumber(tbParam.Rate) or 0;
			local nCheckMaker = tonumber(tbParam.CheckMaker) or 0;
			local nBuy_Genre = tonumber(tbParam.Buy_Genre) or 0;
			local nBuy_DetailType = tonumber(tbParam.Buy_DetailType) or 0;
			local nBuy_ParticularType = tonumber(tbParam.Buy_ParticularType) or 0;
			local nBuy_Level = tonumber(tbParam.Buy_Level) or 0;
			local nCheckTask = tonumber(tbParam.CheckTask) or 0;
			local nTaskGroup = tonumber(tbParam.TaskGroup) or 0;
			local nTaskId = tonumber(tbParam.TaskId) or 0;
			local nMaxCount = tonumber(tbParam.MaxCount) or 0;
			if not self.tbItem then
				self.tbItem = {};
			end
			if nIndex > 0 and nGenre > 0 and nDetailType > 0 and nParticularType > 0 and nLevel > 0 then
				self.tbItem[nIndex] = {{nGenre, nDetailType, nParticularType, nLevel}, szName, nPer, nPerEx, {nGenreEx, nDetailTypeEx, nParticularTypeEx, nLevelEx}, szNameEx, nRate, nCheckMaker, {nBuy_Genre, nBuy_DetailType, nBuy_ParticularType, nBuy_Level}, {nCheckTask, nTaskGroup, nTaskId, nMaxCount}};
			end
		end
	end
end

if not MODULE_GC_SERVER then
	Task.TaskExp:Load(Task.TaskExp.Exp_szFileName);
end
Task.TaskExp:LoadEx(Task.TaskExp.Item_szFileName);