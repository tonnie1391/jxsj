-- 文件名　：wine_fire.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-23 17:59:40
-- 描述：酿酒的篝火

local tbItem = Item:GetClass("wine_fire");

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

function tbItem:CanUse()
	local tbGame = KinGame2:GetGameObjByMapId(me.nMapId);
	if not tbGame then
		return -2;
	end
	local nRoom = tbGame:GetCurrentStepRoomId();
	if nRoom ~= 1 then
		return -2;
	end
	local tbRoom = tbGame.tbRoom[nRoom];
	if not tbRoom then
		return -2;
	end
	if tbRoom:IsRoomStart() ~= 1 then
		return -2;
	end
	if tbRoom.nStep ~= 2 then
		return -2;
	end
	local tbNpc = KNpc.GetAroundNpcList(me,KinGame2.WINE_NEED_FIRE_MIN_DISTANCE);	
	local nRet = 0;
	for _,pNpc in pairs(tbNpc) do
		if pNpc then
			if pNpc.nTemplateId == KinGame2.WINE_NPC_TEMPLATEID  then
				local nStep = pNpc.GetTempTable("KinGame2").nStep or 0;
				local nDead = tbRoom.tbWine[pNpc.dwId] and tbRoom.tbWine[pNpc.dwId].bDead or 0;
				local nFinish = tbRoom.tbWine[pNpc.dwId] and tbRoom.tbWine[pNpc.dwId].bFinishFire or 0;
				if nStep == 2 then	--只有点火阶段时候才能进行点火
					if nDead == 1 or nFinish == 1 then
						nRet = -1;
					else
						nRet = 1;
					end
				else
					nRet = -1;
				end
			end
		end
	end
	return nRet;
end

function tbItem:InitGenInfo()
	it.SetTimeOut(1,10 * 60);
	return {};
end

function tbItem:OnUse()
	local nRet = self:CanUse();
	if nRet == 0 then
		local szMsg = "请在酒坛附近使用";
		me.Msg(szMsg,"");
		Dialog:SendBlackBoardMsg(me,szMsg)
		return 0;
	elseif nRet == -1 then
		local szMsg = "现在并不需要火种";
		me.Msg(szMsg,"");
		Dialog:SendBlackBoardMsg(me,szMsg)
		return 0;
	elseif nRet == -2 then
		return 0;
	end
	GeneralProcess:StartProcess("点火中...", 1 * Env.GAME_FPS, {self.DoFire, self,it.dwId}, nil, tbEvent);
end

function tbItem:DoFire(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		return 0;
	end
	local _,x,y = me.GetWorldPos();
	KNpc.Add2(KinGame2.WINE_NEED_FIRE_ID,10,-1,me.nMapId,x,y);
end


--------任务物品----------
local tbTaskItem = Item:GetClass("kingame_taskitem");

function tbTaskItem:InitGenInfo()
	it.SetTimeOut(1,10 * 60);
	return {};
end