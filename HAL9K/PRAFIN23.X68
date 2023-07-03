*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : Khaoula Ikkene Marc García Bonet y ,Carolina Marín Sánchez 
* Date       : 19/05/2023
* Description: Emulador de la HAL9000
*-----------------------------------------------------------
  ORG $1000
EMEM:   DC.W $E082,$E09B,$E0B4,$E01D,$2020,$C006,$2031,$C017,$F160
        DC.W $F170,$CE70,$3040,$EFFD,$501E,$4008,$8000,$0001
        DC.W $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
ET0:    DC.W 0 ;eregistro T0
ET1:    DC.W 0 ;eregistro T1
EX2:    DC.W 0 ;eregistro X2
EX3:    DC.W 0 ;eregistro X3
EX4:    DC.W 0 ;eregistro X4
EX5:    DC.W 0 ;eregistro X5
EX6:    DC.W 0 ;eregistro X6
EX7:    DC.W 3 ;eregistro X7
ESR:    DC.W 0 ;eregistro de estado (00000000 00000CNZ)

START:
      CLR.W EPC   
FETCH:
       
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	        ; ESCRIBID VUESTRO CODIGO AQUI	
        MOVE.W EPC,A0
        ADD.W EPC,A0  ;Para  compensar la diferencia con el PC del 68k
        MOVE.W EMEM(A0),EIR ; relativo al PC
        ADDQ.W #1,EPC
         
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta sección debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificación en 
        
        

    	    ; ESCRIBID VUESTRO CODIGO AQUI   
            ; en la subrutina usaremos D0 para copiar el EIR 
            
	        SUBA.W #2,A7 ; guardar espacio para el parametro de salida D1
	        MOVE.W EIR, -(A7) ; guardar espacio para el parametro de entrada EIR
	        

	        JSR DECOD
	        ADDQ.W #2,A7 ; Eliminar el EIR de la pila
	        MOVE.W (A7)+,D1 ; guardar el id en D1
	                     
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ELOA
    JMP ESTO
    JMP ELOIP
    JMP ESTIP
    JMP EGOI
    JMP EGOZ
    JMP EGON
    JMP EEXIT
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP EAND
    JMP ESET
    JMP EADQ
    JMP ELSH
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecución de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ELOA:

    JSR ValueofI  
;A1 contiene la @ del registro destino.
    JSR ValueofM   
;A6 contiene la @ del registro fuente.
    MOVE.W (A6),(A1)
    
    ;Actualizar los flags
    JSR FlagZ
    JSR FlagN   
    
    BRA FETCH
    
ESTO:

    JSR ValueofI
   ;A1 contiene la @ del registro fuente.
    JSR ValueofM    
    ;A6 contiene la @ de la posición destino. 
    MOVE.W (A1),(A6)
    
    ;No se actualizan los flags

    BRA FETCH

ELOIP:

    JSR ValueofI
    ;A1 contiene la @ del registro destino.
    JSR ValueofB    
    ;A6 tiene el registro cuya dirección contiene la posición de memoria fuente
    
    MOVE.W (A6),D2
    MULU.W #2,D2
    LEA.L EMEM,A2 
    ADDA.W D2,A2  ;A2 contiene la posición de memoria fuente. 
    MOVE.W (A2),(A1)
    ADD.W #1,(A6) ;Xb <- [Xb]+1
    
     ;Actualizar los flags  
    JSR FlagZ
    JSR FlagN   
    
    BRA FETCH

    
      
ESTIP:
   
    JSR ValueofI
    ;A1 contiene la dirección del registro definido por 'i'.
    JSR ValueofB
    ;A6 contiene la dirección de Rb.
    MOVE.W (A6),D2
    MULU.W #2,D2
    LEA.L EMEM,A2
    ADD.W D2,A2 ;A2 contiene la dirección destino.
    MOVE.W (A1),(A2)
    ADDQ.W #1,(A6) ;Xb <- [Xb] + 1 

   ;No se actualizan los flags
    BRA FETCH
	
EGOI:

     
    JSR ValueofMAbsolut 
    ;D2 contiene el valor de M
    MOVE.W D2,EPC ; cargar M en el EPC
    
    ;No se actualizan los flags
    
    BRA FETCH

EGOZ:

    MOVE.W ESR,D3
    AND.W #1,D3 
    CMP #0,D3  ;Se usa D3 para comprobar si el bit 0 de ESR (Flag Z) es 1 o 0
    BEQ Z0 ; salta si Z = 0
    JSR ValueofMAbsolut 
    ;D2 contiene el valor de M
    MOVE.W D2,EPC  ; cargar M en el EPC

 
Z0:
  ;no se cumple la condición
  BRA FETCH  

EGON:
    
    BTST #1,ESR
    BEQ N1 ;salta si N = 1
    BRA FETCH
N1:
    JSR ValueofMAbsolut 
    ;D2 contiene el valor de M
    MOVE.W D2,EPC  ; cargar M en el EPC
    BRA FETCH  
    
EEXIT:


 SIMHALT ; detener la máquina
ECOPY:

    JSR ValueofB
    ;A6 contiene la dirección de Rb.
    MOVE.W (A6),D7 ;D7=[Rb]
  
    JSR ValueofC
    ;A6 contiene la dirección de Rc.
    MOVE.W D7,(A6) ;Rc <- [Rb]
    
 ;Actualizar los flags  
    JSR FlagZ
    JSR FlagN


    BRA FETCH

EADD:
    
    JSR ValueofA
    ;A6 contiene la dirección de Ra.
    MOVE.W (A6),D7 ;D7=[Ra]
    
    JSR ValueofB
    ;A6 contiene la dirección de Rb.
    ADD.W (A6),D7 ;D7=[Ra]+[Rb]
    JSR FlagC ; actualizar el FlagC justo después de ejecutar la instrucción
      
    JSR ValueofC
    ;A6 contiene la dirección de Rc.
    MOVE.W D7,(A6) ;Rc <- [Ra]+[Rb] 
 ;Actualizar los flags      
    JSR FlagZ
    JSR FlagN
    
    BRA FETCH

ESUB:
    
    JSR ValueofA
    ;A6 contiene la dirección de Ra.
    MOVE.W (A6),D7
    NOT.W D7
    ADDQ.B #1,D7 ;D7=[Ra]'
    
    
    JSR ValueofB
    ;A6 contiene la dirección de Rb.
    MOVE.W (A6),D5 ;D5=[Rb]
    ADD.W D7,D5 ;D5=[Rb]-[Ra]
    JSR FlagC  ; actualizar el FlagC justo después de ejecutar la instrucción
    
    JSR ValueofC
    ;A6 contiene la dirección de Rc.
    MOVE.W D5,(A6) ;Rc=[Rb]-[Ra]
    
    JSR FlagZ
    JSR FlagN
    
    BRA FETCH

EAND:

    JSR ValueofA
    ;A6 contiene la dirección de Ra.
    MOVE.W (A6),D7 ;D7=[Ra]
    
    JSR ValueofB
    ;A6 contiene la dirección de Rb.
    MOVE.W (A6),D5 ;D5=[Rb]
    AND.W D7,D5
    
    JSR ValueofC
    ;A6 contiene la dirección de Rc.
    MOVE.W D5,(A6) Rc <- [Ra] ^ [Rb]
    
    JSR FlagZ
    JSR FlagN

    BRA FETCH

ESET:
 
    JSR ValueofK
    ;D2 contiene el valor de K.
    MOVE.W D2,D5 ;Se guarda el valor de D2 porque D2 se usará en ValueofC
    JSR ValueofC
    MOVE.W D5,(A6)
 
    JSR FlagZ
    JSR FlagN
    
    BRA FETCH

EADQ:

    JSR ValueofK
    ;D2 contiene el valor de K.
    MOVE.W D2,D5 ;Se guarda el valor de D2 porque D2 se usará en ValueofC
    JSR ValueofC
    ADD.W D5,(A6) Rc <- [Rc]+K
    
    JSR FlagC
    JSR FlagZ
    JSR FlagN
    
    BRA FETCH

ELSH:
    
   JSR ValueofB
   
   MOVE.W EIR,D2
   AND.W #$0700,D2 ;0700 para que los unos coincidan con la posición de ppp.
   LSR.W #8,D2 ;D2 contiene el valor de ppp
   
   MOVE.W EIR,D3
   AND.W #1,D3 ;D3 contiene el valor de n
   CMP.W #0,D3
   BEQ N0
   
   MOVE.W (A6),D3 ;Si n=1 se produce un desplazamiento a la derecha de ppp bits 
   LSR.W D2,D3
   JSR FlagC
   MOVE.W D3,(A6) ;Rb <- [Rb] right shift p
   
   JSR FlagZ
   JSR FlagN
   
   
   BRA FETCH
   
N0:

   MOVE.W (A6),D3 ;Si n=0 se produce un desplazamiento a la izquierda
   LSL.W D2,D3
   JSR FlagC
   MOVE.W D3,(A6) ;Rb <- [Rb] left shift p
   
   JSR FlagZ
   JSR FlagN

   BRA FETCH

    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI

ValueofI: ; obtener el valor del i
     
     MOVE.W EIR,D2 ;D2 contiene la codificación de la instrucción 
     AND.W #1,D2
     
     JSR ValueofR
     
     MOVE.W A6,A1 ;Se guarda el valor de A6 en A1 por si se vuelve a usar A6.
     RTS
     
 ValueofM: ; para sacar m de la instrucción
     MOVE.W EIR,D2   
     AND.W #$01FE,D2 ;01FE para que los unos coincidan con M
     LSR.W #1,D2
     MULU.W #2,D2 ;se multiplica por 2 porque una posición de la HAL son dos del 68k
     LEA.L EMEM,A6
     ADD.W D2,A6  
     RTS   
     
 ValueofMAbsolut: ;Obtener M sin cargarlo en A6
    MOVE.W EIR, D2
    AND.W #$01FE, D2
    LSR.W #1,D2
    RTS

ValueofK:

 MOVE.W EIR,D2 
 AND.W #$07F8,D2 ;07F8 para que los unos coincidan con la posición de K
 LSR.W #3,D2 ;Despl. 3 a la derecha porque el último bit de K es el #3 de D2
 EXT.W D2 ;Extensión de signo de K
 RTS
  
   
ValueofA: ;obtener el valor de aaa
     MOVE.W EIR,D2 
     AND.W #$0700,D2 ;0700 para que los unos coincidan con la posición de aaa
     LSR.W #8,D2 ; D2 contiene el valor de aaa
     
     JSR ValueofR 
     RTS 

    
ValueofB: ;obtener el valor de bbb

     MOVE.W EIR,D2 
     AND.W #$0070,D2 ;0070 para que los unos coincidan con la posición de bbb
     LSR.W #4,D2 ; D2 contiene el valor de bbb
     
     JSR ValueofR 
     RTS  

ValueofC:  ;obtener el valor de ccc
     MOVE.W EIR,D2 
     AND.W #$0007, D2 ;D2 contiene el valor de ccc
       
     JSR ValueofR
     RTS  
     
FlagZ: 

 ;El registro D4 será utilizado para las subrutinas de actualización de flags  

 MOVE.W (A6),D4 
 BNE CERO ;salta Si Z=0
 
 MOVE.W ESR, D4
 BSET.L #0,D4 
 MOVE.W D4, ESR ;Flag Z HAL = 1
 RTS
CERO:
 MOVE.W ESR, D4
 BCLR.L #0, D4
  MOVE.W D4, ESR ;Flag Z HAL = 0

 RTS       
 
FlagN:
    MOVE.W (A6),D4 
    CMP.W #0,D4
    BMI NEG ;salta Si N=1
    ;Si N = 0
    MOVE.W ESR, D4
    BCLR.L #1, D4
    MOVE.W D4, ESR ;Flag N HAL = 0

    RTS
NEG:  
    MOVE.W ESR, D4
    BSET.L #1,D4
    MOVE.W D4, ESR ;Flag Z HAL = 1

    RTS

FlagC:
  
  BCS C1   ;Si el carry del 68k está a 1 se salta a C1
  MOVE.W ESR, D4
  BCLR.L #2,D4 ;Si no, el bit correspondiente a Carry de ESR se pone a 0
  MOVE.W D4, ESR

 RTS
C1:
  MOVE.W ESR, D4 ;Se mueve ESR a D4 y se pone el bit de carry a 1.
  BSET.L #2,D4   
  MOVE.W D4, ESR
  

  RTS
  
ValueofR:
  
  ;Se va mirando el valor de D2 para saber qué registro se está tratando.
  
  CMP.B #7,D2
  BEQ R7
  CMP.B #6,D2
  BEQ R6
  CMP.B #5,D2
  BEQ R5
  CMP.B #4,D2
  BEQ R4
  CMP.B #3,D2
  BEQ R3
  CMP.B #2,D2
  BEQ R2
  CMP.B #1,D2
  BEQ R1
  LEA.L ET0,A6
  RTS
  
  ;Se carga A6 con la dirección del registro obtenido con los CMP.
  
  R1:
  LEA.L ET1,A6
  RTS
  R2:
  LEA.L EX2,A6
  RTS
  R3:
  LEA.L EX3,A6
  RTS
  R4:
  LEA.L EX4,A6
  RTS
  R5:
  LEA.L EX5,A6
  RTS
  R6:
  LEA.L EX6,A6
  RTS
  R7:
  LEA.L EX7,A6
  RTS


 

           
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	        ; ESCRIBID VUESTRO CODIGO AQUI
	MOVE.W D0, -(A7)  ; guardar el registro de datos a usar        
    MOVE.W 6(A7),D0        ; mover EIR en D0
    BTST.L #15, D0  
    BNE B1  ; bit = 1; Z = 0
    
 
  
 
   ;Se miran los 4 o 5 primeros bits para saber de qué instrucción se trata.
B0:
    
  BTST.L #14, D0
    BNE B01
    
B00:   
  BTST.L #13, D0
    BNE B001
B000:   
     BTST.L #12, D0
    BNE B0001
B0000:
 MOVE.W #0, 8(A7)  ; LOA    
      JMP ET3
B0001:
    MOVE.W #1,8(A7) ;STO
     
     JMP ET3

B001:
    BTST.L #12,D0
    BNE B0011
B0010:
    MOVE.W #2,8(A7) ; LOIP   
     JMP ET3 
B0011:
    MOVE.W #3, 8(A7) ; STIP
       
     JMP ET3
B01:
    BTST.L #13,D0
    BNE B011
B010:
    BTST.L #12,D0
    BNE B0101
B0100:
    MOVE.W #4,8(A7) ; GOI
    ;RTS
     JMP ET3 
B011:
    BTST.L #12,D0
    BNE B0111 
B0110:
 MOVE.W #6,8(A7) ; GON
    JMP ET3 
B0101:
    MOVE.W #5,8(A7) ; GOZ
    JMP ET3 
    
B0111:
    ; no existe esta instrucción
         JMP ET3 
    
B1:
    BTST.L #14, D0
    BNE B11
B10:
    MOVE.W #7,8(A7) ; EXIT
      JMP ET3 
    
B11:
    BTST.L #13, D0
    BNE B111
B110:
    BTST.L #12,D0
    BNE B1101
B1100:
    BTST.L #11,D0
    BNE B11001
B11000:
    MOVE.W #8,8(A7) ; COPY
    JMP ET3 
B11001:
    MOVE.W #9,8(A7) ; ADD
    JMP ET3 
    
B1101:
    BTST.L #11,D0
    BNE B11011
B11010:
    MOVE.W #10,8(A7) ; SUB   
    JMP ET3    
B11011:
    MOVE.W #11,8(A7) ; AND  
     JMP ET3    
B111:
    BTST.L  #12,D0
    BNE B1111
B1110:
    BTST.L #11, D0
    BNE B11101
B11100:
    MOVE.W #12, 8(A7) ; SET
    JMP ET3    
B1111:
    BTST.L #11, D0
    BEQ B11110

B11110:
    MOVE.W #14,8(A7) ; LSH
    JMP ET3   
B11101:
    MOVE.W #13, 8(A7) ; ADQ
   
  ET3:
    MOVE.W  (A7)+, D0 ; recuperar el valor de D0 
    RTS   

  
    ;--- FDECOD: FIN DECOD
    END    START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
