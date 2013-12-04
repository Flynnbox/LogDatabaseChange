set quoted_identifier off 
go
set ansi_nulls off 
go

--create table
if exists ( select 1 from information_schema.tables where table_name = N'logDatabaseChange' ) begin
  drop table logDatabaseChange
end

if not exists ( select 1 from information_schema.tables where table_name = N'logDatabaseChange' ) begin
	create table [dbo].[logDatabaseChange]
	(
	 [ChangeLogGuid] [uniqueidentifier] not null,
	 [ApplicationName] [varchar](50) not null,
	 [FilePath] [varchar](500) not null,
	 [FileVersion] [int] not null,
	 [Description] [varchar](max) null,
	 [CreatedDate] [datetime] not null,
	 [CreatedBy] [varchar](50) not null,
	 constraint [PK_logDatabaseChange] primary key nonclustered ([ChangeLogGuid] asc, [FileVersion] asc) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY]

	alter table [dbo].[logDatabaseChange] add constraint DF_logDatabaseChange_CreatedDate default (getdate()) for [CreatedDate]

	alter table [dbo].[logDatabaseChange] add constraint DF_logDatabaseChange_CreatedBy default (suser_sname()) for [CreatedBy]

end
go

--create stored procedure
if exists ( select 1 from information_schema.routines where routine_name = 'logDatabaseChangeInsert' and routine_type = 'procedure' ) 
  drop procedure [dbo].[logDatabaseChangeInsert]
go

create procedure [dbo].[logDatabaseChangeInsert]
(
 @Guid uniqueidentifier,
 @Version int = 0,
 @App varchar(50),
 @File varchar(500),
 @Desc varchar(max) = null
)
as 
set nocount on

insert  into logDatabaseChange
        (
         ChangeLogGuid,
         ApplicationName,
         FilePath,
         FileVersion,
         Description
        )
values
        (
         @Guid,
         @App,
         @File,
         @Version,
         @Desc
        )

set nocount off
go

grant execute on [dbo].[logDatabaseChangeInsert] to public
go

--create udf
if exists ( select 1 from information_schema.routines where routine_name = 'logIsNewVersionOfDatabaseChange' and routine_type = 'function' ) 
  drop function [dbo].[logIsNewVersionOfDatabaseChange]
go
  
create function [dbo].[logIsNewVersionOfDatabaseChange]
(
 @Guid uniqueidentifier,
 @Version int = 0
)
returns bit
as 
begin
  declare @IsNewDatabaseChange bit

  if exists ( select 1 from logDatabaseChange where ChangeLogGuid = @Guid and FileVersion >= @Version ) begin
    set @IsNewDatabaseChange = 0
  end
  else begin
		set @IsNewDatabaseChange = 1
  end

  return @IsNewDatabaseChange
end
go

declare @temp uniqueidentifier = newid()
exec logDatabaseChangeInsert @temp, 1, 'LOG', 'logDatabaseChange_deploy.sql', 'Created logDatabaseChange table, stored procedure, and udf';

set quoted_identifier off 
go
set ansi_nulls on 
go