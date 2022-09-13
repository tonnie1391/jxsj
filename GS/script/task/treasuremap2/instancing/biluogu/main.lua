------------------------------------------------------
-- 文件名　：main.lua
-- 创建者　：dengyong
-- 创建时间：2012-08-02 16:04:54
-- 描  述  ：碧落谷副本逻辑
------------------------------------------------------
Require("\\script\\task\\treasuremap\\treasuremap.lua");
Require("\\script\\task\\treasuremap2\\treasuremap.lua");

local tbInstancing = TreasureMap2:GetInstancingBase(7);

-- 进度条开启时间
tbInstancing.PROCESS_TIME	= 3 * Env.GAME_FPS;

-- 障碍NPC的ID和位置
tbInstancing.tbObstacleInfo = 
{
	[1] = 
	{
		{
			7006, {53440/32, 111328/32}, {53408/32, 111360/32}, {53376/32, 111392/32}, {53344/32, 111424/32},
			{53312/32, 111456/32}, {53280/32, 111488/32}, {53248/32, 11520/32},
		},
	},
	[2] = 
	{
		{
			7006, {55104/32, 110592/32}, {55136/32, 110624/32}, {55168/32, 110656/32}, {55200/32, 110688/32},
		},
	},
	[3] = 
	{
		{
			7006, {56384/32, 109952/32}, {56416/32, 109920/32}, {56448/32, 109888/32}, {56480/32, 109856/32},
		},
	}
}

-- 碰到障碍之后被弹至的坐标
tbInstancing.tbTrapBackPos = 
{
	[1] = {53248/32, 111328/32},
	[2] = {55040/32, 110784/32},
	[3] = {56384/32, 109792/32},
}

-- boss2跑跑点
tbInstancing.tbBoss2AiPos =
{
	{55072, 110816},
	{55488, 109792},
}

-- 她的寻路点
tbInstancing.tbHerAiPos =
{
	[1] =
	{
		{52672, 110592},
		{53120, 111168},
		{53792, 111936},
		{54016, 112160},
		{54720, 111360},
	},
	[2] =
	{
		{54944, 110976},
		{55360, 110144},
		{55648, 109600},
		{55936, 109208},
	},
	[3] =
	{
		{56352, 109760},
		{56704, 110496},
		{57344, 111264},
		{57408, 111776},
		{56832, 112832},
	},	
}

-- 杂兵1
tbInstancing.tbXiaoBing1Pos =
{
	{ 52512/32, 110688/32 },
	{ 52416/32, 110816/32 },
	{ 52352/32, 111008/32 },
	{ 52480/32, 111232/32 },
	{ 52640/32, 111232/32 },
	{ 52800/32, 111104/32 },
}

-- 杂兵2
tbInstancing.tbXiaoBing2Pos = 
{
	{ 54720/32, 110912/32 },
	{ 54720/32, 111168/32 },
	{ 54656/32, 111360/32 },
	{ 54816/32, 111008/32 },
	{ 54944/32, 111136/32 },
	{ 54848/32, 111264/32 },
}

-- 机关NPC坐标
tbInstancing.tbJiGuanPos = 
{
	--{ 55584/32, 109056/32 },
	--{ 55680/32, 109504/32 },
	--{ 55872/32, 108736/32 },
	--{ 56192/32, 109088/32 },
	--{ 56064/32, 109536/32 },	
	{ 55520/32,	109184/32 },
	{ 55904/32,	108832/32 },
	{ 56288/32,	109152/32 },
	{ 55808/32,	109792/32 },
	{ 56224/32,	109664/32 },
	
}

tbInstancing.XIAOBING_TEMP		= 11028
tbInstancing.SHE_TEMPLATE_ID1	= 11030;
tbInstancing.SHE_TEMPLATE_ID2	= 11038;
tbInstancing.BOAT_TEMPLATE		= 11057

-- 子书青，用来表现剧情的点
tbInstancing.tbHerAddPos1 = 
{
	{52640/32, 110560/32},
	{56032/32, 109440/32},
	{52608/32, 118112/32},
}

-- 子书青，战斗的点
tbInstancing.tbHerAddPos2 = 
{
	{55936/32, 109208/32},
	{52928/32, 117856/32},
}

-- 竹筏的点
tbInstancing.tbBoadAddPos = 
{
	{57152/32, 113568/32},
	{57248/32, 113440/32},
	{57344/32, 113344/32},
}

-- 离开船需要的点
tbInstancing.tbBoatLeavePos = 	
{
	{54528/32, 116864/32},
	{54496/32, 116800/32},
}

-- 步骤经验
tbInstancing.tbStepExp = 
{
--	[1] = {0, 0, 35000, 45000, 10000, 50000, 30000, 0, 60000, 0},
--	[2] = {0, 0, 227500, 292500, 65000, 325000, 195000, 0, 390000, 0},
--	[3] = {0, 0, 3372950, 4336650, 963700, 4818500, 2891100, 0, 5782200, 0},
	[1] = {0, 0, 30, 40, 40, 45, 55, 0, 70, 0},
	[2] = {0, 0, 55, 65, 70, 75, 85, 0, 100, 0},
	[3] = {0, 0, 55, 65, 70, 75, 85, 0, 100, 0},
}

tbInstancing.tbStepTips = 
{
	"<color=red>Đánh bại Tịch Diệm<color>",
	"<color=red>Bảo vệ Tử Thư Thanh<color>",
	"<color=red>Đánh bại Phương Tây Bạch<color>",
	"<color=red>Phá giải Trận pháp<color>",
	"<color=red>Đánh bại Phương Tây Bạch<color>",
	"<color=red>Đến bến đò<color>",
	"<color=red>Phá hủy Phệ Hồn Đăng<color>",
	"<color=red>Đánh bại Võ Thị Văn<color>",
}

-- 跳船前的传送点
tbInstancing.tbBoatLandInPos = {57056, 113120};

-- 各个BOSS的积分
tbInstancing.tbBossScore =
{
	{18, 20, 40, 60},
	{27, 30, 60, 90},
	{54, 60, 120, 180,}
}

-- 马牌随机信息
tbInstancing.tbHorseRandomInfo = 
{
	{{1, 12, 68, 1}, 15,  7 * 24 * 3600},	-- 15%, 7天
	{{1, 12, 68, 2}, 2,  30 * 24 * 3600},	-- 2%, 30天
	{{1, 12, 57, 4}, 2,  30 * 24 * 3600},	-- 2%, 30天
}

-- 小兵的积分
tbInstancing.tbXiaoBingScore = {2, 3, 6};
tbInstancing.SKILL_BUFF_ID	 = 1972;	-- 秋姨的祝福
tbInstancing.SKILL_BUFF_TIME = 18 * 3600 * 2;		-- buf时间
tbInstancing.SKILL_BUFF_LIMIT_LEVEL = 50;	-- buff限制等级，50级以上的不加buf

tbInstancing.tbHerTalkContent = 
{
	[1] =
	{
		"一别以来，我在……一个地方一直修炼武艺，你也没有丢下功夫吧？",
		"听说义军的据点被频繁袭击，你又这么没用……我当然要来看看你有没有事",
		"人家只是着急大意了，不然就凭那个粗汉，哼！怎么可能抓的住我",
	},
	[3] =
	{
		"这一伙人自称狩义，听义军的前辈说，他们在四处袭击义军的据点。",
		"这个地方是很隐蔽的所在，按理说不应该被轻易发现才是啊……",
		"据点被突袭时，他们的目标很明确。就是在到处寻找我的下落，想必……",
		"说起来，前段时间我拜了一位很高的高人为师。你现在一定不是我的对手了哦~",
	}
}

local function __DelNpc(pNpc)
	if pNpc then
		pNpc.Delete();
		pNpc = nil;
	end
end

function tbInstancing:ChuanfuDialog()
	local szMsg = "";
	local tbOpt = {};
	
	if self.WATER_FIGHT_FINISHED == 1 then
		szMsg = "Đại hiệp, có chuyện gì chăng?";
		tbOpt = 
		{
			{"<color=yellow>Đưa ta sang bến đò bên kia<color>", me.NewWorld, self.nMapId, unpack(self.tbBoatLeavePos[2])},		-- 是的，确实是飞过去的
			{"Để ta suy nghĩ thêm"},
		}
		Dialog:Say(szMsg, tbOpt);
		return;
	elseif self.nBoatUsed and self.nBoatUsed > 3 then
		Dialog:Say("Đã hết bè tre rồi!");
		return;
	end
		
	szMsg = "Thật may mắn khi còn lại 3 chiếc bè tre. Người đầu tiên lên bè sẽ phải điều khiển hướng đi và chọn bạn đi cùng. Nhanh chân lên nào!";
	tbOpt = 
	{
		{"<color=yellow>Ta lên trước<color>", self.ApplyCtrBoat, self, 1},
		{"Để ta suy nghĩ thêm"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbInstancing:ApplyCtrBoat(nStep, dwId)
	local szMsg = "Chọn bạn đi cùng:";
	local tbOpt = {};
	
	if nStep == 1 then		
		local tbPlayerList = self:GetPlayerList();
		for _, pPlayer in pairs(tbPlayerList) do
			if pPlayer.nId ~= me.nId and pPlayer.IsInCarrier() == 0 then
				table.insert(tbOpt, {pPlayer.szName, self.ApplyCtrBoat, self, 2, pPlayer.nId});
			end		
		end	
		
		if #tbOpt == 0 then
			self:BringPlayerToBoat({{me, 0}});
			return;		
		end		
		
		Dialog:Say(szMsg, tbOpt);
	elseif nStep == 2 then
		local pPlayer = KPlayer.GetPlayerObjById(dwId);
		if not pPlayer then
			return;
		end
		
		if pPlayer.IsInCarrier() == 1 then
			me.Msg(pPlayer.szName.." đã lên bè khác!");
			self:ApplyCtrBoat(1);
			return;
		end
		
		local tb = {}
		table.insert(tb, {me, 0});
		table.insert(tb, {pPlayer, 1});
		self:BringPlayerToBoat(tb, me);		
	end		
end

function tbInstancing:BringPlayerToBoat(tb, pPlayer)
	if not self.tbBoat then
		pPlayer.Msg("Đã hết bè tre rồi!");
		return;
	end
	
	self.nBoatUsed = self.nBoatUsed or 1;
	local pBoat = self.tbBoat[self.nBoatUsed];
	if not pBoat then
		return;
	end
	for _, _tb in pairs(tb) do
		if _tb[1].IsInCarrier() == 0 then
			_tb[1].RideHorse(0);
			_tb[1].NewWorld(self.nMapId, self.tbBoatLandInPos[1]/32, self.tbBoatLandInPos[2]/32);
			Npc.tbCarrier:LandInCarrier(pBoat, unpack(_tb));
		end
	end	
	self.nBoatUsed = self.nBoatUsed + 1;
	pBoat.SetFightState(1);
end

function tbInstancing:OnPlayerLeaveBoat(pPlayer)
	pPlayer.SetFightState(1);
	pPlayer.NewWorld(self.nMapId, unpack(self.tbBoatLeavePos[2]));
	
	-- 回收空船
	local tbPassenger = him.GetCarrierPassengers();
	if Lib:CountTB(tbPassenger) == 0 then
		for i, pBoat in pairs(self.tbBoat) do
			if pBoat.dwId == him.dwId then
				table.remove(self.tbBoat, i);
				pBoat.Delete();				
				pBoat = KNpc.Add2(self.BOAT_TEMPLATE, self.nNpcLevel, -1, self.nMapId, unpack(self.tbBoadAddPos[i]));
				if pBoat then
					table.insert(self.tbBoat, pBoat);
				end
				break;
			end
		end
		
		self.nBoatUsed = self.nBoatUsed - 1;
	end
end

function tbInstancing:OnNew()
	self.nStep = 0;
	self.WATER_FIGHT_FINISHED = 0;
	self.nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.nTreasureId].tbNpcLevel[self.nTreasureLevel] ;
	
	self.BOSS1_TEMPLATE_DIALOG	= {11032, self.nNpcLevel, -1, self.nMapId, 52704/32, 110688/32};
	self.BOSS1_TEMPLATE_FIGHT	= {11029, self.nNpcLevel, -1, self.nMapId, 52704/32, 110688/32};
	self.BOSS2_TEMPLATE_STEP1	= {11031, self.nNpcLevel, -1, self.nMapId, 54880/32, 110880/32};
	self.BOSS2_TEMPLATE_STEP2	= {11033, self.nNpcLevel, -1, self.nMapId, 54880/32, 110880/32};
	self.BOSS2_TEMPLATE_STEP3	= {11034, self.nNpcLevel, -1, self.nMapId, 55744/32, 109024/32};	
	self.BOSS3_TEMPLATE_DIALOG	= {11039, self.nNpcLevel, -1, self.nMapId, 52608/32, 118080/32}; 
	self.BOSS3_TEMPLATE_FIGHT	= {11036, self.nNpcLevel, -1, self.nMapId, 52608/32, 118080/32};
	self.LINYANQIN_DIALOG		= {11037, self.nNpcLevel, -1, self.nMapId, 52864/32, 117984/32};
	
	-- 添加障碍
	self:AddObstacleNpc();
	
	-- 添加BOSS1，对话型NPC
	--self.pBoss1 = KNpc.Add2(self.BOSS1_TEMPLATE_DIALOG, self.nNpcLevel, -1, self.nMapId, 52704/32, 110688/32);
	self.pBoss1 = KNpc.Add2(unpack(self.BOSS1_TEMPLATE_DIALOG))
	self.nBoss1Dialog = 1;
	
	-- 流程控制
	self.tbProcess = 
	{
		{self.ProcStep1, self},		-- 击败小兵
		{self.ProcStep2, self},		-- 夕焱喊话
		{self.ProcStep3, self},		-- 击败夕焱
		{self.ProcStep4, self},		-- 击败方西白1
		{self.ProcStep4_2, self},	-- 硬解五音机关
		{self.ProcStep5, self},		-- 击败方西白2
		{self.ProcStep6, self},		-- 击毁噬魂灯
		{self.ProcStep7, self},		-- 武氏文喊话
		{self.ProcStep8, self},		-- 击败武氏文
		{self.ProcEnd, self},		-- end mission
	}
	
	self.nHerTalkCount = 1;
	self.nBossStep	= 0;
	self.nUiMsgTipStep = 0;
	self.nBoss3TalkCall = nil;
end

-- 对所有从弹出黑框剧情
function tbInstancing:BlackSkyTalk(szMsg, ...)
	for _, pPlayer in pairs(self:GetPlayerList()) do
		local _OldMe = me;
		me = pPlayer;
		szMsg = string.format(szMsg, pPlayer.szName);
		TaskAct:Talk(szMsg, ...);
		me = _OldMe;
	end
end

-- 刷新第一波小怪
function tbInstancing:RefreshNpc1()
	self.MONSTER1_COUNT = 6;
	for _, tbPos in pairs(self.tbXiaoBing1Pos) do
		local pNpc = KNpc.Add2(self.XIAOBING_TEMP, self.nNpcLevel, -1, self.nMapId, unpack(tbPos));
		if pNpc then
			pNpc.GetTempTable("TreasureMap2").nNpcScore = self.tbXiaoBingScore[self.nTreasureLevel];
		end
	end
end

-- 刷新第二波小怪
function tbInstancing:RefreshNpc2()
	for _, tbPos in pairs(self.tbXiaoBing2Pos) do
		local pNpc = KNpc.Add2(self.XIAOBING_TEMP, self.nNpcLevel, -1, self.nMapId, unpack(tbPos));
		if pNpc then
			pNpc.GetTempTable("TreasureMap2").nNpcScore = self.tbXiaoBingScore[self.nTreasureLevel];
		end
	end
end

-- 随机刷出5个机关NPC，指定开启顺序
function tbInstancing:AddJiGuanNpc()
	self.tbJiGuanSort = {};		-- 机关开启顺序
	self.tbJiGuanOpen = {};		-- 已开启机关序列
	
	local tbName = {"[Địa]", "[Thủy]", "[Hỏa]", "[Phong]", "[Lôi]"};
	local tbName2 = {unpack(tbName)};
	
	for _, tbPos in pairs(self.tbJiGuanPos) do
		local nRand = MathRandom(1, #tbName);
		local nRandSort = MathRandom(1, #tbName2);
		table.insert(self.tbJiGuanSort, tbName2[nRandSort]);
		local pNpc = KNpc.Add2(11035, self.nNpcLevel, -1, self.nMapId, unpack(tbPos));
		pNpc.szName = tbName[nRand];
		table.remove(tbName, nRand);
		table.remove(tbName2, nRandSort);
	end
end

function tbInstancing:AddObstacleNpc()
	self.tbObstacleNpc = {};
	for i, tbInfo in pairs(self.tbObstacleInfo) do
		self.tbObstacleNpc[i] = {};
		
		for _, tbData in pairs(tbInfo) do		
			local nTemplate = tbData[1];
			for _, v in pairs(tbData) do
				if type(v) == "table" then
					local pNpc = KNpc.Add2(nTemplate, 20, -1, self.nMapId, v[1], v[2]);
					if pNpc then
						table.insert(self.tbObstacleNpc[i], pNpc);
					end
				end
			end			
		end
	end
	self.nObstacleStepClear = 0;
end

-- 指定清除某个步骤的障碍
function tbInstancing:ClearObstacle(nStep)
	if not self.tbObstacleNpc or not self.tbObstacleNpc[nStep] then
		return;
	end
	
	local tbNpc = self.tbObstacleNpc[nStep];
	for _, pNpc in pairs(tbNpc) do
		if pNpc then
			pNpc.Delete();
		end
	end
	self.nObstacleStepClear = nStep;
end

-- 过程切换
function tbInstancing:GoNextStep()
	self.nStep = self.nStep + 1;
	
	if not self.tbProcess[self.nStep] then
		--print("【Fatal Error!】Unkown Step！");
		return 0;
	end
	
	local tbProc = self.tbProcess[self.nStep];
	local _, nRet = Lib:CallBack(tbProc);
	if nRet ~= 1 then
	--	print("【Fatal Error!】Cannot find the way!");
	end
	
	self:UpdateMsgUI();
	
	-- 添加步骤经验
	local tbExp = self.tbStepExp[self.nTreasureLevel];
	local nExp = (tbExp and tbExp[self.nStep]) or 0;
	if nExp ~= 0 then
		for _, pPlayer in pairs(self:GetPlayerList()) do
			local nBaseExp = pPlayer.GetBaseAwardExp();
			pPlayer.AddExp(nExp * nBaseExp);
		end
	end
end

-- 点击一个机关
function tbInstancing:ApplyJiGuan(szName, bConfim)
	if #self.tbJiGuanOpen == 5 then
		return;
	end
	
	bConfim = bConfim or 0;
	if bConfim == 0 then
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
			
		GeneralProcess:StartProcess("Đang mở...", self.PROCESS_TIME, {self.ApplyJiGuan, self, szName, 1}, nil, tbEvent);		
	else
		KTeam.Msg2Team(me.nTeamId, me.szName.." đã mở "..szName);	
		if self.tbJiGuanSort[#self.tbJiGuanOpen + 1] == szName then
			self.tbJiGuanOpen[#self.tbJiGuanOpen + 1] = szName;
		else
			KTeam.Msg2Team(me.nTeamId, "Thứ tự mở không đúng, hãy mở lại từ đầu!");
			self.tbJiGuanOpen = {};
		end
		
		if #self.tbJiGuanOpen == 5 then
			self:GoNextStep();
		end
	end
end

-- 刚开场，与BOSS1对话号刷一波小怪
function tbInstancing:ProcStep1()
	self:RefreshNpc1();
	self.nBoss1Dialog = 0;
end

-- 第一波小怪死光了，boss1喊话，喊话结束变身战斗NPC
function tbInstancing:ProcStep2()
	if self.nTalkTimer then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = nil;
	end
	
	self.nTalkTimer = Timer:Register(3 * Env.GAME_FPS, self.Boss1Talk, self);
	self.nUiMsgTipStep = 1;		-- 击败夕焱
end

function tbInstancing:Boss1Talk()
	self.nTalk_Step = self.nTalk_Step or 1;
	if self.nTalk_Step == 1 then
		--self.pBoss1.SendChat("能从这里潜入，难道你们是义军的人？");
		self:NpcTalkWithChat(self.pBoss1, "能从这里潜入，难道你们是义军的人？")
		self.nTalk_Step = self.nTalk_Step + 1;
		return 3 * Env.GAME_FPS;
	elseif self.nTalk_Step == 2 then
		--self.pBoss1.SendChat("杂鱼，既然让我看到，就把命留下吧！");
		self:NpcTalkWithChat(self.pBoss1, "杂鱼，既然让我看到，就把命留下吧！")
		self.nTalk_Step = self.nTalk_Step + 1;
		return 3 * Env.GAME_FPS;
	else
		self.pBoss1.Delete();
		--self.pBoss1 = KNpc.Add2(self.BOSS1_TEMPLATE_FIGHT, self.nNpcLevel, -1, self.nMapId, 52704/32, 110688/32);
		self.pBoss1 = KNpc.Add2(unpack(self.BOSS1_TEMPLATE_FIGHT));
		self.pBoss1.GetTempTable("TreasureMap2").nNpcScore = self.tbBossScore[self.nTreasureLevel][1];
	end
	
	self.nTalk_Step = 1;
	self.nTalkTimer = nil;
	return 0;
end

-- boss1挂了，添加boss2第一阶段
function tbInstancing:ProcStep3()

	-- 子书青出现，黑屏剧情，并进行寻路
	-- 那个她
	self.pShe = KNpc.Add2(self.SHE_TEMPLATE_ID1, self.nNpcLevel, -1, self.nMapId, unpack(self.tbHerAddPos1[1]));
	self.pShe.SetCurCamp(0);
	local szMsg = [[<color=red>Tử Thư Thanh: <color>Đại hiệp cứu mạng...<end>
	<color=yellow>%s：<color>Thư Thanh? Sao muội lại bị giam ở đây?<end>
	<color=red>Tử Thư Thanh: <color>Gần đây, doanh trại nghĩa quân thường xuyên bị đạo tặc tấn công, muội đến doanh trại để hỏi thăm đại hiệp thì bị bọn chúng bắt giữ<end>
	<color=red>Tử Thư Thanh: <color>Muội thật bất cẩn. Nhưng xem ra bọn chúng biết muội là ai và thay vì giết thì bọn chúng lại giam ở đây.<end>
	<color=red>Tử Thư Thanh: <color>Tên cầm đầu doanh trại ắt hẳn là 1 tên gian xảo, nên việc trốn thoát khỏi đây thật khó vô cùng.]];
	self:BlackSkyTalk(szMsg, self.SendBlackBoardMsgByTeam, self, "Bảo vệ Thư Thanh rời khỏi đây");
	self.pShe.AI_ClearPath();
	for _, tbPos in pairs(self.tbHerAiPos[1]) do
		self.pShe.AI_AddMovePos(tbPos[1], tbPos[2]);
	end
	self.pShe.SetNpcAI(9,0,0,0,0,0,0,0);
	self.pShe.SetActiveForever(1);
	self.pShe.SetCurCamp(6);
	self.pShe.GetTempTable("Npc").tbOnArrive = {self.OnSheArrive, self, 1};
	--self.nHerTalkTimer = Timer:Register(1, self.SheIsTalking, self, 1);	-- 边走边喊话
	
	self.pBoss1 = nil;
	self:ClearObstacle(self.nObstacleStepClear + 1);	-- 清除障碍
	
	self.nBossStep = 1;
	self.nUiMsgTipStep = 2;		-- 保护子书青
end

function tbInstancing:OnSheArrive(nStep)
	if not self.pShe then
		return;
	end
	
	self.pShe.AI_ClearPath();
	self.pShe.SetNpcAI(100,0,0,0,0,0,0,0,0,0,0);	-- 表示清除寻路AI
	
	if nStep == 1 then
		self:RefreshNpc2();		-- 刷第二波小怪
		self.pBoss2 = KNpc.Add2(unpack(self.BOSS2_TEMPLATE_STEP1));
		self.pBoss2.GetTempTable("TreasureMap2").nNpcScore = self.tbBossScore[self.nTreasureLevel][2];
		
		-- 方西白黑屏喊话
		local szMsg = [[<color=red>Phương Tây Bạch: <color>Đây không phải là con a đầu ta đã bắt giữ sao, ngươi lại có thể trốn thoát khỏi đây, chắc do tên Nghĩa Quân đi cùng. Được, xông lên đây cùng lúc nào!]];
		self:BlackSkyTalk(szMsg);
		
		self:SendBlackBoardMsgByTeam("Bảo vệ Thư Thanh và Tiêu diệt kẻ địch");
		self.nUiMsgTipStep = 3;		-- 击败方西白
	elseif nStep == 2 then
		-- 化身战斗女神
		local _, x, y = self.pShe.GetWorldPos();
		__DelNpc(self.pShe);			
		self.pShe = KNpc.Add2(self.SHE_TEMPLATE_ID2, self.nNpcLevel, -1, self.nMapId, unpack(self.tbHerAddPos2[1]));
		self.pShe.SetCurCamp(0);
	
		self.nHerTalkTimer = Timer:Register(1, self.SheIsTalking, self, 2);
		self.nUiMsgTipStep = 4;		-- 破解机关
	elseif nStep == 3 then
		self:BlackSkyTalk("<color=red>Tử Thư Thanh: <color>Chúng ta dùng bè tre qua khu này, hãy tránh xa Phệ Hồn Đăng, nếu không được thì phá hủy nó.");
		self.nUiMsgTipStep = 7;		-- 乘坐渡船
	end
	
	self:UpdateMsgUI();
end

function tbInstancing:SheIsTalking(nTalkStep)
	if nTalkStep == 2 then
		--self.pShe.SendChat(string.format("<color=yellow>%s%s%s%s%s<color>，以之为序，此阵须臾可破", unpack(self.tbJiGuanSort)));
		self:NpcTalkWithChat(self.pShe, string.format("Thứ tự là <color=yellow>%s-%s-%s-%s-%s<color> hãy ghi nhớ.", unpack(self.tbJiGuanSort)));
		return 15 * Env.GAME_FPS;
	elseif nTalkStep == 3 or nTalkStep == 1 then
		local tbTalkContent = self.tbHerTalkContent[nTalkStep];
		if not tbTalkContent then
			self.nHerTalkCount = 1;
			return 0;
		end
		
		local szTalk = tbTalkContent[self.nHerTalkCount];
		if not szTalk then
			self.nHerTalkCount = 1;
			return 0;
		end
		
		--self.pShe.SendChat(szTalk);
		self:NpcTalkWithChat(self.pShe, szTalk);
		self.nHerTalkCount = self.nHerTalkCount + 1;
		return 8 * Env.GAME_FPS;
	end
	
	self.nHerTalkCount = 1;
	return 0;
end

-- boss2第一阶段完了，出boss2第二阶段
function tbInstancing:ProcStep4()
	--local x, y, z = self.pBoss2.GetWorldPos();
	self.pBoss2.Delete();
	self.pBoss2 = KNpc.Add2(unpack(self.BOSS2_TEMPLATE_STEP2));
	
	self:AddJiGuanNpc();   -- 添加五音机关
	
	--她又要开始走了
	self.pShe.AI_ClearPath();
	for _, tbPos in pairs(self.tbHerAiPos[2]) do
		self.pShe.AI_AddMovePos(tbPos[1], tbPos[2]);
	end
	self.pShe.SetNpcAI(9,0,0,0,0,0,0,0);
	self.pShe.SetActiveForever(1);
	self.pShe.GetTempTable("Npc").tbOnArrive = {self.OnSheArrive, self, 2};
	
	-- 要逃跑？？？
	self.pBoss2.SetCurCamp(6);
	self.pBoss2.AI_ClearPath();
	for _, tbPos in pairs(self.tbBoss2AiPos) do
		self.pBoss2.AI_AddMovePos(tbPos[1], tbPos[2]);
	end
	self.pBoss2.SetNpcAI(9,0,0,0,0,0,0,0);
	self.pBoss2.SetActiveForever(1);
	self.pBoss2.GetTempTable("Npc").tbOnArrive = {self.OnBoss2Arrive, self};
	self:SendBlackBoardMsgByTeam("Kẻ địch đã trốn thoát, hãy nhanh chân bắt lấy hắn!");
	
	self:ClearObstacle(self.nObstacleStepClear + 1);	-- 清除障碍
	self.nUiMsgTipStep = 3;			-- 击败方西白
end

function tbInstancing:OnBoss2Arrive()
	if not self.pBoss2 then
		return;
	end

	self.pBoss2.Delete();
	self.pBoss2 = nil;
	--self.pBoss2 = KNpc.Add2(self.BOSS2_TEMPLATE_STEP3, self.nNpcLevel, -1, self.nMapId, 55872/32, 109120/32)
	self.pBoss2 = KNpc.Add2(unpack(self.BOSS2_TEMPLATE_STEP3));
	self.pBoss2.AddSkillState(999, 10, 1, 18 * 3600 * 2);		-- 金钟罩，2个小时（到副本结束）
	self.pBoss2.GetTempTable("TreasureMap2").nNpcScore = self.tbBossScore[self.nTreasureLevel][3];
	
	local szMsg = [[<color=red>Phương Tây Bạch: <color>Kỹ năng tốt lắm! Nhưng nếu ngươi sa vào trận pháp này thì Thần Tiên cũng khó thoát! Ngoan ngoãn chịu chết đi.<end>
	<color=red>Tử Thư Thanh: <color>Ngay cả ngươi võ công cao cường cũng dùng đến thủ đoạn. Thật đáng xấu hổ.<end>
	<color=red>Phương Tây Bạch: <color>A đầu ngốc! Xem ngươi làm được gì ở đây.]];
	self:BlackSkyTalk(szMsg, self.SendBlackBoardMsgByTeam, self, "Kẻ địch đã bày trận pháp. Mau phá trận.");
end

--破解五音机关
function tbInstancing:ProcStep4_2()
	self.pBoss2.RemoveSkillState(999);	-- 解除金钟罩BUFF
	self:SendBlackBoardMsgByTeam("Trận pháp đã bị phá. Hãy tiêu diệt kẻ địch và rời khỏi đây.");
	
	-- 她停止喊话
	if self.nHerTalkTimer then
		Timer:Close(self.nHerTalkTimer);
		self.nHerTalkTimer = nil;
	end
	
	self.nUiMsgTipStep = 5;		-- 击败方西白2
	self:UpdateMsgUI();
end

-- boss2完全挂了，水上游戏..
function tbInstancing:ProcStep5()
	self.pBoss2.Delete();
	self.pBoss2 = nil;
	self:ClearObstacle(self.nObstacleStepClear + 1);
	self:SendBlackBoardMsgByTeam("Đến bến tàu và xuống bè tre.");
	self.nUiMsgTipStep = 6;		-- 前往渡口
	
	-- 添加船
	self.tbBoat = {};
	for i = 1, 3 do
		local pNpc = KNpc.Add2(self.BOAT_TEMPLATE, self.nNpcLevel, -1, self.nMapId, unpack(self.tbBoadAddPos[i]));
		if pNpc then
			table.insert(self.tbBoat, pNpc);
		end
	end
	
	-- 添加水上机关
	self.WATER_FIGHT_COUNT		= 9;
	
	-- 她，继续带领我前进
	__DelNpc(self.pShe);
	self.pShe = KNpc.Add2(self.SHE_TEMPLATE_ID1, self.nNpcLevel, -1, self.nMapId, unpack(self.tbHerAddPos1[2]));
	self.pShe.AI_ClearPath();
	for _, tbPos in pairs(self.tbHerAiPos[3]) do
		self.pShe.AI_AddMovePos(tbPos[1], tbPos[2]);
	end
	self.pShe.SetNpcAI(9,0,0,0,0,0,0,0);
	self.pShe.SetActiveForever(1);
	self.pShe.SetCurCamp(0);
	self.pShe.GetTempTable("Npc").tbOnArrive = {self.OnSheArrive, self, 3};	
	self.nHerTalkTimer = Timer:Register(1, self.SheIsTalking, self, 3);	-- tell me something again
	
	self.nBossStep = 2;
end

-- 水上机关全部被摧毁，刷新boss3
function tbInstancing:ProcStep6()
	self.pBoss3 = KNpc.Add2(unpack(self.BOSS3_TEMPLATE_DIALOG));
	self.nBoss3Dialog	= 1;
	self:ClearObstacle(self.nObstacleStepClear + 1);
	self.WATER_FIGHT_FINISHED = 1;
	self.nBossStep = 3;
	self.nUiMsgTipStep = 8;		-- 击败武氏文
	
	self:SendBlackBoardMsgByTeam("Toàn bộ Phệ Hồn Đăng đã bị hủy, nhanh chóng tiến về phía trước.");
end

-- 与boss3对话，喊话结束，变身战斗NPC
function tbInstancing:ProcStep7()
	if self.nTalkTimer then
		Timer:Close(self.nTalkTimer);
		self.nTalkTimer = nil;
	end
	
	self.nBoss3Dialog	= 0;
	local szMsg = [[<color=red>Võ Thị Văn: <color>Ngươi xứng đáng khi mang danh hiệu Nghĩa Quân khi có thể ra vào nơi này như chốn không người. Ta thật sự đánh giá ngươi quá thấp <color=yellow>%s<color>.<end>
	<color=red>Võ Thị Văn: <color>Nhưng chỉ đến đây thôi. Mạng sống ngươi và bí mật về Du Long Giác sẽ kết thúc tại đây. Chết đi!!!]];
	self:BlackSkyTalk(szMsg, self.OnBoss3TalkEnd, self);
--	self.nTalkTimer = Timer:Register(1 * Env.GAME_FPS, self.Boss3Talk, self);
end

-- 要喊话一段时间
function tbInstancing:OnBoss3TalkEnd()
	self.nBoss3TalkCall = self.nBoss3TalkCall or 1;
	if self.nBoss3TalkCall == 1 then
		self.pBoss3.Delete();
		self.pBoss3 = KNpc.Add2(unpack(self.BOSS3_TEMPLATE_FIGHT));
		self.pBoss3.GetTempTable("TreasureMap2").nNpcScore = self.tbBossScore[self.nTreasureLevel][4];
		
		-- 她又化身战斗女神
		__DelNpc(self.pShe);
		self.pShe = KNpc.Add2(self.SHE_TEMPLATE_ID2, self.nNpcLevel, -1, self.nMapId, unpack(self.tbHerAddPos2[2]));
		self.pShe.SetCurCamp(0);
		self.nBoss3TalkCall = 0;
	end
end

-- boss3挂了，她变成非战斗状态，林烟卿对话NPC出现
function tbInstancing:ProcStep8()
	__DelNpc(self.pShe);
	self.pShe = KNpc.Add2(self.SHE_TEMPLATE_ID1, self.nNpcLevel, -1, self.nMapId, unpack(self.tbHerAddPos1[3]));
	self.pLin = KNpc.Add2(unpack(self.LINYANQIN_DIALOG));
	
	Timer:Register(1 * Env.GAME_FPS, self.OnEndTalking, self);
	
	self:ApplyGiveHorse();
end

function tbInstancing:OnEndTalking()
	local tbTalk = 
	{
		{self.pLin, "Thư Thanh, sư phụ đây! Nghĩa quân thật bất tài, không thể bảo vệ ngươi rồi.", 3 * Env.GAME_FPS},
		{self.pShe, "Sư phụ! Đệ tử vẫn ổn. Nghĩa Quân đã chiến đấu hết sức để bảo vệ đệ tử.", 3 * Env.GAME_FPS},
		{self.pLin, "Bỏ qua chuyện này đi, hãy theo ta về, ta sẽ truyền thụ võ công cho con.", 3 * Env.GAME_FPS},
		{self.pShe, "Xin tuân lệnh sư phụ.", 3 * Env.GAME_FPS},
		{self.pShe, "Xin tạm biệt, nếu nhân duyên còn tiếp tục, chúng ta sẽ lại gặp nhau.", 3 * Env.GAME_FPS}
	}
	self.nEndTalkStep = self.nEndTalkStep or 1;
	local tbCurTalk = tbTalk[self.nEndTalkStep];
	
	if not tbCurTalk then		-- 对话结束
		self.nEndTalkStep = nil;
		self:GoNextStep();
		return 0;
	end
	
	--tbCurTalk[1].SendChat(tbCurTalk[2]);
	self:NpcTalkWithChat(tbCurTalk[1], tbCurTalk[2]);
	self.nEndTalkStep = self.nEndTalkStep + 1;
	return tbCurTalk[3];
end

function tbInstancing:ProcEnd()
	self:MissionComplete();		-- 其实是调treasuremap2_mission的MissionComplete
end

function tbInstancing:UpdateMsgUI()
	local szMsg = string.format(TreasureMap2.MSG_INSTANCE,TreasureMap2.TEMPLATE_LIST[self.nTreasureId].szName, self.nTreasureLevel, math.floor(self.tbInstance.nScore));
	if self.tbStepTips[self.nUiMsgTipStep] then
		szMsg = szMsg .. "\n" .. self.tbStepTips[self.nUiMsgTipStep];
	end
	for _, pPlayer in pairs(self:GetPlayerList()) do
		TreasureMap2:UpdateMsgUi(pPlayer,  szMsg);		
	end	
end

function tbInstancing:ApplyGiveHorse()
	local nLevel = self.nTreasureLevel;
	if not self.tbHorseRandomInfo[nLevel] then
		return;
	end
	
	local tbRandInfo = self.tbHorseRandomInfo[nLevel];
	local nRandom = MathRandom(1, 100);
	if nRandom > tbRandInfo[2] then
		return;
	end
			
	if nLevel == 3 then		-- 需要由GC控制产出数量
		-- 任务变量里面存的是天数
		local nHorseDay = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_BILUOGU_HORSE_DAY);
		local nToday = Lib:GetLocalDay(GetTime());
		local bHorseFlag = 0;
		if nHorseDay < nToday then
			bHorseFlag = 1;
		elseif nHorseDay == nToday then
			local nTodayCount = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_BILUOGU_HORSE_COUNT);
			if nTodayCount < TreasureMap2.nBiluogu_Horse_Count then
				bHorseFlag = 1;
			end
		end
		
		-- 就算GS判断是可以给马的，也不能给马，因为有可能是因为同步的原因GS端的任务变量并不是最新的值，还得由GC仲裁
		if bHorseFlag == 1 then
			-- 副本关键信息，用来查找对应的副本对象；一个人不可能在同一时刻在同一张地图上开启两个副本
			local tbInstancKey = {self.nMapId, self.nCaptainId, self.nStartTime};
			GCExcute{"TreasureMap2:ApplyGiveHorse_BiLuoGu", tbInstancKey};
		end
		return;		-- 等待GC回调
	end
	
	self:AddHorse();
end

function tbInstancing:AddHorse()
	local nLevel = self.nTreasureLevel;
	if not self.tbHorseRandomInfo[nLevel] then
		return;
	end
	
	local tbRandInfo = self.tbHorseRandomInfo[self.nTreasureLevel];
	local tbPlayer = self:GetPlayerList();
	if not tbPlayer or #tbPlayer == 0 then
		return;
	end
	
	local nPlayer = MathRandom(1, #tbPlayer);	
	local pItem = tbPlayer[nPlayer].AddItem(unpack(tbRandInfo[1]));
	if pItem then
		local szMsg = string.format("Chúc mừng <color=green>%s<color> tại <color=red>[Bích Lạc Cốc]<color> nhận được <color=purple>[%s]<color>",tbPlayer[nPlayer].szName,pItem.szName);
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL,szMsg);
		KDialog.MsgToGlobal(szMsg);
		
		pItem.SetTimeOut(0, GetTime() + tbRandInfo[3]);
		pItem.Sync();
	end
end

function tbInstancing:NpcTalkWithChat(pNpc, szChat)
	if not pNpc or not szChat then
		return;
	end
	
	pNpc.SendChat(szChat);
	local tbNearPlayer = KNpc.GetAroundPlayerList(pNpc.dwId, 60);
	if tbNearPlayer then
		for _, pPlayer in ipairs(tbNearPlayer) do
			pPlayer.Msg("<color=white>" .. szChat .. "<color>", pNpc.szName);
		end
	end
end

-- 添加秋姨的祝福
function tbInstancing:AfterJoin()
	if me.nLevel < self.SKILL_BUFF_LIMIT_LEVEL then
		me.AddSkillState(self.SKILL_BUFF_ID, math.ceil(me.nLevel / 10), 1, self.SKILL_BUFF_TIME, 1, 1);
	end
end

function tbInstancing:DoLeave()
	if me.nLevel < self.SKILL_BUFF_LIMIT_LEVEL then
		me.RemoveSkillState(self.SKILL_BUFF_ID);
	end
end