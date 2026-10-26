kernel.renderer.registrar_pagelet('datos_discapacidad', function(info) {
	var id = '#' + info.id;
        
	function navegar_form(params) {
		kernel.ajax.load(params.href, id, {forzar_cambio_op:true,
			success: function() {
				kernel.evts.disparar('info_formulario_cargado', params);
			}
		});
	}

	function cargar_formulario_censo(params) {
		navegar_form(params);
	}

	function registrar_listeners() {
		var id_evento = 'seleccion_formulario';
		kernel.evts.escuchar(id_evento, cargar_formulario_censo);
	}
     
/* FUNCIONES DE CONTROL DEL BOTON 'GUARDAR' */

	function seteos() {
		deshabilitar_boton_guardar();

		tipo = $("#form_datos_discapacidad-TIPO").val();
		grado = $("#form_datos_discapacidad-GRADO").val();
		caracter = $("#form_datos_discapacidad-CARACTER").val();
		desde = $("#form_datos_discapacidad-FECHA_DESDE").val();
		hasta = $("#form_datos_discapacidad-FECHA_HASTA").val();
		cobertura = $("#form_datos_discapacidad-COBERTURA_SALUD").prop('checked');
		observaciones = $("#form_datos_discapacidad-OBSERVACIONES").val();
		
		comparar();	
	}

	function comparar() 
	{
		hubo_cambio_tipo = false;
		hubo_cambio_grado = false;
		hubo_cambio_caracter = false;
		hubo_cambio_desde = false;
		hubo_cambio_hasta = false;
		hubo_cambio_cobertura = false;
		hubo_cambio_observaciones = false;

		$( "#formulario .editable" ).change(function() {
			
			if (tipo == $("#form_datos_discapacidad-TIPO").val()){
				hubo_cambio_tipo = false;
			}else{
				hubo_cambio_tipo = true;
			}
			
			if (grado == $("#form_datos_discapacidad-GRADO").val()){
				hubo_cambio_grado = false;
			}else{
				hubo_cambio_grado = true;
			}
			
			if (caracter == $("#form_datos_discapacidad-CARACTER").val()){
				hubo_cambio_caracter = false;
			}else{
				hubo_cambio_caracter = true;
			}
			
			if (desde == $("#form_datos_discapacidad-FECHA_DESDE").val()){
				hubo_cambio_desde = false;
			}else{
				hubo_cambio_desde = true;
			}
			
			if (hasta == $("#form_datos_discapacidad-FECHA_HASTA").val()){
				hubo_cambio_hasta = false;
			}else{
				hubo_cambio_hasta = true
			}
			
			if (cobertura == $("#form_datos_discapacidad-COBERTURA_SALUD").prop('checked')){
				hubo_cambio_cobertura = false;
			}else{
				hubo_cambio_cobertura = true;
			}
			
			if (observaciones == $("#form_datos_discapacidad-OBSERVACIONES").val()){
				hubo_cambio_observaciones = false;
			}else{
				hubo_cambio_observaciones = true;
			}
			
			if (hubo_cambio_tipo | hubo_cambio_grado | hubo_cambio_caracter | hubo_cambio_desde | hubo_cambio_hasta | hubo_cambio_cobertura | hubo_cambio_observaciones){
				habilitar_boton_guardar();
			}else{
				deshabilitar_boton_guardar()
			}

		});
	}

	function deshabilitar_boton_guardar()
	{
		$('#btn_guardar').prop('disabled', true);
	}

	function habilitar_boton_guardar()
	{
		$('#btn_guardar').prop('disabled', false);
	}

        return {
		onload: function() {
//                        kernel.evts.disparar('info_formulario_cargado', {href:info.url_discapacidad});
                        registrar_listeners();
						seteos();

                        if (info.estado === "ok"){
                            /*kernel_config.historia_activa = true;
                            guarani.cambiar_op({
                                href: info.url_discapacidad,
                                mensaje_post_navegacion: {
                                    mensaje: info.mensaje,
                                    options: {tipo: 'alert-success'}
                                }
                            });*/
                            kernel.ui.show_mensaje(info.mensaje);
                        }
                        else if(info.estado === "error"){
                            kernel.ui.show_mensaje(info.mensaje, {tipo: 'alert-error'});
                        }
                        
                        $(id).on('click','a.js-btnEliminar', function(){
                            var $btn = $(this);
                            var discapacidad = $btn.parents('tr').find('.tipo_disc').text();
                            kernel.ui.prompt({
                            msg: 'Desea eliminar discapacidad ' + discapacidad + '?',
                            msg_ok: 'Eliminar',
                            msg_cancel: 'Cancelar',
                            ok: function() {
                                    kernel.ajax.call($btn.attr('href') , {
                                            historia: false,
                                            type: 'get',
                                            success: function(response) {
                                                if ($('.item_disc:visible').length > 1){
                                                    kernel.ui.show_mensaje(response.msj);
                                                    $btn.parents('tr').hide();
                                                } else {
                                                    guarani.cambiar_op({
                                                        href: info.url_discapacidad,
                                                        mensaje_post_navegacion: {
                                                            mensaje: response.msj
                                                        }
                                                    });
                                                }
                                            },
                                            error: function(response) {
                                                kernel.ui.show_mensaje(response.msj, {tipo: 'alert-error'});
                                            }
                                    })
                                }
                            })
                            return false;
                        });
                        
//                        $(id).on('submit','#form_datos_discapacidad', function(){
//                            
//                            kernel.ajax.call($('#form_datos_discapacidad').attr('action') , {
//                                    historia: false,
//                                    type: 'post',
//                                    data: $('#form_datos_discapacidad').serialize(),
//                                    success: function(response) {
//                                        guarani.cambiar_op({
//                                            href: info.url_discapacidad,
//                                            mensaje_post_navegacion: {
//						mensaje: response.msj
//                                            }
//                                        });
//                                    },
//                                    error: function(response) {
//                                        $(id).html(response.cont);
//                                        kernel.ui.show_mensaje(response.msj, {tipo: 'alert-error'});
//                                    }
//                            })
//                            
//                            return false;
//                        });
                        
                        $.datepicker.setDefaults( $.datepicker.regional["es"] );
						$(id).find('input.date').datepicker({
							changeMonth: true,
							changeYear: true,
							firstDay:0,
							yearRange: "-70:+70"
			});
                        
                        
//                        var anchors = '#lista_forms a';
//
//                        $(anchors).removeClass('active');
//                        $(anchors).attr('aria-pressed', 'false');
//                        var anchor_seleccionado = anchors + '[href$="' + info.url_discapacidad + '"]';
//
//                        $(anchor_seleccionado).addClass('active');
		}
	}
})
