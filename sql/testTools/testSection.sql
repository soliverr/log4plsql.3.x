create or replace function fct_test_log return number
is
    pCTX PLOG.LOG_CTX := PLOG.init(null, PLOG.LDEBUG, TRUE, TRUE);
begin 
        PLOG.debug (pCTX, 'message for debug');
        PLOG.info  (pCTX, 'message for information');
        PLOG.warn  (pCTX, 'message for warning ');
        PLOG.error (pCTX, 'message for error');
        PLOG.fatal (pCTX, 'message for fatal');
        return 0;
end fct_test_log;
/
sho error

create or replace procedure proc_test_log 
is
    pCTX PLOG.LOG_CTX := PLOG.init(null, PLOG.LDEBUG, TRUE, TRUE);
    temp  number; 
begin 
        temp := fct_test_log;
        PLOG.debug (pCTX, 'message for debug');
        PLOG.info  (pCTX, 'message for information');
        PLOG.warn  (pCTX, 'message for warning ');
        PLOG.error (pCTX, 'message for error');
        PLOG.fatal (pCTX, 'message for fatal');
end proc_test_log;
/
sho error

create or replace procedure proc_test_log2 (pCTX in out PLOG.LOG_CTX) 
is
begin 
        PLOG.error (pCTX, 'in sub section');
end proc_test_log2;
/
sho error


declare
    pCTX PLOG.LOG_CTX := PLOG.init(null, PLOG.LDEBUG, TRUE, TRUE);
begin 
    PLOG.SetBeginSection (pCTX, 'codePart1');
        PLOG.debug (pCTX, 'message for debug');
        PLOG.info  (pCTX, 'message for information');
        PLOG.warn  (pCTX, 'message for warning ');
        PLOG.error (pCTX, 'message for error');
        PLOG.fatal (pCTX, 'message for fatal');
    PLOG.SetBeginSection (pCTX, 'codePart2');
        PLOG.info  (pCTX, 'information message');
    PLOG.SetEndSection (pCTX);
    proc_test_log;
    PLOG.SetBeginSection (pCTX, 'call->proc_test_log');
        proc_test_log2 (pCTX);
    PLOG.SetEndSection (pCTX);
End;
/


/* No result un SQLPUS.
but in backgroundProcess output


E:\GGM\perso\log4plsql\Log4plsql\cmd>setlocal

E:\GGM\perso\log4plsql\Log4plsql\cmd>call setVariable.bat
variable setup

2003-06-07 01:39:27,878 INFO  (backgroundProcess) Start                               [   ][main][     Run.java:59]
2003-06-07 01:39:27,888 DEBUG (backgroundProcess) log4plsql.properties : .\properties\log4plsql.xml                               [   ][main][     Run.java:60]
2003-06-07 01:39:27,888 DEBUG (backgroundProcess) log4j.properties : .\\properties\\log4j.properties                               [   ][main][     Run.java:61]
2003-06-07 01:39:27,898 DEBUG (ReaderDBThread) ReaderLogDataBase : Connect                               [   ][main][ReaderThread.java:38]
2003-06-07 01:39:29,481 DEBUG (ReaderDBThread) begin loop                               [   ][Thread-0][ReaderThread.java:52]
2003-06-07 01:39:38,784 DEBUG (log4plsql.SCOTT.block.codePart1) message for debug                               [DatabaseLoginDate:07 juin      2003 01:39:38: 30][Thread-0][            ?:?]
2003-06-07 01:39:38,834 INFO  (log4plsql.SCOTT.block.codePart1) message for information                               [DatabaseLoginDate:07 juin      2003 01:39:38: 30][Thread-0][            ?:?]
2003-06-07 01:39:38,874 WARN  (log4plsql.SCOTT.block.codePart1) message for warning                                [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:38,924 ERROR (log4plsql.SCOTT.block.codePart1) message for error                               [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:38,954 FATAL (log4plsql.SCOTT.block.codePart1) message for fatal                               [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:39,004 INFO  (log4plsql.SCOTT.block.codePart1.codePart2) information message                               [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:39,034 DEBUG (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG.SCOTT.FCT_TEST_LOG) message for debug                               [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:39,074 INFO  (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG.SCOTT.FCT_TEST_LOG) message for information                               [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:39,104 WARN  (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG.SCOTT.FCT_TEST_LOG) message for warning                                [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:39,135 ERROR (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG.SCOTT.FCT_TEST_LOG) message for error                               [DatabaseLoginDate:07 juin      2003 01:39:38: 31][Thread-0][            ?:?]
2003-06-07 01:39:39,175 FATAL (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG.SCOTT.FCT_TEST_LOG) message for fatal                               [DatabaseLoginDate:07 juin      2003 01:39:38: 32][Thread-0][            ?:?]
2003-06-07 01:39:39,315 DEBUG (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG) message for debug                               [DatabaseLoginDate:07 juin      2003 01:39:38: 32][Thread-0][            ?:?]
2003-06-07 01:39:39,345 INFO  (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG) message for information                               [DatabaseLoginDate:07 juin      2003 01:39:38: 32][Thread-0][            ?:?]
2003-06-07 01:39:39,385 WARN  (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG) message for warning                                [DatabaseLoginDate:07 juin      2003 01:39:38: 32][Thread-0][            ?:?]
2003-06-07 01:39:39,425 ERROR (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG) message for error                               [DatabaseLoginDate:07 juin      2003 01:39:38: 32][Thread-0][            ?:?]
2003-06-07 01:39:39,455 FATAL (log4plsql.SCOTT.block.SCOTT.PROC_TEST_LOG) message for fatal                               [DatabaseLoginDate:07 juin      2003 01:39:38: 32][Thread-0][            ?:?]
2003-06-07 01:39:39,495 ERROR (log4plsql.SCOTT.block.call->proc_test_log) in sub section                               [DatabaseLoginDate:07 juin      2003 01:39:38: 32][Thread-0][            ?:?]

*/


create or replace function funcTSec return boolean is
begin
    PLOG.error ('error in funcTSec');
    return true;    
end;    
/

create or replace package ptSec is
    procedure ptSecPrc;
end;
/

create or replace package body ptSec is
    procedure ptSecPrc is
        r boolean;
    begin
        PLOG.error ('error in ptSec');
        r := funcTSec;
    end;    
end;
/

Exec PLOG.purge;
Exec ptSec.ptSecPrc; 


select  LSECTION||'->'||LTEXTE         from  tlog;

SQL> select  LSECTION||'->'||LTEXTE         from  tlog;

LSECTION||'->'||LTEXTE
--------------------------------------------------------------------------------
plog.purge->Purge By SCOTT
block.SCOTT.PTSEC->error in ptSec
block.SCOTT.PTSEC.SCOTT.FUNCTSEC->error in funcTSec



create or replace procedure procTSec (cpt number default 0) is
    pCTX PLOG.LOG_CTX := PLOG.init(pLEVEL       => PLOG.LDEBUG);
begin
    PLOG.INFO (pCTX,  cpt);
    if cpt < 100 then
        procTSec ( cpt + 1 );
    end if;
end;    
/

Exec PLOG.purge;
Exec procTSec; 

set linesize 4000
set pagesize 1000
select LTEXTE||'-'||length(LSECTION)||'-'||LSECTION  from  tlog;

/*
SQL>  select LTEXTE||'-'||length(LSECTION)||'-'||LSECTION  from  tlog;

LTEXTE||'-'||LENGTH(LSECTION)||'-'||LSECTION

Purge by user:SCOTT-10-plog.purge
0-20-block.SCOTT.PROCTSEC
1-35-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC
2-50-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC
3-65-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC
4-80-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC
5-95-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC

LTEXTE||'-'||LENGTH(LSECTION)||'-'||LSECTION

6-110-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC
7-125-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.S
8-140-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.S
9-155-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.S
10-170-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
11-185-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
12-200-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.

LTEXTE||'-'||LENGTH(LSECTION)||'-'||LSECTION

13-215-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
14-230-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
15-245-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
16-260-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
17-275-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
18-290-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.
19-305-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.

LTEXTE||'-'||LENGTH(LSECTION)||'-'||LSECTION

20-320-block.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.SCOTT.PROCTSEC.

*/




create or replace procedure pts009 is begin PLOG.ERROR ('009'); pts010 ; end;    
/
create or replace procedure pts008 is begin PLOG.ERROR ('008'); pts009 ; end;    
/
create or replace procedure pts007 is begin PLOG.ERROR ('007'); pts008 ; end;    
/
create or replace procedure pts006 is begin PLOG.ERROR ('006'); pts007 ; end;    
/
create or replace procedure pts005 is begin PLOG.ERROR ('005'); pts006 ; end;    
/
create or replace procedure pts004 is begin PLOG.ERROR ('004'); pts005 ; end;    
/
create or replace procedure pts003 is begin PLOG.ERROR ('003'); pts004 ; end;    
/
create or replace procedure pts002 is begin PLOG.ERROR ('002'); pts003 ; end;    
/
create or replace procedure pts001 is begin PLOG.ERROR ('001'); pts002 ; end;    
/

SET SERVEROUTPUT ON SIZE 1000000 
set linesize 2000
create or replace procedure pts010 
is 
ms varchar2(2000);
    pCTX       PLOG.LOG_CTX := PLOG.INIT  ;
begin 
    PLOG.full_call_stack; 
end;    
/


Exec PLOG.purge;
Exec pts001 ; 

set linesize 4000
select ltexte from tlog;
select lsection from tlog;
 
 
/*

SQL>
SQL> create or replace procedure pts009 is begin PLOG.ERROR ('009'); pts010 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts008 is begin PLOG.ERROR ('008'); pts009 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts007 is begin PLOG.ERROR ('007'); pts008 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts006 is begin PLOG.ERROR ('006'); pts007 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts005 is begin PLOG.ERROR ('005'); pts006 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts004 is begin PLOG.ERROR ('004'); pts005 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts003 is begin PLOG.ERROR ('003'); pts004 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts002 is begin PLOG.ERROR ('002'); pts003 ; end;
  2  /

ProcÚdure crÚÚe.

SQL> create or replace procedure pts001 is begin PLOG.ERROR ('001'); pts002 ; end;
  2  /

ProcÚdure crÚÚe.

SQL>
SQL> SET SERVEROUTPUT ON SIZE 1000000
SQL> set linesize 2000
SQL> create or replace procedure pts010
  2  is
  3  ms varchar2(2000);
  4      pCTX       PLOG.LOG_CTX := PLOG.INIT  ;
  5  begin
  6      PLOG.full_call_stack;
  7  end;
  8  /

ProcÚdure crÚÚe.

SQL>
SQL>
SQL> Exec PLOG.purge;

ProcÚdure PL/SQL terminÚe avec succÞs.

SQL> Exec pts001 ;

ProcÚdure PL/SQL terminÚe avec succÞs.

SQL>
SQL> set linesize 4000
SQL> select ltexte from tlog;

LTEXTE

Purge By SCOTT
001
002
003
004
005
006
007
008
009
----- PL/SQL Call Stack -----

LTEXTE

  object      line  object
  handle    number  name
7AC91128       962  package body ULOG.PLOG
7AC91128       952  package body ULOG.PLOG
7AB8EAB4         6  procedure SCOTT.PTS010
7AA1F490         1  procedure SCOTT.PTS009
7ABE59F8         1  procedure SCOTT.PTS008
7A7F4AD8         1  procedure SCOTT.PTS007
7AA1D214         1  procedure SCOTT.PTS006
7AA37674         1  procedure SCOTT.PTS005
7A7F1858         1  procedure SCOTT.PTS004

LTEXTE

7A7D5570         1  procedure SCOTT.PTS003
7A7D3918         1  procedure SCOTT.PTS002
7A7CEB80         1  procedure SCOTT.PTS001
7A7C4AE0         1  anonymous block


11 ligne(s) sÚlectionnÚe(s).

SQL> select lsection from tlog;

LSECTION

plog.purge
block.SCOTT.PTS001
block.SCOTT.PTS001.SCOTT.PTS002
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003.SCOTT.PTS004
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003.SCOTT.PTS004.SCOTT.PTS005
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003.SCOTT.PTS004.SCOTT.PTS005.SCOTT.PTS006
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003.SCOTT.PTS004.SCOTT.PTS005.SCOTT.PTS006.SCOTT.PTS007
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003.SCOTT.PTS004.SCOTT.PTS005.SCOTT.PTS006.SCOTT.PTS007.SCOTT.PTS008
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003.SCOTT.PTS004.SCOTT.PTS005.SCOTT.PTS006.SCOTT.PTS007.SCOTT.PTS008.SCOTT.PTS009
block.SCOTT.PTS001.SCOTT.PTS002.SCOTT.PTS003.SCOTT.PTS004.SCOTT.PTS005.SCOTT.PTS006.SCOTT.PTS007.SCOTT.PTS008.SCOTT.PTS009.SCOTT.PTS010

11 ligne(s) sÚlectionnÚe(s).

SQL>
SQL>



*/



Create or replace package insert_error as 
           procedure insert_error; 
end insert_error; 
/

Create or replace package outer_insert_error as 
           procedure outer_insert_error; 
end outer_insert_error; 
/

create or replace package body insert_error as 
           procedure insert_error is 
                   begin 
                           plog.fatal(dbms_utility.format_call_stack); 
                end insert_error; 
end insert_error; 
/

create or replace package body outer_insert_error as 
           procedure outer_insert_error is 
           begin 
                           insert_error.insert_error(); 
          end outer_insert_error; 
end outer_insert_error; 
/

Exec PLOG.purge
/

 SET SERVEROUTPUT ON
exec outer_insert_error.outer_insert_error(); 



Select * from vlog
/

set linesize 2000
select LSECTION from tlog;


/*
SQL> Create or replace package insert_error as
  2             procedure insert_error;
  3  end insert_error;
  4  /

Package crÚÚ.

SQL>
SQL> Create or replace package outer_insert_error as
  2             procedure outer_insert_error;
  3  end outer_insert_error;
  4  /

Package crÚÚ.

SQL>
SQL> create or replace package body insert_error as
  2             procedure insert_error is
  3                     begin
  4                             plog.fatal(dbms_utility.format_call_stack);
  5                  end insert_error;
  6  end insert_error;
  7  /

Corps de package crÚÚ.

SQL>
SQL> create or replace package body outer_insert_error as
  2             procedure outer_insert_error is
  3             begin
  4                             insert_error.insert_error();
  5            end outer_insert_error;
  6  end outer_insert_error;
  7  /

Corps de package crÚÚ.

SQL>
SQL> Exec PLOG.purge

ProcÚdure PL/SQL terminÚe avec succÞs.

SQL> /

Corps de package crÚÚ.

SQL>
SQL>  SET SERVEROUTPUT ON
SQL> exec outer_insert_error.outer_insert_error();

ProcÚdure PL/SQL terminÚe avec succÞs.

SQL>
SQL>
SQL>
SQL> Select * from vlog
  2  /

LOG
--------------------------------------------------------------------------------
[Fev 27, 20:35:09:87][INFO][SCOTT][plog.purge][Purge by user:SCOTT]
[Fev 27, 20:35:09:21][FATAL][SCOTT][block.SCOTT.OUTER_INSERT_ERROR.SCOTT.INSERT_
ERROR][----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
668896D4         4  package body SCOTT.INSERT_ERROR
66882068         4  package body SCOTT.OUTER_INSERT_ERROR
6688580C         1  anonymous block
]


SQL>
SQL>
SQL> set linesize 2000
SQL> select LSECTION from tlog;

LSECTION

plog.purge
block.SCOTT.OUTER_INSERT_ERROR.SCOTT.INSERT_ERROR

SQL>
*/