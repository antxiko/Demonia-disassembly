# Demonia (Microids, 1986, MSX1) - desensamblado
#
# `make` extrae los bloques de la cinta, monta la memoria como queda al cargar,
# la traza y comprueba que al rehacer los listados sale EXACTAMENTE el .cas
# original, byte a byte.
#
# Lo que hace raro a este juego: no cabe en la RAM visible. Busca un slot con
# 64 KB y esconde 26 KB DEBAJO de la ROM del BASIC (paginas 0 y 1). Los siete
# trozos que trae la cinta detras del cargador no se ejecutan donde se cargan:
# cada uno lleva pegada una rutinilla que conmuta el slot, hace un LDIR y
# devuelve el slot como estaba. Por eso aqui hay TRECE listados y no nueve, y
# por eso el verify tiene dos pasos: primero cada listado, y luego pegar los
# trozos en el orden de la cinta.

CAS     := demonia.cas
CAS_SHA := 69031ee25099df0703332ca74a64b52e6dd9909e4cfded4c3699be153adc5fc9
SYMS    := work/msx.sym

# Los listados que salen del trazado global de la imagen de 64K...
IMAGEN  := bajo0000 bajo4000 bajo6000 bajo7900 juego
# ...y los que se trazan aparte, porque se ejecutan donde la cinta los deja.
CINTA   := arranque carga1 carga2 carga3cola carga4cola carga5cola \
           carga6cab carga7cola
TODOS   := $(IMAGEN) $(CINTA)
ASMS    := $(patsubst %,src/demonia_%.asm,$(TODOS))

.PHONY: all verify clean extract cuerpos imagen trazado listados sanity test cinta densidad sobra imagenes web

all: verify

# ---------------------------------------------------------------- extraccion
cinta:
	@if [ ! -f "$(CAS)" ]; then \
	  echo ""; \
	  echo "  Falta la imagen de cinta: $(CAS)"; \
	  echo ""; \
	  echo "  No se distribuye con este repositorio, solo el trabajo de"; \
	  echo "  documentacion. Para reconstruirlo todo hace falta tu propia copia"; \
	  echo "  del .cas de Demonia, con ese nombre y en la raiz del proyecto."; \
	  echo "  Debe dar este sha256:"; \
	  echo "      $(CAS_SHA)"; \
	  echo ""; \
	  exit 1; \
	fi
	@echo "$(CAS_SHA)  $(CAS)" | sha256sum -c - >/dev/null 2>&1 \
	  || echo "  AVISO: $(CAS) no da el sha256 esperado; los listados pueden no cuadrar."

extract: extracted/.stamp
extracted/.stamp: tools/cas_parse.py $(CAS) | cinta
	@mkdir -p work extracted
	python3 tools/cas_parse.py $(CAS) extracted > work/cas_parse.log
	@touch $@

# El reparto de los bloques a modulos NO se escribe a mano: sale de la tabla de
# descriptores que el propio cargador lleva en 0x8180, y cuerpos.py aborta si
# alguna entrada no cuadra con el tamano de su bloque.
cuerpos: work/modulos.json
work/modulos.json: tools/cuerpos.py extracted/.stamp
	python3 tools/cuerpos.py extracted work

imagen: work/imagen64k.bin
work/imagen64k.bin: tools/imagen.py src/reparto.txt work/modulos.json
	python3 tools/imagen.py src/reparto.txt work

# ------------------------------------------------------------------ trazado
work/imagen.trace.json: tools/z80trace.py src/imagen.entries src/imagen.nocode work/imagen64k.bin
	python3 tools/z80trace.py work/imagen64k.bin 0x0000 src/imagen.entries work/imagen src/imagen.nocode

work/piezas.json: tools/piezas.py src/piezas.txt work/imagen.trace.json
	python3 tools/piezas.py src/piezas.txt work

define TRAZA_CINTA
work/$(1).trace.json: tools/z80trace.py src/$(1).entries work/piezas.json
	python3 tools/z80trace.py work/$(1).bin $(2) src/$(1).entries work/$(1) src/$(1).nocode
endef
$(eval $(call TRAZA_CINTA,arranque,0x8180))
$(eval $(call TRAZA_CINTA,carga1,0xA000))
$(eval $(call TRAZA_CINTA,carga2,0xAD00))
$(eval $(call TRAZA_CINTA,carga3cola,0xB468))
$(eval $(call TRAZA_CINTA,carga4cola,0xBF32))
$(eval $(call TRAZA_CINTA,carga5cola,0xBB96))
$(eval $(call TRAZA_CINTA,carga6cab,0xAFD0))
$(eval $(call TRAZA_CINTA,carga7cola,0x96E8))

trazado: work/piezas.json $(patsubst %,work/%.trace.json,$(CINTA))

# ----------------------------------------------------------------- listados
listados: $(ASMS)

define LISTADO
src/demonia_$(1).asm: work/$(1).trace.json src/$(1).notes tools/mkasm.py $(SYMS)
	python3 tools/mkasm.py work/$(1).bin $(2) work/$(1).trace.json \
	  src/$(1).notes $(SYMS) $$@ "DEMONIA - MSX - $(3)"
endef
$(eval $(call LISTADO,bajo0000,0x0000,graficos escondidos bajo la ROM del BASIC (paginas 0)))
$(eval $(call LISTADO,bajo4000,0x4000,datos escondidos bajo la ROM del BASIC (pagina 1)))
$(eval $(call LISTADO,bajo6000,0x6000,patrones y colores escondidos bajo la ROM (pagina 1)))
$(eval $(call LISTADO,bajo7900,0x7900,la musica: partitura y reproductor))
$(eval $(call LISTADO,juego,0x8000,el juego))
$(eval $(call LISTADO,arranque,0x8180,el cargador de los siete trozos))
$(eval $(call LISTADO,carga1,0xA000,pantalla de carga en SCREEN 3))
$(eval $(call LISTADO,carga2,0xAD00,pantalla de carga en SCREEN 2))
$(eval $(call LISTADO,carga3cola,0xB468,busca el slot de 64K y copia a 0x4000))
$(eval $(call LISTADO,carga4cola,0xBF32,copia los graficos a 0x0000))
$(eval $(call LISTADO,carga5cola,0xBB96,copia los graficos a 0x1F32))
$(eval $(call LISTADO,carga6cab,0xAFD0,copia patrones y colores a 0x6000))
$(eval $(call LISTADO,carga7cola,0x96E8,copia la musica a 0x7900))

# El trazado de los listados que salen de la imagen lo prepara piezas.py, asi
# que basta con que exista piezas.json.
work/bajo0000.trace.json work/bajo4000.trace.json work/bajo6000.trace.json \
work/bajo7900.trace.json work/juego.trace.json: work/piezas.json

# ------------------------------------------------------------------ sanidad
sanity: listados
	@echo "=================================================================="
	@echo " Coherencia: ningun punto de entrada dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py src/imagen.entries src/juego.notes src/imagen.nocode
	@echo ""
	@echo "=================================================================="
	@echo " Sanidad del trazado: las zonas de datos no pueden salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py work/imagen.trace.json src/imagen.nocode
	@echo ""
	@echo "=================================================================="
	@echo " Cruce COMPLETO: todas las zonas D contra lo que el trazador cree"
	@echo "=================================================================="
	@python3 tools/check_datos_como_codigo.py work src
	@echo ""
	@echo "=================================================================="
	@echo " La memoria montada contra la del emulador, si hay volcado"
	@echo "=================================================================="
	@python3 tools/coteja_ram.py work/imagen64k.bin work/mapa.json work/omsx/ram64k.bin
	@echo ""
	@echo "=================================================================="
	@echo " La portada: descomprimirla tiene que dar el titulo y la firma"
	@echo "=================================================================="
	@python3 tools/portada.py
	@echo ""
	@echo "=================================================================="
	@echo " Las 26 pantallas, dibujadas desde la cinta: 640 baldosas cada una"
	@echo "=================================================================="
	@python3 tools/mapas.py
	@echo ""
	@echo "=================================================================="
	@echo " Presupuesto de la cinta: no deben quedar bytes sin explicar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py work src $(CAS)

verify: listados
	@python3 tools/verifica.py src work $(CAS)
	@$(MAKE) --no-print-directory sanity

densidad:
	@python3 tools/densidad_total.py src

sobra: listados
	@python3 tools/lo_que_sobra.py work src

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

# --------------------------------------------------------------------- web
# Las imagenes NO son capturas: tools/mapas.py las dibuja desde los bytes de la
# cinta, repitiendo el descompresor de 0x819D y revelando cada baldosa como lo
# haria el VDP. Por eso cuelgan de la imagen de memoria y no de un emulador.
imagenes: work/imagen64k.bin
	@mkdir -p docs/imagenes
	@python3 tools/mapas.py

web: imagenes
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py docs/imagenes docs/index.html en
	python3 tools/make_web.py docs/imagenes docs/es/index.html es
	@touch docs/.nojekyll
	@python3 tools/check_enlaces.py docs

clean:
	rm -rf extracted work/*.raw work/*.bin work/*.json work/*.blocks work/*.log
	rm -f extracted/.stamp
