kernel.renderer.registrar_pagelet('renglones', function(info) {
	var id = '#' + info.id;
	var fecha_inicio, fecha_fin;
	
	/*************************************************************************/
	// UTIL
	/*************************************************************************/
	function get_nota(row) {
		return $.trim(row.find('.nota').val());
	}

	function get_cond_nota(row) {
		var nota = get_nota(row);
		if (nota == '') {
			return '';
		}
//		var escala = _escalas.get_escala(id_escala)
//		escala.validar(nota);
		return info.escala[nota].r;
	}
	
	function get_res_nota(row) {
		var nota = get_nota(row);
		if (nota == '') {
			return '';
		}
		
		var result = info.escala[nota].r;
		
		if (result == "P" && (!info.prom_abierta || !row.hasClass('promocional'))){			
			result = "A";
		}
		
		return _resultados[result];
	}

	function get_cond(row) {
		return row.find('.condicion').find(':selected').val();
	}

	function get_res_cond(row) {
		var cond = get_cond(row);
		var esta_seteada = cond != '' && (typeof _condiciones[cond].resultado !== "undefined");
		var result = _condiciones[cond].resultado;
		if (result == "P" && (!info.prom_abierta || !row.hasClass('promocional'))){
			result = "A";
		}
		if (esta_seteada) {
			return _resultados[result];
		} else {
			return '';
		}
	}
	/*************************************************************************/
	// CHEQUEO DE ERRORES
	/*************************************************************************/
	/**
	 * Setea una condici?n v?lida para la nota actual
	 */
	function update_condicion(row) {
		var cond_nota = get_cond_nota(row);
		var condicion = false;
		
		if (cond_nota == "P" && (!info.prom_abierta || !row.hasClass('promocional'))){
			//console.log('update_condicion: '+row.hasClass('promocional'));
			cond_nota = "A";
		}

		$.each(_condiciones, function() {
			if (this.resultado == cond_nota) {
				condicion = this;
				return false;
			}
		});
		
		if (condicion === false) { // no hay condici?n que matchee con la nota
			//console.log('error de matcheo de resultado de condici?n con resultado de nota');
		}
		
		row.find('.condicion').val(condicion.cond);
	}
	
	// Setea el resultado a partir de la nota
	function update_resultado_nota(row) {
		var res = get_res_nota(row);
		row.find('.resultado').html(res);
	}
	
	// Setea el resultado a partir de la condici?n
	function update_resultado_cond(row) {
        update_condicion(row);
		var res = get_res_cond(row);
		row.find('.resultado').html(res);
	}
	
	/**
	 * Una nota es v?lida si es vac?a o si existe en el mapeo de la escala
	 */
	function chequeo_nota_valida(row) {
		var nota = get_nota(row);
		var valida = (nota == '') || (typeof info.escala[nota] !== "undefined");
		
		return valida;
	}

	function chequeo_consistencia(row) {
		var res_cond = row.find('.condicion').find(':selected').data('resultado');

		// Si la nota es promocionable la condici?n puede ser promoci?n o aprobado
		if (get_cond_nota(row) == "P" && (res_cond == "P" || res_cond == "A")){
			return true;
		} else {
			return res_cond == get_cond_nota(row);
		}
	}

	function chequeo_porcentaje_valido(row) {
		var valor = row.find('.asistencia').val();
		if ((valor == '')) {
			return true;
		}
		
		var porcentaje = parseFloat(valor);
		return (! isNaN(valor) && porcentaje >= 0 && porcentaje <= 100);
	}

	/**
	 * si la nota no es v?lida o no pasa el chequeo de consistencia (comparar 
	 * los resultados de la condici?n y la nota) se limpia el campo nota
	 */
	function control_condicion(row) {
		var nota = row.find('.nota');
		var resultado = row.find('.resultado');
		var cond_nota = get_cond_nota(row); //condicion asociada a la nota
		var cond = get_cond(row);
		if (cond == "")
		{
			var result = "";
			var res_descr = "";
		}
		else
		{
			var result = _condiciones[cond].resultado; //resultado de la condicion seleccionada
			var res_descr = _resultados[result];

		}
		
		if(!(cond_nota == 'P' && (result == 'A' || result == 'P'))){
			nota.val('');	
		}

		resultado.val(result);

		row.find('.resultado').html(res_descr);	
		update_result_ausente(row);
		
		/*if(resultado.val() == 'U' && nota.val() == ''){
			update_condicion_resultado(row);
			return false;
		}*/
		
//		if (! chequeo_nota_valida(row) || ! chequeo_consistencia(row)) {
//			var nota = row.find('.nota');
//			//nota.val('');
//			//$(id).plugin_renglones('remove_error', nota);
//			//$(id).plugin_renglones('set_error', nota, info.mensajes.nota_no_coincide_condicion_promocion);
//            if(nota.val() != ''){
//                $("tr#"+id_renglon_before_change+" select.condicion").val(val_condicion_before_change);
//                kernel.ui.show_mensaje(info.mensajes.nota_no_coincide_condicion_seleccionada, {tipo: 'alert-error'});
//            }
//		}
//        else{
//		    update_resultado_cond(row);
//        }
	}

	function validar_renglon(row, tipo) {
		var valido = true;
		if (! chequeo_porcentaje_valido(row)) {
			$(id).plugin_renglones('set_error', row.find('.asistencia'), info.mensajes.asistencia_invalida);
			valido = false;
		} else {
			$(id).plugin_renglones('remove_error', row.find('.asistencia'));
		}

		if (! chequeo_nota_valida(row)) {
			$(id).plugin_renglones('set_error', row.find('.nota'), info.mensajes.nota_invalida);
			valido = false;
		} else { // si es v?lido hay que setear el resultado
			if (get_nota(row) != '') { // s?lo cambia el resultado si la nota no es vac?a
				//update_resultado_nota(row);
				update_resultado_cond(row);
			}
			$(id).plugin_renglones('remove_error', row.find('.nota'));
		}

		// no coincide el resultado de la nota con el resultado de la condici?n
		if (valido && ! chequeo_consistencia(row)) {
			if (get_nota(row) != '') { // se actualiza la condici?n s?lo si la nota no es vac?a
				update_condicion(row);
			}
		}

		return valido;
	}
	
	function validar_fecha(row) {
		var fecha = create_date(row.find('.fecha').val());
		//console.log(fecha);
		if (fecha.getTime() < fecha_inicio.getTime() || fecha_fin.getTime() < fecha.getTime()) {
			$(id).plugin_renglones('set_error', row.find('.fecha'), info.mensajes.fecha_invalida);	
		} else {
			$(id).plugin_renglones('remove_error', row.find('.fecha'));
		}
	}
	
	function validar_inicial(row) {
		if (get_nota(row) != '') { // si la nota no es vac?a entonces se actualiza la condici?n
			//update_resultado_nota(row);
			//update_condicion(row);
		} else {
			//update_resultado_cond(row);
		}
	}
	
	function hay_cambios() {
		var cambiaron_datos = false;
		
		$(id).find('tbody tr').each(function() {
			$(this).find('input, select').each(function(){
				var campo = $(this);
				if (campo.val() != campo.attr('prev-value')){
					cambiaron_datos = true;
				}
			});
		});
		
		return cambiaron_datos;
	}
	
	function setup_autocomplete() {
		$('#notas_cursada_query').autocomplete({
			source: info.url_autocomplete,
			minLength: 1,
			search: function() {
				kernel.ui.show_loading();
			},
			open: function() {

			},
			response: function(event, ui) {
				kernel.ui.hide_loading();
				if (ui.content.length === 0) {
					kernel.ui.show_mensaje(info.mensajes.no_se_encontraron_alumnos, {tipo: 'alert-error'});
				}
			},
			select: function( event, ui ) {
				guarani.cambiar_op({
					href: ui.item.id
				});
			}
		});
			
		$('#notas_cursada_query').keypress(function(event){
			if(event.keyCode == 13){
				event.preventDefault();
			}
		})
	}
	
	function create_date(date_string) {
		var fecha_split = date_string.split('/');
		return new Date(fecha_split[2], fecha_split[1]-1, fecha_split[0]);
	}
	
// setea resultado a partir de la condici?n seleccionada, en caso de que el resultado sea 'U' o ausente, se deshabilita el combo 'nota'.	
	function update_result_ausente(row){
		var res_cond = row.find('.js-condicion').find(':selected').data('resultado');
		row.find('.resultado').val(res_cond);
//		var res_descr = _resultados[res_cond];
//		row.find('.resultado').html(res_descr);

		if (res_cond == "U"){
			row.find('.nota').val('');
			row.find('.nota').attr('disabled', 'disabled');
		} else {
			row.find('.nota').removeAttr('disabled');
		}
	}
	
	function deshabilitar_renglones(){
			var row = $(this).parents('tr');

				$(id).find('.tabla-renglones tr').each(function() {
					var resultado = row.find('.condicion').find(':selected').data('resultado');
					if (resultado == "U" && !($(this).hasClass('error-renglon'))){
						row.find('.nota').attr('disabled', 'disabled');
					}else{
						row.find('.nota').removeAttr('disabled');					
					}
				});	

			// Si el acta de promocion esta cerrada entonces deshabilita la edicion de los alumnos promocionales
			if(info.prom_abierta == 0){
				$(id).find('.tabla-renglones tr').each(function() {
					var res_cond = row.find('.js-condicion').find(':selected').data('resultado');
					row.find('.resultado').val(res_cond);

					if($(this).hasClass('promocional') && res_cond == 'P' && !($(this).hasClass('error-renglon'))){//si el alumno es promocional deshabilita la edicion
						$(this).find('input, select').prop( "disabled", true );
						$(this).not('.header-tabla').addClass('renglon-deshabilitado');
					}
				});			
			}
			
			// Si esta en cierre parcial de actas de cursadas, entonces deshabilita la edicion de los
			// alumnos a los que se le cargo nota/condicion de regularidad/resultado...
			
                        // ******* SE COMENTA EL IF, PERSONALIZADO PARA QUE PERMITA REALIZAR CERRADO PARCIAL Y PODER EDITAR LA NOTAS LUEGO DEL GUARDADO
                        //****** OJO PUEDE TRAER PROBLEMAS DE INCONSISTENCIA CON LA DB
			/*if(info.cierre_parcial){
				$(id).find('.tabla-renglones tr').each(function() {
					var condicion = $(this).find('.condicion').find(':selected').val();
					if( condicion != '' && !($(this).hasClass('error-renglon'))){//si tiene condicion de regularidad deshabilita la edicion porque se encuentra en cierre parcial.
						$(this).find('input, select').prop( "disabled", true );
						$(this).not('.header-tabla').addClass('renglon-deshabilitado');
					}
				});			
			}*/			
		
	}
	return {
		onload: function() {
			guarani.set_condicion_antes_de_navegar(hay_cambios, info.msj_navegacion);

			$(id).plugin_renglones({
				validadores: [{
						tipo: 'inicial',
						validar: validar_inicial
					},{
						tipo: ["fecha"],
						validar: validar_fecha
					},{
						tipo: ["nota", "asistencia"],
						validar: validar_renglon
					}, {
						tipo: ["condicion"],
						validar: control_condicion
					}
				],
				
				highlight_renglon: info.highlight_renglon,
				
				success: function() {
					kernel.ui.show_mensaje(info.guardado_exitoso, {});
					deshabilitar_renglones();
				},
				error: function() {
					kernel.ui.show_mensaje(info.guardado_error, {tipo: 'alert-error'});
					deshabilitar_renglones();
				}
			});
			
			fecha_inicio = create_date(info.fecha_inicio);
			fecha_fin = create_date(info.fecha_fin);
			setup_autocomplete();
			$('.btn-primary').focus();

            $(id).on('focus', 'select.condicion', function(){
                val_condicion_before_change = $(this).val();
                id_renglon_before_change = $(this).parents('tr').attr('id');
            });

            $(id).on('focus', 'select.nota', function(){
				var row = $(this).parents('tr');
				var resultado = row.find('.condicion').find(':selected').data('resultado');
                if (resultado == "U"){
					row.find('.nota').attr('disabled', 'disabled');
				}else{
					row.find('.nota').removeAttr('disabled');					
				}
            });

			deshabilitar_renglones();
		}
	}
})