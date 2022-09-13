
-- NPC正在做什么
Npc.DO_NONE				= 0;		-- 什么也不干
Npc.DO_STAND			= 1;		-- 站立
Npc.DO_WALK				= 2;		-- 行走
Npc.DO_RUN				= 3;		-- 跑动
Npc.DO_JUMP				= 4;		-- 跳跃
Npc.DO_SKILL			= 5;		-- 发技能的命令
Npc.DO_MAGIC			= 6;		-- 施法
Npc.DO_ATTACK			= 7;		-- 攻击
Npc.DO_SIT				= 8;		-- 打坐
Npc.DO_HURT				= 9;		-- 受伤
Npc.DO_DEATH			= 10;		-- 死亡
Npc.DO_IDLE				= 11;		-- 喘气
Npc.DO_SPECIALSKILL		= 12;		-- 技能控制动作
Npc.DO_SPECIAL1			= 13;		-- 特殊1
Npc.DO_SPECIAL2			= 14;		-- 特殊2
Npc.DO_SPECIAL3			= 15;		-- 特殊3
Npc.DO_SPECIAL4			= 16;		-- 特殊4
Npc.DO_RUNATTACK		= 17;
Npc.DO_MANYATTACK		= 18;
Npc.DO_JUMPATTACK		= 19;
Npc.DO_REVIVE			= 20;
Npc.DO_STALL			= 21;
Npc.DO_MOVEPOS			= 22;		-- 瞬间移动
Npc.DO_KNOCKBACK		= 23;		-- 震退

-- NPC行为
Npc.ACT_FIGHTSTAND		= 0;		-- 战斗状态站立
Npc.ACT_STAND1			= 1;		-- 非战斗状态站立一
Npc.ACT_STAND2			= 2;		-- 非战斗状态站立二
Npc.ACT_FIGHTWALK		= 3;		-- 战斗状态行走
Npc.ACT_WALK			= 4;		-- 非战斗状态行走
Npc.ACT_FIGHTRUN		= 5;		-- 战斗状态奔跑
Npc.ACT_RUN				= 6;		-- 非战斗状态奔跑
Npc.ACT_HURT			= 7;		-- 受伤
Npc.ACT_DEATH			= 8;		-- 死亡
Npc.ACT_ATTACK1			= 9;		-- 攻击一
Npc.ACT_ATTACK2			= 10;		-- 攻击二
Npc.ACT_MAGIC			= 11;		-- 技能攻击
Npc.ACT_SIT				= 12;		-- 打坐
Npc.ACT_JUMP			= 13;		-- 跳跃
Npc.ACT_NONE			= 14;		-- 无

-- NPC状态
Npc.STATE_HURT			= 0;		-- 受伤动作状态
Npc.STATE_WEAK			= 1;		-- 虚弱状态
Npc.STATE_SLOWALL		= 2;		-- 迟缓状态
Npc.STATE_BURN			= 3;		-- 灼伤状态
Npc.STATE_STUN			= 4;		-- 眩晕状态
Npc.STATE_FIXED			= 5;		-- 定身状态
Npc.STATE_PALSY			= 6;		-- 麻痹状态
Npc.STATE_SLOWRUN		= 7;		-- 减跑速状态
Npc.STATE_FREEZE		= 8;		-- 冻结状态
Npc.STATE_CONFUSE		= 9;		-- 混乱状态
Npc.STATE_KNOCK			= 10;		-- 击退状态
Npc.STATE_DRAG			= 11;		-- 拉回状态
Npc.STATE_SILENCE		= 12;		-- 沉默退状态
Npc.STATE_ZHICAN		= 13;		-- 致残状态
Npc.STATE_FLOAT			= 14;		-- 致残状态

Npc.STATE_POISON		= 15;		-- 中毒状态
Npc.STATE_HIDE			= 16;		-- 隐身状态
Npc.STATE_SHIELD		= 17;		-- 护盾状态
Npc.STATE_SUDDENDEATH	= 18;		-- 猝死状态
Npc.STATE_IGNORETRAP	= 19;		-- 不触发陷阱状态

-- NPC资源部位
Npc.NPCRES_PART_HELM	= 0;		-- 头部资源
Npc.NPCRES_PART_ARMOR	= 1;		-- 身体资源
Npc.NPCRES_PART_WEAPON	= 2;		-- 武器资源
Npc.NPCRES_PART_HORSE	= 3;		-- 马匹资源

-- Npc聊天泡泡组的属性，Weight是权重据此来随机到一个组(最终再根据具体泡泡权重随机到具体的一项),Index为Npc组的下标，不能有重复
Npc.BubbleProperty = 
{
	Silence		= { Weight = 200 },								-- 沉默
	Task 		= { Weight = 50, nIndex = "Task" },				-- 普通泡泡
	Normal		= { Weight = 50, nIndex = "Normal" },			-- 任务泡泡
};

-- NPC虚拟关系枚举 (请与程序 knpcdef.h 中 KE_NPC_VIRTUALRELATIONTYPE 对应)
Npc.emNPCVRELATIONTYPE_NONE 	= 0;		-- 无关系
Npc.emNPCVRELATIONTYPE_TONE 	= 1;		-- 帮会关系
Npc.emNPCVRELATIONTYPE_UNION	= 2;		-- 联盟关系


-- 要记录掉落过程中每个玩家获得情况的掉落列表
Npc.DROPFILE_RECORD_LIST	= "\\setting\\npc\\dropfile_recordlist.txt";