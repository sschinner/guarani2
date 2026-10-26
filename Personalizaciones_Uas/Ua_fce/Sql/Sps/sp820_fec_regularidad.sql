drop PROCEDURE "dba".sp820_fec_regularidad;
CREATE PROCEDURE "dba".sp820_fec_regularidad(
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo,
		    pMateria LIKE sga_actas_examen.materia,
                                    pCondreg LIKE  sga_cursadas.cond_regularidad,
                                    pTipofecha char(1))

RETURNING date; -- fecha de vigencia de la regularidad , si no la aprobó retorna nulos

-- Variables 
DEFINE v_fecha date;



-- blk de excepciones
ON EXCEPTION 
   return  null;
  
END EXCEPTION;


BEGIN
if pTipoFecha = 'F' then
begin
    SELECT   fin_vigencia_regul into v_fecha
    from  sga_cursadas cu1	    
     where   cu1.unidad_academica = pUA
      and cu1.carrera = pCarrera
     and cu1.legajo =  pLegajo 
     and cu1.materia = pMateria 
     and cu1.resultado = 'A'
     and cu1.cond_regularidad = pCondreg;	

  end;
else
   begin
    SELECT   fecha_regularidad into v_fecha
    from  sga_cursadas cu1	    
     where  cu1.unidad_academica = pUA
     and cu1.carrera = pCarrera
     and cu1.legajo =  pLegajo 
     and cu1.materia = pMateria 
     and cu1.resultado = 'A'
     and cu1.cond_regularidad = pCondreg;

  end;
end if;
	
     RETURN v_fecha;
END;

END PROCEDURE;
                                                                                                                                                                                                     
