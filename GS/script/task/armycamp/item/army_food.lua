--食物
--孙多良
--2008.08.04

local tbItem = Item:GetClass("army_food")
tbItem.CONSUME_TIME = 60; --耗时5分钟
tbItem.PERIOD_TIME = 5; --每5秒一跳
tbItem.tbFood = 
{--等级 = 经验
	[1] = 300000,
	[2] = 600000,
}

function tbItem:OnUse()
	local nExp = it.GetGenInfo(1) or 0;
	local nAddExp = self.tbFood[it.nLevel];
	me.AddExp(nAddExp - nExp);
	do return 1 end;
	
	local tbTemp = it.GetTempTable("army_food");
	if not tbTemp.nTimerId then
		tbTemp.nTimerId  = 0;
	end
	if tbTemp.nTimerId > 0 then
		return 0;
	end
	local nExp = it.GetGenInfo(1);
	if not nExp then
		it.SetGenInfo(1, 0);
	end
	local nTimerId = Timer:Register(self.PERIOD_TIME * Env.GAME_FPS, self.OnNpcTimer, self, me.nId, it.dwId);
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	local nTime = math.ceil(((self.tbFood[it.nLevel] - nExp) /  math.ceil((self.tbFood[it.nLevel]/self.CONSUME_TIME)*self.PERIOD_TIME))) * self.PERIOD_TIME;
	GeneralProcess:StartProcess("Đang ăn...", nTime * Env.GAME_FPS, {self.SuccessUse, self, me.nId, it.dwId}, {self.FailUse, self, me.nId, it.dwId}, tbEvent);
	tbTemp.nTimerId = nTimerId;
	return 0;
end

function tbItem:SuccessUse(nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return 0;
	end
	pPlayer.Msg("Đã ăn xong.")
end

function tbItem:FailUse(nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return 0;
	end		
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return 0;
	end
	local tbTemp = pItem.GetTempTable("army_food");
	if tbTemp.nTimerId > 0 then
		if Timer:GetRestTime(tbTemp.nTimerId) > 0 then
			Timer:Close(tbTemp.nTimerId);
		end
	end
	tbTemp.nTimerId = 0;
	me.Msg("享用食物状态被打断。")
end

function tbItem:OnNpcTimer(nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return 0;
	end		
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return 0;
	end
	local nExp = pItem.GetGenInfo(1);
	local nAddExp = math.ceil((self.tbFood[pItem.nLevel] / self.CONSUME_TIME) * self.PERIOD_TIME);
	
	if nAddExp + nExp > self.tbFood[pItem.nLevel] then
		nAddExp = self.tbFood[pItem.nLevel] - nExp;
	end
	nExp = nExp + nAddExp;
	pItem.SetGenInfo(1, nExp);
	pItem.Sync();
	pPlayer.AddExp(nAddExp);
	if nExp >= self.tbFood[pItem.nLevel] then
		pPlayer.DelItem(pItem)
		return 0;
	end
	
	return self.PERIOD_TIME * Env.GAME_FPS;
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = GetTime() + 30 * 24 * 3600;
	it.SetTimeOut(0, nSec);
	return	{ };
end

function tbItem:GetTip(nState)
	local nExp = it.GetGenInfo(1);
	local szTip = "";
	szTip = szTip..string.format("<color=0x8080ff>Nhấn chuột phải dùng<color>\n");
	szTip = szTip..string.format("<color=yellow>Thức ăn nhận kinh nghiệm: %s/%s<color>",nExp, self.tbFood[it.nLevel]);
	return szTip;
end
