
--帮会金条
--zhengyuhua
--2009.01.16


local tbItem = Item:GetClass("tongfunditem")
tbItem.ExReturnBindCoin = 0;	--返还获得银两的百分比绑定金币
function tbItem:OnUse()
	local nMoney = it.GetExtParam(1);
	if me.dwTongId == 0 then
		me.Msg("您没有帮会，不能使用该道具！")
		return 0;
	end
	local pTong = KTong.GetTong(me.dwTongId)
	if not pTong then
		return 0;
	end
	if nMoney + pTong.GetBuildFund() > Tong.MAX_BUILD_FUND then
		me.Msg("您的帮会建设资金将要超过存款上限，无法再增加帮会建设资金。")
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	if self.ExReturnBindCoin > 0 then
		me.AddBindCoin(math.floor(self.ExReturnBindCoin * nMoney / 1000), Player.emKBINDCOIN_ADD_TONG_JINTIAO);
	end
	Dbg:WriteLog("tongfunditem", me.szName, me.szAccount, nMoney, nKinId, nMemberId);
	PlayerHonor:AddConsumeValue(me, it.nValue, "tongfunditem");			-- 累加消耗型财富
	GCExcute{"Tong:AddBuildFund_GC", me.dwTongId, nKinId, nMemberId, nMoney, 0.8, 1, 0};
	return 1;
end