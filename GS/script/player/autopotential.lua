
-- 自动分配潜能点功能

-- 潜能表格
Player.tbFactionPotential	= {};

function Player:InitFactionPotential()
	local tbFactionPotential = self.tbFactionPotential;
	local tbData = Lib:LoadTabFile("\\setting\\player\\attrib_route.txt");
	for _, tbRow in ipairs(tbData) do
		local nFaction	= tonumber(tbRow.FACTION);
		local nRoute	= tonumber(tbRow.ROUTE);
		local tbFaction	= tbFactionPotential[nFaction];
		if (not tbFaction) then
			tbFaction = {};
			tbFactionPotential[nFaction] = tbFaction;
		end
		tbFaction[nRoute] =
		{
			tonumber(tbRow.POTENTIAL_STRENGTH),
			tonumber(tbRow.POTENTIAL_DEXTERITY),
			tonumber(tbRow.POTENTIAL_VITALITY),
			tonumber(tbRow.POTENTIAL_ENERGY),
		};
	end
end

function Player:AutoAssginPotential(nFactionId, nRouteId, nRemain)	-- 程序回调接口：自动潜能分配

	local tbAssign = self.tbFactionPotential[nFactionId][nRouteId];

	local nSum = 0;
	for i = 1, #tbAssign do
		nSum = nSum + tbAssign[i];
	end
	if (0 == nSum) then
		print("自动分配表每项的值不能全为0！");
		return;
	end
	
	local tbRet	= {};

	for i = 1, #tbAssign do
		tbRet[i] = math.floor(nRemain * (tbAssign[i] / nSum));
	end

	return tbRet;

end

function Player:ReAssignPotential()
	
	if me.GetTask(2,1) == 1 then
		return 0;
	end
	
	me.UnAssignPotential();
	local tbAssign = Player:AutoAssginPotential(me.nFaction, me.nRouteId, me.nRemainPotential);
	me.ApplyAssignPotential(unpack(tbAssign));
	return 1;
end

Player:InitFactionPotential();

if Player.nEventIdAutoAssignPotential ~= nil then
	PlayerEvent:UnRegisterGlobal("OnLevelUp", nEventIdAutoAssignPotential);
end
if MODULE_GAMESERVER then
Player.nEventIdAutoAssignPotential = PlayerEvent:RegisterGlobal("OnLevelUp", Player.ReAssignPotential, Player);
end
--?pl DoScript("\\script\\player\\autopotential.lua")