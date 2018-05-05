; Incluir definiciones para el ATMEGA328P
.INCLUDE "m328pdef.inc"

.ORG 0x0000					; Organiza todo a partir de la dirección 0x0000
RJMP setup					; Asegurar que el programa comience en la etiqueta setup

.ORG 0x000C					; 
RJMP guachdoj				; Lugar de la interrupción por WDT

; ******************************************************************************************************
; RUTINA DE CONFIGURACIONES
setup: 
	
	RCALL WDT_off			; Apagar el WDT para evitar errores si se configura en RESET

	; Limpieza de registros de propósito general a utilizar
	CLR r16					; Uso general
	CLR r17					; Contador
	CLR r18					; Configuraciones
	LDI r19, 0xF0
	CLR r24					; Para rutina de retraso
	CLR r25					; Para rutina de retraso

	; ***** Configuraciones de puertos *****
	; Configurar Puerto B, pines 0 a 5 como salidas
	LDI r16, 0b00111111
	OUT DDRB, r16
	; Configurar Puerto D, pines 7 y 5 como salidas, los demás como entradas
	LDI r16, 0b10100000
	OUT DDRD, r16

	NOP
	SBI PORTD, 7
	SBI PORTD, 5

	; Esto sucede una vez cada que se resetea el microcontrolador
	CLR r17
	flasheo:					; Dar un parpadeo de los LEDs 5 veces
		CLR r16
		OUT PORTB, r16
		CALL delay_05
		SER r16
		OUT PORTB, r16
		CALL delay_05
		INC r17
		CPI r17, 5
		BRNE flasheo

	; CONFIGURAR EL WATCHDOG
	RCALL WDT_config

; ******************************************************************************************************
; RUTINA LOOP
loop:
	RJMP loop				; Se quedará en esto hasta que se desborde el WDT

; ******************************************************************************************************
; RUTINA DE RETRASO
; A partir de este punto, todo es parte del loop del delay
delay_05: 
	LDI r16, 24				; Cargar un valor de 8 en el registro 16
; Valores iniciales calculados para el retraso
outer_loop: 
	LDI r24, low(3037)		; Cargar low(3037) en el registro 24
	LDI r25, high(3037)		; Cargar high(3037) en el registro 25
	delay_loop: 
		ADIW r24, 1				; Añadir inmediatamente a la palabra, r24:r25 se incrementan
		BRNE delay_loop			; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
		DEC r16					; disminuir r16
		BRNE outer_loop			; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
		RET						; regresar de la subrutina


; ******************************************************************************************************
; WATCHDOG CONFIGURACION Y HABILITACION
WDT_config:
	CLI								; Apagar las interrupciones globales
	WDR								; Darle reset al WatchDog

	LDS r16, WDTCSR					; Cargar el valor del Registro de Control del WDT
	ORI r16, (1<<WDCE) | (1<<WDE)
	STS WDTCSR, r16
	; Hay 4 ciclos de reloj para colocal valores del timer, antes de que WDCE cambie a 0
	; Preescaler de 256K = 2.0 s, configurado por los bits WDP3, WDP2, WDP1, WDP0
	; Activar la interrupción por WDT con el registro WDIE
	; Los bits 3 (WDE) y 6 (WDIE) permiten seleccionar el comportamiento cuando se desborda el WDT
	;	WDE		WDIE		Modo									Acción al desbordar
	;	0		0			Detenido								Ninguna
	;	0		1			Modo Interrupción						Ir a la interrupción
	;	1		0			Modo Reset del sistema					Reiniciar
	;	1		1			Modo Interrupción, reset del sistema	Interrupción y luego ir al modo de Reinicio
	LDI r16, (1<<WDIE) | (1<<WDP2) | (1<<WDP1) | (1<<WDP0)
	STS WDTCSR, r16

	SEI								; Encender las interrupciones globales
	RET

; ******************************************************************************************************
; WATCHDOG TURN OFF
WDT_off:
	CLI								; Desactivar las interrupciones globales
	WDR								; Reset al Watchdog timer
	
	IN r16, MCUSR					; Adquirir el valor del MCUSR
									; MCUSR Registro de Estado del MCU, que controla las banderas de reset del uControlador
									; Bit 3 WDRF, Bandera de Reset por WDT 
									; Bit 2 BORF, Bandera de Reset por Brown-Out
									; Bit 1 EXTRF, Bandera de Reset por acción externa
									; Bit 0 PORF, Bandera de Reset por un Encendido del sistema
	ANDI r16, (0xFF & (0<<WDRF))	; Apagar la bandera de WDT
	OUT MCUSR, r16					; Limpiar todos los posibles RESET
	LDS r16, WDTCSR					; Leer el registro de control del WatchDog
	ORI r16, (1<<WDCE) | (1<<WDE)	; Escribir un 1 en los bits WDCE (4) y WDE (3) del registro WDTCSR
	STS WDTCSR, r16					; Registro de control del timer del Watch-Dog
	LDI r16, (0<<WDE)				; Apagar el WDT
	STS WDTCSR, r16
	SEI								; Activar de nuevo las interrupciones globales
	RET

; ******************************************************************************************************
; Rutina de interrupción	
guachdoj:
	RCALL WDT_config				; Reconfigurar de nuevo el WDT para que re-inicie
									; Esto es muy importante, puede hacerse con WDT simplemente
									; Pero re-configurar es más seguro
	OUT PORTB, r19					; Mostrar algo al entrar a la interrupción
	SWAP r19

	RETI							; Regresar de la interrupción