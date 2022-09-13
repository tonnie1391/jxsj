-- 文件名　：wldh_book.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-22 20:06:18
-- 描  述  ：

local tbItem = Item:GetClass("wldh_book")

function tbItem:OnUse()
	self:OnSureUse();
	return 0;
end

function tbItem:OnSureUse()
	local szMsg = [[
    欢迎来到英雄岛！
    欲参加<color=yellow>门派单人赛、混合双人赛、混合三人赛、五行五人赛<color>这四项赛事的侠客，请组队前往英雄岛的<color=green>小型赛报名官<color>处，由队长报名参赛并建立战队，之后才能入场。
	欲参加<color=yellow>大型团体赛<color>的侠客，请前往英雄岛的<color=green>大型团体赛报名官<color>处报名入场。
    各项比赛的规则和赛程请查阅<color=yellow>F12帮助锦囊的最新消息<color>，请各位侠客提前做好入场参赛的准备。武林大会结束后，可以到临安府的武林大会官员处领取优胜奖励。
	]]
	local tbOpt = {
		{"基本注意事项", self.OnAbout, self, 1},
		{"武林大会专用绑银", self.OnAbout, self, 2},
		{"查询门派单人赛赛程", self.OnAbout, self, 3},
		{"查询混合双人赛赛程", self.OnAbout, self, 4},
		{"查询混合三人赛赛程", self.OnAbout, self, 5},
		{"查询五行五人赛赛程", self.OnAbout, self, 6},
		{"查询大型团体赛赛程", self.OnAbout, self, 7},
		{"我已经了解"},
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:OnAbout(nType)
	local szMsg = self.tbAbout[nType];
	local tbOpt = {
		{"返回上一层", self.OnSureUse, self},
		{"Đóng lại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

tbItem.tbAbout = {
[1] = [[
1、	只能参加<color=green>混合双人赛、混合三人赛、五行五人赛中的其中一项<color>赛事。门派单人赛和大型团体赛可以自由参加。
2、	踏入英雄岛后，角色<color=green>背包和储物箱内的物品会交由系统暂管<color>，离开英雄岛后自动归还。
3、	在武林大会的场所购买物品时，只能使用专用绑银，您必须在来<color=green>英雄岛之前准备好<color>，通过<color=green>奇珍阁<color>有出售。
4、	在英雄岛上将聚集本服所有参赛玩家，你可以前往<color=green>试炼谷<color>找其它服务器玩家切磋武艺。
]],
[2] = [[
    比赛需要的药品和食物可在比赛准备会场内购买，但是必须要使用<color=yellow>武林大会专用绑银<color>。

    <color=green>专用绑银获得方式：<color>由英雄岛的车夫传送回临安，在奇珍阁金币区购买<color=yellow>武林大会专用绑银<color>，右键使用即可获取。
    
    专用绑银的余额可在临安府的武林大会报名官处查询。
]],
[3] = [[
<color=green>预赛时间：
10月09日~10月13日，每天20:00~21:45。<color>每天8场比赛，15分钟1场。
总计40场预赛，你只需参加其中的<color=green>24场<color>即可。排名<color=green>前32<color>的战队，晋级决赛。

<color=green>决赛时间：
10月29日，20:00~21:30。<color>共7场比赛，15分钟1场。
32进16、16进8、8进4、4进2、2进1，除了2进1需进行<color=green>3场<color>比赛外，其余4轮比赛都只进行<color=green>1场<color>。
]],
[4] = [[
<color=green>预赛时间：
10月14日~10月18日，每天20:00~21:45。<color>每天8场比赛，15分钟1场。
总计40场预赛，你只需参加其中的<color=green>24场<color>即可。排名<color=green>前32<color>的战队，获得决赛资格。

<color=green>决赛时间：
10月30，20:00~21:30。<color>共7场比赛，15分钟1场。
32进16、16进8、8进4、4进2、2进1，除了2进1需进行<color=green>3场<color>比赛外，其余4轮比赛都只进行<color=green>1场<color>。
]],
[5] = [[
<color=green>预赛时间：
10月19日~10月23日，每天20:00~21:45。<color>每天8场比赛，15分钟1场。
总计40场预赛，你只需参加其中的<color=green>24场<color>即可。排名<color=green>前32<color>的战队，获得决赛资格。

<color=green>决赛时间：
10月31日，20:00~21:30。<color>共7场比赛，15分钟1场。
32进16、16进8、8进4、4进2、2进1，除了2进1需进行<color=green>3场<color>比赛外，其余4轮比赛都只进行<color=green>1场<color>。
]],
[6] = [[
<color=green>预赛时间：
10月24日~10月28日，每天20:00~21:45。<color>每天8场比赛，15分钟1场。
总计40场预赛，你只需参加其中的<color=green>24场<color>即可。排名<color=green>前32<color>的战队，获得决赛资格。

<color=green>决赛时间：
    11月01日，20:00~21:30。<color>共7场比赛，15分钟1场。

    32进16、16进8、8进4、4进2、2进1，除了2进1，需进行<color=green>3场<color>比赛外，其余4轮比赛都只进行<color=green>1场<color>。
]],
[7] = [[
<color=green>预赛时间：
10月份的10、11日，17、18日，24、25日，每天22:00~23:00<color>，即比赛期间的周六、周日，每天1场。
共计6场比赛。每场比赛都必须要来参加，来能获得积分。每场比赛会由系统自动来分配对阵表。
预赛中，胜方得3分；负方得0分；轮空得3分。最终，总积分排名<color=green>前4<color>的服务器代表队，进入决赛。

<color=green>决赛时间：
11月02日（星期一），19:30~20:30（4进2），21:00~22:00（2进1）<color>
进行4进2、2进1，共<color=green>2轮<color>比赛。
]],
};
