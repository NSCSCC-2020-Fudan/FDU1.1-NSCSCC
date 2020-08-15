_start:
    li $sp, 0x8fc08000
    li $s0, 0x8fc04000
    li $s1, 0xbfc04000
    li $s2, 0x19260817
    li $s3, 0x8fc02000
    b     main


memset:
    # $t0 ← $s0
    addu  $t0, $0, $s0
    # $t1 ← $t0 + 0x200
    addiu $t1, $t0, 0x200
loop:
    sw    $s2, 0($t0)
    slt   $t2, $t0, $t1
    addiu $t0, 4
    bne   $t2, $0, loop
    jr    $ra

store_tag:
        move    $5,$0
        move    $2,$0
        move    $a0, $0
AHA3:
        li      $3,32768                    # 0x8000
        slt     $t3,$5,$3
        addu    $3,$4,$5
        beq     $t3,$0,AHA4
        # lb      $3,0($3)
        addu    $2,$2,$3
        addiu   $5,$5,64
        lui     $t7, 0xa000
        # cache   0b01001, 0($t7)
        cache 0x9, 0($t7)
        # cache 0b01000, 0($t7)
        cache 0x8, 0($t7)
        addu    $t7,$t7,$3
        b       AHA3
AHA4:
        j       $31

index_writeback:
        move    $5,$0
        move    $2,$0
        move    $a0, $0
AHA7:
        li      $3,32768                    # 0x8000
        slt     $t3,$5,$3
        addu    $3,$4,$5
        beq     $t3,$0,AHA8
        # lb      $3,0($3)
        lui     $t7,0xa000
        addu    $t7,$t7,$3
        # cache   0b00000, 0($t7)
        cache 0x0, 0($t7)
        addu    $2,$2,$3
        # cache   0b00001, 0($t7)
        cache 0x1, 0($t7)
        addiu   $5,$5,64
        b       AHA7

AHA8:
        j       $31


# sh*tcpy
# sheetcpy(int *a, int *b)
# $4: a, $5: b
sheetcpy:
        # move    $3,$0
        addu   $3, $0, $0
AHA11:
        slti     $t2,$3,64
        sll     $2,$3,2
        beq     $t2,$0,AHA12

        addu    $6,$5,$2
        addu    $2,$4,$2
        addiu   $3,$3,1
        lw      $2,0($2)
        sw      $2,0($6)
        b       AHA11

AHA12:
        jr      $31


hit_invalidate:
        # move    $2,$0
        addu   $2, $0, $0
        addu   $4, $0, $s3
AHA15:
        slti     $t3,$2,64
        sll     $3,$2,2
        beq     $t3,$0,AHA16

        addu    $3,$4,$3
        # li      $5,291
        addiu $5,$0,291
        # sw      $5,0($3)
        # cache   0b10000, 0($3)
        cache 0x10,0($3)
        # cache   0b10101, 0($3)
        cache 0x15,0($3)
        addiu   $2,$2,1
        b       AHA15

AHA16:
        jr      $31


# Test Begin

test1:
        # move    $2,$0
        addu $2, $0, $0
        # move    $3,$0
        addu $3, $0, $0
AHA19:
        slti     $4,$2,100
        mult    $2,$2
        beq     $4,$0,AHA18
        mflo    $4
        addu    $3,$3,$4
        addiu   $2,$2,1
        b       AHA19

AHA18:
        sll     $2,$3,2
        sll     $3,$3,4
        addu    $3,$2,$3
        sll     $2,$3,2
        addu    $2,$3,$2
        jr      $31

test2:
        # move    $3,$0
        addu $3,$0,$0
        # move    $2,$0
        addu $2,$0,$0
        # li      $5,1                        # 0x1
        addiu $5,$0,1
        # move    $4,$0
        addu $4,$0,$0
AHA22:
        slti     $t6,$3,128
        addu    $6,$4,$5
        beq     $t6,$0,AHA23

        addu    $2,$2,$4
        addiu   $4,$5,1
        addiu   $3,$3,1
        # move    $5,$6
        addu $5, $6, $0
        b       AHA22

AHA23:
        jr      $31

test3:
        # li      $3,1                        # 0x1
        addiu $3,$0,1
        # move    $2,$0
        addu $2,$0,$0
AHA27:
        slti     $t4,$3,9217
        # li      $4,9216           # 0x2400
        addiu $4,$0,9216
        beq     $t4,$0,AHA28

        # nop
        div     $0,$4,$3
        bne     $3,$0,safe1
        break   7  # 0x0007000d
        safe1:
        mfhi    $4
        mult    $3,$4
        mflo    $5
        addu    $2,$2,$5
        bgtz    $4,AHA26

        # li      $4,9216           # 0x2400
        addiu  $4, $0, 9216
        div     $0,$4,$3
        bne     $3,$0,safe2
        break   7  # 0x0007000d
        safe2:
        mflo    $4
        addu    $2,$2,$4
AHA26:
        addiu   $3,$3,1
        b       AHA27

AHA28:
        jr      $31

# Test End


main:
    bal memset

    lw  $t0,  0($s0)  # expect 0x19260817
    lw  $t0,  0($s1)  # expect 0x00000000
    lw  $t0, 48($s0)  # expect 0x19260817
    lw  $t0, 48($s1)  # expect 0x00000000

    # Store Tag
    addiu $8, $0, 29
    mtc0  $0, $8, 0
    mtc0  $0, $8, 2
    beq $0, $0, treap
    treap:
    addiu $8, $0, 28
    mtc0  $0, $8, 0
    mtc0  $0, $8, 2
    bal store_tag

    lw  $t0,  0($s0)  # expect 0x00000000
    lw  $t0,  0($s1)  # expect 0x00000000
    lw  $t0, 48($s0)  # expect 0x00000000
    lw  $t0, 48($s1)  # expect 0x00000000
    bal memset

    lw  $t0,  0($s0)  # expect 0x19260817
    lw  $t0,  0($s1)  # expect 0x00000000
    lw  $t0, 48($s0)  # expect 0x19260817
    lw  $t0, 48($s1)  # expect 0x00000000

    # Index Invalidate Writeback
    bal index_writeback

    lw  $t0,  0($s1)  # expect 0x19260817
    lw  $t0, 48($s1)  # expect 0x19260817
    lw  $t0,  0($s0)  # expect 0x19260817
    lw  $t0, 48($s0)  # expect 0x19260817

    # Hit Invalidate / Hit Invalidate Writeback
    lui $4, 0x8fc0
    ori $4, $4, test1
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $v0, $0  # expect 0x1f505b8

    lui $4, 0x8fc0
    ori $4, $4, test2
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $0, $v0  # expect 0x955795c2

    lui $4, 0x8fc0
    ori $4, $4, test3
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $v0, $0  # expect 0x184fabb8

    # test again
    lui $4, 0x8fc0
    ori $4, $4, test1
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $v0, $0  # expect 0x1f505b8

    lui $4, 0x8fc0
    ori $4, $4, test2
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $0, $v0  # expect 0x955795c2

    lui $4, 0x8fc0
    ori $4, $4, test3
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $v0, $0  # expect 0x184fabb8

    lui $4, 0x8fc0
    ori $4, $4, test2
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $0, $v0  # expect 0x955795c2

    lui $4, 0x8fc0
    ori $4, $4, test1
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $v0, $0  # expect 0x1f505b8

    lui $4, 0x8fc0
    ori $4, $4, test3
    addu  $5, $0, $s3
    bal sheetcpy
    bal hit_invalidate
    jalr $s3
    addu $t0, $v0, $0  # expect 0x184fabb8

    # not implemented cache operations
    # The operation of this instruction is UNDEFINED for any operation/cache combination that is not implemented.
    # The operation of this instruction is UNDEFINED if the operation requires an address, and that address is uncacheable.

    # in case of RI exception
    lui $t0,0x0100
    addiu $t0,$0,0x7bcd
    # cache 0b10100,0($t0)
    # cache 0x14,0($t0)
    addu $t0, $0, $0
    # cache 0b10111,0($t0)
    # cache 0x17,0($t0)
    addu $t0, $0, $0
    # cache 0b00101,0($t0)
    lui $t0,0xa000
    # cache 0x5,0($t0)
    addu $t0, $0, $0

    # expect no exceptions?
    addiu $t3,$0,1
    addu $t4, $t3, $t3  # expect 2

    # end
    over:
    b over
