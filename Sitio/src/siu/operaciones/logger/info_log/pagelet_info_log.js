kernel.renderer.registrar_pagelet('info_log', function(info) {
    var id = '#' + info.id;
    function init_filtro() {
        function accionar_filtro(li)
        {
            var $li = $(li);
            var valor = '#' + $li.children('span').attr('class');
            filtro.accionar($li, 'debug', valor);            
        }
        
        filtro.agregar('debug', {
            elems_eliminar: function(valor) {
                return $('#info div:not('+ valor +')');
            },
            elems: function() {
                return $('#info div');
            },
            evt__pre_filtrar: function() {
                //desactivamos el resto de los filtros
                $('#filtro_debug li.seleccionado').each(function() {
                    accionar_filtro(this);
                })
            }
        });
        
        $('#filtro_debug li').click(function() {
            accionar_filtro(this);
        });        
    }
    
    return {
        onload: function() {
//            filtro = new util.filtro();
//            init_filtro();
        }
    }
})