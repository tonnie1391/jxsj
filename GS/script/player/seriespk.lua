--===================================================
-- 文件名　：seriespk.lua
-- 创建者　：sunduoliang
-- 创建时间：2012-06-21 15:15:15
-- 功能描述：pk连斩特效
--===================================================
if not MODULE_GAMESERVER then
	return 0;
end
local SeriesPk = seriespk or {};

SeriesPk.bOpen = 1; --开关
SeriesPk.TSK_GROUP = 2027;	
SeriesPk.TSK_COUNT = 243;	--连斩数量
SeriesPk.TSK_TIME  = 244;	--连斩时间

SeriesPk.DEF_SERIES_TIME  = 5 * 60;	--连斩最长时间

function SeriesPk:PlayerDeath(pKiller)
	local tbTemp = me.GetTempTable("SeriesPk") or {};
	if self.bOpen ~= 1 or tbTemp.nClose == 1 then
		return 0;
	end
	me.SetTask(self.TSK_GROUP, self.TSK_TIME, 0);
	me.SetTask(self.TSK_GROUP, self.TSK_COUNT, 0);
	if not pKiller then
		return 0;
	end
	local pPlayer = pKiller.GetPlayer();
	if pPlayer then
		if GetTime() - pPlayer.GetTask(self.TSK_GROUP, self.TSK_TIME) > self.DEF_SERIES_TIME then
			pPlayer.SetTask(self.TSK_GROUP, self.TSK_COUNT, 0);
		end
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_TIME, GetTime());
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_COUNT, pPlayer.GetTask(self.TSK_GROUP, self.TSK_COUNT) + 1);
		local nPkCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_COUNT);
		if nPkCount > 1 then
			pPlayer.ShowSeriesPk(1, nPkCount);
		end
	end
	return 0;
end

PlayerEvent:RegisterGlobal("OnDeath", SeriesPk.PlayerDeath, SeriesPk);
