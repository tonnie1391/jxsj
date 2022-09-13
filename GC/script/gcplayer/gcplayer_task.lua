-------------------------------------------------------------------
--File: gcplayer_task.lua
--Author: lbh
--Date: 2007-9-17 21:47
--Describe: kgc_player的任务变量定义
-------------------------------------------------------------------
if (MODULE_GAMECLIENT) then
	return;
end
local preEnv = _G	--保存旧的环境
setfenv(1, KGCPlayer)	--设置当前环境为KGCPlayer

TSK_LEAVE_KIN_TIME 		= 1;
TSK_ONLINESERVER 		= 2;
TSK_FACTION 			= 3;
TSK_MEMBER_ID			= 4;
TSK_TONGSTOCK			= 5;
TSK_OFFICIAL_LEVEL		= 6;
TSK_MAINTAIN_OFFICIAL_NO = 7;
TSK_CURRENCY_MONEY 		= 8;
TSK_CONNET_ID			= 9;
EXP						= 10;
LEVEL					= 11;
SEX						= 12;
TRAINING_MONTH			= 13;
TRAINING_COUNT			= 14;
MONEY_HONOR				= 15;
OFFLIVE_SERVERID		= 16;
TEAM_ID					= 17;
SNS_BIND				= 18;

preEnv.setfenv(1, preEnv)	--恢复全局环境
