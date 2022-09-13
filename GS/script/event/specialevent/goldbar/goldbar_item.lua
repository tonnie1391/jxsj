--文件名  : goldbar_item.lua
--创建者  : jiazhenwei
--创建日期: 2010-06-07 15:54:19
--描 述 :金牌特权令

local tbItem = Item:GetClass("jinpaitequan");

function tbItem:OnUse()
	
	if me.CountFreeBagCell() < 1 then
		me.Msg( "请预留1格背包空间吧！");
		return 0;
	end
	
	--五级套  （一天）
	me.AddSkillState(880, 1, 1, 24 * 3600 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(385, 5, 1, 24 * 3600 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(386, 5, 1, 24 * 3600 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(387, 5, 1, 24 * 3600 * Env.GAME_FPS, 1, 0, 1);
	
	--无限传送符   （一天）
	local pItem = me.AddItem(18, 1, 195, 1);
	if pItem then
		pItem.SetTimeOut(0, GetTime() + 24*3600);
		pItem.Sync();
	end
	
	--双倍经验buff（一天）
	me.AddSkillState(890, 1, 1, 24 * 3600 * Env.GAME_FPS, 1, 0, 1);
	
	--log
	Dbg:WriteLog("GoldBar", me.szName, "[金牌网吧]使用金牌特权令获得五级buff套、无限传送符、双倍经验buff （一天）");
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[金牌网吧]使用金牌特权令获得五级buff套、无限传送符、双倍经验buff （一天）");
	return 1;
end
