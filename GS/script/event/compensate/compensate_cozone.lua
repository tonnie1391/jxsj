-- 合服补偿通用脚本

local CompensateCozone = {};
SpecialEvent.CompensateCozone = CompensateCozone;

CompensateCozone.FUDAI_COUNT_PERTIME	= 20; 	-- 每次20个
CompensateCozone.FUDAI_COUNT_GIVE		= 15;	-- 福袋领取次数
CompensateCozone.FUDAI_COZONE_DISTIME	= 150;	-- 合服时间差距在150天
CompensateCozone.FUDAI_OPENTIME			= 30;	-- 合服补偿福袋持续时间
CompensateCozone.FUDAI_GIVE_LEVEL		= 50;	-- 合服补偿领取最低等级

CompensateCozone.TSKGRP = 2110;
CompensateCozone.TSKID_FUDAI_COUNT = 1; -- 福袋领取次数
CompensateCozone.TSKID_COMBINE_FRESH_FLAG = 2; -- 刷新领奖变量的标记

function CompensateCozone:CheckFudaiCompenstateState(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	
	local nNowTime = GetTime()
	local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME); 
	local nZoneStartTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nDisTime = KGblTask.SCGetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE);
	
	-- 不是从服玩家
	if (pPlayer.IsSubPlayer() == 0) then
		return 0;
	end

	-- 合服时间差距小于150天,不能领
	if (nDisTime < 3600 * 24 * self.FUDAI_COZONE_DISTIME) then
		return 0;
	end
	
	-- 超过30天就不能领了
	if (nNowTime < nGbCoZoneTime or nNowTime > nGbCoZoneTime + self.FUDAI_OPENTIME * 24 * 60 * 60) then
		return 0;
	end
	return 1;	
end

-- 判断福袋领取资格
function CompensateCozone:CheckFudaiQualification(pPlayer)
	if (not pPlayer) then
		return 0, "玩家不存在";
	end

	local nNowTime = GetTime()
	local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME); 
	local nZoneStartTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nDisTime = KGblTask.SCGetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE);
	
	-- 不是从服玩家
	if (pPlayer.IsSubPlayer() == 0) then
		return 0, "您不是合服时从服玩家，不能领取合服补偿福袋";
	end

	-- 合服时间差距小于150天,不能领
	if (nDisTime < 3600 * 24 * self.FUDAI_COZONE_DISTIME) then
		return 0, string.format("您所在合服后的两个服务器的开服时间差距没有大于%d天，不能领取补偿福袋", self.FUDAI_COZONE_DISTIME);
	end
	
	-- 超过30天就不能领了
	if (nNowTime < nGbCoZoneTime or nNowTime > nGbCoZoneTime + self.FUDAI_OPENTIME * 24 * 60 * 60) then
		return 0, string.format("不在领取期限内不能领取合服补偿福袋");
	end

	-- 等级要求不够
	if (pPlayer.nLevel < self.FUDAI_GIVE_LEVEL) then
		return 0, string.format("您当前等级没有达到%d级，不能领取合服补偿福袋", self.FUDAI_GIVE_LEVEL);
	end
	
	local nFudaiGetCount = pPlayer.GetTask(self.TSKGRP, self.TSKID_FUDAI_COUNT);
	
	-- 超过领取次数就不能领了
	if (nFudaiGetCount >= self.FUDAI_COUNT_GIVE) then
		return 0, string.format("您已经领完了所有福袋补偿");
	end
	
	-- 背包空间不足
	if (pPlayer.CountFreeBagCell() < self.FUDAI_COUNT_PERTIME) then
		return 0, string.format("Hành trang không đủ %d个，不能领取合服补偿", self.FUDAI_COUNT_PERTIME);
	end
		
	return 1;	
end

function CompensateCozone:OnFudaiDialog()
	local nFlag, szMsg = self:CheckFudaiQualification(me);
	if (nFlag == 0) then
		Dialog:Say(szMsg);
		return 0;
	end
	
	local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
	local nFudaiGetCount = me.GetTask(self.TSKGRP, self.TSKID_FUDAI_COUNT);
	local szTime = os.date("%Y年%m月%d日", nGbCoZoneTime + self.FUDAI_OPENTIME * 24 * 60 *60);
	local nLastCount = self.FUDAI_COUNT_GIVE - nFudaiGetCount;
	if (nLastCount <= 0) then
		nLastCount = 0;
		return 0;
	end
	
	Dialog:Say(string.format("在<color=yellow>%s<color>之前，你还有<color=yellow>%d<color>次福袋可以领取，每次可以得到<color=yellow>%d<color>个福袋，你确定现在领吗？", szTime, nLastCount, self.FUDAI_COUNT_PERTIME),
			{
				{"Xác nhận", self.OnSureGetFudai, self},
				{"Để ta suy nghĩ thêm"},
			}
		);
	return 1;
end

function CompensateCozone:OnSureGetFudai()
	local nFlag, szMsg = self:CheckFudaiQualification(me);
	if (nFlag == 0) then
		Dialog:Say(szMsg);
		return 0;
	end
	
	for i=1, self.FUDAI_COUNT_PERTIME do
		me.AddItem(18,1,80,1);
	end
	local nCount = me.GetTask(self.TSKGRP, self.TSKID_FUDAI_COUNT);
	nCount = nCount + 1;
	me.SetTask(self.TSKGRP, self.TSKID_FUDAI_COUNT, nCount);
	self:WriteLog(me.szName, "OnSureGetFudai", nCount);
	return 1;
end

-- TODO
function CompensateCozone:OnLogin(bExchangeServerComing)
	if (1 == bExchangeServerComing) then
		return 0;
	end
-- 合服bug修正，把子服玩家的奖励标志清除
	if (me.IsSubPlayer() == 1) then
		local nFreshFlag = me.GetTask(self.TSKGRP, self.TSKID_COMBINE_FRESH_FLAG);
		local nCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
		-- 表示子服玩家需要把数据清除
		if (nCoZoneTime > 0 and nFreshFlag <= 0) then
			local nFlag = me.GetTask(2065, 2); -- 修炼珠
			if (1 == nFlag) then
				me.SetTask(2065, 2, 0);
			end

			nFlag = me.GetTask(Task.tbPlayerPray.TSKGROUP, Task.tbPlayerPray.TSK_IFGETEXTRACOUNT);	-- 祈福
			if (1 == nFlag) then
				me.SetTask(Task.tbPlayerPray.TSKGROUP, Task.tbPlayerPray.TSK_IFGETEXTRACOUNT, 0);	-- 祈福
			end

			nFlag = me.GetTask(2013, 5); -- 福袋
			if (1 == nFlag) then
				me.SetTask(2013, 5, 0); -- 福袋
			end

			me.SetTask(self.TSKGRP, self.TSKID_COMBINE_FRESH_FLAG, GetTime());
			self:WriteLog("OnLogin", "CoZone Flag fresh", me.szName, GetTime());
		end
	end
end

-- 开启子服玩家补偿标志清零的功能
function CompensateCozone:_OpenFreshSubPlayerCompenFlag()
	if (self.nLoginRegisterId and self.nLoginRegisterId > 0) then
		PlayerEvent:UnRegister("OnLogin", self.nLoginRegisterId);
		self.nLoginRegisterId = 0;
	end
	self.nLoginRegisterId = PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.CompensateCozone.OnLogin, SpecialEvent.CompensateCozone);
end

function CompensateCozone:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "SpecialEvent", "CompensateCozone", unpack(arg));
	end
	if (MODULE_GAMECLIENT) then
		Dbg:Output("SpecialEvent", "CompensateCozone", unpack(arg));
	end
	return 1;
end

