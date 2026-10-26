kernel.renderer.registrar_pagelet('cabecera', function(info) {
    var id = '#' + info.id;
	
	function bind_escala_notas() {
		var escala_notas_cargada = false;
		var tabla_notas = $("<table style='margin-top: 16px;'><thead><th>Valor</th><th>Descripci&oacute;n</th><th>Resultado</th></thead><tbody></tbody></table>");
		tabla_notas.addClass('table').addClass('table-condensed');
		$('#ver_escala').click(function() {
			if (!escala_notas_cargada) {
				kernel.ui.show_loading($(this), 'small', {
					my: 'center',
					at: 'right center',
					offset: '10 0',
					of: $(this)
				});
				$.ajax({
					url: info.url_escala,
					success: function(res) {
						$($.parseJSON(res)).each(function() {
							var escala = $(this)[0];
							var fila = $('<tr>');
							fila.append($('<td>' + escala.DESCRIPCION + '</td>'));
							fila.append($('<td>' + escala.RESULTADO + '</td>'));
							fila.append($('<td>' + escala.VALOR + '</td>'));
							tabla_notas.find('tbody').append(fila);
						});
						escala_notas_cargada = true;
						kernel.ui.hide_loading();
						$.facebox(tabla_notas);
					}
				});
			} else {
				$.facebox(tabla_notas);
			}
			
		});
	}
	
    return {
        onload: function() {
			bind_escala_notas();
			
			$(id).find('button#js-colapsar-info-mesa').click(function() {
				var barra = $('.js-barra-herramientas');
				//console.log(barra);
				if (barra.is(':visible')) {
					barra.slideUp();
				}
				
				var detalle = $('.js-detalle-materia');
				
				if (detalle.is(':visible')) {
					detalle.slideUp();
				} else {
					detalle.slideDown();
				}
			});
			
			$(id).find('button#js-colapsar-herramientas').click(function() {
				var detalle = $('.js-detalle-materia');
				
				if (detalle.is(':visible')) {
					detalle.slideUp();
				}
				
				var barra = $('.js-barra-herramientas');
				
				if (barra.is(':visible')) {
					barra.slideUp();
				} else {
					barra.slideDown();
				}
			});
        }
    }
})