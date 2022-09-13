-- 文件名　：dts_money.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-28 09:43:52
-- 描  述  ：大逃杀货币

local tbMoney = Item:GetClass("faguangtongqian")
tbMoney.szInfo = "Tặng cho đồng đội!"


function tbMoney:OnUse()	
--	local tbOpt = {			
--			{"交易给队友",	self.SelectPlayer, self},	
--			{"Đóng lại"},
--	};	
--			
--	Dialog:Say(self.szInfo,tbOpt);
--	
	self:SelectPlayer();
	return 0;
end;
function tbMoney:SelectPlayer()		
	local tbOpt = {};
	local tbDialog = {};
	if me.nTeamId == 0 then
		return 0;
	end
	
	if DaTaoSha:IsPlayerDeath(me) == 1 then
		me.Msg("Đang trọng thương, không thể giao dịch với đồng đội!");
		return 0;
	end
	
	local tbPlayerIdList = KTeam.GetTeamMemberList(me.nTeamId);
	for _, nPlayerId in pairs(tbPlayerIdList) do			
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if  pPlayer and pPlayer.szName ~= me.szName and DaTaoSha:IsPlayerDeath(pPlayer) == 0 then
			table.insert(tbDialog,{pPlayer.szName,self.Trade,self,pPlayer.nId});
		end
	end
	table.insert(tbDialog,{"Đóng lại"});
	tbOpt = Lib:MergeTable( tbOpt,tbDialog);		
	Dialog:Say(self.szInfo,tbOpt);	
	return 0;	
end

function tbMoney:Trade(nId)
	local nMoneyNum = me.GetItemCountInBags(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4],nil, -1);
	if nMoneyNum > 0 then
		Dialog:AskNumber("Hãy nhập số lượng", nMoneyNum, self.TradeEx, self, nId);
	else
		me.Msg("Không có đủ vật phẩm!");
	end	
end

function tbMoney:TradeEx(nPlayerId, nCount)
	if nCount <= 0 then
		return 0;
	end
	
	local nMoneyNum = me.GetItemCountInBags(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4],nil, -1);
	if nMoneyNum < nCount then
		me.Msg("Không có đủ vật phẩm!");
		return 0;
	end

	if DaTaoSha:IsPlayerDeath(me) == 1 then
		me.Msg("Đang trọng thương, không thể giao dịch với đồng đội!");
		return 0;
	end	
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if  pPlayer  then	
		if DaTaoSha:IsPlayerDeath(pPlayer) == 1 then
			me.Msg("Đồng đội đang trọng thương, không thể giao dịch!");
			return 0;
		end	
		local nAddCount = pPlayer.AddStackItem(DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4],nil, nCount);
		if nAddCount == 0 then 
			me.Msg("Hành trang của đối phương đã đầy!");
			return;
		end		
		local szMsg = string.format("Đồng đội <color=yellow>%s<color> giao dịch cho <color=yellow>%s<color> %s Hàn Vũ Phù Thạch!", me.szName, pPlayer.szName, nAddCount);
		KTeam.Msg2Team(me.nTeamId, szMsg);
		me.ConsumeItemInBags2(nAddCount, DaTaoSha.MONEY[1], DaTaoSha.MONEY[2], DaTaoSha.MONEY[3], DaTaoSha.MONEY[4], nil, -1);
	end
end
