<?php
use SIUToba\rest\rest;
use siu\modelo\datos\catalogo;

class recurso_legacy {

    /**
     * GET /legacy/inscriptos
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Inscriptos a carrera
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__inscriptos(){

        $datos = catalogo::consultar("rest_legacy", "inscriptos_carrera");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/carrera_titulo
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Titulos de la carrera
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__carrera_titulo(){

        $datos = catalogo::consultar("rest_legacy", "carrera_titulo");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/carrera
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Carreras
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__carrera(){

        $datos = catalogo::consultar("rest_legacy", "carrera");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/institucion
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Nombre de la universidad
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__institucion(){

        $datos = catalogo::consultar("rest_legacy", "institucion");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/respacad
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Responsable Academica
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__respacad(){

        $datos = catalogo::consultar("rest_legacy", "respacad");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/respacad_carrera
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Carreras de una Responsable Academica
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__respacad_carrera(){

        $datos = catalogo::consultar("rest_legacy", "respacad_carrera");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/respacad_titulo
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Titulos de una Responsable Academica
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__respacad_titulo(){

        $datos = catalogo::consultar("rest_legacy", "respacad_titulo");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/titulo
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Titulos
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__titulo(){

        $datos = catalogo::consultar("rest_legacy", "titulo");

        rest::response()->get_list($datos);

    }

    /**
     * GET /legacy/graduado
     * @param_query $ua string [required] Filtro Código de la Unidad Académica
     * @notes
     *  <p>Los Filtros se definen como 'condicion;valor' donde 'condicion' puede ser: <br/>
     *     [entre| es_mayor_que| desde| es_mayor_igual_que| es_menor_que| es_menor_igual_que| hasta| es_igual_a| es_distinto_de| contiene| no_contiene| comienza_con| termina_con]
     *	</p>
     * @summary Graduados
     * @responses  200 Exito
     * @responses  400 Errores en los parámetros
     */
    function get_list__graduado(){

        $datos = catalogo::consultar("rest_legacy", "graduado");

        rest::response()->get_list($datos);

    }

} 