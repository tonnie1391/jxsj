-- 文件名　：fangju_qianghuajuanzhou.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-29 11:51:24
-- 描  述  ：

local tbqianghuajuanzhou = Item:GetClass("fangjuqianghua");
tbqianghuajuanzhou.szInfo = "Bùa cường hóa phòng cụ có thể sử dụng hoặc tặng cho đồng đội. <color=yellow>Tối đa có thể tăng lên +14<color>"

function tbqianghuajuanzhou:OnUse()	
	local tbOpt = {
			{"Sử dụng",	self.OnUseEx, self, it.dwId  },
			{"Tặng cho đồng đội",	DaTaoSha.tbqianghuajuanzhou.Trade, DaTaoSha.tbqianghuajuanzhou, it.dwId, 2},	
			{"Đóng lại"},
	};	
			
	Dialog:Say(self.szInfo,tbOpt);
	
	return 0;
end;

function tbqianghuajuanzhou:OnUseEx(nId)
        local tbFangJu ={"Thăng cấp ","Thăng cấp Y Phục","Thăng cấp Yêu Đái","Thăng cấp Hài Tử","Thăng cấp Hộ Uyển" };   
  	local tbOpt = {};
  	local nMaxQianghua = 14;
 	 tbOpt = Lib:MergeTable( tbOpt,{
		--Item.EQUIPPOS_HEAD			= 0;		-- 头
		--Item.EQUIPPOS_BODY			= 1;		-- 衣服
		--Item.EQUIPPOS_BELT			= 2;		-- 腰带
		--Item.EQUIPPOS_WEAPON		= 3;		-- 武器
		--Item.EQUIPPOS_FOOT			= 4;		-- 鞋子
		--Item.EQUIPPOS_CUFF			= 5;		-- 护腕
		--Item.EQUIPPOS_AMULET		= 6;		-- 护身符
		--Item.EQUIPPOS_RING			= 7;		-- 戒指
		--Item.EQUIPPOS_NECKLACE		= 8;		-- 项链
		--Item.EQUIPPOS_PENDANT		= 9;		-- 腰坠
  			--{"强化武器",  self.OnQiangHua, self ,3, nId},
			--{"强化头盔",  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou, 0, nId},
			--{"强化衣服",  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou, 1, nId},
			--{"强化腰带",  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou, 2, nId},		
			--{"强化鞋子",  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou, 4, nId},
			--{"强化护腕",  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou, 5, nId},
			--{"强化护身符",  self.OnQiangHua, self, 6, nId},
			--{"强化戒指",  self.OnQiangHua, self, 7, nId},
			--{"强化项链",  self.OnQiangHua, self, 8, nId},
			--{"强化腰坠",  self.OnQiangHua, self, 9, nId},	
			{"Đóng lại"},
	});
	if not DaTaoSha:GetPlayerMission(me) then
		return;
	end
	if DaTaoSha:GetPlayerMission(me).nLevel ~= 1 then	
		nMaxQianghua = 14;
	end
	for i = 1,  3 do		
		local pEquip = me.GetItem(Item.ROOM_EQUIP, i - 1, 0);	
		if pEquip and pEquip.nEnhTimes < nMaxQianghua then
			table.insert(tbOpt, 1, {tbFangJu[i],  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou, i - 1, nId});
		end		
	end  	  
	for i = 4,  5 do
		local pEquip = me.GetItem(Item.ROOM_EQUIP, i, 0);	
		if pEquip and pEquip.nEnhTimes < nMaxQianghua then
			table.insert(tbOpt, 1, {tbFangJu[i],  DaTaoSha.tbqianghuajuanzhou.OnQiangHua, DaTaoSha.tbqianghuajuanzhou , i, nId});
		end			
	end  	    
	Dialog:Say(self.szInfo,tbOpt); 
	return 0;
end;
