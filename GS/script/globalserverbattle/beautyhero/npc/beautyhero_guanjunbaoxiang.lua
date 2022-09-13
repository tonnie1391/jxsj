-- 文件名  : beautyhero_baoxiang.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-27 12:13:59
-- 描述    : 
local tbNpc = Npc:GetClass("beautyhero_guanjunbaoxiang");
tbNpc.TIME_INTERVER = 3;

function tbNpc:OnDialog()	
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
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不够。");
		return 0;
	end	

	pNpc.Delete();	
	if GLOBAL_AGENT	then
		BeautyHero:AddGlobalRestAward(me.nId,BeautyHero.COIN_BOX, me);
	else
		local pItem = me.AddItem(unpack(BeautyHero.ITEM_BAOXIANG));
		if pItem then
			pItem.Bind(1);
		end
	end
end

