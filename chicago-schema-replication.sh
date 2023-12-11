#!/bin/bash
# Put password for the user dbreplica
echo "Input database password for the user dbreplica"
read PGPASSWORD 
# Add database, user and objects
sudo docker exec pg-service psql -h localhost -U postgres -c "create database chicago"
sudo docker exec pg-service psql -h localhost -U postgres -d chicago -c "
CREATE USER dbreplica LOGIN PASSWORD '$PGPASSWORD';
ALTER USER dbreplica WITH replication;
ALTER USER dbreplica WITH superuser;"
sudo docker exec pg-service psql -h localhost -U postgres -d chicago -c "DROP TABLE IF EXISTS public.business_licenses CASCADE;
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
sudo docker exec pg-service psql -h localhost -U postgres -d chicago -c "CREATE EXTENSION IF NOT EXISTS pglogical;
GRANT usage ON SCHEMA pglogical TO dbreplica;"
echo "Provide IP for the source database"
read INSTANCE_IP
sudo docker exec pg-service psql -h localhost -U postgres -d chicago -c "SELECT pglogical.create_node(node_name := 'subscriber', dsn := 'host=localhost port=5432 dbname=chicago user=dbreplica')"
sudo docker exec pg-service psql -h localhost -U postgres -d chicago -c "SELECT pglogical.create_subscription(subscription_name := 'omni_sub_01', provider_dsn := 'host=$INSTANCE_IP port=5432 dbname=chicago user=dbreplica password=$PGPASSWORD')"
sudo docker exec pg-service psql -h localhost -U postgres -d chicago -c "SELECT COUNT(*) FROM business_licenses ORDER BY 1"

