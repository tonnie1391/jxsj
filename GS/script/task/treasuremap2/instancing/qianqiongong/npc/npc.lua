
-- ====================== 文件信息 ======================

-- 千琼宫副本 NPC 脚本
-- Edited by peres
-- 2008/07/25 AM 11:39

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbNpc_Bag		= Npc:GetClass("purepalace2_bag");				-- 装有钥匙的袋子
local tbNpc_1		= Npc:GetClass("purepalace2_xiaolian_npc");		-- 第一个对话类型 NPC
local tbNpc_2		= Npc:GetClass("purepalace2_xiaolian_fight");	-- 护送 NPC

local tbNpc_Hiding	= Npc:GetClass("purepalace2_hiding");	-- 隐匿之处传送点
local tbNpc_Outside	= Npc:GetClass("purepalace2_outside");	-- 副本出口

local tbNpc_Task	= Npc:GetClass("purepalace2_lixianglan");


tbNpc_1.tbTrack	= {
	{1629, 3044},
	{1640, 3030},
	{1618, 3008},
	{1596, 2981},
	{1571, 2956},
}

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

function tbNpc_1:OnDialog()
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	if tbInstancing.tbBossDown[1] == 1 and tbInstancing.tbBossDown[2] == 0 and tbInstancing.nGirlProStep == 0 then
		local nKeys		= me.GetItemCountInBags(18,1,183,1);
		if nKeys > 0 then
			Dialog:Say("Ngươi đã nhận được thuốc giải?", {
					  {"Đây, hãy thử liều thuốc này", self.Release, self, him.dwId},
					  {"Đợi một chút"},
					});
		else
			Dialog:Say("Ta đã bị kẹt ở đây nhiều năm, Bất Đổng Tha Môn có một liều độc dược, bị trúng độc sẽ tê liệt không thể di chuyển. Ngươi có thể giúp ta không ? Ta thật sự không hiểu, Dữ Tha Môn vô oan vô cừu lại không có ai dám đối đầu.");
			return;
		end;
	end;
	
	if tbInstancing.tbBossDown[2] == 1 and tbInstancing.nGirlProStep == 1 then
		local nKeys		= me.GetItemCountInBags(18,1,184,1);
		if nKeys > 0 and tbInstancing.tbBossDown[5] == 1 then
			Dialog:Say("Ngươi đã giúp ta tìm thấy Khỏa Bảo Châu?", {
					  {"Đây, hãy thử khỏa bảo châu này", self.Finish, self, him.dwId},
					  {"Đợi một chút"},
					});
		else
			Dialog:Say("Ta mắt đã mờ thân cạn kiệt sức lực, chỉ có 1 liêu thuốc giải không thể cứu được độc thấm sâu trong người, ta nghe nói trong Thiên Quỳnh Cung có báo vật <color=yellow>Thiên Niên Bảo Châu<color>, có thể trị dứt căn bệnh của ta, ngươi có thiện chí, Có thể giúp ta tìm và mang về không ?");
			return;
		end;
	end;
end;


function tbNpc_1:Release(nNpcId)
	
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
		
	local nKeys		= me.GetItemCountInBags(18,1,183,1);
	
	if nKeys <=0 then
		Dialog:Say("Trên người của ngươi không có thuốc giải ?");
		return;
	end;
	
	me.ConsumeItemInBags(1, 18, 1, 183, 1);

	local nCurMapId, nCurPosX, nCurPosY = him.GetWorldPos();
	him.Delete();
	
	local pFightNpc		= KNpc.Add2(6968, 20, -1, nCurMapId, nCurPosX, nCurPosY, 0, 0, 1);
	
	-- 在这里记录小怜的 ID
	tbInstancing.nGirlId	= pFightNpc.dwId;
	
	pFightNpc.szName	= "Tiểu Linh";
	pFightNpc.SetTitle("Do đội <color=yellow>"..me.szName.."<color> bảo vệ");
	pFightNpc.SetCurCamp(0);
	
	pFightNpc.RestoreLife();
	
--	pFightNpc.GetTempTable("Npc").tbOnArrive = {tbNpc.OnArrive, tbNpc, pFightNpc, me};

	pFightNpc.AI_ClearPath();
	
	for _,Pos in ipairs(self.tbTrack) do
		if (Pos[1] and Pos[2]) then
			pFightNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
		end
	end;
	
	pFightNpc.SetNpcAI(9, 50, 1,-1, 25, 25, 25, 0, 0, 0, me.GetNpc().nIndex);
	
	tbInstancing.nGirlProStep = 1;
end;


function tbNpc_1:Finish(nNpcId)
	
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	
	local nMapId, nMapX, nMapY	= pNpc.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
		
	local nKeys		= me.GetItemCountInBags(18,1,184,1);
	
	if nKeys <=0 then
		Dialog:Say("Ngươi không có Bảo Châu ư ?");
		return;
	end;
	
	me.ConsumeItemInBags(1, 18, 1, 184, 1);

	local nCurMapId, nCurPosX, nCurPosY = pNpc.GetWorldPos();
	pNpc.Delete();
	
	TreasureMap2:NotifyAroundPlayer(me, "<color=yellow>Tiểu Liên đã nuốt Tiểu Bảo Châu, một tiếng cười lớn, đột nhiên biến mất !<color>");
	
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[tbInstancing.nTreasureId].tbNpcLevel[tbInstancing.nTreasureLevel] ;
		
	-- 加隐藏 BOSS
	local pBoss = KNpc.Add2(6969, nNpcLevel, 3, nMapId, 1822, 2907);

	if pBoss then
		pBoss.GetTempTable("TreasureMap2").nNpcScore = 36 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
	end	
	
	-- 加一个传送点
	local pSendPos	= KNpc.Add2(6971, 1, -1, nMapId, nMapX, nMapY);
	pSendPos.szName	= "Truyền tống";
	
	tbInstancing.nGirlProStep = 2;
end;



-- 护送 NPC 小怜被杀死
function tbNpc_2:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	assert(tbInstancing);
	
	tbInstancing.nGirlKilled	= 1;
end;


-- 打开袋子拿到解药
function tbNpc_Bag:OnDialog()
	
	local nFreeCell = me.CountFreeBagCell();
	if nFreeCell < 2 then
		Dialog:SendInfoBoardMsg(me, "Hành trang cần trống <color=yellow> 2 ô mới có thể tiếp tục<color>!");
		return;
	end;
	
	-- TODO:liucahng 10写到head中去
	GeneralProcess:StartProcess("Đang mở...", 10 * 18, {self.OnOpen, self, me.nId, him.dwId}, {me.Msg, "Mở bị gián đoạn"}, tbEvent);

end;

function tbNpc_Bag:OnOpen(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	
	local nFreeCell = pPlayer.CountFreeBagCell();
	if nFreeCell < 2 then
		Dialog:SendInfoBoardMsg(pPlayer, "Hành trang cần trống <color=yellow> 2 ô mới có thể tiếp tục<color>!");
		return;
	end;
	
	local pNpc = KNpc.GetById(dwNpcId);
	
	if (pNpc and pNpc.nIndex > 0) then
		
		local nMapId, nMapX, nMapY	= pNpc.GetWorldPos();
		local tbInstancing = TreasureMap2:GetInstancing(nMapId);
		assert(tbInstancing);
		
		if tbInstancing.tbBossDown[1] == 1 and tbInstancing.tbBossDown[5] == 0 then
			
			pPlayer.AddItem(18, 1, 183, 1);
			pPlayer.Msg("<color=yellow>Ngươi nhận được 1 bình thuốc giải độc !<color>");
			-- 通知附近的玩家
			TreasureMap2:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.." nhận được 1 bình thuốc giải độc !<color>");
					
		elseif tbInstancing.tbBossDown[5] == 1 then
			
			pPlayer.AddItem(18, 1, 184, 1);
			pPlayer.Msg("<color=yellow>Ngươi có được 1 Khỏa bảo châu !<color>");
			-- 通知附近的玩家
			TreasureMap2:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.." nhận được 1 khỏa bảo châu!<color>");

		end;
		pNpc.Delete();
	end
end;


function tbNpc_Task:OnDialog()
	Dialog:Say(string.format("%s, xin chào!",me.szName));
end;


function tbNpc_Hiding:OnDialog()
	
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	
	Dialog:Say("Ngươi có muốn tiến vào đối đầu với thử thách?", {
			  {"Vâng", self.Inside, self, nMapId},
			  {"Không"},
			});
end;

function tbNpc_Hiding:Inside(nMapId)
	me.NewWorld(nMapId, 1732, 2913);
end;



function tbNpc_Outside:OnDialog()
	
	local nCaptainId = me.GetTempTable("TreasureMap2").nCaptainId;
	if not nCaptainId then
		print("ERROR,qianqionggong outside dialog");
		return;
	end

	local tbInstancing = TreasureMap2:GetInstancingByPlayerId(nCaptainId);
	if not tbInstancing then
		return;
	end
--	local nMapId, nMapX, nMapY	= tbInstancing.tbLeavePos[1],tbInstancing.tbLeavePos[2],tbInstancing.tbLeavePos[3];
	
--	Dialog:Say(
--	"你现在要离开这里吗？",
--		{"是的", self.SendOut, self, me, nMapId, nMapX, nMapY},
--		{"暂不"}
--	);
end;
