{
@echo off
rem ==================================
rem =                                =
rem =               Personalizado    =
rem =                                =
rem ==================================
CD "E:\tags"
SET /p script=Nombre del Script:
SET /p usuario=Nombre del Usuario:
echo "Todavia no se como carajo enmascarar la clave, asi que fijate que no te vea nadie"
SET /p password=Calve del Usuario:
CLS
FOR %%b in (posgrado_fich posgrado_fbcb posgrado_fadu posgrado_fhuc posgrado_fcjs posgrado_fce posgrado_fca posgrado_fcv posgrado_fiq) DO (call "C:\Informix\bin\sqleditor400.exe" /s rectorado_csm /d %%b /u %usuario% /pw %password% %script% /exec /output c:\temp\sqlout.txt /exit)
pause

}
