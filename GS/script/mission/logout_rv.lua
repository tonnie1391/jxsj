--离线和服务器宕机状态恢复;玩家登陆时执行(跨服登陆也会执行)
--sunduoliang
--2009.1.9
--设置接口：me.SetLogoutRV(nType);
--还原接口：me.SetLogoutRV(0);

--各系统定义
Mission.LOGOUTRV_DEF_MISSION_ESPORT		= 1;	--雪仗竞技赛
Mission.LOGOUTRV_DEF_MISSION_DRAGONBOAT	= 2;	--赛龙舟竞技
Mission.LOGOUTRV_DEF_LOOKER				= 3;	--观战模式
Mission.LOGOUTRV_DEF_XOYO				= 4;    --逍遥谷
Mission.LOGOUTRV_DEF_MISSION_TOWER		= 5;	--植物大战僵尸
Mission.LOGOUTRV_DEF_MISSION_CASTLEFIGHT = 6;
Mission.LOGOUTRV_DEF_MISSION_SONGJIN 	= 7;

--各系统恢复函数定义
Mission.tbLogOutRVFun = {
	[Mission.LOGOUTRV_DEF_MISSION_ESPORT] 		= "Esport:LogOutRV",
	[Mission.LOGOUTRV_DEF_MISSION_DRAGONBOAT]	= "Esport.DragonBoat:LogOutRV",
	[Mission.LOGOUTRV_DEF_LOOKER]				= "Looker:LogOutRV",
	[Mission.LOGOUTRV_DEF_XOYO]					= "XoyoGame.BaseGame:LogOutRV",
	[Mission.LOGOUTRV_DEF_MISSION_TOWER]		= "TowerDefence:LogOutRV",
	[Mission.LOGOUTRV_DEF_MISSION_CASTLEFIGHT]	= "CastleFight:LogOutRV",
	[Mission.LOGOUTRV_DEF_MISSION_SONGJIN]		= "Battle:LogOutRV",
}

function Mission:LogOutRV()
	if me.GetLogOutState() > 0 then
		local szFun = self.tbLogOutRVFun[me.GetLogOutState()];
		if szFun then
			Lib:CallBack({szFun});
		end
	end
	me.SetLogOutState(0);
end

