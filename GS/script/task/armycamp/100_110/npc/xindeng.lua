-----------------------------------------------------------
-- 文件名　：xindeng.lua
-- 文件描述：心灯
-- 创建者　：ZhangDeheng
-- 创建时间：2008-12-02 16:15:45
-----------------------------------------------------------

local tbXinDengIn = Npc:GetClass("xindeng_in");

-- 传送的位置
tbXinDengIn.tbPos = {{1842, 2779}, {1872, 2867}, {1836, 2929}, {1773, 2892}, {1773, 2818}, };
 
function tbXinDengIn:OnDialog()
	--打断传送事件
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	-- 传送
	local nIndex = him.GetTempTable("Task").nId
	if (not nIndex or nIndex < 1 or nIndex > 5) then
		return;
	end;
	GeneralProcess:StartProcess("Đang truyền tống...", 1 * Env.GAME_FPS, {self.SendTo, self, me.nId, self.tbPos[nIndex][1], self.tbPos[nIndex][2]}, {me.Msg, "Dịch chuyển thất bại!"}, tbEvent);
end;

function tbXinDengIn:SendTo(nPlayerId, nPosX, nPosY)
	local pPlayer =  KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	local nSubWorld, _, _	= pPlayer.GetWorldPos();
	pPlayer.NewWorld(nSubWorld, nPosX, nPosY);
end;

-- 心灯 出
local tbXinDengOut = Npc:GetClass("xindeng_out");

tbXinDengOut.tbPos = {{1820, 2821}, {1843, 2857}, {1822, 2877}, {1795, 2859}, {1799, 2837}, };

function tbXinDengOut:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local nIndex = him.GetTempTable("Task").nId
	if (not nIndex or nIndex < 1 or nIndex > 5) then
		return;
	end;
	
	me.NewWorld(nSubWorld, self.tbPos[nIndex][1], self.tbPos[nIndex][2]);
end;