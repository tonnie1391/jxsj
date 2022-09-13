-- 文件名　：chibangbaoxiang.lua
-- 创建者　：sunduoliang
-- 创建时间：2012-06-29 09:15:26
-- 功能    ：翅膀宝箱。

local tbItem = Item:GetClass("chibangbangxiang_ex");
tbItem.ExParam = 1;	--有效期（天）
tbItem.Def_Day = 7; --默认有效期7天
tbItem.tbList = {
	--对应宝箱等级
	[1] = {
			[0] = {"精致翅膀[霸蝶之羽]", {1,26,38,1}}, --男性翅膀
			[1] = {"精致翅膀[妖精之羽]", {1,26,39,1}}, --女性翅膀
		  },
	[2] = {
			[0] = {"华丽翅膀[炽炎之羽]", {1,26,40,1}}, --男性翅膀
			[1] = {"华丽翅膀[精灵之羽]", {1,26,41,1}}, --女性翅膀
		  },
}
function tbItem:OnUse()
	if me.CountFreeBagCell() < 1  then
		Dialog:Say("Hành trang không đủ 1 ô trống.", {"Ta hiểu rồi"});
		return 0;
	end
	local nDay = it.GetExtParam(self.ExParam) or 0;
	if nDay == 0 then
		nDay = self.Def_Day;
	end
	local szMsg = "这是一个散发着神秘光芒的精致宝盒，让人迫不及待的想打开。有心之人可将此宝盒赠与心爱之人。";
	local tbOpt = {};
	local nSex = me.nSex;
	for nLevel, tbLevel in pairs(self.tbList) do
		local tbWing = tbLevel[nSex];
		tbOpt[#tbOpt + 1] = {string.format("打开领取%s级<color=yellow>%s<color>",nLevel, tbWing[1]), self.OnChooseWing, self, nLevel, it.dwId, nDay};
	end
	tbOpt[#tbOpt + 1] = {"我要留着宝盒赠与心上人儿"};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:OnChooseWing(nLevel, dwItemId, nDay)
	local tbLevel = self.tbList[nLevel];
	if (not tbLevel) then
		Dialog:Say("翅膀不存在");
		return 0;
	end
	
	local tbWing = tbLevel[me.nSex];
	local szMsg = string.format("你即将获得%s级<color=yellow>%s<color>，使用期为%s天，你还可以选择领取华丽的另一级翅膀或将此宝物赠与心上人儿。", nLevel, tbWing[1], nDay);
	Dialog:Say(szMsg, {
			{string.format("确认领取%s级%s<color=green>[获取绑定]<color>", nLevel, tbWing[1]), self.OnSureChoose, self, nLevel, dwItemId, nDay},
			{"Để ta suy nghĩ lại"},
		});
end

function tbItem:OnSureChoose(nLevel, dwItemId, nDay)
	local tbLevel = self.tbList[nLevel];
	if (not tbLevel) then
		Dialog:Say("翅膀不存在");
		return 0;
	end

	local pDelItem = KItem.GetObjById(dwItemId);
	if (not pDelItem) then
		Dialog:Say("道具不存在");
		return 0;
	end
	
	if me.DelItem(pDelItem,Player.emKLOSEITEM_USE) == 1 then
		local pItem = me.AddItem(unpack(tbLevel[me.nSex][2]));
		if pItem then
			pItem.Bind(1);
			me.SetItemTimeout(pItem, 60*24*nDay, 0);
		end		
	end
end
