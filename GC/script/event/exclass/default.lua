-------------------------------------------------------------------
--File: 	default.lua
--Author: 	sunduoliang
--Date: 	2008-6-20
--Describe:	活动管理系统.扩展函数类
--InterFace1: self:GetParam(szParam);获得获得表中szParam类型的所有参数，返回table
--EventManager:GetTask(nTaskId);		--获得任务变量
--EventManager:SetTask(nTaskId, nValue);--设置任务变量
--EventManager:GetNpcClass(varNpc);		--获得npc表，varNpc为npcId，或者npc类型（类型，普通类型为classname）（特殊类型：_JINGYING:精英，_SHOULING:首领，_ALLNPC:所有npc）
--EventManager:GetNpcClass(varNpc):OnEventDeath(pNpc) --为自定义npc死亡调用函数

-------------------------------------------------------------------

local tbClass = EventManager:GetClass("default")

function tbClass:OnDialog()
	--对话npc
end

function tbClass:OnUse()
	--使用物品
end

function tbClass:PickUp()
	--拾取物品
end

function tbClass:IsPickable()
	--是否允许拾取
end

function tbClass:InitGenInfo()
	--物品生成
	return {};
end

function tbClass:ExeStartFun(tbParam)
	--执行限时事件
end

function tbClass:ExeEndFun(tbParam)
	--执行限时事件结束
end

function tbClass:ExeNpcStartFun(tbParam)
	--招呼npc执行，关键字（MapPath）
end

function tbClass:ExeNpcEndFun(tbParam)
	--招呼npc执行，关键字（MapPath）
end
