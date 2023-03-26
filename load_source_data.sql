/*
** run on na-sqlc02v02\sql2  
***REMEMBER TO CHANGE THE START/END DATES BELOW
The end date should be the 1st of the month following the period of the report sought e.g. It's 2018, you want a report for April, so if today is 10th May, then both start and end date is 1st May.
The start date should be three years before the end date. e.g. set @startdate = 'May 1, 2015' set @enddate = 'May 1, 2018'
Please note that some extracts only have an enddate, this matches up with the monthly extract job
*/
use SingleCustomerView
declare @startdate datetime, @enddate datetime
set @startdate = 'MAR 1, 2016'
set @enddate = 'MAR 1, 2019'


truncate table [02_DGD_TX] 

insert into [02_DGD_TX] 
select convert(date, orderdate) as [order Date], convert(varchar(8), convert(time, orderdate)) as 	 [Order Time]
	,o.OrderID [Order Number]
	,o.OrderTotal [Order Total]
	,o.TransactionNo [Payment Reference]
	,null as [Collection] -- this is not whether it has been collected
	,i.catref[Document Reference]
	,i.IAID
	,i.itemid [Item Number]
		,[Price] [Item Price]
	,[Postagecost] [Item Postage]
	,emaildeliveryaddress 
	from [wb-sqlc01v02].discovery_orders.dbo.tblOrders o 
	join [wb-sqlc01v02].discovery_orders.dbo.tblOrderItems i on i.OrderId = o.OrderId
	where orderdate < @enddate


truncate table [14_IMO_TX] 

insert into [14_IMO_TX] 
  select [order_ref_no]
	  ,case f.[company_id] when null then null else company_name end as company_name
      ,[customer_title]
      ,[customer_first_names]
      ,[customer_family_name]
	  ,[customer_email_address]
	   ,replace(replace(replace(replace(replace(replace([order_summary],char(9), ' '),char(10),' '),char(11),' '),char(12),' '),char(13),' '),char(124),' ') as order_summary
	  ,[net_amount] + [vat_amount] as price
	  ,[status_changed_date] as date_order_last_updated
    FROM [wb-sqlc01v02].[image_library].[dbo].[tbl_fee_request] f
	left join [wb-sqlc01v02].[image_library].[dbo].[tbl_company] c on f.company_id = c.company_id
	where status_changed_date < @enddate 

truncate table [16_RMS_CT]
insert into [16_RMS_CT]

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT      [ID]
	       ,[Title]
           ,[FirstName]
           ,[LastName]
	  	   ,[Company]
           ,[Address]
	  	  ,[Address2]
          ,[City]
	      ,[State]
    	  ,[Country]
          ,[Zip]
	      ,[EmailAddress]
          ,[TotalSales]
          ,[LastVisit]
          ,[CurrentDiscount]
          ,[PriceLevel]
  	 
  FROM [na-sqlc01v01].[RMSBookshopDB].[dbo].[Customer]
  where lastvisit < @enddate

  truncate table  [17_RMS_TX]

insert into [17_RMS_TX]

  SELECT Customer.FirstName + ', ' + Customer.LastName AS CustomerName, Customer.Emailaddress, Customer.AccountNumber, Customer.Company, Customer.Address,
       Customer.Address2, Customer.City, Customer.State, Customer.Zip, Department.Name, Category.Name as  Name10,Item.ItemLookupCode, Supplier.SupplierName,
  	Item.BinLocation, Item.Description, Item.WebItem, Item.Quantity, Item.Price, Item.PriceA, Item.PriceB, Item.PriceC, Item.SalePrice, Item.SaleStartDate,
		 Item.SaleEndDate, Item.LastSold, TransactionEntry.Quantity as  Quantity25,TransactionEntry.Price as  Price26,TransactionEntry.Price * TransactionEntry.Quantity AS Total, 
		 [Transaction].TransactionNumber, [Transaction].Time, TransactionEntry.Quantity * TransactionEntry.Cost AS Cost,
		  (TransactionEntry.Price - TransactionEntry.Cost) * TransactionEntry.Quantity AS Profit,
	  	  CASE WHEN TransactionEntry.Price <> 0 THEN CASE WHEN TransactionEntry.Quantity > 0 THEN (TransactionEntry.Price - TransactionEntry.Cost) / TransactionEntry.Price ELSE CASE WHEN TransactionEntry.Quantity < 0 THEN (TransactionEntry.Price - TransactionEntry.Cost) / (TransactionEntry.Price*-1) ELSE 0 END END ELSE 0 END AS ProfitMargin,
	   ReasonCodeDiscount.Description as  Description33,ReasonCodeTaxChange.Description as  Description34,ReasonCodeReturn.Description as  Description35,
		CASE TransactionEntry.PriceSource WHEN 1 THEN 'Regular Price' WHEN 2 THEN 'Quantity Discount' WHEN 3 THEN 'Buydown Discount' WHEN 4 THEN 'Price Level Disc.' WHEN 5 THEN 'Sale Price' WHEN 6 THEN 'Disc. from Reg. Price by Cashier' WHEN 7 THEN 'Disc. from Cur. Price by Cashier' WHEN 8 THEN 'Cost Markup Disc. by Cashier' WHEN 9 THEN 'Profit Margin Disc. by Cashier' WHEN 10 THEN 'Cashier Set' WHEN 11 THEN 'Component' ELSE 'Unknown' END AS PriceSource, 
		Register.Number       FROM    [na-sqlc01v01].RMSBookShopDB.dbo.TransactionEntry INNER JOIN  [na-sqlc01v01].RMSBookShopDB.dbo.[Transaction] WITH(NOLOCK) ON TransactionEntry.TransactionNumber = [Transaction].TransactionNumber 
         INNER JOIN   [na-sqlc01v01].RMSBookShopDB.dbo.Batch WITH(NOLOCK) ON [Transaction].BatchNumber = Batch.BatchNumber 
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.Item WITH(NOLOCK) ON TransactionEntry.ItemID = Item.ID 
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.Department WITH(NOLOCK) ON Item.DepartmentID = Department.ID 
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.Category WITH(NOLOCK) ON Item.CategoryID = Category.ID 
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.Supplier WITH(NOLOCK) ON Item.SupplierID = Supplier.ID 
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.ReasonCode AS ReasonCodeDiscount WITH(NOLOCK) ON TransactionEntry.DiscountReasonCodeID = ReasonCodeDiscount.ID 
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.ReasonCode AS ReasonCodeTaxChange WITH(NOLOCK) ON TransactionEntry.TaxChangeReasonCodeID = ReasonCodeTaxChange.ID
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.ReasonCode AS ReasonCodeReturn WITH(NOLOCK) ON TransactionEntry.ReturnReasonCodeID = ReasonCodeReturn.ID
         LEFT JOIN       [na-sqlc01v01].RMSBookShopDB.dbo.Register WITH(NOLOCK) ON Batch.RegisterID = Register.ID
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.Customer WITH(NOLOCK) ON [Transaction].CustomerID = Customer.ID
         LEFT JOIN    [na-sqlc01v01].RMSBookShopDB.dbo.Cashier WITH(NOLOCK) ON [Transaction].CashierID = Cashier.ID
		 where lastvisit > @startdate or (lastvisit is null and [Transaction].Time > @startdate) -- updated 03/10/2019 call number 9714

truncate table [18_RDR_CT] 

insert into [18_RDR_CT] 
 select r.[user_id],user_ticket,
	  case [user_type] when 10 then 'Staff' when 20 then 'Temporary Ticket'  when 30 then 'Government' when 40 then 'Public' end as user_type,
	  case [user_status] when 10 then 'Active' else 'Inactive' end as user_status,
	  [user_title],[user_fname],replace([user_sname],char(124), char(32)) as user_sname,[user_gender],
  CAST((ISNULL([house_no_name], '') + ' ' + ISNULL(replace([address_line1], char(124), char(32)), '')) AS VARCHAR(255)) as address_line_1,[address_line2],[post_town],[county],[postcode],[country],
  replace (ct.contact_no,char(124), char(32)) as email_address, 
  ch.contact_no as contact_phone,
  user_Marketing, user_Shared
   FROM [wb-sqlc01v02].[prologon].[dbo].[user_reader] r 
   LEFT JOIN [wb-sqlc01v02].[prologon].[dbo].user_reader_marketing m on r.user_id = m.user_id
   LEFT JOIN ( select user_id, contact_no, contact_id ,
	row_number() over ( partition by c.user_id order by c.contact_id desc ) as row_num from [wb-sqlc01v02].[prologon].[dbo].user_reader_contacts c where contact_type=50) ct 
	on ct.user_id = r.user_id and row_num = 1 
   LEFT JOIN ( select user_id, contact_no, contact_id ,
	row_number() over ( partition by c1.user_id order by c1.contact_id desc ) as row_num1 from [wb-sqlc01v02].[prologon].[dbo].user_reader_contacts c1 where contact_type=60) ch 
	on ch.user_id = r.user_id and row_num1 = 1 where user_inactivation_date > @startdate 
	union
	--archive tables
  select r.[user_id],user_ticket,
  	  case [user_type] when 10 then 'Staff' when 20 then 'Temporary Ticket'  when 30 then 'Government' when 40 then 'Public' end as user_type,
	  case [user_status] when 10 then 'Active' else 'Inactive' end as user_status,
  [user_title],[user_fname],replace([user_sname],char(124), char(32)) as user_sname,[user_gender],
  ISNULL([house_no_name],'') + ' ' + ISNULL(replace([address_line1],char(124), char(32)),'') as address_line_1,[address_line2],[post_town],[county],[postcode],[country],
   replace (ct.contact_no,char(124), char(32)) as email_address, 
  ch.contact_no as contact_phone,
  user_Marketing, user_Shared
   FROM [wb-sqlc01v02].[prologon].[dbo].[arch_user_reader] r 
   LEFT JOIN [wb-sqlc01v02].[prologon].[dbo].arch_user_reader_marketing m on r.user_id = m.user_id
   LEFT JOIN ( select user_id, contact_no, contact_id ,
	row_number() over ( partition by c.user_id order by c.contact_id desc ) as row_num from [wb-sqlc01v02].[prologon].[dbo].arch_user_reader_contacts c where contact_type=50) ct 
	on ct.user_id = r.user_id and row_num = 1 
   LEFT JOIN ( select user_id, contact_no, contact_id ,
	row_number() over ( partition by c1.user_id order by c1.contact_id desc ) as row_num1 from [wb-sqlc01v02].[prologon].[dbo].arch_user_reader_contacts c1 where contact_type=60) ch 
	on ch.user_id = r.user_id and row_num1 = 1 where user_inactivation_date >  @startdate 

truncate table [19_RDR_MB] 

insert into [19_RDR_MB] 
	select user_id,user_ticket,[user_issuedate]  , [user_expiry_date]  ,[user_inactivation_date] 
from [wb-sqlc01v02].[prologon].[dbo].user_reader where user_inactivation_date >  @startdate 
union
select user_id,user_ticket,[user_issuedate]  , [user_expiry_date]  ,[user_inactivation_date] 
from [wb-sqlc01v02].[prologon].[dbo].arch_user_reader  where user_inactivation_date >  @startdate 

truncate table [20_RDR_RQ] 


insert into [20_RDR_RQ] 
select req_id, user_id, user_ticket,USER_GROUP,
PRODUCTION_TYPE,REQ_TYPE_CODE,
 letter_code + ' ' + convert(varchar(10),class_no) + 
	case  when subclass_no = -1 then '' else '/' + convert(varchar(10),subclass_no) end + '/' + piref as  REQUEST_DETAILS,
	ORDER_DATE,LAST_SCANNED_DATE, letter_code, class_no
from [wb-sqlc01v02].doris.dbo.requisitions where  user_id is not null and order_date > @startdate 
 and order_date < @enddate order by order_date


 truncate table [21_RDR_BR] 
--now running monthly job that gets the last 3 years data

insert into [21_RDR_BR] 
select * from  [wb-sqlc01v02].doris.dbo.temp_barrier


  truncate table [22_DIS_CT]

insert into [22_DIS_CT]
select u.id, email, title, 
name, 
firstname, lastname,
 department, housenameno,street, town, county, u.country, postcode, 
phonenumber,readerticket, contactbyTNA, MailingList,  
lastlogindate = CASe when lastlogindate < createdate then createdate else lastlogindate  end ,
 CAST(createdate AS datetime) 
 from 
[wb-sqlc01v02].aspidentity.dbo.aspnetusers u left outer join [wb-sqlc01v02].aspidentity.dbo.addresses a 
on applicationuser_id = u.id  
where lastlogindate < @enddate and createdate < @enddate and lastlogindate > @startdate -- Updated 19/02/2019 call 7706 


truncate table [23_rco_tx]

insert into [23_RCO_TX] 
SELECT        tbl_customer.title_text, tbl_customer.first_names_text,	tbl_customer.family_name_text,
			  tbl_customer.telephone_text,tbl_customer.fax_no_text, 
	          tbl_customer.reader_ticket_number,tbl_customer.source_text,
		      tbl_customer.password_text,	tbl_customer.row_change_date, 
         			    tbl_customer.marketing_question,tbl_customer_address.address_usage_text,
						 replace(replace(tbl_customer_address.address_text, char(13), char(32)), char(10), char(32)) , 
                         replace(replace(tbl_customer_address.postcode_text, char(13), char(32)), char(10), char(32)) , 
						 replace(replace(tbl_customer_address.country_ID, char(13), char(32)), char(10), char(32)), 
						 tbl_customer_address.row_change_date AS CA_row_change_date, 
                         tbl_customer_address_1.address_usage_text AS CA1_address_usage_text, tbl_customer_address_1.address_text AS CA1_address_text, 
                         tbl_customer_address_1.postcode_text AS CA1_postcode_text, tbl_customer_address_1.country_ID AS CA1_country_ID, 
                         tbl_customer_address_1.row_change_date AS CA1_row_change_date,tbl_customer_interaction.copying_order_delivery_ID, 
                         tbl_customer_interaction.interaction_type_text,tbl_customer_interaction.action_text,tbl_customer_interaction.create_date, 
                         tbl_customer_interaction.target_date,tbl_customer_interaction.complete_date,tbl_customer_interaction.source_text AS CI_source_text, 
                         tbl_customer_interaction.row_change_date AS CI_row_change_date,tbl_customer_interaction.target_date_by_agreement AS CI_target_date_by_agreement, 
                         tbl_customer.customer_ID, tbl_customer_address.customer_address_id
FROM            [wb-sqlc01v03].record_copying_legacy.dbo.tbl_customer as tbl_customer LEFT OUTER JOIN
                          [wb-sqlc01v03].record_copying_legacy.dbo.tbl_customer_interaction as tbl_customer_interaction ON tbl_customer.customer_ID = tbl_customer_interaction.customer_ID LEFT OUTER JOIN
                          [wb-sqlc01v03].record_copying_legacy.dbo.tbl_customer_address AS tbl_customer_address_1 ON tbl_customer.customer_ID = tbl_customer_address_1.customer_ID LEFT OUTER JOIN
                         [wb-sqlc01v03].record_copying_legacy.dbo.tbl_customer_address as tbl_customer_address ON tbl_customer.customer_ID = tbl_customer_address.customer_ID
WHERE        (tbl_customer_address.address_type_text = 'P') AND (tbl_customer_address_1.address_type_text = 'E')
and  create_date > @startdate and create_date < @enddate

truncate table [24_RCN_TX] 

insert into [24_RCN_TX] 
SELECT [Id],
      [UserId]
      ,[Email]
      ,[ProfileName]
      ,[Title]
      ,[FirstName]
      ,[LastName]
      ,[Telephone]
      ,[Address1]
      ,[Address2]
      ,[City]
      ,[County]
      ,[PostCode]
      ,[Country]
      ,cu.[ChangedBy], ItemId AS Expr1, PageCheckId, OrderStatusId, TransactionNo, 
                         GroupedOrder, Created, TargetDate, Completed, Dispatched, 
                         Collected, replace (CancelReason,char(13), char(32)) as CancelReason, SuspendedReason, Price, DeliveryPrice, 
                         Naturalisation, CopyingSelected, DeliverySelected, RecordDetailsId, 
                         CustomerId, AdditionalInformationId, co.ChangedBy AS OrderUpdatedBy
FROM            [wb-sqlc01v02].RecordCopying.dbo.tblCustomer cu INNER JOIN
                            [wb-sqlc01v02].RecordCopying.dbo.tblCopyOrder co ON cu.Id = CustomerId
						 where created < @enddate


Update [24_RCN_TX] set [EMAIL] = replace(Replace([EMAIL], char(10), ''), char(13), '');Update [24_RCN_TX] set [PROFILENAME] = replace(Replace([PROFILENAME], char(10), ''), char(13), '');
Update [24_RCN_TX] set [TITLE] = replace(Replace([TITLE], char(10), ''), char(13), '');Update [24_RCN_TX] set [FIRSTNAME] = replace(Replace([FIRSTNAME], char(10), ''), char(13), '');
Update [24_RCN_TX] set [LASTNAME] = replace(Replace([LASTNAME], char(10), ''), char(13), '');Update [24_RCN_TX] set [TELEPHONE] = replace(Replace([TELEPHONE], char(10), ''), char(13), '');
Update [24_RCN_TX] set [ADDRESS1] = replace(Replace([ADDRESS1], char(10), ''), char(13), '');Update [24_RCN_TX] set [ADDRESS2] = replace(Replace([ADDRESS2], char(10), ''), char(13), '');
Update [24_RCN_TX] set [CITY] = replace(Replace([CITY], char(10), ''), char(13), '');Update [24_RCN_TX] set [COUNTY] = replace(Replace([COUNTY], char(10), ''), char(13), '');
Update [24_RCN_TX] set [POSTCODE] = replace(Replace([POSTCODE], char(10), ''), char(13), '');Update [24_RCN_TX] set [COUNTRY] = replace(Replace([COUNTRY], char(10), ''), char(13), '');
Update [24_RCN_TX] set [CHANGEDBY] = replace(Replace([CHANGEDBY], char(10), ''), char(13), '');Update [24_RCN_TX] set [EXPR1] = replace(Replace([EXPR1], char(10), ''), char(13), '');
Update [24_RCN_TX] set [CANCELREASON] = replace(Replace([CANCELREASON], char(10), ''), char(13), '');Update [24_RCN_TX] set [SUSPENDEDREASON] = replace(Replace([SUSPENDEDREASON], char(10), ''), char(13), '');
Update [24_RCN_TX] set [ORDERUPDATEDBY] = replace(Replace([ORDERUPDATEDBY], char(10), ''), char(13), '');


truncate table [34_WIF_CT] 
insert into [34_WIF_CT] 

SELECT [email]
      ,[subRequest]
      ,[timestamp]
  FROM [wb-sqlc01v03].[public_portal].[dbo].[emaillist] where timestamp < @enddate

truncate table [35_WIF_ss] 
insert into [35_WIF_SS] 
SELECT [mac_address]
      ,[email]
      ,[timestamp]
  FROM [wb-sqlc01v03].[public_portal].[dbo].[maclist] where timestamp < @enddate