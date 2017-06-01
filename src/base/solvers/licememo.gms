$Title  License Memorandum (LICEMEMO,SEQ=307)

$ontext

This model generates a license memorandum with all licensed components
and available subsystems.

When you purchase GAMS you buy components like the BASE component,
solver components like CONOPT, and GAMS language extension components
like MPSGE. Each licensed component enables you to run the associated
subsystems (mostly solvers). Each licensed component comes with an
expiration and a maintenance date. Subsystems corresponding to a
licensed component will stop working after the expiration date. GAMS
distributions that are not newer then the maintenance date will allow
you to run the subsystems associated with the component in full mode.

$offtext

Sets ModelTypes     / system.ModelTypes     /
     Components     / system.Components     /
     SolverNames    / system.SolverNames    /
     ComponentSolverMap(Components,SolverNames) / system.ComponentSolverMap /
     SolverPlatformMap(SolverNames,*)           / system.SolverPlatformMap /

Set  s(SolverNames) Solvers available for this platform
     c(Components)  Components available for this platform;

$setnames "%gams.subsys%" d f e
$ifthen exist "%d%%f%.gdx"
  Set Attributes; Parameter SolverAttributes(SolverNames,Attributes);
$ gdxin "%d%%f%.gdx"
$ load Attributes SolverAttributes
  s(SolverNames) = sum(SolverPlatformMap(SolverNames,'%system.platform%'),1)
                   and not SolverAttributes(SolverNames,'Hidden');
$else
  s(SolverNames) = sum(SolverPlatformMap(SolverNames,'%system.platform%'),1);
$endif
c(Components)  = sum(ComponentSolverMap(Components,s),1);

alias (*,u,v);

file fm /licememo.txt/; fm.pw = 72;

put fm 'L I C E N S E   M E M O R A N D U M':<>fm.pw /
       'GAMS Development Corporation':<>fm.pw //;

$set filename %gams.license%
$if '%filename' == '' $set filename %gams.sysdir%gamslice.txt
if(%system.licensestatus%,
   put '**** Error Message: %system.licensestatustext%'
     / '**** License file : %filename%'
     / '**** System downgraded to demo mode'// );

$onputS
Serial   : %system.LicenseDC% : %system.LicenseID% : %system.LicenseDateS%

Licensee : %system.LicenseLicensee%
         : %system.LicenseInstitution%

Platform : %system.LicensePlatformText%
           %system.LicenseType%
           %system.LicenseLevelText%
           %system.LicenseMUDText%

Vendor   : %system.LicenseVendor%

$offput

$set LExpDate %system.LicenseDateEvalS% (%system.LicenseDaysEval% days left)
$ifi %system.LicenseDaysEval% == INF $set LExpDate Indefinite
scalar TodayDate; TodayDate=jnow;
put   "Today's date       : " TodayDate.date
    / "License Expiration : %LExpDate%"
$ifi %system.LicenseDaysEval% == INF
    / 'M&S Expiration     : %system.LicenseDateMaintS% (%system.LicenseDaysMaint% days left)'

put // 'Licensed Components:'
if(card(ComponentEDate),
   put /;
   loop(SortedUels(u,c)$ComponentEDate(c),
      put / '  ' Components.te(c):48 ' ';
      if(ComponentEdate(c)=Inf,
         put 'M&S due ' ComponentMDate.date(c)
      else
         put 'expires ' ComponentEDate.date(c)))
else put ' none' );
Put //;

$if set short $exit
put / 'Licensed Subsystems:';
scalar cnt;
if(card(ComponentMDate),
put /;
   loop(SortedUels(u,c)$ComponentMDate(c),
      put / Components.te(c):0 @17; cnt=0;
      loop((v,s)$(SortedUels(v,s)*ComponentSolverMap(c,s)), put$(mod(cnt,4)=0) / ' ':18; cnt=cnt+1; put ' ' s.tl ));
else
   put ' none' / );

put /// 'Solver/Modeltype Matrix:';
Set AllSolvers(SolverNames); AllSolvers(s) = sum(ComponentSolverMap(c,s),1);
file.pw=120;
put // @13; loop(ModelTypes, put ModelTypes.tl:7);
loop(SortedUels(u,AllSolvers)$sum(ModelTypes,SolverCapabilities(AllSolvers,ModelTypes)),
   put / AllSolvers.tl;
   loop(ModelTypes, put ' ':7; put$SolverCapabilities(AllSolvers,ModelTypes) @(fm.cc-7) 'yes    ' ));
