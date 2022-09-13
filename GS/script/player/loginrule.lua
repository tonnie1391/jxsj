Player.tbLoginRule = {};
local tbLoginRule = Player.tbLoginRule;

tbLoginRule.tbRule = 
{
	["GM"]				= 0,
	["VIP"]				= 0,
	["ChangeServer"]	= 2,
	["RMBPlayer"]		= 2,
	["Normal"]			= 100,
};

function tbLoginRule:IsVip(szAccount)
	return 0;
end

function tbLoginRule:IsGM(tbRole)
	if tbRole.nCamp == 6 then
		return 1;
	else
		return 0;
	end
end

function tbLoginRule:IsPay(tbRole)
	if tbRole.nPay > 0 then
		return 1;
	else
		return 0;
	end
end

function tbLoginRule:MakeSureType(tbType)
	local szType = "Normal";
	for _, _type in ipairs(tbType) do
		if (self.tbRule[_type] < self.tbRule[szType]) then
			szType = _type;
		end
	end
	return szType;
end

function tbLoginRule.AllowLogin(tbRole, nFreeCount, nChangeServer)
	local self = tbLoginRule;
	local tbType = {"Normal"};
	if nChangeServer == 1 then
		table.insert(tbType, "ChangeServer");
	end
	if self:IsVip(tbRole) == 1 then
		table.insert(tbType, "VIP");
	end
	if self:IsGM(tbRole) == 1 then
		table.insert(tbType, "GM");
	end
	if self:IsPay(tbRole) == 1 then
		table.insert(tbType, "RMBPlayer");
	end
	local szType = self:MakeSureType(tbType);
	if nFreeCount > self.tbRule[szType] then
		return 1;
	else
		return 0;
	end
end

function tbLoginRule:OnGSStart()
	local tbSvrCfg = Lib:LoadIniFile("servercfg.ini");
	local nPrecision = tonumber(tbSvrCfg["Overload"]["Precision"]);
	self.tbRule["Normal"] = nPrecision;
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(tbLoginRule.OnGSStart, tbLoginRule);
end
