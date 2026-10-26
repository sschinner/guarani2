-- Doy permisos a tablas de dimensiones
GRANT SELECT ON dba.sga_insc_cursadas TO gerencial_ro;
GRANT SELECT ON dba.sga_alumnos TO gerencial_ro;
GRANT SELECT ON dba.sga_personas TO gerencial_ro;
GRANT SELECT ON dba.sga_comisiones TO gerencial_ro;
GRANT SELECT ON dba.sga_actas_cursado TO gerencial_ro;
GRANT SELECT ON dba.sga_curs_pendiente TO gerencial_ro;
GRANT SELECT ON dba.sga_det_acta_curs TO gerencial_ro;

GRANT SELECT ON dba.sga_detalle_acta TO gerencial_ro;
GRANT SELECT ON dba.sga_actas_examen TO gerencial_ro;
GRANT SELECT ON dba.sga_carreras TO gerencial_ro;
GRANT SELECT ON dba.sga_materias TO gerencial_ro;
GRANT SELECT ON dba.sga_turnos_examen TO gerencial_ro;
GRANT SELECT ON AUX_DW_EGRESADOS TO gerencial_ro;

-- Doy permiso de ejecución a SPs de soporte
grant execute on sp820_contar_egresados to gerencial_ro;
