
if (not FightSkill.tbStatereplaceregular) then
	FightSkill.tbStateReplaceRegular = {};
end

local tbRegular = FightSkill.tbStateReplaceRegular;

tbRegular.tbReplaceRegular = 
{
	-- 新来的强制替换
	tbForceReplace = 
	{
		--阵法
		{383,1344,1345,1346,1347,1349,1351,1353,1355,1357,1811,1813,1815,1817,1819,1821,1823,1825},
		--阵眼
		{381,382,1348,1350,1352,1354,1356,1810,1812,1814,1816,1818,1820,1822,1824},
		--boss内外功免疫互相覆盖,10%血后释放清风符覆盖掉免疫技能 
		{1401,1404,586},
		{830},--袖箭120伤害增加状态
		{834},--掌毒传递伤害
		{2093,2095},--韩丹的两种debuff互相覆盖
		{2828,2829,2830},--飞针古墓3个姿态互相覆盖
		{2342},--陆往生反弹状态强制替换,以不同等级来实现随机伤害..
	},
	
	-- 等级高的替换 
	tbLevelReplace = 
	{
		{385,876},
		{386,877},
		{387,878},
		{106,277},
		{1625,1626},--侠客岛资源点debuff用10级覆盖占领buff
		--战神丹效果和宋金战场光环不叠加
		{1154,1638},
		{2527,1826,1827,1828},--美女活动buff高级覆盖低级
	},

	-- 时间多的替换
	tbTimeReplace = 
	{
		{476},--周菜和月菜剩余时间多的覆盖
		{378},--喝酒buff时间叠加无论等级
	},
	-- 自身的优先
	tbRelation = 
	{
		{25,253},
		{46,239},
		{55,240},
		{61,275},
		{201,247},
		{101,276},
		{102,241},
		{108,278},
		{116,244},
		{228,779,805},--刀少行龙不雨,北冥神功,北冥神功子3个状态自身优先
		{164,242},
		{170,243},
		{180,245},
		{191,246},
		{177,780},
		{1360,1361},
		{1298,1299},
		{1472,1473},
		{855,1186},
		{1254,1269},
		{1249,1266},
		{838,1647},
		{826,1665},
		{836,873},--叶底藏花和叶底藏花自身互相覆盖
		{1966,1967},--迷乱之柱自身效果优先于加给其他npc的无敌状态
		{1974,1975},--同伴技能对自身效果和对队友效果不可叠加
	},
	-- 魔法属性值较大的优先，设为一组内的技能需要有且仅有一条魔法属性，且是相同属性，才会生效
	-- 若技能填入如下组，则该技能本身的替代规则也由默认的等级优先，变为大数值优先
	tbMagicValue = 
	{
		{333,478,880},
		{482,882},
		{835,1173},
	},
	--已有此buff,不会刷新buff
	tbFirstRecValue =
	{
		{210},--乾坤大挪移
		{1281},--被动触发的悲酥清风,以免被反弹诅咒频繁反弹
		{774},--被动触发的万蛊蚀心,以免被反弹诅咒频繁反弹
		{801},--被动触发的悲魔血光,以免被反弹诅咒频繁反弹
		{388},--被动触发的瘟蛊之气,以免被反弹诅咒频繁反弹
		{810},--被动醉蝶,重复释放不会刷新
	},
	--如果以前存在此buff，则叠加次数+1，即叠加
	tbSuperpose = 
	{
		--{180},
		--{技能id},
		{3010},--Ám Tiêu
		{2991},--Kinh Lôi Trảm
		{1273},--枪天连环夺命枪叠加攻击
		{1660},--连环夺命枪叠加减少攻击
		{1276},
		{1279},
		{1285},
		{13},--轻功耗体叠加
		--{1292},--袖箭120子
		{1648},--刀翠120子
		{1112},--剑武120子
		{1671},--气武120子
		{1661},--剑昆120子
		--{1287},--棍少120子
		{1848},--伏牛山boss技能,叠加受到伤害增加
		{1870},--叠加受到伤害增加
		{1875},--叠加受到伤害增加
		{1886},--叠加受到伤害增加
		{1892},--叠加受到伤害增加
		{1900},--叠加受到伤害增加
		{1917},--叠加受到伤害增加
		{1925},--叠加攻击增加
		{1938},--叠加受到伤害增加
		{1953},--叠加攻击增加
		{2170},
		{1855},--自动伤害叠加
		{806},--血鼎功子_叠加受到伤害增加
		{1698},--叠加受到伤害增加
		{1700},--叠加受到伤害增加
		{1718},--自动伤害叠加
		{1704},--叠加受到伤害增加
		{35},--不动明王子叠加跑速和闪避降低
		{2407},--龙门飞剑藏宝图，扩大受到伤害
		{1996},--新装备技能,附近每个友方为自身叠加buff
		{2504},--新藏宝图及军营buff
		{2506},--新藏宝图及军营buff
		{2514},--新藏宝图及军营buff
		{2555},--新藏宝图及军营buff
		{2556},--新藏宝图及军营buff
		{2564},--新藏宝图及军营buff
		{2583},--新藏宝图及军营buff
		{2587},--新藏宝图及军营buff
		{2660},--新藏宝图及军营buff
		{815},--冰心倩影_子_叠加降低对手闪避和完全闪避
		{2817},--古墓闪
		{2818},--古墓杀
		{2846},--飞针淬毒
		{2853},--五气朝元叠加伤害
		{2858},--剑古墓叠加降低药效
		{2841},--剑古墓叠加伤害增加
		--{2856},--刀少化解伤害逐渐降低
        	{2901},--额伦连环夺命，叠加伤害
	},
	--如果以前存在此buff，且等级和类型一样，则叠加剩余时间
	--参数1:技能ID,参数2:持续时间上限
	tbTimeAdd = 
	{
		{892},--强化优惠
		{1193,18*90},--剑翠110_十面埋伏_队友
		{2844,10*18},--飞针古墓_伺机待发叠加时间,最多10秒
		{1978,18*18},--棍丐棒打狗头,最多18秒
		{2819},--每秒获得闪
		{2820},--每秒获得杀
	},
	-- 开关buff,重复使用状态消失
	tbSwitch =
	{
		{14},--普伤害转五行伤害
		{846},--纵鹤功
		{850},--魔刀吞神
		{78},--无形蛊
		--{2822},--冰魄银针
	},
}

function tbRegular:AdjustSkillRegular()
	local tbSkillCheck = {};
	for szKey, tbRegular in pairs(self.tbReplaceRegular) do
		for szTypeName, tbSkillId in ipairs(tbRegular) do
			for nIndex, nSkillId in ipairs(tbSkillId) do
				--print(szKey, szTypeName, nIndex, nSkillId);
				if (szKey == "tbTimeAdd" and nIndex > 1) then
					--print("***********", szTypeName, nIndex);
				else
					assert(not tbSkillCheck[nSkillId]);
					--print("nSkillId",nSkillId,"------------")
					tbSkillCheck[nSkillId] = 1;
				end
			end
		end
	end
end

tbRegular:AdjustSkillRegular();


function tbRegular:GetConflictingSkillList(nDesSkillId)
	for _, tbRegular in pairs(self.tbReplaceRegular) do
		for _, tbSkillId in ipairs(tbRegular) do
			for _, nSkillId in ipairs(tbSkillId) do
				if (nDesSkillId == nSkillId) then
					return tbSkillId;
				end
			end
		end
	end
end

function tbRegular:GetStateGroupReplaceType(nDesSkillId)
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbForceReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 1;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbLevelReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 2;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 3;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbRelation) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 4;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbMagicValue) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 5;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbFirstRecValue) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 6;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSuperpose) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 7;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeAdd) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 8;
			end
		end
	end	
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSwitch) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 9;
			end
		end
	end
	return 0;
end
