-- 七大福利开启时间
SpecialEvent.WELLFRAE_START_TIME = 20090625;

function SpecialEvent:IsWellfareStarted_Remake()
	local nTime = tonumber(os.date("%Y%m%d", GetTime()));
	if nTime >= self.WELLFRAE_START_TIME then
		return 1;
	else
		return 0;
	end
end

function SpecialEvent:WeiwangWeeklyRankUpdate()
	if tonumber(GetLocalDate("%w")) == 1 then
		PlayerHonor:OnSchemeUpdateWeiwangHonorLadder();
		GlobalExcute{"Ladder:RefreshLadderName"};
		KGblTask.SCSetDbTaskInt(DBTASK_WEIWANG_WEEK, tonumber(GetLocalDate("%W")));
	end
end
