      SUBROUTINE FLFREE (FRREC,AFE,NAFE,KGE,NKGE)
C
C     CALCULATES THE AREA FACTOR MATRIX AND GRAVITATIONAL STIFFNESS
C     MATRIX FOR A SINGLE FLUID ELEMENT ON THE FREE SURFACE
C
      LOGICAL         ERROR    ,GRAV     ,LTILT
      INTEGER         FRREC(7) ,GF1      ,GF2      ,GF3      ,IZ(1)    ,
     1                GRID(3,4)
      DOUBLE PRECISION          R12(3)   ,R13(3)   ,A        ,RT(3)    ,
     1                AFE(16)  ,KGE(16)  ,AFACT    ,RHOXG
      CHARACTER       UFM*23
      COMMON /XMSSG / UFM
      COMMON /ZZZZZZ/ Z(1)
      COMMON /FLBPTR/ ERROR    ,ICORE    ,LCORE    ,IBGPDT   ,NGBPDT   ,
     1                ISIL     ,NSIL     ,IGRAV    ,NGRAV
      COMMON /MATIN / MATID    ,INFLAG
      COMMON /MATOUT/ DUM(3)   ,RHO
      COMMON /SYSTEM/ SYSBUF   ,NOUT
      COMMON /BLANK / NOGRAV   ,NOFREE   ,TILT(2)
      EQUIVALENCE     (Z(1),IZ(1))
C
C     GRID POINTS DEFINING FOUR OVERLAPING TRIANGLES IN A QUAD
C
      DATA    GRID  / 1        ,2        ,3        ,
     1                2        ,3        ,4        ,
     2                3        ,4        ,1        ,
     3                4        ,1        ,2        /
      DATA    LTILT / .FALSE.  /
C
C
C     CALCULATE SIZE OF ELEMENT MATRICES
C
      NGRIDF = 4
      IF (FRREC(6) .LT. 0) NGRIDF = 3
      NAFE = NGRIDF*NGRIDF*2
      NKGE = 0
C
C     OBTAIN MATERIAL PROPERTY AND GRAVITY DATA IF A GRAV ID IS GIVEN
C
      GRAV = .FALSE.
      IF (FRREC(7) .EQ. 0) GO TO 6
      INFLAG = 11
      MATID  = FRREC(2)
      CALL MAT (FRREC(1))
C
      IF (NGRAV .EQ. 0) GO TO 70
      LGRAV = IGRAV + NGRAV - 1
      DO 2 I = IGRAV,LGRAV,6
      IF (IZ(I) .EQ. FRREC(7)) GO TO 4
    2 CONTINUE
C
      GO TO 70
C
    4 G = SQRT(Z(I+3)**2 + Z(I+4)**2 + Z(I+5)**2)
C
C     USING THE FIRST GRAV VECTOR DETERMING THE FREE SURFACE PLOTTING
C     ANGLE
C
      IF (LTILT) GO TO 5
      TILT(1) = Z(I+5)/G
      TILT(2) = Z(I+3)/G
      LTILT   = .FALSE.
C
    5 G     = G*Z(I+2)
      RHOXG = DBLE(RHO)*DBLE(G)
      NKGE  = NAFE
      NOGRAV= 1
      GRAV  = .TRUE.
C
C     DETERMINE NUMBER OF OVERLAPING TRIANGLES TO BE UESED
C
C     1 IF TRIANGLAR FLUID FACE
C     4 IF QUADRATIC FLUID FACE
C
    6 ITRIA = 4
      IF (NGRIDF .NE. 4) ITRIA = 1
C
C     ZERO OUT GRAVITATIONAL STIFFNESS AND AREA FACTOR MATRIX
C
      DO 10 I = 1,16
      KGE(I) = 0.0D0
   10 AFE(I) = 0.0D0
C
C     LOOP OVER TRIANGLES
C
C     FIRST LOCATE GRID POINT COORDINATES FOR CORNERS FO THIS TRIANGLE
C
      DO 50 IT = 1,ITRIA
C
      I   = GRID(1,IT)
      GF1 = IBGPDT + (FRREC(I+2)-1)*4
      I   = GRID(2,IT)
      GF2 = IBGPDT + (FRREC(I+2)-1)*4
      I   = GRID(3,IT)
      GF3 = IBGPDT + (FRREC(I+2)-1)*4
C
C     CALCUATE AREA OF TRIAGLE
C     DIVIDE AREA BY TWO IF OVERLAPPING TRIAGLES USED
C
      DO 20 I = 1,3
      R12(I) = Z(GF2+I) - Z(GF1+I)
   20 R13(I) = Z(GF3+I) - Z(GF1+I)
C
      CALL DCROSS (R12,R13,RT)
C
      A = DSQRT(RT(1)*RT(1) + RT(2)*RT(2) + RT(3)*RT(3))/2.0D0
      IF (ITRIA .EQ. 4) A = A/2.0D0
C
C     INSERT AREA AND STIFFNESS CONTRIBUTIONS INTO FULL SIZE
C     ELEMTENT MATRICES
C
      DO 40 I = 1,3
      ICOL = GRID(I,IT)
      ILOC = NGRIDF*(ICOL-1)
      DO 30 J = 1,3
      IROW = GRID(J,IT)
      IF (IROW .EQ. ICOL) AFACT = A/6.0D0
      IF (IROW .NE. ICOL) AFACT = A/12.0D0
      AFE(ILOC+IROW) = AFE(ILOC+IROW) + AFACT
      IF (GRAV) KGE(ILOC+IROW) = KGE(ILOC+IROW) + RHOXG*AFACT
   30 CONTINUE
   40 CONTINUE
C
   50 CONTINUE
C
      RETURN
C
C     ERROR CONDITIONS
C
   70 WRITE  (NOUT,80) UFM,FRREC(1),FRREC(7)
   80 FORMAT (A23,' 8012, FLUID ELEMENT',I9,
     1       ' ON A CFFREE CARD REFERENCES UNDEFINED GRAVITY ID',I9)
      ERROR = .TRUE.
      RETURN
      END
