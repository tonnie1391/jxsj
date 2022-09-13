--禁咒爆竹
--孙多良
--2008.12.31

local tbItem = Item:GetClass("jinzhoubaozhu");
tbItem.nCDTime = 10 * 60 	--cd时间30分钟
tbItem.nSkillId = 1123;		--使用技能Id

function tbItem:InitGenInfo()
	-- 设定有效期限
	it.SetTimeOut(0, (GetTime() + 24 * 3600));
	return	{ };
end

function tbItem:OnUse()
	local nCurTime = GetTime();
	local nYear = it.GetGenInfo(1);
	local nTime = it.GetGenInfo(2);
	if nYear > 0 then
		local nCurDate 	= tonumber(os.date("%Y%m%d%H%M%S", nCurTime));
		local nCanDate = (nYear* 1000000 + nTime)
		local nSec1 = Lib:GetDate2Time(nCurDate);
		local nSec2 = Lib:GetDate2Time(nCanDate) + self.nCDTime;
		if nSec1 < nSec2 then
			me.Msg(string.format("这个禁咒爆竹已使用过，您还需要等待<color=yellow>%s<color>后才能再次使用。", Lib:TimeFullDesc(nSec2 - nSec1)));
			return 0;
		end
	end
	if me.nFightState == 0 then
		me.Msg("必须在野外地图才能使用。");
		return 0;
	end
	me.CastSkill(self.nSkillId, 2, -1, me.GetNpc().nIndex);
	local nYearDate = tonumber(os.date("%Y%m%d", nCurTime));
	local nTimeDate = tonumber(os.date("%H%M%S", nCurTime));
	it.SetGenInfo(1,nYearDate);
	it.SetGenInfo(2,nTimeDate);
	Dialog:SendBlackBoardMsgTeam(me, "噼里啪啦一阵乱响，附近的年兽会被吓坏的！ ", 1)
	return 0;
end
