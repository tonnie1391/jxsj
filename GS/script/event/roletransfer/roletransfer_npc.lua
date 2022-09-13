-- 文件名　：roletransfer_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-07-28 09:33:24
-- 功能    ：转移官员
local tbNpc = Npc:GetClass("roletransfer");

function tbNpc:OnDialog(nFlag)
	local szMsg = [[江涵秋影雁初飞，与客闲情上翠微，
	陌野粮川收锦色，空山云岫染残辉。
	
	好一处优美的灵山顶，您是否要离开这里？
	]]			
	local tbOpt = {{"离开", self.BuyItem, self},
		{"我还想欣赏此番美景"}};
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbNpc:BuyItem(nFlag)
	local szMsg = "正所谓山上容易下山难，要安全离开这里需要老身的神仙绳（15000金币），您是否要购买并使用？";
	local tbOpt = {{"购买", self.BuyItem, self, 1},
		{"Để ta suy nghĩ thêm"}};
	if not nFlag then
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	if me.nCoin < SpecialEvent.tbRoleTransfer.nCancelApplyCoin then
		Dialog:Say("您的金币不足！", {{"我知道啦"}});
		return;
	end
	if me.CountFreeBagCell() <= 0 then
		Dialog:Say("需要一格背包空间。", {{"我知道啦"}});
		return;
	end
	me.ApplyAutoBuyAndUse(SpecialEvent.tbRoleTransfer.nWairListIdEx, 1, 1);
	me.NewWorld(29, 1628, 3952);
	me.Msg("您已经安全下了灵山顶，尽情享受剑侠世界的江湖儿女情怀吧。");
	Dialog:SendBlackBoardMsg(me, "您已经安全下了灵山顶，尽情享受剑侠世界的江湖儿女情怀吧。");	
	Player:SendMsgToKinOrTong(me, "下了灵山顶，开始了崭新的剑侠世界之旅，请周知。", 1);
	Player:SendMsgToKinOrTong(me, "下了灵山顶，开始了崭新的剑侠世界之旅，请周知。", 0);
	me.SendMsgToFriend("Hảo hữu ["..me.szName.."]下了灵山顶，开始了崭新的剑侠世界之旅，请周知。");
	Dbg:WriteLog(me.szAccount, me.szName, "上交转移资格证获释");
end
