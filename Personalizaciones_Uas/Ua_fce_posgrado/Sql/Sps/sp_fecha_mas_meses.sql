drop PROCEDURE sp_fecha_mas_meses;
CREATE PROCEDURE sp_fecha_mas_meses ( pFecha CHAR(10), pCantMeses INTEGER )
       RETURNING char(10); -- "dd/mm/yyyy"

DEFINE vi_dia, vi_mes, vi_anio, vi_masanios, vi_maxdias   INTEGER;
DEFINE vd_Fecha DATE;
DEFINE vc_FechaRtn CHAR(10);

BEGIN


   LET vd_Fecha = To_Date ( pFecha, "%d/%m/%Y" );
   LET vi_dia   = DAY(vd_Fecha);
   LET vi_mes   = MONTH(vd_Fecha);
   LET vi_anio  = YEAR(vd_Fecha);

   LET vi_masanios = 0;
   IF pCantMeses > 12 THEN

      WHILE pCantMeses >= 12

         LET vi_masanios = vi_masanios + 1;
         LET pCantMeses = pCantMeses - 12;

      END WHILE;

   END IF;

   -- voy componiendo la nueva fecha.
   LET vi_anio = vi_anio + vi_masanios;
   LET vi_mes = vi_mes + pCantMeses;

   IF vi_mes > 12 THEN
      LET vi_anio = vi_anio + 1;
      LET vi_mes = vi_mes - 12;
   END IF;

   -- no me voy a poner a ver el dia exacto, no es el objetivo de esta fx.
   -- IF vi_dia >= 30 THEN
   --   LET vi_dia = 28;
   -- END IF;

    -- Verifico si es Bisiesto
    IF vi_mes = 2 THEN
        IF vi_dia > 28 THEN
            IF MOD(vi_anio,4) = 0 AND ( MOD(vi_anio,100) <> 0 OR MOD(vi_anio,400)=0)  THEN
                -- Es Bisiesto
                LET vi_dia = 29;
            ELSE
                -- No es Bisiesto
                LET vi_dia = 28;
            END IF;
        END IF;
    ELSE
        -- vi_mes <> 2
        IF vi_dia > 30 THEN
            IF (vi_mes = 4 OR vi_mes = 6 OR vi_mes = 9 OR vi_mes = 11) THEN
                LET vi_dia = 30;
            ELSE
                LET vi_dia = 31;
            END IF;
        END IF
    END IF;

   LET vc_FechaRtn = TO_CHAR(MDY( vi_mes, vi_dia, vi_anio ), "%d/%m/%Y");

   RETURN vc_FechaRtn;

END;
END PROCEDURE;                         
                                                                                                                                                                                                                                                              
