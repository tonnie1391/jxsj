
--	ÃÅÅÉ½ÓÒýÈË	
local tbMenPaiJieYinRen = Npc:GetClass("menpaijieyinren");
local tbNpcTemplate2Faction = 
{
	[3507] = Env.FACTION_ID_SHAOLIN, 
	[3501] = Env.FACTION_ID_TIANWANG, 
	[3513] = Env.FACTION_ID_TANGMEN,
	[3519] = Env.FACTION_ID_WUDU, 
	[3525] = Env.FACTION_ID_EMEI, 
	[3531] = Env.FACTION_ID_CUIYAN,
	[3537] = Env.FACTION_ID_GAIBANG, 
	[3543] = Env.FACTION_ID_TIANREN, 
	[3549] = Env.FACTION_ID_WUDANG, 
	[3555] = Env.FACTION_ID_KUNLUN, 
	[3474] = Env.FACTION_ID_MINGJIAO, 
	[3480] = Env.FACTION_ID_DALIDUANSHI,
	[11015] = Env.FACTION_ID_GUMU,
}
function tbMenPaiJieYinRen:OnDialog()
	Npc.tbMenPaiNpc:DialogJieYinRen(tbNpcTemplate2Faction[him.nTemplateId])
end
