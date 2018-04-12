;
; desplaza.asm
;
; Created: 12/04/2018 13:03:01
; Author : MaedhrosIx
;


.ORG 0x0000
RJMP main
main:
	LDI r16, 128		; Cargar un 128 al r16

; Desplazamiento de bits
; Estas operaciones afectan al bit de acarreo del registro de estado (lo usan como buffer)
desplazamiento:
	LSR r16				; Desplazar una posición a la derecha el bit del registro
	LSR r16				; Desplazar de nuevo
	; El desplazamiento a la izquierda se realiza con la instrucción LSL
	LSL r16
	LSL r16

	ASR r16				; Desplazamiento aritmético hacia la derecha
	ASR r16

	LDI r16, 128
rotacion:
	ROL r16				; Rotación de un bit hacia la izquierda
	; La rotación a la derecha se realiza con ROR
	ROR r16

intercambio:
	SWAP r16			; Realiza un intercambio de nibbles en el registro

; Modificar los bits del registro de estado y brincos dependientes (TODOS LLEVAN A UNA ETIQUETA):
; Nombre		Bit		EnviarAlto		EnviarBajo		BrincaSiAlto	BrincaSiBajo
; Interrupción	(I)		SEI				CLI				BRIE			BRID
; Bit Respaldo	(T)		SET				CLT				BRTS			BRTC
; Medio Acarreo	(H)		SEH				CLH				BRHS			BRHC
; Signo			(S)		SES				CLS				BRGE			BRLT *
; Sobreflujo	(V)		SEV				CLV				BRVS			BRVC
; Negativo		(N)		SEN				CLN				BRMI			BRPL $
; Cero			(Z)		SEZ				CLZ				BREQ			BRNE +
; Acarreo		(C)		SEC				CLC				BRCS			BRCC
;
; Notas
; * BRGE es comparativo brinca si es mayor o igual que, mientras que BRLT brinca si es menor que (todo con signo)
; + BREQ es comparativo brinca si son iguales, mientras que BRNE brinca si no son iguales
; $ BRMI brinca si es negativo, mientras que BRPL brinca si no es negativo
; Se utilizan junto con las instrucciones de comparación CP, CPC (con acarreo) y CPI (con una constante),
; ya que modifican las banderas Z, C, N, V, H, S
; CPSE Rd, Rf realiza la comparacion de dos registros para ver si son iguales

carga:
	LDI r16, 1			; Cargar un 1 a r16
	LDI r17, 8			; Cargar un 8 a r17
	movimiento:
		LSL r16			; Recorrer a la izquierda un bit	
		;RCALL delay_05	; Esperar un tiempo
		CPSE r16, r17	; Comparar si son iguales los registros
		RJMP movimiento	; Si no son iguales entonces sigue dando vuelts
		RJMP carga		; En caso contrario dar un reset
	
; ******************************************************************************************************
; RUTINA DE RETRASO
; A partir de este punto, todo es parte del loop del delay
delay_05: 
	LDI r16, 64				; Cargar un valor de 8 en el registro 16
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
	