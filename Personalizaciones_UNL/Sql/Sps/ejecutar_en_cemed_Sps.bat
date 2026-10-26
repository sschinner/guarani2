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
FOR %%b in (cemed_fbcb cemed_fhuc cemed_ism cemed_fcjs cemed_euaa cemed_idiomas cemed_fadu cemed_ecm cemed_fca cemed_fce cemed_fcv cemed_fich cemed_secgral cemed_extension) DO (call "C:\Informix\bin\sqleditor400.exe" /s cemed_csm /d %%b /u %usuario% /pw %password% %script% /exec /output c:\temp\sqlout.txt /exit)
pause

}
