CLS
@ECHO OFF
ECHO.
ECHO Test the build local
ECHO.
SETLOCAL

ECHO .
ECHO Starting Nant build script
ECHO .

SET TARGET=build
SET TARGET=buildAndTest

nant.exe -buildfile:"Solution.build" -l:"Solution.log" %TARGET% -v ^
         -D:project.dir=%~dps0 ^
         -D:BuildVersion=9999 ^
         -D:project.Builds=%~dps0 ^
         -D:project.FullBuild=false
if %ERRORLEVEL% NEQ 0 goto ERROR
GOTO END

:ERROR
ECHO .
ECHO .
ECHO Build failed, see Nant logging
ECHO .
ECHO .
GOTO END

:END
endlocal

:: pause
