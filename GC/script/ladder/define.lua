-- 文件名　：define.lua
-- 创建者　：zhouchenfei
-- 创建时间：2008-11-13 16:26:06


if not Ladder then --调试需要
	Ladder = {};
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..");
end

local preEnv = _G;	--保存旧的环境
setfenv(1, Ladder);	--设置当前环境为Ladder

-- 排行榜大类
LADDER_CLASS_WLDH				= 1;	-- 其他排行榜类
LADDER_CLASS_LADDER				= 2;	-- 其他排行榜类
LADDER_CLASS_WLLS				= 3;	-- 联赛类
LADDER_CLASS_WULIN				= 4;	-- 武林荣誉
LADDER_CLASS_LINGXIU			= 5;	-- 领袖荣誉
LADDER_CLASS_MONEY				= 6;	-- 财富
LADDER_CLASS_FIGHTPOWER			= 7;	-- 战斗力

-- 排行榜小类
LADDER_TYPE_LADDER_LEVEL			= 1;	-- 等级排行榜小类
LADDER_TYPE_LADDER_ACTION			= 2;	-- 活动排行榜
LADDER_TYPE_LADDER_EVENTPLANT		= 3;
LADDER_TYPE_LADDER_KINREPUTE		= 4;

LADDER_TYPE_LADDER_ACTION_SPRING			= 1;
LADDER_TYPE_LADDER_ACTION_XOYOGAME			= 2;
LADDER_TYPE_LADDER_ACTION_DRAGONBOAT		= 3;	-- 龙舟排行榜
LADDER_TYPE_LADDER_ACTION_WEIWANG			= 4;	-- 江湖威望
LADDER_TYPE_LADDER_ACTION_PRETTYGIRL		= 5;	-- 美女大选排行榜
LADDER_TYPE_LADDER_ACTION_KAIMENTASK		= 6;	-- 霸主之印排行榜
LADDER_TYPE_LADDER_ACTION_BEAUTYHERO		= 8;	-- 巾帼英雄排行榜
LADDER_TYPE_LADDER_ACTION_LADDER1			= 9;	-- 排行榜
LADDER_TYPE_LADDER_ACTION_LADDER2			= 10;	-- 排行榜
LADDER_TYPE_LADDER_ACTION_LADDER3			= 11;	-- 赤夜飞翎收集榜

LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM		= 1;
LADDER_TYPE_LADDER_EVENTPLANT_PRETEAM		= 2;

LADDER_TYPE_WLLS_CUR_PRIMAY		= 1;	-- 当届联赛初级榜 
LADDER_TYPE_WLLS_CUR_ADV 		= 2;	-- 当届联赛高级榜
LADDER_TYPE_WLLS_HONOR			= 3;	-- 荣誉榜
LADDER_TYPE_WLLS_LAST_PRIMAY		= 4;	-- 上届联赛初级榜
LADDER_TYPE_WLLS_LAST_PRIMAY		= 5;	-- 上届联赛高级榜

LADDER_TYPE_WLDH_FACTION				= 1;	-- 武林大会门派 
LADDER_TYPE_WLDH_DOUBLE 				= 2;	-- 武林大会双人赛
LADDER_TYPE_WLDH_THREE					= 3;	-- 武林大会三人赛
LADDER_TYPE_WLDH_SERIESFIVE				= 4;	-- 武林大会五行五人赛
LADDER_TYPE_WLDH_RAID					= 5;	-- 武林大会团体赛

LADDER_TYPE_WULIN_HONOR_WULIN			= 1;	-- 武林荣誉小类
LADDER_TYPE_WULIN_HONOR_FACTION			= 2;	-- 门派荣誉小类
LADDER_TYPE_WULIN_HONOR_WLLS			= 3;	-- 联赛荣誉小类
LADDER_TYPE_WULIN_HONOR_SONGJINBATTLE	= 4;	-- 宋金荣誉小类

LADDER_TYPE_LINGXIU_HONOR_LINGXIU		= 1;	-- 领袖荣誉小类
LADDER_TYPE_LINGXIU_HONOR_AREABATTLE	= 2;	-- 区域争夺战荣誉小类
LADDER_TYPE_LINGXIU_HONOR_BAIHUTANG		= 3;	-- 白虎堂荣誉小类

LADDER_TYPE_MONEY_HONOR_MONEY		= 1;	-- 财富荣誉小类

LADDER_TYPE_FIGHTPOWER_TOTAL		= 1;		-- 总战斗力
LADDER_TYPE_FIGHTPOWER_ACHIVEMENT	= 2;		-- 成就
	

SEARCHTYPE_PLAYERNAME			= 1;		-- 排行榜搜索类型搜索人名
SEARCHTYPE_WLLSTEAMNAME			= 2;		-- 排行榜搜索类型搜索战队名
SEARCHTYPE_KINNAME				= 3;		-- 排行榜搜索类型搜索家族名

preEnv.setfenv(1, preEnv);	--恢复全局环境


Ladder.tbFacContext = {
		[Env.FACTION_ID_NOFACTION]	= "Thế Giới";
		[Env.FACTION_ID_SHAOLIN]	= "Thiếu Lâm";
		[Env.FACTION_ID_TIANWANG]	= "Thiên Vương";
		[Env.FACTION_ID_TANGMEN]	= "Đường Môn";
		[Env.FACTION_ID_WUDU]		= "Ngũ Độc";
		[Env.FACTION_ID_EMEI]		= "Nga My";
		[Env.FACTION_ID_CUIYAN]		= "Thúy Yên";
		[Env.FACTION_ID_GAIBANG]	= "Cái Bang";
		[Env.FACTION_ID_TIANREN]	= "Thiên Nhẫn";
		[Env.FACTION_ID_WUDANG]		= "Võ Đang";
		[Env.FACTION_ID_KUNLUN]		= "Côn Lôn";
		[Env.FACTION_ID_MINGJIAO]	= "Minh Giáo";
		[Env.FACTION_ID_DALIDUANSHI] = "Đoàn Thị";
		[Env.FACTION_ID_GUMU]		= "Cổ Mộ";
	};
	