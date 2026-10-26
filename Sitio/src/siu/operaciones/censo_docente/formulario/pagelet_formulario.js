kernel.renderer.registrar_pagelet('formulario', function(info) {
    var id = '#' + info.id;
    var id_intervalo;
	
	var localidades = {
		pri_: {
			pais: 54,
			provincia: false,
			localidad: false
		}
	};
    
    var cambio = false;
	
	function setup_principales() {
		var cBusquedaDestino = "";

		$('#btnLocPersonal').on('click', function() {
			cBusquedaDestino = "pri_";
			$.facebox(info.localidades);
			inicializoCuadroBusqueda();
		});

		$('#btnLocPersonal').on('keypress', function(e) {
			if (e.which == 13) $(this).trigger('click');
		});
		
		$('#btnLocPersonalBorrar').on('click', function() {
			$('#CENS_LOC_PER_LECT_TEXTO, #CENS_LOC_PER_LECT, #CENS_CP_PER_LECT').val('');
		});
		
		$('#pais').on('change', function() {
			buscoProvincias($(this).val());
			$('#localidad').children().remove();
			$('#tablaResultados').css('display', 'none');
			$('#agregar').css('display', 'none');
		});

		$('#provincia').on('change', function() {
			$('#tablaResultados').css('display', 'none');
			$('#agregar').css('display', 'none');
		});


		function buscoProvincias(pais_id){
			$.ajax({
				url: info.url_provincias,
				dataType: 'json',
				data: {pais: pais_id},
				type: 'post',
				success: function(data) {
					$('#provincia').children().remove();
                                        $('#provincia').append($('<optgroup label="Provincias">'));
					$('#provincia').append(
						$('<option></option>').val('').html('Seleccione provincia')
					);
					//console.log(data);
					$.each(data, function(key, value) {
						$('#provincia').append(
							$('<option></option>').val(value['ID']).html(value['DESC'])
						);
					});
				}
			});	
		}

		function inicializoCuadroBusqueda() {
			var pais_def = 54;
			pais_def = localidades[cBusquedaDestino]['pais'];

			var provincia_def = '';
			if (localidades[cBusquedaDestino]['provincia'] != ""){
				provincia_def = localidades[cBusquedaDestino]['provincia'];
			}
			$('#localidad').val('');
			buscoProvincias(pais_def);

			$('#pais option').each(
				function(key, value)
				{
					if(value['value'] == pais_def){
						$(this).prop('selected', 'selected');
					}
				}
			);

			$('#provincia option').each(
				function(key, value) 
				{
					if (value['value'] == provincia_def){
						$(this).prop('selected', 'selected');
					}
				}
			);
			$('#tablaResultados').css('display', 'none');
			$('#agregar').css('display', 'none');

			$('#pais').on('change', function() {
				//console.log('change pais');
				buscoProvincias($(this).val());
				$('#localidad').children().remove();
				$('#tablaResultados').css('display', 'none');
				$('#agregar').css('display', 'none');
			});

			$('#buscar').on('click', function() {
				$('#localidades').submit();
			});
			
			$('#localidades').on('submit', function() {
				$('#error_busqueda_provincia').hide();
				$('#error_busqueda_localidad').hide();
				$('#error_busqueda_cp').hide();
				if ($('#pais').val() != '___' && $('#provincia').val() != '')
				{
					if ($('#localidad').val() != '')
					{
						$('#ajax-loader').css('display', 'block');
						$.ajax({				
							url: info.url_localidades,				
							dataType: 'json',
							data: {provincia: $('#provincia').val(), localidad: $('#localidad').val()},						
							type: 'post',
							success: function(data) {
								if (!(typeof data == "undefined") && !(data == false)){
									$('#cps').children().remove();
                                                                        $('#cps').append($('<optgroup label="Codigo postal">'));
									var mostrarResultados = 0;
									$('#cps').append(
										$('<option></option>').val('').html('--- SELECCIONE ---')
									);
									$.each(data, function(key, value) {									
										if (value['DESC'] != "")
										{
											mostrarResultados = 1;
											$('#cps').append(
												$('<option></option>').val(value['ID']).html(value['DESC'])
											);
										}
									});

									if (mostrarResultados == 1){
										$('#tablaResultados').css('display', 'block');
										$('#agregar').css('display', 'block');
										$('#tablaNoResultados').css('display', 'none');
									}
								}
								else
								{
									$('#tablaResultados').css('display', 'none');
									$('#agregar').css('display', 'none');								
									$('#tablaNoResultados').css('display', 'block');
								}
								$('#ajax-loader').css('display', 'none');
							}
						});
					}
					else
					{
						$('#error_busqueda_localidad').show();
					}
				}
				else
				{
					$('#error_busqueda_provincia').show();
				}
				return false;
			});

			$('#agregar').on('click', function() {
				$('#error_busqueda_cp').hide();
				if ($('#cps').val() != '')
				{
					localidades[cBusquedaDestino]['pais'] = $("#pais option:selected").val();
					localidades[cBusquedaDestino]['provincia'] = $("#provincia option:selected").val();


					/* IdLocalidad_CodigoPostal_NombreLocalidad*/
					var valor = jQuery.trim($("#cps option:selected").val());
					//console.log("#cps option:selected: "+valor);
					var pos = valor.search(new RegExp("_")); // Posicion del primer "_"
					//console.log("Posicion del primer _ : "+pos);
					var largo = valor.length;
					//console.log("largo: "+largo);
					var id_localidad = valor.substr(0,pos);
					//console.log("id_localidad = valor.substr(0,pos): "+id_localidad);					
					var aux = valor.substr(pos+1);
					//console.log("Aux1 : "+aux);
					largo = aux.length;
					pos = aux.search(new RegExp("_"));
					//console.log("Posicion del segundo _ : "+pos);
					var cp = aux.substr(0,pos);
					//console.log("CP : "+cp);
					var nombre_localidad = aux.substr(pos+1, largo);
					//console.log("nombre localidad : "+nombre_localidad);
					var loc_result = nombre_localidad+', '+jQuery.trim($("#provincia option:selected").text())+', '+jQuery.trim($("#pais option:selected").text());

					if (cBusquedaDestino == "pri_")
					{
						$('#CENS_LOC_PER_LECT_TEXTO').val(loc_result);
						$('#CENS_CP_PER_LECT').val(cp);
						$('#CENS_LOC_PER_LECT').val(id_localidad);
                                                $('#CENS_CP_PER_LECT').focus();
					}

					set_cambio();
					$.facebox.close();
				}
				else
				{
					$('#error_busqueda_cp').show();
				}
			});
		};



		$('form').keypress(function(e){
			if(e.which == 13){
				return false; 
			}
		});
	}	
	
    function seteos() {
		setup_principales();
        
        mantener_valores_guardados();
		$('.guardar').on('click', function() {
			guardar_form();
			return false;
		});
	}
	
	function validar_email(value) {
		var filter = /^([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+.)+([a-zA-Z0-9]{2,4})+$/;
		return filter.test(value);
	}
	
    function guardar_form(callback) {
        deshabilitar_boton_guardar();
        if ($('#' + $('#form_id').val() + ' .js-error').length > 0) {
            return false
        }
        var url = info.url_guardar;
        kernel.util.clear_interval(id_intervalo);

        kernel.ajax.load(url, id, {
            historia: false,
            type: 'POST',
            data: $('#' + $('#form_id').val()).serializeArray(),

            success: function () {
                $('.editable').each(function () {
                    var valor_actual;
                    switch ($(this).prop('type'))
                    {
                        case 'checkbox':
                            valor_actual = $(this).is(':checked');
                            break;
                        case 'radio':
                            valor_actual = $('[name=' + $(this).prop('name') + ']:checked').val();
                            break;
                        default:
                            valor_actual = $(this).val();
                    }
                    if ($(this).data('prev_value') != valor_actual) {
                        $(this).data('prev_value', valor_actual);
                    }
                });
                if (typeof callback != 'undefined') {
                    callback();
                }
                seteos();
                kernel.ui.show_mensaje(info.msg_guardado_exitoso, {
                    until_interaction: true
                });
            },
            error: function (r) {
                $("input, select").css('background-color', 'white');
                for (var i = 0; i < r.campos_error.length; ++i) {
                    $('#' + r.campos_error[i]).css('background-color', 'red');
                }
                $('[name="__csrf"]').val(r.csrf_token);
                kernel.ui.show_mensaje(info.msg_error_al_guardar, {tipo: 'alert-error'});
            },
            complete: function () {
                habilitar_boton_guardar();
                id_intervalo = kernel.util.set_interval(comparar, 500);
            }
        });
    }
    
    function navegar_form(params) {
		kernel.ajax.load(params.href, id, {
			success: function() {
				info.id_form = params.form;
				seteos(); 
				$('#mensaje').css('display', 'none');
				kernel.evts.disparar('info_formulario_cargado', params);
			}
		});        
    }
    
	function cargar_formulario_censo(params) { 
        if (cambio) {
			guardar_form(function() {
			navegar_form(params);
            });
        } else {
            navegar_form(params);
        }
    }
	
	function registrar_listeners() {
		var id_evento = 'seleccion_formulario';
        kernel.evts.escuchar(id_evento, cargar_formulario_censo);
    }
    
    function mantener_valores_guardados() 
    {
        $('.editable').each(function() { 
            switch ($(this).prop('type'))
            {
                case 'checkbox':
                   $(this).data('prev_value', $(this).is(':checked'));
                   break;
                case 'radio':
                    if ($(this).is(':checked')) {
                        $('[name='+$(this).prop('name')+']').data('prev_value',$(this).val());
                   }
                   break;
                default:
                   $(this).data('prev_value', $(this).val());
            }
        });
    }
	
	function validar_campo_email(elem) 
	{
		if ( elem.val() != '' && !validar_email(elem.val())) {
				var clase_error = 'js-error-formato-CENS_E_MAIL';
				if ($('#'+$('#form_id').val()).find("."+clase_error).length < 1) {
					var msg_arriba = $('<span>Formato incorrectooo</span>');
					msg_arriba.addClass('alert-error');
					msg_arriba.addClass('js-error');
					msg_arriba.addClass(clase_error);
					elem.after(msg_arriba);
				}
			} else {
				$('.js-error-formato-CENS_E_MAIL').remove();
			}
		
	}
	
	
	function validar_obligatoriedad(elem) 
	{
			var editable_id = elem.attr('id');
			var clase_error = 'js-error-require';
			var span_clase_error = 'js-error-require_'+editable_id;
			if (elem.hasClass('require') && elem.val() == '' && ! elem.hasClass(clase_error) ) {
////				if ($('.js-error-formato-CENS_E_MAIL').length > 0) {
////					$('.js-error-formato-CENS_E_MAIL').remove();
////				}
				elem.addClass(clase_error);
				var error = $('<span class="obligatorio"></span>');
				error.addClass('alert-error');
				error.addClass('js-error');
				error.addClass(span_clase_error);
				$('[for="'+editable_id+'"]').append(error);
			
			} else if (elem.hasClass(clase_error) && elem.val() != '') {
				elem.removeClass(clase_error);
				$(id).find("."+span_clase_error).remove();
			} else if(! elem.hasClass('require')) {
				// posible bug de chrome
				if (elem.hasClass(clase_error)) {
					elem.removeClass(clase_error);
				}
				$(id).find("."+span_clase_error).remove();
			} 
	}
	
	
	function validar(elem) 
	{
//		if (elem.attr('id') == 'CENS_E_MAIL') {
//			validar_campo_email(elem)
//		}
		validar_obligatoriedad(elem);
	}
	
    function comparar() 
    {
		var hubo_cambio = false;
        $('.editable').each(function() {
			validar($(this));
			var valor_actual;
            switch ($(this).prop('type'))
            {
                case 'checkbox':
                   valor_actual = $(this).is(':checked');
                   break;
                case 'radio':
                   valor_actual = $('[name='+$(this).prop('name')+']:checked').val();
                   break;
                default:
                   valor_actual = $(this).val();
            }
            if ($(this).data('prev_value') != valor_actual) {
                hubo_cambio = true;
            }
            
        });
        if (!hubo_cambio){
            unset_cambio();
        } else {
			set_cambio();
		}
		if($('.js-error').length > 0) {
			deshabilitar_boton_guardar();
		}
            
    }
	
	function deshabilitar_boton_guardar()
	{
        $('.guardar').prop('disabled', true);
	}
	
	function habilitar_boton_guardar()
	{
        $('.guardar').prop('disabled', false);
	}
    
    function set_cambio()
    {
        //kernel.evts.disparar('cambio_algo_status');
        cambio = true;
        $('.guardar').text('Guardar ahora');
		habilitar_boton_guardar();
    }
    
    function unset_cambio()
    {
        cambio = false;
        $('.guardar').text('Guardado');
        deshabilitar_boton_guardar();
    }
    
    
    return {
        onload: function() {
            id_intervalo = kernel.util.set_interval(comparar, 500);
       		registrar_listeners();
			jQuery(document).ready(function(){				
				seteos();
			});
			
			if (info.modo_reinscripcion) {
				$('#btn-reinscripcion').on('click', function() {	
					kernel.ajax.call(info.url_reinscripcion, {
						dataType: 'json',
						type: 'post',
						success: function(paquete) {
							$('#mensaje_reinscripcion').html(info.reinscripcion_completa);
						}
					});

                return false;
				});
			}
        }
    }
})