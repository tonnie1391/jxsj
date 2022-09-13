
-- Npc默认模板（也是基础模板）

-- 注意：default新定义接口在使用时注意检查是否是nil值
-- huadengshizhe,unqueboss,kinboss,huihuangzhiguo,huangjinzhiguo会重载该基类

-- 从Npc模板库中找到此模板，如不存在会自动建立新模板并返回
-- 提示：npc.lua 已经在 preload.lua 中前置，这里无需再Require
local tbDefault	= Npc:GetClass("default");

-- 定义对话事件
function tbDefault:OnDialog()
	local szMsg	= string.format("%s: %s, ngươi khỏe chứ?", him.szName, me.szName);
	Dialog:Say(szMsg, {});
end;


-- 生成顶层层对话选项,不允许放入永久性对话
function tbDefault:GenTopDialogOpt()
	return {};
end

-- 定义死亡事件
function tbDefault:OnDeath(pNpcKiller)
	--local szMsg	= string.format("%s：我被 %s 杀了！", him.szName, pNpcKiller.szName);
	--Msg2SubWorld(szMsg);
end;

function tbDefault:ExternDropOnDeath(pNpcKiller)
	--print("tbDefault:ExternDropOnDeath");
end

-- Client,触发聊天泡泡
function tbDefault:OnTriggerBubble()
	local nBubbleGroupTotleWeight = self:GetBubbleGroupTotleWeight();
	if (nBubbleGroupTotleWeight <= 0) then
		return;
	end
	
	local nGroupRandom = MathRandom(nBubbleGroupTotleWeight);
	local nSum = 0;
	local tbSelectedBubble = nil;
	for _,item in pairs(Npc.BubbleProperty) do
		nSum = nSum + item.Weight;
		if (nSum >= nGroupRandom) then -- 选择了组
			if (not item.nIndex) then
				return;
			end
			
			tbSelectedBubble = self:GetSelectedBubble(item.nIndex);
			break;
		end
	end
	
	if (not tbSelectedBubble) then
		return;
	end
	
	--  判断所有条件是否满足，若满足则显示消息，并且执行客户端的回调
	if (tbSelectedBubble.tbConditions) then
		for _,cond in ipairs(tbSelectedBubble.tbConditions) do
			if (dostring(self:ReadBubbleConditionFaction(cond))() ~= 1) then
				return;
			end
		end
	end
		
	-- 执行到此处表明所有条件均满足
	local szMsg = tbSelectedBubble.szMsg;
	
	him.SetBubble(szMsg);
	
	-- 执行客户端回调
	if (tbSelectedBubble.tbCallBacks) then
		for _,callback in ipairs(tbSelectedBubble.tbCallBacks) do
			Lib:CallBack(callback);
		end
	end
end


-- 获得所有泡泡组的总权重见define.lua
function tbDefault:GetBubbleGroupTotleWeight()
	local nSum = 0;
	for _,item in pairs(Npc.BubbleProperty) do
		nSum = nSum + item.Weight;
	end
	
	return nSum;
end

function tbDefault:GetSelectedBubble(nIndex)
	local tbBubbleGroup = self.tbBubble[nIndex];
	if (not tbBubbleGroup) then
		return;
	end
	local nItemTotleWeight = self:GetTotleWeightInSingleGroup(nIndex);
	if (nItemTotleWeight <= 0) then
		return;
	end
	
	local nBubbleRandom = MathRandom(nItemTotleWeight);
	local nSum = 0;
	for _, item in pairs(self.tbBubble[nIndex]) do
		nSum = nSum + item.nProbability;
		if (nSum >= nBubbleRandom) then
			return item;
		end
	end
end

function tbDefault:GetTotleWeightInSingleGroup(nIndex)
	local nSum = 0;
	if (not self.tbBubble[nIndex]) then
		print(nnIndex)
		assert(false);
	end
	for _, item in pairs(self.tbBubble[nIndex]) do
		nSum = nSum + item.nProbability;
	end
	
	return nSum
end

function tbDefault:ReadBubbleConditionFaction(tbFunction)
	local szFuncName	= "";
	local szFuncParam	= "";
	szFuncName = tbFunction[1];
	for i = 2, #tbFunction do
		szFuncParam	= table.concat(tbFunction[i], ",");	
	end

	return szFuncName.."("..szFuncParam..")";
end


--============ 定义属性 =============--

-- 专门处理技能，因为基础技能是按照五行处理的，而不是等级
local tbSeriesSkill	= {
	[Env.SERIES_NONE]	= 1,
	[Env.SERIES_METAL]	= 2,
	[Env.SERIES_WOOD]	= 3,
	[Env.SERIES_WATER]	= 4,
	[Env.SERIES_FIRE]	= 5,
	[Env.SERIES_EARTH]	= 6,
}
local function GetSkillId(nSeries, nLevel)
	return tbSeriesSkill[nSeries];
end;

-------------- 等级数据 ---------------
tbDefault.tbLevelData	= {	-- 当NPC的ClassName为default时，调用一下技能数值脚本
	--优先级最低的AI、技能、数值脚本
	AIMode		= 4,	
	AIParam1	= 0,	
	AIParam2	= 0,
	AIParam3	= 0,	
	AIParam4	= 0,					
	AIParam5	= 0,
	AIParam6	= 0,
	AIParam7	= 0,
	AIParam8	= 0,
	AIParam9	= 0,
	AIParam10	= 0,	
	AIParam11	= 0,	
	
	Skill1				= 0,
	Level1				= 0,
	Skill2				= 0,
	Level2				= 0,
	Skill3				= 0,
	Level3				= 0,
	Skill4				= 0,
	Level4				= 0,
	Exp					= 0,
	Life				= 100,
	LifeReplenish		= 0,
	AR					= 0,
	Defense				= 0,
	MinDamage			= 0,
	MaxDamage			= 0,
	FireResist			= 0,
	ColdResist			= 0,
	LightResist			= 0,
	PoisonResist		= 0,
	PhysicsResist		= 0,
	PhysicalDamageBase	= 0,
	PhysicalMagicBase	= 0,
	PoisonDamageBase	= 0,
	PoisonMagicBase		= 0,
	ColdDamageBase		= 0,
	ColdMagicBase		= 0,
	FireDamageBase		= 0,
	FireMagicBase		= 0,
	LightingDamageBase	= 0,
	LightingMagicBase	= 0,
	AuraSkillId			= 0,
	AuraSkillLevel		= 0,
	PasstSkillId		= 0,
	PasstSkillLevel		= 0,
	PasstSkillId1		= 0,
	PasstSkillLevel1	= 0,
	PasstSkillId2		= 0,
	PasstSkillLevel2	= 0,
	BaseHeight			= 0,
};

function tbDefault:no()
end

function tbDefault:cancel()
end

tbDefault.tbBubble = 
{
	--[[
	[Npc.BubbleProperty.Task.nIndex] 	= 
	{
		{nProbability = 1, szMsg = Task:GetTaskGossip(nTaskId), Conditions = {}, CallBacks = {}},
		{nProbability = 1, szMsg = Task:GetTaskGossip(nTaskId), Conditions = {}, CallBacks = {}},
	},
	]]--
	[Npc.BubbleProperty.Normal.nIndex] 	= 
	{
		{
			nProbability = 1, 
			szMsg = "你好<pic=1>，找我有什么事吗？",
		},
		{
			nProbability = 1, 
			szMsg = "<pic=2>希望你不要浪费我的时间！",
		},
		{
			nProbability = 1,
			szMsg = "<pic=3>剑侠世界的精彩需要慢慢体会！",
		},
		{
			nProbability = 1,
			szMsg = "<pic=4>欢迎来到剑侠世界！",
		},
		--[[
		{
			nProbability = 1, 
			szMsg = "hi, if you are male you will maybe see this msg",
			tbConditions = 
			{
				{"BubbleCond:IsFaction","2"},
				{"BubbleCond:IsMale"},
			}, 
			tbCallBacks = 
			{
				{"Task:OnAskAward", 1, 1},
				{"Task:OnRefresh", 1, 1, 0},
			},
		},
		]]--
	},
}
