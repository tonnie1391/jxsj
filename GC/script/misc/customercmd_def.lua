-------------------------------------------------------------------
--File: customercmd_def.lua
--Author: zouying
--Date: 2009-5-11 16:52
--Describe: gm专用脚本，gs，gc共同定义
-------------------------------------------------------------------

GmCmd.TASK_CUSTOMER_ID 	= 2090;
GmCmd.SUBTASKID_UNBANCHAT = 1;
GmCmd.SUBTASKID_FREEPRISON  = 2;
--GM系统执行指令的返回值(参见cpp中的enum KE_GMCMD_RESULT)
GmCmd.GMCMD_RESULT_PLAYER_NOT_FOUND		= 7;	--玩家不存在
GmCmd.GMCMD_RESULT_PLAYER_NOT_ONLINE	= 8;	--玩家不在线
--对应l2e_gmcmd协议的byAction字段
GmCmd.GMCMD_ACTION_OPERATE	= 0;	--做操作
GmCmd.GMCMD_ACTION_GETDATA	= 1;	--获取数据
