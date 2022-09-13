-------------------------------------------------------------------
--File		: tianlao.lua
--Author	: ZouYing
--Date		: 2008-8-26 16:43
--Describe	: 天牢脚本
-------------------------------------------------------------------

local PRISONE_LEFTTIME = 3;
local TIANLAO_MAPID = 399;
local TASK_PRISONE_TASKID = 2000;

local tbNpc = Npc:GetClass("tianlaoyuzu");

local tbTianLaoMap = Map:GetClass(TIANLAO_MAPID);

function tbNpc:OnTimer(nPlayerId)				-- 时间到会调用此函数
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	-- 返回0，表示要关闭此Timer
	local tbTmp = me.GetTempTable("Npc");
	tbTmp.nPrisonLeftTimeId = nil;
	me.SetTask(TASK_PRISONE_TASKID, PRISONE_LEFTTIME, 0);	-- 坐牢剩余时间设置为0秒
	-- 时间到了，自动传送出去
	self:LeavePrison(me);
	return 0;
end

function tbNpc:OnDialog()
	local tbTmp	= me.GetTempTable("Npc");
	
	if (tbTmp.nPrisonLeftTimeId) then
		
		local nLeftTime = Timer:GetRestTime(tbTmp.nPrisonLeftTimeId) / Env.GAME_FPS;
		local szMsg = "";
		
		if (nLeftTime > 0) then
			local nHour, nMin, nSec	= Lib:TransferSecond2NormalTime(nLeftTime);
			szMsg = string.format(Npc.IVER_szTianLao, nHour, nMin, nSec);	
	 		Dialog:Say(szMsg,
			{
				{"Kết thúc đối thoại"}
			});
		end
	elseif (me.GetTask(TASK_PRISONE_TASKID, PRISONE_LEFTTIME)) then
			Dialog:Say(Npc.IVER_szTianLaoForever,
			{
				{"Kết thúc đối thoại"}
			});
	else
		-- 时间到了，自动传送出去
		self:LeavePrison(me);		
	end
end

function tbNpc:LeavePrison(pPlayer)
	if (not pPlayer) then
		return; 
	end
	
	pPlayer.SetForbidChat(0);
	pPlayer.DisabledStall(0);	--摆摊
	pPlayer.DisableOffer(0);
	local nMapId, nPointId, nXPos, nYPos = pPlayer.GetDeathRevivePos();
	
	pPlayer.NewWorld(nMapId, nXPos / 32, nYPos / 32);
end

-- 定义玩家进入事件
function tbTianLaoMap:OnEnter(szParam)
	
	local nRestSec = me.GetTask(TASK_PRISONE_TASKID, PRISONE_LEFTTIME);
	me.SetForbidChat(1);
	-- 开启计时器（最多禁100天，大于100天即为永久）
	if (nRestSec > 0 and nRestSec <= 100 * 3600) then
		me.DisabledStall(1);	--摆摊
		me.DisableOffer(1);
		local tbTmp	= me.GetTempTable("Npc");
		tbTmp.nPrisonLeftTimeId = Timer:Register(nRestSec * Env.GAME_FPS, tbNpc.OnTimer, tbNpc, me.nId);
	end
end

-- 定义玩家离开事件
function tbTianLaoMap:OnLeave(szParam)
	local tbTmp = me.GetTempTable("Npc");
	if (tbTmp.nPrisonLeftTimeId) then
		local nRestSec	= Timer:GetRestTime(tbTmp.nPrisonLeftTimeId) / Env.GAME_FPS;
		if (nRestSec <= 0) then	-- 特殊处理正好等于0的情况
			nRestSec = 0;
		end
		me.SetTask(TASK_PRISONE_TASKID, PRISONE_LEFTTIME, nRestSec);
		Timer:Close(tbTmp.nPrisonLeftTimeId);
		tbTmp.nNpcYuzuTimerId = nil;
	end
end


