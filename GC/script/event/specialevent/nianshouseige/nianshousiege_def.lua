-- 文件名　：nianshousiege_def.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-28 14:10:10
-- 描  述  ：

SpecialEvent.NianShouSiege = SpecialEvent.NianShouSiege or {};
local tbNianShouSiege = SpecialEvent.NianShouSiege or {};

tbNianShouSiege.IS_OPEN					= 1;	-- 系统开关

-- task id
tbNianShouSiege.TASK_GROUP_ID			= 2027;	-- 任务组ID
tbNianShouSiege.TASK_DAY_WIN_TIMES		= 190;	-- 当天累计打到年兽次数
tbNianShouSiege.TASK_LAST_WIN_DAY		= 191;	-- 最后一次打到年兽的时间
tbNianShouSiege.TASK_AWARD_COUNT		= 192;	-- 累计奖励次数

-- const
tbNianShouSiege.NPC_NIANSHOU_ID			= 7278;	-- 年兽id
tbNianShouSiege.NPC_BAIQIULING_ID		= 7287;	-- 活动白秋林
tbNianShouSiege.NPC_BAIQIULING_FIGHT_ID	= 7288;	-- 战斗白秋林

tbNianShouSiege.SKILL_HITNIANSHOU		= 16;	-- 攻击年兽技能
tbNianShouSiege.NIANSHOU_SKILL1			= 1078;	-- 年兽技能1 
tbNianShouSiege.NIANSHOU_SKILL2			= 1323;	-- 年兽技能1 
tbNianShouSiege.NIANSHOU_SKILL3			= 1137;	-- 年兽技能1 

tbNianShouSiege.MAX_DAY_WIN_TIMES		= 3;	-- 每天有效杀死年兽次数
tbNianShouSiege.MAX_BIANPAO_USE_RANGE	= 25;	-- 鞭炮使用的最大距离
tbNianShouSiege.MAX_AWARD_RANGE			= 45;	-- 领奖范围
tbNianShouSiege.MAX_BAOXIAO_COUNT		= 20;	-- 给予宝箱的最大个数
tbNianShouSiege.PLAYER_LEVEL_LIMIT		= 80;	-- 玩家等级限制
tbNianShouSiege.PLAYER_HIT_TIMES_LIMIT	= 1;	-- 玩家攻击多少次才能满足领奖条件
--tbNianShouSiege.NIANSHOU_MAX_LIFE		= 100;	-- 年兽最大血量
tbNianShouSiege.AWARD_COST_MONEY		= 10000;-- 领奖一次消耗银两
tbNianShouSiege.AWARD_GET_BINDMOENY		= 150000;--领奖一次获得绑银
tbNianShouSiege.PROTECT_BLOOD			= 20000;	-- 年兽未走到白秋林面前的保护血量
tbNianShouSiege.INTERVAL_CHAT			= 10 * 18;	-- 年兽喊话间隔


tbNianShouSiege.ITEM_XIANGZI_ID			= {18, 1, 1166, 1};	-- 年兽宝箱

tbNianShouSiege.PREPARE_TIME			= 5 * 60 * 18;	-- 提前公告时间
tbNianShouSiege.FIGHTING_TIME			= 5 * 60 * 18;	-- 年兽与白秋林战斗的时间

tbNianShouSiege.OPEN_DAY	= 20110128;	-- 开启时间
tbNianShouSiege.CLOSE_DAY	= 20110201;	-- 结束时间


tbNianShouSiege.NIANSHOU_BORN_POS	= {24, 1642, 3369}	-- 年兽出现地方

tbNianShouSiege.BAIQIULING_POS	={24, 1786, 3532}		-- 白秋林的位置

tbNianShouSiege.TB_ROUTE = "\\setting\\event\\specialevent\\nianshouseige\\fengxiang.txt";-- 年兽行进路径

-- 系统开关
function tbNianShouSiege:CheckIsOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.OPEN_DAY or nDate > self.CLOSE_DAY then
		return 0;
	end
	return self.IS_OPEN;
end


tbNianShouSiege.NIANSHOU_CHAT	=
{
	[1] = "哈哈哈哈哈哈哈",
};

tbNianShouSiege.MSG_NIANSHOU_DEATH	=
{
	[0] = "恭喜！年兽被击退了!",
	[1] = "恭喜！年兽被击退了，掉了很多宝贝！预计年兽13:45会再来，请做好防范！",
	[2] = "恭喜！年兽被击退了，掉了很多宝贝！预计年兽18:45会再来，请做好防范！",
	[3] = "恭喜！年兽被击退了，掉了很多宝贝！预计年兽19:45会再来，请做好防范！",
	[4] = "恭喜！年兽被击退了，掉了很多宝贝！预计年兽20:45会再来，请做好防范！",
	[5] = "恭喜！年兽被击退了，掉了很多宝贝！今日活动暂告一段落，明天请继续做好防范！",
	[6] = "恭喜！年兽被击退了！今年它不敢再来了！",
};

tbNianShouSiege.MSG_BAIQIULING_DEATH =
{
	[0] = "年兽将白秋琳击为重伤，众侠士不能获得任何奖励了！",
	[1] = "年兽将白秋琳击为重伤，众侠士不能获得任何奖励了，预计年兽13:45会再来，下次请召集更多人手来！",
	[2] = "年兽将白秋琳击为重伤，众侠士不能获得任何奖励了，预计年兽18:45会再来，下次请召集更多人手来！",
	[3] = "年兽将白秋琳击为重伤，众侠士不能获得任何奖励了，预计年兽19:45会再来，下次请召集更多人手来！",
	[4] = "年兽将白秋琳击为重伤，众侠士不能获得任何奖励了，预计年兽20:45会再来，下次请召集更多人手来！",
	[5] = "年兽将白秋琳击为重伤，众侠士不能获得任何奖励了，今日活动暂告一段落，明日请召集更多人手来！",
	[6] = "年兽回家休息了，今年它不会再来了！",
};

tbNianShouSiege.MSG_NIANSHOU_CHAT	= 
{
	[1] = "我就不告诉你我最怕鞭炮！",
	[2] = "吼~！吼~！凤翔这座城池很合我胃口~",
	[3] = "只要在我附近使用鞭炮，我就浑身不舒服！",
	[4] = "听说这里的特产商人那卖鞭炮！",
};