-- 材料，任何玩家点击会采得此物品

local tbNpc = Npc:GetClass("funiushan_caikuangqu_masheng"); 

-- TODO: liuchang 刷新点
tbNpc.tbGrowPoses = 
{
	{1886,3478},
	{1895,3477},
	{1928,3298},
	{1950,3439},
	{1976,3302},
	{2002,3355},
	{2018,3423},
	{2038,3389},
}


-- 刷新材料
function tbNpc:Grow(nMapId)	
	for _, tbPos in ipairs(self.tbGrowPoses) do
		KNpc.Add2(4013, 1, -1, nMapId, tbPos[1], tbPos[2]);
	end
end


function tbNpc:OnDialog()
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
	
	GeneralProcess:StartProcess("正在采集", 5 * 18, {self.OnCollect, self, him.dwId, me.nId}, {me.Msg, "采集失败"}, tbEvent);		
end;


function tbNpc:OnCollect(nNpcId, nPlayerId)
	-- 删除此Npc
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pNpc or not pPlayer) then
		return;
	end
	local nMapId, nPosX, nPosY = pNpc.GetWorldPos();
	-- TODO:liuchang 之后得注册FB计时器，当FB关闭的时候会关闭这些计时器
	Timer:Register(Env.GAME_FPS*8, self.Rebirth, self, pNpc.nTemplateId, nMapId, nPosX, nPosY);
	pNpc.Delete();
	
	-- 添加材料
	pPlayer.AddItem(20, 1, 604, 1);
end


function tbNpc:Rebirth(nTemplateId, nMapId, nPosX, nPosY)
	KNpc.Add2(nTemplateId, 1, -1, nMapId, nPosX, nPosY);
	
	return 0;
end


local tbNpc1 = Npc:GetClass("funiushan_caikuangqu_mubang"); 

-- TODO: liuchang 刷新点
tbNpc1.tbGrowPoses = 
{
	{1886,3469},
	{1891,3482},
	{1897,3473},
	{1931,3413},
	{1952,3257},
	{1960,3327},
	{1956,3424},
	{1976,3307},
	{1993,3431},
	{2013,3411},
	{2024,3337},
}


-- 刷新材料
function tbNpc1:Grow(nMapId)	
	for _, tbPos in ipairs(self.tbGrowPoses) do
		KNpc.Add2(4014, 1, -1, nMapId, tbPos[1], tbPos[2]);
	end
end


function tbNpc1:OnDialog()
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
	
	GeneralProcess:StartProcess("正在采集", 5 * 18, {self.OnCollect, self, him.dwId, me.nId}, {me.Msg, "采集失败"}, tbEvent);		
end;


function tbNpc1:OnCollect(nNpcId, nPlayerId)
	-- 删除此Npc
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pNpc or not pPlayer) then
		return;
	end
	local nMapId, nPosX, nPosY = pNpc.GetWorldPos();
	-- TODO:liuchang 之后得注册FB计时器，当FB关闭的时候会关闭这些计时器
	Timer:Register(Env.GAME_FPS*8, self.Rebirth, self, pNpc.nTemplateId, nMapId, nPosX, nPosY);
	pNpc.Delete();
	
	-- 添加材料
	pPlayer.AddItem(20, 1, 605, 1);
end


function tbNpc1:Rebirth(nTemplateId, nMapId, nPosX, nPosY)
	KNpc.Add2(nTemplateId, 1, -1, nMapId, nPosX, nPosY);
	
	return 0;
end
