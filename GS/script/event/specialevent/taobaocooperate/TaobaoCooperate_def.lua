-- 文件名  : TaobaoCooperate.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-09-03 15:08:15
-- 描述    : 淘宝合作活动

SpecialEvent.tbTaobaoCooperate = SpecialEvent.tbTaobaoCooperate or {};
local tbTaobaoCooperate = SpecialEvent.tbTaobaoCooperate;

tbTaobaoCooperate.TASK_GID 		= 2139;	--任务组
tbTaobaoCooperate.TASK_TASKID_GETBOX	= 1;	--获得淘礼盒的数量
tbTaobaoCooperate.TASK_TASKID_USEBOX	= 2;	--使用的数量
tbTaobaoCooperate.TASK_TASKID_GETAWARD = {3, 4, 5, 6, 7}	--是否获得淘礼包、淘宝红包礼金100,50,10,5

tbTaobaoCooperate.nOpenTime = 20101010		--开始时间
tbTaobaoCooperate.nCloseTime = 20101120		--结束时间
tbTaobaoCooperate.nNpc = 0;					--npcAdd标志
tbTaobaoCooperate.nTaoBaoDaShi	= 6724;		--淘宝大使模板id
tbTaobaoCooperate.tbTaoBaoPoint	= {{25,1675,3219}, {23,1569,3097}, {24,1788,3531}, {27,1618,3218}, {28,1540,3288}, {26,1584,3192}, {29,1628,3940}};	--淘宝大使出生坐标
tbTaobaoCooperate.nMaxTaoBox = 2500;		--服务器最大产出淘礼包数量
tbTaobaoCooperate.nMaxUse	= 30;			--每个角色最多使用多少个礼盒
tbTaobaoCooperate.tbTaskInfo = {1, 2, 3, 4, 5};	--任务变量3,4,5,6,7对应的物品
tbTaobaoCooperate.tbItemInfo = {[1] = {10,1,1, {18,1,709,1,nil,1}},[2] = {50,2, 2},[3] = {100,3, 2}, [4] = {500,4, 2}, [5] = {2000,6,2},[6] = {2000,5, 2}, [7] = {4340, 7, 2}, [8] = {500,8,3,20000}, [9] = {500,9,1,{18,1,80,1,nil,2}}};
--随机物品的种类1，表示物品，2表示代金券红包，3表示绑银
--[1] = 488,[2] = 100红包,[3] = 50红包,[4] = 10红包,[5] = 5红包,[6] = 20代金券,[7] = 5代金券,[8] = 20000绑银,[9] = 2福袋
tbTaobaoCooperate.tbNameAward	= {
	"一等奖淘·礼包", 
	"二等奖价值100元的【淘宝红包】",
	"二等奖价值50元【淘宝红包】",
	"二等奖价值10元【淘宝红包】", 	
	"二等奖价值100元【淘宝代金券】",
	"三等奖价值5元【淘宝红包】",
	"三等奖价值20元【淘宝代金券】",
	"幸运奖20000绑定银两",
	"幸运奖2个福袋"
	}

--数据
tbTaobaoCooperate.tbTaoBaoInfo = {};		--数据
