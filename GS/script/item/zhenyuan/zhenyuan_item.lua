
local tbItem = Item:GetClass("zhenyuan_tie");

tbItem.tbIndex = {
	[1] = 1,
	[2] = 2,
}

tbItem.tbADVLevelNpc = {
	[4665] = 193,	--宝玉
	[6917] = 193,	--宝玉
	[6727] = 193,	--宝玉
	[6729] = 193,	--宝玉
	[6803] = 241,	--叶静
	[6916] = 241,	--叶静
	[3316] = 241,	--叶静
	[6728] = 241,	--叶静
	[6895] = 182,	--夏小倩
	[3244] = 182,	--夏小倩
	[6725] = 182,	--夏小倩
	[4666] = 194,	--莺莺
	[6910] = 194,	--莺莺
	[3227] = 177,	--紫苑
	[6898] = 177,	--紫苑
	[6726] = 177,	--紫苑
	[7157] = 177,	--紫苑
	[7158] = 177,	--紫苑
	[3241] = 181,	--木超
	[6897] = 181,	--木超
	[7226] = 181,	--木超
	[3228] = 178,	--秦仲
	[6896] = 178,	--秦仲
	}

tbItem.tbHunDunZhenyuan = {{1,24,8,1},{1,24,9,1},{1,24,10,1},{1,24,11,1}};

function tbItem:OnUse(nParam)
	local dwId = nParam;
	
	local pNpc = KNpc.GetById(dwId);
	me.Msg(""..dwId)
	if dwId == 0 or not pNpc then
		me.Msg("Hãy chọn 1 NPC rồi dùng đạo cụ này!");
		return 0;
	end
	local nPartnerId = self.tbADVLevelNpc[pNpc.nTemplateId];
	local pItem = nil;
	local nType = 0;
	if nPartnerId then
		nType = 2;
		local szNpcName = pNpc.szName;
		local tbSkillCountRate = Partner.tbSkillRule[4];
		if not tbSkillCountRate then
			return;		-- 给定同伴类型没有对应的配置
		end
		local nCountAll = Partner:RandomSkillCount(tbSkillCountRate, 4);	
		pItem = Item.tbZhenYuan:Generate({nPartnerId, nCountAll});
		if pItem and me.GetTeamId() then
			KTeam.Msg2Team(me.nTeamId, string.format("Đồng đội <color=yellow>%s<color> đã ngưng tụ <color=yellow>%s<color> thành Chân nguyên.", me.szName, szNpcName));
		end
	else
		nType = 1;
		local tbGDPL = self.tbHunDunZhenyuan[MathRandom(#self.tbHunDunZhenyuan)];
		local tbGenInfo = {};		-- 要生成道具的GenInfo
		Item.tbZhenYuan:GenTemplateId(tbGenInfo, 8);			-- 模板ID
		Item.tbZhenYuan:GenLevel(tbGenInfo, 1);				-- 初始等级，0
		Item.tbZhenYuan:GenCurExp(tbGenInfo, 0);				-- 初始经验，0
		Item.tbZhenYuan:GenEquiped(tbGenInfo, 0);				-- 初始未装备过
		local tbPotenLevel = {MathRandom(2), MathRandom(2),MathRandom(2),MathRandom(2)}
		for i, nStarLevel in ipairs(tbPotenLevel) do
			local szFun = "GenAttribPotential"..i;
			Item.tbZhenYuan[szFun](Item.tbZhenYuan, tbGenInfo, nStarLevel);	-- 各属性资质的价值量星级
		end
		Item.tbZhenYuan:GenPotenRateTemp(tbGenInfo, 8);	-- 属性资质分配模板
		pItem = me.AddItem(tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4], 0, 0, 0, tbGenInfo);
	end
	if pItem then
		pNpc.DieWithoutPunish();
		StatLog:WriteStatLog("stat_info", "zhenyuan", "get", me.nId,
		string.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", pItem.szName, pItem.szGUID,
				Item.tbZhenYuan:GetLevel(pItem),
				Item.tbZhenYuan:GetZhenYuanValue(pItem), Item.tbZhenYuan:GetAttribMagicId(pItem, 1),
				Item.tbZhenYuan:GetAttribPotential1(pItem), Item.tbZhenYuan:GetAttribMagicId(pItem, 2),
				Item.tbZhenYuan:GetAttribPotential2(pItem), Item.tbZhenYuan:GetAttribMagicId(pItem, 3),
				Item.tbZhenYuan:GetAttribPotential3(pItem), Item.tbZhenYuan:GetAttribMagicId(pItem, 4),
				Item.tbZhenYuan:GetAttribPotential4(pItem), nType));
		return 1;
	end
	return 0;
end 

function tbItem:CheckUsable(nParam)
	me.Msg(""..nParam)
	if (Item.tbZhenYuan.bOpen ~= 1) then
		Dialog:Say("Hiện tại hoạt động Chân nguyên đã kết thúc, không thể sử dụng thẻ!");
		return 0;
	end
	
	if MODULE_GAMECLIENT then
		local pSelectNpc = me.GetSelectNpc();
		if not pSelectNpc then
			me.Msg("Hãy chọn 1 NPC rồi dùng đạo cụ này!");
			return 0;
		end
		local nLevel = self.tbIndex[it.nLevel];
		local nRes, varMsg = Item.tbZhenYuan:TryToPersuade(me, pSelectNpc, nLevel);
		if nRes == 0 then
			me.Msg(varMsg);		-- 不能说服，返回错误信息
			UiManager:OpenWindow("UI_INFOBOARD", varMsg);
			return 0;
		end		
	elseif MODULE_GAMESERVER then
		if not nParam or nParam == 0 then
			me.Msg("Hãy chọn 1 NPC rồi dùng đạo cụ này!");
			return 0;
		end
		
		local pNpc = KNpc.GetById(nParam);
		if not pNpc then
			return 0;
		end
		
		local nLevel = self.tbIndex[it.nLevel];
		local nRes, varMsg = Item.tbZhenYuan:TryToPersuade(me, pNpc, nLevel);
		if nRes == 0 then
			me.Msg(varMsg);		-- 不能说服，返回错误信息
			Dialog:SendBlackBoardMsg(me, varMsg)
			return 0;
		end
	end
	
	return 1;
end

function tbItem:OnClientUse()
	local pSelectNpc = me.GetSelectNpc();
	if not pSelectNpc then
		return 0;
	end

	return pSelectNpc.dwId;
end
