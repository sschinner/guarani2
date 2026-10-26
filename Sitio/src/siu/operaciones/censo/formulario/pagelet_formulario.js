kernel.renderer.registrar_pagelet('formulario', function(info) {
	var id = '#' + info.id;
	var id_intervalo;
	var localidades = {
		pri_: {
			pais: 54,
			provincia: false,
			localidad: false
		},
		pro_: {
			pais: 54,
			provincia: false,
			localidad: false
		},
		per_: {
			pais: 54,
			provincia: false,
			localidad: false
		}
	};

	var cambio = false;

	function setup_principales() {
		var cBusquedaDestino = "";
		/* acordeon */		
		$('#acordeon a').on({
			click: function(e) {
			if ($(this).attr('class') == 'descolapsar'){
			$(this).removeClass('descolapsar');
			$(this).addClass('colapsar');
			} else {
			$(this).removeClass('colapsar');
			$(this).addClass('descolapsar');
			};
			$(this).next().toggle('slow');
			return false;
		},
			keypress: function(e) {
			if (e.which == 13) {
				 $(this).trigger('click');
			}
		}
		}).next().hide();


		$('#btnLocPersonal').on('click', function() {
			cBusquedaDestino = "pri_";
			$.facebox(info.localidades);
			inicializoCuadroBusqueda();			
		});

		$('#btnLocPersonal').on('keypress', function(e) {
			if (e.which == 13) $(this).trigger('click');
		});
		
		$('#btnLocProcedencia').on('click', function() {
			cBusquedaDestino = "pro_";
			$.facebox(info.localidades);
			inicializoCuadroBusqueda();
		});

		$('#btnLocProcedencia').on('keypress', function(e) {
			if (e.which == 13) $(this).trigger('click');
		});

		$('#btnLocAllegada').on('click', function() {
			cBusquedaDestino = "per_";
			$.facebox(info.localidades);
			inicializoCuadroBusqueda();
		});

		$('#btnLocAllegada').on('keypress', function(e) {
			if (e.which == 13) $(this).trigger('click');
		});

		$('#btnCerrarCuadroLocalidad').on('click', function (){
			$('#cuadroBuscarLocalidad').hide(500,function (){});
		});
		
		$('#btnLocPersonalBorrar').on('click', function() {
			$('#CENS_LOC_PER_LECT_TEXTO, #CENS_LOC_PER_LECT, #CENS_CP_PER_LECT').val('');
		});
		
		$('#btnLocProcedenciaBorrar').on('click', function() {
			$('#CENS_LOC_PROC_TEXTO, #CENS_LOC_PROC, #CENS_CP_PROC').val('');
		});
		
		$('#btnLocAllegadaBorrar').on('click', function() {
			$('#CENS_LOC_PERS_ALLEG_TEXTO, #CENS_LOC_PERS_ALLEG, #CENS_CP_PERS_ALLEG').val('');
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
				buscoProvincias($(this).val());
				$('#localidad').children().remove();
				$('#tablaResultados').css('display', 'none');
				$('#agregar').css('display', 'none');
			});

			$('#cancelar').on('click', function(){
									$('#provincia').children().remove();
									$('#localidad').children().remove();
									$('#localidad').val('');		
									$('#cuadroBuscarLocalidad').hide(500);
									$.facebox.close();
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
									var mostrarResultados = 0;
									$('#cps').append($('<optgroup label="Codigo postal">'));
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
					var pos = valor.search(new RegExp("_")); // Posicion del primer "_"
					var largo = valor.length;
					var id_localidad = valor.substr(0,pos);

					var aux = valor.substr(pos+1);
					largo = aux.length;
					pos = aux.search(new RegExp("_"));
					var cp = aux.substr(0,pos);
					var nombre_localidad = aux.substr(pos+1, largo);
					var loc_result = nombre_localidad+', '+jQuery.trim($("#provincia option:selected").text())+', '+jQuery.trim($("#pais option:selected").text());

					var cp_result = cp;

					if (cBusquedaDestino == "pri_")
					{
						$('#CENS_LOC_PER_LECT_TEXTO').val(loc_result);
						$('#CENS_CP_PER_LECT').val(cp_result);
						$('#CENS_LOC_PER_LECT').val(id_localidad);
						$('#CENS_CP_PER_LECT').focus();
					}

					if (cBusquedaDestino == "pro_")
					{
						$('#CENS_LOC_PROC_TEXTO').val(loc_result);
						$('#CENS_LOC_PROC').val(id_localidad);
						$('#CENS_CP_PROC').val(cp_result);
						$('#CENS_CP_PROC').focus();
					}

					if (cBusquedaDestino == "per_")
					{
						$('#CENS_LOC_PERS_ALLEG_TEXTO').val(loc_result);
						$('#CENS_LOC_PERS_ALLEG').val(id_localidad);
						$('#CENS_CP_PERS_ALLEG').val(cp_result);
						$('#CENS_CP_PERS_ALLEG').focus();
					}

					set_cambio();
					$('#cuadroBuscarLocalidad').hide(500);
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

		$('#CENS_CALLE_PER_LECT').focus();
	}

	function setup_financiamiento(){
		financiamiento_beca();
		financiamiento_beca_economica();

		// si costea sus estudios con una beca activar
		$('#AUX2_ALU_COS_EST_BECA').on('click', function() {
			financiamiento_beca();
		});

		$('#AUX2_ALU_BECA_TIPO_ECO').on('click', function() {
			financiamiento_beca_economica();
		});

		$('#AUX2_ALU_COS_EST_AP_FAM').focus();
	}

	function financiamiento_beca(){
		if ($('#AUX2_ALU_COS_EST_BECA').attr('checked') == 'checked'){
			$('#fuente_beca input[type=checkbox]').each(function() {
				$(this).removeAttr("disabled");
			});

			$('#tipo_beca input[type=checkbox]').each(function() {
				$(this).removeAttr("disabled");
			});
		}
		else
		{
			$('#fuente_beca input[type=checkbox]').each(function() {
				$(this).removeAttr("checked");
				$(this).prop('disabled', true);
			});

			$('#tipo_beca input[type=checkbox]').each(function() {
				$(this).removeAttr("checked");
				$(this).prop('disabled', true);
			});

			$('#tipo_ayuda input[type=checkbox]').each(function() {
				$(this).removeAttr("checked");
				$(this).prop('disabled', true);
			});
		}
	}

	function financiamiento_beca_economica(){
		if ($('#AUX2_ALU_BECA_TIPO_ECO').attr('checked') == 'checked'){
			$('#tipo_ayuda input[type=checkbox]').each(function() {
				$(this).removeAttr("disabled");
			});
		}
		else
		{
			$('#tipo_ayuda input[type=checkbox]').each(function() {
				$(this).removeAttr("checked");
				$(this).prop('disabled', true);
			});
		}
	}

	function setup_trabajo(){
		trabajo();

		$('#AUX1_EXISTE_TRAB_ALUM').on('change', function() {
			trabajo();
		})

		$('#CENS_SECTOR').on('change', function() {
			cargar_actividad_secundaria($(this).val(), null);
		});

		$('#CENS_EMPRESA').on('change', function() {
			empresa();
		});
	}

	function empresa(){
		var empresa = $('#CENS_EMPRESA');
		var empresa_otra = $('#CENS_EMPRESA_OTRA');

		if (empresa.val() == ''){
			if (empresa_otra.val() == ''){
				empresa_otra.prop('disabled', false);				
			} else {
				empresa.prop('disabled', false);
			}
		}else {
			empresa_otra.val('');
			empresa_otra.prop('disabled', true);
		}
	}

	function cargar_actividad_secundaria(sector, subsector){
		$.ajax({
			url: info.url_subsectores_economicos,
			dataType: 'json',
			data: {sector: sector},
			type: 'post',
			success: function(data) {
				$('#CENS_SUBSECTOR').children().remove();
				$('#CENS_SUBSECTOR').append(
					$('<option></option>').val('').html('-- SELECCIONE --')
				);
				$.each(data, function(key, value) {
					$('#CENS_SUBSECTOR').append(
						$('<option></option>').val(value['ID']).html(value['DESC'])
					);
				});
			},
			complete: function(){
				//console.log('subsector: '+subsector);
				$('#CENS_SUBSECTOR').val(subsector);
			}
		});
	}

	function trabajo(){
		if ($('#AUX1_EXISTE_TRAB_ALUM option:selected').val() == '1')
		{
			$('.js-datos-trabajo select, .js-datos-trabajo input').prop('disabled', false);
			$('.js-datos-trabajo select.obligatorio, .js-datos-trabajo input.obligatorio').addClass('require');

			$('#datos_trabajo_adicionales select').prop("disabled", false);
			$('#datos_trabajo_adicionales select').addClass('require');
			empresa();
		}
		else
		{
			$('.js-datos-trabajo select,.js-datos-trabajo input').val('');
			$('.js-datos-trabajo select,.js-datos-trabajo input').prop('disabled', true);
			$('.js-datos-trabajo select.obligatorio,.js-datos-trabajo input.obligatorio').removeClass('require');

			$('#datos_trabajo_adicionales select').removeClass('require');
			$('#datos_trabajo_adicionales select').prop('disabled', true);
			$('#datos_trabajo_adicionales select').val('');
		}
	}

	function setup_padres(){
		// padre
		//valores iniciales
		if ($('#AUX1_PADRE_VIVE-S').attr('checked') == 'checked'){
			padre_vive_s();
		};

		if ($('#AUX1_PADRE_VIVE-N').attr('checked') == 'checked'){
			padre_vive_n();			
		};

		if ($('#AUX1_PADRE_VIVE-D').attr('checked') == 'checked'){
			padre_vive_d();
		};
		padre_trabajo();

		// eventos
		$('#AUX1_PADRE_VIVE-S').on('click', function() {
			padre_vive_s();
		});

		$('#AUX1_PADRE_VIVE-N').on('click', function() {
			padre_vive_n();
		});

		$('#AUX1_PADRE_VIVE-D').on('click', function() {
			padre_vive_d();
		});

		$('#CENS_SIT_LABORAL_PADRE').on('change', function() {
			padre_trabajo();
		});

		// madre
		//valores iniciales
		if ($('#AUX1_MADRE_VIVE-S').attr('checked') == 'checked'){
			madre_vive_s();
		};

		if ($('#AUX1_MADRE_VIVE-N').attr('checked') == 'checked'){
			madre_vive_n();			
		};

		if ($('#AUX1_MADRE_VIVE-D').attr('checked') == 'checked'){
			madre_vive_d();
		};		
		madre_trabajo();

		// eventos
		$('#AUX1_MADRE_VIVE-S').on('click', function() {
			madre_vive_s();
		});

		$('#AUX1_MADRE_VIVE-N').on('click', function() {
			madre_vive_n();
		});

		$('#AUX1_MADRE_VIVE-D').on('click', function() {
			madre_vive_d();
		});

		$('#CENS_SIT_LABORAL_MADRE').on('change', function() {
			madre_trabajo();
		});

		$('#AUX1_PADRE_VIVE-S').focus();
	}

	function desactivar_padre_trabaja_otro()
	{
		$('#AUX2_PADRE_TRAB_OTRO').val('');
		$('#AUX2_PADRE_TRAB_OTRO').prop('disabled', true);
		$('#AUX2_PADRE_TRAB_OTRO').removeClass('require');
	}

	function desactivar_sit_laboral_padre()
	{
		$('#CENS_SIT_LABORAL_PADRE').val('');
		$('#CENS_SIT_LABORAL_PADRE').prop('disabled', true);
		$('#CENS_SIT_LABORAL_PADRE').removeClass('require');
	}

	function desactivar_datos_trabajo_padre()
	{
		$('.datos_trabajo_padre select, .datos_trabajo_padre input').each(function(){
				$(this).val('');
				$(this).prop('disabled', true);
				if ($(this).hasClass('require')) {
					$(this).removeClass('require');
				}
		});
		
	}

	function padre_vive_s()
	{
		$('#CENS_SIT_LABORAL_PADRE').prop('disabled', false);
		$('#CENS_SIT_LABORAL_PADRE').addClass('require');
	}

	function padre_vive_n()
	{
		desactivar_sit_laboral_padre();
		desactivar_datos_trabajo_padre();
		desactivar_padre_trabaja_otro();
	}

	function padre_vive_d()
	{
		padre_vive_n();
	}

	function activar_datos_trabajo_padre()
	{
		$('.datos_trabajo_padre select, .datos_trabajo_padre input').each(function(){
			$(this).prop('disabled', false);
			$(this).addClass('require');
		});
	}

	function padre_trabajo()
	{
		if ($('#CENS_SIT_LABORAL_PADRE option:selected').val() == '1'){
			activar_datos_trabajo_padre();
			desactivar_padre_trabaja_otro();
		}

		if ( $.inArray($('#CENS_SIT_LABORAL_PADRE option:selected').val(),['','2','4']) != -1){
			desactivar_datos_trabajo_padre();
			desactivar_padre_trabaja_otro();
		}

		if ($('#CENS_SIT_LABORAL_PADRE option:selected').val() == '3'){
			desactivar_datos_trabajo_padre();
			$('#AUX2_PADRE_TRAB_OTRO').prop('disabled', false);
			$('#AUX2_PADRE_TRAB_OTRO').addClass('require');
		}
	}

	/// madres
	function madre_vive_s()
	{
		$('#CENS_SIT_LABORAL_MADRE').prop('disabled', false);
		$('#CENS_SIT_LABORAL_MADRE').addClass('require');
	}

	function madre_vive_n()
	{
		desactivar_sit_laboral_madre();
		desactivar_datos_trabajo_madre();
		desactivar_madre_trabaja_otro();
	}

	function madre_vive_d()
	{
		madre_vive_n();
	}

	function desactivar_madre_trabaja_otro()
	{
		$('#AUX2_MADRE_TRAB_OTRO').val('');
		$('#AUX2_MADRE_TRAB_OTRO').prop('disabled', true);
		$('#AUX2_MADRE_TRAB_OTRO').removeClass('require');
	}

	function desactivar_sit_laboral_madre()
	{
		$('#CENS_SIT_LABORAL_MADRE').val('');
		$('#CENS_SIT_LABORAL_MADRE').prop('disabled', true);
		$('#CENS_SIT_LABORAL_MADRE').removeClass('require');
	}

	function desactivar_datos_trabajo_madre()
	{
		$('.datos_trabajo_madre select, .datos_trabajo_madre input').each(function(){
				$(this).val('');
				$(this).prop('disabled', true);
				if ($(this).hasClass('require')) {
					$(this).removeClass('require');
				}
		});
		
	}

	function activar_datos_trabajo_madre()
	{
		$('.datos_trabajo_madre select, .datos_trabajo_madre input').each(function(){
			$(this).prop('disabled', false);
			$(this).addClass('require');
		});
	}

	function madre_trabajo()
	{
		if ($('#CENS_SIT_LABORAL_MADRE option:selected').val() == '1'){
			activar_datos_trabajo_madre();
			desactivar_madre_trabaja_otro();
		}

		if ( $.inArray($('#CENS_SIT_LABORAL_MADRE option:selected').val(),['','2','4']) != -1){
			desactivar_datos_trabajo_madre();
			desactivar_madre_trabaja_otro();
			
		}

		if ($('#CENS_SIT_LABORAL_MADRE option:selected').val() == '3'){
			desactivar_datos_trabajo_madre();
			$('#AUX2_MADRE_TRAB_OTRO').prop('disabled', false);
			$('#AUX2_MADRE_TRAB_OTRO').addClass('require');
		}
	}

	function setup_estudios (){
		$('#AUX2_ALU_OTESTSUP_UNI').focus();
	}

	function setup_tecnologia (){
		tecno_regularidad();

		$('#AUX2_ALU_TEC_INT_REGUL').on('change', function() {
			tecno_regularidad();
		});

		$('#AUX2_ALU_TEC_PC_CASA').focus();
	}

	function tecno_regularidad(){
		var selector_checks = '#acceso_internet input[type=checkbox],#utilizacion-internet input[type=checkbox]';
		if ($('#AUX2_ALU_TEC_INT_REGUL option:selected').val() != '' && $('#AUX2_ALU_TEC_INT_REGUL option:selected').val() != '4') {
			$(selector_checks).each(function(){
				$(this).removeAttr("disabled");
			});
			
		} else {
			$(selector_checks).each(function(){
				$(this).removeAttr("checked");
				$(this).prop('disabled', true);
			});
		}
	}

	function setup_deporte (){
		deporte_practica();
				
		$('#AUX1_PRACTICA_DEPORTES').on('click', function() {
			deporte_practica();
		});

		$('#AUX1_PRACTICA_DEPORTES').focus();
	}

	function deporte_practica(){
		if ($('#AUX1_PRACTICA_DEPORTES').is(':checked')) {
			$('#deporte_datos input[type=checkbox]').each(function(){
				$(this).removeAttr("disabled");
			});
		} else {
			$('#deporte_datos input[type=checkbox]').each(function(){
				$(this).removeAttr("checked");
				$(this).prop('disabled', true);
			});				
		}
	}

	function setup_idioma(){
		$('#AUX2_ALU_IDIOMA_INGL-3').focus();
	}

	function seteos() {
		if (info.id_form == 'principales'){
			setup_principales();
		}

		if (info.id_form == 'financiamiento'){
			setup_financiamiento();
		}

		if (info.id_form == 'trabajo'){
			setup_trabajo();
		}

		if (info.id_form == 'padres'){
			setup_padres();
		}

		if (info.id_form == 'estudios'){
			setup_estudios();
		}

		if (info.id_form == 'tecnologia'){
			setup_tecnologia();
		}

		if (info.id_form == 'deporte'){
			setup_deporte();
		}

		if (info.id_form == 'idioma'){
			setup_idioma();
		}
		mantener_valores_guardados();
		$('#columna_2').undelegate('.guardar', 'click');
		$('#columna_2').delegate('.guardar', 'click', function (){
			kernel.evts.disparar('cambio_algo_guardar');
			unset_cambio();
			guardar_form();
			return false;
		});
	}

	function validar_email(value) {
		var filter = /^([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+.)+([a-zA-Z0-9]{2,4})+$/;
		return filter.test(value);
	}

	function guardar_form(callback) {
		if ($('#'+$('#form_id').val()+' .js-error').length > 0) {
			return false
		}

		var url = info.url_guardar;
		kernel.util.clear_interval(id_intervalo);
		kernel.ajax.load(url, $(id), {
			historia: false,
			type: 'POST',
			data: $('#'+$('#form_id').val()).serializeArray(),

			success: function() {
				$('.editable').each(function() { 
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
                                
                                // Si los datos se guardan bien le quito la clase 'con-faltantes' (le saca el rojo de fondo).
                                $('a.censo.active').removeClass('con-faltantes');
			},
			error: function(r) {
				$("input, select").css('background-color', 'white');
				for (var i=0; i< r.campos_error.length; ++i) {
					$('#'+r.campos_error[i]).css('background-color', 'red');
				}
				$('[name="__csrf"]').val(r.csrf_token);
				kernel.ui.show_mensaje(info.msg_error_al_guardar, {tipo:'alert-error'});
			},
			complete: function () {
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
				agregar_cartel_error(elem);
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
	
	function agregar_cartel_error(elem)
	{
		var editable_id = elem.attr('id');
		var clase_error = 'js-error-require';
		var span_clase_error = 'js-error-require_'+editable_id;
		elem.addClass(clase_error);
		var error = $('<span class="obligatorio"></span>');
		error.addClass('alert-error');
		error.addClass('js-error');
		error.addClass(span_clase_error);
		$('[for="'+editable_id+'"]').append(error);
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
		habilitar_boton_confirmar();
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
			deshabilitar_boton_confirmar();
		}

	}

	function deshabilitar_boton_guardar()
	{
		$('.guardar').prop('disabled', true);
	}

	function deshabilitar_boton_confirmar()
	{
		$('#btnConfirmar').prop('disabled', true);
	}

	function habilitar_boton_guardar()
	{
		$('.guardar').prop('disabled', false);
	}
	
	function habilitar_boton_confirmar()
	{
		$('#btnConfirmar').prop('disabled', false);
	}

	function set_cambio()
	{
		//kernel.evts.disparar('cambio_algo_status');
		cambio = true;
		$('.guardar').text('Guardar');
		habilitar_boton_guardar();
	}

	function unset_cambio()
	{
		cambio = false;
		$('.guardar').text('Guardar');
		deshabilitar_boton_guardar();
	}

	return {
		onload: function() {
			$('input.date').datepicker( "destroy" );
            $('input.date').datepicker({
                changeMonth: true,
                changeYear: true,
                firstDay: 0
            });
			
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
