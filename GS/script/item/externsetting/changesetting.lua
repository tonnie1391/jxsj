-- 装备，秘籍修为配置

Require("\\script\\item\\externsetting\\externsetting.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbChangeSetting = Item.tbExternSetting:GetClass("change");

tbChangeSetting.FILENAME						= "change.txt";

------------------------------------------------------------------------------------------
-- interface

function tbChangeSetting:Load(szPath)
	local bRet = 1;
	if (1 ~= self:LoadChange(szPath)) then
		bRet = 0;
	end
	return	bRet;
end

function tbChangeSetting:LoadChange(szDir)
	self.tbChange = {};
	self.tbItemToChangeId = {};
	local tbNumColName = {Id = 1};
	local tbFile = Lib:LoadTabFile(szDir..self.FILENAME, tbNumColName);
	if not tbFile then
		print("no File", szDir..self.FILENAME)
	end
	if tbFile then
		for _, tbItem in pairs(tbFile) do
			local nId = tbItem.Id;
			if not self.tbChange[nId] then
				self.tbChange[nId] = {};
			end
			for i = 1, Player.FACTION_NUM do
				local szColName = "Faction"..i;
				if tbItem[szColName] then
					local szGDPL = Lib:StrTrim(tbItem[szColName], '"');		
					if self.tbItemToChangeId[szGDPL] and self.tbItemToChangeId[szGDPL] ~= nId then
						print("[Error] "..szGDPL.." 装备change表重复出现在不同的ID中，请及时检查！！");
					end
					local tbGDPL = self:GDPLStrToTable(szGDPL);
					if #tbGDPL ~= 4 then
						print("[Error] "..szGDPL.." 装备change表转换出错", unpack(tbGDPL));
						tbGDPL = nil;		-- 防止装备切换出错导致数据异常，转换失败的不记录
					end
					self.tbItemToChangeId[szGDPL] = nId;
					self.tbChange[nId][i] = tbGDPL;
				end
			end
		end
	end
	return	1;
end

function tbChangeSetting:GDPLStrToTable(szGDPL)
	local nBegin = 1;
	local nFind = string.find(szGDPL, ",", nBegin);
	local tbGDPL = {}
	while nFind and nFind > 0 and nBegin < string.len(szGDPL) do
		table.insert(tbGDPL, tonumber(string.sub(szGDPL,nBegin,nFind - 1)))
		nBegin = nFind + 1;
		nFind = string.find(szGDPL, ",", nBegin);
	end
	table.insert(tbGDPL, tonumber(string.sub(szGDPL,nBegin)))
	return tbGDPL;
end

