--王老吉降火卡
--孙多良
--2008.08.25

local tbItem = Item:GetClass("wanglaoji_jianghuoka")
function tbItem:OnUse()
	self:SureUse(it.dwId)
end

function tbItem:SureUse(nItemId, nFlag)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if nFlag ~= 1 then
		local szMsg = "是否确定使用王老吉降火卡？";
		local tbOpt = {
			{"我确定要使用", self.SureUse, self, nItemId, 1},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local WangLaoJi = SpecialEvent.WangLaoJi;
	if WangLaoJi:CheckEventTime(2) == 0 then
		if pItem.nCount <= 1 then
			if (me.DelItem(pItem,  Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1) then
				me.Msg("删除失败！");
				return 0;
			end
		else
			pItem.SetCount(pItem.nCount - 1); 
		end
		me.Msg("王老吉防上火活动已经结束，卡片已过期，谢谢参与，您获得100绑定银两。");
		me.AddBindMoney(100, Player.emKBINDMONEY_ADD_EVENT);
		return 0;
	end
	local nCount = pItem.nCount;
	if nCount <= 1 then
		if (me.DelItem(pItem, Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1) then
			me.Msg("删除失败！");
			return 0;
		end
	else
		pItem.SetCount(nCount - 1); 
	end
	local nWeek = WangLaoJi:GetTask(WangLaoJi.TASK_WEEK);
	
	--防止测试调时间导致错误
	if nWeek > KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) then
		WangLaoJi:SetTask(WangLaoJi.TASK_WEEK, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10));
	end
	
	if nWeek < KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) then
		for i = nWeek + 1 , KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) do
			if me.szName == KGblTask.SCGetDbTaskStr(WangLaoJi.KEEP_SORT[i]) then
				WangLaoJi:SetTask(WangLaoJi.TASK_GRAGE, 0);
				WangLaoJi:SetTask(WangLaoJi.TASK_WEEK, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10));
				me.Msg(string.format("\n<color=yellow>恭喜您获得了王老吉江湖防上火活动的第%s周的第一名！！！<color>", i));
				break;
			end
		end
		WangLaoJi:SetTask(WangLaoJi.TASK_WEEK, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10));
	end
	local nGrage = WangLaoJi:GetTask(WangLaoJi.TASK_GRAGE);
	WangLaoJi:SetTask(WangLaoJi.TASK_GRAGE, (nGrage + WangLaoJi.DEF_CARD_GRAGE));
	GCExcute({"SpecialEvent.WangLaoJi:DoSort", (nGrage+WangLaoJi.DEF_CARD_GRAGE), me.szName})	
	me.Msg("您成功使用了<color=yellow>王老吉降火卡<color>，获得了<color=yellow>10点<color>积分。");
end

