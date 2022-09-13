-- 晓菲
local tbXiaoFei = Npc:GetClass("xoyonpc_xiaofei") -- id:3319
function tbXiaoFei:OnDialog()
	if TimeFrame:GetState("OpenXoyoGameTask") ~= 1 then
		Dialog:Say("Hoạt động chưa mở, hãy quay trở lại sau.");
		return;
	end
	
	local szMsg = "Nghe đồng Tiêu Dao Cốc có rất nhiều thẻ thần kỳ, ta có một bộ sưu tập, hãy đặt những thẻ thu thập được vào đây, ta sẽ căn cứ số lượng và hạng thẻ để thưởng cho ngươi.";
	szMsg = szMsg .. "<enter><color=red>Chỗ ta còn rất nhiều Thẻ bảo vật, nhưng ngươi phải tìm được những bảo vật này thì ta mới cho ngươi được.<color>";
	
	local tbOpt = {
		{"Nhận Tiêu Dao Lục", self.GetXoyolu, self},	
		{"Bảo vật đổi thẻ", self.HandUpItem, self},
		{"Ta muốn đổi Thể đặc biệt", self.GetSpecialCard, self},	
		{"Ta đến nhận thưởng", self.GetAward, self},
		{"Kết thúc đối thoại"},
	};
	
	--if tonumber(GetLocalDate("%Y%m%d")) < 20090501 then
	--	table.insert(tbOpt, 2, {"交还逍遥录", self.HandUpXoyolu, self});
	--end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbXiaoFei:GetXoyolu()
	local nRes, szMsg = XoyoGame.XoyoChallenge:CanGetXoyolu(me);
	if nRes == 0 and szMsg then
		Dialog:Say(szMsg);
		return;
	end
	
	XoyoGame.XoyoChallenge:GetXoyolu(me);
end

function tbXiaoFei:HandUpXoyolu()
	local nRes, szMsg = XoyoGame.XoyoChallenge:CanHandUpXoyolu(me);
	
	if nRes == 0 and szMsg then
		Dialog:Say(szMsg);
		return;
	end
	
	local szMsg = string.format("Trong tháng này ngươi thu thập được <color=green>%d/%d<color> thẻ, ngươi có muốn đổi lấy <color=green>phần thưởng<color> căn cứ vào xếp hạng tích lũy của ngươi?",
		XoyoGame.XoyoChallenge:GetGatheredCardNum(me), XoyoGame.XoyoChallenge:GetTotalCardNum()
	);
	
	Dialog:OpenGift(szMsg, nil, {self.CallbackHandUpXoyolu, self});
end

function tbXiaoFei:CallbackHandUpXoyolu(tbItems)
	local nRes, szMsg = XoyoGame.XoyoChallenge:HandUpXoyolu(me, tbItems);
	if szMsg then
		Dialog:Say(szMsg);
	end
end

function tbXiaoFei:HandUpItem()
	local nRes, szMsg = XoyoGame.XoyoChallenge:CanHandUpItemForCard(me);
	if nRes == 0 and szMsg then
		Dialog:Say(szMsg);
		return;
	end
	
	Dialog:OpenGift(XoyoGame.XoyoChallenge:ItemForCardDesc(), nil, {self.CallbackHandUpItem, self});
end

function tbXiaoFei:CallbackHandUpItem(tbItems)
	local nRes, szMsg = XoyoGame.XoyoChallenge:HandUpItemForCard(me, tbItems);
	if szMsg then
		Dialog:Say(szMsg);
	end
end

function tbXiaoFei:GetSpecialCard()
	local nRes, szMsg = XoyoGame.XoyoChallenge:CanGetSpecialCard(me);
	if nRes == 0 and szMsg then
		Dialog:Say(szMsg);
		return;
	end
	
	Dialog:OpenGift("Có thể dùng 1 trong các món bất kỳ: Huyết Ảnh Thương, Linh Thú Chiến Ngoa, Độn Giáp Linh Phù, Tử Tinh Huyễn Bội, Thất Thái Tiên Đơn để đổi Thẻ đặc biệt, 1 món đổi 1 thẻ, mỗi ngày tối đa 2 thẻ.",
	nil, {self.CallbackGetSpecialCard, self});
end

function tbXiaoFei:CallbackGetSpecialCard(tbItems)
	local nRes, szMsg = XoyoGame.XoyoChallenge:GetSpecialCard(me, tbItems);
	if szMsg then
		Dialog:Say(szMsg);
	end
end

function tbXiaoFei:GetAward()
	local nRes, szMsg = XoyoGame.XoyoChallenge:GetAward(me);
	if szMsg then
		Dialog:Say(szMsg);
	end
end

--?pl DoScript("\\script\\mission\\xoyogame\\npc\\xiaofei.lua")