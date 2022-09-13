-- 文件名　：fuben_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-7
-- 描  述  ：

function CFuben:LoadGameType()
	local tbFile = Lib:LoadTabFile("\\setting\\fuben\\comfubenType.txt");
	if not tbFile then
		print("读取文件错误，文件不存在comfubenType.txt");
		return;
	end
	self.FUBEN = {};
	self.FUBEN_EX = {};
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then	
			local nType  = tonumber(tbParam.nType) or 0;
			local szName  = tbParam.szName;
			local szTxtName = tbParam.szTxtName;
			local nCount = tonumber(tbParam.nCount) or 0;
			local nFlag = tonumber(tbParam.IsDaily) or 0;
			local nTime = tonumber(tbParam.nTime) or 0;
			if not self.FUBEN[szItemName] then
				self.FUBEN[nType] = {};	
				self.FUBEN[nType].szName = szName;
				self.FUBEN[nType].szTxtName = szTxtName;
				self.FUBEN[nType].nCount = nCount;
				self.FUBEN[nType].nFlag = nFlag;
				self.FUBEN[nType].nTime = nTime;
			end
		end
	end
	local szFilePath =  "\\setting\\fuben\\";
	for nType, tbFun in pairs(self.FUBEN) do	
		local szTxtName = szFilePath..tbFun.szTxtName;
		local tbFile = Lib:LoadTabFile(szTxtName);
		if not tbFile then
			print("读取文件错误，文件不存在",tbFun.szTxtName);
			return;
		end
		for nId, tbParam in ipairs(tbFile) do
			if nId >= 1 then
				local nIdEx  = tonumber(tbParam.nId) or 0;
				local nMapId  = tonumber(tbParam.MapId) or 0;
				local szName = tbParam.Name;
				local nMinNumber = tonumber(tbParam.MinNumber) or 0;
				local nMaxNumber = tonumber(tbParam.MaxNumber) or 0;
				local nGrade = tonumber(tbParam.Grade) or 0;
				local nTime = tonumber(tbParam.Time) or 0;
				local szFlowFile = tbParam.FlowFile;
				local szItemId = tbParam.ItemId;
				local nGroupModel = tonumber(tbParam.GroupModel) or 0;
				local nCount = tonumber(tbParam.Count) or 0;
				local nFlagAuto = tonumber(tbParam.AutoOpen) or 0;
				local FubenId = tonumber(tbParam.FubenId) or 0;
				local szConditionItemName = tbParam.ConditionItem;
				local szConditionMapType = tbParam.ConditionMapType;
				local nTotalTime = tonumber(tbParam.TotalTime) or 0;
				if not self.FUBEN[nType][nIdEx] then
					self.FUBEN[nType][nIdEx] = {};
					self.FUBEN[nType][nIdEx].nMapId = nMapId;
					self.FUBEN[nType][nIdEx].szName = szName;
					self.FUBEN[nType][nIdEx].nMinNumber = nMinNumber;
					self.FUBEN[nType][nIdEx].nMaxNumber = nMaxNumber;
					self.FUBEN[nType][nIdEx].nGrade = nGrade;
					self.FUBEN[nType][nIdEx].nTime = nTime;
					self.FUBEN[nType][nIdEx].szItemId = szItemId;
					self.FUBEN[nType][nIdEx].nGroupModel = nGroupModel;
					self.FUBEN[nType][nIdEx].nCount = nCount;
					self.FUBEN[nType][nIdEx].nFlagAuto = nFlagAuto;
					self.FUBEN[nType][nIdEx].nFubenId = FubenId;
					self.FUBEN[nType][nIdEx].szConditionItemName = szConditionItemName;
					self.FUBEN[nType][nIdEx].szConditionMapType = szConditionMapType;
					self.FUBEN[nType][nIdEx].nTotalTime = nTotalTime;
					if szItemId then
						self.FUBEN_EX[szItemId] = {nType,nIdEx};
					end
				end
			end
		end
	end
end

CFuben:LoadGameType();
