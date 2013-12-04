--***Use Ctrl-Shift-M to replace parameter placeholders***--
if exists (select 1 from information_schema.views where table_name = N'<viewName, sysname, appTable>')
	drop view <viewName, sysname, appTable>
go

create view <viewName, sysname, appTable>
as
select
	--columnlist
from
	--tablelist
go

print 'View: <viewName, sysname, appTable>.viw version ' + cast(@Version as varchar) + ' successfully applied to ' + @@servername + '.' + db_name();
go
