kernel.renderer.registrar_pagelet('lista_materias', function(info) {
    var id = '#' + info.id;    
	
	function info_materia_inscripto() {
		var enlace = $(id + ' .seleccionada').find('a.item-materia');
		
		var materia = enlace.data('nombre-materia');
		enlace.html('<i class="icon-thumbs-up"></i> ' + materia);
	}
	
	function info_materia_baja() {
		var enlace = $(id + ' .seleccionada').find('a.item-materia');
		
		var materia = enlace.data('nombre-materia');
		enlace.html(materia);
	}

	var cargando_materia = false;
	
	function info_materia_cargada(params) {
		var anchors = id + ' a.item-materia';
        $(anchors).parent().removeClass('seleccionada');
		
        cargando_materia = false;
		
		var anchor_seleccionado = anchors + '[href$="' + params.href + '"]';
        $(anchor_seleccionado).parent().addClass('seleccionada');
		
		$('#menu-materias').collapse('hide');
    }

    function registrar_disparadores() {
		$(id).delegate('#menu-materias li', 'click', function() {
			$(this).find('a').trigger('click');
		});
		
		$(id).delegate('li > a', 'click', function(e) {
			if (cargando_materia) {
				return false;
			}
			cargando_materia = true;
			
			setTimeout(function() {
				cargando_materia = false;
			}, 5000);
			
            if (e.ctrlKey) { // para que ctrl + click abra una nueva pestaña
                return true;
            }
			
            kernel.evts.disparar('seleccion_materia', {
                href: $(this).attr('href'),
				materia: $(this).text()
            });
            
            return false;
        });
	}	
    
    function registrar_listeners() {
        kernel.evts.escuchar('info_materia_cargada', info_materia_cargada);
        kernel.evts.escuchar('info_materia_inscripto', info_materia_inscripto);
        kernel.evts.escuchar('info_materia_baja', info_materia_baja);
        kernel.evts.escuchar('info_examen_inscripto', info_materia_inscripto);
        kernel.evts.escuchar('info_examen_baja', info_materia_baja);
    }

    return {
        onload: function() {
            registrar_listeners();
			registrar_disparadores();
			$('#menu-materias').collapse({
				toggle: true
			});
        }
    }
}, '_comun/pagelets')