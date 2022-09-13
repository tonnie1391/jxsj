-- 文件名　：roletransfer_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-07-21 09:40:35
-- 功能    ：

SpecialEvent.tbRoleTransfer = SpecialEvent.tbRoleTransfer or {};
local tbRoleTransfer = SpecialEvent.tbRoleTransfer;

tbRoleTransfer.bOpen = 1;		--系统开关

tbRoleTransfer.TASK_GROUP_ID 			= 2175;	-- 任务变量组
tbRoleTransfer.TASK_OBJ_ACCOUNT		= 2;		-- 转入的账号（2-9）

tbRoleTransfer.nMinLevel 	= 90;				--角色必须超过90级才能转移
tbRoleTransfer.nMinHonor 	= 5000;				--角色财富荣誉大于5000才能转移
tbRoleTransfer.tbApplyItem 	= {18, 1, 1364, 1};		--角色转移资格证
tbRoleTransfer.nWairListId 	= 462;				--角色转移资格证奇珍阁Id
tbRoleTransfer.nWairListIdEx 	= 463;				--神仙绳奇珍阁Id
tbRoleTransfer.nCancelApplyCoin 	= 15000;			--角色转移资格证兑换的绑金

tbRoleTransfer.nFrendLevel 		= 3;				--3级得好友发邮件
tbRoleTransfer.nDayApplyInGame 	= 3 * 24 * 3600;	--游戏内5天申请时间
tbRoleTransfer.nDayApplyInNet 	= 7 * 24 * 3600;	--网页7天申请时间
tbRoleTransfer.nDayOthenAccept 	= 17 * 24 * 3600;	--15天乙方接收期
tbRoleTransfer.nMaxTransferDay 	= 22 * 24 * 3600;	--申请转移最慢时间20天（20天过期的角色上线自动设回扩展点，删除buff）

tbRoleTransfer.tbMapInfo	= {2090, 1607, 3184};	--转移成功角色关到指定地图

tbRoleTransfer.tbMailMsg = {
	"您的好友<color=yellow>%s<color>已经申请了角色转移，请周知。剑侠世界特此提醒。",
	"您的好友<color=yellow>%s<color>已经成功进行角色转移，现在为转移后的新玩家登录，请周知。剑侠世界特此提醒。",
	};


tbRoleTransfer.tbInfo = {
	"您想知道更多关于角色转移的信息吗？",
	[[
	<color=green>转移条件：<color>
	
		1、角色财富超过5000
		2、角色等级超过90级
		3、账号解锁状态
		4、携带角色转移资格证(15000金币)
	]],
	[[
	<color=green>转移流程：<color>
	
		1、转出方作为队长邀请接收方账号下任一角色组队，然后在此处进行申请，若符合条件，则进入游戏审核期（3天）；
		2、3天后开通网页申请，转出方在指定网页填写相关资料（7天），资料填写完毕后对转出方账号冻结；
		3、转出方填写资料完毕后接收方可以进行资料填写（7天），资料填写完毕后接收方账号冻结；
		4、通过官方审核后（5个工作日），即可进行角色转移，双方角色解冻；
		5、转出角色将被传入灵山顶，需要在山顶老人处购买神仙绳（15000金币）才能进入游戏。
	]],
	[[
	<color=green>注意事项：<color>
	
		1、同一账号同时只能有一个角色转移或者接收转移；
		2、申请失败后（包括审核不通过，转出、接收方没填写资料），只能在申请达22天后才能再次申请角色转移；
		3、若接收方7天未进行资料填，转移方账号将自动解冻；
		4、取消申请需要上交角色转移资格证，角色转移证被扣除的同时将会返还15000绑定金币； 
		5、角色转移资格证不能用于进行卖出，交易，拍卖，摆摊，邮寄，丢弃等行为；
		6、转移成功后，转出角色原所在账号需在申请达22天后才能再次申请角色转移；
		7、申请失败的道具可再次申请；
		8、角色金币将不会被转移。
	]]
}

--数据存储
tbRoleTransfer.tbTransferDate = tbRoleTransfer.tbTransferDate or {};
--转移角色信息{转移角色账号， 转移角色名字，转入角色账号，转入角色申请名字，转移角色时间GetTime()，状态(0撤销1申请2成功)}
tbRoleTransfer.tbTransferFinish = tbRoleTransfer.tbTransferFinish or {};
--转移成功的角色信息{转移角色名字，转入角色账号， 转移角色gateway}
