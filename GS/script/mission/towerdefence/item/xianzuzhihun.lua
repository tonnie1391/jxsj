-- 文件名　：toweritem.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-10 16:42:59
-- 描  述  ：

local tbTower = Item:GetClass("xianzuzhihun");

function tbTower:OnUse()
	local nCurDay = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDay = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_DAY);
	if nTaskDay < nCurDay then
		me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_DAY, nCurDay);
		me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_COUNT, 0);
	end 
	
	local nTaskCount = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_COUNT);
	if nTaskCount >= 3 then
		me.Msg("每天只能使用<color=yellow>3个先祖之魂<color>换取3次额外机会，你今天换取的机会<color=yellow>已达3次<color>。")
		return 0;
	end
	local nTaskAllCount = me.GetTask(TowerDefence.TSK_GROUP,TowerDefence.TSK_NEWYEAR_LIGUAN_COUNT_ALL)
	if nTaskAllCount >= 10 then
		me.Msg("活动期间只能使用<color=yellow>10个先祖之魂<color>换取10次额外机会，你换取的机会<color=yellow>已达10次<color>。")
		return 0;
	end
	me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_COUNT, nTaskCount + 1);
	me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_EXCOUNT, me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_EXCOUNT) + 1);
	me.SetTask(TowerDefence.TSK_GROUP,TowerDefence.TSK_NEWYEAR_LIGUAN_COUNT_ALL, me.GetTask(TowerDefence.TSK_GROUP,TowerDefence.TSK_NEWYEAR_LIGUAN_COUNT_ALL) + 1);
	me.Msg("您获得了<color=yellow>1次<color>额外参赛资 ô.");
	return 1;
end

function tbTower:GetTip()
	local nTimes = me.GetTask(2118,13);
	local szColor = "green"
	if nTimes == 10 then
		szColor = "gray"
	end
	local szMsg = "活动期间你已经使用过的次数：<color="..szColor..">"..nTimes.."/10<color>";
	return szMsg;
end
