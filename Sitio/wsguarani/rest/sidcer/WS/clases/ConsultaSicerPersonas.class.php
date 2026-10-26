<?php

require_once( CLASE_JSON_DATOS_CRUDOS_RESPUESTA );

class ConsultaSicerPersonas extends Consulta //GuaraniMultiplesUAs
{

    const OPERACION_DEFAULT = 'personas';

    protected $operaciones = array('datosanalitico', 'datospersonales');

    public function __construct()
    {
        $this->continuar_en_fallo_de_conexion = true;
        $this->setParametrosPorPrepare(true);
        parent::__construct();
    }

    protected function getSistemasCompatibles()
    {
        return array('guarani' => true, 'sipu' => false);
    }

    protected function getFetchMode()
    {
        return PDO::FETCH_NUM;
    }

    protected function armarDefinicion()
    {
        $this->setDefinicion(0, 'personas', 'CodigoSicerPersona', false);
        $this->setDefinicion(1, 'operacion', 'TextoSimple', false);

        $this->setDefinicion(null, 'pais', 'Integer', false);
        $this->setDefinicion(null, 'tipo_documento', 'TipoDocumento', false);
        $this->setDefinicion(null, 'numero_documento', 'NroDocumento', false);
        $this->setDefinicion(null, 'codigoTituloAraucano', 'Integer', false);
    }

    protected function getConsultaPorPersonas()
    {
        return "SELECT  DISTINCT
            NVL(CP.e_mail,DC.e_mail) AS email,
            CASE WHEN DC.te_per_lect IS NOT NULL THEN TRIM(DC.te_per_lect) ELSE '' END ||
            CASE WHEN DCA.celular_numero IS NOT NULL THEN  ' Celular: ' ||  TRIM(DCA.celular_numero)  ELSE '' END ||
            CASE WHEN DC.te_proc    IS NOT NULL THEN ' Tel. procedencia: '     || TRIM(DC.numero_proc) ELSE '' END as telefono,
            P.tipo_documento || '-' || P.nro_documento AS persona, 
            DC.fecha_actualiz

            FROM    sga_personas P,
            sga_datos_censales DC ,
            sga_datos_cen_aux DCA, 
            OUTER gda_anun_conf_pers CP

            WHERE   P.nro_inscripcion = DC.nro_inscripcion
            AND     DC.nro_inscripcion = DCA.nro_inscripcion
            AND     DC.fecha_relevamiento = (SELECT max (fecha_relevamiento) FROM sga_datos_censales WHERE nro_inscripcion = P.nro_inscripcion)
            AND     DCA.fecha_relevamiento = (SELECT max (fecha_relevamiento) FROM sga_datos_cen_aux WHERE nro_inscripcion = P.nro_inscripcion)
            AND     P.unidad_academica = CP.unidad_academica
            AND     P.nro_inscripcion = CP.nro_inscripcion
            AND     P.tipo_documento  = :tipo_documento
            AND     P.nro_documento = :numero_documento;";
    }

    protected function getConsultaPorDatosanalitico()
    {
       list($tipo_documento, $nro_documento) = $this->getPersona();
       
       return "EXECUTE PROCEDURE sp819_unl_sidcer_ws_analitico ( '" . $tipo_documento . "', '" . $nro_documento . "') ;";
    }

    protected function getConsultaPorDatospersonales()
    {
        list($tipo_documento, $nro_documento) = $this->getPersona();

        return "SELECT  DISTINCT

        P.apellido,  -- 0
	P.nombres,	 -- 1
        DECODE (P.sexo,  1, 'Masculino', '0', 'Femenino') as SEXO,  -- 2
		P.fecha_nacimiento,  -- 3
        CASE P.nacionalidad WHEN 2 THEN  P.nacionalidad || '' ELSE (SELECT mn.descripcion FROM mdp_nacionalidades mn WHERE mn.nacionalidad = P.nacionalidad ) END AS nacionalidad, -- 4
        A.legajo,  -- 5
        pa2.pais, -- 6
        pa2.nombre,  -- 7
        pr2.provincia, -- 8
        pr2.nombre, -- 9
        l2.localidad, -- 10
        l2.nombre, -- 11

	CASE WHEN DC.calle_proc IS NOT NULL THEN TRIM(DC.calle_proc) ELSE '' END ||
        CASE WHEN DC.numero_proc    IS NOT NULL THEN ' N.'     || TRIM(DC.numero_proc) ELSE '' END ||
        CASE WHEN DC.piso_proc      IS NOT NULL THEN ' piso: ' || TRIM(DC.piso_proc) ELSE '' END   ||
        CASE WHEN DC.dpto_proc      IS NOT NULL THEN ' dpto: ' || TRIM(DC.dpto_proc) ELSE '' END  ||
        CASE WHEN DC.unidad_proc    IS NOT NULL THEN ' unidad: ' || TRIM(DC.unidad_proc) ELSE '' END as direccion, -- 12

        CASE WHEN DC.te_per_lect IS NOT NULL THEN TRIM(DC.te_per_lect) ELSE '' END ||
        CASE WHEN DC.te_proc    IS NOT NULL THEN ' Tel. procedencia: '     || TRIM(DC.numero_proc) ELSE '' END as telefono_fijo, -- 13

	TRIM(DCA.celular_numero), -- 14
        DC.e_mail, -- 15
	TD.desc_abreviada, -- 16
	P.nro_documento,  -- 17
	DC.fecha_actualiz --18

        FROM    sga_personas P, sga_alumnos A,
                mug_localidades l, mug_dptos_partidos dp, mug_provincias pr, mug_paises pa ,
                mug_localidades l2, mug_dptos_partidos dp2, mug_provincias pr2, mug_paises pa2 ,
                sga_datos_censales DC ,
                sga_datos_cen_aux DCA,
                mdp_tipo_documento TD

        WHERE   P.nro_inscripcion = A.nro_inscripcion
        AND     DC.nro_inscripcion = A.nro_inscripcion
        AND     DC.fecha_relevamiento = (SELECT max (fecha_relevamiento) FROM sga_datos_censales WHERE nro_inscripcion = P.nro_inscripcion)
        AND     DCA.nro_inscripcion = A.nro_inscripcion
        AND     DCA.fecha_relevamiento = (SELECT max (fecha_relevamiento) FROM sga_datos_cen_aux WHERE nro_inscripcion = P.nro_inscripcion)
        AND     l.dpto_partido = dp.dpto_partido
        AND     dp.provincia = pr.provincia
        AND     pr.pais = pa.pais
        AND     P.loc_nacimiento = l.localidad

        AND     l2.dpto_partido = dp2.dpto_partido
        AND     dp2.provincia = pr2.provincia
        AND     pr2.pais = pa2.pais
        AND     DC.loc_proc  = l2.localidad
        AND	TD.tipo_documento = P.tipo_documento
        AND     P.tipo_documento = '" . $tipo_documento . "'
        AND     P.nro_documento  = '" . $nro_documento . "'";
    }
    
    private function getPersona()
    {
        if ($this->getParametro('personas')) {
            return explode('-', $this->getParametro('personas'));
        }
        
        return null;
    }
    
    protected function setConsulta()
    {
        $this->consulta = $this->getConsultaDeOperacion($this->getParametro('operacion'));
    }

    protected function getConsultaDeOperacion($operacion = null)
    {
        $metodo = 'getConsultaPor' . ucfirst(strtolower(($operacion == null ? static::OPERACION_DEFAULT : $operacion)));

        return $this->$metodo();
    }

    protected function filtroSalidaDeOperacion($operacion, $datos)
    {
        $metodo = 'filtroSalidaPor' . ucfirst(strtolower(($operacion == null ? static::OPERACION_DEFAULT : $operacion)));

        return $this->$metodo($datos);
    }

    protected function filtroSalidaPorPersonas($datos)
    {
        $datos_return = array();
        if (count($datos)) {
	    $fecha_max = 0; 
	    foreach ($datos as $dato) {

	    if ($dato[3] > $fecha_max) {
	       $fecha_max = $dato[3];
	       $datos_return['email'] = $dato[0];
	       $datos_return['telefono'] = $dato[1];
	       $datos_return['persona'] = $dato[2];
	    }
	    }
        }

        return $datos_return;
    }

    protected function filtroSalidaPorDatosanalitico($datos)
    {
        $datos_return = array();
        $i = 0;
        foreach ($datos as &$dato) {

            $datos_return[$i]['titulo_araucano'] = (int)$dato[0];
            $datos_return[$i]['titulo_nombre'] = $dato[1];
            $datos_return[$i]['responsable_academica'] = (int)$dato[2];
            $datos_return[$i]['propuesta'] = $dato[3];
            $datos_return[$i]['propuesta_nombre'] = (string)$dato[4];
            $datos_return[$i]['plan_alumno'] = (string)$dato[28];
            $datos_return[$i]['titulo_esta_cumplido'] = (string)$dato[30];
            $datos_return[$i]['nro_resolucion_ministerial'] = (string)$dato[5];
            $datos_return[$i]['nro_resolucion_coneau'] = (string)$dato[6];
            $datos_return[$i]['nro_resolucion_institucion'] = '';
            $date_ingreso = DateTime::createFromFormat('Y-m-d', $dato[7]);
            $datos_return[$i]['fecha_ingreso'] = $date_ingreso->format('d/m/Y');
 	    $date_egreso = DateTime::createFromFormat('Y-m-d', $dato[8]);
     	    $datos_return[$i]['fecha_egreso'] = $date_egreso->format('d/m/Y');
            $datos_return[$i]['tiene_sanciones'] = (string)$dato[29];
            $datos_return[$i]['titulo_anterior_nivel'] = (string)$dato[9];
            $datos_return[$i]['titulo_anterior_origen'] = ($dato[31]!='')?(int)$dato[31]:null;
            $datos_return[$i]['titulo_anterior_nacionalidad'] = (string)$dato[10];
            $datos_return[$i]['titulo_anterior_institucion'] = (string)$dato[11];
            $datos_return[$i]['titulo_anterior_denominacion'] = (string)$dato[12];
            $datos_return[$i]['titulo_anterior_revalidado'] = (string)$dato[13];
            $datos_return[$i]['titulo_anterior_nro_resolucion'] = (string)$dato[14];
            $datos_return[$i]['titulo_apto_ejercicio'] = (string)$dato[15];
            $datos_return[$i]['plan_vigente'] = (string)$dato[16];
            $datos_return[$i]['tipo'] = (string)$dato[32];
            $datos_return[$i]['actividad_nombre'] = (string)$dato[17];
            $datos_return[$i]['actividad_codigo'] = (string)$dato[18];
            $datos_return[$i]['creditos'] = (string)$dato[33];
	    $date = DateTime::createFromFormat('Y-m-d', $dato[19]);
     	    $datos_return[$i]['fecha'] = $date->format('d/m/Y');
            $datos_return[$i]['nota'] = $dato[20];
            $datos_return[$i]['resultado'] = $dato[21];
            $datos_return[$i]['folio_fisico'] = (int)$dato[23];
            $datos_return[$i]['promedio'] = (string)$dato[25];
            $datos_return[$i]['promedio_sin_aplazos'] = (string)$dato[26];
            $datos_return[$i]['forma_aprobacion'] = (string)$dato[27];
            if ($dato[22] == null OR $dato[22] == ''){
                $datos_return[$i]['acta_resolucion'] = (string)$dato[24];
            } else {
                $datos_return[$i]['acta_resolucion'] = $dato[22];
            }
            $i ++;
        }

        return $datos_return;
    }

    protected function filtroSalidaPorDatospersonales($datos)
    {
        $datos_return = array();
        if (count($datos)) {
	    $fecha_max = 0; 
	    foreach ($datos as $dato) {
	    	if ($dato[18] > $fecha_max) {
	            $fecha_max = $dato[18];
	            $datos_return['apellido'] = (string)$dato[0];
	            $datos_return['nombres'] = (string)$dato[1];
        	    $datos_return['genero'] = (string)$dato[2];

		    $date = DateTime::createFromFormat('Y-m-d', $dato[3]);
        	    $datos_return['fecha_nacimiento'] = $date->format('d/m/Y');

	            $datos_return['nacionalidad'] = (string)$dato[4];
	            $datos_return['legajo'] = (string)$dato[5];
                    $datos_return['pais_origen'] = (int)$dato[6];
	            $datos_return['codigo_pais_procedencia'] = (int)$dato[6];
	            $datos_return['nombre_pais_procedencia'] = (string)$dato[7];
	            $datos_return['codigo_provincia_procedencia'] = (int)$dato[8];
	            $datos_return['nombre_provincia_procedencia'] = (string)$dato[9];
        	    $datos_return['codigo_localidad_procedencia'] = (int)$dato[10];
	            $datos_return['nombre_localidad_procedencia'] = (string)$dato[11];
	            $datos_return['direccion_procedencia'] = (string)$dato[12];
	            $datos_return['telefono_fijo'] = (string)$dato[13];
        	    $datos_return['telefono_celular'] = (string)$dato[14];
	            $datos_return['mail'] = (string)$dato[15];
             	    $datos_return['documento'] = (string)$dato[16] . " " . $dato[17];
	    	}
            }
        }

        return $datos_return;
    }

    protected function filtroSalida($unosResultados)
    {
        $datos = parent::filtroSalida($unosResultados);

        return $this->filtroSalidaDeOperacion($this->getParametro('operacion'), $datos);
    }

    public function getClaseRespuesta()
    {
        return 'JSONDatosCrudosRespuesta';
    }

    protected function evaluaCodigoSicerPersona($unValor)
    {
        $validos = array('-');
        return ctype_alnum(str_replace($validos, '', $unValor)) and ( strlen($unValor) <= 255 );
    }

}

