-------------------------------------------------------
-- 文件名　: newland_item_atom.lua
-- 创建者　: zhangjinpin@kingsoft
-- 创建时间: 2010-10-15 14:22:37
-- 文件描述:
-------------------------------------------------------

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbItem = Item:GetClass("newland_item_totung");

function tbItem:OnUse()
	
	-- global only
	if Newland:CheckIsOpen() ~= 1 or Newland:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- period and state
	if Newland:GetPeriod() ~= Newland.PERIOD_WAR_OPEN then
		return 0;
	end
	
	if Newland:GetWarState() ~= Newland.WAR_START then
		return 0;
	end
	
	-- fight state
	if me.nFightState ~= 1 then
		return 0;
	end
	
	local nGroupIndex = Newland:GetPlayerGroupIndex(me);
	if nGroupIndex <= 0 then
		return 0;
	end
	
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	local nMapLevel = Newland:GetMapLevel(nMapId);
	if nMapLevel <= 0 then
		return 0;
	end
	
	local nNpcId = it.GetExtParam(1);
	local pNpc = KNpc.Add2(nNpcId, 120, -1, nMapId, nMapX, nMapY);
	if pNpc then
		pNpc.SetVirtualRelation(Player.emKPK_STATE_EXTENSION, nGroupIndex);
		pNpc.SetCurCamp(me.GetCurCamp());
		Newland:OnCallAtom(pNpc, nGroupIndex, nMapId, me);
		return 1;
	end
	
	return 0;
end
