-- 文件名　：trap_switch.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-19 21:41:52
-- 描述：开启trap点的npc

local tbNpc = Npc:GetClass("trap_switch");


function tbNpc:OnDialog()
	self:OnSwitch(him.dwId);
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
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
}

function tbNpc:OnSwitch(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end
	local pGame =  KinGame2:GetGameObjByMapId(me.nMapId);
	local tbTmp = pNpc.GetTempTable("KinGame2");
	if not tbTmp or not tbTmp.nRoomId or not tbTmp.nDirection then
		return 0;
	end
	if not pGame then
		return 0;
	end
	--当前房间的上一个房间如果未完成，则不能进行开锁操作
	local pRoom = pGame.tbRoom[tbTmp.nRoomId - 1];
	if pRoom:IsRoomFinished() ~= 1 then
		return 0;
	end 
	local nHasOpen = tbTmp.nHasOpen;
	if not nHasOpen or nHasOpen == 0 then
		GeneralProcess:StartProcess("Đang mở...", KinGame2.TRAP_SWITCH_DELAY * Env.GAME_FPS, {self.OnOpen, self, nNpcId}, nil, tbEvent);	
	elseif nHasOpen == 1 then
		Dialog:SendBlackBoardMsg(me, "这个柱子的机关已经被人开动过了。");
		return 0;
	end
end

function tbNpc:OnOpen(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end
	local tbTmp = pNpc.GetTempTable("KinGame2");
	local pGame =  KinGame2:GetGameObjByMapId(me.nMapId);
	if not tbTmp or not tbTmp.nRoomId or not tbTmp.nDirection then
		return 0;
	end
	if not pGame then
		return 0;
	end
	if tbTmp.nHasOpen and tbTmp.nHasOpen == 1 then
		Dialog:SendBlackBoardMsg(me, "这个柱子的机关已经被人开动过了。");
		return 0;
	end
	local pRoom = pGame.tbRoom[tbTmp.nRoomId];
	if tbTmp.nRoomId == 4 or tbTmp.nRoomId == 5 or tbTmp.nRoomId == 6 then
		if tbTmp.nDirection == 1 then
			if not pRoom.nIsRightOpen or pRoom.nIsRightOpen == 0 then
				pRoom.nIsRightOpen = 1;
				Dialog:SendBlackBoardMsg(me, "你听到“唰”的一声，对面的障碍已经开启了");
				pNpc.GetTempTable("KinGame2").nHasOpen = 1;
				pGame:DelTrapNpc(tbTmp.nRoomId,2);
			end
		elseif tbTmp.nDirection == 2 then
			if not pRoom.nIsLeftOpen or pRoom.nIsLeftOpen == 0 then
				pRoom.nIsLeftOpen = 1;
				Dialog:SendBlackBoardMsg(me, "你听到“唰”的一声，对面的障碍已经开启了");
				pNpc.GetTempTable("KinGame2").nHasOpen = 1;
				pGame:DelTrapNpc(tbTmp.nRoomId,1);
			end
		end
		if pRoom.nIsLeftOpen == 1 and pRoom.nIsRightOpen == 1 then
			pGame:StartRoom(tbTmp.nRoomId);
		end
		return 0;
	else
		pNpc.GetTempTable("KinGame2").nHasOpen = 1;
		pGame:DelTrapNpc(tbTmp.nRoomId,1);
		pGame:StartRoom(tbTmp.nRoomId);
		return 0;
	end
end