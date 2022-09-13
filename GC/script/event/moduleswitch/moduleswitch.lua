------------------------------------------------------
-- 文件名　：moduleswitch.lua
-- 创建者　：dengyong
-- 创建时间：2010-08-10 11:28:41
-- 功能    ：功能模块开关控制
------------------------------------------------------
if not SpecialEvent.tbModuleSwitch then
	SpecialEvent.tbModuleSwitch = {};
end

local tbModuleSwitch = SpecialEvent.tbModuleSwitch;

tbModuleSwitch.szFileName = "\\setting\\misc\\moduleswitch.txt";
tbModuleSwitch.tbSwitchState = {};

--tb = 
--{
--	{szModule, nstate, szCallBack}
--}
function tbModuleSwitch:LoadConfig()
	local tbFile = Lib:LoadTabFile(self.szFileName);
	if not tbFile then
		return;
	end

	self.tbSwitchState = {};
	for i, tbData in pairs(tbFile) do
		-- 因为运行到这里的时候还不知道这个字符串对应的table是否已经被加载了，
		-- 因此，这是还不能将字符串转成table。
		local szModule = tbData["moduletable"];
		local szName = tbData["modulename"];
				
		-- 开关状态
		local nState = assert(tonumber(tbData["switch"]));		-- 1表示开启，0表示关闭
		
		local tbModuleData = {};
		tbModuleData.szModule = szModule;
		tbModuleData.nState = nState;
		tbModuleData.szCallBack = tbData["callbackfun"];
		
		self.tbSwitchState[szName] = tbModuleData;
	end
end

function tbModuleSwitch:OnServerStart()
	for _, tbData in pairs(self.tbSwitchState) do
		local nState = tbData.nState;
		local szModule = tbData.szModule;
		local szFun  = tbData.szCallBack;	
	
		local tbModule = self:SplitStrToTab(szModule);
		
		if tbModule and tbModule[szFun] then
			-- 如果是全局函数，不需要self值
			if tbModule == _G then
				tbModule[szFun](nState);
			else
				tbModule[szFun](tbModule, nState);
			end
		end
	end
end

function tbModuleSwitch:SplitStrToTab(szModule)
	local tbModuleStr = {};
		
	-- Lib:SplitStr()不能正确解析转义字符，这里特殊处理自己解析了一遍
	if szModule and szModule ~= "" then
		local nStart = 1;
		local nAt = string.find(szModule, "%.");
		while nAt do
			tbModuleStr[#tbModuleStr+1] = string.sub(szModule, nStart, nAt - 1);
			nStart = nAt + 1;
			nAt = string.find(szModule, "%.", nStart);
		end
		tbModuleStr[#tbModuleStr+1] = string.sub(szModule, nStart);
	
		if not tbModuleStr or tbModuleStr == {} then
			assert(false);
		end
	end
	
	-- 遍历字符串，得到模块的table
	local tbModule = _G;
	for _, szSubTable in pairs(tbModuleStr) do
		tbModule = tbModule[szSubTable];
		if not tbModule or tbModule == {} then
			assert(false);
		end
	end
	
	return tbModule;
end

tbModuleSwitch:LoadConfig();
if MODULE_GAMESERVER then
	ServerEvent:RegisterServerStartFunc(tbModuleSwitch.OnServerStart, tbModuleSwitch);
end