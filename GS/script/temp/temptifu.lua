--体服使用
if (EventManager.IVER_bOpenTiFu ~= 1) then
	return;
end

-- 宋金体验专用角色

local tbNpcBai = Npc:GetClass("tmpnpc_tifu");

tbNpcBai.nTaskGroupId = 2051;
tbNpcBai.nTaskId1 = 1;	--领取马牌标志
tbNpcBai.nTaskId2 = 2;	--领取包包，银两标志
tbNpcBai.nTaskId3 = 5;	--领取基础用品标志
tbNpcBai.nTaskIdFactionRoutes		= 6;	--记录所有门派每条路线变量使用(6 - 30)!!!!!!!!!!!
tbNpcBai.nTaskIdFactionRoutesEnd	= 30;
tbNpcBai.nSongjin_70Level	= 130;					-- 宋金体验把玩家提升到的等级
tbNpcBai.nWeaponLevel		= 10;					-- 宋金体验的武器等级
tbNpcBai.nArmor_Level		= 10;					-- 宋金体验的防具等级
tbNpcBai.nEnhanceLevel		= 14;					-- 宋金体验装备的强化等级15改
tbNpcBai.nMijiLevel			= 110;					-- 秘籍等级
tbNpcBai.nTaskId_Partner  	= 10;					-- 同伴装备任务变量
tbNpcBai.nPartnerTemp 		= 6801;  -- 赠送同伴的NPC模板ID
tbNpcBai.nPotentialMax = 218;

tbNpcBai.tbSkillList =
{
	{1493, 1504, 1511, 1515, 1517, 1522},	-- 金
	{1496, 1507, 1511, 1515, 1518, 1522},	-- 木
	{1495, 1506, 1511, 1515, 1519, 1522},	-- 水
	{1492, 1503, 1511, 1515, 1520, 1522},	-- 火
	{1494, 1505, 1511, 1515, 1521, 1522},	-- 土
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
tbNpcBai.nBindCoin		= 10000;					-- 绑定金币
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
		{	-- 古墓
			{	-- 剑古墓
				[0] = {
					{2,  1, 1512-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 1472-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 1086-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 641-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 336-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 699-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 25, 2, -1},
				},
				[1]	= {
					{2,  1, 1512-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 1462-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 1096-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 646-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 336-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 692-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 26, 2, -1},
				},
			},
			{	-- 针古墓
				[0]	= {
					{2,  2, 210-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 1472-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 1086-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 641-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 488-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 336-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 699-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{1, 14, 24, 2, -1},
				},
				[1]	= {
					{2,  2, 210-6+tbNpcBai.nWeaponLevel, tbNpcBai.nWeaponLevel, -1},
					{2,  3, 1462-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  9, 1096-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  8, 646-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  7, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 10, 498-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  5, 336-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  4, 246-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2, 11, 692-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
					{2,  6, 247-6+tbNpcBai.nArmor_Level, tbNpcBai.nArmor_Level, -1},
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
{	6	,	0	,	3	,	"皮"		,	4	,	9	,	267	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	9	,	268	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	3	,	247	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	3	,	248	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	8	,	429	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	8	,	430	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	10	,	43	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	10	,	44	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	7	,	25	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	7	,	26	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	5	,	326	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	5	,	327	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	4	,	139	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	4	,	140	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	11	,	25	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	11	,	26	,	10	,	}	,
{	6	,	0	,	3	,	"皮"		,	4	,	6	,	114	,	10	,	}	,
{	6	,	1	,	3	,	"皮"		,	4	,	6	,	115	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	9	,	267	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	9	,	268	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	3	,	247	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	3	,	248	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	8	,	429	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	8	,	430	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	10	,	45	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	10	,	46	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	7	,	25	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	7	,	26	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	5	,	330	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	5	,	330	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	4	,	142	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	4	,	142	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	11	,	25	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	11	,	26	,	10	,	}	,
{	6	,	0	,	4	,	"皮"		,	4	,	6	,	114	,	10	,	}	,
{	6	,	1	,	4	,	"皮"		,	4	,	6	,	114	,	10	,	}	,
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
{"古剑",6,3,"皮",},	--这里五行特意区别开的（跟土系有冲突）
{"古针",6,4,"皮",},	--这里五行特意区别开的（跟土系有冲突）
}

tbNpcBai.tbMidBook = {--中级秘籍技能ID
	1200	,
	1201	,
	1202	,
	1202	,
	1203	,
	1204	,
	1205	,
	1206	,
	1207	,
	1208	,
	1209	,
	1210	,
	1211	,
	1212	,
	1213	,
	1214	,
	1215	,
	1216	,
	1217	,
	1218	,
	1219	,
	1220	,
	1221	,
	1222	,
	2815 ,
	2826 ,
}

tbNpcBai.tbHighBookSkill = {--高级秘籍技能ID
	1241	,
	1242	,
	1243	,
	1244	,
	1245	,
	1246	,
	1247	,
	1248	,
	1249	,
	1250	,
	1251	,
	1252	,
	1253	,
	1254	,
	1255	,
	1256	,
	1257	,
	1258	,
	1259	,
	1260	,
	1261	,
	1262	,
	1263	,
	1264	,
	2816	,
	2838	,
}
-- 对话
function tbNpcBai:OnDialog()
	--升级到30才有资格
	if me.nLevel < 30 then
		Dialog:Say("等级不足30级，您可以选择继续体验新手任务再来吧。");
		return;
	end
	Dialog:Say("测试服角色方案", {
			{"<color=yellow>升级为测试服角色<color>", self.LevelUpPlayer, self, 1},
			{"获得古墓派马牌技能", self.GetGumuSkill, self},
			{"获得测试服装备", self.GetEquipFaction, self, 1},
			{"领取中级秘籍和高级秘籍", self.GetMiJiBook, self},
		--	{"获得90级马", self.GetHorse_60Level, self},
			{"秘籍等级提升", self.LevelUpBook, self},
			{"领取修连珠无限洗点", self.GetXiuLianZhu, self},
			{"领取常用物品", self.GetDailyItem,self},
			{"购买龙纹银币", self.SellLongwen,self},
			--{"离开灵秀村", self.GoOther, self},
			--{"领取和升级五行印", self.UpDateWuXingYin, self},
			--{"领取基础用品", self.GetSundries, self},
			--{"领取夜明珠", self.GetYemingzhu, self},
			--{"领取120级同伴", self.OnSelectPartner, self},
			--{"领取同伴精魄", self.GetJingpo, self},
			--{"获得剑侠币和扩展背包", self.AddMoneyAndExbag, self};
			{"Kết thúc đối thoại"},
	});
end

function tbNpcBai:GetGumuSkill()
	if me.nFaction ~= 13 then
		Dialog:Say("只有古墓派才可以领取。");
		return;
	end
	if me.GetSkillState(2894) > 0 then
		Dialog:Say("您已经领取过了。");
		return;
	end
	if me.nFaction == 13 then
		for i = 2894, 2899 do
			me.AddFightSkill(i, 50)
		end
	end
end

function tbNpcBai:GoOther()
	Npc:GetClass("chefu"):OnDialog();
end

function tbNpcBai:SellLongwen()
	me.OpenShop(177, 1);
end

function tbNpcBai:GetDailyItem()
	Dialog:Say("领取常用物品", {
		{"领取披风和同伴", self.GetMantleAndPartner, self},
		{"领取同伴精魄", self.GetJingpo, self},
		{"领取夜明珠", self.GetYemingzhu, self},
		{"领取解玉锤", self.GetJieYuChui, self},
		{"领取金刚钻", self.GetJInGangZ, self},
		})
end

function tbNpcBai:GetMantleAndPartner()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(self.nTaskGroupId,self.nTaskId1) == nNowDate then
		Dialog:Say("每天只能领取一次。");
		return 0;		
	end
	if me.GetHonorLevel() <= 7 then
		Dialog:Say("您的荣誉等级需要达到潜龙才能领取。");
		return 0;
	end
	local pMantle = me.AddItem(1,17,me.nSeries*2+me.nSex-1,me.GetHonorLevel());
	if pMantle then
		pMantle.Bind(1);
		me.SetItemTimeout(pMantle, 24*60, 0);
	end
	self:GetPartners(me.GetHonorLevel() - 4);	--3级同伴
	
	me.SetTask(self.nTaskGroupId,self.nTaskId1,nNowDate);
end

function tbNpcBai:GetJieYuChui()
	if me.CountFreeBagCell() < 10 then
		Dialog:Say("Hành trang không đủ 10 ô.");
		return 0;
	end	
	me.AddStackItem(18, 1, 1312, 1, {bForceBind=1}, 10);
end

function tbNpcBai:GetJInGangZ()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	me.AddStackItem(18, 1, 1311, 1, {bForceBind=1}, 10);
end

--加同伴
function tbNpcBai:GetPartners(nSkillLevel)
	if me.nRouteId <= 0 then
		Dialog:Say("选定路线后再来吧", tbOpt);
		return
	end
	if not me.GetPartner(0) then
		Partner:AddPartner(me.nId, 2025, -1);
	end
	local pPartner = me.GetPartner(0);
	pPartner.DeleteAllSkill();
	Partner:AddFriendship(pPartner, 110*100)
	pPartner.SetValue(2,120)
	local tbPartnerSkill	= {
		{1493, 1504, 1511, 1515, 1517, 1522},	-- 金
		{1496, 1507, 1511, 1515, 1518, 1522},	-- 木
		{1495, 1506, 1511, 1515, 1519, 1522},	-- 水
		{1492, 1503, 1511, 1515, 1520, 1522},	-- 火
		{1494, 1505, 1511, 1515, 1521, 1522},	-- 土
	};

	local tbSkillId = tbPartnerSkill[me.nSeries]
	for i = 1, 6  do
	    pPartner.AddSkill({nId = tbSkillId[i], nLevel = nSkillLevel})
	end
	
	local INTTOALPOTENTIAL = 218;--同伴总潜能
	local tbFactionPotential = {};
	local tbData = Lib:LoadTabFile("\\setting\\player\\attrib_route.txt");
	local nPot_v;
	for _, tbRow in ipairs(tbData) do
		local nFaction	= tonumber(tbRow.FACTION);
		local nRoute	= tonumber(tbRow.ROUTE);
		local tbFaction	= tbFactionPotential[nFaction];
		if (not tbFaction) then
			tbFaction = {};
			tbFactionPotential[nFaction] = tbFaction;
		end
		tbFaction[nRoute] =
		{
			tonumber(tbRow.POTENTIAL_STRENGTH),
			tonumber(tbRow.POTENTIAL_DEXTERITY),
			tonumber(tbRow.POTENTIAL_VITALITY),
			tonumber(tbRow.POTENTIAL_ENERGY),
		};
	end
	for i=1,4 do
		nPot_v = INTTOALPOTENTIAL*tbFactionPotential[me.nFaction][me.nRouteId][i]/10
		me.GetPartner(0).SetAttrib(i-1, nPot_v)
	end
end

function tbNpcBai:OnSelectPartner()
	local nTask = me.GetTask(self.nTaskGroupId, self.nTaskId_Partner);
	if nTask >= 1 then
		me.Msg("你已经领取过该奖励了！");
		return;
	end
	
	if me.nSeries < 1 or me.nFaction < 1 then
		Partner:SendClientMsg("请先入了门派再来！");
		me.Msg("请先入了门派再来！");
		return;
	end
	
	if me.nRouteId < 1 then
		Partner:SendClientMsg("请先选择门派路线！");
		me.Msg("请先选择门派路线！");
		return;
	end
	
	if me.nPartnerCount >= me.nPartnerLimit then
		Partner:SendClientMsg("你的同伴已经满了！");
		me.Msg("你的同伴已经满了！");
		return;
	end
	
	if ( Partner:AddPartner(me.nId, self.nPartnerTemp, me.nSeries) == 1 ) then
		local pPartner = me.GetPartner(me.nPartnerCount - 1);	-- 取出刚刚添加的同伴
		self:SetPartnerAttrib(pPartner, me.nSeries);
		
		Partner:SendClientMsg(string.format("你获得了同伴%s！", pPartner.szName));
		me.Msg(string.format("你获得了同伴%s！", pPartner.szName));		
	end
	
	me.SetTask(self.nTaskGroupId, self.nTaskId_Partner, 1);
end

function tbNpcBai:SetPartnerAttrib(pPartner, nSeries)	
	-- 设置等级
	pPartner.SetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL, 120);
	
	-- 设置技能
	for i = 1, pPartner.nSkillCount do
		local tbSkill = pPartner.GetSkill(i - 1);
		tbSkill.nLevel = 3;
		tbSkill.nId = self.tbSkillList[nSeries][i];
		pPartner.SetSkill(i - 1, tbSkill);
	end
	
	-- 设置潜能
	local tbCurPoten = Player.tbFactionPotential[me.nFaction][me.nRouteId];
	local nPotentailTemp = 0;
	for nId, tb in pairs(Partner.tbPotentialTemp) do
		if (tb.nStrength == tbCurPoten[1] and tb.nDexterity == tbCurPoten[2] 
			and tb.nVitality == tbCurPoten[3] and tb.nEnergy == tbCurPoten[4]) then
				nPotentailTemp = nId;
				break;
		end
	end
	pPartner.SetValue(Partner.emKPARTNERATTRIBTYPE_PotentialTemp, nPotentailTemp);
	for nAttribIndex = 0, 3 do
		pPartner.SetAttrib(nAttribIndex, 0);
	end
	-- 重新分配
	Partner:AddPotential_Pure(pPartner.nPartnerIndex, self.nPotentialMax);
end

function tbNpcBai:GetSundries()
	if me.GetTask(self.nTaskGroupId, self.nTaskId3) == 1 then
		Dialog:Say("您已经领取过了。")
		return 0;
	end
	if me.nRouteId <= 0 then
		Dialog:Say("入门后再来吧", tbOpt);
		return
	end
	if me.CountFreeBagCell() < 21 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	--武林秘籍和洗髓经
	for i=1,5 do me.AddItem(18,1,191,1).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,191,2).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,192,1).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,192,2).Bind(1) end;
	--雏凤披风一件
	me.AddItem(1,17,me.nSeries*2+me.nSex-1,7).Bind(1);
	me.SetTask(self.nTaskGroupId, self.nTaskId3, 1)
end

function tbNpcBai:GetYemingzhu()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	me.AddStackItem(18, 1, 357, 1, {bForceBind=1}, 100);
end

function tbNpcBai:GetJingpo()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	me.AddStackItem(18, 1, 544, 3, {bForceBind=1}, 10);
end

function tbNpcBai:GetItems(tbItemList, nFaction, nRouteId, nSex, nQianghua)
	if nRouteId <= 0 then
		return;
	end
	for i=1,#tbItemList do
		local nItemRouteId = (nFaction - 1) * 2 + nRouteId;
		if nRouteId ~= 0 then 
			if tbItemList[i][1] == self.tbFixList[nItemRouteId][2] or tbItemList[i][1] == -1 then
				if tbItemList[i][2] == nSex or tbItemList[i][2] == -1 then
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

function tbNpcBai:UpDateWuXingYin()
	local tbOpt = {
		{"领取满级五行印", self.GetWuXingYin, self},
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
		Item:SetSignetMagic(pItem, 1, 1000, 0);
		Item:SetSignetMagic(pItem, 2, 1000, 0);
	end
	Dialog:Say("您成功领取了满级的五行印.");		
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
	nLevel = nLevel + 150;
	if nLevel > 1000 then
		nLevel = 1000;
	end
	Item:SetSignetMagic(pSignet, nMagicIndex, nLevel, 0);
	Dialog:Say("成功升级五行印属性,如果属性未满,您可以继续找我升级.");
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
	me.AddBindMoney(self.nBindMoney);
	me.AddBindCoin(self.nBindCoin);
	for i = 1, 3 do
		local pItem = me.AddItem(unpack(self.tbExbag_20Grid))
		if pItem then
			pItem.Bind(1)
		end
	end
	me.SetTask(self.nTaskGroupId,self.nTaskId2,1)
end

function tbNpcBai:GetMiJiBook()
	
	if (me.nFaction >= 1 and me.nFaction <= 13) then
		if me.CountFreeBagCell() < 4 then
			me.Msg("Hành trang không đủ chỗ trống，请空出至少4格空间！");
			return
		end
		
		-- 中级秘籍
		me.AddItem(1, 14, me.nFaction*2-1, 2);
		me.AddItem(1, 14, me.nFaction*2, 2);
		
		-- 高级秘籍
		me.AddItem(1, 14, me.nFaction*2-1, 3);
		me.AddItem(1, 14, me.nFaction*2, 3);
		
		--轻功
		me.AddFightSkill(10,20);

		--中级秘籍技能
		me.AddFightSkill(tbNpcBai.tbMidBook[me.nFaction*2-1],10)--中级秘籍技能
		me.AddFightSkill(tbNpcBai.tbMidBook[me.nFaction*2],10)--中级秘籍技能

		--高级秘籍技能
		me.AddFightSkill(tbNpcBai.tbHighBookSkill[me.nFaction*2-1],10)--中级秘籍技能
		me.AddFightSkill(tbNpcBai.tbHighBookSkill[me.nFaction*2],10)--中级秘籍技能
		
	elseif (me.nFaction == 0) then
		Dialog:Say("先加入门派才能领取秘籍");
	end
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
	if me.GetTask(self.nTaskGroupId,self.nTaskId2) ~= 0 then
		Dialog:Say("已升过级并领取过剑侠币和扩展背包。");
		return 0;		
	end
	if me.CountFreeBagCell() < 3 then
		Dialog:Say("Hành trang không đủ 。");
		return 0;
	end	
	if (me.nFaction == 0) then
		local nSexLimit	= Player.tbFactions[nIndex].nSexLimit;
		if (nSexLimit >= 0 and nSexLimit ~= me.nSex) then
			me.Msg("对不起，该门派不收"..Player.SEX[me.nSex].."弟子！");
			return;
		end
		me.JoinFaction(nIndex);
		if nIndex == 13 then
			for i = 2894, 2899 do
				me.AddFightSkill(i, 50)
			end
		end
	end
	local nLevelUp = self.nSongjin_70Level - me.nLevel;
	me.DirectChangeLevel(nLevelUp);
	me.CallClientScript({"me.DirectChangeLevel", nLevelUp});
	me.AddBindMoney(self.nBindMoney);
	me.AddBindCoin(self.nBindCoin);
	for i = 1, 3 do
		local pItem = me.AddItem(unpack(self.tbExbag_20Grid))
		if pItem then
			pItem.Bind(1)
		end
	end
	me.SetTask(self.nTaskGroupId,self.nTaskId2,1);
	me.SetTask(1022, 215, 4095); -- 学习110技能
	me.AddRepute(7, 1, 9000);	--联赛声望
	me.AddRepute(8, 1, 9000);	--领土声望
	me.AddRepute(5, 3, 9000);	--逍遥声望
	me.AddRepute(9, 1, 12000);	--秦始皇陵·官府声望
	-- 送1亿绑银
	me.AddGlbBindMoney(100000000);
	
	--me.SetTask(2027,230, 1);	--可以通过换线专员出去
end

-- 获得60级紫装所属的门派
function tbNpcBai:GetEquipFaction(nPosStartIdx)
	local tbOpt		= {};
	local nCount	= 9;
	if (me.nFaction == 0) then
		Dialog:Say("请先升级角色并加入门派。");
		return 0;
	end
	if me.nRouteId <= 0 then
		Dialog:Say("选定路线后再来吧");
		return
	end
	if me.GetTask(self.nTaskGroupId,self.nTaskIdFactionRoutes) == 1 then
		Dialog:Say("一个角色只能领取一套装备，你已经领取过了，不能再领取！")
		return 0;
	end
	self:GetEquipRoute(me.nFaction, 1)
end

-- 获得60级紫装所属的路线
function tbNpcBai:GetEquipRoute(nFactionId, nPosStartIdx)
	if me.nFaction ~= 0 then
		Faction:InitChangeFaction(me);
	end
	
	local tbOpt		= {};
	local nCount	= 9;
	local nMajorFaction = Faction:Genre2Faction(me, 1);
	local nMinorFaction = Faction:Genre2Faction(me, 2);
	local tbFactions = {nMajorFaction};
	if nMinorFaction > 0 then
		table.insert(tbFactions, nMinorFaction);
	end
	
	for _, nFactionId in ipairs(tbFactions) do
		for i = nPosStartIdx, #Player.tbFactions[nFactionId].tbRoutes do
			if (nCount <= 0) then
				tbOpt[#tbOpt]	= {"Trang sau", self.GetEquipRoute, self, nFactionId, i - 1};
				break;
			end
			tbOpt[#tbOpt+1]	= {Player:GetFactionRouteName(nFactionId, i).."90级装备和武器", self.GetEquip, self, nFactionId, i};
			nCount	= nCount - 1;
		end
	end
	
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	
	local szMsg = "选择你需要的装备的路线。<color=yellow>每个角色只能领取一套装备，请谨慎选择！<color>";
	Dialog:Say(szMsg, tbOpt);
end

-- 获得90级紫装
function tbNpcBai:GetEquip(nFactionId, nRouteId)
	--local nEquipNum = me.GetTask(self.nTaskGroupId,self.nTaskIdFactionRoutes + (((nFactionId-1) * 2 + nRouteId) - 1));
	--if  nEquipNum ~= 0 then
	--	Dialog:Say("您已领取过了该路线装备，每条路线只限领取一套装备。");
	--	return 0;
	--end	
	if me.GetTask(self.nTaskGroupId,self.nTaskIdFactionRoutes) == 1 then
		Dialog:Say("一个角色只能领取一套装备，你已经领取过了，不能再领取！")
		return 0;
	end
	
	local tbEquip	= self.tbAddedItem[nFactionId][nRouteId][me.nSex];
	if (not tbEquip) then
		return;
	end	
	if me.CountFreeBagCell() < 35 then
		Dialog:Say("Hành trang không đủ ,领取装备需要35格背包空间。");
		return 0;
	end
	
	-- 原来的装备只加武器了
	local g,d,p,l,s = unpack(tbEquip[1])
	local pItem = me.AddItem(g,d,p,l,s, 14);			-- 武器特殊处理
	if pItem then
		pItem.Bind(1);
	end
	--雏凤披风
	local pMantle = me.AddItem(1,17,me.nSeries*2+me.nSex-1,7);
	if pMantle then
		pMantle.Bind(1)
	end
	self:GetPartners(3);	--3级同伴
	--武林秘籍
	for i=1,5 do me.AddItem(18,1,191,1).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,191,2).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,192,1).Bind(1) end;
	for i=1,5 do me.AddItem(18,1,192,2).Bind(1) end;
	--五行印
	local pItem = me.AddItem(1,16,me.nFaction,1);
	if pItem then
		pItem.Bind(1);
		Item:SetSignetMagic(pItem, 1, 1000, 0);
		Item:SetSignetMagic(pItem, 2, 1000, 0);
	end
	--无限传送符
	local pTransfer = me.AddItem(18,1,195,1);
	if pTransfer then
		pTransfer.Bind(1);
	end
	--赤兔
	local pHorse = me.AddItem(1,12,67,1);
	if pHorse then
		pHorse.Bind(1);
	end
	local pZhenfa = me.AddItem(18,1,320,3);
	if pZhenfa then
		pZhenfa.Bind(1);
	end
	--装备
	self:GetItems(self.tbArmorsList, nFactionId, nRouteId, me.nSex, tbNpcBai.nEnhanceLevel)
	
	me.SetTask(self.nTaskGroupId, self.nTaskIdFactionRoutes, 1)
	
	
	--me.SetTask(self.nTaskGroupId,self.nTaskIdFactionRoutes + (((nFactionId-1) * 2 + nRouteId) - 1), 1);	
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
