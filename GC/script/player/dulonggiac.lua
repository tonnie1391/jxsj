
Player.AllPlayerOwn = {}

function Player:GetAllPlayerHaveItem()
	DoScript("\\script\\player\\dulonggiac.lua")
	GlobalExcute({"Player:GetAllPlayer"})
end

function Player:CreateDuLongGiac()
	local szMsg = string.format("<color=yellow>Du Long Giác<color> đã xuất hiện tại Ba Lăng Huyện")
	Dialog:GlobalMsg2SubWorld_GC(szMsg);
	GlobalExcute({"Player:CreateDuLongGiac"})
end

function Player:DelDuLongGiac()
	local szMsg = string.format("Toàn bộ <color=yellow>Du Long Giác<color> đã biến mất!")
	Dialog:GlobalMsg2SubWorld_GC(szMsg);
	GlobalExcute({"Player:ClearDuLongGiac"})
end

function Player:Result(tbPlayer)
	Player.AllPlayerOwn = {}
	for _, tbPlayerInfo in pairs (tbPlayer) do
		table.insert(Player.AllPlayerOwn, tbPlayerInfo)
	end
	
	for _, tbPlayerAnn in pairs (Player.AllPlayerOwn) do
		local szMsg = string.format("<color=yellow>Du Long Giác<color> đang nằm trong tay <color=green>%s<color> <pos=%d,%d,%d>", tbPlayerAnn[1], tbPlayerAnn[2], tbPlayerAnn[3], tbPlayerAnn[4])
		Dialog:GlobalMsg2SubWorld_GC(szMsg);
	end
end