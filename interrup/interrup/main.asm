;
; interrup.asm
;
; Created: 13/04/2018 12:39:39
; Author : MaedhrosIx
;

.ORG 0x0000					; Organiza todo a partir de la dirección 0x0000
RJMP setup					; Asegurar que el programa comience en la etiqueta setup

; ******************************************************************************************************
; RUTINA DE CONFIGURACIONES
setup: 
	SER r16					; Cargar el valor inmediato 0xFF (todos los bits en 1) en el registro 16
	CLR r17
	CLR r18
	CLR r19
	CLR r20

	; ***** Configuraciones de puertos *****
	; Configurar Puerto B, Pin5 como salida
	LDI r16, 0b00111111
	OUT DDRB, r16
	; Configurar Puerto C como salidas
	OUT DDRC, r16			; Colocar el registro de Dirección de Datos (DDR) del puerto B como salidas para todos los pines
	; Configurar Puerto D, Pin2 como entrada
	LDI r16, 0b11111011
	OUT DDRD, r16

	; *** Configurar la interrupción INT0
	; En primer lugar se activan las interrupciones (activar bit7 del SREG)
	SEI
	; Después habiliar la interrupción0 INT0
	SBI EIMSK, 0
	; Es posible modificar la la forma en que se activa la interupción con EICRA
	; 00	LOW
	; 01	CHANGE
	; 10	FALLING
	; 11	RISING
	LDI r22, 0b00000011
	STS EICRA, r22	; Se requiere utilizar STS por el espacio en memoria
	; A PARTIR DE AQUÍ SE PUEDEN USAR LAS INTERRUPCIONES
	
; ******************************************************************************************************
; RUTINA DE CONTADOR INCREMENTAL
loop:
	LDI r17, 0x00			; colocar r17 al inicio de la memoria EEPROM
	continc:
		CALL EEPROM_read	; Leer la EEPROM en la dirección asignada por r18:r17
		OUT PORTC, r19		; Enviar los valores por el PORTC
		BST r19,6			; Guardar bit 6 del r19 en T (SREG6)
		BLD r20,5			; Cargar el bit T del SREG en el bit del registro 
		OUT PORTB, r20		; Enviar el dato por el PORTB
		RCALL delay_05		; Llamar al delay

		INC r17				; Incrementa r17 para avanzar por la memoria
		CPI r17, 10			; Compara r17 con 10
		BRNE continc		; En caso de que no sean iguales, ir a continc
	
	RJMP loop				; Entrar dentro de un loop infinito (salta a la etiqueta loop)

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
; RUTINA LECTURA DE EEPROM
EEPROM_read:
	; asegurar que haya una lectura en proceso
	SBIC EECR, EEPE
	RJMP EEPROM_read	; Salto relativo al mismo en caso de que la instrucción anterior no de un salto

	; Establecer la dirección, en el registro EEAR de 16 bits
	OUT EEARH, r18
	OUT EEARL, r17

	; Inicia la lectura, bit 0 del registro de control EERE EEPROM Read Enable
	SBI EECR, EERE

	; Colocar el dato en el registro
	IN r19, EEDR
	RET

; ******************************************************************************************************
; INTERRUPCIONES

; Interrupción INT0
EXT_INT0:
	LDI r17, 0x00
	; Regresar al punto donde se quedo el código al mandar a llamar la interrupción
	RETI