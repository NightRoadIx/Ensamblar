;
; MemoriaEEPROM.asm

.ORG 0x0000			; Organizar desde la dirección 0x0000
RJMP main
main:
	LDI r16, 8		; Cargar el valor de 8 en el registro 16
	LDI r17, 0		; Cargar el registro 17 con la parte baja de la dirección a guardar el dato
	LDI r18, 0		; Cargar el registro 18 con la parte alta de la dirección a guardar el dato
	; Llamar a la rutina de escritura
	; CALL EEPROM_write
	; Llamar a la rutina de lectura
	; CALL EEPROM_read

; * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; El dato a escribir está en el registro 16
; Se escribe en las direcciones r18:r17
EEPROM_write:
	; asegurar que no se hace una escritura en el proceso
	SBIC EECR, EEPE		; SBIC P,b, en esta caso registro de control del EEPROM, bit 1 EEPE (EEPROM Write Enable)
						; Salto si el bit del registro está borrado
	RJMP EEPROM_write	; Salto relativo al mismo en caso de que la instrucción anterior no de un salto

	; Establecer la dirección, en el registro EEAR de 16 bits
	OUT EEARH, r18
	OUT EEARL, r17

	; Coloca el dato en el registro EEDR para el datoa leer o escribir
	OUT EEDR, r16

	; Pone en alto al habilitador maestro, bit 2 del registro de control
	; Al colocarse en alto, se cuenta con 4 ciclos de reloj para iniciar la escritura
	SBI EECR, EEMPE

	; Inicia la escritura
	SBI EECR, EEPE
	OUT EECR, r17
	RET

; * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; El dato a leer se guardará en el registro 16
; Se lee de las direcciones r18:r17
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