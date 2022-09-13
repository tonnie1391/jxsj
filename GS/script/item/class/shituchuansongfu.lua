
Require("\\script\\item\\class\\shituchuansongfulogic.lua");

-- 师徒传送符
local tbItem = Item:GetClass("teacher2student");

--tbItem.TASK_SHITU_GROUP					= Relation.TASK_GROUP;
--tbItem.TASK_ID_SHITU_BAIHUTANG 			= Relation.TASK_ID_SHITU_BAIHUTANG; -- 白虎堂
--tbItem.TASK_ID_SHITU_BATTLE 			= Relation.TASK_ID_SHITU_BATTLE ; -- 宋金战场
--tbItem.TASK_ID_SHITU_FACTION 			= Relation.TASK_ID_SHITU_FACTION; -- 门派竞技
--tbItem.TASK_ID_SHITU_WANTED 			= Relation.TASK_ID_SHITU_WANTED; -- 通缉任务
--tbItem.TASK_ID_SHITU_YIJUN 				= Relation.TASK_ID_SHITU_YIJUN; -- 义军任务
--tbItem.TASK_ID_SHITU_CHUANGONG_COUNT 	= Relation.TASK_ID_SHITU_CHUANGONG_COUNT; -- 记录完家本周完成师徒传功的次数
--tbItem.TASK_ID_SHITU_CHUANGONG_TIME		= Relation.TASK_ID_SHITU_CHUANGONG_TIME; -- 记录玩家上次传功的时间
--tbItem.TASK_ID_SHITU_BUFF_TIME 			= Relation.TASK_ID_SHITU_BUFF_TIME; -- 弟子上次领取师徒buff的日期

tbItem.BATTLE_VALID_TIME = 1800;	-- 参加宋金战场的时间必须在连续30分钟以上才认为真正参加了宋金
-- TODO:具体数字待定，表示师徒任务当中各项活动需要的次数
tbItem.nNeed_Level 		= 69;
tbItem.nNeed_FavorLevel = 4;
tbItem.nNeed_BaiHuTang	= 2;
tbItem.nNeed_Battle 	= 2;
tbItem.nNeed_Faction 	= 2;
tbItem.nNeed_Wanted 	= 3;
tbItem.nNeed_YiJun 		= 3;

tbItem.nMax_ChuanGong_Level = 100;	-- 传功需要的弟子最高等级
-- tbItem.nMax_ChuanGong_Time 	= Relation.nMax_ChuanGong_Time;		-- 每周最多能够传功的次数
-- 玩家的身份
tbItem.PLAYER_FIGURE_TEACHER 	= 1;	-- 师傅
tbItem.PLAYER_FIGURE_STUDENT 	= 2;	-- 弟子
tbItem.PLAYER_FIGURE_GRADUATE 	= 3;	-- 已出师或超过69级但没有收徒的角色
tbItem.PLAYER_FIGURE_FRESHMAN 	= 4;	-- 没有达到69级且没有拜师的玩家

tbItem.tbForbidTemplateMapId = {241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 187, 188, 189, 190, 191, 192, 193, 194, 195, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236,
						237, 238, 239, 240, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 1425, 1426, 1427, 1428, 1429, 1430, 1431, 1432, 1433, 1434, 1435, 1436, 1461,
						1462, 1463, 1464, 1465, 1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473, 1474, 1475, 1476, 1477, 1478, 1479, 1480, 1481, 1482, 1483, 1484, 1485, 1486, 1487, 1488, 1489,
						1490, 1491, 1492, 1493, 1494, 1495, 1496, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 
						323, 324, 325, 326, 327, 328, 329, 330, 331, 332,1635,1636,1637,1638,1639,1640,1641,1642,1643};

function tbItem:OnUse()
	local nFigure = self:GetFigure();
	local szMsg = "古之学者必有师。师者，所以传道受业解惑也。人非生而知之者，孰能无惑？惑而不从师，其为惑也，终不解矣。生乎吾前，其闻道也固先乎吾，吾从而师之；生乎吾后，其闻道也亦先乎吾，吾从而师之。吾师道也，夫庸知其年之先后生于吾乎？是故无贵无贱，无长无少，道之所存，师之所存也。\n";
	if (nFigure == self.PLAYER_FIGURE_TEACHER) then
		Dialog:Say(szMsg ..  me.szName.."，请选择你要进行的操作？",
		{
			-- {"查看徒弟情况", self.ShowOnlineStudent, self, 0},
			{"进行师徒传功", self.ChuanGong, self},
			{"进行师徒传送", self.ChuanSong, self, 1},
			{"给予徒弟祝福", self.AddBuff4Student, self},
			{"更换师徒称号", self.ChangeShituTitle, self},
			{"Kết thúc đối thoại"},
		})
	elseif (nFigure == self.PLAYER_FIGURE_STUDENT) then
		Dialog:Say(szMsg .. me.szName.."，请选择你要进行的操作？",
		{
			-- {"查看自己当前的师徒任务情况", self.ShowStudentInfo, self, me.szName, 1, 1},
			{"进行师徒传送",  self.ChuanSong, self, 1},
			{"获取弟子称号",  self.FetchStudentTitle, self},
			{"Kết thúc đối thoại"},
		})
	elseif (nFigure == self.PLAYER_FIGURE_GRADUATE) then
		local szMsg = "    收徒的好处：\n    1.徒弟成功出师，就可以成为师傅的密友。徒弟每次在奇珍阁消费，师傅都能获得他消费额5%的绑定金币返还。\n    " .. 
					"2.成为师傅后，可以进行传功，每周4次，每天最多1次。传功期间，师傅和徒弟都能获得经验以及亲密度。"
		Dialog:Say(szMsg
			-- {{"进行师徒传功", self.ChuanGong, self},}
		);
	elseif (nFigure == self.PLAYER_FIGURE_FRESHMAN) then
		local szMsg = "    拜师的好处：\n    当今世界处处充满了危机，对于一位新人，最好能找一位资历深厚的前辈，并且拜他为师。这样，不仅可以在你遇到困难的时候有个强而有力的后援，还可以通过向前辈学习，" ..
						"进一步了解这个世界。在你做任务的时候师傅可以帮你完成，只要2人组队，师傅杀的任务怪你也会计数。另外在你出师之后，你们依然保有师徒名分，更可以在师傅升级后领取师傅精进奖励。";
		Dialog:Say(szMsg);
	end
	
	-- self:ShowOnlineStudent();
	return 0;
end

-- 更换师徒称号
function tbItem:ChangeShituTitle()
	local tbStudent = me.GetTrainingStudentList();
	if (not tbStudent or Lib:CountTB(tbStudent) == 0) then
		Dialog:Say("你当前没有可以替换的师徒称号。");
		return;
	end
	
	local tbTitleList = {};
	for _, szStudentName in pairs(tbStudent) do
		local szTempTitle = string.format("%s%s", szStudentName, EventManager.IVER_szTeacherTitle);
		table.insert(tbTitleList, szTempTitle);
	end
		
	local tbShituTitleList = {};
	for _, szShituTitle in pairs(tbTitleList) do
		tbShituTitleList[#tbShituTitleList + 1] = {szShituTitle, self.SelectShituTitle, self, szShituTitle};
	end
	
	tbShituTitleList[#tbShituTitleList + 1] = {"Để ta suy nghĩ thêm吧"};
	
	Dialog:Say("你可以从下面的列表中选择要更换的师徒称号：", tbShituTitleList);
end

-- 选择师徒称号
function tbItem:SelectShituTitle(szShituTitle)
	local tbAllTitle = me.GetAllTitle();
	-- 如果原来有师徒称号的话，把原有的师徒称号取消掉
	for _, tbTitleInfo in pairs(tbAllTitle) do
		if (tbTitleInfo.byTitleGenre == 250) then	-- 自定义称号大类的id是250
			local szTitle = tbTitleInfo.szTitleName;
			local nStart, nEnd = string.find(szTitle, EventManager.IVER_szTeacherTitle);
			if (nStart and nEnd and nStart ~= nEnd and nEnd == string.len(szTitle)) then
				me.RemoveSpeTitle(szTitle);
			end
		end
	end
	
	me.AddSpeTitle(szShituTitle, GetTime() + 3600 * 24 * 365 * 10, "gold");
	Dialog:Say(string.format("你已经把师徒称号更换为：<color=yellow>%s<color>", szShituTitle));
end

-- 获取弟子称号
function tbItem:FetchStudentTitle()
	local szTeacherName = me.GetTrainingTeacher();
	if (not szTeacherName) then
		return;
	end
	
	local szStudentTitle = szTeacherName .. EventManager.IVER_szTudiTitle;
	
	-- 如果原来有师徒称号的话，把原有的师徒称号取消掉
	local tbAllTitle = me.GetAllTitle();
	for _, tbTitleInfo in pairs(tbAllTitle) do
		if (tbTitleInfo.byTitleGenre == 250) then	-- 自定义称号大类的id是250
			local szTitle = tbTitleInfo.szTitleName;
			local nStart, nEnd = string.find(szTitle, EventManager.IVER_szTudiTitle);
			if (nStart and nEnd and nStart ~= nEnd and nEnd == string.len(szTitle)) then
				me.RemoveSpeTitle(szTitle);
			end
		end
	end
	
	me.AddSpeTitle(szStudentTitle, GetTime() + 3600 * 24 * 365 * 10, "gold");
	Dialog:Say(string.format("你已经获得弟子称号：<color=yellow>%s<color>", szStudentTitle));
end

-- 为弟子增加每天buff              
function tbItem:AddBuff4Student()
	local tbStudent = me.GetTrainingStudentList();
	if (not tbStudent or Lib:CountTB(tbStudent) == 0) then
		Dialog:Say("你当前没有未出师的弟子，请先收几个徒弟吧。");
		return;
	end
	
	local bAddBuff = 0;
	local nRange = 50;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, nRange);
	if (tbPlayerList) then
		for _, pPlayer in ipairs(tbPlayerList) do
			if (pPlayer.nLevel < self.nMax_ChuanGong_Level and pPlayer.nLevel < me.nLevel 
				and me.szName == pPlayer.GetTrainingTeacher()) then
				local nNowDate = tonumber(os.date("%Y%m%d", GetTime()));
				local nLastAddBuffDate = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_BUFF_TIME);
				if (nNowDate ~= nLastAddBuffDate and nNowDate > nLastAddBuffDate) then
					pPlayer.AddSkillState(876,5,1,32400,1,0,1);		-- 护甲
					pPlayer.AddSkillState(877,5,1,32400,1,0,1);		-- 五行
					pPlayer.AddSkillState(878,5,1,32400,1,0,1);		-- 磨刀
					pPlayer.AddSkillState(879,7,1,32400,1,0,1);		-- 双倍经验
					pPlayer.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_BUFF_TIME, nNowDate);
					bAddBuff = 1;
				end
			end
		end
	end
	
	local szMsg = "给予徒弟祝福需要注意如下几点：\n    1 弟子必须是未出师弟子\n    2 弟子等级不能超过100级，否则弟子不能得到状态\n    3 弟子等级不能超过师傅\n    4 在加接受祝福的时候，弟子不能离开师傅太远\n    5 每个弟子一天只能接受一次祝福\n\n";
	if (bAddBuff == 1) then
		Dialog:Say(szMsg .. "    已经为你的弟子增加状态了。<color=red>如果还有弟子没有加上，请再次确认以上注意事项。<color>");
	else
		Dialog:Say(szMsg .. "    <color=red>你身边没有适合添加状态的弟子。请留意以上注意事项。<color>");
	end
	return 1;
end

function tbItem:ChuanSong(nChoice)
	-- 如果存在当前师父，表示自己的身份是未出师弟子，需要传送到师傅那里
	local szTeacherName = me.GetTrainingTeacher();
	if (szTeacherName) then
		local nTeacherId = KGCPlayer.GetPlayerIdByName(szTeacherName);
		local nOnline = KGCPlayer.OptGetTask(nTeacherId, KGCPlayer.TSK_ONLINESERVER);
		self:SelectPlayer(szTeacherName, me.szName, nChoice, nOnline);
	end
	
	-- 如果存在未出师弟子，表明自己身份是师傅，需要传送到弟子那里
	local tbStudent = me.GetTrainingStudentList();
	if (tbStudent and Lib:CountTB(tbStudent) ~= 0) then
		self:ShowOnlineStudent(nChoice);
	end
end

function tbItem:GetFigure()
	local tbStudent = me.GetTrainingStudentList();
	if (not tbStudent or #tbStudent < 1) then
		if (me.GetTrainingTeacher()) then
			return self.PLAYER_FIGURE_STUDENT;
		elseif (me.nLevel >= 50) then
			return self.PLAYER_FIGURE_GRADUATE;
		else
			return self.PLAYER_FIGURE_FRESHMAN;
		end
	else
		return self.PLAYER_FIGURE_TEACHER;
	end
end

function tbItem:IsStudentAround()
	local bIsStudentAround = 0;
	local nRange = 50;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, nRange);
	if (tbPlayerList) then
		for _, pPlayer in ipairs(tbPlayerList) do
			if (pPlayer.nLevel < self.nMax_ChuanGong_Level and pPlayer.nLevel < me.nLevel 
				and 1 == me.IsTeacherRelation(pPlayer.szName, 1)) then
				bIsStudentAround = 1;
				break;
			end
		end
	end
	return bIsStudentAround;
end

-- 进行师徒传功 furuilei 是否需要在这里添加传功代码待定
function tbItem:ChuanGong()
	local bCanChuanGong = self:CanChuanGong();
	if (0 == bCanChuanGong) then
		return 0;
	end
	Dialog:Say("    传功开始了，这个过程将持续15分钟，期间可能会有名为“欺师灭祖”的恐怖组织前来捣乱。<color=red>在此过程中请注意保护好您的徒弟，不要离开或者下线。怪物的存在时间为15分钟，15分钟后自动消失。要抓紧时间消灭他们。<color>");
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	local tbNpc	= Npc:GetClass("chuangonglunpc");	
	tbNpc:StartToWork(nMapId, nMapX, nMapY, me.nId);
	me.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_CHUANGONG_TIME, GetTime());
	local nChuanGongTime = me.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_CHUANGONG_COUNT) + 1;
	me.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_CHUANGONG_COUNT, nChuanGongTime);
	
	-- 成就，师徒传功
	Achievement:FinishAchievement(me, 18);
	Achievement:FinishAchievement(me, 19);
	Achievement:FinishAchievement(me, 20);
	Achievement:FinishAchievement(me, 21);
end

function tbItem:CanChuanGong()
	if (me.nFightState == 0) then
		Dialog:Say("您在这里无法吸收到天地之灵气，传功效果不理想，请到野外地图再开启传功。");
		return 0;
	end
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	local nMapIndex = SubWorldID2Idx(nMapId);
	if (-1 == nMapId) then
		return 0;
	end
	local nMapTemplateId	= SubWorldIdx2MapCopy(nMapIndex);
	if (0 == nMapTemplateId) then
		return 0;
	end
	for _, v in ipairs(self.tbForbidTemplateMapId) do
		if (v == nMapTemplateId) then
			Dialog:Say("该地图禁止进行师徒传功。");
			return 0;
		end
	end
	local nCurTime = GetTime();
	local nLastChuanGongTime = me.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_CHUANGONG_TIME);
	local nLastChuanGongDay = os.date("%Y%m%d", nLastChuanGongTime);
	local nCurDay = os.date("%Y%m%d", nCurTime);
	if (nLastChuanGongDay == nCurDay) then
		Dialog:Say("您今天已经完成1次传功，内力消耗过度，因此您今天不能再次传功。");
		return 0;
	end
	local nChuanGongTime = me.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_CHUANGONG_COUNT);
	local nCurWeek = os.date("%Y%W", nCurTime);
	local nLastChuanGongWeek = os.date("%Y%W", nLastChuanGongTime);
	if (nLastChuanGongWeek ~= nCurWeek) then
		nChuanGongTime = 0;
		me.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_CHUANGONG_COUNT, nChuanGongTime);
	end
	if (Relation.nMax_ChuanGong_Time <= nChuanGongTime) then
		Dialog:Say("您本周已经完成" .. Relation.nMax_ChuanGong_Time .. "次传功，内力消耗过度，因此您本周不能再次进行传功。");
		return 0;
	end
	local bCanChuanGong = self:IsStudentAround();
	if (0 == bCanChuanGong) then
		Dialog:Say("您身边没有符合传功条件的弟子，无法进行传功。");
		return 0;
	end
	return 1;
end

-- 参数nChoice0表示玩家要查看徒弟信息，1表示玩家要进行师徒传送
function tbItem:ShowOnlineStudent(nChoice)
	local tbOnlineStudents = {};
	local tbStudents = me.GetTrainingStudentList();
	if (1 == nChoice) then
		if Domain:GetBattleState() == Domain.BATTLE_STATE then
			Dialog:Say("领土争夺战期间，禁止使用师徒传送符！");
			return;
		end
		if (not tbStudents or #tbStudents == 0) then
			Dialog:Say("没有徒弟，或者徒弟已经出师，不能使用师徒传送符！");
			return;
		end
	end
	
	for _,szStudentName in ipairs(tbStudents) do
		local nStudentPlayerId = KGCPlayer.GetPlayerIdByName(szStudentName);
		local nOnline = KGCPlayer.OptGetTask(nStudentPlayerId, KGCPlayer.TSK_ONLINESERVER);
		if (nOnline > 0) then
			tbOnlineStudents[#tbOnlineStudents + 1] = {szStudentName, self.SelectPlayer, self, szStudentName, me.szName, nChoice, nOnline};
		elseif (nChoice == 0) then
			tbOnlineStudents[#tbOnlineStudents + 1] = {szStudentName, self.SelectPlayer, self, szStudentName, me.szName, nChoice, nOnline};
		end
	end
	if (#tbOnlineStudents > 0) then
		tbOnlineStudents[#tbOnlineStudents + 1] = {"取消"};
		if (1 == nChoice) then
			Dialog:Say("你想到哪位徒弟那里去？", tbOnlineStudents);
		elseif (0 == nChoice) then
			Dialog:Say("请选择您要查看哪位徒弟的情况", tbOnlineStudents);
		end
	else
		if (1 == nChoice) then
			Dialog:Say("你没有徒弟在线！");
		elseif (0 == nChoice) then
			Dialog:Say("您目前没有未出师的弟子。");
		end
	end
end

function tbItem:ShowStudentInfo(szStudentName, nOnline, bIsSelf)
	local pPlayer = nil;
	local szMsg = "";
	if (nOnline <= 0) then
		szMsg = szMsg .. "该玩家不在线，无法查询。";
	else
		if (type(szStudentName) == "string") then
			pPlayer = KPlayer.GetPlayerByName(szStudentName);
		end
		if (not pPlayer) then
			Dialog:Say("该玩家与您不在同一地图，无法获取其信息。");
			return 0;
		end
		local nBaihutang = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_BAIHUTANG);
		local nBattle = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_BATTLE);
		local nFaction = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_FACTION);
		local nWanted = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_WANTED);
		local nYiJun = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_YIJUN);
		local nFavorLevel = 1;
		if (1 == bIsSelf) then	-- 如果是徒弟在查看自己的师徒任务信息，那么获取的亲密度应该是自己与师傅之间的
			nFavorLevel = me.GetFriendFavorLevel(me.GetTrainingTeacher());
		else					-- 如果是师傅在查看自己徒弟的任务信息，那么获取的亲密度应该是自己与指定徒弟之间的
			nFavorLevel = me.GetFriendFavorLevel(szStudentName);
		end
		local nLevel = pPlayer.nLevel;
		szMsg = szMsg .. "    姓名：" .. szStudentName .. "\n";
		szMsg = szMsg .. "    当前等级：<color=yellow>" .. nLevel .. "<color>级，"
		szMsg = self:GetStudentInfo(szMsg, nLevel, self.nNeed_Level);
		szMsg = szMsg .. "    你们之间的亲密度：<color=yellow>" .. nFavorLevel .. "<color>级，";
		szMsg = self:GetStudentInfo(szMsg, nFavorLevel, self.nNeed_FavorLevel);
		szMsg = szMsg .. "    该弟子参加过白虎堂次数<color=yellow>" .. nBaihutang .. "<color>次，";
		szMsg = self:GetStudentInfo(szMsg, nBaihutang, self.nNeed_BaiHuTang);
		szMsg = szMsg .. "    该弟子参加过宋金战场次数<color=yellow>" .. nBattle .. "<color>次，";
		szMsg = self:GetStudentInfo(szMsg, nBattle, self.nNeed_Battle);
		szMsg = szMsg .. "    该弟子参加过门派竞技次数<color=yellow>" .. nFaction .. "<color>次，";
		szMsg = self:GetStudentInfo(szMsg, nFaction, self.nNeed_Faction);
		szMsg = szMsg .. "    该弟子参加过通缉任务次数<color=yellow>" .. nWanted .. "<color>次，";
		szMsg = self:GetStudentInfo(szMsg, nWanted, self.nNeed_Wanted);
		szMsg = szMsg .. "    该弟子参加过义军任务次数<color=yellow>" .. nYiJun .. "<color>次，";
		szMsg = self:GetStudentInfo(szMsg, nYiJun, self.nNeed_YiJun);
	end
	Dialog:Say(szMsg);
end

function tbItem:GetStudentInfo(szMsg, nCount, nNeedCount)
	local szAchieve = "<color=green>已经达到<color>出师要求。\n";
	local szNotAchieve = "<color=red>还未达到<color>出师要求。\n";
	if (nCount >= nNeedCount) then
		szMsg = szMsg .. szAchieve;
	else
		szMsg = szMsg .. szNotAchieve;
	end
	return szMsg;
end

function tbItem:SelectPlayer(szDstPlayerName, szAppPlayerName, nChoice, nOnline)
	if (0 == nOnline) then
		Dialog:Say("你的师傅当前没有在线，无法传送。");
	else
		me.GetTempTable("Item").szBeComeToSutdentName = szDstPlayerName;
		GCExcute({"Item.tbShiTuChuanSongFu:SelectDstPlayerPos", szDstPlayerName, szAppPlayerName});
		Player:RegisterTimer(Env.GAME_FPS * 60 * 10, self.InvalidRequest, self);	-- 10min以后失效
	end
end

function tbItem:InvalidRequest()
	me.GetTempTable("Item").szBeComeToSutdentName = nil;
	return 0;
end
