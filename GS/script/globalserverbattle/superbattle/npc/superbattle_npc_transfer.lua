-------------------------------------------------------
-- 文件名　 : superbattle_npc_transfer.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-09 16:51:57
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbNpc = Npc:GetClass("superbattle_npc_transfer");

function tbNpc:OnDialog()
	local szMsg = "    Một cách thần kỳ của tạo hóa! Ngươi muốn đi đâu? Ta sẽ giúp ngươi...";
	local tbOpt = {};
	local nCamp = SuperBattle:GetPlayerTypeData(me, "nCamp");
	if nCamp > 0 then
		for _, tbInfo in pairs(SuperBattle.tbPole) do
			if tbInfo.nOwner == nCamp then
				local tbPole = SuperBattle.POLE_POS[tbInfo.nIndex];
				if tbPole then
					table.insert(tbOpt, {tbPole.szName, self.TransPole, self, tbInfo.nIndex});
				end
			end
		end
	end
	tbOpt[#tbOpt + 1] = {"<color=yellow>Chức năng Tẩy Tủy<color>", self.ResetPoint, self};
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:TransPole(nIndex)
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đang truyền tống...", 1 * Env.GAME_FPS, {self.DoTransPole, self, nIndex}, nil, tbBreakEvent);
end

function tbNpc:DoTransPole(nIndex)
	local tbPole = SuperBattle.POLE_POS[nIndex];
	if tbPole then
		local nMapX, nMapY = unpack(tbPole.tbTransPos);
		me.SetFightState(1);
		Player:AddProtectedState(me, SuperBattle.SUPER_TIME);
		me.NewWorld(me.nMapId, nMapX, nMapY);
	end
end

function tbNpc:ResetPoint()
	
	local tbDashi = Npc:GetClass("xisuidashi");
	local szMsg = "Ta có thể giúp ngươi phân phối lại Điểm Tiềm Năng và Điểm Kỹ Năng. Ngươi muốn điều gì?";
	local tbOpt = 
	{
		{"Tẩy Điểm Tiềm Năng", tbDashi.OnResetDian, tbDashi, me, 1},
		{"Tẩy Điểm Kỹ Năng", tbDashi.OnResetDian, tbDashi, me, 2},
		{"Tẩy cả 2 loại", tbDashi.OnResetDian, tbDashi, me, 0},
		{"Quay lại", self.OnDialog, self},
	};	

	Dialog:Say(szMsg, tbOpt);
end
