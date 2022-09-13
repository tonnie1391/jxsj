Require("\\script\\event\\collectcard\\define.lua")

local tbItem = Item:GetClass("collect_huoju");
local CollectCard = SpecialEvent.CollectCard;
local tbAward = 
{
	[4] = 200,
	[3] = 40,
	[2] = 20,
	[1] = 15,
}

function tbItem:OnUse()
	self:OnUseSure(it.dwId)
	return 0;
end

function tbItem:OnUseSure(nItemId, nFlag)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 1;
	end
	if nFlag ~= 1 then
		local tbOpt = {
			{"查看火炬的详细作用", self.OpenHelp, self},
			{string.format("使用并获得%s点火炬手积分",tbAward[pItem.nLevel]), self.OnUseSure, self, nItemId, 1},
			{"退出"},
		}
		Dialog:Say("使用后获得火炬手积分，积分可兑换高额奖励，排名和积分在<color=yellow>修炼珠<color>可查询", tbOpt);
		return 1;
	end
	
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	
	if nData < CollectCard.TIME_STATE[3] then
		Dialog:Say([[<enter>  从<color=yellow>8月28日到8月31日<color>，争当火炬手选举将会火热进行，请保留火炬，并在活动期间使用。]]);
		return 1;
	end
	local nPoint = tbAward[pItem.nLevel];
	if me.DelItem(pItem, Player.emKLOSEITEM_TYPE_EVENTUSED) ~= 1 then
		CollectCard:WriteLog("删除火炬失败", me.nId);
		return 1;
	end	
	me.SetTask(CollectCard.TASK_GROUP_ID, CollectCard.TASK_HUOJU_POINT, me.GetTask(CollectCard.TASK_GROUP_ID, CollectCard.TASK_HUOJU_POINT) + nPoint);
	local nMePoint =  me.GetTask(CollectCard.TASK_GROUP_ID, CollectCard.TASK_HUOJU_POINT);
	
	GCExcute({"SpecialEvent.CollectCard:AddRank_GC", me.szName, nMePoint});
	if nData < CollectCard.TIME_STATE[4] then
		Dialog:Say(string.format("您获得<color=yellow>%s点<color>火炬积分，详细情况请查看<color=yellow>修炼珠<color>相关选项", nPoint));
	end
	CollectCard:WriteLog(string.format("使用盛夏火炬，获得了%s点积分, 火炬手总分：%s", nPoint, nMePoint), me.nId);
	return 1;
end

function tbItem:OpenHelp()
	--打开帮助锦囊
	me.CallClientScript({"UiManager:OpenWindow", "UI_HELPSPRITE"});
	return 1;
end
