-------------------------------------------------------
-- 文件名　 : superbattle_npc_land.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 16:17:12
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbNpc = Npc:GetClass("superbattle_npc_land");

function tbNpc:OnDialog()
	
	-- 活动是否开启
	if SuperBattle:CheckIsOpen() ~= 1 or SuperBattle:CheckIsGlobal() ~= 1 then
		Dialog:Say("Chiến trường chưa mở, không thể tham gia.");
		return 0;
	end
	
	local szMsg = "    Hai mươi năm rồi, ta vẫn không thể quên được trận chiến năm xưa. Khói lửa khuynh thành, đao kiếm ngang dọc. Ngươi muốn theo ta đến chiến trường năm xưa.\n<color=yellow>(Khi trận chiến kết thúc, hãy quay lại đây nhận phần thưởng của mình)<color>";
	local tbOpt = 
	{
		{"<color=yellow>Tham chiến<color>", self.EnterBattle, self},
		{"Kiểm tra thứ hạng trong tuần", self.Query, self},
		{"Kiểm tra điểm tuần trước", self.QueryLastGpa, self},
		{"Ta hiểu rồi"},	
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:EnterBattle()
	SuperBattle:EnterBattle_GS(me);
end

function tbNpc:Query()
	local szMsg = "    Tại đây có thể kiểm tra thứ hạng trên toàn máy chủ, ";
	local nSort = 0;
	local nGpa = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_GPA) or 0;
	for i, tbInfo in pairs(SuperBattle.tbGlobalBuffer) do
		if tbInfo[1] == me.szName then
			nSort = i;
		end
	end
	if nSort == 0 then
		szMsg = szMsg .. string.format("Tích lũy của ngươi là: <color=yellow>%s<color>, chưa lọt vào bảng xếp hạng.", nGpa);
	else
		szMsg = szMsg .. string.format("Tích lũy của ngươi là: <color=yellow>%s<color>, đạt hạng <color=yellow>%s<color> trên bảng xếp hạng", nGpa, nSort);
	end
	local tbOpt =
	{
		{"<color=yellow>Xem bảng xếp hạng<color>", self.QueryOther, self},
		{"Ta hiểu rồi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:QueryOther(nFrom)
	local tbOpt = {"Ta hiểu rồi"};
	local szMsg = "          <color=cyan>XẾP HẠNG LIÊN SERVER<color>\n\n";
	local nBegin = nFrom or 0;
	local nLeft = #SuperBattle.tbGlobalBuffer - nBegin;
	local nLength = nLeft <= 10 and nLeft or 10;
	for i = nBegin, nBegin + nLength do 
		if SuperBattle.tbGlobalBuffer[i] then
			szMsg = szMsg .. string.format("<color=yellow>%s%s%s%s<color>\n",
				Lib:StrFillC(string.format("%s.", i), 4),
				Lib:StrFillC(SuperBattle.tbGlobalBuffer[i][1], 17),
				Lib:StrFillC(ServerEvent:GetServerNameByGateway(SuperBattle.tbGlobalBuffer[i][3]), 8),
				Lib:StrFillC(SuperBattle.tbGlobalBuffer[i][2], 6)
			);
		end
	end
	if nLeft > 10 then
		table.insert(tbOpt, 1, {"<color=yellow>Trang kế<color>", self.QueryOther, self, nBegin + nLength + 1});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:QueryLastGpa()
	local nLastGpa = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_LAST_GPA) or 0;
	local nLastSort = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_LAST_SORT) or 0;
	local szMsg = string.format("Tích lũy tuần trước của ngươi là: <color=yellow>%s<color>, đạt hạng <color=yellow>%s<color> trên bảng xếp hạng", nLastGpa, nLastSort);
	Dialog:Say(szMsg);
end
