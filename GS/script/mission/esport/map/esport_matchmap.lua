--竞技赛(准备场)
--孙多良
--2008.12.25

-- 屏蔽地图
do return end

Require("\\script\\mission\\esport\\esport_def.lua");

local tbMap = Map:GetClass(Esport.DEF_MAP_TEMPLATE_ID);

-- 定义玩家进入事件
function tbMap:OnEnter()

end

-- 定义玩家离开事件
function tbMap:OnLeave()
	--不是离线退出,直接return
	local tbPlayerInfo = Esport.tbPlayerLists[me.nId]
	if not tbPlayerInfo then
		return 0;
	end
	
	if not Esport.tbMissionLists[tbPlayerInfo[1]] then
		return 0;
	end
	
	if not Esport.tbMissionLists[tbPlayerInfo[1]][tbPlayerInfo[3]] then
		return 0;
	end
	
	if Esport.tbMissionLists[tbPlayerInfo[1]][tbPlayerInfo[3]]:IsOpen() ~= 1 then
		return 0;
	end
	if Esport.tbMissionLists[tbPlayerInfo[1]][tbPlayerInfo[3]]:GetPlayerGroupId(me) >= 0 then
		Esport.tbMissionLists[tbPlayerInfo[1]][tbPlayerInfo[3]]:KickPlayer(me, "Logout");
	end
end
