local tbItem = Item:GetClass("kingame_qiandai")

function tbItem:GetTip()
	local nCount = me.GetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_BAG_ID);
	local szTip = "";
	szTip = szTip..string.format("<color=0x8080ff>×°¹ÅÇ®±ÒµÄÇ®´ü<color>\n");
	szTip = szTip..string.format("<color=yellow>¹ÅÇ®±Ò×°ÔØÁ¿: %d/1000<color>", nCount);
	return szTip;
end
