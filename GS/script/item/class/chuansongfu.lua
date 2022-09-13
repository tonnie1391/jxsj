Require("\\script\\task\\armycamp\\item\\army_token.lua");

-- 传送符

local tbChuangsongfu = Item:GetClass("chuansongfu");

tbChuangsongfu.nTime = 10;			-- 延时的时间(秒)
tbChuangsongfu.HORSE_SKILLID = 1417;

-- UNDONE: zbl	临时写法,以后改为判断配置表格参数
tbChuangsongfu.tbTransItemId = { 
	[3] ={"tbHomeMap", 1}, 	--有限新手村
	[4] ={"tbCityMap", 1},	--有限城市
	[19]={"tbGenreMap", 1}, --有限门派
	[20]={"tbHomeMap", 0},  --无限新手村
	[21]={"tbCityMap", 0}, 	--无限城市
	[22]={"tbGenreMap", 0}, --无限门派
	[55]={"tbHomeMap", 1},  --有限新手村
};	-- 各种传送符的Id

tbChuangsongfu.tbNewTransItem = {[195] = 0, [235] = 0}; --无限传送符

-- 去新手村的传送符
tbChuangsongfu.tbHomeMap	=
{
	["Vân Trung Trấn"]	= { 1, 1389, 3102 },
 	["Vĩnh Lạc Trấn"]	= { 3, 1693, 3288 },
 	["Thạch Cổ Trấn"]	= { 6, 1572, 3106 },
 	["Long Tuyền Thôn"]	= { 7, 1510, 3268 },
 	["Long Môn Trấn"]	= { 2, 1785, 3586 },
	["Giang Tân Thôn"]	= { 5, 1597, 3131 },
	["Đạo Hương Thôn"]	= { 4, 1624, 3253 },
 	["<color=yellow>Ba Lăng Huyện [Tiến]<color>"]	= { 8, 1721, 3381 },
};

-- 去城市的传送符
tbChuangsongfu.tbCityMap =
{
 	["Dương Châu Phủ"]	= { 26, 1641, 3129 },
	["Tương Dương Phủ"]	= { 25, 1630,	3169 },
 	["Lâm An Phủ"]	= { 29, 1605, 3946 },
	["Phượng Tường Phủ"]	= { 24, 1767, 3540 },
 	["Đại Lý Phủ"]	= { 28, 1439, 3366 },
 	["Thành Đô Phủ"]	= { 27, 1666,	3260 },
 	["Biện Kinh Phủ"]	= { 23, 1486,	3179 },
};

-- 去门派的传送符
tbChuangsongfu.tbGenreMap =
{
	["Võ Đang Phái"]	= { 14, 1435, 2991 },
 	["Ngũ Độc Giáo"]	= { 20, 1574, 3145 },
 	["Thiên Vương Bang"]	= { 22, 1663, 3039 },
	["Thiên Nhẫn Giáo"]	= { 10, 1658, 3324 },
 	["Đường Môn"]	= { 18, 1633, 3179 },
 	["Thiếu Lâm Phái"]	= {  9, 1702, 3093 },
 	["Côn Lôn Phái"]	= { 12, 1700, 3080 },
 	["Cái Bang"]	= { 15, 1606, 3245 },
	["Nga My Phái"]	= { 16, 1584, 3041 },
 	["Thúy Yên Môn"]	= { 17, 1487, 3093 },
 	["Đại Lý Đoàn Thị"]= { 19, 1618, 3120 },
 	["Minh Giáo"]	= { 224, 1625, 3181 },
 	["Cổ Mộ Phái"]	= { 2261, 1733,3054 },
};

tbChuangsongfu.tbBaihutang =
{
 	["Báo danh Dương Châu"]	= { 26, 1454, 3220 },
	["Báo danh Tương Dương"]	= { 25, 1596, 3258 },
 	["Báo danh Lâm An"]	= { 29, 1691, 3899 },
	["Báo danh Phượng Tường"]	= { 24, 1841, 3395 },
 	["Báo danh Đại Lý"]	= { 28, 1549, 3242 },
 	["Báo danh Thành Đô"]	= { 27, 1593, 3117 },
 	["Báo danh Biện Kinh"]	= { 23, 1568,	3162 },
};

tbChuangsongfu.tbXiaoyaogu =
{
 	["Báo danh Biện Kinh"]	= { 23, 1460,3081},
 	--["自动组队"]		= "AutoTeam:OpenUi",	--string为CallClientScript的目标table名，后续逻辑中需要判断value的type来分情况执行
};

tbChuangsongfu.tbSuperBattle =
{
	["Báo danh Tương Dương"] = {25, 1638, 3300},
	["Báo danh Biện Kinh"] = {23, 1680, 3090},
};

tbChuangsongfu.tbBaseMap	= {};	-- 基础地图，可直接传送到的地图（会被其它模块调用）

function tbChuangsongfu:Init()
	-- 军营地图
	local tbArmyMap	= {};
	for _, tbPosInfo in ipairs(Item:GetClass("army_token").tbTransMap) do
		tbArmyMap[tbPosInfo[1]]	= {unpack(tbPosInfo, 2)};
	end

	-- 无限传送符可以到达的所有“基础”地图
	-- （白虎、宋金、逍遥情况比较复杂，没有划为基础地图）
	local tbMapSet	= {
		self.tbHomeMap,		-- 新手村
		self.tbCityMap,		-- 城市
		self.tbGenreMap,	-- 门派
		tbArmyMap,			-- 军营
	};
	self.tbBaseMap	= {};
	for _, tbPosSet in ipairs(tbMapSet) do
		for szName, tbPos in pairs(tbPosSet) do
			if type(tbPos) == "table" then
				self.tbBaseMap[tbPos[1]]	= {
					szName	= szName,
					nMapId	= tbPos[1],
					nX		= tbPos[2],
					nY		= tbPos[3],
				}
			end
		end
	end
end

function tbChuangsongfu:OnUse()
	if self.tbNewTransItem[it.nParticular] then
		local szMsg = "Muốn đi đâu thì đi!<pic=48>";
		local tbOpt = {
			{"Tân Thủ Thôn", self.OnTransItem, self, it, self.tbHomeMap, self.tbNewTransItem[it.nParticular]},
			{"Thành thị", self.OnTransItem, self, it, self.tbCityMap, self.tbNewTransItem[it.nParticular]},
			{"Môn phái", self.OnTransItem, self, it, self.tbGenreMap, self.tbNewTransItem[it.nParticular]},
			{"Bạch Hổ Đường", self.OnTransItem, self, it, self.tbBaihutang, self.tbNewTransItem[it.nParticular]},
			{"Mông Cổ-Tây Hạ", self.OnTransBattle, self, it.dwId},
			{"Tiêu Dao Cốc", self.OnTransItem, self, it, self.tbXiaoyaogu, self.tbNewTransItem[it.nParticular]},
			{"Quân doanh",  self.OnTransArmyCamp, self, it.dwId},
			-- {"<color=yellow>Tống Kim liên Server<color>", self.OnTransItem, self, it, self.tbSuperBattle, self.tbNewTransItem[it.nParticular]},
		}
		
		-- local nSkillLevel = me.GetSkillState(self.HORSE_SKILLID);
		-- if (nSkillLevel > 0) then
			local nIndex = Map.tbChuanSongMapInfo.tbMapIndex["Khu vực luyện công"];
			local tbSubMap = Map.tbChuanSongMapInfo.tbSubMap[nIndex];
			table.insert(tbOpt, #tbOpt + 1, {"<color=yellow>Khu vực luyện công<color>", self.OnTransItemEx, self, it, tbSubMap, self.tbNewTransItem[it.nParticular]});
		-- end

		if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH and me.nFightState == 0 then
			table.insert(tbOpt, {"<color=yellow>[Quan chiến] Tứ kết liên đấu<color>", Wlls.OnLookDialog, Wlls});	
		end
		if HomeLand:GetMapIdByPlayerId(me.nId) > 0 and me.nFightState == 0 then
			table.insert(tbOpt, {"<color=yellow>Lãnh địa gia tộc<color>", self.OnTransHomeLand, self});	
		end
		table.insert(tbOpt, #tbOpt + 1, {"Để ta suy nghĩ đã"});
		
		Dialog:Say(szMsg, tbOpt)
		return 0;
	end
	if not self.tbTransItemId[it.nParticular] then
		return 0;
	end
	self:OnTransItem(it, self[self.tbTransItemId[it.nParticular][1]], self.tbTransItemId[it.nParticular][2]);
	return 0;	-- OnUse函数中返回0不删除;返回1表示删除
end

function tbChuangsongfu:OnTransHomeLand()
	local tbOpt = 
	{
		{"Đồng ý", HomeLand.EnterHomeLand, HomeLand},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say("确定前往家族领地吗？\n", tbOpt);
end

-- 功能:	点击传送符,选择所能到达的地方
-- 参数:	pItem		传送符这个对象
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	nIsLimit	标记是传送符还是无限传送符(nIsLimit=1表示当前使用的是普通传送符,nIsLimit=0则表示无限传送符)
-- 参数:	szFrom		当前这一页的关键字从szFrom的下一个选项开始
function tbChuangsongfu:OnTransItem(pItem, tbPosTb, nIsLimit, szFrom)
	local tbOpt		= {};
	local nCount	= 9;
	
	-- TODO: zbl 当一页存不下这些数据的时候的情况没有处理
	for szName, tbPos in next, tbPosTb, szFrom do
		local tbPerPos = tbPosTb[szName];
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang tiếp theo", self.OnTransItem, self, pItem, tbPosTb, nIsLimit, tbOpt[#tbOpt-1][1]};
			break;
		end
		tbOpt[#tbOpt+1]	= {szName, self.DelayTime, self, pItem, tbPerPos, nIsLimit, szName};
		nCount = nCount - 1;
	end
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("Muốn đi đâu thì đi!<pic=48>", tbOpt);
end

function tbChuangsongfu:OnTransItemEx(pItem, tbPosTb, nIsLimit, szFrom)
	local tbOpt		= {};

	if (not tbPosTb) then
		return;
	end

	if (tbPosTb.tbMapList and #tbPosTb.tbMapList > 0) then
		self:OnShowMapList(pItem, tbPosTb, 1, nIsLimit, szFrom);
		return;
	end
	
	if (not tbPosTb.tbMapIndex) then
		return;
	end
	
	if (not tbPosTb.tbSubMap) then
		return;
	end

	for i, tbPos in ipairs(tbPosTb.tbSubMap) do
		tbOpt[#tbOpt+1]	= {tbPos.szSubName, self.OnTransItemEx, self, pItem, tbPos, nIsLimit, szFrom};
	end

	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("Muốn đi đâu thì đi!<pic=48>", tbOpt);
end

function tbChuangsongfu:OnShowMapList(pItem, tbPosTb, nPage, nIsLimit, szFrom)
	local tbOpt		= {};
	local tbMapList	= tbPosTb.tbMapList;
	local nStart	= (nPage - 1) * 10 + 1;
	local nEnd		= nPage * 10;
	if (nEnd > #tbMapList) then
		nEnd = #tbMapList;
	end
	if (nPage > 1) then
		tbOpt[#tbOpt + 1] = {"Trước", self.OnShowMapList, self, pItem, tbMapList, nPage - 1, nIsLimit, szFrom};		
	end
	for i=nStart, nEnd do
		local szName	= tbMapList[i].szName;
		local tbPerPos	= {tbMapList[i].nMapId, tbMapList[i].nX, tbMapList[i].nY};
		local nFightState = tbMapList[i].nFightsSate;
		tbOpt[#tbOpt+1]	= {szName, self.DelayTime, self, pItem, tbPerPos, nIsLimit, szName, nFightState};
	end
	
	if (nEnd < #tbMapList) then
		tbOpt[#tbOpt + 1] = {"Sau", self.OnShowMapList, self, pItem, tbMapList, nPage + 1, nIsLimit, szFrom};
	end
	
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("Muốn đi đâu thì đi!<pic=48>", tbOpt);
end

-- 功能:	点击传送符后,玩家在战斗状态下将延时self.nTime(秒),否则不延时
-- 参数:	pItem		传送符这个对象
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	nIsLimit	是否为无限传送符
-- 参数:	szName		当前传送符所要传送过去的地方的名字
function tbChuangsongfu:DelayTime(pItem, tbPos, nIsLimit, szName, nFightState)
	if not me or not pItem then
		return;
	end
	local szForbitMap = KItem.GetOtherForbidType(unpack(pItem.TbGDPL()))
	local nCanUse = 1;
	if szForbitMap then
		nCanUse = KItem.CheckLimitUse(me.nMapId, szForbitMap);
	end
	if (not nCanUse or nCanUse == 0) then
		me.Msg("Đạo cụ này không được dùng ở đây!");
		return;
	end
	-- 玩家在非战斗状态下传送无延时正常传送
	-- 若是CallClientScript，则无延时直接call
	if 0 == me.nFightState or type(tbPos) == "string" then
		self:TransPlayer(pItem.dwId, tbPos, nIsLimit, szName, nFightState);
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
	GeneralProcess:StartProcess("Đang truyền tống...", self.nTime * Env.GAME_FPS, {self.TransPlayer, self, pItem.dwId, tbPos, nIsLimit, szName, nFightState}, nil, tbEvent);
end

-- 功能:	传送玩家
-- 参数:	pItem		传送符这个对象
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	nIsLimit	标记是普通传送符还是无限传送符(nIsLimit=1表示当前使用的是普通传送符,nIsLimit=0则表示无限传送符)
-- 参数:	szName		当前传送符所要传送过去的地方的名字
function tbChuangsongfu:TransPlayer(nItemId, tbPos, nIsLimit, szName)
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	if (nIsLimit == 1) then
		if (me.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			me.Msg("Hủy Truyền Tống Phù thất bại!");
			return;
		end
	end
	if type(tbPos) == "table" then
		me.Msg(string.format("Ngồi yên, %s!",szName));
		me.NewWorld(unpack(tbPos));
		if nFightState then
			me.SetFightState(nFightState);
		end
		Npc.tbFollowPartner:FollowNewWorld(me, unpack(tbPos));
	elseif type(tbPos) == "string" then
		me.CallClientScript({ tbPos });
	end
end

function tbChuangsongfu:OnTransBattle(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	Setting:SetGlobalObj(me, him, pItem);
	Item:GetClass("songjinzhaoshu"):OnUse();
	Setting:RestoreGlobalObj();
end

function tbChuangsongfu:OnTransArmyCamp(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	Setting:SetGlobalObj(me, him, pItem);
	Item:GetClass("army_token"):OnUse();
	Setting:RestoreGlobalObj();
end

-- 检查是否有无限传送符（会被其它模块调用）
function tbChuangsongfu:GetUnlimitedTrans()
	if me.IsInCarrier() == 1 then
		return;
	end
	
	for nParticular, nIsLimit in pairs(self.tbNewTransItem) do
		local tbItem	= me.FindItemInBags(18, 1, nParticular, 1)[1];
		if (tbItem and nIsLimit == 0) then
			return tbItem.pItem;
		end
	end
	-- 特权用户不用使用道具
	local nCurDate = tonumber(GetLocalDate("%y%m%d"));	
	if math.floor(me.GetTask(2038, 7)/100) >= math.floor(nCurDate/100) then
		return 1;
	end
	return nil;
end

-- 客户端发指令直接飞往某地图
function tbChuangsongfu:OnClientCall(nMapId)
	local pItem	= self:GetUnlimitedTrans();
	if (not pItem) then
		me.Msg("Vị đại hiệp này, hay là dùng 1 Truyền Tống Phù trước đi!");
		return;
	end
	local tbPos	= self.tbBaseMap[nMapId];
	if (not tbPos) then
		me.Msg("Nơi này không thể đến!");
		return;
	end
	if type(pItem) == "number" then -- 返回的是个数字则是特权用户
		SpecialEvent.tbTequan.tbChuansong:DelayTime({tbPos.nMapId, tbPos.nX, tbPos.nY}, tbPos.szName);
	else
		self:DelayTime(pItem, {tbPos.nMapId, tbPos.nX, tbPos.nY}, 0, tbPos.szName);
	end
end

tbChuangsongfu:Init()
