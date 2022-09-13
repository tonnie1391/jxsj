-- GlobalServer Player Event


if not GLOBAL_AGENT then
	return 0;
end

function PlayerEvent:Gb_PlayerLogin(bExchange)
	me.ForbitTrade(1);
	if bExchange == 1 then
		return 0;
	end
	me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID, me.nExchangeMoney);
	me.CostBindMoney(me.GetBindMoney(), Player.emKBINDMONEY_COST_EVENT);
	-- 加个LOG~万一正服误进这个函数还能通过LOG处理被刷的绑银
	Dbg:WriteLog("Gb_PlayerLogin", "Exchange GlobalMoney", me.szName, me.nExchangeMoney);
	me.AddBindMoney(me.nExchangeMoney, 100);
	Transfer:PlayerLogin(me.nId);
	if me.szAccount == "trantan" then
		me.AddItem(18, 1, 16, 1)
	end
end

-- 注册跨区服登陆回调
PlayerEvent:RegisterGlobal("OnLogin", PlayerEvent.Gb_PlayerLogin, PlayerEvent);

function PlayerEvent:Gb_PlayerLogout(szReason)
	--if (szReason ~= "SwitchServer") then 
		local nValue = me.GetBindMoney();
		nValue = nValue + me.GetItemPriceInBags();	
		local nOrgValue = me.GetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID);
		local nDiffValue = nValue - nOrgValue;
		me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID, nValue);
		if nDiffValue ~= 0 then		-- 差异不为0则同步回正服
			Dbg:WriteLog("GlobalConsume", me.szName, nValue);
			GCExcute{"Player:Gb_DataSync_GC", me.szName, nDiffValue};
		end
	--end
	Transfer:PlayerLogout(me.nId);
end
PlayerEvent:RegisterGlobal("OnLogout", PlayerEvent.Gb_PlayerLogout, PlayerEvent);
