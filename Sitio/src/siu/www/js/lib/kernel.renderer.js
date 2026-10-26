var kernel = kernel || {};
//var __pagelets = {};
kernel.renderer = function() {
	var pagelets_rendered = 0;

	var pagelet_tools = [];

	/** pagelet_tool **/
	var pagelet_tool = function(obj) {
		this.data = obj;
		this.abort = false;
	}

	pagelet_tool.prototype.get_info = function() {
		return this.data.info;
	}
	pagelet_tool.prototype.get_op = function() {
		return this.data.op;
	}
	pagelet_tool.prototype.tiene_archivo_js = function() {
		return this.data.tiene_archivo_js;
	}

	pagelet_tool.prototype.get_clase_js = function() {
		return this.data.clase_js;
	}

	pagelet_tool.prototype.load_css = function(callback) {
		if (this.abort) {
			return;
		}
		kernel.loader.load_css(this.data.css, callback);
	}

	pagelet_tool.prototype.load_content = function() {
		if (this.abort) {
			return;
		}
		var e = document.getElementById(this.data.info.id);
		if (e) {
			e.style.display = 'none';
			$(e).html(this.data.content);
		}            
	}

	pagelet_tool.prototype.load_js = function(callback) {
		if (this.abort) {
			return;
		}
		kernel.loader.load_js(this.data.js, callback);
	}

	pagelet_tool.prototype.cleanup = function() {
		this.abort = true;    
	}

	// los pagelets que hay en la página actual
	var pagelets = {};
	
	// todas las funciones de inicialización de los pagelets
	var pagelet_init_fns = {};
	
	function get_pagelet_init_fn(nombre, op) {
		return pagelet_init_fns[op][nombre];
	}
	
	return {
		registrar_pagelet: function(nombre, fn, op) {
			if (typeof op == 'undefined') {
				op = kernel.util.get_current_op();
			}
			// no está definida la op
			if (typeof pagelet_init_fns[op] == 'undefined') {
				pagelet_init_fns[op] = {};
			}
			
			if (typeof pagelet_init_fns[op][nombre] == 'undefined') {
				pagelet_init_fns[op][nombre] = fn;
			}
			
			kernel.log.add_debug('registro de pagelet', op + ' -> ' + nombre);
		},
		set_state: function(pagelet_tool, state) {
			if (pagelet_tool.abort) {
				return;
			}
			switch (state) {
				case 0: // First state, load the css
					kernel.ui.add_show_loading_count();
					pagelet_tool.load_css(function() {
						kernel.renderer.set_state(pagelet_tool, 1);
					});
					break;
				case 1:
					pagelet_tool.load_content();
					pagelets_rendered++;
					if (pagelets_rendered >= kernel_config.pagelet_count) {
						pagelets_rendered = 0;
						kernel.evts.disparar('kernel.pageletsLoaded', {});
					}
					kernel.renderer.set_state(pagelet_tool, 2);
					break;
				case 2:
					if (kernel_config.stall_js && pagelets_rendered < kernel_config.widget_count) {
						// wait for css and content to render
						setTimeout(function() {
							kernel.renderer.set_state(pagelet_tool, 2)
						}, 100);
					} else {
						pagelet_tool.load_js(function() {
							if ((typeof pagelet_tool.get_clase_js() != 'undefined')) {
								kernel.ui.substract_show_loading_count();
								var info = pagelet_tool.get_info();
								try {
									if (pagelet_tool.tiene_archivo_js()) {
										// instanciamos el pagelet
										pagelets[info.id] = eval(get_pagelet_init_fn(pagelet_tool.get_clase_js(), pagelet_tool.get_op()))(info);
									}

									if (document.getElementById(info.id)) {
										if (info.visible) {
											// se esconde para cargar el contenido y no se vea como
											// se va cargando. en este punto ya está completo, así que es seguro mostrarlo
											document.getElementById(info.id).style.display = 'block';
										}
										document.getElementById(info.id).style.clear = 'both';
										$('#loading').hide();

										if (pagelet_tool.tiene_archivo_js()) {
											// ejecutamos onload después de mostrar el contenido
											pagelets[info.id].onload();
										}
									}
								} catch (e) {
									var clase = pagelet_tool.get_clase_js();
									console.log('error cargando el pagelet "'+ clase +'". Probablemente no se definió el archivo js o el nombre de la clase js no es correcto');
									throw e;
								}
							}
						});
					}
			}
		},

		on_arrival: function(obj) {
			var w = new pagelet_tool(obj);
			kernel.renderer.set_state(w, 0);
			pagelet_tools.push(w);
			kernel.log.add_debug('arribo pagelet', obj);
		},
		on_full_arrival: function(obj) {
			var w = new pagelet_tool(obj);
			kernel.renderer.set_state(w, 2);
			pagelet_tools.push(w);
		},
		pagelet: function(id) {
			if (pagelets[id]) {
				return pagelets[id];
			} else {
				return false;
			}
		},
		cleanup: function() {
			kernel.evts.disparar('kernel.beforeCleanup',{});
			kernel.loader.cleanup();
			for (var i = 0; i < pagelet_tools.length; i++) {
				pagelet_tools[i].cleanup();
			}
			pagelet_tools = [];
			kernel.evts.cleanup();
		}
	};
}();