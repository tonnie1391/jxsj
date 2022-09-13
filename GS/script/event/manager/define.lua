-------------------------------------------------------------------
--File: 	define.lua
--Author: sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统
--InterFace1:提前定义.
--InterFace2:
--InterFace3:
-------------------------------------------------------------------


EventManager.EventManager 		= EventManager.EventManager or {};
EventManager.Event 				= EventManager.Event or {};
EventManager.EventNpc 			= EventManager.EventNpc or {};
EventManager.EventItem 			= EventManager.EventItem or {};
EventManager.EventItemId 		= EventManager.EventItemId or {};
EventManager.EventPart 			= EventManager.EventPart or {};
EventManager.EventKindBase 		= EventManager.EventKindBase or {};
EventManager.EventKind 			= EventManager.EventKind or {};
EventManager.EventKind.ExClass 	= EventManager.EventKind.ExClass or {};
EventManager.EventKind.Module 	= EventManager.EventKind.Module or {};

EventManager.tbFun 				= EventManager.tbFun or {};			--常用函数表
EventManager.ExEvent			= EventManager.ExEvent or {};		--活动功能性表
EventManager.KingEyes			= EventManager.KingEyes or {};		--运营支持

Require("\\script\\event\\manager\\base.lua");
Require("\\script\\event\\manager\\eventpart.lua");
Require("\\script\\event\\manager\\event.lua");
Require("\\script\\event\\manager\\manager.lua");

EventManager.TASK_GROUP_ID 		= 2026;	--活动任务变量Group(1-50为在线指令任务变量使用（使用重复批次，批次用年月日）)
EventManager.TASK_PACTH_GROUP_ID= 2096;	--活动任务变量Group批次表
EventManager.EVENT_TABLE 		= "\\setting\\event\\manager\\event.txt";
EventManager.EVENT_BASE_PATH    = "\\setting\\event\\manager\\";
EventManager.EVENT_CLOSE_DATE 	= -3;	--关闭活动,
EventManager.EVENT_TIMER_DATE_RSTART 	= -2;	--预备启动,
EventManager.EVENT_TIMER_DATE_START 	= -1;	--马上活动,
EventManager.EVENT_PARAM_MAX 	= 25;	--扩展参数最大数

EventManager.AWARD_TYPE_ITEM1 	= 0;	--奖励类型（所有）
EventManager.AWARD_TYPE_ITEM2 	= 1;	--奖励类型（材料奖励）
EventManager.AWARD_TYPE_MAREIAL = 2;	--奖励所需材料

EventManager.TIME_MAX_MAINTAIN = 46800;		--计时器最大时间间隔 秒
EventManager.KIND_CALLBOSS_GC	= 1;	--GC特殊执行类型,gc调用召唤npc.

EventManager.DIALOG_CLOSE = "Kết thúc đối thoại";	--对话结束语句.统一接口插入,清除