kernel.renderer.registrar_pagelet('acta', function(info) {
	var id = '#' + info.id;

	return {
		onload: function() {
			$(id + ' #js-filtro_folio').on('change', function () {
				if ($(this).val() != ""){
					$(id+' table.js-folio').hide();
					$('table.js-folio[data-folio="'+$(this).val()+'"]').show();
				} else {
					$(id+' table.js-folio').show();
				}
			});
		}
	}
})