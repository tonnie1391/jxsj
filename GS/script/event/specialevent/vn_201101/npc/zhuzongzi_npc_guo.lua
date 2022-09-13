-- 文件名　：zhuzongzi_npc_guo.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-21 16:10:10
-- 描  述  ：

SpecialEvent.ZongZi2011 = SpecialEvent.ZongZi2011 or {};
local tbZongZi = SpecialEvent.ZongZi2011 or {};

local tbNpc = Npc:GetClass("zhuzongzi_guo_vn");

function tbNpc:OnDialog()
	if me.nId ~= tbZongZi:GetOwnerId(him) then
		return;
	end
	if tbZongZi:IsWellDone(him) == 0 then	-- 未煮熟
		local nRes, szMsg = tbZongZi:GetDialogMsg(him);
		if nRes == 0 then
			return 0;
		end
		local tbOpt = {{"知道了"}};
		if tbZongZi:IsActived(him) == 0 then
			tbOpt = 
			{
				{"加木柴", tbZongZi.DialogAddMuChai, tbZongZi, me.nId, him.dwId},
				{"知道了"}
			};
		end
		Dialog:Say(szMsg, tbOpt);
	else	
		local nState = tbZongZi:HasZongZi(him);
		if nState == 0 then	-- 已经收获
			Dialog:Say("你已经从锅子里获得了粽子。");
		else
			local nRes, szMsg = tbZongZi:GetDialogMsg(him);
			if nRes == 0 then
				return 0;
			end
			local tbOpt = 
			{
				{"收获粽子", tbZongZi.DialogGetZongZi, tbZongZi, me.nId, him.dwId},
				{"再等等看"}	
			};
			Dialog:Say(szMsg, tbOpt);
		end
	end
end

function tbZongZi:DialogAddMuChai(nPlayerId, nNpcId, nCheck)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not Npc then
		Dialog:Say("真遗憾，你煮粽子的火熄了");
		return 0;
	end
	if nCheck and nCheck == 1 then
		self:AddMuChai(nPlayerId, nNpcId);
		return 0;
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
		
	GeneralProcess:StartProcess("加木柴中", 3 * Env.GAME_FPS, 
		{self.DialogAddMuChai,self, nPlayerId, nNpcId, 1}, nil, tbEvent);
end

function tbZongZi:DialogGetZongZi(nPlayerId, nNpcId, nCheck)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if pPlayer.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ ，请清理出<color=yellow>1格<color>背包空间。");
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not Npc then
		Dialog:Say("真遗憾，你煮粽子的火熄了");
		return 0;
	end
	if nCheck and nCheck == 1 then
		self:GetZongZi(nPlayerId, nNpcId);
		return 0;
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
		
	GeneralProcess:StartProcess("收获中", 3 * Env.GAME_FPS, 
		{self.DialogGetZongZi,self, nPlayerId, nNpcId, 1}, nil, tbEvent);
end