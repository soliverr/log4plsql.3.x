
create or replace package PMDC as

/** 
*  package name : PMDC                                                       
*<br/>
*<br/>
*See : <a href="http://log4plsql.sourceforge.net">http://log4plsql.sourceforge.net</a>                                 
*<br/>
*<br/>
*Objectif : Generic tool of log in a Oracle database                      
*same prototype and functionality that log4j.                             
*<a href="http://jakarta.apache.org/log4j">http://jakarta.apache.org/log4j </a>                                        
*<br/><br/><br/>
*<b> for exemple and documentation See: http://log4plsql.sourceforge.net/docs/UserGuide.html</b>
**
*@headcom 
*<br/>
*<br/>                                                                         
*<br/>
*History who               date     comment
*V1     Greg Woolsey      29-MAR-04 add MDC (Mapped Domain Context) Feature
*<br/>
*<br/>
* Copyright (C) LOG4PLSQL project team. All rights reserved.<br/>
*<br/>
* This software is published under the terms of the The LOG4PLSQL <br/>
* Software License, a copy of which has been included with this<br/>
* distribution in the LICENSE.txt file.  <br/>
* see: <http://log4plsql.sourceforge.net>  <br/><br/>
* 
*/


    -- puts a key/value pair into the current log context
    -- putting a null vlaue is the same as calling remove(pKey)  
    procedure put(pKey varchar2, pValue varchar2);

    -- retrieves the current value of the given log context key 
    function get(pKey varchar2) return varchar2;

    -- removes a key from the current log context 
    procedure remove(pKey varchar2);
    
    -- returns the string of all mapped context values 
    function getValueString return varchar2;

    -- returns the string of all mapped context keys 
    function getKeyString return varchar2;

    -- returns the key and value string separator character(s).
    function getSeparator return varchar2;
    
end PMDC;
/



create or replace package body PMDC as



-------------------------------------------------------------------
--
--  Nom package        : PMDC
--
--  Objectif           : MDC Features
--
--  Version            : 1.0
-------------------------------------------------------------------
-- see package spec for history
-------------------------------------------------------------------


-------------------------------------------------------------------
-- Variable global privé au package
-------------------------------------------------------------------
/*
 * Copyright (C) LOG4PLSQL project team. All rights reserved.
 *
 * This software is published under the terms of the The LOG4PLSQL 
 * Software License, a copy of which has been included with this
 * distribution in the LICENSE.txt file.  
 * see: <http://log4plsql.sourceforge.net>  */
 
-------------------------------------------------------------------





	gSeparator constant varchar2(1) := chr(29);
	gSepLength pls_integer := length(gSeparator);
	
	gKeys varchar2(4096) := gSeparator;
	gValues varchar2(4096) := gSeparator;
--
function getPos(pKey varchar2) return pls_integer
is
	cnt pls_integer := 0;
	pos pls_integer := 0;
	sep pls_integer := 1;
begin
	if gKeys = gSeparator then return 0; end if;
	pos := instr(gKeys, pKey || gSeparator);
	if pos = 0 then return 0; end if;
	--
	while sep > 0 and sep <= pos loop
		cnt := cnt + 1;
		sep := instr(gKeys, gSeparator, sep+gSepLength);
	end loop;
	return cnt;
end getPos;
--
procedure put(pKey varchar2, pValue varchar2)
is
	idx pls_integer := 0;
	posStart pls_integer := 0;
begin
	idx := getPos(pKey);
	if idx = 0 then -- new key, add to end 
		gKeys := gKeys || pKey || gSeparator;
		gValues := gValues || pValue || gSeparator;
	else -- replace value for existing key 
		posStart := instr(gValues, gSeparator, 1, idx);
		gValues := substr(gValues, 1, posStart + (gSepLength -1) ) ||
				  	  pValue || 
					  substr(gValues, instr(gValues, gSeparator, posStart+gSepLength, 1));
	end if;
end put;
--
function get(pKey varchar2) return varchar2
is
	idx pls_integer := 0;
	lStart pls_integer := 0;
	lEnd pls_integer := 0;
begin
	idx := getPos(pKey);
	if idx = 0 then return ''; end if;
--
	lStart := instr(gValues, gSeparator, 1, idx);
	lEnd := instr(gValues, gSeparator, lStart+gSepLength, 1);
	return substr(gValues, lStart+gSepLength, lEnd-lStart-gSepLength);
end get;
--
procedure remove(pKey varchar2)
is
	idx pls_integer := 0;
	lStart pls_integer := 0;
	lEnd pls_integer := 0;
begin
	idx := getPos(pKey);
	if idx = 0 then return; end if; -- key doesn't exist, nothing to do.
--
	lStart := instr(gValues, gSeparator, 1, idx);
	lEnd := instr(gValues, gSeparator, lStart+gSepLength, 1);
	gValues := substr(gValues, 1, lStart) || substr(gValues, lEnd+gSepLength);
--
	lStart := instr(gKeys, gSeparator, 1, idx);
	lEnd := instr(gKeys, gSeparator, lStart+gSepLength, 1);
	gKeys := substr(gKeys, 1, lStart) || substr(gKeys, lEnd+gSepLength);
end remove;
--
function getKeyString return varchar2 is
begin
	return gKeys;
end getKeyString;
--
function getValueString return varchar2 is
begin
	return gValues;
end getValueString;
--
function getSeparator return varchar2 is
begin
	return gSeparator;
end getSeparator;
--
end PMDC;
/
