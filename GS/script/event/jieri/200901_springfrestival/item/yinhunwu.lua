--引魂雾，年兽
--sunduoliang
--2008.12.31

local tbItem = Item:GetClass("yinhunwu");	--引魂雾
local tbNpc  = Npc:GetClass("nianshou_callboss");	--年兽

tbItem.tbMsg = {
	"你等了半天，压根儿没看到什么野兽的影子！再试一次看看吧！",
	"秋姨说这野兽狡猾，要有耐心才行，先静静心再试试看！",
	"做事贵在坚持，我就不信这怪物不出来！",
	"看来诱出年兽也不是想像中那么难，看我怎么教训这孽畜！",
} 
tbItem.nDelay = 5 * Env.GAME_FPS;	--延时
tbItem.nNpcId = 3618;				--年兽Id
tbItem.nNpcLiveTime = 60 * 60 * Env.GAME_FPS		--年兽生存时间

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSecTime = Lib:GetDate2Time(Esport.SNOWFIGHT_STATE[3])
	it.SetTimeOut(0, nSecTime);
	return	{ };
end

-- 打断事件
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
}

function tbItem:OnUse()
	if me.nFightState == 0 then
		me.Msg("必须在野外地图才能使用。");
		return 0;
	end	
	if me.CountFreeBagCell() < 4 then
		local szAnnouce = "Hành trang không đủ ，请留出4格空间再试。";
		me.Msg(szAnnouce);
		return 0;
	end	
	GeneralProcess:StartProcess("引诱年兽中...", self.nDelay, {self.DoCallBoss, self, me.nId, it.dwId}, nil, tbEvent);
end

function tbItem:DoCallBoss(nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pItem   = KItem.GetObjById(nItemId);
	if not pPlayer or not pItem then
		return 0;
	end
	if MathRandom(1,100) > 25 then
		local nCount = pItem.GetGenInfo(1);
		if nCount > 2 then
			nCount = 2;
		else
			pItem.SetGenInfo(1, nCount + 1);
		end
		
		pPlayer.Msg(self.tbMsg[nCount + 1]);
		return 0;
	end
	pPlayer.Msg(self.tbMsg[4]);
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	if pPlayer.DelItem(pItem) == 1 then
		local pNpc = KNpc.Add2(self.nNpcId, pPlayer.nLevel, -1, nMapId, nPosX, nPosY);
		if pNpc then
			pNpc.SetLiveTime(self.nNpcLiveTime);
			pNpc.GetTempTable("Npc").nTimerId = Timer:Register(self.nNpcLiveTime, self.OnNpcTimeOut, self, pPlayer.nId, pNpc.dwId);
			Dialog:SendBlackBoardMsgTeam(pPlayer, "年兽：吼，我有神灵护体，你们这些小杂碎能奈我何", 1)
			for i=1, 4 do
				self:GetRandomItem(pPlayer);
			end
		end
	end
end

function tbItem:GetRandomItem(pPlayer)
	local nRateSum = 0;
	local nRate = MathRandom(1, 1000000);
	for _,tbItem in pairs(self.tbRandItemList) do
		nRateSum = nRateSum + tbItem.nRandRate;
		if nRate <= nRateSum then
			local pItem = pPlayer.AddItem(tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			if pItem then
				Dbg:WriteLog("引魂雾",  pPlayer.szName, string.format("随机获得物品一个%s", pItem.szName));
			end
			return 0;
		end
	end
end

function tbItem:OnNpcTimeOut(nPlayerId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
	if pNpc then
		pNpc.Delete();
	end
	
	if pPlayer then
		pPlayer.Msg("年兽：有古怪！小杂碎们难道要暗算我，不和你们耍了！(你召唤的年兽消失了！)");		
	end
	return 0;
end

function tbItem:LoadRandomItem()
	local tbSortItem = Lib:LoadTabFile("\\setting\\event\\manager\\2009_event\\springfestival\\droprate001_nianshou.txt");
	if not tbSortItem then
		return 0;
	end
	self.tbRandItemList = {};
	for nId, tbItem in pairs(tbSortItem) do
		self.tbRandItemList[nId] = {};
		self.tbRandItemList[nId].nGenre = tonumber(tbItem.Genre) or 0;
		self.tbRandItemList[nId].nDetail = tonumber(tbItem.Detail) or 0;
		self.tbRandItemList[nId].nParticular = tonumber(tbItem.Particular) or 0;
		self.tbRandItemList[nId].nLevel = tonumber(tbItem.Level) or 0;
		self.tbRandItemList[nId].nRandRate = tonumber(tbItem.RandRate) or 0;
		self.tbRandItemList[nId].szName = tbItem.Name;
	end
end

tbItem:LoadRandomItem()

function tbNpc:OnDeath(pNpcKiller)
	if him.GetTempTable("Npc").nTimerId then
		Timer:Close(him.GetTempTable("Npc").nTimerId);
	end
	local pPlayer = pNpcKiller.GetPlayer();
	if pPlayer then
		Dialog:SendBlackBoardMsgTeam(pPlayer, "年兽：呜~~~卑鄙~~~你们搞暗算，吾命休矣。", 1)
	end
end

