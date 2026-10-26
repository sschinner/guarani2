kernel.renderer.registrar_pagelet('renglones', function(info) {
    var id = '#' + info.id;
	var fecha_inicio, fecha_fin;

	/*************************************************************************/
	// UTIL
	/*************************************************************************/
	function get_nota(row) {
		return $.trim(row.find('.nota').val());
	}

	function get_res_nota(row) {
		var nota = get_nota(row);
		if (nota == '') {
			return '';
		}
		
		return info.escala[nota].r;
	}
	
	function update_resultado(row) {
		var texto = 'Ausente';
		var resultado_id = 'U';
		if (chequeo_nota_valida(row)) {
			var nota = get_nota(row);
			if (nota != '') {
				texto = _resultados[info.escala[nota].r];
				resultado_id = info.escala[nota].r;
			}
		} else {
			texto = '';
		}
		
		row.find('.wrapper-resultado .texto').html(texto);
		row.find('.wrapper-resultado input').val(resultado_id);
	}

	function setup_autocomplete() {
		$('#notas_examen_query').autocomplete({
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
			
		$('#notas_examen_query').keypress(function(event){
			if(event.keyCode == 13){
				event.preventDefault();
			}
		})
	}

	function update_condicion(row) {
		var texto = '';
		if (chequeo_nota_valida(row)) {
			var nota = get_nota(row);
			if (nota != '') {
				texto = info.escala[nota].c;
			}
		} else {
			texto = '';
		}
		
		row.find('.concepto').html(texto);
	}
	
	/*************************************************************************/
	// CHEQUEO DE ERRORES
	/*************************************************************************/	
	/**
	 * Una nota es válida si es vacía o si existe en el mapeo de la escala
	 */
	function chequeo_nota_valida(row) {
		var nota = get_nota(row);
		return (nota == '') || (typeof info.escala[nota] !== "undefined");
	}

	function validar_renglon(row) {
		var valido = true;
		
		if (msg_arriba || msg_abajo) {
			msg_arriba.remove();
			msg_abajo.remove();
		}
		
		if (! chequeo_nota_valida(row)) {
			$(id).plugin_renglones('set_error', row.find('.nota'), info.mensajes.nota_invalida);
			valido = false;
		} else {
			$(id).plugin_renglones('remove_error', row.find('.nota'));
		}
		
		update_resultado(row);
		update_condicion(row);

		return valido;
	}

	function validar_fecha(row) {
		var fecha = create_date(row.find('.fecha').val());
		if (fecha.getTime() < fecha_inicio.getTime() || fecha_fin.getTime() < fecha.getTime()) {
			$(id).plugin_renglones('set_error', row.find('.fecha'), info.mensajes.fecha_invalida);	
		} else {
			$(id).plugin_renglones('remove_error', row.find('.fecha'));
		}
	}

	function validar_inicial(row) {
		update_resultado(row);
		update_condicion(row);
	}

	function create_date(date_string) {
		var fecha_split = date_string.split('/');
		return new Date(fecha_split[2], fecha_split[1]-1, fecha_split[0]);
	}

	var msg_arriba, msg_abajo;
    return {
        onload: function() {
			$(id).plugin_renglones({
				validadores: [{
						tipo: 'inicial',
						validar: validar_inicial
					}, {
						tipo: ["fecha"],
						validar: validar_fecha
					}, {
						tipo: ["nota"],
						validar: validar_renglon
					}
				],
				
				highlight_renglon: info.highlight_renglon,
				
				success: function() {
					kernel.ui.show_mensaje(info.guardado_exitoso, {});
				},
				error: function() {
					kernel.ui.show_mensaje(info.guardado_error, {tipo: 'alert-error'});
				}
			});

			fecha_inicio = create_date(info.fecha_inicio);
			fecha_fin = create_date(info.fecha_fin);
			setup_autocomplete();
                        $('.btn-primary').focus();
        }
    }
})
