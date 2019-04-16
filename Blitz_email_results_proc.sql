--select * from master..v_blitz_results

create proc sp_email_blitz_results
as
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

set @xml = cast((select priority as 'td','',checkdate as 'td','',finding as 'td','',case when databasename is null then 'Null' else databasename end as 'td','',details as 'td','',url as 'td'
from master..v_blitz_results
order by priority, databasename
for xml path('tr'), elements ) as nvarchar(max))

set @body = '<html><body><H3>Blitz Results High Priority for Tallmadge-DB</H3>
<table border = 1>
<tr>
<th>Priority Level</th> <th>Date</th> <th>Result</th> <th>Database</th> <th>Details</th> <th>More Info</th>'

set @body = @body + @xml + '</table></body></html>'

exec msdb.dbo.sp_send_dbmail
@profile_name = 'DBMail_Tallmadge_DB',
@body = @body,
@body_format = 'HTML',
@recipients = 'tadams@summitoh.net',
@subject = 'SP Blitz High Priority results for Tallmadge-DB'


--exec sp_email_blitz_results
