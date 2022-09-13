
/*
---------------------------------
˵�� : �������ʺ����ͳ�Ʊ�
���� : tb_jxex_stat_account
----------------------------------
*/
CREATE TABLE IF NOT EXISTS tb_jxex_stat_account
(
  ID                  int(11)                             not null        auto_increment,          -- ID,����
  tStatDate           date                                not null,                                -- ����
  nTotalAccount       int(11)                             not null,                                -- �ʺ�����
  nActiveAccount      int(11)                             not null,                                -- ��ǰ��Ծ�ʺ���
  nLostAccount        int(11)                             not null,                                -- ������ʧ�ʺ���
  primary key(ID),
  unique(tStatDate)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;		


/*
---------------------------------
˵�� : ��������ɫ���ͳ�Ʊ�
���� : tb_jxex_stat_role
----------------------------------
*/
CREATE TABLE IF NOT EXISTS tb_jxex_stat_role
(
  ID                  int(11)                             not null        auto_increment,          -- ID,����
  tStatDate           date                                not null,                                -- ����
  nTotalRole          int(11)                             not null,                                -- ��ɫ����
  nActiveRole         int(11)                             not null,                                -- ��ǰ��Ծ��ɫ����
  nRole1              int(11)                             not null,                                -- 1��ɫ�ʺ�����
  nRole2              int(11)                             not null,                                -- 2��ɫ�ʺ�����
  nRole3              int(11)                             not null,                                -- 3��ɫ�ʺ�����
  nRole4              int(11)                             not null,                                -- 4��ɫ�ʺ�����
  nRole5              int(11)                             not null,                                -- 5��ɫ�ʺ�����
  nRole6              int(11)                             not null,                                -- 6��ɫ�ʺ�����
  nRole7              int(11)                             not null,                                -- 7��ɫ�ʺ�����
  nRole8              int(11)                             not null,                                -- 8��ɫ�ʺ�����
  nRole9              int(11)                             not null,                                -- 9��ɫ�ʺ�����
  nRole10             int(11)                             not null,                                -- 10��ɫ�ʺ�����
  nRole11             int(11)                             not null,                                -- 11��ɫ�ʺ�����
  nRole12             int(11)                             not null,                                -- 12��ɫ�ʺ�����
  primary key(ID),
  unique(tStatDate)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*
---------------------------------
˵�� : ��ɫ��������ͳ�Ʊ�
���� : tb_jxex_stat_roleinfo
----------------------------------
*/
CREATE TABLE IF NOT EXISTS tb_jxex_stat_roleinfo
(
  ID                  int(11)                             not null        auto_increment,          -- ID,����
  tStatDate           date                                not null,                                -- ����
  sField              varchar(200)                        not null,                                -- ����
  sValue              varchar(200)                        not null,                                -- ��ֵ
  nTotal              int(11)                             not null,                                -- ����
  primary key(ID),
  index(tStatDate)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;		


/*
---------------------------------
˵�� : ������ͳ�Ʊ�
���� : tb_jxex_stat_gamemoney
----------------------------------
*/
CREATE TABLE IF NOT EXISTS tb_jxex_stat_gamemoney
(
  ID                  int(11)                             not null        auto_increment,          -- ID,����
  tStatDate           date                                not null,                                -- ����
  sName               varchar(200)                        not null,                                -- ;��
  sType               varchar(200)                        not null,                                -- ����
  nValue              int(11)                             not null,                                -- ��ֵ
  primary key(ID),
  index(tStatDate)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;
	

/*
---------------------------------
˵�� : �����ͳ�Ʊ�
���� : tb_jxex_stat_ibshop
----------------------------------
*/
CREATE TABLE IF NOT EXISTS tb_jxex_stat_ibshop
(
  ID                  int(11)                             not null        auto_increment,          -- ID,����
  tStatDate           date                                not null,                                -- ����
  sItem_Name          varchar(200)                        not null,                                -- ������
  nItem_Type          int(11)                             not null,                                -- ��������
  nJB_Amount          int(11)                             not null,                                -- �����������
  nBindJB_Amount      int(11)                             not null,                                -- �󶨽����������
  nPrice              int(11)                             not null,                                -- ��ҵ���
  nBindPrice          int(11)                             not null,                                -- �󶨽�ҵ���
  primary key(ID),
  index(tStatDate)	
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

		
/*
---------------------------------
˵�� : �������ͱ�
���� : tb_jxex_stat_itemtype
----------------------------------
*/
CREATE TABLE IF NOT EXISTS tb_jxex_stat_itemtype
(
  nTypeID             int(11)                             not null,                                -- ����ID,����
  sTypeName           varchar(200)                        not null,                                -- ������
  sRemark             varchar(200)                            null,                                -- ����
  primary key(nTypeID)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

		
/*
---------------------------------
˵�� : ������Ϣ��
���� : tb_jxex_stat_err
----------------------------------
*/
CREATE TABLE IF NOT EXISTS tb_jxex_stat_err
(
  Error            varchar(200)                           not null,        -- ����
  Time_Stamp       timestamp             default now()    not null         -- ����
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*����������Ӫ����ͳ��
ͳ�Ʒ������ʺ����
ͳ�Ʒ�������ɫ���
ͳ�ƽ�ɫ��������
ͳ�ƽ�����
ͳ�������
*/
DROP PROCEDURE IF EXISTS proc_jxex_stat;
CREATE PROCEDURE proc_jxex_stat()
main:BEGIN
 declare v_Table_Role varchar(200);
 declare v_Table_GameMoney varchar(200);
 declare v_Table_IBShop varchar(200);
 declare v_Table_ibitem varchar(200);
 declare v_postfix varchar(200);
 
 declare v_Field_Role varchar(200);
 declare v_Field_Account varchar(200);
 declare v_Field_Grade varchar(200);
 declare v_Field_Mana varchar(200);
 declare v_Field_LastLogin varchar(200);
 declare v_Field_GameTime varchar(200);
 declare v_Field_TrustTime varchar(200);
 declare v_Field_GameMoney varchar(200);
 declare v_Field_EquipValue varchar(200);
 declare v_Field_Friends varchar(200);
 declare v_Field_MakeSkill varchar(200);
 
 declare v_Field_MoneyType varchar(200);
 declare v_Field_Value varchar(200);
 
 declare v_Field_ItemName varchar(200);
 declare v_Field_JBAmount varchar(200);
 declare v_Field_BindJBAmount varchar(200);
 
 declare v_Field_Item varchar(200);
 declare v_Field_Price varchar(200);
 declare v_Field_BindPrice varchar(200);
 declare v_Field_ItemTyp varchar(200);
 
 declare v_TotalAccount int;
 declare v_ActiveAccount int;
 declare v_LostAccount int;
 declare v_TotalRole int;
 declare v_ActiveRole int;
 declare v_Mana int;
 
 declare v_Role1 int;
 declare v_Role2 int;
 declare v_Role3 int;
 declare v_Role4 int;
 declare v_Role5 int;
 declare v_Role6 int;
 declare v_Role7 int;
 declare v_Role8 int;
 declare v_Role9 int;
 declare v_Role10 int;
 declare v_Role11 int;
 declare v_Role12 int;
 
 declare v_Field varchar(50);
 declare v_Value varchar(50);
 declare v_Total int;
 
 declare v_Max int;
 declare v_Min int;
 declare v_num int;
 declare v_varchar varchar(200);
 declare v_Date date;
 declare v_TimeStamp datetime;
 declare v_BaseMana int;
 declare v_ActiveDate int;
 declare v_DatabaseName varchar(200);
 declare v_errmsg varchar(200);
 
 START TRANSACTION;
 
 set v_BaseMana = 10;
 set v_ActiveDate = 3;
 set v_Date = SUBDATE(CURRENT_DATE(),1);
 set v_DatabaseName = database();
  
 set v_postfix = v_Date + 0;
 set v_Table_Role = CONCAT('roleinfo_' , v_postfix);
 set v_Table_GameMoney = CONCAT('jxb_' , v_postfix);
 set v_Table_IBShop = CONCAT('ibshop_' , v_postfix);
 set v_Table_ibitem = CONCAT('ibitem_' , v_postfix);
 
 -- RoleInfo 
 select sequenumber into v_Field_Role from tblfieldname where tablename = 'RoleInfo' and fieldname = '��ɫ��';
 set v_Field_Role = concat('F',v_Field_Role);

 select sequenumber into v_Field_Account from tblfieldname where tablename = 'RoleInfo' and fieldname = '�ʺ���';
 set v_Field_Account = concat('F',v_Field_Account); 

 select sequenumber into v_Field_Grade from tblfieldname where tablename = 'RoleInfo' and fieldname = '�ȼ�';
 set v_Field_Grade = concat('F',v_Field_Grade); 

 select sequenumber into v_Field_Mana from tblfieldname where tablename = 'RoleInfo' and fieldname = '��������';
 set v_Field_Mana = concat('F',v_Field_Mana);

 select sequenumber into v_Field_LastLogin from tblfieldname where tablename = 'RoleInfo' and fieldname = '�ϴε�¼ʱ��';
 set v_Field_LastLogin = concat('F',v_Field_LastLogin);

 select sequenumber into v_Field_GameTime from tblfieldname where tablename = 'RoleInfo' and fieldname = '������ʱ��';
 set v_Field_GameTime = concat('F',v_Field_GameTime);

 select sequenumber into v_Field_TrustTime from tblfieldname where tablename = 'RoleInfo' and fieldname = '���й�ʱ��';
 set v_Field_TrustTime = concat('F',v_Field_TrustTime);  

 select sequenumber into v_Field_GameMoney from tblfieldname where tablename = 'RoleInfo' and fieldname = '��������';
 set v_Field_GameMoney = concat('F',v_Field_GameMoney);

 select sequenumber into v_Field_EquipValue from tblfieldname where tablename = 'RoleInfo' and fieldname = 'װ����ֵ';
 set v_Field_EquipValue = concat('F',v_Field_EquipValue);
     
 select sequenumber into v_Field_Friends from tblfieldname where tablename = 'RoleInfo' and fieldname = '������';
 set v_Field_Friends = concat('F',v_Field_Friends);
     
 select sequenumber into v_Field_MakeSkill from tblfieldname where tablename = 'RoleInfo' and fieldname = '�������ܵȼ�';
 set v_Field_MakeSkill = concat('F',v_Field_MakeSkill);
   
 -- JXB      
 select sequenumber into v_Field_MoneyType from tblfieldname where tablename = 'JXB' and fieldname = ';��';
 set v_Field_MoneyType = concat('F',v_Field_MoneyType);
     
 select sequenumber into v_Field_Value from tblfieldname where tablename = 'JXB' and fieldname = '����';
 set v_Field_Value = concat('F',v_Field_Value);
 
 -- IBShop     
 select sequenumber into v_Field_ItemName from tblfieldname where tablename = 'IBShop' and fieldname = '��������';
 set v_Field_ItemName = concat('F',v_Field_ItemName);
     
 select sequenumber into v_Field_JBAmount from tblfieldname where tablename = 'IBShop' and fieldname = '�����������';
 set v_Field_JBAmount = concat('F',v_Field_JBAmount);
    
 select sequenumber into v_Field_BindJBAmount from tblfieldname where tablename = 'IBShop' and fieldname = '�󶨽����������';
 set v_Field_BindJBAmount = concat('F',v_Field_BindJBAmount);
  
 -- ibitem  
 select sequenumber into v_Field_Item from tblfieldname where tablename = 'ibitem' and fieldname = '��������';
 set v_Field_Item = concat('F',v_Field_Item);
  
 select sequenumber into v_Field_Price from tblfieldname where tablename = 'ibitem' and fieldname = '��ҵ���';
 set v_Field_Price = concat('F',v_Field_Price); 
 
 select sequenumber into v_Field_BindPrice from tblfieldname where tablename = 'ibitem' and fieldname = '�󶨽�ҵ���';
 set v_Field_BindPrice = concat('F',v_Field_BindPrice); 
 
 select sequenumber into v_Field_ItemTyp from tblfieldname where tablename = 'ibitem' and fieldname = '���';
 set v_Field_ItemTyp = concat('F',v_Field_ItemTyp);

 t_account:begin
 set @v_table_exist = 0;
 set @v_SQL = concat('select 1 into @v_table_exist from information_schema.tables where table_name = "',v_Table_Role,'" and table_schema = "',v_DatabaseName,'"');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;  
 if (@v_table_exist <> 1) then
   set v_errmsg = concat(v_Table_Role,' is not exists');
   
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_account;
 end if;
 
 set @v_record_exist = 0;
 set @v_SQL = concat('select 1 into @v_record_exist from tb_jxex_stat_account where tStatDate = "',v_Date,'" limit 1');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;  
 if (@v_record_exist = 1) then
   leave t_account;
 end if;
 
 if (v_Field_Account is null or v_Field_LastLogin is null) then 
   set v_errmsg = 'Field is not exist: roleinfo�ʺ��� or roleinfo�ϴε�¼ʱ��';
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_account;
 end if;

 set @v_count = 0;
 set @v_SQL = concat('select count(distinct ',v_Field_Account,') into @v_count from ',v_Table_Role);
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;   
 select @v_count into v_TotalAccount;
   
 set v_ActiveDate = v_ActiveDate - 1;
 set @v_count = 0;
 set @v_SQL = concat('select count(distinct ',v_Field_Account,') into @v_count from ',v_Table_Role,' where (',v_Field_LastLogin,' is not null and ',v_Field_LastLogin,'>SUBDATE(STR_TO_DATE("',v_Date,'","%Y-%m-%d"),',v_ActiveDate,'))');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;
 select @v_count into v_ActiveAccount;
     
 set v_LostAccount = v_TotalAccount - v_ActiveAccount;
 
 insert into tb_jxex_stat_account(ID,tStatDate,nTotalAccount,nActiveAccount,nLostAccount)
   values(null,v_Date,v_TotalAccount,v_ActiveAccount,v_LostAccount);
  commit;
 
 end t_account;
 
 t_role:begin
 set @v_table_exist = 0;
 set @v_SQL = concat('select 1 into @v_table_exist from information_schema.tables where table_name = "',v_Table_Role,'" and table_schema = "',v_DatabaseName,'"');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;
 if (@v_table_exist <> 1) then
   set v_errmsg = concat(v_Table_Role,' is not exists');
   
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit; 
   leave t_role;
 end if;
 
 set @v_record_exist = 0;
 set @v_SQL = concat('select 1 into @v_record_exist from tb_jxex_stat_role where tStatDate = "',v_Date,'" limit 1');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt; 
 if (@v_record_exist = 1) then
   leave t_role;
 end if;
 
 end t_role;

 t_gamemoney:begin
 set @v_table_exist = 0;
 set @v_SQL = concat('select 1 into @v_table_exist from information_schema.tables where table_name = "',v_Table_GameMoney,'" and table_schema = "',v_DatabaseName,'"');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;  
 if (@v_table_exist <> 1) then
   set v_errmsg = concat(v_Table_GameMoney,' is not exists');
   
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_gamemoney;
 end if;
 
 set @v_record_exist = 0;
 set @v_SQL = concat('select 1 into @v_record_exist from tb_jxex_stat_gamemoney where tStatDate = "',v_Date,'" limit 1');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;  
 if (@v_record_exist = 1) then
   leave t_gamemoney;
 end if;
 
 if (v_Field_MoneyType is null or v_Field_Value is null) then 
   set v_errmsg = 'Field is not exist:jxb���� or jxb;��';
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_gamemoney;
 end if;
 
 set @v_SQL = concat('insert into tb_jxex_stat_gamemoney(ID,tStatDate,sName,sType,nValue) select null,STR_TO_DATE("',v_Date,'","%Y-%m-%d"),cast(',v_Field_MoneyType,' as binary),cast((substring_index(substring_index(',v_Field_MoneyType,',"]",1),"[",-1)) as binary),(CASE WHEN ',v_Field_Value,' is null THEN 0 else ',v_Field_Value,' END) nValue from ',v_Table_GameMoney); 
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;   
 commit; 
 end t_gamemoney;
 
 
 t_ibshop:begin
 set @v_table_exist = 0;
 set @v_SQL = concat('select 1 into @v_table_exist from information_schema.tables where table_name = "',v_Table_ibitem,'" and table_schema = "',v_DatabaseName,'"');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;  
 if (@v_table_exist <> 1) then
   set v_errmsg = concat(v_Table_ibitem,' is not exists');   
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_ibshop;
 end if;
 
 set @v_table_exist = 0;
 set @v_SQL = concat('select 1 into @v_table_exist from information_schema.tables where table_name = "',v_Table_IBShop,'" and table_schema = "',v_DatabaseName,'"');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;  
 if (@v_table_exist <> 1) then
   set v_errmsg = concat(v_Table_IBShop,' is not exists');
   
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_ibshop;
 end if;
 
 set @v_record_exist = 0;
 set @v_SQL = concat('select 1 into @v_record_exist from tb_jxex_stat_ibshop where tStatDate = "',v_Date,'" limit 1');
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;  
 if (@v_record_exist = 1) then
   leave t_ibshop;
 end if;
 
 if (v_Field_ItemName is null or v_Field_JBAmount is null or v_Field_BindJBAmount is null) then
   set v_errmsg = 'Field is not exists:ibshop�������� or ibshop����������� or ibshop�󶨽����������';
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_ibshop;
 end if;
 
 if (v_Field_Item is null or v_Field_Price is null or v_Field_BindPrice is null or v_Field_ItemTyp is null) then
   set v_errmsg = 'Field is not exists:ibitem�������� or ibitem��ҵ��� or ibitem�󶨽�ҵ��� or ibitem���';
   insert into tb_jxex_stat_err(error) values(v_errmsg);
   commit;
   leave t_ibshop;
 end if;
  
 set @v_SQL = concat('insert into tb_jxex_stat_ibshop(ID,tStatDate,sItem_Name,nItem_Type,nJB_Amount,nBindJB_Amount,nPrice,nBindPrice) select null,STR_TO_DATE("',v_Date,'","%Y-%m-%d"),cast(i.',v_Field_Item,' as binary),(CASE WHEN i.',v_Field_ItemTyp,' is null THEN 0 else i.',v_Field_ItemTyp,' END) nItem_Type,(CASE WHEN s.',v_Field_JBAmount,' is null THEN 0 else s.',v_Field_JBAmount,' END) nJB_Amount,(CASE WHEN s.',v_Field_BindJBAmount,' is null THEN 0 else s.',v_Field_BindJBAmount,' END) nBindJB_Amount,(CASE WHEN i.',v_Field_Price,' is null THEN 0 else i.',v_Field_Price,' END) nPrice,(CASE WHEN i.',v_Field_BindPrice,' is null THEN 0 else i.',v_Field_BindPrice,' END) nBindPrice from ',v_Table_ibitem,' i left outer join ',v_Table_IBShop,' s on i.',v_Field_Item,'=s.',v_Field_ItemName); 
 PREPARE stmt from @v_SQL;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;
 end t_ibshop;
end main;