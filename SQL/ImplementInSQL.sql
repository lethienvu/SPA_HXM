USE Paradise_HPSF
GO
if object_id('[dbo].[sp_DashBoard]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_DashBoard] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_DashBoard](@LoginID int = 3,
    @ProcedureName NVARCHAR(100) = NULL,
 @Month INT = NULL,
    @Year INT = NULL,
    @FromDate Date = NULL,
    @ToDate Date = NULL,
    @IdentityID VARCHAR(36) = NULL,
    @IdentityID_Param VARCHAR(36) = NULL,
 @OTDate Date = NULL,
 @TypeReport NVARCHAR(MAX) = null,
 @TimePeriod INT = 30,
 @LanguageID varchar(3) = 'VN',
 @isWeb int = 2)
AS
BEGIN
 --Author: VU
 --This is a frame to view HTML Mobile app

 IF(ISNULL(@ProcedureName, '') = '')
  SET @ProcedureName = 'sp_DashBoard'

 --All function in app mobile
 --Phân quyền
  create table #tmpDataRightCustom (FullAccess varchar(50),ObjectName nvarchar(200),LoginID int,ObjectID int)
  exec SC_LoadFullRightObject @LoginID,'#tmpDataRightCustom'

  --thiết lập chia các loại menu
  select m.MenuID,m.ClassName,l.Content, CAST(NULL AS NVARCHAR(100)) SelectedMenubar
  into #MobileFunction
  from MEN_Menu m
  --phân quyền theo nhóm
  left join tblMD_Message l on l.MessageID = MenuID and l.Language = @LanguageID --tên menu
  inner join tblSC_Object o on m.AssemblyName + '.' + m.ClassName = o.ObjectName
  inner join #tmpDataRightCustom r on r.ObjectID = o.ObjectID
  where r.LoginID = @LoginID and ISNULL(FullAccess,0) > 0
  and MenuID IN('MnuHRS2000', 'MnuWPT100', 'MnuWPT101', 'MnuWPT200', 'MnuWPT201', 'MnuWPT203', 'MnuWPT202', 'MnuWPT204', 'MnuWPT206', 'MnuWPT300', 'MnuWPT301', 'MnuWPT302', 'MnuWPT208', 'MnuWPT21', 'MnuWPT205', 'MnuHRS300', 'MnuWPT500', 'MnuWPT501') --Vũ: chỉ hiển thị các menu đang build
  and isnull(NotUsePlatform, '') not like '%'+CAST(@isWeb as varchar(5))+ '%'
  --and m.MenuID in (select CurrentMenuID from tblWorkFlow  where ParentMenuID = 'MnuWPT000' and left(CurrentMenuID,3) = 'Mnu')
  and (m.ParentMenuID = 'MnuWPT000' OR MenuID IN ('MnuHRS225', 'MnuHRS2000', 'MnuHRS300'))
  and m.MenuID <> 'MnuHRS406'
  and m.IsVisible = 1
  order by m.Priority

  UPDATE #MobileFunction SET SelectedMenubar = CASE WHEN MenuID IN ('MnuWPT200', 'MnuWPT100', 'MnuWPT101') THEN N'NghiPhep'
             WHEN MenuID IN ('MnuWPT201', 'MnuWPT202', 'MnuWPT203') THEN N'TangCa'
             WHEN MenuID IN ('MnuWPT206', 'MnuWPT300', 'MnuWPT301', 'MnuWPT302', 'MnuWPT500') THEN N'ChamCong'
            ELSE 'HoSo'
           END

  --thông báo trên app
  INSERT INTO #MobileFunction(MenuID, ClassName, Content, SelectedMenubar)
  SELECT 'MnuHRS301', 'sp_ViewNotificationInApp', N'Thông báo', N'HoSo'

   DECLARE @MenuID varchar(20) = (SELECT MenuID FROM  #MobileFunction WHERE ClassName = @ProcedureName)

  UPDATE #MobileFunction SET ClassName = 'sp_DashBoard_Real' WHERE MenuID = 'MnuHRS2000'

  --get param of procedure
 SELECT pl.MenuID,
    sp.name AS ProcedureName,
    'exec ' + pl.ClassName + ' ' + STUFF((
        SELECT ', ' + p.name
        FROM sys.parameters p
        WHERE p.object_id = sp.object_id
        FOR XML PATH('')), 1, 2, '') AS ParamNames
 INTO #Procedure
 FROM
  sys.procedures sp
 JOIN
  #MobileFunction pl ON sp.name = pl.ClassName
 WHERE pl.MenuID = @MenuID
 ORDER BY
  sp.name



 DECLARE @css1 NVARCHAR(MAX) = '', @css2 NVARCHAR(MAX) = '', @html1 NVARCHAR(MAX) = '', @html2 NVARCHAR(MAX) = '', @html3 NVARCHAR(MAX) = '', @js1 NVARCHAR(MAX) = '', @js2 NVARCHAR(MAX) = '', @js3 NVARCHAR(MAX) = ''

 --To excute procedure
 DECLARE @Query NVARCHAR(MAX) = ''

 create table #ViewHTML (css1 NVARCHAR(MAX), css2 NVARCHAR(MAX), html1 NVARCHAR(MAX), html2 NVARCHAR(MAX), html3 NVARCHAR(MAX), js1 NVARCHAR(MAX), js2 NVARCHAR(MAX), js3 NVARCHAR(MAX))

 SELECT @Query = N'insert into #ViewHTML(css1, css2, html1, html2, html3, js1, js2, js3)
       ' + ParamNames
 FROM  #Procedure
 WHERE MenuID = @MenuID

 --use for fix bug

 --if @LoginID = 3 begin
 -- SELECT @Query = ''
 --FROM  #Procedure
 --WHERE MenuID = @MenuID

 --select * from #Procedure
 --return end

 EXEC sp_executesql
    @Query,
    N'@LoginID int,
       @LanguageID varchar(3),
   @isWeb int,
    @Month INT,
    @Year INT,
    @FromDate Date,
    @ToDate Date,
    @IdentityID VARCHAR(36),
 @OTDate Date,
    @IdentityID_Param VARCHAR(36),
 @TypeReport NVARCHAR(MAX),
 @TimePeriod INT',
    @LoginID = @LoginID,
 @LanguageID = @LanguageID,
 @isWeb = @isWeb,
 @Month = @Month,
 @Year = @Year,
  @FromDate = @FromDate,
  @ToDate = @ToDate,
  @IdentityID = @IdentityID,
  @IdentityID_Param = @IdentityID_Param,
  @OTDate = @OTDate,
  @TypeReport = @TypeReport,
  @TimePeriod = @TimePeriod

   --Menubar
   declare @cssMenubar nvarchar(max)='', @htmlHome nvarchar(max)='', @menuBar nvarchar(max)='', @IsSelected nvarchar(100) = '', @titleHeader nvarchar(100) = ''

   SELECT @IsSelected = SelectedMenubar, @titleHeader = Content
   FROM #MobileFunction
   WHERE MenuID = @MenuID

   create table #ViewMenuBar (cssMenubar nvarchar(max),htmlHome nvarchar(max),menuBar nvarchar(max))
   insert into #ViewMenuBar(cssMenubar, htmlHome, menuBar)
   exec sp_MenuBar @IsSelected = @IsSelected, @titleHeader = @titleHeader
   select @cssMenubar=ISNULL(cssMenubar,''), @htmlHome=ISNULL(htmlHome,''), @menuBar = menuBar from #ViewMenuBar

   DECLARE @htmlPopup NVARCHAR(MAX) = '', @cssPopup NVARCHAR(MAX) = '', @jsPopup NVARCHAR(MAX) = ''

  CREATE TABLE #PopUp(CSS NVARCHAR(MAX), HTML NVARCHAR(MAX), JS NVARCHAR(MAX))
  INSERT INTO #PopUp(CSS, HTML, JS)
  EXEC sp_popupForWeb @LanguageID = @LanguageID

  SELECT @cssPopup = CSS, @htmlPopup = HTML, @jsPopup = JS
  FROM #PopUp

   IF(@MenuID = 'MnuHRS2000')
   BEGIN
   SET @cssMenubar = ''
   SET @htmlHome = ''
   SET @menuBar = ''
   END

   --about translate for other language
   DECLARE @EngLanguage NVARCHAR(MAX) = '', @jsForTranslate NVARCHAR(MAX) = ''

   SET @EngLanguage = N'<script>
       var ENGLanguage = {
        hello: "Hello!",
        dashboard: "Dashboard",
        leave: "Leave",
        ot: "Overtime",
        attendance: "Attendance",
        personal: "Personal",
        warningAbnormal: "Please send the request confirm time attendance for lacking data days!",
        questionAtt: "Question for HR",
        year: "Year",
        month: "Month",
        attDay: "Working Days",
        totalOTV: "Total OT Hours",
        paidLeave: "Paid Leave",
        unpaidLeave: "Unpaid Leave",
        wDays: "Working Days: ",
        timesheetWk: "Timesheet for week (Salary Month: ' + ISNULL(CONVERT(VARCHAR(10), @FromDate, 103), '') + N' - ' + ISNULL(CONVERT(VARCHAR(10), @ToDate, 103), '') + N')",
        forgotAtt: "Forgot Timekeeping: ",
        shift: "Shift",
        in: "In",
        out: "Out",
        workingTime: "Working",
        ottime: "OT",
        stdWD: "WD Standard: ",
        leaveHoliday: "Leave Holiday: ",
    althisyear: "AL This Year",
    lastyear: "AL Last Year",
    totalAL: "Total AL",
    taken: "Taken",
    remain: "Remain",
    pending: "Pending",
    approved: "Approved",
    rejected: "Rejected",
    canceled: "Canceled",
    fromDateL: "From: ",
    toDateL: "To: ",
    filter: "Filter",
    titleLeave: "LEAVE REGISTER INFORMATION",
    empID: "Employee ID: ",
    fullN: "Full name: ",
    from: "From: ",
    to: "To: ",
    time: "Time: ",
    shift: "Shift: ",
    reason: "Reason: ",
    approvalLine: "APPROVAL LINE",
    thisstatus: "Current Status: ",
    app1: "Approver 1: ",
    app1Note: "Approver 1 Remark: ",
    app2: "Approver 2: ",
    app2Note: "Approver 2 Remark: ",
    cancel: "Send cancel require",
    al: "Annual Leave",
    hours: "Hours",
    otdate: "OT Date: ",
    totalOT: "Total OT: ",
    detailtitle: "REGISTRATION DETAILS",
    empth: "EmployeeID",
    nameth: "Name",
    otdateth: "OTDate",
    fromth: "From",
    toth: "To",
    amountth: "Amount",
    assistant: "Assistant register",
    approverNote: "Remark for approver: ",
    rejectAction: "Reject",
    approveAction: "Approve",
    leavedateth: "Leave Date",
    leavecodeth: "Leave Type",
    timeth: "Time",
    leaveTitle: "LEAVE REGISTRATION INFORMATION",
    changepass: "Reset password",
    aboutSoft: "About software",
    setting: "Settings",
    logout: "Logout",
    updatePhoto: "Update employee profile photo",

    attnoti: "Attendance",
    allnoti: "All",
    leavenoti: "Leave",
    otnoti: "Overtime",
    titleSub: "All notification",
    leavetype: "Leave type: ",
    aldetail: "Annual Leave Detail",
    fullDayn: "Full day",
    halfDayn: "Half day",
    fromDateV: "From date: ",
    toDateV: "To date: ",
    fromDateH: "From date: ",
    toDateH: "To date: ",
    timePeriod: "Time period: ",
    amountTime: "Amount: ",
    listDate: "Day List: ",
    chooseLeaveType: "Choose the leave type",
    halfBeforeV: "Half before",
    halfAfterV: "Half after",
    hour4: "4 hours",
    registerV: "Submit",
    timekeeping: "Timekeeping Confirm",
    forgotThisMonth: "Number of times forgot to timekeeping in this month: "

       };
      </script>'

 SET @jsForTranslate = N'<script>
       function translateToLanguage(ENGLanguage) {
        for (const [id, text] of Object.entries(ENGLanguage)) {
         const element = document.getElementById(id);
         if (element) {
          element.textContent = text;
         }
        }
       }

       ' + CASE WHEN @LanguageID = 'EN' THEN 'translateToLanguage(ENGLanguage);' ELSE '' END  + N'
       </script>'



 SELECT @css1 = css1, @css2 = css2, @html1 = html1, @html2 = html2, @html3 = html3, @js1 = js1, @js2 = js2, @js3 = js3
 FROM #ViewHTML

 SELECT @cssMenubar + @cssPopup + @htmlPopup + @htmlHome + @menuBar + @css1 + @css2 + @html1 + @html2 + @html3 + @js1 + @js2 + @js3 + @jsPopup + @EngLanguage + @jsForTranslate AS Col1
END
GO
exec sp_DashBoard 3,NULL,11,2025,'2025-11-01','2025-11-30'