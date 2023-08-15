net stop winmgmt /y
C:
CD %SystemRoot%\System32\wbem
RD /S /Q repository
regsvr32 /s %SystemRoot%\system32\scecli.dll
regsvr32 /s %SystemRoot%\system32\userenv.dll
for /f %%s in ('dir /b /s *.dll') do regsvr32 /s %%s
scrcons.exe /regserver
unsecapp.exe /regserver
winmgmt.exe /regserver
wmiadap.exe /regserver
wmiapsrv.exe /regserver
wmiprvse.exe /regserver
mofcomp cimwin32.mof
mofcomp cimwin32.mfl
mofcomp rsop.mof
mofcomp rsop.mfl
for /f %%s in ('dir /b *.mof') do mofcomp %%s
for /f %%s in ('dir /b *.mfl') do mofcomp %%s