
local GongPingZi = Npc:GetClass("gongpingzi");

function GongPingZi:OnDialog()
	local tbOpt = 
	{
		{"家族战场", KinBattle.Npc.OnDialogField, KinBattle.Npc},
		{"比武擂台", BiWu.OnDialog, BiWu},
		{"Kết thúc đối thoại"},
	};
	Dialog:Say("我这里为你们提供了各种公平的比武环境。", tbOpt);
end

function BiWu:OnDialog()

--	不进行初始化，在OpenMission时处理相关数值	
--	Class TB_MAPDEC_INFO 不再使用，BW.tbMission[nMapId] 代替
	
	local nOpen, nRun, nFree = 0,0,0;	--已经报名 准备入场--报名 并 开始比赛--空闲场地
	
	local nCityid = SubWorldIdx2ID(SubWorld);			--当前城市ID
	--local tbBwMap = self.TB_CITY_BIWU_INFO[nCityid];	--当前城市对应的比武场地
	local tbBwMapInfo = self:GetBiWuMapInfo(nCityid);
	
	--for i = 1, #tbBwMap do
		--local tbInfo = self.tbMission[tbBwMap[i]];
	for nMapId, tbInfo in pairs(tbBwMapInfo) do
		
		if (tbInfo.nState == 1) then
			nOpen = nOpen + 1;
		elseif (tbInfo.nState == 2) then
			nOpen = nOpen + 1;
			nRun = nRun + 1;
		else
			nFree = nFree + 1;
		end;
	end;
	
	--晕,没有已经报名的,没有已经开打的,没有空的, 那就是没有比武地图喽
	if (nOpen == 0 and nRun == 0 and nFree == 0) then
		BiWu:ErrorMsg(3);
		return 0;
	end;
	
	local szMsg = string.format("%s：擂台场乃提供给武林侠士比武切磋，一决高低之地。各位也可以入场观看高手切磋，相信也会受益匪浅！", him.szName);
	local tbOpp = {};
	table.insert(tbOpp, {"我们要约定比武之期", "BiWu:OnSelectMap", nFree});	--虽然应该现判断说没有 空闲场地就不出对话,
																			--但是有对话可以增加提示,不用在主对话中加了
	if (nOpen == 0 and nRun == 0) then
		szMsg = string.format("%s当前尚未有大侠约定一战。",szMsg);
	else
		if (nOpen ~= 0) then
			szMsg = string.format("%s当前已约定了%d场比武之期。",szMsg, nOpen);
		end;
		if (nRun ~= 0) then
			szMsg = string.format("%s正在进行%d场精彩对决。",szMsg, nRun);
		end;
		
		if (BiWu:CheckShowKey() ~= 0) then
			table.insert(tbOpp, {"我想重新查看入场的口令",self.OnShowKey, self});	--这是一种写法, 需要传入self 才可继承(这里用这个词对否) 
		end;
		table.insert(tbOpp, {"我来参加比武的，让我入场吧","BiWu:OnEnterMatch"});	--这是另一种写法 不需要传入self自己完成继承
		table.insert(tbOpp, {"我来观战高手切磋", self.OnLook, self});	--有约定比武才 可以观看喽
	end;
	
	table.insert(tbOpp, {"查询比武战绩", self.ShowMyGrade, self});		--这个是帮助
	table.insert(tbOpp, {"比武的规则是什么？", self.OnHelp, self});		--这个是帮助
	table.insert(tbOpp, {"我只是来看看热闹而已", self.OnCancel});	--恩恩,总要有个退出选择啊
	Dialog:Say(szMsg, tbOpp);
end;


function BiWu:OnSelectMap()
	if (self:IsSigningUp() == 0) then
		return 0;
	end;
	local szMsg = string.format("%s：天时、地利、人和，据其三者方可立于不败之地。比武之中，地势地形至关重要。你们也挑选一个合适的擂台场地吧！", him.szName);
	local tbOpp = {};
	--local nCityid = SubWorldIdx2ID(SubWorld);			--当前城市ID
	--local tbBwMap = self.TB_CITY_BIWU_INFO[nCityid];	--本城市对应的擂台地图
	local tbBwMapInfo = self:GetBiWuMapInfo();
	--for i = 1, #tbBwMap do
	for nMapId, tbInfo in pairs(tbBwMapInfo) do
		--if (self.tbMission[tbBwMap[i]]~= nil) then
		local szOpp = GetMapNameFormId(nMapId);
		if (tbInfo.nState and tbInfo.nState ~= 0) then
			szOpp = string.format("%s<%s>", szOpp, "已约定");
		end;
		table.insert(tbOpp, {szOpp, self.OnSelectType, self, nMapId});
	end;
	--end;
	table.insert(tbOpp, {"我们再考虑一下", self.OnCancel});
	Dialog:Say(szMsg, tbOpp);
end;

function BiWu:OnSelectType(nMapId)
	local szMsg = string.format("%s：擂台之上，比武切磋自有定则。两位可以选择单挑比武，也可以各自招纳若干高手进行多人互战。两位考虑清楚了么？", him.szName);
	Dialog:Say(szMsg, {
	{"我们要进行1V1对战",self.SignUpFinal, self, nMapId, 1},
	{"我们要进行2V2对战",self.SignUpFinal, self, nMapId, 2},
	{"我们要进行3V3对战",self.SignUpFinal, self, nMapId, 3},
	{"我们要进行4V4对战",self.SignUpFinal, self, nMapId, 4},
	{"我们要进行5V5对战",self.SignUpFinal, self, nMapId, 5},
	{"我们要进行6V6对战",self.SignUpFinal, self, nMapId, 6},
	{"我们再考虑一下",self.OnCancel},	});
end;

function BiWu:SignUpFinal(nMapId, nMemberCount)
	
	if (self:IsSigningUp(nMapId) == 0) then
		return 0;
	end;
	
	if (nMemberCount <= 0 or nMemberCount > 6) then
		return 0;
	end
	
	local szSignMapName = SubWorldName(SubWorld);
	local OldSubWorld = SubWorld;
	SubWorld = SubWorldID2Idx(nMapId);
	
	-- Mission:Open(self.MISSIONID);
	local tbKey = {};
	tbKey = self:GetRandomKey();	--随机一个 key 作为擂台进出的关键字 供角色使用
		
	local tbCaptainName = {};
	local tbCaptainId = {};
	local tbPlayer, nTeamCount = me.GetTeamMemberList()
	
	for i = 1, #tbPlayer do 
		Setting:SetGlobalObj(tbPlayer[i]);
		--SetMissionS(self.MSS_CAPTAIN[i], me.GetName());
		
		tbCaptainName[#tbCaptainName + 1] = me.szName;
		tbCaptainId[#tbCaptainId + 1] = me.nId;
		local szKeyMsg = "";
		if (nMemberCount > 1) then
			szKeyMsg = string.format("你所在队伍的入场口令为：<color=red>%d<color>。请将该口令通知你的队友。要能答出该口令才能入场比武。", tbKey[i]);
			me.Msg(szKeyMsg);
		end
		Dialog:Say(string.format("%s：你们约定于1分钟后在[%s]进行[%dV%d]的对战。请尽快进行准备并入场。%s", 
								him.szName, GetMapNameFormId(nMapId), 
								nMemberCount, nMemberCount, szKeyMsg),
							{{"恩，Ta hiểu rồi",self.OnCancel},});
		Setting:RestoreGlobalObj();
	end;
	
	BiWu:StartGame(nMapId, nMemberCount, tbKey, tbCaptainName, tbCaptainId);	-- 开启mission
	SubWorld = OldSubWorld;
	
	
	local szMsg = string.format("%s 与 %s 约定于1分钟后在[%s]的[%s]进行[%dV%d]的对战。", 
					tbCaptainName[1], tbCaptainName[2], szSignMapName, 
					self.tbMission[nMapId].szMapName, nMemberCount, nMemberCount);
	KTeam.Msg2Team(me.nTeamId, string.format("%s请尽快进行准备并入场。", szMsg));

	local szNews = string.format("%s敬请各位武林同道到场观武论战。", szMsg);
--	KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szNews);
end;

function BiWu:GetRandomKey()
	local tbKey = {};
	tbKey[1] = MathRandom(1, 9999)
	tbKey[2] = MathRandom(1, 9999)
	
	--保证key1 key2>0, key1 ~= key2
	if (tbKey[2] == tbKey[1]) then
		if (tbKey[1] < 9996) then
			tbKey[2] = tbKey[1] + 3
		else
			tbKey[2] = tbKey[1] - 3;
		end
	end
	return tbKey;
end;


--擂台比武的帮助
function BiWu:OnHelp()
	Dialog:Say("公平子：比武擂台是武林侠士互相切磋武艺、一决高下的场所。擂台给比赛双方提供一个公平的场地。"
		.."要进行比武擂台赛，首先在我这边进行擂台比赛的申请。"
		.."由于我们场地有限，当所有场地正在进行比赛的时候，不接受新的比赛申请。",
				{
					{"Trang sau", self.OnHelp1, self},
					{"就这样吧", self.OnCancel},
				});
end;
function BiWu:OnHelp1()
	Dialog:Say("公平子：申请成功后，双方有<color=yellow>1分钟<color>入场时间。待入场时间结束后，比赛正式开始！"
				.."比赛时间分为<color=yellow>1分钟<color>准备时间和<color=yellow>10分钟<color>战斗时间。时间结束时双方未分胜负，则依照双方的伤害量来判决胜负。" ,
				{
					{"返回", self.OnDialog, self},
					{"就这样吧", self.OnCancel},
				});
end;


function BiWu:OnEnterMatch()
	
	if (me.nLevel < self.LimitLevel) then
		self:ErrorMsg(16);
		return 0;
	end;
	
	if (me.nFaction == Player.FACTION_NONE) then
		self:ErrorMsg(18);
		return 0;
	end;
	
	local nMapId = BiWu:CheckShowKey();
	
	if (nMapId ~= 0) then 
		BiWu:OnJoin(nMapId, 0);	--如果是队长，则camp任意填一个，不作为入场的判断
	else
		local tbBwMapInfo = self:GetBiWuMapInfo();
		local tbOpp = {};
		for i, tbInfo in pairs(tbBwMapInfo) do
			if (tbInfo.nState ~= 0 and tbInfo.nState ~= nil) then
				table.insert(tbOpp, {tbInfo.szMapName, "BiWu:OnEnterMatchMap", i});
			end;
		end;
		table.insert(tbOpp, {"啊，我忘了", BiWu.OnCancel});
		Dialog:Say(string.format("%s：请问这位大侠/女侠，你是来参加哪场比武的？", him.szName), tbOpp);
	end;
end

function BiWu:OnEnterMatchMap(nMapId)
	local tbTempTable = me.GetTempTable("Mission");
	local tbBiWuTask = tbTempTable.tbBiwu;
	if (not tbBiWuTask) then
		tbBiWuTask = {};
		tbTempTable.tbBiwu = tbBiWuTask;
	end;
	tbBiWuTask.nEnterMap = nMapId;

	if not self.tbMission[nMapId] then  --先要判断mission是否存在 zounan
		return 0;
	end
	
	tbBiWuTask.szEnterMap = self.tbMission[nMapId].szMapName;
	if (self.tbMission[nMapId].nType == 1) then
		Dialog:Say(string.format("%s：这是1v1比赛, 只能两个人参加本场比武。",him.szName, tbBiWuTask.szEnterMap),
						{
							{"哦，知道了", self.OnCancel, self},
							});
	else
		Dialog:Say(string.format("%s：入场比武需要口令验证，请告诉我[%s]的入场口令！",him.szName, tbBiWuTask.szEnterMap),
						{
							{"验证口令",self.OnEnterKey, self},
							{"我再去查看一下口令", self.OnCancel, self},
							});
	end;
end;

function BiWu:OnEnterKey()
	Dialog:AskNumber("请输入入场号码:", 10000, self.DoEnterKey, self);
end

function BiWu:DoEnterKey(nKey)
	nKey = tonumber(nKey);
	local tbTempTable = me.GetTempTable("Mission");
	local tbBiWuTask = tbTempTable.tbBiwu;
	if (not tbBiWuTask) then
		return 0;
	end;
	local nMapId = tbBiWuTask.nEnterMap;
	
	local OldSubWorld = SubWorld;
	local nMapIdx = SubWorldID2Idx(nMapId);
	if (nMapIdx < 0) then
		return 0;
	end;
	--SubWorld = nMapIdx;
	if not self.tbMission[nMapId] then  --先要判断mission是否存在 zounan
		return 0;
	end
	
	local tbTeamKey = self.tbMission[nMapId].tbTeamKey;--{GetMissionV(MS_TEAMKEY[1]), GetMissionV(MS_TEAMKEY[2])};
	--SubWorld = OldSubWorld;
	if (nKey == tbTeamKey[1]) then
		self:OnJoin(nMapId,1);
	elseif (nKey == tbTeamKey[2]) then
		self:OnJoin(nMapId,2);
	else
		Dialog:Say(string.format("%s：这位大侠，你的入场口令不对啊，我可不敢轻易让你下场比武，要是出了差池可就不好了！", him.szName),{{"啊，不对吗，我再确认一下",self.OnCancel}});
	end
	
end

function BiWu:OnLook()
	local tbBwMapInfo = self:GetBiWuMapInfo();
	local tbOpp = {};
	for i, tbInfo in pairs(tbBwMapInfo) do
		if (tbInfo.nState == 1) then
			table.insert(tbOpp, {tbInfo.szMapName, "BiWu:OnLookMap", i});
			
		end;
	end;
	if (#tbOpp == 0) then
		Dialog:Say(string.format("%s；对不起，现在没有供观看的比赛，你稍后再来吧。",him.szName), {{"Kết thúc đối thoại",self.OnCancel}});
		return 0;
	end;
	table.insert(tbOpp, {"Kết thúc đối thoại", BiWu.OnCancel, self});
	
	Dialog:Say(string.format("%s：原来是来观武论战的武林同道，如能一睹巅峰之战，受益匪浅啊！也请你决定一下，要观看哪一场对战？", him.szName), tbOpp);

end;

function BiWu:OnLookMap(nMapId)
	if (self.tbMission[nMapId].nState ~= 1) then
		BiWu:ErrorMsg(9);
		return 0;
	end;
	if (me.szName == self.tbMission[nMapId].tbCaptainName[1] or me.szName == self.tbMission[nMapId].tbCaptainName[2]) then
		me.Msg("你已约定本场比武，请直接入场比赛。");
		BiWu:OnJoin(nMapId, 0);	--队长不能进行观战
	else
		local szMsg = string.format("%s：%s 与 %s 将在[%s]进行%s的对战！你确定要观战么？",
		him.szName, self.tbMission[nMapId].tbCaptainName[1], 
		self.tbMission[nMapId].tbCaptainName[2], self.tbMission[nMapId].szMapName,
		self.tbMission[nMapId].szType );
		Dialog:Say(szMsg, {
		{"我要去观战", "BiWu:DoLook", nMapId},
		{"还是算了", self.OnCancel, self},
		});
	end;
	
end;

function BiWu:DoLook(nMapId)
	if not self.tbMission[nMapId] then
		BiWu:ErrorMsg(9);
		return 0;
	end
	if (self.tbMission[nMapId].nState ~= 1) then
		BiWu:ErrorMsg(9);
		return 0;
	end;
	self:OnJoin(nMapId, 3);	--加入到观众的
end

--to join in a fight group	group --组
function BiWu:OnJoin(nMapId, nGroup)
	local idx = SubWorldID2Idx(nMapId);
	if (idx < 0) then
		return
	end;
	--如果只是 获得 擂台比武的简单状态 就不用在 WorldIndex中切来切去了,全部存在tabal中了
	-- 当前如果是和Mission中角色数 或者对Mission中角色做相关Mission操作 还是要的
	local OldSubWorld = SubWorld;
	SubWorld = idx;
	if (self.tbMission[nMapId].nState ~= 1) then
		self:ErrorMsg(9);
		SubWorld = OldSubWorld;
		return 0;
	end;
	local szMyName = me.szName;
	if (szMyName == self.tbMission[nMapId].tbCaptainName[1]) then
		self:JoinCamp(nMapId, 1);
	elseif (szMyName == self.tbMission[nMapId].tbCaptainName[2]) then
		self:JoinCamp(nMapId, 2);
	elseif (nGroup == 1 or nGroup == 2) then
		local nMstGroup = self.tbMission[nMapId]:GetPlayerGroupId(KPlayer.GetPlayerObjById(self.tbMission[nMapId].tbCaptainId[nGroup]));
		local nMasterNum = 0;
		if (nMstGroup > 0) then
				nMasterNum = 1;
		end
		if (self.tbMission[nMapId]:GetPlayerCount(nGroup) - nMasterNum < self.tbMission[nMapId].nType - 1) then
			self:JoinCamp(nMapId, nGroup);
		else
			self:ErrorMsg(10);
		end;
	elseif (nGroup == 3) then
		self:JoinCamp(nMapId, 3);
	else
		self:ErrorMsg(4);
	end;
	
	SubWorld=OldSubWorld;
end;

--提示：
function BiWu:ErrorMsg(nErrorId)
	local tb_szErrorMsg	= 
			{
				[1]		= "申请比赛的两方需要先组队然后再申请！",
				[2]		= "申请比赛的双方身上所带的银两不够。",
				[3]		= "报名出现问题，请与官方联系！",
				[4]		= "你不是参加比赛的人员，无法入场比赛，只能进场观看！",
				[5]		= "报名的必须是当前队伍的队长！",
				[6]		= "你身上所带的银两不够！",
				[7]		= "对不起，你还没有报名观看！",
				[8]		= "对不起，比赛场地已经被别人抢先租下了！",
				[9]		= "对不起，比赛已经开始了，你不能进比武场了！",
				[10]	= "你要参加的比赛方已经全数到齐了，你还是下次再来吧！",
				[11]	= "组队申请的必须是比赛<color=yellow>双方<color>的队长，你们队伍好像不是<color=yellow>两个人<color>吧。",
				[12]	= "你不是已经约定比武了么？比武之期渐近，你还是去勤加练习才是！",
				[13]	= "你的队友已经约定比武了！请组其他玩家来约定比武吧。",
				[14]	= "你的队友离你太远了。请你们一起到我这里来，方能约定比武。",
				[15]	= string.format("等级达到%d级后方可进入擂台比武。你的队伍中还有人不到%d级吧！",BiWu.LimitLevel, BiWu.LimitLevel),
				[16]	= string.format("等级达到%d级后方可进入擂台比武。你目前还不到%d级吧！", BiWu.LimitLevel, BiWu.LimitLevel),
				[17]	= "加入门派后方可进入擂台比武。你的队伍中还有人没有拜师加入门派吧！",
				[18]	= "加入门派后方可进入擂台比武。你目前还没有拜师加入门派吧！",
				};

	local szMsg	= "";
	if (tb_szErrorMsg[nErrorId]) then
		szMsg = string.format("%s：%s", him.szName, tb_szErrorMsg[nErrorId]);
	else
		szMsg = string.format("%s：%s", him.szName, "你好！");
	end;
	Dialog:Say(szMsg, {{"Kết thúc đối thoại",self.OnCancel}});
	return
end;


--能否报名申请擂台一战
function BiWu:IsSigningUp(nMapId)
	local tbTeamMembers, nMemberCount = me.GetTeamMemberList()
	local _, nCurMemCount = KTeam.GetTeamMemberList(me.nTeamId);
	local nSignMap = me.GetMapId()
	
	if (nCurMemCount  == 2 and  nMemberCount ~= 2) then	--要组队二人并站一起
		self:ErrorMsg(14);
		return 0;
	end;
	
	if (nMemberCount  ~= 2) then	--要组队二人
		self:ErrorMsg(11);
		return 0;
	end;

	if (me.IsCaptain() ~= 1) then 		--来报名的必须是队长
		self:ErrorMsg(5);
		return 0;
	end;
	
	local tbBwMapInfo = self:GetBiWuMapInfo(nSignMap);
	if (nMapId) then					--如果选择了地图，看这张地图有没有被预订
		if (tbBwMapInfo[nMapId].nState == 0 or not tbBwMapInfo[nMapId].nState) then
			return 1;
		else
			self:ErrorMsg(8);
			return 0;
		end;
	end;
	
	if (self:CheckShowKey() ~= 0) then		--检查看是否约定过比武擂台了，如果可以ShowKey
		self:ErrorMsg(12);
		return 0;
	end;
	local nMeId = me.nId
	for i = 1, nMemberCount do 
		if (tbTeamMembers[i].nId ~= nMeId) then
			Setting:SetGlobalObj(tbTeamMembers[i]);
			
			if (me.GetMapId() ~= nSignMap) then		-- 检查看队友是不是在同一个地图上
				Setting:RestoreGlobalObj();
				self:ErrorMsg(14);
				return 0;
			end;
			
			if (self:CheckShowKey() ~= 0) then		--检查看是否约定过比武擂台了，如果可以ShowKey
				self:ErrorMsg(12);
				Setting:RestoreGlobalObj();
				self:ErrorMsg(13);
				return 0;
			end;
			
			if (me.nLevel < self.LimitLevel) then
				Setting:RestoreGlobalObj();
				self:ErrorMsg(15);
				return 0;
			end;
			
			if (me.nFaction == Player.FACTION_NONE) then
				Setting:RestoreGlobalObj();
				self:ErrorMsg(17);
				return 0;
			end;
			Setting:RestoreGlobalObj();
		end;
	end;
	
	local nFree = 0;					--还没选择地图，就只判断有没有空闲的
	
	for nMapId, tbInfo in pairs(tbBwMapInfo) do
		if (tbInfo.nState == 0 or not tbInfo.nState) then
			return nMapId;
		end;
	end;
	
	self:ErrorMsg(8);
	return 0;
end;

--- //
function BiWu:ShowMyGrade()
	Dialog:Say("请选择你要查询的比赛类型", {
		{"1V1对战",self.DoShowMyGrade, self, 1},
		{"2V2对战",self.DoShowMyGrade, self, 2},
		{"3V3对战",self.DoShowMyGrade, self, 3},
		{"4V4对战",self.DoShowMyGrade, self, 4},
		{"5V5对战",self.DoShowMyGrade, self, 5},
		{"6V6对战",self.DoShowMyGrade, self, 6},
		{"Để ta suy nghĩ lại",self.OnCancel},	});
end;

function BiWu:DoShowMyGrade(nType)
	local nCount = me.GetTask(self.TSKG_BIWU, self.TSK_TB_COUNT[nType]);
	local nTAWinCnt = me.GetTask(self.TSKG_BIWU, self.TSK_TB_TOTALWIN[nType]);
	local nTALosCnt = nCount-nTAWinCnt;
	local nCLWinCnt = me.GetTask(self.TSKG_BIWU, self.TSK_TB_CURLINKWIN[nType]);
	local nMLWinCnt = me.GetTask(self.TSKG_BIWU, self.TSK_TB_MAXLINKWIN[nType]);
	Dialog:Say(string.format("你%dV%d的参赛总场次数：%d场",
								nType, nType,nCount
								), 
			{
			{"查询其他比赛类型",self.ShowMyGrade,self},
			{"Để ta suy nghĩ lại",self.OnCancel},
			});
end;
