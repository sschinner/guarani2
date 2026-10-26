kernel.renderer.registrar_pagelet('notificaciones', function(info) {
    var id = '#' + info.id;
	var h;
	
	function refresh(es_cursada) {
		$.ajax({
			url: info.url_refresh,                        
			dataType: 'json',
			success: function(datos) {
				if(es_cursada) {
					h = new horario.cursada(datos, 'asignaciones_cursada', info.banda_horaria_cursado);
					$('#eleccion-periodo').change();
				} else {
					var $ls = $('ul.notif_examenes_listado').html('');
					$(datos).each(function() {
						$ls.append('<li \
								class="notif_examen_inscripto" \
								data-title="&lt;span style=\'font-weight: bold\'&gt;('+this.MATERIA+') '+this.materia+'&lt;/span&gt;" \
								data-content="Fecha de Examen: '+this.fecha_dia+' '+this.fecha_hora+'"> \
								('+this.MATERIA+') '+this.materia+' - '+this.fecha_dia+' '+this.fecha_hora+' \
								</li>');
					});

                    if(datos.length == 0){//Si no hay inscripciones a examenes muestro la leyenda
                        $(id+" p#inscripcion_examenes_notificacion").show();
                    }
                    else{//Si hay inscripciones a examenes escondo la leyenda
                        $(id+" p#inscripcion_examenes_notificacion").hide();

                        $('.notif_examen_inscripto').popover({
                            html: true,
                            placement: 'top',
                            container: 'body',
                            trigger: 'hover'
                        });
                    }

				}
			}
		});
	}
	
    return {
        onload: function() {
			h = new horario.cursada(info.asignaciones, 'asignaciones_cursada', info.banda_horaria_cursado);

			$('#eleccion-periodo').change(function() {
				h[$(this).val()]();
			});
			
			kernel.evts.escuchar('info_materia_inscripto', function() {
				refresh(true);
			});
			kernel.evts.escuchar('info_materia_baja', function() {
				refresh(true);
			});
			
			kernel.evts.escuchar('info_examen_inscripto', function() {
				refresh(false);
			});
			kernel.evts.escuchar('info_examen_baja', function() {
				refresh(false);
			});
        }
    }
}, '_comun/pagelets')
