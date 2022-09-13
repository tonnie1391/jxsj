-- 文件名　：dlgjiaoyunpc.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-13 11:37:53
-- 功能描述：典礼相关npc（提供对话选项的教育npc）

local tbNpc = Npc:GetClass("marry_dlgjiaoyunpc");

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local szMsg = "人生何处无芳草，何必单恋一枝花，情场如战场，珍重。";
	local tbOpt = {
		{"<color=gold>侠侣闯天下系统介绍<color>", self.GetJiaoyuMsg1, self},
		{"<color=gold>了解情花<color>", self.GetJiaoyuMsg2, self},
		{"<color=gold>典礼流程<color>", self.GetJiaoyuMsg3, self},
		{"<color=gold>典礼的好处<color>", self.GetJiaoyuMsg4, self},
		{"<color=gold>主要NPC<color>", self.GetJiaoyuMsg5, self},
		{"<color=gold>典礼和宴席<color>", self.GetJiaoyuMsg6, self},
		{"以后再来看吧"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetJiaoyuMsg1()
	me.SetTask(1022,216,1,1);
	local szMsg = [[
<color=green>【典礼条件】<color>
    1、男女双方等级均达到<color=yellow>69<color>级；
    2、男女双方均为<color=yellow>单身<color>状态，没有纳吉、侠侣关系。
    3、双方<color=yellow>亲密度<color>达到<color=yellow>3<color>级。
]];
  	local tbOpt = { 
    	{"返回上一层", self.OnDialog, self}
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetJiaoyuMsg2()
	me.SetTask(1022,217,1,1);
	local szMsg = [[
<color=green>【情花有什么用处？】<color>
    结成侠侣必备的各种道具，都需要用<color=yellow>情花<color>才能在典礼商人万有全处购买。

<color=green>【如何获得情花？】<color>
    1、在<color=yellow>奇珍阁<color>购买情花，这是获取情花的<color=yellow>最快<color>的方式。
    2、完成<color=yellow>逍遥谷3级和3级以上的关卡<color>后，会有一定几率刷出<color=yellow>情花<color>，采集后获得一个绑定的<color=yellow>情花花瓣<color>；
       生活技能达到<color=yellow>60<color>级后自动学会情花花瓣的加工制作，分别消耗<color=yellow>150<color>的精力、活力，即可获得<color=yellow>绑定的情花<color>。
]];
  	local tbOpt = { 
    	{"返回上一层", self.OnDialog, self}
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetJiaoyuMsg3()
	me.SetTask(1022,218,1,1);
	local szMsg = [[
<color=green>【纳吉】<color>
    1、用<color=yellow>情花<color>在江津村<color=yellow>典礼商人万有全<color>处购买纳吉礼包。<color=yellow>纳吉双方其中一人购买即可。<color>
    2、右键点击打开纳吉礼包，获得<color=yellow>纳吉卡<color>；
    3、纳吉双方男女组队，一方<color=yellow>使用纳吉卡<color>进行纳吉，另一方同意后，纳吉成功。
<color=green>【典礼】<color>
    1、纳吉成功后，<color=yellow>男方<color>用情花在江津村万有全处购买<color=yellow>典礼礼包<color>；女方若误购典礼礼包，可右键使用兑换回绑定的情花。
    2、男女双方组队，男方凭典礼礼包在江津村<color=yellow>老月<color>处<color=yellow>预订典礼<color>；
    3、举办典礼的当天中午12点至次日早上7点，在<color=yellow>老月<color>处<color=yellow>参加典礼<color>。典礼双方的<color=yellow>好友、同一家族成员<color>无需凭证即可入场庆贺；非好友则需要持有<color=yellow>邀请函<color>才能进入。邀请函可在典礼场地内由二位侠侣或者他们的结义兄弟、闺中密友购买，并分发给宾客。
<color=green>【典礼后】<color>
    典礼结束后，二位侠侣可以去江津村老月处领取<color=yellow>侠侣信物。
]];
	local tbOpt = { 
    	{"返回上一层", self.OnDialog, self}
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetJiaoyuMsg4()
	me.SetTask(1022,219,1,1);
	local szMsg = [[
<color=green>【典礼的好处】<color>
    让老月见证你们之间的情意吧！成为侠侣后您还将获得各种持续性的好处：
    1、<color=yellow>专属称号。<color>纳吉、举办典礼后均有称号表明身份，告诉别人你已经心有所属了！    
    2、<color=yellow>侠侣坐骑。<color>白虎欢欢、白鹿喜喜与你们相伴到天涯，让世人见证你们感天动地的爱情。<color=yellow>（仅皇家典礼礼包专有）<color>
    3、<color=yellow>豪华侠侣信物。<color>侠侣信物美丽又实惠。使用侠侣信物即可获得<color=yellow>心心相印、侠侣坐骑、侠侣传送、经验加成、侠侣光环<color>。（不同档次的侠侣信物可获得的功能不同）  
    
    详情请查阅F12帮助锦囊里的详细帮助。
]];
  	local tbOpt = { 
    	{"返回上一层", self.OnDialog, self}
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetJiaoyuMsg5()
	me.SetTask(1022,220,1,1);
	local szMsg = [[
<color=green>【老月】<color>
    江津村老月是您典礼过程的重要见证人，在他这里可以：
    1、预订典礼；
    2、参加典礼；
    3、查询近期典礼日程；
    4、参观典礼地图；
    5、举办典礼后，领取侠侣信物。

<color=green>【典礼商人万有全】<color>
    江津村典礼商人万有全处出售结成侠侣需要的各种道具，如纳吉礼包、典礼礼包、烟花礼炮等。只需要用一定数量的<color=yellow>情花<color>即可。
    情花可在奇珍阁购买，或者逍遥谷内采集花瓣后加工制作。

<color=green>【红姨】<color>
    纳吉成功后，若觉后悔，你可以在红姨处<color=yellow>申请解除纳吉<color>，解除时交付一定费用。
    <color=yellow>注意：若已经使用典礼礼包预订典礼，则不能再反悔了。<color>
]];
  	local tbOpt = { 
    	{"返回上一层", self.OnDialog, self}
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetJiaoyuMsg6()
	me.SetTask(1022,221,1,1);
	local szMsg = [[
<color=green>【典礼流程】<color>

    典礼场地在典礼<color=yellow>当天中午12点-次日上午7点<color>一直开启，时间到后，场地自动关闭。
    
    1、<color=red>入座。<color>二位侠侣、来宾等进入典礼场地，来宾可以在场地内的礼金收取人处给二位侠侣<color=yellow>送出祝福<color>；
    2、<color=red>开启。<color>二位侠侣的结义兄弟、闺中密友或二位侠侣点击典礼主持人吉祥开启典礼；
    3、<color=red>拜堂。<color>众多游戏内NPC前来致贺，二位侠侣拜堂，来宾放烟花、祝贺；
    4、<color=red>宴席。<color>来宾可以点击获得餐桌上的菜，食用后可获得一定奖励。二位侠侣此时也可到宴席中间找“<color=yellow>福临门<color>”开启小游戏。举办王侯和皇家典礼还可以进行<color=yellow>抽奖<color>，幸运者可以获得价值不菲的玄晶。
    5、<color=red>结束。<color>典礼场地在<color=yellow>当天中午12点-次日上午7点<color>一直开启，时间到后，场地自动关闭。
注：若您的烟花等不够用都可以在<color=yellow>场地内的典礼商人<color>处购买。
    若<color=yellow>未能如期<color>举办典礼，则典礼场地关闭后<color=yellow>可以到江津村老月处修复<color>侠侣关系。
]];
  	local tbOpt = { 
   	 	{"返回上一层", self.OnDialog, self}
	};
	Dialog:Say(szMsg, tbOpt);
end
