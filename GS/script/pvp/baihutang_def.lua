
BaiHuTang.TSKG_PVP_ACT	  = 2009;
BaiHuTang.TSK_BaiHuTang_PKTIMES = 1;
BaiHuTang.TSK_BaiHuTang_PKTIMES_Ex = 5;
BaiHuTang.TSK_TIME_STAMP	= 6;	--白虎堂时间戳
BaiHuTang.MAX_ONDDAY_PKTIMES = EventManager.IVER_nBaiHuTangCount; 
BaiHuTang.SIX_NUMBERS = 1000000;
BaiHuTang.MAX_NUMBER = 100;

if (EventManager.IVER_bOpenTiFu == 1) then
	BaiHuTang.TIMELEFT		  = Env.GAME_FPS * 60 * 10;
	BaiHuTang.TIMEPKLEFT	  	= Env.GAME_FPS * 60 * 30;
else
	BaiHuTang.TIMELEFT		  = Env.GAME_FPS * 60 * 30;
end

BaiHuTang.nTimes	= 1;		--平台开启奖励倍数

BaiHuTang.RESTSTATE	   = 0; -- 0 无活动状态
BaiHuTang.APPLYSTATE   = 1;	-- 1 报名状态
BaiHuTang.FIGHTSTATE   = 2;	-- 2 PK状态	
BaiHuTang.nActionState = 0;


BaiHuTang.nKillBossCamp = 0; --杀死三层boss的联盟或者帮会id,高级和黄金通用

BaiHuTang.BASIC_TRANS_RICHES_GOLDEN = 300000; --进入跨服白虎的帮会的财富最低限制

BaiHuTang.BASIC_TRANS_LEVEL	= 6;	--进入跨服白虎最低等级为6P

--BaiHuTang.BASIC_TRANS_RICHES_GAOJI = xxxxxx; 以后高级场开使用

BaiHuTang.tbPlayerInBossDeathMap = {}; --黄金3层boss死亡时地图内的玩家

BaiHuTang.nEnteredGBMapPlayer = 0 ;	--记录已经进入跨服的人数

BaiHuTang.MAX_COUNT_TRANSFER = 60; --最大能跨过去的人数

BaiHuTang.BASIC_COUNT_TRANSFER = 6; --开启传送门的最少的人数


BaiHuTang.nTaskId	= 0;
BaiHuTang.ChuJi = 225;
BaiHuTang.ChuJi2 = 274;
BaiHuTang.ChuJi3 = 333;
BaiHuTang.GaoJi = 233;
BaiHuTang.Goldlen = 821;
BaiHuTang.tbMapList = {225, 274, 233, 821};

BaiHuTang.tbIsOpen	  = {};
BaiHuTang.nRegisterId = nil;
BaiHuTang.nRegisterIdLeft = nil;
BaiHuTang.nBossNo	  = nil;
BaiHuTang.tbDaDianPos = {}; 
BaiHuTang.tbPKPos	  = {};
BaiHuTang.tbMapKey 	  = {};
BaiHuTang.tbTrapList  = {};
BaiHuTang.tbSysMsg    = {};
BaiHuTang.tbAnimalPos = {};
BaiHuTang.tbNumber	  = {};
BaiHuTang.tbMapId = {};
BaiHuTang.tbBatte = {};
BaiHuTang.tbNpcLevel = {45, 55, 65, 85, 95, 105, 110, 115, 120};
BaiHuTang.tbBossShowMsg = {3, 4, 5};
BaiHuTang.TSKGID	  = 2009;
BaiHuTang.TASK_USED_NUM = 3;
BaiHuTang.TASK_WEEK_ID	= 4;

BaiHuTang.TSK_LIMITWEIWANG	= 2;
BaiHuTang.LIMITWEIWANG		= 30;

BaiHuTang.BAIHUTANG_REPUTE_CAMP	= 5;
BaiHuTang.BAIHUTANG_REPUTE_CALSS= 1;

BaiHuTang.nStateJour = 0;
BaiHuTang.END = 7;

BaiHuTang.tbGetAwardCount = {};

-- 队长的领袖荣誉
BaiHuTang.HONOR ={{[3] = 6,  [4] = 9,  [5] = 12,  [6] = 15},	-- 第一关
		 		  {[3] = 6,  [4] = 9,  [5] = 12,  [6] = 15},	-- 第二关
		 		  {[3] = 12, [4] = 18, [5] = 24,  [6] = 30},	-- 第三关
				 };

if (EventManager.IVER_bOpenTiFu == 1) then
	BaiHuTang.STATE_TRANS	=
	{							--时间有延迟
	--	 状态 					定时时间			时间到回调函数(函数返回0表示不在继续定时，结束活动)
		{1, 	Env.GAME_FPS * 60 * 3, 			"ShowGongGao"		},		--  显示公告
		{2,		Env.GAME_FPS * 60 * 3,			"ShowGongGao"		},		--  显示公告
		{3,		Env.GAME_FPS * 60 * 1,			"ShowGongGao"		}, 		--  显示公告
		{4,		Env.GAME_FPS * 60 * 12,			"CallBoss"			}, 		-- Call 第一层BOSS
		{5,		Env.GAME_FPS * 60 * 9,			"CallBoss"			}, 		-- Call 第二层BOSS
		{6,		Env.GAME_FPS * 60 * 9,			"CallBoss"			}, 		-- Call 第三层BOSS
		{BaiHuTang.END}
	};
else
	BaiHuTang.STATE_TRANS	=
	{							--时间有延迟
	--	 状态 					定时时间			时间到回调函数(函数返回0表示不在继续定时，结束活动)
		{1, 	Env.GAME_FPS * 60 * 10, 		"ShowGongGao"		},		--  显示公告
		{2,		Env.GAME_FPS * 60 * 10,			"ShowGongGao"		},		--  显示公告
		{3,		Env.GAME_FPS * 60 * 5,			"ShowGongGao"		}, 		--  显示公告
		{4,		Env.GAME_FPS * 60 * 10,			"CallBoss"			}, 		-- Call 第一层BOSS
		{5,		Env.GAME_FPS * 60 * 4,			"CallBoss"			}, 		-- Call 第二层BOSS
		{6,		Env.GAME_FPS * 60 * 3,			"CallBoss"			}, 		-- Call 第三层BOSS
		{BaiHuTang.END}
	};
end

BaiHuTang.szApplyMsg = "Hoạt động Bạch Hổ Đường bắt đầu báo danh, các đại hiệp trên cấp 50 có thể đến các điểm báo danh thành thị để đăng ký tham gia.";

function BaiHuTang:OnPlayerTrap(nMapId)
	if (self.tbIsOpen[nMapId] ~= 1) then
		return;
	end
	
	-- 添加福袋
	if me.CountFreeBagCell() >= 1 then
		me.AddItem(18,1,80,1);
	else
		me.Msg("Hành trang không đủ ô trống, không thể nhận <color=yellow>Túi Phúc Hoàng Kim<color>");
	end
	
	--闯关成功，添加10点声望
	self:AddRepute(me, 10);
	me.AddBindMoney(30000 * BaiHuTang:GetFloor(nMapId));
	local nPrestige = 1;
	if BaiHuTang:GetLevelByMapId(nMapId) == 1 and TimeFrame:GetStateGS("OpenOneAdvBaiHuTang") == 1 then
		nPrestige = math.floor(nPrestige / 2);
	end
	me.AddKinReputeEntry(nPrestige, "baihutang")		-- 江湖威望
	local nLevel = BaiHuTang:GetLevelByMapId(nMapId);
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("BaiHuTang", me, nLevel, BaiHuTang:GetFloor(nMapId)) 
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	if BaiHuTang:GetFloor(nMapId) >= 1 then
		SpecialEvent.tbGoldBar:AddTask(me, 9);		--金牌联赛白虎堂每层
	end
	local nToMapId = self.tbMapKey[nMapId];
	-- 踢出mission
	if (nToMapId == 225 or nToMapId == 233 or nToMapId == 274 or nToMapId ==821) then
		BaiHuTang:KickOutMission(me, nToMapId);
	end	
	if (nToMapId) then
		local tbSect = self.tbPKPos[MathRandom(#self.tbPKPos)];
		me.NewWorld(nToMapId, tbSect.nX / 32, tbSect.nY / 32);
	end	
	--3条命
	if BaiHuTang:GetFloor(nMapId) <= 2 then
		me.GetPlayerTempTable().nCount = 3
	end
	
	if BaiHuTang:GetFloor(nMapId) == 3 then
		--通过白虎堂统计
		local nTimes = me.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_BAIHU);
		me.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_BAIHU, nTimes + 1);
		
		Achievement:FinishAchievement(me, 177);
		Achievement:FinishAchievement(me, 179);
	end

	if BaiHuTang:GetFloor(nMapId) == 1 then
		Player:AddJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_BAIHUTANG, 1);
	end
	
	-- 激活龙珠
	if TimeFrame:GetState("Keyimen") == 1 and BaiHuTang:GetFloor(nToMapId) == 2 then
		Item:ActiveDragonBall(me);
	end
end

function BaiHuTang:SetTrapList()
	self.tbMapKey[226] = 230; self.tbMapKey[228] = 230;
	self.tbMapKey[234] = 238; self.tbMapKey[236] = 238;
	self.tbMapKey[227] = 231; self.tbMapKey[229] = 231;
	self.tbMapKey[235] = 239; self.tbMapKey[237] = 239;
	self.tbMapKey[230] = 232; self.tbMapKey[231] = 232;
	self.tbMapKey[238] = 240; self.tbMapKey[239] = 240;	
	self.tbMapKey[232] = 225; self.tbMapKey[240] = 233;
	-- 初级第二场
	self.tbMapKey[275] = 279; self.tbMapKey[277] = 279;
	self.tbMapKey[276] = 280; self.tbMapKey[278] = 280;
	self.tbMapKey[279] = 281; self.tbMapKey[280] = 281;
	self.tbMapKey[281] = 274;
	
	-- 初级第三场
	self.tbMapKey[334] = 338; self.tbMapKey[336] = 338;
	self.tbMapKey[335] = 339; self.tbMapKey[337] = 339;
	self.tbMapKey[338] = 340; self.tbMapKey[339] = 340;
	self.tbMapKey[340] = 333;
	
	--黄金白虎堂
	self.tbMapKey[822] = 826; self.tbMapKey[823] = 826;
	self.tbMapKey[824] = 827; self.tbMapKey[825] = 827;
	self.tbMapKey[826] = 828; self.tbMapKey[827] = 828;
	self.tbMapKey[828] = 821;
	
	local tbTestTrap = {};
	local tbTest = {};
	local tbMapIdList = {226,227,228,229,230,231,232,235,234,236,237,238,239,240,
						275, 276, 277, 278, 279, 280, 281, 
						334, 335, 336, 337, 338, 339, 340,
						822, 823, 824, 825, 826, 827, 828,
						};
	for _, nIndex in ipairs(tbMapIdList) do
		tbTest = Map:GetClass(nIndex);
		tbTestTrap = tbTest:GetTrapClass("to_exit");
		if (tbTestTrap) then
				tbTestTrap.OnPlayer = function (self)
				BaiHuTang:OnPlayerTrap(nIndex);
			end
		end
		if (tbTestTrap) then
			table.insert(self.tbTrapList, tbTestTrap);
		end
	end
end

-- 进出地图事件

local tbMapId_Hall = {BaiHuTang.ChuJi, BaiHuTang.ChuJi2, BaiHuTang.ChuJi3, BaiHuTang.GaoJi, BaiHuTang.Goldlen};
local tbMapFun_Hall = {};
function tbMapFun_Hall:OnEnter(szParam)
	me.SetFightState(1);		--设置战斗状态
	Player:AddProtectedState(me, 5);	--保护状态
	me.nPkModel = Player.emKPK_STATE_PRACTISE;
	DataLog:WriteELog(me.szName, 4, 1, me.nMapId);
end
--离开时设回非战斗状态
function tbMapFun_Hall:OnLeave(szParam)
	me.SetFightState(0);		--设置战斗状态
	me.nPkModel = Player.emKPK_STATE_PRACTISE;
	DataLog:WriteELog(me.szName, 4, 4, me.nMapId);
end

local tbMapId_FLOOR1 = {226, 227, 228, 229, 234, 235, 236, 237, 275, 276, 277, 278, 334, 335, 336, 337, 822, 823, 824, 825};
local tbMapFun_FLOOR1 = {};
function tbMapFun_FLOOR1:OnEnter(szParam)
	DataLog:WriteELog(me.szName, 4, 1, me.nMapId);
end

--离开时设回非战斗状态
function tbMapFun_FLOOR1:OnLeave(szParam)
	DataLog:WriteELog(me.szName, 4, 4, me.nMapId);
end

local tbMapId_FLOOR2 = {230, 231, 279, 280, 338, 339, 238, 239, 826, 827};
local tbMapFun_FLOOR2 = {};
function tbMapFun_FLOOR2:OnEnter(szParam)
	DataLog:WriteELog(me.szName, 4, 1, me.nMapId);
end

function tbMapFun_FLOOR2:OnEnter(szParam)
	DataLog:WriteELog(me.szName, 4, 4, me.nMapId);
end


local tbMapId_FLOOR3 = {240, 232, 828};
local tbMapFun_FLOOR3 = {};
function tbMapFun_FLOOR3:OnEnter(szParam)
	DataLog:WriteELog(me.szName, 4, 1, me.nMapId);
end

function tbMapFun_FLOOR3:OnLeave(szParam)
	local tbMapId = {
		[240] = 233,
		[232] = 225,
		[828] = 821,
	};
	if tbMapId[me.nMapId] then
		BaiHuTang:OnKickPlayer(me, tbMapId[me.nMapId]);
	end
	DataLog:WriteELog(me.szName, 4, 4, me.nMapId);
end

for _, nMapId in pairs(tbMapId_Hall) do
	local tbBattleMap = Map:GetClass(nMapId);
	for szFnc in pairs(tbMapFun_Hall) do
		tbBattleMap[szFnc] = tbMapFun_Hall[szFnc];
	end
end

for _, nMapId in pairs(tbMapId_FLOOR1) do
	local tbBattleMap = Map:GetClass(nMapId);
	for szFnc in pairs(tbMapFun_FLOOR1) do
		tbBattleMap[szFnc] = tbMapFun_FLOOR1[szFnc];
	end
end

for _, nMapId in pairs(tbMapId_FLOOR2) do
	local tbBattleMap = Map:GetClass(nMapId);
	for szFnc in pairs(tbMapFun_FLOOR2) do
		tbBattleMap[szFnc] = tbMapFun_FLOOR2[szFnc];
	end
end

for _, nMapId in pairs(tbMapId_FLOOR3) do
	local tbBattleMap = Map:GetClass(nMapId);
	for szFnc in pairs(tbMapFun_FLOOR3) do
		tbBattleMap[szFnc] = tbMapFun_FLOOR3[szFnc];
	end
end

-- 进出地图 end

function BaiHuTang:init()
	local tbNumColSet = {["TRAPX"]=1, ["TRAPY"]=1};
	local tbData = {};
	tbData = Lib:LoadTabFile("\\setting\\pvp\\map\\chuanrudian_dadian.txt", tbNumColSet);
	for _, tbRow in ipairs(tbData) do
		local tbPos = {
				nX = tbRow.TRAPX;
				nY = tbRow.TRAPY;
			}
		table.insert(BaiHuTang.tbDaDianPos, tbPos);
	end	
	tbData = Lib:LoadTabFile("\\setting\\pvp\\map\\xiaoguai.txt", tbNumColSet);
	for _, tbRow in ipairs(tbData) do
		local tbPos = {
			nX	= tbRow.TRAPX;
			nY	= tbRow.TRAPY
			};
		table.insert(BaiHuTang.tbAnimalPos, tbPos);
	end
	tbData = Lib:LoadTabFile("\\setting\\pvp\\map\\chuanrudian_pk.txt", tbNumColSet);
	for _, tbRow in ipairs(tbData) do
		local tbPos = {
			nX = tbRow.TRAPX;
			nY = tbRow.TRAPY;
			}
		table.insert(BaiHuTang.tbPKPos, tbPos);
	end
	BaiHuTang.tbBatte[self.ChuJi] = {MapId = {
												{   226, 227, 228, 229, 
												 	275, 276, 277, 278, 
												 	334, 335, 336, 337};   --第一层地图
												{	230, 231, 
													279, 280,
													338, 339 }; 		  --第二层地图
												{232, 281, 340};		  --第三层地图
										 	 };
									tbNpcTemp  = {2660, 2681, 2685}; 				--小怪模板Id
									tbBossTemp = {2661, 2682, 2686}					--Boss模板Id
									};
										  
	BaiHuTang.tbBatte[self.GaoJi] = {MapId = {
												{234, 235, 236, 237};
												{238, 239};
												{240};
	    									 };
									  tbNpcTemp	 = {2662, 2683, 2687};
									  tbBossTemp = {2663, 2684, 2688};
									 };
	BaiHuTang.tbBatte[self.Goldlen] = {MapId = {
												{822, 823, 824, 825};
												{826, 827};
												{828};
	    									 };
									  tbNpcTemp	 = {3683, 3685, 3687};
									  tbBossTemp = {3684, 3686, 3688};
									 };
	BaiHuTang:SetTrapList();
	
	self.tbSysMsg[1] = "Hoạt động Bạch Hổ Đường chính thức bắt đầu, Bạch Hổ Đường xuất hiện Sấm Đường Tặc!";
	self.tbSysMsg[2] = "Thời gian đăng ký Bạch Hổ Đường đã kết thúc, hoạt động chính thức bắt đầu!";
	self.tbSysMsg[3] = "Thủ Lĩnh Sấm Đường Tặc xuất hiện tại tầng 1 Bạch Hổ Đường!";
	self.tbSysMsg[4] = "Thủ Lĩnh Thiết Đồ Tặc xuất hiện tại tầng 2 Bạch Hổ Đường!";
	self.tbSysMsg[5] = "Hộ Đồ Sứ xuất hiện tại tầng 3 Bạch Hổ Đường!";
	self.tbSysMsg[6] = "Xin chúc mừng bạn đã vượt qua Bạch Hổ Đường thành công!";
	self.tbSysMsg[7] = "Sắp hết thời gian, chuẩn bị rời khỏi Bạch Hổ Đường!";
	self.nActionState = self.RESTSTATE; --刚开始将活动设置为 维护状态
end

BaiHuTang.BOSS_NAME = 
{
	[1] = "Thủ Lĩnh Sấm Đường Tặc ",
	[2] = "Thủ Lĩnh Thiết Đồ Tặc ",
	[3] = "Hộ Đồ Sứ "
};
BaiHuTang:init();
