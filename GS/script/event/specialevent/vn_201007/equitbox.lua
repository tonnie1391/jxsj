-- 文件名  : equitbox.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-05 17:02:43
-- 描述    : 

--VN--

local tbItem = Item:GetClass("equitling");
tbItem.tbSeries = {"金","木","水","火","土"};
tbItem.tbType = {"内功系", "外功系"};
tbItem.tbSex = {"男", "女"};

function tbItem:OnUse()
	local nPater = it.GetGenInfo(1);
	local nIndex = it.GetGenInfo(2);
	if not SpecialEvent.tbVnChongji.tbAwordItem[nPater] or not SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex] then
		me.Msg("系统错误，请联系GM！");
		return 0;
	end
	local pItem = me.AddItem(unpack(SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][1]));
	if pItem then
		Dbg:WriteLog("VnChongji", "冲级领奖活动", me.szAccount, me.szName, string.format("开启装备箱子获得装备%s", pItem.szName));
	end
	return 1;
end

function tbItem:GetTip()
	local nPater = it.GetGenInfo(1);
	local nIndex = it.GetGenInfo(2);
	local szMsg = "";
	if not SpecialEvent.tbVnChongji.tbAwordItem[nPater] or not SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex] then
		return "";
	end
	szMsg = string.format("装备名：%s\n", SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][2]);
	if SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][3] ~= 0 then
		szMsg = szMsg..string.format("五行推荐：%s\n", self.tbSeries[SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][3]]);
	end
	if SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][4] ~= 0 then
		szMsg = szMsg..string.format("门派推荐：%s\n", self.tbType[SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][4]]);
	end
	if SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][5] ~= 0 then
		szMsg = szMsg..string.format("性别限制：%s\n", self.tbSex[SpecialEvent.tbVnChongji.tbAwordItem[nPater][nIndex][5]]);
	end
	return szMsg;
end
