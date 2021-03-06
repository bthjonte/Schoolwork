.data
inbuf: .space 64
inPos: .quad 0
outbuf: .space 64
outPos: .quad  0
	.text

	.global	inImage
	.global	getInt
	.global getText	
	.global getChar	
	.global getInPos 	
	.global setInPos	
	.global outImage
	.global putInt
	.global putText
	.global putChar
	.global getOutPos 	
	.global setOutPos 	

inImage:
movq $inbuf, %rdi
movq $61 , %rsi
movq stdin, %rdx 
call fgets
movq $0,inPos
ret

getInt:
	movq	$0, %rax	#nollställ resultatregistret)
	movq	$0, %r9	#nollställ teckenindikator (0 betyder positivt, 1 negativt)
    leaq    inbuf,%r8
    addq    inPos,%r8
    movq    $0, %r10
    movq    $0, %r11
getIntLOOP:
    cmpq $63, inPos
    jge getIntRet
	cmpb	$' ',(%r8)
	jne	SIGN
	incq	%r8	#stega fram till nästa tecken
	incq	inPos	#stega fram till nästa tecken
	jmp	getIntLOOP
SIGN:	
	cmpb	$'+', (%r8)	#check +
	jne	SIGN2
	incq	%r8	#stega fram till nästa tecken
	incq	inPos	#stega fram till nästa tecken
	jmp	NUM
SIGN2:
	cmpb	$'-', (%r8)	#check -
	jne	NUM
	movq	$1, %r9	#indikera negativt
	incq	%r8	#stega fram till nästa tecken
	incq	inPos	#stega fram till nästa tecken
NUM:
    cmpq $63, inPos
    jge getIntRet
	cmpb	$'0', (%r8)
	jl	NAN		#teckenkod mindre än '0'
	cmpb	$'9', (%r8)
	jg	NAN		#teckenkod större än '9'
    movb    (%r8),%r11b
	subl	$'0', %r11d	#subtrahera så talet motsvarande teckenkoden kvarstår
	imull	$10, %eax
	addl	%r11d, %eax
	incq	%r8		#stega fram till nästa tecken
	incq	%r10
	jmp	NUM
NAN:
    addq %r10, inPos
	cmpq	$1, %r9
	jne	END
	negq	%rax
    jmp END
getIntRet:
    pushq getIntLOOP
    jmp inImage
getText:
    leaq inbuf,%r8
    movq $0, %r9
    addq inPos,%r8
getTextLOOP:
        cmpq $63, inPos
        jge getTextRet
        cmpb $0 ,(%r8) 
        je getEND
        cmpq %r9 ,%rsi #sluta när r9 är n    
        je getEND
        incq    %r8    #öka inbuf med 1
        incq    %r9    #öka n  med 1
        incq    inPos
        movb 0(%r8,%r9,1),%r11b
        movb %r11b,(%rdi)
        incq %rdi
	    jmp	getTextLOOP
getEND:
        movq %r9 , %rax
        incq %rdi
        jmp END
getTextRet:
    pushq getTextLOOP
    jmp inImage
getChar:
        cmpq $63, inPos
        jge inImage
        leaq inbuf,%r8
        addq inPos,%r8 
        movb (%r8),%al
        incq inPos
        jmp END
putText: 
            leaq outbuf,%r8
            movq $0, %r9
            addq outPos,%r8
            cmpq $255, %rdi
            jl putChar
textLoop:        
        cmpq $63, outPos
        jge outImage
        movb 0(%rdi,%r9,1), %r10b
	    cmpb	$0, %r10b 
	    je	putEND
	    movb	%r10b, (%r8) #hämta bokstavens teckenkod
        incq %r9
        incq %r8
        incq outPos
        jmp textLoop 
putEND:
        movb $0,(%r8)
        jmp END
outImage:
    leaq outbuf, %rdi
    call puts
    movq $0, outPos
    jmp END
getOutPos:
    movq outPos, %rax 
    jmp END
setOutPos:
    cmpq $0, %rdi 
    jle  SetOutPosMin
    cmpq $63, %rdi 
    jge SetOutPosMax
    leaq outbuf,%r8
    addq %rdi,%r8
    movb $0,(%r8)
    movq %rdi, outPos
    jmp END
SetOutPosMax:
    leaq outbuf,%r8
    addq $63,%r8
    movb $0,(%r8)
    movq $63,outPos
    jmp END
SetOutPosMin:
    leaq outbuf,%r8
    movb $0, (%r8)
    movq $0, outPos
    jmp END
setInPos:
    cmpq $0, %rdi 
    jle  SetInPosMin
    cmpq $64, %rdi 
    jge SetInPosMax
    movq %rdi, inPos
    jmp END
SetInPosMax:
    movq $64, inPos
    jmp END
SetInPosMin:
    movq $0, inPos
    jmp END

putInt:
xorq %rsi, %rsi
movq $10, %r11
movq %rdi, %rax
leaq outbuf,%r8
addq outPos,%r8
cmpq $0, %rdi 
jg  putLoop
movb $'-', (%r8)
negq %rax
incq outPos
incq %r8


putLoop:
cmpq $63, outPos
jge outImage
movq $0, %rdx
divq %r11
addq $48, %rdx
cmpq $48, %rdx
je next
pushq %rdx
incq %rsi
jmp putLoop

next:
cmpq $0, %rsi
jz nextnext
popq %rdx
movb %dl, (%r8)
decq %rsi
incq outPos
incq %r8
jmp  next

nextnext:
movb $0,(%r8)
ret

putChar:
        cmpq $63, outPos
        jge outImage
        leaq outbuf,%r8
        addq outPos,%r8 
        movb %dil,(%r8)
        incq %r8
        movb $0,(%r8)
        incq outPos
        jmp END
END:	
	ret

