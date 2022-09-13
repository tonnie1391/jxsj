
		 
TreasureMap.tbLuoPanGift = Gift:New();

local tbGift = TreasureMap.tbLuoPanGift;
local tbTreasureMapId = {};

function tbGift:OnSwitch(pPickItem, pDropItem, nX, nY)
	if (not pDropItem) then
		return 1;
	end
	
	if (self:IsTreasureMap(pDropItem) ~= 1) then
		me.Msg("<color=red>La bàn chỉ chứa Tàng Bảo Đồ!<color>");
		return 0;
	end
	
								  
	local pFind = self:First();
	if (pFind) then
		me.Msg("<color=red>1 lần chỉ có thể phân biệt 1 Tàng Bảo Đồ!<color>");
		return 0;
	end

									 
	local nIdentify = pDropItem.GetGenInfo(TreasureMap.ItemGenIdx_IsIdentify);	-- 是否是辨认过的藏宝图
	if (nIdentify ~= 1) then
		me.Msg("<color=red>Chỉ chứa Tàng Bảo Đồ đã đọc qua!<color>")
		return 0;
	end
	
	return	1;
end

function tbGift:OnUpdate()
	self._szContent = "Mời đưa vào tất cả Tàng Bảo Đồ của khu này.";
end

function tbGift:OnOK()
	local pTreasureMap = self:First();
	if (not pTreasureMap) then
		Dialog:SendInfoBoardMsg(me, "<color=red>Mời đưa Tàng Bảo Đồ cần phân biệt vào!<color>");
		return;
	end
	
	if (self:IsTreasureMap(pTreasureMap) ~= 1) then
		Dialog:SendInfoBoardMsg(me, "<color=red>Mời chuyển đi đồ vật không liên quan đến Tàng Bảo Đồ!<color>");
		return;
	end

	
	local nIdentify = pTreasureMap.GetGenInfo(TreasureMap.ItemGenIdx_IsIdentify);	-- 是否是辨认过的藏宝图
	if (nIdentify ~= 1) then
		Dialog:SendInfoBoardMsg(me, "<color=red>La bàn chỉ phân biệt những Tàng Bảo Đồ đã đọc qua!<color>");
		return;
	end	
	
	local nTreasureId		= pTreasureMap.GetGenInfo(TreasureMap.ItemGenIdx_nTreaaureId); -- 所对应宝藏的编号
	local tbTreasureInfo	= TreasureMap:GetTreasureInfo(nTreasureId);
	
	local nMyMapId, nMyPosX, nMyPosY	= me.GetWorldPos();
	local nDestMapId 		= tbTreasureInfo.MapId;
	local nDestPosX			= tbTreasureInfo.MapX;
	local nDestPosY			= tbTreasureInfo.MapY;
	
	if (nMyMapId ~= nDestMapId) then
		Dialog:SendInfoBoardMsg(me, "<color=red>Kho báu được đánh dấu trên bản đồ không ở khu vực này!<color>");
		return;
	end
	
	local szMsg, nDistance = TreasureMap:GetDirection({nMyPosX, nMyPosY}, {nDestPosX, nDestPosY})
	
	if (nDistance > TreasureMap.MAX_POSOFFSET) then
		me.Msg("Kho báu ở <color=yellow>phía "..szMsg.." cách khoảng "..math.floor(nDistance / 6).." trượng<color>!");
	else
		me.Msg("Kho báu ngay dưới chân bạn!");
	end
	
end

function tbGift:IsTreasureMap(pItem)
	if (pItem.nGenre == 18 and pItem.nDetail == 1 and pItem.nParticular == 9) then
		return 1;
	end
	
	return 0;
end



local tbItem = Item:GetClass("luopan");

function tbItem:OnUse()
	Dialog:Gift("TreasureMap.tbLuoPanGift");
end
