<?php
namespace kernel\interfaz\vistas;

use kernel\kernel;
use kernel\nucleo\recursos;
use kernel\interfaz\vista;
use kernel\interfaz\pagelet;
use kernel\interfaz\unidad_renderizacion_ajax;

abstract class vista_pagelets extends vista implements unidad_renderizacion_ajax
{
    protected $widgets;
    protected $pagelets = array();

    function __construct()
    {
        parent::__construct();
    }

    function get_tipo()
    {
        return 'vista_pagelets';
    }
    
    function set_controlador($controlador)
    {
        parent::set_controlador($controlador);
        foreach ($this->get_pagelets() as $pagelet) {
            $pagelet->set_controlador($controlador);
        }
    }
    
    /**
     * @return A list of widgets in the order required by the current layout
     */
    function get_pagelets()
    {
		uasort($this->pagelets, array($this, "cmp_pagelets"));
        return $this->pagelets;
    }
	
	protected function cmp_pagelets($p1, $p2)
	{
		$prioridad_1 = $p1->get_prioridad();
		$prioridad_2 = $p2->get_prioridad();
		
		if ($prioridad_1 == $prioridad_2) {
			return 0;
		}
		// para hacer el orden decreciente
		return ($prioridad_1 < $prioridad_2) ? 1 : -1;
	}

	/**
	 * Agrega un pagelet a la vista.
	 * @param pagelet $pagelet
	 * @param integer $prioridad por defecto 0. Mientras más grande este número
	 * mayor la prioridad del pagelet (se renderiza antes)
	 */
    function add_pagelet(pagelet $pagelet, $prioridad = 0, $id_interno = false)
    {
		$id = ($id_interno !== false) ? $id_interno : $pagelet->get_id();
        $this->pagelets[$id] = $pagelet;
		$this->pagelets[$id]->set_prioridad($prioridad);
        
        if (isset($this->controlador)) {
            $pagelet->set_controlador($this->controlador);
        }
    }

    function get_pagelets_count()
    {
        return count($this->get_pagelets());
    }

    function prepare()
    {
    }

    function pagelet($id)
    {
        return $this->pagelets[$id];
    }
	
	protected function before_render()
	{
		
	}
	 
    function render()
    {
		$this->before_render();
        $tpl = $this->get_template();
        $pagelets = $this->get_pagelets();
        $contexto = $this->get_contexto();
        
        foreach ($pagelets as $id => $pagelet) {
            $pagelet->set_modo(pagelet::MODO_COMPLETO);
            $contexto["$id"] = $pagelet;
        }
		
        $tpl->display($contexto);
		
		if (! kernel::proyecto()->es_pipe_nav()) {
			$init_code = "<script type='text/javascript'>$(document).ready(function() {";
			foreach ($pagelets as $pagelet) {
				$paquete = array(
					'info' => $pagelet->get_js_info(),
					'clase_js' => $pagelet->get_nombre_clase_js(),
				);
				$json_paquete = json_encode($paquete);

				$init_code .= "kernel.renderer.on_full_arrival($json_paquete);"; 
			}
			$init_code .= "});</script>";
		}
		
		echo $init_code;
    }

    /**
     * Renderiza el esqueleto de una vista.
     * @param boolean $return si es verdadero el valor se retorna en lugar de hacer un output
     */
    function render_skeleton($return = false)
    {
		$this->before_render();
        $tpl = $this->get_template();
        $pagelets = $this->get_pagelets();
        $contexto = $this->get_contexto();
        
        foreach ($pagelets as $id => $pagelet) {
            $pagelet->set_modo(pagelet::MODO_SKELETON);
            $contexto["$id"] = $pagelet;
        }
        
        if (! $return) {
            $tpl->display($contexto);
        } else {
            return $tpl->render($contexto);
        }
    }

    function render_pipe()
    {
        $this->flush();
        $pagelets = $this->get_pagelets();
		$count = 0;
        foreach ($pagelets as $pagelet) {
            $pagelet->set_modo(pagelet::MODO_CONTENIDO);
            $pagelet->exec_prepare();
			if (!$pagelet->is_empty()) {
				$count++;
			}
            $pagelet->render_pipe();
            $this->flush();
        }
		echo "<script type='text/javascript'>kernel_config.pagelet_count = $count</script>";
    }

    /**
	 * Renderiza la vista completa y hace el output para que lo reciba el kernel de js.
	 * Primero se renderiza el skeleton y luego los trozos de javascript que lo cargan
	 */
    function render_ajax()
    {
        $cont = $this->render_skeleton(true);
        $pagelets = $this->get_pagelets();
		$count = 0;
        foreach ($pagelets as $pagelet) {
            $pagelet->set_modo(pagelet::MODO_CONTENIDO);
            $pagelet->exec_prepare();
			if (!$pagelet->is_empty()) {
				$count++;
			}
            $cont .= $pagelet->render_pipe(true);
        }
		$cont .= "<script type='text/javascript'>kernel_config.pagelet_count = $count</script>";
		
        echo kernel::renderer()->get_respuesta_json(1, $cont, $this->get_extra_params());
    }
	
	function get_extra_params()
	{
		return array(
			'titulo' => kernel::pagina()->get_titulo_completo(),
            'operacion' => kernel::ruteador()->get_id_operacion()
		);
	}
	
	protected function flush()
    {
//        ob_end_flush();
        flush();
//        ob_start();
    }
	
	function get_css_resources()
	{
		$pagelets = $this->get_pagelets();
		$files = array();
		foreach ($pagelets as $pagelet) {
			foreach ($pagelet->get_css_files() as $file) {
				$files[] = $file;
			}
		}
		
		$files = array_unique($files);
		$loaders = '';
		foreach ($files as $file) {
			$loaders .=  "<link type='text/css' href='$file' rel='stylesheet' />";
		}
		
		return $loaders;
	}
	
	function get_js_resources()
	{
		$pagelets = $this->get_pagelets();
		$files = array();

		foreach ($pagelets as $pagelet) {
			foreach ($pagelet->get_js_files() as $file) {
				$files[] = $file;
			}
		}
		
		$files = array_unique($files);
		$loaders = '';
		foreach ($files as $file) {
			$loaders .=  "<script type='text/javascript' src='$file'></script>";			
		}
		
		return $loaders;
	}
}

?>
