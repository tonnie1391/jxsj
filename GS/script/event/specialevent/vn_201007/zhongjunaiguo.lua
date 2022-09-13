-- 文件名  : zhongjunaiguo.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-09 10:59:15
-- 描述    : 越南7月忠君爱国

--VN--
if  not MODULE_GAMESERVER then
	return;
end

SpecialEvent.tbZhongJunAiGuo = SpecialEvent.tbZhongJunAiGuo or {};
local tbZhongJunAiGuo = SpecialEvent.tbZhongJunAiGuo;

tbZhongJunAiGuo.tbJinXi = {18,1,2,3};	--金犀
tbZhongJunAiGuo.tbJinXiSuiPian = {18,	1,982,1};	--金犀碎片

function tbZhongJunAiGuo:OnDialog()
	local szMsg = string.format("拆解公式：金犀(3级) = 10 * 金犀碎片\n", self.nComMoney);
	Dialog:OpenGift(szMsg, nil, {self.OnOpenGiftOk, self});
end

function tbZhongJunAiGuo:OnOpenGiftOk(tbItemObj)
	local nFlag, szMsg = self:ChechItem(tbItemObj);
	if (nFlag == 0) then
		me.Msg(szMsg or "存在不符合的物品或者数量超过限制!");		
		return 0;
	end;
	-- 扣除物品
	for _, pItem in pairs(tbItemObj) do
		if me.DelItem(pItem[1]) ~= 1 then
			return 0;
		end
	end
	me.AddStackItem(self.tbJinXiSuiPian[1], self.tbJinXiSuiPian[2], self.tbJinXiSuiPian[3],self.tbJinXiSuiPian[4], nil, 10);
	EventManager:WriteLog("[越南7月忠君爱国]拆解金犀", me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[越南7月忠君爱国]拆解金犀");
end

-- 检测物品及数量是否符合
function tbZhongJunAiGuo:ChechItem(tbItemObj)	
	if Lib:CountTB(tbItemObj) > 1 or Lib:CountTB(tbItemObj) <= 0 then
		return 0;
	end
	for _, pItem in pairs(tbItemObj) do
		local szFollowCryStal 	= string.format("%s,%s,%s,%s", unpack(self.tbJinXi));
		local szItem		= string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if szFollowCryStal ~= szItem then
			return 0;
		end;
		if pItem[1].IsBind() == 1 then
			return 0, "你的金犀绑定了，无法拆解！";
		end
		if pItem[1].GetGenInfo(1) < pItem[1].GetExtParam(1) then
			return 0, "你放的金犀用过了吧！";
		end
	end
	--背包判断
	if me.CountFreeBagCell() < 1 then		
		return 0, "请预留1格背包空间再来吧！";
	end
	
	return 1;
end;
