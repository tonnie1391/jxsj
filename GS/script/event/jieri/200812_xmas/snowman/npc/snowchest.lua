-- 文件名　：snowball.lua
-- 创建者　：zounan
-- 创建时间：2009-11-24 14:35:26
-- 描  述  ：
local tbNpc = Npc:GetClass("snowchest");

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};
SpecialEvent.Xmas2008.XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman or {};
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;

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
	GeneralProcess:StartProcess("果果采集中..." , XmasSnowman.CHEST_CATCHTIME * Env.GAME_FPS ,  {self.CatchSnow , self,him.dwId} , nil , tbEvent);	
end

function tbNpc:CatchSnow(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	


	if me.CountFreeBagCell() < 1 then
		me.Msg("您的包裹空间不足");
		return;
	end	

	local pItem = me.AddItem(unpack(XmasSnowman.BOX_ID));
	if pItem then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, 30*24*60, 0);
			--增加技能状态
		me.AddSkillState(385, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(386, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(387, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		--幸运值880, 4,，打怪经验879, 5
		me.AddSkillState(880, 4, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
		me.AddSkillState(879, 8, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	end
	pNpc.Delete();
end
