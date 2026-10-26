kernel.renderer.registrar_pagelet('edicion_asistencias', function(info) {
    var id = '#' + info.id;
	
    return {
        onload: function() {
			$('#js-guardar-asistencia').show().position({
				my: 'left',
				at: 'right center',
				offset: '5 0',
				of: $('#js-info-mesa')
			});
			
			$(id).find('.box-asistencia').click(function() {
				var box = $(this);
				if (box.hasClass('ausente')) {
					box.find('.check-asistencia input').prop('checked',true);
					box.removeClass('ausente');
				} else {
					box.find('.check-asistencia input').prop('checked',false);
					box.addClass('ausente');
				}
			});
			
			$(id).find('.form-renglones').submit(function() {
				var $form = $(this);
				kernel.ajax.call($form.attr('action'), {
					type: 'POST',
					data: $form.serializeArray(),
					success: function(response) {
						kernel.ui.show_mensaje(response.cont);
					}
				});
				return false;
			});
        }
    }
})