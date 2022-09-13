--固定预先加载的脚本，会是所有脚本加载的第一个

print("Begin load script files...");

--调试输出辅助函数，输出一些只用于调试而无关游戏功能的信息
--一般提交时应把所有调试信息删掉，为了防止忘记删除及区别真正要输出的信息而设此函数而不要直接用print
--在此设_DbgOut为空，调试模式时可在某处转向为print
function _DbgOut()
end

--== 载入游戏模块 ==--
local tbData		= KLib.LoadTabFile("\\setting\\scripttable.txt");
local tbModuleBase	= { szModuleName = "__ModuleBase" };
local tbMoudleMT	= { __index	= tbModuleBase };
local tbModelSet	= {};
for nRow = 2, #tbData do
	local szModule	= tbData[nRow][1];
	tbModelSet[szModule]	= 1;
	_G[szModule]	= setmetatable({ szModuleName = szModule }, tbMoudleMT);
end
Env.tbModelSet		= tbModelSet;


--== 模块基类函数定义 ==--
function tbModuleBase:DbgOut(...)
	Dbg:Output(self.szModuleName, unpack(arg));
end
function tbModuleBase:WriteLog(nLevel, ...)
	Dbg:WriteLogEx(nLevel, self.szModuleName, unpack(arg));
end
function tbModuleBase:GetPlayerTempTable(pPlayer)
	return pPlayer.GetTempTable(self.szModuleName)
end


--因Excel表格编辑导致字符串前后带""，把带有""的字符串的""号去掉
local function ClearStrQuote(szParam)
	if szParam == nil then
		szParam = "";
	end
	if string.len(szParam) > 1 then
		local nSit = string.find(szParam, "\"");
		if nSit and nSit == 1 then
			local szFlag = string.sub(szParam, 2, string.len(szParam));
			local szLast = string.sub(szParam, string.len(szParam), string.len(szParam));
			szParam = szFlag;
			if szLast == "\"" then
				szParam = string.sub(szParam, 1, string.len(szParam)-1);
			end
		end
	end
	szParam = string.gsub(szParam, "\"","\\\"");
	return szParam;
end


--== 载入脚本常数 ==--
local tbFileData		= KLib.LoadTabFile("\\setting\\scriptvalue\\filelist.txt");
for nFileRow = 2, #tbFileData do
	local szTableName	= tbFileData[nFileRow][1];
	local tbTable		= _G[szTableName];
	if (not tbTable) then
		tbTable			= {};
		_G[szTableName]	= tbTable;
	end
	local szFilePath	= tbFileData[nFileRow][2];
	local tbValueData	= KLib.LoadTabFile(szFilePath);
	if (not tbValueData) then
		print(string.format("ScriptValue file \"%s\" not found!!!"));
		tbValueData		= {};
	end
	for nValueRow = 2, #tbValueData do
		local szName	= ClearStrQuote(tbValueData[nValueRow][1]);
		local szValue	= ClearStrQuote(tbValueData[nValueRow][2]);
		szValue = tonumber(szValue) or loadstring("return \"".. szValue.."\"")();
		tbTable[szName]	= szValue;
	end
end


if (not GetLocalDate) then	-- 临时解决GC没有对应函数
	GetLocalDate	= os.date;
end

--禁用脚本指令
dofile		= nil;
loadfile	= nil;
io			= nil;
math.random	= nil;
math.randomseed	= nil;
local old_time = os.time;
local old_date = os.date;
local old_assert = assert;

function os.time(arg)
	if arg then
		return old_time(arg);
	else
		print(debug.traceback("os.time参数不能为空，要获取本地时间可使用GetTime()"));
		return GetTime();
	end
end

function os.date(format, time)
	if not time then
		print(debug.traceback("os.date第二个参数不能为空，可使用GetTime()获取本地时间作为第二参数，或者直接使用GetLocalDate()"));
	end
	
	if not format then
		format = "%Y\\%m\\%d  %H:%M:%S";
	end
	
	if not time then
		time = GetTime();
	end
	
	return old_date(format, time);
end

function assert(bool, ...)
	if not bool then
		old_assert(bool, unpack(arg));
	end
	return bool, unpack(arg);
end

--全局变量保护，从此不允许出现新的全局变量
local tbMetaTable	= {
	__newindex	= function (tb, key, value)
		if (key == "it" or key == "him" or key == "me") then
			rawset(_G, key, value);
		else
			error("Attempt create global value :"..tostring(key), 2);
		end;
	end,
};
setmetatable(_G, tbMetaTable);

--== 太常用的需要前置的文件，放在这里一次性Require ==--

-- 全部通用
Require("\\script\\lib\\lib.lua");
Require("\\script\\lib\\dbg.lua");
Require("\\script\\lib\\calc.lua");
Require("\\script\\common\\env.lua");
Require("\\script\\lib\\vfactory.lua");

