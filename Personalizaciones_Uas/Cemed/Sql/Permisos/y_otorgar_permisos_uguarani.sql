{
-- ESTE ESQUEMA QUEDA EN DESUSO. sE MANTIENE EL SCRIPT PARA DOCUMENTAR COMO ES LA CONFIGURACIÓN DE UN USUARIO QUE PUEDE OTORGAR PERMISOS DE SETSESSIONAUTH
-- Como usuario dba y para cada BD del CEMED:
-- Otorgar permisos de DBSA a dba y a uguarani
GRANT DBA TO dba;
GRANT DBSECADM TO dba;

-- Otorgar Permisos de DBSA a uguarani -- Usuario de conexión genérico de CEMED
GRANT DBA TO uguarani;
GRANT DBSECADM TO uguarani;

revoke DBA from guarani;

-- Otorgar permiso de autorización para todos los usuarios de conexión al usuario genérico de conexión de CEMED
-- REVOKE SETSESSIONAUTH ON PUBLIC FROM uguarani;
GRANT SETSESSIONAUTH ON PUBLIC TO uguarani;

-- *****************************************************************************************
-- El siguiente script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************

select "grant connect to "|| usuario || ";" from acc_usuarios;
select "grant guarani to "|| usuario || ";" from acc_usuarios;

}
