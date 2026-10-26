var hay_dev_bar = true;
var opened = false;
var loading_logger = false;
var debug__tabla_catalogo, debug__tabla_controles;
var cargando_dev_bar = false;
function debug__esconder_tablas()
{
	if (debug__tabla_catalogo) debug__tabla_catalogo.hide();
	if (debug__tabla_controles) debug__tabla_controles.hide();	
}
$(document).ready(function() {
	/********************************************************************/
	// INICIALIZACIÓN BARRA
	/********************************************************************/
	var bar = $("<div id='development_bar'>").click(function(e) {
		e.stopPropagation();
		debug__esconder_tablas();
		if (opened) {
			$('#db_show_log').animate({
				height: '0'
			}, 400, function() {
				$('#db_expand').removeClass('arrow-down');
			});
			opened = false;
		} else {
			reload_dev_bar_content(function() {
				$('#db_show_log').animate({
					height: '300'
				}, 400, function() {
					$('#db_expand').addClass('arrow-down');
				});
				opened = true;
			});
		}
	});

	/********************************************************************/
	// CERRAR BARRA
	/********************************************************************/
	bar.append($("<div id='db_close'>").click(function(e) {
		$('#db_wrapper').remove();
		return false;
	}));

	/********************************************************************/
	// ABRIR LOGGER EXTERNO
	/********************************************************************/
	bar.append($("<div id='db_open'>").click(function() {
		window.open(kernel_config.url_log + '/elegir_log/' + kernel_config.log_id);
		return false;
	}));
	
	/********************************************************************/
	// PAGELETS
	/********************************************************************/
	kernel.evts.escuchar('guarani.beforeCambiarOp', function() {
		$('#db_pagelets').data('showing_pagelets', false);
	}, true);
	
	bar.append($("<div id='db_pagelets'>").click(function() {
		if ($(this).data('showing_pagelets')) {
			$('.pagelet').css({border: 'inherit'});	
		} else {
			$('.pagelet').css({border: '2px solid red'});
		}
		
		$(this).data('showing_pagelets',!$(this).data('showing_pagelets'));
		
		return false;
	}));
	
	/********************************************************************/
	// CATALOGO
	/********************************************************************/
	var catalogo = $("<div id='db_catalogo'>");
	bar.append(catalogo.click(function() {
		if (debug__tabla_catalogo.is(':visible')) {
			debug__tabla_catalogo.hide();
		} else {
			debug__esconder_tablas();
			debug__tabla_catalogo.show().position({my: 'left bottom', at: 'left top', offset: '3 -3', of: $('#development_bar')});
		}
		return false;
	}));
	catalogo.append($("<div id='db_catalogo_count'>"));

	/********************************************************************/
	// CONTROLES
	/********************************************************************/
	var controles = $("<div id='db_controles'>");
	bar.append(controles.click(function() {
		if (debug__tabla_controles.is(':visible')) {
			debug__tabla_controles.hide();
		} else {
			debug__esconder_tablas();
			debug__tabla_controles.show().position({my: 'left bottom', at: 'left top', offset: '3 -3', of: $('#development_bar')});
		}
		return false;
	}));
	controles.append($("<div id='db_controles_count'>"));
	
	
	bar.append($("<div id='db_expand'>"));
	bar.append($("<div id='db_time'>"));
	bar.append($("<div id='db_error_php'>"));
	bar.append($("<div id='db_error'>"));
	bar.append($("<div id='db_mem'>"));
	bar.append($("<div id='db_session_size'>"));
	
	$('body').append($("<div id='loading-dev-bar'>").hide());
	
	reload_dev_bar();
	
	
	// Se agrega al body el logger
	var log_content = $('<div id="db_show_log">');
	var wrapper = $("<div id='db_wrapper'>");
	wrapper.append(bar).append(log_content);
	$('body').append(wrapper);
	
	
	// Enganche loader con ajax
	$(document).ajaxStart(function() {
		$('#loading-dev-bar').show().position({my: 'left top', at: 'right top', offset: '10 2', of: $('#db_expand')});
	});
	
	$(document).ajaxComplete(function(e, jqXHR) {
		if (! loading_logger) {
			kernel_config.log_id = jqXHR.getResponseHeader('guarani-log');
		}
	});
	
	$(document).ajaxStop(function() {
		if (loading_logger) {
			loading_logger = false;
		} else {
			reload_dev_bar();
		}
		$('#loading-dev-bar').hide();
	});
	
});

function reload_dev_bar_content(afterComplete)
{
	cargando_dev_bar = true;
	loading_logger = true;
	if (!afterComplete) {
		afterComplete = function() {}
	}
	$.ajax({
		url: kernel_config.url_log + 'ajax_elegir_log/' + kernel_config.log_id,
		dataType: 'json',
		complete: function(e) {
			cargando_dev_bar = false;
			var contenido;
			try {
				contenido = $.parseJSON(e.responseText).content;
			} catch (e) {
				contenido = e.responseText;
			}
			$('#db_show_log').html('<pre>' + contenido + '</pre>');
			afterComplete();
		}
	});
}

function reload_tabla_catalogo(catalogo) {
	var tabla = $('<table id="db_catalogo_tabla">').hide();
	tabla.addClass('table').addClass('table-bordered').addClass('table-condensed');
	tabla.append($('<thead><tr><th>Clase</th><th>Método</th><th>Medio</th><th>Acción</th><th>Tiempo</th></tr></thead>'));
	var tbody = $('<tbody>');
	tabla.append(tbody);
	var tr;
	for (var i = 0; i < catalogo.length; i++) {
		tr = $('<tr>');
		tr.append($('<td>').html(catalogo[i].clase));
		tr.append($('<td>').html(catalogo[i].metodo));
		tr.append($('<td>').html(catalogo[i].medio));
		tr.append($('<td>').html(catalogo[i].accion));
		tr.append($('<td>').html(catalogo[i].tiempo));
		tbody.append(tr);
	}
	if (debug__tabla_catalogo) {
		debug__tabla_catalogo.remove();
	}
	
	debug__tabla_catalogo = tabla;
	$('body').append(debug__tabla_catalogo);
	$('#db_catalogo_count').text('(' + catalogo.length + ')');
}

function reload_tabla_controles(controles) {
	var tabla = $('<table id="db_controles_tabla">').hide();
	tabla.addClass('table').addClass('table-bordered').addClass('table-condensed');
	tabla.append($('<thead><tr><th>Punto</th><th>Control</th><th>Comportamiento</th><th>Medio</th><th>Resultado</th><th>Tiempo</th><th>Mensaje</th></tr></thead>'));
	var tbody = $('<tbody>');
	tabla.append(tbody);
	var tr;
	for (var i = 0; i < controles.length; i++) {
		tr = $('<tr>');
		tr.append($('<td>').html(controles[i].punto));
		tr.append($('<td>').html(controles[i].control));
		tr.append($('<td>').html(controles[i].comportamiento));
		tr.append($('<td>').html(controles[i].medio));
		tr.append($('<td>').html(controles[i].resultado));
		tr.append($('<td>').html(controles[i].tiempo));
		tr.append($('<td>').html(controles[i].mensaje));
		tbody.append(tr);
	}
	if (debug__tabla_controles) {
		debug__tabla_controles.remove();
	}
	
	debug__tabla_controles = tabla;
	$('body').append(debug__tabla_controles);
	$('#db_controles_count').text('(' + controles.length + ')');
}

function reload_dev_bar()
{
	cargando_dev_bar = true;
	loading_logger = true;	
	$.ajax({
		url: kernel_config.url_log_info + '/' + kernel_config.log_id,
		dataType: 'json',
		error: function(jqXHR, textStatus, errorThrown) {
		},
		success: function(paquete) {
			$('#db_time').html(paquete.time);
			$('#db_error_php').html(paquete.warning);
			$('#db_error').html(paquete.exception);
			$('#db_mem').html(paquete.memory);
			$('#db_session_size').html(paquete.session + ' Kb');
			reload_tabla_catalogo(paquete.catalogo);
			reload_tabla_controles(paquete.controles);
			if (opened) {
				reload_dev_bar_content();
			}
		},
		complete: function() {
			cargando_dev_bar = false;
		}
	});	
	
}