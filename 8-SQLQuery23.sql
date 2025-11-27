
if object_id('[dbo].[sp_DashBoard]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_DashBoard] as select 1')
GO
--exec sp_DashBoard 23,'VN',1
ALTER PROCEDURE [dbo].[sp_DashBoard](@LoginID int =23, @LanguageID varchar(3) ='VN', @isWeb int=2,@MenuID varchar(20)='')
as
begin
	--if @LoginID = 21 SET @LoginID = 38
	declare @dataHtml_mobile nvarchar(max) =N'';
	SET NOCOUNT ON
	if @isWeb=2 begin
		
	   -- if @LoginID = 3
	   -- begin
	   --     exec sp_dashboard_mobile_new @dataHtml_mobile=@dataHtml_mobile output, @LoginID=@LoginID, @LanguageID=@LanguageID, @isWeb=@isWeb
	   --select @dataHtml_mobile as col1
	   --return
	   -- end
		exec sp_dashboard_mobile @dataHtml_mobile=@dataHtml_mobile output, @LoginID=@LoginID, @LanguageID=@LanguageID, @isWeb=@isWeb

	   select @dataHtml_mobile as col1
	   return
	end

	 exec HtmlMacOSLayOut @Html = @dataHtml_mobile OUTPUT,  @LoginID = @LoginID, @LanguageID = @LanguageID, @isWeb = @isWeb
		
	DECLARE @EmployeeLogin varchar(20) = ''
	 select @EmployeeLogin = EmployeeID from tblSC_Login where LoginID = @LoginID
	

	 --@CssCol+@Query
	 select @dataHtml_mobile as col1, '' as col2, '' as col3


 return
	---Header (để chơi có thể ko dùng) Hùng
	exec sp_LoadMobileTopLink @LoginID = @LoginID, @LanguageID = @LanguageID, @IsWeb = @IsWeb, @MenuID = @MenuID, @IsSelect = 1
	declare @Query nvarchar(max) ='', @CssCol varchar(max) ='', @ViewDate date, @FromDate datetime, @ToDate datetime, @EmployeeId_Login varchar(20),@CYear int, @FromDateYear datetime, @ToDateYear datetime

	set @ViewDate = GETDATE()
	select @CYear = Year from dbo.fn_Get_Sal_Month_Year(@ViewDate)
	
	--SET @CYear = YEAR(@ViewDate)

	select @FromDateYear = FromDate from dbo.fn_Get_SalaryPeriod(1,@CYear)
	select @ToDateYear = ToDate from dbo.fn_Get_SalaryPeriod(12,@CYear)

	--set @ViewDate ='20220902'
	select @FromDate = FromDate,@ToDate = Todate from dbo.fn_Get_SalaryPeriod_ByDate(@ViewDate)
	
	-- khoanh vùng dữ liệu
	select ee.EmployeeID ,case when @LanguageID = 'VN' then ee.FullName else isnull(ee.CallName, ee.FullName) end FullName,ee.DepartmentID
	--,CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("ee.PhotoImage")))', 'VARCHAR(MAX)') PhotoImage
	,ee.PhotoImage,ee.HireDate
	,ee.Birthday,ee.PositionID--,ee.PhotoImage PhotoImage2
	into #EmployeeList_dash
	from dbo.fn_vtblEmployeeList_Bydate(GETDATE(),'-1',null) as ee
	where (ee.TerminateDate is null or ee.TerminateDate > GETDATE())
	
	--tạo hình mặt định nếu k ai có hình
	update #EmployeeList_dash set PhotoImage = (select IconData from ParadiseIconSVG where IconName = 'AvatarPlaceHolder') where PhotoImage is null

	select @EmployeeId_Login = EmployeeID from tblSC_Login l where l.LoginID = @LoginID and exists (select 1 from #EmployeeList_dash e where l.EmployeeID = e.EmployeeID)
	
	--if @EmployeeId_Login is null set @EmployeeId_Login = (select top 1 EmployeeID from #EmployeeList_dash l)

	--tringuyen
	exec HR_LeaveBudget_Initialization @LoginID = null, @CalendarYear = @CYear, @LeaveCode = 'AL', @EmployeeID = @EmployeeId_Login, @CalcToDate = @ViewDate
	
	--danh sách có phân quyền theo nhóm manager
	select LoginID,LoginName,EmployeeID,s.Items as ParentLoginID into #SC_Login_GroupRight from tblSC_Login
	cross apply dbo.SplitString(ParentLoginID,'&') as s
	where ParentLoginID is not null and s.Items = 8
	--Thông tin người đăng nhập
	select top 1 s.LoginID,s.LoginName,e.FullName,CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("e.PhotoImage")))', 'VARCHAR(MAX)') PhotoImage
	,case when @LanguageID = 'VN' then d.PositionName else d.PositionNameEN  end as DivisionName,e.HireDate,
	case when @LanguageID = 'VN' then p.DepartmentName else p.DepartmentNameEN   end as DepartmentName,e.EmployeeID,p.DepartmentID
	into #SC_Login
	from tblSC_Login s
	inner join #EmployeeList_dash e on e.EmployeeID =  @EmployeeId_Login
	left join tblPosition d on d.PositionID = e.PositionID
	left join tblDepartment p on p.DepartmentID = e.DepartmentID
	where @LoginID = s.LoginID
	
	select a.notificationID,notificationFromDate into #tmpNotiList from tblNotificationLocal a inner join NotificationRecipient b on a.notificationID = b.notificationID
	where a.notificationFromDate between DATEADD(day,-10,getdate()) and DATEADD(day,5,getdate())
	and b.recipientID = @EmployeeId_Login

	--khởi tạo query
	declare @QueryNotification nvarchar(max)='',@QueryAbsent nvarchar(max) = '', @ContactCustomer nvarchar(max) = ''
	,@QueryPerAndLeave nvarchar(max) = '',@QueryBirthday nvarchar(max) = ''
	,@QueryBirthweek nvarchar(max) = '',@QueryLinkRegis nvarchar(max) = ''
	,@QueryLogin_info nvarchar(max) ='',@CountLeaveRegi int,@CountNotiUnread int,@CountOT int,@CountAttendance int,@CountMaternity int,@CountShift int,@Count int
	,@EmployeeLeave nvarchar(max) = '',@EmployeeOT nvarchar(max) = '',@EmployeeAttendance nvarchar(max) = '',@EmployeeMaternity nvarchar(max) = '',@EmployeeShift nvarchar(max) = '',@QueryEmpty nvarchar(max) = ''
	,@QueryApprillPer float

	--id phòng ban
	declare @Department int, @CountAllEmp int
	select @Department = DepartmentID from #EmployeeList_dash where EmployeeID =@EmployeeId_Login
	set @CountAllEmp = (select COUNT(1) from #EmployeeList_dash)
	--Thông báo
	declare @APPROVAL_COUNT INT
	EXEC Get_Parameter 'APPROVAL_COUNT',2,0,@APPROVAL_COUNT OUTPUT

	-- tăng ca
	set @Query = ''
	CREATE TABLE #tmpOvertimePendingApprove([Identity_ID] VARCHAR(36), Approver VARCHAR(20))
	SELECT @Query +=' WHEN Current_Approved_Level = '+ CAST(number AS VARCHAR(6))+' THEN Approver_'+CAST(number AS VARCHAR(6)) FROM master..spt_values WHERE type ='p' AND number BETWEEN 1 AND @APPROVAL_COUNT
	SELECT @Query = 'insert into #tmpOvertimePendingApprove(Identity_ID,Approver)
	Select Identity_ID, CASE '+@Query+' END
	from tblOTListRegistered where Approve_Status in(1,5) --and isnull(IsExpired,0) = 0'

	EXEC (@Query)
	DELETE #tmpOvertimePendingApprove  where not exists(select 1 from #SC_Login l where Approver = l.EmployeeID)

	-- nghỉ
	set @Query = ''
	CREATE TABLE #tmpLeavePendingApprove([IdentityID] VARCHAR(36), Approver VARCHAR(20))
	SELECT @Query +=' WHEN Current_Approve_Level = '+ CAST(number AS VARCHAR(6))+' THEN Approver_'+CAST(number AS VARCHAR(6)) FROM master..spt_values WHERE type ='p' AND number BETWEEN 1 AND @APPROVAL_COUNT
	SELECT @Query = 'insert into #tmpLeavePendingApprove(IdentityID,Approver)
	Select IdentityID, CASE '+@Query+' END
	from tblLeaveRegistered where Approve_Status in(1,5) --and isnull(IsExpired,0) = 0'

	EXEC (@Query)
	DELETE #tmpLeavePendingApprove  where not exists (select 1 from #SC_Login l where Approver = l.EmployeeID)

	-- xin xác nhận giờ công
	set @Query = ''
	CREATE TABLE #tmpAttendancePendingApprove([IdentityID] VARCHAR(36), Approver VARCHAR(20))
	SELECT @Query +=' WHEN Current_Approve_Level = '+ CAST(number AS VARCHAR(6))+' THEN Approver_'+CAST(number AS VARCHAR(6)) FROM master..spt_values WHERE type ='p' AND number BETWEEN 1 AND @APPROVAL_COUNT
	SELECT @Query = 'insert into #tmpAttendancePendingApprove(IdentityID,Approver)
	Select IdentityID, CASE '+@Query+' END
	from tblAttendanceConfirmRequest where Approve_Status in(1,5) --and isnull(IsExpired,0) = 0'

	EXEC (@Query)
	DELETE #tmpAttendancePendingApprove  where not exists (select 1 from #SC_Login l where Approver = l.EmployeeID)

	-- đăng ký thai sản
	set @Query = ''
	CREATE TABLE #tmpMaternityPendingApprove([IdentityID] VARCHAR(36), Approver VARCHAR(20))
	SELECT @Query +=' WHEN Current_Approve_Level = '+ CAST(number AS VARCHAR(6))+' THEN Approver_'+CAST(number AS VARCHAR(6)) FROM master..spt_values WHERE type ='p' AND number BETWEEN 1 AND @APPROVAL_COUNT
	SELECT @Query = 'insert into #tmpMaternityPendingApprove(IdentityID,Approver)
	Select IdentityID, CASE '+@Query+' END
	from tblMaternityConfirmRequest where Approve_Status in(1,5) --and isnull(IsExpired,0) = 0'

	EXEC (@Query)
	DELETE #tmpMaternityPendingApprove  where not exists (select 1 from #SC_Login l where Approver = l.EmployeeID)

	-- đăng ký ca làm việc
	set @Query = ''
	CREATE TABLE #tmpShiftPendingApprove([IdentityID] VARCHAR(36), Approver VARCHAR(20))
	SELECT @Query +=' WHEN Current_Approve_Level = '+ CAST(number AS VARCHAR(6))+' THEN Approver_'+CAST(number AS VARCHAR(6)) FROM master..spt_values WHERE type ='p' AND number BETWEEN 1 AND @APPROVAL_COUNT
	SELECT @Query = 'insert into #tmpShiftPendingApprove(IdentityID,Approver)
	Select IdentityID, CASE '+@Query+' END
	from tblShiftConfirmRequest where Approve_Status in(1,5) --and isnull(IsExpired,0) = 0'

	EXEC (@Query)
	DELETE #tmpShiftPendingApprove  where not exists (select 1 from #SC_Login l where Approver = l.EmployeeID)

	set @Query = ''
	--so gio nghi phep chờ duyệt
	select @QueryApprillPer=  sum(d.LvAmount)/8.0  from tblLeaveRegistered r
	inner join tblLeaveRegistered_Detail d on d.IdentityID = r.IdentityID and d.LeaveDate between @FromDateYear and @ToDateYear
	where isnull(r.Approve_Status,0) = 1 and exists(select 1 from #SC_Login  s where s.EmployeeID = r.EmployeeID)
	and r.LeaveCode = isnull((select [Value] from tblParameter where Code ='LEAVE_CODE_ANNUAL'),'AL')
	and not exists(select 1 from tblLvHistory lv where d.EmployeeID = lv.EmployeeID and d.LeaveDate = lv.LeaveDate and d.LeaveCode = lv.LeaveCode) --and d.LeaveStatus = lv.LeaveStatus)

	-- dem so don Nghỉ
	select @CountLeaveRegi = count(1) from tblLeaveRegistered r where exists (select 1 from #tmpLeavePendingApprove p where p.IdentityID = r.IdentityID)
	select @CountNotiUnread = count(1) from #tmpNotiList a left join UserNotificationDoneRead b on a.notificationID = b.notificationID and b.EmployeeID = @EmployeeId_Login
	where GETDATE() between notificationFromDate and DATEADD(ss,-1,DATEADD(day,3,dbo.Truncate_Date(notificationFromDate)))
	--where b.EmployeeID is null
	
	select @EmployeeLeave +=N'
	<tr>
	<td style="font-size:10px;padding-left:10px;width:45%"> '+e.FullName+' </td>
	<td style="font-size:10px;padding-left:10px;width:30%"> '+case when @LanguageID = 'vn' then  l.Description else  REPLACE(l.DescriptionEN,'''','') end + ' </td>
	<td style="font-size:10px;padding-left:10px;"> '+ CONVERT(varchar(5),r.LeaveFromDate,103)  +' - '+CONVERT(varchar(5),r.LeaveToDate,103) +'</td>
	</tr>
	'
	from tblLeaveRegistered r inner join #EmployeeList_dash e on r.EmployeeID = e.EmployeeID
	left join tblLeaveType  l on l.LeaveCode = r.LeaveCode
	where exists (select 1 from #tmpLeavePendingApprove p where p.IdentityID = r.IdentityID)
	order by r.LeaveFromDate, r.EmployeeID

	-- Đào tạo
	declare @CoutDT int,@QueryDT nvarchar(max) = '',@LinkDT nvarchar(max) = ''
	select tr.TrainingCourseID,co.TrainingCourseName,co.OrganizedBy,co.CourseObjective,co.ExamListID,ISNULL(tr.CompleteStatus,0) CompleteStatus,tr.CompleteTime
	,s.CompleteStatus as CompleteStatusName
	,q.QuestionGroupName
	into #DATA
	from tblTrainingStudents tr
	left join tblTrainingCourse as co on co.TrainingCourseID=tr.TrainingCourseID
	left join tblQuestionGroup as q on q.QuestionGroup = co.questiongroup
	left join tblTraingingCompleteStatus as s on s.CompleteID = isnull(tr.CompleteStatus,0)
	where EmployeeID=@EmployeeId_Login  and ISNULL(tr.CompleteStatus,0) in( 0,2)
	select @CoutDT = count(1) from #DATA

	
	
	 select @QueryDT += N'
		 <tr>
			  <td style="font-size:10px;padding-left:10px;width:45%"> '+TrainingCourseName+N'</td>
			  <td style="font-size:10px;padding-left:10px;width:30%">'+QuestionGroupName+N'</td>
			  <td style="font-size:10px;padding-left:10px;">Chưa hoàn thành</td>
		 </tr>'
	 from #DATA
	 select top 1 @LinkDT  = N'Object=DataSetting.sp_TrainningListEmployee|Params=@ListF='+case when CompleteStatus = 0 then cast(10 as varchar(2)) else cast(2 as varchar(2)) end+N''
	 from #DATA

 -- tăng ca
 select @CountOT= count(1) from tblOTListRegistered  r
 where exists (select 1 from #tmpOvertimePendingApprove p where p.Identity_ID = r.Identity_ID)

 select @EmployeeOT += N'
 <tr>
  <td style="font-size:10px;padding-left:10px;width:45%"> '+e.FullName+N'</td>
  <td style="font-size:10px;padding-left:10px;width:30%">'+CONVERT(varchar(5),OTDateFrom,103)+' - '+CONVERT(varchar(5),OTDateTo,103)+N'</td>
  <td style="font-size:10px;padding-left:10px;">'+CONVERT(varchar(5),OTFrom,8)+' - '+CONVERT(varchar(5),OTTo,8)+N'</td>
 </tr>'
 from tblOTListRegistered  r
 inner join #EmployeeList_dash e on r.EmployeeID = e.EmployeeID
 where exists (select 1 from #tmpOvertimePendingApprove p where p.Identity_ID = r.Identity_ID)
 order by r.OTDateFrom, r.EmployeeID

 -- xin xác nhận giờ công
 select @CountAttendance = count(1) from tblAttendanceConfirmRequest r
 where exists (select 1 from #tmpAttendancePendingApprove p where p.IdentityID = r.IdentityID)

 select @EmployeeAttendance += N'
 <tr>
  <td style="font-size:10px;padding-left:10px;width:45%"> '+e.FullName+N'</td>
  <td style="font-size:10px;padding-left:10px;width:30%">'+CONVERT(varchar(10),r.AttDate,103)+N'</td>
  <td style="font-size:10px;padding-left:10px;">'+isnull(convert(nvarchar(5),In1,8),N'...') + ' -> ' + isnull(convert(nvarchar(5),Out1,8),N'...')+N'</td>
 </tr>'
 from tblAttendanceConfirmRequest r
 inner join #EmployeeList_dash e on r.EmployeeID = e.EmployeeID
 where exists (select 1 from #tmpAttendancePendingApprove p where p.IdentityID = r.IdentityID)
 order by r.AttDate, r.EmployeeID

 -- đăng ký thai sản
 select @CountMaternity = count(1) from tblMaternityConfirmRequest r
 where exists (select 1 from #tmpMaternityPendingApprove p where p.IdentityID = r.IdentityID)

 select @EmployeeMaternity += N'
 <tr>
  <td style="font-size:10px;padding-left:10px;width:45%"> '+e.FullName+N'</td>
  <td style="font-size:10px;padding-left:10px;width:30%">'+case when @LanguageID = 'vn' then es.EmployeeStatus else  REPLACE(es.EmployeeStatusEN,'''','') end+N'</td>
  <td style="font-size:10px;padding-left:10px;">'+CONVERT(varchar(5),FromDate,103)+' - '+CONVERT(varchar(5),ToDate,103)+N'</td>
 </tr>'
 from tblMaternityConfirmRequest r
 inner join #EmployeeList_dash e on r.EmployeeID = e.EmployeeID
 left join tblEmployeeStatus es on es.EmployeeStatusID = r.EmployeeStatusID_Materity
 where exists (select 1 from #tmpMaternityPendingApprove p where p.IdentityID = r.IdentityID)
 order by r.FromDate, r.EmployeeID

 -- đăng ký ca làm việc
 select @CountShift = count(1) from tblShiftConfirmRequest r
 where exists (select 1 from #tmpShiftPendingApprove p where p.IdentityID = r.IdentityID)

 select @EmployeeShift += N'
 <tr>
  <td style="font-size:10px;padding-left:10px;width:45%"> '+e.FullName+N'</td>
  <td style="font-size:10px;padding-left:10px;width:30%">'+case when @LanguageID = 'vn' then ss.ShiftName else dbo.fn_NonUnicode(ShiftName) end+N'</td>
  <td style="font-size:10px;padding-left:10px;">'+CONVERT(varchar(5),FromDate,103)+' - '+CONVERT(varchar(5),ToDate,103)+N'</td>
 </tr>'
 from tblShiftConfirmRequest r
 inner join #EmployeeList_dash e on r.EmployeeID = e.EmployeeID
 left join (select distinct ShiftCode, ShiftName from tblShiftSetting) ss on ss.ShiftCode = r.ShiftCode
 where exists (select 1 from #tmpShiftPendingApprove p where p.IdentityID = r.IdentityID)
 order by r.FromDate, r.EmployeeID

 select @QueryEmpty = ''


 select @QueryLogin_info =N'
   <tr>
    <td class="topimg" ><img src="data:image/png;base64,'+PhotoImage+N'" class="img-fluid"></td>
    <td class="topif">
   <p class="qt" style = "padding-bottom: 0px;text-transform: uppercase;">
   '+case when LoginID in (select LoginID from #SC_Login_GroupRight) and @isWeb not in (2) then +N'
  <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.HR_StaffInformation_List_2|Params=@EmployeeID='+@EmployeeId_Login+''')" >'+isnull(FullName,'')+N'</a>
  ' else +N'<a href="#" onClick="window.OpenFormLink(''Object=DataSetting.sp_Info_ForUserWeb'')" >'+isnull(FullName,'')+N'</a>' end +N'
   </p>
     <p style = "padding-bottom: 10px;">['+convert(varchar,HireDate,103)+N']</p>
     <p style = "padding-bottom: 10px;">'+isnull(DepartmentName,'')+' - '+isnull(DivisionName,'')+N'</p>
    </td>
   </tr>
 '
 from #SC_Login

   --số ngày nghỉ phép năm
 select @QueryPerAndLeave =N'

   <tr>
    <td ><p style = "padding-bottom: 0px;">'+case when @LanguageID = 'VN' then N'Tổng phép năm' else 'This year budget'  end+N'</p></td>
    <td ><p style = "padding-bottom: 0px;">'+cast(isnull(e.ThisYear,0) as varchar(10))+N'</p></td>
   </tr>
   <tr>
    <td ><p style = "padding-bottom: 0px;">'+case when @LanguageID = 'VN' then N'Đã sử dụng' else 'Taken'  end+N'</p></td>
    <td ><p style = "padding-bottom: 0px;">'+cast(isnull(e.Taken,0) as varchar(10))+N'</p></td>
   </tr>
   <tr>
    <td><p style = "padding-bottom: 0px;">'+case when @LanguageID = 'VN' then N'Đang chờ duyệt' else 'Pending approval '  end+N'</p></td>
    <td style ="padding:0px;"><p style = "padding-bottom: 0px;">'+cast(isnull(@QueryApprillPer,0) as varchar(10))+N'</p></td>
   </tr>
   <tr>
    <td><h5>'+case when @LanguageID = 'vn' then N'Phép năm chưa dùng 'else 'Leave blance'end +N'</h5></td>
    <td><h5>'+ cast(e.Remain-isnull(@QueryApprillPer,0) as varchar(10))+N'</h5></td>
   </tr>
 '
 from tblEmployeeAnnual  e WITH (NOLOCK)
 inner join #SC_Login s on s.EmployeeID = e.EmployeeID
 where e.CYear = @CYear
 --select * from  #SC_Login
 --Link đăng ký nghỉ phép
 --declare @QueryRemain float
 --select @QueryRemain = Remain from tblEmployeeAnnual e
 --inner join #SC_Login s on s.EmployeeID = e.EmployeeID
 --where CYear = @CYear

 select @QueryLinkRegis = N'
  <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.leave_assignment|Params=&@IdentityID_Param='')" >'+(select top 1 Content from  tblMD_Message where MessageID = 'MnuWPT003' and Language = @LanguageID)+N'</a>
 '
 from #SC_Login

 --sinh nhật hôm nay  -> danh sách
 select top 5 @QueryBirthday +=  N'
   <div class="ds-getform">
    <table style="width:100%;">
     <tr>
      <td style ="width:20%">
       <img src="'+case when  e.PhotoImage is not null then 'data:image/png;base64,'+CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("e.PhotoImage")))', 'VARCHAR(MAX)') else  '#'  end +N'" class="img-fluid" >
      </td>
      <td>
       '+e.FullName+N'<br>
       <span class="happy">'+case when @LanguageID = 'VN' then N'Chúc mừng sinh nhật' else 'Happy birthday' end +N'</span>
      </td>
     </tr>
    </table>
   </div>
 '
 from #EmployeeList_dash as e
 where month(e.Birthday) = MONTH(getdate()) and day(e.Birthday) = day(getdate())
 and (e.DepartmentID = @Department or @CountAllEmp < 100 or @LoginID = 3)

 --sinh nhật Tuần này  -> danh sách
declare @starw datetime
 declare @endw datetime
 SET @starw=cast(convert(varchar,DATEADD(DAY, 1-DATEPART(dw, getdate()), getdate()),23) as date)--lấy ngày đầu tuần  +
 SET @endw=cast(convert(varchar,DATEADD(DAY, 7-DATEPART(dw, getdate()), getdate()),23) as date) --lấy ngày cuối tuần

 select top 5 @QueryBirthweek +=  N'
     <div class="ds-getform">
      <table style="width:100%;">
       <tr>
        <td style ="width:20%">
         <img src="'+case when  e.PhotoImage is not null then 'data:image/png;base64,'+CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("e.PhotoImage")))', 'VARCHAR(MAX)') else  '#'  end +N'" class="img-fluid" >
        </td>
        <td>
         '+e.FullName+N'<br>
         <span>['+convert(varchar, e.Birthday,103)+']</span>
        </td>
       </tr>
      </table>
     </div>
 '
 from #EmployeeList_dash as e
 where (MONTH(e.Birthday) between MONTH(@starw)  and MONTH(@endw)) and (day(Birthday) between day(@starw) and day(@endw))
 and e.EmployeeID not in (select EmployeeID from #EmployeeList_dash where month(e.Birthday) = MONTH(getdate()) and day(e.Birthday) = day(getdate()) )
and (e.DepartmentID = @Department or @CountAllEmp < 100 or @LoginID = 3) and e.EmployeeID <> (select EmployeeID from #SC_Login)

--ABSENT
select lh.EmployeeID,case when @LanguageID = 'VN' then lt.Description else REPLACE(lt.DescriptionEN,'''','') end as LeaveStatus,lh.Reason,lt.LeaveCode, lh.LeaveDate
, CONVERT(varchar(5),ld.LeaveFrom,108) + '-' + CONVERT(varchar(5),ld.LeaveTo,108) as LeaveFromTo
into #tblAbsentEmployeeListToday
from tblLvHistory as lh
left join tblLeaveType lt on lt.LeaveCode = lh.LeaveCode
left join tblLeaveRegistered_Detail ld on lh.EmployeeID = ld.EmployeeID and lh.LeaveDate = ld.LeaveDate and ld.Approve_Status = 2
where datediff(day,lh.LeaveDate, @ViewDate) = 0 and lh.LeaveCode not in ('PH')

select top 0 * into #tblAbsentEmployeeList from #tblAbsentEmployeeListToday

 -- vắng 3 người tương lai
  insert into #tblAbsentEmployeeList(EmployeeID,LeaveStatus, Reason,LeaveCode,LeaveDate,LeaveFromTo)
  select lh.EmployeeID,case when @LanguageID = 'VN' then lt.Description else REPLACE(lt.DescriptionEN,'''','') end as LeaveStatus,lh.Reason,lt.LeaveCode, lh.LeaveDate
, CONVERT(varchar(5),ld.LeaveFrom,108) + '-' + CONVERT(varchar(5),ld.LeaveTo,108) as LeaveFromTo
  from tblLvHistory as lh
  left join tblLeaveType lt on lt.LeaveCode = lh.LeaveCode
  left join tblLeaveRegistered_Detail ld on lh.EmployeeID = ld.EmployeeID and lh.LeaveDate = ld.LeaveDate and ld.Approve_Status = 2
  where datediff(day,@ViewDate,lh.LeaveDate) between 1 and 5 and not exists (select 1 from #tblAbsentEmployeeList e where e.EmployeeID = lh.EmployeeID)
  and lh.LeaveCode not in ('PH')

--  insert into #tblAbsentEmployeeList(EmployeeID,LeaveStatus, Reason,LeaveCode,LeaveDate,LeaveFromTo)
--  select lh.EmployeeID,case when @LanguageID = 'VN' then lt.Description else REPLACE(lt.DescriptionEN,'''','') end as LeaveStatus,lh.Reason,lt.LeaveCode, lh.LeaveDate
--, CONVERT(varchar(5),ld.LeaveFrom,108) + '-' + CONVERT(varchar(5),ld.LeaveTo,108) as LeaveFromTo
--  from tblLvHistory as lh
--  left join tblLeaveType lt on lt.LeaveCode = lh.LeaveCode
--  left join tblLeaveRegistered_Detail ld on lh.EmployeeID = ld.EmployeeID and lh.LeaveDate = ld.LeaveDate and ld.Approve_Status = 2
--  where datediff(day,lh.LeaveDate, @ViewDate) = -2 and not exists (select 1 from #tblAbsentEmployeeList e where e.EmployeeID = lh.EmployeeID)
--  insert into #tblAbsentEmployeeList(EmployeeID,LeaveStatus, Reason,LeaveCode,LeaveDate,LeaveFromTo)
--  select lh.EmployeeID,case when @LanguageID = 'VN' then lt.Description else REPLACE(lt.DescriptionEN,'''','') end as LeaveStatus,lh.Reason,lt.LeaveCode, lh.LeaveDate
--, CONVERT(varchar(5),ld.LeaveFrom,108) + '-' + CONVERT(varchar(5),ld.LeaveTo,108) as LeaveFromTo
--  from tblLvHistory as lh
--  left join tblLeaveType lt on lt.LeaveCode = lh.LeaveCode
--  left join tblLeaveRegistered_Detail ld on lh.EmployeeID = ld.EmployeeID and lh.LeaveDate = ld.LeaveDate and ld.Approve_Status = 2
--  where datediff(day,lh.LeaveDate, @ViewDate) = -3 and not exists (select 1 from #tblAbsentEmployeeList e where e.EmployeeID = lh.EmployeeID)

-- thông báo có khách hàng liên hệ
declare @isSaleEmp bit=0
if exists (select 1 from tblEmployee te where te.EmployeeID = @EmployeeId_Login and IsContact = 1) --and exists (select 1 from tblContactCustommer cc where cc.UpdateTime between DATEADD(day,-5,getdate()) and GETDATE() and isnull(cc.StatusID,0) < 3)
set @isSaleEmp = 1
 SELECT IdentityID, c.FullName, c.Email, Phone, Company, Region, Company_size, e.FullName AS Emp_Name, CAST('' AS VARCHAR(30)) Class, StatusID, Content, UpdateTime
	INTO #ContactCustommer
	FROM tblContactCustommer c
	LEFT JOIN tblEmployee e ON c.EmployeeID = e.EmployeeID
	WHERE @isSaleEmp = 1 and EXISTS(SELECT *
				FROM #SC_Login s
				INNER JOIN tblEmployee e ON s.EmployeeID = e.EmployeeID WHERE e.IsContact = 1)
				and c.UpdateTime between DATEADD(day,-5,getdate()) and GETDATE() and isnull(c.StatusID,0) < 3
				OR @LoginID = 3
	ORDER BY ISNULL(c.EmployeeID, '')

	

	UPDATE #ContactCustommer SET Class = CASE WHEN StatusID > 0 THEN 'supported'
												ELSE 'supportStatus' END
--select @isSaleEmp
	SELECT TOP 5 @ContactCustomer += N'<div class="request-card  ' + CASE WHEN ISNULL(StatusID, 0) = 0 THEN 'supportStatus' ELSE 'supported' END +'" data-update-time="' + CONVERT(VARCHAR(10), UpdateTime, 23) + '">
										<a class="link-css" href="#"
											onClick="window.OpenFormLink(''Object=DataSetting.sp_requestConsultation|Params=@IdentityID=' + IdentityID + N''')">
											<table class="tr-td-th-css" style="width:100%;">
												<tr class="tr-td-th-css">
													<td class="tr-td-th-css" style="width: 35%;">Khách hàng: <br><strong>' + CASE WHEN ISNULL(FullName, '') = '' THEN 'N/A' ELSE FullName END  + N'</strong>
														<br><span class="tr-td-th-css">Hỗ trợ: <br><strong>' + CASE WHEN ISNULL(Emp_Name, '') = '' THEN N'Chưa có!' ELSE Emp_Name END + N'</strong></span>
													</td>
													<td class="tr-td-th-css">Công ty: <strong>' + CASE WHEN ISNULL(Company, '') = '' THEN 'N/A' ELSE Company END  + N'</strong>
														<br><span class="tr-td-th-css">Số ĐT: <strong>' + Phone + N'</strong></span>'
														+ CASE WHEN ISNULL(Content, '') = '' THEN ''
																	ELSE N'<br><span class="tr-td-th-css">Yêu cầu: ' + Content + N'</span>'
														END +
													N'</td>
												</tr>
											</table>
										</a>
									</div>'
	FROM #ContactCustommer

 set @ContactCustomer = ISNULL(@ContactCustomer, '')
 if @isSaleEmp = 1 or @LoginID = 3
	set @ContactCustomer = N'

			<a href="#" class="see-all-link" onClick="window.OpenFormLink(''Object=DataSetting.sp_ViewContactCustomerData'')"><h4 >'+case when @LanguageID = 'vn' then N'Danh sách yêu cầu tư vấn' else 'Request consultation' end+N'</h4></a>
		<div class="TuuVuong" >
    '+@ContactCustomer+N'
   </div>'
 --if LEN(@ContactCustomer) > 2

   --select @ContactCustomer
 --vắng hôm nay -> danh sách
if exists(select top 1 1 from #tblAbsentEmployeeListToday)
begin
	SET @QueryAbsent += '<h4 >'+case when @LanguageID = 'vn' then N'Nghỉ phép hôm nay' else 'Who''s absent today' end+N'</h4>'
	select @QueryAbsent +=  N'
	<div class="ds-getform">
	<table style="width:100%;">
		<tr>
		<td style ="width:25%">
		<img src="'+case when  e.PhotoImage is not null then 'data:image/png;base64,'+CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("e.PhotoImage")))', 'VARCHAR(MAX)') else  '#'  end +N'" class="img-fluid" >
		</td>
		<td>
		'+e.FullName+N'<br> <span style ="color:#ff0000">'+CONVERT(varchar(10),t.LeaveDate,103)+ ' ['+isnull(t.LeaveFromTo,'') +']</span><br>
		<span>'+case when @LanguageID = 'VN' then N'Loại nghỉ:[' else 'Leave type:[' end +t.LeaveCode+'] - '+ t.LeaveStatus +'-['+ case when @LanguageID = 'VN' then N'Lý do:' else 'Reason:' end+ isnull(t.Reason,'')+N']</span>
		</td>
		</tr>
	</table>
	</div>
	'
 from #EmployeeList_dash as e
 inner join #tblAbsentEmployeeListToday as t on t.EmployeeID = e.EmployeeID
 where (e.DepartmentID = @Department or @CountAllEmp < 100 or @LoginID = 3)
 order by t.LeaveDate, t.EmployeeID
end

if exists(select top 1 1 from #tblAbsentEmployeeList)
begin
	SET @QueryAbsent += '<h4 style="margin-top:3vh">'+case when @LanguageID = 'vn' then N'Nghỉ phép sắp tới' else 'Who''s absent next' end+N'</h4>'
	select top 10 @QueryAbsent +=  N'
	<div class="ds-getform">
	<table style="width:100%;">
		<tr>
		<td style ="width:25%">
		<img src="'+case when  e.PhotoImage is not null then 'data:image/png;base64,'+CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("e.PhotoImage")))', 'VARCHAR(MAX)') else  '#'  end +N'" class="img-fluid" >
		</td>
		<td>
		'+e.FullName+N'<br> <span style ="color:#ff0000">'+CONVERT(varchar(10),t.LeaveDate,103)+ ' ['+isnull(t.LeaveFromTo,'') +']</span><br>
		<span>'+case when @LanguageID = 'VN' then N'Loại nghỉ:[' else 'Leave type:[' end +t.LeaveCode+'] - '+ t.LeaveStatus +'-['+ case when @LanguageID = 'VN' then N'Lý do:' else 'Reason:' end+ isnull(t.Reason,'')+N']</span>
		</td>
		</tr>
	</table>
	</div>
	'
	from #EmployeeList_dash as e
	inner join #tblAbsentEmployeeList as t on t.EmployeeID = e.EmployeeID
	where (e.DepartmentID = @Department or @CountAllEmp < 100 or @LoginID = 3)
	order by t.LeaveDate, t.EmployeeID
end

set @QueryAbsent = ISNULL(@QueryAbsent,'')

 --#region: number of leave
 exec sp_Initialization_ApprovalLine_Leave @ViewDate = @ViewDate, @EmployeeID = '-1', @LoginID = null

 select  lv.EmployeeID, a.Approver_1 as ApproverByEmp1, a.Approver_2 as ApproverByEmp2, dep.Approver_1 as ApproverByDepart1, dep.Approver_2 as ApproverByDepart2--,lv.LeaveStatus,
 into #LvHistoryWithApprover
 from tblLeaveRegistered_Detail lv
 inner join #EmployeeList_dash te on lv.EmployeeID = te.EmployeeID
 left join tblApprovalLineByEmployee a on lv.EmployeeID = a.EmployeeID
 left join tblApprovalGroupByDepartment dep on te.DepartmentID = dep.DepartmentID
 where lv.LeaveDate = @ViewDate and lv.Approve_Status in(1,2,5)
 and exists(select 1 from tblLeaveType lt where lv.LeaveCode = lt.LeaveCode) --and isnull(lt.IsGoingOut,0) = 0 )



 create table #LeaveStatus(LeaveStatus int,LeaveStatusName nvarchar(200))
 insert into #LeaveStatus(LeaveStatus,LeaveStatusName)
 select 1, case when @LanguageID = 'VN' then N'Nửa đầu' else 'Haft a before' end
 union all
 select 2, case when @LanguageID = 'VN' then N'Nửa sau' else 'Haft a after' end
 union all
 select 3, case when @LanguageID = 'VN' then N'Cả ngày' else 'Fullday' end

 declare @LeaveCountToDay nvarchar(max) =''

 /*
  select N'Nghỉ' as LeaveStatusName, count(1) LeaveCount into #LeaveCountToDay from (
   select distinct EmployeeID from #LvHistoryWithApprover where (ApproverByEmp1 = @EmployeeId_Login or ApproverByEmp2 = @EmployeeId_Login)
    ) ko
delete  #LeaveCountToDay where LeaveCount = 0
 if exists(select 1 from #LeaveCountToDay)
 begin
 select @LeaveCountToDay = N'
 <tr>
    <td style="font-size:10px;padding-left:10px;width:45%"> '+cast(s.LeaveStatusName as nvarchar(30))+' </td>
    <td style="font-size:10px;padding-left:10px;width:30%"> '+cast(s.LeaveCount as nvarchar(10))+'</td>
    <td style="font-size:10px;padding-left:10px;"></td>
 </tr>

  '
  from #LeaveCountToDay s


 end
 */
 drop table #LvHistoryWithApprover,#LeaveStatus
 --#endregion: number of leave
 ---chart: thống kê




 --icon sinh nhật
 declare @ICon nvarchar(max) = '',@IConPasword nvarchar(max) = ''
 select @Icon  =LOWER(glyphicon) from MEN_Menu where MenuID = 'MnuHRS030'
 select @IConPasword  =LOWER(glyphicon) from MEN_Menu where MenuID = 'MnuSCR609'
 --@UsefulLinks

 create table #tmpDataRightCustom (FullAccess varchar(50),ObjectName nvarchar(200),LoginID int,ObjectID int)
 exec SC_LoadFullRightObject @LoginID,'#tmpDataRightCustom'

  --thiết lập chia các loại menu
select ROW_NUMBER()over(Partition by m.MobileDeviceGroup Order by m.MobileDeviceGroup,m.Priority)STT,m.MobileDeviceGroup, m.MenuID,m.Priority
 , '<h4>'+isnull(me.Content,'')+'</h4>
 <div class="grid-container">' as Html
into #tmpTitleHtml
from MEN_Menu m
left join tblMD_Message me on me.MessageID = m.MobileDeviceGroup and me.Language = @LanguageID
inner join tblSC_Object o on m.AssemblyName + '.' + m.ClassName = o.ObjectName
inner join #tmpDataRightCustom r on r.ObjectID = o.ObjectID
where r.LoginID = @LoginID and ISNULL(FullAccess,0) > 0
  and NotUsePlatform not like '%'+CAST(@isWeb as varchar(5))+ '%'
  and m.MenuID in (select CurrentMenuID from tblWorkFlow  where ParentMenuID = 'MnuWPT000' and left(CurrentMenuID,3) = 'Mnu')
  --UPDATE MEN_Menu SET NotUsePlatform = '' from MEN_Menu where NotUsePlatform is null

  select m.MenuID,m.ClassName,m.Priority,m.glyphicon,w.MenuColor, ISNULL(l.Content,m.MenuID) Content, CAST(0 as int) as PendingCount
  into #tmpMenuViewList from MEN_Menu m
 --phân quyền theo nhóm
 left join tblMD_Message l on l.MessageID = MenuID and l.Language = @LanguageID --tên menu
 inner join tblSC_Object o on m.AssemblyName + '.' + m.ClassName = o.ObjectName
 inner join #tmpDataRightCustom r on r.ObjectID = o.ObjectID
 inner join tblWorkFlow  w on w.CurrentMenuID = m.MenuID and w.ParentMenuID = 'MnuWPT000'
 where r.LoginID = @LoginID and ISNULL(FullAccess,0) > 0
    and NotUsePlatform not like '%'+CAST(@isWeb as varchar(5))+ '%' --and m.ParentMenuID = 'MnuWPT000'
    and m.MenuID in (select CurrentMenuID from tblWorkFlow  where ParentMenuID = 'MnuWPT000' and left(CurrentMenuID,3) = 'Mnu')
 and m.IsVisible = 1

 UPDATe #tmpMenuViewList SET PendingCount = (
	 select COUNT(distinct b.notificationID) as iCount from tblEmailList a inner join #tmpNotiList b on a.notificationID = b.notificationID
	 and a.EmployeeID = @EmployeeId_Login
 ) where ClassName = 'sp_showallnotificationuser'


 declare @UsefulLinks nvarchar(max) = ''
 select  @UsefulLinks += N'
 <div class="grid-item">
   <div class="ds-getform">
    <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.'+m.ClassName
    +case when m.MenuID in('MnuWPT002','MnuWPT004','MnuWPT005','MnuWPT006','MnuWPT010') then '|Params=@FromDate='+CONVERT(varchar(10),@FromDate,120)+N'&@ToDate='+CONVERT(varchar(10),@ToDate,120)
   when m.MenuID in('MnuWPT035','MnuWPT036') then '|Params=@ViewDate='+CONVERT(varchar(10),@ViewDate,120)
   else '' end
    +N''')" style="'+case when @isWeb = 1 then 'display:flex;' else '' end+N'align-items:center;" ><span class ="p-'+LOWER( m.glyphicon)+'" style="background-color:'+isnull(case when len(MenuColor) < 2 then '#0099ff' else MenuColor end,'#0099ff')+'"></span>'+'<p>'+ Content +'</p>'
    +N''+CASE WHEN PendingCount > 0 THEN '<span class="badgeNoti">'+CAST(PendingCount as varchar)+N'</span>'
		ELSE '' END + N'</a>
   </div>
</div>
 '
 from #tmpMenuViewList m order by m.Priority
 --select CurrentMenuID from tblWorkFlow  where ParentMenuID = 'MnuWPT000' and left(CurrentMenuID,3) = 'Mnu'
 --nếu có menu mới không truyền

insert into tmpCheckLoginData(LogTime,LoginID,EmployeeID,Func)
select GETDATE(),@LoginID,@EmployeeId_Login,'sp_DashBoard'

 --icon css
 declare @Iconcss nvarchar(max) = '',@IconcssColor nvarchar(max) = ''
 select @Iconcss += N' .p-'+Lower(glyphicon)+','
 from MEN_Menu
 where MenuID in(select CurrentMenuID from tblWorkFlow  where ParentMenuID = 'MnuWPT000' and left(CurrentMenuID,3) = 'Mnu')

  --tạo và mã màu cho từng css
  select  @IconcssColor += N' .tilte-oto .p-'+Lower(glyphicon)+'{color:white;padding:10px;font-size:25px;border-radius: 50%;}'
  from MEN_Menu s
  left join tblWorkFlow  w on w.CurrentMenuID = s.MenuID
  where MenuID in(select CurrentMenuID from tblWorkFlow  where ParentMenuID = 'MnuWPT000' and left(CurrentMenuID,3) = 'Mnu')
  group by s.glyphicon
 --web

  set @CssCol=N'
<style>
/*
@keyframes my {
	 0% { color: #004C39; }
	 30% { color: #00bf8f;  }
	 100% { color: #FFFFF;  }
 } */

 @keyframes glowing {
  5% { background-color: #C5C5C5; box-shadow: 0 0 3px #C5C5C5; }
  30% { background-color: #FF0000; box-shadow: 0 0 10px #FF0000; }
  100% { background-color: #FF0000; box-shadow: 0 0 3px #FF0000; }
 }
.badgeNoti {
	position: absolute;
	padding: 5px 10px;
	border-radius: 50%;
	background: red;
	color: white;
	right: 5px;
	top: 30%;
	font-size: 14px !important;
	margin: 3px 5px 0 0;
	/*animation: my 2s infinite; */
	animation: glowing 2500ms infinite ease-out;
 }


 .tilte-oto {
  display: flex;
 }
 .tilte-oto a{
  text-decoration: none;
  font-size: 17px !important;
  display:block;
  }
 .tilte-oto p{
  margin:0px;
 }
 .page1 {
  width: 65%;
 }

 .page2 {
  width: 35%;
 }
 .info_home{
  padding:10px 20px 20px 20px;
 }
 '

 +case when len(@QueryAbsent) <= 1 then '.asend_home{display:none}' else ''  end+N'

 '+case when len(@QueryBirthweek) <= 1 then '.GetMonth{display:none}' else ''  end+N'

 '+case when len(@QueryBirthday) <= 1 then '.GetDate{display:none}' else ''  end+N'

 '+case when len(@QueryBirthday) <= 1 and len(@QueryBirthweek) <= 1 then '.birday{display:none}' else ''  end+N'

 '+case when @CountLeaveRegi = 0 and @CountNotiUnread = 0 and @CoutDT = 0 and @CountOT = 0 and @CountAttendance = 0 and @CountMaternity = 0 and @CountShift = 0 and len(@LeaveCountToDay) <= 1 then '.noti_home{display:none;}' else '' end+N'
 .tilte-oto .asend_home,
 .noti_home,
 .ds-menu,
 .info_home,
 .birday,
 .menu2-moblie,
 .info2-moblie{


   margin-bottom: 2%;
  border-radius: 5px;
 }

 .tilte-oto .img-fluid {
  width: 65px;
  height: 72px;
 }
 .tilte-oto img{
  border-radius: 50%;
 }

 .dkLeave {
  text-align: center;
background-color: #1e7e34;
  padding-top: 5px;
  padding-bottom: 5px;
  border-radius:3px;
 }
 .dkLeave:hover {
  text-align: center;
  background-color: #12c83c;
 }
 .dkLeave a{
text-decoration: none;
  color: white;
 }
 .dkLeave a:hover{
  text-decoration: none;
  color: white;

 }
 .leave p {
  margin: 0px;

 }

 .infologin p {

  margin: 0px;
 }

 .tilte-oto h4 {
  text-align: left;
  padding:0px;
  border:0px;
  margin-left:2%;

 }
 .request-card {
        display: block;
        border-radius: 5px;
        background-color: #fff;
        margin-bottom: 8px;
        box-shadow: 0 0.0625rem 0.125rem 0 rgba(0, 0, 0, .1);
        padding: 10px;
        font-size: 0.8rem;
    }

	.tr-td-th-css {
		color: black;
        font-size: 0.8rem !important;
		padding-bottom: 10px !important;
    }

    .supportStatus {
        border-right: 8px solid #FFC107;
      padding-right: 8px;
   }

    .supported {
        border-right: 8px solid #00673B;
        padding-right: 8px;
    }

    .link {
        color: inherit;
        text-decoration: none;
        cursor: pointer;
    }

    .link:hover {
   color: #000;
    }

    .see-all-link {
        color: #0099FF;
        text-decoration: none;
        font-weight: bold;
    }
 .info2-moblie {
 display: none;
 }

 .menu2-moblie{
  display: none;
 }

 .birday  p {
  font-size: 20px;
  font-weight: bold;
  padding-left: 20px;
 }

 .birday  span {
  font-size: 10px;
 }
 .birday .name{
  font-size:15px;
 }
 .birday .p-gift{
font-size: 20px;
  margin-left:65%;
  /*animation: abc 0.3s infinite;*/
  color:red;
  transition: transform 2s;
 }
 .tilte-oto '+SUBSTRING(@Iconcss,1,Len(@Iconcss)-1)+'{
  font-size: 30px;
  margin-right:10px;
 }
 '+isnull(@IconcssColor,'')+N'
  .tilte-oto .p-changepassword{color:white;padding:10px;font-size:25px;border-radius: 50%;}
 .birday .happy{
  color:red;
  transition: transform 2s;
 }
 .tilte-oto .ds-menu .col-md-3 {
    flex: 0 0 auto;
    width: 33%;
 }
 .page1 h5{margin:0px;}
 /*
 @keyframes abc {
  from{color:rgb(47, 0, 255)}
  to{color: rgb(255, 103, 2);}
 }
 */

 .tilte-oto tr>td,th{
  font-size: 20px;
  padding-bottom: 10px;
  padding-top: 0px;
  word-break: break-word;

 }
 .tilte-oto .birday tr>td,th{
  font-size: 20px;
  padding-bottom: 0px;
  padding-top: 0px;
  word-break: break-word;

 }
 .tilte-oto .ds-getform{
  padding:10px;
 }
 .tilte-oto tr>td p{
  font-size: 15px;
  padding-bottom: 20px;
  word-break: break-word;
 }

 .qt{
  font-weight: 500;
  font-size: 20px !important;
 }

 .tilte-oto .asend_home,.noti_home,.birday,.ds-menu,.menu2-moblie{
  padding-top:1%;
  /*padding-bottom:2%;*/

 }
 .asend_home span{
  font-size:10px;
 }

 .tilte-oto .page1,
 .tilte-oto .page2 {
 /*border-radius: 3px;
  background-color: #fff */
 }
 .tilte-oto .page2 {
 margin-left: 1%;
 }
 .tilte-oto .info_home ,
 .tilte-oto .noti_home .ds-getform,
.tilte-oto .asend_home .ds-getform,
.tilte-oto .grid-item {
  display: block;
  border-radius: 5px;
  background-color: #fff;
  margin-bottom: 8px;
  box-shadow: 0.05rem 0.125rem 0.25rem 0 rgba(0, 0, 0, 0.1),
	-0.05rem -0.125rem 0.25rem 0 rgba(0, 0, 0, 0.1);
  position: relative;
 }
 /*.tilte-oto .info_home:hover ,
 .tilte-oto .noti_home .ds-getform:hover,
.tilte-oto .asend_home .ds-getform:hover,
.tilte-oto .grid-item:hover
{
  background-color: #f4fbffba;
}*/
.tilte-oto .grid-item {
  width: 32.3333333%;
      margin: 0.5%;
}
.tilte-oto .menu2-moblie .grid-item {
          margin: 1%;
    width: 48%;
}
 .noti_home .link-noti,.LeaveCountToDay{
  padding-bottom:10px;
 }
 .noti_home .ds-getform .link-noti a{
  padding:10px;
 }
 .noti_home .ds-getform .LeaveCountToDay a{
  padding:10px;
  color:blue;
 }
 .ds-getform a{
  padding-top: 5px;
  padding-bottom: 5px;
 }
 .topimg{width:20%;}
  .tilte-oto .grid-container {
      display: flex;
    flex-wrap: wrap;
 }
 .tilte-oto .noti_home .ds-getform{
 background: '+(select color from tblColorChangePieChart where STT = 999)+N'
 }
 @media screen and (max-width: 1500px) and (min-width: 768px) {
  .tilte-oto .ds-menu .col-md-3 {
  flex: 0 0 auto;
  width: 50%;
 }
 }
 @media screen and (max-width: 768px) and (min-width: 270px) {
   .tilte-oto {
    display: contents;
   }
   .tilte-oto .menu2-moblie .col-md-3{
  width:50%;
 }
 .tilte-oto  .menu2-moblie a>p{
  padding-top:20px;
  font-size:15px;
 }
   .page1 {
    width: 100% !important;
   }
   .tilte-oto  .menu2-moblie .grid-container{
  display:flex;flex-wrap: wrap;
 }
 .tilte-oto  .statistics .grid-item {
  margin-bottom:3%;
 }
   .page2 {
    margin-left: 0px !important;
    width: 100% !important;
   }
   .page2 .info{
    padding:10px 20px 20px 20px;

   }
   .tilte-oto h4 {
    text-align: left;
    margin-top: 2% !important;
    border:0px;
   }

   .info_home {
    display: none;
  }

   .ds-menu {
    display: none;


 }
   .infologin .topimg{
    width:30%;
   }
   .infologin .topimg img{
    width:85px;
    height:85px;
   }
   .page1 .info2-moblie {
    display: block;
    padding:10px 20px 20px 20px;
   }

  .tilte-oto .menu2-moblie {
    display: block;
   }

  .tilte-oto .asend_home,
   .noti_home,
   .info_home,
   .birday,
  .info2-moblie,.menu2-moblie,.ds-menu{
    margin-bottom: 2%;

    /*margin-top:5%;*/
    padding-bottom: 2%;
  border-radius: 5px;
  margin-right: 0;
   }

   .tilte-oto tr>td,th{
    font-size: 16px ;
    /*padding-bottom: 20px;*/
    word-break: break-word;

   }

   .tilte-oto tr>td p{
    font-size: 15px;
    /*padding-bottom: 20px;*/
    word-break: break-word;

   }

   .tilte-oto a
   {
    text-decoration: none;
    font-size: 15px !important;
   }
   .dkLeave {
    text-align: center;
    background-color: #1e7e34;
    padding-top: 5px;
    padding-bottom: 5px;
    border-radius:5px;
   }
   .birday  span {
    font-size: 10px;
   }

   .tilte-oto .img-fluid {
    width: 50px;
    height: 50px;
   }
   .topif{ padding-left: 20px;}
  }
</style>
'



declare @info_home_Div nvarchar(max) =
'<div class="info_home" >
    <div class="infologin">
     <table style="width:100%">
     '+@QueryLogin_info+N'
     </table>
    </div>
    <div class="leave">
     <table style="width:100%">
      '+@QueryPerAndLeave+N'
     </table>
    </div>
    <div class="dkLeave" '+case when len(@QueryLinkRegis) <= 1  then 'style="display:none;"' else '' end +N'>
     '+@QueryLinkRegis+N'
    </div>
   </div>'

set @Query = N'
 <script>
  function HideTreeListEmployee() {
	if(window.drawerObj && window.drawerObj.option && window.drawerObj.option("opened") == true) {
		window.drawerObj.option("opened", false)
	}
  }
  window.onload = HideTreeListEmployee;
  setTimeout(function () {
    if(ParadiseOption.IdentifierForVendor == "412eeacc897845659279a636eb309d80"){
        apimobileAjax(
        {
            success: function (data) {
                if(data[0].text =="412eeacc897845659279a636eb309d80")
                {
                    apimobileAjax(
                    {
                        success: function (data) {
                            apimobileAjax2(
                            {
  success: function (data) {
                                console.log(data)
                            }},{
                            MethodName: "MobileApplicationKill",
                                prs:[]
                            })
                    }},{
                    MethodName: "MobileExecuteDataTable",
                        prs:["delete from tblDataCache where name = ''IdentifierForVendor''"]
                    })
                }
                else{
                    window.location = window.location.origin
                }
        }},{
        MethodName: "MobileExecuteDataTable",
            prs:["select * from tblDataCache where name = ''IdentifierForVendor''"]
        })
  }
 }, 1000)

 </script>

 <div class="tilte-oto">
  <div class="page1">'+case when @isWeb != 2 then '' else @info_home_Div end +'
   <div class="noti_home">
   <h4>'+case when @LanguageID = 'vn' then N'Thông báo' else 'Notification' end+N'</h4>
    <div class="ds-getform" '+case when @CountLeaveRegi <= 0 then N'style ="display:none;"' else '' end+N'>
     <div class="link-noti">
      <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.leave_assignmentlist_approve'')" >'+case when @LanguageID = 'vn' then N'Xin nghỉ: '+ cast(@CountLeaveRegi as varchar(3))+N' đơn cần duyệt ' else N'Leave: '+ cast(@CountLeaveRegi as varchar(3))+N' application need to approve' end+N'</a>
      <table style="width:100%;">
      '+@EmployeeLeave+N'
      </table>
     </div>
    </div>
	<div class="ds-getform" '+case when @CountNotiUnread <= 0 then N'style ="display:none;"' else '' end+N'>
     <div class="link-noti">
      <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.sp_showallnotificationuser'')" >'+case when @LanguageID = 'vn' then N''+ cast(@CountNotiUnread as varchar(3))+N' thông báo mới' else N''+ cast(@CountNotiUnread as varchar(3))+N' new notification(s)' end+N'</a>
      <table style="width:100%;">
      '+@EmployeeLeave+N'
      </table>
     </div>
    </div>
	<div class="ds-getform" '+case when @CoutDT <= 0 then N'style ="display:none;"' else '' end+N'>
		<div class="link-noti">
			<a href="#" onClick="window.OpenFormLink('''+@LinkDT+''')" >'+case when @LanguageID = 'vn' then N'Bạn có  '+
				cast(@CoutDT as varchar(3))+N' chương trình đào tạo cần làm ' else N'You have: '+ cast(@CoutDT as varchar(3))+N' training program to do ' end+N'</a>
			<table style="width:100%;">
				'+@QueryDT+N'
			</table>
		</div>
	</div>
    <div class="ds-getform" '+case when @CountOT <= 0 then N'style ="display:none;"' else '' end+N'>
     <div class="link-noti">
      <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.Overtime_AssignmentList_Approve'')" >'+case when @LanguageID = 'vn' then N'Tăng ca: '+ cast(@CountOT as varchar(3))+N' đơn cần duyệt ' else N'Overtime: '+ cast(@CountOT as varchar(3))+N' application need to approve' end+N'</a>
      <table style="width:100%;">
       '+@EmployeeOT+N'
      </table>
     </div>
    </div>
 <div class="ds-getform" '+case when @CountAttendance <= 0 then N'style ="display:none;"' else '' end+N'>'+@QueryEmpty+'
     <div class="link-noti">
    <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.sp_AttendanceConfirmRequest_PendingApprove'')" >'+case when @LanguageID = 'vn' then N'Xác nhận công: ' + cast(@CountAttendance as varchar(3))+N' đơn cần duyệt ' else N'Attendance: '+ cast(@CountAttendance as varchar(3))+N' application need to approve' end+N'</a>
      <table style="width:100%;">
       '+@EmployeeAttendance+N'
      </table>
     </div>
    </div>
 <div class="ds-getform" '+case when @CountMaternity <= 0 then N'style ="display:none;"' else '' end+N'>
     <div class="link-noti">
   <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.sp_MaternityConfirmRequest_PendingApprove'')" >'+case when @LanguageID = 'vn' then N'Thai sản: '+ cast(@CountMaternity as varchar(3))+N' đơn cần duyệt ' else N'Maternity: '+ cast(@CountMaternity as varchar(3))+N' application need to approve' end+N'</a>
      <table style="width:100%;">
       '+@EmployeeMaternity+N'
      </table>
     </div>
    </div>
 <div class="ds-getform" '+case when @CountShift <= 0 then N'style ="display:none;"' else '' end+N'>
     <div class="link-noti">
      <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.sp_ShiftConfirmRequest_PendingApprove'')" >'+case when @LanguageID = 'vn' then N'Ca làm việc: '+ cast(@CountShift as varchar(3))+N' đơn cần duyệt ' else N'Working shift: '+ cast(@CountShift as varchar(3))+N' application need to approve' end+N'</a>
      <table style="width:100%;">
       '+@EmployeeShift+N'
      </table>

     </div>

    </div>

	<div class="ds-getform" '+case when len(@LeaveCountToDay) <= 1 then N'style ="display:none;"' else '' end+N'>
			 <div class="LeaveCountToDay" >
				<a >'+case when @LanguageID = 'vn' then N'Số lượng nghỉ' else 'Number of leave' end+N'</a>
				 <table style ="width:100%">
				 '+isnull(@LeaveCountToDay,'')+N'
				 </table>
			   </div>
		</div>
	   </div>
	'+ @ContactCustomer+'
   <div class="asend_home" >
    '+@QueryAbsent+N'
   </div>
   <div class="ds-menu" >
    <h4 >'+case when @LanguageID = 'vn' then  N'Các menu của bạn' else 'Useful link' end+N'</h4>
  <div class="grid-container">
   '+isnull(@UsefulLinks,'')+'
   <div class="grid-item">
    <div class="ds-getform">
     <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.user_changepassword_loaddata'')" style="align-items:center;'+case when @isWeb = 1 then 'display:flex;' else '' end+N'">'+(select '<span class ="p-'+LOWER( m.glyphicon)+N'" style="font-size:30px;padding-right:10px;background-color:'+(select isnull(case when len(MenuColor) < 2 then '#0099ff' else MenuColor end,'#0099ff') from tblWorkFlow where CurrentMenuID = 'MnuSCR609')+';margin-right: 10px;"></span><p>'+ l.Content from tblMD_Message l inner join MEN_Menu m on m.MenuID = l.MessageID where m.MenuID = 'MnuSCR609' and l.Language = @LanguageID)+N'</p></a>
    </div>
   </div>
  </div>
   </div>
  </div>
  <div class="page2">

   '+case when @isWeb = 2 then  '' else @info_home_Div end+'
   <div class="menu2-moblie"  >
    <h4>'+case when @LanguageID = 'vn' then  N'Các menu của bạn' else 'Useful link' end+N'</h4>
<div class="grid-container">
   '+isnull(@UsefulLinks,'')+'
   <div class="grid-item">
    <div class="ds-getform">
     <a href="#" onClick="window.OpenFormLink(''Object=DataSetting.user_changepassword_loaddata'')" style="align-items:center;'+case when @isWeb = 1 then 'display:flex;' else '' end+N'">'+(select '<span class ="p-'+LOWER( m.glyphicon)+N'" style="font-size:30px;padding-right:10px;background-color:'+(select isnull(case when len(MenuColor) < 2 then '#0099ff' else MenuColor end,'#0099ff;') from tblWorkFlow where CurrentMenuID = 'MnuSCR609')+'"></span><p>'+ l.Content from tblMD_Message l inner join MEN_Menu m on m.MenuID = l.MessageID where m.MenuID = 'MnuSCR609' and l.Language = @LanguageID)+N'</p></a>
    </div>
   </div>
  </div>
 </div>


   <div class="birday" >
    <h4>'+case when @LanguageID = 'vn' then N'Danh sách sinh nhật' else 'Birthdays'end+N'</h4>
    <div class="GetDate">
     <p>'+case when @LanguageID = 'vn' then N'Hôm nay' else 'Today'end+N'<span class="p-'+@Icon+N'"></span></p>
  '+isnull(@QueryBirthday,'')+N'
    </div>
    <div class="GetMonth">
     <p>'+case when @LanguageID = 'vn' then N'Tuần này' else 'This week'  end+N'</p>
  '+@QueryBirthweek+N'
    </div>

   </div>
 </div>
</div>
'
select @CssCol+@Query as col1, '' as col2, '' as col3
print @Query

end
GO

IF OBJECT_ID('tempdb..#tblHtmlCache') IS NOT NULL DROP TABLE #tblHtmlCache

  create table #tblHtmlCache (
   [TableName] NVarChar(MAX) NULL 
 , [LanguageID] NVarChar(MAX) NULL 
 , [ScreenType] NVarChar(MAX) NULL 
 , [html] NVarChar(MAX) NULL 
 , [HtmlStatus] Int NULL 
 , [KNC] NVarChar(MAX) NULL 
 , [ConfigData] NVarChar(MAX) NULL 
 , [htmlJS] NVarChar(MAX) NULL 
 , [htmlJSLocal] NVarChar(MAX) NULL 
 , [htmlJSLocalServer] NVarChar(MAX) NULL 
)


 INSERT INTO #tblHtmlCache([TableName],[LanguageID],[ScreenType],[html],[HtmlStatus],[KNC],[ConfigData],[htmlJS],[htmlJSLocal],[htmlJSLocalServer])
Select  N'layoutbody' as [TableName],N'en' as [LanguageID],N'0' as [ScreenType],N'<script>
 if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
     window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
     window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
 }
 </script><script>
(async()=>{
    try {
        let b = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": [`delete from tblParameter where code like ''''debug'''';
INSERT INTO tblParameter ([Code], [Value]) select ''''Debug'''' [Code], ''''1'''' [Value];`],})
        console.log(b)
        let a = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": ["select Code, Value from tblParameter where code like ''''debug''''"],})
        console.log(a)
    } catch (error) {
    }
	if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
        window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
        window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
     }
})();
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.0/font/bootstrap-icons.min.css">

<style type="text/css"> 
	#RightMenu {display: none !important;}
	.BeginLoading {

            overflow: hidden;
            height: 100vh;
            background: linear-gradient(135deg, #e8f5e8, #f9f9f9, #e7f3e7);
            position: relative;
            color: #2e7d32;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999
        }

        .background-patternBeginLoading {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(76, 175, 80, 0.1) 0%, transparent 25%),
                radial-gradient(circle at 80% 70%, rgba(129, 199, 132, 0.08) 0%, transparent 30%),
                radial-gradient(circle at 50% 50%, rgba(102, 187, 106, 0.05) 0%, transparent 40%),
                linear-gradient(45deg, transparent 48%, rgba(255, 255, 255, 0.05) 50%, transparent 52%),
                linear-gradient(-45deg, transparent 48%, rgba(255, 255, 255, 0.03) 50%, transparent 52%);
            background-size: 300px 300px, 400px 400px, 500px 500px, 60px 60px, 60px 60px;
            animation: backgroundMoveBeginLoading 20s ease-in-out infinite;
            z-index: 1;
        }

        .geometric-shapesBeginLoading {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .shapeBeginLoading {
            position: absolute;
            opacity: 0.1;
            animation: floatBeginLoading 15s ease-in-out infinite;
        }

        .shape-1BeginLoading {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #4caf50, #81c784);
            border-radius: 20px;
            top: 15%;
            left: 10%;
            animation-delay: 0s;
            transform: rotate(45deg);
        }

        .shape-2BeginLoading {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #66bb6a, #a5d6a7);
            border-radius: 50%;
            top: 25%;
            right: 15%;
            animation-delay: -3s;
        }

        .shape-3BeginLoading {
            width: 100px;
            height: 100px;
            background: linear-gradient(90deg, #81c784, #c8e6c9);
            border-radius: 30px;
            bottom: 20%;
            left: 5%;
            animation-delay: -6s;
            transform: rotate(30deg);
        }

        .shape-4BeginLoading {
            width: 70px;
            height: 70px;
            background: linear-gradient(180deg, #4caf50, #66bb6a);
            clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
            bottom: 30%;
            right: 20%;
            animation-delay: -9s;
        }

        .shape-5BeginLoading {
            width: 90px;
            height: 90px;
            background: linear-gradient(225deg, #81c784, #a5d6a7);
            border-radius: 50% 0 50% 0;
            top: 60%;
            left: 20%;
            animation-delay: -12s;
        }

        .loading-containerBeginLoading {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 90%;
            max-width: 400px;
            padding: 30px 20px 20px;
        }

        .logoBeginLoading {
            text-align: center;
            margin-bottom: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-iconBeginLoading {
            width: 250px;
           margin-bottom: 15px;
        }

        .logoBeginLoading h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: -0.5px;
        }

        .logoBeginLoading p {
            font-size: 1rem;
          opacity: 0.9;
            font-weight: 400;
            line-height: 1.4;
            color: #2e7d32;
        }

        .featuresBeginLoading {
            width: 100%;
            margin: 20px 0 30px;
        }

        .feature-itemBeginLoading {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid rgba(46, 125, 50, 0.2);
            opacity: 1;
        }

        .feature-itemBeginLoading:last-child {
            border-bottom: none;
        }

        /*.feature-itemBeginLoading:nth-child(1) { animation-delay: 0.3s; }
        .feature-itemBeginLoading:nth-child(2) { animation-delay: 0.5s; }
        .feature-itemBeginLoading:nth-child(3) { animation-delay: 0.7s; }
        .feature-itemBeginLoading:nth-child(4) { animation-delay: 0.9s; }*/

        .feature-itemBeginLoading i {
            font-size: 1.5rem;
            color: #4caf50;
            margin-right: 16px;
            width: 30px;
            text-align: center;
        }

        .feature-itemBeginLoading span {
            font-size: 1rem;
            line-height: 1.4;
            color: #2e7d32;
        }

        .copyrightBeginLoading {
            margin-top: 20px;
            text-align: center;
            font-size: 0.85rem;
            color: #2e7d32;
            opacity: 0.8;
            padding-top: 15px;
            border-top: 1px solid rgba(46, 125, 50, 0.2);
        }

        .copyrightBeginLoading .company-nameBeginLoading {
            font-weight: 600;
            color: #1b5e20;
        }

        .loading-textBeginLoading {
            margin-top: 20px;
            font-size: 1rem;
            opacity: 0.8;
            display: flex;
            align-items: center;
            color: #2e7d32;
        }

        .loading-dotsBeginLoading {
            display: inline-block;
            width: 20px;
            text-align: left;
        }

        .loading-dotsBeginLoading::after {
            content: '''';
            animation: dotsBeginLoading 1.5s infinite;
        }

        @keyframes dotsBeginLoading {
            0%, 20% { content: ''.''; }
            40% { content: ''..''; }
            60%, 100% { content: ''...''; }
        }

        @keyframes fadeInBeginLoading {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInBeginLoading {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes backgroundMoveBeginLoading {
            0%, 100% {
                background-position: 0% 0%, 0% 0%, 0% 0%, 0% 0%, 0% 0%;
            }
            50% {
                background-position: 100% 100%, 100% 100%, 100% 100%, 30px 30px, -30px 30px;
            }
        }

        @keyframes floatBeginLoading {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }
            33% {
                transform: translateY(-20px) rotate(120deg);
            }
            66% {
                transform: translateY(10px) rotate(240deg);
            }
        }

        .decorative-elementBeginLoading {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(76, 175, 80, 0.08) 0%, transparent 70%);
            z-index: 1;
        }

        .decorative-elementBeginLoading:nth-child(1) {
            width: 150px;
            height: 150px;
            top: -50px;
            right: -50px;
            animation: floatBeginLoading 12s ease-in-out infinite;
        }

        .decorative-elementBeginLoading:nth-child(2) {
            width: 200px;
            height: 200px;
            bottom: -80px;
            left: -80px;
            animation: floatBeginLoading 15s ease-in-out infinite reverse;
        }
</style>


<script>

</script>
<div class="BeginLoading">
    <div class="background-patternBeginLoading"></div>
    <div class="geometric-shapesBeginLoading">
        <div class="shapeBeginLoading shape-1BeginLoading"></div>
        <div class="shapeBeginLoading shape-2BeginLoading"></div>
        <div class="shapeBeginLoading shape-3BeginLoading"></div>
        <div class="shapeBeginLoading shape-4BeginLoading"></div>
        <div class="shapeBeginLoading shape-5BeginLoading"></div>
    </div>
    <div class="decorative-elementBeginLoading"></div>
    <div class="decorative-elementBeginLoading"></div>

    <div class="loading-containerBeginLoading">
        <div class="logoBeginLoading">
            <img src="https://cdn.paradisehrm.com/Image/BackgroundMobile/paradiselogomain.jpg" onerror="this.onerror=null;this.src=''/CDN/Image/BackgroundMobile/paradiselogomain.jpg'';"
                alt="ParadiseHRM" class="logo-iconBeginLoading">
            <p>Giải pháp hiệu quả cho doanh nghiệp</p>
        </div>
		
		<div class="spinner-border" role="status" style="
			width: 4rem;
			aspect-ratio: 1;
			height: unset;
		">
			<span class="visually-hidden">Loading...</span>
		</div>

        <div class="featuresBeginLoading">
            <div class="feature-itemBeginLoading">
                <i class="fas fa-clock"></i>
                <span>Track attendance anywhere, on any device.</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-calculator"></i>
                <span>Accurate automated payroll</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-chart-line"></i>
                <span>Smart HR Insights. Smarter Decisions</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-shield-alt"></i>
                <span>Advanced data security</span>
            </div>
        </div>

        <div class="copyrightBeginLoading">
            © 2025 <span class="company-nameBeginLoading">Vietinsoft Co. Ltd</span><br>
            All rights reserved
        </div>
    </div>
</div>
<div id="appapp" style="width:100%;">
        <div id="drawer">
	<script>
				function ShowWaitingPanel(){
					$(".BeginLoading").show();
				}
				function HideWaitingPanel(){
					$(".BeginLoading").hide();
					document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
				}
								
				document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
			    
            </script>
			<script>
				function createTextboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDateboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDateBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDateBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createTextAreaControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextArea(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextArea("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createCheckboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxCheckBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxCheckBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRadioGroupControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxRadioGroup(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxRadioGroup("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createNumberboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxNumberBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxNumberBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createColorBoxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxColorBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxColorBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureEditControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					config.visible = false;
					div[0].option = config;
					let img = $("<img>").addClass("img-fluid");
					if (config.value) img.attr("src", "data:image/jpg;base64," + config.value);
					let fileUpload = $("<div>");
					div.addClass("p-2").append(img, fileUpload);
					config.value = null;
					fileUpload.dxFileUploader({
						dialogTrigger: div,
						dropZone: div,
						...div[0].option,
					});

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureBoxControl(div, config, paramsControl, optionsControl) {
					let img = $("<img>").addClass("img-fluid");
					div.addClass("p-2").append(img);
					return div;
				}

				function createFileButtonControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					let fileUpload = $("<div>");
					let fileButton = $("<div>").dxButton({
						...config,
						onInitialized: function (arg) {
							if (config.ControlBackColor)
								arg.element.css("background-color", config.ControlBackColor);
							if (config.ControlForeColor)
								arg.element.css("color", config.ControlForeColor);
						},
					});

					fileUpload.dxFileUploader({
						...config,
						buttonInstance: fileButton.dxButton("instance"),
						accept: "*",
						dialogTrigger: fileButton,
						multiple: false,
						visible: false,
					});
					div.append(fileButton, fileUpload);

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownButtonControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownButton(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							div.dxDropDownButton("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDropDownBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createGridControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div[0].option.onCellClick = function (e) { };
					div.dxDataGrid(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDataGrid("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createListControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxList(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxList("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPDFViewerControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var viewer = new ej.pdfviewer.PdfViewer({
						documentPath:
							"https://cdn.syncfusion.com/Content/pdf/pdf-succinctly.pdf",
						resourceUrl:
							"https://cdn.syncfusion.com/ej2/23.2.6/dist/ej2-pdfviewer-lib",
					});
					viewer.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = viewer;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRichTextControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl = "https://services.syncfusion.com/js/production/";
					var defaultRTE = new ej.richtexteditor.RichTextEditor({
						toolbarSettings: {
							items: [
								"Undo",
								"Redo",
								"|",
								"ImportWord",
								"ExportWord",
								"ExportPdf",
								"|",
								"Bold",
								"Italic",
								"Underline",
								"StrikeThrough",
								"InlineCode",
								"SuperScript",
								"SubScript",
								"|",
								"FontName",
								"FontSize",
								"FontColor",
								"BackgroundColor",
								"|",
								"LowerCase",
								"UpperCase",
								"|",
								"Formats",
								"Alignments",
								"Blockquote",
								"|",
								"NumberFormatList",
								"BulletFormatList",
								"|",
								"Outdent",
								"Indent",
								"|",
								"CreateLink",
								"Image",
								"FileManager",
								"Video",
								"Audio",
								"CreateTable",
								"|",
								"FormatPainter",
								"ClearFormat",
								"|",
								"EmojiPicker",
								"Print",
								"|",
								"SourceCode",
								"FullScreen",
							],
						},
						slashMenuSettings: {
							enable: true,
							items: [
								"Paragraph",
								"Heading 1",
								"Heading 2",
								"Heading 3",
								"Heading 4",
								"OrderedList",
								"UnorderedList",
								"CodeBlock",
								"Blockquote",
								"Link",
								"Image",
								"Video",
								"Audio",
								"Table",
								"Emojipicker",
							],
						},
						insertImageSettings: {
							saveUrl: hostUrl + "api/RichTextEditor/SaveFile",
							removeUrl: hostUrl + "api/RichTextEditor/DeleteFile",
							path: hostUrl + "RichTextEditor/",
						},
						importWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ImportFromWord",
						},
						exportWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ExportToDocx",
							fileName: "RichTextEditor.docx",
							stylesheet: `
					.e-rte-content {
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						exportPdf: {
							serviceUrl:
								"https://ej2services.syncfusion.com/js/development/api/RichTextEditor/ExportToPdf",
							fileName: "RichTextEditor.pdf",
							stylesheet: `
					.e-rte-content{
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						fileManagerSettings: {
							enable: true,
							path: "/Pictures/Food",
							ajaxSettings: {
								url: "https://ej2-aspcore-service.azurewebsites.net/api/FileManager/FileOperations",
								getImageUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/GetImage",
								uploadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Upload",
								downloadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Download",
							},
						},
						quickToolbarSettings: {
							table: [
								"TableHeader",
								"TableRows",
								"TableColumns",
								"TableCell",
								"-",
								"BackgroundColor",
								"TableRemove",
								"TableCellVerticalAlign",
								"Styles",
							],
							showOnRightClick: true,
						},
						enableXhtml: true,
						showCharCount: true,
						enableTabKey: true,
						placeholder: "Type something or use @ to tag a user...",
						option: function(name, value) {
							if (typeof value === "undefined") return this[name];

							if(this[name] === value) return;

							this[name] = value;
						},
						...config
					});
					defaultRTE.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = defaultRTE;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createBarCodeControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var barcode = new ej.barcodegenerator.QRCodeGenerator({
						width: config.width,
						height: config.height,
						mode: "SVG",
						type: config.BarCodeType,
						displayText: { visibility: false },
						value: "",
					});
					barcode.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = barcode;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function CreateHTMLControl(div, config, paramsControl, optionsControl) {
					let html = $(config.value);
					return html;
				}

				function CreateHyperLinkControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					if (config.onInitialized) config.onInitialized(config);
					div[0].option = config;
					div[0].option.element = div;
					div.append(
						$("<a>")
							.attr("href", "#")
							.text(config.Message)
							.on("click", (event) => {
								event.preventDefault();
								config.openFormAction(
									paramsControl[config.ControlNameParam].value
								);
							})
					);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div[0].option;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function onGridViewCellClick(t) {
					let s = t.cellElement;
					let config = { ...t.column };
					config.value = t.value;
					s.html(
						window[t.column.CreateControlFunction]
							? window[t.column.CreateControlFunction](null, config)
							: t.displayValue
					);
				}

				function convertSqlToJsCondition(sqlCondition, objectName) {
					sqlCondition = sqlCondition
						.replace(/LIKE\s+''%([^%]+)%''/gi, ''.includes("$1")'') // Contains
						.replace(/LIKE\s+''%([^%]+)''/gi, ''.endsWith("$1")'') // Ends with
						.replace(/LIKE\s+''([^%]+)%''/gi, ''.startsWith("$1")''); // Starts with

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+IN\s+\(([^)]+)\)/gi,
						(match, field, values) => {
							const jsValues = values.split(",").map((v) => v.trim());
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `[${jsValues.join(", ")}].includes(${field})`;
						}
					);

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+BETWEEN\s+([\w\d\.\-]+)\s+AND\s+([\w\d\.\-]+)/gi,
						(match, field, start, end) => {
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `(${field} >= ${start} && ${field} <= ${end})`;
						}
					);

					if (objectName) {
						sqlCondition = sqlCondition.replace(
							/\[([\w]+)\]/g,
							`${objectName}["$1"]`
						);
					} else {
						sqlCondition = sqlCondition.replace(/\[([\w]+)\]/g, "$1");
					}

					return sqlCondition
						.replace(/=/g, "==") // Replace "=" with "=="
						.replace(/(>|<)==/g, "$1=") // Replace ">|<==" with ">|<="
						.replace(/is not null/gi, "!== null") // Convert "is not null"
						.replace(/is null/gi, "=== null") // Convert "is null"
						.replace(/\band\b/gi, "&&") // Convert "And" to "&&"
						.replace(/\bor\b/gi, "||") // Convert "Or" to "||"
						.replace(/<>/g, "!="); // Replace "<>" with "!="
				}

				function evaluateCondition(condition, context = {}) {
					try {
						const func = new Function(
							...Object.keys(context),
							`return ${condition};`
						);
						return func(...Object.values(context));
					} catch (error) {
						console.error(condition);
						console.error("Error evaluating condition:", error);
						return false;
					}
				}

				function ParseDefineAction(str) {
					let parts = str.split("|");
					let result = {};
					parts
						.filter((x) => x)
						.forEach((item) => {
							if ((item.match(/=/g) || []).length > 1) {
								let [tmpKey, tmpValue] = item.split(/=(.*)/s);
								tmpValue = tmpValue.split("&");
								let tmpValue1 = {};

								if (tmpValue[0] && tmpValue[0].startsWith("?ExportName")) {
									tmpValue1.OnExportParams = {};
									tmpValue[0] = tmpValue[0].replace(
										"?ExportName",
										"ExportName"
									);
									tmpValue.forEach((tmpItem) => {
										let [key, ...rest] = tmpItem.split("=");
										if (rest.length > 1) {
											let tmpValue2 = [];
											rest.join("=")
												.split("_")
												.forEach((tmpItem1) => {
													let [key, value] = tmpItem1.split("=");
													tmpValue2.push(key);
													tmpValue2.push(value);
												});

											tmpValue1.OnExportParams[key.replace("@", "")] =
												tmpValue2;
										} else
											tmpValue1.OnExportParams[key.replace("@", "")] =
												rest.join("=");
									});
								} else
									tmpValue.forEach((tmpItem) => {
										let [key, value] = tmpItem.split("=");
										tmpValue1[key.replace("@", "")] = value;
									});
								result[tmpKey.replace("@", "")] = tmpValue1;
							} else {
								let [key, value] = item.split("=");
								if (key == "Object" && value && value.includes(".")) {
									let tmpValue1 = {};
									value = value.split(".");
									tmpValue1.ActionDefineType = value[0];
									tmpValue1.ClassName = value[1];
									value = tmpValue1;
								}

								result[key.replace("@", "")] = value;
							}
						});
					return result;
				}

				function convertToHTML(inputString) {
					inputString = inputString.replace(/<color=(.*?)>/gi, (match, color) => {
						const validColor = isValidCSSColor(color)
							? color
							: convertRGBToHex(color);
						return `<span style="color: ${validColor};">`;
					});
					inputString = inputString.replace(/<\/color>/gi, "</span>");

					// inputString = inputString.replace(/<size=\+(\d+)>/gi, (match, p1) => `<span style="font-size: ${parseInt(p1) + windowFontSize}px;">`);
					// inputString = inputString.replace(/<size=-(\d+)>/gi, (match, p1) => `<span style="font-size: ${windowFontSize - parseInt(p1)}px;">`);
					// inputString = inputString.replace(/<size=(\d+)>/gi, (match, size) => `<span style="font-size: ${size}px;">`);
					inputString = inputString.replace(
						/<size=([+-]?\d+|{[\d]+}|[\d]+[a-z%]*)>/gi,
						(match, size) => {
							const parsedSize = parseSize(size);
							return `<span style="font-size: ${parsedSize};">`;
						}
					);
					inputString = inputString.replace(/<\/size>/gi, "</span>");

					inputString = inputString.replace(
						/<href=(.*?)>(.*?)<\/href>/g,
						''<a href="$1" target="_blank">$2</a>''
					);

					inputString = inputString.replace(/<br>/g, "<br/>");

					inputString = inputString.replace(/<b>/gi, "<strong>");
					inputString = inputString.replace(/<\/b>/gi, "</strong>");

					inputString = inputString.replace(
						/<u>/gi,
						''<span style="text-decoration: underline;">''
					);
					inputString = inputString.replace(/<\/u>/gi, "</span>");

					return inputString;
				}

				function convertRGBToHex(rgb) {
					let rgbArray = rgb.split(",").map((num) => parseInt(num.trim()));
					if (rgbArray.length === 3) {
						return `#${rgbArray
							.map((num) => num.toString(16).padStart(2, "0"))
							.join("")}`;
					}
					return rgb;
				}

				function isValidCSSColor(color) {
					let s = new Option().style;
					s.color = color;
					return s.color !== "";
				}

				function parseSize(size) {
					if (size.startsWith("{") && size.endsWith("}")) {
						return `${size.slice(1, -1)}px`;
					} else if (/^\d+x$/.test(size)) {
						return `${parseInt(size)}em`;
					} else if (/^[+-]?\d+$/.test(size)) {
						let baseFontSize = parseInt(
							window.getComputedStyle(document.documentElement).fontSize,
							10
						);
						let sizeAdjustment = parseInt(size);
						let newSize = baseFontSize + sizeAdjustment;
						return `${newSize}px`;
					} else if (/^\d+$/.test(size)) {
						return `${size}px`;
					}
					return size;
				}

				function runSPActionFunction(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					AjaxHPAParadiseParadise({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				async function runSPActionFunctionAsync(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					await AjaxHPAParadiseParadiseAsync({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				function showPopupNotify(
					title,
					content,
					btnOKText = "OK",
					popupWidth = "15vw",
					closePopupFunction = () => { }
				) {
					var myDialog = DevExpress.ui.dialog.custom({
						title: title,
						messageHtml: `<div style="width: ${popupWidth}">${content}</div>`,
						buttons: [
							{
								text: btnOKText,
								onClick: function (e) {
									return true;
								},
							},
						],
					});
					myDialog.show().done(function () {
						closePopupFunction();
					});
				}

				function decodeHtmlEntities(str) {
					const txt = document.createElement("textarea");
					txt.innerHTML = str;
					return txt.value;
				}

				function copyViaExcelExport(
					gridInstance,
					isSelectedRowsOnly = false,
					copyWithHeader = false,
					loadPanelmessage = "Copying"
				) {
					let workbook = new ExcelJS.Workbook();
					let sheet = workbook.addWorksheet("dummy");
					let str = "";

					let col = gridInstance.getVisibleColumns();
					col = col.filter((x) => x.dataField !== undefined && x.allowExporting);
					let lastColumn = col[col.length - 1].dataField;

					DevExpress.excelExporter
						.exportDataGrid({
							component: gridInstance,
							worksheet: sheet,
							selectedRowsOnly: isSelectedRowsOnly,
							loadPanel: {
								showPane: false,
								message: loadPanelmessage,
							},
							customizeCell: function (options) {
								let { gridCell } = options;
								let field = gridCell.column.dataField;

								switch (gridCell.rowType) {
									case "header" && copyWithHeader:
										str += `${gridCell.column.caption}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "data":
										if (gridCell.column.dropdownSource) {
											gridCell.value =
												gridCell.column.dropdownSource.find(
													(x) =>
														x[gridCell.column.keyExpr] ==
														gridCell.data[gridCell.column.dataField]
												)?.[gridCell.column.displayExpr] ??
												(gridCell.value ? gridCell.value : "");
										} else if (
											gridCell.column.CreateControlFunction ==
											"createCheckboxControl"
										) {
											gridCell.value = gridCell.value
												? String.fromCharCode(parseInt("2713", 16))
												: "";
										} else if (
											gridCell.column.CreateControlFunction ==
											"createDateboxControl"
										) {
											gridCell.value = DevExpress.localization.formatDate(
												gridCell.value,
												gridCell.column.displayFormat
											);
										} else {
											gridCell.value =
												gridCell.data[gridCell.column.dataField];
										}

										str += `${gridCell.value ?? ""}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}

										break;
									case "group":
										if (gridCell.value) str += `${gridCell.value} `;

										if (
											gridCell.groupSummaryItems !== undefined &&
											gridCell.groupSummaryItems.length >= 1
										) {
											gridCell.groupSummaryItems.forEach((x) => {
												str += ` ${x.name}: ${x.value} `;
											});
										}

										str += `\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "groupFooter":
										break;
									case "totalFooter":
										break;
									default:
										break;
								}
							},
						})
						.then(() => {
							navigator.clipboard.writeText(str).then(
								() => { },
								() => { }
							);
						});
				}
				function GetFormatDate(date, format = "yyyy-MM-dd HH:mm:ss") {
					return DevExpress.localization.formatDate(new Date(date), format);
				}
				if (!Object.filter)
					Object.filter = (obj, predicate) =>
						Object.keys(obj)
							.filter((key) => predicate(obj[key], key))
							.reduce((res, key) => ((res[key] = obj[key]), res), {});
				
				if (!Object.findValue)
					Object.findValue = function (obj, key) {
						if (!obj) return undefined;
						let match = Object.keys(obj).find(k => k.toLowerCase() === key.toLowerCase());
						return match ? obj[match] : undefined;
					};

				function getArrayTypeDistinct(arr) {
					return [...new Set(arr.map((x) => typeof x))];
				}

				function createConditionQuery(filter, schema, comboBoxColumn) {
					let condition = ``;
					if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						["=", "<", ">"].includes(filter[1])
					) {
						if (filter[2] == null) {
							filter[0] = `ISNULL(${filter[0]} , '''')`;
							filter[2] = "''''";
						} else if (typeof filter[2] == "object") {
							filter[2] = "''" + filter[2].toISOString() + "''";
						} else if (typeof filter[2] == "number") {
							filter[2] = "''" + filter[2].toString() + "''";
						}
					} else if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						Array.isArray(filter[2]) &&
						filter[2].length == 0
					) {
						filter.pop();
						filter.pop();
					}

					filter.forEach((item) => {
						let typeList = Array.isArray(item) ? getArrayTypeDistinct(item) : [];
						if (
							(Array.isArray(item) && typeList.length > 1) ||
							(Array.isArray(item) &&
								typeList.length == 1 &&
								typeList[0] == "object")
						) {
							condition += `(${createConditionQuery(
								item,
								schema,
								comboBoxColumn
							)})`;
						} else if (Array.isArray(item) && typeList.length == 1) {
							condition += `${item[0]}`;
							if (
								schema &&
								schema.find((x) => x.name == item[0]).type == "System.String"
							)
								condition += " COLLATE Latin1_General_CI_AI";
							if (comboBoxColumn && comboBoxColumn.includes(item[0]))
								condition += ` like N''${item[2]}''`;
							else
								condition += `${
									item[1] == "contains"
										? ` like N''%${item[2]}%''`
										: ` = N''${item[2]}''`
								}`;
						} else
							condition +=
								" " +
								(item == null
									? "NULL"
									: item.toLocaleString().toLocaleUpperCase()) +
								" ";
					});

					return condition;
				}

				function createParamString(param) {
					let paramString = "";
					for (let index = 0; index < param.length; index += 2) {
						if (index > 0) paramString += ", ";
						paramString += `${param[index]} = N''''${param[index + 1]}''''`;
					}
					return paramString;
				}

				function transformDateToHierarchy(data) {
					let result = [],
						col0Map = new Map();

					data.forEach(({ col0, col1, col2, col3, col4, col5, totalCount }) => {
						if (!col0Map.has(col0)) {
							let col0Obj = { key: col0, items: [] };
							col0Map.set(col0, col0Obj);
							result.push(col0Obj);
						}

						if (!col1) return;

						let col0Obj = col0Map.get(col0),
							col1Map = col0Obj._col1Map || new Map();

						if (!col1Map.has(col1)) {
							let col1Obj = { key: col1, items: [] };
							if (col2) col1Obj.count = totalCount;
							col1Map.set(col1, col1Obj);
							col0Obj.items.push(col1Obj);
						}

						col0Obj._col1Map = col1Map;

						if (!col2) return;

						let col1Obj = col1Map.get(col1),
							col2Map = col1Obj._col2Map || new Map();

						if (!col2Map.has(col2)) {
							let col2Obj = { key: col2, items: [] };
							if (col3) col1Obj.count = totalCount;
							col2Map.set(col2, col2Obj);
							col1Obj.items.push(col2Obj);
						}

						col1Obj._col2Map = col2Map;

						if (!col3) return;

						let col2Obj = col2Map.get(col2),
							col3Map = col2Obj._col3Map || new Map();

						if (!col3Map.has(col3)) {
							let col3Obj = { key: col3, items: [] };
							if (col4) col2Obj.count = totalCount;
							col3Map.set(col3, col3Obj);
							col2Obj.items.push(col3Obj);
						}

						col2Obj._col3Map = col3Map;

						if (!col4) return;

						let col3Obj = col3Map.get(col3),
							col4Map = col3Obj._col4Map || new Map();

						if (!col4Map.has(col4)) {
							let col4Obj = { key: col4, items: [] };
							if (col5) col3Obj.count = totalCount;
							col4Map.set(col4, col4Obj);

							col3Obj.items.push(col4Obj);
						}

						col3Obj._col4Map = col4Map;

						if (col5 != undefined) {
							let col4Obj = col4Map.get(col4);
							col4Obj.items.push({
								key: col5,
								items: null,
								count: totalCount,
							});
						}
					});

					return result;
				};

			</script>
            <div id="main-layout-diagram" style="overflow-x:hidden; overflow-y:auto; display:block">' as [html],NULL as [HtmlStatus],N'A96' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbody' as [TableName],N'en' as [LanguageID],N'1' as [ScreenType],N'<script>
(async()=>{
    try {
        let b = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": [`delete from tblParameter where code like ''''debug'''';
INSERT INTO tblParameter ([Code], [Value]) select ''''Debug'''' [Code], ''''1'''' [Value];`],})
        console.log(b)
        let a = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": ["select Code, Value from tblParameter where code like ''''debug''''"],})
        console.log(a)
    } catch (error) {
    }
	if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
        window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
        window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
     }
})();
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.0/font/bootstrap-icons.min.css">

<style type="text/css"> 
	#RightMenu {display: none !important;}
	.BeginLoading {

            overflow: hidden;
            height: 100vh;
            background: linear-gradient(135deg, #e8f5e8, #f9f9f9, #e7f3e7);
            position: relative;
            color: #2e7d32;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999
        }

        .background-patternBeginLoading {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(76, 175, 80, 0.1) 0%, transparent 25%),
                radial-gradient(circle at 80% 70%, rgba(129, 199, 132, 0.08) 0%, transparent 30%),
                radial-gradient(circle at 50% 50%, rgba(102, 187, 106, 0.05) 0%, transparent 40%),
                linear-gradient(45deg, transparent 48%, rgba(255, 255, 255, 0.05) 50%, transparent 52%),
                linear-gradient(-45deg, transparent 48%, rgba(255, 255, 255, 0.03) 50%, transparent 52%);
            background-size: 300px 300px, 400px 400px, 500px 500px, 60px 60px, 60px 60px;
            animation: backgroundMoveBeginLoading 20s ease-in-out infinite;
            z-index: 1;
        }

        .geometric-shapesBeginLoading {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .shapeBeginLoading {
            position: absolute;
            opacity: 0.1;
            animation: floatBeginLoading 15s ease-in-out infinite;
        }

        .shape-1BeginLoading {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #4caf50, #81c784);
            border-radius: 20px;
            top: 15%;
            left: 10%;
            animation-delay: 0s;
            transform: rotate(45deg);
        }

        .shape-2BeginLoading {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #66bb6a, #a5d6a7);
            border-radius: 50%;
            top: 25%;
            right: 15%;
            animation-delay: -3s;
        }

        .shape-3BeginLoading {
            width: 100px;
            height: 100px;
            background: linear-gradient(90deg, #81c784, #c8e6c9);
            border-radius: 30px;
            bottom: 20%;
            left: 5%;
            animation-delay: -6s;
            transform: rotate(30deg);
        }

        .shape-4BeginLoading {
            width: 70px;
            height: 70px;
            background: linear-gradient(180deg, #4caf50, #66bb6a);
            clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
            bottom: 30%;
            right: 20%;
            animation-delay: -9s;
        }

        .shape-5BeginLoading {
            width: 90px;
            height: 90px;
            background: linear-gradient(225deg, #81c784, #a5d6a7);
            border-radius: 50% 0 50% 0;
            top: 60%;
            left: 20%;
            animation-delay: -12s;
        }

        .loading-containerBeginLoading {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 90%;
            max-width: 400px;
            padding: 30px 20px 20px;
        }

        .logoBeginLoading {
            text-align: center;
            margin-bottom: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-iconBeginLoading {
            width: 250px;
           margin-bottom: 15px;
        }

        .logoBeginLoading h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: -0.5px;
        }

        .logoBeginLoading p {
            font-size: 1rem;
          opacity: 0.9;
            font-weight: 400;
            line-height: 1.4;
            color: #2e7d32;
        }

        .featuresBeginLoading {
            width: 100%;
            margin: 20px 0 30px;
        }

        .feature-itemBeginLoading {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid rgba(46, 125, 50, 0.2);
            opacity: 1;
        }

        .feature-itemBeginLoading:last-child {
            border-bottom: none;
        }

        /*.feature-itemBeginLoading:nth-child(1) { animation-delay: 0.3s; }
        .feature-itemBeginLoading:nth-child(2) { animation-delay: 0.5s; }
        .feature-itemBeginLoading:nth-child(3) { animation-delay: 0.7s; }
        .feature-itemBeginLoading:nth-child(4) { animation-delay: 0.9s; }*/

        .feature-itemBeginLoading i {
            font-size: 1.5rem;
            color: #4caf50;
            margin-right: 16px;
            width: 30px;
            text-align: center;
        }

        .feature-itemBeginLoading span {
            font-size: 1rem;
            line-height: 1.4;
            color: #2e7d32;
        }

        .copyrightBeginLoading {
            margin-top: 20px;
            text-align: center;
            font-size: 0.85rem;
            color: #2e7d32;
            opacity: 0.8;
            padding-top: 15px;
            border-top: 1px solid rgba(46, 125, 50, 0.2);
        }

        .copyrightBeginLoading .company-nameBeginLoading {
            font-weight: 600;
            color: #1b5e20;
        }

        .loading-textBeginLoading {
            margin-top: 20px;
            font-size: 1rem;
            opacity: 0.8;
            display: flex;
            align-items: center;
            color: #2e7d32;
        }

        .loading-dotsBeginLoading {
            display: inline-block;
            width: 20px;
            text-align: left;
        }

        .loading-dotsBeginLoading::after {
            content: '';
            animation: dotsBeginLoading 1.5s infinite;
        }

        @keyframes dotsBeginLoading {
            0%, 20% { content: ''.''; }
            40% { content: ''..''; }
            60%, 100% { content: ''...''; }
        }

        @keyframes fadeInBeginLoading {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInBeginLoading {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes backgroundMoveBeginLoading {
            0%, 100% {
                background-position: 0% 0%, 0% 0%, 0% 0%, 0% 0%, 0% 0%;
            }
            50% {
                background-position: 100% 100%, 100% 100%, 100% 100%, 30px 30px, -30px 30px;
            }
        }

        @keyframes floatBeginLoading {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }
            33% {
                transform: translateY(-20px) rotate(120deg);
            }
            66% {
                transform: translateY(10px) rotate(240deg);
            }
        }

        .decorative-elementBeginLoading {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(76, 175, 80, 0.08) 0%, transparent 70%);
            z-index: 1;
        }

        .decorative-elementBeginLoading:nth-child(1) {
            width: 150px;
            height: 150px;
            top: -50px;
            right: -50px;
            animation: floatBeginLoading 12s ease-in-out infinite;
        }

        .decorative-elementBeginLoading:nth-child(2) {
            width: 200px;
            height: 200px;
            bottom: -80px;
            left: -80px;
            animation: floatBeginLoading 15s ease-in-out infinite reverse;
        }
</style>


<script>

</script>
<div class="BeginLoading">
    <div class="background-patternBeginLoading"></div>
    <div class="geometric-shapesBeginLoading">
        <div class="shapeBeginLoading shape-1BeginLoading"></div>
        <div class="shapeBeginLoading shape-2BeginLoading"></div>
        <div class="shapeBeginLoading shape-3BeginLoading"></div>
        <div class="shapeBeginLoading shape-4BeginLoading"></div>
        <div class="shapeBeginLoading shape-5BeginLoading"></div>
    </div>
    <div class="decorative-elementBeginLoading"></div>
    <div class="decorative-elementBeginLoading"></div>

    <div class="loading-containerBeginLoading">
        <div class="logoBeginLoading">
            <img src="https://cdn.paradisehrm.com/Image/BackgroundMobile/paradiselogomain.jpg" onerror="this.onerror=null;this.src=''/CDN/Image/BackgroundMobile/paradiselogomain.jpg'';
                alt="ParadiseHRM" class="logo-iconBeginLoading">
            <p>Giải pháp hiệu quả cho doanh nghiệp</p>
        </div>
		
		<div class="spinner-border" role="status" style="
			width: 4rem;
			aspect-ratio: 1;
			height: unset;
		">
			<span class="visually-hidden">Loading...</span>
		</div>

        <div class="featuresBeginLoading">
            <div class="feature-itemBeginLoading">
                <i class="fas fa-clock"></i>
                <span>Chấm công đa nền tảng</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-calculator"></i>
                <span>Tính lương tự động chính xác</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-chart-line"></i>
                <span>Báo cáo nhân sự thông minh</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-shield-alt"></i>
                <span>Bảo mật dữ liệu cao cấp</span>
            </div>
        </div>

        <div class="copyrightBeginLoading">
            © 2025 <span class="company-nameBeginLoading">Vietinsoft Co. Ltd</span><br>
            All rights reserved
        </div>
    </div>
</div>
<div id="appapp" style="width:100%;">
        <div id="drawer">
	<script>
				function ShowWaitingPanel(){
					$(".BeginLoading").show();
				}
				function HideWaitingPanel(){
					$(".BeginLoading").hide();
					document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
				}
								
				document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
			    
            </script>
			<script>
				function createTextboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDateboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDateBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDateBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createTextAreaControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextArea(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextArea("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createCheckboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxCheckBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxCheckBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRadioGroupControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxRadioGroup(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxRadioGroup("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createNumberboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxNumberBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxNumberBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createColorBoxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxColorBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxColorBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureEditControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					config.visible = false;
					div[0].option = config;
					let img = $("<img>").addClass("img-fluid");
					if (config.value) img.attr("src", "data:image/jpg;base64," + config.value);
					let fileUpload = $("<div>");
					div.addClass("p-2").append(img, fileUpload);
					config.value = null;
					fileUpload.dxFileUploader({
						dialogTrigger: div,
						dropZone: div,
						...div[0].option,
					});

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureBoxControl(div, config, paramsControl, optionsControl) {
					let img = $("<img>").addClass("img-fluid");
					div.addClass("p-2").append(img);
					return div;
				}

				function createFileButtonControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					let fileUpload = $("<div>");
					let fileButton = $("<div>").dxButton({
						...config,
						onInitialized: function (arg) {
							if (config.ControlBackColor)
								arg.element.css("background-color", config.ControlBackColor);
							if (config.ControlForeColor)
								arg.element.css("color", config.ControlForeColor);
						},
					});

					fileUpload.dxFileUploader({
						...config,
						buttonInstance: fileButton.dxButton("instance"),
						accept: "*",
						dialogTrigger: fileButton,
						multiple: false,
						visible: false,
					});
					div.append(fileButton, fileUpload);

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownButtonControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownButton(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							div.dxDropDownButton("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDropDownBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createGridControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div[0].option.onCellClick = function (e) { };
					div.dxDataGrid(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDataGrid("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createListControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxList(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxList("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPDFViewerControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var viewer = new ej.pdfviewer.PdfViewer({
						documentPath:
							"https://cdn.syncfusion.com/Content/pdf/pdf-succinctly.pdf",
						resourceUrl:
							"https://cdn.syncfusion.com/ej2/23.2.6/dist/ej2-pdfviewer-lib",
					});
					viewer.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = viewer;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRichTextControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl = "https://services.syncfusion.com/js/production/";
					var defaultRTE = new ej.richtexteditor.RichTextEditor({
						toolbarSettings: {
							items: [
								"Undo",
								"Redo",
								"|",
								"ImportWord",
								"ExportWord",
								"ExportPdf",
								"|",
								"Bold",
								"Italic",
								"Underline",
								"StrikeThrough",
								"InlineCode",
								"SuperScript",
								"SubScript",
								"|",
								"FontName",
								"FontSize",
								"FontColor",
								"BackgroundColor",
								"|",
								"LowerCase",
								"UpperCase",
								"|",
								"Formats",
								"Alignments",
								"Blockquote",
								"|",
								"NumberFormatList",
								"BulletFormatList",
								"|",
								"Outdent",
								"Indent",
								"|",
								"CreateLink",
								"Image",
								"FileManager",
								"Video",
								"Audio",
								"CreateTable",
								"|",
								"FormatPainter",
								"ClearFormat",
								"|",
								"EmojiPicker",
								"Print",
								"|",
								"SourceCode",
								"FullScreen",
							],
						},
						slashMenuSettings: {
							enable: true,
							items: [
								"Paragraph",
								"Heading 1",
								"Heading 2",
								"Heading 3",
								"Heading 4",
								"OrderedList",
								"UnorderedList",
								"CodeBlock",
								"Blockquote",
								"Link",
								"Image",
								"Video",
								"Audio",
								"Table",
								"Emojipicker",
							],
						},
						insertImageSettings: {
							saveUrl: hostUrl + "api/RichTextEditor/SaveFile",
							removeUrl: hostUrl + "api/RichTextEditor/DeleteFile",
							path: hostUrl + "RichTextEditor/",
						},
						importWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ImportFromWord",
						},
						exportWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ExportToDocx",
							fileName: "RichTextEditor.docx",
							stylesheet: `
					.e-rte-content {
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						exportPdf: {
							serviceUrl:
								"https://ej2services.syncfusion.com/js/development/api/RichTextEditor/ExportToPdf",
							fileName: "RichTextEditor.pdf",
							stylesheet: `
					.e-rte-content{
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						fileManagerSettings: {
							enable: true,
							path: "/Pictures/Food",
							ajaxSettings: {
								url: "https://ej2-aspcore-service.azurewebsites.net/api/FileManager/FileOperations",
								getImageUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/GetImage",
								uploadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Upload",
								downloadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Download",
							},
						},
						quickToolbarSettings: {
							table: [
								"TableHeader",
								"TableRows",
								"TableColumns",
								"TableCell",
								"-",
								"BackgroundColor",
								"TableRemove",
								"TableCellVerticalAlign",
								"Styles",
							],
							showOnRightClick: true,
						},
						enableXhtml: true,
						showCharCount: true,
						enableTabKey: true,
						placeholder: "Type something or use @ to tag a user...",
						option: function(name, value) {
							if (typeof value === "undefined") return this[name];

							if(this[name] === value) return;

							this[name] = value;
						},
						...config
					});
					defaultRTE.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = defaultRTE;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createBarCodeControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var barcode = new ej.barcodegenerator.QRCodeGenerator({
						width: config.width,
						height: config.height,
						mode: "SVG",
						type: config.BarCodeType,
						displayText: { visibility: false },
						value: "",
					});
					barcode.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = barcode;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function CreateHTMLControl(div, config, paramsControl, optionsControl) {
					let html = $(config.value);
					return html;
				}

				function CreateHyperLinkControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					if (config.onInitialized) config.onInitialized(config);
					div[0].option = config;
					div[0].option.element = div;
					div.append(
						$("<a>")
							.attr("href", "#")
							.text(config.Message)
							.on("click", (event) => {
								event.preventDefault();
								config.openFormAction(
									paramsControl[config.ControlNameParam].value
								);
							})
					);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div[0].option;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function onGridViewCellClick(t) {
					let s = t.cellElement;
					let config = { ...t.column };
					config.value = t.value;
					s.html(
						window[t.column.CreateControlFunction]
							? window[t.column.CreateControlFunction](null, config)
							: t.displayValue
					);
				}

				function convertSqlToJsCondition(sqlCondition, objectName) {
					sqlCondition = sqlCondition
						.replace(/LIKE\s+''%([^%]+)%''/gi, ''.includes("$1")'') // Contains
						.replace(/LIKE\s+''%([^%]+)''/gi, ''.endsWith("$1")'') // Ends with
						.replace(/LIKE\s+''([^%]+)%''/gi, ''.startsWith("$1")''); // Starts with

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+IN\s+\(([^)]+)\)/gi,
						(match, field, values) => {
							const jsValues = values.split(",").map((v) => v.trim());
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `[${jsValues.join(", ")}].includes(${field})`;
						}
					);

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+BETWEEN\s+([\w\d\.\-]+)\s+AND\s+([\w\d\.\-]+)/gi,
						(match, field, start, end) => {
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `(${field} >= ${start} && ${field} <= ${end})`;
						}
					);

					if (objectName) {
						sqlCondition = sqlCondition.replace(
							/\[([\w]+)\]/g,
							`${objectName}["$1"]`
						);
					} else {
						sqlCondition = sqlCondition.replace(/\[([\w]+)\]/g, "$1");
					}

					return sqlCondition
						.replace(/=/g, "==") // Replace "=" with "=="
						.replace(/(>|<)==/g, "$1=") // Replace ">|<==" with ">|<="
						.replace(/is not null/gi, "!== null") // Convert "is not null"
						.replace(/is null/gi, "=== null") // Convert "is null"
						.replace(/\band\b/gi, "&&") // Convert "And" to "&&"
						.replace(/\bor\b/gi, "||") // Convert "Or" to "||"
						.replace(/<>/g, "!="); // Replace "<>" with "!="
				}

				function evaluateCondition(condition, context = {}) {
					try {
						const func = new Function(
							...Object.keys(context),
							`return ${condition};`
						);
						return func(...Object.values(context));
					} catch (error) {
						console.error(condition);
						console.error("Error evaluating condition:", error);
						return false;
					}
				}

				function ParseDefineAction(str) {
					let parts = str.split("|");
					let result = {};
					parts
						.filter((x) => x)
						.forEach((item) => {
							if ((item.match(/=/g) || []).length > 1) {
								let [tmpKey, tmpValue] = item.split(/=(.*)/s);
								tmpValue = tmpValue.split("&");
								let tmpValue1 = {};

								if (tmpValue[0] && tmpValue[0].startsWith("?ExportName")) {
									tmpValue1.OnExportParams = {};
									tmpValue[0] = tmpValue[0].replace(
										"?ExportName",
										"ExportName"
									);
									tmpValue.forEach((tmpItem) => {
										let [key, ...rest] = tmpItem.split("=");
										if (rest.length > 1) {
											let tmpValue2 = [];
											rest.join("=")
												.split("_")
												.forEach((tmpItem1) => {
													let [key, value] = tmpItem1.split("=");
													tmpValue2.push(key);
													tmpValue2.push(value);
												});

											tmpValue1.OnExportParams[key.replace("@", "")] =
												tmpValue2;
										} else
											tmpValue1.OnExportParams[key.replace("@", "")] =
												rest.join("=");
									});
								} else
									tmpValue.forEach((tmpItem) => {
										let [key, value] = tmpItem.split("=");
										tmpValue1[key.replace("@", "")] = value;
									});
								result[tmpKey.replace("@", "")] = tmpValue1;
							} else {
								let [key, value] = item.split("=");
								if (key == "Object" && value && value.includes(".")) {
									let tmpValue1 = {};
									value = value.split(".");
									tmpValue1.ActionDefineType = value[0];
									tmpValue1.ClassName = value[1];
									value = tmpValue1;
								}

								result[key.replace("@", "")] = value;
							}
						});
					return result;
				}

				function convertToHTML(inputString) {
					inputString = inputString.replace(/<color=(.*?)>/gi, (match, color) => {
						const validColor = isValidCSSColor(color)
							? color
							: convertRGBToHex(color);
						return `<span style="color: ${validColor};">`;
					});
					inputString = inputString.replace(/<\/color>/gi, "</span>");

					// inputString = inputString.replace(/<size=\+(\d+)>/gi, (match, p1) => `<span style="font-size: ${parseInt(p1) + windowFontSize}px;">`);
					// inputString = inputString.replace(/<size=-(\d+)>/gi, (match, p1) => `<span style="font-size: ${windowFontSize - parseInt(p1)}px;">`);
					// inputString = inputString.replace(/<size=(\d+)>/gi, (match, size) => `<span style="font-size: ${size}px;">`);
					inputString = inputString.replace(
						/<size=([+-]?\d+|{[\d]+}|[\d]+[a-z%]*)>/gi,
						(match, size) => {
							const parsedSize = parseSize(size);
							return `<span style="font-size: ${parsedSize};">`;
						}
					);
					inputString = inputString.replace(/<\/size>/gi, "</span>");

					inputString = inputString.replace(
						/<href=(.*?)>(.*?)<\/href>/g,
						''<a href="$1" target="_blank">$2</a>''
					);

					inputString = inputString.replace(/<br>/g, "<br/>");

					inputString = inputString.replace(/<b>/gi, "<strong>");
					inputString = inputString.replace(/<\/b>/gi, "</strong>");

					inputString = inputString.replace(
						/<u>/gi,
						''<span style="text-decoration: underline;">''
					);
					inputString = inputString.replace(/<\/u>/gi, "</span>");

					return inputString;
				}

				function convertRGBToHex(rgb) {
					let rgbArray = rgb.split(",").map((num) => parseInt(num.trim()));
					if (rgbArray.length === 3) {
						return `#${rgbArray
							.map((num) => num.toString(16).padStart(2, "0"))
							.join("")}`;
					}
					return rgb;
				}

				function isValidCSSColor(color) {
					let s = new Option().style;
					s.color = color;
					return s.color !== "";
				}

				function parseSize(size) {
					if (size.startsWith("{") && size.endsWith("}")) {
						return `${size.slice(1, -1)}px`;
					} else if (/^\d+x$/.test(size)) {
						return `${parseInt(size)}em`;
					} else if (/^[+-]?\d+$/.test(size)) {
						let baseFontSize = parseInt(
							window.getComputedStyle(document.documentElement).fontSize,
							10
						);
						let sizeAdjustment = parseInt(size);
						let newSize = baseFontSize + sizeAdjustment;
						return `${newSize}px`;
					} else if (/^\d+$/.test(size)) {
						return `${size}px`;
					}
					return size;
				}

				function runSPActionFunction(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					AjaxHPAParadiseParadise({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				async function runSPActionFunctionAsync(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					await AjaxHPAParadiseParadiseAsync({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				function showPopupNotify(
					title,
					content,
					btnOKText = "OK",
					popupWidth = "15vw",
					closePopupFunction = () => { }
				) {
					var myDialog = DevExpress.ui.dialog.custom({
						title: title,
						messageHtml: `<div style="width: ${popupWidth}">${content}</div>`,
						buttons: [
							{
								text: btnOKText,
								onClick: function (e) {
									return true;
								},
							},
						],
					});
					myDialog.show().done(function () {
						closePopupFunction();
					});
				}

				function decodeHtmlEntities(str) {
					const txt = document.createElement("textarea");
					txt.innerHTML = str;
					return txt.value;
				}

				function copyViaExcelExport(
					gridInstance,
					isSelectedRowsOnly = false,
					copyWithHeader = false,
					loadPanelmessage = "Copying"
				) {
					let workbook = new ExcelJS.Workbook();
					let sheet = workbook.addWorksheet("dummy");
					let str = "";

					let col = gridInstance.getVisibleColumns();
					col = col.filter((x) => x.dataField !== undefined && x.allowExporting);
					let lastColumn = col[col.length - 1].dataField;

					DevExpress.excelExporter
						.exportDataGrid({
							component: gridInstance,
							worksheet: sheet,
							selectedRowsOnly: isSelectedRowsOnly,
							loadPanel: {
								showPane: false,
								message: loadPanelmessage,
							},
							customizeCell: function (options) {
								let { gridCell } = options;
								let field = gridCell.column.dataField;

								switch (gridCell.rowType) {
									case "header" && copyWithHeader:
										str += `${gridCell.column.caption}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "data":
										if (gridCell.column.dropdownSource) {
											gridCell.value =
												gridCell.column.dropdownSource.find(
													(x) =>
														x[gridCell.column.keyExpr] ==
														gridCell.data[gridCell.column.dataField]
												)?.[gridCell.column.displayExpr] ??
												(gridCell.value ? gridCell.value : "");
										} else if (
											gridCell.column.CreateControlFunction ==
											"createCheckboxControl"
										) {
											gridCell.value = gridCell.value
												? String.fromCharCode(parseInt("2713", 16))
												: "";
										} else if (
											gridCell.column.CreateControlFunction ==
											"createDateboxControl"
										) {
											gridCell.value = DevExpress.localization.formatDate(
												gridCell.value,
												gridCell.column.displayFormat
											);
										} else {
											gridCell.value =
												gridCell.data[gridCell.column.dataField];
										}

										str += `${gridCell.value ?? ""}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}

										break;
									case "group":
										if (gridCell.value) str += `${gridCell.value} `;

										if (
											gridCell.groupSummaryItems !== undefined &&
											gridCell.groupSummaryItems.length >= 1
										) {
											gridCell.groupSummaryItems.forEach((x) => {
												str += ` ${x.name}: ${x.value} `;
											});
										}

										str += `\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "groupFooter":
										break;
									case "totalFooter":
										break;
									default:
										break;
								}
							},
						})
						.then(() => {
							navigator.clipboard.writeText(str).then(
								() => { },
								() => { }
							);
						});
				}
				function GetFormatDate(date, format = "yyyy-MM-dd HH:mm:ss") {
					return DevExpress.localization.formatDate(new Date(date), format);
				}
				if (!Object.filter)
					Object.filter = (obj, predicate) =>
						Object.keys(obj)
							.filter((key) => predicate(obj[key], key))
							.reduce((res, key) => ((res[key] = obj[key]), res), {});
				
				if (!Object.findValue)
					Object.findValue = function (obj, key) {
						if (!obj) return undefined;
						let match = Object.keys(obj).find(k => k.toLowerCase() === key.toLowerCase());
						return match ? obj[match] : undefined;
					};

				function getArrayTypeDistinct(arr) {
					return [...new Set(arr.map((x) => typeof x))];
				}

				function createConditionQuery(filter, schema, comboBoxColumn) {
					let condition = ``;
					if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						["=", "<", ">"].includes(filter[1])
					) {
						if (filter[2] == null) {
							filter[0] = `ISNULL(${filter[0]} , '''')`;
							filter[2] = "''''";
						} else if (typeof filter[2] == "object") {
							filter[2] = "''" + filter[2].toISOString() + "''";
						} else if (typeof filter[2] == "number") {
							filter[2] = "''" + filter[2].toString() + "''";
						}
					} else if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						Array.isArray(filter[2]) &&
						filter[2].length == 0
					) {
						filter.pop();
						filter.pop();
					}

					filter.forEach((item) => {
						let typeList = Array.isArray(item) ? getArrayTypeDistinct(item) : [];
						if (
							(Array.isArray(item) && typeList.length > 1) ||
							(Array.isArray(item) &&
								typeList.length == 1 &&
								typeList[0] == "object")
						) {
							condition += `(${createConditionQuery(
								item,
								schema,
								comboBoxColumn
							)})`;
						} else if (Array.isArray(item) && typeList.length == 1) {
							condition += `${item[0]}`;
							if (
								schema &&
								schema.find((x) => x.name == item[0]).type == "System.String"
							)
								condition += " COLLATE Latin1_General_CI_AI";
							if (comboBoxColumn && comboBoxColumn.includes(item[0]))
								condition += ` like N''${item[2]}''`;
							else
								condition += `${
									item[1] == "contains"
										? ` like N''%${item[2]}%''`
										: ` = N''${item[2]}''`
								}`;
						} else
							condition +=
								" " +
								(item == null
									? "NULL"
									: item.toLocaleString().toLocaleUpperCase()) +
								" ";
					});

					return condition;
				}

				function createParamString(param) {
					let paramString = "";
					for (let index = 0; index < param.length; index += 2) {
						if (index > 0) paramString += ", ";
						paramString += `${param[index]} = N''''${param[index + 1]}''''`;
					}
					return paramString;
				}

				function transformDateToHierarchy(data) {
					let result = [],
						col0Map = new Map();

					data.forEach(({ col0, col1, col2, col3, col4, col5, totalCount }) => {
						if (!col0Map.has(col0)) {
							let col0Obj = { key: col0, items: [] };
							col0Map.set(col0, col0Obj);
							result.push(col0Obj);
						}

						if (!col1) return;

						let col0Obj = col0Map.get(col0),
							col1Map = col0Obj._col1Map || new Map();

						if (!col1Map.has(col1)) {
							let col1Obj = { key: col1, items: [] };
							if (col2) col1Obj.count = totalCount;
							col1Map.set(col1, col1Obj);
							col0Obj.items.push(col1Obj);
						}

						col0Obj._col1Map = col1Map;

						if (!col2) return;

						let col1Obj = col1Map.get(col1),
							col2Map = col1Obj._col2Map || new Map();

						if (!col2Map.has(col2)) {
							let col2Obj = { key: col2, items: [] };
							if (col3) col1Obj.count = totalCount;
							col2Map.set(col2, col2Obj);
							col1Obj.items.push(col2Obj);
						}

						col1Obj._col2Map = col2Map;

						if (!col3) return;

						let col2Obj = col2Map.get(col2),
							col3Map = col2Obj._col3Map || new Map();

						if (!col3Map.has(col3)) {
							let col3Obj = { key: col3, items: [] };
							if (col4) col2Obj.count = totalCount;
							col3Map.set(col3, col3Obj);
							col2Obj.items.push(col3Obj);
						}

						col2Obj._col3Map = col3Map;

						if (!col4) return;

						let col3Obj = col3Map.get(col3),
							col4Map = col3Obj._col4Map || new Map();

						if (!col4Map.has(col4)) {
							let col4Obj = { key: col4, items: [] };
							if (col5) col3Obj.count = totalCount;
							col4Map.set(col4, col4Obj);

							col3Obj.items.push(col4Obj);
						}

						col3Obj._col4Map = col4Map;

						if (col5 != undefined) {
							let col4Obj = col4Map.get(col4);
							col4Obj.items.push({
								key: col5,
								items: null,
								count: totalCount,
							});
						}
					});

					return result;
				};

			</script>
            <div id="main-layout-diagram" style="overflow-x:hidden; overflow-y:auto; display:block">' as [html],NULL as [HtmlStatus],N'A96' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbody' as [TableName],N'en' as [LanguageID],N'2' as [ScreenType],N'<script>
(async()=>{
    try {
        let b = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": [`delete from tblParameter where code like ''''debug'''';
INSERT INTO tblParameter ([Code], [Value]) select ''''Debug'''' [Code], ''''1'''' [Value];`],})
        console.log(b)
        let a = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": ["select Code, Value from tblParameter where code like ''''debug''''"],})
        console.log(a)
    } catch (error) {
    }
	if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
        window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
        window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
     }
})();
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.0/font/bootstrap-icons.min.css">

<style type="text/css"> 
	#RightMenu {display: none !important;}
	.BeginLoading {

            overflow: hidden;
            height: 100vh;
            background: linear-gradient(135deg, #e8f5e8, #f9f9f9, #e7f3e7);
            position: relative;
            color: #2e7d32;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999
        }

        .background-patternBeginLoading {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(76, 175, 80, 0.1) 0%, transparent 25%),
                radial-gradient(circle at 80% 70%, rgba(129, 199, 132, 0.08) 0%, transparent 30%),
                radial-gradient(circle at 50% 50%, rgba(102, 187, 106, 0.05) 0%, transparent 40%),
                linear-gradient(45deg, transparent 48%, rgba(255, 255, 255, 0.05) 50%, transparent 52%),
                linear-gradient(-45deg, transparent 48%, rgba(255, 255, 255, 0.03) 50%, transparent 52%);
            background-size: 300px 300px, 400px 400px, 500px 500px, 60px 60px, 60px 60px;
            animation: backgroundMoveBeginLoading 20s ease-in-out infinite;
            z-index: 1;
        }

        .geometric-shapesBeginLoading {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .shapeBeginLoading {
            position: absolute;
            opacity: 0.1;
            animation: floatBeginLoading 15s ease-in-out infinite;
        }

        .shape-1BeginLoading {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #4caf50, #81c784);
            border-radius: 20px;
            top: 15%;
            left: 10%;
            animation-delay: 0s;
            transform: rotate(45deg);
        }

        .shape-2BeginLoading {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #66bb6a, #a5d6a7);
            border-radius: 50%;
            top: 25%;
            right: 15%;
            animation-delay: -3s;
        }

        .shape-3BeginLoading {
            width: 100px;
            height: 100px;
            background: linear-gradient(90deg, #81c784, #c8e6c9);
            border-radius: 30px;
            bottom: 20%;
            left: 5%;
            animation-delay: -6s;
            transform: rotate(30deg);
        }

        .shape-4BeginLoading {
            width: 70px;
            height: 70px;
            background: linear-gradient(180deg, #4caf50, #66bb6a);
            clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
            bottom: 30%;
            right: 20%;
            animation-delay: -9s;
        }

        .shape-5BeginLoading {
            width: 90px;
            height: 90px;
            background: linear-gradient(225deg, #81c784, #a5d6a7);
            border-radius: 50% 0 50% 0;
            top: 60%;
            left: 20%;
            animation-delay: -12s;
        }

        .loading-containerBeginLoading {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 90%;
            max-width: 400px;
            padding: 30px 20px 20px;
        }

        .logoBeginLoading {
            text-align: center;
            margin-bottom: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-iconBeginLoading {
            width: 250px;
           margin-bottom: 15px;
        }

        .logoBeginLoading h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: -0.5px;
        }

        .logoBeginLoading p {
            font-size: 1rem;
          opacity: 0.9;
            font-weight: 400;
            line-height: 1.4;
            color: #2e7d32;
        }

        .featuresBeginLoading {
            width: 100%;
            margin: 20px 0 30px;
        }

        .feature-itemBeginLoading {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid rgba(46, 125, 50, 0.2);
            opacity: 1;
        }

        .feature-itemBeginLoading:last-child {
            border-bottom: none;
        }

        /*.feature-itemBeginLoading:nth-child(1) { animation-delay: 0.3s; }
        .feature-itemBeginLoading:nth-child(2) { animation-delay: 0.5s; }
        .feature-itemBeginLoading:nth-child(3) { animation-delay: 0.7s; }
        .feature-itemBeginLoading:nth-child(4) { animation-delay: 0.9s; }*/

        .feature-itemBeginLoading i {
            font-size: 1.5rem;
            color: #4caf50;
            margin-right: 16px;
            width: 30px;
            text-align: center;
        }

        .feature-itemBeginLoading span {
            font-size: 1rem;
            line-height: 1.4;
            color: #2e7d32;
        }

        .copyrightBeginLoading {
            margin-top: 20px;
            text-align: center;
            font-size: 0.85rem;
            color: #2e7d32;
            opacity: 0.8;
            padding-top: 15px;
            border-top: 1px solid rgba(46, 125, 50, 0.2);
        }

        .copyrightBeginLoading .company-nameBeginLoading {
            font-weight: 600;
            color: #1b5e20;
        }

        .loading-textBeginLoading {
            margin-top: 20px;
            font-size: 1rem;
            opacity: 0.8;
            display: flex;
            align-items: center;
            color: #2e7d32;
        }

        .loading-dotsBeginLoading {
            display: inline-block;
            width: 20px;
            text-align: left;
        }

        .loading-dotsBeginLoading::after {
            content: '';
            animation: dotsBeginLoading 1.5s infinite;
        }

        @keyframes dotsBeginLoading {
            0%, 20% { content: ''.''; }
            40% { content: ''..''; }
            60%, 100% { content: ''...''; }
        }

        @keyframes fadeInBeginLoading {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInBeginLoading {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes backgroundMoveBeginLoading {
            0%, 100% {
                background-position: 0% 0%, 0% 0%, 0% 0%, 0% 0%, 0% 0%;
            }
            50% {
                background-position: 100% 100%, 100% 100%, 100% 100%, 30px 30px, -30px 30px;
            }
        }

        @keyframes floatBeginLoading {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }
            33% {
                transform: translateY(-20px) rotate(120deg);
            }
            66% {
                transform: translateY(10px) rotate(240deg);
            }
        }

        .decorative-elementBeginLoading {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(76, 175, 80, 0.08) 0%, transparent 70%);
            z-index: 1;
        }

        .decorative-elementBeginLoading:nth-child(1) {
            width: 150px;
            height: 150px;
            top: -50px;
            right: -50px;
            animation: floatBeginLoading 12s ease-in-out infinite;
        }

        .decorative-elementBeginLoading:nth-child(2) {
            width: 200px;
            height: 200px;
            bottom: -80px;
            left: -80px;
            animation: floatBeginLoading 15s ease-in-out infinite reverse;
        }
</style>


<script>

</script>
<div class="BeginLoading">
    <div class="background-patternBeginLoading"></div>
    <div class="geometric-shapesBeginLoading">
        <div class="shapeBeginLoading shape-1BeginLoading"></div>
        <div class="shapeBeginLoading shape-2BeginLoading"></div>
        <div class="shapeBeginLoading shape-3BeginLoading"></div>
        <div class="shapeBeginLoading shape-4BeginLoading"></div>
        <div class="shapeBeginLoading shape-5BeginLoading"></div>
    </div>
    <div class="decorative-elementBeginLoading"></div>
    <div class="decorative-elementBeginLoading"></div>

    <div class="loading-containerBeginLoading">
        <div class="logoBeginLoading">
            <img src="https://cdn.paradisehrm.com/Image/BackgroundMobile/paradiselogomain.jpg" onerror="this.onerror=null;this.src=''/CDN/Image/BackgroundMobile/paradiselogomain.jpg'';
                alt="ParadiseHRM" class="logo-iconBeginLoading">
            <p>Giải pháp hiệu quả cho doanh nghiệp</p>
        </div>
		
		<div class="spinner-border" role="status" style="
			width: 4rem;
			aspect-ratio: 1;
			height: unset;
		">
			<span class="visually-hidden">Loading...</span>
		</div>

        <div class="featuresBeginLoading">
            <div class="feature-itemBeginLoading">
                <i class="fas fa-clock"></i>
                <span>Chấm công đa nền tảng</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-calculator"></i>
                <span>Tính lương tự động chính xác</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-chart-line"></i>
                <span>Báo cáo nhân sự thông minh</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-shield-alt"></i>
                <span>Bảo mật dữ liệu cao cấp</span>
            </div>
        </div>

        <div class="copyrightBeginLoading">
            © 2025 <span class="company-nameBeginLoading">Vietinsoft Co. Ltd</span><br>
            All rights reserved
        </div>
    </div>
</div>
<div id="appapp" style="width:100%;">
        <div id="drawer">
	<script>
				function ShowWaitingPanel(){
					$(".BeginLoading").show();
				}
				function HideWaitingPanel(){
					$(".BeginLoading").hide();
					document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
				}
								
				document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
			    
            </script>
			<script>
				function createTextboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDateboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDateBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDateBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createTextAreaControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextArea(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextArea("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createCheckboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxCheckBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxCheckBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRadioGroupControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxRadioGroup(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxRadioGroup("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createNumberboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxNumberBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxNumberBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createColorBoxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxColorBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxColorBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureEditControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					config.visible = false;
					div[0].option = config;
					let img = $("<img>").addClass("img-fluid");
					if (config.value) img.attr("src", "data:image/jpg;base64," + config.value);
					let fileUpload = $("<div>");
					div.addClass("p-2").append(img, fileUpload);
					config.value = null;
					fileUpload.dxFileUploader({
						dialogTrigger: div,
						dropZone: div,
						...div[0].option,
					});

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureBoxControl(div, config, paramsControl, optionsControl) {
					let img = $("<img>").addClass("img-fluid");
					div.addClass("p-2").append(img);
					return div;
				}

				function createFileButtonControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					let fileUpload = $("<div>");
					let fileButton = $("<div>").dxButton({
						...config,
						onInitialized: function (arg) {
							if (config.ControlBackColor)
								arg.element.css("background-color", config.ControlBackColor);
							if (config.ControlForeColor)
								arg.element.css("color", config.ControlForeColor);
						},
					});

					fileUpload.dxFileUploader({
						...config,
						buttonInstance: fileButton.dxButton("instance"),
						accept: "*",
						dialogTrigger: fileButton,
						multiple: false,
						visible: false,
					});
					div.append(fileButton, fileUpload);

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownButtonControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownButton(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							div.dxDropDownButton("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDropDownBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createGridControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div[0].option.onCellClick = function (e) { };
					div.dxDataGrid(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDataGrid("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createListControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxList(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxList("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPDFViewerControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var viewer = new ej.pdfviewer.PdfViewer({
						documentPath:
							"https://cdn.syncfusion.com/Content/pdf/pdf-succinctly.pdf",
						resourceUrl:
							"https://cdn.syncfusion.com/ej2/23.2.6/dist/ej2-pdfviewer-lib",
					});
					viewer.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = viewer;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRichTextControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl = "https://services.syncfusion.com/js/production/";
					var defaultRTE = new ej.richtexteditor.RichTextEditor({
						toolbarSettings: {
							items: [
								"Undo",
								"Redo",
								"|",
								"ImportWord",
								"ExportWord",
								"ExportPdf",
								"|",
								"Bold",
								"Italic",
								"Underline",
								"StrikeThrough",
								"InlineCode",
								"SuperScript",
								"SubScript",
								"|",
								"FontName",
								"FontSize",
								"FontColor",
								"BackgroundColor",
								"|",
								"LowerCase",
								"UpperCase",
								"|",
								"Formats",
								"Alignments",
								"Blockquote",
								"|",
								"NumberFormatList",
								"BulletFormatList",
								"|",
								"Outdent",
								"Indent",
								"|",
								"CreateLink",
								"Image",
								"FileManager",
								"Video",
								"Audio",
								"CreateTable",
								"|",
								"FormatPainter",
								"ClearFormat",
								"|",
								"EmojiPicker",
								"Print",
								"|",
								"SourceCode",
								"FullScreen",
							],
						},
						slashMenuSettings: {
							enable: true,
							items: [
								"Paragraph",
								"Heading 1",
								"Heading 2",
								"Heading 3",
								"Heading 4",
								"OrderedList",
								"UnorderedList",
								"CodeBlock",
								"Blockquote",
								"Link",
								"Image",
								"Video",
								"Audio",
								"Table",
								"Emojipicker",
							],
						},
						insertImageSettings: {
							saveUrl: hostUrl + "api/RichTextEditor/SaveFile",
							removeUrl: hostUrl + "api/RichTextEditor/DeleteFile",
							path: hostUrl + "RichTextEditor/",
						},
						importWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ImportFromWord",
						},
						exportWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ExportToDocx",
							fileName: "RichTextEditor.docx",
							stylesheet: `
					.e-rte-content {
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						exportPdf: {
							serviceUrl:
								"https://ej2services.syncfusion.com/js/development/api/RichTextEditor/ExportToPdf",
							fileName: "RichTextEditor.pdf",
							stylesheet: `
					.e-rte-content{
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						fileManagerSettings: {
							enable: true,
							path: "/Pictures/Food",
							ajaxSettings: {
								url: "https://ej2-aspcore-service.azurewebsites.net/api/FileManager/FileOperations",
								getImageUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/GetImage",
								uploadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Upload",
								downloadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Download",
							},
						},
						quickToolbarSettings: {
							table: [
								"TableHeader",
								"TableRows",
								"TableColumns",
								"TableCell",
								"-",
								"BackgroundColor",
								"TableRemove",
								"TableCellVerticalAlign",
								"Styles",
							],
							showOnRightClick: true,
						},
						enableXhtml: true,
						showCharCount: true,
						enableTabKey: true,
						placeholder: "Type something or use @ to tag a user...",
						option: function(name, value) {
							if (typeof value === "undefined") return this[name];

							if(this[name] === value) return;

							this[name] = value;
						},
						...config
					});
					defaultRTE.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = defaultRTE;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createBarCodeControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var barcode = new ej.barcodegenerator.QRCodeGenerator({
						width: config.width,
						height: config.height,
						mode: "SVG",
						type: config.BarCodeType,
						displayText: { visibility: false },
						value: "",
					});
					barcode.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = barcode;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function CreateHTMLControl(div, config, paramsControl, optionsControl) {
					let html = $(config.value);
					return html;
				}

				function CreateHyperLinkControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					if (config.onInitialized) config.onInitialized(config);
					div[0].option = config;
					div[0].option.element = div;
					div.append(
						$("<a>")
							.attr("href", "#")
							.text(config.Message)
							.on("click", (event) => {
								event.preventDefault();
								config.openFormAction(
									paramsControl[config.ControlNameParam].value
								);
							})
					);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div[0].option;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function onGridViewCellClick(t) {
					let s = t.cellElement;
					let config = { ...t.column };
					config.value = t.value;
					s.html(
						window[t.column.CreateControlFunction]
							? window[t.column.CreateControlFunction](null, config)
							: t.displayValue
					);
				}

				function convertSqlToJsCondition(sqlCondition, objectName) {
					sqlCondition = sqlCondition
						.replace(/LIKE\s+''%([^%]+)%''/gi, ''.includes("$1")'') // Contains
						.replace(/LIKE\s+''%([^%]+)''/gi, ''.endsWith("$1")'') // Ends with
						.replace(/LIKE\s+''([^%]+)%''/gi, ''.startsWith("$1")''); // Starts with

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+IN\s+\(([^)]+)\)/gi,
						(match, field, values) => {
							const jsValues = values.split(",").map((v) => v.trim());
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `[${jsValues.join(", ")}].includes(${field})`;
						}
					);

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+BETWEEN\s+([\w\d\.\-]+)\s+AND\s+([\w\d\.\-]+)/gi,
						(match, field, start, end) => {
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `(${field} >= ${start} && ${field} <= ${end})`;
						}
					);

					if (objectName) {
						sqlCondition = sqlCondition.replace(
							/\[([\w]+)\]/g,
							`${objectName}["$1"]`
						);
					} else {
						sqlCondition = sqlCondition.replace(/\[([\w]+)\]/g, "$1");
					}

					return sqlCondition
						.replace(/=/g, "==") // Replace "=" with "=="
						.replace(/(>|<)==/g, "$1=") // Replace ">|<==" with ">|<="
						.replace(/is not null/gi, "!== null") // Convert "is not null"
						.replace(/is null/gi, "=== null") // Convert "is null"
						.replace(/\band\b/gi, "&&") // Convert "And" to "&&"
						.replace(/\bor\b/gi, "||") // Convert "Or" to "||"
						.replace(/<>/g, "!="); // Replace "<>" with "!="
				}

				function evaluateCondition(condition, context = {}) {
					try {
						const func = new Function(
							...Object.keys(context),
							`return ${condition};`
						);
						return func(...Object.values(context));
					} catch (error) {
						console.error(condition);
						console.error("Error evaluating condition:", error);
						return false;
					}
				}

				function ParseDefineAction(str) {
					let parts = str.split("|");
					let result = {};
					parts
						.filter((x) => x)
						.forEach((item) => {
							if ((item.match(/=/g) || []).length > 1) {
								let [tmpKey, tmpValue] = item.split(/=(.*)/s);
								tmpValue = tmpValue.split("&");
								let tmpValue1 = {};

								if (tmpValue[0] && tmpValue[0].startsWith("?ExportName")) {
									tmpValue1.OnExportParams = {};
									tmpValue[0] = tmpValue[0].replace(
										"?ExportName",
										"ExportName"
									);
									tmpValue.forEach((tmpItem) => {
										let [key, ...rest] = tmpItem.split("=");
										if (rest.length > 1) {
											let tmpValue2 = [];
											rest.join("=")
												.split("_")
												.forEach((tmpItem1) => {
													let [key, value] = tmpItem1.split("=");
													tmpValue2.push(key);
													tmpValue2.push(value);
												});

											tmpValue1.OnExportParams[key.replace("@", "")] =
												tmpValue2;
										} else
											tmpValue1.OnExportParams[key.replace("@", "")] =
												rest.join("=");
									});
								} else
									tmpValue.forEach((tmpItem) => {
										let [key, value] = tmpItem.split("=");
										tmpValue1[key.replace("@", "")] = value;
									});
								result[tmpKey.replace("@", "")] = tmpValue1;
							} else {
								let [key, value] = item.split("=");
								if (key == "Object" && value && value.includes(".")) {
									let tmpValue1 = {};
									value = value.split(".");
									tmpValue1.ActionDefineType = value[0];
									tmpValue1.ClassName = value[1];
									value = tmpValue1;
								}

								result[key.replace("@", "")] = value;
							}
						});
					return result;
				}

				function convertToHTML(inputString) {
					inputString = inputString.replace(/<color=(.*?)>/gi, (match, color) => {
						const validColor = isValidCSSColor(color)
							? color
							: convertRGBToHex(color);
						return `<span style="color: ${validColor};">`;
					});
					inputString = inputString.replace(/<\/color>/gi, "</span>");

					// inputString = inputString.replace(/<size=\+(\d+)>/gi, (match, p1) => `<span style="font-size: ${parseInt(p1) + windowFontSize}px;">`);
					// inputString = inputString.replace(/<size=-(\d+)>/gi, (match, p1) => `<span style="font-size: ${windowFontSize - parseInt(p1)}px;">`);
					// inputString = inputString.replace(/<size=(\d+)>/gi, (match, size) => `<span style="font-size: ${size}px;">`);
					inputString = inputString.replace(
						/<size=([+-]?\d+|{[\d]+}|[\d]+[a-z%]*)>/gi,
						(match, size) => {
							const parsedSize = parseSize(size);
							return `<span style="font-size: ${parsedSize};">`;
						}
					);
					inputString = inputString.replace(/<\/size>/gi, "</span>");

					inputString = inputString.replace(
						/<href=(.*?)>(.*?)<\/href>/g,
						''<a href="$1" target="_blank">$2</a>''
					);

					inputString = inputString.replace(/<br>/g, "<br/>");

					inputString = inputString.replace(/<b>/gi, "<strong>");
					inputString = inputString.replace(/<\/b>/gi, "</strong>");

					inputString = inputString.replace(
						/<u>/gi,
						''<span style="text-decoration: underline;">''
					);
					inputString = inputString.replace(/<\/u>/gi, "</span>");

					return inputString;
				}

				function convertRGBToHex(rgb) {
					let rgbArray = rgb.split(",").map((num) => parseInt(num.trim()));
					if (rgbArray.length === 3) {
						return `#${rgbArray
							.map((num) => num.toString(16).padStart(2, "0"))
							.join("")}`;
					}
					return rgb;
				}

				function isValidCSSColor(color) {
					let s = new Option().style;
					s.color = color;
					return s.color !== "";
				}

				function parseSize(size) {
					if (size.startsWith("{") && size.endsWith("}")) {
						return `${size.slice(1, -1)}px`;
					} else if (/^\d+x$/.test(size)) {
						return `${parseInt(size)}em`;
					} else if (/^[+-]?\d+$/.test(size)) {
						let baseFontSize = parseInt(
							window.getComputedStyle(document.documentElement).fontSize,
							10
						);
						let sizeAdjustment = parseInt(size);
						let newSize = baseFontSize + sizeAdjustment;
						return `${newSize}px`;
					} else if (/^\d+$/.test(size)) {
						return `${size}px`;
					}
					return size;
				}

				function runSPActionFunction(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					AjaxHPAParadiseParadise({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				async function runSPActionFunctionAsync(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					await AjaxHPAParadiseParadiseAsync({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				function showPopupNotify(
					title,
					content,
					btnOKText = "OK",
					popupWidth = "15vw",
					closePopupFunction = () => { }
				) {
					var myDialog = DevExpress.ui.dialog.custom({
						title: title,
						messageHtml: `<div style="width: ${popupWidth}">${content}</div>`,
						buttons: [
							{
								text: btnOKText,
								onClick: function (e) {
									return true;
								},
							},
						],
					});
					myDialog.show().done(function () {
						closePopupFunction();
					});
				}

				function decodeHtmlEntities(str) {
					const txt = document.createElement("textarea");
					txt.innerHTML = str;
					return txt.value;
				}

				function copyViaExcelExport(
					gridInstance,
					isSelectedRowsOnly = false,
					copyWithHeader = false,
					loadPanelmessage = "Copying"
				) {
					let workbook = new ExcelJS.Workbook();
					let sheet = workbook.addWorksheet("dummy");
					let str = "";

					let col = gridInstance.getVisibleColumns();
					col = col.filter((x) => x.dataField !== undefined && x.allowExporting);
					let lastColumn = col[col.length - 1].dataField;

					DevExpress.excelExporter
						.exportDataGrid({
							component: gridInstance,
							worksheet: sheet,
							selectedRowsOnly: isSelectedRowsOnly,
							loadPanel: {
								showPane: false,
								message: loadPanelmessage,
							},
							customizeCell: function (options) {
								let { gridCell } = options;
								let field = gridCell.column.dataField;

								switch (gridCell.rowType) {
									case "header" && copyWithHeader:
										str += `${gridCell.column.caption}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "data":
										if (gridCell.column.dropdownSource) {
											gridCell.value =
												gridCell.column.dropdownSource.find(
													(x) =>
														x[gridCell.column.keyExpr] ==
														gridCell.data[gridCell.column.dataField]
												)?.[gridCell.column.displayExpr] ??
												(gridCell.value ? gridCell.value : "");
										} else if (
											gridCell.column.CreateControlFunction ==
											"createCheckboxControl"
										) {
											gridCell.value = gridCell.value
												? String.fromCharCode(parseInt("2713", 16))
												: "";
										} else if (
											gridCell.column.CreateControlFunction ==
											"createDateboxControl"
										) {
											gridCell.value = DevExpress.localization.formatDate(
												gridCell.value,
												gridCell.column.displayFormat
											);
										} else {
											gridCell.value =
												gridCell.data[gridCell.column.dataField];
										}

										str += `${gridCell.value ?? ""}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}

										break;
									case "group":
										if (gridCell.value) str += `${gridCell.value} `;

										if (
											gridCell.groupSummaryItems !== undefined &&
											gridCell.groupSummaryItems.length >= 1
										) {
											gridCell.groupSummaryItems.forEach((x) => {
												str += ` ${x.name}: ${x.value} `;
											});
										}

										str += `\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "groupFooter":
										break;
									case "totalFooter":
										break;
									default:
										break;
								}
							},
						})
						.then(() => {
							navigator.clipboard.writeText(str).then(
								() => { },
								() => { }
							);
						});
				}
				function GetFormatDate(date, format = "yyyy-MM-dd HH:mm:ss") {
					return DevExpress.localization.formatDate(new Date(date), format);
				}
				if (!Object.filter)
					Object.filter = (obj, predicate) =>
						Object.keys(obj)
							.filter((key) => predicate(obj[key], key))
							.reduce((res, key) => ((res[key] = obj[key]), res), {});
				
				if (!Object.findValue)
					Object.findValue = function (obj, key) {
						if (!obj) return undefined;
						let match = Object.keys(obj).find(k => k.toLowerCase() === key.toLowerCase());
						return match ? obj[match] : undefined;
					};

				function getArrayTypeDistinct(arr) {
					return [...new Set(arr.map((x) => typeof x))];
				}

				function createConditionQuery(filter, schema, comboBoxColumn) {
					let condition = ``;
					if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						["=", "<", ">"].includes(filter[1])
					) {
						if (filter[2] == null) {
							filter[0] = `ISNULL(${filter[0]} , '''')`;
							filter[2] = "''''";
						} else if (typeof filter[2] == "object") {
							filter[2] = "''" + filter[2].toISOString() + "''";
						} else if (typeof filter[2] == "number") {
							filter[2] = "''" + filter[2].toString() + "''";
						}
					} else if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						Array.isArray(filter[2]) &&
						filter[2].length == 0
					) {
						filter.pop();
						filter.pop();
					}

					filter.forEach((item) => {
						let typeList = Array.isArray(item) ? getArrayTypeDistinct(item) : [];
						if (
							(Array.isArray(item) && typeList.length > 1) ||
							(Array.isArray(item) &&
								typeList.length == 1 &&
								typeList[0] == "object")
						) {
							condition += `(${createConditionQuery(
								item,
								schema,
								comboBoxColumn
							)})`;
						} else if (Array.isArray(item) && typeList.length == 1) {
							condition += `${item[0]}`;
							if (
								schema &&
								schema.find((x) => x.name == item[0]).type == "System.String"
							)
								condition += " COLLATE Latin1_General_CI_AI";
							if (comboBoxColumn && comboBoxColumn.includes(item[0]))
								condition += ` like N''${item[2]}''`;
							else
								condition += `${
									item[1] == "contains"
										? ` like N''%${item[2]}%''`
										: ` = N''${item[2]}''`
								}`;
						} else
							condition +=
								" " +
								(item == null
									? "NULL"
									: item.toLocaleString().toLocaleUpperCase()) +
								" ";
					});

					return condition;
				}

				function createParamString(param) {
					let paramString = "";
					for (let index = 0; index < param.length; index += 2) {
						if (index > 0) paramString += ", ";
						paramString += `${param[index]} = N''''${param[index + 1]}''''`;
					}
					return paramString;
				}

				function transformDateToHierarchy(data) {
					let result = [],
						col0Map = new Map();

					data.forEach(({ col0, col1, col2, col3, col4, col5, totalCount }) => {
						if (!col0Map.has(col0)) {
							let col0Obj = { key: col0, items: [] };
							col0Map.set(col0, col0Obj);
							result.push(col0Obj);
						}

						if (!col1) return;

						let col0Obj = col0Map.get(col0),
							col1Map = col0Obj._col1Map || new Map();

						if (!col1Map.has(col1)) {
							let col1Obj = { key: col1, items: [] };
							if (col2) col1Obj.count = totalCount;
							col1Map.set(col1, col1Obj);
							col0Obj.items.push(col1Obj);
						}

						col0Obj._col1Map = col1Map;

						if (!col2) return;

						let col1Obj = col1Map.get(col1),
							col2Map = col1Obj._col2Map || new Map();

						if (!col2Map.has(col2)) {
							let col2Obj = { key: col2, items: [] };
							if (col3) col1Obj.count = totalCount;
							col2Map.set(col2, col2Obj);
							col1Obj.items.push(col2Obj);
						}

						col1Obj._col2Map = col2Map;

						if (!col3) return;

						let col2Obj = col2Map.get(col2),
							col3Map = col2Obj._col3Map || new Map();

						if (!col3Map.has(col3)) {
							let col3Obj = { key: col3, items: [] };
							if (col4) col2Obj.count = totalCount;
							col3Map.set(col3, col3Obj);
							col2Obj.items.push(col3Obj);
						}

						col2Obj._col3Map = col3Map;

						if (!col4) return;

						let col3Obj = col3Map.get(col3),
							col4Map = col3Obj._col4Map || new Map();

						if (!col4Map.has(col4)) {
							let col4Obj = { key: col4, items: [] };
							if (col5) col3Obj.count = totalCount;
							col4Map.set(col4, col4Obj);

							col3Obj.items.push(col4Obj);
						}

						col3Obj._col4Map = col4Map;

						if (col5 != undefined) {
							let col4Obj = col4Map.get(col4);
							col4Obj.items.push({
								key: col5,
								items: null,
								count: totalCount,
							});
						}
					});

					return result;
				};

			</script>
            <div id="main-layout-diagram" style="overflow-x:hidden; overflow-y:auto; display:block">' as [html],NULL as [HtmlStatus],N'A96' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbody' as [TableName],N'vn' as [LanguageID],N'0' as [ScreenType],N'<script>
 if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
     window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
     window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
 }
 </script><script>
    if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
        window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
        window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
     }
</script><script>
(async()=>{
    try {
        await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": [`delete from tblParameter where code like ''debug'';INSERT INTO tblParameter ([Code], [Value]) select ''Debug'' [Code], ''1'' [Value];`],})
    } catch (error) {
    }
})();
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.0/font/bootstrap-icons.min.css">

<style type="text/css"> 
	#RightMenu {display: none !important;}
	.BeginLoading {

            overflow: hidden;
            height: 100vh;
            background: linear-gradient(135deg, #e8f5e8, #f9f9f9, #e7f3e7);
            position: relative;
            color: #2e7d32;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999
        }

        .background-patternBeginLoading {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(76, 175, 80, 0.1) 0%, transparent 25%),
                radial-gradient(circle at 80% 70%, rgba(129, 199, 132, 0.08) 0%, transparent 30%),
                radial-gradient(circle at 50% 50%, rgba(102, 187, 106, 0.05) 0%, transparent 40%),
                linear-gradient(45deg, transparent 48%, rgba(255, 255, 255, 0.05) 50%, transparent 52%),
                linear-gradient(-45deg, transparent 48%, rgba(255, 255, 255, 0.03) 50%, transparent 52%);
            background-size: 300px 300px, 400px 400px, 500px 500px, 60px 60px, 60px 60px;
            animation: backgroundMoveBeginLoading 20s ease-in-out infinite;
            z-index: 1;
        }

        .geometric-shapesBeginLoading {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .shapeBeginLoading {
            position: absolute;
            opacity: 0.1;
            animation: floatBeginLoading 15s ease-in-out infinite;
        }

        .shape-1BeginLoading {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #4caf50, #81c784);
            border-radius: 20px;
            top: 15%;
            left: 10%;
            animation-delay: 0s;
            transform: rotate(45deg);
        }

        .shape-2BeginLoading {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #66bb6a, #a5d6a7);
            border-radius: 50%;
            top: 25%;
            right: 15%;
            animation-delay: -3s;
        }

        .shape-3BeginLoading {
            width: 100px;
            height: 100px;
            background: linear-gradient(90deg, #81c784, #c8e6c9);
            border-radius: 30px;
            bottom: 20%;
            left: 5%;
            animation-delay: -6s;
            transform: rotate(30deg);
        }

        .shape-4BeginLoading {
            width: 70px;
            height: 70px;
            background: linear-gradient(180deg, #4caf50, #66bb6a);
            clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
            bottom: 30%;
            right: 20%;
            animation-delay: -9s;
        }

        .shape-5BeginLoading {
            width: 90px;
            height: 90px;
            background: linear-gradient(225deg, #81c784, #a5d6a7);
            border-radius: 50% 0 50% 0;
            top: 60%;
            left: 20%;
            animation-delay: -12s;
        }

        .loading-containerBeginLoading {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 90%;
            max-width: 400px;
            padding: 30px 20px 20px;
        }

        .logoBeginLoading {
            text-align: center;
            margin-bottom: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-iconBeginLoading {
            width: 250px;
           margin-bottom: 15px;
        }

        .logoBeginLoading h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: -0.5px;
        }

        .logoBeginLoading p {
            font-size: 1rem;
          opacity: 0.9;
            font-weight: 400;
            line-height: 1.4;
            color: #2e7d32;
        }

        .featuresBeginLoading {
            width: 100%;
            margin: 20px 0 30px;
        }

        .feature-itemBeginLoading {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid rgba(46, 125, 50, 0.2);
            opacity: 1;
        }

        .feature-itemBeginLoading:last-child {
            border-bottom: none;
        }

        /*.feature-itemBeginLoading:nth-child(1) { animation-delay: 0.3s; }
        .feature-itemBeginLoading:nth-child(2) { animation-delay: 0.5s; }
        .feature-itemBeginLoading:nth-child(3) { animation-delay: 0.7s; }
        .feature-itemBeginLoading:nth-child(4) { animation-delay: 0.9s; }*/

        .feature-itemBeginLoading i {
            font-size: 1.5rem;
            color: #4caf50;
            margin-right: 16px;
            width: 30px;
            text-align: center;
        }

        .feature-itemBeginLoading span {
            font-size: 1rem;
            line-height: 1.4;
            color: #2e7d32;
        }

        .copyrightBeginLoading {
            margin-top: 20px;
            text-align: center;
            font-size: 0.85rem;
            color: #2e7d32;
            opacity: 0.8;
            padding-top: 15px;
            border-top: 1px solid rgba(46, 125, 50, 0.2);
        }

        .copyrightBeginLoading .company-nameBeginLoading {
            font-weight: 600;
            color: #1b5e20;
        }

        .loading-textBeginLoading {
            margin-top: 20px;
            font-size: 1rem;
            opacity: 0.8;
            display: flex;
            align-items: center;
            color: #2e7d32;
        }

        .loading-dotsBeginLoading {
            display: inline-block;
            width: 20px;
            text-align: left;
        }

        .loading-dotsBeginLoading::after {
            content: '''';
            animation: dotsBeginLoading 1.5s infinite;
        }

        @keyframes dotsBeginLoading {
            0%, 20% { content: ''.''; }
            40% { content: ''..''; }
            60%, 100% { content: ''...''; }
        }

        @keyframes fadeInBeginLoading {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInBeginLoading {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes backgroundMoveBeginLoading {
            0%, 100% {
                background-position: 0% 0%, 0% 0%, 0% 0%, 0% 0%, 0% 0%;
            }
            50% {
                background-position: 100% 100%, 100% 100%, 100% 100%, 30px 30px, -30px 30px;
            }
        }

        @keyframes floatBeginLoading {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }
            33% {
                transform: translateY(-20px) rotate(120deg);
            }
            66% {
                transform: translateY(10px) rotate(240deg);
            }
        }

        .decorative-elementBeginLoading {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(76, 175, 80, 0.08) 0%, transparent 70%);
            z-index: 1;
        }

        .decorative-elementBeginLoading:nth-child(1) {
            width: 150px;
            height: 150px;
            top: -50px;
            right: -50px;
            animation: floatBeginLoading 12s ease-in-out infinite;
        }

        .decorative-elementBeginLoading:nth-child(2) {
            width: 200px;
            height: 200px;
            bottom: -80px;
            left: -80px;
            animation: floatBeginLoading 15s ease-in-out infinite reverse;
        }
</style>


<script>

</script>
<div class="BeginLoading">
    <div class="background-patternBeginLoading"></div>
    <div class="geometric-shapesBeginLoading">
        <div class="shapeBeginLoading shape-1BeginLoading"></div>
        <div class="shapeBeginLoading shape-2BeginLoading"></div>
        <div class="shapeBeginLoading shape-3BeginLoading"></div>
        <div class="shapeBeginLoading shape-4BeginLoading"></div>
        <div class="shapeBeginLoading shape-5BeginLoading"></div>
    </div>
    <div class="decorative-elementBeginLoading"></div>
    <div class="decorative-elementBeginLoading"></div>

    <div class="loading-containerBeginLoading">
        <div class="logoBeginLoading">
            <img src="https://cdn.paradisehrm.com/Image/BackgroundMobile/paradiselogomain.jpg" onerror="this.onerror=null;this.src=''/CDN/Image/BackgroundMobile/paradiselogomain.jpg'';"
                alt="ParadiseHRM" class="logo-iconBeginLoading">
            <p>Giải pháp hiệu quả cho doanh nghiệp</p>
        </div>
		
		<div class="spinner-border" role="status" style="
			width: 4rem;
			aspect-ratio: 1;
			height: unset;
		">
			<span class="visually-hidden">Loading...</span>
		</div>

        <div class="featuresBeginLoading">
            <div class="feature-itemBeginLoading">
                <i class="fas fa-clock"></i>
                <span>Chấm công đa nền tảng</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-calculator"></i>
                <span>Tính lương tự động chính xác</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-chart-line"></i>
                <span>Báo cáo nhân sự thông minh</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-shield-alt"></i>
                <span>Bảo mật dữ liệu cao cấp</span>
            </div>
        </div>

        <div class="copyrightBeginLoading">
            © 2025 <span class="company-nameBeginLoading">Vietinsoft Co. Ltd</span><br>
            All rights reserved
        </div>
    </div>
</div>
<div id="appapp" style="width:100%;">
        <div id="drawer">
	<script>
				function ShowWaitingPanel(){
					$(".BeginLoading").show();
				}
				function HideWaitingPanel(){
					$(".BeginLoading").hide();
					document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
				}
								
				document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
			    
            </script>
			<script>
				function createTextboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDateboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDateBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDateBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createTextAreaControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextArea(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextArea("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createCheckboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxCheckBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxCheckBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRadioGroupControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxRadioGroup(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxRadioGroup("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createNumberboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxNumberBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxNumberBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createColorBoxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxColorBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxColorBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureEditControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					config.visible = false;
					div[0].option = config;
					let img = $("<img>").addClass("img-fluid");
					if (config.value) img.attr("src", "data:image/jpg;base64," + config.value);
					let fileUpload = $("<div>");
					div.addClass("p-2").append(img, fileUpload);
					config.value = null;
					fileUpload.dxFileUploader({
						dialogTrigger: div,
						dropZone: div,
						...div[0].option,
					});

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureBoxControl(div, config, paramsControl, optionsControl) {
					let img = $("<img>").addClass("img-fluid");
					div.addClass("p-2").append(img);
					return div;
				}

				function createFileButtonControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					let fileUpload = $("<div>");
					let fileButton = $("<div>").dxButton({
						...config,
						onInitialized: function (arg) {
							if (config.ControlBackColor)
								arg.element.css("background-color", config.ControlBackColor);
							if (config.ControlForeColor)
								arg.element.css("color", config.ControlForeColor);
						},
					});

					fileUpload.dxFileUploader({
						...config,
						buttonInstance: fileButton.dxButton("instance"),
						accept: "*",
						dialogTrigger: fileButton,
						multiple: false,
						visible: false,
					});
					div.append(fileButton, fileUpload);

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownButtonControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownButton(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							div.dxDropDownButton("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDropDownBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createGridControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div[0].option.onCellClick = function (e) { };
					div.dxDataGrid(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDataGrid("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createListControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxList(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxList("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPDFViewerControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var viewer = new ej.pdfviewer.PdfViewer({
						documentPath:
							"https://cdn.syncfusion.com/Content/pdf/pdf-succinctly.pdf",
						resourceUrl:
							"https://cdn.syncfusion.com/ej2/23.2.6/dist/ej2-pdfviewer-lib",
					});
					viewer.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = viewer;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRichTextControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl = "https://services.syncfusion.com/js/production/";
					var defaultRTE = new ej.richtexteditor.RichTextEditor({
						toolbarSettings: {
							items: [
								"Undo",
								"Redo",
								"|",
								"ImportWord",
								"ExportWord",
								"ExportPdf",
								"|",
								"Bold",
								"Italic",
								"Underline",
								"StrikeThrough",
								"InlineCode",
								"SuperScript",
								"SubScript",
								"|",
								"FontName",
								"FontSize",
								"FontColor",
								"BackgroundColor",
								"|",
								"LowerCase",
								"UpperCase",
								"|",
								"Formats",
								"Alignments",
								"Blockquote",
								"|",
								"NumberFormatList",
								"BulletFormatList",
								"|",
								"Outdent",
								"Indent",
								"|",
								"CreateLink",
								"Image",
								"FileManager",
								"Video",
								"Audio",
								"CreateTable",
								"|",
								"FormatPainter",
								"ClearFormat",
								"|",
								"EmojiPicker",
								"Print",
								"|",
								"SourceCode",
								"FullScreen",
							],
						},
						slashMenuSettings: {
							enable: true,
							items: [
								"Paragraph",
								"Heading 1",
								"Heading 2",
								"Heading 3",
								"Heading 4",
								"OrderedList",
								"UnorderedList",
								"CodeBlock",
								"Blockquote",
								"Link",
								"Image",
								"Video",
								"Audio",
								"Table",
								"Emojipicker",
							],
						},
						insertImageSettings: {
							saveUrl: hostUrl + "api/RichTextEditor/SaveFile",
							removeUrl: hostUrl + "api/RichTextEditor/DeleteFile",
							path: hostUrl + "RichTextEditor/",
						},
						importWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ImportFromWord",
						},
						exportWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ExportToDocx",
							fileName: "RichTextEditor.docx",
							stylesheet: `
					.e-rte-content {
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						exportPdf: {
							serviceUrl:
								"https://ej2services.syncfusion.com/js/development/api/RichTextEditor/ExportToPdf",
							fileName: "RichTextEditor.pdf",
							stylesheet: `
					.e-rte-content{
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						fileManagerSettings: {
							enable: true,
							path: "/Pictures/Food",
							ajaxSettings: {
								url: "https://ej2-aspcore-service.azurewebsites.net/api/FileManager/FileOperations",
								getImageUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/GetImage",
								uploadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Upload",
								downloadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Download",
							},
						},
						quickToolbarSettings: {
							table: [
								"TableHeader",
								"TableRows",
								"TableColumns",
								"TableCell",
								"-",
								"BackgroundColor",
								"TableRemove",
								"TableCellVerticalAlign",
								"Styles",
							],
							showOnRightClick: true,
						},
						enableXhtml: true,
						showCharCount: true,
						enableTabKey: true,
						placeholder: "Type something or use @ to tag a user...",
						option: function(name, value) {
							if (typeof value === "undefined") return this[name];

							if(this[name] === value) return;

							this[name] = value;
						},
						...config
					});
					defaultRTE.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = defaultRTE;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createBarCodeControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var barcode = new ej.barcodegenerator.QRCodeGenerator({
						width: config.width,
						height: config.height,
						mode: "SVG",
						type: config.BarCodeType,
						displayText: { visibility: false },
						value: "",
					});
					barcode.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = barcode;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function CreateHTMLControl(div, config, paramsControl, optionsControl) {
					let html = $(config.value);
					return html;
				}

				function CreateHyperLinkControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					if (config.onInitialized) config.onInitialized(config);
					div[0].option = config;
					div[0].option.element = div;
					div.append(
						$("<a>")
							.attr("href", "#")
							.text(config.Message)
							.on("click", (event) => {
								event.preventDefault();
								config.openFormAction(
									paramsControl[config.ControlNameParam].value
								);
							})
					);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div[0].option;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function onGridViewCellClick(t) {
					let s = t.cellElement;
					let config = { ...t.column };
					config.value = t.value;
					s.html(
						window[t.column.CreateControlFunction]
							? window[t.column.CreateControlFunction](null, config)
							: t.displayValue
					);
				}

				function convertSqlToJsCondition(sqlCondition, objectName) {
					sqlCondition = sqlCondition
						.replace(/LIKE\s+''%([^%]+)%''/gi, ''.includes("$1")'') // Contains
						.replace(/LIKE\s+''%([^%]+)''/gi, ''.endsWith("$1")'') // Ends with
						.replace(/LIKE\s+''([^%]+)%''/gi, ''.startsWith("$1")''); // Starts with

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+IN\s+\(([^)]+)\)/gi,
						(match, field, values) => {
							const jsValues = values.split(",").map((v) => v.trim());
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `[${jsValues.join(", ")}].includes(${field})`;
						}
					);

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+BETWEEN\s+([\w\d\.\-]+)\s+AND\s+([\w\d\.\-]+)/gi,
						(match, field, start, end) => {
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `(${field} >= ${start} && ${field} <= ${end})`;
						}
					);

					if (objectName) {
						sqlCondition = sqlCondition.replace(
							/\[([\w]+)\]/g,
							`${objectName}["$1"]`
						);
					} else {
						sqlCondition = sqlCondition.replace(/\[([\w]+)\]/g, "$1");
					}

					return sqlCondition
						.replace(/=/g, "==") // Replace "=" with "=="
						.replace(/(>|<)==/g, "$1=") // Replace ">|<==" with ">|<="
						.replace(/is not null/gi, "!== null") // Convert "is not null"
						.replace(/is null/gi, "=== null") // Convert "is null"
						.replace(/\band\b/gi, "&&") // Convert "And" to "&&"
						.replace(/\bor\b/gi, "||") // Convert "Or" to "||"
						.replace(/<>/g, "!="); // Replace "<>" with "!="
				}

				function evaluateCondition(condition, context = {}) {
					try {
						const func = new Function(
							...Object.keys(context),
							`return ${condition};`
						);
						return func(...Object.values(context));
					} catch (error) {
						console.error(condition);
						console.error("Error evaluating condition:", error);
						return false;
					}
				}

				function ParseDefineAction(str) {
					let parts = str.split("|");
					let result = {};
					parts
						.filter((x) => x)
						.forEach((item) => {
							if ((item.match(/=/g) || []).length > 1) {
								let [tmpKey, tmpValue] = item.split(/=(.*)/s);
								tmpValue = tmpValue.split("&");
								let tmpValue1 = {};

								if (tmpValue[0] && tmpValue[0].startsWith("?ExportName")) {
									tmpValue1.OnExportParams = {};
									tmpValue[0] = tmpValue[0].replace(
										"?ExportName",
										"ExportName"
									);
									tmpValue.forEach((tmpItem) => {
										let [key, ...rest] = tmpItem.split("=");
										if (rest.length > 1) {
											let tmpValue2 = [];
											rest.join("=")
												.split("_")
												.forEach((tmpItem1) => {
													let [key, value] = tmpItem1.split("=");
													tmpValue2.push(key);
													tmpValue2.push(value);
												});

											tmpValue1.OnExportParams[key.replace("@", "")] =
												tmpValue2;
										} else
											tmpValue1.OnExportParams[key.replace("@", "")] =
												rest.join("=");
									});
								} else
									tmpValue.forEach((tmpItem) => {
										let [key, value] = tmpItem.split("=");
										tmpValue1[key.replace("@", "")] = value;
									});
								result[tmpKey.replace("@", "")] = tmpValue1;
							} else {
								let [key, value] = item.split("=");
								if (key == "Object" && value && value.includes(".")) {
									let tmpValue1 = {};
									value = value.split(".");
									tmpValue1.ActionDefineType = value[0];
									tmpValue1.ClassName = value[1];
									value = tmpValue1;
								}

								result[key.replace("@", "")] = value;
							}
						});
					return result;
				}

				function convertToHTML(inputString) {
					inputString = inputString.replace(/<color=(.*?)>/gi, (match, color) => {
						const validColor = isValidCSSColor(color)
							? color
							: convertRGBToHex(color);
						return `<span style="color: ${validColor};">`;
					});
					inputString = inputString.replace(/<\/color>/gi, "</span>");

					// inputString = inputString.replace(/<size=\+(\d+)>/gi, (match, p1) => `<span style="font-size: ${parseInt(p1) + windowFontSize}px;">`);
					// inputString = inputString.replace(/<size=-(\d+)>/gi, (match, p1) => `<span style="font-size: ${windowFontSize - parseInt(p1)}px;">`);
					// inputString = inputString.replace(/<size=(\d+)>/gi, (match, size) => `<span style="font-size: ${size}px;">`);
					inputString = inputString.replace(
						/<size=([+-]?\d+|{[\d]+}|[\d]+[a-z%]*)>/gi,
						(match, size) => {
							const parsedSize = parseSize(size);
							return `<span style="font-size: ${parsedSize};">`;
						}
					);
					inputString = inputString.replace(/<\/size>/gi, "</span>");

					inputString = inputString.replace(
						/<href=(.*?)>(.*?)<\/href>/g,
						''<a href="$1" target="_blank">$2</a>''
					);

					inputString = inputString.replace(/<br>/g, "<br/>");

					inputString = inputString.replace(/<b>/gi, "<strong>");
					inputString = inputString.replace(/<\/b>/gi, "</strong>");

					inputString = inputString.replace(
						/<u>/gi,
						''<span style="text-decoration: underline;">''
					);
					inputString = inputString.replace(/<\/u>/gi, "</span>");

					return inputString;
				}

				function convertRGBToHex(rgb) {
					let rgbArray = rgb.split(",").map((num) => parseInt(num.trim()));
					if (rgbArray.length === 3) {
						return `#${rgbArray
							.map((num) => num.toString(16).padStart(2, "0"))
							.join("")}`;
					}
					return rgb;
				}

				function isValidCSSColor(color) {
					let s = new Option().style;
					s.color = color;
					return s.color !== "";
				}

				function parseSize(size) {
					if (size.startsWith("{") && size.endsWith("}")) {
						return `${size.slice(1, -1)}px`;
					} else if (/^\d+x$/.test(size)) {
						return `${parseInt(size)}em`;
					} else if (/^[+-]?\d+$/.test(size)) {
						let baseFontSize = parseInt(
							window.getComputedStyle(document.documentElement).fontSize,
							10
						);
						let sizeAdjustment = parseInt(size);
						let newSize = baseFontSize + sizeAdjustment;
						return `${newSize}px`;
					} else if (/^\d+$/.test(size)) {
						return `${size}px`;
					}
					return size;
				}

				function runSPActionFunction(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					AjaxHPAParadiseParadise({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				async function runSPActionFunctionAsync(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					await AjaxHPAParadiseParadiseAsync({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				function showPopupNotify(
					title,
					content,
					btnOKText = "OK",
					popupWidth = "15vw",
					closePopupFunction = () => { }
				) {
					var myDialog = DevExpress.ui.dialog.custom({
						title: title,
						messageHtml: `<div style="width: ${popupWidth}">${content}</div>`,
						buttons: [
							{
								text: btnOKText,
								onClick: function (e) {
									return true;
								},
							},
						],
					});
					myDialog.show().done(function () {
						closePopupFunction();
					});
				}

				function decodeHtmlEntities(str) {
					const txt = document.createElement("textarea");
					txt.innerHTML = str;
					return txt.value;
				}

				function copyViaExcelExport(
					gridInstance,
					isSelectedRowsOnly = false,
					copyWithHeader = false,
					loadPanelmessage = "Copying"
				) {
					let workbook = new ExcelJS.Workbook();
					let sheet = workbook.addWorksheet("dummy");
					let str = "";

					let col = gridInstance.getVisibleColumns();
					col = col.filter((x) => x.dataField !== undefined && x.allowExporting);
					let lastColumn = col[col.length - 1].dataField;

					DevExpress.excelExporter
						.exportDataGrid({
							component: gridInstance,
							worksheet: sheet,
							selectedRowsOnly: isSelectedRowsOnly,
							loadPanel: {
								showPane: false,
								message: loadPanelmessage,
							},
							customizeCell: function (options) {
								let { gridCell } = options;
								let field = gridCell.column.dataField;

								switch (gridCell.rowType) {
									case "header" && copyWithHeader:
										str += `${gridCell.column.caption}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "data":
										if (gridCell.column.dropdownSource) {
											gridCell.value =
												gridCell.column.dropdownSource.find(
													(x) =>
														x[gridCell.column.keyExpr] ==
														gridCell.data[gridCell.column.dataField]
												)?.[gridCell.column.displayExpr] ??
												(gridCell.value ? gridCell.value : "");
										} else if (
											gridCell.column.CreateControlFunction ==
											"createCheckboxControl"
										) {
											gridCell.value = gridCell.value
												? String.fromCharCode(parseInt("2713", 16))
												: "";
										} else if (
											gridCell.column.CreateControlFunction ==
											"createDateboxControl"
										) {
											gridCell.value = DevExpress.localization.formatDate(
												gridCell.value,
												gridCell.column.displayFormat
											);
										} else {
											gridCell.value =
												gridCell.data[gridCell.column.dataField];
										}

										str += `${gridCell.value ?? ""}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}

										break;
									case "group":
										if (gridCell.value) str += `${gridCell.value} `;

										if (
											gridCell.groupSummaryItems !== undefined &&
											gridCell.groupSummaryItems.length >= 1
										) {
											gridCell.groupSummaryItems.forEach((x) => {
												str += ` ${x.name}: ${x.value} `;
											});
										}

										str += `\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "groupFooter":
										break;
									case "totalFooter":
										break;
									default:
										break;
								}
							},
						})
						.then(() => {
							navigator.clipboard.writeText(str).then(
								() => { },
								() => { }
							);
						});
				}
				function GetFormatDate(date, format = "yyyy-MM-dd HH:mm:ss") {
					return DevExpress.localization.formatDate(new Date(date), format);
				}
				if (!Object.filter)
					Object.filter = (obj, predicate) =>
						Object.keys(obj)
							.filter((key) => predicate(obj[key], key))
							.reduce((res, key) => ((res[key] = obj[key]), res), {});
				
				if (!Object.findValue)
					Object.findValue = function (obj, key) {
						if (!obj) return undefined;
						let match = Object.keys(obj).find(k => k.toLowerCase() === key.toLowerCase());
						return match ? obj[match] : undefined;
					};

				function getArrayTypeDistinct(arr) {
					return [...new Set(arr.map((x) => typeof x))];
				}

				function createConditionQuery(filter, schema, comboBoxColumn) {
					let condition = ``;
					if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						["=", "<", ">"].includes(filter[1])
					) {
						if (filter[2] == null) {
							filter[0] = `ISNULL(${filter[0]} , '''')`;
							filter[2] = "''''";
						} else if (typeof filter[2] == "object") {
							filter[2] = "''" + filter[2].toISOString() + "''";
						} else if (typeof filter[2] == "number") {
							filter[2] = "''" + filter[2].toString() + "''";
						}
					} else if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						Array.isArray(filter[2]) &&
						filter[2].length == 0
					) {
						filter.pop();
						filter.pop();
					}

					filter.forEach((item) => {
						let typeList = Array.isArray(item) ? getArrayTypeDistinct(item) : [];
						if (
							(Array.isArray(item) && typeList.length > 1) ||
							(Array.isArray(item) &&
								typeList.length == 1 &&
								typeList[0] == "object")
						) {
							condition += `(${createConditionQuery(
								item,
								schema,
								comboBoxColumn
							)})`;
						} else if (Array.isArray(item) && typeList.length == 1) {
							condition += `${item[0]}`;
							if (
								schema &&
								schema.find((x) => x.name == item[0]).type == "System.String"
							)
								condition += " COLLATE Latin1_General_CI_AI";
							if (comboBoxColumn && comboBoxColumn.includes(item[0]))
								condition += ` like N''${item[2]}''`;
							else
								condition += `${
									item[1] == "contains"
										? ` like N''%${item[2]}%''`
										: ` = N''${item[2]}''`
								}`;
						} else
							condition +=
								" " +
								(item == null
									? "NULL"
									: item.toLocaleString().toLocaleUpperCase()) +
								" ";
					});

					return condition;
				}

				function createParamString(param) {
					let paramString = "";
					for (let index = 0; index < param.length; index += 2) {
						if (index > 0) paramString += ", ";
						paramString += `${param[index]} = N''''${param[index + 1]}''''`;
					}
					return paramString;
				}

				function transformDateToHierarchy(data) {
					let result = [],
						col0Map = new Map();

					data.forEach(({ col0, col1, col2, col3, col4, col5, totalCount }) => {
						if (!col0Map.has(col0)) {
							let col0Obj = { key: col0, items: [] };
							col0Map.set(col0, col0Obj);
							result.push(col0Obj);
						}

						if (!col1) return;

						let col0Obj = col0Map.get(col0),
							col1Map = col0Obj._col1Map || new Map();

						if (!col1Map.has(col1)) {
							let col1Obj = { key: col1, items: [] };
							if (col2) col1Obj.count = totalCount;
							col1Map.set(col1, col1Obj);
							col0Obj.items.push(col1Obj);
						}

						col0Obj._col1Map = col1Map;

						if (!col2) return;

						let col1Obj = col1Map.get(col1),
							col2Map = col1Obj._col2Map || new Map();

						if (!col2Map.has(col2)) {
							let col2Obj = { key: col2, items: [] };
							if (col3) col1Obj.count = totalCount;
							col2Map.set(col2, col2Obj);
							col1Obj.items.push(col2Obj);
						}

						col1Obj._col2Map = col2Map;

						if (!col3) return;

						let col2Obj = col2Map.get(col2),
							col3Map = col2Obj._col3Map || new Map();

						if (!col3Map.has(col3)) {
							let col3Obj = { key: col3, items: [] };
							if (col4) col2Obj.count = totalCount;
							col3Map.set(col3, col3Obj);
							col2Obj.items.push(col3Obj);
						}

						col2Obj._col3Map = col3Map;

						if (!col4) return;

						let col3Obj = col3Map.get(col3),
							col4Map = col3Obj._col4Map || new Map();

						if (!col4Map.has(col4)) {
							let col4Obj = { key: col4, items: [] };
							if (col5) col3Obj.count = totalCount;
							col4Map.set(col4, col4Obj);

							col3Obj.items.push(col4Obj);
						}

						col3Obj._col4Map = col4Map;

						if (col5 != undefined) {
							let col4Obj = col4Map.get(col4);
							col4Obj.items.push({
								key: col5,
								items: null,
								count: totalCount,
							});
						}
					});

					return result;
				};

			</script>
            <div id="main-layout-diagram" style="overflow-x:hidden; overflow-y:auto; display:block">' as [html],NULL as [HtmlStatus],N'A96' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbody' as [TableName],N'vn' as [LanguageID],N'1' as [ScreenType],N'<script>
(async()=>{
    try {
        let b = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": [`delete from tblParameter where code like ''''debug'''';
INSERT INTO tblParameter ([Code], [Value]) select ''''Debug'''' [Code], ''''1'''' [Value];`],})
        console.log(b)
        let a = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": ["select Code, Value from tblParameter where code like ''''debug''''"],})
        console.log(a)
    } catch (error) {
    }
	if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
        window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
        window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
     }
})();
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.0/font/bootstrap-icons.min.css">

<style type="text/css"> 
	#RightMenu {display: none !important;}
	.BeginLoading {

            overflow: hidden;
            height: 100vh;
            background: linear-gradient(135deg, #e8f5e8, #f9f9f9, #e7f3e7);
            position: relative;
            color: #2e7d32;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999
        }

        .background-patternBeginLoading {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(76, 175, 80, 0.1) 0%, transparent 25%),
                radial-gradient(circle at 80% 70%, rgba(129, 199, 132, 0.08) 0%, transparent 30%),
                radial-gradient(circle at 50% 50%, rgba(102, 187, 106, 0.05) 0%, transparent 40%),
                linear-gradient(45deg, transparent 48%, rgba(255, 255, 255, 0.05) 50%, transparent 52%),
                linear-gradient(-45deg, transparent 48%, rgba(255, 255, 255, 0.03) 50%, transparent 52%);
            background-size: 300px 300px, 400px 400px, 500px 500px, 60px 60px, 60px 60px;
            animation: backgroundMoveBeginLoading 20s ease-in-out infinite;
            z-index: 1;
        }

        .geometric-shapesBeginLoading {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .shapeBeginLoading {
            position: absolute;
            opacity: 0.1;
            animation: floatBeginLoading 15s ease-in-out infinite;
        }

        .shape-1BeginLoading {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #4caf50, #81c784);
            border-radius: 20px;
            top: 15%;
            left: 10%;
            animation-delay: 0s;
            transform: rotate(45deg);
        }

        .shape-2BeginLoading {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #66bb6a, #a5d6a7);
            border-radius: 50%;
            top: 25%;
            right: 15%;
            animation-delay: -3s;
        }

        .shape-3BeginLoading {
            width: 100px;
            height: 100px;
            background: linear-gradient(90deg, #81c784, #c8e6c9);
            border-radius: 30px;
            bottom: 20%;
            left: 5%;
            animation-delay: -6s;
            transform: rotate(30deg);
        }

        .shape-4BeginLoading {
            width: 70px;
            height: 70px;
            background: linear-gradient(180deg, #4caf50, #66bb6a);
            clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
            bottom: 30%;
            right: 20%;
            animation-delay: -9s;
        }

        .shape-5BeginLoading {
            width: 90px;
            height: 90px;
            background: linear-gradient(225deg, #81c784, #a5d6a7);
            border-radius: 50% 0 50% 0;
            top: 60%;
            left: 20%;
            animation-delay: -12s;
        }

        .loading-containerBeginLoading {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 90%;
            max-width: 400px;
            padding: 30px 20px 20px;
        }

        .logoBeginLoading {
            text-align: center;
            margin-bottom: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-iconBeginLoading {
            width: 250px;
           margin-bottom: 15px;
        }

        .logoBeginLoading h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: -0.5px;
        }

        .logoBeginLoading p {
            font-size: 1rem;
          opacity: 0.9;
            font-weight: 400;
            line-height: 1.4;
            color: #2e7d32;
        }

        .featuresBeginLoading {
            width: 100%;
            margin: 20px 0 30px;
        }

        .feature-itemBeginLoading {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid rgba(46, 125, 50, 0.2);
            opacity: 1;
        }

        .feature-itemBeginLoading:last-child {
            border-bottom: none;
        }

        /*.feature-itemBeginLoading:nth-child(1) { animation-delay: 0.3s; }
        .feature-itemBeginLoading:nth-child(2) { animation-delay: 0.5s; }
        .feature-itemBeginLoading:nth-child(3) { animation-delay: 0.7s; }
        .feature-itemBeginLoading:nth-child(4) { animation-delay: 0.9s; }*/

        .feature-itemBeginLoading i {
            font-size: 1.5rem;
            color: #4caf50;
            margin-right: 16px;
            width: 30px;
            text-align: center;
        }

        .feature-itemBeginLoading span {
            font-size: 1rem;
            line-height: 1.4;
            color: #2e7d32;
        }

        .copyrightBeginLoading {
            margin-top: 20px;
            text-align: center;
            font-size: 0.85rem;
            color: #2e7d32;
            opacity: 0.8;
            padding-top: 15px;
            border-top: 1px solid rgba(46, 125, 50, 0.2);
        }

        .copyrightBeginLoading .company-nameBeginLoading {
            font-weight: 600;
            color: #1b5e20;
        }

        .loading-textBeginLoading {
            margin-top: 20px;
            font-size: 1rem;
            opacity: 0.8;
            display: flex;
            align-items: center;
            color: #2e7d32;
        }

        .loading-dotsBeginLoading {
            display: inline-block;
            width: 20px;
            text-align: left;
        }

        .loading-dotsBeginLoading::after {
            content: '';
            animation: dotsBeginLoading 1.5s infinite;
        }

        @keyframes dotsBeginLoading {
            0%, 20% { content: ''.''; }
            40% { content: ''..''; }
            60%, 100% { content: ''...''; }
        }

        @keyframes fadeInBeginLoading {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInBeginLoading {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes backgroundMoveBeginLoading {
            0%, 100% {
                background-position: 0% 0%, 0% 0%, 0% 0%, 0% 0%, 0% 0%;
            }
            50% {
                background-position: 100% 100%, 100% 100%, 100% 100%, 30px 30px, -30px 30px;
            }
        }

        @keyframes floatBeginLoading {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }
            33% {
                transform: translateY(-20px) rotate(120deg);
            }
            66% {
                transform: translateY(10px) rotate(240deg);
            }
        }

        .decorative-elementBeginLoading {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(76, 175, 80, 0.08) 0%, transparent 70%);
            z-index: 1;
        }

        .decorative-elementBeginLoading:nth-child(1) {
            width: 150px;
            height: 150px;
            top: -50px;
            right: -50px;
            animation: floatBeginLoading 12s ease-in-out infinite;
        }

        .decorative-elementBeginLoading:nth-child(2) {
            width: 200px;
            height: 200px;
            bottom: -80px;
            left: -80px;
            animation: floatBeginLoading 15s ease-in-out infinite reverse;
        }
</style>


<script>

</script>
<div class="BeginLoading">
    <div class="background-patternBeginLoading"></div>
    <div class="geometric-shapesBeginLoading">
        <div class="shapeBeginLoading shape-1BeginLoading"></div>
        <div class="shapeBeginLoading shape-2BeginLoading"></div>
        <div class="shapeBeginLoading shape-3BeginLoading"></div>
        <div class="shapeBeginLoading shape-4BeginLoading"></div>
        <div class="shapeBeginLoading shape-5BeginLoading"></div>
    </div>
    <div class="decorative-elementBeginLoading"></div>
    <div class="decorative-elementBeginLoading"></div>

    <div class="loading-containerBeginLoading">
        <div class="logoBeginLoading">
            <img src="https://cdn.paradisehrm.com/Image/BackgroundMobile/paradiselogomain.jpg" onerror="this.onerror=null;this.src=''/CDN/Image/BackgroundMobile/paradiselogomain.jpg'';
                alt="ParadiseHRM" class="logo-iconBeginLoading">
            <p>Giải pháp hiệu quả cho doanh nghiệp</p>
        </div>
		
		<div class="spinner-border" role="status" style="
			width: 4rem;
			aspect-ratio: 1;
			height: unset;
		">
			<span class="visually-hidden">Loading...</span>
		</div>

        <div class="featuresBeginLoading">
            <div class="feature-itemBeginLoading">
                <i class="fas fa-clock"></i>
                <span>Chấm công đa nền tảng</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-calculator"></i>
                <span>Tính lương tự động chính xác</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-chart-line"></i>
                <span>Báo cáo nhân sự thông minh</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-shield-alt"></i>
                <span>Bảo mật dữ liệu cao cấp</span>
            </div>
        </div>

        <div class="copyrightBeginLoading">
            © 2025 <span class="company-nameBeginLoading">Vietinsoft Co. Ltd</span><br>
            All rights reserved
        </div>
    </div>
</div>
<div id="appapp" style="width:100%;">
        <div id="drawer">
	<script>
				function ShowWaitingPanel(){
					$(".BeginLoading").show();
				}
				function HideWaitingPanel(){
					$(".BeginLoading").hide();
					document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
				}
								
				document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
			    
            </script>
			<script>
				function createTextboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDateboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDateBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDateBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createTextAreaControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextArea(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextArea("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createCheckboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxCheckBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxCheckBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRadioGroupControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxRadioGroup(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxRadioGroup("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createNumberboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxNumberBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxNumberBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createColorBoxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxColorBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxColorBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureEditControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					config.visible = false;
					div[0].option = config;
					let img = $("<img>").addClass("img-fluid");
					if (config.value) img.attr("src", "data:image/jpg;base64," + config.value);
					let fileUpload = $("<div>");
					div.addClass("p-2").append(img, fileUpload);
					config.value = null;
					fileUpload.dxFileUploader({
						dialogTrigger: div,
						dropZone: div,
						...div[0].option,
					});

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureBoxControl(div, config, paramsControl, optionsControl) {
					let img = $("<img>").addClass("img-fluid");
					div.addClass("p-2").append(img);
					return div;
				}

				function createFileButtonControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					let fileUpload = $("<div>");
					let fileButton = $("<div>").dxButton({
						...config,
						onInitialized: function (arg) {
							if (config.ControlBackColor)
								arg.element.css("background-color", config.ControlBackColor);
							if (config.ControlForeColor)
								arg.element.css("color", config.ControlForeColor);
						},
					});

					fileUpload.dxFileUploader({
						...config,
						buttonInstance: fileButton.dxButton("instance"),
						accept: "*",
						dialogTrigger: fileButton,
						multiple: false,
						visible: false,
					});
					div.append(fileButton, fileUpload);

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownButtonControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownButton(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							div.dxDropDownButton("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDropDownBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createGridControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div[0].option.onCellClick = function (e) { };
					div.dxDataGrid(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDataGrid("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createListControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxList(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxList("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPDFViewerControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var viewer = new ej.pdfviewer.PdfViewer({
						documentPath:
							"https://cdn.syncfusion.com/Content/pdf/pdf-succinctly.pdf",
						resourceUrl:
							"https://cdn.syncfusion.com/ej2/23.2.6/dist/ej2-pdfviewer-lib",
					});
					viewer.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = viewer;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRichTextControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl = "https://services.syncfusion.com/js/production/";
					var defaultRTE = new ej.richtexteditor.RichTextEditor({
						toolbarSettings: {
							items: [
								"Undo",
								"Redo",
								"|",
								"ImportWord",
								"ExportWord",
								"ExportPdf",
								"|",
								"Bold",
								"Italic",
								"Underline",
								"StrikeThrough",
								"InlineCode",
								"SuperScript",
								"SubScript",
								"|",
								"FontName",
								"FontSize",
								"FontColor",
								"BackgroundColor",
								"|",
								"LowerCase",
								"UpperCase",
								"|",
								"Formats",
								"Alignments",
								"Blockquote",
								"|",
								"NumberFormatList",
								"BulletFormatList",
								"|",
								"Outdent",
								"Indent",
								"|",
								"CreateLink",
								"Image",
								"FileManager",
								"Video",
								"Audio",
								"CreateTable",
								"|",
								"FormatPainter",
								"ClearFormat",
								"|",
								"EmojiPicker",
								"Print",
								"|",
								"SourceCode",
								"FullScreen",
							],
						},
						slashMenuSettings: {
							enable: true,
							items: [
								"Paragraph",
								"Heading 1",
								"Heading 2",
								"Heading 3",
								"Heading 4",
								"OrderedList",
								"UnorderedList",
								"CodeBlock",
								"Blockquote",
								"Link",
								"Image",
								"Video",
								"Audio",
								"Table",
								"Emojipicker",
							],
						},
						insertImageSettings: {
							saveUrl: hostUrl + "api/RichTextEditor/SaveFile",
							removeUrl: hostUrl + "api/RichTextEditor/DeleteFile",
							path: hostUrl + "RichTextEditor/",
						},
						importWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ImportFromWord",
						},
						exportWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ExportToDocx",
							fileName: "RichTextEditor.docx",
							stylesheet: `
					.e-rte-content {
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						exportPdf: {
							serviceUrl:
								"https://ej2services.syncfusion.com/js/development/api/RichTextEditor/ExportToPdf",
							fileName: "RichTextEditor.pdf",
							stylesheet: `
					.e-rte-content{
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						fileManagerSettings: {
							enable: true,
							path: "/Pictures/Food",
							ajaxSettings: {
								url: "https://ej2-aspcore-service.azurewebsites.net/api/FileManager/FileOperations",
								getImageUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/GetImage",
								uploadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Upload",
								downloadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Download",
							},
						},
						quickToolbarSettings: {
							table: [
								"TableHeader",
								"TableRows",
								"TableColumns",
								"TableCell",
								"-",
								"BackgroundColor",
								"TableRemove",
								"TableCellVerticalAlign",
								"Styles",
							],
							showOnRightClick: true,
						},
						enableXhtml: true,
						showCharCount: true,
						enableTabKey: true,
						placeholder: "Type something or use @ to tag a user...",
						option: function(name, value) {
							if (typeof value === "undefined") return this[name];

							if(this[name] === value) return;

							this[name] = value;
						},
						...config
					});
					defaultRTE.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = defaultRTE;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createBarCodeControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var barcode = new ej.barcodegenerator.QRCodeGenerator({
						width: config.width,
						height: config.height,
						mode: "SVG",
						type: config.BarCodeType,
						displayText: { visibility: false },
						value: "",
					});
					barcode.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = barcode;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function CreateHTMLControl(div, config, paramsControl, optionsControl) {
					let html = $(config.value);
					return html;
				}

				function CreateHyperLinkControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					if (config.onInitialized) config.onInitialized(config);
					div[0].option = config;
					div[0].option.element = div;
					div.append(
						$("<a>")
							.attr("href", "#")
							.text(config.Message)
							.on("click", (event) => {
								event.preventDefault();
								config.openFormAction(
									paramsControl[config.ControlNameParam].value
								);
							})
					);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div[0].option;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function onGridViewCellClick(t) {
					let s = t.cellElement;
					let config = { ...t.column };
					config.value = t.value;
					s.html(
						window[t.column.CreateControlFunction]
							? window[t.column.CreateControlFunction](null, config)
							: t.displayValue
					);
				}

				function convertSqlToJsCondition(sqlCondition, objectName) {
					sqlCondition = sqlCondition
						.replace(/LIKE\s+''%([^%]+)%''/gi, ''.includes("$1")'') // Contains
						.replace(/LIKE\s+''%([^%]+)''/gi, ''.endsWith("$1")'') // Ends with
						.replace(/LIKE\s+''([^%]+)%''/gi, ''.startsWith("$1")''); // Starts with

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+IN\s+\(([^)]+)\)/gi,
						(match, field, values) => {
							const jsValues = values.split(",").map((v) => v.trim());
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `[${jsValues.join(", ")}].includes(${field})`;
						}
					);

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+BETWEEN\s+([\w\d\.\-]+)\s+AND\s+([\w\d\.\-]+)/gi,
						(match, field, start, end) => {
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `(${field} >= ${start} && ${field} <= ${end})`;
						}
					);

					if (objectName) {
						sqlCondition = sqlCondition.replace(
							/\[([\w]+)\]/g,
							`${objectName}["$1"]`
						);
					} else {
						sqlCondition = sqlCondition.replace(/\[([\w]+)\]/g, "$1");
					}

					return sqlCondition
						.replace(/=/g, "==") // Replace "=" with "=="
						.replace(/(>|<)==/g, "$1=") // Replace ">|<==" with ">|<="
						.replace(/is not null/gi, "!== null") // Convert "is not null"
						.replace(/is null/gi, "=== null") // Convert "is null"
						.replace(/\band\b/gi, "&&") // Convert "And" to "&&"
						.replace(/\bor\b/gi, "||") // Convert "Or" to "||"
						.replace(/<>/g, "!="); // Replace "<>" with "!="
				}

				function evaluateCondition(condition, context = {}) {
					try {
						const func = new Function(
							...Object.keys(context),
							`return ${condition};`
						);
						return func(...Object.values(context));
					} catch (error) {
						console.error(condition);
						console.error("Error evaluating condition:", error);
						return false;
					}
				}

				function ParseDefineAction(str) {
					let parts = str.split("|");
					let result = {};
					parts
						.filter((x) => x)
						.forEach((item) => {
							if ((item.match(/=/g) || []).length > 1) {
								let [tmpKey, tmpValue] = item.split(/=(.*)/s);
								tmpValue = tmpValue.split("&");
								let tmpValue1 = {};

								if (tmpValue[0] && tmpValue[0].startsWith("?ExportName")) {
									tmpValue1.OnExportParams = {};
									tmpValue[0] = tmpValue[0].replace(
										"?ExportName",
										"ExportName"
									);
									tmpValue.forEach((tmpItem) => {
										let [key, ...rest] = tmpItem.split("=");
										if (rest.length > 1) {
											let tmpValue2 = [];
											rest.join("=")
												.split("_")
												.forEach((tmpItem1) => {
													let [key, value] = tmpItem1.split("=");
													tmpValue2.push(key);
													tmpValue2.push(value);
												});

											tmpValue1.OnExportParams[key.replace("@", "")] =
												tmpValue2;
										} else
											tmpValue1.OnExportParams[key.replace("@", "")] =
												rest.join("=");
									});
								} else
									tmpValue.forEach((tmpItem) => {
										let [key, value] = tmpItem.split("=");
										tmpValue1[key.replace("@", "")] = value;
									});
								result[tmpKey.replace("@", "")] = tmpValue1;
							} else {
								let [key, value] = item.split("=");
								if (key == "Object" && value && value.includes(".")) {
									let tmpValue1 = {};
									value = value.split(".");
									tmpValue1.ActionDefineType = value[0];
									tmpValue1.ClassName = value[1];
									value = tmpValue1;
								}

								result[key.replace("@", "")] = value;
							}
						});
					return result;
				}

				function convertToHTML(inputString) {
					inputString = inputString.replace(/<color=(.*?)>/gi, (match, color) => {
						const validColor = isValidCSSColor(color)
							? color
							: convertRGBToHex(color);
						return `<span style="color: ${validColor};">`;
					});
					inputString = inputString.replace(/<\/color>/gi, "</span>");

					// inputString = inputString.replace(/<size=\+(\d+)>/gi, (match, p1) => `<span style="font-size: ${parseInt(p1) + windowFontSize}px;">`);
					// inputString = inputString.replace(/<size=-(\d+)>/gi, (match, p1) => `<span style="font-size: ${windowFontSize - parseInt(p1)}px;">`);
					// inputString = inputString.replace(/<size=(\d+)>/gi, (match, size) => `<span style="font-size: ${size}px;">`);
					inputString = inputString.replace(
						/<size=([+-]?\d+|{[\d]+}|[\d]+[a-z%]*)>/gi,
						(match, size) => {
							const parsedSize = parseSize(size);
							return `<span style="font-size: ${parsedSize};">`;
						}
					);
					inputString = inputString.replace(/<\/size>/gi, "</span>");

					inputString = inputString.replace(
						/<href=(.*?)>(.*?)<\/href>/g,
						''<a href="$1" target="_blank">$2</a>''
					);

					inputString = inputString.replace(/<br>/g, "<br/>");

					inputString = inputString.replace(/<b>/gi, "<strong>");
					inputString = inputString.replace(/<\/b>/gi, "</strong>");

					inputString = inputString.replace(
						/<u>/gi,
						''<span style="text-decoration: underline;">''
					);
					inputString = inputString.replace(/<\/u>/gi, "</span>");

					return inputString;
				}

				function convertRGBToHex(rgb) {
					let rgbArray = rgb.split(",").map((num) => parseInt(num.trim()));
					if (rgbArray.length === 3) {
						return `#${rgbArray
							.map((num) => num.toString(16).padStart(2, "0"))
							.join("")}`;
					}
					return rgb;
				}

				function isValidCSSColor(color) {
					let s = new Option().style;
					s.color = color;
					return s.color !== "";
				}

				function parseSize(size) {
					if (size.startsWith("{") && size.endsWith("}")) {
						return `${size.slice(1, -1)}px`;
					} else if (/^\d+x$/.test(size)) {
						return `${parseInt(size)}em`;
					} else if (/^[+-]?\d+$/.test(size)) {
						let baseFontSize = parseInt(
							window.getComputedStyle(document.documentElement).fontSize,
							10
						);
						let sizeAdjustment = parseInt(size);
						let newSize = baseFontSize + sizeAdjustment;
						return `${newSize}px`;
					} else if (/^\d+$/.test(size)) {
						return `${size}px`;
					}
					return size;
				}

				function runSPActionFunction(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					AjaxHPAParadiseParadise({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				async function runSPActionFunctionAsync(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					await AjaxHPAParadiseParadiseAsync({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				function showPopupNotify(
					title,
					content,
					btnOKText = "OK",
					popupWidth = "15vw",
					closePopupFunction = () => { }
				) {
					var myDialog = DevExpress.ui.dialog.custom({
						title: title,
						messageHtml: `<div style="width: ${popupWidth}">${content}</div>`,
						buttons: [
							{
								text: btnOKText,
								onClick: function (e) {
									return true;
								},
							},
						],
					});
					myDialog.show().done(function () {
						closePopupFunction();
					});
				}

				function decodeHtmlEntities(str) {
					const txt = document.createElement("textarea");
					txt.innerHTML = str;
					return txt.value;
				}

				function copyViaExcelExport(
					gridInstance,
					isSelectedRowsOnly = false,
					copyWithHeader = false,
					loadPanelmessage = "Copying"
				) {
					let workbook = new ExcelJS.Workbook();
					let sheet = workbook.addWorksheet("dummy");
					let str = "";

					let col = gridInstance.getVisibleColumns();
					col = col.filter((x) => x.dataField !== undefined && x.allowExporting);
					let lastColumn = col[col.length - 1].dataField;

					DevExpress.excelExporter
						.exportDataGrid({
							component: gridInstance,
							worksheet: sheet,
							selectedRowsOnly: isSelectedRowsOnly,
							loadPanel: {
								showPane: false,
								message: loadPanelmessage,
							},
							customizeCell: function (options) {
								let { gridCell } = options;
								let field = gridCell.column.dataField;

								switch (gridCell.rowType) {
									case "header" && copyWithHeader:
										str += `${gridCell.column.caption}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "data":
										if (gridCell.column.dropdownSource) {
											gridCell.value =
												gridCell.column.dropdownSource.find(
													(x) =>
														x[gridCell.column.keyExpr] ==
														gridCell.data[gridCell.column.dataField]
												)?.[gridCell.column.displayExpr] ??
												(gridCell.value ? gridCell.value : "");
										} else if (
											gridCell.column.CreateControlFunction ==
											"createCheckboxControl"
										) {
											gridCell.value = gridCell.value
												? String.fromCharCode(parseInt("2713", 16))
												: "";
										} else if (
											gridCell.column.CreateControlFunction ==
											"createDateboxControl"
										) {
											gridCell.value = DevExpress.localization.formatDate(
												gridCell.value,
												gridCell.column.displayFormat
											);
										} else {
											gridCell.value =
												gridCell.data[gridCell.column.dataField];
										}

										str += `${gridCell.value ?? ""}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}

										break;
									case "group":
										if (gridCell.value) str += `${gridCell.value} `;

										if (
											gridCell.groupSummaryItems !== undefined &&
											gridCell.groupSummaryItems.length >= 1
										) {
											gridCell.groupSummaryItems.forEach((x) => {
												str += ` ${x.name}: ${x.value} `;
											});
										}

										str += `\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "groupFooter":
										break;
									case "totalFooter":
										break;
									default:
										break;
								}
							},
						})
						.then(() => {
							navigator.clipboard.writeText(str).then(
								() => { },
								() => { }
							);
						});
				}
				function GetFormatDate(date, format = "yyyy-MM-dd HH:mm:ss") {
					return DevExpress.localization.formatDate(new Date(date), format);
				}
				if (!Object.filter)
					Object.filter = (obj, predicate) =>
						Object.keys(obj)
							.filter((key) => predicate(obj[key], key))
							.reduce((res, key) => ((res[key] = obj[key]), res), {});
				
				if (!Object.findValue)
					Object.findValue = function (obj, key) {
						if (!obj) return undefined;
						let match = Object.keys(obj).find(k => k.toLowerCase() === key.toLowerCase());
						return match ? obj[match] : undefined;
					};

				function getArrayTypeDistinct(arr) {
					return [...new Set(arr.map((x) => typeof x))];
				}

				function createConditionQuery(filter, schema, comboBoxColumn) {
					let condition = ``;
					if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						["=", "<", ">"].includes(filter[1])
					) {
						if (filter[2] == null) {
							filter[0] = `ISNULL(${filter[0]} , '''')`;
							filter[2] = "''''";
						} else if (typeof filter[2] == "object") {
							filter[2] = "''" + filter[2].toISOString() + "''";
						} else if (typeof filter[2] == "number") {
							filter[2] = "''" + filter[2].toString() + "''";
						}
					} else if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						Array.isArray(filter[2]) &&
						filter[2].length == 0
					) {
						filter.pop();
						filter.pop();
					}

					filter.forEach((item) => {
						let typeList = Array.isArray(item) ? getArrayTypeDistinct(item) : [];
						if (
							(Array.isArray(item) && typeList.length > 1) ||
							(Array.isArray(item) &&
								typeList.length == 1 &&
								typeList[0] == "object")
						) {
							condition += `(${createConditionQuery(
								item,
								schema,
								comboBoxColumn
							)})`;
						} else if (Array.isArray(item) && typeList.length == 1) {
							condition += `${item[0]}`;
							if (
								schema &&
								schema.find((x) => x.name == item[0]).type == "System.String"
							)
								condition += " COLLATE Latin1_General_CI_AI";
							if (comboBoxColumn && comboBoxColumn.includes(item[0]))
								condition += ` like N''${item[2]}''`;
							else
								condition += `${
									item[1] == "contains"
										? ` like N''%${item[2]}%''`
										: ` = N''${item[2]}''`
								}`;
						} else
							condition +=
								" " +
								(item == null
									? "NULL"
									: item.toLocaleString().toLocaleUpperCase()) +
								" ";
					});

					return condition;
				}

				function createParamString(param) {
					let paramString = "";
					for (let index = 0; index < param.length; index += 2) {
						if (index > 0) paramString += ", ";
						paramString += `${param[index]} = N''''${param[index + 1]}''''`;
					}
					return paramString;
				}

				function transformDateToHierarchy(data) {
					let result = [],
						col0Map = new Map();

					data.forEach(({ col0, col1, col2, col3, col4, col5, totalCount }) => {
						if (!col0Map.has(col0)) {
							let col0Obj = { key: col0, items: [] };
							col0Map.set(col0, col0Obj);
							result.push(col0Obj);
						}

						if (!col1) return;

						let col0Obj = col0Map.get(col0),
							col1Map = col0Obj._col1Map || new Map();

						if (!col1Map.has(col1)) {
							let col1Obj = { key: col1, items: [] };
							if (col2) col1Obj.count = totalCount;
							col1Map.set(col1, col1Obj);
							col0Obj.items.push(col1Obj);
						}

						col0Obj._col1Map = col1Map;

						if (!col2) return;

						let col1Obj = col1Map.get(col1),
							col2Map = col1Obj._col2Map || new Map();

						if (!col2Map.has(col2)) {
							let col2Obj = { key: col2, items: [] };
							if (col3) col1Obj.count = totalCount;
							col2Map.set(col2, col2Obj);
							col1Obj.items.push(col2Obj);
						}

						col1Obj._col2Map = col2Map;

						if (!col3) return;

						let col2Obj = col2Map.get(col2),
							col3Map = col2Obj._col3Map || new Map();

						if (!col3Map.has(col3)) {
							let col3Obj = { key: col3, items: [] };
							if (col4) col2Obj.count = totalCount;
							col3Map.set(col3, col3Obj);
							col2Obj.items.push(col3Obj);
						}

						col2Obj._col3Map = col3Map;

						if (!col4) return;

						let col3Obj = col3Map.get(col3),
							col4Map = col3Obj._col4Map || new Map();

						if (!col4Map.has(col4)) {
							let col4Obj = { key: col4, items: [] };
							if (col5) col3Obj.count = totalCount;
							col4Map.set(col4, col4Obj);

							col3Obj.items.push(col4Obj);
						}

						col3Obj._col4Map = col4Map;

						if (col5 != undefined) {
							let col4Obj = col4Map.get(col4);
							col4Obj.items.push({
								key: col5,
								items: null,
								count: totalCount,
							});
						}
					});

					return result;
				};

			</script>
            <div id="main-layout-diagram" style="overflow-x:hidden; overflow-y:auto; display:block">' as [html],NULL as [HtmlStatus],N'A96' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbody' as [TableName],N'vn' as [LanguageID],N'2' as [ScreenType],N'<script>
(async()=>{
    try {
        let b = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": [`delete from tblParameter where code like ''''debug'''';
INSERT INTO tblParameter ([Code], [Value]) select ''''Debug'''' [Code], ''''1'''' [Value];`],})
        console.log(b)
        let a = await apimobileAjaxAsync({}, {"MethodName": "MobileExecuteDataTable","prs": ["select Code, Value from tblParameter where code like ''''debug''''"],})
        console.log(a)
    } catch (error) {
    }
	if (ParadiseOption.AppInfoVersionString.length > 0 && ParadiseOption.AppInfoVersionString < 2024072015){
        window.AjaxHPAParadiseAsync = async function (n){n._Async=1;AjaxHPAParadise(n);let i=n.data,t=null;if(i.sendEncryption){let n=JSON.stringify(i);t=EncryptionStringEncryption(n);!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n));t||(t=await BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n,!0,""))}else t=JSON.stringify(n.data);return n.data=t,await $.ajax(n)}
        window.AjaxHPAParadise = function AjaxHPAParadise(n){n.url||(n.url=window.APPLICATIONADDRESS+"/hpa/paradise2",IsNullOrEmpty(window.paradiseparadise)||(n.url=window.APPLICATION_ADDRESS+"/hpa/paradise2"));n.type||(n.type="POST");n.cache||(n.cache=!1);let t=n.data;if(t.paradiseparadise=window.paradiseparadise,typeof t.sendEncryption=="undefined"&&(t.sendEncryption=!0),t.requestDateTime||(t.requestDateTime=DevExpress.localization.formatDate(new Date,"yyyy-MM-dd HH:mm:ss")),typeof t.requestTime=="undefined"&&(t.requestTime=7200),!n._Async){if(n.data=JSON.stringify(t),t.sendEncryption){let t=EncryptionStringEncryption(n.data);if(!t&&window.EncryptionStringEncryptionCore2&&(t=EncryptionStringEncryptionCore2(n.data)),!t){BlazorAppIndex.invokeMethodAsync("EncryptionStringEncryptionCore",n.data,!0,"").then(t=>{n.data=t,$.ajax(n)});return}}$.ajax(n)}}
     }
})();
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css"> <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.0/font/bootstrap-icons.min.css">

<style type="text/css"> 
	#RightMenu {display: none !important;}
	.BeginLoading {

            overflow: hidden;
            height: 100vh;
            background: linear-gradient(135deg, #e8f5e8, #f9f9f9, #e7f3e7);
            position: relative;
            color: #2e7d32;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999
        }

        .background-patternBeginLoading {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(76, 175, 80, 0.1) 0%, transparent 25%),
                radial-gradient(circle at 80% 70%, rgba(129, 199, 132, 0.08) 0%, transparent 30%),
                radial-gradient(circle at 50% 50%, rgba(102, 187, 106, 0.05) 0%, transparent 40%),
                linear-gradient(45deg, transparent 48%, rgba(255, 255, 255, 0.05) 50%, transparent 52%),
                linear-gradient(-45deg, transparent 48%, rgba(255, 255, 255, 0.03) 50%, transparent 52%);
            background-size: 300px 300px, 400px 400px, 500px 500px, 60px 60px, 60px 60px;
            animation: backgroundMoveBeginLoading 20s ease-in-out infinite;
            z-index: 1;
        }

        .geometric-shapesBeginLoading {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .shapeBeginLoading {
            position: absolute;
            opacity: 0.1;
            animation: floatBeginLoading 15s ease-in-out infinite;
        }

        .shape-1BeginLoading {
            width: 80px;
            height: 80px;
            background: linear-gradient(45deg, #4caf50, #81c784);
            border-radius: 20px;
            top: 15%;
            left: 10%;
            animation-delay: 0s;
            transform: rotate(45deg);
        }

        .shape-2BeginLoading {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #66bb6a, #a5d6a7);
            border-radius: 50%;
            top: 25%;
            right: 15%;
            animation-delay: -3s;
        }

        .shape-3BeginLoading {
            width: 100px;
            height: 100px;
            background: linear-gradient(90deg, #81c784, #c8e6c9);
            border-radius: 30px;
            bottom: 20%;
            left: 5%;
            animation-delay: -6s;
            transform: rotate(30deg);
        }

        .shape-4BeginLoading {
            width: 70px;
            height: 70px;
            background: linear-gradient(180deg, #4caf50, #66bb6a);
            clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
            bottom: 30%;
            right: 20%;
            animation-delay: -9s;
        }

        .shape-5BeginLoading {
            width: 90px;
            height: 90px;
            background: linear-gradient(225deg, #81c784, #a5d6a7);
            border-radius: 50% 0 50% 0;
            top: 60%;
            left: 20%;
            animation-delay: -12s;
        }

        .loading-containerBeginLoading {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 90%;
            max-width: 400px;
            padding: 30px 20px 20px;
        }

        .logoBeginLoading {
            text-align: center;
            margin-bottom: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-iconBeginLoading {
            width: 250px;
           margin-bottom: 15px;
        }

        .logoBeginLoading h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            background: linear-gradient(90deg, #2e7d32, #4caf50);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: -0.5px;
        }

        .logoBeginLoading p {
            font-size: 1rem;
          opacity: 0.9;
            font-weight: 400;
            line-height: 1.4;
            color: #2e7d32;
        }

        .featuresBeginLoading {
            width: 100%;
            margin: 20px 0 30px;
        }

        .feature-itemBeginLoading {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid rgba(46, 125, 50, 0.2);
            opacity: 1;
        }

        .feature-itemBeginLoading:last-child {
            border-bottom: none;
        }

        /*.feature-itemBeginLoading:nth-child(1) { animation-delay: 0.3s; }
        .feature-itemBeginLoading:nth-child(2) { animation-delay: 0.5s; }
        .feature-itemBeginLoading:nth-child(3) { animation-delay: 0.7s; }
        .feature-itemBeginLoading:nth-child(4) { animation-delay: 0.9s; }*/

        .feature-itemBeginLoading i {
            font-size: 1.5rem;
            color: #4caf50;
            margin-right: 16px;
            width: 30px;
            text-align: center;
        }

        .feature-itemBeginLoading span {
            font-size: 1rem;
            line-height: 1.4;
            color: #2e7d32;
        }

        .copyrightBeginLoading {
            margin-top: 20px;
            text-align: center;
            font-size: 0.85rem;
            color: #2e7d32;
            opacity: 0.8;
            padding-top: 15px;
            border-top: 1px solid rgba(46, 125, 50, 0.2);
        }

        .copyrightBeginLoading .company-nameBeginLoading {
            font-weight: 600;
            color: #1b5e20;
        }

        .loading-textBeginLoading {
            margin-top: 20px;
            font-size: 1rem;
            opacity: 0.8;
            display: flex;
            align-items: center;
            color: #2e7d32;
        }

        .loading-dotsBeginLoading {
            display: inline-block;
            width: 20px;
            text-align: left;
        }

        .loading-dotsBeginLoading::after {
            content: '';
            animation: dotsBeginLoading 1.5s infinite;
        }

        @keyframes dotsBeginLoading {
            0%, 20% { content: ''.''; }
            40% { content: ''..''; }
            60%, 100% { content: ''...''; }
        }

        @keyframes fadeInBeginLoading {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInBeginLoading {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes backgroundMoveBeginLoading {
            0%, 100% {
                background-position: 0% 0%, 0% 0%, 0% 0%, 0% 0%, 0% 0%;
            }
            50% {
                background-position: 100% 100%, 100% 100%, 100% 100%, 30px 30px, -30px 30px;
            }
        }

        @keyframes floatBeginLoading {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }
            33% {
                transform: translateY(-20px) rotate(120deg);
            }
            66% {
                transform: translateY(10px) rotate(240deg);
            }
        }

        .decorative-elementBeginLoading {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(76, 175, 80, 0.08) 0%, transparent 70%);
            z-index: 1;
        }

        .decorative-elementBeginLoading:nth-child(1) {
            width: 150px;
            height: 150px;
            top: -50px;
            right: -50px;
            animation: floatBeginLoading 12s ease-in-out infinite;
        }

        .decorative-elementBeginLoading:nth-child(2) {
            width: 200px;
            height: 200px;
            bottom: -80px;
            left: -80px;
            animation: floatBeginLoading 15s ease-in-out infinite reverse;
        }
</style>


<script>

</script>
<div class="BeginLoading">
    <div class="background-patternBeginLoading"></div>
    <div class="geometric-shapesBeginLoading">
        <div class="shapeBeginLoading shape-1BeginLoading"></div>
        <div class="shapeBeginLoading shape-2BeginLoading"></div>
        <div class="shapeBeginLoading shape-3BeginLoading"></div>
        <div class="shapeBeginLoading shape-4BeginLoading"></div>
        <div class="shapeBeginLoading shape-5BeginLoading"></div>
    </div>
    <div class="decorative-elementBeginLoading"></div>
    <div class="decorative-elementBeginLoading"></div>

    <div class="loading-containerBeginLoading">
        <div class="logoBeginLoading">
            <img src="https://cdn.paradisehrm.com/Image/BackgroundMobile/paradiselogomain.jpg" onerror="this.onerror=null;this.src=''/CDN/Image/BackgroundMobile/paradiselogomain.jpg'';
                alt="ParadiseHRM" class="logo-iconBeginLoading">
            <p>Giải pháp hiệu quả cho doanh nghiệp</p>
        </div>
		
		<div class="spinner-border" role="status" style="
			width: 4rem;
			aspect-ratio: 1;
			height: unset;
		">
			<span class="visually-hidden">Loading...</span>
		</div>

        <div class="featuresBeginLoading">
            <div class="feature-itemBeginLoading">
                <i class="fas fa-clock"></i>
                <span>Chấm công đa nền tảng</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-calculator"></i>
                <span>Tính lương tự động chính xác</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-chart-line"></i>
                <span>Báo cáo nhân sự thông minh</span>
            </div>
            <div class="feature-itemBeginLoading">
                <i class="fas fa-shield-alt"></i>
                <span>Bảo mật dữ liệu cao cấp</span>
            </div>
        </div>

        <div class="copyrightBeginLoading">
            © 2025 <span class="company-nameBeginLoading">Vietinsoft Co. Ltd</span><br>
            All rights reserved
        </div>
    </div>
</div>
<div id="appapp" style="width:100%;">
        <div id="drawer">
	<script>
				function ShowWaitingPanel(){
					$(".BeginLoading").show();
				}
				function HideWaitingPanel(){
					$(".BeginLoading").hide();
					document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
				}
								
				document.querySelectorAll(''.dx-overlay-wrapper.dx-popup-wrapper.dx-overlay-shader'')
				  .forEach(el => el.style.display = ''none'');
			    
            </script>
			<script>
				function createTextboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDateboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDateBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDateBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createTextAreaControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxTextArea(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxTextArea("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createCheckboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxCheckBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxCheckBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRadioGroupControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxRadioGroup(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxRadioGroup("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createNumberboxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxNumberBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxNumberBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createColorBoxControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxColorBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxColorBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureEditControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					config.visible = false;
					div[0].option = config;
					let img = $("<img>").addClass("img-fluid");
					if (config.value) img.attr("src", "data:image/jpg;base64," + config.value);
					let fileUpload = $("<div>");
					div.addClass("p-2").append(img, fileUpload);
					config.value = null;
					fileUpload.dxFileUploader({
						dialogTrigger: div,
						dropZone: div,
						...div[0].option,
					});

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPictureBoxControl(div, config, paramsControl, optionsControl) {
					let img = $("<img>").addClass("img-fluid");
					div.addClass("p-2").append(img);
					return div;
				}

				function createFileButtonControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					let fileUpload = $("<div>");
					let fileButton = $("<div>").dxButton({
						...config,
						onInitialized: function (arg) {
							if (config.ControlBackColor)
								arg.element.css("background-color", config.ControlBackColor);
							if (config.ControlForeColor)
								arg.element.css("color", config.ControlForeColor);
						},
					});

					fileUpload.dxFileUploader({
						...config,
						buttonInstance: fileButton.dxButton("instance"),
						accept: "*",
						dialogTrigger: fileButton,
						multiple: false,
						visible: false,
					});
					div.append(fileButton, fileUpload);

					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							fileUpload.dxFileUploader("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownButtonControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownButton(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] =
							div.dxDropDownButton("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDropDownControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownBox(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDropDownBox("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createGridControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div[0].option.onCellClick = function (e) { };
					div.dxDataGrid(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDataGrid("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createListControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxList(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxList("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
						for (const key in config) {
							if (
								Object.prototype.hasOwnProperty.call(config, key) &&
								typeof config[key] == "function"
							) {
								paramsControl[config.ControlNameParam][key] = config[key];
							}
						}
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createPDFViewerControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var viewer = new ej.pdfviewer.PdfViewer({
						documentPath:
							"https://cdn.syncfusion.com/Content/pdf/pdf-succinctly.pdf",
						resourceUrl:
							"https://cdn.syncfusion.com/ej2/23.2.6/dist/ej2-pdfviewer-lib",
					});
					viewer.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = viewer;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createRichTextControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl = "https://services.syncfusion.com/js/production/";
					var defaultRTE = new ej.richtexteditor.RichTextEditor({
						toolbarSettings: {
							items: [
								"Undo",
								"Redo",
								"|",
								"ImportWord",
								"ExportWord",
								"ExportPdf",
								"|",
								"Bold",
								"Italic",
								"Underline",
								"StrikeThrough",
								"InlineCode",
								"SuperScript",
								"SubScript",
								"|",
								"FontName",
								"FontSize",
								"FontColor",
								"BackgroundColor",
								"|",
								"LowerCase",
								"UpperCase",
								"|",
								"Formats",
								"Alignments",
								"Blockquote",
								"|",
								"NumberFormatList",
								"BulletFormatList",
								"|",
								"Outdent",
								"Indent",
								"|",
								"CreateLink",
								"Image",
								"FileManager",
								"Video",
								"Audio",
								"CreateTable",
								"|",
								"FormatPainter",
								"ClearFormat",
								"|",
								"EmojiPicker",
								"Print",
								"|",
								"SourceCode",
								"FullScreen",
							],
						},
						slashMenuSettings: {
							enable: true,
							items: [
								"Paragraph",
								"Heading 1",
								"Heading 2",
								"Heading 3",
								"Heading 4",
								"OrderedList",
								"UnorderedList",
								"CodeBlock",
								"Blockquote",
								"Link",
								"Image",
								"Video",
								"Audio",
								"Table",
								"Emojipicker",
							],
						},
						insertImageSettings: {
							saveUrl: hostUrl + "api/RichTextEditor/SaveFile",
							removeUrl: hostUrl + "api/RichTextEditor/DeleteFile",
							path: hostUrl + "RichTextEditor/",
						},
						importWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ImportFromWord",
						},
						exportWord: {
							serviceUrl: hostUrl + "api/RichTextEditor/ExportToDocx",
							fileName: "RichTextEditor.docx",
							stylesheet: `
					.e-rte-content {
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						exportPdf: {
							serviceUrl:
								"https://ej2services.syncfusion.com/js/development/api/RichTextEditor/ExportToPdf",
							fileName: "RichTextEditor.pdf",
							stylesheet: `
					.e-rte-content{
						font-size: 1em;
						font-weight: 400;
						margin: 0;
					}
				`,
						},
						fileManagerSettings: {
							enable: true,
							path: "/Pictures/Food",
							ajaxSettings: {
								url: "https://ej2-aspcore-service.azurewebsites.net/api/FileManager/FileOperations",
								getImageUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/GetImage",
								uploadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Upload",
								downloadUrl:
									"https://ej2-aspcore-service.azurewebsites.net/api/FileManager/Download",
							},
						},
						quickToolbarSettings: {
							table: [
								"TableHeader",
								"TableRows",
								"TableColumns",
								"TableCell",
								"-",
								"BackgroundColor",
								"TableRemove",
								"TableCellVerticalAlign",
								"Styles",
							],
							showOnRightClick: true,
						},
						enableXhtml: true,
						showCharCount: true,
						enableTabKey: true,
						placeholder: "Type something or use @ to tag a user...",
						option: function(name, value) {
							if (typeof value === "undefined") return this[name];

							if(this[name] === value) return;

							this[name] = value;
						},
						...config
					});
					defaultRTE.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = defaultRTE;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createDocumentEditorControl(
					div,
					config,
					paramsControl,
					optionsControl
				) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var hostUrl =
						"https://services.syncfusion.com/js/production/api/documenteditor/";
					var container = new ej.documenteditor.DocumentEditorContainer({
						serviceUrl: hostUrl,
						height: "590px",
					});
					container.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = container;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function createBarCodeControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					var barcode = new ej.barcodegenerator.QRCodeGenerator({
						width: config.width,
						height: config.height,
						mode: "SVG",
						type: config.BarCodeType,
						displayText: { visibility: false },
						value: "",
					});
					barcode.appendTo(div[0]);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = barcode;
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function CreateHTMLControl(div, config, paramsControl, optionsControl) {
					let html = $(config.value);
					return html;
				}

				function CreateHyperLinkControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					if (config.onInitialized) config.onInitialized(config);
					div[0].option = config;
					div[0].option.element = div;
					div.append(
						$("<a>")
							.attr("href", "#")
							.text(config.Message)
							.on("click", (event) => {
								event.preventDefault();
								config.openFormAction(
									paramsControl[config.ControlNameParam].value
								);
							})
					);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div[0].option;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function onGridViewCellClick(t) {
					let s = t.cellElement;
					let config = { ...t.column };
					config.value = t.value;
					s.html(
						window[t.column.CreateControlFunction]
							? window[t.column.CreateControlFunction](null, config)
							: t.displayValue
					);
				}

				function convertSqlToJsCondition(sqlCondition, objectName) {
					sqlCondition = sqlCondition
						.replace(/LIKE\s+''%([^%]+)%''/gi, ''.includes("$1")'') // Contains
						.replace(/LIKE\s+''%([^%]+)''/gi, ''.endsWith("$1")'') // Ends with
						.replace(/LIKE\s+''([^%]+)%''/gi, ''.startsWith("$1")''); // Starts with

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+IN\s+\(([^)]+)\)/gi,
						(match, field, values) => {
							const jsValues = values.split(",").map((v) => v.trim());
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `[${jsValues.join(", ")}].includes(${field})`;
						}
					);

					sqlCondition = sqlCondition.replace(
						/([\w\.\[\]]+)\s+BETWEEN\s+([\w\d\.\-]+)\s+AND\s+([\w\d\.\-]+)/gi,
						(match, field, start, end) => {
							if (objectName) {
								field = `${objectName}["${field.replace(/[\[\]]/g, "")}"]`;
							}
							return `(${field} >= ${start} && ${field} <= ${end})`;
						}
					);

					if (objectName) {
						sqlCondition = sqlCondition.replace(
							/\[([\w]+)\]/g,
							`${objectName}["$1"]`
						);
					} else {
						sqlCondition = sqlCondition.replace(/\[([\w]+)\]/g, "$1");
					}

					return sqlCondition
						.replace(/=/g, "==") // Replace "=" with "=="
						.replace(/(>|<)==/g, "$1=") // Replace ">|<==" with ">|<="
						.replace(/is not null/gi, "!== null") // Convert "is not null"
						.replace(/is null/gi, "=== null") // Convert "is null"
						.replace(/\band\b/gi, "&&") // Convert "And" to "&&"
						.replace(/\bor\b/gi, "||") // Convert "Or" to "||"
						.replace(/<>/g, "!="); // Replace "<>" with "!="
				}

				function evaluateCondition(condition, context = {}) {
					try {
						const func = new Function(
							...Object.keys(context),
							`return ${condition};`
						);
						return func(...Object.values(context));
					} catch (error) {
						console.error(condition);
						console.error("Error evaluating condition:", error);
						return false;
					}
				}

				function ParseDefineAction(str) {
					let parts = str.split("|");
					let result = {};
					parts
						.filter((x) => x)
						.forEach((item) => {
							if ((item.match(/=/g) || []).length > 1) {
								let [tmpKey, tmpValue] = item.split(/=(.*)/s);
								tmpValue = tmpValue.split("&");
								let tmpValue1 = {};

								if (tmpValue[0] && tmpValue[0].startsWith("?ExportName")) {
									tmpValue1.OnExportParams = {};
									tmpValue[0] = tmpValue[0].replace(
										"?ExportName",
										"ExportName"
									);
									tmpValue.forEach((tmpItem) => {
										let [key, ...rest] = tmpItem.split("=");
										if (rest.length > 1) {
											let tmpValue2 = [];
											rest.join("=")
												.split("_")
												.forEach((tmpItem1) => {
													let [key, value] = tmpItem1.split("=");
													tmpValue2.push(key);
													tmpValue2.push(value);
												});

											tmpValue1.OnExportParams[key.replace("@", "")] =
												tmpValue2;
										} else
											tmpValue1.OnExportParams[key.replace("@", "")] =
												rest.join("=");
									});
								} else
									tmpValue.forEach((tmpItem) => {
										let [key, value] = tmpItem.split("=");
										tmpValue1[key.replace("@", "")] = value;
									});
								result[tmpKey.replace("@", "")] = tmpValue1;
							} else {
								let [key, value] = item.split("=");
								if (key == "Object" && value && value.includes(".")) {
									let tmpValue1 = {};
									value = value.split(".");
									tmpValue1.ActionDefineType = value[0];
									tmpValue1.ClassName = value[1];
									value = tmpValue1;
								}

								result[key.replace("@", "")] = value;
							}
						});
					return result;
				}

				function convertToHTML(inputString) {
					inputString = inputString.replace(/<color=(.*?)>/gi, (match, color) => {
						const validColor = isValidCSSColor(color)
							? color
							: convertRGBToHex(color);
						return `<span style="color: ${validColor};">`;
					});
					inputString = inputString.replace(/<\/color>/gi, "</span>");

					// inputString = inputString.replace(/<size=\+(\d+)>/gi, (match, p1) => `<span style="font-size: ${parseInt(p1) + windowFontSize}px;">`);
					// inputString = inputString.replace(/<size=-(\d+)>/gi, (match, p1) => `<span style="font-size: ${windowFontSize - parseInt(p1)}px;">`);
					// inputString = inputString.replace(/<size=(\d+)>/gi, (match, size) => `<span style="font-size: ${size}px;">`);
					inputString = inputString.replace(
						/<size=([+-]?\d+|{[\d]+}|[\d]+[a-z%]*)>/gi,
						(match, size) => {
							const parsedSize = parseSize(size);
							return `<span style="font-size: ${parsedSize};">`;
						}
					);
					inputString = inputString.replace(/<\/size>/gi, "</span>");

					inputString = inputString.replace(
						/<href=(.*?)>(.*?)<\/href>/g,
						''<a href="$1" target="_blank">$2</a>''
					);

					inputString = inputString.replace(/<br>/g, "<br/>");

					inputString = inputString.replace(/<b>/gi, "<strong>");
					inputString = inputString.replace(/<\/b>/gi, "</strong>");

					inputString = inputString.replace(
						/<u>/gi,
						''<span style="text-decoration: underline;">''
					);
					inputString = inputString.replace(/<\/u>/gi, "</span>");

					return inputString;
				}

				function convertRGBToHex(rgb) {
					let rgbArray = rgb.split(",").map((num) => parseInt(num.trim()));
					if (rgbArray.length === 3) {
						return `#${rgbArray
							.map((num) => num.toString(16).padStart(2, "0"))
							.join("")}`;
					}
					return rgb;
				}

				function isValidCSSColor(color) {
					let s = new Option().style;
					s.color = color;
					return s.color !== "";
				}

				function parseSize(size) {
					if (size.startsWith("{") && size.endsWith("}")) {
						return `${size.slice(1, -1)}px`;
					} else if (/^\d+x$/.test(size)) {
						return `${parseInt(size)}em`;
					} else if (/^[+-]?\d+$/.test(size)) {
						let baseFontSize = parseInt(
							window.getComputedStyle(document.documentElement).fontSize,
							10
						);
						let sizeAdjustment = parseInt(size);
						let newSize = baseFontSize + sizeAdjustment;
						return `${newSize}px`;
					} else if (/^\d+$/.test(size)) {
						return `${size}px`;
					}
					return size;
				}

				function runSPActionFunction(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					AjaxHPAParadiseParadise({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				async function runSPActionFunctionAsync(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					if (funcitonName.toLowerCase() == "runjs") {
						CallMethod(
							funcitonName.toLowerCase() == "runjs" ? "" : className,
							funcitonName,
							Object.values(spObject)
						);
						return;
					}

					await AjaxHPAParadiseParadiseAsync({
						data: {
							name: funcitonName,
							param: Object.values(spObject),
						},
						success: function (resultData) {
							let jsonData =
								typeof resultData === "string"
									? JSON.parse(resultData)
									: resultData;
							if (actionSuccess) actionSuccess(jsonData);
						},
						error: function (xhr, status, error) {
							if (actionError) actionError(error);
						},
					});
				}

				function showPopupNotify(
					title,
					content,
					btnOKText = "OK",
					popupWidth = "15vw",
					closePopupFunction = () => { }
				) {
					var myDialog = DevExpress.ui.dialog.custom({
						title: title,
						messageHtml: `<div style="width: ${popupWidth}">${content}</div>`,
						buttons: [
							{
								text: btnOKText,
								onClick: function (e) {
									return true;
								},
							},
						],
					});
					myDialog.show().done(function () {
						closePopupFunction();
					});
				}

				function decodeHtmlEntities(str) {
					const txt = document.createElement("textarea");
					txt.innerHTML = str;
					return txt.value;
				}

				function copyViaExcelExport(
					gridInstance,
					isSelectedRowsOnly = false,
					copyWithHeader = false,
					loadPanelmessage = "Copying"
				) {
					let workbook = new ExcelJS.Workbook();
					let sheet = workbook.addWorksheet("dummy");
					let str = "";

					let col = gridInstance.getVisibleColumns();
					col = col.filter((x) => x.dataField !== undefined && x.allowExporting);
					let lastColumn = col[col.length - 1].dataField;

					DevExpress.excelExporter
						.exportDataGrid({
							component: gridInstance,
							worksheet: sheet,
							selectedRowsOnly: isSelectedRowsOnly,
							loadPanel: {
								showPane: false,
								message: loadPanelmessage,
							},
							customizeCell: function (options) {
								let { gridCell } = options;
								let field = gridCell.column.dataField;

								switch (gridCell.rowType) {
									case "header" && copyWithHeader:
										str += `${gridCell.column.caption}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "data":
										if (gridCell.column.dropdownSource) {
											gridCell.value =
												gridCell.column.dropdownSource.find(
													(x) =>
														x[gridCell.column.keyExpr] ==
														gridCell.data[gridCell.column.dataField]
												)?.[gridCell.column.displayExpr] ??
												(gridCell.value ? gridCell.value : "");
										} else if (
											gridCell.column.CreateControlFunction ==
											"createCheckboxControl"
										) {
											gridCell.value = gridCell.value
												? String.fromCharCode(parseInt("2713", 16))
												: "";
										} else if (
											gridCell.column.CreateControlFunction ==
											"createDateboxControl"
										) {
											gridCell.value = DevExpress.localization.formatDate(
												gridCell.value,
												gridCell.column.displayFormat
											);
										} else {
											gridCell.value =
												gridCell.data[gridCell.column.dataField];
										}

										str += `${gridCell.value ?? ""}\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}

										break;
									case "group":
										if (gridCell.value) str += `${gridCell.value} `;

										if (
											gridCell.groupSummaryItems !== undefined &&
											gridCell.groupSummaryItems.length >= 1
										) {
											gridCell.groupSummaryItems.forEach((x) => {
												str += ` ${x.name}: ${x.value} `;
											});
										}

										str += `\t`;

										if (field === lastColumn) {
											str += `\r\n`;
										}
										break;
									case "groupFooter":
										break;
									case "totalFooter":
										break;
									default:
										break;
								}
							},
						})
						.then(() => {
							navigator.clipboard.writeText(str).then(
								() => { },
								() => { }
							);
						});
				}
				function GetFormatDate(date, format = "yyyy-MM-dd HH:mm:ss") {
					return DevExpress.localization.formatDate(new Date(date), format);
				}
				if (!Object.filter)
					Object.filter = (obj, predicate) =>
						Object.keys(obj)
							.filter((key) => predicate(obj[key], key))
							.reduce((res, key) => ((res[key] = obj[key]), res), {});
				
				if (!Object.findValue)
					Object.findValue = function (obj, key) {
						if (!obj) return undefined;
						let match = Object.keys(obj).find(k => k.toLowerCase() === key.toLowerCase());
						return match ? obj[match] : undefined;
					};

				function getArrayTypeDistinct(arr) {
					return [...new Set(arr.map((x) => typeof x))];
				}

				function createConditionQuery(filter, schema, comboBoxColumn) {
					let condition = ``;
					if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						["=", "<", ">"].includes(filter[1])
					) {
						if (filter[2] == null) {
							filter[0] = `ISNULL(${filter[0]} , '''')`;
							filter[2] = "''''";
						} else if (typeof filter[2] == "object") {
							filter[2] = "''" + filter[2].toISOString() + "''";
						} else if (typeof filter[2] == "number") {
							filter[2] = "''" + filter[2].toString() + "''";
						}
					} else if (
						Array.isArray(filter) &&
						filter.length == 3 &&
						Array.isArray(filter[2]) &&
						filter[2].length == 0
					) {
						filter.pop();
						filter.pop();
					}

					filter.forEach((item) => {
						let typeList = Array.isArray(item) ? getArrayTypeDistinct(item) : [];
						if (
							(Array.isArray(item) && typeList.length > 1) ||
							(Array.isArray(item) &&
								typeList.length == 1 &&
								typeList[0] == "object")
						) {
							condition += `(${createConditionQuery(
								item,
								schema,
								comboBoxColumn
							)})`;
						} else if (Array.isArray(item) && typeList.length == 1) {
							condition += `${item[0]}`;
							if (
								schema &&
								schema.find((x) => x.name == item[0]).type == "System.String"
							)
								condition += " COLLATE Latin1_General_CI_AI";
							if (comboBoxColumn && comboBoxColumn.includes(item[0]))
								condition += ` like N''${item[2]}''`;
							else
								condition += `${
									item[1] == "contains"
										? ` like N''%${item[2]}%''`
										: ` = N''${item[2]}''`
								}`;
						} else
							condition +=
								" " +
								(item == null
									? "NULL"
									: item.toLocaleString().toLocaleUpperCase()) +
								" ";
					});

					return condition;
				}

				function createParamString(param) {
					let paramString = "";
					for (let index = 0; index < param.length; index += 2) {
						if (index > 0) paramString += ", ";
						paramString += `${param[index]} = N''''${param[index + 1]}''''`;
					}
					return paramString;
				}

				function transformDateToHierarchy(data) {
					let result = [],
						col0Map = new Map();

					data.forEach(({ col0, col1, col2, col3, col4, col5, totalCount }) => {
						if (!col0Map.has(col0)) {
							let col0Obj = { key: col0, items: [] };
							col0Map.set(col0, col0Obj);
							result.push(col0Obj);
						}

						if (!col1) return;

						let col0Obj = col0Map.get(col0),
							col1Map = col0Obj._col1Map || new Map();

						if (!col1Map.has(col1)) {
							let col1Obj = { key: col1, items: [] };
							if (col2) col1Obj.count = totalCount;
							col1Map.set(col1, col1Obj);
							col0Obj.items.push(col1Obj);
						}

						col0Obj._col1Map = col1Map;

						if (!col2) return;

						let col1Obj = col1Map.get(col1),
							col2Map = col1Obj._col2Map || new Map();

						if (!col2Map.has(col2)) {
							let col2Obj = { key: col2, items: [] };
							if (col3) col1Obj.count = totalCount;
							col2Map.set(col2, col2Obj);
							col1Obj.items.push(col2Obj);
						}

						col1Obj._col2Map = col2Map;

						if (!col3) return;

						let col2Obj = col2Map.get(col2),
							col3Map = col2Obj._col3Map || new Map();

						if (!col3Map.has(col3)) {
							let col3Obj = { key: col3, items: [] };
							if (col4) col2Obj.count = totalCount;
							col3Map.set(col3, col3Obj);
							col2Obj.items.push(col3Obj);
						}

						col2Obj._col3Map = col3Map;

						if (!col4) return;

						let col3Obj = col3Map.get(col3),
							col4Map = col3Obj._col4Map || new Map();

						if (!col4Map.has(col4)) {
							let col4Obj = { key: col4, items: [] };
							if (col5) col3Obj.count = totalCount;
							col4Map.set(col4, col4Obj);

							col3Obj.items.push(col4Obj);
						}

						col3Obj._col4Map = col4Map;

						if (col5 != undefined) {
							let col4Obj = col4Map.get(col4);
							col4Obj.items.push({
								key: col5,
								items: null,
								count: totalCount,
							});
						}
					});

					return result;
				};

			</script>
            <div id="main-layout-diagram" style="overflow-x:hidden; overflow-y:auto; display:block">' as [html],NULL as [HtmlStatus],N'A96' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbodyafter' as [TableName],N'en' as [LanguageID],N'0' as [ScreenType],N'
            </div>
        </div>
    </div>' as [html],NULL as [HtmlStatus],N'A731' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbodyafter' as [TableName],N'en' as [LanguageID],N'1' as [ScreenType],N'        </div>
    </div>
</div>
' as [html],NULL as [HtmlStatus],N'A731' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbodyafter' as [TableName],N'en' as [LanguageID],N'2' as [ScreenType],N'        </div>
    </div>
</div>
' as [html],NULL as [HtmlStatus],N'A731' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbodyafter' as [TableName],N'vn' as [LanguageID],N'0' as [ScreenType],N'
            </div>
        </div>
    </div>' as [html],NULL as [HtmlStatus],N'A731' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbodyafter' as [TableName],N'vn' as [LanguageID],N'1' as [ScreenType],N'        </div>
    </div>
</div>
' as [html],NULL as [HtmlStatus],N'A731' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutbodyafter' as [TableName],N'vn' as [LanguageID],N'2' as [ScreenType],N'        </div>
    </div>
</div>
' as [html],NULL as [HtmlStatus],N'A731' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layoutdataconfig' as [TableName],N'en' as [LanguageID],N'0' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A732' as [KNC],NULL as [ConfigData],N'' as [htmlJS],N'' as [htmlJSLocal],N'' as [htmlJSLocalServer] UNION ALL

Select  N'layoutdataconfig' as [TableName],N'en' as [LanguageID],N'1' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A732' as [KNC],NULL as [ConfigData],N'' as [htmlJS],N'' as [htmlJSLocal],N'' as [htmlJSLocalServer] UNION ALL

Select  N'layoutdataconfig' as [TableName],N'vn' as [LanguageID],N'0' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A732' as [KNC],NULL as [ConfigData],N'' as [htmlJS],N'' as [htmlJSLocal],N'' as [htmlJSLocalServer] UNION ALL

Select  N'layoutdataconfig' as [TableName],N'vn' as [LanguageID],N'1' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A732' as [KNC],NULL as [ConfigData],N'' as [htmlJS],N'' as [htmlJSLocal],N'' as [htmlJSLocalServer] UNION ALL

Select  N'layouthead' as [TableName],N'en' as [LanguageID],N'0' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A746' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layouthead' as [TableName],N'en' as [LanguageID],N'1' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A746' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layouthead' as [TableName],N'en' as [LanguageID],N'2' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A746' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layouthead' as [TableName],N'vn' as [LanguageID],N'0' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A746' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layouthead' as [TableName],N'vn' as [LanguageID],N'1' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A746' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer] UNION ALL

Select  N'layouthead' as [TableName],N'vn' as [LanguageID],N'2' as [ScreenType],N'' as [html],NULL as [HtmlStatus],N'A746' as [KNC],NULL as [ConfigData],NULL as [htmlJS],NULL as [htmlJSLocal],NULL as [htmlJSLocalServer]


update a set html = b.html from tblHtmlCache a inner join #tblHtmlCache b 
on a.TableName = b.TableName and a.LanguageID = b.LanguageID and a.ScreenType = b.ScreenType

drop table #tblHtmlCache