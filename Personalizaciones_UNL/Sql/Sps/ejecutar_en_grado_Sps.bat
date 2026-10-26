{
@echo off
rem ==================================
rem =                                =
rem =               Personalizado    =
rem =                                =
rem ==================================
CD "E:\2.9.5"
SET /p script=Nombre del Script:
SET /p usuario=Nombre del Usuario:
echo "Todavia no se como carajo enmascarar la clave, asi que fijate que no te vea nadie"
SET /p password=Calve del Usuario:
CLS
FOR %%b in (alumnado_fich alumnado_fbcb alumnado_ess alumnado_fadu alumnado_ism alumnado_fcjs alumnado_fcm alumnado_fce ) DO (call "C:\Informix\bin\sqleditor400.exe" /s guarani_test /d %%b /u %usuario% /pw %password% %script% /exec /output c:\temp\sqlout.txt /exit)
pause

}
