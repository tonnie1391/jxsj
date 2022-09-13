-------------------------------------------------------
-- 文件名　：xkland_npc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-04-09 15:53:44
-- 文件描述：一整个宇宙，换一个颗红豆
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

-- npc都放在这里
-- 1. 区服城市npc，负责传送至侠客岛、首领竞拍、选择阵营等
-- 2. 侠客岛接引npc，负责进入比赛场
-- 3. 复活点车夫，负责传送回侠客岛
-- 4. 复活点商人：药品、攻城令牌

local tbNpc = Xkland.Npc or {};
Xkland.Npc = tbNpc;

-------------------------------------------------------
-- 城市npc
-------------------------------------------------------
-- 1. 首领竞标，调用竞标接口，传送到全局服务器排名
-- 2. 选择阵营，攻守或六个阵营
-- 3. 传送到侠客岛
-- 4. 查询跨服绑银
function tbNpc:OnDialogCity()
	
	-- 活动是否开启
	-- if Xkland:CheckIsOpen() ~= 1 then
		-- Dialog:Say("一去萧萧数十州，相逢非复少年头。");
		-- return 0;
	-- end
	
	-- local nTransferId = Transfer:GetMyTransferId(me);
	-- if not Transfer.tbGlobalMapId[nTransferId] then
		-- Dialog:Say("一去萧萧数十州，相逢非复少年头。");
		-- return 0;
	-- end
	
	local tbOpt = {};
	local szMsg = "铁浮城变数万千，请大侠小心行事！<enter><color=gold>据我所知，不是帮会首领也可以参加竞标了！只要参加就可获得大量经验，个人积分达到500还可获得更多，以及江湖威望！<color>";
	
	-- 届数校验
	Xkland:RectifySession(me);
	
	-- 帮会首领选项
	if Xkland:GetPeriod() == Xkland.PERIOD_COMPETITIVE then
		table.insert(tbOpt, {"<color=yellow>跨服城战竞标<color>", self.CompetitiveBidding, self});
	end
	
	-- 选择阵营
	if Xkland:GetPeriod() == Xkland.PERIOD_SELECT_GROUP then
		table.insert(tbOpt, {"<color=yellow>加入军团申请<color>", self.SelectWarCamp, self});
	end
	
	-- 传送至英雄岛
	if Xkland:GetPeriod() == Xkland.PERIOD_WAR_OPEN then
		table.insert(tbOpt, {"<color=yellow>前往英雄岛参战<color>", self.AttendGlobalWar, self});
	else
		table.insert(tbOpt, {"<color=gray>前往英雄岛<color>", self.AttendGlobalWar, self});
	end
	
	-- 查询跨服绑银
	table.insert(tbOpt, {"查询跨服绑银", self.QueryGlobalMoney, self});

	-- 领取奖励
	if Xkland:GetPeriod() == Xkland.PERIOD_COMPETITIVE and Xkland:GetSession() ~= 1 then
		table.insert(tbOpt, {"跨服城战奖励", self.ShowAllAward, self});
	end
	
	table.insert(tbOpt, {"查询历届城主", self.QueryCastleHistory, self});
	table.insert(tbOpt, {"我要兑换同伴装备", self.ExchangePartnerEq, self});
	table.insert(tbOpt, {"我要了解跨服城战", self.WarHelp, self});
	table.insert(tbOpt, {"Ta hiểu rồi"});
	
	-- 领取退回金币
	if Xkland:GetPeriod() ~= Xkland.PERIOD_COMPETITIVE and me.GetTask(Xkland.TASK_GID, Xkland.TASK_COMP_COIN) > 0 then
		table.insert(tbOpt, #tbOpt - 1, {"<color=yellow>领取竞标返还额<color>", self.GetBackCoin, self});
	end
	
	-- 领取跨服绑银
	if (GetPlayerSportTask(me.nId, Xkland.GA_TASK_GID, Xkland.GA_TASK_WAR_BACKMONEY) or 0) > 0 then
		table.insert(tbOpt, #tbOpt - 1, {"<color=yellow>领取剩余跨服绑银<color>", self.GetBackMoney, self});
	end
	
	-- 领取城主令牌
	if Xkland:GetPeriod() == Xkland.PERIOD_COMPETITIVE and Xkland:CheckCastleOwner(me.szName) == 1 then
		table.insert(tbOpt, #tbOpt - 1, {"<color=yellow>领取城主令牌<color>", Xkland.GetLadderAward_GS, Xkland, me.szName});	
	end
	
	-- 追加赏金界面
	if Xkland:GetPeriod() == Xkland.PERIOD_WAR_REST and Xkland:CheckCastleOwner(me.szName) == 1 then
		local nGroupIndex = Xkland:GetCaptainIndex(me);
		table.insert(tbOpt, #tbOpt - 1, {"<color=yellow>追加军团赏金<color>", Xkland.OnApplyOpenMemberAward, Xkland, nGroupIndex});	
	end
	
	Dialog:Say(szMsg, tbOpt);
end

-- 帮会首领竞标
function tbNpc:CompetitiveBidding()
	
	-- 是否竞拍期
	if Xkland:GetPeriod() ~= Xkland.PERIOD_COMPETITIVE then
		Dialog:Say("<color=yellow>对不起，现在不是竞标期，无法参加竞标。<color><enter><color=green>竞标期：<color>每周日、周一、周四");
		return 0;
	end

	-- 第一届为明标，第二届以后为暗标
	if Xkland:GetSession() ~= 1 then 
		local nCompetitive = me.GetTask(Xkland.TASK_GID, Xkland.TASK_COMP_COIN);
		local szMsg = string.format("此次为<color=yellow>暗标<color>，你只能看到自己的竞标金额，你当前竞标的金币为<color=yellow>%s<color><color=green>（竞标失败后来我这里领取返还金币）<color>", nCompetitive);
		local tbOpt = 
		{
			{"<color=yellow>我要补价<color>", self.AppendBidding, self},
			{"Để ta suy nghĩ thêm"}
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	else
		Xkland:GetPlayerCompRank_GS(me);
	end
end

-- 暗标补价
function tbNpc:AppendBidding()
	Dialog:AskNumber("请输入金币数量：", Xkland.MAX_COMPETITIVE, Xkland.OnCompetitiveBidding_GS, Xkland);
end

-- 选择阵营
function tbNpc:SelectWarCamp()
	
	-- 判断时期
	if Xkland:GetPeriod() ~= Xkland.PERIOD_SELECT_GROUP then
		Dialog:Say("<color=yellow>对不起，现在不是加入军团的时间。<color><enter><color=green>加入军团时间：<color><enter>    每周二00:00-周三19:29；<enter>    每周五00:00-周六19:29");
		return 0;
	end
	
	-- 大区军团列表
	local tbGroup = Xkland.tbLocalGroupBuffer;
	local nCaptain = (Xkland:GetCaptainIndex(me) > 0) and 1 or Xkland:CheckTongPresident(me);
	
	-- 同步帮会名字
	local szTongName = ""
	local pTong = KTong.GetTong(me.dwTongId);
	if pTong then
		szTongName = pTong.GetName();
	end
		
	-- 客户端打开选择界面
	local szWindow = (Xkland:GetSession() == 1 and "UI_SELECTGROUP_FR") or "UI_SELECTGROUP_NR";
	
	me.CallClientScript({"UiManager:OpenWindow", szWindow});
	me.CallClientScript({"Ui:ServerCall", szWindow, "OnRecvData", tbGroup, nCaptain, szTongName});
	
	if Xkland:CheckTongPresident(me) ~= 1 then
		me.CallClientScript({"Ui:ServerCall", szWindow, "DisableAll"});
	end
end

-- 传送到侠客岛
function tbNpc:AttendGlobalWar()

	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say("<color=yellow>您的等级不足。<color><enter>报名条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、帮会首领代表全帮报名。");
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say("<color=yellow>您还未加入门派。<color><enter>报名条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、帮会首领代表全帮报名。");
		return 0;
	end
	
	-- 判断披风(雏凤)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < Xkland.MANTLE_LEVEL then
		Dialog:Say("<color=yellow>此去极其凶险，你没有足以保护自己的披风，怎能匆忙应战？<color><enter>报名条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、帮会首领代表全帮报名。");
		return 0;	
	end
	
	-- 记录帮会名字
	local pTong = KTong.GetTong(me.dwTongId);
	local szTong = me.GetTaskStr(Xkland.TASK_GID, Xkland.TASK_TONGNAME);
	me.SetTaskStr(Xkland.TASK_GID, Xkland.TASK_TONGNAME, (pTong and pTong.GetName()) or "");
	
	-- 传送到跨服服务器(里面已经做了一些判断)
	Transfer:NewWorld2GlobalMap(me);
end

-- 查询跨服绑银
function tbNpc:QueryGlobalMoney()
	local nMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	local szMsg = "";
	if nMoney >= 0 then
		szMsg = string.format("你当前的跨服绑银数量为<color=gold>%s<color>。\n此乃所有跨服活动唯一专用货币，若要获取更多，可按<color=yellow>Ctrl + G<color>打开奇珍阁，购买“跨服活动专用绑银”。", nMoney);
	else
		szMsg = "对不起，暂时无法查询。";
	end
	Dialog:Say(szMsg, {"返回上一层", self.OnDialogCity, self});
end

-- 退回金币
function tbNpc:GetBackCoin()
	
	-- 竞拍期不可以领取
	if Xkland:GetPeriod() == Xkland.PERIOD_COMPETITIVE then
		Dialog:Say("只有等今日的竞标结束后，才能领取竞标失败退还的金币。");
		return 0;
	end
	
	local nRectify = Xkland:RectifyCompCoin(me);
	if nRectify == 1 then
		Dialog:Say("您已竞标成功，可在铁浮城远征大将处领取返还的跨服绑银。");
		return 0;
	end
	
	-- 是否有金币可领
	local nComp = me.GetTask(Xkland.TASK_GID, Xkland.TASK_COMP_COIN);
	if nComp <= 0 then
		Dialog:Say("对不起，您没有金币可以领取。");
		return 0;
	end
	
	-- 金币解冻
	local nRet = me.UnFreezeCoin(nComp, Player.emKCOIN_FREEZE_XKLAND);
	if nRet ~= 1 then
		return 0;
	end
	
	me.Msg(string.format("你成功领取了<color=yellow>%s<color>金币。", nComp));
	
	-- 任务变量清0
	me.SetTask(Xkland.TASK_GID, Xkland.TASK_COMP_COIN, 0);
end

-- 领取金币
function tbNpc:GetBackMoney()
	
	if Xkland:GetPeriod() ~= Xkland.PERIOD_COMPETITIVE then
		Dialog:Say("只有竞标期才可以领取上届返还的跨服绑银。");
		return 0;
	end
	
	local nMoney = GetPlayerSportTask(me.nId, Xkland.GA_TASK_GID, Xkland.GA_TASK_WAR_BACKMONEY);
	if nMoney <= 0 then
		return 0;
	end
	
	local nCurrentMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney + nMoney > me.GetMaxCarryMoney() then
		Dialog:Say("对不起，你身上的跨服绑银即将超过上限，请使用后再来领取。");
		return 0;
	end
	
	-- 锁住玩家
	me.AddWaitGetItemNum(1);
	GCExcute({"Xkland:GetBackMoney_GC", me.szName});
end

-- 城战奖励相关
function tbNpc:ShowAllAward()
	local tbOpt =
	{
		{"查看胜方奖励", self.ShowCastleAward, self},
		{"领取胜方奖励", Xkland.GetCastleAward_GS, Xkland, me.szName},
		{"领取赏金", self.GetSingleAward, self},
		{"领取经验和威望", self.GetExtraAward, self},
		{"Ta hiểu rồi"},
	};
	Dialog:Say("这里可以查询胜利方奖励，也可以领取个人奖励。", tbOpt);
end

-- 领取积分奖励
function tbNpc:GetSingleAward()
	
	local nSingleBox = Xkland:CheckSingleAward(me);
	if nSingleBox <= 0 then
		return 0;
	end
	
	local szMsg = string.format("恭喜您！<enter>根据您的积分状况，可以领取<color=yellow>%s个卓越战功箱<color>！", nSingleBox);
	local tbOpt = 
	{
		{"确定领取", Xkland.GetSingleAward_GS, Xkland},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 领取经验威望
function tbNpc:GetExtraAward()

	local nExtraAward = Xkland:CheckExtraAward(me);
	if nExtraAward <= 0 then
		return 0;
	end
	
	local nRepute = (nExtraAward >= 500) and 50 or 0;
	local szMsg = string.format("恭喜您！<enter>根据您的积分状况，可以领取<color=yellow>%s万<color>经验，<color=yellow>%s点<color>威望！", nExtraAward, nRepute);
	local tbOpt = 
	{
		{"确定领取", Xkland.GetExtraAward_GS, Xkland, nExtraAward, nRepute},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);	
end

-- 查看胜利方奖励
function tbNpc:ShowCastleAward()
	
	local szMsg = "请确认您要查看胜利方那种奖励。";
	local tbOpt = 
	{
		{"宝箱奖励", self.ShowCastleAwardEx, self, 1},
		{"令牌奖励", self.ShowCastleAwardEx, self, 2},		
		{"Ta hiểu rồi"}
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 查看胜利方奖励(类别)
function tbNpc:ShowCastleAwardEx(nType)
	
	if Xkland:GetPeriod() ~= Xkland.PERIOD_COMPETITIVE then
		Dialog:Say("对不起，现在无法查看胜方奖励。");
		return 0;
	end
	
	if Xkland:GetSession() == 1 then
		Dialog:Say("对不起，现在无法查看胜方奖励。");
		return 0;
	end
	
	local tbList = 
	{
		szLingXiuName = Xkland.tbLocalCastleBuffer.szPlayerName,
		nHoldTime = Xkland:GetOccupyTime(),
		nTotalPoint = 0,
		nType = nType,
	};
	local tbChengZhuAword = {Xkland.tbLocalCastleBuffer.nCastleBox, Xkland.tbLocalCastleBuffer.nLingPai};
	tbList.nTotalPoint = tbChengZhuAword[nType];
	
	tbList.tbTongInfo = {};
	for szTmpTongName, tbInfo in pairs(Xkland.tbLocalCastleBuffer.tbTong or {}) do
		local tbAword = {tbInfo.nBox, tbInfo.nLingPai};
		table.insert(tbList.tbTongInfo, {szTongName = szTmpTongName, szServer = tbInfo.szGateway, nCurPoint = tbAword[nType]});
	end

	me.CallClientScript({"UiManager:OpenWindow", "UI_DISTRIBUTE"});
	me.CallClientScript({"Ui:ServerCall", "UI_DISTRIBUTE", "DisableAll"});
	me.CallClientScript({"Ui:ServerCall", "UI_DISTRIBUTE", "OnRecvData", tbList});
end

-- 帮助对话
function tbNpc:WarHelp()
	
	local szMsg = "城主必须守卫铁浮城，时刻小心各大势力与英雄们结成的攻城军团。<enter>铁浮城宝座虚位以待，谁能坐得长久也未为可知……<enter><color=gold>更多请按F12-详细帮助-跨服城战<color>";
	local tbOpt = 
	{
		{"城战简介", self.OnWarHelp, self, 1},
		{"城战时间", self.OnWarHelp, self, 2},
		{"参加条件", self.OnWarHelp, self, 3},
		{"城战规则", self.OnWarHelp, self, 4},
		{"城战奖励", self.OnWarHelp, self, 5},
		{"常见问题", self.OnWarHelp, self, 6},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnWarHelp(nIndex)
	
	local szMsg = "";
	
	if nIndex == 1 then
		szMsg = [[
    世人从古图《清明上河图》中，发现了一座藏宝甚丰的古城，这座城池名叫“<color=yellow>铁浮城<color>”。一时间，江湖风云突变，英雄骤起，都只为这传说中的<color=yellow>铁浮城王座<color>而来……
    
    铁浮城争夺战已经拉开帷幕，<color=yellow>全区<color>的各路英雄豪杰们，请不要错过良机，各大主城的<color=yellow>铁浮城远征大将<color>将带您揭开跨服城战之序幕！
    
    <color=green>城战时间：<color><color=yellow>每周六、周三<color>
    <color=green>竞标条件：<color>
        等级达到<color=yellow>100级<color>、加入门派、装备有<color=yellow>雏凤<color>或雏凤以上披风的任意玩家。
    <color=green>参战方式：<color>
        1、符合竞标条件；
        2、加入帮会，且<color=yellow>所属帮会首领报名参战<color>，并由<color=yellow>军团领袖通过参战申请<color>。
    <color=green>相关NPC：<color><color=yellow>铁浮城远征大将<color>（城市）
    
<color=gold>详情请查阅F12帮助锦囊-详细帮助-跨服城战<color>
]];
	
	elseif nIndex == 2 then
		szMsg = [[
		
<color=green>【每周三开战】<color>
    竞标：<color=yellow>周日00:00 - 周一23:59<color>
    报名：<color=yellow>周二00:00 - 周三晚19:29<color>
    准备：<color=yellow>周三晚19:30 - 20:00<color>
    攻城：<color=yellow>周三晚20:00 - 21:29<color>
    分奖：<color=yellow>周三晚21:30 - 23:59<color>
    领奖：<color=yellow>周四00:00 - 23:59<color>

<color=green>【每周六开战】<color>
    竞标：<color=yellow>周四00:00 - 23:59<color>
    报名：<color=yellow>周五00:00 - 周六晚19:29<color>
    准备：<color=yellow>周六晚19:30 - 20:00<color>
    攻城：<color=yellow>周六晚20:00 - 21:29<color>
    分奖：<color=yellow>周六晚21:30 - 23:59<color>
    领奖：<color=yellow>周日00:00 - 下周一23:59<color>

注意：开启150等级上限后，开启跨服城战。
]];
		
	elseif nIndex == 3 then
		szMsg = [[
<color=green>竞标条件：<color>
    等级达到<color=yellow>100级<color>、加入门派、装备有<color=yellow>雏凤<color>或雏凤以上披风的任意玩家。
<color=green>参战方式：<color>
    1、等级达到<color=yellow>100级<color>、加入门派、装备有<color=yellow>雏凤<color>或雏凤以上披风方有资格。
    2、加入帮会，且<color=yellow>所属帮会首领报名参战<color>，并由<color=yellow>军团领袖通过参战申请<color>。
]];
	
	elseif nIndex == 4 then
		szMsg = [[
<color=green>【竞标期】<color>
    1、城主自动成为守城军团领袖。
    2、符合条件任意侠士在此竞标，建立军团。（<color=yellow>第一届为明标，之后为暗标<color>）
<color=green>【报名期】<color>
    1、军团领袖可在此设置赏金。<color=yellow>若不设置，则战后无赏金奖励<color>。
    2、帮会首领在此报名并加入军团，由军团首领<color=yellow>同意或者拒绝<color>参战申请。
    3、<color=yellow>军团领袖可替本军团成员支付征战费用。<color>
<color=green>【准备期】<color>
    1、在此进入英雄岛。
    2、19:30可从英雄岛的铁浮城传送人处进入铁浮城，30分钟时间准备。
<color=green>【攻打期】<color>
    1、20:00城战打响。
    2、攻击敌人、争夺资源点、占领王座可以获取积分。
    3、第一次出复活点、被重伤后从复活点再次出战，都需要缴纳一定跨服绑银（可由领袖设为免费）。
    4、若坐上王座，则本军团每分钟持续增加增加王座积分。
    5、城战结束，王座积分高的一方获胜。
<color=green>【分奖期】<color>
    1、城战结束当天，新城主分配奖励给各个公会，剩余奖励归城主所有。
    2、军团领袖此时可追加赏金。参战侠士可依据积分领取赏金宝箱奖励。
    3、众侠士可依据积分领取经验奖励，积分高者领取更多奖励与威望。
<color=green>【首次城战有何不同】<color>
    1、竞标为明标，且前6位均可建立军团。
    2、所有军团攻城，资源点无龙柱，复活点3无法争夺。军团成员死亡后选择随机复活点复活。
]];
		
	elseif nIndex == 5 then
		szMsg = [[
<color=green>【城主专属奖励】<color>
    称号：<color=yellow>铁浮城主·傲世凌天<color>
    购买以下物品的特权：<color=yellow>凌天披风、凌天神驹<color>

<color=green>【城主雕像】<color>
    跨服城战结束后，自动为城主在英雄岛以及凤翔战场竖立雄伟雕像。
    
<color=green>【城主勇士奖励】<color>
    称号：<color=gold>铁浮勇士·群雄逐日<color>
    购买以下物品的特权：<color=gold>逐日披风、逐日神驹<color>
    
<color=green>【辉煌战功箱】<color>
    辉煌战功箱（不绑定）由城主分配
    打开辉煌战功箱有机会获得<color=yellow>1~3级同伴装备碎片<color>！
    
<color=green>【赏金奖励】<color>
    赏金奖励可在战前以及战后由军团领袖设置。根据个人积分和赏金设置，可领取一定数量的卓越战功箱。
    打开卓越战功箱有机会获得<color=yellow>1~2级同伴装备碎片、7级及以上高级玄晶<color>！
    
<color=green>【同伴装备】<color>
    打开战功箱有机会获得<color=yellow>同伴装备碎片<color>！
    集齐50个同种碎片，即可在我这里换取一件完整的同伴装备。
    
<color=green>【经验和威望】<color>
    所有侠士在城战结束后于铁浮城大将处领取最低100W经验的奖励。依据积分多寡，还可领取到更多经验以及江湖威望奖励。
]];
		
	elseif nIndex == 6 then
		szMsg = [[
<color=green>问：为何我不能进入内城、王座？<color>
答：进入铁浮城最低披风等级：外围-雏凤、内城-潜龙、王座-至尊。

<color=green>问：攻击敌方有何好处？<color>
答：每次重伤敌方后都会获得一定的积分与跨服绑银，同时铁浮城军需库的绑银也会相应增加，铁浮城军需库越是丰足，城主可分配的战功箱越多。

<color=green>问：积分有何作用？<color>
答：若军团领袖设置赏金奖励，战后依据各侠士积分决定可以领取到赏金奖励的多少。并且积分多少会决定各位侠士最终获得的经验以及威望值。
    <color=yellow>注：只有积分排名进入赏金奖励设置排名范围内才可领取到赏金奖励。<color>

<color=green>问：如何查看详细战况？<color>
答：按<color=yellow> ~ 键<color>。

<color=gold>更多问题请查阅F12帮助锦囊-详细帮助-跨服城战<color>
]];		
	end
	
	Dialog:Say(szMsg, {"返回上一层", self.WarHelp, self});
end

-- 查询历届城主
function tbNpc:QueryCastleHistory(nFrom)
	
	local tbHistory = Xkland.tbLocalCastleBuffer.tbHistory;
	if not tbHistory then
		Dialog:Say("查询不到任何有关城主的记录。");
		return 0;
	end
	
	local tbOpt = {{"Ta hiểu rồi"}};
	local szMsg = "\n历届城主名单：\n\n";
	local nCount = 8;
	local nLast = nFrom or 1;
	for i = nLast, #tbHistory do
		local szSession = (i > 10) and string.format("%s届", Lib:Transfer4LenDigit2CnNum(i)) or string.format("第%s届", Lib:Transfer4LenDigit2CnNum(i));
		szMsg = szMsg .. string.format("<color=green>%s：<color=yellow>%s%s<color>\n", Lib:StrFillC(szSession, 8), Lib:StrFillC(tbHistory[i].szPlayerName, 17), Lib:StrFillC(ServerEvent:GetServerNameByGateway(tbHistory[i].szGateway), 8));
		nCount = nCount - 1;
		nLast = nLast + 1;
		if nCount <= 0 then
			table.insert(tbOpt, 1, {"Trang sau", self.QueryCastleHistory, self, nLast});
			break;
		end	
	end
	
	Dialog:Say(szMsg, tbOpt);
end

-------------------------------------------------------
-- 侠客岛接引npc
-------------------------------------------------------
function tbNpc:OnDialogLand()
	
	if Xkland:CheckIsOpen() ~= 1 or Xkland:CheckIsGlobal() ~= 1 then
		Dialog:Say("当日龙蛇归草莽，此时琴剑付高楼。");
		return 0;
	end
	
	local szMsg = "城战结束后，请新城主速来我这里分配奖励给各帮首领，也可追加赏金。<color=yellow>（城战当天21:30-23:59）<color>\n分配好后，请帮会首领回本服，找各大主城的铁浮城远征大将领取。<color=yellow>（下届城战结束前）<color>";
	local tbOpt = 
	{
		{"<color=yellow>我要进入铁浮城<color>", self.JoinWar, self},
		{"<color=yellow>城主分配奖励<color>", self.DistributeAward, self},
		{"设置本军团军需库", self.SetFreeRevival, self},
		{"查询各军团军需库", self.QueryFreeRevival, self},
		{"领取庆祝烟花", self.GetYanhua, self},
		{"Ta hiểu rồi"},
	};

	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:DistributeAward()
	
	local szMsg = "请确认您要分配什么奖励。";
	local tbOpt = 
	{
		{"<color=yellow>分配宝箱<color>", self.DistributeAwardEx, self, 1},
		{"<color=yellow>分配令牌<color>", self.DistributeAwardEx, self, 2},		
		{"Ta hiểu rồi"},
	};

	Dialog:Say(szMsg, tbOpt);
end

-- 进入比赛场
function tbNpc:JoinWar(nSure)
	
	-- 判断开战与否
	if Xkland:GetWarState() == 0 then
		Dialog:Say("铁浮城争夺战尚未开始，请届时前来参战。<enter><color=gold>详情按F12-详细帮助-跨服城战查询<color>");
		return 0;
	end
	
	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say("<color=yellow>您的等级不足。<color><enter>参战条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、所在帮会已加入军团。");
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say("<color=yellow>您还未加入门派。<color><enter>参战条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、所在帮会已加入军团。");
		return 0;
	end
	
	-- 判断披风(雏凤)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < Xkland.MANTLE_LEVEL then
		Dialog:Say("<color=yellow>此去极其凶险，你没有足以保护自己的披风，怎能匆忙应战？<color><enter>参战条件：<enter>    1、等级达到100级、已加入门派；<enter>    2、装备有雏凤或以上的披风；<enter>    3、所在帮会已加入军团。");
		return 0;	
	end
	
	-- 帮会名字
	local szTongName = me.GetTaskStr(Xkland.TASK_GID, Xkland.TASK_TONGNAME);
	
	-- 军团领袖
	local nCaptainIndex = ((Xkland:CheckCastleOwner(me.szName) == 1) and 1) or Xkland:GetCaptainIndex(me);
		
	-- 区服网关
	local szGateway = Transfer:GetMyGateway(me);
	
	-- 如果没有军团
	local szGroupName = League:GetMemberLeague(Xkland.LEAGUE_TYPE, me.szName);
	if not szGroupName then
		
		-- 如果是军团领袖，则直接检验
		if nCaptainIndex > 0 then
			GCExcute({"Xkland:OnPlayerJoinGroup_GA", me.szName, nTongGroupIndex, szGateway});
			
		else	
			-- 判断是否有帮会，无帮会不能参加
			if szTongName == "" then
				Dialog:Say("对不起，你没有加入帮会，无法参战。");
				return 0;
			else
				-- 有帮会，则判断帮会所有在军团
				local nTongGroupIndex = Xkland:GetGroupIndexByTongName(szTongName);
				
				-- 加入到帮会所在的军团
				if nTongGroupIndex > 0 then
					GCExcute({"Xkland:OnPlayerJoinGroup_GA", me.szName, nTongGroupIndex, szGateway});
					
				-- 否则不能参加
				else
					Dialog:Say("对不起，你无法参加本届跨服城战。");
					return 0;
				end
			end
		end
		
	-- 如果有军团
	else
		-- 跨服数据
		local nGroupIndex = Xkland:GetGroupIndex(me);
		
		-- 如果是军团领袖，则直接检验
		if nCaptainIndex > 0 then
			if nCaptainIndex ~= nGroupIndex then
				GCExcute({"Xkland:SetPlayerGroup_GA", me.szName, nCaptainIndex});
			end
		
		-- 不是军团领袖
		else
			-- 如果有帮会
			if szTongName ~= "" then
				
				-- 取帮会所在军团
				local nTongGroupIndex = Xkland:GetGroupIndexByTongName(szTongName);
				
				-- 如果帮会有军团
				if nTongGroupIndex > 0 then	
					
					-- 跨服数据不对
					if nTongGroupIndex ~= nGroupIndex then
						GCExcute({"Xkland:SetPlayerGroup_GA", me.szName, nTongGroupIndex});
					end
				end
			end
		end
	end
	
	-- 二次确定，为了缓冲时间
	if not nSure then
		local szMsg = "即将进入铁浮城外围，确定进入么？";
		local tbOpt = 
		{
			{"Xác nhận", self.JoinWar, self, 1};
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	-- 跨服数据
	local nGroupIndex = Xkland:GetGroupIndex(me);
		
	-- 第一届传送至索引复活点
	if Xkland:GetSession() == 1 then
		if Xkland.REVIVAL_POS_INDEX[nGroupIndex] then
			me.SetTask(Xkland.TASK_GID, Xkland.TASK_LAND_ENTER, 1);
			me.NewWorld(unpack(Xkland.REVIVAL_POS_INDEX[nGroupIndex]));
		else
			Dialog:Say("系统错误，请联系客服处理。");
			return 0;
		end	
	else
		local nRand = MathRandom(1, 3);
		if Xkland.REVIVAL_POS_WAR[nGroupIndex] then
			me.SetTask(Xkland.TASK_GID, Xkland.TASK_LAND_ENTER, 1);
			me.NewWorld(unpack(Xkland.REVIVAL_POS_WAR[nGroupIndex][nRand]));
		else
			Dialog:Say("系统错误，请联系客服处理。");
			return 0;
		end
	end
end

-- 设置免费复活次数
function tbNpc:SetFreeRevival()

	if Xkland:CheckFreeRevival(me) ~= 1 then
		return 0;
	end
	
	local nCaptainIndex = Xkland:GetCaptainIndex(me);
	local nRevivalMoney = Xkland.tbWarBuffer[nCaptainIndex].nRevivalMoney or 0;
	local tbFreeRevival = Xkland.tbWarBuffer[nCaptainIndex].tbFreeRevival or {};
	local nCastleMoney = Xkland.tbCastleBuffer.nCastleMoney or 0;
	
	local szMsg = string.format([[
	下面可以设置本军团的军需库绑银和成员的免费征战次数。（城主将优先取铁浮城军需库中的<color=yellow>%s两<color>投入到本军团军需库中）
	
	<color=yellow>本军团的军需库绑银为：%s两
	
	%s - %s次
	%s - %s次
	%s - %s次
	%s - %s次<color>
]], nCastleMoney, nRevivalMoney,
	Xkland.MANTLE_TYPE[7], tbFreeRevival[7] or 0,
	Xkland.MANTLE_TYPE[8], tbFreeRevival[8] or 0,
	Xkland.MANTLE_TYPE[9], tbFreeRevival[9] or 0,
	Xkland.MANTLE_TYPE[10], tbFreeRevival[10] or 0
);

	local tbOpt =
	{
		{"增加本军团军需库绑银", self.AddFreeRevivalMoney, self},
		{"设置免费征战次数", self.SetMantleFreeRevival, self},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 增加免费复活基金
function tbNpc:AddFreeRevivalMoney()
	Dialog:AskNumber("请输入跨服绑银：", Xkland.MAX_FREE_REVIVAL, Xkland.AddFreeRevival_GS, Xkland);
end

-- 设置披风等级复活次数
function tbNpc:SetMantleFreeRevival()
	
	if Xkland:CheckFreeRevival(me) ~= 1 then
		return 0;
	end
	
	local szMsg = "这里可以设置每个披风等级的免费征战次数。<enter><color=gold>在次数限制内，若成员需要再次出战，则优先扣除本军团军需库中的绑银，次数用完或军需库扣完为止。<color>";
	local tbOpt = 
	{
		{Xkland.MANTLE_TYPE[7], self.OnSetMantleFreeRevival, self, 7},
		{Xkland.MANTLE_TYPE[8], self.OnSetMantleFreeRevival, self, 8},
		{Xkland.MANTLE_TYPE[9], self.OnSetMantleFreeRevival, self, 9},
		{Xkland.MANTLE_TYPE[10], self.OnSetMantleFreeRevival, self, 10},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnSetMantleFreeRevival(nType)
	Dialog:AskNumber("请输入免费次数：", 10, Xkland.SetMantleRevival_GS, Xkland, nType);
end

-- 查询免费复活相关
function tbNpc:QueryFreeRevival()

	local szMsg = "这里可以查询各个军团的军需库与免费征战次数的设置。<enter><color=gold>在次数限制内，若成员需要再次出战，则优先扣除本军团军需库中的绑银，次数用完或军需库扣完为止。<color>";
	local tbOpt = {};
	for nGroupIndex, tbInfo in pairs(Xkland.tbGroupBuffer) do
		tbOpt[nGroupIndex] = {tbInfo.szGroupName, self.OnQueryFreeRevival, self, tbInfo.szGroupName, nGroupIndex};
	end
	table.insert(tbOpt, {"Ta hiểu rồi"});
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnQueryFreeRevival(szGroupName, nGroupIndex)
	
	if not Xkland.tbWarBuffer[nGroupIndex] then
		Dialog:Say("查询不到该军团的军需库资料。");
		return 0;
	end	
	
	local nRevivalMoney = Xkland.tbWarBuffer[nGroupIndex].nRevivalMoney or 0;
	local tbFreeRevival = Xkland.tbWarBuffer[nGroupIndex].tbFreeRevival or {};
	
	local szMsg = string.format([[

	<color=cyan>%s<color>
	
	<color=yellow>军团的军需库绑银为：%s两
	
	%s - %s次
	%s - %s次
	%s - %s次
	%s - %s次<color>
]], szGroupName, nRevivalMoney,
	Xkland.MANTLE_TYPE[7], tbFreeRevival[7] or 0,
	Xkland.MANTLE_TYPE[8], tbFreeRevival[8] or 0,
	Xkland.MANTLE_TYPE[9], tbFreeRevival[9] or 0,
	Xkland.MANTLE_TYPE[10], tbFreeRevival[10] or 0
);

	Dialog:Say(szMsg);
end

-- 城主分配奖励
function tbNpc:DistributeAwardEx(nType)
	
	if Xkland:CheckCastleOwner(me.szName) ~= 1 then
		Dialog:Say("对不起，只有城主才能分配奖励");
		return 0
	end
	
	if Xkland:GetPeriod() ~= Xkland.PERIOD_WAR_REST then
		Dialog:Say("对不起，只有在城战结束后当天（21:30-23:59），才能分配奖励。");
		return 0;
	end
	
	if not nType then
		return 0;
	end
	
	local tbAwardType = {Xkland.tbCastleBuffer.nCastleBox, Xkland.tbCastleBuffer.nLingPai};
	
	local tbList = 
	{
		szLingXiuName = Xkland.tbCastleBuffer.szPlayerName,
		nHoldTime = Xkland:GetOccupyTime(),
		nTotalPoint = tbAwardType[nType],
		nType = nType,
	};
	
	tbList.tbTongInfo = {};
	for szTmpTongName, tbInfo in pairs(Xkland.tbCastleBuffer.tbTong or {}) do
		table.insert(tbList.tbTongInfo, {szTongName = szTmpTongName, szServer = tbInfo.szGateway});
	end

	me.CallClientScript({"UiManager:OpenWindow", "UI_DISTRIBUTE"});
	me.CallClientScript({"Ui:ServerCall", "UI_DISTRIBUTE", "OnRecvData", tbList});
end

-- 领取庆祝烟花
function tbNpc:GetYanhua()
	
	if Xkland:GetPeriod() ~= Xkland.PERIOD_WAR_REST then
		Dialog:Say("对不起，只有城战结束的当晚可以领取庆祝烟花。");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请留出至少一格背包空间再来领取");
		return 0;
	end
	
	me.AddItem(unpack(Xkland.YANHUA_ID));
end

-------------------------------------------------------
-- 复活点车夫
-------------------------------------------------------
function tbNpc:OnDialogChefu()
	
	local szMsg = "铁浮城太危险了，我可以带你回英雄岛。";
	local tbOpt = 
	{
		{"设置本军团军需库", self.SetFreeRevival, self},
		{"查询各军团军需库", self.QueryFreeRevival, self},
		{"返回英雄岛", self.ReturnLand, self},
		{"Ta hiểu rồi"},
	};
	
	if Xkland:GetSession() ~= 1 then
		table.insert(tbOpt, 2, {"传送至本方复活点", self.TransOtherRevival, self});
	end
		
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ReturnLand()
	Transfer:NewWorld2GlobalMap(me);
end

function tbNpc:TransOtherRevival()
	local nGroupIndex = Xkland:GetGroupIndex(me);
	local szMsg = "本方复活点列表";
	local tbOpt = {};
	for nIndex, tbPos in pairs(Xkland.REVIVAL_POS_WAR[nGroupIndex] or {}) do
		table.insert(tbOpt, {Xkland.MAP_NAME[tbPos[1]], self.DoTransOtherRevival, self, tbPos});
	end
	if Xkland:GetRevivalOwner(me.nMapId) == nGroupIndex then
		for nIndex, tbPos in pairs(Xkland.REVIVAL_POS_WAR[3] or {}) do
			if tbPos[1] == me.nMapId then
				table.insert(tbOpt, {"争夺复活点", self.DoTransOtherRevival, self, tbPos});
			end
		end	
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:DoTransOtherRevival(tbPos)
	me.NewWorld(unpack(tbPos));
end

-------------------------------------------------------
-- 复活点商人
-------------------------------------------------------
function tbNpc:OnDialogTrader()
	me.OpenShop(164,7);
end

-------------------------------------------------------
-- 兑换同伴装备
-------------------------------------------------------

-- 装备碎片与同伴装备的兑换关系
tbNpc.tbExchangeInfo = 
{	
	--碎片的p值， 同伴装备的G，D，P，L
	[941] = {5, 19, 1, 1},
	[942] = {5, 19, 1, 2},
	[943] = {5, 19, 1, 3},
	[944] = {5, 20, 1, 1},
	[945] = {5, 20, 1, 2},
	[946] = {5, 20, 1, 3},
	[947] = {5, 23, 1, 1},
	[948] = {5, 23, 1, 2},
	[949] = {5, 23, 1, 3}
}

-- 体服环境特殊需求
-- 第一步选取要换取的装备等级
-- 第二步放入对应类型对应数量的装备碎片
-- 第三步对放入的碎片类型和数量进行匹配判断
-- 第四步删除要兑换的碎片并添加对应的同伴装备
function tbNpc:ExchangePartnerEq(nStep, nLevel, tbItemObj, tbAddItemInfo)
	
	nStep = nStep or 1;
	nLevel = nLevel or 0;
	
	local tbLevelInfo = 
	{
		[1] = "Bích Huyết",
		[2] = "Kim Lân",
		[3] = "Đơn Tâm",
	}
	local szLevel = tbLevelInfo[nLevel] or "";
	
	local szMsg, tbOpt = "", {};
	if nStep == 1 then
		
		szMsg = "Mở Rương Chiến Công Trác Việt hoặc Rương Chiến Công Huy Hoàng có cơ hội thu được mảnh trang bị đồng hành, ngươi muốn đổi loại nào?"
		tbOpt = 
		{
			-- 响应操作，进入第二步
			{"Trang bị Bích Huyết", self.ExchangePartnerEq, self, 2, 1},	
			{"Trang bị Kim Lân",	self.ExchangePartnerEq, self, 2, 2},
			{"Trang bị Đơn Tâm", self.ExchangePartnerEq, self, 2, 3},
			{"Ta chỉ xem qua thôi"}
		};
		Dialog:Say(szMsg, tbOpt);
		
	elseif nStep == 2 then
		
		if nLevel < 1 or nLevel > 3 then
			return;
		end
		
		-- 玩家点击确定按钮进入第三步
		szMsg = "Mở Rương Chiến Công Trác Việt hoặc Rương Chiến Công Huy Hoàng có cơ hội thu được mảnh trang bị đồng hành, ";
		szMsg = szMsg..string.format("<color=green>có thể đổi %s Chi Nhẫn, %s Chiến Y, %s Hộ Thân Phù.", szLevel, szLevel, szLevel);
		szMsg = szMsg.."<color> Mỗi trang bị cần <color=red>100 mảnh trang bị tương ứng<color>.";
		Dialog:OpenGift(szMsg, nil, {self.ExchangePartnerEq, self, 3, nLevel});	
		
	elseif nStep == 3 then
		
		szMsg, tbOpt = self:GetPartnerEquipExchangeInfo(tbItemObj, nLevel);
		Dialog:Say(szMsg, tbOpt);
		
	elseif nStep == 4 then
		
		local nToDelCount = 100;	-- 要扣除的碎片数量
		local szSuiPianName = "";
		for i, tbItem in pairs(tbItemObj) do
			local pItem = tbItem[1];
			if szSuiPianName == "" then
				szSuiPianName = pItem.szName;
			end
			
			if (pItem.nCount > nToDelCount) then
				
				-- 扣除成功才计数
				if (pItem.SetCount(pItem.nCount - nToDelCount, Item.emITEM_DATARECORD_REMOVE) == 1) then
					nToDelCount = 0;
				end
			else
				-- 扣除成功才计数
				local nCount = pItem.nCount;
				if (me.DelItem(tbItem[1], Player.emKLOSEITEM_EXCHANGE_PARTEQ) == 1) then
					nToDelCount = nToDelCount - nCount;
				end
			end
			
			-- 只扣除50个
			if nToDelCount <= 0 then
				break;
			end
		end	
		
		if nToDelCount <= 0 then	-- 50个碎片扣除成功才能添加装备
			me.AddItem(unpack(tbAddItemInfo));		-- 添加同伴装备
			me.Msg(string.format("恭喜！你获得了一件%s！", KItem.GetNameById(unpack(tbAddItemInfo))));
			-- log
			Dbg:WriteLog("Xkland", "跨服城战", me.szAccount, me.szName, string.format("兑换同伴装备：%s", KItem.GetNameById(unpack(tbAddItemInfo))));
			
		elseif nToDelCount < 100 then	-- 扣除了不足50个碎片，玩家有亏损，记个LOG
			Dbg:WriteLog(string.format("玩家%s用碎片兑换同伴装备失败，扣除了%s%d个！", me.szName, 
				szSuiPianName, 100 - nToDelCount));
		end
	end	
end

-- 获得碎片与装备之间的兑换关系
function tbNpc:GetPartnerEquipExchangeInfo(tbItemObj, nLevel)
	
	local nCount = 0;		-- 碎片数量
	local nParticular = 0;	-- 碎片的P值
	local szMsg, tbOpt = "", {};
	
	for i, tbItem in pairs(tbItemObj) do
		local pItem = tbItem[1];
		
		-- 放入了非法物品
		if not self.tbExchangeInfo[pItem.nParticular] or self.tbExchangeInfo[pItem.nParticular][4] ~= nLevel then
			szMsg = "<color=red>您放入的物品不对<color>，每件装备需要50个对应的装备碎片。";
			break;
		elseif nParticular ~= pItem.nParticular then
			if nParticular == 0 then
				nParticular = pItem.nParticular;
			else
				szMsg = "一次只能换取一件同伴装备，所以请只放入一种类型的装备碎片！";
				break;
			end
		end
		
		nCount = nCount + pItem.nCount;
	end

	if nCount < 50 and szMsg == "" then
		szMsg = "<color=red>您放入的物品数量不足<color>, 每件装备需要50个对应的装备碎片。";
	end

	-- 如果到这里，说明可以交换
	if szMsg == "" then
		szMsg = string.format("你确定要用50个%s换取<color=red>%s<color>", 
			KItem.GetNameById(18, 1, nParticular, 1), 
			KItem.GetNameById(unpack(self.tbExchangeInfo[nParticular]))
		);
		tbOpt = 
		{
			{"我确定", self.ExchangePartnerEq, self, 4, nLevel, tbItemObj, self.tbExchangeInfo[nParticular]},
			{"Để ta suy nghĩ thêm"}
		}
	end
	
	return szMsg, tbOpt;
end

-------------------------------------------------------
-- 城主侍卫任务
-------------------------------------------------------

tbNpc.TASK_GID 				= 1025;			-- 令牌任务组ID
tbNpc.TASK_CHENGZHU_SHOP 	= 17;			-- 开启城主商店
tbNpc.TASK_SHIWEI_SHOP		= 18;			-- 开启侍卫商店
tbNpc.TASK_IS_FINSH 		= 19;			-- 城主交和氏璧的数目是否够200(0 or 1)
tbNpc.TASK_GID_CCHENGZHU	= 2125			-- 城主令牌任务交和氏璧任务组
tbNpc.TASK_ALREADY_NUM 		= 21			-- 城主交和氏璧的数目
tbNpc.NeedNum 				= 10;			-- 需要的和氏璧数目
tbNpc.szItemGDPL 			= "18,1,377,1";	-- 和氏璧GDPL
tbNpc.nTaskID 				= 471;			-- 城主任务ID
tbNpc.tbShop 				= {173, 174};	-- 侍卫马店173，城主马店174

function tbNpc:OnDialogTask()
	local szMsg = "亦狂亦侠真名士，能哭能歌迈俗流！";
	local tbOpt = 
	{		
		{"Ta hiểu rồi"},
	};
	
	if me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 then		
		table.insert(tbOpt, 1, {"我要购买勇士披风", self.GetPiFengAward, self, 2});
	end
	if me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 then		
		table.insert(tbOpt, 1, {"我要购买城主披风", self.GetPiFengAward, self, 1});
	end
	if me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 and
		me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 then
		szMsg = szMsg.."\n你在我这里可以购买<color=yellow>城主及勇士<color>披风。";
	elseif me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 then
		szMsg = szMsg.."\n你已经获得购买<color=yellow>勇士<color>披风的资 ô.";
	elseif me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 then
		szMsg = szMsg.."\n你已经获得购买<color=yellow>城主<color>披风的资 ô.";
	end
	
	local nLevel,nState,nTime =  me.GetSkillState(1629);
	if nLevel == 1 and nTime > 0 then
		szMsg = szMsg.."\n你已经获得购买<color=yellow>逐日<color>神驹的资 ô.";
		table.insert(tbOpt, 1, {"我要购买逐日神驹", self.OpenHorseShop, self, 1});
	elseif nLevel == 2 and nTime > 0 then
		szMsg = szMsg.."\n你已经获得购买<color=yellow>凌天<color>神驹的资 ô.";
		table.insert(tbOpt, 1, {"我要购买凌天神驹", self.OpenHorseShop, self, 2});
	end
	
	if Task:GetPlayerTask(me).tbTasks[self.nTaskID] and Task:GetPlayerTask(me).tbTasks[self.nTaskID].nCurStep == 5 then
		szMsg = "\n这里可以上交和氏璧，完成<color=yellow>凯旋铁浮城<color>任务。"..szMsg;
		table.insert(tbOpt, 1, {"<color=yellow>上交和氏璧<color>", self.HandInHeshibi, self});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OpenHorseShop(nLevel)
	me.OpenShop(self.tbShop[nLevel], 3);
end

function tbNpc:GetPiFengAward(nId)
	if me.GetTask(self.TASK_GID, self.TASK_CHENGZHU_SHOP) == 1 and nId == 1 then		
		me.OpenShop(172, 3);
	end
	if me.GetTask(self.TASK_GID, self.TASK_SHIWEI_SHOP) == 1 and nId == 2  then
		me.OpenShop(171, 3);
	end	
end

function tbNpc:HandInHeshibi()
	if not Task:GetPlayerTask(me).tbTasks[self.nTaskID] and Task:GetPlayerTask(me).tbTasks[self.nTaskID].nCurStep == 5 then
		Dialog:Say("你没有<color=yellow>凯旋铁浮城<color>这个任务是不能上交和氏璧的！", {"知道了"});	
		return 0;
	end
	if me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM) >= self.NeedNum then
		Dialog:Say("你上交的和氏璧已经够了！", {"知道了"});	
		return 0;
	end
	local nCount = me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM);
	local szContent = string.format("请放入要上交的和氏璧\n您已经上交了%s个和氏璧了，还需要上交%s个。", nCount, self.NeedNum - nCount);
	Dialog:OpenGift(szContent, nil, {self.OnOpenGiftOk, self});
end

function tbNpc:OnOpenGiftOk(tbItemObj)
	local nAlreadyCount = me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM);
	local nNeedCount = self.NeedNum - nAlreadyCount;
	for _, tbItem in pairs(tbItemObj) do
		local szItemInfo = string.format("%s,%s,%s,%s", tbItem[1].nGenre, tbItem[1].nDetail, tbItem[1].nParticular, tbItem[1].nLevel);
		if szItemInfo ~= self.szItemGDPL then
			Dialog:Say("你放的物品不对!", {"知道了"});
			return 0;
		end
	end
	local nCount = 0;
	for _, tbItem in pairs(tbItemObj) do
		nCount = nCount + tbItem[1].nCount;
	end
	if nNeedCount < nCount then
		Dialog:Say("你交的和氏璧太多了！", {"知道了"});
		return 0;
	end
	for _, tbItem in pairs(tbItemObj) do
		tbItem[1].Delete(me);
	end
	me.SetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM, me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM) + nCount);
	if me.GetTask(self.TASK_GID_CCHENGZHU, self.TASK_ALREADY_NUM) >= self.NeedNum then
		me.SetTask(self.TASK_GID, self.TASK_IS_FINSH, 1);
	end
	EventManager:WriteLog(string.format("[铁浮城城主令牌任务]上交和氏璧%s", nCount), me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[铁浮城城主令牌任务]上交和氏璧%s", nCount));	
end
