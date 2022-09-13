-- 文件名　：missionlevel10_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-26 15:06:51
-- 描述：10级教育副本npc

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
}

local tbZhuzi = Npc:GetClass("primerlv10_zhuzi");

function tbZhuzi:OnDialog()
	local nSeries = him.GetTempTable("Task").nSeries;
	if not nSeries then
		return 0;
	end
	local nTaskSub = Task.PrimerLv10.tbNormalBossTaskSub[nSeries];
	if me.GetTask(1025,nTaskSub) == 1 then	--已经杀过这个boss了不能开柱子
		return 0;
	end
	GeneralProcess:StartProcess("Đang mở...", 3 * Env.GAME_FPS, {self.OpenBoss,self,him.dwId,me.nId,nSeries},nil,tbEvent);
end

function tbZhuzi:OpenBoss(nNpcId,nPlayerId,nSeries)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pGame = Task.PrimerLv10:GetGameObjByPlayerId(nPlayerId) or Task.PrimerLv10:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	pGame:AddSeriesBoss(nNpcId,nSeries,pPlayer.nSeries);
end

-------------------------------
local tbFire = Npc:GetClass("primerlv10_fire");


function tbFire:OnDialog()
	local tbFind = me.FindItemInBags(unpack(Task.PrimerLv10.PUSH_FIRE_ITEM));
	if #tbFind < 1 then
		return 0;
	end
	if me.GetTask(1025,48) ~= 1 then
		return 0;
	end
	if me.GetTask(1025,39) == 5 then
		return 0;
	end
	GeneralProcess:StartProcess("灭火中...", 2 * Env.GAME_FPS, {self.PushFire,self,him.dwId,me.nId},nil,tbEvent);
end

function tbFire:PushFire(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pGame = Task.PrimerLv10:GetGameObjByPlayerId(nPlayerId) or Task.PrimerLv10:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	local tbFind = pPlayer.FindItemInBags(unpack(Task.PrimerLv10.PUSH_FIRE_ITEM));
	if #tbFind < 1 then
		return 0;
	end
	if #tbFind > 0 then
		pPlayer.ConsumeItemInBags(1, unpack(Task.PrimerLv10.PUSH_FIRE_ITEM));
		pNpc.Delete();
		pGame:PushFire(nPlayerId);
		return 1;
	end	
end

---------------------------------
local tbBaiqiulin = Npc:GetClass("primerlv10_baiqiulin");

function tbBaiqiulin:OnDialog()
	local nMapId = him.nMapId;
	local pGame = Task.PrimerLv10:GetGameObjByMapId(nMapId) or Task.PrimerLv10:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	if me.GetTask(1025,33) ~= 2 then
		return 0;
	else
		local szMsg = "确定要离开么？"
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"我要离开",Task.PrimerLv10.LeaveGame,Task.PrimerLv10,me.nId};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
	end
end

----------------------------------
local tbWounded = Npc:GetClass("primerlv10_wounded");

function tbWounded:OnDialog()
	local tbFind = me.FindItemInBags(unpack(Task.PrimerLv10.GRASS_ITEM));
	if #tbFind < 1 then
		return 0;
	end
	if me.GetTask(1025,49) ~= 1 then
		return 0;
	end
	if me.GetTask(1025,40) == 5 then
		return 0;
	end
	if him.GetTempTable("Task").nHasCured and him.GetTempTable("Task").nHasCured == 1 then
		return 0;
	end
	GeneralProcess:StartProcess("医治伤员中...", 2 * Env.GAME_FPS, {self.Cure,self,him.dwId,me.nId},nil,tbEvent);
end

function tbWounded:Cure(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pGame = Task.PrimerLv10:GetGameObjByPlayerId(nPlayerId) or Task.PrimerLv10:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	local tbFind = pPlayer.FindItemInBags(unpack(Task.PrimerLv10.GRASS_ITEM));
	if #tbFind < 1 then
		return 0;
	end
	if #tbFind > 0 then
		pPlayer.ConsumeItemInBags(1, unpack(Task.PrimerLv10.GRASS_ITEM));
		pNpc.SendChat("谢谢你，我的伤已经好了....");
		pNpc.GetTempTable("Task").nHasCured = 1;	--标记此玩家已经治愈过
		pGame:CureWounded(nPlayerId);
		if pGame.nIsStatic == 1 then
			pNpc.Delete();	--如果是静态副本，就删除这个npc
		end
		return 1;
	end	
end

