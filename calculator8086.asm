
DATA SEGMENT
    NUM1 DW ?
    NUM2 DW ?
    OPERATOR DB ?  
    TEN DW 0AH       ; USED FOR MULTIPLICATION  
    IS_MINUS DB 00H             ; IF 1, THE NUMBER IS NEGATIVE  
    FIRST DB 01
    CALC DB 10,13, "                 8086 CALCULATOR", "$" 
    EMPTY DB 10, 13, "$"
    INPUT1 DB 10, 13, "ENTER FIRST NUMBER : ","$"
    INPUT2 DB 10, 13, "ENTER SECOND NUMBER: ", "$"
    INPUT_OPR DB 10, 13, "OPERATION (+ - / *) : ", "$"
    RESULT DB 10, 13, "RESULT: ", "$" 
    OVER DB "RESULT IS OUT OF RANGE$"
    ZERO_DIV_ERR DB "ERROR: DIVIDE BY ZERO$"
    
    DATA ENDS

ASSUME CS:CODE, DS:DATA

CODE SEGMENT
    START:
    MOV AX, DATA
    MOV DS, AX  
    
    XOR CX, CX
    
    MOV DX, OFFSET CALC          ; PRINTING THE TITLE = 8086 CALCULATOR
    MOV AH, 09H
    INT 21H 
                
    MOV DX, OFFSET EMPTY
    MOV AH, 09H
    INT 21H
    
    
    MOV DX, OFFSET INPUT1         ; ASKING FOR INPUT1
    MOV AH, 09
    INT 21H  
    JMP TAKE_NUMBER
    NUMBER1:   
    MOV NUM1, CX

    MOV FIRST, 2H
    
    MOV DX, OFFSET INPUT2          ; TAKING INPUT2
    MOV AH, 09
    INT 21H
    JMP TAKE_NUMBER 
    NUMBER2:
    MOV NUM2, CX  
    
    
    
    MOV DX, OFFSET INPUT_OPR         ; asking for operator 
    MOV AH, 09
    INT 21H 
    CALL TAKE_OPERATOR
    
          
    JMP EXIT     
                         
    TAKE_NUMBER:             ; THIS SHOULD BE THE PROCEDURE
            
            MOV CX, 0
            MOV IS_MINUS, 00H   
        
        
    NEXT_DIGIT:
            MOV AH, 01H
            INT 21H
            
            CMP AL, '-'           ; TO CHECK FOR NEGATIVE NUMBER
            JE SET_MINUS
            
            CMP AL, 13           ; FOR ENTER KEY
            JE STOP_INPUT 
                          
            CMP AL, 8             ; BACKSPACE KEY
            JNE NO_BACKSPACE
            MOV DX, 0              ; REMOVE THE LAST DIGIT
            MOV AX, CX
            DIV TEN
            MOV CX, AX
            
            ;PUTC ' '
            MOV DL, ' '
            MOV AH, 02H
            INT 21H
            
            ;PUTC 8
            MOV DL, 8
            INT 21H
            
            JMP NEXT_DIGIT            
            
            
            NO_BACKSPACE:
            PUSH AX
            MOV AX, CX
            MUL TEN
            MOV CX, AX
            POP AX
            
            CMP DX, 0
            JNE OVER_16            ; OUT OF RANGE OF 16 BITS
            
            
            SUB AL, 30H             ; THE INPUTED DIGIT
            MOV AH, 0
            MOV DX, CX             ; JST FOR BACKUP IF THE ADDITION OF THAT DIGIT RESULTS IN OVERFLOW
            ADD CX, AX             ; BASICALLY WE ARE ADDING ONLY DIGIT IN AL
            JC OUT_OF_RANGE          ; OUT OF RANGE
            
            JMP NEXT_DIGIT
            
            
            
    SET_MINUS:
            MOV IS_MINUS, 01
            JMP NEXT_DIGIT              
              
        
    OUT_OF_RANGE:
            MOV CX, DX
            MOV DX, 0 
            
    OVER_16:
            MOV AX, CX
            DIV TEN         ; IF MULTIPLYING WITH 10 IS OUT OF 16BITS, THEN DIV IT BY 10
            MOV CX, AX
            
            ;PUTC 8  
            MOV DL, 8
            MOV AH, 02H
            INT 21H
            
            ;PUTC ' '
            MOV DL, ' '
            INT 21H
            
            ;PUTC 8
            MOV DL, 8
            INT 21H
                      
            JMP NEXT_DIGIT
            
            
    STOP_INPUT:
            CMP IS_MINUS, 0
            JE NOT_MINUS
            NEG CX             ; IF IS_MINUS == 1 , NEGATE THE CX
        
    NOT_MINUS:
           CMP FIRST, 1
           JE NUMBER1
           JMP NUMBER2
    
   
    
         
         
    TAKE_OPERATOR PROC
        
        MOV AH, 01H
        INT 21H
        
        MOV OPERATOR, AL 
        
        MOV DX, OFFSET RESULT           ; PRINTING THE RESULT STATEMENT
        MOV AH, 09H 
        INT 21H
        
        MOV AL, OPERATOR
        
        CMP AL, '+'
        JE ADDITION
        
        CMP AL, '*'
        JE MULTIPLICATION
        
        CMP AL, '/'
        JE DIVISION
        
        CMP AL, '-'
        JE SUBTRACTION    
        
                
       
        RET 
    TAKE_OPERATOR ENDP

   
         
    ADDITION:
    MOV AX, NUM1
    ADD AX, NUM2
    JC OVERFLOW 
    CMP AX, 0    
    JS PUT_MINUS    
    JMP PRINT_RESULT
    
               
    SUBTRACTION:
    MOV AX, NUM1
    SUB AX, NUM2 
    ;JC OVERFLOW
    CMP AX, 0
    JS PUT_MINUS
    JMP PRINT_RESULT
    
    
    MULTIPLICATION:
    MOV AX, NUM1
    IMUL NUM2
    JC OVERFLOW
    CMP AX, 0
    JS PUT_MINUS
    JMP PRINT_RESULT
    
    DIVISION:
    CMP NUM2, 0
    JE ZERO_DIV_ERROR
    MOV DX, 0
    MOV AX, NUM1
    IDIV NUM2
    JC OVERFLOW
    CMP AX, 0
    JS PUT_MINUS
    JMP PRINT_RESULT   
    
 
    PRINT_RESULT:
    CMP AX, 0
    JE PRINT_ZERO
    JMP PRINT
    
    PUT_MINUS:
    ;PUTC '-'
    MOV DL, '-'
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX
    
    PRINT:                ; FOR PRINTING THE RESULT
    MOV BX, 10
    MOV DX, -1
    LOOPING:
    PUSH DX
    MOV DX, 0
    CMP AX, 0
    JE DONE
    DIV BX 
    JMP LOOPING
    
    DONE:
    POP DX
    CMP DX, -1
    JE EXIT
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    JMP DONE                ; UPTO THIS
    

    OVERFLOW:
    MOV DX, OFFSET OVER
    MOV AH, 09H 
    INT 21H
    JMP EXIT  
    
    PRINT_ZERO:
    ;PUTC '0'
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP EXIT      
           
    ZERO_DIV_ERROR:
    MOV DX, OFFSET ZERO_DIV_ERR
    MOV AH, 09H 
    INT 21H
    
    EXIT:
    MOV AH, 4CH
    INT 21H
    
    
    CODE ENDS
END START
