-------------------------------------------------------------------
--File:
--Author: sunduoliang
--Date: 2008-5-21 21:59
--Describe: 篝火物品脚本
-------------------------------------------------------------------

local tbGouhuoItem	= Item:GetClass("firewood_tong");

tbGouhuoItem.nDelayTime		= 5;	-- 拾取篝火时会延时5(秒) 

-- 功能:	判断篝火能否被拾取(没有组队不能拾取)
-- 参数:	nObjId	物品ID
function tbGouhuoItem:IsPickable(nObjId)
	if me.dwTongId <= 0 then
		me.Msg("没有加入帮会，不能点燃。")
		return 0;
	end
	self:DelayTime(me, nObjId);
	return 0;
end

-- 功能:	篝火拾取了以后的操作
-- 参数:	nX, nY	被拾取的篝火的坐标
function tbGouhuoItem:PickUp(nX, nY)
	local nExistentTime = it.GetExtParam(1);	--持续时间
	local nBaseMultip = it.GetExtParam(2);		--经验倍率
	if nExistentTime == 0 then
		nExistentTime = 900;
	end
	if nBaseMultip == 0 then
		nBaseMultip = 100;
	end
	self:CallGouhuoNpc(nX, nY, nExistentTime, nBaseMultip);
	me.Msg("你点燃了篝火，可以和自己帮会成员在篝火周围分享经验！");
	return	0;
end


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
-- 功能:	拾取篝火进度条，执行self.nDelayTime秒的延时
-- 参数:	pPlayer 拾取篝火的玩家对象
-- 参数:	nObjId	物品ID
function tbGouhuoItem:DelayTime(pPlayer, nObjId)
	GeneralProcess:StartProcess("Đang đốt lửa...", self.nDelayTime * Env.GAME_FPS, {self.DoPickUp, self, pPlayer.nId, nObjId}, nil, tbEvent);
end

-- 功能:	进度条结束后执行拾取物品
-- 参数:	pPlayer	拾取的玩家，
-- 参数:	nObjId	物品ID
function tbGouhuoItem:DoPickUp(nPlayerId, nObjId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return;
	end
	pPlayer.PickUpItem(nObjId, 0);
end

-- 功能:	call出篝火Npc
-- 参数:	nX, nY	被拾取的篝火的坐标
function tbGouhuoItem:CallGouhuoNpc(nX, nY, nExistentTime, nBaseMultip)
	local tbNpc	= Npc:GetClass("gouhuonpc");
	local nMapIdx		= SubWorldID2Idx(me.nMapId);
	local pNpc	= KNpc.Add(tbNpc.nNpcId, 1, -1, nMapIdx, nX, nY);		-- 获得篝火Npc
	tbNpc:InitGouHuo(pNpc.dwId, 3,	nExistentTime, 5, 45, nBaseMultip, 0)
	local nTongId = me.dwTongId;
	tbNpc:SetTongId(pNpc.dwId, nTongId)
	tbNpc:StartNpcTimer(pNpc.dwId)
end
