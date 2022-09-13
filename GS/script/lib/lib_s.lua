-------------------------------------------------------
-- 文件名　: lib_s.lua
-- 创建者　: zhangjinpin@kingsoft
-- 创建时间: 2012-06-12 15:27:30
-- 文件描述:
-------------------------------------------------------

-------------------------------------------------------
-- 脚本重载模块
-------------------------------------------------------
local tbSuperScript = Lib._SuperScript or {};
Lib._SuperScript = tbSuperScript;

tbSuperScript.MAX_DEPTH = 100;
tbSuperScript._ForbidFile = 
{
	["preload.lua"] = 1;
	["preload_client.lua"] = 1;
	["preload_gs.lua"] = 1;
	["preload_gc.lua"] = 1;
};

tbSuperScript._Sort = function(tbA, tbB)
	return tbA[1] < tbB[1];
end

function tbSuperScript:LoadScriptFile()
	self.tbDir = {};
	local tbFile = KFile.GetCurDirAllFile("\\script", ".lua");
	for _, szFullPath in pairs(tbFile or {}) do
		szFullPath = string.gsub(szFullPath, "/", "\\");
		szFullPath = string.gsub(szFullPath, "\r\n", "\n");
		local nFind = string.find(szFullPath, "\\script");
		local nDepth = 0;
		if nFind then
			local szPath = string.sub(szFullPath, nFind + 1, -1);
			local tbT = self.tbDir;
			while true do
				local nT = string.find(szPath, "\\");
				if not nT then
					table.insert(tbT, szPath);
					break;
				end
				local szT = string.sub(szPath, 1, nT - 1);
				if not tbT[szT] then
					tbT[szT] = {tbRoot = tbT, szName = szT};
				end
				tbT = tbT[szT];
				szPath = string.sub(szPath, nT + 1, -1);
				nDepth = nDepth + 1;
				if nDepth > self.MAX_DEPTH then
					break;
				end
			end
		end
	end
	me.Msg("目录文件列表更新完毕！");
end

function tbSuperScript:GetFullPath(tbDir)
	local szFullPath = tbDir.szName or "";
	local tbRoot = tbDir.tbRoot;
	if not tbRoot then
		return "\\";
	end
	while tbRoot do
		szFullPath = (tbRoot.szName or "") .. "\\" .. szFullPath;
		tbRoot = tbRoot.tbRoot;
	end
	return szFullPath;
end

function tbSuperScript:DoScriptDir()
	if not self.tbDir then
		self:LoadScriptFile();
	end
	local tbLastDir = me.GetTempTable("Lib").tbLastDir;
	if not tbLastDir then
		tbLastDir = self.tbDir;
	end
	me.CallClientScript({"UiManager:OpenWindow", "UI_SUPERSCRIPT"});
	self:DoSelectDir(tbLastDir);
end

function tbSuperScript:DoSelectDir(tbDir)
	local tbSortDir = {nCount = 0};
	local tbSortFile = {nCount = 0};
	local tbRecentFile = me.GetTempTable("Lib").tbRecentFile or {};
 	for varKey, varValue in pairs(tbDir) do
		if varKey ~= "tbRoot" and varKey ~= "szName" then
			if type(varValue) == "table" then
				tbSortDir.nCount = tbSortDir.nCount + 1;
				tbSortDir[tbSortDir.nCount] = varKey;
			else
				tbSortFile.nCount = tbSortFile.nCount + 1;
				local tbFile  = {};
				if self._ForbidFile[varValue] then
					tbFile = {varValue, 0};
				elseif tbRecentFile[varValue] then
					tbFile = {varValue, 2};
				else
					tbFile = {varValue, 1};
				end
				tbSortFile[tbSortFile.nCount] = tbFile;
			end
		end
	end;
	table.sort(tbSortDir);
	table.sort(tbSortFile, self._Sort);
	me.GetTempTable("Lib").tbLastDir = tbDir;
	me.CallClientScript({"Ui:ServerCall", "UI_SUPERSCRIPT", "OnRecvData", tbSortDir, tbSortFile});
end

function tbSuperScript:DoSubDir(szSubDir)
	local tbLastDir = me.GetTempTable("Lib").tbLastDir;
	if not tbLastDir then
		tbLastDir = self.tbDir;
	end
	if tbLastDir[szSubDir] then
		self:DoSelectDir(tbLastDir[szSubDir]);
	end
end

function tbSuperScript:DoParentDir()
	local tbLastDir = me.GetTempTable("Lib").tbLastDir;
	if not tbLastDir then
		return 0;
	end
	if tbLastDir.tbRoot then
		self:DoSelectDir(tbLastDir.tbRoot);
	end
end

function tbSuperScript:DoSelectFile(szFileName, nType)
	if self._ForbidFile[szFileName] then
		me.Msg("该文件禁止重载！");
		return 0;
	end
	local tbLastDir = me.GetTempTable("Lib").tbLastDir;
	if not tbLastDir then
		tbLastDir = self.tbDir;
	end
	local szFullPath = self:GetFullPath(tbLastDir);
	szFullPath = szFullPath .. "\\" .. szFileName;
	me.Msg(string.format("重新载入脚本文件<color=yellow>[%s]<color>", szFullPath));
	if nType == 1 then
		local nRet, szRet = self:DoScriptEx(szFullPath);	
		if not me.GetTempTable("Lib").tbRecentFile then
			me.GetTempTable("Lib").tbRecentFile = {};
		end
		local tbRecentFile = me.GetTempTable("Lib").tbRecentFile;
		if not tbRecentFile[szFileName] and nRet == 1 then
			tbRecentFile[szFileName] = 1;
		end
		me.CallClientScript({"Ui:ServerCall", "UI_SUPERSCRIPT", "OnUpdateFile", szFileName, nRet, szRet});
	elseif nType == 2 then
		GCExcute({"Lib._SuperScript:DoSelectFile_GC", me.nId, szFullPath, szFileName});
	end
end

function tbSuperScript:DoSelectFile_GC(nPlayerId, szFullPath, szFileName)
	local nRet, szRet = self:DoScriptEx(szFullPath);
	GlobalExcute({"Lib._SuperScript:DoSelectFile_GS", nPlayerId, szFileName, nRet, szRet});
end

function tbSuperScript:DoSelectFile_GS(nPlayerId, szFileName, nRet, szRet)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if not pPlayer.GetTempTable("Lib").tbRecentFile then
		pPlayer.GetTempTable("Lib").tbRecentFile = {};
	end
	local tbRecentFile = pPlayer.GetTempTable("Lib").tbRecentFile;
	if not tbRecentFile[szFileName] and nRet == 1 then
		tbRecentFile[szFileName] = 1;
	end
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_SUPERSCRIPT", "OnUpdateFile", szFileName, nRet, szRet});
end

function tbSuperScript:DoUpdateAllFile()
	local tbLastDir = me.GetTempTable("Lib").tbLastDir;
	if not tbLastDir then
		tbLastDir = self.tbDir;
	end
 	for varKey, varValue in pairs(tbLastDir) do
		if varKey ~= "tbRoot" and varKey ~= "szName" then
			if type(varValue) ~= "table" then
				self:DoSelectFile(varValue, 1);
			end
		end
	end
end

function tbSuperScript:DoScriptEx(szFullPath)
	local szFileData = KFile.ReadTxtFile(szFullPath);
	if not szFileData then
		return 0;
	end
	local function fnCall()
		return loadstring(szFileData, "@" .. szFullPath)();
	end
	local function fnShowStack(s)
		return debug.traceback(s, 2);
	end
	local tbRet	= {xpcall(fnCall, fnShowStack)};
	local nMax	= table.maxn(tbRet);
	local szRet = "";
	if nMax >= 2 then
		szRet = tostring(tbRet[2]);
		for i = 3, nMax do
			szRet = szRet .. "\t" .. tostring(tbRet[i]);
		end
	end
	return (tbRet[1] and 1) or 0, szRet;
end

-------------------------------------------------------
-- 通用奖励计算模块
-------------------------------------------------------
local tbCalcAward = Lib._CalcAward or {};
Lib._CalcAward = tbCalcAward;

tbCalcAward.AWARD_GRADE		= 4;					-- 奖励档次
tbCalcAward.AWARD_STEP 		= 3;					-- 奖励几率衰减倍数
tbCalcAward.AWARD_MULTI 	= 2;					-- 奖励数值递进倍数
tbCalcAward.AWARD_EXCEPT	= 3000000;				-- 单次奖励期望
tbCalcAward.AWARD_REDUCE	= 1;					-- 开服衰减率

tbCalcAward.AWARD_RATE		= {8, 2, 2};
tbCalcAward.AWARD_TYPE		=
{
	["玄晶"] = {1, 1},
	["绑银"] = {2, 2},
	["绑金"] = {3, 0.01},
};

tbCalcAward.XUANJING_VALUE 	=
{
	[1] = 100,
	[2] = 360,
	[3] = 1296,
	[4] = 4665,
	[5] = 16796,
	[6] = 60466,
	[7] = 217678,
	[8] = 783641,
	[9] = 2821109,
	[10] = 10155995,
	[11] = 36565762,
	[12] = 131636744,
}

function tbCalcAward:FindGrade(nExcept)
	if nExcept < self.XUANJING_VALUE[1] or nExcept >= self.XUANJING_VALUE[12] then
		return 0;
	end
	for i, nValue in ipairs(self.XUANJING_VALUE) do
		if nExcept < nValue then
			return i - 1;
		end
	end
end

function tbCalcAward:RandomAward(nGrade, nStep, nMulti, nExcept, nReduce, tbRate)
	
	local nGrade = nGrade or self.AWARD_GRADE;
	local nStep = nStep or self.nAwardStep;
	local nMulti = nMulti or self.AWARD_MULTI;
	local nReduce = nReduce or self.AWARD_REDUCE;
	local nExcept = nExcept or self.AWARD_EXCEPT;
	local tbRate = tbRate or self.AWARD_RATE;
	
	local tbX = {}
	local nTx = 0;
	for i = 1, nGrade do
		tbX[nGrade - i + 1] = tbX[nGrade - i + 2] and tbX[nGrade - i + 2] * nStep or 1;
		nTx = nTx + tbX[nGrade - i + 1];
	end
	
	local nBaseT1 = tbX[1] / nTx;
	local nDeno = 0;
	for i = 1, nGrade do 
		nDeno = nDeno +  nStep ^ (nGrade - i) * nMulti ^ (i - 1);
	end
	local nBaseT2 = nStep ^ (nGrade - 1) / (nBaseT1 * nDeno);
	
	local tbT = {};
	for i = 1, nGrade do
		tbT[i] = {};
		tbT[i][1] = nBaseT1 / (nStep ^ (i - 1));
		tbT[i][2] = nBaseT2 * (nMulti ^ (i - 1))
		tbT[i][3] = nExcept * tbT[i][2];
	end
	
	local tbA = {};
	for szType, tbInfo in pairs(self.AWARD_TYPE) do
		if not tbA[szType] then
			tbA[szType] = {};
		end
		for i = 1, nGrade do
			local nExcept = tbT[i][3] * nReduce;
			if szType == "玄晶" then
				local nLvl = self:FindGrade(nExcept);
				if nLvl > 0 then
					local nRate = (self.XUANJING_VALUE[nLvl + 1] - nExcept) / (self.XUANJING_VALUE[nLvl + 1] - self.XUANJING_VALUE[nLvl]);
					tbA[szType][nLvl] = (tbA[szType][nLvl] or 0) + nRate * tbT[i][1];
					tbA[szType][nLvl + 1] = (tbA[szType][nLvl + 1] or 0) + (1 - nRate) * tbT[i][1];
				end
			else
				tbA[szType][i] = tbT[i][1];
			end
		end
	end
	
	local tbR = {};
	local nR = 0;
	for i, nV in ipairs(tbRate) do
		nR = nR + nV;
	end
	for i, nV in ipairs(tbRate) do
		tbR[i] = nV / nR;
	end

	local tbAwardList = {};
	for szType, tbInfo in pairs(tbA) do
		if not tbAwardList[szType] then
			tbAwardList[szType] = {};
		end
		for j, nRate in pairs(tbInfo) do
			local nRateX = nRate * tbR[self.AWARD_TYPE[szType][1]];
			if nRateX > 0 then
				if szType == "玄晶" then
					table.insert(tbAwardList[szType], {j, nRateX, self.XUANJING_VALUE[j]});
				else
					local nExcept = tbT[j][3] * nReduce;
					table.insert(tbAwardList[szType], {nExcept * self.AWARD_TYPE[szType][2], nRateX, nExcept});
				end
			end
		end	
		table.sort(tbAwardList[szType], function(a, b) return a[1] < b[1] end);
	end
	
	local tbRet = {};
	for szType, tbInfo in pairs(tbAwardList) do
		for i, tbData in ipairs(tbInfo) do
			table.insert(tbRet, {szType, tbData[1], math.floor(tbData[2] * 1000000), tbData[2], tbData[3]});
		end
	end
	
	return tbRet;
end

function tbCalcAward:GetMaxMoney(tbAward)
	local nMaxValue = 0;
	for _, tbInfo in ipairs(tbAward) do
		if tbInfo[1] == "绑银" and nMaxValue < tbInfo[2] then
			nMaxValue = tbInfo[2];
		end
	end
	return nMaxValue;
end

function tbCalcAward:_T()
	local szPath = "\\output.txt";
	KFile.WriteFile(szPath, "");
	local tbExcept = {};
	local tbDay = {1, 30, 60, 90, 120, 150, 180, 210, 240};
	for _, nDay in ipairs(tbDay) do
		table.insert(tbExcept, {40000, {10, 0, 0}, 3, 4, 2, nDay});
	end
	for i, tbInfo in ipairs(tbExcept) do
		KFile.AppendFile(szPath, string.format("天数：%s\t期望：%s\n", tbInfo[6], tbInfo[1] * Lib:_GetXuanReduce(tbInfo[6])));
		local tbRet = self:RandomAward(tbInfo[3], tbInfo[4], tbInfo[5], tbInfo[1], Lib:_GetXuanReduce(tbInfo[6]), tbInfo[2]);
		local szMsg = "type\tvalue\tweight\trate\texcept\n";
		local nSum = 0;
		for i, tbInfo in ipairs(tbRet) do
			szMsg = string.format("%s%s\t%s\t%s\t%s\t%s\n", szMsg, tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4], tbInfo[5]);
			nSum = nSum + tbInfo[4] * tbInfo[5];
		end
		szMsg = string.format("%s\t\t\t\t%s\n\n", szMsg, nSum);
		KFile.AppendFile(szPath, szMsg);
	end
end

function Lib:_GetXuanPrice(nX)
	
	local tbT = 
	{
		{1, 1165},
		{27 ,905},
		{41 ,822},
		{48 ,761},
		{62 ,669},
		{76 ,630},
		{90 ,602},
		{104,545},
		{125,519},
		{132,490},
		{139,484},
		{146,475},
		{167,253},
		{174,236},
		{181,220},
		{196,196},
		{203,157},
		{210,130},
		{231,113},
		{273,102},
		{314,97 },
		{328,86 },
		{396,74 },
	};
 	
 	if nX <= tbT[1][1] then
 		return tbT[1][2];
 	end
 	
 	if nX >= tbT[#tbT][1] then
 		return tbT[#tbT][2];
 	end 
 	 
 	local nL = 0;
 	for i, tbInfo in ipairs(tbT) do
 		if nX < tbInfo[1] then
 			nL = i - 1;
 			break;
 		end
 	end
 	
 	local nY = tbT[nL][2] + (tbT[nL + 1][2] - tbT[nL][2]) * (nX - tbT[nL][1]) / (tbT[nL + 1][1] - tbT[nL][1]);
 	return nY;
end

function Lib:_GetXuanReduce(nX)
	return 1 - (1 - self:_GetXuanPrice(400) / self:_GetXuanPrice(nX)) / 1.5;
end

function Lib:_GetXuanEnlarge(nX)
	return 1 + (self:_GetXuanReduce(nX) - self:_GetXuanReduce(1)) / self:_GetXuanReduce(1);
end

function Lib:_L()
	local szPath = "\\output.txt";
	KFile.WriteFile(szPath, "");
	local szMsg = "day\tprice\n";
	for i = 1, 400 do
		szMsg = string.format("%s%s\t%s\n", szMsg, i, math.floor(self:_GetXuanPrice(i)));
	end
	KFile.AppendFile(szPath, szMsg);
end

---------------------------------------------------------------------------------------------
--通用价值量根据服务器换算为绑金绑银玄晶
--价值量根据726,363,311分为三个区间
--换算出来的绑金：价值量*0.8和价值量*1.2
--换算出来的绑银：价值量*0.8/100和价值量*1.2/100
--换算出来的玄晶：价值量在玄晶的区间上下两个玄晶
--提供概率值为：1/6, 1/6, 1/6, 1/6, 1/6*(1-总价值量)/（玄晶1价值量-玄晶2价值量）, 1/6*(1 - (1-总价值量)/（玄晶1价值量-玄晶2价值量）)
---------------------------------------------------------------------------------------------
tbCalcAward.tbFrameDay = {{212212, 363},{201203, 363},{202010,311}};

function tbCalcAward:CaleBindValue(nValueTotal)
	if nValueTotal <= 0 then
		return;
	end
	local nBack = 0;
	local nOpenDay = tonumber(os.date("%Y%m", tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))));
	for _, tb in ipairs(self.tbFrameDay) do
		if nOpenDay < tb[1] then
			nBack = tb[2];
			break;
		end
	end
	local nMaxValue = math.floor(nBack / 363 * nValueTotal);
	local nBindMoney1 = math.floor(nMaxValue * 0.8 / 100) * 100;
	local nBindMoney2 = math.floor(nMaxValue * 1.2 / 100) * 100;
	local nBindCoin1 = math.floor(nMaxValue * 0.75 / 1000) * 10;
	local nBindCoin2 = math.floor(nMaxValue * 1.25 / 1000) * 10;
	local nXuanJing = 0;
	local n = math.floor(10000 * 1/6);
	local tbRandom = {n, n, n, n, n, n}
	-- print(nBack)

	for i, nValue in ipairs(self.XUANJING_VALUE) do
		if nMaxValue >= nValue and nMaxValue < self.XUANJING_VALUE[i + 1] then
			local nRate = math.floor((self.XUANJING_VALUE[i + 1] - nMaxValue) / (self.XUANJING_VALUE[i + 1] - self.XUANJING_VALUE[i]) * 100);
			table.insert(tbRandom, math.floor(100 * 1/3 * nRate));
			table.insert(tbRandom, math.floor(100 * 1/3 * (100 - nRate)));
			nXuanJing = i;
			-- print(nMaxValue)
			break;
		end
	end
	local tbAward = {
			{["szType"] = "bindmoney", 	["varValue"] = nBindMoney1, 					["nRate"] = tbRandom[1]},
			{["szType"] = "bindmoney", 	["varValue"] = nBindMoney2, 					["nRate"] = tbRandom[2]},
			{["szType"] = "bindcoin", 	["varValue"] = nBindCoin1, 						["nRate"] = tbRandom[3]},
			{["szType"] = "bindcoin", 	["varValue"] = nBindCoin2, 						["nRate"] = tbRandom[4]},
			{["szType"] = "item", 		["varValue"] = {18,1,114,nXuanJing,1,1}, 		["nRate"] = tbRandom[5]},
			{["szType"] = "item", 		["varValue"] = {18,1,114,nXuanJing + 1,1,1}, 	["nRate"] = tbRandom[6]},
		}
	return tbAward;
end

