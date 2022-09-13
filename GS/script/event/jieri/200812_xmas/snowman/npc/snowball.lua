-- 文件名　：snowball.lua
-- 创建者　：zounan
-- 创建时间：2009-11-24 14:35:26
-- 描  述  ：
local tbNpc = Npc:GetClass("snowball");

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};
SpecialEvent.Xmas2008.XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman or {};
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;

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
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	GeneralProcess:StartProcess("采集中..." , XmasSnowman.SNOWBALL_CATCHTIME * Env.GAME_FPS ,  {self.CatchSnow , self,him.dwId} , nil , tbEvent);	
end

function tbNpc:CatchSnow(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	
	if not pNpc.GetTempTable("Npc").nIndex then
		return;
	end	
	local nIndex = pNpc.GetTempTable("Npc").nIndex;
	if not XmasSnowman.tbSnowballMgr[nIndex] then
		return;
	end
	
	if not XmasSnowman.tbSnowballMgr[nIndex][pNpc.dwId] then
		return;
	end
	
	local nRandom = MathRandom(1,3);
	if me.CountFreeBagCell() < 1 then
		me.Msg("您的包裹空间不足");
		return;
	end
	for i = 1, nRandom do
		local pItem = me.AddItem(unpack(XmasSnowman.SNOWFLAKE_ID));
		if pItem then
			pItem.Bind(1);
			me.SetItemTimeout(pItem, XmasSnowman.SNOWFLAKE_TIMEOUT, 0);
		end
	end
		
	Timer:Register(Env.GAME_FPS * XmasSnowman.SNOWBALL_INTERVAL, self.CallSnowBall, self, me.nMapId, nIndex, XmasSnowman.tbSnowballMgr[nIndex][pNpc.dwId]);
	pNpc.Delete();
	XmasSnowman.tbSnowballMgr[nIndex][pNpc.dwId] = nil;
	return;	
end

function tbNpc:CallSnowBall(nMapId, nIndex, nPos)
	local nNpcId =  XmasSnowman.tbSnowmanMgr[nIndex];
	if nNpcId then
		local pSnowman = KNpc.GetById(nNpcId);	
		if pSnowman and pSnowman.GetTempTable("Npc").tbData then	
			local pNpc = KNpc.Add2(XmasSnowman.SNOWBALL_ID, 50, -1, nMapId, XmasSnowman.SNOWBALL_POS[nIndex][nPos].nX, XmasSnowman.SNOWBALL_POS[nIndex][nPos].nY);
			if pNpc then
				XmasSnowman.tbSnowballMgr[nIndex][pNpc.dwId] = nPos;
				pNpc.GetTempTable("Npc").nIndex = nIndex;
			end
		end
	end
	return 0;
end	
