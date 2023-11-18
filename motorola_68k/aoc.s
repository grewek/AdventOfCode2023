;------------------------------
; Example inspired by Photon's Tutorial:
;  https://www.youtube.com/user/ScoopexUs
;

;---------- Const ----------
;CIAA            = $00bfe001
;COPPERLIST_SIZE = 1000             ;Size of the copperlist
;LINE            = 100              ;<= 255

  section    AOC,CODE

start:
  move.w     #1,d0                    ;TODO: Build the Solutions
              ;;Execute all our manual test for our utility functions
  jsr        string_into_tokens
  jsr        ascii_to_int_tests
  jsr        string_to_value_tests
******************************************************************	
mainloop:
  nop
  jmp        mainloop                 ;TODO: :]

;---------- Includes ----------
  INCLUDE    "utilitys.s"