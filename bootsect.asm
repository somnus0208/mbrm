org 00600h
;****************************
;    First Sector Start
;****************************
    xor ax,ax
    mov ss,ax
    mov sp,7c00h
    sti

    push ax
    pop es
    push ax
    pop ds
;-----------------------------
;copy code from 0x07c1b to 0x061bh
;-----------------------------
    cld
    mov si,7c1bh
    mov di,061bh
    push ax
    push di
    mov cx,1e5h
    rep movsb
    retf

;------------------------------
;Read MBR from hard disk
;------------------------------
    mov ax,0201h
    mov dx,0081h
    mov cx,0001h
    mov bx,0800h
    int 13h
;------------------------------
;Restore MBR to the second sector hard disk
;------------------------------    
    mov ax,0301h
    mov dx,0081h
    mov cx,0002h
    int 13h
;------------------------------
;Store DPT in the original MBR
;Store Disk Signature to Second sector frome USB disk  
;------------------------------
    cld
    mov si,09b8h
    mov di,11b8h
    mov cx,72
    rep movsb
;------------------------------
;Read the second sector from USB disk
;------------------------------
    mov ax,0201h
    mov dx,0080h
    mov cx,0002h
    mov bx,0800h
    int 13h
;------------------------------
;copy the stored DPT to the new MBR
;------------------------------
    cld
    mov si,11b8h
    mov di,09b8h
    mov cx,66
    rep movsb
;------------------------------
;Write the new MBR from ES:BX to the hard disk
;------------------------------

    mov ax,0301h
    mov dx,0081h
    mov cx,0001h
    int 13h
;------------------------------
;------------------------------    
    cmp ah,0
    jz  SUCCESS
    cmp ah,0
    jnz FAIL
SUCCESS:
    mov ax,MS
    mov bp,ax
    mov cx,7
    mov ax,01301h
    mov bx,000fh
    mov dx,0000
    int 10h
    jmp $
FAIL:
    mov ax,MS2
    mov bp,ax
    mov cx,6
    mov ax,01301h
    mov bx,000fh
    mov dx,0000
    int 10h
    jmp $


MS:                     db "Success"
MS2:                    db "Failed" 

times 446-($-$$)        db 0
;***************************
;USB disk own DPT
;***************************
dw 0x0180,0x0001,0xfe0c,0xffff
dw 0x003f,0x0000,0xf8cd,0x01f8
times 48                db 0
dw 0xaa55
;****************************
;    First Sector End
;****************************

;****************************
;    Second Sector Start
;****************************

    xor ax,ax
    mov ss,ax
    mov sp,7c00h
    sti

    push ax
    pop  es
    push ax
    pop  ds
;-----------------------------
;copy main code from 0x07c1b to 0x061bh
;-----------------------------
    cld
    mov si,7c1bh
    mov di,061bh
    push ax
    push di
    mov cx,1e5h
    rep movsb
    retf 
;27 bytes
;-----------------------------
;Show Message
;-----------------------------
    mov ax, $$+27+19+19+14+5;3
    mov bp,ax            ;2,5
    mov cx,24+22+17+8    ;3,8
    mov ax,01301h        ;3,11
    mov bx,000fh         ;3,14
    mov dx,0000          ;3,17
    int 10h              ;2,19
;19 bytes
;-----------------------------
;Use system clock service to delay 5 seconds
;-----------------------------
CLOCK:
    mov ah,01h        ;2
    mov cx,0          ;3
    mov dx,0          ;3
    int 1ah           ;2
READ_TIME:
    xor ax,ax         ;2
    int 1ah           ;2
    cmp dx,91         ;3
    jb  READ_TIME     ;2
;19 bytes
;------------------------------
;Read the second sector from hard disk 
;to the 07c00h address
;------------------------------
    mov ax,0201h ;3
    mov dx,0080h ;3
    mov cx,0002h ;3
    mov bx,7c00h ;3
    int 13h      ;2
;14 bytes
;------------------------------
;Jump to 07c00h address
;------------------------------
    xor ax,ax  ;2
    push ax    ;1
    push bx    ;1
    retf       ;1
;5 bytes
MSS1:                                    db "When Anything is Wrong",0AH,0DH ;24
MSS2:                                    db "Please Call For Help",0AH,0DH  ;22
MSS3:                                    db "Somnus.V"  ;8
;27+19+19+14+5+24+22+17+14+8
times 510-(27+19+19+14+5+24+22+8)        db 0
dw 0xaa55
;****************************
;    Second Sector End
;****************************
