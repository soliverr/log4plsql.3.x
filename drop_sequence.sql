--
-- Drop given sequence
--

define L_SEQ_NAME = &1

declare
  l$cnt integer := 0;
begin
  select count(1) into l$cnt
    from sys.all_sequences
   where sequence_name = upper('&&L_SEQ_NAME')
     and sequence_owner = upper('&&ORA_SCHEMA_OWNER');

   if l$cnt > 0 then
     execute immediate 'drop sequence &&L_SEQ_NAME';
     dbms_output.put_line('I: Sequence ' || upper('&&L_SEQ_NAME') || ' droped' );
   end if;
end;
/

undefine L_SEQ_NAME
