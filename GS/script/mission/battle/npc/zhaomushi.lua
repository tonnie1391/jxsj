-- 招募使

local tbChuanmushi	= Npc:GetClass("zhaomushi");

tbChuanmushi.tbBattleSeq = {"", "", ""};

tbChuanmushi.TBFACTIONEQUIP = 
{
	{--初级战场，扬州战场
		[1] = 49, -- 少林
		[2] = 50, --天王掌门
		[3] = 51, --唐门掌门
		[4] = 53, --五毒掌门
		[5] = 55, --峨嵋掌门
		[6] = 56, --翠烟掌门
		[7] = 58, --丐帮掌门
		[8] = 57, --天忍掌门
		[9] = 59, --武当掌门
		[10] = 60, --昆仑掌门
		[11] = 52, --明教掌门
		[12] = 54, --大理段氏掌门
		[13] = 292, -- 古墓
	},
	{--中级战场，凤翔战场
		[1] = 61, -- 少林
		[2] = 62, --天王掌门
		[3] = 63, --唐门掌门
		[4] = 65, --五毒掌门
		[5] = 67, --峨嵋掌门
		[6] = 68, --翠烟掌门
		[7] = 70, --丐帮掌门
		[8] = 69, --天忍掌门
		[9] = 71, --武当掌门
		[10] = 72, --昆仑掌门
		[11] = 64, --明教掌门
		[12] = 66, --大理段氏掌门
		[13] = 293, -- 古墓
	},
};

-- 功能 玩家通过和招募使对话,传送至对应的阵营报名点
-- 参数:	szCamp 招募使代表的阵营(song/jin)
function tbChuanmushi:OnDialog(szCamp)
	local tbOpt					= {};
	local nNpcCampId			= Battle.tbNPCNAMETOID[szCamp]							-- 招募使所代表的阵营(1表示宋,2表示金)
	local szNpcDialog			= Battle.tbZhaomushiCampDialog[nNpcCampId] .. "\n";		-- 招募使说的话
	local nLevelId				= Battle:GetJoinLevel(me);								-- 表示玩家能参加的战场级别(0表示等级不够无法参加,1初级战场,2中级战场,3高级战场)
	local szBattleMapName		= Battle.NAME_GAMELEVEL[nLevelId];
	
	if (nLevelId == 0) then														-- 等级不够时
		Dialog:Say("Ngươi chưa đạt đến cấp 60, không thể báo danh vào chiến trường.");
		return;
	end

	-- 是白名
	if (me.IsFreshPlayer() == 1) then
		Dialog:Say("Bạn chưa gia nhập môn phái, gia nhập rồi hãy quay lại!");
		return;
	end
	
	--add by LQY 新战场入口
	local IsOpen = 0;
	for _, nOpen in pairs(NewBattle.tbNewBattleOpen[nLevelId]) do
		IsOpen = IsOpen + nOpen;
	end
	
	if IsOpen > 0 then
		self:OnNewBattleEnter(szCamp);
		return;
	end
		
	local nNpcCampId	= Battle.tbNPCNAMETOID[szCamp];						-- 招募使所代表的阵营(1表示宋,2表示金)
	local tbPlayerReply	= Battle.tbPlayerReply2Zhaomushi[nNpcCampId];		-- 玩家的选项

	for i=1, #self.tbBattleSeq do
		if (Battle.MAPID_LEVEL_CAMP[nLevelId][i]) then
			local nMapId	= Battle.MAPID_LEVEL_CAMP[nLevelId][i][nNpcCampId];	-- 获得战场报名点的地图Id
			local nSongCampNum, nJinCampNum = Battle:GetPlayerCount(nLevelId, i);		-- 获得已经报名的宋方和金方的人数
			if (nSongCampNum >= 0) then
				szNpcDialog = szNpcDialog .. string.format("Hiện tại <color=yellow>%s%s<color> đã bắt đầu báo danh. <color=orange>Quân số bên Tống: %d<color>; <color=purple>quân số bên Kim: %d<color>.\n", szBattleMapName, self.tbBattleSeq[i], nSongCampNum, nJinCampNum)
			else
				szNpcDialog = szNpcDialog .. string.format("Hiện <color=yellow>%s%s<color> chưa bắt đầu báo danh.\n", szBattleMapName, self.tbBattleSeq[i]);
			end
			tbOpt[#tbOpt+1] = {string.format(tbPlayerReply[1], szBattleMapName, self.tbBattleSeq[i]), Battle.EnterRegistPlace, Battle, nMapId, me.nId};	-- 传送去报名点
		end
	end

	local tbOpenShop = {"Ta muốn mua trang bị chiến trường Dương Châu", self.OnBuyBattleEquip, self, 1};
	tbOpt[#tbOpt + 1] = tbOpenShop;
	tbOpenShop = {"Ta muốn mua trang bị chiến trường Phượng Tường", self.OnBuyBattleEquip, self, 2};
	tbOpt[#tbOpt + 1] = tbOpenShop;

	tbOpt[#tbOpt + 1] = {tbPlayerReply[2]};												-- 放弃

	Dialog:Say(szNpcDialog, tbOpt);
end

-- add by LQY 新战场入口
function tbChuanmushi:OnNewBattleEnter(szCamp)
	local tbOpt					= {};
	local nNpcCampId			= Battle.tbNPCNAMETOID[szCamp]							-- 招募使所代表的阵营(1表示宋,2表示金)
	local szNpcDialog			= Battle.tbZhaomushiCampDialog[nNpcCampId] .. "\n";		-- 招募使说的话
	local nLevelId				= Battle:GetJoinLevel(me);								-- 表示玩家能参加的战场级别(0表示等级不够无法参加,1初级战场,2中级战场,3高级战场)
	local szBattleMapName		= Battle.NAME_GAMELEVEL[nLevelId];
	if (nLevelId == 0) then														-- 等级不够时
		Dialog:Say("你目前学艺未精，等级未到60级，还不能报名进入战场！");
		return;
	end

	-- 是白名
	if (me.IsFreshPlayer() == 1) then
		Dialog:Say("你目前尚未加入门派，武艺不精，还是等加入门派后再来把！");
		return;
	end
	local nNpcCampId	= Battle.tbNPCNAMETOID[szCamp];						-- 招募使所代表的阵营(1表示宋,2表示金)
	local tbPlayerReply	= Battle.tbPlayerReply2Zhaomushi[nNpcCampId];		-- 玩家的选项
	local tbNewBattleSeq = NewBattle.tbNewBattleSeq[nLevelId];
	for i=1, #tbNewBattleSeq do
		local nMapId	= NewBattle.TB_MAP_BAOMING[nLevelId][i][nNpcCampId];			-- 获得战场报名点的地图Id
		local nSongCampNum, nJinCampNum = Battle:GetPlayerCount(nLevelId, i);		-- 获得已经报名的宋方和金方的人数
		if (NewBattle.tbNewBattleOpen[nLevelId][i] == 1) then
			szNpcDialog = szNpcDialog .. string.format("现在<color=yellow>%s%s<color>报名已经开始。<color=orange>宋军人数为：%d<color>；<color=purple>金军人数为：%d<color>。\n", szBattleMapName, tbNewBattleSeq[i], nSongCampNum + 1, nJinCampNum + 1);
		else
			szNpcDialog = szNpcDialog .. string.format("当前<color=yellow>%s%s<color>报名尚未开始。\n", szBattleMapName, tbNewBattleSeq[i]);
		end
		tbOpt[#tbOpt+1] = {string.format(tbPlayerReply[1], szBattleMapName, tbNewBattleSeq[i]), self.EnterRegistPlace_NewBattle, self, nMapId};	-- 传送去报名点
	end
	local tbOpenShop = {"我要购买扬州战场装备", self.OnBuyBattleEquip, self, 1};
	tbOpt[#tbOpt + 1] = tbOpenShop;
	tbOpenShop = {"我要购买凤翔战场装备", self.OnBuyBattleEquip, self, 2};
	tbOpt[#tbOpt + 1] = tbOpenShop;

	tbOpt[#tbOpt + 1] = {tbPlayerReply[2]};												-- 放弃

	Dialog:Say(szNpcDialog, tbOpt);
end

-- 进入新战场报名地图
function tbChuanmushi:EnterRegistPlace_NewBattle(nMapId)
	me.SetFightState(0);
	me.NewWorld(nMapId, unpack(NewBattle:GetRandomPoint(NewBattle.POS_BAOMING)));
end
function tbChuanmushi:OnBuyBattleEquip(nBattleLevel)
	local nFaction = me.nFaction;
	if nFaction <= 0 or me.GetCamp() == 0 then
		Dialog:Say("Người chơi không phải chữ trắng mới mua được trang bị Chiến Trường Tống Kim");
		return 0;
	end	
	me.OpenShop(self.TBFACTIONEQUIP[nBattleLevel][nFaction], 1, 100, me.nSeries)
end
