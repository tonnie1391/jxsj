-- 文件名　：missionlevel20_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-20 14:42:49
-- 描述：20教育副本npc

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

local tbZhuzi = Npc:GetClass("primerlv20_zhuzi");

function tbZhuzi:OnDialog()
	if me.GetTask(1025,28) ~= 1 then	--上一步没完成，不能开柱子
		return 0;
	end
	if me.GetTask(1025,29) == 1 then	--已经开启过了，不能开柱子
		return 0;
	end
	GeneralProcess:StartProcess("Đang mở...", 3 * Env.GAME_FPS, {self.OpenXiezi,self,him.dwId,me.nId},nil,tbEvent);
end

function tbZhuzi:OpenXiezi(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pGame = Task.PrimerLv20:GetGameObjByPlayerId(nPlayerId) or Task.PrimerLv20:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	local funFinish = function(pMember)
		if pMember.GetTask(1025,28) ~= 1 then	--没杀毒一风
			return 0;
		end
		if pMember.GetTask(1025,29) == 1 then	--已经开启过了，不能开柱子
			return 0;
		end
		--设置任务变量，完成任务29
		pMember.SetTask(1025,29,1);
	end
	pGame:TeamExcete(pPlayer,funFinish);
	pGame:AddXiezi();
	pNpc.Delete();
end

-------------------------------------------------
local tbBottle = Npc:GetClass("primerlv20_bottle");

function tbBottle:OnDialog()
--	GeneralProcess:StartProcess("Đang mở...", 3 * Env.GAME_FPS, {self.OpenBottle,self,him.dwId,me.nId},nil,tbEvent);
end


--function tbBottle:OpenBottle(nNpcId,nPlayerId)
--	local pNpc = KNpc.GetById(nNpcId);
--	if not pNpc then
--		return 0;
--	end
--	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
--	if not pPlayer then
--		return 0;
--	end
--	local pGame = Task.PrimerLv20:GetGameObjByPlayerId(nPlayerId);
--	if not pGame then
--		return 0;
--	end
--	pGame:OpenBottle();
--	pNpc.Delete();
--end

--------------------------------------------------

local tbXiting = Npc:GetClass("primerlv20_xiting");

function tbXiting:OnDialog()
	local nMapId = him.nMapId;
	local pGame = Task.PrimerLv20:GetGameObjByMapId(nMapId);
	if not pGame then
		return 0;
	end
	Task.PrimerLv20:StartStepByTaskStep(me,8);
	him.Delete();
	return 1;
end


---------------------------------
local tbBaiqiulin = Npc:GetClass("primerlv20_baiqiulin");

function tbBaiqiulin:OnDialog()
	local nMapId = him.nMapId;
	local pGame = Task.PrimerLv20:GetGameObjByMapId(nMapId) or Task.PrimerLv20:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	if me.GetTask(1025,32) ~= 2 then
		return 0;
	else
		local szMsg = "确定要离开么？"
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"我要离开碧落谷",Task.PrimerLv20.LeaveGame,Task.PrimerLv20,me.nId};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
	end
end


------------------------------
local tbCuijian = Npc:GetClass("cuijian");

function tbCuijian:OnDialog()
	if me.GetTask(1025,32) ~= 1 then
		Dialog:Say("几年前在家中饭都吃不饱，赶巧赶上征兵俺就来了，一天三顿，管饱！嘿嘿嘿…");
		return 0;		
	else
		local szMsg = "你真的要去碧落谷么？"
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"快送我去碧落谷",Task.PrimerLv20.OpenBiluogu,Task.PrimerLv20,me.nId};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
	end
end

