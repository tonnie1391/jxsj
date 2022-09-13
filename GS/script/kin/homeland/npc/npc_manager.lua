Require("\\script\\kin\\homeland\\homeland_def.lua")

local tbNpc = Npc:GetClass("homelandnpc_manager");

function tbNpc:OnDialog()
	local szMsg = "Ngươi cần đi đến đâu? Ta tiễn ngươi 1 đoạn";
	local tbOpt = {};
	-- for i = 1, #HomeLand.TB_TRANS_POS do
		-- table.insert(tbOpt, {HomeLand.TB_TRANS_POS[i][2], self.Transmit, self, i});
	-- end
	table.insert(tbOpt, {"Về chốn giang hồ", self.Back2City, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:Transmit(nPosIndex)
	me.NewWorld(me.nMapId, HomeLand.TB_TRANS_POS[nPosIndex][1][1], HomeLand.TB_TRANS_POS[nPosIndex][1][2]);
end

function tbNpc:Back2City()
	Npc:GetClass("chefu"):SelectMap("city");
end