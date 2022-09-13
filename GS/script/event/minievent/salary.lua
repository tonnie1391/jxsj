--工资领取：福利版推出后，符合江湖威望条件的玩家，可以每周领取最多价值500RMB的绑定金币

SpecialEvent.Salary = {}
local Salary = SpecialEvent.Salary;

Salary.TASK_GROUP_ID = 2027;
Salary.TASK_LAST_PAID_TIME = 68;

function Salary:CanGetSalary()
	if SpecialEvent:IsWellfareStarted_Remake() ~= 1 then
		return 0, "Tính năng này chưa mở.";
	end
	
	local nTime = GetTime();
	local nWeek = Lib:GetLocalWeek(nTime);
	
	local nLastTime = me.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_PAID_TIME);
	local nLastWeek = Lib:GetLocalWeek(nLastTime);
	
	local nTimeOK = 0;
	
	if nLastTime == 0 or nWeek > nLastWeek then
		nTimeOK = 1;
	end
	
	if nTimeOK ~= 1 then
		return 0, "Tuần này bạn đã nhận lương rồi!";
	end
	
	if KGblTask.SCGetDbTaskInt(DBTASK_WEIWANG_WEEK) ~= tonumber(GetLocalDate("%W")) then
		return 0, "Bảng xếp hạng Uy danh tuần này vẫn chưa có!";
	end
	
	local nLevel = GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_WEIWANG, 0);
	
	if nLevel < 1 or nLevel > 1200 then
		return 0, "Bạn không đủ điều kiện để nhận lương.";
	end
	
	local nCoin, nDecreaseRepute;
	if 1 <= nLevel and nLevel <=10 then
		nCoin = 12000;
		nDecreaseRepute = 0;
	elseif 11 <= nLevel and nLevel <= 30 then
		nCoin = 6000;
		nDecreaseRepute = 0;
	elseif 31 <= nLevel and nLevel <= 60 then
		nCoin = 3000;
		nDecreaseRepute = 0;
	elseif 61 <= nLevel and nLevel <= 100 then
		nCoin = 2000;
		nDecreaseRepute = 0;
	else
		nCoin = 500;
		nDecreaseRepute = 0;
	end
	
	if me.nPrestige < nDecreaseRepute then
		return 0, string.format("Để nhận lương của <color=yellow>hạng %d<color>, bạn cần có ít nhất <color=yellow>%d điểm<color> Uy danh.", nLevel, nDecreaseRepute);
	end
	
	return 1, nLevel, nCoin, nDecreaseRepute;
end


function Salary:GetSalary()
	local nRes, var, nCoin, nDecreaseRepute = Salary:CanGetSalary();
	if nRes == 0 then
		Dialog:Say(var);
		return;
	end
	
	local nLevel = var;
	
	if nCoin then
		local szMsg = string.format("Tuần này, Uy danh của bạn đạt <color=yellow>hạng %d<color>. Bạn có thể nhận <color=yellow>%d %s khóa<color>\n\nBạn đã nghĩ kỹ chưa?",
			nLevel, nCoin, IVER_g_szCoinName);
			
		local tbOpt = {
			{"Xác nhận lãnh", self.GetSalary2, self, nCoin, 0, nLevel},
			{"Để ta suy nghĩ lại"},
			};
		Dialog:Say(szMsg, tbOpt);	
	end
end

function Salary:GetSalary2(nCoin, nDecreaseRepute, nLevel)
	local nRes, var = Salary:CanGetSalary();
	if nRes == 0 then
		Dialog:Say(var);
		return;
	end
	
	me.AddBindCoin(nCoin, Player.emKBINDCOIN_ADD_SALARY);
	local nOldReput = me.nPrestige;
	local nNewPrestige = math.max(nOldReput + 20, 0);
	KGCPlayer.SetPlayerPrestige(me.nId, nNewPrestige);	
	me.SetTask(self.TASK_GROUP_ID, self.TASK_LAST_PAID_TIME, GetTime());
	
	local szLog = string.format("%s 第%d名 获得福利工资%d绑定%s， 减少%d点威望，威望由%s减为%s", me.szName, nLevel, nCoin, IVER_g_szCoinName, nDecreaseRepute, nOldReput, nNewPrestige);
	Dbg:WriteLog("SpecialEvent.Salary", szLog);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	--记录玩家领取工资的次数
	Stats.Activity:AddCount(me, Stats.TASK_COUNT_SALARY, 1);
	KStatLog.ModifyAdd("bindcoin", "[产出]工资", "总量", nCoin);
end
