kernel.renderer.registrar_pagelet('lista_mensajes', function(info) {
	var id = '#' + info.id;

	return {
		onload: function() {
			$(id).delegate('table .adjunto', 'click', function(e) {
				e.stopPropagation();
			});
			$(id).delegate('table tr', 'click', function() {
				
				var id = $(this).attr('id');

				if ($('#'+id).hasClass('abierto')) {
					$('#'+id).removeClass('abierto');
					$('#' + id + ' .icono-colapsado').removeClass('icon-minus');
					$('#msg_' + id).slideUp('slow');
					$('#' + id).removeClass('leido');
				} else {
					
					if($('#mensaje' + id).html() != ""){
						$('#' + id).addClass('leido');
						$('#' + id + ' .icono-colapsado').addClass('icon-minus');
						$('#imgestado' + id).removeClass('icon-envelope');
						$('#imgestado' + id).addClass('icon-ok');
						$('#msg_' + id).slideDown('slow');
						$('#' + id).addClass('abierto');						
					} else {
						kernel.ajax.call($(this).data('url-leer'), {
							type: 'get',
							data: {
								id: id
							},
							success: function(data) {
								$('#mensaje' + id).html(data.cont);
								$('#' + id).addClass('leido');
								$('#' + id + ' .icono-colapsado').addClass('icon-minus');
								$('#imgestado' + id).removeClass('icon-envelope');
								$('#imgestado' + id).addClass('icon-ok');
								$('#msg_' + id).slideDown('slow');
								$('#' + id).addClass('abierto');
							}
						});						
					}
				}
				return false;
			});

			$(id).delegate('table tr', 'keypress', function(e) {
				if (e.which == 13) {
					$(this).trigger('click');
				}
			});

		}
	}
})