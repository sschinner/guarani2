kernel.renderer.registrar_pagelet('edicion_notas', function(info) {
    var id = '#' + info.id;
	var max_texareas = 20;
	/*************************************************************************/
	// UTIL
	/*************************************************************************/
	function get_nota(row) {
		return $.trim(row.find('.nota').val());
	}

	function get_res_nota(row) {
		var nota = get_nota(row);
		if (nota == '') {
			return 'vacio';
		}
		
		return info.escala[nota].r;
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

	function update_resultado(row) {
		var texto = '';
		if (chequeo_nota_valida(row)) {
			var nota = get_nota(row);
			if (nota != '') {
				texto = _resultados[info.escala[nota].r];
				row.find('textarea').removeAttr('disabled');
			} else {
				row.find('textarea').val('');
				row.find('textarea').attr('disabled', 'disabled');
			}
		} else {
			texto = '';
			row.find('textarea').val('');
			row.find('textarea').attr('disabled', 'disabled');
		}
		
		row.find('.resultado').html(texto);
	}
	
	function validar_renglon(row) {
		var valido = true;

		if (! chequeo_nota_valida(row)) {
			$(id).plugin_renglones('set_error', row.find('.nota'), info.mensajes.nota_invalida);
			valido = false;
		}
		
		if (valido) {
			$(id).plugin_renglones('remove_error', row.find('.nota'));
		}
		update_resultado(row);
		return valido;
	}
	
	function validar_inicial(row) {
		update_resultado(row);
	}
	
	function hay_cambios() {
		var cambiaron_datos = false;
		
		$(id).find('tbody tr').each(function() {
			$(this).find('select, textarea').each(function(){
				var campo = $(this);
				if (campo.val() != campo.attr('prev-value')){
					//console.log(campo.id+' valor actual: '+campo.val()+' valor anterior: '+campo.attr('prev-value'));
					cambiaron_datos = true;
				}
			});
		});
		
		return cambiaron_datos;
	}
	
    return {
        onload: function() {
			guarani.set_condicion_antes_de_navegar(hay_cambios, info.msj_navegacion);
			info_ = info;
			
			$(id).plugin_renglones({
				validadores: [{
						tipo: ['inicial'],
						validar: validar_inicial
					},{
						tipo: ["nota"],
						validar: validar_renglon
					}
				],
				
				highlight_renglon: info.highlight_renglon,
				
				success: function() {
					kernel.ui.show_mensaje(info.edicion_notas_parciales_ok, {});
				},
				error: function() {
					kernel.ui.show_mensaje(info.edicion_notas_parciales_error, {tipo: 'alert-error'});
					$('.error-renglon').find('input[type="text"]').focus();
				}
			});
			
			$(id).on('focus', 'textarea', function() {
				var pos = $(this).position();
				$(this).css({ 
					position: "absolute",
					marginLeft: 0, marginTop: 0,
					top: pos.top, left: pos.left,
					'z-index': 100
				});
				$(this).animate({width: 150, height: 100});
			}).on('blur', 'textarea', function() {
				var elem = $(this);
				elem.animate({width: 100, height: 20}, 400, 'linear', function() {
					elem.css({position: 'static', 'z-index': 0});
				});
			}).on('keyup', 'textarea', function(e) {
				if (e.keyCode == 27) {
					$(this).blur();
				}
			});

			function controlo_maximo(elem, cant, maximo){				
				if (cant > maximo){
					elem.val(elem.val().substring(0, maximo));
				}
			}
			
			$(id).on('focus', 'textarea', function() {
				var elem = $(this);				
				controlo_maximo(elem, elem.val().length, info.max_textarea);				
			}).on('blur', 'textarea', function() {
				var elem = $(this);
				controlo_maximo(elem, elem.val().length, info.max_textarea);
			}).on('keyup', 'textarea', function(e) {
				var elem = $(this);
				controlo_maximo(elem, elem.val().length, info.max_textarea);
			});
			
        }
    }
})
