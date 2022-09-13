-- 文件名　：qiandai_newplayer.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-12-10 16:45:04
-- 功能    ：


local tbItem = Item:GetClass("qiandai_newplayer");

tbItem.tbRate = {33,66,99,100};

tbItem.tbMoney = {
	[1] = {{180, 200, 220, 220},{180,200,220,180}},
	[2] = {{380, 400, 420, 420},{380, 400, 420, 380}},
	[3] = {{580, 600, 620, 620},{580, 600, 620, 580}},
	[4] = {{780, 800, 820, 820},{780, 800, 820,780}},
	[5] = {{980, 1000, 1020, 1020},{980, 1000, 1020,980}},
};

tbItem.tbMaxMoney = {220, 420, 620, 820, 1020};	--最大获取银两数目，背包携带量检查

function tbItem:OnUse()
	local nLevel = it.nLevel;
	local nGroup = 1;	--工作室，正常
	local bBind = 0;
	if IpStatistics:IsStudioRole(me) then
		nGroup = 2;
		bBind = 1;
	end
	if me.nCashMoney + self.tbMaxMoney[nLevel] >me.GetMaxCarryMoney() then
		me.Msg("你的银两携带达上限了，无法获得银两。");
		return 0;
	end
	if me.GetBindMoney() + self.tbMaxMoney[nLevel] >me.GetMaxCarryMoney() then
		me.Msg("你的绑定银两携带达上限了，无法获得绑定银两。");
		return 0;
	end
	local nGrade = 0;	--第几组
	local nRate = MathRandom(100);
	for i , nRateEx in ipairs(self.tbRate) do
		if nRate <= nRateEx then
			nGrade = i;
			break;
		end
	end
	if not self.tbMoney[nLevel] or not self.tbMoney[nLevel][nGroup] or not self.tbMoney[nLevel][nGroup] or not self.tbMoney[nLevel][nGroup][nGrade] then
		me.Msg("道具有问题。");
		return 0;
	end
	if nGrade <= 3 then
		if bBind == 0 then
			me.Earn(self.tbMoney[nLevel][nGroup][nGrade], 100);
		else
			me.AddBindMoney(self.tbMoney[nLevel][nGroup][nGrade]);
		end
	else
		if bBind == 1 then
			me.Earn(self.tbMoney[nLevel][nGroup][nGrade], 100);
		else
			me.AddBindMoney(self.tbMoney[nLevel][nGroup][nGrade]);
		end
	end
	return 1;
end
