-------------------------------------------------------
-- 文件名　：changelive.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-03-18 14:18:57
-- 文件描述：剑网转剑世客户端接受功能
-- 增加设计：1. 增加区服的范围；2. 只有1级小号可以领奖；3. 提升等级
-- 增加设计：4. 金麟区；5. 价值量规则修改；6. 结束时间变化；7.增加福利次数
-- 增加设计：8. 第二批剑网转剑世 2009-5-15
-------------------------------------------------------

-- 定义剑网转剑世这个特殊事件
local tbChangeLive = {};
SpecialEvent.ChangeLive = tbChangeLive;

-- "\\setting\\player\task_def.txt" 这个表中增加一行任务标记
tbChangeLive.TASKGID = 2084;				-- 剑网转剑世活动相关
tbChangeLive.TIME_BEGIN = 200906052400;		-- 活动开始时间
tbChangeLive.TIME_END = 200906152400;		-- 活动结束时间

tbChangeLive.TASK_CHANGELIVE_AWARD = 1;		-- 领取奖励标记
tbChangeLive.TASK_CHANGELIVE_VALG = 2;		-- 累计绑定价值量
tbChangeLive.TASK_CHANGELIVE_VALS = 3;		-- 累计非绑定价值量

tbChangeLive.TASK_CHANGELIVE_MONEY_S = 4;	-- 非绑定银两
tbChangeLive.TASK_CHANGELIVE_COIN_G = 5;	-- 绑定金币
tbChangeLive.TASK_CHANGELIVE_MONEY_G = 6;	-- 绑定银两

tbChangeLive.IS_AWARDED_EXT_POINT = 7;		-- 使用7号扩展点(千位)

tbChangeLive.REQUIRE_SPACE = 1;				-- 需要多少背包空间
tbChangeLive.DEF_ITEM = {18, 1, 312, 1};	-- 钱袋子item编号

-- 剑网转剑侠价值量汇总表
tbChangeLive.INPUT_FILE_PATH = "\\setting\\event\\changelive\\jstran_accvalsum.txt";
-- 转换成功的剑网账号表
tbChangeLive.OUPUT_FILE_PATH = "\\..\\jstran_success.txt";

-- 第二批转剑世名单
tbChangeLive.INPUT_FILE_PATH_2 = "\\setting\\event\\changelive\\jstran_accvalsum_2.txt";
tbChangeLive.OUPUT_FILE_PATH_2 = "\\..\\jstran_success_2.txt";

-- 保存转向区服标示
tbChangeLive.tbServerList =
{
	[1] = 1,	-- 青龙电信
	[2] = 2,	-- 白虎网通
	[3] = 3,	-- 朱雀电信
	[4] = 4,	-- 玄武电信
	[5] = 5,	-- 紫薇网通
	[6] = 6,	-- 北斗电信
	[7] = 7,	-- 金麟电信
}

-- 用来存放转换表
tbChangeLive.tbReform = {};

-- 活动开关
tbChangeLive.bOpen = 1;

function tbChangeLive:_SetState(bOpen)
	self.bOpen = bOpen;
end

function tbChangeLive:_GetState()
	return self.bOpen;
end

-- 用来存放输入表
function tbChangeLive:Init()
	
	if self:_GetState() ~= 1 then
		return 0;
	end
	
	-- 读取价值量汇总表
	local tbMap	= {};
	--local tbInput = Lib:LoadTabFile(self.INPUT_FILE_PATH);
	local tbInput = Lib:LoadTabFile(self.INPUT_FILE_PATH_2);
	
	-- 读不到则返回
	if not tbInput then 
		return 0;
	end	
	
	-- 判断是否没数据
	if Lib:CountTB(tbInput) < 1 then
		return 0;
	end
	
	-- 初始化，生成一个转换表
	for _, tbRow in ipairs(tbInput) do 	 	
	 	tbMap[tbRow["jsAccDatabase"].."_"..string.upper(tbRow["jsAccount"])] = tbMap[tbRow["jsAccDatabase"].."_"..string.upper(tbRow["jsAccount"])] or {};
	 	tbMap[tbRow["jsAccDatabase"].."_"..string.upper(tbRow["jsAccount"])][tbRow["jxServerGroup"].."_"..tbRow["jxAccount"]] 
	 		= {tonumber(tbRow["nAccValG"]), tonumber(tbRow["nAccValS"])};
	end
	
	-- 存入转换表
	self.tbReform = tbMap;
end

-- 活动开关检测
function tbChangeLive:CheckState()
	
	if self:_GetState() ~= 1 then
		return 0;
	end
	
	-- 判断是否为剑侠接口专区
	local szServer = GetGatewayName();
	local nJsAccDB = tonumber(string.sub(szServer, 5, 6));
	
	if not self.tbServerList[nJsAccDB] then
		return 0;
	end
	
	-- 取当前服务器时间转换数字
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));

	-- 判断时间
	if nNowDate < self.TIME_BEGIN or nNowDate > self.TIME_END then
		return 0;
	end
	
	-- 判断是否没读到
	if not self.tbReform then 
		return 0;
	end
	
	-- 判断是否没数据
	if Lib:CountTB(self.tbReform) < 1 then
		return 0;
	end

	-- 活动开启
	return 1;
end

-- 触发对话框
function tbChangeLive:OnDialog()
		
	local bOk, szMsg = self:CheckGetAward();
	
	-- 无法领取奖励
	if bOk ~= 1 then
		
		-- 提示对话框
		Dialog:Say(szMsg, {"Ta hiểu rồi"});
		
		-- 直接返回
		return;
	end
	
	-- 条件选项：1. 领取奖品; 2. 我还要想想
	local tbOpt = {
		{"领取奖品", self.SelectAccount, self},
		{"我还要想想"},
	}
	
	local szMsg = string.format("欢迎从异世来的侠客，老朽这里有礼物送给你，以帮助你度过前期的难关。");
	Dialog:Say(szMsg, tbOpt);
end

function tbChangeLive:CheckAccount()
	
	-- 先找到账号名
	local szAccount = string.upper(me.szAccount);
	
	-- 再找网关的名字
	local szServer = GetGatewayName();
	
	-- 形式为"gate0102"之类，我们用它的5-6位
	local nJsAccDB = tonumber(string.sub(szServer, 5, 6));
	
	-- 根据tbServerList转换为[0-1]格式
	local nServerGroup = self.tbServerList[nJsAccDB];
	
	if not nServerGroup then
		return 0;
	end
	
	-- 连起来当索引
	local szIndex = nServerGroup.."_"..szAccount;

	-- 取匹配账号表
	local tbMap = self.tbReform[szIndex];
	
	-- 不存在账号则返回0
	if not tbMap then
		return 0;
	end
	
	-- 存在返回1和表
	return 1, tbMap;
end

-- 判断是否有账号转入剑世，并相应生成账号表
function tbChangeLive:CheckGetAward()
	
	if self:_GetState() ~= 1 then
		return 0, "对不起，剑网转剑世活动已经关闭。";
	end

	local bOk = self:CheckAccount();
	
	-- 不存在账号
	if bOk ~=1 then
		return 0, "对不起，并没有任何账号申请转入您的剑侠世界账号。";
	end
	
	-- 取7号扩展点千位数值
	local nPoint = me.GetExtPoint(self.IS_AWARDED_EXT_POINT);
	local nFoo = math.floor(nPoint / 1000);		-- 取整
	local nExtPoint = math.mod(nFoo, 10);		-- 取余数
	
	-- 判断是否有标记
	if me.GetTask(self.TASKGID, self.TASK_CHANGELIVE_AWARD) ~= 0 then -- 角色领取过
		return 0, "你已经领取过了，不要来骗我了。";
	
	 --可以激活该角色	
	elseif nExtPoint ~= 0 then 	-- 账号下其他角色领取过了
		return 0, "对不起，您的账号下已经有其他角色领取过了。";	
	
	-- 是否是1级小号
	elseif me.nLevel > 1 then
		return 0, "对不起，您的角色等级太高，无法领取奖励。";
	end
	
	-- 至此该角色可以领取奖励
	return 1;
end

function tbChangeLive:SelectAccount()
		
	-- 得到转入账号表
	local _, tbAccount = self:CheckAccount();
	
	if not tbAccount then 
		return 0;
	end
	
	local szMsg = "";
	local tbOpt = {};	
	
	-- 判断转入账号数目
	local nCount = Lib:CountTB(tbAccount);	
	
	-- 只有一个账号
	if nCount == 1 then
		szMsg = "你有一个账号要转到这里来，请确认。";
			
	-- 多个账号
	elseif nCount > 1 then
		szMsg = string.format("你有好几个账号都想要转到这里来，<color=red>但是你只能选择一个，请作出选择。<color>");
	end
		 	
	-- 对话框账号列表**这里不能用ipairs
	for szLine, tbRow in pairs(tbAccount) do 
	
		-- 分割字符串
		local nAt = string.find(szLine, "_");
		local szJxAccDB = string.sub(szLine, 1, nAt - 1);
		local szJxAccount = string.sub(szLine, nAt + 1);
		local nServer = math.mod(tonumber(szJxAccDB), 10);
		local nRegion = math.floor(tonumber(szJxAccDB)/10);
		
		-- 生成列表
		table.insert(tbOpt, {
			"将剑网<color=yellow> "..nRegion.."区"..nServer.."服 <color>的账号转过来",
			self.ConfirmAccount, self, tbRow[1], tbRow[2], szJxAccDB, szJxAccount,
			nRegion.."区"..nServer.."服"
			}
		);
	end
	
	-- 增加一个返回项
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
end

-- 确认使用该角色领取奖励
function tbChangeLive:ConfirmAccount(nAccValG, nAccValS, szJxAccDB, szJxAccount, szTxt)
	
	-- 增加一个确认对话框，同时显示账号名称
	local szMsg	= string.format("你确定要把剑网<color=yellow> "..szTxt.." <color>的账号\r\n<color=yellow> "..szJxAccount.." <color>转过来么？");
	local tbOpt = {
		{"是", self.GetAward, self, nAccValG, nAccValS, szJxAccDB, szJxAccount},
		{"Để ta suy nghĩ thêm"}
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 发放奖励，生成转服成功表
function tbChangeLive:GetAward(nAccValG, nAccValS, szJxAccDB, szJxAccount)
		
	-- 发奖励前再判断一次，避免非法客户端进入
	local bOk = self:CheckGetAward();
	
	if bOk ~= 1 then
		return 0;
	end
	
	-- 判定背包空间是否足够
	if me.CountFreeBagCell() < tbChangeLive.REQUIRE_SPACE then
		Dialog:Say("你背包满了，放不下，留"..tostring(tbChangeLive.REQUIRE_SPACE).."格空间再来吧。", {"Ta hiểu rồi"});
		return 0
	end

	-- 发放奖励物件
	local pItem = me.AddItem(unpack(self.DEF_ITEM));
	
	-- 失败则返回
	if not pItem then
		return 0;
	end
	
	pItem.Bind(1); 	-- 绑定之，不用加时限
	
	-- 绑定财富补偿
	local nExtraValG = self:ExtraValue(tonumber(nAccValG));
	local nCurrValG = tonumber(nAccValG) + tonumber(nExtraValG);

	-- 价值量设任务变量放在角色身上
	me.SetTask(self.TASKGID, self.TASK_CHANGELIVE_VALG, nCurrValG);
	me.SetTask(self.TASKGID, self.TASK_CHANGELIVE_VALS, tonumber(nAccValS));
	
	-- 价值量转换
	local nMKP, nGTP, nMoneyG, nMoneyS, nCoinG = self:TransValue(nCurrValG, tonumber(nAccValS));
	
	-- 记录在玩家身上
	me.SetTask(self.TASKGID, self.TASK_CHANGELIVE_MONEY_G, nMoneyG);
	me.SetTask(self.TASKGID, self.TASK_CHANGELIVE_MONEY_S, nMoneyS);
	me.SetTask(self.TASKGID, self.TASK_CHANGELIVE_COIN_G, nCoinG);
	
	-- 精活直接增加
	me.ChangeCurMakePoint(nMKP);
	me.ChangeCurGatherPoint(nGTP);
	
	-- 跟绑金不同，增加精活要自己写提示
	me.Msg(string.format("您获得了<color=yellow>%s<color>点精力", nMKP));
	me.Msg(string.format("您获得了<color=yellow>%s<color>点活力", nGTP));

	-- 成功提示文字
	local szMsg = string.format("你成功领取礼物，获得%s，请查收！", pItem.szName);
	
	-- 提升角色等级
	self:SetTransLevel();
		
	-- 设置扩展点，该账号其他角色不能领取奖励
	-- fix a bug...2009-3-26
	me.AddExtPoint(self.IS_AWARDED_EXT_POINT, 1000);
	
	-- 角色本身标记
	me.SetTask(self.TASKGID, self.TASK_CHANGELIVE_AWARD, tonumber(GetLocalDate("%Y%m%d")));
	
	-- make log
	Dbg:WriteLog("SpecialEvent.ChangeLive", "剑网转剑世", me.szAccount, me.szName, 
		"绑定财富："..tonumber(nAccValG), "不绑定财富："..tonumber(nAccValS), "补偿财富："..tonumber(nExtraValG));
	
	-- 客服log
	local szLog = "转入剑世成功，获得绑定财富：" .. nAccValG .. "，不绑定财富：" .. nAccValS .. "，补偿财富：" .. nExtraValG;
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	
	-- 生成转服表
	local szOutput = szJxAccount.."\t"..szJxAccDB.."\t\r\n";
	--KIo.AppendFile(self.OUPUT_FILE_PATH, szOutput);
	--GCExcute({"KFile.AppendFile", self.OUPUT_FILE_PATH, szOutput});
	GCExcute({"KFile.AppendFile", self.OUPUT_FILE_PATH_2, szOutput});

	Dialog:Say(szMsg, tbOpt);
end

-- 绑定财富补偿
function tbChangeLive:ExtraValue(nAccValG)
	
	local nBasicFactor = 0;		-- 基本权值
	local nRoleFactor = 0;		-- 角色权值
	local nFixedFactor = 0;		-- 固定补偿
	
	local nRoleValG = 0;		-- 角色财富
	local nExtraValG = 0;		-- 补偿财富
	
	-- 服务器等级上限150级
	if TimeFrame:GetState("OpenLevel150") == 1 then
		
		local nOpenTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
		local nCurrTime = GetTime();
		
		if nCurrTime - nOpenTime >= 180 * 60 * 60 * 24 then
			nBasicFactor = 40;
			nRoleFactor = 0.5;
			nFixedFactor = 100000;
		else
			nBasicFactor = 30;
			nRoleFactor = 0.4;
			nFixedFactor = 50000;	
		end

	-- 服务器等级上限99级
	elseif TimeFrame:GetState("OpenLevel99") == 1 then
		nBasicFactor = 20;
		nRoleFactor = 0.3;
		nFixedFactor = 30000;
	
	-- 服务器等级上限89级
	elseif TimeFrame:GetState("OpenLevel89") == 1 then
		nBasicFactor = 10;
		nRoleFactor = 0.2;
		nFixedFactor = 20000;
	
	-- 服务器等级上限79级
	elseif TimeFrame:GetState("OpenLevel79") == 1 then
		nBasicFactor = 5;
		nRoleFactor = 0.1;
		nFixedFactor = 10000;
	
	-- 服务器等级上限69级：什么都不给
	else
		return 0;
	end
	
	if nBasicFactor > 0 then
		
		-- 4倍时间*0.5小时
		me.SetTask(1023, 7, me.GetTask(1023, 7) + nBasicFactor * 0.5 * 10);
		
		-- 祈福机会1次
		Task.tbPlayerPray:AddCountByLingPai(me, nBasicFactor);
		
		-- 福袋次数10
		me.SetTask(2013, 4, me.GetTask(2013, 4) + nBasicFactor * 10);
		
		-- 精活使用个数5
		me.SetTask(2024, 20, me.GetTask(2024, 20) + nBasicFactor * 5);
		me.SetTask(2024, 21, me.GetTask(2024, 21) + nBasicFactor * 5);
		
		-- 江湖威望3
		me.AddKinReputeEntry(nBasicFactor * 3);
	end
	
	nRoleValG = nAccValG * nRoleFactor;
	
	if nRoleValG > 20000 then
		nRoleValG = 20000;
	end
	
	nExtraValG = nRoleValG + nFixedFactor;
	
	return nExtraValG;
end

-- 价值量转换成相应的精活、绑金、绑银、银两
function tbChangeLive:TransValue(nAccValG, nAccValS)

	local nMKP, nGTP, nMoneyG, nMoneyS, nCoinG;
	
	-- 非绑定价值
	if nAccValS > 32000 then		
		nMKP = 100000; -- 10万精力
		nGTP = 100000; -- 10万活力
		nMoneyS = 2400000 + (nAccValS - 32000) * 150 
		
	elseif nAccValS > 0 then		
		nMKP = nAccValS * 3.125;
		nGTP = nAccValS * 3.125;
		nMoneyS = nAccValS * 75;
		
	else -- 出问题的情况，处理一下..
		nMKP = 0;
		nGTP = 0;
		nMoneyS = 0;	
	end
	
	-- 绑定价值
	if nAccValG > 0 then
		nCoinG = nAccValG * 0.8;
		nMoneyG = nAccValG * 40;
	else
		nCoinG = 0;
		nMoneyG = 0;
	end
		
	-- STR to INT
	return 
		math.floor(tonumber(nMKP)), 
		math.floor(tonumber(nGTP)), 
		math.floor(tonumber(nMoneyG)), 
		math.floor(tonumber(nMoneyS)), 
		math.floor(tonumber(nCoinG));
end

-- 设置转入后角色等级，为服务器开放等级前一档次
function tbChangeLive:SetTransLevel()
	
	-- 再判断一次
	if me.nLevel > 1 then
		return;
	end
	
	-- 服务器等级上限150级
	if TimeFrame:GetState("OpenLevel150") == 1 then
		me.AddLevel(99-me.nLevel);
		return;
	end
	
	-- 服务器等级上限99级
	if TimeFrame:GetState("OpenLevel99") == 1 then
		me.AddLevel(89-me.nLevel);
		return;
	end
	
	-- 服务器等级上限89级
	if TimeFrame:GetState("OpenLevel89") == 1 then
		me.AddLevel(79-me.nLevel);
		return;
	end
	
	-- 服务器等级上限79级
	if TimeFrame:GetState("OpenLevel79") == 1 then
		me.AddLevel(69-me.nLevel);
		return;
	end
	
	-- 69的上限就是1级
end

-- 脚本加载初始化
tbChangeLive:Init();
