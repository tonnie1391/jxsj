------------------------------------------------------
--文件名		：	xingjundan.lua
--功能描述		：	行军单脚本。
------------------------------------------------------
local tbXingJunDan = Item:GetClass("xingjundan");
tbXingJunDan.LASTTIME = 60 * 60;
tbXingJunDan.LEVEL = {6, 8, 10};
tbXingJunDan.SKILLID = {385, 386, 387};

function tbXingJunDan:OnUse()
	if (me.GetNpc().GetRangeDamageFlag() ~= 1) then
		me.Msg("Hành quân đan phải ở trạng thái chinh chiến mới có thể sử dụng.");
		return 0;
	end
	for i = 1, #self.SKILLID do
		me.AddSkillState(self.SKILLID[i], self.LEVEL[it.nLevel], 1, self.LASTTIME * Env.GAME_FPS, 1, 0, 1);
	end
	return 1;
end
