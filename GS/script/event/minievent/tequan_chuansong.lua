Require("\\script\\event\\minievent\\tequan.lua");

-- 传送符
SpecialEvent.tbTequan.tbChuansong = SpecialEvent.tbTequan.tbChuansong or {};
local tbTequanChuansong = SpecialEvent.tbTequan.tbChuansong;
local tbChuangsongfu = Item:GetClass("chuansongfu");

function tbTequanChuansong:OnUse()
	local szMsg = "想去哪就去哪！<pic=48>";
	local tbOpt = {
		{"新手村", self.OnTransItem, self, tbChuangsongfu.tbHomeMap},
		{"城市", self.OnTransItem, self, tbChuangsongfu.tbCityMap},
		{"门派", self.OnTransItem, self, tbChuangsongfu.tbGenreMap},
		{"白虎堂", self.OnTransItem, self, tbChuangsongfu.tbBaihutang},
		{"宋金战场", self.OnTransBattle, self},
		{"逍遥谷", self.OnTransItem, self, tbChuangsongfu.tbXiaoyaogu},
		{"伏牛山军营",  self.OnTransArmyCamp, self},
		{"<color=yellow>跨服宋金<color>", self.OnTransItem, self, tbChuangsongfu.tbSuperBattle},
	}
	
	local nSkillLevel = me.GetSkillState(tbChuangsongfu.HORSE_SKILLID);
	if (nSkillLevel > 0) then
		local nIndex = Map.tbChuanSongMapInfo.tbMapIndex["野外地图"];
		local tbSubMap = Map.tbChuanSongMapInfo.tbSubMap[nIndex];
		table.insert(tbOpt, #tbOpt + 1, {"<color=yellow>野外地图<color>", self.OnTransItemEx, self, tbSubMap});
	end

	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH and me.nFightState == 0 then
		table.insert(tbOpt, {"<color=yellow>【观战】联赛八强赛<color>", Wlls.OnLookDialog, Wlls});	
	end
	if HomeLand:GetMapIdByPlayerId(me.nId) > 0 and me.nFightState == 0 then
		table.insert(tbOpt, {"<color=yellow>家族领地<color>", tbChuangsongfu.OnTransHomeLand, tbChuangsongfu});	
	end
	table.insert(tbOpt, #tbOpt + 1, {"Để ta suy nghĩ lại"});
	
	Dialog:Say(szMsg, tbOpt)
	return 1;
end


-- 功能:	点击传送符,选择所能到达的地方
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	szFrom		当前这一页的关键字从szFrom的下一个选项开始
function tbTequanChuansong:OnTransItem(tbPosTb, szFrom)
	local tbOpt		= {};
	local nCount	= 9;
	
	-- TODO: zbl 当一页存不下这些数据的时候的情况没有处理
	for szName, tbPos in next, tbPosTb, szFrom do
		local tbPerPos = tbPosTb[szName];
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.OnTransItem, self, tbPosTb, tbOpt[#tbOpt-1][1]};
			break;
		end
		tbOpt[#tbOpt+1]	= {szName, self.DelayTime, self, tbPerPos, szName};
		nCount = nCount - 1;
	end
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("想去哪就去哪！<pic=48>", tbOpt);
end

function tbTequanChuansong:OnTransItemEx(tbPosTb, szFrom)
	
	local tbOpt		= {};

	if (not tbPosTb) then
		return;
	end

	if (tbPosTb.tbMapList and #tbPosTb.tbMapList > 0) then
		self:OnShowMapList(tbPosTb, 1, szFrom);
		return;
	end
	
	if (not tbPosTb.tbMapIndex) then
		return;
	end
	
	if (not tbPosTb.tbSubMap) then
		return;
	end

	for i, tbPos in ipairs(tbPosTb.tbSubMap) do
		tbOpt[#tbOpt+1]	= {tbPos.szSubName, self.OnTransItemEx, self, tbPos, szFrom};
	end

	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("想去哪就去哪！<pic=48>", tbOpt);
end

function tbTequanChuansong:OnShowMapList(tbPosTb, nPage, szFrom)
	local tbOpt		= {};
	local tbMapList	= tbPosTb.tbMapList;
	local nStart	= (nPage - 1) * 10 + 1;
	local nEnd		= nPage * 10;
	if (nEnd > #tbMapList) then
		nEnd = #tbMapList;
	end
	if (nPage > 1) then
		tbOpt[#tbOpt + 1] = {"Trang trước", self.OnShowMapList, self, tbMapList, nPage - 1, szFrom};		
	end
	for i=nStart, nEnd do
		local szName	= tbMapList[i].szName;
		local tbPerPos	= {tbMapList[i].nMapId, tbMapList[i].nX, tbMapList[i].nY};
		tbOpt[#tbOpt+1]	= {szName, self.DelayTime, self, tbPerPos, szName};
	end
	
	if (nEnd < #tbMapList) then
		tbOpt[#tbOpt + 1] = {"Trang sau", self.OnShowMapList, self, tbMapList, nPage + 1, szFrom};
	end
	
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("想去哪就去哪！<pic=48>", tbOpt);
end

-- 功能:	点击传送符后,玩家在战斗状态下将延时self.nTime(秒),否则不延时
-- 参数:	pItem		传送符这个对象
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	nIsLimit	是否为无限传送符
-- 参数:	szName		当前传送符所要传送过去的地方的名字
function tbTequanChuansong:DelayTime(tbPos, szName)
	if not me then
		return;
	end
	local szForbitMap = "chuansong";
	local nCanUse = KItem.CheckLimitUse(me.nMapId, szForbitMap);
	if (not nCanUse or nCanUse == 0) then
		me.Msg("该道具禁止在本地图使用！");
		return;
	end
	-- 玩家在非战斗状态下传送无延时正常传送
	-- 若是CallClientScript，则无延时直接call
	if 0 == me.nFightState or type(tbPos) == "string" then
		self:TransPlayer(tbPos, szName);
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
	GeneralProcess:StartProcess("正在传送...", tbChuangsongfu.nTime * Env.GAME_FPS, {self.TransPlayer, self, tbPos, szName}, nil, tbEvent);
end

-- 功能:	传送玩家
-- 参数:	tbPos		某个新手村、城市或者门派信息的table
-- 参数:	szName		当前传送符所要传送过去的地方的名字
function tbTequanChuansong:TransPlayer(tbPos, szName)
	if type(tbPos) == "table" then
		me.Msg(string.format("坐好了，%s！",szName));
		me.NewWorld(unpack(tbPos));
	elseif type(tbPos) == "string" then
		me.CallClientScript({ tbPos });
	end
end

function tbTequanChuansong:OnTransBattle()
	local nLevelId	= Battle:GetJoinLevel(me);	-- 能参加的宋金战役的等级(0玩家的等级不够不能参加,1初级,2中级,3高级)
	if (nLevelId == 0) then		-- 等级不够时,点击宋金诏书没有操作
		Dialog:Say("你目前学艺未精，等级未到<color=green>60<color>级，还不能报名进入战场！");
		return 0;
	end
	if (me.IsFreshPlayer() == 1) then
		Dialog:Say("你目前尚未加入门派，武艺不精，还是等加入门派后再来把！");
		return 0;
	end	
	Item:GetClass("songjinzhaoshu"):SelectCamp(0, nLevelId, 1);
end

function tbTequanChuansong:OnTransArmyCamp(nItemId)
	local szMsg = "请选择您想前往的军营";
	local tbOpt = {}
	local tbArmToken = Item:GetClass("army_token");
	for i, tbItem in ipairs(tbArmToken.tbTransMap) do
		table.insert(tbOpt, {tbItem[1], tbArmToken.OnTrans, tbArmToken, 0, i, 1})
	end
	
	Lib:SmashTable(tbOpt);
	
	tbArmToken.nOptionAutoTeamId = #tbOpt + 1;
	table.insert(tbOpt, { "自动组队", tbArmToken.OnTrans, tbArmToken, 0, tbArmToken.nOptionAutoTeamId, 1});
	
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

