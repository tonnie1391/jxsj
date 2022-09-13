-- 文件名　：newbattle_def.lua
-- 创建者　：LQY
-- 创建时间：2012-07-18 14:28:20
-- 说	 明：配置
-- 不会害怕会明白，这坦白的未来

NewBattle.__DEBUG	=	nil;		--是否开启DEBUG

NewBattle.nNewBattle_Rand		= 0; 					-- 宋金战场出现新战场的概率百分比
NewBattle.BATTLE_STATES =  		--战场所有状态
{
	["CLOSED"] 	= 	1,
	["SIGNUP"] 	=	2,
	["FIGHT"]	=	3,
	["FINISH"]	=	4
};
NewBattle.tbNewBattleSeq	=
{
	[1] = {""},
	[2] = {""},
	[3] = {""},
	
};
NewBattle.OPEN_BATTLE =			-- 低中高新战场是否开启
{
	[1]	= 0,
	[2]	= 1,
	[3]	= 0,
};
NewBattle.BATTLE_NPCNAME = 		--野生NPC名字	
{
		["SHIBING"]		=	"Sĩ binh",
		["XIAOWEI"]		=	"Hiệu úy",
		["TONGLING"]	=	"Thống lĩnh",
		["FUJIANG"]		=	"Phó tướng",
};
NewBattle.BATTLE_NPCPOINT = 	--野生NPC分素
{
		["SHIBING"]		=	20,
		["XIAOWEI"]		=	40,
		["TONGLING"]	=	100,
		["FUJIANG"]		=	160,
};
NewBattle.BATTLE_NPCLEVEL = 	-- NPC强度等级
{
	[1] = 
	{
		["JIANTA"]		=	1,
		["PAOTAI"]		=	1,
		["ZHANCHE"]		=	1,
		["LONGMAI"]		=	1,
		["SHOUHUZHE"]	=	70,
		["ZHAOHUANSHI"]	=	70,
		["SHIBING"]		=	70,
		["XIAOWEI"]		=	75,
		["TONGLING"]	=	75,
		["FUJIANG"]		=	75,
	},
	[2] = 
	{
		["JIANTA"]		=	1,
		["PAOTAI"]		=	1,
		["ZHANCHE"]		=	1,
		["LONGMAI"]		=	1,
		["SHOUHUZHE"]	=	70,
		["ZHAOHUANSHI"]	=	30,
		["SHIBING"]		=	95,
		["XIAOWEI"]		=	100,
		["TONGLING"]	=	100,
		["FUJIANG"]		=	100,
	},
	[3] = 
	{
		["JIANTA"]		=	150,
		["PAOTAI"]		=	150,
		["ZHANCHE"]		=	150,
		["LONGMAI"]		=	150,
		["SHOUHUZHE"]	=	150,
		["ZHAOHUANSHI"]	=	150,
		["SHIBING"]		=	150,
		["XIAOWEI"]		=	150,
		["TONGLING"]	=	150,
		["FUJIANG"]		=	150,
	},
};
NewBattle.POWER_NUM =
{
	["XIA"] 	=	1,
	["MENG"]	=	2,
};
NewBattle.POWER_ENAME =
{
	[1] = "XIA",
	[2] = "MENG",
};
NewBattle.POWER_CNAME =
{
	[0] = "Trung lập",
	[1] = "Mông Cổ",
	[2] = "Tây Hạ",
};
NewBattle.NPC_CNAME =
{
	["ZHANCHE"]		= "Chiến Xa",
	["JIANTA"] 		= "Tiễn Tháp",
	["PAOTAI"]		= "Pháo Tháp",
	["SHOUHUZHE"]	= "Hộ Thủ Giả",
	["LONGMAI"]	 	= "Long Mạch",
};
NewBattle.POWER_COLOR =
{
	["XIA"]		=	"orange",
	["MENG"]	=	"pink",
};

NewBattle.FIGHT_RELATION =
{
	["ZHANCHE"]		= 1,
	["JIANTA"]		= 2,
	["PAOTAI"]		= 3,
	["PLAYER"]		= 4,
	["LONGMAI"]		= 5,
};

--表们
NewBattle.tbPlayerList 	= NewBattle.tbPlayerList or {};
NewBattle.tbTimers 		= NewBattle.tbTimers or {};
NewBattle.tbpNpcCars	= NewBattle.tbpNpcCars or {["XIA"] = {},["MENG"] = {}};
NewBattle.tbPos_ZhanChe	= NewBattle.tbPos_ZhanChe or {["XIA"] = {},["MENG"] = {}};

--公告条
--1 2 4为三种不同方式，3 5 6 7 为组合
NewBattle.SYSTEM_CHANNEL_MSG   		= 1;
NewBattle.BOTTOM_BLACK_MSG			= 2;
NewBattle.MIDDLE_RED_MSG   			= 4;

NewBattle.SYSTEMBLACK_MSG			= 3;
NewBattle.SYSTEMRED_MSG				= 5;
NewBattle.BLACKRED_MSG				= 6;
NewBattle.SYSTEMBLACKRED_MSG		= 7;

NewBattle.MSGSENDRULE = 			--发消息送规则
{
	[1] = {"CHANNEL"},
	[2] = {"BLACK"},
	[3] = {"CHANNEL","BLACK"},
	[4] = {"RED"},
	[5] = {"CHANNEL","RED"},
	[6] = {"RED","BLACK"},
	[7] = {"CHANNEL","RED","BLACK"},
};

----基础设置
NewBattle.nBattle_State			=	NewBattle.nBattle_State or NewBattle.BATTLE_STATES.CLOSED;	--活动当前状态
NewBattle.OPEN					=	1;								--系统开关
NewBattle.MAXPLAYER				=	50;								--每方人数上限 总上限*2
NewBattle.MINPLAYER				=	0;								--开启战场每方人数下限，总数为*2
NewBattle.SIGNLIMIT				=	3;								--报名差距人数控制，小于等于这个数
NewBattle.CARRIERDISLIMIT		= 	10;								--登录载具最大距离，好看又科学
NewBattle.LONGMAIBLOODBIANSHEN 	= 	25;								--龙脉变身血量百分比
NewBattle.DEF_DIS	 			= 	50;								--防御刷分范围，1.5屏以内
NewBattle.KILL_BASEPOINT		=	200;							--杀人基础分

--TASK ID
NewBattle.TK_PLAYERCARRIERSKILLS_TASKGROUP 		=	2200;
NewBattle.TK_PLAYERISINNEWBATTLE				=	1;				-- 玩家是否在新战场中

--载具打断方式
NewBattle.tbCarrierBreakEvent =
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
	--Player.ProcessBreakEvent.emEVENT_ATTACKED,			--被攻击
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_REVIVE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
};

----连斩
NewBattle.SERIESPK_NAME	= {									--连斩称号
	[1]	= {20 , "Thí Luyện Giang Hồ"},
	[2]	= {30, "Huyết Chiến Thiên Hạ"},
	[3]	= {40, "Không Thể Cản Phá"},
	[4]	= {50, "Thao Túng Thiên Địa"},
	[5]	= {60, "Khuynh Đảo Phong Vân"},
	[6]	= {70, "Uy Chấn Tứ Phương"},
	[7]	= {100, "Hùng Bá Thiên Hạ"},
	[8] = {99999,"Sai quá sai rồi..."},
};

NewBattle.NAME_RANK	= {
	"<color=white>Binh bét<color>", 
	"<color=white>Sĩ binh<color>",
	"<color=0xa0ff>Hiệu úy<color>", 
	"<color=0xa0ff>Đô đốc<color>",
	"<color=yellow>Thống lĩnh<color>",
	"<color=yellow>Chính tướng<color>",
	"<color=0xff>Phó tướng<color>",  
	"<color=0xff>Thống chế<color>",
	"<color=yellow><bclr=red>Đại tướng<bclr><color>", 
	"<color=yellow><bclr=red>Nguyên soái<bclr><color>",
};

NewBattle.TIPVALUE	= {										--战场提示,提示/攻守
	[1]	= {
		"Hãy đợi đến khi trận chiến bắt đầu", 
		"Điều khiển Chiến Xa (2 người)"
		},
	[2] = {
		"Tấn công Đá Triệu Hồi", 
		"Chiếm giữ Đá Triệu Hồi"
		},
	[3] = {
		"Bảo vệ Pháo Tháp",
		"Bảo vệ Thủ Hộ Giả",
		"Bảo vệ Long Mạch"
		},
	[4] = {
		"Phá hủy Pháo Tháp",
		"Tiêu diệt Thủ Hộ Giả",
		"Phá hủy Long Mạch"
		},
};
----积分规则
NewBattle.SERIESPKPOINT 	= 0.25;							--连斩>=3积分加成
NewBattle.FRISTBLOODPOINT 	= 500;							--一血得分

--击杀积分规则
NewBattle.KILLPOINTRULE =
{
	--击杀类型 = 个人奖励积分，阵营共享积分, 提示内容
	["ZHANCHE"]		= {800,		0		, "Bạn phá hủy <color=yellow>Chiến Xa<color> nhận được <color=white>%d<color> tích lũy!"},
	["JIANTA"] 		= {800,		0		, "Bạn phá hủy <color=yellow>Tiễn Tháp<color> nhận được <color=white>%d<color> tích lũy!"},
	["PAOTAI"]		= {2000,	600		, "Bạn phá hủy <color=yellow>Pháo Tháp<color> nhận được <color=white>%d<color> tích lũy!"},
	["SHOUHUZHE"]	= {2000,	1000	, "Bạn đánh bại <color=yellow>Thủ Hộ Giả<color> nhận được <color=white>%d<color> tích lũy!"},
	["LONGMAI"]	 	= {2000,	0		, "Bạn phá hủy <color=yellow>Long Mạch<color> nhận được <color=white>%d<color> tích lũy!"},
};
--守护积分，个人奖励
NewBattle.DEFPOINTRULE =
{
	["PAOTAI"] 		=	10,
	["LONGMAI"]		=	20,
	["SHOUHUZHE"]	=	30,
};
--战场积分，个人奖励,百分比
NewBattle.BATTLEPOINTRULE =
{
	["WIN"] 		=	15,
	["LOST"]		=	5,
	["DRAW"]		=	10,
};


----时间们
NewBattle.TIME_SIGN 				= 	5 * 60 * Env.GAME_FPS;			--报名时间
NewBattle.TIME_FIGHT				=	25 * 60 * Env.GAME_FPS;			--战斗时间
NewBattle.UPDATE_TIME				=	5 * Env.GAME_FPS;				--更新数据(帧)
NewBattle.PLAYERTRANSFERCD			=	0;--2 * 60;						--个人传送CD(秒)
NewBattle.STONETRANSFERCD			=	30;								--传送石保护时间(秒)
NewBattle.PLAYERPROTECTEDTIME		=	5;								--玩家复活保护时间(秒)
NewBattle.SWORDREBORN				=	3 * 60 * Env.GAME_FPS;			--箭塔重生时间
NewBattle.SERIESPKSHOW				=	30;								--连斩显示时间(秒)
NewBattle.MAKECARTIME				=	1 * 60 * Env.GAME_FPS;			--战车制造时间
NewBattle.GETCARRIERTIME			=	1 * Env.GAME_FPS;				--登录载具读条时间,已作废
NewBattle.MAKEPAOTAI				=	3 * 60 * Env.GAME_FPS;			--炮台刷新时间
NewBattle.TIME_BOOM					=	20 * Env.GAME_FPS;				--爆机时间
NewBattle.DEFPOINTTIME				=	15 * Env.GAME_FPS;				--守护刷分时间
NewBattle.BEATTACKTIME				=	20;								--NPC被攻击提示间隔

----地图们
NewBattle.TB_MAP_BAOMING =			--报名点地图
{
	[1]	= 
	{
		[1] = {2284, 2285},
	},
	[2] = 
	{
		[1] = {2284, 2285},
		-- [2] = {2290, 2291},
	},
	-- [3] =
	-- {
		-- [1] = {2284, 2285},
		-- [2] = {2290, 2291},
	-- },
};
NewBattle.TB_MAP_BATTLE =			--战斗地图
{
	[1]	= 
	{
		[1] = 2260,
		-- [2] = 2260,
	},
	[2] = 
	{
		[1] = 2260,
		-- [2] = 2289,
	},
	-- [3] = 2260,
};
----坐标们
NewBattle.POS_BUFFS = 
{
	["XIA"] =
	{
		[1] = {1724, 3527},
		[2] = {1753, 3550},
		[3] = {1778, 3582},
		[4] = {1756, 3618},
		[5] = {1785, 3629},
		[6] = {1714, 3581},
		[7] = {1734, 3612},
		[8] = {1742, 3572}
		
	},
	["MENG"] = 
	{
		[1] = {2020, 3206},
		[2] = {1995, 3234},
		[3] = {2005, 3262},
		[4] = {2045, 3304},
		[5] = {2070, 3289},
		[6] = {2045, 3225},
		[7] = {2068, 3256},	
		[8] = {2018, 3265}
	},
};
NewBattle.POS_READY = 				--双方后营传送坐标
{
	["XIA"] =
	{
		[1]	= {1607, 3697},
		[2]	= {1591, 3713},
		[3]	= {1646, 3741},
		[4]	= {1626, 3740},

	};

	["MENG"] =
	{
		[1]	= {2109, 3098},
		[2]	= {2125, 3104},
		[3]	= {2132, 3134},
		[4]	= {2117, 3117},

	};
};

NewBattle.POS_BRON = 				--双方大营传送坐标
{
	["XIA"] =
	{
		[1]	= {1666, 3598},
		[2]	= {1730, 3531},
		[3]	= {1793, 3607},
		[4]	= {1766, 3633},
		[5]	= {1762, 3566},

	};

	["MENG"] =
	{
		[1]	= {2028, 3215},
		[2]	= {1986, 3252},
		[3]	= {2061, 3325},
		[4]	= {2024, 3281},
		[5]	= {2072, 3250},

	};

};
NewBattle.POS_BAOMING = 			--报名点传出坐标
{
	[1] = {1671, 3281},
	[2] = {1672, 3305},
	[3] = {1688, 3306},
};
NewBattle.POS_CHUANSONG = 			--传送石传送点坐标
{
	[1]	= {1890, 3417},
	[2]	= {1881, 3403},
	[3]	= {1872, 3415},
	[4]	= {1884, 3426},

};

NewBattle.POS_CHUANSONGSTONE = {1884, 3412};	--召唤石刷新点

NewBattle.POS_YAOSHANG	  =
{
	["XIA"]  =	{1626, 3711},
	["MENG"] =	{2106, 3115},
};
NewBattle.POS_ZHAOHUANSHI = 					--双方召唤师刷新点
{
	["XIA"]  =
	{
		[1] = {1636, 3726},
		--[0]	= {1636, 3726},
	};
	["MENG"] =
	{
		[1]	= {2119, 3125},
		--[0]	= {2119, 3125},
	};
};
NewBattle.POS_YAODIAN	=						--双方药店刷新点
{
	["XIA"] 	= {1626, 3711},
	["MENG"] 	= {2106, 3115}
};
NewBattle.POS_SHOUHUZHE	=						--双方守护者刷新点
{
	["XIA"] 	= {1758, 3569},
	["MENG"] 	= {2022, 3279}
};
NewBattle.POS_LONGMAI	=						--双方龙脉刷新点
{
	["XIA"] 	= {1731, 3589},
	["MENG"] 	= {2054, 3247},
};
NewBattle.POS_PAOTAI	=						--炮台刷新点
{
	["XIA"] =
	{
		[1]	= {1774, 3555},
		[2]	= {1802, 3639}
	};
	["MENG"] =
	{
		[1]	= {2002, 3308},
		[2]	= {1988, 3216}
	};
}

NewBattle.POS_ZHANCHE = 						--战车刷新点
{
	["XIA"] =
	{
		[1]	= {1708, 3552},
		[2]	= {1710, 3564},
		[3]	= {1757, 3637},
		[4]	= {1764, 3630},
		[5]	= {1771, 3621},
		[6] = {1731, 3530},
		[7] = {1693, 3607},
		[8] = {1772, 3589}
	};
	["MENG"] =
	{
		[1]	= {2088, 3280},
		[2]	= {2081, 3287},
		[3]	= {2076, 3296},
		[4]	= {2026, 3208},
		[5]	= {2020, 3215},
		[6] = {1985, 3251},
		[7] = {2059, 3327},
		[8] = {2006, 3273}

	};
};

NewBattle.POS_JIANTA = 							--箭塔刷新点
{
	["XIA"] =
	{
		[1]	= {1824, 3483},
		[2]	= {1836, 3499},
		[3]	= {1761, 3472},
		[4]	= {1830, 3642},
		[5]	= {1751, 3593},

	};
	["MENG"] =
	{
		[1]	= {1950, 3348},
		[2]	= {1961, 3361},
		[3]	= {1995, 3404},
		[4]	= {1968, 3189},
		[5]	= {2037, 3251},

	};
};
NewBattle.POS_BOOM = 							--爆炸点~
{
	["XIA"] =
	{
		[1]		= {1733, 3577},
		[2]		= {1738, 3581},
		[3]		= {1742, 3589},
		[4]		= {1740, 3597},
		[5]		= {1733, 3602},
		[6]		= {1726, 3600},
		[7]		= {1717, 3595},
		[8]		= {1721, 3586},
		[9]		= {1728, 3582},
		[10]	= {1736, 3588},
		[11]	= {1731, 3594},
		[12]	= {1726, 3589},
		[13]	= {1731, 3592},
	},
	["MENG"] =
	{
		[1]		= {2045, 3242},
		[2]		= {2051, 3239},
		[3]		= {2059, 3244},
		[4]		= {2065, 3254},
		[5]		= {2059, 3266},
		[6]		= {2052, 3265},
		[7]		= {2044, 3260},
		[8]		= {2045, 3251},
		[9]		= {2049, 3247},
		[10]	= {2057, 3249},
		[11]	= {2051, 3255},
		[12]	= {2056, 3266},
		[13]	= {2053, 3238},
	},
};
----NPCid们
NewBattle.ZHAOHUANSHI_ID 	= 10267;		--召唤师ID
NewBattle.STONE_ID		 	= 10268;		--召唤石ID
NewBattle.SHOUHUZHE_ID		=				--守护者ID
{
	["XIA"]		=	10275;
	["MENG"]	=	10276;
};
NewBattle.LONGMAI_ID 		= 				--龙脉ID
{
	["XIA"]		=	10272;
	["MENG"]	=	10271;
};
NewBattle.BUFF_ID 		= 				--龙脉ID
{
	["XIA"]		=	2350;
	["MENG"]	=	2351;
};
NewBattle.JIANTA_ID			=				--箭塔ID
{
	["XIA"]		=	11004;
	["MENG"]	=	11005;
};
NewBattle.ZHANCHE_ID		=				--战车ID
{
	["XIA"]		=	11001;
	["MENG"]	=	11000;
};
NewBattle.PAOTAI_ID			=				--炮台ID
{
	["XIA"]		=	11006;
	["MENG"]	=	11003;
};
NewBattle.YAODIAN_ID		=				--药商
{
	["XIA"]		=	2504;
	["MENG"]	=	2507;
};
NewBattle.FIGHTNPC_ID		=				--士兵校尉统领副将大将
{
	[1]	=
	{
		["SHIBING"]	= 2509,
		["XIAOWEI"]	= 2510,
		["TONGLING"]= 2511,
		["FUJIANG"]	= 2512,
	},
	[2]	=
	{
		["SHIBING"]	= 2515,
		["XIAOWEI"]	= 2516,
		["TONGLING"]= 2517,
		["FUJIANG"]	= 2518,
	},
};
NewBattle.FIGHTNPC_NAME = 				--士兵校尉统领副将大将ID2NAME
{
	[2509] = "SHIBING",
	[2515] = "SHIBING",	
	[2510] = "XIAOWEI",
	[2516] = "XIAOWEI",
	[2511] = "TONGLING",
	[2517] = "TONGLING",	
	[2512] = "FUJIANG",
	[2518] = "FUJIANG",	
};

----技能特效ID
NewBattle.BOOM_ID			= 2947;			--爆炸特效
NewBattle.BIANSHEN			=				--龙脉变身
{
	["XIA"] 	= 2943;
	["MENG"]	= 2944;
};
NewBattle.WUDITEXIAO			=				--龙脉无敌特效
{
	["XIA"] 	= 2650;
	["MENG"]	= 2651;
};



--获取table坐标集中一个随机的坐标点
function NewBattle:GetRandomPoint(tbpos)
	if type(tbpos) ~= "table" then
		return tbpos;
	end
	return tbpos[MathRandom(1, #tbpos)];
end

--是否能开启战场
function NewBattle:CanStartBattle()
	if(NewBattle.OPEN == 0 or NewBattle.nBattle_State ~= NewBattle.BATTLE_STATES.CLOSED) then
		return 0;
	end
	return 1;
end



--获取连斩称号
function NewBattle:GetSeriesPkName(nNum)
	for i = 2,#self.SERIESPK_NAME do
		if(nNum < self.SERIESPK_NAME[i][1] and nNum >= self.SERIESPK_NAME[i-1][1]) then
			local nR = 0;
			if nNum == self.SERIESPK_NAME[i-1][1] then
				nR = 1;
			end
			return self.SERIESPK_NAME[i-1][2],nR;
		end
	end
end

--添加计时器
function NewBattle:AddTimer(szName, nTime, fnFun, ...)
	local nTimeId = Timer:Register(nTime, fnFun, unpack(arg));
	self.tbTimers[szName] = nTimeId;
	return nTimeId;
end

--获取计时器
function NewBattle:GetTimerId(szName)
	return self.tbTimers[szName] or  0;
end

--关闭所有计时器
function NewBattle:CloseAllTimer()
	for szTimeName, nId in pairs(self.tbTimers) do
		local nRest = Timer:GetRestTime(nId);
		if nRest ~= -1 then
			Timer:Close(nId);
		end
	end
end

--存入战车ID
function NewBattle:SaveCardwId(szPower, nNum, dwId)
	NewBattle.tbpNpcCars[szPower][nNum] = dwId;
end

--删除战车ID
function NewBattle:DeleteCardwId(szPower, nNum)
	NewBattle.tbpNpcCars[szPower][nNum] = 0;
end

--根据阵营格式颜色信息
function NewBattle:GetColStr(szStr, nPower)
	return string.format("<color=%s>%s<color>", self.POWER_COLOR[self.POWER_ENAME[nPower]], szStr);
end

--根据nTitle获得军衔，至少>4
function NewBattle:GetTitle(nTitle)
	local szTitle = Battle.NAME_RANK[nTitle];
	return "("..szTitle..")" or "";
end

--获取敌人
function NewBattle:GetEnemy(nPower)
	if type(nPower) == "number" then
		return (nPower == 1) and 2 or 1;
	end
	return (nPower == "XIA") and "MENG" or "XIA";
end
--
--DEBUG BEGIN
if NewBattle.__DEBUG then
  NewBattle.TIME_SIGN 				= 	1 * 60  * Env.GAME_FPS;
  NewBattle.TIME_FIGHT 				= 	50 * 60 * Env.GAME_FPS;
  NewBattle.MINPLAYER				=	0;
  NewBattle.MAKECARTIME				=	10 * Env.GAME_FPS;			--战车制造时间
  NewBattle.SWORDREBORN             =   10 * Env.GAME_FPS;			--箭塔重生时间
  NewBattle.MAKEPAOTAI				=	0.1 * 60 * Env.GAME_FPS;	--炮台刷新时间
end
--DEBUG END
--
