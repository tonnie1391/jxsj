--体服使用

-- 宋金体验专用角色

local tbNpcBai	= Npc:GetClass("getequip");

tbNpcBai.nTaskGroupId = 2051;
tbNpcBai.nTaskId1 = 1;	--领取马牌标志
tbNpcBai.nTaskId2 = 2;	--领取包包，银两标志
tbNpcBai.nTaskIdRoute={
	[1]=3,	--领取一个路线装备标志
 	[2]=4,	--领取另一个路线装备标志
}
tbNpcBai.nTaskId3 = 5;	--领取祈福护身符

--tbNpcBai.nSongjin_70Level	= 130;					-- 宋金体验把玩家提升到的等级
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

tbNpcBai.tbMidBookSkill = {--中级秘籍技能ID
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
	2815	,
	2826	,
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

tbNpcBai.tbExbag_20Grid		= {21, 8, 1, 1};		-- 20格背包
tbNpcBai.nAddedKarmaPerTime	= 3000;					-- 每次增加500点修为
tbNpcBai.nAddedMoney		= 1000000;				-- 每次选择赠送剑侠币的选项可得到100wJXB
tbNpcBai.nBindMoney		= 10000000;					-- 绑定银两
tbNpcBai.nBindCoin		= 5000;						-- 绑定金币
tbNpcBai.nExbagItem			= {}					-- 20格背包

tbNpcBai.tbArmorsList = {--橙装炼化
--series	,	sex	,	IsPhysical	,	材料	,	Genre	,	DetailType	,	ParticularType	,	Level
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
--{	5	,	0	,	-1	,	"皮"		,	4	,	3	,	247	,	10	,	}	,
--{	5	,	1	,	-1	,	"皮"		,	4	,	3	,	248	,	10	,	}	,
{	5	,	0	,	-1	,	"皮"		,	4	,	3	,	262	,	10	,	}	,
{	5	,	1	,	-1	,	"皮"		,	4	,	3	,	263	,	10	,	}	,
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
{	5	,	0	,	-1	,	"皮"		,	4	,	9	,	267	,	10	,	}	,
{	5	,	1	,	-1	,	"皮"		,	4	,	9	,	268	,	10	,	}	,
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
};
tbNpcBai.tbArmorsListPurple = {
--{	series	,	sex	,	physical	,	材料	,	Genre	,	DetailType	,	ParticularType	,	Level	,},
{	1	,	-1	,	-1	,	-1	,	2	,	6	,	152	,	1	,},
{	2	,	-1	,	-1	,	-1	,	2	,	6	,	162	,	1	,},
{	3	,	-1	,	-1	,	-1	,	2	,	6	,	172	,	1	,},
{	4	,	-1	,	-1	,	-1	,	2	,	6	,	182	,	1	,},
{	5	,	-1	,	-1	,	-1	,	2	,	6	,	192	,	1	,},
{	1	,	0	,	-1	,	"铁"	,	2	,	3	,	603	,	1	,},
{	1	,	1	,	-1	,	"铁"	,	2	,	3	,	613	,	1	,},
{	1	,	0	,	-1	,	"皮"	,	2	,	3	,	623	,	1	,},
{	1	,	1	,	-1	,	"皮"	,	2	,	3	,	633	,	1	,},
{	2	,	0	,	-1	,	"皮"	,	2	,	3	,	643	,	1	,},
{	2	,	1	,	-1	,	"皮"	,	2	,	3	,	653	,	1	,},
{	2	,	0	,	-1	,	"布"	,	2	,	3	,	663	,	1	,},
{	2	,	1	,	-1	,	"布"	,	2	,	3	,	673	,	1	,},
{	3	,	0	,	-1	,	"皮"	,	2	,	3	,	683	,	1	,},
{	3	,	1	,	-1	,	"皮"	,	2	,	3	,	693	,	1	,},
{	3	,	0	,	-1	,	"布"	,	2	,	3	,	703	,	1	,},
{	3	,	1	,	-1	,	"布"	,	2	,	3	,	713	,	1	,},
{	4	,	0	,	-1	,	"皮"	,	2	,	3	,	723	,	1	,},
{	4	,	1	,	-1	,	"皮"	,	2	,	3	,	733	,	1	,},
{	4	,	0	,	-1	,	"皮"	,	2	,	3	,	743	,	1	,},
{	4	,	1	,	-1	,	"皮"	,	2	,	3	,	753	,	1	,},
{	5	,	0	,	-1	,	"铁"	,	2	,	3	,	763	,	1	,},
{	5	,	1	,	-1	,	"铁"	,	2	,	3	,	773	,	1	,},
{	5	,	0	,	-1	,	"布"	,	2	,	3	,	783	,	1	,},
{	5	,	1	,	-1	,	"布"	,	2	,	3	,	793	,	1	,},
{	5	,	0	,	-1	,	"皮"	,	2	,	3	,	1467	,	1	,},
{	5	,	1	,	-1	,	"皮"	,	2	,	3	,	1477	,	1	,},
{	1	,	0	,	-1	,	-1	,	2	,	8	,	301	,	1	,},
{	1	,	1	,	-1	,	-1	,	2	,	8	,	311	,	1	,},
{	2	,	0	,	-1	,	-1	,	2	,	8	,	321	,	1	,},
{	2	,	1	,	-1	,	-1	,	2	,	8	,	331	,	1	,},
{	3	,	0	,	-1	,	-1	,	2	,	8	,	341	,	1	,},
{	3	,	1	,	-1	,	-1	,	2	,	8	,	351	,	1	,},
{	4	,	0	,	-1	,	-1	,	2	,	8	,	361	,	1	,},
{	4	,	1	,	-1	,	-1	,	2	,	8	,	371	,	1	,},
{	5	,	0	,	-1	,	-1	,	2	,	8	,	381	,	1	,},
{	5	,	1	,	-1	,	-1	,	2	,	8	,	391	,	1	,},
{	1	,	0	,	-1	,	-1	,	2	,	7	,	303	,	1	,},
{	1	,	1	,	-1	,	-1	,	2	,	7	,	313	,	1	,},
{	2	,	0	,	-1	,	-1	,	2	,	7	,	323	,	1	,},
{	2	,	1	,	-1	,	-1	,	2	,	7	,	333	,	1	,},
{	3	,	0	,	-1	,	-1	,	2	,	7	,	343	,	1	,},
{	3	,	1	,	-1	,	-1	,	2	,	7	,	353	,	1	,},
{	4	,	0	,	-1	,	-1	,	2	,	7	,	363	,	1	,},
{	4	,	1	,	-1	,	-1	,	2	,	7	,	373	,	1	,},
{	5	,	0	,	-1	,	-1	,	2	,	7	,	383	,	1	,},
{	5	,	1	,	-1	,	-1	,	2	,	7	,	393	,	1	,},
{	1	,	0	,	-1	,	-1	,	2	,	10	,	303	,	1	,},
{	1	,	1	,	-1	,	-1	,	2	,	10	,	313	,	1	,},
{	2	,	0	,	-1	,	-1	,	2	,	10	,	323	,	1	,},
{	2	,	1	,	-1	,	-1	,	2	,	10	,	333	,	1	,},
{	3	,	0	,	-1	,	-1	,	2	,	10	,	343	,	1	,},
{	3	,	1	,	-1	,	-1	,	2	,	10	,	353	,	1	,},
{	4	,	0	,	-1	,	-1	,	2	,	10	,	363	,	1	,},
{	4	,	1	,	-1	,	-1	,	2	,	10	,	373	,	1	,},
{	5	,	0	,	-1	,	-1	,	2	,	10	,	383	,	1	,},
{	5	,	1	,	-1	,	-1	,	2	,	10	,	393	,	1	,},
{	1	,	0	,	-1	,	"铁"	,	2	,	9	,	601	,	1	,},
{	1	,	1	,	-1	,	"铁"	,	2	,	9	,	611	,	1	,},
{	1	,	0	,	-1	,	"皮"	,	2	,	9	,	621	,	1	,},
{	1	,	1	,	-1	,	"皮"	,	2	,	9	,	631	,	1	,},
{	2	,	0	,	-1	,	"皮"	,	2	,	9	,	641	,	1	,},
{	2	,	1	,	-1	,	"皮"	,	2	,	9	,	651	,	1	,},
{	2	,	0	,	-1	,	"布"	,	2	,	9	,	661	,	1	,},
{	2	,	1	,	-1	,	"布"	,	2	,	9	,	671	,	1	,},
{	3	,	0	,	-1	,	"皮"	,	2	,	9	,	681	,	1	,},
{	3	,	1	,	-1	,	"皮"	,	2	,	9	,	691	,	1	,},
{	3	,	0	,	-1	,	"布"	,	2	,	9	,	701	,	1	,},
{	3	,	1	,	-1	,	"布"	,	2	,	9	,	711	,	1	,},
{	4	,	0	,	-1	,	"皮"	,	2	,	9	,	721	,	1	,},
{	4	,	1	,	-1	,	"皮"	,	2	,	9	,	731	,	1	,},
{	4	,	0	,	-1	,	"皮"	,	2	,	9	,	741	,	1	,},
{	4	,	1	,	-1	,	"皮"	,	2	,	9	,	751	,	1	,},
{	5	,	0	,	-1	,	"铁"	,	2	,	9	,	761	,	1	,},
{	5	,	1	,	-1	,	"铁"	,	2	,	9	,	771	,	1	,},
{	5	,	0	,	-1	,	"布"	,	2	,	9	,	781	,	1	,},
{	5	,	1	,	-1	,	"布"	,	2	,	9	,	791	,	1	,},
{	5	,	0	,	-1	,	"皮"	,	2	,	9	,	1081	,	1	,},
{	5	,	1	,	-1	,	"皮"	,	2	,	9	,	1091	,	1	,},
{	1	,	-1	,	-1	,	-1	,	2	,	5	,	151	,	1	,},
{	2	,	-1	,	-1	,	-1	,	2	,	5	,	161	,	1	,},
{	3	,	-1	,	-1	,	-1	,	2	,	5	,	171	,	1	,},
{	4	,	-1	,	-1	,	-1	,	2	,	5	,	181	,	1	,},
{	5	,	-1	,	-1	,	-1	,	2	,	5	,	191	,	1	,},
{	1	,	0	,	-1	,	-1	,	2	,	11	,	301	,	1	,},
{	1	,	1	,	-1	,	-1	,	2	,	11	,	311	,	1	,},
{	2	,	0	,	-1	,	-1	,	2	,	11	,	321	,	1	,},
{	2	,	1	,	-1	,	-1	,	2	,	11	,	331	,	1	,},
{	3	,	0	,	-1	,	-1	,	2	,	11	,	341	,	1	,},
{	3	,	1	,	-1	,	-1	,	2	,	11	,	351	,	1	,},
{	4	,	0	,	-1	,	-1	,	2	,	11	,	361	,	1	,},
{	4	,	1	,	-1	,	-1	,	2	,	11	,	371	,	1	,},
{	5	,	0	,	-1	,	-1	,	2	,	11	,	381	,	1	,},
{	5	,	1	,	-1	,	-1	,	2	,	11	,	391	,	1	,},
{	1	,	-1	,	-1	,	-1	,	2	,	4	,	151	,	1	,},
{	2	,	-1	,	-1	,	-1	,	2	,	4	,	161	,	1	,},
{	3	,	-1	,	-1	,	-1	,	2	,	4	,	171	,	1	,},
{	4	,	-1	,	-1	,	-1	,	2	,	4	,	181	,	1	,},
{	5	,	-1	,	-1	,	-1	,	2	,	4	,	191	,	1	,},
};
tbNpcBai.tbArmorsListSilver = {
--	series		sex		Physical		材料		Genre		DetailType		ParticularType		Level
{	1	,	-1	,	-1	,	-1	,	4	,	6	,	94	,	10	},
{	2	,	-1	,	-1	,	-1	,	4	,	6	,	99	,	10	},
{	3	,	-1	,	-1	,	-1	,	4	,	6	,	104	,	10	},
{	4	,	-1	,	-1	,	-1	,	4	,	6	,	109	,	10	},
{	5	,	-1	,	-1	,	-1	,	4	,	6	,	114	,	10	},
--{	1	,	1	,	-1	,	-1	,	4	,	3	,	143	,	10	},
--{	2	,	1	,	-1	,	-1	,	4	,	3	,	144	,	10	},
--{	3	,	1	,	-1	,	-1	,	4	,	3	,	145	,	10	},
--{	4	,	1	,	-1	,	-1	,	4	,	3	,	146	,	10	},
--{	5	,	1	,	-1	,	-1	,	4	,	3	,	147	,	10	},
--{	1	,	0	,	-1	,	-1	,	4	,	3	,	153	,	10	},
--{	2	,	0	,	-1	,	-1	,	4	,	3	,	154	,	10	},
--{	3	,	0	,	-1	,	-1	,	4	,	3	,	155	,	10	},
--{	4	,	0	,	-1	,	-1	,	4	,	3	,	156	,	10	},
--{	5	,	0	,	-1	,	-1	,	4	,	3	,	157	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	8	,	351	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	8	,	352	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	8	,	371	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	8	,	372	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	8	,	391	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	8	,	392	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	8	,	411	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	8	,	412	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	8	,	431	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	8	,	432	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	8	,	457	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	8	,	458	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	8	,	461	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	8	,	462	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	8	,	465	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	8	,	466	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	8	,	469	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	8	,	470	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	8	,	473	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	8	,	474	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	9	,	477	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	9	,	478	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	9	,	479	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	9	,	480	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	9	,	481	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	9	,	482	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	9	,	483	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	9	,	484	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	9	,	485	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	9	,	486	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	3	,	223	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	3	,	224	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	3	,	225	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	3	,	226	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	3	,	227	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	3	,	228	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	3	,	229	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	3	,	230	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	3	,	231	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	3	,	232	,	10	},
{	1	,	-1	,	1	,	-1	,	4	,	4	,	444	,	10	},
{	1	,	-1	,	2	,	-1	,	4	,	4	,	445	,	10	},
{	2	,	-1	,	1	,	-1	,	4	,	4	,	446	,	10	},
{	2	,	-1	,	2	,	-1	,	4	,	4	,	447	,	10	},
{	3	,	-1	,	1	,	-1	,	4	,	4	,	448	,	10	},
{	3	,	-1	,	2	,	-1	,	4	,	4	,	449	,	10	},
{	4	,	-1	,	1	,	-1	,	4	,	4	,	450	,	10	},
{	4	,	-1	,	2	,	-1	,	4	,	4	,	451	,	10	},
{	5	,	-1	,	1	,	-1	,	4	,	4	,	452	,	10	},
{	5	,	-1	,	2	,	-1	,	4	,	4	,	453	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	7	,	31	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	7	,	32	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	7	,	33	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	7	,	34	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	7	,	35	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	7	,	36	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	7	,	37	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	7	,	38	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	7	,	39	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	7	,	40	,	10	},
{	1	,	-1	,	1	,	-1	,	4	,	5	,	447	,	10	},
{	1	,	-1	,	2	,	-1	,	4	,	5	,	448	,	10	},
{	2	,	-1	,	1	,	-1	,	4	,	5	,	449	,	10	},
{	2	,	-1	,	2	,	-1	,	4	,	5	,	450	,	10	},
{	3	,	-1	,	1	,	-1	,	4	,	5	,	451	,	10	},
{	3	,	-1	,	2	,	-1	,	4	,	5	,	452	,	10	},
{	4	,	-1	,	1	,	-1	,	4	,	5	,	453	,	10	},
{	4	,	-1	,	2	,	-1	,	4	,	5	,	454	,	10	},
{	5	,	-1	,	1	,	-1	,	4	,	5	,	455	,	10	},
{	5	,	-1	,	2	,	-1	,	4	,	5	,	456	,	10	},
--{	1	,	0	,	-1	,	-1	,	4	,	11	,	61	,	10	},
--{	1	,	1	,	-1	,	-1	,	4	,	11	,	62	,	10	},
--{	2	,	0	,	-1	,	-1	,	4	,	11	,	63	,	10	},
--{	2	,	1	,	-1	,	-1	,	4	,	11	,	64	,	10	},
--{	3	,	0	,	-1	,	-1	,	4	,	11	,	65	,	10	},
--{	3	,	1	,	-1	,	-1	,	4	,	11	,	66	,	10	},
--{	4	,	0	,	-1	,	-1	,	4	,	11	,	67	,	10	},
--{	4	,	1	,	-1	,	-1	,	4	,	11	,	68	,	10	},
--{	5	,	0	,	-1	,	-1	,	4	,	11	,	69	,	10	},
--{	5	,	1	,	-1	,	-1	,	4	,	11	,	70	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	11	,	71	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	11	,	72	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	11	,	73	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	11	,	74	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	11	,	75	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	11	,	76	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	11	,	77	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	11	,	78	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	11	,	79	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	11	,	80	,	10	},
--护腕
{	1	,	0	,	1	,	-1	,	4	,	10	,	481,	10	},
{	1	,	1	,	1	,	-1	,	4	,	10	,	482,	10	},
{	1	,	0	,	2	,	-1	,	4	,	10	,	483,	10	},
{	1	,	1	,	2	,	-1	,	4	,	10	,	484,	10	},
{	2	,	0	,	1	,	-1	,	4	,	10	,	485,	10	},
{	2	,	1	,	1	,	-1	,	4	,	10	,	486	,	10	},
{	2	,	0	,	2	,	-1	,	4	,	10	,	487	,	10	},
{	2	,	1	,	2	,	-1	,	4	,	10	,	488	,	10	},
{	3	,	0	,	1	,	-1	,	4	,	10	,	489	,	10	},
{	3	,	1	,	1	,	-1	,	4	,	10	,	490	,	10	},
{	3	,	0	,	2	,	-1	,	4	,	10	,	491	,	10	},
{	3	,	1	,	2	,	-1	,	4	,	10	,	492	,	10	},
{	4	,	0	,	1	,	-1	,	4	,	10	,	493	,	10	},
{	4	,	1	,	1	,	-1	,	4	,	10	,	494	,	10	},
{	4	,	0	,	2	,	-1	,	4	,	10	,	495	,	10	},
{	4	,	1	,	2	,	-1	,	4	,	10	,	496	,	10	},
{	5	,	0	,	1	,	-1	,	4	,	10	,	497	,	10	},
{	5	,	1	,	1	,	-1	,	4	,	10	,	498	,	10	},
{	5	,	0	,	2	,	-1	,	4	,	10	,	499	,	10	},
{	5	,	1	,	2	,	-1	,	4	,	10	,	500	,	10	},
};
tbNpcBai.tbArmorsListGold = {
--	series		sex		IsPhysical		材料		Genre		DetailType		ParticularType		Level
{	1	,	-1	,	-1	,	-1	,	4	,	6	,	95	,	10	},
{	2	,	-1	,	-1	,	-1	,	4	,	6	,	100	,	10	},
{	3	,	-1	,	-1	,	-1	,	4	,	6	,	105	,	10	},
{	4	,	-1	,	-1	,	-1	,	4	,	6	,	110	,	10	},
{	5	,	-1	,	-1	,	-1	,	4	,	6	,	115	,	10	},
--{	1	,	1	,	-1	,	-1	,	4	,	3	,	148	,	10	},
--{	2	,	1	,	-1	,	-1	,	4	,	3	,	149	,	10	},
--{	3	,	1	,	-1	,	-1	,	4	,	3	,	150	,	10	},
--{	4	,	1	,	-1	,	-1	,	4	,	3	,	151	,	10	},
--{	5	,	1	,	-1	,	-1	,	4	,	3	,	152	,	10	},
--{	1	,	0	,	-1	,	-1	,	4	,	3	,	158	,	10	},
--{	2	,	0	,	-1	,	-1	,	4	,	3	,	159	,	10	},
--{	3	,	0	,	-1	,	-1	,	4	,	3	,	160	,	10	},
--{	4	,	0	,	-1	,	-1	,	4	,	3	,	161	,	10	},
--{	5	,	0	,	-1	,	-1	,	4	,	3	,	162	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	8	,	353	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	8	,	354	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	8	,	373	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	8	,	374	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	8	,	393	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	8	,	394	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	8	,	413	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	8	,	414	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	8	,	433	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	8	,	434	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	8	,	459	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	8	,	460	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	8	,	463	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	8	,	464	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	8	,	467	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	8	,	468	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	8	,	471	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	8	,	472	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	8	,	475	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	8	,	476	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	9	,	487	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	9	,	488	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	9	,	489	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	9	,	490	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	9	,	491	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	9	,	492	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	9	,	493	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	9	,	494	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	9	,	495	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	9	,	496	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	3	,	233	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	3	,	234	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	3	,	235	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	3	,	236	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	3	,	237	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	3	,	238	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	3	,	239	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	3	,	240	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	3	,	241	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	3	,	242	,	10	},
{	1	,	-1	,	1	,	-1	,	4	,	4	,	454	,	10	},
{	1	,	-1	,	2	,	-1	,	4	,	4	,	455	,	10	},
{	2	,	-1	,	1	,	-1	,	4	,	4	,	456	,	10	},
{	2	,	-1	,	2	,	-1	,	4	,	4	,	457	,	10	},
{	3	,	-1	,	1	,	-1	,	4	,	4	,	458	,	10	},
{	3	,	-1	,	2	,	-1	,	4	,	4	,	459	,	10	},
{	4	,	-1	,	1	,	-1	,	4	,	4	,	460	,	10	},
{	4	,	-1	,	2	,	-1	,	4	,	4	,	461	,	10	},
{	5	,	-1	,	1	,	-1	,	4	,	4	,	462	,	10	},
{	5	,	-1	,	2	,	-1	,	4	,	4	,	463	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	7	,	41	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	7	,	42	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	7	,	43	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	7	,	44	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	7	,	45	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	7	,	46	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	7	,	47	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	7	,	48	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	7	,	49	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	7	,	50	,	10	},
{	1	,	-1	,	1	,	-1	,	4	,	5	,	457	,	10	},
{	1	,	-1	,	2	,	-1	,	4	,	5	,	458	,	10	},
{	2	,	-1	,	1	,	-1	,	4	,	5	,	459	,	10	},
{	2	,	-1	,	2	,	-1	,	4	,	5	,	460	,	10	},
{	3	,	-1	,	1	,	-1	,	4	,	5	,	461	,	10	},
{	3	,	-1	,	2	,	-1	,	4	,	5	,	462	,	10	},
{	4	,	-1	,	1	,	-1	,	4	,	5	,	463	,	10	},
{	4	,	-1	,	2	,	-1	,	4	,	5	,	464	,	10	},
{	5	,	-1	,	1	,	-1	,	4	,	5	,	465	,	10	},
{	5	,	-1	,	2	,	-1	,	4	,	5	,	466	,	10	},
--{	1	,	0	,	-1	,	-1	,	4	,	11	,	81	,	10	},
--{	1	,	1	,	-1	,	-1	,	4	,	11	,	82	,	10	},
--{	2	,	0	,	-1	,	-1	,	4	,	11	,	83	,	10	},
--{	2	,	1	,	-1	,	-1	,	4	,	11	,	84	,	10	},
--{	3	,	0	,	-1	,	-1	,	4	,	11	,	85	,	10	},
--{	3	,	1	,	-1	,	-1	,	4	,	11	,	86	,	10	},
--{	4	,	0	,	-1	,	-1	,	4	,	11	,	87	,	10	},
--{	4	,	1	,	-1	,	-1	,	4	,	11	,	88	,	10	},
--{	5	,	0	,	-1	,	-1	,	4	,	11	,	89	,	10	},
--{	5	,	1	,	-1	,	-1	,	4	,	11	,	90	,	10	},
{	1	,	0	,	-1	,	-1	,	4	,	11	,	91	,	10	},
{	1	,	1	,	-1	,	-1	,	4	,	11	,	92	,	10	},
{	2	,	0	,	-1	,	-1	,	4	,	11	,	93	,	10	},
{	2	,	1	,	-1	,	-1	,	4	,	11	,	94	,	10	},
{	3	,	0	,	-1	,	-1	,	4	,	11	,	95	,	10	},
{	3	,	1	,	-1	,	-1	,	4	,	11	,	96	,	10	},
{	4	,	0	,	-1	,	-1	,	4	,	11	,	97	,	10	},
{	4	,	1	,	-1	,	-1	,	4	,	11	,	98	,	10	},
{	5	,	0	,	-1	,	-1	,	4	,	11	,	99	,	10	},
{	5	,	1	,	-1	,	-1	,	4	,	11	,	100	,	10	},
--护腕
{	1	,	0	,	1	,	-1	,	4	,	10	,	501 ,	10	},
{	1	,	1	,	1	,	-1	,	4	,	10	,	502 ,	10	},
{	1	,	0	,	2	,	-1	,	4	,	10	,	503 ,	10	},
{	1	,	1	,	2	,	-1	,	4	,	10	,	504 ,	10	},
{	2	,	0	,	1	,	-1	,	4	,	10	,	505 ,	10	},
{	2	,	1	,	1	,	-1	,	4	,	10	,	506	,	10	},
{	2	,	0	,	2	,	-1	,	4	,	10	,	507	,	10	},
{	2	,	1	,	2	,	-1	,	4	,	10	,	508	,	10	},
{	3	,	0	,	1	,	-1	,	4	,	10	,	509	,	10	},
{	3	,	1	,	1	,	-1	,	4	,	10	,	510	,	10	},
{	3	,	0	,	2	,	-1	,	4	,	10	,	511	,	10	},
{	3	,	1	,	2	,	-1	,	4	,	10	,	512	,	10	},
{	4	,	0	,	1	,	-1	,	4	,	10	,	513	,	10	},
{	4	,	1	,	1	,	-1	,	4	,	10	,	514	,	10	},
{	4	,	0	,	2	,	-1	,	4	,	10	,	515	,	10	},
{	4	,	1	,	2	,	-1	,	4	,	10	,	516	,	10	},
{	5	,	0	,	1	,	-1	,	4	,	10	,	517	,	10	},
{	5	,	1	,	1	,	-1	,	4	,	10	,	518	,	10	},
{	5	,	0	,	2	,	-1	,	4	,	10	,	519	,	10	},
{	5	,	1	,	2	,	-1	,	4	,	10	,	520	,	10	},
};

tbNpcBai.tbWeaponsList = {
--,Genre,DetailType,ParticularType,Level
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
{	2	,	1	,	711	,	10	,},--气武
{	2	,	1	,	701	,	10	,},--剑武
{	2	,	1	,	691	,	10	,},
{	2	,	1	,	721	,	10	,},
{	2	,	1	,	971	,	10	,},
{	2	,	1	,	981	,	10	,},
{	2	,	1	,	621	,	10	,},
{	2	,	1	,	641	,	10	,},
{	2	,	1	,	1516	,	10	,},--剑古墓
{	2	,	2	,	214	,	10	,},--针古墓
--下面是pve的
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
{	2	,	1	,	891	,	10	,},--气武
{	2	,	1	,	881	,	10	,},--剑武
{	2	,	1	,	871	,	10	,},
{	2	,	1	,	901	,	10	,},
{	2	,	1	,	991	,	10	,},
{	2	,	1	,	1001	,	10	,},
{	2	,	1	,	801	,	10	,},
{	2	,	1	,	821	,	10	,},
{	2	,	1	,	1506	,	10	,},--剑古墓
{	2	,	2	,	204	,	10	,},--针古墓
};
tbNpcBai.tbWeaponsListSilver = {
--	Genre	,	DetailType	,	ParticularType	,	Level	},
{	2	,	1	,	1265	,	10	},
{	2	,	1	,	1266	,	10	},
{	2	,	1	,	1267	,	10	},
{	2	,	1	,	1268	,	10	},
{	2	,	2	,	145	,	10	},
{	2	,	2	,	146	,	10	},
{	2	,	1	,	1269	,	10	},
{	2	,	1	,	1270	,	10	},
{	2	,	1	,	1273	,	10	},
{	2	,	1	,	1274	,	10	},
{	2	,	1	,	1274	,	10	},
{	2	,	1	,	1271	,	10	},
{	2	,	1	,	1277	,	10	},
{	2	,	1	,	1275	,	10	},
{	2	,	1	,	1276	,	10	},
{	2	,	1	,	1278	,	10	},
{	2	,	1	,	1281	,	10	},
{	2	,	1	,	1280	,	10	},
{	2	,	1	,	1279	,	10	},
{	2	,	1	,	1282	,	10	},
{	2	,	1	,	1283	,	10	},
{	2	,	1	,	1284	,	10	},
{	2	,	1	,	1272	,	10	},
{	2	,	1	,	1274	,	10	},
{	2	,	1	,	1527	,	10	},--剑古墓
{	2	,	2	,	237	,	10	},--针古墓
};
tbNpcBai.tbWeaponsListGold = {
--	Genre	,	DetailType	,	ParticularType	,	Level	},
{	2	,	1	,	1335	,	10	},
{	2	,	1	,	1336	,	10	},
{	2	,	1	,	1337	,	10	},
{	2	,	1	,	1338	,	10	},
{	2	,	2	,	147	,	10	},
{	2	,	2	,	148	,	10	},
{	2	,	1	,	1339	,	10	},
{	2	,	1	,	1340	,	10	},
{	2	,	1	,	1343	,	10	},
{	2	,	1	,	1344	,	10	},
{	2	,	1	,	1344	,	10	},
{	2	,	1	,	1341	,	10	},
{	2	,	1	,	1347	,	10	},
{	2	,	1	,	1345	,	10	},
{	2	,	1	,	1346	,	10	},
{	2	,	1	,	1348	,	10	},
{	2	,	1	,	1351	,	10	},
{	2	,	1	,	1350	,	10	},
{	2	,	1	,	1349	,	10	},
{	2	,	1	,	1352	,	10	},
{	2	,	1	,	1353	,	10	},
{	2	,	1	,	1354	,	10	},
{	2	,	1	,	1342	,	10	},
{	2	,	1	,	1344	,	10	},
{	2	,	1	,	1528	,	10	},--剑古墓
{	2	,	2	,	238	,	10	},--针古墓
};

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
};

tbNpcBai.tbHorseList	= {
	{1, 12, 4, 2, -1},	-- 60级马
	{1, 12, 10, 4, -1},	-- 赤兔
};

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
{"古剑",5,1,"布",},
{"古针",5,2,"皮",},--正常是皮甲,现在没物品,先填布
};
tbNpcBai.tbJewsList = {--宝石配置
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
{"古剑",5,1,"布",},
{"古针",5,2,"皮",},
};

-- 对话
function tbNpcBai:OnDialog()
	Dialog:Say("测试用角色方案", {
		{"升级与入门派(130级)", self.LevelUpPlayer, self, 1, 130},
		
		{"领家族关卡测试装备(10,12)", 	self.TestEquip1012, self},
		{"领跨服宋金测试装备(15改)", 	self.GetPurple15, self},
		{"低等级橙装及杂物", self.TestEquipParam1, self},
		
		{"秘籍等级提升", self.LevelUpBook, self},
		{"秘籍技能和杂物", self.GetSundries, self},
		
		{"外网角色配置(自定义)->", self.WaiwangCeshi, self},
		--{"点卡版测试装备->", self.DianKaBanTest, self},
		--{"召唤洗髓岛秃驴", self.CallXiSuiNpc, self},
		--{"领取或升级五行印", self.GetWuXingYinLv, self},
		{"洗点", self.Xidian, self},
		{"删除背包内所有物品", self.DelAllItem, self},
		{"Kết thúc đối thoại"},
	});
end

--输入升级等级并入门
function tbNpcBai:AdjustPlayerLevel()
	Dialog:AskNumber("输入等级(0~150)", 150, tbNpcBai.LevelUpPlayer, tbNpcBai, 1);
end

--点卡版测试
function tbNpcBai:DianKaBanTest()
	local tbOpt = {
			{"升级与入门派(79级)", self.LevelUpPlayer, self, 1, 79},
			{"领79级用生活用品", self.GetAllItems79, self},
			{"点卡版79级角色装备", self.DianKaBanCeShi79, self},

			{"升级与入门派(109级)", self.LevelUpPlayer, self, 1, 109},
			{"领109级用生活用品", self.GetAllItems109, self},
			{"点卡版109级角色装备", self.DianKaBanCeShi109, self},

			{"领中级秘籍和升级秘籍技能", self.GetSpecialSkill, self},
			{"秘籍等级提升", self.LevelUpBook, self},
			{"洗点", self.Xidian, self},
			{"Ta chỉ đến xem thôi"},
		}
	Dialog:Say("您想要什么?", tbOpt);
end

--外网测试用角色配置
function tbNpcBai:WaiwangCeshi()
	local tbOpt = {
		{"升级与入门派(自设等级)", self.AdjustPlayerLevel, self},
		
		{"低等级橙装及杂物", self.TestEquipParam1, self},
		{"领+12套橙装及杂物", 		self.GetAllItems109, self},
		{"领+14套橙装及杂物", 		self.GetPurple, self},
		{"领+15改套橙装及杂物", 	self.GetPurple15, self},
		{"领+16套白银套及杂物", 	self.GetSilver, self},
		{"领+16套黄金套及杂物", 	self.GetGold, self},

		{"领各种单独物品装备->", 		self.GetSomeEquip,self},
		
		{"Ta chỉ đến xem thôi"},
	}
	Dialog:Say("您想要什么?", tbOpt);
end
--领单独的一些装备
function tbNpcBai:GetSomeEquip()
	local tbOpt = {
		{"各种技能和杂物", self.GetSundries, self},
		{"领同伴6技能3级", self.GetPartners, self, 3},
		{"领同伴6技能6级", self.GetPartners, self, 6},

		{"领+12橙武器", 		self.GetWeapons, self, self.tbWeaponsList, 12},
		{"领+14橙武器", 		self.GetWeapons, self, self.tbWeaponsList, 14},
		{"领+15橙武器", 		self.GetWeapons, self, self.tbWeaponsList, 15},
		{"领+16白银武器", 		self.GetWeapons, self, self.tbWeaponsListSilver, 16},
		{"领+16黄金武器", 		self.GetWeapons, self, self.tbWeaponsListGold, 16},

		{"领+1腰带", 			self.GetItems, self, self.tbBeltList, 14},
		
		{"领+16白银防具首饰", 	self.GetItems, self, self.tbArmorsListSilver, 16},
		{"领+16黄金防具首饰", 	self.GetItems, self, self.tbArmorsListGold, 16},

		{"领炼化+1防具+12", 	self.GetItems, self, self.tbArmorsList, 12},
		{"领炼化+1防具+14", 	self.GetItems, self, self.tbArmorsList, 14},
		--{"领炼化+1防具+16", 	self.GetItems, self, self.tbArmorsList, 16},

		{"Trang trước", self.WaiwangCeshi, self},
		{"Ta chỉ đến xem thôi"},
	}
	Dialog:Say("您想要什么?", tbOpt);
end

--输入装备等级
function tbNpcBai:TestEquipParam1()
	if me.nRouteId <= 0 then
		Dialog:Say("选定路线后再来吧", tbOpt);
		return
	end
	Dialog:AskNumber("装备等级(0~10)", 10, tbNpcBai.TestEquipParam2, tbNpcBai);
end

--输入强化等级
function tbNpcBai:TestEquipParam2(nEquipLv)
	Dialog:AskNumber("强化等级(0~16)", 16, tbNpcBai.TestEquip, tbNpcBai, nEquipLv);
end

--领任意等级装备
function tbNpcBai:TestEquip(nEquipLv,nEnhLevel)
	--披风及杂物
	tbNpcBai:GetSundries()
	--武器防具
	tbNpcBai:GetWeapons(tbNpcBai.tbWeaponsList, nEnhLevel, nEquipLv)
	tbNpcBai:GetItems(tbNpcBai.tbArmorsListPurple, nEnhLevel, nEquipLv+1)
end
--领基础物品
function tbNpcBai:GetSundries(nMantleLv)
	if me.nRouteId <= 0 then
		Dialog:Say("选定路线后再来吧", tbOpt);
		return
	end
	--武林秘籍洗髓经等
	local tbPoints =
	{
		--物品等级 = {次数上限，任务变量组，任务变量};
		[1] = {18,1,191,1, 5, 2040,  5}, --初级武林秘籍
		[2] = {18,1,191,2, 5, 2040,  8}, --中级武林秘籍
		[3] = {18,1,326,3, 2, 2040, 10}, --什锦百果粽
		[4] = {18,1,465,1, 2, 2040, 21}, --沧海月明
		
		[5] = {18,1,192,1, 5, 2040,  6}, --初级洗髓经
		[6] = {18,1,192,2, 5, 2040,  9}, --中级洗髓经
		[7] = {18,1,326,2, 2, 2040, 11}, --八宝粽
		[8] = {18,1,464,1, 2, 2040, 20}, --彩云追月
	};
	for i = 1,#tbPoints do
		local nNeed = tbPoints[i][5] - me.GetTask(tbPoints[i][6], tbPoints[i][7]);
		if nNeed > 0 then
			for j = 1, nNeed do
				me.AddItem(tbPoints[i][1], tbPoints[i][2], tbPoints[i][3], tbPoints[i][4]).Bind(1)
			end
		end
	end
	--领马
	local nHorseLevel = 1
	if me.nLevel >= 60 then
		nHorseLevel = 2
	end
	local pItem = me.AddItem(unpack(tbNpcBai.tbHorseList[nHorseLevel])).Bind(1);
	--各种其他途径获得的技能
	tbNpcBai:GetSpecialSkill();
	if nMantleLv then
		tbNpcBai:GetMantle(nMantleLv);
	else
		--输入披风等级
		Dialog:AskNumber("披风等级(1~10)", 10, tbNpcBai.GetMantle, tbNpcBai);
	end
	tbNpcBai:SetWuXingYin(1500);--轮回印
	me.AddItem(18,1,320,3);		--高级阵法
	me.AddItem(19,3,1,6);		--月菜
	me.AddItem(18,1,195,1);		--无限传送符
end
--披风
function tbNpcBai:GetMantle(nMantleLv)
	nMantleLv = math.min(math.max(nMantleLv,1),10)
	--披风
	if nMantleLv >=9 then
		me.AddItem(1,17,11+me.nSex,nMantleLv).Bind(1);--城战披风,换门派不用换披风
	else
		me.AddItem(1,17,me.nSeries*2+me.nSex-1,nMantleLv).Bind(1);
	end
end

--洗点
function tbNpcBai:Xidian()
	me.ResetFightSkillPoint();
	me.SetTask(2,1,1);
	me.UnAssignPotential();
end
--4%武器
function tbNpcBai:GetWeapons(tbItemList, nQianghua, nLevel)
	local nItemRouteId = (me.nFaction-1)*2 +me.nRouteId;
	if me.nRouteId <= 0 then
		Dialog:Say("选定路线后再来吧", tbOpt);
		return
	end
	local tmpItem = {unpack(tbItemList[nItemRouteId])}
	--不填nLevel的话就是直接等于表内填物品id
	nLevel = nLevel or 10;
	nLevel = math.min(math.max(nLevel,1), 10);
	tmpItem[3] = tmpItem[3] + nLevel - 10;
	tmpItem[4] = tmpItem[4] + nLevel - 10;
	tmpItem[6] = nQianghua or 0
	local pItem = me.AddItem(unpack(tmpItem))
	local nHoleLevel = 5;
	for i = 1, 3 do
	     pItem.MakeHole(i, nHoleLevel, 1);
	end
	pItem.Bind(1)
end
--给装备打孔
function tbNpcBai:EnchaseStone()
	--local pItem = me.AddItem(2,1,1287,10,-1,12)
	local nHoleLevel = 5;
	for i = 1, 3 do
		pItem.MakeHole(i, nHoleLevel, 1);
		--pItem.EnchaseStone(24, 1, 17, 5, i);
	end
	pItem.Bind(1);
end
--定制防具
function tbNpcBai:GetItems(tbItemList, nQianghua, nLevel, nHoleLevel)
	if me.nRouteId <= 0 then
		Dialog:Say("选定路线后再来吧", tbOpt);
		return
	end
	nHoleLevel = nHoleLevel or 5;
	local pItem
	--不填nLevel的话就是直接等于表内填物品id
	nLevel = nLevel or 1;
	nLevel = math.min(math.max(nLevel,1), 10);
	for i=1,#tbItemList do
		local nItemRouteId = (me.nFaction-1)*2 +me.nRouteId;
		if me.nRouteId ~= 0 then
			if tbItemList[i][1] == self.tbFixList[nItemRouteId][2] or tbItemList[i][1] == -1 then--检查五行是否相符
				if tbItemList[i][2] == me.nSex or tbItemList[i][2] == -1 then--检查性别是否相符
					if tbItemList[i][3] == self.tbFixList[nItemRouteId][3] or tbItemList[i][3] == -1 then--检查内外功是否相符
						if tbItemList[i][4] == self.tbFixList[nItemRouteId][4] or tbItemList[i][4] == -1 then--检查布甲皮是否相符
							pItem = me.AddItem(tbItemList[i][5],tbItemList[i][6],tbItemList[i][7]+nLevel-1,tbItemList[i][8]+nLevel-1,-1,nQianghua);
							--for i = 1, 3 do
							pItem.MakeHole(1, nHoleLevel, 1);
							pItem.MakeHole(2, nHoleLevel, 0);
							pItem.MakeHole(3, nHoleLevel, 0);
							--pItem.EnchaseStone(24, 1, 17, 5, i);
							--end
							pItem.Bind(1)
						end
					end
				end
			end
		end
	end
end
--+1腰带
function tbNpcBai:GetBelt(tbItemList)
	self:GetItems(tbItemList,14);
end

--加同伴
function tbNpcBai:GetPartners(nSkillLevel)
	if me.nRouteId <= 0 then
		Dialog:Say("选定路线后再来吧", tbOpt);
		return
	end
	Partner:AddPartner(me.nId, 2025, -1)
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

--各种其他途径获得的技能
function tbNpcBai:GetSpecialSkill()
	if (me.nRouteId == 0) then
		Dialog:Say("选定路线后再来吧", tbOpt);
		return;
	end
	--各种其他途径获得的技能
	me.AddFightSkill(10,20);--初级秘籍_轻功
	me.AddFightSkill(tbNpcBai.tbMidBookSkill[me.nFaction*2+me.nRouteId-2],10)--中级秘籍技能
	me.AddFightSkill(tbNpcBai.tbHighBookSkill[me.nFaction*2+me.nRouteId-2],10)--高级秘籍技能
	--me.AddFightSkill(1240+me.nFaction*2+me.nRouteId-2,10)--高级秘籍技能
	me.SetTask(1022,215,4095,1)--允许投点110技能
	if me.nLevel >=100 then
		me.AddItem(1,14,me.nFaction*2+me.nRouteId-2,3)--高级秘籍
	elseif me.nLevel >=70 then
		me.AddItem(1,14,me.nFaction*2+me.nRouteId-2,2)--中级秘籍
	elseif me.nLevel >=20 then
		me.AddItem(1,14,me.nFaction*2+me.nRouteId-2,1)--初级秘籍
	end
end

--点卡版79级装备
function tbNpcBai:DianKaBanCeShi79()
	local tbOpt = {
		{"领7级橙武器+10", self.GetWeapons, self, self.tbWeaponsList, 10, 7},
		{"领8级橙防具+10", self.GetItems, self, self.tbArmorsListPurple, 10, 8},

		{"Ta chỉ đến xem thôi"},
	}
	Dialog:Say("您想要什么?", tbOpt);
end

--点卡版109级装备
function tbNpcBai:DianKaBanCeShi109()
	local tbOpt = {
		{"领+12橙武器", 		self.GetWeapons, self, self.tbWeaponsList, 12},
		{"领炼化+1防具+12", 	self.GetItems, self, self.tbArmorsList, 12},

		{"Ta chỉ đến xem thôi"},
	}
	Dialog:Say("您想要什么?", tbOpt);
end

--79级+8套防具+10武器
function tbNpcBai:GetAllItems79()
	tbNpcBai:GetSundries(4)
	--武器防具
	tbNpcBai:GetWeapons(self.tbWeaponsList, 10, 7)
	tbNpcBai:GetItems(self.tbArmorsListPurple, 10, 8)
end
--+10套防具,12武器
function tbNpcBai:TestEquip1012()
	tbNpcBai:GetSundries(3);	--披风及杂物
	tbNpcBai:GetPartners(1);	--同伴
	--武器防具
	tbNpcBai:GetWeapons(tbNpcBai.tbWeaponsList, 12, 10);
	tbNpcBai:GetItems(tbNpcBai.tbArmorsListPurple, 10, 10+1);
end
--12套
function tbNpcBai:GetAllItems109()
	tbNpcBai:GetSundries(5)
	--武器防具
	tbNpcBai:GetWeapons(self.tbWeaponsList, 12)
	tbNpcBai:GetItems(self.tbArmorsList, 12)
end
--15改防具,16武器
function tbNpcBai:GetPurple15()
	tbNpcBai:GetSundries(7)
	tbNpcBai:GetPartners(3)
	local tbItemList = tbNpcBai.tbWeaponsList;
	tbNpcBai:GetWeapons(tbItemList, 16)
	local tbItemList = tbNpcBai.tbArmorsList;
	tbNpcBai:GetItems(tbItemList, 79)
end
--14套炼化
function tbNpcBai:GetPurple()
	tbNpcBai:GetSundries(7)
	tbNpcBai:GetPartners(3)
	local tbItemList = tbNpcBai.tbWeaponsList;
	tbNpcBai:GetWeapons(tbItemList, 14)
	local tbItemList = tbNpcBai.tbArmorsList;
	tbNpcBai:GetItems(tbItemList, 14)
end
--白银16套
function tbNpcBai:GetSilver()
	tbNpcBai:GetSundries(8);
	tbNpcBai:GetPartners(5);
	local tbItemList = tbNpcBai.tbWeaponsListSilver;
	tbNpcBai:GetWeapons(tbItemList, 16);
	local tbItemList = tbNpcBai.tbArmorsListSilver;
	tbNpcBai:GetItems(tbItemList, 16);
end
--黄金16套
function tbNpcBai:GetGold()
	tbNpcBai:GetSundries(9)
	tbNpcBai:GetPartners(6)
	local tbItemList = tbNpcBai.tbWeaponsListGold;
	tbNpcBai:GetWeapons(tbItemList, 16)
	local tbItemList = tbNpcBai.tbArmorsListGold;
	tbNpcBai:GetItems(tbItemList, 16)
	me.AddItem(5,23,1,1).Bind(1);
end
--轮回印
function tbNpcBai:GetWuXingYinLv(nLevel)
	Dialog:AskNumber("输入轮回印等级(0~1500)", 1500, tbNpcBai.SetWuXingYin, tbNpcBai);
end

--升级五行印
function tbNpcBai:SetWuXingYin(nLevel)
	nLevel = math.min(math.max(nLevel,0),1500);
	local pSignet = me.GetItem(Item.ROOM_EQUIP,Item.EQUIPPOS_SIGNET, 0);
	if not pSignet then
		--tbNpcBai:GetWuXingYin(nLevel)
		local b = me.AddItem(1,16,13,2);
		Item: SetSignetMagic(b,1,nLevel,0)
		Item: SetSignetMagic(b,2,nLevel,0)
		--Dialog:Say("您装备栏没有五行印，送你个吧");
		return 0;
	end
	Item:SetSignetMagic(pSignet, 1, nLevel, 0);
	Item:SetSignetMagic(pSignet, 2, nLevel, 0);
	Dialog:Say("成功升级五行印属性");
end

-- 升级角色
function tbNpcBai:LevelUpPlayer(nPosStartIdx, nSjLevel)
	if (me.nFaction ~= 0) then
		self:JoinFactionLevelUp(me.nFaction, nSjLevel);
		return;
	end
	local tbOpt		= {};
	local nCount	= 9;
	for i = nPosStartIdx, Player.FACTION_NUM do
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.LevelUpPlayer, self, i - 1, nSjLevel};
			break;
		end
		tbOpt[#tbOpt + 1]	= {Player:GetFactionRouteName(i), self.JoinFactionLevelUp, self, i, nSjLevel};
		nCount	= nCount - 1;
	end
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	Dialog:Say("加入门派", tbOpt);
end

-- 加入门派
function tbNpcBai:JoinFactionLevelUp(nIndex, nSjLevel)
	local nLevelUp = nSjLevel - me.nLevel;
	me.DirectChangeLevel(nLevelUp);
	me.CallClientScript({"me.DirectChangeLevel", nLevelUp});
	if me.nFaction ==0 then
		me.JoinFaction(nIndex);
	end
	me.AddBindMoney(self.nBindMoney);
	me.AddBindCoin(self.nBindCoin);
	me.Earn(100, Player.emKEARN_EVENT);
	for i = 1, 3 do
		local pItem = me.AddItem(unpack(self.tbExbag_20Grid))
		if pItem then
			pItem.Bind(1)
		end
	end
	--me.SetTask(self.nTaskGroupId,self.nTaskId2,1);
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

--删除背包内所有物品
function tbNpcBai:DelAllItem()
    local tbAllRoom = {
            Item.BAG_ROOM,
        }
    for _, tbRoom in pairs(tbAllRoom) do
        for _, nRoom in pairs(tbRoom) do
            local tbIdx = me.FindAllItem(nRoom);
            for i = 1, #tbIdx do
                local pItem = KItem.GetItemObj(tbIdx[i]);
                me.DelItem(pItem);
            end;
        end;
    end;
end

--输入升级等级并入门
function tbNpcBai:CallXiSuiNpc()
	CallNpc(3593,120,0,0);
end
