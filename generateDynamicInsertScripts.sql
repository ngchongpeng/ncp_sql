


--
if (object_id('tempdb..##temp')) is not null drop table ##temp

--
declare @query varchar(max) = 'select * from ParenthoodTaxRebateTransaction where ParenthoodTaxRebateHeaderId in (select Id from ParenthoodTaxRebateHeader where ParenthoodTaxRebateAccountId=''75CE502A-644E-4F3E-B7EA-0BCED8ADC120'')'
declare @q nvarchar(max) = concat('select * into ##temp from (',  @query, ') a')
exec sp_executesql @q

--
declare @table varchar(max) = trim(substring(
	@query,
	charindex('from',@query)+len('from'),
	case
		when charindex('where',@query) = 0
		then len(@query)-(charindex('from',@query)+len('from'))+1
		else charindex('where',@query)-(charindex('from',@query)+len('from'))
	end))

declare @t varchar(max) = case
	when CHARINDEX('.',@table) = 0
	then @table
	else SUBSTRING(@table,charindex('.',@table)+1,len(@table)-charindex('.',@table))
	end

--
declare @columns varchar(max) = (select string_agg(COLUMN_NAME,',') from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=@t)
declare @values varchar(max) = (select string_agg(''''''''' + ' + 'isnull(convert(varchar(max),' + COLUMN_NAME + '),''NULL'')' + ' + ''''''''',','','',') from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=@t)

--
declare @dynamicQuery nvarchar(max) = 'select replace(''insert into ' + @table + ' (' + @columns + ') values ('' + ' + 'concat(' + @values + ') + '')'',''''''NULL'''''',''NULL'') as [INSERT] from ##temp'
exec sp_executesql @dynamicQuery

--
if (object_id('tempdb..##temp')) is not null drop table ##temp

