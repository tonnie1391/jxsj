Require("\\script\\event\\collectcard\\define.lua")

local tbItem = Item:GetClass("guoqing_shoucang");
local CollectCard = SpecialEvent.CollectCard;

function tbItem:GetTip(nState)
	local nEnter = 0;
	local szTipTemp = "";
	local nCollect = 0;
	for _, tbTask in pairs(CollectCard.TASK_CARD_ID) do
		local n = 10 - string.len(tbTask[2]);
		local szBlank = "";
		for i=1, n do
			szBlank = szBlank .. " ";
		end
		if me.GetTask(CollectCard.TASK_GROUP_ID, tbTask[1]) == 1 then
			szTipTemp = szTipTemp .. string.format("<color=yellow>%s<color>%s",tbTask[2],szBlank);
			nCollect = nCollect + 1;
		else
			szTipTemp = szTipTemp .. string.format("<color=gray>%s<color>%s",tbTask[2],szBlank);
		end
		nEnter = nEnter + 1;
		if math.mod(nEnter, 4) == 0 then
			szTipTemp = szTipTemp .. "";
		end
		
	end
	local nAwarId, szDesc, nCollect, nOpenMaxCard = CollectCard:GetAward_CardBag_InFor();
	local szLuckyCard = "暂无";
	local nLuckyId = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM);
	if CollectCard.TASK_CARD_ID[nLuckyId] then
		szLuckyCard = CollectCard.TASK_CARD_ID[nLuckyId][2];
	end
	
	local szTip = string.format("今天幸运卡：<color=gold>%s<color><enter>已鉴定卡片数：%s张<enter>已收集的卡片(%s/56)：<enter>%s", 
		szLuckyCard, nOpenMaxCard, nCollect, szTipTemp);

	return szTip;
end

function tbItem:OnUse()
	--local nAwarId, szDesc, nCollect, nOpenMaxCard = CollectCard:GetAward_CardBag_InFor()
	--if nAwarId < 0 then
	--	szDesc = "暂无奖励";
	--end
	--
	--local szTip = string.format("<enter>国庆活动期间，您已经鉴定过了<color=yellow>%s张<color>活动卡（总共可以鉴定<color=yellow>50张<color>），收藏到了<color=yellow>%s张<color>活动卡。根据您目前的参与情况，可以获得如下奖励：\n\n<color=yellow>%s<color>\n\n", nOpenMaxCard, nCollect,szDesc);
	--if nCollect < 28 then
	--	szTip = szTip .. "请继续加油";
	--end
	--local tbOpt = {{"Xác nhận"}};
	--Dialog:Say(szTip, tbOpt);
	return 0;
end

