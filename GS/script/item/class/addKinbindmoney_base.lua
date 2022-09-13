----addKinbindmoney_base.lua
----作者：孙多良
----2012-14-08
----info：获得家族银锭



local tbBase = Item:GetClass("addKinbindmoney_base");

--数值
--类型（1.游龙密室产出）
function tbBase:OnUse()
	local nKinId, nMemberId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		me.Msg("您必须加入家族后，才可获得家族银锭！");
		return 0;
	end
	
	local nSalary = it.GetExtParam(1);
	local nYinding = me.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING);
	if nYinding +  nSalary > Kinsalary.MAX_YINDING then
		me.Msg("您的家族银锭将超出上限，请在银锭商店中消费后再来使用。");
		return 0;
	end
	
	me.SetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING, nYinding + nSalary);
	me.Msg(string.format("你获得了%s家族银锭", nSalary))
	
	local szLog = string.format("%s获得了%s家族银锭", me.szName, nSalary);
	Dbg:WriteLog("UseItem",  szLog);			
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	return 1;
end
