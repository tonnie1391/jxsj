-- 文件名　：presendcard_def.lua
-- 创建者　：zounan
-- 创建时间：2010-05-03 14:52:58
-- 描  述  ：


PresendCard.VERSION_TSK = 2120; --任务变量组2120
PresendCard.VERSION_TYPE = 2000;-- nTypeId为2000以上


PresendCard.ITEM_TIMEOUT = 30 *24 * 3600; -- 物品有效期一个月 （秒数）
PresendCard.ITEM_ID		 = {18,1,931,1};  -- 礼包ID

	
PresendCard.INDEX_NAME			= 1;	-- 活动名称
PresendCard.INDEX_CALLBACKFUNC	= 2;	-- 激活码验证回调函数
PresendCard.INDEX_CDKEYFLAG		= 3;	-- 激活码关键字
PresendCard.INDEX_ITEMTABLE		= 4;	-- 礼包id
PresendCard.INDEX_COUNT			= 5;	-- 礼包的个数
PresendCard.INDEX_TASKGROUP		= 6;	-- 记录激活标记的任务变量id
PresendCard.INDEX_TASKID		= 7;	
PresendCard.INDEX_STARTTIME		= 8;	-- 活动开启时间
PresendCard.INDEX_ENDTIME		= 9;	-- 活动结束时间
PresendCard.INDEX_KEYINDEX		= 10;	-- 关键字所对应的位置
PresendCard.INDEX_PARAM			= 11;	-- 参数
PresendCard.INDEX_GATEWAYLIMIT	= 12;	-- 区服限制
PresendCard.INDEX_OTHER			= 13;	-- 其他
PresendCard.INDEX_TIMEOUT		= 14;	-- 物品有效期(单位是小时)

PresendCard.RESULT_DESC =
{
	[1] = "成功验证",
	[2] = "验证失败",
	[3] = "帐号不存在",
	[1009] = "传入的参数非法或为空",
	[1500] = "此激活码不存在",
	[1501] = "此激活码已被激活使用",
	[1502] = "此激活码已过期",
}

PresendCard._FLAG_TEST = { [2] = 0, [3] = 0 , [4] = 0,[6] = 0, [2000] = 0};
	
	

PresendCard.PRESEND_TYPE = 
{
	[0] = {"默认", "PresendCard:ErrorCard"};		--验证不成功
	[1] = {"新手卡", "SpecialEvent.NewPlayerCard:OnCheckCardResult"};	--新手卡
	[2] = {"联想合作伙伴", "PresendCard:OnCheckResult_LX", "LX", {18,1,387,1}, 1, 2027, 73, 20090807, 20101231, {1,6}};		--联想活动
--	[3] = {"百事合作伙伴", "PresendCard:OnCheckResult_JN", "JN", {18,1,401,1}, 1, 2027, 76, 20090901, 20100331, {1,2}};		--百事活动
	[4] = {"戴尔合作伙伴", "PresendCard:OnCheckResult_DL", "DL", {18,1,533,1}, 1, 2027, 92, 20091201, 20100630, {1,6}};		--戴尔活动
	[6] = {"YY合作", "PresendCard:OnCheckResult_YY", "YY", {18,1,931,1}, 1, 0, 0, 20100405, 20100630, {1,2},nil,"gate1107,gate1011","PresendCard:OnCheckBefore_YY"};		--YY活动
	[2000] = {"马来新手活动", "PresendCard:OnCheckResult_MLXS", "MLXS", {18,1,910,1}, 1, 2091, 1, 0, 0, {1,2,3,4}};		--马来新手活动	
}


--YY的参数表
PresendCard.PRESEND_TYPE[6][PresendCard.INDEX_PARAM] =
{
 	[1] = {[[AddItem:"18,1,489,2","1","1","0"]],[[AddItem:"18,1,71,3","10","1","0"]],},
 	[2] = {[[AddBindCoin:"7000"]],},
 	[3] = {[[AddItem:"18,1,244,2","1","1","0"]],}, --魂石 	
 	[4] = {[[AddItem:"18,1,932,1","1","1","0"]],}, --面具
 	[5] = {[[AddItem:"18,1,71,3","10","1","0"]],}, --强效
 	[6] = {[[AddBindMoney:"800000"]],},			 --绑银
 	[7] = {[[AddItem:"18,1,1,7","2","1","0"]],},   --7玄	
 	[8] = {[[AddItem:"18,1,212,1","2","1","0"]],}, --祈福令牌初级
 	[9] = {[[AddItem:"18,1,933,1","6","1","0"]],}, --圣诞糖果 TODO
 	[10] = {[[AddItem:"18,1,113,3","1","1","0"]],}, --传音海螺	
	[11] = {[[AddItem:"18,1,932,1","1","1","0"]],}, --面具
	[12] = {[[AddItem:"18,1,212,1","2","1","0"]],}, --祈福初级
	[13] = {[[AddBindCoin:"3500"]],}, 				--绑金3500
	[14] = {[[AddItem:"18,1,251,1","2","1","0"]],}, --秘境地图 	 	 	
	[15] = {[[AddItem:"18,1,933,1","5","1","0"]],}, --圣诞糖果 TODO
	[16] = {[[AddItem:"18,1,1,7","1","1","0"]],}, 	--7玄
	[17] = {[[AddBindMoney:"400000"]],}, 			--绑银40W
	[18] = {[[AddItem:"18,1,113,2","3","1","0"]],}, --传音海螺 中
	[19] = {[[AddItem:"20,1,465,1","10","1","0"]],}, --空白的心得书
	[20] = {[[AddItem:"18,1,195,1","1","1","43200"]],}, --无限的传送符
	[21] = {[[AddItem:"18,1,1,7","1","1","0"]],}, 	--7玄
	[22] = {[[AddItem:"18,1,933,1","4","1","0"]],}, --圣诞糖果 TODO
	[23] = {[[AddItem:"18,1,71,2","12","1","0"]],}, --大白
	[24] = {[[AddItem:"18,1,251,1","1","1","0"]],[[AddItem:"18,1,189,2","2","1","0"]],}, --秘境
	[25] = {[[AddItem:"18,1,212,1","2","1","0"]],}, --祈福初级
	[26] = {[[AddBindCoin:"2000"]],},				--绑金2000
	[27] = {[[AddBindMoney:"500000"]],},	    	--绑银50W
	[28] = {[[AddItem:"1,12,27,4","1","1","57600"]],}, --吉祥虎 	
};

PresendCard.PresendCardParamYY = 
{
	["C1"] = 1;
	["C2"] = 2;	 
	["C3"] = 3;	
	["C4"] = 4;	
	["C5"] = 5;	
	["C6"] = 6;	
	["C7"] = 7;	
	["C8"] = 8;	
	["C9"] = 9;	
	["C0"] = 10;	
	["D1"] = 11;	
	["D2"] = 12;	
	["D3"] = 13;	
	["D4"] = 14;	
	["D5"] = 15;	
	["D6"] = 16;	
	["D7"] = 17;	
	["D8"] = 18;	
	["D9"] = 19;	
	["D0"] = 20;	
	["E1"] = 21;	
	["E2"] = 22;	
	["E3"] = 23;
	["E4"] = 24;
	["E5"] = 25;
	["E6"] = 26;
	["E7"] = 27;
	["E8"] = 28;	
};



PresendCard.KEYNAME = 
{
	["AddItem"] 		= {1, "获取道具", 	},		--物品
	["AddMoney"] 		= {2, "增加银两", 	},		--银两
	["AddBindMoney"] 	= {3, "增加绑银",   },		--绑定银两
	["AddBindCoin"] 	= {4, "增加绑金", 	},		--绑定金币
	["AddKinRepute"] 	= {5, "增加江湖威望", },	--江湖威望	
	["AddExp"]			= {6, "增加经验",	},		--经验	
	["AddTitle"] 		= {7, "增加称号",   },		--＋称号	
	["AddSpeTitle"] 	= {8, "增加特殊称号",},		--＋特殊称号
	["AddExOpenQiFu"] = {9, "增加祈福机会",},		--＋祈福机会
	["AddExOpenFuDai"] = {10, "增加开福袋机会",},	--＋开福袋机会
};
