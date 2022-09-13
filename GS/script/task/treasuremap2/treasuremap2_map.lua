-- 文件名  : treasuremap2_map.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-18 11:32:18
-- 描述    : 
Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua")

--local tbMap = Map:GetClass(TreasureMap2.MAP_TEMPLATE_ID);
local tbMap = {};
-- 定义玩家进入事件 没必要在这里
function tbMap:OnEnter()

end

-- 定义玩家离开事件
function tbMap:OnLeave()

--	local nCaptainId = me.GetTempTable("TreasureMap2").nCaptainId; -- 不能用这个 因为MISSIONcomplete的时候 这个已经没有用了
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);	
	if not tbInstancing then
		return;
	end	

	tbInstancing:KickPlayer(me);

end


for nTreasureId, tbData in pairs(TreasureMap2.TEMPLATE_LIST) do
	local tbMapTemplet = Map:GetClass(tbData.nTemplateMapId);
	for szFnc in pairs(tbMap) do
		tbMapTemplet[szFnc] = tbMap[szFnc];
	end
end
