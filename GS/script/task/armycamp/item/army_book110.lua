--110级兵书
--高升
--2009.01.04

local tbItem = Item:GetClass("army_book110")
tbItem.nTime = 1;
tbItem.nRelayTime = 5 --需要延时10分钟后才能再读
tbItem.nBookMax = 10;
tbItem.nRepute  = 3;
tbItem.nSkillId  = 798;
tbItem.nExp	= 20000;
tbItem.nMoney = 100;
tbItem.nTaskGroupId = 2044;	--任务变量Group

function tbItem:OnUse()
	local nYear = it.GetGenInfo(2);
	local nTime = it.GetGenInfo(3);
	if nYear > 0 then
		local nDate = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
		local nCanDate = (nYear* 1000000 + nTime)
		local nSec1 = Lib:GetDate2Time(nDate);
		local nSec2 = Lib:GetDate2Time(nCanDate) + self.nRelayTime;
		if nSec1 < nSec2 then
			me.Msg(string.format("Đọc xong 1 trang đợi 1 phút nữa mới đọc được trang kế, đợi <color=yellow>%s giây<color> nữa mới được đọc trang kế.", (nSec2 - nSec1)))
			return 0;
		end
	end	
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
	me.AddSkillState(self.nSkillId, 1, 1, self.nTime * Env.GAME_FPS, 0);
	GeneralProcess:StartProcess("Đang đọc...", self.nTime * Env.GAME_FPS, {self.SuccessUse, self, it.dwId, me.nId}, {self.FailUse, self, me.nId}, tbEvent);
end

function tbItem:FailUse(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return 0;
	end		
	pPlayer.RemoveSkillState(self.nSkillId);
end

function tbItem:SuccessUse(nItemId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return 0;
	end	
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return 0;
	end
	--to do
	--获得3点声望
	--pPlayer.AddKinReputeEntry(self.nRepute);
	pPlayer.AddExp(self.nExp);
	Task.tbArmyCampInstancingManager.StatLog:WriteLog(7,1);
	--读过书记录
	local nUseCount = tonumber(pItem.GetGenInfo(1)) or 0;
	if self.nBookMax - nUseCount <= 1 then
		pPlayer.SetTask(1022,165,1,1)
		if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			assert(false);
		--	pPlayer.Msg("删除兵书失败！");
			return 0;
		end
		pPlayer.AddExp(self.nExp);
		pPlayer.Earn(self.nMoney, Player.emKEARN_TASK_ARMYCAMP);
		KStatLog.ModifyAdd("jxb", "[产出]军营任务", "总量", self.nMoney);
		Task.tbArmyCampInstancingManager.StatLog:WriteLog(9,1);
		
		-- 读兵书成就
		Achievement:FinishAchievement(pPlayer, 234);
		Achievement:FinishAchievement(pPlayer, 240);
		--读完书记录
	else
		pItem.SetGenInfo(1,nUseCount + 1);
		local nYearDate = tonumber(GetLocalDate("%Y%m%d"));
		local nTimeDate = tonumber(GetLocalDate("%H%M%S"));
		pItem.SetGenInfo(2,nYearDate);
		pItem.SetGenInfo(3,nTimeDate);
		pItem.Sync();
		
	end
	pPlayer.RemoveSkillState(self.nSkillId);
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	--local nDate = tonumber(GetLocalDate("%Y%m%d2400"));
	--local nSec = Lib:GetDate2Time(nDate);
	--it.SetTimeOut(0, nSec);
	return	{ };
end

function tbItem:GetTip(nState)
	local nUseCount = it.GetGenInfo(1);
	local szTip = "";
	szTip = szTip..string.format("<color=0x8080ff>Nhấn chuột phải dùng<color>\n");
	szTip = szTip..string.format("<color=yellow>Đọc binh thư trang: %s/%s<color>",nUseCount, self.nBookMax);
	return szTip;
end
