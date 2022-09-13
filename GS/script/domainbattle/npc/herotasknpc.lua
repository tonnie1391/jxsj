-- 英雄任务授予仪式，时间关系，代码比较的乱

local tbManager 		= {};
Task.HeroTaskManager 	= tbManager;
tbManager.nMapId 		= 1541;

function tbManager:Open()
	if SubWorldID2Idx(self.nMapId) < 0 then
		return;
	end
	
	self.tbNpc = {};
	local pNpc = KNpc.Add2(4462, 120, -1, self.nMapId, 1597, 3227);
	self.tbNpc["shixuanyuan"] = pNpc.dwId;
	local pNpc = KNpc.Add2(4458, 120, -1, self.nMapId, 1603, 3221);
	self.tbNpc["hantuozhou"] = pNpc.dwId;
	local pNpc = KNpc.Add2(4460, 120, -1, self.nMapId, 1599, 3225);
	self.tbNpc["yangtiexin"] = pNpc.dwId;
	local pNpc = KNpc.Add2(4456, 120, -1, self.nMapId, 1601, 3223);
	self.tbNpc["baiqiulin"] = pNpc.dwId;
	local pNpc = KNpc.Add2(4464, 120, -1, self.nMapId, 1593, 3232);
	self.tbNpc["guanyuan_1"] = pNpc.dwId;
	local pNpc = KNpc.Add2(4464, 120, -1, self.nMapId, 1591, 3234);
	self.tbNpc["guanyuan_2"] = pNpc.dwId;
	local pNpc = KNpc.Add2(4464, 120, -1, self.nMapId, 1589, 3236);
	self.tbNpc["guanyuan_3"] = pNpc.dwId;
	local pNpc = KNpc.Add2(4464, 120, -1, self.nMapId, 1587, 3238);
	self.tbNpc["guanyuan_4"] = pNpc.dwId;
	
	local pNpc = KNpc.Add2(4471, 120, -1, self.nMapId, 1614, 3215);
	self.tbNpc["libushangshu"] = pNpc.dwId;
	
end;

-- 走出去再走回来说话
function tbManager:MoveToSay(nId, tbPos, nChangeId, szText, szName)
	local tbOnArrive = {self.OnArrive1, self, nId, szText, tbPos, nChangeId, szName};
	self:Escort(nId, tbPos[1], tbOnArrive)
end;

function tbManager:Escort(nId, tbPos, tbOnArrive)
	local pNpc = KNpc.GetById(nId);
	assert(pNpc);
	pNpc.SetCurCamp(0);
	pNpc.RestoreLife();
	pNpc.GetTempTable("Npc").tbOnArrive = tbOnArrive;
	pNpc.AI_ClearPath();
	for _,Pos in ipairs(tbPos) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
		end
	end;
	pNpc.SetNpcAI(9, 0, 0, -1, 25, 25, 25, 0, 0, 0, 0);
end;

function tbManager:OnArrive1(nId, szText, tbPos, nChangeNpcId, szName)
	local tbPlayList, _ = KPlayer.GetMapPlayer(self.nMapId);
	local pNpc = KNpc.GetById(nId);
	assert(pNpc);
	pNpc.SendChat(szText);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(szText, pNpc.szName);
	end;
	
	local tbArrive = {self.OnArrive2, self, pNpc.dwId, nChangeNpcId, szName};
	tbManager:Escort(nId, tbPos[2], tbArrive);
end;

function tbManager:OnArrive2(nId, nChangeNpcId, szName)
	local pNpc = KNpc.GetById(nId);
	assert(pNpc);
	local nMapId, nX, nY = pNpc.GetWorldPos();
	pNpc.Delete();
	local pNpc = KNpc.Add2(nChangeNpcId, 120, -1, nMapId, nX, nY);
	self.tbNpc[szName] = pNpc.dwId;
end;

-- 说一句话
function tbManager:Say(nId, szText)
	local pNpc = KNpc.GetById(nId);
	assert(pNpc);

	local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
	local pNpc = KNpc.GetById(nId);
	assert(pNpc);

	pNpc.SendChat(szText);
	
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(szText, pNpc.szName);
	end;	
end;

--礼部尚书
local tbNpcShangShu 		= Npc:GetClass("hr_libushangshu");
tbNpcShangShu.MAP_ID 		= 1;
tbNpcShangShu.tbShengZhi 	= {
		"奉天承运，皇帝诏曰：",
		"在领土战中功绩卓绝，有目共睹",
		"为表嘉奖，以示圣恩，准其上殿面圣",
		"并令巧匠树其雕像，以供万民敬仰",
		"钦此！",
	}
tbNpcShangShu.tbWisher = {
		"hr_hantuozhou",
		"hr_baiqiulin",
		"hr_yangtiexin",
		"hr_shixuanyuan",
		"hr_guanyuan",
		"hr_guanyuan",
		"hr_guanyuan",
		"hr_guanyuan",
	}

function tbNpcShangShu:OnDialog()
	local tbNpc = Npc:GetClass("chaotingyushi");
	if( tbNpc:IsFirst(me) == 0 or me.GetTask(1024, 62) == 1) then
		local szMsg = string.format("%s：%s%s", him.szName, me.szName, ", xin chào!！");
		Dialog:Say(szMsg, {{"Kết thúc đối thoại"}});
		return;
	end;
	
	tbManager.szHeroName = me.szName;
	
	local szMsg = "仪式可随时开始，若无需要等待的好友良朋我便开始宣读圣旨了。";
	local tbOpt = {
		{"开始仪式", self.Start2, self, him.dwId},
		{"再等一等"},
	}
	Dialog:Say(szMsg, tbOpt);	
end;

-- 2
function tbNpcShangShu:Start2(nNpcId)
	-- 通知全服
	me.SetTask(1024, 62, 1); 
	local szMsg = "为表彰玩家<color=red>" .. me.szName .."<color>在领土争夺战“霸主任务”中作出的杰出贡献，皇帝在宫中设下宴席，并特许百姓通过临安皇宫门前的礼部侍郎前来观礼。"
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=4471>：“吉时已到，本阁奉皇命主持仪式；请诸位肃静，聆听圣旨。”");
		Setting:RestoreGlobalObj();
	end;
	
	self.nTimerId = Timer:Register(Env.GAME_FPS * 5, self.OnBreath, self, nNpcId);
	self.nTalkNo = 1;
end;

function tbNpcShangShu:OnBreath(nNpcId)
	local pNpc 	= KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end;
	local szMsg = self.tbShengZhi[self.nTalkNo];
	if (self.nTalkNo == 2) then
		szMsg = "<color=red>" .. tbManager.szHeroName .. "<color>，" .. szMsg;
	end;

	pNpc.SendChat(szMsg);
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		teammate.Msg(szMsg, pNpc.szName);
	end;
	
	self.nTalkNo = self.nTalkNo + 1;
	if (self.nTalkNo > 5) then
		self:Start3(nNpcId)
		return 0;
	end;	
end;

-- 3
function tbNpcShangShu:Start3(nNpcId)
	local pNpc 	= KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=4471>：“皇上有旨：今日为授予吉日，在殿诸位不论君臣，请各自尽兴。来本阁先敬<color=red>" ..tbManager.szHeroName .. "<color>一杯；在座诸位都不要拘束！”");
		Setting:RestoreGlobalObj();
	end;
	
	Timer:Register(Env.GAME_FPS * 10, self.OnBreath3, self, nNpcId);
	self.nWishNo = 1;
end;

function tbNpcShangShu:OnBreath3(nNpcId)
	if (self.nWishNo > 8) then
		return 0;
	end;
	
	local tbWisher = Npc:GetClass(self.tbWisher[self.nWishNo]);
	tbWisher:Wish(nNpcId, tbManager.szHeroName);
	
	if (self.nWishNo == 5) then
		local tbWisher = Npc:GetClass(self.tbWisher[6]);
		tbWisher:Wish(nNpcId, tbManager.szHeroName);
		
		tbWisher = Npc:GetClass(self.tbWisher[7]);
		tbWisher:Wish(nNpcId, tbManager.szHeroName);
		
		tbWisher = Npc:GetClass(self.tbWisher[8]);
		tbWisher:Wish(nNpcId, tbManager.szHeroName);
	end;
	
	self.nWishNo = self.nWishNo + 1;
	if (self.nWishNo > 5) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Setting:SetGlobalObj(teammate);
			TaskAct:Talk("<npc=4471>：“皇上特地下旨在临安城中广放烟花。此刻当是烟火缤纷，满城同庆。”");
			Setting:RestoreGlobalObj();
		end;
		-- "系统公告"
		local tbFireWorks = Npc:GetClass("hr_fireworks");
		tbFireWorks:OnOpen();
		return 0;
	end;
end;


local tbHanTuoZhou 	= Npc:GetClass("hr_hantuozhou");
tbHanTuoZhou.szText = "雄鹰展翅，任重而道远。"	;
function tbHanTuoZhou:Wish(szName)
	if (not tbManager or not tbManager.tbNpc["hantuozhou"]) then
		return;
	end;
	
	self.szText = "<color=red>" .. tbManager.szHeroName .. "<color>" .. self.szText;
	tbManager:Say(tbManager.tbNpc["hantuozhou"], self.szText);
end;

local tbBaiQiuLin 	= Npc:GetClass("hr_baiqiulin");
tbBaiQiuLin.szText 	= "秋琳代表义军恭祝皇上，江山永固，万万岁！";
tbBaiQiuLin.tbPos 	= {
		{{1601, 3223}, {1603, 3226}, {1606, 3225}, {1610, 3224}, {1611, 3225}},
		{{1611, 3225}, {1610, 3224}, {1606, 3225}, {1603, 3226}, {1601, 3223}},
	}

function tbBaiQiuLin:Wish(szName)
	if (not tbManager or not tbManager.tbNpc["baiqiulin"]) then
		return;
	end;
	
	local pNpc = KNpc.GetById(tbManager.tbNpc["baiqiulin"]);
	
	local nMapId, nX, nY = pNpc.GetWorldPos();
	pNpc.Delete();
	local pNpc = KNpc.Add2(4457, 120, -1, nMapId, nX, nY);
	tbManager:MoveToSay(pNpc.dwId, self.tbPos, 4456, self.szText, "baiqiulin");
end;


local tbYangTieXin 	= Npc:GetClass("hr_yangtiexin");
tbYangTieXin.szText 	= "天王帮上下祝皇上龙体安康，国运昌盛，万万岁！";
tbYangTieXin.tbPos 	= {
		{{1599, 3225}, {1603, 3226}, {1606, 3225}, {1610, 3224}, {1611, 3225}},
		{{1611, 3225}, {1610, 3224}, {1606, 3225}, {1603, 3226}, {1599, 3225}},
	}

function tbYangTieXin:Wish(szName)
	if (not tbManager or not tbManager.tbNpc["yangtiexin"]) then
		return;
	end;
	
	local pNpc = KNpc.GetById(tbManager.tbNpc["yangtiexin"]);
	
	local nMapId, nX, nY = pNpc.GetWorldPos();
	pNpc.Delete();
	local pNpc = KNpc.Add2(4461, 120, -1, nMapId, nX, nY);
	tbManager:MoveToSay(pNpc.dwId, self.tbPos, 4460, self.szText, "yangtiexin");
end;

local tbHanTuoZhou 	= Npc:GetClass("hr_shixuanyuan");
tbHanTuoZhou.szText = "叫花子就不上去讨人厌了，我在这里喝酒吧！"	;
function tbHanTuoZhou:Wish(szName)
	if (not tbManager or not tbManager.tbNpc["shixuanyuan"]) then
		return;
	end;
	
	tbManager:Say(tbManager.tbNpc["shixuanyuan"], self.szText);
end;

local tbGuanYuan 	= Npc:GetClass("hr_guanyuan");
tbGuanYuan.tbText 	= {
		"少年有为！", 
		"可喜可贺！", 
		"我大宋收复失地有望了！", 
		"真是少年俊杰！"
	};
function tbGuanYuan:Wish(szName)
	if (not self.nNo or self.nNo <= 0 or self.nNo > 4) then
		self.nNo = 1;
	end;
	local szNpcName = "guanyuan_" .. self.nNo;
	if (not tbManager or not tbManager.tbNpc[szNpcName]) then
		return;
	end;

	
	tbManager:Say(tbManager.tbNpc[szNpcName], self.tbText[self.nNo]);
	self.nNo = self.nNo + 1;
end;

local tbFireWorks = Npc:GetClass("hr_fireworks");

function tbFireWorks:OnOpen()
	local szMsz = "为了表彰玩家<color=red>" .. tbManager.szHeroName .. "<color>在此次“霸主任务”中所做的杰出贡献，皇上下令大放烟火，普天同庆。"
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	
	tbManager.tbFirews = {};
	local pNpc = KNpc.Add2(4465, 125, -1, 29, 1626, 3967);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	pNpc = KNpc.Add2(4465, 125, -1, 29, 1745, 3831);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	pNpc = KNpc.Add2(4465, 125, -1, 29, 1724, 4084);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	pNpc = KNpc.Add2(4465, 125, -1, 29, 1654, 3939);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	pNpc = KNpc.Add2(4465, 125, -1, 29, 1919, 3919);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	
	pNpc = KNpc.Add2(4465, 125, -1, tbManager.nMapId, 1609, 3224);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	pNpc = KNpc.Add2(4465, 125, -1, tbManager.nMapId, 1605, 3235);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	pNpc = KNpc.Add2(4465, 125, -1, tbManager.nMapId, 1594, 3239);
	tbManager.tbFirews[#tbManager.tbFirews + 1] = pNpc.dwId;
	
	Timer:Register(Env.GAME_FPS * 5, self.OnBreath, self);
end;

function tbFireWorks:OnBreath()
	if (not tbManager.nFireStart or tbManager.nFireStart < 1) then
		tbManager.nFireStart = 1;
	end;
	
	for i = 1, #tbManager.tbFirews do
		local pNpc = KNpc.GetById(tbManager.tbFirews[i]);
		if (pNpc) then
			pNpc.CastSkill(307, 1, -1, pNpc.nIndex);
			local tbPlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, 300);
			if (tbPlayerList) then
				for _, pPlayer in ipairs(tbPlayerList) do
					if (pPlayer.nLevel >= 50) then
						pPlayer.AddExp(50000);
					end;
				end;
			end;
		end;
	end;
	
	
	tbManager.nFireStart = tbManager.nFireStart + 1;
	if (tbManager.nFireStart > 10) then
		for i = 1, #tbManager.tbFirews do
			if (tbManager.tbFirews[i]) then
				local pNpc = KNpc.GetById(tbManager.tbFirews[i]);
				if (pNpc) then
					pNpc.Delete();
				end;
			end;
		end;
		
		-- 系统公告
		local szMsz = "为了表彰玩家<color=red>" .. tbManager.szHeroName .. "<color>在领土争夺战“霸主任务”中作出的杰出贡献，皇帝在宫中设下宴席，并特许百姓通过临安皇宫门前的礼部侍郎进入朝圣阁观礼。"
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Setting:SetGlobalObj(teammate);
			TaskAct:Talk("<npc=4471>：“此番有幸请得翠烟门主为诸位献上一曲；请诸位洗耳聆听。”");
			Setting:RestoreGlobalObj();
		end;
		
		self:OnStartMusic();
		return 0;
	end;
end;

function tbFireWorks:OnStartMusic()
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);

	local nNo = 0;	
	for _, teammate in ipairs(tbPlayList) do
		if ( nNo / 4 == 0) then
			teammate.NewWorld(teammate.nMapId, 1607, 3217);
		elseif (nNo / 4 == 1) then
			teammate.NewWorld(teammate.nMapId, 1620, 3232);
		elseif (nNo / 4 == 2) then
			teammate.NewWorld(teammate.nMapId, 1599, 3221);
		else
			teammate.NewWorld(teammate.nMapId, 1617, 3240);
		end;
		nNo = nNo + 1;
	end;
	
	tbManager.tbDanceNpc = {};
	local tbNpcPos = {
		[1] = {
				{1613, 3222}, {1616, 3225}
			},
		[2] = {
				{1619, 3238}, {1616, 3242}, {1608, 3250}, {1605, 3253}
			},
		}
		for i = 1, #tbNpcPos[1] do
			local pNpc = KNpc.Add2(4468, 120, -1, tbManager.nMapId, tbNpcPos[1][i][1], tbNpcPos[1][i][2]);
			tbManager.tbDanceNpc[#tbManager.tbDanceNpc + 1] = pNpc.dwId;	
		end;
		for i = 1, #tbNpcPos[2] do
			local pNpc = KNpc.Add2(4469, 120, -1, tbManager.nMapId, tbNpcPos[2][i][1], tbNpcPos[2][i][2]);
			tbManager.tbDanceNpc[#tbManager.tbDanceNpc + 1] = pNpc.dwId;	
		end;
		
		for _, teammate in ipairs(tbPlayList) do
			teammate.CallClientScript({"PlaySound", "\\audio\\map\\m3007.mp3", 1});
		end;
		self:YiYuOut();
	
	self.AddExpTimerId = Timer:Register(Env.GAME_FPS, self.AddExp, self);	
	Timer:Register(Env.GAME_FPS * 2 * 60, self.OnClose, self);	
end;

function tbFireWorks:AddExp()
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		if (teammate.nLevel >= 50) then
			teammate.AddExp(50000);
		end;
	end;
end;

function tbFireWorks:YiYuOut()
	local tbPos = {
			{1610, 3210}, {1608, 3215}, {1608, 3220}, {1608, 3224}, {1609, 3229}
		};
	local pNpc = KNpc.Add2(4467, 120, -1, tbManager.nMapId, 1610, 3210);
	local tbOnArrive = {self.YiYuOnArrive, self, pNpc.dwId};
	tbManager:Escort(pNpc.dwId, tbPos, tbOnArrive);
end;

function tbFireWorks:YiYuOnArrive(nId)
	local pNpc = KNpc.GetById(nId);
	assert(pNpc);
	pNpc.Delete();
	pNpc = KNpc.Add2(4466, 120, -1, tbManager.nMapId, 1609, 3229);
	tbManager.tbDanceNpc[#tbManager.tbDanceNpc + 1] = pNpc.dwId;
end;
	
function tbFireWorks:OnClose()
	if (self.AddExpTimerId) then
		Timer:Close(self.AddExpTimerId);
		self.AddExpTimerId = nil;
	end;
	
	local tbPlayList, _ = KPlayer.GetMapPlayer(tbManager.nMapId);
	for _, teammate in ipairs(tbPlayList) do
		Setting:SetGlobalObj(teammate);
		TaskAct:Talk("<npc=4471>：“授予仪式结束，请在殿诸位谢恩退朝。”");
		Setting:RestoreGlobalObj();
	end;	
	
	for i = 1, #tbManager.tbDanceNpc do
		local pNpc = KNpc.GetById(tbManager.tbDanceNpc[i]);
		if (pNpc) then
			pNpc.Delete();
		end;
	end;
	
	return 0;
end;

if MODULE_GAMESERVER then
	ServerEvent:RegisterServerStartFunc(Task.HeroTaskManager.Open, Task.HeroTaskManager);
end
