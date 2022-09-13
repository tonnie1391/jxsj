
-- ====================== 文件信息 ======================

-- 万花谷副本 NPC 脚本
-- Edited by peres
-- 2008/11/09 PM 16:53

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

Require("\\script\\task\\treasuremap\\instancing\\wanhuagu\\main.lua");

local tbNpc_Captain			= Npc:GetClass("wanhuagu_captain");
local tbNpc_Boss_1			= Npc:GetClass("wanhuagu_boss_1");
local tbNpc_TaoZi_Fight_1	= Npc:GetClass("wanhuagu_taozi_fight_1");
local tbNpc_TaoZi_Fight_Npc	= Npc:GetClass("wanhuagu_taozi_npc");
local tbNpc_TaoZi_Fight_2	= Npc:GetClass("wanhuagu_taozi_fight_2");
local tbNpc_QingQing_Fight	= Npc:GetClass("wanhuagu_qingqing_fight");
local tbNpc_QingQing_Npc	= Npc:GetClass("wanhuagu_qingqing_npc");
local tbNpc_Boss_2			= Npc:GetClass("wanhuagu_boss_2");
local tbNpc_Boss_3			= Npc:GetClass("wanhuagu_boss_3");
local tbNpc_Boss_Male_4		= Npc:GetClass("wanhuagu_boss_male_4");
local tbNpc_Boss_Female_4	= Npc:GetClass("wanhuagu_boss_female_4");
local tbNpc_Boss_5			= Npc:GetClass("wanhuagu_boss_5");
local tbNpc_Boss_6			= Npc:GetClass("wanhuagu_boss_6");
local tbNpc_Soldier			= Npc:GetClass("wanhuagu_soldier");
local tbNpc_BlackBear		= Npc:GetClass("wanhuagu_blackbear");
local tbNpc_Oryx			= Npc:GetClass("wanhuagu_oryx");
local tbNpc_Leopard			= Npc:GetClass("wanhuagu_leopard");
local tbNpc_Boss_6_Npc		= Npc:GetClass("wanhuagu_boss_6_npc");
local tbNpc_Boss_6_Fight	= Npc:GetClass("wanhuagu_boss_6_fight");

local tbNpc_Door			= Npc:GetClass("wanhuagu_door_1");
local tbNpc_Aster			= Npc:GetClass("wanhuagu_aster");
local tbNpc_Bag				= Npc:GetClass("wanhuagu_bag_1");
local tbNpc_Bag_2			= Npc:GetClass("wanhuagu_bag_2");

local tbNpc_TalkNpc_1		= Npc:GetClass("wanhuagu_talk_npc_1");		-- 牧童
local tbNpc_TalkNpc_2		= Npc:GetClass("wanhuagu_talk_npc_2");		-- 绵羊

local tbNpc_TalkNpc_3		= Npc:GetClass("wanhuagu_talk_npc_3");		-- 船夫
local tbNpc_Boss_3_talk		= Npc:GetClass("wanhuagu_boss_3_talk");		-- 药剂师对话

local tbNpc_Box				= Npc:GetClass("wanhuagu_box");				-- 箱子
local tbNpc_TaoZi_Talk_2	= Npc:GetClass("wanhuagu_taozi_npc_2");		-- 陶子对话2

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
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
}


-- 杀死铁莫西
function tbNpc_Captain:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.nCaptainFight = 1;
end;

-- 陶子对话
function tbNpc_TaoZi_Fight_Npc:OnDialog()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if tbInstancing.nTaoZiEscort == 0 then
		local szTalk	= [[<color=red><npc=2762><color>：你们一定要帮帮我！这万花谷本来是个远离尘世的小岛，几十年来，为了躲避战乱与江湖上的仇杀，数位有缘误入到此的奇人异士都安安稳稳的留了下来。<end>
							<color=red><npc=2762><color>：然而几天前不知从何而来的一伙蛮族乘船来到了岛上，在游荡了一段时间后终于发现了万花谷的入口，这入口大门<color=red>只有我和我妹妹青青两人的钥匙合在一起<color>才能打开，而妹妹刚刚被一蛮族首领虏了去！。<end>
							<color=red><npc=2762><color>：如果不是你们，刚刚可能我也……<end>
							<color=red><npc=2762><color>：求求你们！为了不破坏这处净土，将青青妹妹从他们手中解救出来吧！]];
							
		TaskAct:Talk(szTalk, self.TalkEnd, self, him.dwId, me.nId);
	
	end;
end;


function tbNpc_TaoZi_Fight_Npc:TalkEnd(nNpcId, nPlayerId)
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId)
	local pNpc		= KNpc.GetById(nNpcId);
	
	if not pPlayer or not pNpc then return 1; end;
	
	local nMapId, nMapX, nMapY	= pNpc.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if tbInstancing.nTaoZiEscort == 1 then
		return 1;
	end;
	
	if pPlayer and pNpc then
		pNpc.Delete();
		tbInstancing.pTaoZi_Fight_2 = tbInstancing:AddSeekNpc(2763, 50, 1598, 3177, tbInstancing.tbTaoZiSeekPos, 0, pPlayer, 1, self);		
		if tbInstancing.pTaoZi_Fight_2 then
			tbInstancing.dwTaoZi_Fight_2 = tbInstancing.pTaoZi_Fight_2.dwId;
		end;
		tbInstancing.nTaoZiEscort = 1;
	end;
end;


function tbNpc_TaoZi_Fight_Npc:OnArrive(pFightNpc, pPlayer)
	print ("tbNpc_TaoZi_Fight_Npc:OnArrive");
	local nMapId, nMapX, nMapY	= pFightNpc.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.nTaoZiEscort = 2;
	pFightNpc.SendChat("看啊！又有一群蛮兵来了！");
	
end;

function tbNpc_TaoZi_Fight_1:OnDeath()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.nTaoZi_Death	= 1;
	tbInstancing.nDoorOpen		= 1;
	
	-- 删掉大门
	local pNpcDoor = KNpc.GetById(tbInstancing.dwIdDoor);
	if pNpcDoor then pNpcDoor.Delete(); end;	
end;

function tbNpc_TaoZi_Fight_2:OnDeath()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.nTaoZi_Death	= 1;
	tbInstancing.nDoorOpen		= 1;
	
	-- 删掉大门
	local pNpcDoor = KNpc.GetById(tbInstancing.dwIdDoor);
	if pNpcDoor then pNpcDoor.Delete(); end;
		
end;


function tbNpc_Soldier:OnDeath()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.nSoldierFight = tbInstancing.nSoldierFight + 1;
	
	print ("tbInstancing.nSoldierFight：", tbInstancing.nSoldierFight);
end;


function tbNpc_Boss_1:OnDeath()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	local pQingQing_Fight_1 = KNpc.GetById(tbInstancing.dwQingQing_F_1);
	if pQingQing_Fight_1 then
		pQingQing_Fight_1.Delete();
	end;
	
	if tbInstancing.nTaoZi_Death == 0 then
		local pTaoZi_Fight_2 = KNpc.GetById(tbInstancing.dwTaoZi_Fight_2);
		pTaoZi_Fight_2.Delete();
		
		-- 加对话 NPC
		tbInstancing:AddNpc(tbInstancing.tbNpcPos[6], nMapId);
		tbInstancing:AddNpc(tbInstancing.tbNpcPos[7], nMapId);
		
		-- 加袋子
		tbInstancing:AddNpc(tbInstancing.tbObjPos[6], nMapId);
		
		tbInstancing.nBoss_1	= 1;
	end;
	
end;


function tbNpc_Boss_2:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	tbInstancing:AddNpc(tbInstancing.tbObjPos[9], nMapId);
end;

function tbNpc_Boss_2:OnLifePercentReduceHere(nLifePercent)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[2] == 0 then
		-- 在这里生产可重生的熊
		for i=14, 16 do
			KNpc.Add2(tbInstancing.tbNpcPos[i][1],
						tbInstancing.tbNpcPos[i][2],
						-1,
						nMapId,
						tbInstancing.tbNpcPos[i][4],
						tbInstancing.tbNpcPos[i][5],
						1,
						0,
						1);
		end;
		tbInstancing.tbBossLifePoint[2] = 1;
		him.SendChat("快出来，我的猛兽！");
	end;
end;


function tbNpc_Boss_3:OnDeath()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.nBoss_3	= 1;
	
	-- 删除障碍物
	for i=1, #tbInstancing.tb_dwIdAster do
		local pNpc	= KNpc.GetById(tbInstancing.tb_dwIdAster[i]);
		if pNpc then
			pNpc.Delete();
		end;
	end;
	
	-- 变成非战斗状态
	tbInstancing:AddNpc(tbInstancing.tbNpcPos[13], nMapId);	
end;


-- 击败柳生时出现袋子
function tbNpc_Boss_Male_4:OnDeath()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);	
	tbInstancing:AddNpc(tbInstancing.tbObjPos[7], nMapId);
	
	tbInstancing.nBoss_4	= 1;
end;

-- 柳生 60% 血量时贾茹出现
function tbNpc_Boss_Male_4:OnLifePercentReduceHere(nLifePercent)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if nLifePercent == 60 and tbInstancing.tbBossLifePoint[4] == 0 then
		tbInstancing:AddNpc(tbInstancing.tbBossPos[5], nMapId);
		tbInstancing.tbBossLifePoint[4] = 1;
		him.SendChat("贾茹，我现在伤得很重……");
	end;
	
end;	


function tbNpc_Boss_5:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	tbInstancing:AddNpc(tbInstancing.tbObjPos[10], nMapId);
end;

function tbNpc_Boss_6:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);	
	
	-- 加船夫
	tbInstancing:AddNpc(tbInstancing.tbNpcPos[12], nMapId);
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
--		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss2"], 28, -1, -1, him);
		TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
		
		-- 副本任务的处理
		local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();
		
		-- 师徒成就：副本万花谷
		TreasureMap:GetAchievement(tbTeamMembers, Achievement_ST.FUBEN_WANHUA, pPlayer.nMapId);
		
		if (not tbTeamMembers) or (nMemberCount <= 0) then
			TreasureMap:InstancingTask(pPlayer, tbInstancing.nMapTemplateId);
			return;
		else
			for i=1, nMemberCount do
				local pNowPlayer	= tbTeamMembers[i];
				TreasureMap:InstancingTask(pNowPlayer, tbInstancing.nMapTemplateId);
			end
		end
		
		-- 用于老玩家召回任务完成任务记录
		local tbMemberList = pPlayer.GetTeamMemberList();	
		for _, player in ipairs(tbMemberList) do 
			Task.OldPlayerTask:AddPlayerTaskValue(player.nId, 2082, 5);
		end;
	end;
	
	-- 加箱子
	for i=11, 13 do
		tbInstancing:AddNpc(tbInstancing.tbObjPos[i], nMapId);
	end;
	
	KStatLog.ModifyAdd("mixstat", "杀死BOSS通关", "总量", 1);
	
end;


function tbNpc_Door:OnDialog()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	local nKeys		= me.GetItemCountInBags(18,1,246,1);
	
	if nKeys > 0 then
		GeneralProcess:StartProcess("Đang mở……", 10 * 18, {self.OnOpened, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);
	end;
	
end;

-- 用钥匙打开大门
function tbNpc_Door:OnOpened(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;

	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc and pNpc.nIndex > 0) then
		local nMapId, nMapX, nMapY	= pNpc.GetWorldPos();
		local tbInstancing = TreasureMap:GetInstancing(nMapId);
		tbInstancing.nDoorOpen = 1;
		me.ConsumeItemInBags(1, 18, 1, 246, 1);
		pNpc.Delete();
	end;
end;

function tbNpc_Aster:OnDialog()
	return;
end;


-- 打开袋子拿到钥匙
function tbNpc_Bag:OnDialog()
	
	local nFreeCell = me.CountFreeBagCell();
	if nFreeCell < 2 then
		Dialog:SendInfoBoardMsg(me, "请把背包清理出<color=yellow> 2 格或以上的空间<color>！");
		return;
	end;
	
	-- TODO:liucahng 10写到head中去
	GeneralProcess:StartProcess("Đang mở……", 10 * 18, {self.OnOpened, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);

end;

function tbNpc_Bag:OnOpened(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;

	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc and pNpc.nIndex > 0) then
		
		local nMapId, nMapX, nMapY	= pNpc.GetWorldPos();
		local tbInstancing = TreasureMap:GetInstancing(nMapId);	
		
		if tbInstancing.nBoss_1 == 1 and tbInstancing.nBoss_3 == 0 then
			pPlayer.AddItem(18, 1, 246, 1);
			pPlayer.Msg("<color=yellow>你得到了一把钥匙！<color>");	
			-- 通知附近的玩家
			TreasureMap:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.."得到了一把钥匙！<color>");
		elseif tbInstancing.nBoss_3 == 1 then
			pPlayer.AddItem(18, 1, 249, 1);
			pPlayer.Msg("<color=yellow>你得到了一坛女儿红！<color>");	
			-- 通知附近的玩家
			TreasureMap:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.."得到了一坛女儿红！<color>");		
		end;
		pNpc.Delete();
	end;
end;


function tbNpc_Bag_2:OnDialog()
	local nFreeCell = me.CountFreeBagCell();
	if nFreeCell < 2 then
		Dialog:SendInfoBoardMsg(me, "请把背包清理出<color=yellow> 2 格或以上的空间<color>！");
		return;
	end;
	
	-- TODO:liucahng 10写到head中去
	GeneralProcess:StartProcess("Đang mở……", 10 * 18, {self.OnOpened, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);
end;

function tbNpc_Bag_2:OnOpened(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;

	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc and pNpc.nIndex > 0) then
		pPlayer.AddItem(18, 1, 250, 1);
		pPlayer.Msg("<color=yellow>你得到了一支笛子！<color>");	
		-- 通知附近的玩家
		TreasureMap:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.."得到了一支笛子！<color>");
		pNpc.Delete();	
	end;
end;


function tbNpc_TalkNpc_1:OnDialog()
	local szTalk	= [[<color=red><npc=2787><color>：呜呜呜……前面的桃林里有两只凶狠的花豹，把我的羊一下就给咬死了！听青青姐说，<color=orange>林子里有一支笛子<color>，只要吹响了它，这些野兽就会安静下来……<end>
						<color=red><npc=2787><color>：不过除非你们能<color=orange>偷偷的走过去<color>不被那些野兽看到，否则千万不要靠近它们！它们实在是太危险了！]];
						
	TaskAct:Talk(szTalk, Npc:GetClass("wanhuagu_talk_npc_1").TalkEnd, Npc:GetClass("wanhuagu_talk_npc_1"), him, me);
end;

function tbNpc_TalkNpc_1:TalkEnd(pNpc, pPlayer)
	Dialog:SendBlackBoardMsg(pPlayer, "从小同那得知，想安抚花豹，必须得拿到其身后的笛子");
end;

function tbNpc_TalkNpc_2:OnDialog()
	Dialog:Say("咩………………………………");
end;

-- 船夫对话
function tbNpc_TalkNpc_3:OnDialog()
	local nTreasureId			= TreasureMap:GetMyInstancingTreasureId(me);
		if not nTreasureId or nTreasureId <= 0 then
			me.Msg("读取进入点时出错，请直接使用回程符返回！");
			return;
		end;
	local tbInfo				= TreasureMap:GetTreasureInfo(nTreasureId);
	local nMapId, nMapX, nMapY	= tbInfo.MapId, tbInfo.MapX, tbInfo.MapY;
	
	Dialog:Say(
		"客官来嘞，怎样？在岛上是否已经游玩够了？如果想回去的话，小六这就送您一程。",
		{"是的", self.SendOut, self, me, nMapId, nMapX, nMapY},
		{"暂不"}
	);
end;

function tbNpc_TalkNpc_3:SendOut(pPlayer, nMapId, nMapX, nMapY)
	pPlayer.NewWorld(nMapId, nMapX, nMapY);
end;


-- 黄散一对话
function tbNpc_Boss_3_talk:OnDialog()
	Dialog:Say(
		"好吧，你们赢了，想要做什么药就和我说吧，天下没有我做不出来的药剂，只要你们能把材料搞来！",
		{"我想做隐身药[需要10块熊皮]", self.MakeIt, self, me},
		{"离开"}
	);	
	return;
end;


function tbNpc_Boss_3_talk:MakeIt(pPlayer)
	local nBearSkin		= pPlayer.GetItemCountInBags(18,1,247,1);
	if nBearSkin < 10 then
		Dialog:Say("哼！你现在哪来的<color=yellow> 10 张熊皮<color>，别骗老子！");
		return;
	end;
	pPlayer.ConsumeItemInBags(10, 18, 1, 247, 1);
	pPlayer.AddItem(18,1,248,1);
	Dialog:Say("拿好了，这是你要的隐身药，可要小心使用啊，它<color=yellow>最多只能维持 1 分钟的时间<color>。");
	return;
end;



function tbNpc_Box:OnDialog()
	GeneralProcess:StartProcess("Đang mở rương", 10 * 18, {self.OpenTreasureBox, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);
end;

function tbNpc_Box:OpenTreasureBox(nPlayerId, dwNpcId)
	-- 爆物品
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc and pNpc.nIndex > 0) then
		pPlayer.DropRateItem(TreasureMap.szInstancingBox_Level3, TreasureMap.nTreasureBoxDropCount, -1, -1, pNpc)
		pPlayer.Msg("<color=yellow>开启完成！<color>")
		pNpc.Delete();
	end
end


function tbNpc_QingQing_Npc:OnDialog()
	local szTalk	= [[<color=red><npc=2765><color>：谢谢你们，如此安静的山谷实在不能容忍那些蛮人染指。毕竟我也是一个从各个地方漂泊过来的人，深知一份平静是多么难得的不易。<end>
						<color=red><npc=2765><color>：对了，这是进入万花谷的钥匙，里面有些人挺有趣呢，如果你们愿意，可以和他们切磋一番。]];
						
	TaskAct:Talk(szTalk, self.TalkEnd, self, him.dwId, me.nId);
end;

function tbNpc_QingQing_Npc:TalkEnd()
	return 1;
end;


function tbNpc_TaoZi_Talk_2:OnDialog()
	local szTalk	= [[<color=red><npc=2792><color>：陶子：谢谢你们赶走了那些蛮人，这是万花谷的钥匙，如果想拜访谷中的那些奇人异士的话就拿去吧，相信你们会喜欢上这里的。<end>
						<color=red><npc=2792><color>：哦，对了，谷内深处有一个嗜酒如命的和尚，常年难见踪影。据说此人武功深不可测，谷内的人无不敬其三分，如果你们有幸能遇到的话千万小心言行，他最喜欢与人切磋武艺了。当然，如果击败了他你们也算是高手了……哈哈。]];
						
	TaskAct:Talk(szTalk, self.TalkEnd, self, him.dwId, me.nId);
end;

function tbNpc_TaoZi_Talk_2:TalkEnd()
	return 1;
end;