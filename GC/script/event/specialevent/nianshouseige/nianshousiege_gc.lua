-- 文件名　：nianshousiege_gc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-28 14:10:10
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\specialevent\\nianshouseige\\nianshousiege_def.lua");
SpecialEvent.NianShouSiege = SpecialEvent.NianShouSiege or {};
local tbNianShouSiege = SpecialEvent.NianShouSiege or {};

function SpecialEvent:StartNianShouSiege_GC(nSeg)
	if tbNianShouSiege:CheckIsOpen() == 1 then
		tbNianShouSiege.nSeg = nSeg or 0;
		Timer:Register(tbNianShouSiege.PREPARE_TIME, tbNianShouSiege.StartMsg, tbNianShouSiege);
		Dialog:GlobalNewsMsg_GC("发现作乱的年兽！5分钟后将到达凤翔府西北城门，请80级及以上的侠士准备！（需要使用一串在凤翔特产商人处购得的鞭炮）");
		Dialog:GlobalMsg2SubWorld_GC("发现作乱的年兽！<color=yellow>5分钟<color>后将到达<color=yellow>凤翔府西北城门<color>，请<color=yellow>80级<color>及以上的侠士准备！（需要使用一串在凤翔特产商人处购得的鞭炮）");
	end
end

function tbNianShouSiege:StartMsg()
	GlobalExcute{"SpecialEvent.NianShouSiege:StartNianShouSiege_GS2", self.nSeg};
	Dialog:GlobalNewsMsg_GC("年兽从西北城门进入凤翔府捣乱，请80级及以上的侠士前去阻止！（需要使用一串在凤翔特产商人处购得的鞭炮）");
	Dialog:GlobalMsg2SubWorld_GC("年兽从<color=yellow>西北城门<color>进入<color=yellow>凤翔府<color>捣乱，请<color=yellow>80级<color>及以上的侠士前去阻止！（需要使用一串在凤翔特产商人处购得的鞭炮）");
	return 0;
end

-- 成功杀死年兽
function tbNianShouSiege:NianShouDeath_GC(nMapId)
	GlobalExcute{"SpecialEvent.NianShouSiege:EventEndRefreshNpc", nMapId};
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nIndex = self.nSeg;
	if nDate == self.CLOSE_DAY and self.nSeg == 5 then
		nIndex = 6;
	end
	Dialog:GlobalNewsMsg_GC(self.MSG_NIANSHOU_DEATH[nIndex]);
	Dialog:GlobalMsg2SubWorld_GC(self.MSG_NIANSHOU_DEATH[nIndex]);
end

-- 没有杀死年兽
function tbNianShouSiege:FailToKillNianShou_GC(nMapId)
	GlobalExcute{"SpecialEvent.NianShouSiege:EventEndRefreshNpc", nMapId};
	local nIndex = self.nSeg;
	if nDate == self.CLOSE_DAY and self.nSeg == 5 then
		nIndex = 6;
	end
	Dialog:GlobalNewsMsg_GC(self.MSG_BAIQIULING_DEATH[nIndex]);
	Dialog:GlobalMsg2SubWorld_GC(self.MSG_BAIQIULING_DEATH[nIndex]);
end