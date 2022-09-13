local preEnv = _G;
setfenv(1, AutoTeam);

--逍遥谷
XOYO_PUTONG		= 1;
XOYO_KUNNAN		= 2;
XOYO_CHUANSHUO	= 3;
XOYO_DIYU		= 4;

--军营副本
ARMY_FUNIUSHAN		= 11;
ARMY_BAIMANSHAN		= 12;
ARMY_HAIWANGLINGMU	= 13;

--参与自动组队的玩家需要达到的等级
MIN_PLAYER_LEVEL = 80;

--组队完成的人数
MAX_TEAM_MEMBER = 2;

--队伍组满后玩家确认的倒数计时秒数
CONFIRM_COUNTDOWN_SECONDS = 30;

--组队确认的选择项
CONFIRM_OK		= 1;
CONFIRM_REFUSE	= 2;

preEnv.setfenv(1, preEnv)