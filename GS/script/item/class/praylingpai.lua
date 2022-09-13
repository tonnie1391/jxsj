-- 文件名　：prayitem.lua
-- 创建者　：zhouchenfei
-- 创建时间：2008-10-09 10:53:33
-- 祈福道具，增加祈福次数

local tbItem 	= Item:GetClass("praylingpai");
tbItem.tbLevelItem = 
{
	--等级, 声望, 次数
	[1] = {30, 5},
	[2] = {200,10},
	[3] = {640,20},
	[4] = {30, 5},
	[5] = {200,10},
}

function tbItem:OnUse()
	local pPlayer	= me;
	local nNowTime	= GetTime();
	local nType		= it.nLevel;
	local nRepute	= self.tbLevelItem[nType][1];
	local nCount	= self.tbLevelItem[nType][2];
	if nType >= 2 then
		if me.IsAccountLock() ~= 0 then
			me.Msg("Tài khoản đang khóa không thể thao tác");
			return 0;
		end
	end
	if (1 == Task.tbPlayerPray:CheckLingPaiUsed(pPlayer, nNowTime)) then
		pPlayer.Msg("Mỗi ngày chỉ có thể sử dụng 1 lệnh bài. Hôm nay không thể sử dụng thêm");
		return 0;
	end
		
	local nFlag, nReputeExt = Player:AddReputeWithAccelerate(pPlayer, 5,4,nRepute);
	
	if (1 == nFlag) then
		pPlayer.Msg("Danh vọng đã đạt cấp cao nhất, không thể tăng thêm");
	end

	Task.tbPlayerPray:AddCountByLingPai(pPlayer, nCount);
	Task.tbPlayerPray:SetLingPaiUsedTime(pPlayer, nNowTime);
	
	pPlayer.Msg(string.format("Nhận được %d lần quay chúc phúc", nCount));
	
	return 1;
end
