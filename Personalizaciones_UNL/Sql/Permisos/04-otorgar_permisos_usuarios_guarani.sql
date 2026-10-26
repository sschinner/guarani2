-- *****************************************************************************************
-- El siguiente script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************
{
select "grant connect to "|| usuario || ";" from acc_usuarios;
select "grant guarani to "|| usuario || ";" from acc_usuarios;

}
