-- 文件名　：childrenday_define.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-14 11:05:56
-- 功能    ：

SpecialEvent.tbChildrenDay2012 = SpecialEvent.tbChildrenDay2012 or {};
local tbChildrenDay2012 = SpecialEvent.tbChildrenDay2012;

tbChildrenDay2012.tbFactionName = {"少林","天王","唐门","五毒","峨嵋", "翠烟","丐帮","天忍","武当","昆仑","明教","大理段氏"};
tbChildrenDay2012.TASKID_GROUP			= 2192;

tbChildrenDay2012.TASKID_FACTION_START	= 21; 	--1-12表示门派激活
tbChildrenDay2012.TASKID_FACTION_END		= 32; 	--1-12表示门派激活
tbChildrenDay2012.TASKID_TIME				= 33;		--表示时间
tbChildrenDay2012.TASKID_CHANGE_TIME		= 34;	--被变身时间
tbChildrenDay2012.TASKID_CHANGE_TYPE		= 44;	--被变身类型

tbChildrenDay2012.TASKID_HULU_COUNT		= 35;		--每天砸葫芦的次数
tbChildrenDay2012.TASKID_HULU_DATE		= 36;	--砸葫芦的日期
tbChildrenDay2012.TASKID_HULU_HANDON	= 37;		--上交葫芦的标志（保留现场）

tbChildrenDay2012.TASKID_GETITEM_COUNT	= 38;	--获得变身咒道具的次数
tbChildrenDay2012.TASKID_GETITEM_DATE	= 39;	--获得变身咒道具的时间

tbChildrenDay2012.TASKID_EVENT_COUNT	= 40;	--活动产出小葫芦的数目
tbChildrenDay2012.TASKID_EVENT_DATE		= 41;		--活动产出小葫芦的时间

tbChildrenDay2012.TASKID_MAX_REPUTE_ITEM		= 42;
tbChildrenDay2012.TASKID_MAX_SPE_ITEM			= 45;

tbChildrenDay2012.tbLimitMask = {["[面具]快乐的小男孩"] = 1,["[面具]快乐的小女孩"] = 1, ["[面具]宝果子"] = 1, ["[面具]二丫"] = 1,["[面具]虎子"] = 1, ["[面具]燕燕"] = 1, ["[面具]牧童"] = 1, ["[面具]喜妞妞"] = 1, ["[面具]福娃娃"] = 1};
tbChildrenDay2012.nChangeTime	= 600;	--变身时间（秒）

tbChildrenDay2012.nMaxSkillLevel 	= 26;		--变身技能最大等级
tbChildrenDay2012.nSkillId		= 2764;		--变身技能id

tbChildrenDay2012.nMaxCount 	= 10;	--每天10次
tbChildrenDay2012.nPlayerLevel 	= 60;
tbChildrenDay2012.tbAwardItem 	= {18, 1, 1728, 1};	--变身奖励

tbChildrenDay2012.nDayEventMaxCount = 6;	--每天活动产出最大数目

tbChildrenDay2012.nStartDay 	= 20120525;
tbChildrenDay2012.nEndDay 	= 20120603;

tbChildrenDay2012.nMaxReputeItem = 5;
tbChildrenDay2012.nMaxSpeItem 	   = 1;

tbChildrenDay2012.tbRepute = {{5,4,2600, {18,1,1251,1,1,1}, 3, "小游龙阁声望令[护身符]"}, {8, 1, 17750, {18,1,1251,2,1,1}, 4,"小游龙阁声望令[帽子]"}, {7,1,21000, {18,1,1251,3,1,1}, 4,"小游龙阁声望令[衣服]"}, {5,2,250, {18,1,1251,4,1,1},  1,"小游龙阁声望令[腰带]"}};

tbChildrenDay2012.szUITitle = "葫芦兄弟送惊喜";
tbChildrenDay2012.tbMsgFerCount = {
	"<color=yellow>本轮6种礼物如上<color>\n正在进行第%s次领取礼物 ，还可领取%s次\n<color=red>本次领取礼物需要花费的小葫芦数：%s<color>",
	"<color=yellow>请选择一张卡片<color>\n正在进行第%s次领取礼物 ，还可领取%s次\n<color=red>本次领取礼物需要花费的小葫芦数：%s<color>",
	"<color=yellow>点击按钮开始下一次<color>\n正在进行第%s次领取礼物 ，还可领取%s次\n<color=red>本次领取礼物需要花费的小葫芦数：%s<color>"
}
tbChildrenDay2012.tbCostItem = {18,1,1728,1};	--砸葫芦

tbChildrenDay2012.tbPlayerAwardList = {};

function tbChildrenDay2012:CheckHasMask(pPlayer)
	local pItem = pPlayer.GetItem(0,11,0);
	if not pItem then
		return 0
	end
	if self.tbLimitMask[pItem.szName] then
		return 1;
	end
	return 0;
end
