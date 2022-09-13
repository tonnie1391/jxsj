
-- 游戏世界基础常量定义（注意保持与程序的一致）

Env.GAME_FPS			= 18;		-- 游戏世界每秒帧数

-- 性别定义
Env.SEX_MALE			= 0;		-- 男性
Env.SEX_FEMALE			= 1;		-- 女性

-- 性别描述字符串
Env.SEX_NAME =
{
	[Env.SEX_MALE]		= "男性",
	[Env.SEX_FEMALE]	= "女性",
};

-- 五行常量定义
Env.SERIES_NONE			= 0;		-- 无系
Env.SERIES_METAL		= 1;		-- 金系
Env.SERIES_WOOD			= 2;		-- 木系
Env.SERIES_WATER		= 3;		-- 水系
Env.SERIES_FIRE			= 4;		-- 火系
Env.SERIES_EARTH		= 5;		-- 土系

-- 五行名称字符串
Env.SERIES_NAME	=
{
	[Env.SERIES_NONE]	= "无",
	[Env.SERIES_METAL]	= "金",
	[Env.SERIES_WOOD]	= "木",
	[Env.SERIES_WATER]	= "水",
	[Env.SERIES_FIRE]	= "火",
	[Env.SERIES_EARTH]	= "土",
};

Env.DISPLAY_RESOLUTION =
{
	["a"] = { 800,  600 },
	["b"] = { 1024, 768 },
	["c"] = { 1280, 800 },
}

-- 世界新闻类型
Env.NEWSMSG_NORMAL 		= 0;    -- 普通
Env.NEWSMSG_COUNT		= 1;	-- 延时播放
Env.NEWSMSG_TIMEEND		= 2;	-- 定时停止
Env.NEWSMSG_MARRAY		= 3;	-- 结婚的特效消息

Env.WEIWANG_BATTLE		= 1;
Env.WEIWANG_MENPAIJINGJI= 2;
Env.WEIWANG_DATI		= 3;
Env.WEIWANG_BAIHUTANG 	= 4;
Env.WEIWANG_TREASURE	= 5;
Env.WEIWANG_BAOWANTONG	= 6;
Env.WEIWANG_GUOZI		= 7;
Env.WEIWANG_BOSS		= 8;

-- 大区类型定义（默认电信）
--	TODO：目前只支持金山版
Env.ZONE_TYPE	=
{
	[2]		= 2,
	[5]		= 2,
	[9]		= 2,
	[11]	= 2,
};

Env.FACTION_ID_NOFACTION	= 0;
Env.FACTION_ID_SHAOLIN		= 1;		-- 少林
Env.FACTION_ID_TIANWANG		= 2;		-- 天王
Env.FACTION_ID_TANGMEN		= 3;		-- 唐门
Env.FACTION_ID_WUDU			= 4;		-- 武毒
Env.FACTION_ID_EMEI			= 5;		-- 峨眉
Env.FACTION_ID_CUIYAN		= 6;		-- 翠烟
Env.FACTION_ID_GAIBANG		= 7;		-- 丐帮
Env.FACTION_ID_TIANREN		= 8;		-- 天忍
Env.FACTION_ID_WUDANG		= 9;		-- 武当
Env.FACTION_ID_KUNLUN		= 10;		-- 昆仑
Env.FACTION_ID_MINGJIAO		= 11;		-- 明教
Env.FACTION_ID_DALIDUANSHI	= 12;		-- 大理段氏
Env.FACTION_ID_GUMU			= 13;		-- 古墓

Env.FACTION_NUM			= 13;

-- 大区类型名定义
--(废弃，获得大区类型名可使用Env:GetZoneTypeName(szGatewayName)
Env.ZONE_TYPE_NAME	=
{
	[1]		= "电信",
	[2]		= "网通",
};

function Env:GetZoneType(szGatewayName)
	local tbInfor = ServerEvent:GetServerInforByGateway(szGatewayName);
	if not tbInfor or not tbInfor.ZoneType then
		--如果没有数据用老方法
		local nZoneId	= tonumber(string.sub(szGatewayName, 5, 6));
		return self.ZONE_TYPE[nZoneId] or 1;
	end
	return tbInfor.ZoneType;
end

function Env:GetZoneTypeName(szGatewayName)
	if ServerEvent:GetServerInforByGateway(szGatewayName) then
		return ServerEvent:GetServerInforByGateway(szGatewayName).ZoneTypeName;
	end
	return "电信";
end
