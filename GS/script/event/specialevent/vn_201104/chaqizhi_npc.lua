-- 文件名　：tree.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 17:10:44
--

local tbNpc = Npc:GetClass("qizhi2011_vn");
SpecialEvent.tbChaQi2011 = SpecialEvent.tbChaQi2011 or {};
local tbChaQi2011 = SpecialEvent.tbChaQi2011;

function tbNpc:OnDialog()
	local szMsg = "";
	local tbOpt = {{"Ta hiểu rồi"}};
	local tbTemp = him.GetTempTable("Npc").tbChaQi2011;
	if self:IsMySelf(him.dwId) == 0 then
		szMsg = "好像不是你的旗帜。";
	else
		--奖励提示	
		if tbTemp.nTreeIndex == 1 then			
			szMsg = string.format("再过%s秒后旗帜就能顺利激活了，请不要离开。", math.ceil(tonumber(Timer:GetRestTime(tbTemp.nTimerId_Die)) / 18));
		else
			szMsg = " 旗帜上好像有个宝盒，要领取吗？";
			table.insert(tbOpt, 1, {"Nhận", tbChaQi2011.GatherSeed, tbChaQi2011, him.dwId, me.nId});
		end		
	end
	Dialog:Say(szMsg, tbOpt);
end

--是不是自己的树
function tbNpc:IsMySelf(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbChaQi2011 or tbTemp.tbChaQi2011.nPlayerId ~= me.nId then
		return 0;
	end
	return 1;
end

