-- CREATE TABLE WITH LC_CLASSES AND AGGREGATION LEVELS
     
DROP TABLE IF EXISTS public.lc_attributes;

CREATE TABLE public.lc_attributes (lc_code integer NOT NULL,lc_class text,lc1_code integer,lc1_class text,CONSTRAINT lc_attributes_pkey PRIMARY KEY (lc_code));
