-- 文件名　：gbltask.lua
-- 创建者　：maiyajin
-- 创建时间：2008-11-13 11:30:30

Require("\\script\\misc\\globaltaskdef.lua");

--注意：注册新功能需添加到tbSwitchs末尾，不能影响已有项的顺序
GblTask.tbSwitchs	= {
	--name, default value
	{"UI_PAYONLINE", 1},
	{"UI_HELPSPRITE_ZHIDAO", 1},
	{"UI_DAILY", 1},
	{"PAYONLINE_REFRESH_MONEY", 1},
	{"UI_HELPSPRITE_DOMAIN", 0},
};

assert(#GblTask.tbSwitchs <= 32, "目前最多可设32项");

--C/S
--查询所需功能是否打开，打开返回1，否则返回0
--if (GblTask:GetUiFunSwitch("UI_HELPSPRITE_ZHIDAO") == 1) then
--		TODO:...
--end
function GblTask:GetUiFunSwitch(szSwitch)
	local nData  = KGblTask.SCGetDbTaskInt(DBTASD_UI_FUN_SWITCH);
	local nIndex = self:GetBitIndex(szSwitch);
	local nBit   = KLib.GetBit(nData, nIndex);
	local nOpen  = self:Bit2Open(nIndex, nBit);
	return nOpen;
end

--S
--设置功能开关：1为开，0为关
function GblTask:SetUiFunSwitch(szSwitch, nOpen)
	local nData  = KGblTask.SCGetDbTaskInt(DBTASD_UI_FUN_SWITCH);
	local nIndex = self:GetBitIndex(szSwitch);
	local nBit   = self:Open2Bit(nIndex, nOpen);
	nData = KLib.SetBit(nData, nIndex, nBit);
	KGblTask.SCSetDbTaskInt(DBTASD_UI_FUN_SWITCH, nData);
end

--输入功能名及其存储在DBTASD_UI_FUN_SWITCH中的bit, 返回相应nOpen
--nBit = 0 表示默认值， nBit = 1 表示不是默认
function GblTask:Bit2Open(nIndex, nBit)
	assert(nBit == 0 or nBit == 1);
	local nDefault = self.tbSwitchs[nIndex][2];
	assert(nDefault == 0 or nDefault == 1);
	if(nBit == 0) then
		return nDefault;
	else
		return 1 - nDefault;	-- 1变0、0变1
	end
end

--输入功能名及nOpen, 返回DBTASD_UI_FUN_SWITCH中相应bit
--返回值 nBit = 0 表示默认值， nBit = 1 表示不是默认
function GblTask:Open2Bit(nIndex, nOpen)
	local nDefault = self.tbSwitchs[nIndex][2];
	assert(nDefault == 0 or nDefault == 1);
	if(nDefault == nOpen) then
		return 0;
	else
		return 1;
	end
end

--查找功能名储存在DBTASD_UI_FUN_SWITCH的第几位
function GblTask:GetBitIndex(szSwitch)
	for i, v in ipairs(self.tbSwitchs) do
		if (v[1] == szSwitch) then
			return i;
		end
	end
	assert(false, "找不到相应功能名");
end

function GblTask:CleanUiSwitch()
	KGblTask.SCSetDbTaskInt(DBTASD_UI_FUN_SWITCH, 0);
end

------------------------------同步逻辑----------------------------------

-- 客户端、服务端 变量数据
GblTask.tbSyncClientTaskData	= {};

-- 客户端接收
function GblTask:s2c_SetTask(key, value)
	GblTask.tbSyncClientTaskData[key]	= value;
end
function GblTask:s2c_AllTask(tbTaskData)
	GblTask.tbSyncClientTaskData	= tbTaskData;
end

-- 服务器启动
function GblTask:OnStart()
	for _, nKey in ipairs(self.tbSyncReg) do
		local nValue	= KGblTask.SCGetDbTaskInt(nKey);
		local szValue	= KGblTask.SCGetDbTaskStr(nKey);
		if (nValue and nValue ~= 0) then
			self.tbSyncClientTaskData[nKey]	= nValue;
		elseif (szValue and szValue ~= "") then
			self.tbSyncClientTaskData[nKey]	= szValue;
		end
	end
end

-- 服务器玩家上线
function GblTask:OnLogin()
	me.CallClientScript({"GblTask:s2c_AllTask", self.tbSyncClientTaskData});
end

-- 服务器变量改变
function GblTask:OnSetTask(nKey, varValue)
	if (self.tbSyncClientTaskData[nKey]	~= varValue) then
		self.tbSyncClientTaskData[nKey]	= varValue;
		KPlayer.CallAllClientScript({"GblTask:s2c_SetTask", nKey, varValue});
	end
end

-- 服务器注册
if (MODULE_GAMESERVER) then
	-- 注册需要同步客户端的变量
	KGblTask.RegistSyncClientTask(GblTask.tbSyncReg);
	
	-- 注册服务器启动调用
	ServerEvent:RegisterServerStartFunc(GblTask.OnStart, GblTask);
	
	-- 注册玩家上线调用
	PlayerEvent:RegisterGlobal("OnLogin", GblTask.OnLogin, GblTask)
end
