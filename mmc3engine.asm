	.inesprg 4
	.ineschr 0
	.inesmir 1
	.inesmap 4
	
	.LIST
	.bank 7
	.org $F2D0
	


RESET
	sei
	cld
	lda #$08
	sta $2000
	ldx #$FF
	txs
.waitvsync
	lda $2002
	bpl .waitvsync
.waitvsync2
	lda $2002
	bpl .waitvsync2

	lda #$FF
	sta $4017
	lda #$00
	sta $4010

	ldx #$07
	ldy #$87
.InitializeBank
	lda InitBank,x
	jsr MMC3SetBank
	dey
	dex
	bpl .InitializeBank
	
	ldy #$FE
	ldx #$05
.checkscore
	lda $07D7,x 
	cmp #$0A
	bcs .initializer
	dex
	bpl .checkscore
	lda $07FF
	cmp #$A5
	bne .initializer 
	ldy #$D6
	
.initializer
	jsr $90CC
	
	sta $4011
	sta $0770



	lda #$A5
	sta $07FF
	sta $07A7

	lda #$0F
	sta $4015

	lda #$06
	sta $2001
	
	jsr $8220
	jsr $8E19
	inc $0774
	
	lda $0778
	ora #$80
	sta $2000

	cli

InfiniteLoop
	jmp InfiniteLoop

VRAM_addr_table_l
	db $01,$A4,$C8,$EC,$10,$00,$41,$41,$4C,$34,$3C,$44,$54,$68,$7C,$A8
	db $BF,$DE,$EF

VRAM_addr_table_h
	db $03,$8C,$8C,$8C,$8D,$03,$03,$03,$8D,$8D,$8D,$8D,$8D,$8D,$8D,$8D
	db $8D,$8D,$8D

VRAM_addr_offset
	db $00,$40

NMI
	lda $0778
	and #$7E
	jsr $8EED
	lda $0779
	and #$E6
	ldy $0774
	bne .nobgsprites
	lda $0779
	ora #$1E
.nobgsprites
	sta $0779
	and #$E7
	sta $2001
	ldx $2002
	lda #$00
	sta $2005
	sta $2005
	sta $2003
	lda #$02
	sta $4014

	ldx $0773
	lda VRAM_addr_table_l , x
	sta <$00
	lda VRAM_addr_table_h , x
	sta <$01
	jsr $8EDD
	ldy #$00
	ldx $0773
	cpx #$06
	bne .nooffset
	iny
.nooffset
	ldx VRAM_addr_offset,y
	lda #$00
	sta $0300,x
	sta $0301,x
	sta $0773

	lda #$1F
	sta $E000
	sta $C000
	sta $C001
	sta $E001

	lda $0779
	sta $2001
	cli

	ldy #$86
	lda #$00
	jsr MMC3SetBank

	jsr $8000

	ldy #$86
	lda #$04
	jsr MMC3SetBank

	jsr $8E5C
	jsr $8182
	jsr $8F97

	lda $0776
	lsr a
	bcs .skip_deccnt

	lda $0747
	beq .decstart
	dec $0747
	bne .skip_deccnt
.decstart
	ldx #$14
	dec $077F
	bpl .time
	lda #$14
	sta $077F
	ldx #$23
.time
	lda $0780,x
	beq .dex
	dec $0780,x
.dex
	dex
	bpl .time
.skip_deccnt

	inc <$09

	ldx #$00
	ldy #$07
	lda $07A7
	and #$02
	sta <$00
	lda $07A8
	and #$02
	eor <$00
	clc
	beq .rndloop
	sec
.rndloop
	ror $07A7,x
	inx
	dey
	bne .rndloop


	lda $0776
	lsr a
	bcs .skip_main
	lda $0722
	beq .skip_renewspr
	jsr $8223
	jsr $81C6
.skip_renewspr

	jsr $8212
.skip_main

	lda $2002
	lda $0778
	ora #$80
	jsr $8EED

	rti

MMC3SetBank	
	sty $8000
	sta $8001
	rts

InitBank
	db $00,$02,$04,$05,$06,$07
	db $04,$05
	
	
CHRBankSet
	ldy #$80
	lda #$00
	jsr MMC3SetBank
	iny
	lda #$02
	jsr MMC3SetBank
	iny
	lda #$04
	jsr MMC3SetBank
	iny
	lda #$05
	jsr MMC3SetBank
	iny
	lda #$06
	jsr MMC3SetBank
	iny
	lda #$07
	jsr MMC3SetBank
	rts
	
	rts

IRQ
	php
	pha
	txa
	pha
	tya
	pha

	lda #$00
	sta $E000

	ldy #$08
.wait
	dey
	bne .wait

	lda $2002
	lda $06FE
	ora $0778
	tax
	sta $0778
	lda $073F
	stx $2000
	sta $2005

	pla
	tay
	pla
	tax
	pla
	plp
	rti

	org $FFFA
	dw NMI
	dw RESET
	dw IRQ