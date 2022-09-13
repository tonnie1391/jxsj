--File: log_ui.lua
--Author: sunduoliang
--Date: 2008-3-23 15:31:26
--Describe: Ui统计Log
-------------------------------------------------------------------
Log.Ui_TbSaveTempInit = {};
Log.Ui_Open = 0;
--记录Log Ui注释
Log.Ui_TbSaveTempInit = 
{
	--["角色等级"] = {},
	--["F1主角界面"] = {},
	--["F2物品界面"] = {},
	--["F3技能界面"] = {},
	--["F4任务界面"] = {},
	--["F5人际界面"] = {},
	--["F6家族界面"] = {},
	--["P组队界面"] = {},
	--["F8生活技能界面"] = {},
	--["F11系统设置界面"] = {},
	--["F12帮助系统界面"] = {},
	--["打开奇珍阁"] = {},
	--["打开大地图"] = {},
	--["切换小地图大小"] = {},
	--["V打坐"] = {},
	--["切换聊天频道"] = {},
	--["Ctrl+鼠标右键"] = {},
	--["交易"] = {},
	--["添加好友"] = {},
	--["组队"] = {},
	--["密聊"] = {},
	--["查看邮件"] = {},
	--["鼠标左右键技能更改"] = {},	
	--["快捷键更改"] = {},
	--["自动寻路"] = {},
	--["自动打怪"] = {},
	--["PK状态切换"] = {},
	--["在2级前是否点击白秋林"] = {},
	--["是否使用过车夫"] = {},
	--["是否使用过储物箱"] = {},
	--["是否改变过存点"] = {},	 
	--["是否使用过回城卷"] = {},	
	["点击帮助锦囊首页"] = {},
	["点击活动推荐页"] = {},
	["点击详细帮助页"] = {},
	["点击搜索按钮"] = {},
	["点击剑侠知道页"] = {},
	[string.format("点击%s区新品上市",IVER_g_szCoinName)] = {},
	[string.format("点击%s区推荐商品", IVER_g_szCoinName)] = {},
	["点击银两页"] = {},
	["点击绑金区新品上市"] = {},
	["点击绑金区推荐商品"] = {},
	["点击交易所"] = {},
	["点击邮箱"] = {},
	["使用修炼珠"] = {},
};

--client 接口
function Log:Ui_SendLog(szField, nValue)
	-- do return end; -- 关闭
	if self.Ui_Open ~= 1 then
		return 0;
	end
	if self.Ui_TbSaveTempInit[szField] == nil then
		return;
	end
	
	if self.Ui_TbSaveTempInit[szField][me.nId] == nil then
		me.CallServerScript({ "NewPlayerUiCmd", szField, nValue});
		self.Ui_TbSaveTempInit[szField][me.nId] = 1;
	end
end

--server 接口
function Log:Ui_LogSetValue(szField, nValue)
	-- do return end; -- 关闭
	-- 不合法的指令不予通过
	if self.Ui_TbSaveTempInit[szField] == nil then
		--print("指令不通过");
		return;
	end	
	
	if self.Ui_TbSaveTempInit[szField][me.nId] == nil then
		self.Ui_TbSaveTempInit[szField][me.nId] = 1;
		-- print(szKey, szField, nValue)
		KStatLog.ModifyField("ui", me.szName, szField, nValue)
		-- KStatLog.ModifyField("ui", szField, "点击数据统计", nValue)
	end
end
