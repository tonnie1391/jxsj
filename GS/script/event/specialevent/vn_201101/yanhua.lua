-- 文件名  : yanhua.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-29 15:36:29
-- 描述    : 烟花

local tbItem = Item:GetClass("yanhua_vn");
tbItem.tbSkillId = {
	[1142] = 2201;
	[1144] = 2202;
	[1140] = 2203;
	[1143] = 2204;
	[1146] = 2205;
	[1141] = 2206;
	[1139] = 2207;
	[1145] = 2208;
	}


function tbItem:OnUse()
	local nSkillId = self.tbSkillId[it.nParticular];
	if not nSkillId then
		return 1;
	end
	me.CastSkill(nSkillId, 1, -1, me.GetNpc().nIndex);
	return 1;
end
