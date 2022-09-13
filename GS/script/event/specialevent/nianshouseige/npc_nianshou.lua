-- 文件名　：npc_nianshou.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-28 14:10:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end
Require("\\script\\event\\specialevent\\nianshouseige\\nianshousiege_def.lua");
SpecialEvent.NianShouSiege = SpecialEvent.NianShouSiege or {};
local tbNianShouSiege = SpecialEvent.NianShouSiege or {};

local tbNpc = Npc:GetClass("nianshou_2011");

function tbNpc:StartSiege()
	local pNpc = KNpc.Add2(tbNianShouSiege.NPC_NIANSHOU_ID, 100, -1, tbNianShouSiege.NIANSHOU_BORN_POS[1], tbNianShouSiege.NIANSHOU_BORN_POS[2], tbNianShouSiege.NIANSHOU_BORN_POS[3]);
	if not pNpc then
		return nil;
	end
	if tbNianShouSiege.NIANSHOU_MAX_LIFE then	-- 测试时候用来设置血量
		pNpc.SetMaxLife(tbNianShouSiege.NIANSHOU_MAX_LIFE);
		pNpc.RestoreLife();
	end
	pNpc.SetActiveForever(1);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive1, self, pNpc.dwId};
	pNpc.GetTempTable("Npc").tbNianShou = {};
	pNpc.GetTempTable("Npc").tbNianShou.nMapId = nMapId;
	pNpc.GetTempTable("Npc").tbNianShou.nBeHitActive = 1;	-- 年兽是否可被攻击
	pNpc.GetTempTable("Npc").tbNianShou.nArrivePos = 0;		-- 是否走到白秋林面前
	pNpc.GetTempTable("Npc").tbNianShou.tbPlayerList = {};
	pNpc.GetTempTable("Npc").tbNianShou.tbLogList = {};
	pNpc.GetTempTable("Npc").nChatTimerId = Timer:Register(tbNianShouSiege.INTERVAL_CHAT, self.Chat, self, pNpc.dwId);
	self:StartMove(pNpc)
	return pNpc.dwId;
end

-- 年兽开始移动
function tbNpc:StartMove(pNpc)
	if not pNpc then
		return 0;
	end
	local nMapId = pNpc.GetTempTable("Npc").tbNianShou.nMapId;
	pNpc.AI_ClearPath();
	local tbRoute = Lib:LoadTabFile(tbNianShouSiege.TB_ROUTE);
	if not tbRoute or #tbRoute == 0 then
		Dbg:WriteLog("年兽添加路径失败");
		return 0;
	end
	for nIndex, tbTemp in ipairs(tbRoute) do
		if not tbNianShouSiege.NIANSHOU_BORN_INDEX or nIndex > tbNianShouSiege.NIANSHOU_BORN_INDEX then
			pNpc.AI_AddMovePos(tonumber(tbTemp["POSX"]), tonumber(tbTemp["POSY"]));	-- 添加移动路线
		end
	end
	pNpc.AddFightSkill(tbNianShouSiege.NIANSHOU_SKILL1, 11, 1);
	pNpc.AddFightSkill(tbNianShouSiege.NIANSHOU_SKILL2, 11, 2);
	pNpc.AddFightSkill(tbNianShouSiege.NIANSHOU_SKILL3, 11, 3);
	pNpc.SetNpcAI(9, 20, 1, 1, 80, 10, 10, 0, 0, 0, 0); 
end

-- 快走到白秋林,切换成纯寻路AI
function tbNpc:OnArrive1(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.AI_ClearPath();
	pNpc.AI_AddMovePos(57248, 113152);	-- 添加移动路线
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive2, self, pNpc.dwId};
	pNpc.SetNpcAI(9, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0); 
	return 0;
end

-- 年兽走到白秋林面前
function tbNpc:OnArrive2(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.GetTempTable("Npc").tbNianShou.nArrivePos = 1;
	pNpc.GetTempTable("Npc").tbNianShou.nBeHitActive = 1
	pNpc.AI_ClearPath();
	pNpc.SetNpcAI(4, 0, 80, 10, 10, 0, 25, 10, 0, 0, 0); 
	if not pNpc.GetTempTable("Npc").tbNianShou.nTimerId_BiSha then
		pNpc.GetTempTable("Npc").tbNianShou.nTimerId_BiSha = Timer:Register(tbNianShouSiege.FIGHTING_TIME, self.KillBaiQiuLing, self, nNpcId, tbNianShouSiege.nNpcFightQiuYiId);
	end
	pNpc.GetTempTable("Npc").tbOnArrive = nil;
	pNpc.SendChat("白秋琳！你竟敢阻拦我！鞭炮声使我又难受起来~");
	return 0;
end

-- 年兽死亡
function tbNpc:_OnDeath(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbAwardPlayerList = {};
	local tbNpcNianShou = pNpc.GetTempTable("Npc").tbNianShou;
	for nPlayerId, nCount in pairs(tbNpcNianShou.tbPlayerList) do
		if nCount >= tbNianShouSiege.PLAYER_HIT_TIMES_LIMIT then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				if tbNianShouSiege:CheckIsNearby(pPlayer, pNpc, tbNianShouSiege.MAX_AWARD_RANGE) == 1 then
					if tbNianShouSiege:CheckDayTask(pPlayer) == 1 then
						local nAwardCount = pPlayer.GetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_AWARD_COUNT)
						pPlayer.SetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_AWARD_COUNT, nAwardCount + 1);
						local nDayTimes = pPlayer.GetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_DAY_WIN_TIMES);
						pPlayer.SetTask(tbNianShouSiege.TASK_GROUP_ID, tbNianShouSiege.TASK_DAY_WIN_TIMES, nDayTimes + 1);
						pPlayer.Msg("您放过鞭炮，是白秋琳的大恩人，快去找她领取谢礼！");
						Dialog:SendBlackBoardMsg(pPlayer, "您放过鞭炮，是白秋琳的大恩人，快去找她领取谢礼！");
					end
					table.insert(tbAwardPlayerList, pPlayer);
				end
			end
		end
	end
	-- 随机发放宝箱奖励
	Lib:SmashTable(tbAwardPlayerList);
	local nXiangZiCount = 0;
	for _, pPlayer in ipairs(tbAwardPlayerList) do
		if pPlayer.CountFreeBagCell() >= 1 then
			pPlayer.AddItem(unpack(tbNianShouSiege.ITEM_XIANGZI_ID));
			pPlayer.Msg("年兽逃跑时不慎遗落了宝箱，恭喜你拿到一个！");
			pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]新春好运来，获得<color=yellow>年兽宝箱<color>一个！");
			Dialog:SendBlackBoardMsg(pPlayer, "年兽逃跑时不慎遗落了宝箱，恭喜你拿到一个！");
			nXiangZiCount = nXiangZiCount + 1;
		end
		if nXiangZiCount >= tbNianShouSiege.MAX_BAOXIAO_COUNT then
			break;
		end
	end 
	tbNpcNianShou.tbPlayerList = {};
	tbNpcNianShou.tbLogList = {};
	if tbNpcNianShou.nTimerId_BiSha then
		Timer:Close(tbNpcNianShou.nTimerId_BiSha);
		tbNpcNianShou.nTimerId_BiSha = nil;
	end
	pNpc.Delete();
	tbNianShouSiege.nNianShouId = nil;
	GCExcute{"SpecialEvent.NianShouSiege:NianShouDeath_GC", tbNpcNianShou.nMapId};
	StatLog:WriteStatLog("stat_info", "chunjie2011", "animal", 0, 0);
end

-- 年兽死亡回调
function tbNpc:OnDeath()
	if him.dwId ==  tbNianShouSiege.nNianShouId then
		self:_OnDeath(him.dwId);
	end
end

-- 年兽受到攻击
function tbNpc:OnHit(nPlayerId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcNianShou = pNpc.GetTempTable("Npc").tbNianShou;
	if tbNpcNianShou.nBeHitActive ~= 1 then
		return 0;
	end
	if tbNpcNianShou.tbPlayerList[nPlayerId] then
		tbNpcNianShou.tbPlayerList[nPlayerId] = tbNpcNianShou.tbPlayerList[nPlayerId] + 1;
	else
		tbNpcNianShou.tbPlayerList[nPlayerId] = 1;
	end
	if not tbNpcNianShou.tbLogList[nPlayerId] then
		tbNpcNianShou.tbLogList[nPlayerId] = 1;
		StatLog:WriteStatLog("stat_info", "chunjie2011", "animal", nPlayerId, tbNianShouSiege.nSeg);
	end
	pNpc.CastSkill(16, 1, -1, pNpc.nIndex);
	if tbNpcNianShou.nArrivePos == 0 and pNpc.nCurLife <= tbNianShouSiege.PROTECT_BLOOD then
		tbNpcNianShou.nBeHitActive = 0;
		pNpc.SendChat("竟逼老子出绝招：隔音棉！鞭炮暂时失效了");
		return 1;
	end
	return 1;
end

-- 年兽与白秋林的对话
function tbNpc:ChatWithBaiQiuLing(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if pNpc.GetTempTable("Npc").nChatTimerId then
		Timer:Close(pNpc.GetTempTable("Npc").nChatTimerId);
		pNpc.GetTempTable("Npc").nChatTimerId = nil;
	end
	local tbNpcNianShou = pNpc.GetTempTable("Npc").tbNianShou;
	local nIndex = tbNpcNianShou.nChatIndex or 1;
	if nIndex > #tbNianShouSiege.NIANSHOU_CHAT then
		--self:PromptPlayer(nNpcId);
		tbNpcNianShou.tbPlayerList = {};
		tbNpcNianShou.tbLogList = {};
		pNpc.Delete();
		GCExcute{"SpecialEvent.NianShouSiege:FailToKillNianShou_GC", tbNpcNianShou.nMapId};
		tbNianShouSiege.nNianShouId = nil;
		return 0;
	end
	pNpc.SendChat(tbNianShouSiege.NIANSHOU_CHAT[nIndex]);
	tbNpcNianShou.nChatIndex = nIndex + 1;
end

-- 任务失败提示玩家
function tbNpc:PromptPlayer(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcNianShou = pNpc.GetTempTable("Npc").tbNianShou;
	for nPlayerId, nCount in pairs(tbNpcNianShou.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if tbNianShouSiege:CheckIsNearby(pPlayer, pNpc, tbNianShouSiege.MAX_AWARD_RANGE) == 1 then
				pPlayer.Msg("白秋琳被击为重伤，您不能获得任何奖励了！");
				Dialog:SendBlackBoardMsg(pPlayer, "白秋琳被击为重伤，您不能获得任何奖励了！");
			end
		end
	end
end

-- 返回年兽是否可攻击
function tbNpc:CheckCanBeAttack(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcNianShou = pNpc.GetTempTable("Npc").tbNianShou;
	if tbNpcNianShou.nBeHitActive ~= 1 then
		return 0;
	end
	return 1;
end

-- 时间到释放必杀技杀死白秋林
function tbNpc:KillBaiQiuLing(nNpcNianShouId, nNpcQiuYiId)
	if not nNpcQiuYiId or not nNpcQiuYiId then
		return 0;
	end
	local pNpcQiuYi = KNpc.GetById(nNpcQiuYiId);
	if not pNpcQiuYi then
		return 0;
	end
	local pNpcNianShou = KNpc.GetById(nNpcNianShouId);
	if not pNpcNianShou then
		return 0;
	end
	pNpcNianShou.SendChat("不跟你玩了，我要出大招了");
	pNpcNianShou.GetTempTable("Npc").tbNianShou.nTimerId_BiSha = nil;
	Timer:Register(5 * 18, self.KillBaiQiuLing2, self, nNpcNianShouId, nNpcQiuYiId);
	return 0;
end

-- 隔5秒检查一次白秋林是否死了，直到弄死白秋林为止
function tbNpc:KillBaiQiuLing2(nNpcNianShouId, nNpcQiuYiId)
	if not nNpcQiuYiId or not nNpcQiuYiId then
		return 0;
	end
	local pNpcQiuYi = KNpc.GetById(nNpcQiuYiId);
	if not pNpcQiuYi then
		return 0;
	end
	local pNpcNianShou = KNpc.GetById(nNpcNianShouId);
	if not pNpcNianShou then
		return 0;
	end
	pNpcNianShou.CastSkill(475, 1, -1, pNpcQiuYi.nIndex);
end

-- 年兽喊话
function tbNpc:Chat(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRand = MathRandom(1, #tbNianShouSiege.MSG_NIANSHOU_CHAT);
	pNpc.SendChat(tbNianShouSiege.MSG_NIANSHOU_CHAT[nRand]);
end