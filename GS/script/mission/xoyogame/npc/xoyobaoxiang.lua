
local tbNpc = Npc:GetClass("xoyobaoxiang")

tbNpc.DROP_RATE_FILE 	= "\\setting\\xoyogame\\npc_baoxiang.txt";
tbNpc.TAKE_TIME			= 10;

function tbNpc:OnDialog()
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	
	-- ½ø¶ÈÌõ
	GeneralProcess:StartProcess(
		"", 
		self.TAKE_TIME * Env.GAME_FPS, 
		{self.CompleteProcess, self, him.dwId, me.nId}, 
		nil, 
		tbEvent
	);
end

function tbNpc:CompleteProcess(nNpcId, nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nNpcTempletId = pNpc.nTemplateId;
	if not self.tbItemList[nNpcTempletId] then
		return 0;
	end
	
	for _, tbItem in pairs(self.tbItemList[nNpcTempletId].tbItem) do
		if tbItem.nRate == 0 then
			pPlayer.AddItem(unpack(tbItem.tbItem));
			break;
		end
	end
	
	local nCurRate = MathRandom(1, self.tbItemList[nNpcTempletId].nMaxRate);
	local nSum = 0;
	for _, tbItem in pairs(self.tbItemList[nNpcTempletId].tbItem) do
		nSum = nSum + tbItem.nRate;
		if tbItem.nRate > 0 and nSum > nCurRate then
			pPlayer.AddItem(unpack(tbItem.tbItem));
			break;
		end
	end
	
	pNpc.Delete();
end

function tbNpc:LoadBaoXiangFlie()
	local tbFile = Lib:LoadTabFile(self.DROP_RATE_FILE);
	if not tbFile then
		return
	end
	self.tbItemList = {};
	
	for i, tbParam in ipairs(tbFile) do
		if i >= 2 then
			local nNpcId = tonumber(tbParam.NpcId) or 0;
			local nRate = tonumber(tbParam.Rate) or 0;
			local nItem_G = tonumber(tbParam.Item_G) or 0;
			local nItem_D = tonumber(tbParam.Item_D) or 0;
			local nItem_P = tonumber(tbParam.Item_P) or 0;
			local nItem_L = tonumber(tbParam.Item_L) or 0;
			self.tbItemList[nNpcId] = self.tbItemList[nNpcId] or {tbItem={}, nMaxRate=0};
			local tbItem = {};
			tbItem.nRate = nRate;
			tbItem.tbItem = {nItem_G, nItem_D, nItem_P, nItem_L};
			table.insert(self.tbItemList[nNpcId].tbItem, tbItem);
			if nRate > 0 then
				self.tbItemList[nNpcId].nMaxRate = self.tbItemList[nNpcId].nMaxRate + nRate;
			end
		end
	end
	
end

tbNpc:LoadBaoXiangFlie();