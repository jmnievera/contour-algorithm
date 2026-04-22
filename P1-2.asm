            # This program traces a contour.
            #
            # Using ecall 582, it loads 2500 8-bit pixels (as 625 words of 4 pixels each) into a
            # linear array of words.
            #
            # The program must find the length of the contour around the white (0xFF) pixels,
            # as well as the pixel index (0-2499) of the upper-left and lower-right 
            # bounding box of the white region. All calculations are relative to the
            # outermost WHITE pixel of the region, NOT the first black pixel outside the
            # region. In addition, each white boundary pixel must be changed to color 0xAA.
            #
            # Required output register usage (for ecall 583):
            # a1: Total perimeter calculated 
            # a2: index of the upper left-most pixel of the bounding box (top left corner)
            # a3: index of the lower right-most pixel of the bounding box (bottom right corner)
            #
            # The program result must be placed in a1, a2, and a3 before
            # ecall 583 is executed so that the solution may be checked for correctness.
            #
            #===========================================================================
            # CHANGE LOG: brief description of changes made from P1-2-shell.asm
            # to this version of code.
            # Date  Modification
            # 10/07 began code implementation
            # 10/08 work on loop implementation
            #       do all of if statement
            #       try to debug issue with "memory accessed before intitalized"
            # 10/12 redo code
            # 10/13 get code working
            #       optimize got dynamic instructions down from 41 to 25
            # 
            #===========================================================================
            
.data 
Map: .alloc 625 # 4 pixels packed in each word (2500 pixels = 625 words)
            
.text
Entry: 
            addi a0, gp, Map #Point to the map image array
            addi a7, x0, 582 # The ecall 582 to create the assignment
            ecall
            
            #***************************************************
            # AN EXAMPLE OF HIGHLIGHTING A PIXEL
            # This ecall is only used for debugging purposes.  Be sure to
            # comment out all uses of this ecall before submitting your solution
            # so that the instructions don't add to your dynamic and static count.
            # addi a1, x0, 648 # to highlight an individual pixel in the map  
            # addi a7, x0, 584 
            # ecall # with this ecall   
            #***************************************************
            
            #YOUR SOLUTION BELOW HERE
            
            addi a1, x0, 0 # Length = 0
            
            # initialize i and j
            addi s2, x0, 0 # i
            addi s3, x0, 0 # j
            
            # innitalize upper, lower, left, right
            addi s5, x0, 50 # upper
            addi s6, x0, 0 # lower
            addi s7, x0, 50 # left
            addi s8, x0, 0 # right
            
            addi a2, x0, 0 # UpperLeft
            addi a3, x0, 0 # BottomRight
            
            # temporary 50 for loop condition
            addi t3, x0, 50 #  50 DO NOT CHANGE
            
            # temporary to hold map address
            add t4, x0, a0
            
            # temporary to hold 0xFF
            addi a4, x0, 0xFF
            
            # temporary to hold 0xAA
            addi a5, x0, 0xAA
            
            # temporary to hold 49
            addi t6, x0, 49
            
Outer: 
            # start of outer loop
            bge s2, t3, Exit # branch if j >= 50
            addi s3, x0, 0
            
Inner: 
            # start of inner loop
            bge s3, t3, EndOfInner # branch if i >= 50
            
            # load current pixel
            lbu t0, 0(t4)
            
            # check if pixel == FF
            bne t0, a4, NotRight
            
            # check if i or j = 0 or = 49
            beq s2, x0, IsBoundary
            beq s3, x0, IsBoundary
            beq s2, t6, IsBoundary
            beq s3, t6, IsBoundary
            
            # check pixel above
            lbu t5, -50(t4)
            beq t5, x0, IsBoundary
            
            #check pixel below
            lbu t5, 50(t4)
            beq t5, x0, IsBoundary
            
            #check pixel left
            lbu t5, -1(t4)
            beq t5, x0, IsBoundary
            
            # check pixel right
            lbu t5, 1(t4)
            beq t5, x0, IsBoundary
            
            beq x0, x0, NotRight
            
IsBoundary: 
            addi a1, a1, 1 #Length++
            sb a5, 0(t4)
            
            bge s2, s5, NotUpper
            add s5, x0, s2
            
NotUpper: 
            blt s2, s6, NotLower
            add s6, x0, s2
            
NotLower: 
            bge s3, s7, NotLeft
            add s7, x0, s3
            
NotLeft: 
            blt s3, s8, NotRight
            add s8, x0, s3
NotRight: 
            
            addi s3, s3, 1 # i++
            addi t4, t4, 1 # map address++
            blt s3, t3, Inner # branch if i < 50
            
EndOfInner: 
            addi s2, s2, 1 # j++
            blt s2, t3, Outer # branch if j < 50
            
Exit: 
            addi t3, x0, 50
            mul a2, s5, t3 # UpperLeft = 50 * Upper
            add a2, a2, s7 # UpperLeft = UpperLeft + Left
            
            mul a3, s6, t3 # LowerRight = 50 * Lower
            add a3, a3, s8 # LowerRight = LowerRight + Right
            
            
            #STUDENT CALCULATES THE FOLLOWING 3 PARAMETERS
            # a1: Total perimeter calculated (AND used to highlight individual pixels) 
            # a2: index of the upper left-most pixel of the bounding box (top left corner)
            # a3: index of the lower right-most pixel of the bounding box (bottom right corner) 
            
            addi a7, x0, 0xAA # to mark the pixel as edge 
            
            #***************************************************
            # AN EXAMPLE OF REPORTING A SOLUTION
            # (comment this out before submitting your solution)
            #addi a1, x0, 400 # guess total perimeter count
            #addi a2, x0, 50 # guess left pixel bounding box
            #addi a3, x0, 740 # guess right pixel bounding box
            #sb a7, 16(a0) # guess a pixel on the contour
            #sb a7, 160(a0) # guess another pixel on contour
            #***************************************************
            
            #YOUR SOLUTION ABOVE HERE
            
End: 
            
            addi a7, x0, 583 # The ecall 583 to check the answer 
            ecall
            addi a0, x0, 0 #Added for debugging purposes - to see if C is returning student results
            jalr ra, ra, 0
            
            
            
            
