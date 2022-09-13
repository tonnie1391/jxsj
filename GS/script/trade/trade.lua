
if (MODULE_GAMECLIENT) then

function Trade:Request(pNpc, bCancel)
	self:SetTradeClientNpc(me, pNpc);
	CoreEventNotify(UiNotify.emCOREEVENT_TRADE_REQUEST, bCancel);
end

function Trade:Response(pNpc)
	self:SetTradeClientNpc(me, pNpc);
	CoreEventNotify(UiNotify.emCOREEVENT_TRADE_RESPONSE);
end

function Trade:Trading(pNpc, nFaction)
	self:SetTradeClientNpc(me, pNpc);
	CoreEventNotify(UiNotify.emCOREEVENT_TRADE_TRADING, nFaction);
end

function Trade:GetTradeClientNpc(pPlayer)
	if (not pPlayer) then
		return;
	end
	local tbTrade = pPlayer.GetPlayerTempTable().tbTrade;
	if (not tbTrade) then
		return;
	end
	return tbTrade.pNpc;
end

function Trade:SetTradeClientNpc(pPlayer, pNpc)
	if (not pPlayer) then
		return;
	end
	local tbTemp = pPlayer.GetPlayerTempTable();
	if not tbTemp.tbTrade then
		tbTemp.tbTrade = {};
	end
	local tbTrade = tbTemp.tbTrade;
	tbTrade.pNpc = pNpc;
end

end	-- if (MODULE_GAMECLIENT) then
