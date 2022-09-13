-------------------------------------------------------
-- 文件名　：qinshihuang_map.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-20 14:31:21
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\qinshihuang\\qinshihuang_def.lua");

local tbQinshihuang = Boss.Qinshihuang;

-- trap
local tbTrap = tbQinshihuang.Trap or {};
tbQinshihuang.Trap = tbTrap;

function tbTrap:OnPlayer()
	if self.nMapId and self.nMapX and self.nMapY and tbQinshihuang._nPasserEffect == 1 then
		self:DoTransfer(self.nMapId, self.nMapX, self.nMapY);
	end
end

function tbTrap:DoTransfer(nMapId, nMapX, nMapY)
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
--		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
--		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đang truyền tống", 10 * Env.GAME_FPS, {self.DoTransferEnd, self, nMapId, nMapX, nMapY}, nil, tbBreakEvent);	
end

function tbTrap:DoTransferEnd(nMapId, nMapX, nMapY)
	me.SetFightState(1);
	me.NewWorld(nMapId, nMapX, nMapY);	
end
-- end

function tbQinshihuang:LinkMapTrap()
	for szTrapName, tbInfo in pairs(self.MAP_TRAP_POS) do
		local tbMap = Map:GetClass(tbInfo[1]);
		local tbTrap = tbMap:GetTrapClass(szTrapName);
		tbTrap.nMapId = tbInfo[2];
		tbTrap.nMapX = tbInfo[3];
		tbTrap.nMapY = tbInfo[4];
		for szFunTrap in pairs(self.Trap) do
			tbTrap[szFunTrap] = self.Trap[szFunTrap];
		end
	end
end

tbQinshihuang:LinkMapTrap();
