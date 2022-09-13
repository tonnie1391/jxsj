local tbItem = Item:GetClass("xiaoxue");

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};
SpecialEvent.Xmas2008.XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman or {};
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;

function tbItem:OnUse(nNpcId)
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nDate < XmasSnowman.EVENT_START  then
		meMsg("活动还没开始呢");
		return;
	end
	
	if nDate > XmasSnowman.EVENT_END then
		me.Msg("活动已经结束");
		return;
	end	
	
	if nNpcId == 0 then
		me.Msg("要选中雪人才能使用哦");
		return;
	end
	local pNpc = self:Check(nNpcId);
	if pNpc == 0 then
		me.Msg("要选中雪人才能使用哦");
		return;
	end
	
	local tbData = pNpc.GetTempTable("Npc").tbData;
	if not tbData then
		print("not npc");
		return;
	end 
	
	local nMapId, nX, nY = pNpc.GetWorldPos();
	local _, nX2, nY2 = me.GetWorldPos();
	local nDistance = (nX2 - nX) * (nX2 - nX) + (nY2 - nY) * (nY2 - nY);
	if nDistance > XmasSnowman.SNOWMAN_DISTANCE then
		me.Msg("要靠近雪人才能使用哦");
		return;
	end		

	local nCount = tbData.nCount;
	if  not XmasSnowman.SNOWMAN_LEVEL[tbData.nLevel] or XmasSnowman.SNOWMAN_LEVEL[tbData.nLevel].nCount == 0 then
		Dialog:SendBlackBoardMsg(me, "你成功堆了一次雪人，他似乎变大了些");
		pNpc.CastSkill(XmasSnowman.SNOWMAN_SKILL, 1, nX, nY);		
		self:GetAward();		
		return 1;
	end
			
	if tbData.nCount + 1 >= XmasSnowman.SNOWMAN_LEVEL[tbData.nLevel].nCount then	
		XmasSnowman.tbSnowmanMgr[tbData.nIndex] = nil;	
		tbData.nLevel = tbData.nLevel + 1;
		tbData.nCount = 0;
		local pNpc2 = KNpc.Add2(XmasSnowman.SNOWMAN_LEVEL[tbData.nLevel].nClassId, 100, -1, nMapId, nX, nY);
		if pNpc2 then
			XmasSnowman.tbSnowmanMgr[tbData.nIndex] =  pNpc2.dwId;
			pNpc2.GetTempTable("Npc").tbData = tbData;
		end
		pNpc.Delete();
		
	else
		tbData.nCount = tbData.nCount + 1;
		pNpc.GetTempTable("Npc").tbData = tbData;
	end
	me.CastSkill(XmasSnowman.SNOWMAN_SKILL, 1, nX * 32, nY * 32);
	Dialog:SendBlackBoardMsg(me, "你成功堆了一次雪人，他似乎变大了些");
	self:GetAward();
	return 1;
end	

function tbItem:GetAward()
	if me.nLevel < XmasSnowman.AWARD_LEVEL_LIMIT then
		me.Msg("您的修为不到60级，没得到福袋！");
		return;
	end
	
	local nPrestige = Player.tbBuyJingHuo:GetTodayPrestige();
	if nPrestige <= 0 then
		nPrestige = XmasSnowman.AWARD_JINGHUO_LIMIT;
	end
	
	if me.nPrestige < nPrestige then
		me.Msg("您的江湖威望没达到今天购买福利精活的威望值，不能得到福袋奖励！");
		return;
	end
	
	if me.CountFreeBagCell() < 1 then
		me.Msg("您的包裹不足，不能获得奖励");
		return;
	end	
	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(XmasSnowman.TSKG_GROUP, XmasSnowman.TSK_AWARD_DATE) ~= nDate then
		me.SetTask(XmasSnowman.TSKG_GROUP, XmasSnowman.TSK_AWARD_DATE, nDate);
		me.SetTask(XmasSnowman.TSKG_GROUP, XmasSnowman.TSK_AWARD_COUNT, 1);
		local pItem = me.AddItem(unpack(XmasSnowman.FUDAI_ID));
		if pItem then
			pItem.Bind(1);
		end
		return;
	end
	local nCount = me.GetTask(XmasSnowman.TSKG_GROUP, XmasSnowman.TSK_AWARD_COUNT);
	if nCount >= XmasSnowman.AWARD_COUNT then
		return; 
	end
	
	me.SetTask(XmasSnowman.TSKG_GROUP, XmasSnowman.TSK_AWARD_COUNT, nCount + 1);
	local pItem = me.AddItem(unpack(XmasSnowman.FUDAI_ID));
	if pItem then
		pItem.Bind(1);
	end
end

function tbItem:OnClientUse()
	local pNpc = me.GetSelectNpc();
	if not pNpc then
		return 0;
	end
	return pNpc.dwId;
end

function tbItem:Check(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);	
	if not pNpc then
		return 0;
	end	 	
	if pNpc.nKind == 3 then
		if  pNpc.nTemplateId >= XmasSnowman.SNOWMAN_LEVEL[1].nClassId and pNpc.nTemplateId <= XmasSnowman.SNOWMAN_LEVEL[#XmasSnowman.SNOWMAN_LEVEL].nClassId then
			return pNpc;	
		end
	end
	return 0;
end
