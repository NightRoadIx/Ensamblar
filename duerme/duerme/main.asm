; Incluir definiciones para el ATMEGA328P
.INCLUDE "m328pdef.inc"

.ORG 0x0000					; Organiza todo a partir de la dirección 0x0000
RJMP setup					; Asegurar que el programa comience en la etiqueta setup

; ******************************************************************************************************
; RUTINA DE CONFIGURACIONES
setup: 
	; Limpieza de registros de propósito general a utilizar
	CLR r16					; Uso general
	CLR r17					; Contador
	CLR r18					; Configuraciones
	CLR r24					; Para rutina de retraso
	CLR r25					; Para rutina de retraso

	; ***** Configuraciones de puertos *****
	; Configurar Puerto B, pines 0 a 5 como salidas
	LDI r16, 0b00111111
	OUT DDRB, r16
	; Configurar Puerto D, pines 7 y 5 como salidas, los demás como entradas
	; pin2 INT0, se utilizará para las interrupciones
	LDI r16, 0b10100000
	OUT DDRD, r16

	NOP
	SBI PORTD, 7
	SBI PORTD, 5

; ******************************************************************************************************
; RUTINA LOOP
loop:
	CLR r16
	CLR r17
	flasheo:						; Hacer que los LEDs parpadeen 5 veces
		OUT PORTB, r16
		CALL delay_05
		SER r16
		OUT PORTB, r16
		CALL delay_05
		INC r17
		CPI r17, 5
		BRNE flasheo

		; Mandar uno tiempo antes de que entre en modo SLEEP
		CALL delay_05
		CALL delay_05
		CALL delay_05
		; Apagar todos los LEDs
		SER r16
		OUT PORTB, r16

	; Mandar a dormir al microcontrolador
	dormir:
		; Configurar la interrupción en modo FALLING
		LDI r18, 0b00000010
		STS EICRA, r18
		; Habilitar la interrupción externa INT0
		SBI EIMSK, 0

		; Configurar el modo de SLEEP
		; Hay varios modos a escoger mediante el registro SMCR
		; bits 3,2,1
		; 000		Modo Idle
		; 001		Modo de reducción de ruido en el ADC
		; 010		Modo de baja potencia
		; 011		Modo de ahorro de energía
		; 100		Reservado
		; 101		Reservado
		; 110		Modo de espera (Standby)
		; 111		Modo de espera extendido
		; Bit 0 activa el modo seleccionado (o por medio de SLEEP)
		LDI r18, 0b00000110
		STS SMCR, r18

		; Finalmente activar las interrupciones
		SEI

	main:
		SLEEP		; Mandar a dormir al microcontrolador de la forma seleccionada
					; Solo despertará con alguna interrupción externa o mediante el Watch Dog Timer
		RJMP main

; ******************************************************************************************************
; RUTINA DE RETRASO
; A partir de este punto, todo es parte del loop del delay
delay_05: 
	LDI r16, 24					; Cargar un valor de 8 en el registro 16
; Valores iniciales calculados para el retraso
outer_loop: 
	LDI r24, low(3037)			; Cargar low(3037) en el registro 24
	LDI r25, high(3037)			; Cargar high(3037) en el registro 25
	delay_loop: 
		ADIW r24, 1				; Añadir inmediatamente a la palabra, r24:r25 se incrementan
		BRNE delay_loop			; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
		DEC r16					; disminuir r16
		BRNE outer_loop			; si no hay un overflow ("salir si no es igual"), regresar a la etiqueta
		RET						; regresar de la subrutina

; ******************************************************************************************************
; INTERRUPCIONES
; Interrupción INT0
EXT_INT0:
	CLI
	CLR r18
	STS SMCR, r18				; Limpiar el registro SMCR para "despertar" al microcontrolador
	; Regresar al punto donde se quedo el código al mandar a llamar la interrupción
	RETI