
-- ====================== 文件信息 ======================

-- 大漠古城存活者 NPC 脚本
-- Edited by peres
-- 2008/05/15 PM 20:27

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbNpc_1			= Npc:GetClass("damogucheng_survivor1");	-- 石敬一（老人）
local tbNpc_2			= Npc:GetClass("damogucheng_survivor2");	-- 鄯士（被锁住的人）
local tbNpc_3			= Npc:GetClass("damogucheng_survivor3");	-- 鄯摩
local tbNpc_4			= Npc:GetClass("damogucheng_survivor4");	-- 青青
local tbBag_1			= Npc:GetClass("damogucheng_bag_1");
local tbBag_2			= Npc:GetClass("damogucheng_bag_2");

local tbTaskNpc			= Npc:GetClass("damogucheng_task_stele");

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

-- 打开袋子拿到钥匙
function tbBag_1:OnDialog()
	
	local nFreeCell = me.CountFreeBagCell();
	if nFreeCell < 2 then
		Dialog:SendInfoBoardMsg(me, "请把背包清理出<color=yellow> 2 格或以上的空间<color>！");
		return;
	end;
	
	-- TODO:liucahng 10写到head中去
	GeneralProcess:StartProcess("Đang mở……", 10 * 18, {self.OnOpen, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);

end;

function tbBag_1:OnOpen(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;

	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc and pNpc.nIndex > 0) then
		pPlayer.AddItem(18, 1, 95, 1);
		pPlayer.Msg("<color=yellow>你得到了一把钥匙！<color>");
		
		-- 通知附近的玩家
		TreasureMap:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.."得到了一把钥匙！<color>");		
		
		pNpc.Delete();
	end
end;


-- 击败第二个 BOSS 后从这拿到琴
function tbBag_2:OnDialog()

	local nFreeCell = me.CountFreeBagCell();
	if nFreeCell < 2 then
		Dialog:SendInfoBoardMsg(me, "请把背包清理出<color=yellow> 2 格或以上的空间<color>！");
		return;
	end;
	
	-- TODO:liucahng 10写到head中去
	GeneralProcess:StartProcess("Đang mở……", 10 * 18, {self.OnOpen, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);

end;


function tbBag_2:OnOpen(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
		
	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc and pNpc.nIndex > 0) then
		pPlayer.AddItem(18, 1, 96, 1);
		pPlayer.Msg("<color=yellow>你得到了一张古琴！<color>");
		
		-- 通知附近的玩家
		TreasureMap:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.."得到了一张古琴！<color>");		
		
		pNpc.Delete();
	end
end;



-- NPC 的对话

-- 石敬一
function tbNpc_1:OnDialog()
	local szTalk	= [[<color=red><npc=2723><color>：十几年了，我是第一次看到有外边的人来到这里。<end>
						<color=red><npc=2723><color>：这座城，也就这样了。无论是他们，还是许多年前那个统领这里的人，谁都改变不了大漠黄沙吞噬这里的结局……<end>]];					
	TaskAct:Talk(szTalk, self.TalkEnd, self);
end;

function tbNpc_1:TalkEnd()
	
end;

-- 鄯士
function tbNpc_2:OnDialog()
	local szTalk	= [[<color=red><npc=2724><color>：哼！你是可以杀了他们，他们该死！可是这又有什么用呢！？<end>
						<color=red><npc=2724><color>：难道你以为杀了一群人，就能救活另外一群人？这和十几年前的他们又有什么区别！<end>]];					
	TaskAct:Talk(szTalk, self.TalkEnd, self);
end;

function tbNpc_2:TalkEnd()
	
end;

-- 鄯摩
function tbNpc_3:OnDialog()
	local szTalk	= [[<color=red><npc=2725><color>：终于还是有人来到这里了……<end>
						<color=red><npc=2725><color>：陌生人，祝你好运吧！<end>]];					
	TaskAct:Talk(szTalk, self.TalkEnd, self);
end;

function tbNpc_3:TalkEnd()
	
end;

-- 青青
function tbNpc_4:OnDialog()
	local szTalk	= [[<color=red><npc=2726><color>：别告诉娘亲我在这里行吗？她总是不让我跑出外面来玩。<end>
						<color=red><npc=2726><color>：不过我肚子饿了，该回去吃饭了，我娘还在等我呢。<end>]];
	TaskAct:Talk(szTalk, self.TalkEnd, self);
end;

function tbNpc_4:TalkEnd()
	
end;


-- 接任务的 NPC
function tbTaskNpc:OnDialog()
	return;
end;