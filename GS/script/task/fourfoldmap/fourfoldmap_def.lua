--四倍经验练级地图
--sunduoliang
--2008.11.05

local Fourfold = Task.FourfoldMap or {};
Task.FourfoldMap = Fourfold;

Fourfold.MAP_TEMPLATE_ID = 343; --模版地图
Fourfold.MAP_APPLY_MAX   = 15;  --每台服务器申请上限
Fourfold.NPC_ID   		 = 2317;  --npcId
Fourfold.TIME_GET_READY  = 1; -- 准备时间（分钟）

Fourfold.TSK_GROUP = 2040;	--任务变量组
--Fourfold.TSK_STATE = 12;	--状态，0未在4倍地图，1在4倍地图
--Fourfold.TSK_ENTER_MAP 	= 13;--传入点地图Id
--Fourfold.TSK_ENTER_POSX = 14;--传入点地图X坐标
--Fourfold.TSK_ENTER_POSY = 15;--传入点地图Y坐标
Fourfold.TSK_REMAIN_TIME = 16;--剩余时间（秒）
--Fourfold.TSK_USE_COUNT	= 17;--使用次数
--Fourfold.TSK_CAPTAIN	= 18;--副本所属队长Id
Fourfold.DEF_MAX_TIME 	= 2 * 60 * 60; 		--最大累计增加时间10小时;
Fourfold.DEF_PRE_TIME 	= 30 * 60;  		--每天累计增加2小时;
Fourfold.DEF_MIN_OPEN_TIME	= 15 * 60;   --时间大于120分才能开启
Fourfold.DEF_MIN_ENTER_TIME	= 60; 	    --剩余时间少于60秒的玩家不允许进入
Fourfold.DEF_MAX_ENTER	= 6;   --最多只能6人进入秘境地图。
Fourfold.DEF_LUCKY		= 10;  --默认增加10点幸运。
Fourfold.LIMIT_LEVEL 	= EventManager.IVER_nFourfoldMapLevel;  --达到50级才能进入

Fourfold.UI_READYTIME_MSG = "<color=green>Thời gian mở: <color=white>%s\n";
Fourfold.UI_TIME_MSG 	= "<color=green>Thời gian đóng lại: <color=white>%s\n\n<color=green>Thời gian tu luyện: <color=white>%s\n";
Fourfold.UI_STAIC_MSG 	= "<color=yellow>Đang tu luyện...<color>";

Fourfold.DEF_MAP_POS	=	{{51840/32,100896/32}}; --传入坐标 

Fourfold.DEF_ITEM_KEY= {18,1,251,1};	--开启副本道具；

Fourfold.TimerList = Fourfold.TimerList or {}; --存储计时器Id;
Fourfold.MissionList = Fourfold.MissionList or {}; --mission列表;
Fourfold.NpcPosList = Fourfold.NpcPosList or {}; --npc坐标列表;
Fourfold.PlayerTempList = Fourfold.PlayerTempList or {}; --玩家临时数据列表;

--模版地图列表;
if not Fourfold.MapTempletList then
	Fourfold.MapTempletList = {};
	Fourfold.MapTempletList.tbBelongList = {};
	Fourfold.MapTempletList.tbMapList = {};
	Fourfold.MapTempletList.nCount = 0;
end

--玩家申请秘境开启时间
if not Fourfold.tbOpenHour then
	Fourfold.tbOpenHour = {};
end
