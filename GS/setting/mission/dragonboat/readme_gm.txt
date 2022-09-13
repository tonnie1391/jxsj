?pl me.AddItem(18,1,326,1) --获得粽子1
?pl me.AddItem(18,1,326,2) --获得粽子2
?pl me.AddItem(18,1,326,3) --获得粽子3
?pl me.AddItem(18,1,326,4) --获得粽子4
?pl me.AddItem(18,1,327,1) --获得龙舟1
?pl me.AddItem(18,1,327,2) --获得龙舟2
?pl me.AddItem(18,1,327,3) --获得龙舟3
?pl me.AddItem(18,1,327,4) --获得龙舟4
?pl me.AddItem(22,1,63,1)  --获得云杉木
?pl me.AddItem(22,1,64,1)  --获得云杉木板
?pl me.AddItem(22,1,65,1)  --获得粗铁块
?pl me.AddItem(22,1,66,1)  --获得粗铁钉
?pl me.AddItem(22,1,67,1)  --获得粗桐油
?pl me.AddItem(22,1,68,1)  --获得上品桐油

?pl me.SetTask(2064, 15, 10) --设置次数
?pl me.SetTask(2064, 16, 10) --设置额外次数
?pl me.SetTask(2064, 17, 0) --每天换取额外次数，记录次数
?pl me.SetTask(2064, 18, 0) --每天换取额外次数，记录时间

?gc Esport:ScheduletaskDragonBoat()	--开启报名

--设置最少多少人才能开启
?gc Console:GetBase(Console.DEF_DRAGON_BOAT).tbCfg.nMinDynPlayer=1;
GlobalExcute{\"GM:DoCommand\",[[Console:GetBase(Console.DEF_DRAGON_BOAT).tbCfg.nMinDynPlayer=1]]}

--设置报名时间；
?gc Console:GetBase(Console.DEF_DRAGON_BOAT).tbCfg.nReadyTime=18*30;
GlobalExcute{\"GM:DoCommand\",[[Console:GetBase(Console.DEF_DRAGON_BOAT).tbCfg.nReadyTime=18*30]]}
