--
-- Install configuration
--

-- Schema owner to keep package
define ORA_SCHEMA_OWNER = &&ORADBA_SYS_OWNER

-- Tablespace for tables
define ORA_TBSP_TBLS = &&ORADBA_TBSP_TBLS

-- Tablespace for indexes
define ORA_TBSP_INDX = &&ORADBA_TBSP_INDX

-- Schema owner to keep clean job
define ORA_SCHEMA_CLEANER = &&ORADBA_SCHEMA_CLEANER

