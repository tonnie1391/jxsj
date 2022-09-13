-- 文件名  : taskexp_npc.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-02 21:22:51
-- 描述    : 

Task.TaskExp = Task.TaskExp or {};
local tbTaskExp = Task.TaskExp;

function tbTaskExp:OnDialog(pPlayer)
	-- 开启界面
	self:SyncData(pPlayer);
end

