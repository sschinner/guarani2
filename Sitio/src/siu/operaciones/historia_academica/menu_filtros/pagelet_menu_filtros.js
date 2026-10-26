kernel.renderer.registrar_pagelet('menu_filtros', function(info) {
    var id = '#' + info.id;
	var mensajes = info.mensajes;
	
	return {
		get_params_filtro: function() {
			var checks = "";
			$('#form_filtros input').each(function(){
				if ($(this).is(':checked')){
					checks = checks + $(this).val()+",";
				}
			})
			return checks;
		},
		get_estados_filtro: function() {
			var estado_cursada = $(id+' a[filtro="cursada"]').attr('estado');
			var estado_examen = $(id+' a[filtro="examen"]').attr('estado');
			var estado_equivalencia = $(id+' a[filtro="equivalencia"]').attr('estado');
			return "e_cu="+estado_cursada+"&e_ex="+estado_examen+"&e_eq="+estado_equivalencia;
		},
		
		onload: function() {
			if (info.checks){
				$.each(info.checks, function(index, value) {
					$(id+' input[type="checkbox"][value="'+value+'"]').prop('checked',true);
				});
			}
			
            $(id + ' input').click(function() {
                kernel.evts.disparar('filtrar');
            });
            
            $(id + ' a').click(function() {
                var filtro = $(this).attr('filtro');
				var estado = $(this).attr('estado');
                if (filtro =="todo"){
					$(id + ' input').prop('checked', true);
					$(id + ' a[estado]').attr('estado', 'A');
                }
				
                if (filtro =="ninguno"){
					$(id + ' input').prop('checked', false);
					$(id + ' a[estado]').attr('estado', 'A');
                }
                
				// combinación de filtros para cursadas
				if (filtro =="cursada"){
					if (estado == "A"){
						$(id + ' input.'+filtro).prop('checked', false);
						$(id + ' input#cursadasAprobadas').prop('checked', true);
						$(id + ' input#cursadasPromocionadas').prop('checked', true);
						$(this).attr('estado', 'T');
					}
					
					if (estado == "T"){
						$(id + ' input.'+filtro).prop('checked', true);
						$(this).attr('estado', 'N');
					}
					
					if (estado == "N"){
						$(id + ' input.'+filtro).prop('checked', false);
						$(this).attr('estado', 'A');
					}
                }
				
				// combinación de filtros para Exámenes
				if (filtro =="examen"){
					if (estado == "A"){
						$(id + ' input.'+filtro).prop('checked', false);
						$(id + ' input#examenesAprobados').prop('checked', true);
						$(this).attr('estado', 'T');
					}
					
					if (estado == "T"){
						$(id + ' input.'+filtro).prop('checked', true);
						$(this).attr('estado', 'N');
					}
					
					if (estado == "N"){
						$(id + ' input.'+filtro).prop('checked', false);
						$(this).attr('estado', 'A');
					}
                }
				
				// combinación de filtros para equivalancias
				if (filtro =="equivalencia"){
					if (estado == "A"){
						$(id + ' input.'+filtro).prop('checked', false);
						$(id + ' input#equivalenciasAprobadas').prop('checked', true);
						$(this).attr('estado', 'T');
					}
					
					if (estado == "T"){
						$(id + ' input.'+filtro).prop('checked', true);
						$(this).attr('estado', 'N');
					}
					
					if (estado == "N"){
						$(id + ' input.'+filtro).prop('checked', false);
						$(this).attr('estado', 'A');
					}
                }
				
				kernel.evts.disparar('filtrar');
				return false;
            });
		}
	}
})