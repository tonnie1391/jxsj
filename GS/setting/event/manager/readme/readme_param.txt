剑世活动系统整理出来的参数和说明
 
参数类型:
d       --整型
dTsk    --任务变量(整型)
s       --字符串

--触发事件
Npc:d		--例子:Npc:2601  (和礼官对话2601为礼官Id   )
Item:s,s,n,n	--例子:Item:lingpai,1440,10,1 (物品lingpai触发,使用和生成物品,lingpai为物品classname,1440为物品有效期,10为使用物品启动进度条时间,1为成功使用物品后是否删除物品)
DropNpc:d	--例子:DropNpc:1000 (Id为1000的npc死亡时触发)
DropNpcType:s	--例子:DropNpcType:merchant (merchant为npc的classname,某类npc死亡时触发)(特殊类型：_JINGYING:精英，_SHOULING:首领，_ALLNPC:所有npc)
TimerStart:d	--例子:TimerStart:1015 10点15分触发事件开始(添-1为服务器启动马上触发)
TimerEnd:d	--例子:TimerEnd:1015 10点15分触发事件结束

没有触发事件,默认为服务器启动马上触发


--条件
CheckTask:dTsk,d,s		--例子:CheckTask:51,5,"最多5次" (51号任务变量大于等于5则返回提示信息)
CheckTaskEq:dTsk,d,s		--例子:CheckTask:51,1,"已参加过" (51号任务变量等于1则返回提示信息)
CheckTaskDay:d,dTsk,dTsk,s	--例子:CheckTaskDay:5,51,52,"每天只能5次" (51记录今天次数,52变量记录今天,51变量大于>=5则返还提示信息)
CheckLevel:d,s			--例子:CheckLevel:60,"要达到60级才行" (等级未达到60则返回提示信息)
CheckFaction:d,s		--例子:CheckFaction:1,"必须是天王才能参加" (门派Id为1为天王,检查玩家是否是天王,如果不是则返回提示信息)
CheckCamp:d,s			--例子:CheckCamp:1,"必须是正派" (同上)
CheckSex:d,s			--例子:CheckSex:0,"必须是男性玩家" (0为男,1为女,不满足要求则返回提示)
CheckMonthPay:d,s		--例子:CheckMonthPay:100,"本月累计充值必须达100元" (判断累计充值是否达到条件)
CheckWeiWang:d,s		--例子:CheckWeiWang:100,"江湖威望必须达100点" (判断江湖威望是否达到条件)
CheckFreeBag:d,s		--例子:CheckFreeBag:2,"必须需要2格背包空间" (判断背包空间是否达到条件)
CheckExt:d,s			--例子:CheckExt:1,"你已经被激活过了" (检查每个累计充值扩展点高四位是否等于某值,等于返回失败,表明已激活)
CheckWeek:d,s			--例子:CheckWeek:1,"现在不是周1,不能参加活动" (必须满足周几才能参加活动, 周表示:0-6)
CheckItemInBag:d,d,d,d,d,d,s	--例子:CheckItemInBag:18,1,1,1,2,0,"你身上没有2个1玄。" 或 CheckItemInBag:18,1,1,1,2,1,"你身上已经有2个1玄。"
CheckItemInAll:d,d,d,d,d,d,s	--例子:CheckItemInAll:18,1,1,1,2,0,"你身上或仓库没有2个1玄。" 或 CheckItemInAll:18,1,1,1,2,1,"你身上或仓库已经有2个1玄。"
CheckInMapType:s,d,s		--例子:CheckInMapType:"fight",0,"必须在野外地图" 或 CheckInMapType:"fight",1,"必须不在野外地图"
CheckInMapLevel:d,d,s		--例子:CheckInMapLevel:50,0,"必须在50级及50级以上地图" 或 CheckInMapLevel:50,1,"必须在50级地图" 或 CheckInMapLevel:50,2,"必须在50级以下的地图"
CheckNpcAtNear:d,d,s		--例子:CheckNpcAtNear:1000,1,"ID为1000的属于我的npc不在我附近" 或 CheckNpcAtNear:1000,0,"ID为1000的npc不在我附近"
CheckDialogNpcAtNear:s		--例子:CheckDialogNpcAtNear:"我的附近有对话npc在"


--执行
SetTask:dTsk,d			--例子:SetTask:51,2 (51号任务变量设置成2)
SetMsg:s			--例子:SetMsg:s (设置执行完成后显示对话界面(Dialog))
SetAwardId:d			--例子:SetAwardId:1	(执行奖励表中的第1项内容)
SetAwardIdUi:d			--例子:SetAwardIdUi:2	(给予界面执行奖励表中的第2项内容)
SetCallNpcId:d			--例子:SetCallNpcId:1	(执行召唤npc表中的第一项内容)
SetDropItemId:d,d		--例子:SetDropItemId:1,10	(怪物死亡时,执行掉落表中的第一项内容,掉落执行次数10次)
SetDroprate:s,d			--例子:SetDroprate:"\setting\npc\droprate\droprate_10.txt",5	(怪物死亡时,执行\setting\npc\droprate\droprate_10.txt掉落表,执行次数5次)
AddTask:dTsk,d			--例子:AddTask:51,2 (51号任务变量值加2)
AddTaskDay:dTsk,dTsk		--例子:AddTaskDay:51,52 (执行每天能参加的次数赠1,51号任务变量赠1,52号变量记录天)
AddItem:d,d,d,d,d,d,d		--例子:AddItem:18,1,1,9,2,1,1440 (获得物品,18,1,1,9为9玄Id, 2为2个,1为绑定,1440为获得有效期1440分钟)
AddTitle:d,d,d,d		--例子:AddTitle:3,2,1,0 (获得称号,4个参数为称号Id值)
AddSkillBuff:d,d,d		--例子:AddSkillBuff:892,1,1440 (获得状态,892为状态技能Id, 1为等级, 1440为有效期,单位分钟)
AddExt:d			--例子AddExt:1	(每个累计充值扩展点高四位得值赠加1)

SetLayer1Msg:s			--例子:SetLayer1Msg:"想了解什么？"(多层对话，第一层描述)
SetLayer2Msg:s,s		--例子:SetLayer2Msg:"关于活动","活动是指...."(多层对话，第二层选项和描述);