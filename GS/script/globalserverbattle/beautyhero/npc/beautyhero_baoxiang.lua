-- 文件名  : beautyhero_baoxiang.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-27 12:13:59
-- 描述    : 
local tbNpc = Npc:GetClass("beautyhero_baoxiang");
tbNpc.TIME_INTERVER = 3;

function tbNpc:OnDialog()
	
	local nCount = tonumber(me.GetItemCountInBags(unpack(BeautyHero.ITEM_CARD))) or 0;
	if nCount > 0 then
		Dialog:Say("你身上已经有卡片了，不能再有了。");
		return;
	end	
		
	-- 启动进度条
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đang mở", self.TIME_INTERVER * Env.GAME_FPS, {self.OnGetCard, self,him.dwId}, nil, tbBreakEvent);
end

function tbNpc:OnGetCard(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local nCount = tonumber(me.GetItemCountInBags(unpack(BeautyHero.ITEM_CARD))) or 0;
	if nCount > 0 then
		Dialog:Say("你身上已经有卡片了 不能再有了");
		return;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不够。");
		return 0;
	end	
	
	
	local nMapId = pNpc.GetWorldPos();
	local tbMissionInfo = BeautyHero:GetMissionInfo(nMapId);
	if not tbMissionInfo then	
		return;
	end	
	local tbTmp = {};
	for i = 1, 16 do
		if tbMissionInfo.tb16Player[i] then
			if tbMissionInfo.tb16Player[i].nWinCount >= (tbMissionInfo.nEliminationCount or 0) then
				table.insert(tbTmp,tbMissionInfo.tb16Player[i].szName);	
			end	 
		end
	end		
	
	if #tbTmp == 0 then
		print("[ERR]beautyhero_baoxiang .OnGetCard");
		return;
	end
		
	local pItem = me.AddItem(unpack(BeautyHero.ITEM_CARD));
	if pItem then
		local nRandom = MathRandom(#tbTmp);
		pItem.Bind(1);
		pItem.SetCustom(2, tbTmp[nRandom]);
		pItem.Sync();
	end
	pNpc.Delete();	
end

