-- 文件名  : beautyhero_global.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-19 21:47:34
-- 描述    : 全局服 巾帼英雄传送人


local tbNpc = Npc:GetClass("beautyhero_global");


function tbNpc:OnDialog()	
	local szMsg = "庄生晓梦迷蝴蝶，望帝春心托杜鹃。";
	local tbOpt = {};
	table.insert(tbOpt,{"我要去比赛场地",self.GoToMatch,self});
	table.insert(tbOpt,{"我要领取魔棒",self.GetMobang,self});	
	table.insert(tbOpt,{"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg,tbOpt);
end


function tbNpc:GoToMatch()	
	local tbMapInfo = BeautyHero.MAP_MELEE;

	-- 检查条件
	if me.GetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_GLOBAL_MATCHTYPE) == 0 then
		Dialog:Say("你是来玩的吧？没有进入资格！");
		return;
	end
	
	BeautyHero:TrapIn(me,tbMapInfo[1]);	
	return;	
end

function tbNpc:GetMobang()
	if me.GetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_GLOBAL_MATCHTYPE) ~= 2 then
		Dialog:Say("只有粉丝团才能获得魔棒。");
		return;
	end		
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不够。");
		return 0;
	end		
	
	local pItem = me.AddItem(unpack(BeautyHero.ITEM_MOBANG));
	if pItem then
		pItem.Bind(1);
	end
end


