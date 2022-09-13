--体服使用
if (EventManager.IVER_bOpenTiFu ~= 1) then
	return;
end

-- 宋金体验专用角色

local tbNpcBai = Npc:GetClass("tmpnpc");

tbNpcBai.nTaskGroupId = 2051;
tbNpcBai.nTaskId1 = 1;	--领取马牌标志
tbNpcBai.nTaskId2 = 2;	--领取包包，银两标志
tbNpcBai.nTaskIdRoute={
	[1]=3,	--领取一个路线装备标志
 	[2]=4,	--领取另一个路线装备标志
}
tbNpcBai.nTaskId3 = 5;	--领取祈福护身符

tbNpcBai.nSongjin_70Level	= 120;					-- 宋金体验把玩家提升到的等级
tbNpcBai.nWeaponLevel		= 10;					-- 宋金体验的武器等级
tbNpcBai.nArmor_Level		= 10;					-- 宋金体验的防具等级
tbNpcBai.nEnhanceLevel		= 8;					-- 宋金体验装备的强化等级
tbNpcBai.nMijiLevel			= 100;					-- 秘籍等级
tbNpcBai.tbQiFuItem = {
	{2,	6,	257,	10}, --金
	{2,	6,	258,	10}, --木
	{2,	6,	259,	10}, --水
	{2,	6,	260,	10}, --火
	{2,	6,	261,	10}, --土
}
tbNpcBai.tbHorse_60Level	= {
	{1, 12, 5, 3, -1},
	{1, 12, 6, 3, -1},
	{1, 12, 7, 3, -1},
	{1, 12, 8, 3, -1},
	{1, 12, 9, 3, -1},
	};	-- 90级马
tbNpcBai.tbExbag_20Grid		= {21, 8, 1, 1};		-- 20格背包
tbNpcBai.nAddedKarmaPerTime	= 3000;					-- 每次增加500点修为
tbNpcBai.nAddedMoney		= 1000000;				-- 每次选择赠送剑侠币的选项可得到100wJXB
tbNpcBai.nBindMoney		= 10000000;					-- 绑定银两
tbNpcBai.nBindCoin		= 5000;						-- 绑定金币
tbNpcBai.nExbagItem			= {}					-- 20格背包
tbNpcBai.tbAddedItem		= {						-- 60级紫装
		{	-- 少林
			{	-- 刀少林
				[0] = {	--男性
					{2,  1, 727-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},	--近身武器meleeweapon.txt
					{2,  3, 828-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--衣服armor
					{2,  9, 826-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--帽子helm
					{2,  8, 406-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--腰带belt
					{2,  7, 408-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--鞋子boots
					{2, 10, 680-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--护腕cuff
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--项链necklace
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--戒指ring
					{2, 11, 406-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--玉佩pendant
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},	--护身符amulet
					{1, 14,1, 2, -1},
				},
				[1] = {	--女性
					{2,  1, 727-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 838-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 836-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 418-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 685-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,1, 2, -1},
				},
			}, 
			{	-- 	棍少林
				[0]	= {
					{2,  1, 737-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 808-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 806-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 406-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 408-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 680-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 406-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 2,  2, -1},
				},
				[1]	= {
					{2,  1, 737-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 818-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 816-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 418-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 685-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 2,  2, -1},
				},
			}, 
		},
		{	-- 天王
			{	-- 	枪天王
				[0]	= {
					{2,  1, 747-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 808-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 806-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 406-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 408-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 680-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 406-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 3, 2, -1},
				},
				[1]	= {
					{2,  1, 747-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 818-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 816-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 418-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 685-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 3, 2, -1},
				},
			},
			{	--	锤天王
				[0]	= {
					{2,  1, 757-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 808-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 806-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 406-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 408-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 680-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 506-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 4, 2, -1},
				},			
				[1]	= {
					{2,  1, 757-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 818-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 816-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 418-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 685-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 206-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 250-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 416-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 207-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 4, 2, -1},
				},
			},
		},
		{	-- 唐门
			{	-- 陷阱唐门
				[0]	= {
					{2,  2,  86-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},	--远程武器rangeweapon.txt
					{2,  3, 848-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 846-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 683-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 5, 2, -1},
				},
				[1]	= {
					{2,  2,  86-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 858-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 856-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10,688-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 5, 2, -1},
				},
			},
			{	-- 	袖箭唐
				[0]	= {
					{2,  2,  96-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},	--远程武器rangeweapon.txt
					{2,  3, 848-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 846-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 683-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 6, 2, -1},
				},
				[1]	= {
					{2,  2,  96-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 858-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 856-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10,688-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 6, 2, -1},
				},
			},
		},
		{	-- 五毒
			{	-- 刀毒
				[0]	= {
					{2,  1, 767-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 848-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 846-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 683-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,7, 2, -1},
				},
				[1]	= {
					{2,  1, 767-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 858-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 856-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10,688-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 447-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,7, 2, -1},
				},
			},
			{	-- 掌毒
				[0]	= {
					{2,  1, 777-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 868-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 866-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,8, 2, -1},
				},
				[1]	= {
					{2,  1, 777-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 878-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 876-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,8, 2, -1},
				},
			},
		},
		{	-- 峨嵋
			{	-- 掌em
				[0] = {
					{2,  1, 807-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 908-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 906-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,9, 2, -1},					
				},
				[1]	= {
					{2,  1, 807-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 918-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 916-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,9, 2, -1},
				}
			},
			{	-- 辅助
				[0] = {
					{2,  1, 817-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 908-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 906-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,10, 2, -1},					
				},
				[1]	= {
					{2,  1, 817-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 918-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 916-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,10, 2, -1},
				}
			},
		},
		{	-- 翠烟
			{	-- 剑翠
				[0]	= {
					{2,  1, 817-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 908-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 906-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,11, 2, -1},
				},
				[1]	= {
					{2,  1, 817-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 918-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 916-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,11, 2, -1},
				},
			},
			{	-- 刀翠
				[0]	= {
					{2,  1, 787-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 908-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 906-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 682-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 251-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,12, 2, -1},
				},
				[1]	= {
					{2,  1, 787-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 918-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 916-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 687-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 251-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,12, 2, -1},
				},       
			},
		},
		{	-- 丐帮
			{	-- 掌丐  
				[0]	= {  
					{2,  1, 847-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 748-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 746-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 368-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 468-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 236-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,13, 2, -1},
				},
				[1]	= {
					{2,  1, 847-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 758-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 756-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 378-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 478-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 236-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,13, 2, -1},
				},
			},
			{	-- 棍丐
				[0]	= {
					{2,  1, 827-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 748-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 746-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 368-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 679-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 249-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,14, 2, -1},
				},
				[1]	= {
					{2,  1, 827-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 758-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 756-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 378-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 684-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 249-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,14, 2, -1},
				}
			},
		},
		{	-- 天忍
			{	-- 战忍
				[0]	= {
					{2,  1, 837-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 728-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 726-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 368-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 679-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 249-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,15, 2, -1},
				},
				[1]	= {
					{2,  1, 837-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 738-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 736-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 378-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 684-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 249-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,15, 2, -1},
				};
			},
			{	-- 魔忍
				[0]	= {
					{2,  1, 857-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 748-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 746-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 368-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 468-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 236-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 366-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,16, 2, -1},
				},
				[1]	= {
					{2,  1, 857-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 758-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 756-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 378-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 478-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 186-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 236-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 376-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 187-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,16, 2, -1},
				},
			},
		},
		{	-- 武当
			{	-- 气武
				[0]	= {
					{2,  1, 887-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 988-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 986-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,17, 2, -1},
				},
				[1]	= {
					{2,  1, 887-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 998-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 996-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,17, 2, -1},
				},
			},
			{	-- 剑武
				[0]	= {
					{2,  1, 877-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 968-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 966-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 681-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 248-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,18, 2, -1},
				},
				[1]	= {
					{2,  1, 877-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 978-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 976-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 686-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 248-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,18, 2, -1},
				},
			},

		},
		{	-- 昆仑
			{	-- 刀昆
				[0]	= {
					{2,  1, 867-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 988-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 986-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 681-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 248-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,19, 2, -1},
				},
				[1]	= {
					{2,  1, 867-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 998-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 996-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 686-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 248-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14,19, 2, -1},
				},
			},
			{	-- 剑昆
				[0]	= {
					{2,  1, 897-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 988-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 986-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 486-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 20, 2, -1},
				}, 
				[1]	= {
					{2,  1, 897-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
				  	{2,  3, 998-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
			   		{2,  9, 996-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {2,  8, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {2,  7, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {2, 10, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {2,  5, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {2, 11, 496-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
                    {1, 14, 20, 2, -1},
                },
            },
		},
		{	-- 明教
			{	-- 锤明教
				[0] = {
					{2,  1, 987-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 848-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 846-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 683-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 21, 2, -1},
				},
				[1]	= {
					{2,  1, 987-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 858-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 856-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10,688-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 21, 2, -1},
				},
			},
			{	-- 剑明教
				[0]	= {
					{2,  1, 977-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 868-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 866-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 428-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 426-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 22, 2, -1},
				},
				[1]	= {
					{2,  1, 977-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 878-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 876-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 438-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 216-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 436-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 217-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 22, 2, -1},
				},
			},
		},
		{	-- 段氏
			{	-- 指段氏
				[0] = {
					{2,  1, 797-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 908-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 906-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 682-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 251-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 23, 2, -1},
				},
				[1]	= {
					{2,  1, 797-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 918-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 916-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 687-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 251-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 23, 2, -1},
				},
			},
			{	-- 气段氏
				[0]	= {
					{2,  1, 817-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 908-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 906-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 448-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 446-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 24, 2, -1},
				},
				[1]	= {
					{2,  1, 817-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 918-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 916-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 458-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 226-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 456-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 227-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 24, 2, -1},
				},
			},
		},
};

tbNpcBai.tbArmorsList = {--series,sex,physical,材料,Genre,DetailType,ParticularType,Level
{	1	,	0	,	1	,	-1		,	4	,	10	,	1	,	10	,	}	,
{	2	,	0	,	1	,	-1		,	4	,	10	,	7	,	10	,	}	,
{	3	,	0	,	1	,	-1		,	4	,	10	,	19	,	10	,	}	,
{	4	,	0	,	1	,	-1		,	4	,	10	,	31	,	10	,	}	,
{	5	,	0	,	1	,	-1		,	4	,	10	,	43	,	10	,	}	,
{	1	,	1	,	1	,	-1		,	4	,	10	,	2	,	10	,	}	,
{	2	,	1	,	1	,	-1		,	4	,	10	,	8	,	10	,	}	,
{	3	,	1	,	1	,	-1		,	4	,	10	,	20	,	10	,	}	,
{	4	,	1	,	1	,	-1		,	4	,	10	,	32	,	10	,	}	,
{	5	,	1	,	1	,	-1		,	4	,	10	,	44	,	10	,	}	,
{	1	,	1	,	2	,	-1		,	4	,	10	,	436	,	10	,	}	,
{	2	,	1	,	2	,	-1		,	4	,	10	,	10	,	10	,	}	,
{	3	,	1	,	2	,	-1		,	4	,	10	,	22	,	10	,	}	,
{	4	,	1	,	2	,	-1		,	4	,	10	,	34	,	10	,	}	,
{	5	,	1	,	2	,	-1		,	4	,	10	,	46	,	10	,	}	,
{	1	,	0	,	2	,	-1		,	4	,	10	,	435	,	10	,	}	,
{	2	,	0	,	2	,	-1		,	4	,	10	,	9	,	10	,	}	,
{	3	,	0	,	2	,	-1		,	4	,	10	,	21	,	10	,	}	,
{	4	,	0	,	2	,	-1		,	4	,	10	,	33	,	10	,	}	,
{	5	,	0	,	2	,	-1		,	4	,	10	,	45	,	10	,	}	,
{	1	,	0	,	-1	,	-1		,	4	,	11	,	1	,	10	,	}	,
{	2	,	0	,	-1	,	-1		,	4	,	11	,	7	,	10	,	}	,
{	3	,	0	,	-1	,	-1		,	4	,	11	,	13	,	10	,	}	,
{	4	,	0	,	-1	,	-1		,	4	,	11	,	19	,	10	,	}	,
{	5	,	0	,	-1	,	-1		,	4	,	11	,	25	,	10	,	}	,
{	1	,	1	,	-1	,	-1		,	4	,	11	,	2	,	10	,	}	,
{	2	,	1	,	-1	,	-1		,	4	,	11	,	8	,	10	,	}	,
{	3	,	1	,	-1	,	-1		,	4	,	11	,	14	,	10	,	}	,
{	4	,	1	,	-1	,	-1		,	4	,	11	,	20	,	10	,	}	,
{	5	,	1	,	-1	,	-1		,	4	,	11	,	26	,	10	,	}	,
{	1	,	0	,	-1	,	-1		,	4	,	7	,	1	,	10	,	}	,
{	2	,	0	,	-1	,	-1		,	4	,	7	,	7	,	10	,	}	,
{	3	,	0	,	-1	,	-1		,	4	,	7	,	13	,	10	,	}	,
{	4	,	0	,	-1	,	-1		,	4	,	7	,	19	,	10	,	}	,
{	5	,	0	,	-1	,	-1		,	4	,	7	,	25	,	10	,	}	,
{	1	,	1	,	-1	,	-1		,	4	,	7	,	2	,	10	,	}	,
{	2	,	1	,	-1	,	-1		,	4	,	7	,	8	,	10	,	}	,
{	3	,	1	,	-1	,	-1		,	4	,	7	,	14	,	10	,	}	,
{	4	,	1	,	-1	,	-1		,	4	,	7	,	20	,	10	,	}	,
{	5	,	1	,	-1	,	-1		,	4	,	7	,	26	,	10	,	}	,
{	2	,	0	,	-1	,	"布"		,	4	,	3	,	35	,	10	,	}	,
{	3	,	0	,	-1	,	"布"		,	4	,	3	,	41	,	10	,	}	,
{	5	,	0	,	-1	,	"布"		,	4	,	3	,	47	,	10	,	}	,
{	1	,	0	,	-1	,	"皮"		,	4	,	3	,	53	,	10	,	}	,
{	2	,	0	,	-1	,	"皮"		,	4	,	3	,	59	,	10	,	}	,
{	4	,	0	,	-1	,	"皮"		,	4	,	3	,	65	,	10	,	}	,
{	1	,	0	,	-1	,	"铁"		,	4	,	3	,	71	,	10	,	}	,
{	3	,	0	,	-1	,	"铁"		,	4	,	3	,	77	,	10	,	}	,
{	4	,	0	,	-1	,	"铁"		,	4	,	3	,	83	,	10	,	}	,
{	5	,	0	,	-1	,	"铁"		,	4	,	3	,	89	,	10	,	}	,
{	2	,	1	,	-1	,	"布"		,	4	,	3	,	36	,	10	,	}	,
{	3	,	1	,	-1	,	"布"		,	4	,	3	,	42	,	10	,	}	,
{	5	,	1	,	-1	,	"布"		,	4	,	3	,	48	,	10	,	}	,
{	1	,	1	,	-1	,	"皮"		,	4	,	3	,	54	,	10	,	}	,
{	2	,	1	,	-1	,	"皮"		,	4	,	3	,	60	,	10	,	}	,
{	4	,	1	,	-1	,	"皮"		,	4	,	3	,	66	,	10	,	}	,
{	1	,	1	,	-1	,	"铁"		,	4	,	3	,	72	,	10	,	}	,
{	3	,	1	,	-1	,	"铁"		,	4	,	3	,	78	,	10	,	}	,
{	4	,	1	,	-1	,	"铁"		,	4	,	3	,	84	,	10	,	}	,
{	5	,	1	,	-1	,	"铁"		,	4	,	3	,	90	,	10	,	}	,
{	1	,	-1	,	-1	,	-1		,	4	,	6	,	94	,	10	,	}	,
{	2	,	-1	,	-1	,	-1		,	4	,	6	,	99	,	10	,	}	,
{	3	,	-1	,	-1	,	-1		,	4	,	6	,	104	,	10	,	}	,
{	4	,	-1	,	-1	,	-1		,	4	,	6	,	109	,	10	,	}	,
{	5	,	-1	,	-1	,	-1		,	4	,	6	,	114	,	10	,	}	,
{	1	,	-1	,	1	,	-1		,	4	,	4	,	118	,	10	,	}	,
{	2	,	-1	,	1	,	-1		,	4	,	4	,	121	,	10	,	}	,
{	3	,	-1	,	1	,	-1		,	4	,	4	,	127	,	10	,	}	,
{	4	,	-1	,	1	,	-1		,	4	,	4	,	133	,	10	,	}	,
{	5	,	-1	,	1	,	-1		,	4	,	4	,	139	,	10	,	}	,
{	1	,	-1	,	2	,	-1		,	4	,	4	,	443	,	10	,	}	,
{	2	,	-1	,	2	,	-1		,	4	,	4	,	124	,	10	,	}	,
{	3	,	-1	,	2	,	-1		,	4	,	4	,	130	,	10	,	}	,
{	4	,	-1	,	2	,	-1		,	4	,	4	,	136	,	10	,	}	,
{	5	,	-1	,	2	,	-1		,	4	,	4	,	142	,	10	,	}	,
{	2	,	0	,	-1	,	"布"		,	4	,	9	,	197	,	10	,	}	,
{	3	,	0	,	-1	,	"布"		,	4	,	9	,	217	,	10	,	}	,
{	5	,	0	,	-1	,	"布"		,	4	,	9	,	257	,	10	,	}	,
{	1	,	0	,	-1	,	"皮"		,	4	,	9	,	177	,	10	,	}	,
{	2	,	0	,	-1	,	"皮"		,	4	,	9	,	195	,	10	,	}	,
{	4	,	0	,	-1	,	"皮"		,	4	,	9	,	237	,	10	,	}	,
{	1	,	0	,	-1	,	"铁"		,	4	,	9	,	175	,	10	,	}	,
{	3	,	0	,	-1	,	"铁"		,	4	,	9	,	215	,	10	,	}	,
{	4	,	0	,	-1	,	"铁"		,	4	,	9	,	235	,	10	,	}	,
{	5	,	0	,	-1	,	"铁"		,	4	,	9	,	255	,	10	,	}	,
{	1	,	0	,	-1	,	-1		,	4	,	8	,	341	,	10	,	}	,
{	2	,	0	,	-1	,	-1		,	4	,	8	,	361	,	10	,	}	,
{	3	,	0	,	-1	,	-1		,	4	,	8	,	381	,	10	,	}	,
{	4	,	0	,	-1	,	-1		,	4	,	8	,	401	,	10	,	}	,
{	5	,	0	,	-1	,	-1		,	4	,	8	,	421	,	10	,	}	,
{	1	,	1	,	-1	,	-1		,	4	,	8	,	342	,	10	,	}	,
{	2	,	1	,	-1	,	-1		,	4	,	8	,	362	,	10	,	}	,
{	3	,	1	,	-1	,	-1		,	4	,	8	,	382	,	10	,	}	,
{	4	,	1	,	-1	,	-1		,	4	,	8	,	402	,	10	,	}	,
{	5	,	1	,	-1	,	-1		,	4	,	8	,	422	,	10	,	}	,
{	1	,	-1	,	1	,	-1		,	4	,	5	,	266	,	10	,	}	,
{	2	,	-1	,	1	,	-1		,	4	,	5	,	274	,	10	,	}	,
{	3	,	-1	,	1	,	-1		,	4	,	5	,	290	,	10	,	}	,
{	4	,	-1	,	1	,	-1		,	4	,	5	,	306	,	10	,	}	,
{	5	,	-1	,	1	,	-1		,	4	,	5	,	322	,	10	,	}	,
{	1	,	-1	,	2	,	-1		,	4	,	5	,	446	,	10	,	}	,
{	2	,	-1	,	2	,	-1		,	4	,	5	,	282	,	10	,	}	,
{	3	,	-1	,	2	,	-1		,	4	,	5	,	298	,	10	,	}	,
{	4	,	-1	,	2	,	-1		,	4	,	5	,	314	,	10	,	}	,
{	5	,	-1	,	2	,	-1		,	4	,	5	,	330	,	10	,	}	,
{	2	,	1	,	-1	,	"布"		,	4	,	9	,	198	,	10	,	}	,
{	3	,	1	,	-1	,	"布"		,	4	,	9	,	218	,	10	,	}	,
{	5	,	1	,	-1	,	"布"		,	4	,	9	,	258	,	10	,	}	,
{	1	,	1	,	-1	,	"皮"		,	4	,	9	,	182	,	10	,	}	,
{	2	,	1	,	-1	,	"皮"		,	4	,	9	,	200	,	10	,	}	,
{	4	,	1	,	-1	,	"皮"		,	4	,	9	,	242	,	10	,	}	,
{	1	,	1	,	-1	,	"铁"		,	4	,	9	,	180	,	10	,	}	,
{	3	,	1	,	-1	,	"铁"		,	4	,	9	,	220	,	10	,	}	,
{	4	,	1	,	-1	,	"铁"		,	4	,	9	,	240	,	10	,	}	,
{	5	,	1	,	-1	,	"铁"		,	4	,	9	,	260	,	10	,	}	,
}

tbNpcBai.tbWeaponsList = {--,Genre,DetailType,ParticularType,Level
{	2	,	1	,	551	,	10	,},
{	2	,	1	,	561	,	10	,},
{	2	,	1	,	571	,	10	,},
{	2	,	1	,	581	,	10	,},
{	2	,	2	,	70	,	10	,},
{	2	,	2	,	80	,	10	,},
{	2	,	1	,	591	,	10	,},
{	2	,	1	,	601	,	10	,},
{	2	,	1	,	631	,	10	,},
{	2	,	1	,	641	,	10	,},
{	2	,	1	,	641	,	10	,},
{	2	,	1	,	611	,	10	,},
{	2	,	1	,	671	,	10	,},
{	2	,	1	,	651	,	10	,},
{	2	,	1	,	661	,	10	,},
{	2	,	1	,	681	,	10	,},
{	2	,	1	,	711	,	10	,},
{	2	,	1	,	701	,	10	,},
{	2	,	1	,	691	,	10	,},
{	2	,	1	,	721	,	10	,},
{	2	,	1	,	971	,	10	,},
{	2	,	1	,	981	,	10	,},
{	2	,	1	,	621	,	10	,},
{	2	,	1	,	641	,	10	,},
{	2	,	1	,	731	,	10	,},
{	2	,	1	,	741	,	10	,},
{	2	,	1	,	751	,	10	,},
{	2	,	1	,	761	,	10	,},
{	2	,	2	,	90	,	10	,},
{	2	,	2	,	100	,	10	,},
{	2	,	1	,	771	,	10	,},
{	2	,	1	,	781	,	10	,},
{	2	,	1	,	811	,	10	,},
{	2	,	1	,	821	,	10	,},
{	2	,	1	,	821	,	10	,},
{	2	,	1	,	791	,	10	,},
{	2	,	1	,	851	,	10	,},
{	2	,	1	,	831	,	10	,},
{	2	,	1	,	841	,	10	,},
{	2	,	1	,	861	,	10	,},
{	2	,	1	,	891	,	10	,},
{	2	,	1	,	881	,	10	,},
{	2	,	1	,	871	,	10	,},
{	2	,	1	,	901	,	10	,},
{	2	,	1	,	991	,	10	,},
{	2	,	1	,	1001	,	10	,},
{	2	,	1	,	801	,	10	,},
{	2	,	1	,	821	,	10	,},
}

tbNpcBai.tbBeltList = {
--series,sex,physical,材料,Genre	,DetailType,ParticularType,Level
{	1	,	0	,	-1	,	-1	,	4	,	8	,	457	,	10	,	}	,
{	1	,	1	,	-1	,	-1	,	4	,	8	,	458	,	10	,	}	,
{	2	,	0	,	-1	,	-1	,	4	,	8	,	461	,	10	,	}	,
{	2	,	1	,	-1	,	-1	,	4	,	8	,	462	,	10	,	}	,
{	3	,	0	,	-1	,	-1	,	4	,	8	,	465	,	10	,	}	,
{	3	,	1	,	-1	,	-1	,	4	,	8	,	466	,	10	,	}	,
{	4	,	0	,	-1	,	-1	,	4	,	8	,	469	,	10	,	}	,
{	4	,	1	,	-1	,	-1	,	4	,	8	,	470	,	10	,	}	,
{	5	,	0	,	-1	,	-1	,	4	,	8	,	473	,	10	,	}	,
{	5	,	1	,	-1	,	-1	,	4	,	8	,	474	,	10	,	}	,
}

tbNpcBai.tbFixList = {
--路线,五行,内外功,布甲皮
{"刀少",1,1,"皮",},
{"棍少",1,1,"铁",},
{"枪天",1,1,"铁",},
{"锤天",1,1,"铁",},
{"陷阱",2,1,"皮",},
{"袖箭",2,1,"皮",},
{"刀毒",2,1,"皮",},
{"掌毒",2,2,"皮",},
{"掌峨",3,2,"布",},
{"辅峨",3,2,"布",},
{"剑翠",3,2,"布",},
{"刀翠",3,1,"布",},
{"掌丐",4,2,"皮",},
{"棍丐",4,1,"皮",},
{"战忍",4,1,"皮",},
{"魔忍",4,2,"皮",},
{"气武",5,2,"布",},
{"剑武",5,1,"布",},
{"刀昆",5,1,"布",},
{"剑昆",5,2,"布",},
{"锤明",2,1,"皮",},
{"剑明",2,2,"皮",},
{"指段",3,1,"布",},
{"气段",3,2,"布",},
}

-- 对话
function tbNpcBai:OnDialog()
	Dialog:Say("宋金专用体验角色方案", {
			{"升级为体服角色", self.LevelUpPlayer, self, 1},
			{"获得宋金专用装备+4", self.GetEquipFaction, self, 1, 4},
			{"获得宋金专用装备+8", self.GetEquipFaction, self, 1, 8},
			{"获得宋金专用装备+10", self.GetEquipFaction, self, 1, 10},
			{"获得宋金专用装备+12", self.GetEquipFaction, self, 1, 12},
			{"获得宋金专用装备+14", self.GetEquipFaction, self, 1, 14},
			{"获得宋金专用装备+16", self.GetEquipFaction, self, 1, 16},
			{"外网测试用角色配置", self.WaiwangCeshi, self},
			{"获得90级马", self.GetHorse_60Level, self},
			{"秘籍等级提升", self.LevelUpBook, self},
			{"领取修连珠无限洗点", self.GetXiuLianZhu, self},
			{"领取祈福护身符", self.GetQiFuRing, self},
			{"领取和升级五行印", self.UpDateWuXingYin, self},
			--{"获得剑侠币和扩展背包", self.AddMoneyAndExbag, self};
			{"Kết thúc đối thoại"},
	});
end

--外网测试用角色配置
function tbNpcBai:WaiwangCeshi()
	local tbOpt = {
		{"领生活用品", self.GetSundries, self},
		{"领武器", self.GetWeapons, self},
		--{"领+1腰带", self.GetBelt, self, self.tbBeltList},
		{"领防具", self.GetArmors, self, self.tbArmorsList},
		{"领中级秘籍和升级秘籍技能", self.GetMiji, self},
		{"秘籍等级提升", self.LevelUpBook, self},
		{"洗点", self.Xidian, self},
		{"Ta chỉ đến xem thôi"},
	}
	Dialog:Say("您想要什么?", tbOpt);
end

function tbNpcBai:GetSundries()
	if me.nRouteId <= 0 then
		Dialog:Say("入门后再来吧", tbOpt);
		return
	end
	--武林秘籍和洗髓经
	for i=1,5 do me.AddItem(18,1,191,1).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,191,2).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,192,1).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,192,2).Bind(1) end;
	--90级马
	for ni, tbItem in pairs(self.tbHorse_60Level) do
		local pItem = me.AddItem(unpack(tbItem));
		if pItem then
			pItem.Bind(1);
		end
	end
	--雏凤，混天，御空披风各一件
	me.AddItem(1,17,me.nSeries*2+me.nSex-1,7).Bind(1);
	--me.AddItem(1,17,me.nSeries*2+me.nSex-1,6).Bind(1);
	--me.AddItem(1,17,me.nSeries*2+me.nSex-1,5).Bind(1);
	--无限传送符
	--me.AddItem(18,1,235,1).Bind(1);
	--领背包
	--for i=1,3 do me.AddItem(21,7,1,1).Bind(1) end
	--领五行印
	local a = me.AddItem(1,16,me.nFaction,1);
	--for i=1,2 do Item: SetSignetMagic(a,i,300,0) end;
	local b = me.AddItem(1,16,me.nFaction,1);
	--for i=1,2 do Item: SetSignetMagic(b,i,500,0) end;
	--轻功和中级秘籍
	me.AddFightSkill(10,20);
	for i=1200,1222 do me.AddFightSkill(i,10) end
end

function tbNpcBai:Xidian()
	me.ResetFightSkillPoint();
	me.SetTask(2,1,1);
	me.UnAssignPotential();
end

function tbNpcBai:GetWeapons()
	local nItemRouteId = (me.nFaction-1)*2 +me.nRouteId;
	if me.nRouteId <= 0 then
		Dialog:Say("入门后再来吧", tbOpt);
		return
	end
	local tmpItem = {unpack(self.tbWeaponsList[nItemRouteId])}
	--tmpItem[6] = 12
	--me.AddItem(unpack(tmpItem)).Bind(1);
	tmpItem[6] = 14
	me.AddItem(unpack(tmpItem)).Bind(1);
	--tmpItem[6] = 15
	--me.AddItem(unpack(tmpItem)).Bind(1);
end

function tbNpcBai:GetItems(tbItemList,nQianghua)
	if me.nRouteId <= 0 then
		Dialog:Say("入门后再来吧", tbOpt);
		return
	end
	for i=1,#tbItemList do
		local nItemRouteId = (me.nFaction-1)*2 +me.nRouteId;
		if me.nRouteId ~= 0 then 
			if tbItemList[i][1] == self.tbFixList[nItemRouteId][2] or tbItemList[i][1] == -1 then
				if tbItemList[i][2] == me.nSex or tbItemList[i][2] == -1 then
					if tbItemList[i][3] == self.tbFixList[nItemRouteId][3] or tbItemList[i][3] == -1 then
						if tbItemList[i][4] == self.tbFixList[nItemRouteId][4] or tbItemList[i][4] == -1 then
							me.AddItem(tbItemList[i][5],tbItemList[i][6],tbItemList[i][7],tbItemList[i][8],-1,nQianghua).Bind(1);
						end
					end
				end
			end
		end
	end	
end

function tbNpcBai:GetArmors(tbItemList)
	--self:GetItems(tbItemList,12);
	self:GetItems(tbItemList,14);
end

function tbNpcBai:GetBelt(tbItemList)
	self:GetItems(tbItemList,14);
end

function tbNpcBai:GetMiji()
	if (me.nRouteId == 0) then
		Dialog:Say("入门后再来吧", tbOpt);
		return;
	end
	local tbEquip	= self.tbAddedItem[me.nFaction][me.nRouteId][me.nSex];
	local tbTmp = {unpack(tbEquip[#tbEquip])};
	local tmpMiji = me.AddItem(unpack(tbTmp));
end

function tbNpcBai:UpDateWuXingYin()
	local tbOpt = {
		{"领取五行印", self.GetWuXingYin, self},
		{"升级五行印-相克强化", self.UpWuXingYin, self, 1},
		{"升级五行印-相克弱化", self.UpWuXingYin, self, 2},
		{"Ta chỉ đến xem thôi"},
	}
	Dialog:Say("您想要什么?", tbOpt);
end

function tbNpcBai:GetWuXingYin()
	if me.nFaction <= 0 then
		Dialog:Say("必须加入门派才能领取五行印。");
		return 0;		
	end	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end
	local pItem = me.AddItem(1,16,me.nFaction,1);
	if pItem then
		pItem.Bind(1);
	end
	Dialog:Say("您成功领取了五行印.");		
end

function tbNpcBai:UpWuXingYin(nMagicIndex)
	local pSignet = me.GetItem(Item.ROOM_EQUIP,Item.EQUIPPOS_SIGNET, 0);
	if not pSignet then
		Dialog:Say("您身上没有五行印.");
		return 0;
	end
	local nLevel 	= pSignet.GetGenInfo(nMagicIndex * 2 - 1, 0);
	if nLevel >= 1000 then
		Dialog:Say("您的五行印该属性已达到满级.");
		return 0;
	end
	nLevel = nLevel + 300;
	if nLevel > 1000 then
		nLevel = 1000;
	end
	Item:SetSignetMagic(pSignet, nMagicIndex, nLevel, 0);
	Dialog:Say("成功升级五行印属性,如果属性未满,您可以继续找我升级.");
end

function tbNpcBai:GetQiFuRing()
	if me.GetTask(self.nTaskGroupId,self.nTaskId3) ~= 0 then
		Dialog:Say("已领取过祈福护身符了。");
		return 0;
	end
	if me.nFaction <= 0 or me.nSeries == 0 then
		Dialog:Say("必须加入门派才能领取祈福护身符。");
		return 0;		
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end
	local pItem = me.AddItem(unpack(self.tbQiFuItem[me.nSeries]));
	if pItem then
		pItem.Bind(1);
		me.SetTask(self.nTaskGroupId,self.nTaskId3, 1);
	end
	Dialog:Say("您成功领取了祈福护身符.");
end

function tbNpcBai:GetXiuLianZhu()
		local nCount = me.GetItemCountInBags(18,1,16,1);
		if (nCount == 0) then
			local tbXiulianzhuItem = { 18, 1, 16, 1 }
			local tbBaseProp = KItem.GetItemBaseProp(unpack(tbXiulianzhuItem));
			if not tbBaseProp then
				return;
			end
			
			local tbItem =
			{
				nGenre		= tbXiulianzhuItem[1],
				nDetail		= tbXiulianzhuItem[2],
				nParticular	= tbXiulianzhuItem[3],
				nLevel		= tbXiulianzhuItem[4],
				nSeries		= (tbBaseProp.nSeries > 0) and tbBaseProp.nSeries or 0,
				bBind		= KItem.IsItemBindByBindType(tbBaseProp.nBindType),
				nCount 		= 1;
			};
		
			if (0 == me.CanAddItemIntoBag(tbItem)) then
				me.Msg("背包已满");
				return;
			end	
		
			tbXiulianzhuItem[5] = tbItem.nSeries;
			me.AddItem(unpack(tbXiulianzhuItem));
			me.Msg("你获得一颗修炼珠!");			
		else
			Dialog:Say("<color=red>你已经拥有修炼珠了！<color>");
		end	
end

function tbNpcBai:AddMoneyAndExbag()
	if me.GetTask(self.nTaskGroupId,self.nTaskId2) ~= 0 then
		Dialog:Say("已领取过剑侠币和扩展背包。");
		return 0;		
	end
	if me.CountFreeBagCell() < 3 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	me.AddBindMoney(self.nBindMoney, 100);
	me.AddBindCoin(self.nBindCoin, 100);
	for i = 1, 3 do
		local pItem = me.AddItem(unpack(self.tbExbag_20Grid))
		if pItem then
			pItem.Bind(1)
		end
	end
	me.SetTask(self.nTaskGroupId,self.nTaskId2,1)
end

-- 升级角色
function tbNpcBai:LevelUpPlayer(nPosStartIdx)
	--if (me.nLevel >= self.nSongjin_70Level) then
	--	Dialog:Say("已升到指定等级。");
	--	return;
	--end
	
	if (me.nFaction ~= 0) then
		self:JoinFactionLevelUp(me.nFaction);
		return;
	end
	
	local tbOpt		= {};
	local nCount	= 9;
	for i = nPosStartIdx, Player.FACTION_NUM do
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.LevelUpPlayer, self, i - 1};
			break;
		end
		tbOpt[#tbOpt + 1]	= {Player:GetFactionRouteName(i), self.JoinFactionLevelUp, self, i};
		nCount	= nCount - 1;
	end
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("加入门派", tbOpt);
end

-- 加入门派
function tbNpcBai:JoinFactionLevelUp(nIndex)
	if (me.nFaction == 0) then
		local nSexLimit	= Player.tbFactions[nIndex].nSexLimit;
		if (nSexLimit >= 0 and nSexLimit ~= me.nSex) then
			me.Msg("对不起，该门派不收"..Player.SEX[me.nSex].."弟子！");
			return;
		end
		me.JoinFaction(nIndex);
	end
	ST_LevelUp(self.nSongjin_70Level - me.nLevel);
	me.AddBindMoney(self.nBindMoney, 100);
	me.AddBindCoin(self.nBindCoin, 100);
	me.Earn(100, Player.emKEARN_EVENT);
	for i = 1, 3 do
		local pItem = me.AddItem(unpack(self.tbExbag_20Grid))
		if pItem then
			pItem.Bind(1)
		end
	end
	me.SetTask(self.nTaskGroupId,self.nTaskId2,1);
	--for i=1,5 do me.AddItem(18,1,191,1) end;
	--for i=1,5 do me.AddItem(18,1,191,2) end;
	--for i=1,5 do me.AddItem(18,1,192,1) end;
	--for i=1,5 do me.AddItem(18,1,192,2) end;
	--me.AddItem(1,17,me.nSeries*2+me.nSex-1,5);

	
end

-- 获得60级紫装所属的门派
function tbNpcBai:GetEquipFaction(nPosStartIdx, nQiangHua)
	local tbOpt		= {};
	local nCount	= 9;
	for i = nPosStartIdx, Player.FACTION_NUM do
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.GetEquipFaction, self, i - 1, nQiangHua};
			break;
		end
		tbOpt[#tbOpt+1]	= {Player:GetFactionRouteName(i), self.GetEquipRoute, self, i, 1, nQiangHua};
		nCount	= nCount - 1;
	end;
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("选择你需要的紫装的门派", tbOpt);
end

-- 获得60级紫装所属的路线
function tbNpcBai:GetEquipRoute(nFactionId, nPosStartIdx, nQiangHua)
	local tbOpt		= {};
	local nCount	= 9;
	for i = nPosStartIdx, #Player.tbFactions[nFactionId].tbRoutes do
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.GetEquipRoute, self, nFactionId, i - 1, nQiangHua};
			break;
		end
		tbOpt[#tbOpt+1]	= {Player:GetFactionRouteName(nFactionId, i).."60级紫装套", self.GetEquip, self, nFactionId, i, nQiangHua};
		nCount	= nCount - 1;
	end;
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("选择你需要的紫装的路线", tbOpt);
end

-- 获得60级紫装
function tbNpcBai:GetEquip(nFactionId, nRouteId, nQiangHua)
	local tbEquip	= self.tbAddedItem[nFactionId][nRouteId][me.nSex];
	if (not tbEquip) then
		return;
	end
	for i = 1, #tbEquip do
		local tbTmp = {unpack(tbEquip[i])};
		tbTmp[6] = tbTmp[6] or nQiangHua;
		me.AddItem(unpack(tbTmp));
	end
end

-- 获得60级马
function tbNpcBai:GetHorse_60Level()
	if me.GetTask(self.nTaskGroupId,self.nTaskId1) ~= 0 then
		Dialog:Say("已领取过马牌了。");
		return 0;		
	end
	if me.CountFreeBagCell() < 5 then
		Dialog:Say("Hành trang không đủ 。需要5格背包空间。");
		return 0;
	end
	for ni, tbItem in pairs(self.tbHorse_60Level) do
		local pItem = me.AddItem(unpack(tbItem));
		if pItem then
			pItem.Bind(1);
		end
	end
	me.SetTask(self.nTaskGroupId,self.nTaskId1, 1)
end

-- 秘籍等级提升
function tbNpcBai:LevelUpBook()
	local pItem		= me.GetEquip(Item.EQUIPPOS_BOOK);
	if (not pItem) then
		me.Msg("您的身上没有秘籍,升级失败,请先装备秘籍！");
		return;
	end
	local nLevel = pItem.GetGenInfo(1);
	if nLevel >=  self.nMijiLevel then
		me.Msg("您的秘籍已升到指定等级！");
		return;
	end
	for i = 1, 1000 do
		local nLevel = pItem.GetGenInfo(1);			-- 秘籍当前等级
		if (nLevel >= self.nMijiLevel) then
			break;
		end
		Item:AddBookKarma(me, self.nAddedKarmaPerTime);
	end
	
end
