--
-- FileName: jianwujiutianyinjianbao.lua
-- Author: hanruofei
-- Time: 2011/3/29 16:57
-- Comment:剑舞九天印鉴包，选择五行
--


local tbItem = Item:GetClass("jianwujiutianyinjianbao");

tbItem.tbTimes = {[13] =30, [14]= 5}		--level对应的有效期

tbItem.tbSeries =
{
	{"剑舞九天印鉴 五行需求：<color=yellow>金<color>", 6}, -- 五行的文字描述和对应五行的剑舞九天印鉴的P（GDPL的P，P决定了剑舞九天印鉴的五行）
	{"剑舞九天印鉴 五行需求：<color=yellow>木<color>", 7},
	{"剑舞九天印鉴 五行需求：<color=yellow>水<color>", 8},
	{"剑舞九天印鉴 五行需求：<color=yellow>火<color>", 9},
	{"剑舞九天印鉴 五行需求：<color=yellow>土<color>", 10},
};     

function tbItem:OnUse()
	local szMsg = "请选择你要领取的剑舞九天印鉴。";
	local tbOpt = {};
	
	for i, v in ipairs(self.tbSeries) do
		table.insert(tbOpt, {v[1], self.GetJianWuJiuTianYinJian, self, me.nId, it.dwId, i, 0, it.nLevel});	
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
		
	Dialog:Say(szMsg, tbOpt);
end

-- 获得制定五行的剑舞九天印鉴,P是GDPL的P
function tbItem:GetJianWuJiuTianYinJian(nPlayerId, nItemId, nSeriesIndex, bSure, nLevel)
	bSure =  bSure or 0;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pItem = KItem.GetObjById( nItemId);
	if not pItem then
		pPlayer.Msg("你的剑舞九天印鉴包不见了。");
		return;
	end

	local szSeriesName, nSeries = unpack(self.tbSeries[nSeriesIndex]);
	
	if bSure == 0 then
		local szMsg = string.format("你确定要领取%s吗？", szSeriesName);
		local tbOpt =
		{
			{"Xác nhận", self.GetJianWuJiuTianYinJian, self,nPlayerId, nItemId, nSeriesIndex, 1, nLevel},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg("你的背包空间不足，请留出1格空间再试");
		return;
	end
	
	-- 删掉剑舞九天印鉴包
	pItem.Delete(pPlayer);
	
	-- 添加制定五行的剑舞九天印鉴
	local pItem = pPlayer.AddItem(1, 18, nSeries, 1);
	if pItem then
		pItem.SetTimeOut(0, GetTime() + self.tbTimes[nLevel] * 24 * 60 * 60); -- 有效期30天
		pItem.Sync();
	else
		Dbg:WriteLog("添加剑舞九天印鉴失败", pPlayer.szName);
	end
end

