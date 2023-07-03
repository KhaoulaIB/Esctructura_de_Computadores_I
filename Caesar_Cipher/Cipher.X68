*-----------------------------------------------------------
* Titulo:P1 (2022-2023) - Caesar Cipher
* Autores: Khaoula Ikkene y Marc García Bonet y Amal Amghar Amghar
*-----------------------------------------------------------
    ORG    $1000
    DISP: EQU 3
    DICT_SIZE: EQU 5
    DICT_IN: DC.B 'ABCDE'
    DICT_OUT: DS.B DICT_SIZE
    TEXT_SIZE: EQU 26
    TEXT_IN: DC.B 'ESTRUCTURA_DE_COMPUTADORES'
    TEXT_OUT: DS.B TEXT_SIZE
    NCHANGES: DS.W 1
    DS.W 0
*--------------------

 START:  
    CLR NCHANGES ;Para inicializar a 0
    LEA.L DICT_IN, A0 ; usaremos A0 para recorrer DICT_IN
    LEA.L TEXT_IN, A1 
    MOVE.W #DICT_SIZE,D0 ;Inicializamos D0 para LOOP0
    SUBQ.W #1,D0
    
LOOP0:
 
    MOVEA A0,A2 ; A2 contindrá la dirección de los carácteres de DICT_OUT
    ADDA #DICT_SIZE,A2 
    ADDA #DISP,A2 ;A2 está colocado en DICT_OUT + DISP
    CMPA A1,A2  ; Si A2>=A1 vuelve a la primera posicion del DICT_OUT   
    BHS OUTOFLENGTH 
    JMP CREA_DICTOUT
        

OUTOFLENGTH: ; calcula la nueva posición del carácter cuando A2 >= A1
    SUB #DICT_SIZE,A2 
    
CREA_DICTOUT: ; guarda los carácteres nuevos en DICT_OUT
    MOVE.B (A0)+,(A2) 
    DBRA D0,LOOP0
    
 ;DICT_OUT YA CREADO
 
    LEA.L TEXT_IN,A2   ;usaremos A2 para recorrer el TEXT_IN
    MOVE.W #TEXT_SIZE,D4 ; D4 se usa para recorrer LOOP1
    SUBQ.B #1,D4            ; Quick porque es <8
    
 
LOOP1:
        LEA.L DICT_IN,A3   ; usaremos A3 para recorrer el DICT_IN  
        MOVE.B (A2),D2 ; D2 contindrá los carácteres del TEXT_IN
        MOVE.W #DICT_SIZE,D5 ; D5 se usará para recorrer el bucle LOOP2 
        SUBQ.W #1,D5
            
LOOP2:    

    MOVE.B (A3),D3 ; D3 contindrá los carácteres del DICT_IN
    CMP D2,D3
    BEQ EXISTE ; Salta si el carácter de TEXT_IN existe en el DICT_IN
    ADDQ.W #1,A3
    DBRA D5,LOOP2 
    CMP #-1,D5
    BEQ NOENCONTRADO ;Salta si el carácter no existe en el DICT_IN  
    
EXISTE:

    ADDQ.W #1,NCHANGES
    ADDA.W #DICT_SIZE,A3 ; A3 contiene la dirección del carácter sustituto
    MOVE.B (A3),TEXT_SIZE(A2) ; Mueve el carácter al TEXT_OUT
    ADDQ.W #1,A2 ; pasa al seguiente elemento del TEXT_IN
    DBRA D4,LOOP1 
    JMP EXIT
    
NOENCONTRADO:    
     MOVE.B (A2),TEXT_SIZE(A2) ; guarda el carácter sin modificaciones
     ADDQ.W #1,A2
     DBRA D4,LOOP1 
    
EXIT:   
    SIMHALT            
    END START


    
    












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
