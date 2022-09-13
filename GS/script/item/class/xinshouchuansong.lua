-- 新手传送符
-- Edit：kenmasterwu

local tbXinshouchuansong = Item:GetClass("xinshouchuansong");

tbXinshouchuansong.nTime = 10;			-- 延时的时间(秒)


--设置一周有效期
function tbXinshouchuansong:InitGenInfo()
	it.SetTimeOut(0, (GetTime() + 7 * 24 * 60 * 60));
	return {};
end


-- 去新手村的传送符
tbXinshouchuansong.tbHomeMap	=
{
	["云中镇"]	= { 1, 1389, 3102 },
 	["永乐镇"]	= { 3, 1693, 3288 },
 	["石鼓镇"]	= { 6, 1572, 3106 },
 	["龙泉村"]	= { 7, 1510, 3268 },
 	["龙门镇"]	= { 2, 1785, 3586 },
	["江津村"]	= { 5, 1597, 3131 },
	["稻香村"]	= { 4, 1624, 3253 },
 	["巴陵县"]	= { 8, 1721, 3381 },
};


-- 去门派的传送符
tbXinshouchuansong.tbGenreMap =
{
	["武当派"]	= { 14, 1435, 2991 },
 	["五毒教"]	= { 20, 1574, 3145 },
 	["天王帮"]	= { 22, 1663, 3039 },
	["天忍教"]	= { 10, 1658, 3324 },
 	["唐门"]	= { 18, 1633, 3179 },
 	["少林派"]	= {  9, 1702, 3093 },
 	["昆仑派"]	= { 12, 1700, 3080 },
 	["丐帮"]	= { 15, 1606, 3245 },
	["峨嵋派"]	= { 16, 1584, 3041 },
 	["翠烟门"]	= { 17, 1487, 3093 },
 	["大理段氏"]	= { 19, 1618, 3120 },
 	["明教"]	= { 224, 1625, 3181 },
 	["古墓派"]	= { 2261, 1733,3054 },
};

--去绝问坡（新手传送符）
tbXinshouchuansong.tbJueWenPo	=
{
	["镇东墓园"]	= { 38, 1879, 3614 },
 	["潼关"]	= { 40, 1904, 3397 },
 	["茶马古道"]	= { 43, 1671, 3452 },
 	["铸剑坊"]	= { 44, 1899, 3653 },
 	["祁连山"]	= { 39, 1754, 3702 },
	["蜀南竹海"]	= { 42, 1729, 4036 },
	["淮水沙洲"]	= { 41, 1749, 3795 },
 	["岳阳楼"]	= { 45, 1878, 3311 },
};



function tbXinshouchuansong:OnUse()
		local szMsg = "想去哪就去哪！<pic=48>";
		local tbOpt = {
			{"新手村", self.OnTransItem, self, it, self.tbHomeMap, 0},
			{"门派", self.OnTransItem, self, it, self.tbGenreMap, 0},
			{"绝问坡", self.OnTransItem, self, it, self.tbJueWenPo, 0},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say(szMsg, tbOpt)
		return 0;
		
	-- OnUse函数中返回0不删除;返回1表示删除
end

-- 功能:	点击传送符,选择所能到达的地方
-- 参数:	pItem		传送符这个对象
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	nIsLimit	标记是传送符还是无限传送符(nIsLimit=1表示当前使用的是普通传送符,nIsLimit=0则表示无限传送符)
-- 参数:	szFrom		当前这一页的关键字从szFrom的下一个选项开始
function tbXinshouchuansong:OnTransItem(pItem, tbPosTb, nIsLimit, szFrom)
	local tbOpt		= {};
	local nCount	= 9;
	
	-- TODO: zbl 当一页存不下这些数据的时候的情况没有处理
	for szName, tbPos in next, tbPosTb, szFrom do
		local tbPerPos = tbPosTb[szName];
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.OnTransItem, self, pItem, tbPosTb, nIsLimit, tbOpt[#tbOpt-1][1]};
			break;
		end
		tbOpt[#tbOpt+1]	= {szName, self.DelayTime, self, pItem, tbPerPos, nIsLimit, szName};
		nCount = nCount - 1;
	end
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("想去哪就去哪！<pic=48>", tbOpt);
end

-- 功能:	点击传送符后,玩家在战斗状态下将延时self.nTime(秒),否则不延时
-- 参数:	pItem		传送符这个对象
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	nIsLimit	是否为无限传送符
-- 参数:	szName		当前传送符所要传送过去的地方的名字
function tbXinshouchuansong:DelayTime(pItem, tbPos, nIsLimit, szName)
	if (0 == me.nFightState) then				-- 玩家在非战斗状态下传送无延时正常传送
		self:TransPlayer(pItem.dwId, tbPos, nIsLimit, szName);
		return;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	GeneralProcess:StartProcess("正在传送...", self.nTime * Env.GAME_FPS, {self.TransPlayer, self, pItem.dwId, tbPos, nIsLimit, szName}, nil, tbEvent);
end

-- 功能:	传送玩家
-- 参数:	pItem		传送符这个对象
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	nIsLimit	标记是普通传送符还是无限传送符(nIsLimit=1表示当前使用的是普通传送符,nIsLimit=0则表示无限传送符)
-- 参数:	szName		当前传送符所要传送过去的地方的名字
function tbXinshouchuansong:TransPlayer(nItemId, tbPos, nIsLimit, szName)
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	local nRet, szMsg = Map:CheckTagServerPlayerCount(tbPos[1]);
	if nRet ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	if (nIsLimit == 1) then
		if (me.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			me.Msg("删除传送符失败！");
			return;
		end
	end
	me.Msg(string.format("坐好了，%s！",szName));
	me.NewWorld(unpack(tbPos));
end
