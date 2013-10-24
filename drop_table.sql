--
-- Drop given table
--

define L_TABLE_NAME = &1

declare
  l$cnt integer := 0;
begin
  select count(1) into l$cnt
    from sys.all_tables
   where table_name = upper('&&L_TABLE_NAME')
     and owner = upper('&&ORA_SCHEMA_OWNER');

   if l$cnt > 0 then
     -- Drop all foreign keys
     for rec in ( select owner, table_name, constraint_name
                    from all_constraints
                   where constraint_type='R'
                     and r_constraint_name in (select constraint_name from all_constraints
                                                where constraint_type in ('P','U') 
                                                  and table_name = upper('&&L_TABLE_NAME')
                                                  and owner = upper('&&ORA_SCHEMA_OWNER'))
                 )
     loop
        dbms_output.put_line('I: alter table ' || rec.owner || '.' || rec.table_name ||
                             ' drop constraint ' || rec.constraint_name );
        execute immediate 'alter table ' || rec.owner || '.' || rec.table_name ||
                          ' drop constraint ' || rec.constraint_name;
     end loop;

     -- Drop table
     execute immediate 'drop table &&L_TABLE_NAME cascade constraints';
     dbms_output.put_line('I: Table ' || upper('&&L_TABLE_NAME') || ' droped' );
   end if;
end;
/

undefine L_TABLE_NAME
