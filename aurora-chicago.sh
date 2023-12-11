#!/bin/bash
#
echo "Input Aurora instance hostname:"
read INSTANCE_IP
echo "Put username for the postgres user:"
read PGUSER
echo "Put password forthe user:"
read -s PGPASSWORD

psql "host=$INSTANCE_IP user=postgres dbname=chicago" -c "DROP TABLE IF EXISTS public.business_licenses CASCADE;
CREATE TABLE public.business_licenses (
    ID character varying(16) NOT NULL,
    LICENSE_ID integer NOT NULL,
    ACCOUNT_NUMBER integer,
    SITE_NUMBER integer,
    LEGAL_NAME character varying(120),
    DOING_BUSINESS_AS_NAME character varying(150),
    ADDRESS character varying(100),
    CITY character varying(50),
    STATE character(2),
    ZIP_CODE character(5),
    WARD integer,
    PRECINCT integer,
    WARD_PRECINCT character varying(8),
    POLICE_DISTRICT integer,
    LICENSE_CODE integer,
    LICENSE_DESCRIPTION character varying(80),
    BUSINESS_ACTIVITY_ID character varying(100),
    BUSINESS_ACTIVITY character varying(800),
    LICENSE_NUMBER integer,
    APPLICATION_TYPE character varying(6),
    APPLICATION_CREATED_DATE date,
    APPLICATION_REQUIREMENTS_COMPLETE date,
    PAYMENT_DATE date,
    CONDITIONAL_APPROVAL character(1),
    LICENSE_TERM_START_DATE date,
    LICENSE_TERM_EXPIRATION_DATE date,
    LICENSE_APPROVED_FOR_ISSUANCE date,
    DATE_ISSUED date,
    LICENSE_STATUS character(3),
    LICENSE_STATUS_CHANGE_DATE date,
    SSA character(2),
    LATITUDE numeric,
    LONGITUDE numeric,
    LOCATION character varying(40)
);
ALTER TABLE public.business_licenses OWNER TO postgres;
ALTER TABLE ONLY public.business_licenses ADD CONSTRAINT business_licenses_pkey PRIMARY KEY (ID,LICENSE_ID);"

curl https://data.cityofchicago.org/api/views/uupf-x98q/rows.csv | psql "host=$INSTANCE_IP user=postgres dbname=chicago" -c "\copy business_licenses from stdin csv header"

psql "host=$INSTANCE_IP user=postgres dbname=chicago" -c "CREATE EXTENSION IF NOT EXISTS pglogical;
GRANT usage ON SCHEMA pglogical TO postgres;"

psql "host=$INSTANCE_IP user=postgres dbname=chicago" -c "SELECT pglogical.create_node(node_name := 'provider', dsn := 'host=$INSTANCE_IP port=5432 dbname=chicago user=$PGUSER password=$PGPASSWORD');
SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);"