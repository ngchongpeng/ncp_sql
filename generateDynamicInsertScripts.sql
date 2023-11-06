
--
if (object_id('tempdb..##temp')) is not null drop table ##temp

--
declare @query varchar(max) = 'select * from Person where Name=''Jingwen'''
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

--
declare @columns varchar(max) = (select string_agg(COLUMN_NAME,',') from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=@table)
declare @values varchar(max) = (select string_agg(''''''''' + ' + 'isnull(convert(varchar(max),' + COLUMN_NAME + '),''NULL'')' + ' + ''''''''',','','',') from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=@table)

--
declare @dynamicQuery nvarchar(max) = 'select ''insert into ' + @table + ' (' + @columns + ') values ('' + ' + 'concat(' + @values + ') + '')'' from ##temp'
exec sp_executesql @dynamicQuery

--
if (object_id('tempdb..##temp')) is not null drop table ##temp

