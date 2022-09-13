--
--

local tbNpc = Npc:GetClass("zhaokan_chuansong");

function tbNpc:OnDialog()
	--把入谷玩家的卡片分数重新放进排行榜
	local nTime = tonumber(GetLocalDate("%Y%m"));
	if nTime == 200906 and  me.GetTask(2050,41) == 200906 then --6月领过逍遥录才进榜
		local nPrevPoint = GetXoyoPointsByName(me.szName); -- 这个月的点数
		local nCurrPoint = XoyoGame.XoyoChallenge:GetTotalPoint(me);
		if nCurrPoint > nPrevPoint then
			PlayerHonor:SetPlayerXoyoPointsByName(me.szName, nCurrPoint);
		end
	end
	
	XoyoGame:JieYinRen();
end