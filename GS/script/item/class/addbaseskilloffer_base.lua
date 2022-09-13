-- 文件名　：addbaseskilloffer_base.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-07-10 15:56:52
-- 功能    ：

local tbBase = Item:GetClass("AddBaseSkillOffer");

function tbBase:OnUse()
	local nValue =tonumber(it.GetExtParam(1));
	if nValue <= 0 then
		me.Msg("道具有问题。");
		return 0;
	end
	local nTotalValue = me.GetTask(Kin.TASK_GROUP, Kin.TASK_SKILLOFFER) + nValue;
	if nTotalValue >= 2000000000 then
		me.Msg("您的功勋值已经够多了，不能再获得了。");
		return 0;
	end
	me.SetTask(Kin.TASK_GROUP, Kin.TASK_SKILLOFFER, nTotalValue);
	me.Msg(string.format("您获得了<color=yellow>%d<color>家族功勋值。",nValue));
	return 1;
end
