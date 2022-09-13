-- 文件名　：kingsoft20years.lua
-- 创建者　：后轩
-- 创建时间：2008-11-10 15:24:55

local tbTwentyAnvsy = {};
SpecialEvent.tbTwentyAnniversary = tbTwentyAnvsy;

tbTwentyAnvsy.TASKGROUP 					= 2027;		--任务组ID
tbTwentyAnvsy.EACH_HOUR_ID					= 20;		--每次领取修炼时间的ID
tbTwentyAnvsy.TIME_COUNT_ID					= 21;		--领取修炼时间的次数的ID
tbTwentyAnvsy.MAX_COUNT						= 3;		--最大领取次数
tbTwentyAnvsy.TIME_LIMIT					= 12;		--领取时修炼珠所剩余时间的最大限制值,超过该时间则不允许领取
tbTwentyAnvsy.EACH_TIME_LENGTH				= 2;		--每次可以领取的时间:2小时
tbTwentyAnvsy.SPECIALMONSTERMAPPROB_TASKID 	= 22;		--进入特殊打怪地图的道具的任务变量
tbTwentyAnvsy.TSK_GREED				 		= 23;		--祝福标志

tbTwentyAnvsy.tbEventTime = {
		20081118,	--开始时间
		20081125,	--结束时间
		20081128,	--金币返回结束时间
	};

function tbTwentyAnvsy:CheckTime()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if (nDate >= self.tbEventTime[1] and nDate < self.tbEventTime[2]) then
		return 1;
	end;
	return 0;
end;

function tbTwentyAnvsy:TwentyYearsOnDialog()	--新手村推广员处的新增对话
	local szMsg = "大家同欢乐，天天都惊喜。<color=yellow>1988年，金山成立了，一晃眼，20年过去了。<color>为了答谢广大用户对我们的支持，我们精心准备了神奇的祝福和神秘的地图，等着你来领取。";
	local tbOpt = {
		{"领取强化费用降低的祝福", self.OnTwentyYearsBlessDialog, self},
		{"领取秘境地图", self.GiveSpecialMonsterMapProb, self},
		{"我只是来凑个热闹的。"},
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end;

function tbTwentyAnvsy:OnTwentyYearsBlessDialog()
	local szMsg = "  有位高人曾教给我一句神奇的祝福语，它可以使被祝福的人在强化装备时，<color=yellow>降低20％<color>的费用。\n  同时老前辈还告诫我，只有江湖威望达到<color=yellow>50点<color>或者本月充值累计达到<color=yellow>15元<color>的侠士被祝福后才有效果。你是这样的人吗？\n\n  <color=red>强化费用降低20％效果持续5天时间<color>";
	local tbOpt = {
		{"很显然，我就是这种人", self.GetTwentyYearsBless, self},
		{"我只是来凑个热闹的。"},
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end;

function tbTwentyAnvsy:GetTwentyYearsBless(nSure)
	if self:CheckTime() ~= 1 then
		Dialog:Say("对不起，本次活动已经结束。");
		return 0;
	end
	
	if (me.nPrestige < 50) and (me.nMonCharge < 15) then	--江湖威望不低于50或者当月充值不低于15元
		local szMsg = "急急如……啊！！祝福祷告失败了！很显然，你不是这种人！(江湖威望必须达到<color=yellow>50点<color>或本月累计充值达到<color=yellow>15元<color>，只要条件达到<color=yellow>其中一条<color>即可领取。)";
		Dialog:Say(szMsg);
		return 0;
	end
	
	if (me.GetSkillState(892) > 0) then
		local szMsg = "你怎么又来了？侠客是不可以贪心的!(<color=yellow>你已经领取过该祝福!<color>)";
		Dialog:Say(szMsg);
		return 0;
	end
	
	--确认领取
	if (nSure) then
		local nTime = 5 * 24 * 3600;
		local nCurDate = tonumber(GetLocalDate("%y%m%d%H%M"));
		me.SetTask(self.TASKGROUP, self.TSK_GREED, nCurDate);
		me.AddSkillState(892, 1, 1, nTime * Env.GAME_FPS, 1, 0, 1);
		Dialog:Say("急急如律令，太上老君快显灵……（突然我感觉到我体内充满了力量）。恭喜你，祝福祷告完成了。");
		return 0;
	end
	
	local tbOpt = {
			{"确定领取", self.GetTwentyYearsBless, self, 1},
			{"Để ta suy nghĩ lại"},
		};
	local szMsg = "点击确定领取将<color=red>自动获得祝福效果<color>，您确定领取吗？。";
	Dialog:Say(szMsg, tbOpt);
	return 0;
end;

function tbTwentyAnvsy:XiuLianZhuOnDialog()
	self:GetXiuLianZhuTime();
end;

function tbTwentyAnvsy:GetXiuLianZhuTime()
	local nTaskvalue = me.GetTask(self.TASKGROUP, self.EACH_HOUR_ID);
	local nTaskCount = me.GetTask(self.TASKGROUP, self.TIME_COUNT_ID);
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	
	--先确定领取的次数没有超过3次
	if (nTaskCount >= self.MAX_COUNT) then
		local szMsg = "你已经领取了<color=yellow>6小时<color>的修炼时间，作为侠客不可以贪心哦！";
		Dialog:Say(szMsg);
		return 0;
	end;
	
	--没有超过三次则判断今天是否已经领取过
	if (not (nDate > nTaskvalue)) then
		local szMsg = "你今天已经领取过该奖励啦！难道你忘了吗？";
		Dialog:Say(szMsg);
		return 0;
	end;
	
	--没有领取过则判断是否符合领取条件:如果领取时修炼时间超过12小时，则不允许领取。
	local tbItem = Item:GetClass("xiulianzhu");
	local nRemianTime = tbItem:GetRemainTime();
	if (nRemianTime > self.TIME_LIMIT) then
		local szMsg = "对不起，您领取后累计修炼时间将超过<color=red>14小时<color>。所以，当您累计修炼时间不超过<color=red>12小时<color>的时候再来领取吧。";
		Dialog:Say(szMsg);
		return 0;
	end;
	
	--符合条件则领取时间
	local szMsg = "您的修炼时间增加了<color=yellow>2<color>小时。如果您本月充值累计达到48元，别忘了在修炼珠中领取本月额外修炼时间哦。";
	local nAddTime = self.EACH_TIME_LENGTH * 60;	--120分钟
	tbItem:AddRemainTime(nAddTime);

	--修改任务变量的值
	me.SetTask(self.TASKGROUP, self.EACH_HOUR_ID, nDate);
	me.SetTask(self.TASKGROUP, self.TIME_COUNT_ID, nTaskCount + 1);
	Dialog:Say(szMsg);
	return 0;
end;

function tbTwentyAnvsy:GiveSpecialMonsterMapProb()	
	--首先判断当月充值是否达到48元或者已经领取过
	local nMonChr = me.GetExtMonthPay();
	local nTaskValue = me.GetTask(self.TASKGROUP, self.SPECIALMONSTERMAPPROB_TASKID);
	if (nTaskValue > 0) then	--当月需充值至少48元
		local szMsg = "您已领取过<color=red>秘境地图<color>了。";
		Dialog:Say(szMsg);
		return 0;
	end;
	
	if (nMonChr < 48) then	--当月需充值至少48元
		local szMsg = "您本月累计充值未满48元，无法领取<color=red>秘境地图<color>。";
		Dialog:Say(szMsg);
		return 0;
	end;
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("您背包空间不足。请整理1格背包空间。");
		return 0;
	end
	
	--符合条件则领取
	--给物品
	local szMsg = "请收好，这是您的<color=red>秘境地图<color>。感谢您对我们的支持。";
	local pItem = me.AddItem(18, 1, 251, 1);
	if pItem then
		pItem.Bind(1);
		local nDate = tonumber(GetLocalDate("%Y%m%d"));
		me.SetTask(self.TASKGROUP, self.SPECIALMONSTERMAPPROB_TASKID, nDate);
		me.Msg("你获得了一个进入特殊打怪地图的道具!");
	end
	Dialog:Say(szMsg, tbOpt);
	return 0;
end;

--帮助锦囊消息
--神秘地图

	--{
	--	nKey 		= 0,	--key值，默认为0
	--	nStartTime 	= 0,	--开启时间 -年月日时分200810101200，默认为0
	--	nEndTime 	= 0,	--结束时间 -年月日时分200810101224，默认为0
	--	nGlobalKey 	= 16,	--默认为开服时间的全局变量
	--	nStartDay 	= 0,	--开服几天后开启（和nLastDay搭配使用），默认为0
	--	nLastDay 	= 0,	--开启后持续时间（和nStartDay搭配使用），默认为0
	--	szTitle		= "",	--标题
	--	szContent 	= [[	--内容
	--	]],
	--},

function tbTwentyAnvsy:SetMysteriousMapNews()
	local tbNews = {};
	tbNews.nKey			= 11;
	tbNews.nStartTime 	= self.tbEventTime[1] * 10000;	--供测试用
	tbNews.nEndTime		= self.tbEventTime[2] * 10000;
	tbNews.nStartDay	= 0;
	tbNews.nLastDay		= 0;
	tbNews.szTitle		= "庆20周年—神秘地图";
	tbNews.szContent	= [[
活动时间：<color=yellow>2008年11月18日更新后——2008年11月25日0时<color>

活动内容：
    大家同欢乐，天天都惊喜。1988年，金山成立了。一晃眼，20年过去了。
    为了答谢广大用户对我们的支持，我们精心准备<color=green>一些神秘的练级地点。<color>
    
    活动期间，凡<color=green>本月累计充值达48元<color>的侠客，都可以到位于各新手村中的活动推广员处，找她们要一张<color=yellow>通到神秘秘境的地图<color>。不过这个地图不是那么容易看懂的，也许义军中的<color=yellow>义军军需官<color>知道点什么。

活动奖励：秘境地图

特别注意：
    <color=green>当月成功充值“15元充值卡”、“30元充值卡”、“48元充值卡”、“50元充值卡”、“100元充值卡”、“500元充值卡”中任意数量的实卡或虚卡、银行卡，才会计入累计充值。<color>

秘境地图：
    绘有神秘练级地点的地图，据说在该地点内<color=yellow>打怪会获得普通怪4倍的经验，2小时后，该地点会自动关闭<color>。不过地图的内容太深奥了，我们看不懂，也许<color=yellow>义军军需官<color>能够帮助我们。
]];

Task.tbHelp:RegisterDyNews(tbNews);	--注册新消息
end;

--修炼珠
function tbTwentyAnvsy:SetXiuLianZhuNews()
	local tbNews = {};
	tbNews.nKey			= 12;
	tbNews.nStartTime 	= self.tbEventTime[1] * 10000;	--供测试用
	tbNews.nEndTime		= self.tbEventTime[2] * 10000;
	tbNews.nStartDay	= 0;
	tbNews.nLastDay		= 0;
	tbNews.szTitle		= "庆20周年—提高修为";
	tbNews.szContent	= [[
活动时间：<color=yellow>2008年11月18日更新后——2008年11月25日0时<color>

活动内容：
    大家同欢乐，天天都惊喜。1988年，金山成立了。一晃眼，20年过去了。
    为了答谢广大用户对我们的支持，我们精心准备了<color=green>6小时的修炼时间<color>等您来领取。
    
    在活动时间内，<color=green>有3次领取2小时修炼时间的机会<color>，只要领取时<color=red>当前剩余修炼时间不超过12小时就可以领取（如果超过12小时领取，累计修炼时间会超过14小时）<color>，不过每人每天只能领取一次哦。

活动奖励：额外修炼时间
]];

Task.tbHelp:RegisterDyNews(tbNews);	--注册新消息
end;

--家族烤棋子
function tbTwentyAnvsy:SetKinQiZiNews()
	local tbNews = {};
	tbNews.nKey			= 13;
	tbNews.nStartTime 	= self.tbEventTime[1] * 10000;	--供测试用
	tbNews.nEndTime		= self.tbEventTime[2] * 10000;
	tbNews.nStartDay	= 0;
	tbNews.nLastDay		= 0;
	tbNews.szTitle		= "庆20周年—家族大插旗";
	tbNews.szContent	= [[
活动时间：<color=yellow>2008年11月18日更新后——2008年11月25日0时<color>

活动内容：
    大家同欢乐，天天都惊喜。1988年，金山成立了。一晃眼，20年过去了。金山的这20年，离不开大家的支持。
    
    在活动期间，<color=green>进行家族插旗活动时，获得的经验会变为原来的2倍。<color>

活动奖励：经验
]];
Task.tbHelp:RegisterDyNews(tbNews);	--注册新消息
end;

--强化费用降低
function tbTwentyAnvsy:SetEhancePayDownNews()
	local tbNews = {};
	tbNews.nKey			= 17;
	tbNews.nStartTime 	= self.tbEventTime[1] * 10000;	--供测试用
	tbNews.nEndTime		= self.tbEventTime[2] * 10000;
	tbNews.nStartDay	= 0;
	tbNews.nLastDay		= 0;
	tbNews.szTitle		= "庆20周年—强化优惠直降20％";
	tbNews.szContent	= [[
活动时间：<color=yellow>2008年11月18日更新后——2008年11月25日0时<color>

活动内容：
    大家同欢乐，天天都惊喜。1988年，金山成立了。一晃眼，20年过去了。
    为了答谢广大用户对我们的支持，我们精心准备了<color=yellow>神奇的祝福等您来领取。<color>
    活动期间，凡<color=green>江湖威望不低于50点或者本月累计充值达15元<color>的侠客，都可以到位于各新手村中的活动推广员处，接受这条神奇的祝福。有了这条祝福，在您<color=green>强化任意装备时，强化费用都会降低20％哦。<color>

活动奖励：强化费用降低

特别注意：
    <color=green>当月成功充值“15元充值卡”、“30元充值卡”、“48元充值卡”、“50元充值卡”、“100元充值卡”、“500元充值卡”中任意数量的实卡或虚卡、银行卡，才会计入累计充值。<color>
]];
Task.tbHelp:RegisterDyNews(tbNews);	--注册新消息
end;

--消费500金币返还100绑金
function tbTwentyAnvsy:SetJinBiHuanHuanNews()
	local tbNews = {};
	tbNews.nKey			= 18;
	tbNews.nStartTime 	= self.tbEventTime[1] * 10000;	--供测试用
	tbNews.nEndTime		= self.tbEventTime[3] * 10000;
	tbNews.nStartDay	= 0;
	tbNews.nLastDay		= 0;
	tbNews.szTitle		= "庆20周年—绑金大派送";
	tbNews.szContent	= [[
活动时间：<color=yellow>2008年11月21日更新后—2008年11月28日0时<color>

活动内容：
    大家同欢乐，天天都惊喜。1988年，金山成立了。
    一晃眼，20年过去了。为了答谢广大用户对我们的支持，只要您在<color=yellow>奇珍阁内消费了本月充值所得的500金币，就会获得100绑定金币的返还<color>，而且消费得越多获得的绑定金币就会越多。怎么样？心动了吧。

活动奖励：绑定金币

特别注意：
    1.<color=green>当月成功充值“15元充值卡”、“30元充值卡”、“48元充值卡”、“50元充值卡”、“100元充值卡”、“500元充值卡”中任意数量的实卡或虚卡、银行卡，所获得金币，才会计入活动范围。<color>
    
    2.消费的金币<color=green>只有本月充值获得的部分<color>才会被认为有效。比如：<color=yellow>本月充值获得1000金币，活动期间消费了1500金币，那么您只能得到200绑金的奖励，另外500金币是不算数的。<color>
    
    3.在奇珍阁购物车下方的信息提示界面会实时显示您已消费的金币，请玩家注意提示信息。

]];
Task.tbHelp:RegisterDyNews(tbNews);	--注册新消息
end;

--帮助锦囊静态消息设置取消本方法。
--if MODULE_GC_SERVER then
--SpecialEvent.tbTwentyAnniversary:SetMysteriousMapNews();
--SpecialEvent.tbTwentyAnniversary:SetXiuLianZhuNews();
--SpecialEvent.tbTwentyAnniversary:SetKinQiZiNews();
--SpecialEvent.tbTwentyAnniversary:SetEhancePayDownNews();
--SpecialEvent.tbTwentyAnniversary:SetJinBiHuanHuanNews();
--end
