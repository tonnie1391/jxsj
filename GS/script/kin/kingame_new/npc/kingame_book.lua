-- 文件名　：kingame_book.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-30 21:30:22
-- 描述：地上的加buff的书

local tbNpc = Npc:GetClass("kingame_book");

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

function tbNpc:OnDialog()
	GeneralProcess:StartProcess("阅读中...", 1 * Env.GAME_FPS, {self.OnPickUp, self, him.dwId}, nil, tbEvent);	
end

function tbNpc:OnPickUp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nPickedCount = pNpc.GetTempTable("KinGame2").nPickedCount;
	if not nPickedCount or nPickedCount >= 3 then
		me.Msg("该本书已经被捡取！");
		pNpc.Delete();
	end
	local pGame = KinGame2:GetGameObjByMapId(pNpc.nMapId);
	if not pGame then
		return 0;
	end
	local nHasPicked = pGame:FindGetBookPlayer(me.nId);
	if nHasPicked == 1 then
		me.Msg("你已经捡过了，不要贪心!");
		return 0;
	end
	me.AddSkillState(KinGame2.PLAYER_ADD_BUFF_ID,1,0,KinGame2.PLAYER_BUFF_TIME * Env.GAME_FPS,1);
	pGame.tbGetBookPlayer[me.nId] = 1;	--标记捡过书了
	pNpc.GetTempTable("KinGame2").nPickedCount = nPickedCount + 1;
	if pNpc.GetTempTable("KinGame2").nPickedCount >= 3 then
		pNpc.Delete();
	end
end
