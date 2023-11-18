
;;SplitWhitespace
;; Splits a given string on whitespace characters
;; Arguments:
;;  a0 -> Start of the string
;; Destroys:
;;  d3 -> Next Character
;; Returns: A pointer and a length
;;  d0 -> Start of the next token
;;  d1 -> length of the token
SplitWhitespace:
  clr.l                   d0
  clr.l                   d1
  move.l                  a0,d0                                                                                                   ;Store our current start
.loop:
  move.b                  (a0)+,d3
  ;;TODO: There are other kinds of whitespace and control characters we probably want to split as well right now we only care for spaces...
  cmp.b                   #$20,d3                                                                                                 ;Whitespace ! -> Get out
  beq.s                   .end
  cmp.b                   #$00,d3                                                                                                 ; Did we hit the end of the string ? -> Get out
  bne.s                   .loop                                                                                                   ;NOTE Scary sound when closing the debugger is scary...but it's almost halloween so time for the OS Ringbuffer to do some shenaningans ?! O_o
.end:
  move.l                  a0,d1                                                                                                   ;Put our ending in d1 behaving like a good little tokenizer :]
  sub.l                   d0,d1
  subq                    #1,d1                                                                                                   ;Subtract one from the position to filter out the last whitespace / null character !
  ;;Cool idea but will probably not work for short words as these will be also 0 :-[
  beq.s                   SplitWhitespace                                                                                         ;Restart the whole procedure...this is buggy :] 
  rts
  
;;Ascii Symbol To Integer 
;; Converts a given Character into it's corosponding value
;;  i.e. ('0' => 0) ('1' => 1) ('2' => 2)...('9' => 9)
;; Arguments:
;;      d6 -> Character to Convert
;; Returns:
;;      d7 -> Character Value (0xFFFFFFFF when the Character cannot be converted)
;;NOTE: Should not handle negative values, we should check the first character of a value if it's negative then we can just flip the value in the end
;;TODO: There is potential for optimization here and i should defenitly check what 
;;      could be done better as the aoc problems will be taxing enough without waiting for hours
;;      for the string conversion !
AsciiToInt:
  cmp.b                   #$30,d6                                                                                                 ; Check value if it's below our threshold >= 0x30 '0'
  blt                     .failure
  cmp.b                   #$39,d6                                                                                                 ; Check value if it's below our threshold <= 0x39 '9'
  bgt                     .failure
  .conversion:
  move.b                  d6,d7
  subi.b                  #$30,d7                                                                                                 ; Subtract the lowest Symbol of the Ascii Digit Table (0x30 '0') from our input
  rts                                                                                                                             ; Done the result should be inside our d7 register
  .failure:
  ;;I should not think in terms of 32bit too much this move costs us 12 cycles everytime
  move.l                  #$FFFFFFFF,d7
  rts

;;String to Value
;; Converts a given string into it's corosponding value, depends on AsciiToInt
;; Arguments:
;;  a7 -> String Pointer
;; Returns:
;;  d6 -> Value
;;  d7 -> Count Characters Consumed
StringToValue:
  clr.l                   d2
  clr.l                   d5
  move.b                  #10,d2
.iter:
  clr.l                   d7
  move.b                  (a0)+,d6
  jsr                     AsciiToInt
  cmp.l                   #$FFFFFFFF,d7
  beq                     .end
  ;; Naaahh 38-70 Cycles for a mulu instruction is not gonna fly here...we only have a few mhz available
  mulu                    d2,d5 
  add.l                   d7,d5
  jmp                     .iter
.end:
  rts

ascii_to_int_tests:
  lea                     zero,a0
  lea                     result_zero,a1
  lea                     end_of_checks,a3
.test_loop:
  move.b                  (a0)+,d6
  move.b                  (a1)+,d5
  jsr                     AsciiToInt
  cmp.b                   d5,d7
  bne                     .failure
  cmp.l                   a1,a3
  beq                     .win
  jmp                     .test_loop                                                                                              ;This is fine for now but later on i should check if we reached the end of the testing range and just get the fuck out

.failure:
  nop
  jmp                     .failure                                                                                                ;Stuck here but there is a bug that needs fixing so that's good :)
  
.win:
  rts                                                                                                                             ;Huge win everything was as expected AWESOME :D 


string_into_tokens:
  ;;Basic Test
  lea                     string_to_split,a0
  jsr                     SplitWhitespace                                                                                         ;Let's see whats happening in the debugger ?!
  ;"hello"
  lea                     string_to_split,a1
  cmp.l                   a1,d0                                                                                                   ;Assert!(a0 == start of string)
  bne                     .failure
  cmp.l                   #5,d1                                                                                                   ;Assert!(d1 === len(str) + 1)
  bne                     .failure
  ;"my"
  jsr                     SplitWhitespace
  lea                     string_to_split,a1
  add                     #$6,a1
  cmp.l                   a1,d0
  bne                     .failure
  cmp.l                   #2,d1
  bne                     .failure
  ;"little"
  jsr                     SplitWhitespace
  lea                     string_to_split,a1
  add                     #$9,a1
  cmp.l                   a1,d0
  bne                     .failure
  cmp.l                   #6,d1
  bne                     .failure
  ;"token"
  jsr                     SplitWhitespace
  lea                     string_to_split,a1
  add                     #$10,a1
  cmp.l                   a1,d0
  bne                     .failure
  cmp.l                   #5,d1
  bne                     .failure
  

  ;;Two space test
  clr.l                   d0
  clr.l                   d1

  ;;"this"
  lea                     double_spaced_string,a0
  jsr                     SplitWhitespace
  lea                     double_spaced_string,a1
  cmp.l                   a1,d0
  bne                     .failure
  cmp.l                   #4,d1
  bne                     .failure

  ;;string
  jsr                     SplitWhitespace
  lea                     double_spaced_string,a1
  add                     #$6,a1
  cmp.l                   a1,d0
  bne                     .failure
  cmp.l                   #6,d1
  bne                     .failure

  jmp                     .win
.failure:
  nop
  jmp                     .failure
.win:
  rts

string_to_value_tests:
  lea                     value_ex_mixed,a0
  jsr                     StringToValue
  move.l                  #12349,d1
  jsr                     .check_values

  lea                     value_ex_tst_a,a0
  jsr                     StringToValue
  move.l                  #1,d1
  jsr                     .check_values

  lea                     value_ex_tst_b,a0
  jsr                     StringToValue
  move.l                  #10,d1
  jsr                     .check_values

  lea                     value_ex_tst_c,a0
  jsr                     StringToValue
  move.l                  #100,d1
  jsr                     .check_values

  lea                     value_ex_tst_d,a0
  jsr                     StringToValue
  move.l                  #1000,d1
  jsr                     .check_values

  lea                     value_ex_tst_e,a0
  jsr                     StringToValue
  move.l                  #10000,d1
  jsr                     .check_values

  lea                     value_ex_tst_f,a0
  jsr                     StringToValue
  move.l                  #100000,d1
  jsr                     .check_values

  lea                     value_ex_tst_g,a0
  jsr                     SplitWhitespace       
  jsr                     StringToValue
  move.l                  #1000000,d1
  jsr                     .check_values

  lea                     value_ex_tst_h,a0
  jsr                     StringToValue
  move.l                  #10000000,d1
  jsr                     .check_values

  lea                     value_ex_tst_i,a0
  jsr                     StringToValue
  move.l                  #10000000,d1
  jsr                     .check_values

  jmp                     .huge_win

.failure:
  nop
  jmp                     .failure
  rts
  jmp                     string_to_value_tests

.huge_win:
  rts

.check_values:  
  cmp.w                   d1,d5
  bne                     .failure
  clr.l                   d1
  rts


  section                 "ASCII_TEST_DATA",data
  zero                    : dc.b '0'
  one                     : dc.b '1'
  two                     : dc.b '2'
  three                   : dc.b '3'
  four                    : dc.b '4'
  five                    : dc.b '5'
  six                     : dc.b '6'
  seven                   : dc.b '7'
  eight                   : dc.b '8'
  nine                    : dc.b '9'
  even

  inv_a                   : dc.b 'a'

  result_zero             : dc.b 0
  result_one              : dc.b 1
  result_two              : dc.b 2
  result_three            : dc.b 3
  result_four             : dc.b 4
  result_five             : dc.b 5
  result_six              : dc.b 6
  result_seven            : dc.b 7
  result_eight            : dc.b 8
  result_nine             : dc.b 9
  result_inv              : dc.b $FFFFFFFF
  end_of_checks           : dc.b $FF
  even

  value_ex_mixed          : dc.b "12349",0
  even
  value_ex_tst_a          : dc.b "1",0
  even
  value_ex_tst_b          : dc.b "10",0
  even
  value_ex_tst_c          : dc.b "100",0
  even
  value_ex_tst_d          : dc.b "1000",0
  even
  value_ex_tst_e          : dc.b "10000",0
  even
  value_ex_tst_f          : dc.b "100000",0
  even
  value_ex_tst_g          : dc.b "1000000",0
  even
  value_ex_tst_h          : dc.b "10000000",0
  even
  value_ex_tst_i          : dc.b "100000000",0
  even

  string_to_split         : dc.b "hello my little token",0
  double_spaced_string    : dc.b "this  string  has  two spaces  between  every  word",0
  tabbed_string           : dc.b "this",9,"string",9,"is",9,"containing",9,"tab",9,"characters",9,"every",9,"other",9,"word",0
  short_words             : dc.b "a short word brings misery"
  even