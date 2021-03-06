--
-- PostgreSQL database dump
--

-- Dumped from database version 10.15
-- Dumped by pg_dump version 12.6 (Ubuntu 12.6-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS misp2db;
--
-- Name: misp2db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE misp2db WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'C.UTF-8';


ALTER DATABASE misp2db OWNER TO postgres;

\connect misp2db

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: misp2; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA misp2;


ALTER SCHEMA misp2 OWNER TO postgres;

SET default_tablespace = '';

--
-- Name: admin; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.admin (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    password character varying(50) NOT NULL,
    login_username character varying(50) NOT NULL,
    salt character varying(50) NOT NULL
);


ALTER TABLE misp2.admin OWNER TO postgres;

--
-- Name: admin_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.admin_id_seq OWNER TO postgres;

--
-- Name: admin_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.admin_id_seq OWNED BY misp2.admin.id;


--
-- Name: check_register_status; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.check_register_status (
    id integer NOT NULL,
    query_name character varying(256) NOT NULL,
    query_time timestamp without time zone DEFAULT now() NOT NULL,
    is_ok boolean NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.check_register_status OWNER TO postgres;

--
-- Name: TABLE check_register_status; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.check_register_status IS 'kehtivuse kontrollp??ringu  registri olek';


--
-- Name: COLUMN check_register_status.query_name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.check_register_status.query_name IS 'kehtivuse kontrollp??ringu  nimi';


--
-- Name: COLUMN check_register_status.query_time; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.check_register_status.query_time IS 'kehtivuse kontrollp??ringu  viimase sooritamise aeg';


--
-- Name: COLUMN check_register_status.is_ok; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.check_register_status.is_ok IS 'kehtivuse kontrollp??ringu  registri staatus: 1 - ok, 0 - vigane (annab veaga vastust)';


--
-- Name: check_register_status_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.check_register_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.check_register_status_id_seq OWNER TO postgres;

--
-- Name: check_register_status_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.check_register_status_id_seq OWNED BY misp2.check_register_status.id;


--
-- Name: classifier; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.classifier (
    id integer NOT NULL,
    content text NOT NULL,
    name character varying(50) NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    xroad_query_xroad_protocol_ver character varying(5),
    xroad_query_xroad_instance character varying(64),
    xroad_query_member_class character varying(16),
    xroad_query_member_code character varying(50),
    xroad_query_subsystem_code character varying(64),
    xroad_query_service_code character varying(256),
    xroad_query_service_version character varying(256),
    xroad_query_request_namespace character varying(256)
);


ALTER TABLE misp2.classifier OWNER TO postgres;

--
-- Name: TABLE classifier; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.classifier IS 'andmekogu klassifikaatorid, mis laetakse andmekogust MISPi baasi loadclassifier p??ringuga, kasutatakse XML - formaadis klassifikatoreid';


--
-- Name: COLUMN classifier.content; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.classifier.content IS 'klassifikaatori sisu XML formaadis';


--
-- Name: classifier_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.classifier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.classifier_id_seq OWNER TO postgres;

--
-- Name: classifier_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.classifier_id_seq OWNED BY misp2.classifier.id;


--
-- Name: group_; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.group_ (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    org_id integer NOT NULL,
    portal_id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE misp2.group_ OWNER TO postgres;

--
-- Name: TABLE group_; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.group_ IS 'kasutajagrupid';


--
-- Name: COLUMN group_.org_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_.org_id IS 'viide asutusele, mille juures see grupp on kasutatav (mingi asutuse gruppi saab kasutada ka tema allasutuste juures )';


--
-- Name: COLUMN group_.name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_.name IS 'grupi nimi';


--
-- Name: group__id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.group__id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.group__id_seq OWNER TO postgres;

--
-- Name: group__id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.group__id_seq OWNED BY misp2.group_.id;


--
-- Name: group_item; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.group_item (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    group_id integer NOT NULL,
    invisible boolean,
    org_query_id integer NOT NULL
);


ALTER TABLE misp2.group_item OWNER TO postgres;

--
-- Name: TABLE group_item; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.group_item IS 'grupi p??ringu??igused';


--
-- Name: COLUMN group_item.group_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_item.group_id IS 'viide grupile';


--
-- Name: COLUMN group_item.invisible; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_item.invisible IS 'varjatud teenuste men????s';


--
-- Name: COLUMN group_item.org_query_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_item.org_query_id IS 'viide lubatud p??ringule ';


--
-- Name: group_item_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.group_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.group_item_id_seq OWNER TO postgres;

--
-- Name: group_item_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.group_item_id_seq OWNED BY misp2.group_item.id;


--
-- Name: group_person; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.group_person (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    group_id integer NOT NULL,
    person_id integer NOT NULL,
    org_id integer NOT NULL,
    validuntil date
);


ALTER TABLE misp2.group_person OWNER TO postgres;

--
-- Name: TABLE group_person; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.group_person IS 'kasutajagruppi kuuluvus';


--
-- Name: COLUMN group_person.group_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_person.group_id IS 'viide kasutajagrupile, kuhu kasutaja kuulub';


--
-- Name: COLUMN group_person.person_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_person.person_id IS 'viide isikule, kes gruppi kuulub';


--
-- Name: COLUMN group_person.org_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_person.org_id IS 'asutus, mille all kehtib see kirje (millise asutuse esindajana v??ib antud p??ringut sooritada) see v??ib olla sama asutus, mis group.org_id v??i ka viimase allasutus';


--
-- Name: COLUMN group_person.validuntil; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_person.validuntil IS 'aegumiskuup??ev, mis ajani gruppikuuluvus kehtib';


--
-- Name: group_person_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.group_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.group_person_id_seq OWNER TO postgres;

--
-- Name: group_person_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.group_person_id_seq OWNED BY misp2.group_person.id;


--
-- Name: manager_candidate; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.manager_candidate (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    manager_id integer NOT NULL,
    org_id integer NOT NULL,
    auth_ssn character varying(20) NOT NULL,
    portal_id integer NOT NULL
);


ALTER TABLE misp2.manager_candidate OWNER TO postgres;

--
-- Name: TABLE manager_candidate; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.manager_candidate IS 'asutuse p????su??iguste halduri kandidaadid, kelle puhul on vajalik mitme esindus??igusliku isiku poolt kinnitamine halduriks';


--
-- Name: manager_candidate_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.manager_candidate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.manager_candidate_id_seq OWNER TO postgres;

--
-- Name: manager_candidate_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.manager_candidate_id_seq OWNED BY misp2.manager_candidate.id;


--
-- Name: news; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.news (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    lang character varying(10) NOT NULL,
    portal_id integer NOT NULL,
    news character varying(512)
);


ALTER TABLE misp2.news OWNER TO postgres;

--
-- Name: news_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.news_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.news_id_seq OWNER TO postgres;

--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.news_id_seq OWNED BY misp2.news.id;


--
-- Name: org; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.org (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    member_class character varying(16),
    subsystem_code character varying(64),
    code character varying(20) NOT NULL,
    sup_org_id integer
);


ALTER TABLE misp2.org OWNER TO postgres;

--
-- Name: TABLE org; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.org IS 'asutused';


--
-- Name: COLUMN org.code; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.org.code IS 'asutuse kood';


--
-- Name: COLUMN org.sup_org_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.org.sup_org_id IS 'viide ??lemasutusele';


--
-- Name: org_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.org_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.org_id_seq OWNER TO postgres;

--
-- Name: org_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.org_id_seq OWNED BY misp2.org.id;


--
-- Name: org_name; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.org_name (
    id integer NOT NULL,
    description character varying(256) NOT NULL,
    lang character varying(10) NOT NULL,
    org_id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.org_name OWNER TO postgres;

--
-- Name: org_name_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.org_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.org_name_id_seq OWNER TO postgres;

--
-- Name: org_name_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.org_name_id_seq OWNED BY misp2.org_name.id;


--
-- Name: org_person; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.org_person (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    org_id integer NOT NULL,
    person_id integer NOT NULL,
    portal_id integer NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    profession character varying(50)
);


ALTER TABLE misp2.org_person OWNER TO postgres;

--
-- Name: TABLE org_person; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.org_person IS 'asutuse ja isiku seos, mis n??itab, et isikul on ??igus seda asutust esindada, teha p??ringuid selle asutuse nime all';


--
-- Name: COLUMN org_person.role; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.org_person.role IS 'kasutajaroll: 0 - asutuse tavakasutaja 1 - asutuse p????su??iguste haldur 2 - portaali haldur';


--
-- Name: org_person_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.org_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.org_person_id_seq OWNER TO postgres;

--
-- Name: org_person_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.org_person_id_seq OWNED BY misp2.org_person.id;


--
-- Name: org_query; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.org_query (
    id integer NOT NULL,
    org_id integer NOT NULL,
    query_id bigint NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.org_query OWNER TO postgres;

--
-- Name: TABLE org_query; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.org_query IS 'asutusele turvaserveris avatud p??ringud';


--
-- Name: org_query_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.org_query_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.org_query_id_seq OWNER TO postgres;

--
-- Name: org_query_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.org_query_id_seq OWNED BY misp2.org_query.id;


--
-- Name: org_valid; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.org_valid (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    org_id integer NOT NULL,
    valid_date timestamp without time zone NOT NULL
);


ALTER TABLE misp2.org_valid OWNER TO postgres;

--
-- Name: TABLE org_valid; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.org_valid IS 'Asutuste kehtivusp??ringu sooritamiste ajad';


--
-- Name: COLUMN org_valid.org_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.org_valid.org_id IS 'viide asutusele';


--
-- Name: COLUMN org_valid.valid_date; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.org_valid.valid_date IS 'kehtivuskontrolli teostamise aeg';


--
-- Name: org_valid_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.org_valid_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.org_valid_id_seq OWNER TO postgres;

--
-- Name: org_valid_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.org_valid_id_seq OWNED BY misp2.org_valid.id;


--
-- Name: package; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.package (
    id integer NOT NULL,
    name character varying(256),
    url character varying(256),
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20)
);


ALTER TABLE misp2.package OWNER TO postgres;

--
-- Name: TABLE package; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.package IS 'BPEL "pakid" (package)';


--
-- Name: COLUMN package.name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.package.name IS 'BPEL package nimi';


--
-- Name: COLUMN package.url; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.package.url IS 'BPEL package upload url';


--
-- Name: package_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.package_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.package_id_seq OWNER TO postgres;

--
-- Name: package_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.package_id_seq OWNED BY misp2.package.id;


--
-- Name: person; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.person (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    ssn character varying(20) NOT NULL,
    givenname character varying(50),
    surname character varying(50) NOT NULL,
    password character varying(50),
    password_salt character varying(50) DEFAULT ''::character varying NOT NULL,
    overtake_code character varying(50),
    overtake_code_salt character varying(50) DEFAULT ''::character varying NOT NULL,
    certificate character varying(3000),
    last_portal integer
);


ALTER TABLE misp2.person OWNER TO postgres;

--
-- Name: TABLE person; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.person IS 'isikud, portaali kasutajakontod';


--
-- Name: COLUMN person.ssn; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person.ssn IS 'isikukood';


--
-- Name: COLUMN person.givenname; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person.givenname IS 'eesnimi';


--
-- Name: COLUMN person.surname; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person.surname IS 'perekonnanimi';


--
-- Name: COLUMN person.password; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person.password IS '??lev??tmiskood';


--
-- Name: COLUMN person.certificate; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person.certificate IS 'sertifikaat';


--
-- Name: person_eula; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.person_eula (
    id integer NOT NULL,
    person_id integer NOT NULL,
    portal_id integer NOT NULL,
    accepted boolean NOT NULL,
    auth_method character varying(64),
    src_addr character varying(64),
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.person_eula OWNER TO postgres;

--
-- Name: TABLE person_eula; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.person_eula IS 'Tabel sisaldab kasutajate portaali kasutajalitsensi tingimustega n??ustumise tulemusi.
		Kui portaali sisseloginud kasutaja on litsensi tingimustega n??ustunud, tehakse k??esolevasse
		tabelisse kirje ja j??rgmisel sisselogimisel litsensiga n??ustumise ekraani enam ei n??idata.
		
		Tabeli kirje m????rab ennek??ike seose kasutajate tabeli ''person'' ja portaali tabeli ''portal''
		vahel koos n??ustumise olekuga t??ev????rtuse t????pi veerus ''accepted''. Lisaks sellele salvestatakse
		n??ustumise juurde metaandmed nagu n??ustumise aeg ja autentimismeetod.
	   ';


--
-- Name: COLUMN person_eula.id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.id IS 'tabeli primaarv??ti';


--
-- Name: COLUMN person_eula.person_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.person_id IS 'viide isikule, kes portaali EULA-ga on n??ustunud (v??i n??ustumise tagasi l??kanud)';


--
-- Name: COLUMN person_eula.portal_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.portal_id IS 'viide portaalile ''portal'' tabelis, millega EULA seotud on';


--
-- Name: COLUMN person_eula.accepted; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.accepted IS 't??ev????rtus, mis n??itab n??ustumise olekut. V??lja v????rtus on
		 - t??ene, kui kasutaja on EULA-ga n??ustunud;
		 - v????r, kui kasutaja on n??ustumise tagasi l??kanud;';


--
-- Name: COLUMN person_eula.auth_method; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.auth_method IS 'kasutaja autentimismeetodi metainfo';


--
-- Name: COLUMN person_eula.src_addr; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.src_addr IS 'kasutaja (IP) aadress';


--
-- Name: COLUMN person_eula.created; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.created IS 'sissekande loomisaeg';


--
-- Name: COLUMN person_eula.last_modified; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.last_modified IS 'sissekande viimase muutmise aeg';


--
-- Name: COLUMN person_eula.username; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.username IS 'sissekande looja kasutajanimi';


--
-- Name: person_eula_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.person_eula_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.person_eula_id_seq OWNER TO postgres;

--
-- Name: person_eula_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.person_eula_id_seq OWNED BY misp2.person_eula.id;


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.person_id_seq OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.person_id_seq OWNED BY misp2.person.id;


--
-- Name: person_mail_org; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.person_mail_org (
    id integer NOT NULL,
    org_id integer,
    person_id integer NOT NULL,
    mail character varying(75),
    notify_changes boolean DEFAULT false NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20)
);


ALTER TABLE misp2.person_mail_org OWNER TO postgres;

--
-- Name: COLUMN person_mail_org.mail; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_mail_org.mail IS 'elektronposti aadress';


--
-- Name: person_mail_org_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.person_mail_org_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.person_mail_org_id_seq OWNER TO postgres;

--
-- Name: person_mail_org_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.person_mail_org_id_seq OWNED BY misp2.person_mail_org.id;


--
-- Name: portal; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.portal (
    id integer NOT NULL,
    short_name character varying(32) NOT NULL,
    org_id integer NOT NULL,
    misp_type integer NOT NULL,
    security_host character varying(256) NOT NULL,
    message_mediator character varying(256) NOT NULL,
    bpel_engine character varying(100) DEFAULT NULL::character varying,
    debug integer NOT NULL,
    univ_auth_query character varying(256),
    univ_check_query character varying(256),
    univ_check_valid_time integer,
    univ_check_max_valid_time integer,
    univ_use_manager boolean,
    use_topics boolean DEFAULT false,
    use_xrd_issue boolean DEFAULT false,
    log_query boolean DEFAULT true,
    register_units boolean,
    unit_is_consumer boolean,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    client_xroad_instance character varying(64),
    xroad_protocol_ver character varying(5) DEFAULT '3.1'::character varying NOT NULL,
    misp2_xroad_service_member_class character varying(16),
    misp2_xroad_service_member_code character varying(20),
    misp2_xroad_service_subsystem_code character varying(64),
    eula_in_use boolean DEFAULT false
);


ALTER TABLE misp2.portal OWNER TO postgres;

--
-- Name: TABLE portal; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.portal IS 'portaali andmed';


--
-- Name: COLUMN portal.short_name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.short_name IS 'l??hinimi, mida kasutatakse antud portaali poole p????rdumisel URLis parameetrina (vanas MISPis portaali kataloogi nimi)';


--
-- Name: COLUMN portal.org_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.org_id IS 'portaali (pea)asutus';


--
-- Name: COLUMN portal.misp_type; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.misp_type IS 'portaali t????p, vanas MISPis konfiparemeeter "misp"';


--
-- Name: COLUMN portal.security_host; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.security_host IS 'turvaserveri aadress, vanas MISPis konfiparemeeter "security_host"';


--
-- Name: COLUMN portal.message_mediator; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.message_mediator IS 'p??ringute saatmise aadress (turvaserver v??i s??numimootor)';


--
-- Name: COLUMN portal.bpel_engine; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.bpel_engine IS 'BPEL mootori aadress (NULL - tegu MISP Lite-ga)';


--
-- Name: COLUMN portal.debug; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.debug IS 'debug log level (default = 0 - no debug info)';


--
-- Name: COLUMN portal.univ_auth_query; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.univ_auth_query IS 'universaalse portaalit????bi korral: ??ksuse esindus??iguse kontrollp??ringu nimi';


--
-- Name: COLUMN portal.univ_check_query; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.univ_check_query IS 'universaalse portaalit????bi korral ??ksuse kehtivuse kontrollp??ringu nimi';


--
-- Name: COLUMN portal.univ_check_valid_time; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.univ_check_valid_time IS 'universaalse portaalit????bi korral: ??ksuse kehtivuse kontrollp??ringu tulemuse kehtivusaeg tundides';


--
-- Name: COLUMN portal.univ_use_manager; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.univ_use_manager IS 'universaalse portaalit????bi korral: n??itab, kas antud portaali puhul kasutada ??ksuse halduri rolli, v??i selle asemel nn lihtsustatud ??iguste andmist ilma ??ksuse halduri m????ramiseta; vanas MISPis konfiparameeter  ''lihtsustatud_oigused''';


--
-- Name: COLUMN portal.log_query; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.log_query IS 'logimisp??ringu nimi';


--
-- Name: COLUMN portal.client_xroad_instance; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.client_xroad_instance IS 'X-Tee v6 kliendi instants';


--
-- Name: COLUMN portal.eula_in_use; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.eula_in_use IS 't??ene, kui portaalis on EULA kasutusel ja kasutajatelt k??sitakse sellega n??ustumist';


--
-- Name: portal_eula; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.portal_eula (
    id integer NOT NULL,
    portal_id integer NOT NULL,
    lang character varying(2) NOT NULL,
    content text NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.portal_eula OWNER TO postgres;

--
-- Name: TABLE portal_eula; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.portal_eula IS 'Tabel sisaldab kasutajalitsentside tekste,
        mis kasutajale esimesel portaali sisselogimisel kuvatakse.
        ??hel portaalil saab olla mitu kasutajalitsensi teksti,
        sellisel juhul iga kanne sisaldab sama litsensi teksti erinevas keeles.
        Tabelisse tehakse kirjeid rakenduse administraatori rollis
        portaali loomise/muutmise vormilt administreerimisliideses.
        Tabeli kirjeid loetakse kasutaja esmasel sisenemisel portaali, et
        kasutajale litsensi sisu n??ustumiseks kuvada.';


--
-- Name: COLUMN portal_eula.id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.id IS 'tabeli primaarv??ti';


--
-- Name: COLUMN portal_eula.portal_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.portal_id IS 'viide portaalile ''portal'' tabelis, millega k??esolev EULA sisu seotud on';


--
-- Name: COLUMN portal_eula.lang; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.lang IS 'EULA sisu kahet??heline keelekood';


--
-- Name: COLUMN portal_eula.content; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.content IS 'EULA sisu tekst MD formaadis';


--
-- Name: COLUMN portal_eula.created; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.created IS 'sissekande loomisaeg';


--
-- Name: COLUMN portal_eula.last_modified; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.last_modified IS 'sissekande viimase muutmise aeg';


--
-- Name: COLUMN portal_eula.username; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.username IS 'sissekande looja kasutajanimi';


--
-- Name: portal_eula_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.portal_eula_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.portal_eula_id_seq OWNER TO postgres;

--
-- Name: portal_eula_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.portal_eula_id_seq OWNED BY misp2.portal_eula.id;


--
-- Name: portal_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.portal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.portal_id_seq OWNER TO postgres;

--
-- Name: portal_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.portal_id_seq OWNED BY misp2.portal.id;


--
-- Name: portal_name; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.portal_name (
    id integer NOT NULL,
    description character varying(256) NOT NULL,
    lang character varying(10) NOT NULL,
    portal_id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.portal_name OWNER TO postgres;

--
-- Name: portal_name_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.portal_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.portal_name_id_seq OWNER TO postgres;

--
-- Name: portal_name_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.portal_name_id_seq OWNED BY misp2.portal_name.id;


--
-- Name: producer; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.producer (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    xroad_instance character varying(64),
    short_name character varying(50) NOT NULL,
    member_class character varying(16),
    subsystem_code character varying(64),
    protocol character varying(16) NOT NULL,
    in_use boolean,
    is_complex boolean,
    wsdl_url character varying(256),
    repository_url character varying(256),
    portal_id integer NOT NULL
);


ALTER TABLE misp2.producer OWNER TO postgres;

--
-- Name: TABLE producer; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.producer IS 'X-tee andmekogud';


--
-- Name: COLUMN producer.protocol; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.producer.protocol IS 'Protokolli, mida produceri querid kasutavad s??numivahetuses.';


--
-- Name: producer_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.producer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.producer_id_seq OWNER TO postgres;

--
-- Name: producer_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.producer_id_seq OWNED BY misp2.producer.id;


--
-- Name: producer_name; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.producer_name (
    id integer NOT NULL,
    description character varying(256) NOT NULL,
    lang character varying(10),
    producer_id integer,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.producer_name OWNER TO postgres;

--
-- Name: producer_name_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.producer_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.producer_name_id_seq OWNER TO postgres;

--
-- Name: producer_name_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.producer_name_id_seq OWNED BY misp2.producer_name.id;


--
-- Name: query; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.query (
    id integer NOT NULL,
    type integer,
    name character varying(256) NOT NULL,
    xroad_request_namespace character varying(256),
    sub_query_names text,
    producer_id integer,
    package_id integer,
    openapi_service_code character varying(256),
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.query OWNER TO postgres;

--
-- Name: TABLE query; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.query IS 'teenused';


--
-- Name: COLUMN query.type; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.type IS 'teenuse t????p 0 - X-tee teenus  1-  WS-BPEL teenus  (2- portaali p??ringu??iguste andmekogu teenus)';


--
-- Name: COLUMN query.name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.name IS 'Teenuse l??hinimi, X-tee v6 korral serviceCode ja serviceVersion punktiga eraldatuna. REST teenuste puhul operationId.';


--
-- Name: COLUMN query.xroad_request_namespace; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.xroad_request_namespace IS 'kasutatakse x-tee v6 klassifikaatorite p??ringul';


--
-- Name: COLUMN query.sub_query_names; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.sub_query_names IS 'Kasutatakse kompleksteenuse puhul alamp??ringute nimistu hoidmiseks.';


--
-- Name: COLUMN query.producer_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.producer_id IS 'viide andmekogule';


--
-- Name: COLUMN query.package_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.package_id IS 'BPEL teenuse korral, viide BPEL package-le';


--
-- Name: COLUMN query.openapi_service_code; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.openapi_service_code IS 'Teenuse nimi, mis on vajalik xroad rest teenuste kasutamiseks';


--
-- Name: query_error_log; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.query_error_log (
    id integer NOT NULL,
    query_log_id integer,
    code character varying(64),
    description text,
    detail text,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.query_error_log OWNER TO postgres;

--
-- Name: query_error_log_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.query_error_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.query_error_log_id_seq OWNER TO postgres;

--
-- Name: query_error_log_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.query_error_log_id_seq OWNED BY misp2.query_error_log.id;


--
-- Name: query_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.query_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.query_id_seq OWNER TO postgres;

--
-- Name: query_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.query_id_seq OWNED BY misp2.query.id;


--
-- Name: query_log; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.query_log (
    id integer NOT NULL,
    query_name character varying(256),
    main_query_name character varying(256),
    query_id character varying(128),
    description character varying(800),
    org_code character varying(256),
    unit_code character varying(256),
    query_time timestamp without time zone,
    person_ssn character varying(20),
    portal_id integer,
    query_time_sec numeric(10,3),
    success boolean DEFAULT true,
    query_size numeric(12,3),
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE misp2.query_log OWNER TO postgres;

--
-- Name: TABLE query_log; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.query_log IS 'sooritatud p??ringute metainfo logi';


--
-- Name: COLUMN query_log.query_name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query_log.query_name IS 'andmekogu.p??ring.versioon';


--
-- Name: COLUMN query_log.query_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query_log.query_id IS 'p??ringu ID';


--
-- Name: COLUMN query_log.person_ssn; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query_log.person_ssn IS 'p??ringu sooritaja isikukood';


--
-- Name: query_log_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.query_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.query_log_id_seq OWNER TO postgres;

--
-- Name: query_log_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.query_log_id_seq OWNED BY misp2.query_log.id;


--
-- Name: query_name; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.query_name (
    id integer NOT NULL,
    description character varying(256) NOT NULL,
    lang character varying(10),
    query_id integer,
    query_note text,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.query_name OWNER TO postgres;

--
-- Name: query_name_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.query_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.query_name_id_seq OWNER TO postgres;

--
-- Name: query_name_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.query_name_id_seq OWNED BY misp2.query_name.id;


--
-- Name: query_topic; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.query_topic (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    query_id integer NOT NULL,
    topic_id integer NOT NULL
);


ALTER TABLE misp2.query_topic OWNER TO postgres;

--
-- Name: query_topic_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.query_topic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.query_topic_id_seq OWNER TO postgres;

--
-- Name: query_topic_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.query_topic_id_seq OWNED BY misp2.query_topic.id;


--
-- Name: t3_sec; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.t3_sec (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    user_from character varying(20) NOT NULL,
    user_to character varying(20),
    action_id integer NOT NULL,
    query character varying(256),
    group_name character varying(150),
    org_code character varying(20),
    portal_name character varying(32),
    valid_until character varying(50),
    query_id character varying(100)
);


ALTER TABLE misp2.t3_sec OWNER TO postgres;

--
-- Name: TABLE t3_sec; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.t3_sec IS '??iguste haldamisega seotud tegevuste logitabel, need tegevused salvestatakse ka X-tee logip??ringuga';


--
-- Name: COLUMN t3_sec.user_from; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.user_from IS 'isikukood, kes andis ??igusi';


--
-- Name: COLUMN t3_sec.user_to; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.user_to IS 'isikukood, kellele anti p??ringu??igused';


--
-- Name: COLUMN t3_sec.action_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.action_id IS 'tegevuse tyyp: 0 - halduri m????ramine, 1 - haldiri kustutamine, 2 - isiku kasutajagruppi lisamine, 3 - isiku kasutajagrupist eemaldamine,  4 - p??ringu??iguste lisamine,  5 - p??ringu??iguste eemaldamine, 6 - kasutajagruppide lisamine,  7 - kasutajagruppide eemaldamine, 8 - esindus??iguse kontroll, 9 - isiku lisamine, 10 - isiku kustutamine, 11 - asutuse lisamine, 12 - asutuse kustutamine, 14 - portaali kustutamine, 15 - grupi parameetrite muutmine';


--
-- Name: COLUMN t3_sec.group_name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.group_name IS 'kasutajagrupi nimi';


--
-- Name: COLUMN t3_sec.org_code; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.org_code IS 'asutuse kood';


--
-- Name: COLUMN t3_sec.query_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.query_id IS 'p??ringu id';


--
-- Name: t3_sec_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.t3_sec_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.t3_sec_id_seq OWNER TO postgres;

--
-- Name: t3_sec_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.t3_sec_id_seq OWNED BY misp2.t3_sec.id;


--
-- Name: topic; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.topic (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    priority integer,
    portal_id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.topic OWNER TO postgres;

--
-- Name: topic_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.topic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.topic_id_seq OWNER TO postgres;

--
-- Name: topic_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.topic_id_seq OWNED BY misp2.topic.id;


--
-- Name: topic_name; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.topic_name (
    id integer NOT NULL,
    description character varying(256) NOT NULL,
    lang character varying(10) NOT NULL,
    topic_id integer NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.topic_name OWNER TO postgres;

--
-- Name: topic_name_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.topic_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.topic_name_id_seq OWNER TO postgres;

--
-- Name: topic_name_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.topic_name_id_seq OWNED BY misp2.topic_name.id;


--
-- Name: xforms; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.xforms (
    id integer NOT NULL,
    form text,
    query_id integer,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    url character varying(256)
);


ALTER TABLE misp2.xforms OWNER TO postgres;

--
-- Name: TABLE xforms; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.xforms IS 'teenuste XForms vormid';


--
-- Name: COLUMN xforms.form; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xforms.form IS 'XForms vorm';


--
-- Name: COLUMN xforms.query_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xforms.query_id IS 'viide p??ringule';


--
-- Name: COLUMN xforms.url; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xforms.url IS 'URL, millelt laetakse XForms';


--
-- Name: xforms_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.xforms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.xforms_id_seq OWNER TO postgres;

--
-- Name: xforms_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.xforms_id_seq OWNED BY misp2.xforms.id;


--
-- Name: xroad_instance; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.xroad_instance (
    id integer NOT NULL,
    portal_id integer NOT NULL,
    code character varying(64) NOT NULL,
    in_use boolean,
    selected boolean,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL
);


ALTER TABLE misp2.xroad_instance OWNER TO postgres;

--
-- Name: TABLE xroad_instance; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.xroad_instance IS 'Tabel sisaldab portaali teenuste X-Tee instantse.
	Veerg ''in_use'' m????rab, millised instantsid on portaalis parasjagu kasutusel.
	Kasutusel olevatest instantside jaoks on teenuste halduril v??imalik v??rskendada
	teenuste nimekirja ja hallata vastavate andmekogude teenuseid.';


--
-- Name: COLUMN xroad_instance.id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.id IS 'tabeli primaarv??ti';


--
-- Name: COLUMN xroad_instance.portal_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.portal_id IS 'viide portaalile ''portal'' tabelis, millega k??esolev X-Tee instants seotud on';


--
-- Name: COLUMN xroad_instance.code; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.code IS 'X-Tee instantsi v????rtus, mis X-Tee s??numite p??isev??ljadele kirjutatakse';


--
-- Name: COLUMN xroad_instance.in_use; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.in_use IS 't??ene, kui k??esolev X-Tee instants on portaalis aktiivne, st selle teenuseid saab laadida;
	v????r, kui k??esolev X-Tee instants ei ole portaalis kasutusel';


--
-- Name: COLUMN xroad_instance.selected; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.selected IS 't??ene, kui k??esolev X-Tee instants on portaalis andmekogude p??ringul vaikimisi valitud;
    v????r, kui k??esolev X-Tee instants ei ole vaikimisi valitud';


--
-- Name: COLUMN xroad_instance.created; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.created IS 'sissekande loomisaeg';


--
-- Name: COLUMN xroad_instance.last_modified; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.last_modified IS 'sissekande viimase muutmise aeg';


--
-- Name: xroad_instance_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.xroad_instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.xroad_instance_id_seq OWNER TO postgres;

--
-- Name: xroad_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.xroad_instance_id_seq OWNED BY misp2.xroad_instance.id;


--
-- Name: xslt; Type: TABLE; Schema: misp2; Owner: postgres
--

CREATE TABLE misp2.xslt (
    id integer NOT NULL,
    query_id integer,
    portal_id integer,
    xsl text,
    priority smallint,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    name character varying(256),
    form_type integer NOT NULL,
    in_use boolean NOT NULL,
    producer_id integer,
    url character varying(256)
);


ALTER TABLE misp2.xslt OWNER TO postgres;

--
-- Name: TABLE xslt; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON TABLE misp2.xslt IS 'XSL stiililehed, mis rakendatakse XForms vormidele';


--
-- Name: COLUMN xslt.query_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.query_id IS 'viide p??ringule, kui null, siis rakendatakse k??igile';


--
-- Name: COLUMN xslt.xsl; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.xsl IS 'XSL stiililileht';


--
-- Name: COLUMN xslt.priority; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.priority IS 'XSL rakendamise j??rjekorranumber 0-esimene';


--
-- Name: COLUMN xslt.name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.name IS 'XSL stiililehe nimetus ';


--
-- Name: COLUMN xslt.form_type; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.form_type IS 'mis t????pi vormile rakendatakse 0-HTML 1-PDF';


--
-- Name: COLUMN xslt.in_use; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.in_use IS 'n??itab, kas XSL on kasutusel v??i mitte';


--
-- Name: COLUMN xslt.producer_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.producer_id IS 'viide andmekogule';


--
-- Name: COLUMN xslt.url; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.url IS 'URL, millelt laetakse XSL';


--
-- Name: xslt_id_seq; Type: SEQUENCE; Schema: misp2; Owner: postgres
--

CREATE SEQUENCE misp2.xslt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE misp2.xslt_id_seq OWNER TO postgres;

--
-- Name: xslt_id_seq; Type: SEQUENCE OWNED BY; Schema: misp2; Owner: postgres
--

ALTER SEQUENCE misp2.xslt_id_seq OWNED BY misp2.xslt.id;


--
-- Name: admin id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.admin ALTER COLUMN id SET DEFAULT nextval('misp2.admin_id_seq'::regclass);


--
-- Name: check_register_status id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.check_register_status ALTER COLUMN id SET DEFAULT nextval('misp2.check_register_status_id_seq'::regclass);


--
-- Name: classifier id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.classifier ALTER COLUMN id SET DEFAULT nextval('misp2.classifier_id_seq'::regclass);


--
-- Name: group_ id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_ ALTER COLUMN id SET DEFAULT nextval('misp2.group__id_seq'::regclass);


--
-- Name: group_item id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_item ALTER COLUMN id SET DEFAULT nextval('misp2.group_item_id_seq'::regclass);


--
-- Name: group_person id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_person ALTER COLUMN id SET DEFAULT nextval('misp2.group_person_id_seq'::regclass);


--
-- Name: manager_candidate id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.manager_candidate ALTER COLUMN id SET DEFAULT nextval('misp2.manager_candidate_id_seq'::regclass);


--
-- Name: news id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.news ALTER COLUMN id SET DEFAULT nextval('misp2.news_id_seq'::regclass);


--
-- Name: org id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org ALTER COLUMN id SET DEFAULT nextval('misp2.org_id_seq'::regclass);


--
-- Name: org_name id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_name ALTER COLUMN id SET DEFAULT nextval('misp2.org_name_id_seq'::regclass);


--
-- Name: org_person id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_person ALTER COLUMN id SET DEFAULT nextval('misp2.org_person_id_seq'::regclass);


--
-- Name: org_query id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_query ALTER COLUMN id SET DEFAULT nextval('misp2.org_query_id_seq'::regclass);


--
-- Name: org_valid id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_valid ALTER COLUMN id SET DEFAULT nextval('misp2.org_valid_id_seq'::regclass);


--
-- Name: package id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.package ALTER COLUMN id SET DEFAULT nextval('misp2.package_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person ALTER COLUMN id SET DEFAULT nextval('misp2.person_id_seq'::regclass);


--
-- Name: person_eula id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_eula ALTER COLUMN id SET DEFAULT nextval('misp2.person_eula_id_seq'::regclass);


--
-- Name: person_mail_org id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_mail_org ALTER COLUMN id SET DEFAULT nextval('misp2.person_mail_org_id_seq'::regclass);


--
-- Name: portal id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal ALTER COLUMN id SET DEFAULT nextval('misp2.portal_id_seq'::regclass);


--
-- Name: portal_eula id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal_eula ALTER COLUMN id SET DEFAULT nextval('misp2.portal_eula_id_seq'::regclass);


--
-- Name: portal_name id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal_name ALTER COLUMN id SET DEFAULT nextval('misp2.portal_name_id_seq'::regclass);


--
-- Name: producer id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.producer ALTER COLUMN id SET DEFAULT nextval('misp2.producer_id_seq'::regclass);


--
-- Name: producer_name id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.producer_name ALTER COLUMN id SET DEFAULT nextval('misp2.producer_name_id_seq'::regclass);


--
-- Name: query id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query ALTER COLUMN id SET DEFAULT nextval('misp2.query_id_seq'::regclass);


--
-- Name: query_error_log id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_error_log ALTER COLUMN id SET DEFAULT nextval('misp2.query_error_log_id_seq'::regclass);


--
-- Name: query_log id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_log ALTER COLUMN id SET DEFAULT nextval('misp2.query_log_id_seq'::regclass);


--
-- Name: query_name id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_name ALTER COLUMN id SET DEFAULT nextval('misp2.query_name_id_seq'::regclass);


--
-- Name: query_topic id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_topic ALTER COLUMN id SET DEFAULT nextval('misp2.query_topic_id_seq'::regclass);


--
-- Name: t3_sec id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.t3_sec ALTER COLUMN id SET DEFAULT nextval('misp2.t3_sec_id_seq'::regclass);


--
-- Name: topic id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.topic ALTER COLUMN id SET DEFAULT nextval('misp2.topic_id_seq'::regclass);


--
-- Name: topic_name id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.topic_name ALTER COLUMN id SET DEFAULT nextval('misp2.topic_name_id_seq'::regclass);


--
-- Name: xforms id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xforms ALTER COLUMN id SET DEFAULT nextval('misp2.xforms_id_seq'::regclass);


--
-- Name: xroad_instance id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xroad_instance ALTER COLUMN id SET DEFAULT nextval('misp2.xroad_instance_id_seq'::regclass);


--
-- Name: xslt id; Type: DEFAULT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xslt ALTER COLUMN id SET DEFAULT nextval('misp2.xslt_id_seq'::regclass);


--
-- Data for Name: admin; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.admin (id, created, last_modified, username, password, login_username, salt) FROM stdin;
1	2021-01-27 11:22:24.503152	2021-01-27 11:22:24.503152	program	nTMoBDR8PX+8G3987H4gpNyhXzc=	misp2	FRpL7MvfTgMA5OG3OKaHNeGOig4=
\.


--
-- Data for Name: check_register_status; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.check_register_status (id, query_name, query_time, is_ok, created, last_modified, username) FROM stdin;
\.


--
-- Data for Name: classifier; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.classifier (id, content, name, created, last_modified, username, xroad_query_xroad_protocol_ver, xroad_query_xroad_instance, xroad_query_member_class, xroad_query_member_code, xroad_query_subsystem_code, xroad_query_service_code, xroad_query_service_version, xroad_query_request_namespace) FROM stdin;
13	<xtee.riigid><item><name>Afganistan</name><code>AF</code></item><item><name>Ahvenamaa</name><code>AX</code></item><item><name>Albaania</name><code>AL</code></item><item><name>Al??eeria</name><code>DZ</code></item><item><name>Ameerika Samoa</name><code>AS</code></item><item><name>Ameerika ??hendriigid</name><code>US</code></item><item><name>Andorra</name><code>AD</code></item><item><name>Angola</name><code>AO</code></item><item><name>Anguilla</name><code>AI</code></item><item><name>Antarktis</name><code>AQ</code></item><item><name>Antigua ja Barbuda</name><code>AG</code></item><item><name>Araabia ??hendemiraadid</name><code>AE</code></item><item><name>Argentina</name><code>AR</code></item><item><name>Armeenia</name><code>AM</code></item><item><name>Aruba</name><code>AW</code></item><item><name>Aserbaid??aan</name><code>AZ</code></item><item><name>Austraalia</name><code>AU</code></item><item><name>Austria</name><code>AT</code></item><item><name>Bahama</name><code>BS</code></item><item><name>Bahrein</name><code>BH</code></item><item><name>Bangladesh</name><code>BD</code></item><item><name>Barbados</name><code>BB</code></item><item><name>Belau</name><code>PW</code></item><item><name>Belgia</name><code>BE</code></item><item><name>Belize</name><code>BZ</code></item><item><name>Benin</name><code>BJ</code></item><item><name>Bermuda</name><code>BM</code></item><item><name>Bhutan</name><code>BT</code></item><item><name>Boliivia</name><code>BO</code></item><item><name>Bosnia- ja Hertsegoviina</name><code>BA</code></item><item><name>Botswana</name><code>BW</code></item><item><name>Bouvet saar</name><code>BV</code></item><item><name>Brasiilia</name><code>BR</code></item><item><name>Briti India ookeani ala</name><code>IO</code></item><item><name>Briti Neitsisaared</name><code>VG</code></item><item><name>Brunei Darussalam</name><code>BN</code></item><item><name>Bulgaaria</name><code>BG</code></item><item><name>Burkina Faso</name><code>BF</code></item><item><name>Burundi</name><code>BI</code></item><item><name>Cabo Verde</name><code>CV</code></item><item><name>Colombia</name><code>CO</code></item><item><name>Cooki saared</name><code>CK</code></item><item><name>Costa Rica</name><code>CR</code></item><item><name>Cote dIvoire</name><code>CI</code></item><item><name>Djibouti</name><code>DJ</code></item><item><name>Dominica</name><code>DM</code></item><item><name>Dominikaani Vabariik</name><code>DO</code></item><item><name>Ecuador</name><code>EC</code></item><item><name>Eesti</name><code>EE</code></item><item><name>Egiptus</name><code>EG</code></item><item><name>Ekvatoriaal-Guinea</name><code>GQ</code></item><item><name>El Salvador</name><code>SV</code></item><item><name>Eritrea</name><code>ER</code></item><item><name>Etioopia</name><code>ET</code></item><item><name>Falklandi (Malviini) saared</name><code>FK</code></item><item><name>Fid??i</name><code>FJ</code></item><item><name>Filipiinid</name><code>PH</code></item><item><name>F????ri saared</name><code>FO</code></item><item><name>Gabon</name><code>GA</code></item><item><name>Gambia</name><code>GM</code></item><item><name>Ghana</name><code>GH</code></item><item><name>Gibraltar</name><code>GI</code></item><item><name>Grenada</name><code>GD</code></item><item><name>Gruusia</name><code>GE</code></item><item><name>Gr????nimaa</name><code>GL</code></item><item><name>Guadeloupe</name><code>GP</code></item><item><name>Prantsuse Guajaana</name><code>GF</code></item><item><name>Guam</name><code>GU</code></item><item><name>Guatemala</name><code>GT</code></item><item><name>Guernsey</name><code>GG</code></item><item><name>Guinea</name><code>GN</code></item><item><name>Guinea-Bissau</name><code>GW</code></item><item><name>Guyana</name><code>GY</code></item><item><name>Haiti</name><code>HT</code></item><item><name>Heard ja McDonald</name><code>HM</code></item><item><name>Aomen</name><code>MO</code></item><item><name>Hongkong</name><code>HK</code></item><item><name>Hiina</name><code>CN</code></item><item><name>Hispaania</name><code>ES</code></item><item><name>Hollandi Antillid</name><code>AN</code></item><item><name>Honduras</name><code>HN</code></item><item><name>Horvaatia</name><code>HR</code></item><item><name>Iirimaa</name><code>IE</code></item><item><name>Iisrael</name><code>IL</code></item><item><name>India</name><code>IN</code></item><item><name>Indoneesia</name><code>ID</code></item><item><name>Iraak</name><code>IQ</code></item><item><name>Iraan</name><code>IR</code></item><item><name>Island</name><code>IS</code></item><item><name>Itaalia</name><code>IT</code></item><item><name>Jaapan</name><code>JP</code></item><item><name>Jamaica</name><code>JM</code></item><item><name>Jeemen</name><code>YE</code></item><item><name>Jersey</name><code>JE</code></item><item><name>Jordaania</name><code>JO</code></item><item><name>J??ulusaar</name><code>CX</code></item><item><name>Kaimanisaared</name><code>KY</code></item><item><name>Kambod??a</name><code>KH</code></item><item><name>Kamerun</name><code>CM</code></item><item><name>Kanada</name><code>CA</code></item><item><name>Kasahstan</name><code>KZ</code></item><item><name>Katar</name><code>QA</code></item><item><name>Kenya</name><code>KE</code></item><item><name>Kesk-Aafrika Vabariik</name><code>CF</code></item><item><name>K??rg??zstan</name><code>KG</code></item><item><name>Kiribati</name><code>KI</code></item><item><name>Komoorid</name><code>KM</code></item><item><name>Kongo DV</name><code>CD</code></item><item><name>Kongo</name><code>CG</code></item><item><name>Kookossaared (Keelingi saared)</name><code>CC</code></item><item><name>Korea RDV</name><code>KP</code></item><item><name>Korea Vabariik</name><code>KR</code></item><item><name>Kreeka</name><code>GR</code></item><item><name>Kuuba</name><code>CU</code></item><item><name>Kuveit</name><code>KW</code></item><item><name>K??pros</name><code>CY</code></item><item><name>Laos</name><code>LA</code></item><item><name>Leedu</name><code>LT</code></item><item><name>Lesotho</name><code>LS</code></item><item><name>Libeeria</name><code>LR</code></item><item><name>Liechtenstein</name><code>LI</code></item><item><name>Liibanon</name><code>LB</code></item><item><name>Luksemburg</name><code>LU</code></item><item><name>L??una-Aafrika Vabariik</name><code>ZA</code></item><item><name>L??una-Georgia ja L??una-Sandwich</name><code>GS</code></item><item><name>L??ti</name><code>LV</code></item><item><name>L????ne-Sahara</name><code>EH</code></item><item><name>Madagaskar</name><code>MG</code></item><item><name>Holland</name><code>NL</code></item><item><name>Makedoonia</name><code>MK</code></item><item><name>Malaisia</name><code>MY</code></item><item><name>Malawi</name><code>MW</code></item><item><name>Maldiivid</name><code>MV</code></item><item><name>Mali</name><code>ML</code></item><item><name>Malta</name><code>MT</code></item><item><name>Mani saar</name><code>IM</code></item><item><name>Maroko</name><code>MA</code></item><item><name>Marshalli Saared</name><code>MH</code></item><item><name>Martinique</name><code>MQ</code></item><item><name>Mauritaania</name><code>MR</code></item><item><name>Mauritius</name><code>MU</code></item><item><name>Mayotte</name><code>YT</code></item><item><name>Mehhiko</name><code>MX</code></item><item><name>Mikroneesia</name><code>FM</code></item><item><name>Moldova</name><code>MD</code></item><item><name>Monaco</name><code>MC</code></item><item><name>Mongoolia</name><code>MN</code></item><item><name>Montenegro</name><code>ME</code></item><item><name>Montserrat</name><code>MS</code></item><item><name>Mosambiik</name><code>MZ</code></item><item><name>Mujal nimetamata territooriumid</name><code>XY</code></item><item><name>M????ramata</name><code>XX</code></item><item><name>Myanmar (Birma)</name><code>MM</code></item><item><name>Namiibia</name><code>NA</code></item><item><name>Nauru</name><code>NR</code></item><item><name>Nepal</name><code>NP</code></item><item><name>Nicaragua</name><code>NI</code></item><item><name>Nigeeria</name><code>NG</code></item><item><name>Niger</name><code>NE</code></item><item><name>Niue</name><code>NU</code></item><item><name>Norfolk</name><code>NF</code></item><item><name>Norra</name><code>NO</code></item><item><name>Omaan</name><code>OM</code></item><item><name>Paapua Uus-Guinea</name><code>PG</code></item><item><name>Pakistan</name><code>PK</code></item><item><name>Palestiina okupeeritud alad</name><code>PS</code></item><item><name>Panama</name><code>PA</code></item><item><name>Paraguay</name><code>PY</code></item><item><name>Peruu</name><code>PE</code></item><item><name>Pitcairn</name><code>PN</code></item><item><name>Poola</name><code>PL</code></item><item><name>Portugal</name><code>PT</code></item><item><name>Prantsuse L??unaalad</name><code>TF</code></item><item><name>Prantsuse Pol??neesia</name><code>PF</code></item><item><name>Prantsusmaa</name><code>FR</code></item><item><name>Puerto Rico</name><code>PR</code></item><item><name>P??hja-Mariaanid</name><code>MP</code></item><item><name>P??ha Tool (Vatikan)</name><code>VA</code></item><item><name>R??union</name><code>RE</code></item><item><name>Rootsi</name><code>SE</code></item><item><name>Rumeenia</name><code>RO</code></item><item><name>Rwanda</name><code>RW</code></item><item><name>Saalomoni Saared</name><code>SB</code></item><item><name>Saint Kitts ja Nevis</name><code>KN</code></item><item><name>Saint Helena</name><code>SH</code></item><item><name>Saint Lucia</name><code>LC</code></item><item><name>Saint Pierre ja Miquelon</name><code>PM</code></item><item><name>Saint Vincent ja Grenadiinid</name><code>VC</code></item><item><name>Saksamaa</name><code>DE</code></item><item><name>Sambia</name><code>ZM</code></item><item><name>Samoa</name><code>WS</code></item><item><name>San Marino</name><code>SM</code></item><item><name>Sao Tom?? ja Principe</name><code>ST</code></item><item><name>Saudi Araabia</name><code>SA</code></item><item><name>Sei??ellid</name><code>SC</code></item><item><name>Senegal</name><code>SN</code></item><item><name>Serbia</name><code>RS</code></item><item><name>Sierra Leone</name><code>SL</code></item><item><name>Singapur</name><code>SG</code></item><item><name>Slovakkia</name><code>SK</code></item><item><name>Sloveenia</name><code>SI</code></item><item><name>Somaalia</name><code>SO</code></item><item><name>Soome</name><code>FI</code></item><item><name>Sri Lanka</name><code>LK</code></item><item><name>Sudaan</name><code>SD</code></item><item><name>Suriname</name><code>SR</code></item><item><name>Liib??a</name><code>LY</code></item><item><name>Suurbritannia</name><code>GB</code></item><item><name>Svaasimaa</name><code>SZ</code></item><item><name>Svalbard ja Jan Mayen</name><code>SJ</code></item><item><name>S????ria</name><code>SY</code></item><item><name>??veits</name><code>CH</code></item><item><name>Zimbabwe</name><code>ZW</code></item><item><name>Taani</name><code>DK</code></item><item><name>Tad??ikistan</name><code>TJ</code></item><item><name>Tai</name><code>TH</code></item><item><name>Taiwan</name><code>TW</code></item><item><name>Tansaania</name><code>TZ</code></item><item><name>Timor-Leste</name><code>TL</code></item><item><name>Togo</name><code>TG</code></item><item><name>Tokelau</name><code>TK</code></item><item><name>Tonga</name><code>TO</code></item><item><name>Trinidad ja Tobago</name><code>TT</code></item><item><name>T??aad</name><code>TD</code></item><item><name>T??ehhi</name><code>CZ</code></item><item><name>T??iili</name><code>CL</code></item><item><name>Tuneesia</name><code>TN</code></item><item><name>Turks ja Caicos</name><code>TC</code></item><item><name>Tuvalu</name><code>TV</code></item><item><name>T??rgi</name><code>TR</code></item><item><name>T??rkmenistan</name><code>TM</code></item><item><name>Uganda</name><code>UG</code></item><item><name>Ukraina</name><code>UA</code></item><item><name>Ungari</name><code>HU</code></item><item><name>Uruguay</name><code>UY</code></item><item><name>Usbekistan</name><code>UZ</code></item><item><name>Uus-Kaledoonia</name><code>NC</code></item><item><name>Uus-Meremaa</name><code>NZ</code></item><item><name>Valgevene</name><code>BY</code></item><item><name>Wallis ja Futuna</name><code>WF</code></item><item><name>Vanuatu</name><code>VU</code></item><item><name>Venemaa</name><code>RU</code></item><item><name>Venezuela</name><code>VE</code></item><item><name>Vietnam</name><code>VN</code></item><item><name>USA Neitsisaared</name><code>VI</code></item><item><name>??hendriikide hajasaared</name><code>UM</code></item></xtee.riigid>	xtee.riigid	2021-01-27 10:25:45.76905	2021-01-27 10:25:45.76905	admin	\N	\N	\N	\N	\N	\N	\N	\N
14	<xroad.countries><item><name>Afghanistan</name><code>AF</code></item><item><name>??land Islands</name><code>AX</code></item><item><name>Albania</name><code>AL</code></item><item><name>Algeria</name><code>DZ</code></item><item><name>American Samoa</name><code>AS</code></item><item><name>United States of America</name><code>US</code></item><item><name>Andorra</name><code>AD</code></item><item><name>Angola</name><code>AO</code></item><item><name>Anguilla</name><code>AI</code></item><item><name>Antarctica</name><code>AQ</code></item><item><name>Antigua and Barbuda</name><code>AG</code></item><item><name>United Arab Emirates</name><code>AE</code></item><item><name>Argentina</name><code>AR</code></item><item><name>Armenia</name><code>AM</code></item><item><name>Aruba</name><code>AW</code></item><item><name>Azerbaijan</name><code>AZ</code></item><item><name>Australia</name><code>AU</code></item><item><name>Austria</name><code>AT</code></item><item><name>Bahamas</name><code>BS</code></item><item><name>Bahrain</name><code>BH</code></item><item><name>Bangladesh</name><code>BD</code></item><item><name>Barbados</name><code>BB</code></item><item><name>Palau</name><code>PW</code></item><item><name>Belgium</name><code>BE</code></item><item><name>Belize</name><code>BZ</code></item><item><name>Benin</name><code>BJ</code></item><item><name>Bermuda</name><code>BM</code></item><item><name>Bhutan</name><code>BT</code></item><item><name>Bolivia</name><code>BO</code></item><item><name>Bosnia and Hertzegovina</name><code>BA</code></item><item><name>Botswana</name><code>BW</code></item><item><name>Bouvet Island</name><code>BV</code></item><item><name>Brazil</name><code>BR</code></item><item><name>British Indian Ocean Territory</name><code>IO</code></item><item><name>Virgin Islands (British)</name><code>VG</code></item><item><name>Brunei Darussalam</name><code>BN</code></item><item><name>Bulgaria</name><code>BG</code></item><item><name>Burkina Faso</name><code>BF</code></item><item><name>Burundi</name><code>BI</code></item><item><name>Cape Verde</name><code>CV</code></item><item><name>Colombia</name><code>CO</code></item><item><name>Cook Islands</name><code>CK</code></item><item><name>Costa Rica</name><code>CR</code></item><item><name>Cote dIvoire</name><code>CI</code></item><item><name>Djibouti</name><code>DJ</code></item><item><name>Dominica</name><code>DM</code></item><item><name>Dominican Republic</name><code>DO</code></item><item><name>Ecuador</name><code>EC</code></item><item><name>Estonia</name><code>EE</code></item><item><name>Egypt</name><code>EG</code></item><item><name>Equatorial Guinea</name><code>GQ</code></item><item><name>El Salvador</name><code>SV</code></item><item><name>Eritrea</name><code>ER</code></item><item><name>Ethiopia</name><code>ET</code></item><item><name>Falkland Islands (Malvinas)</name><code>FK</code></item><item><name>Fiji</name><code>FJ</code></item><item><name>Philippines</name><code>PH</code></item><item><name>Faroe Islands</name><code>FO</code></item><item><name>Gabon</name><code>GA</code></item><item><name>Gambia</name><code>GM</code></item><item><name>Ghana</name><code>GH</code></item><item><name>Gibraltar</name><code>GI</code></item><item><name>Grenada</name><code>GD</code></item><item><name>Georgia</name><code>GE</code></item><item><name>Greenland</name><code>GL</code></item><item><name>Guadeloupe</name><code>GP</code></item><item><name>French Guiana</name><code>GF</code></item><item><name>Guam</name><code>GU</code></item><item><name>Guatemala</name><code>GT</code></item><item><name>Guernsey</name><code>GG</code></item><item><name>Guinea</name><code>GN</code></item><item><name>Guinea-Bissau</name><code>GW</code></item><item><name>Guyana</name><code>GY</code></item><item><name>Haiti</name><code>HT</code></item><item><name>Heard and McDonald Islands</name><code>HM</code></item><item><name>Macao</name><code>MO</code></item><item><name>Hong Kong</name><code>HK</code></item><item><name>China</name><code>CN</code></item><item><name>Spain</name><code>ES</code></item><item><name>Netherlands Antilles</name><code>AN</code></item><item><name>Honduras</name><code>HN</code></item><item><name>Croatia</name><code>HR</code></item><item><name>Ireland</name><code>IE</code></item><item><name>Israel</name><code>IL</code></item><item><name>India</name><code>IN</code></item><item><name>Indonesia</name><code>ID</code></item><item><name>Iraq</name><code>IQ</code></item><item><name>Iran</name><code>IR</code></item><item><name>Iceland</name><code>IS</code></item><item><name>Italy</name><code>IT</code></item><item><name>Japan</name><code>JP</code></item><item><name>Jamaica</name><code>JM</code></item><item><name>Yemen</name><code>YE</code></item><item><name>Jersey</name><code>JE</code></item><item><name>Jordan</name><code>JO</code></item><item><name>Christmas Island</name><code>CX</code></item><item><name>Cayman Islands</name><code>KY</code></item><item><name>Cambodia</name><code>KH</code></item><item><name>Cameroon</name><code>CM</code></item><item><name>Canada</name><code>CA</code></item><item><name>Kazakhstan</name><code>KZ</code></item><item><name>Qatar</name><code>QA</code></item><item><name>Kenya</name><code>KE</code></item><item><name>Central African Republik</name><code>CF</code></item><item><name>Kyrgyzstan</name><code>KG</code></item><item><name>Kiribati</name><code>KI</code></item><item><name>Comoros</name><code>KM</code></item><item><name>Congo, the Democratic Republik of the</name><code>CD</code></item><item><name>Congo</name><code>CG</code></item><item><name>Cocos (Keeling) Islands</name><code>CC</code></item><item><name>Korea, Democratic Peoples Republic of</name><code>KP</code></item><item><name>Korea, Republic of</name><code>KR</code></item><item><name>Greece</name><code>GR</code></item><item><name>Cuba</name><code>CU</code></item><item><name>Kuwait</name><code>KW</code></item><item><name>Cyprus</name><code>CY</code></item><item><name>Lao Peoples Democratic Republic</name><code>LA</code></item><item><name>Lithuania</name><code>LT</code></item><item><name>Lesotho</name><code>LS</code></item><item><name>Liberia</name><code>LR</code></item><item><name>Liechtenstein</name><code>LI</code></item><item><name>Lebanon</name><code>LB</code></item><item><name>Luxembourg</name><code>LU</code></item><item><name>South Africa</name><code>ZA</code></item><item><name>South Georgia and the South Sandwich Islands</name><code>GS</code></item><item><name>Latvia</name><code>LV</code></item><item><name>Western Sahara</name><code>EH</code></item><item><name>Madagascar</name><code>MG</code></item><item><name>Netherlands</name><code>NL</code></item><item><name>Macedonia</name><code>MK</code></item><item><name>Malaysia</name><code>MY</code></item><item><name>Malawi</name><code>MW</code></item><item><name>Maldives</name><code>MV</code></item><item><name>Mali</name><code>ML</code></item><item><name>Malta</name><code>MT</code></item><item><name>Isle of Man</name><code>IM</code></item><item><name>Morocco</name><code>MA</code></item><item><name>Marshall Islands</name><code>MH</code></item><item><name>Martinique</name><code>MQ</code></item><item><name>Mauritania</name><code>MR</code></item><item><name>Mauritius</name><code>MU</code></item><item><name>Mayotte</name><code>YT</code></item><item><name>Mexico</name><code>MX</code></item><item><name>Micronesia</name><code>FM</code></item><item><name>Moldova, Republic of</name><code>MD</code></item><item><name>Monaco</name><code>MC</code></item><item><name>Mongolia</name><code>MN</code></item><item><name>Montenegro</name><code>ME</code></item><item><name>Montserrat</name><code>MS</code></item><item><name>Mozambique</name><code>MZ</code></item><item><name>Areas not elsewhere specified</name><code>XY</code></item><item><name>Not specified</name><code>XX</code></item><item><name>Myanmar</name><code>MM</code></item><item><name>Namibia</name><code>NA</code></item><item><name>Nauru</name><code>NR</code></item><item><name>Nepal</name><code>NP</code></item><item><name>Nicaragua</name><code>NI</code></item><item><name>Nigeria</name><code>NG</code></item><item><name>Niger</name><code>NE</code></item><item><name>Niue</name><code>NU</code></item><item><name>Norfolk Island</name><code>NF</code></item><item><name>Norway</name><code>NO</code></item><item><name>Oman</name><code>OM</code></item><item><name>Papua New Guinea</name><code>PG</code></item><item><name>Pakistan</name><code>PK</code></item><item><name>Palestinian Territory, Occupied</name><code>PS</code></item><item><name>Panama</name><code>PA</code></item><item><name>Paraguay</name><code>PY</code></item><item><name>Peru</name><code>PE</code></item><item><name>Pitcairn</name><code>PN</code></item><item><name>Poland</name><code>PL</code></item><item><name>Portugal</name><code>PT</code></item><item><name>French Southern Territories</name><code>TF</code></item><item><name>French Polynesia</name><code>PF</code></item><item><name>France</name><code>FR</code></item><item><name>Puerto Rico</name><code>PR</code></item><item><name>Northern Mariana Islands</name><code>MP</code></item><item><name>Holy See (Vatican City State)</name><code>VA</code></item><item><name>R??union</name><code>RE</code></item><item><name>Sweden</name><code>SE</code></item><item><name>Romania</name><code>RO</code></item><item><name>Rwanda</name><code>RW</code></item><item><name>Solomon Islands</name><code>SB</code></item><item><name>Saint Kitts and Nevis</name><code>KN</code></item><item><name>Saint Helena</name><code>SH</code></item><item><name>Saint Lucia</name><code>LC</code></item><item><name>Saint Pierre and Miquelon</name><code>PM</code></item><item><name>Saint Vincent and the Grenadines</name><code>VC</code></item><item><name>Germany</name><code>DE</code></item><item><name>Zambia</name><code>ZM</code></item><item><name>Samoa</name><code>WS</code></item><item><name>San Marino</name><code>SM</code></item><item><name>Sao Tome and Principe</name><code>ST</code></item><item><name>Saudi Arabia</name><code>SA</code></item><item><name>Seychelles</name><code>SC</code></item><item><name>Senegal</name><code>SN</code></item><item><name>Serbia</name><code>RS</code></item><item><name>Sierra Leone</name><code>SL</code></item><item><name>Singapore</name><code>SG</code></item><item><name>Slovakia</name><code>SK</code></item><item><name>Slovenia</name><code>SI</code></item><item><name>Somalia</name><code>SO</code></item><item><name>Finland</name><code>FI</code></item><item><name>Sri Lanka</name><code>LK</code></item><item><name>Sudan</name><code>SD</code></item><item><name>Suriname</name><code>SR</code></item><item><name>Libyan Arab Jamahiriya</name><code>LY</code></item><item><name>United Kingdom</name><code>GB</code></item><item><name>Swaziland</name><code>SZ</code></item><item><name>Svalbard and Jan Mayen</name><code>SJ</code></item><item><name>Syrian Arab Republic</name><code>SY</code></item><item><name>Switzerland</name><code>CH</code></item><item><name>Zimbabwe</name><code>ZW</code></item><item><name>Denmark</name><code>DK</code></item><item><name>Tajikistan</name><code>TJ</code></item><item><name>Thailand</name><code>TH</code></item><item><name>Taiwan</name><code>TW</code></item><item><name>Tanzania, United Republic of</name><code>TZ</code></item><item><name>Timor-Leste</name><code>TL</code></item><item><name>Togo</name><code>TG</code></item><item><name>Tokelau</name><code>TK</code></item><item><name>Tonga</name><code>TO</code></item><item><name>Trinidad and Tobago</name><code>TT</code></item><item><name>Chad</name><code>TD</code></item><item><name>Czech Republic</name><code>CZ</code></item><item><name>Chile</name><code>CL</code></item><item><name>Tunisia</name><code>TN</code></item><item><name>Turks and Caicos Islands</name><code>TC</code></item><item><name>Tuvalu</name><code>TV</code></item><item><name>Turkey</name><code>TR</code></item><item><name>Turkmenistan</name><code>TM</code></item><item><name>Uganda</name><code>UG</code></item><item><name>Ukraine</name><code>UA</code></item><item><name>Hungary</name><code>HU</code></item><item><name>Uruguay</name><code>UY</code></item><item><name>Uzbekistan</name><code>UZ</code></item><item><name>New Caledonia</name><code>NC</code></item><item><name>New Zealand</name><code>NZ</code></item><item><name>Belarus</name><code>BY</code></item><item><name>Wallis and Futuna Islands</name><code>WF</code></item><item><name>Vanuatu</name><code>VU</code></item><item><name>Russian Federation</name><code>RU</code></item><item><name>Venezuela</name><code>VE</code></item><item><name>Viet Nam</name><code>VN</code></item><item><name>Virgin Islands (U.S.)</name><code>VI</code></item><item><name>United States Minor Outlying Islands</name><code>UM</code></item></xroad.countries>	xroad.countries	2021-01-27 10:25:45.770569	2021-01-27 10:25:45.770569	admin	\N	\N	\N	\N	\N	\N	\N	\N
15	<ehak><maakond kood="0037" nimi="Harju maakond"><vald kood="0141" nimi="Anija vald"><asula kood="1046" nimi="Aavere k??la"/><asula kood="1088" nimi="Aegviidu alev"/><asula kood="1184" nimi="Alavere k??la"/><asula kood="1278" nimi="Anija k??la"/><asula kood="1321" nimi="Arava k??la"/><asula kood="1961" nimi="H??rmakosu k??la"/><asula kood="2877" nimi="Kaunissaare k??la"/><asula kood="2925" nimi="Kehra k??la"/><asula kood="2928" nimi="Kehra linn"/><asula kood="3022" nimi="Kihmla k??la"/><asula kood="3716" nimi="Kuusem??e k??la"/><asula kood="4213" nimi="Lehtmetsa k??la"/><asula kood="4369" nimi="Lilli k??la"/><asula kood="4397" nimi="Linnakse k??la"/><asula kood="4506" nimi="Look??la"/><asula kood="4672" nimi="L??kati k??la"/><asula kood="5082" nimi="Mustj??e k??la"/><asula kood="5789" nimi="Paasiku k??la"/><asula kood="6009" nimi="Parila k??la"/><asula kood="6022" nimi="Partsaare k??la"/><asula kood="6241" nimi="Pikva k??la"/><asula kood="6254" nimi="Pillapalu k??la"/><asula kood="6828" nimi="Rasivere k??la"/><asula kood="6855" nimi="Raudoja k??la"/><asula kood="7068" nimi="Rook??la"/><asula kood="7396" nimi="Salumetsa k??la"/><asula kood="7398" nimi="Salum??e k??la"/><asula kood="7693" nimi="Soodla k??la"/><asula kood="8764" nimi="Uuearu k??la"/><asula kood="9248" nimi="Vetla k??la"/><asula kood="9318" nimi="Vikipalu k??la"/><asula kood="9480" nimi="Voose k??la"/><asula kood="9827" nimi="??lej??e k??la"/></vald><vald kood="0198" nimi="Harku vald"><asula kood="1084" nimi="Adra k??la"/><asula kood="1774" nimi="Harku alevik"/><asula kood="1776" nimi="Harkuj??rve k??la"/><asula kood="1903" nimi="Humala k??la"/><asula kood="2047" nimi="Ilmandu k??la"/><asula kood="3608" nimi="Kumna k??la"/><asula kood="3997" nimi="K??tke k??la"/><asula kood="4002" nimi="Laabi k??la"/><asula kood="4344" nimi="Liikva k??la"/><asula kood="4880" nimi="Merik??la"/><asula kood="5038" nimi="Muraste k??la"/><asula kood="5327" nimi="Naage k??la"/><asula kood="6814" nimi="Rannam??isa k??la"/><asula kood="7870" nimi="Suurupi k??la"/><asula kood="7905" nimi="S??rve k??la"/><asula kood="8009" nimi="Tabasalu alevik"/><asula kood="8257" nimi="Tiskre k??la"/><asula kood="8442" nimi="Tutermaa k??la"/><asula kood="8599" nimi="T??risalu k??la"/><asula kood="8848" nimi="Vahi k??la"/><asula kood="8877" nimi="Vaila k??la"/><asula kood="9434" nimi="Viti k??la"/><asula kood="9683" nimi="V????na k??la"/><asula kood="9685" nimi="V????na-J??esuu k??la"/></vald><vald kood="0245" nimi="J??el??htme vald"><asula kood="1367" nimi="Aruaru k??la"/><asula kood="1691" nimi="Haapse k??la"/><asula kood="1741" nimi="Haljava k??la"/><asula kood="2009" nimi="Ihasalu k??la"/><asula kood="2100" nimi="Iru k??la"/><asula kood="2234" nimi="J??el??htme k??la"/><asula kood="2248" nimi="J??esuu k??la"/><asula kood="2299" nimi="J??gala k??la"/><asula kood="2301" nimi="J??gala-Joa k??la"/><asula kood="2452" nimi="Kaberneeme k??la"/><asula kood="2601" nimi="Kallavere k??la"/><asula kood="3296" nimi="Koila k??la"/><asula kood="3301" nimi="Koipsi k??la"/><asula kood="3385" nimi="Koogi k??la"/><asula kood="3471" nimi="Kostiranna k??la"/><asula kood="3472" nimi="Kostivere alevik"/><asula kood="3588" nimi="Kullam??e k??la"/><asula kood="4359" nimi="Liivam??e k??la"/><asula kood="4496" nimi="Loo alevik"/><asula kood="4494" nimi="Loo k??la"/><asula kood="4704" nimi="Maardu k??la"/><asula kood="4776" nimi="Manniva k??la"/><asula kood="5389" nimi="Neeme k??la"/><asula kood="5400" nimi="Nehatu k??la"/><asula kood="5997" nimi="Parasm??e k??la"/><asula kood="6785" nimi="Rammu k??la"/><asula kood="6882" nimi="Rebala k??la"/><asula kood="7037" nimi="Rohusi k??la"/><asula kood="7141" nimi="Ruu k??la"/><asula kood="7335" nimi="Saha k??la"/><asula kood="7405" nimi="Sambu k??la"/><asula kood="7498" nimi="Saviranna k??la"/><asula kood="8783" nimi="Uusk??la"/><asula kood="9041" nimi="Vandjala k??la"/><asula kood="9491" nimi="V??erdla k??la"/><asula kood="9838" nimi="??lgase k??la"/></vald><vald kood="0296" nimi="Keila linn"/><vald kood="0304" nimi="Kiili vald"><asula kood="1388" nimi="Arusta k??la"/><asula kood="2671" nimi="Kangru alevik"/><asula kood="3039" nimi="Kiili alev"/><asula kood="3656" nimi="Kurevere k??la"/><asula kood="4550" nimi="Luige alevik"/><asula kood="4633" nimi="L??htse k??la"/><asula kood="4902" nimi="Metsanurga k??la"/><asula kood="5125" nimi="M??isak??la"/><asula kood="5329" nimi="Nabala k??la"/><asula kood="5824" nimi="Paekna k??la"/><asula kood="6198" nimi="Piissoo k??la"/><asula kood="7472" nimi="Sausti k??la"/><asula kood="7701" nimi="Sookaera k??la"/><asula kood="7880" nimi="S??gula k??la"/><asula kood="7894" nimi="S??meru k??la"/><asula kood="8824" nimi="Vaela k??la"/></vald><vald kood="0338" nimi="Kose vald"><asula kood="1089" nimi="Aela k??la"/><asula kood="1113" nimi="Ahisilla k??la"/><asula kood="1174" nimi="Alansi k??la"/><asula kood="1340" nimi="Ardu alevik"/><asula kood="1708" nimi="Habaja alevik"/><asula kood="1779" nimi="Harmi k??la"/><asula kood="2485" nimi="Kadja k??la"/><asula kood="2657" nimi="Kanavere k??la"/><asula kood="2690" nimi="Kantk??la"/><asula kood="2764" nimi="Karla k??la"/><asula kood="2848" nimi="Kata k??la"/><asula kood="2852" nimi="Katsina k??la"/><asula kood="3140" nimi="Kirivalla k??la"/><asula kood="3156" nimi="Kiruvere k??la"/><asula kood="3363" nimi="Kolu k??la"/><asula kood="3460" nimi="Kose alevik"/><asula kood="3464" nimi="Kose-Uuem??isa alevik"/><asula kood="3492" nimi="Krei k??la"/><asula kood="3546" nimi="Kuivaj??e k??la"/><asula kood="3553" nimi="Kukepala k??la"/><asula kood="3829" nimi="K??rvenurga k??la"/><asula kood="3834" nimi="K??ue k??la"/><asula kood="4020" nimi="Laane k??la"/><asula kood="4242" nimi="Leistu k??la"/><asula kood="4352" nimi="Liiva k??la"/><asula kood="4577" nimi="Lutsu k??la"/><asula kood="4667" nimi="L????ra k??la"/><asula kood="4788" nimi="Marguse k??la"/><asula kood="5485" nimi="Nutu k??la"/><asula kood="5506" nimi="N??mbra k??la"/><asula kood="5518" nimi="N??mmeri k??la"/><asula kood="5537" nimi="N??rava k??la"/><asula kood="5656" nimi="Ojasoo k??la"/><asula kood="5738" nimi="Oru k??la"/><asula kood="5907" nimi="Pala k??la"/><asula kood="5962" nimi="Palvere k??la"/><asula kood="6052" nimi="Paunaste k??la"/><asula kood="6053" nimi="Paunk??la"/><asula kood="6483" nimi="Puusepa k??la"/><asula kood="6869" nimi="Rava k??la"/><asula kood="6872" nimi="Raveliku k??la"/><asula kood="6875" nimi="Ravila alevik"/><asula kood="6981" nimi="Riidam??e k??la"/><asula kood="7191" nimi="R????sa k??la"/><asula kood="7308" nimi="Saarnak??rve k??la"/><asula kood="7324" nimi="Sae k??la"/><asula kood="7457" nimi="Saula k??la"/><asula kood="7597" nimi="Silmsi k??la"/><asula kood="7891" nimi="S??meru k??la"/><asula kood="7963" nimi="S????sk??la"/><asula kood="8022" nimi="Tade k??la"/><asula kood="8112" nimi="Tammiku k??la"/><asula kood="8346" nimi="Triigi k??la"/><asula kood="8396" nimi="Tuhala k??la"/><asula kood="8773" nimi="Uueveski k??la"/><asula kood="8847" nimi="Vahet??ki k??la"/><asula kood="9032" nimi="Vanam??isa k??la"/><asula kood="9071" nimi="Vardja k??la"/><asula kood="9323" nimi="Vilama k??la"/><asula kood="9385" nimi="Virla k??la"/><asula kood="9417" nimi="Viskla k??la"/><asula kood="9558" nimi="V??lle k??la"/><asula kood="9749" nimi="??ksi k??la"/></vald><vald kood="0353" nimi="Kuusalu vald"><asula kood="1202" nimi="Allika k??la"/><asula kood="1256" nimi="Andineeme k??la"/><asula kood="1363" nimi="Aru k??la"/><asula kood="1701" nimi="Haavakannu k??la"/><asula kood="1761" nimi="Hara k??la"/><asula kood="1877" nimi="Hirvli k??la"/><asula kood="2046" nimi="Ilmastalu k??la"/><asula kood="2194" nimi="Joaveski k??la"/><asula kood="2209" nimi="Juminda k??la"/><asula kood="2450" nimi="Kaberla k??la"/><asula kood="2509" nimi="Kahala k??la"/><asula kood="2629" nimi="Kalme k??la"/><asula kood="2804" nimi="Kasispea k??la"/><asula kood="2949" nimi="Kemba k??la"/><asula kood="3056" nimi="Kiiu alevik"/><asula kood="3055" nimi="Kiiu-Aabla k??la"/><asula kood="3232" nimi="Kodasoo k??la"/><asula kood="3300" nimi="Koitj??rve k??la"/><asula kood="3336" nimi="Kolga alevik"/><asula kood="1007" nimi="Kolga-Aabla k??la"/><asula kood="3343" nimi="Kolgak??la"/><asula kood="3342" nimi="Kolgu k??la"/><asula kood="3474" nimi="Kosu k??la"/><asula kood="3480" nimi="Kotka k??la"/><asula kood="3630" nimi="Kupu k??la"/><asula kood="3691" nimi="Kursi k??la"/><asula kood="3714" nimi="Kuusalu alevik"/><asula kood="3718" nimi="Kuusalu k??la"/><asula kood="3768" nimi="K??nnu k??la"/><asula kood="3993" nimi="K??lmaallika k??la"/><asula kood="4188" nimi="Leesi k??la"/><asula kood="4334" nimi="Liiapeksi k??la"/><asula kood="4471" nimi="Loksa k??la"/><asula kood="5048" nimi="Murksi k??la"/><asula kood="5064" nimi="Mustametsa k??la"/><asula kood="5108" nimi="Muuksi k??la"/><asula kood="5208" nimi="M??epea k??la"/><asula kood="5533" nimi="N??mmeveski k??la"/><asula kood="5901" nimi="Pala k??la"/><asula kood="6016" nimi="Parksi k??la"/><asula kood="6065" nimi="Pedaspea k??la"/><asula kood="6378" nimi="Pudisoo k??la"/><asula kood="6497" nimi="P??hja k??la"/><asula kood="6606" nimi="P??rispea k??la"/><asula kood="6898" nimi="Rehatse k??la"/><asula kood="7122" nimi="Rummu k??la"/><asula kood="7390" nimi="Salmistu k??la"/><asula kood="7466" nimi="Saunja k??la"/><asula kood="7562" nimi="Sigula k??la"/><asula kood="7734" nimi="Soorinna k??la"/><asula kood="7809" nimi="Suru k??la"/><asula kood="7866" nimi="Suurpea k??la"/><asula kood="7882" nimi="S??itme k??la"/><asula kood="8118" nimi="Tammispea k??la"/><asula kood="8125" nimi="Tammistu k??la"/><asula kood="8144" nimi="Tapurla k??la"/><asula kood="8367" nimi="Tsitre k??la"/><asula kood="8424" nimi="Turbuneeme k??la"/><asula kood="8193" nimi="T??reska k??la"/><asula kood="8782" nimi="Uuri k??la"/><asula kood="8839" nimi="Vahastu k??la"/><asula kood="8919" nimi="Valgej??e k??la"/><asula kood="8954" nimi="Valkla k??la"/><asula kood="9014" nimi="Vanak??la"/><asula kood="9257" nimi="Vihasoo k??la"/><asula kood="9283" nimi="Viinistu k??la"/><asula kood="9411" nimi="Virve k??la"/></vald><vald kood="0424" nimi="Loksa linn"/><vald kood="0431" nimi="L????ne-Harju vald"><asula kood="1208" nimi="Alliklepa k??la"/><asula kood="1221" nimi="Altk??la"/><asula kood="1450" nimi="Audev??lja k??la"/><asula kood="1771" nimi="Harju-Risti k??la"/><asula kood="1782" nimi="Hatu k??la"/><asula kood="2045" nimi="Illurma k??la"/><asula kood="2731" nimi="Karilepa k??la"/><asula kood="2749" nimi="Karjak??la alevik"/><asula kood="2797" nimi="Kasepere k??la"/><asula kood="2909" nimi="Keelva k??la"/><asula kood="2927" nimi="Keibu k??la"/><asula kood="2930" nimi="Keila-Joa alevik"/><asula kood="2978" nimi="Kersalu k??la"/><asula kood="3205" nimi="Klooga alevik"/><asula kood="3207" nimi="Kloogaranna k??la"/><asula kood="3224" nimi="Kobru k??la"/><asula kood="3603" nimi="Kulna k??la"/><asula kood="3682" nimi="Kurkse k??la"/><asula kood="3762" nimi="K??mmaste k??la"/><asula kood="3857" nimi="K??esalu k??la"/><asula kood="4019" nimi="Laane k??la"/><asula kood="4096" nimi="Langa k??la"/><asula kood="4112" nimi="Laok??la"/><asula kood="4148" nimi="Laulasmaa k??la"/><asula kood="4211" nimi="Lehola k??la"/><asula kood="4263" nimi="Lemmaru k??la"/><asula kood="4456" nimi="Lohusalu k??la"/><asula kood="4722" nimi="Madise k??la"/><asula kood="4725" nimi="Maeru k??la"/><asula kood="4876" nimi="Merem??isa k??la"/><asula kood="4931" nimi="Metsl??ugu k??la"/><asula kood="5290" nimi="M????ra k??la"/><asula kood="5343" nimi="Nahkjala k??la"/><asula kood="5424" nimi="Niitv??lja k??la"/><asula kood="5628" nimi="Ohtu k??la"/><asula kood="5812" nimi="Padise k??la"/><asula kood="5821" nimi="Pae k??la"/><asula kood="5925" nimi="Paldiski linn"/><asula kood="6062" nimi="Pedase k??la"/><asula kood="6528" nimi="P??llk??la"/><asula kood="7121" nimi="Rummu alevik"/><asula kood="7856" nimi="Suurk??la"/><asula kood="8460" nimi="Tuulna k??la"/><asula kood="8499" nimi="T??mmiku k??la"/><asula kood="8956" nimi="Valkse k??la"/><asula kood="9101" nimi="Vasalemma alevik"/><asula kood="9231" nimi="Veskik??la"/><asula kood="9265" nimi="Vihterpalu k??la"/><asula kood="9339" nimi="Vilivalla k??la"/><asula kood="9380" nimi="Vintse k??la"/><asula kood="9752" nimi="??mari alevik"/><asula kood="9767" nimi="??nglema k??la"/></vald><vald kood="0446" nimi="Maardu linn"/><vald kood="0651" nimi="Raasiku vald"><asula kood="1373" nimi="Aruk??la alevik"/><asula kood="1954" nimi="H??rma k??la"/><asula kood="1994" nimi="Igavere k??la"/><asula kood="2335" nimi="J??rsi k??la"/><asula kood="2575" nimi="Kalesi k??la"/><asula kood="3183" nimi="Kiviloo k??la"/><asula kood="3597" nimi="Kulli k??la"/><asula kood="3668" nimi="Kurgla k??la"/><asula kood="4758" nimi="Mallavere k??la"/><asula kood="6098" nimi="Peningi k??la"/><asula kood="6122" nimi="Perila k??la"/><asula kood="6228" nimi="Pikavere k??la"/><asula kood="6694" nimi="Raasiku alevik"/><asula kood="7226" nimi="R??tla k??la"/><asula kood="8477" nimi="T??helgi k??la"/></vald><vald kood="0653" nimi="Rae vald"><asula kood="1050" nimi="Aaviku k??la"/><asula kood="1391" nimi="Aruvalla k??la"/><asula kood="1408" nimi="Assaku alevik"/><asula kood="2353" nimi="J??rvek??la"/><asula kood="2377" nimi="J??ri alevik"/><asula kood="2474" nimi="Kadaka k??la"/><asula kood="2763" nimi="Karla k??la"/><asula kood="2885" nimi="Kautjala k??la"/><asula kood="3435" nimi="Kopli k??la"/><asula kood="3687" nimi="Kurna k??la"/><asula kood="4043" nimi="Lagedi alevik"/><asula kood="4208" nimi="Lehmja k??la"/><asula kood="4378" nimi="Limu k??la"/><asula kood="5891" nimi="Pajupea k??la"/><asula kood="6036" nimi="Patika k??la"/><asula kood="6086" nimi="Peetri alevik"/><asula kood="6240" nimi="Pildik??la"/><asula kood="6713" nimi="Rae k??la"/><asula kood="7392" nimi="Salu k??la"/><asula kood="7517" nimi="Seli k??la"/><asula kood="7688" nimi="Soodevahe k??la"/><asula kood="7852" nimi="Suuresta k??la"/><asula kood="7868" nimi="Suursoo k??la"/><asula kood="8454" nimi="Tuulev??lja k??la"/><asula kood="8731" nimi="Urvaste k??la"/><asula kood="8774" nimi="Uuesalu k??la"/><asula kood="8867" nimi="Vaida alevik"/><asula kood="8869" nimi="Vaidasoo k??la"/><asula kood="9108" nimi="Vaskjala k??la"/><asula kood="9202" nimi="Venek??la"/><asula kood="9236" nimi="Veskitaguse k??la"/><asula kood="9832" nimi="??lej??e k??la"/></vald><vald kood="0718" nimi="Saku vald"><asula kood="2220" nimi="Juuliku k??la"/><asula kood="2307" nimi="J??lgim??e k??la"/><asula kood="2552" nimi="Kajamaa k??la"/><asula kood="2794" nimi="Kasemetsa k??la"/><asula kood="3048" nimi="Kiisa alevik"/><asula kood="3119" nimi="Kirdalu k??la"/><asula kood="3697" nimi="Kurtna k??la"/><asula kood="4481" nimi="Lokuti k??la"/><asula kood="4912" nimi="Metsanurme k??la"/><asula kood="5261" nimi="M??nniku k??la"/><asula kood="6739" nimi="Rahula k??la"/><asula kood="7056" nimi="Roobuka k??la"/><asula kood="7361" nimi="Saku alevik"/><asula kood="2652" nimi="Saue k??la"/><asula kood="7469" nimi="Saustin??mme k??la"/><asula kood="7704" nimi="Sookaera-Metsanurga k??la"/><asula kood="8033" nimi="Tagadi k??la"/><asula kood="8096" nimi="Tammej??rve k??la"/><asula kood="8098" nimi="Tammem??e k??la"/><asula kood="8472" nimi="T??dva k??la"/><asula kood="8572" nimi="T??nassilma k??la"/><asula kood="9820" nimi="??ksnurme k??la"/></vald><vald kood="0726" nimi="Saue vald"><asula kood="1141" nimi="Aila k??la"/><asula kood="1206" nimi="Allika k??la"/><asula kood="1216" nimi="Alliku k??la"/><asula kood="1449" nimi="Aude k??la"/><asula kood="1585" nimi="Ellamaa k??la"/><asula kood="1720" nimi="Haiba k??la"/><asula kood="1854" nimi="Hingu k??la"/><asula kood="1975" nimi="H????ru k??la"/><asula kood="2135" nimi="Jaanika k??la"/><asula kood="2267" nimi="J??gisoo k??la"/><asula kood="2427" nimi="Kaasiku k??la"/><asula kood="2455" nimi="Kabila k??la"/><asula kood="2976" nimi="Kernu k??la"/><asula kood="3001" nimi="Kibuna k??la"/><asula kood="3025" nimi="Kiia k??la"/><asula kood="3120" nimi="Kirikla k??la"/><asula kood="3195" nimi="Kivitammi k??la"/><asula kood="3266" nimi="Kohatu k??la"/><asula kood="3285" nimi="Koidu k??la"/><asula kood="3439" nimi="Koppelmaa k??la"/><asula kood="3705" nimi="Kustja k??la"/><asula kood="4014" nimi="Laagri alevik"/><asula kood="4075" nimi="Laitse k??la"/><asula kood="4206" nimi="Lehetu k??la"/><asula kood="4289" nimi="Lepaste k??la"/><asula kood="4717" nimi="Madila k??la"/><asula kood="4739" nimi="Maidla k??la"/><asula kood="4903" nimi="Metsanurga k??la"/><asula kood="5028" nimi="Munalaskme k??la"/><asula kood="5093" nimi="Mustu k??la"/><asula kood="5110" nimi="Muusika k??la"/><asula kood="5157" nimi="M??nuste k??la"/><asula kood="5467" nimi="Nurme k??la"/><asula kood="5601" nimi="Odulemma k??la"/><asula kood="6308" nimi="Pohla k??la"/><asula kood="6588" nimi="P??llu k??la"/><asula kood="6603" nimi="P??rinurme k??la"/><asula kood="6652" nimi="P??ha k??la"/><asula kood="6989" nimi="Riisipere alevik"/><asula kood="7110" nimi="Ruila k??la"/><asula kood="7453" nimi="Saue linn"/><asula kood="7571" nimi="Siimika k??la"/><asula kood="8006" nimi="Tabara k??la"/><asula kood="8045" nimi="Tagametsa k??la"/><asula kood="8421" nimi="Turba alevik"/><asula kood="8450" nimi="Tuula k??la"/><asula kood="8946" nimi="Valingu k??la"/><asula kood="9033" nimi="Vanam??isa k??la"/><asula kood="9049" nimi="Vansi k??la"/><asula kood="9146" nimi="Vatsla k??la"/><asula kood="9362" nimi="Vilum??e k??la"/><asula kood="9401" nimi="Viruk??la"/><asula kood="9794" nimi="????sm??e k??la"/><asula kood="9846" nimi="??rjaste k??la"/></vald><vald kood="0784" nimi="Tallinn"><asula kood="0176" nimi="Haabersti linnaosa"/><asula kood="0298" nimi="Kesklinna linnaosa"/><asula kood="0339" nimi="Kristiine linnaosa"/><asula kood="0387" nimi="Lasnam??e linnaosa"/><asula kood="0482" nimi="Mustam??e linnaosa"/><asula kood="0524" nimi="N??mme linnaosa"/><asula kood="0596" nimi="Pirita linnaosa"/><asula kood="0614" nimi="P??hja-Tallinna linnaosa"/></vald><vald kood="0890" nimi="Viimsi vald"><asula kood="1675" nimi="Haabneeme alevik"/><asula kood="1984" nimi="Idaotsa k??la"/><asula kood="2944" nimi="Kelnase k??la"/><asula kood="2945" nimi="Kelvingi k??la"/><asula kood="4064" nimi="Laiak??la"/><asula kood="4299" nimi="Leppneeme k??la"/><asula kood="4534" nimi="Lubja k??la"/><asula kood="4618" nimi="L??unak??la / Storbyn"/><asula kood="4656" nimi="L????neotsa k??la"/><asula kood="4887" nimi="Metsakasti k??la"/><asula kood="4943" nimi="Miiduranna k??la"/><asula kood="5104" nimi="Muuga k??la"/><asula kood="6370" nimi="Pringi k??la"/><asula kood="6613" nimi="P??rnam??e k??la"/><asula kood="6672" nimi="P????nsi k??la"/><asula kood="6797" nimi="Randvere k??la"/><asula kood="7039" nimi="Rohuneeme k??la"/><asula kood="8039" nimi="Tagak??la / Bakbyn"/><asula kood="8126" nimi="Tammneeme k??la"/><asula kood="9280" nimi="Viimsi alevik"/><asula kood="9619" nimi="V??ikeheinamaa k??la / Lill??ngin"/><asula kood="9744" nimi="??igrum??e k??la"/></vald></maakond><maakond kood="0039" nimi="Hiiu maakond"><vald kood="0205" nimi="Hiiumaa vald"><asula kood="1013" nimi="Aadma k??la"/><asula kood="1157" nimi="Ala k??la"/><asula kood="1200" nimi="Allika k??la"/><asula kood="1374" nimi="Aruk??la"/><asula kood="1589" nimi="Emmaste k??la"/><asula kood="1587" nimi="Emmaste-Kurisu k??la"/><asula kood="1588" nimi="Emmaste-Selja k??la"/><asula kood="1647" nimi="Esik??la"/><asula kood="1713" nimi="Hagaste k??la"/><asula kood="1734" nimi="Haldi k??la"/><asula kood="1732" nimi="Haldreka k??la"/><asula kood="1769" nimi="Harju k??la"/><asula kood="1787" nimi="Hausma k??la"/><asula kood="1788" nimi="Heigi k??la"/><asula kood="1801" nimi="Heiste k??la"/><asula kood="1800" nimi="Heistesoo k??la"/><asula kood="1807" nimi="Hellamaa k??la"/><asula kood="1818" nimi="Heltermaa k??la"/><asula kood="1835" nimi="Hiiessaare k??la"/><asula kood="1841" nimi="Hilleste k??la"/><asula kood="1851" nimi="Hindu k??la"/><asula kood="1873" nimi="Hirmuste k??la"/><asula kood="1952" nimi="H??rma k??la"/><asula kood="1971" nimi="H??ti k??la"/><asula kood="2109" nimi="Isabella k??la"/><asula kood="2180" nimi="Jausa k??la"/><asula kood="2227" nimi="J??ek??la"/><asula kood="2247" nimi="J??eranna k??la"/><asula kood="2250" nimi="J??esuu k??la"/><asula kood="2428" nimi="Kaasiku k??la"/><asula kood="2467" nimi="Kabuna k??la"/><asula kood="2481" nimi="Kaderna k??la"/><asula kood="2533" nimi="Kaigutsi k??la"/><asula kood="2561" nimi="Kalana k??la"/><asula kood="2577" nimi="Kaleste k??la"/><asula kood="2578" nimi="Kalgi k??la"/><asula kood="2650" nimi="Kanapeeksi k??la"/><asula kood="2807" nimi="Kassari k??la"/><asula kood="2881" nimi="Kauste k??la"/><asula kood="2959" nimi="Kerema k??la"/><asula kood="3004" nimi="Kidaste k??la"/><asula kood="3009" nimi="Kiduspe k??la"/><asula kood="3054" nimi="Kiivera k??la"/><asula kood="3160" nimi="Kitsa k??la"/><asula kood="3196" nimi="Kleemu k??la"/><asula kood="3235" nimi="Kodeste k??la"/><asula kood="3253" nimi="Kogri k??la"/><asula kood="3271" nimi="Koidma k??la"/><asula kood="3337" nimi="Kolga k??la"/><asula kood="3433" nimi="Kopa k??la"/><asula kood="3557" nimi="Kukka k??la"/><asula kood="3671" nimi="Kuri k??la"/><asula kood="3680" nimi="Kuriste k??la"/><asula kood="3679" nimi="Kurisu k??la"/><asula kood="3717" nimi="Kuusiku k??la"/><asula kood="3759" nimi="K??lun??mme k??la"/><asula kood="3760" nimi="K??mmusselja k??la"/><asula kood="3781" nimi="K??pu k??la"/><asula kood="3795" nimi="K??rgessaare alevik"/><asula kood="3869" nimi="K??ina alevik"/><asula kood="3895" nimi="K??rdla linn"/><asula kood="3893" nimi="K??rdla-N??mme k??la"/><asula kood="3976" nimi="K??lak??la"/><asula kood="3978" nimi="K??lama k??la"/><asula kood="4025" nimi="Laartsa k??la"/><asula kood="4023" nimi="Laasi k??la"/><asula kood="4056" nimi="Lahek??la"/><asula kood="4128" nimi="Lassi k??la"/><asula kood="4141" nimi="Lauka k??la"/><asula kood="4184" nimi="Leerimetsa k??la"/><asula kood="4209" nimi="Lehtma k??la"/><asula kood="4223" nimi="Leigri k??la"/><asula kood="4245" nimi="Leisu k??la"/><asula kood="4253" nimi="Lelu k??la"/><asula kood="4290" nimi="Lepiku k??la"/><asula kood="4319" nimi="Ligema k??la"/><asula kood="4371" nimi="Lilbi k??la"/><asula kood="4402" nimi="Linnum??e k??la"/><asula kood="4465" nimi="Loja k??la"/><asula kood="4537" nimi="Luguse k??la"/><asula kood="4546" nimi="Luidja k??la"/><asula kood="4590" nimi="L??bembe k??la"/><asula kood="4612" nimi="L??pe k??la"/><asula kood="4765" nimi="Malvaste k??la"/><asula kood="4766" nimi="Mangu k??la"/><asula kood="4780" nimi="Mardihansu k??la"/><asula kood="4844" nimi="Meelste k??la"/><asula kood="4890" nimi="Metsak??la"/><asula kood="4898" nimi="Metsalauka k??la"/><asula kood="4910" nimi="Metsapere k??la"/><asula kood="4966" nimi="Moka k??la"/><asula kood="4993" nimi="Muda k??la"/><asula kood="4995" nimi="Mudaste k??la"/><asula kood="5183" nimi="M??ek??la"/><asula kood="5203" nimi="M??eltse k??la"/><asula kood="5224" nimi="M??gipe k??la"/><asula kood="5258" nimi="M??nnamaa k??la"/><asula kood="5272" nimi="M??nspe k??la"/><asula kood="5298" nimi="M????vli k??la"/><asula kood="5350" nimi="Napi k??la"/><asula kood="5360" nimi="Nasva k??la"/><asula kood="5412" nimi="Niidik??la"/><asula kood="5479" nimi="Nurste k??la"/><asula kood="5503" nimi="N??mba k??la"/><asula kood="5512" nimi="N??mme k??la"/><asula kood="5514" nimi="N??mmerga k??la"/><asula kood="5613" nimi="Ogandi k??la"/><asula kood="5649" nimi="Ojak??la"/><asula kood="5654" nimi="Ole k??la"/><asula kood="5728" nimi="Orjaku k??la"/><asula kood="5767" nimi="Otste k??la"/><asula kood="5908" nimi="Palade k??la"/><asula kood="5932" nimi="Palli k??la"/><asula kood="5946" nimi="Paluk??la"/><asula kood="5978" nimi="Paope k??la"/><asula kood="6024" nimi="Partsi k??la"/><asula kood="6145" nimi="Pihla k??la"/><asula kood="6258" nimi="Pilpak??la"/><asula kood="6297" nimi="Poama k??la"/><asula kood="6357" nimi="Prassi k??la"/><asula kood="6373" nimi="Pr??hlam??e k??la"/><asula kood="6372" nimi="Pr??hnu k??la"/><asula kood="6419" nimi="Puliste k??la"/><asula kood="6459" nimi="Puski k??la"/><asula kood="6460" nimi="Putkaste k??la"/><asula kood="6609" nimi="P??rna k??la"/><asula kood="6615" nimi="P??rnselja k??la"/><asula kood="6661" nimi="P??halepa k??la"/><asula kood="6660" nimi="P??halepa-Harju k??la"/><asula kood="6801" nimi="Rannak??la"/><asula kood="6903" nimi="Reheselja k??la"/><asula kood="6908" nimi="Reigi k??la"/><asula kood="6909" nimi="Reigi-N??mme k??la"/><asula kood="6910" nimi="Reikama k??la"/><asula kood="6972" nimi="Riidak??la"/><asula kood="7009" nimi="Risti k??la"/><asula kood="7014" nimi="Ristiv??lja k??la"/><asula kood="7084" nimi="Rootsi k??la"/><asula kood="7349" nimi="Sakla k??la"/><asula kood="7382" nimi="Salin??mme k??la"/><asula kood="7438" nimi="Sarve k??la"/><asula kood="7528" nimi="Selja k??la"/><asula kood="7548" nimi="Sepaste k??la"/><asula kood="7554" nimi="Sigala k??la"/><asula kood="7616" nimi="Sinima k??la"/><asula kood="7728" nimi="Soonlepa k??la"/><asula kood="7846" nimi="Suurem??isa k??la"/><asula kood="7848" nimi="Suurepsi k??la"/><asula kood="7850" nimi="Suureranna k??la"/><asula kood="7864" nimi="Suuresadama k??la"/><asula kood="7900" nimi="S??ru k??la"/><asula kood="7949" nimi="S????re k??la"/><asula kood="7972" nimi="S??lluste k??la"/><asula kood="8061" nimi="Taguk??la"/><asula kood="8067" nimi="Tahkuna k??la"/><asula kood="8095" nimi="Tammela k??la"/><asula kood="8122" nimi="Tammistu k??la"/><asula kood="8150" nimi="Tareste k??la"/><asula kood="8162" nimi="Taterma k??la"/><asula kood="8190" nimi="Tempa k??la"/><asula kood="8209" nimi="Tiharu k??la"/><asula kood="8236" nimi="Tilga k??la"/><asula kood="8271" nimi="Tohvri k??la"/><asula kood="8382" nimi="Tubala k??la"/><asula kood="8576" nimi="T??rkma k??la"/><asula kood="8656" nimi="Ulja k??la"/><asula kood="8682" nimi="Undama k??la"/><asula kood="8747" nimi="Utu k??la"/><asula kood="8827" nimi="Vaemla k??la"/><asula kood="8853" nimi="Vahtrepa k??la"/><asula kood="8938" nimi="Valgu k??la"/><asula kood="8949" nimi="Valipe k??la"/><asula kood="9019" nimi="Vanam??isa k??la"/><asula kood="9278" nimi="Viilupi k??la"/><asula kood="9295" nimi="Viiri k??la"/><asula kood="9303" nimi="Viita k??la"/><asula kood="9306" nimi="Viitasoo k??la"/><asula kood="9327" nimi="Vilima k??la"/><asula kood="9338" nimi="Vilivalla k??la"/><asula kood="9349" nimi="Villamaa k??la"/><asula kood="8911" nimi="Villemi k??la"/><asula kood="9674" nimi="V??rssu k??la"/><asula kood="9703" nimi="??ngu k??la"/><asula kood="9816" nimi="??htri k??la"/><asula kood="9826" nimi="??lendi k??la"/></vald></maakond><maakond kood="0045" nimi="Ida-Viru maakond"><vald kood="0130" nimi="Alutaguse vald"><asula kood="1103" nimi="Agusalu k??la"/><asula kood="1165" nimi="Alaj??e k??la"/><asula kood="1211" nimi="Alliku k??la"/><asula kood="1310" nimi="Apandiku k??la"/><asula kood="1377" nimi="Aruk??la"/><asula kood="1398" nimi="Arvila k??la"/><asula kood="1443" nimi="Atsalama k??la"/><asula kood="1526" nimi="Edivere k??la"/><asula kood="1623" nimi="Ereda k??la"/><asula kood="2025" nimi="Iisaku alevik"/><asula kood="2042" nimi="Illuka k??la"/><asula kood="2071" nimi="Imatu k??la"/><asula kood="2130" nimi="Jaama k??la"/><asula kood="2249" nimi="J??etaguse k??la"/><asula kood="2281" nimi="J??uga k??la"/><asula kood="2431" nimi="Kaatermu k??la"/><asula kood="2528" nimi="Kaidma k??la"/><asula kood="2586" nimi="Kalina k??la"/><asula kood="2639" nimi="Kamarna k??la"/><asula kood="2752" nimi="Karjamaa k??la"/><asula kood="2767" nimi="Karoli k??la"/><asula kood="2802" nimi="Kasev??lja k??la"/><asula kood="2850" nimi="Katase k??la"/><asula kood="2868" nimi="Kauksi k??la"/><asula kood="2939" nimi="Kellassaare k??la"/><asula kood="3035" nimi="Kiikla k??la"/><asula kood="3190" nimi="Kivin??mme k??la"/><asula kood="3331" nimi="Koldam??e k??la"/><asula kood="3377" nimi="Konsu k??la"/><asula kood="3621" nimi="Kuningak??la"/><asula kood="3644" nimi="Kurem??e k??la"/><asula kood="3696" nimi="Kurtna k??la"/><asula kood="3700" nimi="Kuru k??la"/><asula kood="4258" nimi="Lemmaku k??la"/><asula kood="4374" nimi="Liivak??nka k??la"/><asula kood="4418" nimi="Lipniku k??la"/><asula kood="4610" nimi="L??pe k??la"/><asula kood="4923" nimi="Metsk??la"/><asula kood="5213" nimi="M??etaguse alevik"/><asula kood="5217" nimi="M??etaguse k??la"/><asula kood="5615" nimi="Ohakvere k??la"/><asula kood="5677" nimi="Ongassaare k??la"/><asula kood="5695" nimi="Oonurme k??la"/><asula kood="5841" nimi="Pagari k??la"/><asula kood="6117" nimi="Peressaare k??la"/><asula kood="6127" nimi="Permisk??la"/><asula kood="6224" nimi="Pikati k??la"/><asula kood="6327" nimi="Pootsiku k??la"/><asula kood="6391" nimi="Puhatu k??la"/><asula kood="6767" nimi="Rajak??la"/><asula kood="6816" nimi="Rannapungerja k??la"/><asula kood="6844" nimi="Ratva k??la"/><asula kood="6866" nimi="Rausvere k??la"/><asula kood="6927" nimi="Remniku k??la"/><asula kood="7086" nimi="Roostoja k??la"/><asula kood="7337" nimi="Sahargu k??la"/><asula kood="7649" nimi="Smolnitsa k??la"/><asula kood="7902" nimi="S??rum??e k??la"/><asula kood="7924" nimi="S??lliku k??la"/><asula kood="1534" nimi="Taga-Roostoja k??la"/><asula kood="8035" nimi="Tagaj??e k??la"/><asula kood="8104" nimi="Tammetaguse k??la"/><asula kood="8147" nimi="Tarakuse k??la"/><asula kood="8393" nimi="Tudulinna alevik"/><asula kood="8578" nimi="T??rivere k??la"/><asula kood="8624" nimi="Uhe k??la"/><asula kood="8786" nimi="Uusk??la"/><asula kood="8874" nimi="Vaikla k??la"/><asula kood="9075" nimi="Varesmetsa k??la"/><asula kood="9106" nimi="Vasavere k??la"/><asula kood="9111" nimi="Vasknarva k??la"/><asula kood="9494" nimi="V??hma k??la"/><asula kood="9516" nimi="V??ide k??la"/><asula kood="9580" nimi="V??rnu k??la"/><asula kood="9631" nimi="V??ike-Pungerja k??la"/></vald><vald kood="0251" nimi="J??hvi vald"><asula kood="1524" nimi="Edise k??la"/><asula kood="2271" nimi="J??hvi k??la"/><asula kood="2270" nimi="J??hvi linn"/><asula kood="2520" nimi="Kahula k??la"/><asula kood="3461" nimi="Kose k??la"/><asula kood="3477" nimi="Kotinuka k??la"/><asula kood="4389" nimi="Linna k??la"/><asula kood="5884" nimi="Pajualuse k??la"/><asula kood="5999" nimi="Pargitaguse k??la"/><asula kood="6050" nimi="Pauliku k??la"/><asula kood="6455" nimi="Puru k??la"/><asula kood="7677" nimi="Sompa k??la"/><asula kood="8114" nimi="Tammiku alevik"/></vald><vald kood="0321" nimi="Kohtla-J??rve linn"><asula kood="0120" nimi="Ahtme linnaosa"/><asula kood="0265" nimi="J??rve linnaosa"/><asula kood="0340" nimi="Kukruse linnaosa"/><asula kood="0553" nimi="Oru linnaosa"/><asula kood="0747" nimi="Sompa linnaosa"/></vald><vald kood="0442" nimi="L??ganuse vald"><asula kood="1004" nimi="Aa k??la"/><asula kood="1132" nimi="Aidu k??la"/><asula kood="1139" nimi="Aidu-Liiva k??la"/><asula kood="1133" nimi="Aidu-N??mme k??la"/><asula kood="1140" nimi="Aidu-Sook??la"/><asula kood="1368" nimi="Aruk??la"/><asula kood="1382" nimi="Arup????lse k??la"/><asula kood="1393" nimi="Aruv??lja k??la"/><asula kood="1631" nimi="Erra alevik"/><asula kood="1629" nimi="Erra-Liiva k??la"/><asula kood="1871" nimi="Hirmuse k??la"/><asula kood="2051" nimi="Ilmaste k??la"/><asula kood="2105" nimi="Irvala k??la"/><asula kood="2150" nimi="Jabara k??la"/><asula kood="3194" nimi="Kivi??li linn"/><asula kood="3348" nimi="Koljala k??la"/><asula kood="3404" nimi="Koolma k??la"/><asula kood="3436" nimi="Kopli k??la"/><asula kood="3576" nimi="Kulja k??la"/><asula kood="4347" nimi="Liimala k??la"/><asula kood="4419" nimi="Lipu k??la"/><asula kood="4449" nimi="Lohkuse k??la"/><asula kood="4669" nimi="L??ganuse alevik"/><asula kood="4688" nimi="L??matu k??la"/><asula kood="4740" nimi="Maidla k??la"/><asula kood="4819" nimi="Matka k??la"/><asula kood="4857" nimi="Mehide k??la"/><asula kood="4975" nimi="Moldova k??la"/><asula kood="5088" nimi="Mustm??tta k??la"/><asula kood="5569" nimi="N??ri k??la"/><asula kood="5574" nimi="Oandu k??la"/><asula kood="5652" nimi="Ojamaa k??la"/><asula kood="6172" nimi="Piilse k??la"/><asula kood="6450" nimi="Purtse k??la"/><asula kood="6671" nimi="P??ssi linn"/><asula kood="6894" nimi="Rebu k??la"/><asula kood="7245" nimi="R????sa k??la"/><asula kood="7371" nimi="Salak??la"/><asula kood="7447" nimi="Satsu k??la"/><asula kood="7477" nimi="Savala k??la"/><asula kood="7640" nimi="Sirtsi k??la"/><asula kood="7680" nimi="Sonda alevik"/><asula kood="7735" nimi="Soonurme k??la"/><asula kood="8154" nimi="Tarumaa k??la"/><asula kood="8660" nimi="Uljaste k??la"/><asula kood="8691" nimi="Unik??la"/><asula kood="8884" nimi="Vainu k??la"/><asula kood="9005" nimi="Vana-Sonda k??la"/><asula kood="9086" nimi="Varinurme k??la"/><asula kood="9088" nimi="Varja k??la"/><asula kood="9200" nimi="Veneoja k??la"/><asula kood="9406" nimi="Virunurme k??la"/><asula kood="9475" nimi="Voorepera k??la"/></vald><vald kood="0511" nimi="Narva linn"/><vald kood="0514" nimi="Narva-J??esuu linn"><asula kood="1381" nimi="Arum??e k??la"/><asula kood="1472" nimi="Auvere k??la"/><asula kood="1833" nimi="Hiiemetsa k??la"/><asula kood="1908" nimi="Hundinurga k??la"/><asula kood="3520" nimi="Kudruk??la"/><asula kood="4012" nimi="Laagna k??la"/><asula kood="4884" nimi="Merik??la"/><asula kood="5067" nimi="Mustanina k??la"/><asula kood="5356" nimi="Narva-J??esuu linn"/><asula kood="5663" nimi="Olgina alevik"/><asula kood="6084" nimi="Peeterristi k??la"/><asula kood="6125" nimi="Perjatsi k??la"/><asula kood="6265" nimi="Pimestiku k??la"/><asula kood="6396" nimi="Puhkova k??la"/><asula kood="7619" nimi="Sinim??e alevik"/><asula kood="7631" nimi="Sirgala k??la"/><asula kood="7674" nimi="Soldina k??la"/><asula kood="7908" nimi="S??tke k??la"/><asula kood="8530" nimi="T??rvaj??e k??la"/><asula kood="8619" nimi="Udria k??la"/><asula kood="8895" nimi="Vaivara k??la"/><asula kood="9314" nimi="Viivikonna k??la"/><asula kood="9444" nimi="Vodava k??la"/></vald><vald kood="0735" nimi="Sillam??e linn"/><vald kood="0803" nimi="Toila vald"><asula kood="1212" nimi="Altk??la"/><asula kood="1253" nimi="Amula k??la"/><asula kood="2350" nimi="J??rve k??la"/><asula kood="2420" nimi="Kaasikaia k??la"/><asula kood="2429" nimi="Kaasikv??lja k??la"/><asula kood="2448" nimi="Kabelimetsa k??la"/><asula kood="3269" nimi="Kohtla k??la"/><asula kood="3270" nimi="Kohtla-N??mme alev"/><asula kood="3375" nimi="Konju k??la"/><asula kood="3562" nimi="Kukruse k??la"/><asula kood="4799" nimi="Martsa k??la"/><asula kood="4896" nimi="Metsam??gara k??la"/><asula kood="5142" nimi="M??isamaa k??la"/><asula kood="5680" nimi="Ontika k??la"/><asula kood="5793" nimi="Paate k??la"/><asula kood="6081" nimi="Peeri k??la"/><asula kood="6582" nimi="P??ite k??la"/><asula kood="6656" nimi="P??haj??e k??la"/><asula kood="7063" nimi="Roodu k??la"/><asula kood="7348" nimi="Saka k??la"/><asula kood="7551" nimi="Serva????re k??la"/><asula kood="8275" nimi="Toila alevik"/><asula kood="8563" nimi="T??kumetsa k??la"/><asula kood="8647" nimi="Uikala k??la"/><asula kood="8900" nimi="Vaivina k??la"/><asula kood="8914" nimi="Valaste k??la"/><asula kood="9432" nimi="Vitsiku k??la"/><asula kood="9455" nimi="Voka alevik"/><asula kood="9453" nimi="Voka k??la"/></vald></maakond><maakond kood="0050" nimi="J??geva maakond"><vald kood="0247" nimi="J??geva vald"><asula kood="1185" nimi="Alavere k??la"/><asula kood="1533" nimi="Eerikvere k??la"/><asula kood="1543" nimi="Ehavere k??la"/><asula kood="1582" nimi="Ellakvere k??la"/><asula kood="1598" nimi="Endla k??la"/><asula kood="1950" nimi="H??rjanurme k??la"/><asula kood="2079" nimi="Imukvere k??la"/><asula kood="2099" nimi="Iravere k??la"/><asula kood="2261" nimi="J??geva alevik"/><asula kood="2262" nimi="J??geva linn"/><asula kood="2284" nimi="J??une k??la"/><asula kood="2360" nimi="J??rvepera k??la"/><asula kood="2403" nimi="Kaarepere k??la"/><asula kood="2436" nimi="Kaave k??la"/><asula kood="2495" nimi="Kaera k??la"/><asula kood="2523" nimi="Kaiavere k??la"/><asula kood="2688" nimi="Kantk??la"/><asula kood="2818" nimi="Kassinurme k??la"/><asula kood="2819" nimi="Kassivere k??la"/><asula kood="2861" nimi="Kaude k??la"/><asula kood="3178" nimi="Kivij??rve k??la"/><asula kood="3188" nimi="Kivim??e k??la"/><asula kood="3244" nimi="Kodismaa k??la"/><asula kood="3302" nimi="Koimula k??la"/><asula kood="3518" nimi="Kudina k??la"/><asula kood="3642" nimi="Kuremaa alevik"/><asula kood="3676" nimi="Kurista k??la"/><asula kood="3769" nimi="K??nnu k??la"/><asula kood="3778" nimi="K??ola k??la"/><asula kood="3894" nimi="K??rde k??la"/><asula kood="4078" nimi="Laiuse alevik"/><asula kood="4080" nimi="Laiusev??lja k??la"/><asula kood="4175" nimi="Leedi k??la"/><asula kood="4278" nimi="Lemuvere k??la"/><asula kood="4342" nimi="Liikatku k??la"/><asula kood="4364" nimi="Liivoja k??la"/><asula kood="4367" nimi="Lilastvere k??la"/><asula kood="4579" nimi="Luua k??la"/><asula kood="4613" nimi="L??pe k??la"/><asula kood="4983" nimi="Mooritsa k??la"/><asula kood="5023" nimi="Mullavere k??la"/><asula kood="5131" nimi="M??isamaa k??la"/><asula kood="5373" nimi="Nava k??la"/><asula kood="5548" nimi="N??duvere k??la"/><asula kood="5684" nimi="Ookatku k??la"/><asula kood="5756" nimi="Oti k??la"/><asula kood="5817" nimi="Paduvere k??la"/><asula kood="5870" nimi="Paink??la"/><asula kood="5902" nimi="Pakaste k??la"/><asula kood="5913" nimi="Palamuse alevik"/><asula kood="5954" nimi="Palupere k??la"/><asula kood="6040" nimi="Patjala k??la"/><asula kood="6073" nimi="Pedja k??la"/><asula kood="6233" nimi="Pikkj??rve k??la"/><asula kood="6344" nimi="Praaklima k??la"/><asula kood="6643" nimi="P????ra k??la"/><asula kood="6679" nimi="Raadivere k??la"/><asula kood="6684" nimi="Raaduvere k??la"/><asula kood="6727" nimi="Rahivere k??la"/><asula kood="6834" nimi="Rassiku k??la"/><asula kood="6879" nimi="Reastvere k??la"/><asula kood="7031" nimi="Rohe k??la"/><asula kood="7048" nimi="Ronivere k??la"/><asula kood="7232" nimi="R????bise k??la"/><asula kood="7318" nimi="Sadala alevik"/><asula kood="7323" nimi="Saduk??la"/><asula kood="7539" nimi="Selli k??la"/><asula kood="7573" nimi="Siimusti alevik"/><asula kood="7719" nimi="Soomevere k??la"/><asula kood="7762" nimi="Sudiste k??la"/><asula kood="7943" nimi="S??tsuvere k??la"/><asula kood="7983" nimi="S??valepa k??la"/><asula kood="8174" nimi="Tealama k??la"/><asula kood="8188" nimi="Teilma k??la"/><asula kood="8295" nimi="Tooma k??la"/><asula kood="8318" nimi="Toovere k??la"/><asula kood="8331" nimi="Torma alevik"/><asula kood="8404" nimi="Tuim??isa k??la"/><asula kood="8480" nimi="T??ikvere k??la"/><asula kood="8558" nimi="T??hkvere k??la"/><asula kood="8861" nimi="Vaiatu k??la"/><asula kood="8872" nimi="Vaidavere k??la"/><asula kood="8879" nimi="Vaimastvere k??la"/><asula kood="8979" nimi="Vana-J??geva k??la"/><asula kood="9021" nimi="Vanam??isa k??la"/><asula kood="9037" nimi="Vanav??lja k??la"/><asula kood="9058" nimi="Varbevere k??la"/><asula kood="9333" nimi="Vilina k??la"/><asula kood="9409" nimi="Viruvere k??la"/><asula kood="9431" nimi="Visusti k??la"/><asula kood="9489" nimi="V??duvere k??la"/><asula kood="9519" nimi="V??idivere k??la"/><asula kood="9529" nimi="V??ikvere k??la"/><asula kood="9615" nimi="V??geva k??la"/><asula kood="9655" nimi="V??ljaotsa k??la"/><asula kood="9721" nimi="??una k??la"/><asula kood="9770" nimi="??nkk??la"/></vald><vald kood="0486" nimi="Mustvee vald"><asula kood="1087" nimi="Adraku k??la"/><asula kood="1191" nimi="Alekere k??la"/><asula kood="1481" nimi="Avinurme alevik"/><asula kood="1746" nimi="Halliku k??la"/><asula kood="2129" nimi="Jaama k??la"/><asula kood="2236" nimi="J??emetsa k??la"/><asula kood="2430" nimi="Kaasiku k??la"/><asula kood="2503" nimi="Kaevussaare k??la"/><asula kood="2611" nimi="Kallivere k??la"/><asula kood="2616" nimi="Kalmak??la"/><asula kood="2800" nimi="Kasep???? k??la"/><asula kood="3051" nimi="Kiisli k??la"/><asula kood="3052" nimi="Kiissa k??la"/><asula kood="3467" nimi="Koseveski k??la"/><asula kood="3819" nimi="K??rve k??la"/><asula kood="3826" nimi="K??rvemetsa k??la"/><asula kood="3842" nimi="K??veriku k??la"/><asula kood="3884" nimi="K??rasi k??la"/><asula kood="7285" nimi="K????pa k??la"/><asula kood="3968" nimi="K??kita k??la"/><asula kood="4033" nimi="Laekannu k??la"/><asula kood="4287" nimi="Lepiksaare k??la"/><asula kood="4308" nimi="Levala k??la"/><asula kood="4459" nimi="Lohusuu alevik"/><asula kood="4702" nimi="Maardla k??la"/><asula kood="4727" nimi="Maetsma k??la"/><asula kood="5052" nimi="Metsak??la"/><asula kood="5097" nimi="Mustvee linn"/><asula kood="5367" nimi="Nautrasi k??la"/><asula kood="5430" nimi="Ninasi k??la"/><asula kood="5532" nimi="N??mme k??la"/><asula kood="5598" nimi="Odivere k??la"/><asula kood="5673" nimi="Omedu k??la"/><asula kood="5774" nimi="Paadenurme k??la"/><asula kood="6067" nimi="Pedassaare k??la"/><asula kood="6174" nimi="Piilsi k??la"/><asula kood="6469" nimi="Putu k??la"/><asula kood="6589" nimi="P??llu k??la"/><asula kood="6682" nimi="Raadna k??la"/><asula kood="6764" nimi="Raja k??la"/><asula kood="7130" nimi="Ruskavere k??la"/><asula kood="7303" nimi="Saarj??rve k??la"/><asula kood="7544" nimi="Separa k??la"/><asula kood="7637" nimi="Sirguvere k??la"/><asula kood="7921" nimi="S??lliksaare k??la"/><asula kood="8102" nimi="Tammessaare k??la"/><asula kood="8117" nimi="Tammisp???? k??la"/><asula kood="8149" nimi="Tarakvere k??la"/><asula kood="8210" nimi="Tiheda k??la"/><asula kood="8453" nimi="Tuulavere k??la"/><asula kood="8664" nimi="Ulvi k??la"/><asula kood="8819" nimi="Vadi k??la"/><asula kood="9029" nimi="Vanassaare k??la"/><asula kood="9116" nimi="Vassevere k??la"/><asula kood="9181" nimi="Veia k??la"/><asula kood="9364" nimi="Vilusi k??la"/><asula kood="9466" nimi="Voore k??la"/><asula kood="9596" nimi="V??tikvere k??la"/><asula kood="9773" nimi="??nniksaare k??la"/></vald><vald kood="0618" nimi="P??ltsamaa vald"><asula kood="1076" nimi="Adavere alevik"/><asula kood="1137" nimi="Aidu k??la"/><asula kood="1179" nimi="Alastvere k??la"/><asula kood="1226" nimi="Altnurga k??la"/><asula kood="1293" nimi="Annikvere k??la"/><asula kood="1351" nimi="Arisvere k??la"/><asula kood="1652" nimi="Esku k??la"/><asula kood="2379" nimi="J??rik??la"/><asula kood="2438" nimi="Kaavere k??la"/><asula kood="2461" nimi="Kablak??la"/><asula kood="2562" nimi="Kalana k??la"/><asula kood="2582" nimi="Kalik??la"/><asula kood="2621" nimi="Kalme k??la"/><asula kood="2636" nimi="Kamari alevik"/><asula kood="2875" nimi="Kauru k??la"/><asula kood="3132" nimi="Kirikuvalla k??la"/><asula kood="3458" nimi="Kose k??la"/><asula kood="3624" nimi="Kuningam??e k??la"/><asula kood="3693" nimi="Kursi k??la"/><asula kood="3779" nimi="K??pu k??la"/><asula kood="3801" nimi="K??rkk??la"/><asula kood="4026" nimi="Laasme k??la"/><asula kood="4049" nimi="Lahavere k??la"/><asula kood="4170" nimi="Lebavere k??la"/><asula kood="4513" nimi="Loopre k??la"/><asula kood="4551" nimi="Luige k??la"/><asula kood="4567" nimi="Lustivere k??la"/><asula kood="5123" nimi="M??hk??la"/><asula kood="5136" nimi="M??isak??la"/><asula kood="5166" nimi="M??rtsi k??la"/><asula kood="5253" nimi="M??llikvere k??la"/><asula kood="5382" nimi="Neanurme k??la"/><asula kood="5462" nimi="Nurga k??la"/><asula kood="5501" nimi="N??mavere k??la"/><asula kood="5894" nimi="Pajusi k??la"/><asula kood="6048" nimi="Pauastvere k??la"/><asula kood="6236" nimi="Pikknurme k??la"/><asula kood="6262" nimi="Pilu k??la"/><asula kood="6280" nimi="Pisisaare k??la"/><asula kood="6381" nimi="Pudivere k??la"/><asula kood="6385" nimi="Puduk??la"/><asula kood="6404" nimi="Puiatu k??la"/><asula kood="6479" nimi="Puurmani alevik"/><asula kood="6537" nimi="P??ltsamaa linn"/><asula kood="7175" nimi="R??stla k??la"/><asula kood="7220" nimi="R??sna k??la"/><asula kood="7753" nimi="Sopimetsa k??la"/><asula kood="7798" nimi="Sulustvere k??la"/><asula kood="8113" nimi="Tammiku k??la"/><asula kood="8141" nimi="Tapiku k??la"/><asula kood="8483" nimi="T??ivere k??la"/><asula kood="8515" nimi="T??renurme k??la"/><asula kood="8537" nimi="T??rve k??la"/><asula kood="8674" nimi="Umbusi k??la"/><asula kood="8772" nimi="Uuev??lja k??la"/><asula kood="9437" nimi="Vitsj??rve k??la"/><asula kood="9486" nimi="Vorsti k??la"/><asula kood="9501" nimi="V??hman??mme k??la"/><asula kood="9536" nimi="V??isiku k??la"/><asula kood="9612" nimi="V??gari k??la"/><asula kood="9621" nimi="V??ike-Kamari k??la"/><asula kood="9654" nimi="V??ljataguse k??la"/></vald></maakond><maakond kood="0052" nimi="J??rva maakond"><vald kood="0255" nimi="J??rva vald"><asula kood="1055" nimi="Abaja k??la"/><asula kood="1100" nimi="Ageri k??la"/><asula kood="1122" nimi="Ahula k??la"/><asula kood="1188" nimi="Albu k??la"/><asula kood="1250" nimi="Ambla alevik"/><asula kood="1252" nimi="Ammuta k??la"/><asula kood="1326" nimi="Aravete alevik"/><asula kood="1371" nimi="Aruk??la"/><asula kood="1441" nimi="Ataste k??la"/><asula kood="1567" nimi="Eistvere k??la"/><asula kood="1640" nimi="Ervita k??la"/><asula kood="1655" nimi="Esna k??la"/><asula kood="1825" nimi="Hermani k??la"/><asula kood="1920" nimi="Huuksi k??la"/><asula kood="2073" nimi="Imavere k??la"/><asula kood="2156" nimi="Jalal??pe k??la"/><asula kood="2159" nimi="Jalametsa k??la"/><asula kood="2164" nimi="Jalgsema k??la"/><asula kood="2230" nimi="J??ek??la"/><asula kood="2268" nimi="J??gisoo k??la"/><asula kood="2321" nimi="J??ravere k??la"/><asula kood="2341" nimi="J??rva-Jaani alev"/><asula kood="2343" nimi="J??rva-Madise k??la"/><asula kood="2395" nimi="Kaalepi k??la"/><asula kood="2506" nimi="Kagavere k??la"/><asula kood="2339" nimi="Kahala k??la"/><asula kood="2591" nimi="Kalitsa k??la"/><asula kood="2702" nimi="Kapu k??la"/><asula kood="2712" nimi="Kareda k??la"/><asula kood="2733" nimi="Karinu k??la"/><asula kood="2971" nimi="Keri k??la"/><asula kood="3032" nimi="Kiigevere k??la"/><asula kood="3255" nimi="Koeru alevik"/><asula kood="3273" nimi="Koidu-Ellavere k??la"/><asula kood="3282" nimi="Koigi k??la"/><asula kood="3554" nimi="Kukevere k??la"/><asula kood="3564" nimi="Kuksema k??la"/><asula kood="3673" nimi="Kurisoo k??la"/><asula kood="3723" nimi="Kuusna k??la"/><asula kood="3886" nimi="K??ravete alevik"/><asula kood="3937" nimi="K??sukonna k??la"/><asula kood="3960" nimi="K??isi k??la"/><asula kood="3992" nimi="K??ti k??la"/><asula kood="4022" nimi="Laaneotsa k??la"/><asula kood="4070" nimi="Laimetsa k??la"/><asula kood="4214" nimi="Lehtmetsa k??la"/><asula kood="4428" nimi="Liusvere k??la"/><asula kood="4626" nimi="L??hevere k??la"/><asula kood="4882" nimi="Merja k??la"/><asula kood="4927" nimi="Metsla k??la"/><asula kood="4936" nimi="Metstaguse k??la"/><asula kood="5156" nimi="M??nuvere k??la"/><asula kood="5215" nimi="M??gede k??la"/><asula kood="5226" nimi="M??gise k??la"/><asula kood="5281" nimi="M??rjandi k??la"/><asula kood="5322" nimi="M????sleri k??la"/><asula kood="5402" nimi="Neitla k??la"/><asula kood="5455" nimi="Norra k??la"/><asula kood="5714" nimi="Orgmetsa k??la"/><asula kood="6079" nimi="Peedu k??la"/><asula kood="6085" nimi="Peetri alevik"/><asula kood="6349" nimi="Prandi k??la"/><asula kood="6360" nimi="Preedi k??la"/><asula kood="6398" nimi="Puhmu k??la"/><asula kood="6402" nimi="Puiatu k??la"/><asula kood="6422" nimi="Pullevere k??la"/><asula kood="6580" nimi="P??inurme k??la"/><asula kood="6583" nimi="P??llastvere k??la"/><asula kood="6627" nimi="P??tsavere k??la"/><asula kood="6771" nimi="Raka k??la"/><asula kood="6780" nimi="Ramma k??la"/><asula kood="6870" nimi="Rava k??la"/><asula kood="6915" nimi="Reinevere k??la"/><asula kood="7081" nimi="Roosna k??la"/><asula kood="7135" nimi="Rutikvere k??la"/><asula kood="7157" nimi="R??hu k??la"/><asula kood="7399" nimi="Salutaguse k??la"/><asula kood="7408" nimi="Santovi k??la"/><asula kood="7505" nimi="Seidla k??la"/><asula kood="7521" nimi="Selik??la"/><asula kood="7598" nimi="Silmsi k??la"/><asula kood="7741" nimi="Soosalu k??la"/><asula kood="7770" nimi="Sugalepa k??la"/><asula kood="7895" nimi="S??randu k??la"/><asula kood="7961" nimi="S????sk??la"/><asula kood="7991" nimi="Taadikvere k??la"/><asula kood="8097" nimi="Tammek??la"/><asula kood="8110" nimi="Tammiku k??la"/><asula kood="8137" nimi="Tamsi k??la"/><asula kood="8388" nimi="Tudre k??la"/><asula kood="8616" nimi="Udeva k??la"/><asula kood="8803" nimi="Vaali k??la"/><asula kood="8858" nimi="Vahuk??la"/><asula kood="8944" nimi="Valila k??la"/><asula kood="9047" nimi="Vao k??la"/><asula kood="9243" nimi="Vetepere k??la"/><asula kood="9430" nimi="Visusti k??la"/><asula kood="9446" nimi="Vodja k??la"/><asula kood="9492" nimi="Vuti k??la"/><asula kood="9575" nimi="V??revere k??la"/><asula kood="9623" nimi="V??ike-Kareda k??la"/><asula kood="9638" nimi="V??inj??rve k??la"/><asula kood="9696" nimi="??le k??la"/><asula kood="9755" nimi="??mbra k??la"/><asula kood="9807" nimi="????tla k??la"/><asula kood="9825" nimi="??lej??e k??la"/></vald><vald kood="0567" nimi="Paide linn"><asula kood="1205" nimi="Allikj??rve k??la"/><asula kood="1286" nimi="Anna k??la"/><asula kood="1570" nimi="Eivere k??la"/><asula kood="1653" nimi="Esna k??la"/><asula kood="2421" nimi="Kaaruka k??la"/><asula kood="3019" nimi="Kihme k??la"/><asula kood="3131" nimi="Kirila k??la"/><asula kood="3137" nimi="Kirisaare k??la"/><asula kood="3229" nimi="Kodasema k??la"/><asula kood="3417" nimi="Koordi k??la"/><asula kood="3442" nimi="Korba k??la"/><asula kood="3497" nimi="Kriilev??lja k??la"/><asula kood="5083" nimi="Mustla k??la"/><asula kood="5090" nimi="Mustla-N??mme k??la"/><asula kood="5193" nimi="M??ek??la"/><asula kood="5275" nimi="M??o k??la"/><asula kood="5317" nimi="M??ndi k??la"/><asula kood="5466" nimi="Nurme k??la"/><asula kood="5474" nimi="Nurmsi k??la"/><asula kood="5609" nimi="Oeti k??la"/><asula kood="5648" nimi="Ojak??la"/><asula kood="5761" nimi="Otiku k??la"/><asula kood="5860" nimi="Paide linn"/><asula kood="6214" nimi="Pikak??la"/><asula kood="6377" nimi="Pr????ma k??la"/><asula kood="6405" nimi="Puiatu k??la"/><asula kood="6440" nimi="Purdi k??la"/><asula kood="7083" nimi="Roosna-Alliku alevik"/><asula kood="7428" nimi="Sargvere k??la"/><asula kood="7508" nimi="Seinapalu k??la"/><asula kood="7593" nimi="Sillaotsa k??la"/><asula kood="7863" nimi="Suurpalu k??la"/><asula kood="7889" nimi="S??meru k??la"/><asula kood="8152" nimi="Tarbja k??la"/><asula kood="8570" nimi="T??nnapere k??la"/><asula kood="8917" nimi="Valasti k??la"/><asula kood="8935" nimi="Valgma k??la"/><asula kood="9689" nimi="Vedruka k??la"/><asula kood="9227" nimi="Veskiaru k??la"/><asula kood="9302" nimi="Viisu k??la"/><asula kood="9379" nimi="Viraksaare k??la"/><asula kood="9602" nimi="V????bu k??la"/></vald><vald kood="0834" nimi="T??ri vald"><asula kood="1042" nimi="Aasuv??lja k??la"/><asula kood="1359" nimi="Arkma k??la"/><asula kood="2228" nimi="J??ek??la"/><asula kood="2315" nimi="J??ndja k??la"/><asula kood="2445" nimi="Kabala k??la"/><asula kood="2510" nimi="Kahala k??la"/><asula kood="5144" nimi="Karjak??la"/><asula kood="3148" nimi="Kirna k??la"/><asula kood="3364" nimi="Kolu k??la"/><asula kood="3600" nimi="Kullimaa k??la"/><asula kood="3684" nimi="Kurla k??la"/><asula kood="3735" nimi="K??du k??la"/><asula kood="3854" nimi="K??dva k??la"/><asula kood="3875" nimi="K??ndliku k??la"/><asula kood="3899" nimi="K??revere k??la"/><asula kood="3933" nimi="K??ru alevik"/><asula kood="4153" nimi="Laupa k??la"/><asula kood="4157" nimi="Lauri k??la"/><asula kood="4475" nimi="Lokuta k??la"/><asula kood="4560" nimi="Lungu k??la"/><asula kood="4623" nimi="L????la k??la"/><asula kood="4873" nimi="Meossaare k??la"/><asula kood="4897" nimi="Metsak??la"/><asula kood="5197" nimi="M??ek??la"/><asula kood="5562" nimi="N??suvere k??la"/><asula kood="5641" nimi="Oisu alevik"/><asula kood="5666" nimi="Ollepa k??la"/><asula kood="5906" nimi="Pala k??la"/><asula kood="6134" nimi="Pibari k??la"/><asula kood="6206" nimi="Piiumetsa k??la"/><asula kood="6300" nimi="Poaka k??la"/><asula kood="6505" nimi="P??ikva k??la"/><asula kood="6831" nimi="Rassi k??la"/><asula kood="6863" nimi="Raukla k??la"/><asula kood="6940" nimi="Reopalu k??la"/><asula kood="6948" nimi="Retla k??la"/><asula kood="6995" nimi="Rikassaare k??la"/><asula kood="7095" nimi="Roovere k??la"/><asula kood="7254" nimi="R??a k??la"/><asula kood="7293" nimi="Saareotsa k??la"/><asula kood="7332" nimi="Sagevere k??la"/><asula kood="7452" nimi="Saueaugu k??la"/><asula kood="7683" nimi="Sonni k??la"/><asula kood="7935" nimi="S??revere alevik"/><asula kood="8080" nimi="Taikse k??la"/><asula kood="8325" nimi="Tori k??la"/><asula kood="8573" nimi="T??nnassilma k??la"/><asula kood="8595" nimi="T??ri linn"/><asula kood="8596" nimi="T??ri-Alliku k??la"/><asula kood="9336" nimi="Vilita k??la"/><asula kood="9352" nimi="Villevere k??la"/><asula kood="9425" nimi="Vissuvere k??la"/><asula kood="9653" nimi="V??ljaotsa k??la"/><asula kood="9656" nimi="V??ljataguse k??la"/><asula kood="9690" nimi="V????tsa alevik"/><asula kood="9741" nimi="??iamaa k??la"/><asula kood="9762" nimi="??nari k??la"/><asula kood="9828" nimi="??lej??e k??la"/></vald></maakond><maakond kood="0056" nimi="L????ne maakond"><vald kood="0184" nimi="Haapsalu linn"><asula kood="1017" nimi="Aamse k??la"/><asula kood="1201" nimi="Allika k??la"/><asula kood="1251" nimi="Ammuta k??la"/><asula kood="1592" nimi="Emmuvere k??la"/><asula kood="1624" nimi="Erja k??la"/><asula kood="1658" nimi="Espre k??la"/><asula kood="1692" nimi="Haapsalu linn"/><asula kood="1711" nimi="Haeska k??la"/><asula kood="1824" nimi="Herjava k??la"/><asula kood="1875" nimi="Hobulaiu k??la"/><asula kood="2285" nimi="J????dre k??la"/><asula kood="2466" nimi="Kabrametsa k??la"/><asula kood="2472" nimi="Kadaka k??la"/><asula kood="2497" nimi="Kaevere k??la"/><asula kood="3027" nimi="Kiideva k??la"/><asula kood="3090" nimi="Kiltsi k??la"/><asula kood="3171" nimi="Kivik??la"/><asula kood="3276" nimi="Koheri k??la"/><asula kood="3281" nimi="Koidu k??la"/><asula kood="3341" nimi="Kolila k??la"/><asula kood="3361" nimi="Kolu k??la"/><asula kood="3849" nimi="K??pla k??la"/><asula kood="4063" nimi="Laheva k??la"/><asula kood="4102" nimi="Lannuste k??la"/><asula kood="4351" nimi="Liivak??la"/><asula kood="4426" nimi="Litu k??la"/><asula kood="4592" nimi="L??be k??la"/><asula kood="4883" nimi="Metsak??la"/><asula kood="5186" nimi="M??ek??la"/><asula kood="5216" nimi="M??gari k??la"/><asula kood="5527" nimi="N??mme k??la"/><asula kood="5971" nimi="Panga k??la"/><asula kood="5989" nimi="Paralepa alevik"/><asula kood="6959" nimi="Parila k??la"/><asula kood="6403" nimi="Puiatu k??la"/><asula kood="6413" nimi="Puise k??la"/><asula kood="6462" nimi="Pusku k??la"/><asula kood="6496" nimi="P??gari-Sassi k??la"/><asula kood="7029" nimi="Rohense k??la"/><asula kood="7036" nimi="Rohuk??la"/><asula kood="7120" nimi="Rummu k??la"/><asula kood="7275" nimi="Saanika k??la"/><asula kood="7283" nimi="Saardu k??la"/><asula kood="7540" nimi="Sepak??la"/><asula kood="7606" nimi="Sinalepa k??la"/><asula kood="1119" nimi="Suure-Ahli k??la"/><asula kood="8116" nimi="Tammiku k??la"/><asula kood="8321" nimi="Tanska k??la"/><asula kood="8465" nimi="Tuuru k??la"/><asula kood="8690" nimi="Uneste k??la"/><asula kood="8769" nimi="Uuem??isa alevik"/><asula kood="8768" nimi="Uuem??isa k??la"/><asula kood="8929" nimi="Valgev??lja k??la"/><asula kood="9091" nimi="Varni k??la"/><asula kood="9343" nimi="Vilkla k??la"/><asula kood="9568" nimi="V??nnu k??la"/><asula kood="9616" nimi="V??ike-Ahli k??la"/><asula kood="9673" nimi="V??tse k??la"/><asula kood="9853" nimi="??sse k??la"/></vald><vald kood="0441" nimi="L????ne-Nigula vald"><asula kood="1210" nimi="Allikmaa k??la"/><asula kood="1209" nimi="Allikotsa k??la"/><asula kood="1447" nimi="Auaste k??la"/><asula kood="1469" nimi="Aulepa k??la / Dirsl??tt"/><asula kood="1505" nimi="Dirhami k??la / Derhamn"/><asula kood="1546" nimi="Ehmja k??la"/><asula kood="1556" nimi="Einbi k??la / Enby"/><asula kood="1571" nimi="Elbiku k??la / ??lb??ck"/><asula kood="1600" nimi="Enivere k??la"/><asula kood="1760" nimi="Hara k??la / Harga"/><asula kood="1852" nimi="Hindaste k??la"/><asula kood="1889" nimi="Hosby k??la"/><asula kood="1964" nimi="H??bringi k??la / H??bring"/><asula kood="2084" nimi="Ingk??la"/><asula kood="2126" nimi="Jaakna k??la"/><asula kood="2166" nimi="Jalukse k??la"/><asula kood="2246" nimi="J??esse k??la"/><asula kood="2266" nimi="J??gisoo k??la"/><asula kood="2399" nimi="Kaare k??la"/><asula kood="2426" nimi="Kaasiku k??la"/><asula kood="2446" nimi="Kabeli k??la"/><asula kood="2479" nimi="Kadarpiku k??la"/><asula kood="2593" nimi="Kalju k??la"/><asula kood="2787" nimi="Kasari k??la"/><asula kood="2826" nimi="Kastja k??la"/><asula kood="2904" nimi="Kedre k??la"/><asula kood="2906" nimi="Keedika k??la"/><asula kood="2958" nimi="Keravere k??la"/><asula kood="2983" nimi="Keskk??la"/><asula kood="2977" nimi="Keskvere k??la"/><asula kood="2991" nimi="Kesu k??la"/><asula kood="3135" nimi="Kirim??e k??la"/><asula kood="3147" nimi="Kirna k??la"/><asula kood="3247" nimi="Koela k??la"/><asula kood="3321" nimi="Kokre k??la"/><asula kood="3366" nimi="Koluvere k??la"/><asula kood="3514" nimi="Kudani k??la / Gutan??s"/><asula kood="3539" nimi="Kuij??e k??la"/><asula kood="3551" nimi="Kuke k??la"/><asula kood="3587" nimi="Kullamaa k??la"/><asula kood="3590" nimi="Kullametsa k??la"/><asula kood="3605" nimi="Kuluse k??la"/><asula kood="3665" nimi="Kurevere k??la"/><asula kood="3889" nimi="K??rbla k??la"/><asula kood="4068" nimi="Laik??la"/><asula kood="4178" nimi="Leedik??la"/><asula kood="4230" nimi="Leila k??la"/><asula kood="4271" nimi="Lemmikk??la"/><asula kood="4350" nimi="Liivak??la"/><asula kood="4361" nimi="Liivi k??la"/><asula kood="4400" nimi="Linnam??e k??la"/><asula kood="4553" nimi="Luigu k??la"/><asula kood="4796" nimi="Martna k??la"/><asula kood="5143" nimi="M??isak??la"/><asula kood="5165" nimi="M??rdu k??la"/><asula kood="5259" nimi="M??nniku k??la"/><asula kood="5407" nimi="Nigula k??la"/><asula kood="5413" nimi="Nihka k??la"/><asula kood="5415" nimi="Niibi k??la"/><asula kood="5419" nimi="Niinja k??la"/><asula kood="5526" nimi="N??mme k??la"/><asula kood="5513" nimi="N??mmemaa k??la"/><asula kood="5543" nimi="N??va k??la"/><asula kood="5626" nimi="Ohtla k??la"/><asula kood="5693" nimi="Oonga k??la"/><asula kood="5737" nimi="Oru k??la"/><asula kood="5743" nimi="Osmussaare k??la / Odensholm"/><asula kood="5926" nimi="Palivere alevik"/><asula kood="6029" nimi="Paslepa k??la / Pasklep"/><asula kood="6109" nimi="Perak??la"/><asula kood="6191" nimi="Piirsalu k??la"/><asula kood="6464" nimi="Putkaste k??la"/><asula kood="6586" nimi="P??lli k??la"/><asula kood="6599" nimi="P??ri k??la"/><asula kood="6669" nimi="P??rksi k??la / Birkas"/><asula kood="6805" nimi="Rannaj??e k??la"/><asula kood="6808" nimi="Rannak??la"/><asula kood="6904" nimi="Rehem??e k??la"/><asula kood="6968" nimi="Riguldi k??la / Rickul"/><asula kood="7011" nimi="Risti alevik"/><asula kood="7077" nimi="Rooslepa k??la / Roslep"/><asula kood="7178" nimi="R??ude k??la"/><asula kood="7183" nimi="R??uma k??la"/><asula kood="7284" nimi="Saare k??la / Lyckholm"/><asula kood="7369" nimi="Salaj??e k??la"/><asula kood="7465" nimi="Saunja k??la"/><asula kood="7534" nimi="Seljak??la"/><asula kood="7589" nimi="Silla k??la"/><asula kood="7682" nimi="Soo-otsa k??la"/><asula kood="7709" nimi="Soolu k??la"/><asula kood="7760" nimi="Spithami k??la / Spithamn"/><asula kood="7817" nimi="Sutlepa k??la / Sutlep"/><asula kood="7829" nimi="Suur-N??mmk??la / Klottorp"/><asula kood="7832" nimi="Suure-L??htru k??la"/><asula kood="8025" nimi="Taebla alevik"/><asula kood="8058" nimi="Tagavere k??la"/><asula kood="8074" nimi="Tahu k??la / Sk??tan??s"/><asula kood="8106" nimi="Tammiku k??la"/><asula kood="8187" nimi="Telise k??la / T??lln??s"/><asula kood="8405" nimi="Tuka k??la"/><asula kood="8409" nimi="Tuksi k??la / Bergsby"/><asula kood="8434" nimi="Turvalepa k??la"/><asula kood="8437" nimi="Tusari k??la"/><asula kood="8607" nimi="Ubasalu k??la"/><asula kood="8776" nimi="Uugla k??la"/><asula kood="8785" nimi="Uusk??la"/><asula kood="8890" nimi="Vaisi k??la"/><asula kood="9017" nimi="Vanak??la"/><asula kood="9011" nimi="Vanak??la / Gambyn"/><asula kood="9083" nimi="Variku k??la"/><asula kood="9156" nimi="Vedra k??la"/><asula kood="9254" nimi="Vidruka k??la"/><asula kood="9572" nimi="V??ntk??la"/><asula kood="4632" nimi="V??ike-L??htru k??la"/><asula kood="5523" nimi="V??ike-N??mmk??la / Pers??ker"/><asula kood="9686" nimi="V????nla k??la"/><asula kood="9803" nimi="??sterby k??la"/><asula kood="9812" nimi="??druma k??la"/></vald><vald kood="0907" nimi="Vormsi vald"><asula kood="1493" nimi="Borrby k??la"/><asula kood="1502" nimi="Diby k??la"/><asula kood="1662" nimi="F??llarna k??la"/><asula kood="1670" nimi="F??rby k??la"/><asula kood="1892" nimi="Hosby k??la"/><asula kood="1900" nimi="Hullo k??la"/><asula kood="2981" nimi="Kersleti k??la"/><asula kood="5453" nimi="Norrby k??la"/><asula kood="7124" nimi="Rumpo k??la"/><asula kood="7205" nimi="R??lby k??la"/><asula kood="7502" nimi="Saxby k??la"/><asula kood="7845" nimi="Suurem??isa k??la"/><asula kood="7875" nimi="Sviby k??la"/><asula kood="7971" nimi="S??derby k??la"/></vald></maakond><maakond kood="0060" nimi="L????ne-Viru maakond"><vald kood="0191" nimi="Haljala vald"><asula kood="1032" nimi="Aaspere k??la"/><asula kood="1035" nimi="Aasu k??la"/><asula kood="1040" nimi="Aasumetsa k??la"/><asula kood="1051" nimi="Aaviku k??la"/><asula kood="1073" nimi="Adaka k??la"/><asula kood="1218" nimi="Altja k??la"/><asula kood="1255" nimi="Andi k??la"/><asula kood="1294" nimi="Annikvere k??la"/><asula kood="1463" nimi="Auk??la"/><asula kood="1562" nimi="Eisma k??la"/><asula kood="1637" nimi="Eru k??la"/><asula kood="1661" nimi="Essu k??la"/><asula kood="1723" nimi="Haili k??la"/><asula kood="1739" nimi="Haljala alevik"/><asula kood="1986" nimi="Idavere k??la"/><asula kood="2059" nimi="Ilum??e k??la"/><asula kood="2191" nimi="Joandu k??la"/><asula kood="2558" nimi="Kakuv??lja k??la"/><asula kood="2664" nimi="Kandle k??la"/><asula kood="2715" nimi="Karepa k??la"/><asula kood="2774" nimi="Karula k??la"/><asula kood="2896" nimi="Kavastu k??la"/><asula kood="3161" nimi="Kisuvere k??la"/><asula kood="3173" nimi="Kiva k??la"/><asula kood="3345" nimi="Koljaku k??la"/><asula kood="3401" nimi="Koolim??e k??la"/><asula kood="3449" nimi="Korjuse k??la"/><asula kood="3473" nimi="Kosta k??la"/><asula kood="3754" nimi="K??ldu k??la"/><asula kood="3918" nimi="K??rmu k??la"/><asula kood="3934" nimi="K??smu k??la"/><asula kood="4052" nimi="Lahe k??la"/><asula kood="4151" nimi="Lauli k??la"/><asula kood="4331" nimi="Lihul??pe k??la"/><asula kood="4337" nimi="Liiguste k??la"/><asula kood="4437" nimi="Lobi k??la"/><asula kood="4905" nimi="Metsanurga k??la"/><asula kood="4918" nimi="Metsiku k??la"/><asula kood="5009" nimi="Muike k??la"/><asula kood="5091" nimi="Mustoja k??la"/><asula kood="5364" nimi="Natturi k??la"/><asula kood="5442" nimi="Noonu k??la"/><asula kood="5575" nimi="Oandu k??la"/><asula kood="5786" nimi="Paasi k??la"/><asula kood="5899" nimi="Pajuveski k??la"/><asula kood="5936" nimi="Palmse k??la"/><asula kood="6068" nimi="Pedassaare k??la"/><asula kood="6093" nimi="Pehka k??la"/><asula kood="6148" nimi="Pihlaspea k??la"/><asula kood="6493" nimi="P??druse k??la"/><asula kood="7138" nimi="Rutja k??la"/><asula kood="7329" nimi="Sagadi k??la"/><asula kood="7366" nimi="Sakussaare k??la"/><asula kood="7374" nimi="Salatse k??la"/><asula kood="7468" nimi="Sauste k??la"/><asula kood="8167" nimi="Tatruse k??la"/><asula kood="8195" nimi="Tepelv??lja k??la"/><asula kood="8178" nimi="Tidriku k??la"/><asula kood="8222" nimi="Tiigi k??la"/><asula kood="8293" nimi="Toolse k??la"/><asula kood="8543" nimi="T??ugu k??la"/><asula kood="8787" nimi="Uusk??la"/><asula kood="8888" nimi="Vainupea k??la"/><asula kood="9024" nimi="Vanam??isa k??la"/><asula kood="2779" nimi="Varangu k??la"/><asula kood="9139" nimi="Vatku k??la"/><asula kood="9213" nimi="Vergi k??la"/><asula kood="9270" nimi="Vihula k??la"/><asula kood="9321" nimi="Vila k??la"/><asula kood="9350" nimi="Villandi k??la"/><asula kood="9498" nimi="V??hma k??la"/><asula kood="9552" nimi="V??le k??la"/><asula kood="9592" nimi="V??su alevik"/><asula kood="9593" nimi="V??supere k??la"/></vald><vald kood="0272" nimi="Kadrina vald"><asula kood="1245" nimi="Ama k??la"/><asula kood="1334" nimi="Arbavere k??la"/><asula kood="1897" nimi="Hulja alevik"/><asula kood="1924" nimi="H??beda k??la"/><asula kood="1947" nimi="H??rjadi k??la"/><asula kood="2245" nimi="J??epere k??la"/><asula kood="2253" nimi="J??etaguse k??la"/><asula kood="2380" nimi="J??rim??isa k??la"/><asula kood="2476" nimi="Kadapiku k??la"/><asula kood="2490" nimi="Kadrina alevik"/><asula kood="2614" nimi="Kallukse k??la"/><asula kood="3017" nimi="Kihlevere k??la"/><asula kood="3074" nimi="Kiku k??la"/><asula kood="3362" nimi="Kolu k??la"/><asula kood="3823" nimi="K??rvek??la"/><asula kood="4106" nimi="Lante k??la"/><asula kood="4224" nimi="Leikude k??la"/><asula kood="4498" nimi="Loobu k??la"/><asula kood="4641" nimi="L??sna k??la"/><asula kood="5147" nimi="M??ndavere k??la"/><asula kood="5276" nimi="M??o k??la"/><asula kood="5395" nimi="Neeruti k??la"/><asula kood="5620" nimi="Ohepalu k??la"/><asula kood="5741" nimi="Orutaguse k??la"/><asula kood="6004" nimi="Pariisi k??la"/><asula kood="6507" nimi="P??ima k??la"/><asula kood="6953" nimi="Ridak??la"/><asula kood="7164" nimi="R??meda k??la"/><asula kood="7376" nimi="Salda k??la"/><asula kood="7456" nimi="Saukse k??la"/><asula kood="7747" nimi="Sootaguse k??la"/><asula kood="8254" nimi="Tirbiku k??la"/><asula kood="8278" nimi="Tokolopi k??la"/><asula kood="8622" nimi="Udriku k??la"/><asula kood="8651" nimi="Uku k??la"/><asula kood="8688" nimi="Undla k??la"/><asula kood="8860" nimi="Vaiatu k??la"/><asula kood="9043" nimi="Vandu k??la"/><asula kood="9311" nimi="Viitna k??la"/><asula kood="9449" nimi="Vohnja k??la"/><asula kood="9490" nimi="V??duvere k??la"/><asula kood="9534" nimi="V??ipere k??la"/></vald><vald kood="0663" nimi="Rakvere linn"/><vald kood="0661" nimi="Rakvere vald"><asula kood="1242" nimi="Aluvere k??la"/><asula kood="1259" nimi="Andja k??la"/><asula kood="1345" nimi="Aresi k??la"/><asula kood="1362" nimi="Arkna k??la"/><asula kood="1536" nimi="Eesk??la"/><asula kood="2332" nimi="J??rni k??la"/><asula kood="2373" nimi="J????tma k??la"/><asula kood="2405" nimi="Kaarli k??la"/><asula kood="2741" nimi="Karitsa k??la"/><asula kood="2744" nimi="Kariv??rava k??la"/><asula kood="2781" nimi="Karunga k??la"/><asula kood="2853" nimi="Katela k??la"/><asula kood="2851" nimi="Katku k??la"/><asula kood="3202" nimi="Kloodi k??la"/><asula kood="3263" nimi="Kohala k??la"/><asula kood="3261" nimi="Kohala-Eesk??la"/><asula kood="3432" nimi="Koov??lja k??la"/><asula kood="3582" nimi="Kullaaru k??la"/><asula kood="3790" nimi="K??rgem??e k??la"/><asula kood="4123" nimi="Lasila k??la"/><asula kood="4294" nimi="Lepna alevik"/><asula kood="4309" nimi="Levala k??la"/><asula kood="5055" nimi="Muru k??la"/><asula kood="5182" nimi="M??dapea k??la"/><asula kood="5478" nimi="Nurme k??la"/><asula kood="5554" nimi="N??pi alevik"/><asula kood="5796" nimi="Paatna k??la"/><asula kood="5979" nimi="Papiaru k??la"/><asula kood="6567" nimi="P??ide k??la"/><asula kood="6726" nimi="Rahkla k??la"/><asula kood="6850" nimi="Raudlepa k??la"/><asula kood="6860" nimi="Raudvere k??la"/><asula kood="7058" nimi="Roodev??lja k??la"/><asula kood="7199" nimi="R??gavere k??la"/><asula kood="7684" nimi="Sooaluse k??la"/><asula kood="7892" nimi="S??meru alevik"/><asula kood="7927" nimi="S??mi k??la"/><asula kood="7925" nimi="S??mi-Tagak??la"/><asula kood="8001" nimi="Taaravainu k??la"/><asula kood="8261" nimi="Tobia k??la"/><asula kood="8304" nimi="Toomla k??la"/><asula kood="8520" nimi="T??rma k??la"/><asula kood="8525" nimi="T??rrem??e k??la"/><asula kood="8610" nimi="Ubja k??la"/><asula kood="8637" nimi="Uhtna alevik"/><asula kood="8740" nimi="Ussim??e k??la"/><asula kood="8822" nimi="Vaek??la"/><asula kood="9099" nimi="Varudi-Altk??la"/><asula kood="9098" nimi="Varudi-Vanak??la"/><asula kood="9196" nimi="Veltsi k??la"/><asula kood="9495" nimi="V??hma k??la"/></vald><vald kood="0792" nimi="Tapa vald"><asula kood="1048" nimi="Aavere k??la"/><asula kood="1235" nimi="Alupere k??la"/><asula kood="1315" nimi="Araski k??la"/><asula kood="1410" nimi="Assamalla k??la"/><asula kood="2068" nimi="Imastu k??la"/><asula kood="2199" nimi="Jootme k??la"/><asula kood="2318" nimi="J??neda k??la"/><asula kood="2334" nimi="J??rsi k??la"/><asula kood="2345" nimi="J??rvaj??e k??la"/><asula kood="2482" nimi="Kadapiku k??la"/><asula kood="2500" nimi="Kaeva k??la"/><asula kood="2762" nimi="Karkuse k??la"/><asula kood="2970" nimi="Kerguta k??la"/><asula kood="3288" nimi="Koiduk??la"/><asula kood="3438" nimi="Koplitaguse k??la"/><asula kood="3531" nimi="Kuie k??la"/><asula kood="3592" nimi="Kullenga k??la"/><asula kood="3694" nimi="Kursi k??la"/><asula kood="3702" nimi="Kuru k??la"/><asula kood="3822" nimi="K??rvek??la"/><asula kood="4217" nimi="Lehtse alevik"/><asula kood="4273" nimi="Lemmk??la"/><asula kood="4403" nimi="Linnape k??la"/><asula kood="4470" nimi="Loksa k??la"/><asula kood="4473" nimi="Loksu k??la"/><asula kood="4474" nimi="Lokuta k??la"/><asula kood="4638" nimi="L??pi k??la"/><asula kood="4644" nimi="L??ste k??la"/><asula kood="4920" nimi="Metskaevu k??la"/><asula kood="4963" nimi="Moe k??la"/><asula kood="5352" nimi="Naistev??lja k??la"/><asula kood="5525" nimi="N??mmk??la"/><asula kood="5551" nimi="N??o k??la"/><asula kood="6037" nimi="Patika k??la"/><asula kood="6177" nimi="Piilu k??la"/><asula kood="6204" nimi="Piisupi k??la"/><asula kood="6333" nimi="Porkuni k??la"/><asula kood="6374" nimi="Pruuna k??la"/><asula kood="6491" nimi="P??drangu k??la"/><asula kood="6703" nimi="Rabasaare k??la"/><asula kood="6847" nimi="Raudla k??la"/><asula kood="7198" nimi="R??gavere k??la"/><asula kood="7221" nimi="R??sna k??la"/><asula kood="7343" nimi="Saiakopli k??la"/><asula kood="7358" nimi="Saksi k??la"/><asula kood="7476" nimi="Sauv??lja k??la"/><asula kood="7481" nimi="Savalduma k??la"/><asula kood="7956" nimi="S????se alevik"/><asula kood="8130" nimi="Tamsalu linn"/><asula kood="8140" nimi="Tapa linn"/><asula kood="8549" nimi="T????rak??rve k??la"/><asula kood="8604" nimi="T??rje k??la"/><asula kood="8754" nimi="Uudek??la"/><asula kood="8820" nimi="Vadik??la"/><asula kood="8836" nimi="Vahakulmu k??la"/><asula kood="8903" nimi="Vajangu k??la"/><asula kood="9429" nimi="Vistla k??la"/><asula kood="9505" nimi="V??hmetu k??la"/><asula kood="9506" nimi="V??hmuta k??la"/></vald><vald kood="0901" nimi="Vinni vald"><asula kood="1025" nimi="Aarla k??la"/><asula kood="1043" nimi="Aasuv??lja k??la"/><asula kood="1182" nimi="Alavere k??la"/><asula kood="1193" nimi="Alekvere k??la"/><asula kood="1203" nimi="Allika k??la"/><asula kood="1275" nimi="Anguse k??la"/><asula kood="1331" nimi="Aravuse k??la"/><asula kood="1370" nimi="Arukse k??la"/><asula kood="1372" nimi="Aruk??la"/><asula kood="1395" nimi="Aruv??lja k??la"/><asula kood="2036" nimi="Ilistvere k??la"/><asula kood="2090" nimi="Inju k??la"/><asula kood="2424" nimi="Kaasiksaare k??la"/><asula kood="2484" nimi="Kadila k??la"/><asula kood="2555" nimi="Kakum??e k??la"/><asula kood="2679" nimi="Kannastiku k??la"/><asula kood="2689" nimi="Kantk??la"/><asula kood="2760" nimi="Karkuse k??la"/><asula kood="2872" nimi="Kaukvere k??la"/><asula kood="2919" nimi="Kehala k??la"/><asula kood="2941" nimi="Kellavere k??la"/><asula kood="3252" nimi="Koeravere k??la"/><asula kood="3577" nimi="Kulina k??la"/><asula kood="3809" nimi="K??rma k??la"/><asula kood="3994" nimi="K??ti k??la"/><asula kood="4035" nimi="Laekvere alevik"/><asula kood="4166" nimi="Lavi k??la"/><asula kood="4293" nimi="Lepiku k??la"/><asula kood="4589" nimi="Luusika k??la"/><asula kood="4634" nimi="L??htse k??la"/><asula kood="4948" nimi="Miila k??la"/><asula kood="4978" nimi="Moora k??la"/><asula kood="5105" nimi="Muuga k??la"/><asula kood="5114" nimi="M??driku k??la"/><asula kood="5117" nimi="M??edaka k??la"/><asula kood="5212" nimi="M??etaguse k??la"/><asula kood="5267" nimi="M??nnikv??lja k??la"/><asula kood="5465" nimi="Nurkse k??la"/><asula kood="5471" nimi="Nurmetu k??la"/><asula kood="5521" nimi="N??mmise k??la"/><asula kood="5585" nimi="Obja k??la"/><asula kood="5794" nimi="Paasvere k??la"/><asula kood="5814" nimi="Padu k??la"/><asula kood="5896" nimi="Pajusti alevik"/><asula kood="5923" nimi="Palasi k??la"/><asula kood="6182" nimi="Piira k??la"/><asula kood="6416" nimi="Puka k??la"/><asula kood="6535" nimi="P??lula k??la"/><asula kood="6729" nimi="Rahkla k??la"/><asula kood="6768" nimi="Rajak??la"/><asula kood="6829" nimi="Rasivere k??la"/><asula kood="7012" nimi="Ristik??la"/><asula kood="7028" nimi="Roela alevik"/><asula kood="7034" nimi="Rohu k??la"/><asula kood="7262" nimi="R??nga k??la"/><asula kood="7278" nimi="Saara k??la"/><asula kood="7325" nimi="Sae k??la"/><asula kood="7401" nimi="Salutaguse k??la"/><asula kood="7630" nimi="Sirevere k??la"/><asula kood="7733" nimi="Soonuka k??la"/><asula kood="7748" nimi="Sootaguse k??la"/><asula kood="7777" nimi="Suigu k??la"/><asula kood="8108" nimi="Tammiku k??la"/><asula kood="8390" nimi="Tudu alevik"/><asula kood="8661" nimi="Uljaste k??la"/><asula kood="8665" nimi="Ulvi k??la"/><asula kood="9009" nimi="Vana-Vinni k??la"/><asula kood="9118" nimi="Vassivere k??la"/><asula kood="9153" nimi="Veadla k??la"/><asula kood="9204" nimi="Venevere k??la"/><asula kood="9245" nimi="Vetiku k??la"/><asula kood="9375" nimi="Vinni alevik"/><asula kood="9394" nimi="Viru-Jaagupi alevik"/><asula kood="9395" nimi="Viru-Kabala k??la"/><asula kood="9467" nimi="Voore k??la"/><asula kood="9508" nimi="V??hu k??la"/></vald><vald kood="0903" nimi="Viru-Nigula vald"><asula kood="1037" nimi="Aasukalda k??la"/><asula kood="1402" nimi="Aseri alevik"/><asula kood="1405" nimi="Aseriaru k??la"/><asula kood="2019" nimi="Iila k??la"/><asula kood="2447" nimi="Kabeli k??la"/><asula kood="2583" nimi="Kalik??la"/><asula kood="2626" nimi="Kalvi k??la"/><asula kood="2675" nimi="Kanguristi k??la"/><asula kood="2986" nimi="Kestla k??la"/><asula kood="3179" nimi="Kivik??la"/><asula kood="3295" nimi="Koila k??la"/><asula kood="3394" nimi="Koogu k??la"/><asula kood="3610" nimi="Kunda k??la"/><asula kood="3612" nimi="Kunda linn"/><asula kood="3688" nimi="Kurna k??la"/><asula kood="3709" nimi="Kutsala k??la"/><asula kood="3725" nimi="Kuura k??la"/><asula kood="3803" nimi="K??rkk??la"/><asula kood="3814" nimi="K??rtsialuse k??la"/><asula kood="4305" nimi="Letipea k??la"/><asula kood="4408" nimi="Linnuse k??la"/><asula kood="4736" nimi="Mahu k??la"/><asula kood="4755" nimi="Malla k??la"/><asula kood="4786" nimi="Marinu k??la"/><asula kood="4926" nimi="Metsav??lja k??la"/><asula kood="5456" nimi="Nugeri k??la"/><asula kood="5651" nimi="Ojak??la"/><asula kood="5739" nimi="Oru k??la"/><asula kood="5791" nimi="Paask??la"/><asula kood="5804" nimi="Pada k??la"/><asula kood="5802" nimi="Pada-Aruk??la"/><asula kood="6219" nimi="Pikaristi k??la"/><asula kood="6612" nimi="P??rna k??la"/><asula kood="6821" nimi="Rannu k??la"/><asula kood="7407" nimi="Samma k??la"/><asula kood="7530" nimi="Selja k??la"/><asula kood="7557" nimi="Siberi k??la"/><asula kood="7602" nimi="Simunam??e k??la"/><asula kood="8303" nimi="Toomika k??la"/><asula kood="8602" nimi="T????kri k??la"/><asula kood="8704" nimi="Unukse k??la"/><asula kood="9096" nimi="Varudi k??la"/><asula kood="9121" nimi="Vasta k??la"/><asula kood="9351" nimi="Villavere k??la"/><asula kood="9399" nimi="Viru-Nigula alevik"/><asula kood="9578" nimi="V??rkla k??la"/></vald><vald kood="0928" nimi="V??ike-Maarja vald"><asula kood="1047" nimi="Aavere k??la"/><asula kood="1069" nimi="Aburi k??la"/><asula kood="1309" nimi="Ao k??la"/><asula kood="1476" nimi="Avanduse k??la"/><asula kood="1484" nimi="Avispea k??la"/><asula kood="1521" nimi="Ebavere k??la"/><asula kood="1529" nimi="Edru k??la"/><asula kood="1559" nimi="Eipri k??la"/><asula kood="1594" nimi="Emum??e k??la"/><asula kood="1866" nimi="Hirla k??la"/><asula kood="2080" nimi="Imukvere k??la"/><asula kood="2371" nimi="J????tma k??la"/><asula kood="2437" nimi="Kaavere k??la"/><asula kood="2480" nimi="Kadik??la"/><asula kood="2635" nimi="Kamariku k??la"/><asula kood="2934" nimi="Kellam??e k??la"/><asula kood="3092" nimi="Kiltsi alevik"/><asula kood="3162" nimi="Kitsemetsa k??la"/><asula kood="3297" nimi="Koila k??la"/><asula kood="3367" nimi="Koluvere k??la"/><asula kood="3410" nimi="Koonu k??la"/><asula kood="3692" nimi="Kurtna k??la"/><asula kood="3783" nimi="K??psta k??la"/><asula kood="3878" nimi="K??nnuk??la"/><asula kood="3924" nimi="K??rsa k??la"/><asula kood="3932" nimi="K??ru k??la"/><asula kood="4065" nimi="Lahu k??la"/><asula kood="4091" nimi="Lammask??la"/><asula kood="4125" nimi="Lasinurme k??la"/><asula kood="4339" nimi="Liigvalla k??la"/><asula kood="4356" nimi="Liivak??la"/><asula kood="5132" nimi="M??isamaa k??la"/><asula kood="5235" nimi="M??iste k??la"/><asula kood="5295" nimi="M????ri k??la"/><asula kood="5320" nimi="M????riku k??la"/><asula kood="5333" nimi="Nadalama k??la"/><asula kood="5508" nimi="N??mme k??la"/><asula kood="5529" nimi="N??mmk??la"/><asula kood="5661" nimi="Olju k??la"/><asula kood="5716" nimi="Orguse k??la"/><asula kood="5805" nimi="Padak??la"/><asula kood="5970" nimi="Pandivere k??la"/><asula kood="6158" nimi="Piibe k??la"/><asula kood="6230" nimi="Pikevere k??la"/><asula kood="6382" nimi="Pudivere k??la"/><asula kood="6716" nimi="Raek??la"/><asula kood="6756" nimi="Raigu k??la"/><asula kood="6775" nimi="Rakke alevik"/><asula kood="6836" nimi="Rastla k??la"/><asula kood="7202" nimi="R??itsvere k??la"/><asula kood="7385" nimi="Salla k??la"/><asula kood="7412" nimi="Sandimetsa k??la"/><asula kood="7603" nimi="Simuna alevik"/><asula kood="7746" nimi="Sootaguse k??la"/><asula kood="7831" nimi="Suure-Rakke k??la"/><asula kood="8115" nimi="Tammiku k??la"/><asula kood="8348" nimi="Triigi k??la"/><asula kood="8770" nimi="Uuem??isa k??la"/><asula kood="9048" nimi="Vao k??la"/><asula kood="9056" nimi="Varangu k??la"/><asula kood="9347" nimi="Villakvere k??la"/><asula kood="9485" nimi="Vorsti k??la"/><asula kood="9549" nimi="V??ivere k??la"/><asula kood="9628" nimi="V??ike-Maarja alevik"/><asula kood="9647" nimi="V??ike-Rakke k??la"/><asula kood="9648" nimi="V??ike-Tammiku k??la"/><asula kood="9777" nimi="??ntu k??la"/><asula kood="9783" nimi="??rina k??la"/></vald></maakond><maakond kood="0064" nimi="P??lva maakond"><vald kood="0284" nimi="Kanepi vald"><asula kood="1058" nimi="Abissaare k??la"/><asula kood="1131" nimi="Aiaste k??la"/><asula kood="1620" nimi="Erastvere k??la"/><asula kood="1785" nimi="Hauka k??la"/><asula kood="1799" nimi="Heisri k??la"/><asula kood="1857" nimi="Hino k??la"/><asula kood="1914" nimi="Hurmi k??la"/><asula kood="1960" nimi="H????taru k??la"/><asula kood="2007" nimi="Ihamaru k??la"/><asula kood="2259" nimi="J??gehara k??la"/><asula kood="2277" nimi="J??ksi k??la"/><asula kood="2387" nimi="Kaagna k??la"/><asula kood="2392" nimi="Kaagvere k??la"/><asula kood="2667" nimi="Kanepi alevik"/><asula kood="2707" nimi="Karaski k??la"/><asula kood="2727" nimi="Karilatsi k??la"/><asula kood="2769" nimi="Karste k??la"/><asula kood="3280" nimi="Koigera k??la"/><asula kood="3399" nimi="Kooli k??la"/><asula kood="3415" nimi="Kooraste k??la"/><asula kood="3505" nimi="Krootuse k??la"/><asula kood="3511" nimi="Kr????dneri k??la"/><asula kood="4156" nimi="Lauri k??la"/><asula kood="4707" nimi="Maaritsa k??la"/><asula kood="4730" nimi="Magari k??la"/><asula kood="5314" nimi="M??gra k??la"/><asula kood="5557" nimi="N??rap???? k??la"/><asula kood="5959" nimi="Palutaja k??la"/><asula kood="6089" nimi="Peetrim??isa k??la"/><asula kood="6163" nimi="Piigandi k??la"/><asula kood="6167" nimi="Piigaste k??la"/><asula kood="6209" nimi="Pikaj??rve k??la"/><asula kood="6217" nimi="Pikareinu k??la"/><asula kood="6354" nimi="Prangli k??la"/><asula kood="6472" nimi="Puugi k??la"/><asula kood="6520" nimi="P??lgaste k??la"/><asula kood="6889" nimi="Rebaste k??la"/><asula kood="7486" nimi="Saverna k??la"/><asula kood="7645" nimi="Sirvaste k??la"/><asula kood="7696" nimi="Soodoma k??la"/><asula kood="7785" nimi="Sulaoja k??la"/><asula kood="7897" nimi="S??reste k??la"/><asula kood="8217" nimi="Tiido k??la"/><asula kood="8455" nimi="Tuulem??e k??la"/><asula kood="8469" nimi="T??du k??la"/><asula kood="8932" nimi="Valgj??rve k??la"/><asula kood="9066" nimi="Varbuse k??la"/><asula kood="9229" nimi="Veski k??la"/><asula kood="9422" nimi="Vissi k??la"/><asula kood="9472" nimi="Voorepalu k??la"/></vald><vald kood="0622" nimi="P??lva vald"><asula kood="1027" nimi="Aarna k??la"/><asula kood="1081" nimi="Adiste k??la"/><asula kood="1116" nimi="Ahja alevik"/><asula kood="1156" nimi="Akste k??la"/><asula kood="1261" nimi="Andre k??la"/><asula kood="1609" nimi="Eoste k??la"/><asula kood="1844" nimi="Himma k??la"/><asula kood="1846" nimi="Himmaste k??la"/><asula kood="1885" nimi="Holvandi k??la"/><asula kood="1980" nimi="Ibaste k??la"/><asula kood="2142" nimi="Jaanim??isa k??la"/><asula kood="2197" nimi="Joosu k??la"/><asula kood="2419" nimi="Kaaru k??la"/><asula kood="2471" nimi="Kadaja k??la"/><asula kood="2654" nimi="Kanassaare k??la"/><asula kood="2728" nimi="Karilatsi k??la"/><asula kood="2831" nimi="Kastmekoja k??la"/><asula kood="2869" nimi="Kauksi k??la"/><asula kood="3030" nimi="Kiidj??rve k??la"/><asula kood="3050" nimi="Kiisa k??la"/><asula kood="3170" nimi="Kiuma k??la"/><asula kood="3422" nimi="Koorvere k??la"/><asula kood="3469" nimi="Kosova k??la"/><asula kood="3863" nimi="K??hri k??la"/><asula kood="3923" nimi="K??rsa k??la"/><asula kood="4051" nimi="Lahe k??la"/><asula kood="4062" nimi="Laho k??la"/><asula kood="4198" nimi="Leevij??e k??la"/><asula kood="4446" nimi="Logina k??la"/><asula kood="4468" nimi="Loko k??la"/><asula kood="4522" nimi="Lootvina k??la"/><asula kood="4575" nimi="Lutsu k??la"/><asula kood="4769" nimi="Mammaste k??la"/><asula kood="4851" nimi="Meemaste k??la"/><asula kood="4938" nimi="Metste k??la"/><asula kood="4945" nimi="Miiaste k??la"/><asula kood="4986" nimi="Mooste alevik"/><asula kood="5059" nimi="Mustaj??e k??la"/><asula kood="5061" nimi="Mustakurmu k??la"/><asula kood="5170" nimi="M??tsk??la"/><asula kood="5355" nimi="Naruski k??la"/><asula kood="5445" nimi="Nooritsmetsa k??la"/><asula kood="5705" nimi="Oraj??e k??la"/><asula kood="5809" nimi="Padari k??la"/><asula kood="6025" nimi="Partsi k??la"/><asula kood="6120" nimi="Peri k??la"/><asula kood="6347" nimi="Pragi k??la"/><asula kood="6461" nimi="Puskaru k??la"/><asula kood="6477" nimi="Puuri k??la"/><asula kood="6536" nimi="P??lva linn"/><asula kood="6825" nimi="Rasina k??la"/><asula kood="7071" nimi="Roosi k??la"/><asula kood="7098" nimi="Rosma k??la"/><asula kood="7501" nimi="Savim??e k??la"/><asula kood="7660" nimi="Soesaare k??la"/><asula kood="7855" nimi="Suurk??la"/><asula kood="7858" nimi="Suurmetsa k??la"/><asula kood="7918" nimi="S??kna k??la"/><asula kood="7964" nimi="S????ssaare k??la"/><asula kood="8028" nimi="Taevaskoja k??la"/><asula kood="8198" nimi="Terepi k??la"/><asula kood="8243" nimi="Tilsi k??la"/><asula kood="8353" nimi="Tromsi k??la"/><asula kood="8574" nimi="T??nnassilma k??la"/><asula kood="8644" nimi="Uibuj??rve k??la"/><asula kood="8922" nimi="Valgemetsa k??la"/><asula kood="8927" nimi="Valgesoo k??la"/><asula kood="8989" nimi="Vana-Koiola k??la"/><asula kood="9010" nimi="Vanak??la"/><asula kood="9023" nimi="Vanam??isa k??la"/><asula kood="9072" nimi="Vardja k??la"/><asula kood="9128" nimi="Vastse-Kuuste alevik"/><asula kood="9300" nimi="Viisli k??la"/><asula kood="9470" nimi="Voorek??la"/></vald><vald kood="0708" nimi="R??pina vald"><asula kood="1329" nimi="Aravu k??la"/><asula kood="1705" nimi="Haavametsa k??la"/><asula kood="1706" nimi="Haavap???? k??la"/><asula kood="1849" nimi="Himmiste k??la"/><asula kood="2140" nimi="Jaanikeste k??la"/><asula kood="2241" nimi="J??epera k??la"/><asula kood="2252" nimi="J??evaara k??la"/><asula kood="2256" nimi="J??eveere k??la"/><asula kood="2815" nimi="Kassilaane k??la"/><asula kood="3066" nimi="Kikka k??la"/><asula kood="3145" nimi="Kirmsi k??la"/><asula kood="3405" nimi="Koolma k??la"/><asula kood="3406" nimi="Koolmaj??rve k??la"/><asula kood="3589" nimi="Kullam??e k??la"/><asula kood="3629" nimi="Kunksilla k??la"/><asula kood="3770" nimi="K??nnu k??la"/><asula kood="3963" nimi="K??strim??e k??la"/><asula kood="4066" nimi="Laho k??la"/><asula kood="4193" nimi="Leevaku k??la"/><asula kood="4195" nimi="Leevi k??la"/><asula kood="4326" nimi="Lihtensteini k??la"/><asula kood="4410" nimi="Linte k??la"/><asula kood="4842" nimi="Meeksi k??la"/><asula kood="4849" nimi="Meelva k??la"/><asula kood="4854" nimi="Meerapalu k??la"/><asula kood="4859" nimi="Mehikoorma alevik"/><asula kood="4911" nimi="M??tsavaara k??la"/><asula kood="5221" nimi="M??giotsa k??la"/><asula kood="5269" nimi="M??nnisalu k??la"/><asula kood="5340" nimi="Naha k??la"/><asula kood="5437" nimi="Nohipalo k??la"/><asula kood="5459" nimi="Nulga k??la"/><asula kood="5857" nimi="Pahtp???? k??la"/><asula kood="5992" nimi="Parapalu k??la"/><asula kood="6268" nimi="Pindi k??la"/><asula kood="6631" nimi="P????sna k??la"/><asula kood="6677" nimi="Raadama k??la"/><asula kood="6743" nimi="Rahum??e k??la"/><asula kood="6753" nimi="Raigla k??la"/><asula kood="7016" nimi="Ristipalo k??la"/><asula kood="7151" nimi="Ruusa k??la"/><asula kood="7216" nimi="R??pina linn"/><asula kood="7289" nimi="Saarek??la"/><asula kood="7439" nimi="Sarvem??e k??la"/><asula kood="7579" nimi="Sikakurmu k??la"/><asula kood="7595" nimi="Sillap???? k??la"/><asula kood="7698" nimi="Soohara k??la"/><asula kood="7835" nimi="Suure-Veerksu k??la"/><asula kood="7975" nimi="S??lgoja k??la"/><asula kood="7981" nimi="S??vahavva k??la"/><asula kood="8244" nimi="Timo k??la"/><asula kood="8289" nimi="Toolamaa k??la"/><asula kood="8313" nimi="Tooste k??la"/><asula kood="8370" nimi="Tsirksi k??la"/><asula kood="9080" nimi="Vareste k??la"/><asula kood="9223" nimi="Veriora alevik"/><asula kood="9224" nimi="Verioram??isa k??la"/><asula kood="9294" nimi="Viira k??la"/><asula kood="9369" nimi="Viluste k??la"/><asula kood="9377" nimi="Vinso k??la"/><asula kood="9511" nimi="V??iardi k??la"/><asula kood="9527" nimi="V??ika k??la"/><asula kood="9599" nimi="V??uk??la"/><asula kood="9608" nimi="V????psu alevik"/><asula kood="9175" nimi="V??ike-Veerksu k??la"/><asula kood="9664" nimi="V??ndra k??la"/></vald></maakond><maakond kood="0068" nimi="P??rnu maakond"><vald kood="0214" nimi="H????demeeste vald"><asula kood="1378" nimi="Arumetsa k??la"/><asula kood="1957" nimi="H????demeeste alevik"/><asula kood="2029" nimi="Ikla k??la"/><asula kood="2124" nimi="Jaagupi k??la"/><asula kood="2463" nimi="Kabli k??la"/><asula kood="3508" nimi="Krundik??la"/><asula kood="4004" nimi="Laadi k??la"/><asula kood="4232" nimi="Leina k??la"/><asula kood="4284" nimi="Lepak??la"/><asula kood="4746" nimi="Majaka k??la"/><asula kood="4805" nimi="Massiaru k??la"/><asula kood="4874" nimi="Merek??la"/><asula kood="4892" nimi="Metsak??la"/><asula kood="4908" nimi="Metsapoole k??la"/><asula kood="5403" nimi="Nepste k??la"/><asula kood="5706" nimi="Oraj??e k??la"/><asula kood="5984" nimi="Papisilla k??la"/><asula kood="6103" nimi="Penu k??la"/><asula kood="6194" nimi="Piirumi k??la"/><asula kood="6420" nimi="Pulgoja k??la"/><asula kood="6811" nimi="Rannametsa k??la"/><asula kood="6925" nimi="Reiu k??la"/><asula kood="7706" nimi="Sook??la"/><asula kood="7717" nimi="Soometsa k??la"/><asula kood="8072" nimi="Tahkuranna k??la"/><asula kood="8340" nimi="Treimani k??la"/><asula kood="8724" nimi="Urissaare k??la"/><asula kood="8767" nimi="Uuemaa k??la"/><asula kood="8779" nimi="Uulu k??la"/><asula kood="9521" nimi="V??idu k??la"/><asula kood="9539" nimi="V??iste alevik"/></vald><vald kood="0303" nimi="Kihnu vald"><asula kood="4276" nimi="Lemsi k??la"/><asula kood="4381" nimi="Linak??la"/><asula kood="7089" nimi="Rootsik??la"/><asula kood="7951" nimi="S????re k??la"/></vald><vald kood="0430" nimi="L????neranna vald"><asula kood="1169" nimi="Alak??la"/><asula kood="1204" nimi="Allika k??la"/><asula kood="1366" nimi="Aruk??la"/><asula kood="1591" nimi="Emmu k??la"/><asula kood="1649" nimi="Esivere k??la"/><asula kood="1690" nimi="Haapsi k??la"/><asula kood="1757" nimi="Hanila k??la"/><asula kood="1814" nimi="Helmk??la"/><asula kood="1921" nimi="H??beda k??la"/><asula kood="1929" nimi="H??besalu k??la"/><asula kood="1936" nimi="H??lvati k??la"/><asula kood="2102" nimi="Irta k??la"/><asula kood="2106" nimi="Iska k??la"/><asula kood="2192" nimi="Joonuse k??la"/><asula kood="2255" nimi="J??e????re k??la"/><asula kood="2316" nimi="J??nistvere k??la"/><asula kood="2323" nimi="J??rise k??la"/><asula kood="2349" nimi="J??rve k??la"/><asula kood="2473" nimi="Kadaka k??la"/><asula kood="2606" nimi="Kalli k??la"/><asula kood="2651" nimi="Kanamardi k??la"/><asula kood="2732" nimi="Karin??mme k??la"/><asula kood="2777" nimi="Karuba k??la"/><asula kood="2784" nimi="Karuse k??la"/><asula kood="2792" nimi="Kasek??la"/><asula kood="2879" nimi="Kause k??la"/><asula kood="2912" nimi="Keemu k??la"/><asula kood="2946" nimi="Kelu k??la"/><asula kood="2999" nimi="Kibura k??la"/><asula kood="3006" nimi="Kidise k??la"/><asula kood="3049" nimi="Kiisamaa k??la"/><asula kood="3082" nimi="Kilgi k??la"/><asula kood="3099" nimi="Kinksi k??la"/><asula kood="3113" nimi="Kirbla k??la"/><asula kood="7782" nimi="Kirikuk??la"/><asula kood="3159" nimi="Kiska k??la"/><asula kood="3210" nimi="Kloostri k??la"/><asula kood="3251" nimi="Koeri k??la"/><asula kood="3326" nimi="Kokuta k??la"/><asula kood="3407" nimi="Koonga k??la"/><asula kood="3445" nimi="Korju k??la"/><asula kood="3524" nimi="Kuhu k??la"/><asula kood="3552" nimi="Kuke k??la"/><asula kood="3593" nimi="Kulli k??la"/><asula kood="3616" nimi="Kunila k??la"/><asula kood="3654" nimi="Kurese k??la"/><asula kood="3739" nimi="K??era k??la"/><asula kood="8091" nimi="K??ima k??la"/><asula kood="3765" nimi="K??msi k??la"/><asula kood="3930" nimi="K??ru k??la"/><asula kood="4149" nimi="Laulepa k??la"/><asula kood="4163" nimi="Lautna k??la"/><asula kood="4330" nimi="Lihula linn"/><asula kood="4406" nimi="Linnuse k??la"/><asula kood="4429" nimi="Liustem??e k??la"/><asula kood="4607" nimi="L??o k??la"/><asula kood="4611" nimi="L??pe k??la"/><asula kood="4695" nimi="Maade k??la"/><asula kood="4742" nimi="Maikse k??la"/><asula kood="4807" nimi="Massu k??la"/><asula kood="4820" nimi="Matsalu k??la"/><asula kood="4824" nimi="Matsi k??la"/><asula kood="4847" nimi="Meelva k??la"/><asula kood="4881" nimi="Mere????rse k??la"/><asula kood="4929" nimi="Metsk??la"/><asula kood="4942" nimi="Mihkli k??la"/><asula kood="5049" nimi="Muriste k??la"/><asula kood="5127" nimi="M??isak??la"/><asula kood="5174" nimi="M??isimaa k??la"/><asula kood="5173" nimi="M??tsu k??la"/><asula kood="5202" nimi="M??ense k??la"/><asula kood="5247" nimi="M??lik??la"/><asula kood="5344" nimi="Naissoo k??la"/><asula kood="5385" nimi="Nedrema k??la"/><asula kood="5399" nimi="Nehatu k??la"/><asula kood="5464" nimi="Nurme k??la"/><asula kood="5473" nimi="Nurmsi k??la"/><asula kood="5530" nimi="N??mme k??la"/><asula kood="5563" nimi="N??tsi k??la"/><asula kood="5638" nimi="Oidrema k??la"/><asula kood="5776" nimi="Paadrema k??la"/><asula kood="5801" nimi="Paatsalu k??la"/><asula kood="5845" nimi="Pagasi k??la"/><asula kood="5869" nimi="Paimvere k??la"/><asula kood="5889" nimi="Pajumaa k??la"/><asula kood="5924" nimi="Palatu k??la"/><asula kood="5990" nimi="Parasmaa k??la"/><asula kood="6013" nimi="Parivere k??la"/><asula kood="6055" nimi="Peanse k??la"/><asula kood="6054" nimi="Peantse k??la"/><asula kood="6096" nimi="Penij??e k??la"/><asula kood="6131" nimi="Petaaluse k??la"/><asula kood="6135" nimi="Piha k??la"/><asula kood="6200" nimi="Piisu k??la"/><asula kood="6227" nimi="Pikavere k??la"/><asula kood="6286" nimi="Pivarootsi k??la"/><asula kood="6302" nimi="Poanse k??la"/><asula kood="6707" nimi="Rabavere k??la"/><asula kood="6717" nimi="Raespa k??la"/><asula kood="6722" nimi="Raheste k??la"/><asula kood="6778" nimi="Rame k??la"/><asula kood="6802" nimi="Rannak??la"/><asula kood="6827" nimi="Rannu k??la"/><asula kood="6865" nimi="Rauksi k??la"/><asula kood="6961" nimi="Ridase k??la"/><asula kood="7064" nimi="Rooglaiu k??la"/><asula kood="7087" nimi="Rootsi k??la"/><asula kood="7091" nimi="Rootsi-Aruk??la"/><asula kood="7117" nimi="Rumba k??la"/><asula kood="7259" nimi="R??di k??la"/><asula kood="7287" nimi="Saare k??la"/><asula kood="7310" nimi="Saastna k??la"/><asula kood="7373" nimi="Salavere k??la"/><asula kood="7379" nimi="Salevere k??la"/><asula kood="7462" nimi="Saulepi k??la"/><asula kood="7511" nimi="Seira k??la"/><asula kood="7519" nimi="Seli k??la"/><asula kood="7532" nimi="Selja k??la"/><asula kood="7699" nimi="Sookalda k??la"/><asula kood="7702" nimi="Sookatse k??la"/><asula kood="7749" nimi="Soov??lja k??la"/><asula kood="8088" nimi="Tamba k??la"/><asula kood="8092" nimi="Tamme k??la"/><asula kood="8157" nimi="Tarva k??la"/><asula kood="8220" nimi="Tiilima k??la"/><asula kood="8401" nimi="Tuhu k??la"/><asula kood="8446" nimi="Tuudi k??la"/><asula kood="8478" nimi="T??itse k??la"/><asula kood="8541" nimi="T??usi k??la"/><asula kood="8577" nimi="T??psi k??la"/><asula kood="8663" nimi="Ullaste k??la"/><asula kood="8666" nimi="Uluste k??la"/><asula kood="8712" nimi="Ura k??la"/><asula kood="8722" nimi="Urita k??la"/><asula kood="8830" nimi="Vagivere k??la"/><asula kood="8893" nimi="Vaiste k??la"/><asula kood="8974" nimi="Valuste k??la"/><asula kood="9035" nimi="Vanam??isa k??la"/><asula kood="9061" nimi="Varbla k??la"/><asula kood="9134" nimi="Vastaba k??la"/><asula kood="9141" nimi="Vatla k??la"/><asula kood="9192" nimi="Veltsa k??la"/><asula kood="9388" nimi="Virtsu alevik"/><asula kood="9478" nimi="Voose k??la"/><asula kood="9499" nimi="V??hma k??la"/><asula kood="9528" nimi="V??igaste k??la"/><asula kood="9544" nimi="V??itra k??la"/><asula kood="9584" nimi="V??rungi k??la"/><asula kood="9691" nimi="??epa k??la"/><asula kood="9791" nimi="??hu k??la"/><asula kood="9742" nimi="??ila k??la"/><asula kood="1603" nimi="??nnikse k??la"/></vald><vald kood="0638" nimi="P??hja-P??rnumaa vald"><asula kood="1030" nimi="Aasa k??la"/><asula kood="1215" nimi="Allik??nnu k??la"/><asula kood="1214" nimi="Altk??la"/><asula kood="1237" nimi="Aluste k??la"/><asula kood="1267" nimi="Anelema k??la"/><asula kood="1314" nimi="Arase k??la"/><asula kood="1506" nimi="Eametsa k??la"/><asula kood="1527" nimi="Eense k??la"/><asula kood="1531" nimi="Eerma k??la"/><asula kood="1602" nimi="Enge k??la"/><asula kood="1634" nimi="Ertsma k??la"/><asula kood="1736" nimi="Halinga k??la"/><asula kood="1802" nimi="Helenurme k??la"/><asula kood="2400" nimi="Kaansoo k??la"/><asula kood="2462" nimi="Kablima k??la"/><asula kood="2486" nimi="Kadjaste k??la"/><asula kood="2493" nimi="Kaelase k??la"/><asula kood="2545" nimi="Kaisma k??la"/><asula kood="2619" nimi="Kalmaru k??la"/><asula kood="2669" nimi="Kangru k??la"/><asula kood="2969" nimi="Kergu k??la"/><asula kood="3127" nimi="Kirikum??isa k??la"/><asula kood="3219" nimi="Kobra k??la"/><asula kood="3237" nimi="Kodesmaa k??la"/><asula kood="3459" nimi="Kose k??la"/><asula kood="3599" nimi="Kullimaa k??la"/><asula kood="3617" nimi="Kuninga k??la"/><asula kood="3666" nimi="Kurgja k??la"/><asula kood="3771" nimi="K??nnu k??la"/><asula kood="4101" nimi="Langerma k??la"/><asula kood="4190" nimi="Leetva k??la"/><asula kood="4216" nimi="Lehtmetsa k??la"/><asula kood="4219" nimi="Lehu k??la"/><asula kood="4320" nimi="Libatse k??la"/><asula kood="4504" nimi="Loomse k??la"/><asula kood="4586" nimi="Luuri k??la"/><asula kood="4696" nimi="L????ste k??la"/><asula kood="4743" nimi="Maima k??la"/><asula kood="4808" nimi="Massu k??la"/><asula kood="4891" nimi="Metsak??la"/><asula kood="4913" nimi="Metsavere k??la"/><asula kood="5072" nimi="Mustaru k??la"/><asula kood="5137" nimi="M??isak??la"/><asula kood="5185" nimi="M??dara k??la"/><asula kood="5191" nimi="M??ek??la"/><asula kood="5328" nimi="Naartse k??la"/><asula kood="5610" nimi="Oese k??la"/><asula kood="5720" nimi="Orik??la"/><asula kood="5935" nimi="Pallika k??la"/><asula kood="6113" nimi="Perek??la"/><asula kood="6278" nimi="Pitsalu k??la"/><asula kood="6616" nimi="P??rnj??e k??la"/><asula kood="6617" nimi="P??rnu-Jaagupi alev"/><asula kood="6646" nimi="P????ravere k??la"/><asula kood="6714" nimi="Rae k??la"/><asula kood="6725" nimi="Rahkama k??la"/><asula kood="6732" nimi="Rahnoja k??la"/><asula kood="6921" nimi="Reinumurru k??la"/><asula kood="7061" nimi="Roodi k??la"/><asula kood="7108" nimi="Rukkik??la"/><asula kood="7186" nimi="R??usa k??la"/><asula kood="7229" nimi="R??tsepa k??la"/><asula kood="7391" nimi="Salu k??la"/><asula kood="7406" nimi="Samliku k??la"/><asula kood="7541" nimi="Sepak??la"/><asula kood="7581" nimi="Sikana k??la"/><asula kood="7661" nimi="Sohlu k??la"/><asula kood="7739" nimi="Soosalu k??la"/><asula kood="7838" nimi="Suurej??e k??la"/><asula kood="7912" nimi="S????rike k??la"/><asula kood="7967" nimi="S????stla k??la"/><asula kood="8055" nimi="Tagassaare k??la"/><asula kood="8156" nimi="Tarva k??la"/><asula kood="8316" nimi="Tootsi alev"/><asula kood="8510" nimi="T??rdu k??la"/><asula kood="8588" nimi="T??hjasma k??la"/><asula kood="8843" nimi="Vahenurme k??la"/><asula kood="8901" nimi="Vakalepa k??la"/><asula kood="8909" nimi="Vaki k??la"/><asula kood="8947" nimi="Valistre k??la"/><asula kood="9164" nimi="Vee k??la"/><asula kood="9199" nimi="Venekuusiku k??la"/><asula kood="9237" nimi="Veskisoo k??la"/><asula kood="9267" nimi="Vihtra k??la"/><asula kood="9372" nimi="Viluvere k??la"/><asula kood="9524" nimi="V??idula k??la"/><asula kood="9526" nimi="V??iera k??la"/><asula kood="9663" nimi="V??ndra alev"/><asula kood="9842" nimi="??nnaste k??la"/></vald><vald kood="0624" nimi="P??rnu linn"><asula kood="1107" nimi="Ahaste k??la"/><asula kood="1229" nimi="Alu k??la"/><asula kood="1394" nimi="Aruv??lja k??la"/><asula kood="1458" nimi="Audru alevik"/><asula kood="1513" nimi="Eassalu k??la"/><asula kood="1628" nimi="Ermistu k??la"/><asula kood="2289" nimi="J????pre k??la"/><asula kood="2468" nimi="Kabriste k??la"/><asula kood="2834" nimi="Kastna k??la"/><asula kood="2893" nimi="Kavaru k??la"/><asula kood="3014" nimi="Kihlepa k??la"/><asula kood="3109" nimi="Kiraste k??la"/><asula kood="3746" nimi="K??ima k??la"/><asula kood="3784" nimi="K??pu k??la"/><asula kood="3891" nimi="K??rbu k??la"/><asula kood="4109" nimi="Lao k??la"/><asula kood="4165" nimi="Lavassaare alev"/><asula kood="4268" nimi="Lemmetsa k??la"/><asula kood="4354" nimi="Liiva k??la"/><asula kood="4384" nimi="Lindi k??la"/><asula kood="4430" nimi="Liu k??la"/><asula kood="4617" nimi="L??uka k??la"/><asula kood="4753" nimi="Malda k??la"/><asula kood="4771" nimi="Manija k??la"/><asula kood="4792" nimi="Marksa k??la"/><asula kood="5264" nimi="M??nnikuste k??la"/><asula kood="5578" nimi="Oara k??la"/><asula kood="5864" nimi="Paikuse alev"/><asula kood="5986" nimi="Papsaare k??la"/><asula kood="6082" nimi="Peerni k??la"/><asula kood="6325" nimi="Pootsi k??la"/><asula kood="6499" nimi="P??hara k??la"/><asula kood="6513" nimi="P??ldeotsa k??la"/><asula kood="6518" nimi="P??lendmaa k??la"/><asula kood="6595" nimi="P??rak??la"/><asula kood="6619" nimi="P??rnu linn"/><asula kood="6783" nimi="Rammuka k??la"/><asula kood="6819" nimi="Ranniku k??la"/><asula kood="6962" nimi="Ridalepa k??la"/><asula kood="7300" nimi="Saari k??la"/><asula kood="7460" nimi="Saulepa k??la"/><asula kood="7526" nimi="Seliste k??la"/><asula kood="7536" nimi="Seljametsa k??la"/><asula kood="7591" nimi="Silla k??la"/><asula kood="7663" nimi="Soeva k??la"/><asula kood="7723" nimi="Soomra k??la"/><asula kood="8131" nimi="Tammuru k??la"/><asula kood="8463" nimi="Tuuraste k??la"/><asula kood="8475" nimi="T??hela k??la"/><asula kood="8488" nimi="T??lli k??la"/><asula kood="8540" nimi="T??stamaa alevik"/><asula kood="8924" nimi="Valgeranna k??la"/><asula kood="9113" nimi="Vaskr????ma k??la"/><asula kood="9669" nimi="V??rati k??la"/></vald><vald kood="0712" nimi="Saarde vald"><asula kood="1217" nimi="Allikukivi k??la"/><asula kood="2062" nimi="Ilvese k??la"/><asula kood="2132" nimi="Jaamak??la"/><asula kood="2370" nimi="J????rja k??la"/><asula kood="2572" nimi="Kalda k??la"/><asula kood="2588" nimi="Kalita k??la"/><asula kood="2631" nimi="Kamali k??la"/><asula kood="2648" nimi="Kanak??la"/><asula kood="3061" nimi="Kikepera k??la"/><asula kood="3083" nimi="Kilingi-N??mme linn"/><asula kood="3840" nimi="K??veri k??la"/><asula kood="3928" nimi="K??rsu k??la"/><asula kood="1421" nimi="Laiksaare k??la"/><asula kood="4104" nimi="Lanksaare k??la"/><asula kood="4235" nimi="Leipste k??la"/><asula kood="4440" nimi="Lodja k??la"/><asula kood="4628" nimi="L??hkma k??la"/><asula kood="4782" nimi="Marana k??la"/><asula kood="4787" nimi="Marina k??la"/><asula kood="4916" nimi="Metsa????re k??la"/><asula kood="5085" nimi="Mustla k??la"/><asula kood="5640" nimi="Oissaare k??la"/><asula kood="6143" nimi="Pihke k??la"/><asula kood="6705" nimi="Rabak??la"/><asula kood="6919" nimi="Reinu k??la"/><asula kood="7013" nimi="Ristik??la"/><asula kood="7280" nimi="Saarde k??la"/><asula kood="7463" nimi="Saunametsa k??la"/><asula kood="7560" nimi="Sigaste k??la"/><asula kood="7807" nimi="Surju k??la"/><asula kood="8083" nimi="Tali k??la"/><asula kood="8213" nimi="Tihemetsa alevik"/><asula kood="8458" nimi="Tuuliku k??la"/><asula kood="8485" nimi="T??lla k??la"/><asula kood="9166" nimi="Veelikse k??la"/><asula kood="9297" nimi="Viisireiu k??la"/><asula kood="9652" nimi="V??ljak??la"/></vald><vald kood="0809" nimi="Tori vald"><asula kood="1091" nimi="Aesoo k??la"/><asula kood="1344" nimi="Are alevik"/><asula kood="1510" nimi="Eametsa k??la"/><asula kood="1516" nimi="Eavere k??la"/><asula kood="1574" nimi="Elbi k??la"/><asula kood="1576" nimi="Elbu k??la"/><asula kood="2251" nimi="J??esuu k??la"/><asula kood="3046" nimi="Kiisa k??la"/><asula kood="3077" nimi="Kildemaa k??la"/><asula kood="3084" nimi="Kilksama k??la"/><asula kood="3526" nimi="Kuiaru k??la"/><asula kood="3648" nimi="Kurena k??la"/><asula kood="3812" nimi="K??rsa k??la"/><asula kood="4296" nimi="Lepplaane k??la"/><asula kood="4314" nimi="Levi k??la"/><asula kood="4774" nimi="Mannare k??la"/><asula kood="5036" nimi="Muraka k??la"/><asula kood="5053" nimi="Murru k??la"/><asula kood="5101" nimi="Muti k??la"/><asula kood="5417" nimi="Niidu k??la"/><asula kood="5468" nimi="Nurme k??la"/><asula kood="5698" nimi="Oore k??la"/><asula kood="6012" nimi="Parisselja k??la"/><asula kood="6201" nimi="Piistaoja k??la"/><asula kood="6425" nimi="Pulli k??la"/><asula kood="6608" nimi="P??rivere k??la"/><asula kood="6792" nimi="Randiv??lja k??la"/><asula kood="6986" nimi="Riisa k??la"/><asula kood="5292" nimi="R??tsepa k??la"/><asula kood="7237" nimi="R????gu k??la"/><asula kood="7265" nimi="R??tavere k??la"/><asula kood="7455" nimi="Sauga alevik"/><asula kood="7529" nimi="Selja k??la"/><asula kood="7607" nimi="Sindi linn"/><asula kood="7776" nimi="Suigu k??la"/><asula kood="7996" nimi="Taali k??la"/><asula kood="8019" nimi="Tabria k??la"/><asula kood="8120" nimi="Tammiste k??la"/><asula kood="8269" nimi="Tohera k??la"/><asula kood="8326" nimi="Tori alevik"/><asula kood="8720" nimi="Urge k??la"/><asula kood="8730" nimi="Urumarja k??la"/><asula kood="8885" nimi="Vainu k??la"/><asula kood="9555" nimi="V??lla k??la"/><asula kood="9560" nimi="V??lli k??la"/></vald></maakond><maakond kood="0071" nimi="Rapla maakond"><vald kood="0293" nimi="Kehtna vald"><asula kood="1110" nimi="Ahek??nnu k??la"/><asula kood="1550" nimi="Eidapere alevik"/><asula kood="1583" nimi="Ellamaa k??la"/><asula kood="1684" nimi="Haakla k??la"/><asula kood="1826" nimi="Hertu k??la"/><asula kood="1830" nimi="Hiie k??la"/><asula kood="2087" nimi="Ingliste k??la"/><asula kood="2346" nimi="J??rvakandi alev"/><asula kood="2496" nimi="Kaerepere alevik"/><asula kood="2498" nimi="Kaerepere k??la"/><asula kood="2567" nimi="Kalbu k??la"/><asula kood="2835" nimi="Kastna k??la"/><asula kood="2903" nimi="Keava alevik"/><asula kood="2924" nimi="Kehtna alevik"/><asula kood="2900" nimi="Kehtna-Nurme k??la"/><asula kood="2952" nimi="Kenni k??la"/><asula kood="3389" nimi="Koogim??e k??la"/><asula kood="3391" nimi="Koogiste k??la"/><asula kood="3606" nimi="Kumma k??la"/><asula kood="3785" nimi="K??rbja k??la"/><asula kood="3846" nimi="K??bik??la"/><asula kood="3919" nimi="K??rpla k??la"/><asula kood="4038" nimi="Laeste k??la"/><asula kood="4084" nimi="Lalli k??la"/><asula kood="4133" nimi="Lau k??la"/><asula kood="4248" nimi="Lellapere k??la"/><asula kood="2923" nimi="Lellapere-Nurme k??la"/><asula kood="4250" nimi="Lelle alevik"/><asula kood="4392" nimi="Linnaaluste k??la"/><asula kood="4476" nimi="Lokuta k??la"/><asula kood="4914" nimi="Metsa????re k??la"/><asula kood="5015" nimi="Mukri k??la"/><asula kood="5334" nimi="Nadalama k??la"/><asula kood="5498" nimi="N??lva k??la"/><asula kood="5618" nimi="Ohekatku k??la"/><asula kood="5820" nimi="Pae k??la"/><asula kood="5922" nimi="Palasi k??la"/><asula kood="5947" nimi="Paluk??la"/><asula kood="6530" nimi="P??llu k??la"/><asula kood="6546" nimi="P??rsaku k??la"/><asula kood="6937" nimi="Reonda k??la"/><asula kood="7176" nimi="R??ue k??la"/><asula kood="7298" nimi="Saarep??llu k??la"/><asula kood="7353" nimi="Saksa k??la"/><asula kood="7461" nimi="Saunak??la"/><asula kood="7531" nimi="Selja k??la"/><asula kood="7681" nimi="Sooaluste k??la"/><asula kood="8970" nimi="Valtu-Nurme k??la"/><asula kood="9126" nimi="Vastja k??la"/></vald><vald kood="0317" nimi="Kohila vald"><asula kood="1021" nimi="Aandu k??la"/><asula kood="1079" nimi="Adila k??la"/><asula kood="1094" nimi="Aespa alevik"/><asula kood="1270" nimi="Angerja k??la"/><asula kood="1714" nimi="Hageri alevik"/><asula kood="1715" nimi="Hageri k??la"/><asula kood="2475" nimi="Kadaka k??la"/><asula kood="3268" nimi="Kohila alev"/><asula kood="4453" nimi="Lohu k??la"/><asula kood="4511" nimi="Loone k??la"/><asula kood="4681" nimi="L??mandu k??la"/><asula kood="4811" nimi="Masti k??la"/><asula kood="5250" nimi="M??livere k??la"/><asula kood="5854" nimi="Pahkla k??la"/><asula kood="6140" nimi="Pihali k??la"/><asula kood="6368" nimi="Prillim??e alevik"/><asula kood="6415" nimi="Pukam??e k??la"/><asula kood="6503" nimi="P??ikma k??la"/><asula kood="6710" nimi="Rabivere k??la"/><asula kood="7085" nimi="Rootsi k??la"/><asula kood="7402" nimi="Salutaguse k??la"/><asula kood="7815" nimi="Sutlema k??la"/><asula kood="8721" nimi="Urge k??la"/><asula kood="8976" nimi="Vana-Aespa k??la"/><asula kood="9341" nimi="Vilivere k??la"/></vald><vald kood="0503" nimi="M??rjamaa vald"><asula kood="1168" nimi="Alak??la"/><asula kood="1219" nimi="Altk??la"/><asula kood="1319" nimi="Araste k??la"/><asula kood="1324" nimi="Aravere k??la"/><asula kood="1375" nimi="Aruk??la"/><asula kood="1478" nimi="Avaste k??la"/><asula kood="1725" nimi="Haimre k??la"/><asula kood="1834" nimi="Hiietse k??la"/><asula kood="2081" nimi="Inda k??la"/><asula kood="2147" nimi="Jaaniveski k??la"/><asula kood="2254" nimi="J??e????re k??la"/><asula kood="2296" nimi="J??divere k??la"/><asula kood="2504" nimi="Kaguvere k??la"/><asula kood="2668" nimi="Kangru k??la"/><asula kood="2824" nimi="Kasti k??la"/><asula kood="2883" nimi="Kausi k??la"/><asula kood="2980" nimi="Keskk??la"/><asula kood="2990" nimi="Kesu k??la"/><asula kood="3037" nimi="Kiilaspere k??la"/><asula kood="3080" nimi="Kilgi k??la"/><asula kood="3146" nimi="Kirna k??la"/><asula kood="3175" nimi="Kivi-Vigala k??la"/><asula kood="3267" nimi="Kohatu k??la"/><asula kood="3272" nimi="Kohtru k??la"/><asula kood="3307" nimi="Kojastu k??la"/><asula kood="3365" nimi="Koluta k??la"/><asula kood="3373" nimi="Konnapere k??la"/><asula kood="3380" nimi="Konuvere k??la"/><asula kood="3627" nimi="Kunsu k??la"/><asula kood="3662" nimi="Kurevere k??la"/><asula kood="3813" nimi="K??rtsuotsa k??la"/><asula kood="3831" nimi="K??rvetaguse k??la"/><asula kood="3844" nimi="K??bik??la"/><asula kood="3908" nimi="K??riselja k??la"/><asula kood="4143" nimi="Laukna k??la"/><asula kood="4200" nimi="Leevre k??la"/><asula kood="4221" nimi="Leibre k??la"/><asula kood="4302" nimi="Lestima k??la"/><asula kood="4479" nimi="Lokuta k??la"/><asula kood="4503" nimi="Loodna k??la"/><asula kood="4554" nimi="Luiste k??la"/><asula kood="4647" nimi="L??ti k??la"/><asula kood="4683" nimi="L??mandu k??la"/><asula kood="8232" nimi="Maidla k??la"/><asula kood="4775" nimi="Manni k??la"/><asula kood="4915" nimi="Metsa????re k??la"/><asula kood="4919" nimi="Metsk??la"/><asula kood="4967" nimi="Moka k??la"/><asula kood="5133" nimi="M??isamaa k??la"/><asula kood="5162" nimi="M??raste k??la"/><asula kood="5246" nimi="M??liste k??la"/><asula kood="5262" nimi="M??nniku k??la"/><asula kood="5280" nimi="M??rjamaa alev"/><asula kood="5348" nimi="Naistevalla k??la"/><asula kood="5351" nimi="Napanurga k??la"/><asula kood="5353" nimi="Naravere k??la"/><asula kood="5469" nimi="Nurme k??la"/><asula kood="5482" nimi="Nurtu-N??lva k??la"/><asula kood="5517" nimi="N??mmeotsa k??la"/><asula kood="5561" nimi="N????ri k??la"/><asula kood="5611" nimi="Oese k??la"/><asula kood="5631" nimi="Ohukotsu k??la"/><asula kood="5653" nimi="Ojapere k??la"/><asula kood="5655" nimi="Oja????rse k??la"/><asula kood="5711" nimi="Orgita k??la"/><asula kood="5779" nimi="Paaduotsa k??la"/><asula kood="5826" nimi="Paek??la"/><asula kood="5875" nimi="Paisumaa k??la"/><asula kood="5878" nimi="Pajaka k??la"/><asula kood="5921" nimi="Palase k??la"/><asula kood="5928" nimi="Paljasmaa k??la"/><asula kood="5937" nimi="Pallika k??la"/><asula kood="6438" nimi="Purga k??la"/><asula kood="6523" nimi="P??lli k??la"/><asula kood="6624" nimi="P????deva k??la"/><asula kood="6629" nimi="P????rdu k??la"/><asula kood="6662" nimi="P??hatu k??la"/><asula kood="6800" nimi="Rangu k??la"/><asula kood="6832" nimi="Rassiotsa k??la"/><asula kood="6979" nimi="Riidaku k??la"/><asula kood="7003" nimi="Ringuta k??la"/><asula kood="7015" nimi="Risu-Suurk??la"/><asula kood="7132" nimi="Russalu k??la"/><asula kood="7248" nimi="R????ski k??la"/><asula kood="7622" nimi="Sipa k??la"/><asula kood="7725" nimi="Sooniste k??la"/><asula kood="7740" nimi="Soosalu k??la"/><asula kood="7792" nimi="Sulu k??la"/><asula kood="7853" nimi="Suurk??la"/><asula kood="7890" nimi="S??meru k??la"/><asula kood="7909" nimi="S??tke k??la"/><asula kood="7946" nimi="S????la k??la"/><asula kood="8182" nimi="Teenuse k??la"/><asula kood="8208" nimi="Tiduvere k??la"/><asula kood="8283" nimi="Tolli k??la"/><asula kood="8509" nimi="T??numaa k??la"/><asula kood="8717" nimi="Urevere k??la"/><asula kood="8834" nimi="Vaguja k??la"/><asula kood="8882" nimi="Vaim??isa k??la"/><asula kood="8939" nimi="Valgu k??la"/><asula kood="9340" nimi="Valgu-Vanam??isa k??la"/><asula kood="8997" nimi="Vana-Nurtu k??la"/><asula kood="9007" nimi="Vana-Vigala k??la"/><asula kood="9063" nimi="Varbola k??la"/><asula kood="9189" nimi="Velise k??la"/><asula kood="9190" nimi="Velise-N??lva k??la"/><asula kood="9187" nimi="Velisem??isa k??la"/><asula kood="9228" nimi="Veski k??la"/><asula kood="9256" nimi="Vigala-Vanam??isa k??la"/><asula kood="9359" nimi="Vilta k??la"/><asula kood="9493" nimi="V??eva k??la"/><asula kood="9666" nimi="V??ngla k??la"/><asula kood="9829" nimi="??lej??e k??la"/></vald><vald kood="0668" nimi="Rapla vald"><asula kood="1230" nimi="Alu alevik"/><asula kood="1232" nimi="Alu-Metsk??la"/><asula kood="1316" nimi="Arank??la"/><asula kood="1437" nimi="Atla k??la"/><asula kood="1716" nimi="Hagudi alevik"/><asula kood="1717" nimi="Hagudi k??la"/><asula kood="1805" nimi="Helda k??la"/><asula kood="1931" nimi="H??reda k??la"/><asula kood="1944" nimi="H??rgla k??la"/><asula kood="2020" nimi="Iira k??la"/><asula kood="2161" nimi="Jalase k??la"/><asula kood="2169" nimi="Jaluse k??la"/><asula kood="2216" nimi="Juula k??la"/><asula kood="2223" nimi="Juuru alevik"/><asula kood="2330" nimi="J??rlepa k??la"/><asula kood="2444" nimi="Kabala k??la"/><asula kood="2530" nimi="Kaigepere k??la"/><asula kood="2553" nimi="Kaiu alevik"/><asula kood="2569" nimi="Kalda k??la"/><asula kood="2580" nimi="Kalevi k??la"/><asula kood="2742" nimi="Karitsa k??la"/><asula kood="2845" nimi="Kasvandu k??la"/><asula kood="2933" nimi="Kelba k??la"/><asula kood="2955" nimi="Keo k??la"/><asula kood="3242" nimi="Kodila k??la"/><asula kood="3240" nimi="Kodila-Metsk??la"/><asula kood="3283" nimi="Koigi k??la"/><asula kood="3294" nimi="Koikse k??la"/><asula kood="3541" nimi="Kuimetsa k??la"/><asula kood="3569" nimi="Kuku k??la"/><asula kood="3720" nimi="Kuusiku alevik"/><asula kood="3724" nimi="Kuusiku-N??mme k??la"/><asula kood="3799" nimi="K??rgu k??la"/><asula kood="4413" nimi="Lipa k??la"/><asula kood="4416" nimi="Lipametsa k??la"/><asula kood="4421" nimi="Lipstu k??la"/><asula kood="4443" nimi="Loe k??la"/><asula kood="4602" nimi="L??iuse k??la"/><asula kood="4614" nimi="L??pemetsa k??la"/><asula kood="4728" nimi="Mahlam??e k??la"/><asula kood="4733" nimi="Mahtra k??la"/><asula kood="4741" nimi="Maidla k??la"/><asula kood="4924" nimi="Metsk??la"/><asula kood="5126" nimi="M??isaaseme k??la"/><asula kood="5254" nimi="M??llu k??la"/><asula kood="5520" nimi="N??mme k??la"/><asula kood="5516" nimi="N??mmemetsa k??la"/><asula kood="5522" nimi="N??mmk??la"/><asula kood="5588" nimi="Oblu k??la"/><asula kood="5608" nimi="Oela k??la"/><asula kood="5634" nimi="Ohulepa k??la"/><asula kood="5687" nimi="Oola k??la"/><asula kood="5717" nimi="Orguse k??la"/><asula kood="5911" nimi="Palamulla k??la"/><asula kood="6274" nimi="Pirgu k??la"/><asula kood="6443" nimi="Purila k??la"/><asula kood="6445" nimi="Purku k??la"/><asula kood="6526" nimi="P??lliku k??la"/><asula kood="6533" nimi="P??lma k??la"/><asula kood="6719" nimi="Raela k??la"/><asula kood="6758" nimi="Raikk??la"/><asula kood="6772" nimi="Raka k??la"/><asula kood="6826" nimi="Rapla linn"/><asula kood="6954" nimi="Ridak??la"/><asula kood="7255" nimi="R??a k??la"/><asula kood="7319" nimi="Sadala k??la"/><asula kood="7518" nimi="Seli k??la"/><asula kood="5470" nimi="Seli-Nurme k??la"/><asula kood="7586" nimi="Sikeldi k??la"/><asula kood="7796" nimi="Sulupere k??la"/><asula kood="7840" nimi="Suurekivi k??la"/><asula kood="8138" nimi="Tamsi k??la"/><asula kood="8139" nimi="Tapupere k??la"/><asula kood="8279" nimi="Tolla k??la"/><asula kood="8305" nimi="Toomja k??la"/><asula kood="8441" nimi="Tuti k??la"/><asula kood="8518" nimi="T??rma k??la"/><asula kood="8677" nimi="Ummaru k??la"/><asula kood="8788" nimi="Uusk??la"/><asula kood="8838" nimi="Vahak??nnu k??la"/><asula kood="8842" nimi="Vahastu k??la"/><asula kood="8961" nimi="Valli k??la"/><asula kood="8971" nimi="Valtu k??la"/><asula kood="8982" nimi="Vana-Kaiu k??la"/><asula kood="9046" nimi="Vankse k??la"/><asula kood="9050" nimi="Vaopere k??la"/><asula kood="4318" nimi="V??ljataguse k??la"/><asula kood="9729" nimi="??herdi k??la"/><asula kood="9831" nimi="??lej??e k??la"/></vald></maakond><maakond kood="0074" nimi="Saare maakond"><vald kood="0478" nimi="Muhu vald"><asula kood="1196" nimi="Aljava k??la"/><asula kood="1808" nimi="Hellamaa k??la"/><asula kood="1990" nimi="Igak??la"/><asula kood="2597" nimi="Kallaste k??la"/><asula kood="2691" nimi="Kantsi k??la"/><asula kood="2695" nimi="Kapi k??la"/><asula kood="2987" nimi="Kesse k??la"/><asula kood="3260" nimi="Koguva k??la"/><asula kood="3549" nimi="Kuivastu k??la"/><asula kood="3983" nimi="K??lasema k??la"/><asula kood="4058" nimi="Lahek??la"/><asula kood="4083" nimi="Lalli k??la"/><asula kood="4189" nimi="Leeskopa k??la"/><asula kood="4215" nimi="Lehtmetsa k??la"/><asula kood="4292" nimi="Lepiku k??la"/><asula kood="4311" nimi="Leval??pme k??la"/><asula kood="4353" nimi="Liiva k??la"/><asula kood="4407" nimi="Linnuse k??la"/><asula kood="4595" nimi="L??etsa k??la"/><asula kood="5120" nimi="M??ega k??la"/><asula kood="5130" nimi="M??isak??la"/><asula kood="5243" nimi="M??la k??la"/><asula kood="5370" nimi="Nautse k??la"/><asula kood="5475" nimi="Nurme k??la"/><asula kood="5524" nimi="N??mmk??la"/><asula kood="5639" nimi="Oina k??la"/><asula kood="5831" nimi="Paenase k??la"/><asula kood="5931" nimi="Pallasmaa k??la"/><asula kood="6184" nimi="Piiri k??la"/><asula kood="6638" nimi="P??itse k??la"/><asula kood="6556" nimi="P??daste k??la"/><asula kood="6559" nimi="P??elda k??la"/><asula kood="6598" nimi="P??rase k??la"/><asula kood="6715" nimi="Raegma k??la"/><asula kood="6817" nimi="Rannak??la"/><asula kood="6861" nimi="Raugi k??la"/><asula kood="6888" nimi="Rebaski k??la"/><asula kood="6965" nimi="Ridasi k??la"/><asula kood="7006" nimi="Rinsi k??la"/><asula kood="7093" nimi="Rootsivere k??la"/><asula kood="7223" nimi="R??ssa k??la"/><asula kood="7601" nimi="Simiste k??la"/><asula kood="7724" nimi="Soonda k??la"/><asula kood="7847" nimi="Suurem??isa k??la"/><asula kood="8136" nimi="Tamse k??la"/><asula kood="8418" nimi="Tupenurme k??la"/><asula kood="8440" nimi="Tusti k??la"/><asula kood="8851" nimi="Vahtraste k??la"/><asula kood="9027" nimi="Vanam??isa k??la"/><asula kood="9285" nimi="Viira k??la"/><asula kood="9531" nimi="V??ik??la"/><asula kood="9554" nimi="V??lla k??la"/></vald><vald kood="0689" nimi="Ruhnu vald"><asula kood="7105" nimi="Ruhnu k??la"/></vald><vald kood="0714" nimi="Saaremaa vald"><asula kood="1052" nimi="Aaviku k??la"/><asula kood="1054" nimi="Abaja k??la"/><asula kood="1064" nimi="Abruka k??la"/><asula kood="1067" nimi="Abula k??la"/><asula kood="1207" nimi="Allikalahe k??la"/><asula kood="1268" nimi="Anepesa k??la"/><asula kood="1272" nimi="Angla k??la"/><asula kood="1280" nimi="Anijala k??la"/><asula kood="1297" nimi="Ansek??la"/><asula kood="1300" nimi="Ansi k??la"/><asula kood="1313" nimi="Arandi k??la"/><asula kood="1337" nimi="Ardla k??la"/><asula kood="1346" nimi="Are k??la"/><asula kood="1348" nimi="Ariste k??la"/><asula kood="1357" nimi="Arju k??la"/><asula kood="1364" nimi="Aru k??la"/><asula kood="1389" nimi="Aruste k??la"/><asula kood="1416" nimi="Aste alevik"/><asula kood="1417" nimi="Aste k??la"/><asula kood="1424" nimi="Asuka k??la"/><asula kood="1426" nimi="Asuk??la"/><asula kood="1429" nimi="Asva k??la"/><asula kood="1436" nimi="Atla k??la"/><asula kood="1455" nimi="Audla k??la"/><asula kood="1466" nimi="Aula-Vintri k??la"/><asula kood="1470" nimi="Austla k??la"/><asula kood="1514" nimi="Easte k??la"/><asula kood="1530" nimi="Eeriksaare k??la"/><asula kood="1553" nimi="Eikla k??la"/><asula kood="1564" nimi="Eiste k??la"/><asula kood="1599" nimi="Endla k??la"/><asula kood="1606" nimi="Ennu k??la"/><asula kood="1686" nimi="Haamse k??la"/><asula kood="1695" nimi="Haapsu k??la"/><asula kood="1712" nimi="Haeska k??la"/><asula kood="1731" nimi="Hakjala k??la"/><asula kood="1836" nimi="Hiiev??lja k??la"/><asula kood="1850" nimi="Himmiste k??la"/><asula kood="1853" nimi="Hindu k??la"/><asula kood="1874" nimi="Hirmuste k??la"/><asula kood="1939" nimi="H??mmelepa k??la"/><asula kood="1940" nimi="H??nga k??la"/><asula kood="1965" nimi="H??bja k??la"/><asula kood="2014" nimi="Iide k??la"/><asula kood="2022" nimi="Iilaste k??la"/><asula kood="2056" nimi="Ilpla k??la"/><asula kood="2066" nimi="Imara k??la"/><asula kood="2074" nimi="Imavere k??la"/><asula kood="2097" nimi="Irase k??la"/><asula kood="2103" nimi="Iruste k??la"/><asula kood="2148" nimi="Jaani k??la"/><asula kood="2178" nimi="Jauni k??la"/><asula kood="2200" nimi="Jootme k??la"/><asula kood="2215" nimi="Jursi k??la"/><asula kood="2225" nimi="J??e k??la"/><asula kood="2231" nimi="J??elepa k??la"/><asula kood="2239" nimi="J??empa k??la"/><asula kood="2260" nimi="J??gela k??la"/><asula kood="2274" nimi="J??iste k??la"/><asula kood="2310" nimi="J??maja k??la"/><asula kood="2324" nimi="J??rise k??la"/><asula kood="2366" nimi="J??rve k??la"/><asula kood="2356" nimi="J??rvek??la"/><asula kood="2292" nimi="J????ri k??la"/><asula kood="2398" nimi="Kaali k??la"/><asula kood="2397" nimi="Kaali-Liiva k??la"/><asula kood="2414" nimi="Kaarma k??la"/><asula kood="2412" nimi="Kaarma-J??e k??la"/><asula kood="3122" nimi="Kaarma-Kirikuk??la"/><asula kood="2413" nimi="Kaarma-Kungla k??la"/><asula kood="2416" nimi="Kaarmise k??la"/><asula kood="2442" nimi="Kaavi k??la"/><asula kood="2517" nimi="Kahtla k??la"/><asula kood="2522" nimi="Kahutsi k??la"/><asula kood="2538" nimi="Kailuka k??la"/><asula kood="2541" nimi="Kaimri k??la"/><asula kood="2543" nimi="Kaisa k??la"/><asula kood="2548" nimi="Kaisvere k??la"/><asula kood="2557" nimi="Kakuna k??la"/><asula kood="2594" nimi="Kalju k??la"/><asula kood="2599" nimi="Kallaste k??la"/><asula kood="2603" nimi="Kallem??e k??la"/><asula kood="2605" nimi="Kalli k??la"/><asula kood="2620" nimi="Kalma k??la"/><asula kood="2624" nimi="Kalmu k??la"/><asula kood="2662" nimi="Kandla k??la"/><asula kood="2672" nimi="Kangrusselja k??la"/><asula kood="2878" nimi="Kanissaare k??la"/><asula kood="2697" nimi="Kapra k??la"/><asula kood="2705" nimi="Karala k??la"/><asula kood="2713" nimi="Kareda k??la"/><asula kood="2720" nimi="Kargi k??la"/><asula kood="2722" nimi="Karida k??la"/><asula kood="2747" nimi="Karja k??la"/><asula kood="1498" nimi="Karuj??rve k??la"/><asula kood="2785" nimi="Karuste k??la"/><asula kood="2823" nimi="Kasti k??la"/><asula kood="2857" nimi="Kaubi k??la"/><asula kood="2864" nimi="Kaugatoma k??la"/><asula kood="2874" nimi="Kaunispe k??la"/><asula kood="2888" nimi="Kavandi k??la"/><asula kood="2922" nimi="Kehila k??la"/><asula kood="2935" nimi="Kellam??e k??la"/><asula kood="2982" nimi="Keskranna k??la"/><asula kood="2985" nimi="Keskvere k??la"/><asula kood="3012" nimi="Kihelkonna alevik"/><asula kood="3013" nimi="Kihelkonna-Liiva k??la"/><asula kood="3045" nimi="Kiirassaare k??la"/><asula kood="3098" nimi="Kingli k??la"/><asula kood="3106" nimi="Kipi k??la"/><asula kood="3111" nimi="Kiratsi k??la"/><asula kood="3118" nimi="Kirderanna k??la"/><asula kood="3138" nimi="Kiritu k??la"/><asula kood="3152" nimi="Kiruma k??la"/><asula kood="3258" nimi="Kogula k??la"/><asula kood="3278" nimi="Koidula k??la"/><asula kood="3279" nimi="Koiduv??lja k??la"/><asula kood="3284" nimi="Koigi k??la"/><asula kood="3290" nimi="Koigi-V??ljak??la"/><asula kood="3292" nimi="Koikla k??la"/><asula kood="3298" nimi="Koimla k??la"/><asula kood="3320" nimi="Koki k??la"/><asula kood="3325" nimi="Koksi k??la"/><asula kood="3431" nimi="Koovi k??la"/><asula kood="3437" nimi="Kopli k??la"/><asula kood="3482" nimi="Kotlandi k??la"/><asula kood="3483" nimi="Kotsma k??la"/><asula kood="3519" nimi="Kudjape alevik"/><asula kood="3521" nimi="Kugalepa k??la"/><asula kood="3544" nimi="Kuiste k??la"/><asula kood="3550" nimi="Kuke k??la"/><asula kood="3614" nimi="Kungla k??la"/><asula kood="3625" nimi="Kuninguste k??la"/><asula kood="3632" nimi="Kuralase k??la"/><asula kood="3643" nimi="Kuremetsa k??la"/><asula kood="3655" nimi="Kuressaare linn"/><asula kood="3661" nimi="Kurevere k??la"/><asula kood="3712" nimi="Kuumi k??la"/><asula kood="3715" nimi="Kuuse k??la"/><asula kood="3719" nimi="Kuusiku k??la"/><asula kood="3726" nimi="Kuusn??mme k??la"/><asula kood="3744" nimi="K??iguste k??la"/><asula kood="3747" nimi="K??inastu k??la"/><asula kood="3757" nimi="K??ljala k??la"/><asula kood="3774" nimi="K??nnu k??la"/><asula kood="3800" nimi="K??riska k??la"/><asula kood="3805" nimi="K??rkk??la"/><asula kood="3807" nimi="K??rkvere k??la"/><asula kood="3817" nimi="K??ruse k??la"/><asula kood="3816" nimi="K??ruse-Metsak??la"/><asula kood="3843" nimi="K????ru k??la"/><asula kood="3860" nimi="K??esla k??la"/><asula kood="3870" nimi="K??ku k??la"/><asula kood="3882" nimi="K??o k??la"/><asula kood="3896" nimi="K??rdu k??la"/><asula kood="3916" nimi="K??rla alevik"/><asula kood="3123" nimi="K??rla-Kirikuk??la"/><asula kood="3598" nimi="K??rla-Kulli k??la"/><asula kood="3922" nimi="K??rneri k??la"/><asula kood="3964" nimi="K??bassaare k??la"/><asula kood="3967" nimi="K??dema k??la"/><asula kood="3989" nimi="K??lma k??la"/><asula kood="4007" nimi="Laadjala k??la"/><asula kood="4009" nimi="Laadla k??la"/><asula kood="4041" nimi="Laevaranna k??la"/><asula kood="4053" nimi="Lahek??la"/><asula kood="4057" nimi="Lahetaguse k??la"/><asula kood="4073" nimi="Laimjala k??la"/><asula kood="4110" nimi="Laok??la"/><asula kood="4129" nimi="Lassi k??la"/><asula kood="4138" nimi="Laugu k??la"/><asula kood="4137" nimi="Laugu-Liiva k??la"/><asula kood="4180" nimi="Leedri k??la"/><asula kood="4233" nimi="Leina k??la"/><asula kood="4237" nimi="Leisi alevik"/><asula kood="4238" nimi="Leisi k??la"/><asula kood="4310" nimi="Levala k??la"/><asula kood="4335" nimi="Liigalaskma k??la"/><asula kood="4345" nimi="Liik??la"/><asula kood="4363" nimi="Liiva k??la"/><asula kood="4366" nimi="Liiva-Putla k??la"/><asula kood="4346" nimi="Liivan??mme k??la"/><asula kood="4343" nimi="Liivaranna k??la"/><asula kood="4368" nimi="Lilbi k??la"/><asula kood="4385" nimi="Lindmetsa k??la"/><asula kood="4395" nimi="Linnaka k??la"/><asula kood="4409" nimi="Linnuse k??la"/><asula kood="4509" nimi="Loona k??la"/><asula kood="4561" nimi="Lussu k??la"/><asula kood="4581" nimi="Luulupe k??la"/><asula kood="4604" nimi="L??mala k??la"/><asula kood="4615" nimi="L??pi k??la"/><asula kood="4608" nimi="L??u k??la"/><asula kood="4609" nimi="L??up??llu k??la"/><asula kood="4666" nimi="L??bara k??la"/><asula kood="4636" nimi="L??nga k??la"/><asula kood="4649" nimi="L??tiniidi k??la"/><asula kood="4653" nimi="L????gi k??la"/><asula kood="4661" nimi="L????tsa k??la"/><asula kood="4665" nimi="L????ne k??la"/><asula kood="4675" nimi="L??lle k??la"/><asula kood="4679" nimi="L??manda k??la"/><asula kood="3601" nimi="L??manda-Kulli k??la"/><asula kood="4700" nimi="Maantee k??la"/><asula kood="4713" nimi="Maasi k??la"/><asula kood="4754" nimi="Maleva k??la"/><asula kood="4803" nimi="Masa k??la"/><asula kood="4826" nimi="Matsiranna k??la"/><asula kood="4834" nimi="Meedla k??la"/><asula kood="4855" nimi="Mehama k??la"/><asula kood="4862" nimi="Meiuste k??la"/><asula kood="4888" nimi="Merise k??la"/><asula kood="4894" nimi="Metsak??la"/><asula kood="4899" nimi="Metsal??uka k??la"/><asula kood="4907" nimi="Metsapere k??la"/><asula kood="4909" nimi="Metsara k??la"/><asula kood="4917" nimi="Metsa????re k??la"/><asula kood="4922" nimi="Metsk??la"/><asula kood="4984" nimi="Moosi k??la"/><asula kood="5006" nimi="Mui k??la"/><asula kood="5012" nimi="Mujaste k??la"/><asula kood="5025" nimi="Mullutu k??la"/><asula kood="5034" nimi="Muraja k??la"/><asula kood="5044" nimi="Muratsi k??la"/><asula kood="5050" nimi="Murika k??la"/><asula kood="5080" nimi="Mustjala k??la"/><asula kood="5087" nimi="Mustla k??la"/><asula kood="5139" nimi="M??isak??la"/><asula kood="5154" nimi="M??nnuste k??la"/><asula kood="5155" nimi="M??ntu k??la"/><asula kood="5190" nimi="M??ebe k??la"/><asula kood="5214" nimi="M??ek??la"/><asula kood="5220" nimi="M??gi-Kurdla k??la"/><asula kood="5257" nimi="M??ndjala k??la"/><asula kood="5265" nimi="M??nniku k??la"/><asula kood="5282" nimi="M??ssa k??la"/><asula kood="5284" nimi="M??tasselja k??la"/><asula kood="5287" nimi="M??tja k??la"/><asula kood="5308" nimi="M??ldri k??la"/><asula kood="5361" nimi="Nasva alevik"/><asula kood="5374" nimi="Nava k??la"/><asula kood="5388" nimi="Neeme k??la"/><asula kood="5390" nimi="Neemi k??la"/><asula kood="5401" nimi="Nenu k??la"/><asula kood="5414" nimi="Nihatu k??la"/><asula kood="5428" nimi="Ninase k??la"/><asula kood="5472" nimi="Nurme k??la"/><asula kood="5505" nimi="N??mjala k??la"/><asula kood="5519" nimi="N??mme k??la"/><asula kood="5528" nimi="N??mpa k??la"/><asula kood="5560" nimi="N??ssuma k??la"/><asula kood="5592" nimi="Odal??tsi k??la"/><asula kood="5612" nimi="Oessaare k??la"/><asula kood="5621" nimi="Ohessaare k??la"/><asula kood="5623" nimi="Ohtja k??la"/><asula kood="5644" nimi="Oitme k??la"/><asula kood="5657" nimi="Oju k??la"/><asula kood="5723" nimi="Orin??mme k??la"/><asula kood="5725" nimi="Orissaare alevik"/><asula kood="5757" nimi="Oti k??la"/><asula kood="5792" nimi="Paaste k??la"/><asula kood="5799" nimi="Paatsa k??la"/><asula kood="5836" nimi="Paevere k??la"/><asula kood="5847" nimi="Pahapilli k??la"/><asula kood="5849" nimi="Pahavalla k??la"/><asula kood="5867" nimi="Paik??la"/><asula kood="5868" nimi="Paimala k??la"/><asula kood="5882" nimi="Paju-Kurdla k??la"/><asula kood="5890" nimi="Pajum??isa k??la"/><asula kood="5965" nimi="Pamma k??la"/><asula kood="5967" nimi="Pammana k??la"/><asula kood="5973" nimi="Panga k??la"/><asula kood="5994" nimi="Parasmetsa k??la"/><asula kood="6010" nimi="Parila k??la"/><asula kood="6077" nimi="Peederga k??la"/><asula kood="6137" nimi="Pidula k??la"/><asula kood="6138" nimi="Pidula-Kuusiku k??la"/><asula kood="6153" nimi="Pihtla k??la"/><asula kood="6169" nimi="Piila k??la"/><asula kood="6312" nimi="Poka k??la"/><asula kood="6343" nimi="Praakli k??la"/><asula kood="6418" nimi="Puka k??la"/><asula kood="6427" nimi="Pulli k??la"/><asula kood="6448" nimi="Purtsa k??la"/><asula kood="6534" nimi="P??lluk??la"/><asula kood="6542" nimi="P??rip??llu k??la"/><asula kood="6562" nimi="P??hkla k??la"/><asula kood="6614" nimi="P??rni k??la"/><asula kood="6618" nimi="P??rsama k??la"/><asula kood="6635" nimi="P??ide k??la"/><asula kood="6636" nimi="P??ide-Keskvere k??la"/><asula kood="6639" nimi="P??itse k??la"/><asula kood="6653" nimi="P??ha k??la"/><asula kood="6654" nimi="P??ha-K??nnu k??la"/><asula kood="6730" nimi="Rahniku k??la"/><asula kood="6734" nimi="Rahtla k??la"/><asula kood="6737" nimi="Rahu k??la"/><asula kood="6745" nimi="Rahuste k??la"/><asula kood="6794" nimi="Randk??la"/><asula kood="6799" nimi="Randvere k??la"/><asula kood="6818" nimi="Rannak??la"/><asula kood="6842" nimi="Ratla k??la"/><asula kood="6862" nimi="Raugu k??la"/><asula kood="6899" nimi="Reek??la"/><asula kood="6913" nimi="Reina k??la"/><asula kood="6930" nimi="Reo k??la"/><asula kood="6960" nimi="Ridala k??la"/><asula kood="6997" nimi="Riksu k??la"/><asula kood="7051" nimi="Roobaka k??la"/><asula kood="7088" nimi="Rootsik??la"/><asula kood="7107" nimi="Ruhve k??la"/><asula kood="7200" nimi="R??imaste k??la"/><asula kood="7234" nimi="R????gi k??la"/><asula kood="7258" nimi="R????sa k??la"/><asula kood="7294" nimi="Saarek??la"/><asula kood="7291" nimi="Saaremetsa k??la"/><asula kood="7330" nimi="Sagariste k??la"/><asula kood="7340" nimi="Saia k??la"/><asula kood="7345" nimi="Saikla k??la"/><asula kood="7351" nimi="Sakla k??la"/><asula kood="7372" nimi="Salavere k??la"/><asula kood="7387" nimi="Salme alevik"/><asula kood="7403" nimi="Salu k??la"/><asula kood="7413" nimi="Sandla k??la"/><asula kood="7450" nimi="Sauaru k??la"/><asula kood="7470" nimi="Saue-Mustla k??la"/><asula kood="7451" nimi="Saue-Putla k??la"/><asula kood="7473" nimi="Sauvere k??la"/><asula kood="7513" nimi="Selgase k??la"/><asula kood="7537" nimi="Selja k??la"/><asula kood="7543" nimi="Sepa k??la"/><asula kood="7545" nimi="Sepise k??la"/><asula kood="7568" nimi="Siiksaare k??la"/><asula kood="7584" nimi="Sikassaare k??la"/><asula kood="7596" nimi="Silla k??la"/><asula kood="7658" nimi="Soela k??la"/><asula kood="7689" nimi="Soodevahe k??la"/><asula kood="7799" nimi="Sundimetsa k??la"/><asula kood="7822" nimi="Sutu k??la"/><asula kood="7826" nimi="Suur-Pahila k??la"/><asula kood="7827" nimi="Suur-Rahula k??la"/><asula kood="7837" nimi="Suur-Randvere k??la"/><asula kood="7834" nimi="Suure-Rootsi k??la"/><asula kood="7861" nimi="Suurna k??la"/><asula kood="7885" nimi="S??mera k??la"/><asula kood="7906" nimi="S??rve-Hindu k??la"/><asula kood="7950" nimi="S????re k??la"/><asula kood="7998" nimi="Taaliku k??la"/><asula kood="8049" nimi="Tagam??isa k??la"/><asula kood="8053" nimi="Tagaranna k??la"/><asula kood="8059" nimi="Tagavere k??la"/><asula kood="8076" nimi="Tahula k??la"/><asula kood="8084" nimi="Talila k??la"/><asula kood="8099" nimi="Tammese k??la"/><asula kood="8128" nimi="Tammuna k??la"/><asula kood="8153" nimi="Tareste k??la"/><asula kood="8158" nimi="Taritu k??la"/><asula kood="8185" nimi="Tehumardi k??la"/><asula kood="8227" nimi="Tiirimetsa k??la"/><asula kood="8230" nimi="Tiitsuotsa k??la"/><asula kood="8253" nimi="Tirbi k??la"/><asula kood="8270" nimi="Tohku k??la"/><asula kood="8298" nimi="Toomal??uka k??la"/><asula kood="8323" nimi="Torgu-M??isak??la"/><asula kood="8336" nimi="Tornim??e k??la"/><asula kood="8347" nimi="Triigi k??la"/><asula kood="8406" nimi="Tuiu k??la"/><asula kood="8412" nimi="Tumala k??la"/><asula kood="8426" nimi="Turja k??la"/><asula kood="8443" nimi="Tutku k??la"/><asula kood="8489" nimi="T??lli k??la"/><asula kood="8493" nimi="T??lluste k??la"/><asula kood="8502" nimi="T??nija k??la"/><asula kood="8516" nimi="T??re k??la"/><asula kood="8517" nimi="T??rise k??la"/><asula kood="8526" nimi="T??ru k??la"/><asula kood="8587" nimi="T????tsi k??la"/><asula kood="8600" nimi="T??rju k??la"/><asula kood="8625" nimi="Uduvere k??la"/><asula kood="8652" nimi="Ula k??la"/><asula kood="8662" nimi="Ulje k??la"/><asula kood="8683" nimi="Undim??e k??la"/><asula kood="8692" nimi="Undva k??la"/><asula kood="8693" nimi="Unguma k??la"/><asula kood="8697" nimi="Unim??e k??la"/><asula kood="8708" nimi="Upa k??la"/><asula kood="8771" nimi="Uuem??isa k??la"/><asula kood="8859" nimi="Vahva k??la"/><asula kood="8870" nimi="Vaigu k??la"/><asula kood="8871" nimi="Vaigu-Rannak??la"/><asula kood="8898" nimi="Vaivere k??la"/><asula kood="8951" nimi="Valjala alevik"/><asula kood="8950" nimi="Valjala-Ariste k??la"/><asula kood="8952" nimi="Valjala-Kogula k??la"/><asula kood="8953" nimi="Valjala-Nurme k??la"/><asula kood="8990" nimi="Vana-Lahetaguse k??la"/><asula kood="9013" nimi="Vanakubja k??la"/><asula kood="9018" nimi="Vanal??ve k??la"/><asula kood="9022" nimi="Vanam??isa k??la"/><asula kood="9045" nimi="Vantri k??la"/><asula kood="9089" nimi="Varkja k??la"/><asula kood="9093" nimi="Varpe k??la"/><asula kood="9145" nimi="Vatsk??la"/><asula kood="9158" nimi="Vedruka k??la"/><asula kood="9171" nimi="Veere k??la"/><asula kood="9173" nimi="Veerem??e k??la"/><asula kood="9172" nimi="Veeriku k??la"/><asula kood="9197" nimi="Vendise k??la"/><asula kood="9206" nimi="Vennati k??la"/><asula kood="9226" nimi="Veske k??la"/><asula kood="9241" nimi="Vestla k??la"/><asula kood="9275" nimi="Viidu k??la"/><asula kood="9276" nimi="Viidu-M??ebe k??la"/><asula kood="9293" nimi="Viira k??la"/><asula kood="9315" nimi="Viki k??la"/><asula kood="9328" nimi="Vilidu k??la"/><asula kood="9357" nimi="Vilsandi k??la"/><asula kood="9360" nimi="Viltina k??la"/><asula kood="9378" nimi="Vintri k??la"/><asula kood="9383" nimi="Virita k??la"/><asula kood="9497" nimi="V??hma k??la"/><asula kood="9581" nimi="V??rsna k??la"/><asula kood="9629" nimi="V??ike-Pahila k??la"/><asula kood="9632" nimi="V??ike-Rahula k??la"/><asula kood="9634" nimi="V??ike-Rootsi k??la"/><asula kood="9627" nimi="V??ike-Ula k??la"/><asula kood="9630" nimi="V??ike-V??hma k??la"/><asula kood="9642" nimi="V??kra k??la"/><asula kood="9649" nimi="V??ljak??la"/><asula kood="9660" nimi="V??ljam??isa k??la"/><asula kood="9658" nimi="V??lta k??la"/><asula kood="9799" nimi="??este k??la"/><asula kood="9800" nimi="??ha k??la"/><asula kood="9804" nimi="????riku k??la"/><asula kood="9849" nimi="??ru k??la"/><asula kood="9855" nimi="????dibe k??la"/><asula kood="9854" nimi="????vere k??la"/></vald></maakond><maakond kood="0079" nimi="Tartu maakond"><vald kood="0171" nimi="Elva vald"><asula kood="1018" nimi="Aakre k??la"/><asula kood="1291" nimi="Annikoru k??la"/><asula kood="1418" nimi="Astuvere k??la"/><asula kood="1440" nimi="Atra k??la"/><asula kood="1586" nimi="Elva linn"/><asula kood="1643" nimi="Ervu k??la"/><asula kood="1813" nimi="Hellenurme k??la"/><asula kood="1951" nimi="H??rjanurme k??la"/><asula kood="2348" nimi="J??rvak??la"/><asula kood="2351" nimi="J??rvek??la"/><asula kood="2409" nimi="Kaarlij??rve k??la"/><asula kood="2540" nimi="Kaimi k??la"/><asula kood="2622" nimi="Kalme k??la"/><asula kood="2699" nimi="Kapsta k??la"/><asula kood="2725" nimi="Karij??rve k??la"/><asula kood="3103" nimi="Kipastu k??la"/><asula kood="3121" nimi="Kirepi k??la"/><asula kood="3216" nimi="Kobilu k??la"/><asula kood="3372" nimi="Konguta k??la"/><asula kood="3412" nimi="Koopsi k??la"/><asula kood="3457" nimi="Koruste k??la"/><asula kood="3595" nimi="Kulli k??la"/><asula kood="3633" nimi="Kurek??la"/><asula kood="3637" nimi="Kurek??la alevik"/><asula kood="3639" nimi="Kurelaane k??la"/><asula kood="3738" nimi="K??duk??la"/><asula kood="3881" nimi="K??o k??la"/><asula kood="3949" nimi="K????rdi alevik"/><asula kood="3973" nimi="K??laaseme k??la"/><asula kood="4117" nimi="Lapetukme k??la"/><asula kood="4256" nimi="Lembevere k??la"/><asula kood="4527" nimi="Lossim??e k??la"/><asula kood="4749" nimi="Majala k??la"/><asula kood="4895" nimi="Metsalaane k??la"/><asula kood="5138" nimi="M??isanurme k??la"/><asula kood="5198" nimi="M??elooga k??la"/><asula kood="5206" nimi="M??eotsa k??la"/><asula kood="5211" nimi="M??eselja k??la"/><asula kood="5248" nimi="M??lgi k??la"/><asula kood="5358" nimi="Nasja k??la"/><asula kood="5393" nimi="Neemisk??la"/><asula kood="5447" nimi="Noorma k??la"/><asula kood="5880" nimi="Paju k??la"/><asula kood="5916" nimi="Palamuste k??la"/><asula kood="5952" nimi="Palupera k??la"/><asula kood="5957" nimi="Palup??hja k??la"/><asula kood="6031" nimi="Pastaku k??la"/><asula kood="6071" nimi="Pedaste k??la"/><asula kood="6164" nimi="Piigandi k??la"/><asula kood="6322" nimi="Poole k??la"/><asula kood="6328" nimi="Porik??la"/><asula kood="6393" nimi="Puhja alevik"/><asula kood="6453" nimi="Purtsi k??la"/><asula kood="6648" nimi="P????ritsa k??la"/><asula kood="6663" nimi="P??haste k??la"/><asula kood="6748" nimi="Raigaste k??la"/><asula kood="6809" nimi="Rannak??la"/><asula kood="6822" nimi="Rannu alevik"/><asula kood="6890" nimi="Rebaste k??la"/><asula kood="6955" nimi="Ridak??la"/><asula kood="7167" nimi="R??ngu alevik"/><asula kood="7208" nimi="R??msi k??la"/><asula kood="7282" nimi="Saare k??la"/><asula kood="7420" nimi="Sangla k??la"/><asula kood="7833" nimi="Suure-Rakke k??la"/><asula kood="8094" nimi="Tamme k??la"/><asula kood="8121" nimi="Tammiste k??la"/><asula kood="8180" nimi="Teedla k??la"/><asula kood="8189" nimi="Teilma k??la"/><asula kood="8238" nimi="Tilga k??la"/><asula kood="8575" nimi="T??nnassilma k??la"/><asula kood="8614" nimi="Uderna k??la"/><asula kood="8655" nimi="Ulila alevik"/><asula kood="8727" nimi="Urmi k??la"/><asula kood="8750" nimi="Utukolga k??la"/><asula kood="8846" nimi="Vahessaare k??la"/><asula kood="8941" nimi="Valguta k??la"/><asula kood="8959" nimi="Vallapalu k??la"/><asula kood="9178" nimi="Vehendi k??la"/><asula kood="9191" nimi="Vellavere k??la"/><asula kood="9211" nimi="Verevi k??la"/><asula kood="9260" nimi="Vihavu k??la"/><asula kood="2842" nimi="V??llinge k??la"/><asula kood="9591" nimi="V??sivere k??la"/><asula kood="9633" nimi="V??ike-Rakke k??la"/></vald><vald kood="0283" nimi="Kambja vald"><asula kood="1016" nimi="Aakaru k??la"/><asula kood="2119" nimi="Ivaste k??la"/><asula kood="2433" nimi="Kaatsi k??la"/><asula kood="2641" nimi="Kambja alevik"/><asula kood="2644" nimi="Kammeri k??la"/><asula kood="2891" nimi="Kavandu k??la"/><asula kood="3239" nimi="Kodij??rve k??la"/><asula kood="3585" nimi="Kullaga k??la"/><asula kood="3804" nimi="K??rkk??la"/><asula kood="3986" nimi="K??litse alevik"/><asula kood="4017" nimi="Laane k??la"/><asula kood="4085" nimi="Lalli k??la"/><asula kood="4266" nimi="Lemmatsi k??la"/><asula kood="4291" nimi="Lepiku k??la"/><asula kood="4648" nimi="L??ti k??la"/><asula kood="4720" nimi="Madise k??la"/><asula kood="5194" nimi="M??ek??la"/><asula kood="5690" nimi="Oomiste k??la"/><asula kood="5784" nimi="Paali k??la"/><asula kood="5949" nimi="Palum??e k??la"/><asula kood="5975" nimi="Pangodi k??la"/><asula kood="6426" nimi="Pulli k??la"/><asula kood="6666" nimi="P??hi k??la"/><asula kood="6692" nimi="Raanitsa k??la"/><asula kood="6884" nimi="Rebase k??la"/><asula kood="6932" nimi="Reola k??la"/><asula kood="6935" nimi="Reolasoo k??la"/><asula kood="6994" nimi="Riiviku k??la"/><asula kood="7214" nimi="R??ni alevik"/><asula kood="7624" nimi="Sipe k??la"/><asula kood="7642" nimi="Sirvaku k??la"/><asula kood="7666" nimi="Soinaste k??la"/><asula kood="7743" nimi="Soosilla k??la"/><asula kood="7793" nimi="Sulu k??la"/><asula kood="7828" nimi="Suure-Kambja k??la"/><asula kood="8085" nimi="Talvikese k??la"/><asula kood="8165" nimi="Tatra k??la"/><asula kood="8532" nimi="T??rvandi alevik"/><asula kood="8581" nimi="T??svere k??la"/><asula kood="8632" nimi="Uhti k??la"/><asula kood="8992" nimi="Vana-Kuuste k??la"/><asula kood="9404" nimi="Virulase k??la"/><asula kood="9419" nimi="Visnapuu k??la"/><asula kood="9717" nimi="??ssu k??la"/><asula kood="9835" nimi="??lenurme alevik"/></vald><vald kood="0291" nimi="Kastre vald"><asula kood="1010" nimi="Aadami k??la"/><asula kood="1024" nimi="Aardla k??la"/><asula kood="1022" nimi="Aardlapalu k??la"/><asula kood="1097" nimi="Agali k??la"/><asula kood="1125" nimi="Ahunapalu k??la"/><asula kood="1167" nimi="Alak??la"/><asula kood="1365" nimi="Aruaia k??la"/><asula kood="1696" nimi="Haaslava k??la"/><asula kood="1752" nimi="Hammaste k??la"/><asula kood="1997" nimi="Igevere k??la"/><asula kood="2000" nimi="Ignase k??la"/><asula kood="2076" nimi="Imste k??la"/><asula kood="2112" nimi="Issaku k??la"/><asula kood="2367" nimi="J??rvselja k??la"/><asula kood="2393" nimi="Kaagvere k??la"/><asula kood="2411" nimi="Kaarlim??isa k??la"/><asula kood="2682" nimi="Kannu k??la"/><asula kood="2840" nimi="Kastre k??la"/><asula kood="3167" nimi="Kitsek??la"/><asula kood="3315" nimi="Koke k??la"/><asula kood="3500" nimi="Kriimani k??la"/><asula kood="3652" nimi="Kurepalu k??la"/><asula kood="3677" nimi="Kurista k??la"/><asula kood="3748" nimi="K??ivuk??la"/><asula kood="3772" nimi="K??nnu k??la"/><asula kood="4099" nimi="Lange k??la"/><asula kood="4349" nimi="Liisp??llu k??la"/><asula kood="4658" nimi="L????niste k??la"/><asula kood="4868" nimi="Melliste k??la"/><asula kood="4906" nimi="Metsanurga k??la"/><asula kood="5160" nimi="M??ra k??la"/><asula kood="5240" nimi="M??ksa k??la"/><asula kood="5245" nimi="M??letj??rve k??la"/><asula kood="5944" nimi="Paluk??la"/><asula kood="6311" nimi="Poka k??la"/><asula kood="6584" nimi="P??kste k??la"/><asula kood="7042" nimi="Roiu alevik"/><asula kood="7066" nimi="Rookse k??la"/><asula kood="7161" nimi="R??ka k??la"/><asula kood="7423" nimi="Sarakuste k??la"/><asula kood="7764" nimi="Sudaste k??la"/><asula kood="8107" nimi="Tammevaldma k??la"/><asula kood="8201" nimi="Terikeste k??la"/><asula kood="8211" nimi="Tigase k??la"/><asula kood="8551" nimi="T????raste k??la"/><asula kood="8695" nimi="Unik??la"/><asula kood="8987" nimi="Vana-Kastre k??la"/><asula kood="9234" nimi="Veskim??e k??la"/><asula kood="9570" nimi="V??nnu alevik"/><asula kood="9583" nimi="V??ruk??la"/><asula kood="9605" nimi="V????pste k??la"/></vald><vald kood="0432" nimi="Luunja vald"><asula kood="2459" nimi="Kabina k??la"/><asula kood="2556" nimi="Kakumetsa k??la"/><asula kood="2897" nimi="Kavastu k??la"/><asula kood="3059" nimi="Kikaste k??la"/><asula kood="3749" nimi="K??ivu k??la"/><asula kood="4451" nimi="Lohkva k??la"/><asula kood="4583" nimi="Luunja alevik"/><asula kood="5046" nimi="Muri k??la"/><asula kood="5886" nimi="Pajukurmu k??la"/><asula kood="6249" nimi="Pilka k??la"/><asula kood="6314" nimi="Poksi k??la"/><asula kood="6552" nimi="P??vvatu k??la"/><asula kood="7189" nimi="R????mu k??la"/><asula kood="7479" nimi="Sava k??la"/><asula kood="7491" nimi="Savikoja k??la"/><asula kood="7632" nimi="Sirgu k??la"/><asula kood="7635" nimi="Sirgumetsa k??la"/><asula kood="7958" nimi="S????sek??rva k??la"/><asula kood="7962" nimi="S????sk??la"/><asula kood="9183" nimi="Veibri k??la"/><asula kood="9286" nimi="Viira k??la"/></vald><vald kood="0528" nimi="N??o vald"><asula kood="1129" nimi="Aiamaa k??la"/><asula kood="1223" nimi="Altm??e k??la"/><asula kood="1605" nimi="Enno k??la"/><asula kood="1665" nimi="Etsaste k??la"/><asula kood="2039" nimi="Illi k??la"/><asula kood="2327" nimi="J??riste k??la"/><asula kood="2916" nimi="Keeri k??la"/><asula kood="2989" nimi="Ketneri k??la"/><asula kood="3338" nimi="Kolga k??la"/><asula kood="3939" nimi="K????ni k??la"/><asula kood="4046" nimi="Laguja k??la"/><asula kood="4557" nimi="Luke k??la"/><asula kood="4856" nimi="Meeri k??la"/><asula kood="5495" nimi="N??giaru k??la"/><asula kood="5534" nimi="N??o alevik"/><asula kood="7441" nimi="Sassi k??la"/><asula kood="8133" nimi="Tamsa k??la"/><asula kood="8512" nimi="T??ravere alevik"/><asula kood="8698" nimi="Unipiha k??la"/><asula kood="8796" nimi="Uuta k??la"/><asula kood="9423" nimi="Vissi k??la"/><asula kood="9452" nimi="Voika k??la"/></vald><vald kood="0586" nimi="Peipsi????re vald"><asula kood="1166" nimi="Alaj??e k??la"/><asula kood="1176" nimi="Alasoo k??la"/><asula kood="1181" nimi="Alatskivi alevik"/><asula kood="1413" nimi="Assikvere k??la"/><asula kood="1694" nimi="Haapsipea k??la"/><asula kood="1702" nimi="Haavakivi k??la"/><asula kood="2489" nimi="Kadrina k??la"/><asula kood="2596" nimi="Kallaste linn"/><asula kood="2717" nimi="Kargaja k??la"/><asula kood="2799" nimi="Kasep???? alevik"/><asula kood="2858" nimi="Kauda k??la"/><asula kood="2966" nimi="Keressaare k??la"/><asula kood="2979" nimi="Kesklahe k??la"/><asula kood="3151" nimi="Kirtsi k??la"/><asula kood="3234" nimi="Kodavere k??la"/><asula kood="3310" nimi="Kokanurga k??la"/><asula kood="3323" nimi="Kokora k??la"/><asula kood="3350" nimi="Kolkja alevik"/><asula kood="3425" nimi="Koosa k??la"/><asula kood="3427" nimi="Koosalaane k??la"/><asula kood="3626" nimi="Kuningvere k??la"/><asula kood="3703" nimi="Kusma k??la"/><asula kood="3721" nimi="Kuusiku k??la"/><asula kood="3732" nimi="K??desi k??la"/><asula kood="4050" nimi="Lahe k??la"/><asula kood="4055" nimi="Lahepera k??la"/><asula kood="4379" nimi="Linaleo k??la"/><asula kood="4685" nimi="L??mati k??la"/><asula kood="4816" nimi="Matjama k??la"/><asula kood="4871" nimi="Meoma k??la"/><asula kood="4889" nimi="Metsakivi k??la"/><asula kood="4904" nimi="Metsanurga k??la"/><asula kood="4972" nimi="Moku k??la"/><asula kood="5065" nimi="Mustametsa k??la"/><asula kood="5337" nimi="Naelavere k??la"/><asula kood="5427" nimi="Nina k??la"/><asula kood="5544" nimi="N??va k??la"/><asula kood="5709" nimi="Orgem??e k??la"/><asula kood="5807" nimi="Padak??rve k??la"/><asula kood="5905" nimi="Pala k??la"/><asula kood="5981" nimi="Papiaru k??la"/><asula kood="6026" nimi="Passi k??la"/><asula kood="6057" nimi="Peatskivi k??la"/><asula kood="6111" nimi="Perametsa k??la"/><asula kood="6161" nimi="Piibum??e k??la"/><asula kood="6189" nimi="Piirivarbe k??la"/><asula kood="6259" nimi="Pilpak??la"/><asula kood="6342" nimi="Praaga k??la"/><asula kood="6432" nimi="Punikvere k??la"/><asula kood="6458" nimi="Pusi k??la"/><asula kood="6488" nimi="P??dra k??la"/><asula kood="6515" nimi="P??ldmaa k??la"/><asula kood="6544" nimi="P??rgu k??la"/><asula kood="6577" nimi="P??iksi k??la"/><asula kood="6623" nimi="P??rsikivi k??la"/><asula kood="6699" nimi="Raatvere k??la"/><asula kood="6803" nimi="Ranna k??la"/><asula kood="6902" nimi="Rehemetsa k??la"/><asula kood="6984" nimi="Riidma k??la"/><asula kood="7043" nimi="Ronisoo k??la"/><asula kood="7090" nimi="Rootsik??la"/><asula kood="7127" nimi="Rupsi k??la"/><asula kood="7314" nimi="Saburi k??la"/><asula kood="7444" nimi="Sassukvere k??la"/><asula kood="7484" nimi="Savastvere k??la"/><asula kood="7499" nimi="Savimetsa k??la"/><asula kood="7500" nimi="Savka k??la"/><asula kood="7516" nimi="Selgise k??la"/><asula kood="7627" nimi="Sipelga k??la"/><asula kood="7703" nimi="Sookalduse k??la"/><asula kood="7761" nimi="Sudem??e k??la"/><asula kood="7913" nimi="S????ru k??la"/><asula kood="7938" nimi="S??rgla k??la"/><asula kood="7953" nimi="S????ritsa k??la"/><asula kood="8066" nimi="Tagumaa k??la"/><asula kood="8329" nimi="Torila k??la"/><asula kood="8335" nimi="Toruk??la"/><asula kood="8527" nimi="T??ruvere k??la"/><asula kood="8555" nimi="T??hemaa k??la"/><asula kood="8687" nimi="Undi k??la"/><asula kood="9031" nimi="Vanaussaia k??la"/><asula kood="9053" nimi="Vara k??la"/><asula kood="9090" nimi="Varnja alevik"/><asula kood="9150" nimi="Vea k??la"/><asula kood="9389" nimi="Virtsu k??la"/><asula kood="9644" nimi="V??lgi k??la"/><asula kood="9645" nimi="V??ljak??la"/><asula kood="9787" nimi="??teniidi k??la"/><asula kood="9790" nimi="??tte k??la"/></vald><vald kood="0793" nimi="Tartu linn"><asula kood="1681" nimi="Haage k??la"/><asula kood="2050" nimi="Ilmatsalu alevik"/><asula kood="2049" nimi="Ilmatsalu k??la"/><asula kood="2659" nimi="Kandik??la"/><asula kood="2710" nimi="Kardla k??la"/><asula kood="5277" nimi="M??rja alevik"/><asula kood="6155" nimi="Pihva k??la"/><asula kood="6724" nimi="Rahinge k??la"/><asula kood="7158" nimi="R??hu k??la"/><asula kood="8151" nimi="Tartu linn"/><asula kood="8560" nimi="T??htvere k??la"/><asula kood="8590" nimi="T??ki k??la"/><asula kood="9483" nimi="Vorbuse k??la"/></vald><vald kood="0796" nimi="Tartu vald"><asula kood="1312" nimi="Aovere k??la"/><asula kood="1383" nimi="Arup???? k??la"/><asula kood="1579" nimi="Elistvere k??la"/><asula kood="1617" nimi="Erala k??la"/><asula kood="1699" nimi="Haava k??la"/><asula kood="1993" nimi="Igavere k??la"/><asula kood="2218" nimi="Juula k??la"/><asula kood="2286" nimi="J??usa k??la"/><asula kood="2525" nimi="Kaiavere k??la"/><asula kood="2550" nimi="Kaitsem??isa k??la"/><asula kood="2809" nimi="Kassema k??la"/><asula kood="2829" nimi="Kastli k??la"/><asula kood="3064" nimi="Kikivere k??la"/><asula kood="3221" nimi="Kobratu k??la"/><asula kood="3386" nimi="Koogi k??la"/><asula kood="3572" nimi="Kukulinna k??la"/><asula kood="3737" nimi="K??duk??la"/><asula kood="3777" nimi="K??nnuj??e k??la"/><asula kood="3788" nimi="K??renduse k??la"/><asula kood="3824" nimi="K??rvek??la alevik"/><asula kood="3872" nimi="K??mara k??la"/><asula kood="3900" nimi="K??revere k??la"/><asula kood="3911" nimi="K??rkna k??la"/><asula kood="3913" nimi="K??rksi k??la"/><asula kood="3970" nimi="K??kitaja k??la"/><asula kood="4040" nimi="Laeva k??la"/><asula kood="4093" nimi="Lammiku k??la"/><asula kood="4375" nimi="Lilu k??la"/><asula kood="4487" nimi="Lombi k??la"/><asula kood="4629" nimi="L??hte alevik"/><asula kood="4709" nimi="Maarja-Magdaleena k??la"/><asula kood="4779" nimi="Maramaa k??la"/><asula kood="4900" nimi="Metsanuka k??la"/><asula kood="5310" nimi="M??llatsi k??la"/><asula kood="5408" nimi="Nigula k??la"/><asula kood="5492" nimi="N??ela k??la"/><asula kood="5769" nimi="Otslava k??la"/><asula kood="6034" nimi="Pataste k??la"/><asula kood="6185" nimi="Piiri k??la"/><asula kood="6401" nimi="Puhtaleiva k??la"/><asula kood="6437" nimi="Pupastvere k??la"/><asula kood="6751" nimi="Raigastvere k??la"/><asula kood="6918" nimi="Reinu k??la"/><asula kood="7273" nimi="Saadj??rve k??la"/><asula kood="7286" nimi="Saare k??la"/><asula kood="7393" nimi="Salu k??la"/><asula kood="7542" nimi="Sepa k??la"/><asula kood="7614" nimi="Sinik??la"/><asula kood="7655" nimi="Soek??la"/><asula kood="7668" nimi="Soitsj??rve k??la"/><asula kood="7671" nimi="Sojamaa k??la"/><asula kood="7745" nimi="Sootaga k??la"/><asula kood="7756" nimi="Sortsi k??la"/><asula kood="7988" nimi="Taabri k??la"/><asula kood="8016" nimi="Tabivere alevik"/><asula kood="8123" nimi="Tammistu k??la"/><asula kood="8235" nimi="Tila k??la"/><asula kood="8290" nimi="Toolamaa k??la"/><asula kood="8308" nimi="Tooni k??la"/><asula kood="8334" nimi="Tormi k??la"/><asula kood="8629" nimi="Uhmardu k??la"/><asula kood="8850" nimi="Vahi alevik"/><asula kood="8849" nimi="Vahi k??la"/><asula kood="8934" nimi="Valgma k??la"/><asula kood="8966" nimi="Valmaotsa k??la"/><asula kood="9136" nimi="Vasula alevik"/><asula kood="9161" nimi="Vedu k??la"/><asula kood="9240" nimi="Vesneri k??la"/><asula kood="9273" nimi="Viidike k??la"/><asula kood="9367" nimi="Vilussaare k??la"/><asula kood="9461" nimi="Voldi k??la"/><asula kood="9514" nimi="V??ibla k??la"/><asula kood="9680" nimi="V????gvere k??la"/><asula kood="9688" nimi="V????nikvere k??la"/><asula kood="9725" nimi="??vanurme k??la"/><asula kood="9728" nimi="??vi k??la"/><asula kood="9748" nimi="??ksi alevik"/></vald></maakond><maakond kood="0081" nimi="Valga maakond"><vald kood="0557" nimi="Otep???? vald"><asula kood="1376" nimi="Arula k??la"/><asula kood="2053" nimi="Ilmj??rve k??la"/><asula kood="2820" nimi="Kassiratta k??la"/><asula kood="2837" nimi="Kastolatsi k??la"/><asula kood="2880" nimi="Kaurutootsi k??la"/><asula kood="2914" nimi="Keeni k??la"/><asula kood="2998" nimi="Kibena k??la"/><asula kood="3286" nimi="Koigu k??la"/><asula kood="3353" nimi="Kolli k??la"/><asula kood="3369" nimi="Komsi k??la"/><asula kood="3534" nimi="Kuigatsi k??la"/><asula kood="3663" nimi="Kurevere k??la"/><asula kood="3864" nimi="K??hri k??la"/><asula kood="3954" nimi="K????riku k??la"/><asula kood="4146" nimi="Lauk??la"/><asula kood="4525" nimi="Lossik??la"/><asula kood="4573" nimi="Lutike k??la"/><asula kood="4751" nimi="Makita k??la"/><asula kood="4837" nimi="Meegaste k??la"/><asula kood="4959" nimi="Miti k??la"/><asula kood="5195" nimi="M??ek??la"/><asula kood="5219" nimi="M??gestiku k??la"/><asula kood="5229" nimi="M??giste k??la"/><asula kood="5232" nimi="M??ha k??la"/><asula kood="5279" nimi="M??rdi k??la"/><asula kood="5396" nimi="Neeruti k??la"/><asula kood="5540" nimi="N??uni k??la"/><asula kood="5567" nimi="N??pli k??la"/><asula kood="5752" nimi="Otep???? k??la"/><asula kood="5755" nimi="Otep???? linn"/><asula kood="6060" nimi="Pedajam??e k??la"/><asula kood="6252" nimi="Pilkuse k??la"/><asula kood="6296" nimi="Plika k??la"/><asula kood="6352" nimi="Prange k??la"/><asula kood="6371" nimi="Pringi k??la"/><asula kood="6417" nimi="Puka alevik"/><asula kood="6549" nimi="P??ru k??la"/><asula kood="6570" nimi="P??idla k??la"/><asula kood="6659" nimi="P??haj??rve k??la"/><asula kood="6857" nimi="Raudsepa k??la"/><asula kood="6943" nimi="Restu k??la"/><asula kood="7018" nimi="Risttee k??la"/><asula kood="7148" nimi="Ruuna k??la"/><asula kood="7195" nimi="R??bi k??la"/><asula kood="7418" nimi="Sangaste alevik"/><asula kood="7426" nimi="Sarapuu k??la"/><asula kood="7565" nimi="Sihva k??la"/><asula kood="8219" nimi="Tiidu k??la"/><asula kood="8356" nimi="Truuta k??la"/><asula kood="8546" nimi="T??utsi k??la"/><asula kood="8806" nimi="Vaalu k??la"/><asula kood="8808" nimi="Vaardi k??la"/><asula kood="8999" nimi="Vana-Otep???? k??la"/><asula kood="9252" nimi="Vidrike k??la"/><asula kood="9733" nimi="??du k??la"/></vald><vald kood="0824" nimi="T??rva vald"><asula kood="1152" nimi="Aitsra k??la"/><asula kood="1160" nimi="Ala k??la"/><asula kood="1171" nimi="Alam??isa k??la"/><asula kood="1815" nimi="Helme alevik"/><asula kood="1883" nimi="Holdre k??la"/><asula kood="1905" nimi="Hummuli alevik"/><asula kood="2187" nimi="Jeti k??la"/><asula kood="2264" nimi="J??geveste k??la"/><asula kood="2623" nimi="Kalme k??la"/><asula kood="2757" nimi="Karjatnurme k??la"/><asula kood="2772" nimi="Karu k??la"/><asula kood="2856" nimi="Kaubi k??la"/><asula kood="3124" nimi="Kirikuk??la"/><asula kood="3420" nimi="Koork??la"/><asula kood="3596" nimi="Kulli k??la"/><asula kood="3611" nimi="Kungi k??la"/><asula kood="3866" nimi="K??hu k??la"/><asula kood="4173" nimi="Leebiku k??la"/><asula kood="4390" nimi="Linna k??la"/><asula kood="4433" nimi="Liva k??la"/><asula kood="4620" nimi="L??ve k??la"/><asula kood="5304" nimi="M??ldre k??la"/><asula kood="6042" nimi="Patk??la"/><asula kood="6186" nimi="Piiri k??la"/><asula kood="6222" nimi="Pikasilla k??la"/><asula kood="6257" nimi="Pilpa k??la"/><asula kood="6330" nimi="Pori k??la"/><asula kood="6408" nimi="Puide k??la"/><asula kood="6824" nimi="Ransi k??la"/><asula kood="6946" nimi="Reti k??la"/><asula kood="6976" nimi="Riidaja k??la"/><asula kood="7053" nimi="Roobe k??la"/><asula kood="7113" nimi="Rulli k??la"/><asula kood="7654" nimi="Soe k??la"/><asula kood="7730" nimi="Soontaga k??la"/><asula kood="7993" nimi="Taagepera k??la"/><asula kood="8529" nimi="T??rva linn"/><asula kood="8714" nimi="Uralaane k??la"/><asula kood="9025" nimi="Vanam??isa k??la"/><asula kood="9464" nimi="Voorbahi k??la"/></vald><vald kood="0855" nimi="Valga vald"><asula kood="1766" nimi="Hargla k??la"/><asula kood="2016" nimi="Iigaste k??la"/><asula kood="2137" nimi="Jaanikese k??la"/><asula kood="2384" nimi="Kaagj??rve k??la"/><asula kood="2609" nimi="Kallik??la"/><asula kood="2775" nimi="Karula k??la"/><asula kood="3087" nimi="Killinge k??la"/><asula kood="3116" nimi="Kirbu k??la"/><asula kood="3180" nimi="Kivik??la"/><asula kood="3289" nimi="Koikk??la"/><asula kood="3304" nimi="Koiva k??la"/><asula kood="3383" nimi="Koobassaare k??la"/><asula kood="3447" nimi="Korij??rve k??la"/><asula kood="3452" nimi="Korkuna k??la"/><asula kood="3951" nimi="K????rikm??e k??la"/><asula kood="4024" nimi="Laanemetsa k??la"/><asula kood="4029" nimi="Laatre alevik"/><asula kood="4281" nimi="Lepa k??la"/><asula kood="4493" nimi="Londi k??la"/><asula kood="4530" nimi="Lota k??la"/><asula kood="4563" nimi="Lusti k??la"/><asula kood="4576" nimi="Lutsu k??la"/><asula kood="4677" nimi="L??llem??e k??la"/><asula kood="5003" nimi="Muhkva k??la"/><asula kood="5096" nimi="Mustumetsa k??la"/><asula kood="5881" nimi="Paju k??la"/><asula kood="6234" nimi="Pikkj??rve k??la"/><asula kood="6365" nimi="Priipalu k??la"/><asula kood="6388" nimi="Pugritsa k??la"/><asula kood="6702" nimi="Raavitsa k??la"/><asula kood="6786" nimi="Rampe k??la"/><asula kood="6887" nimi="Rebasem??isa k??la"/><asula kood="7005" nimi="Ringiste k??la"/><asula kood="7686" nimi="Sooblase k??la"/><asula kood="7738" nimi="Sooru k??la"/><asula kood="7801" nimi="Supa k??la"/><asula kood="8064" nimi="Tagula k??la"/><asula kood="8069" nimi="Taheva k??la"/><asula kood="8248" nimi="Tinu k??la"/><asula kood="8365" nimi="Tsirguliina alevik"/><asula kood="8368" nimi="Tsirgum??e k??la"/><asula kood="8491" nimi="T??lliste k??la"/><asula kood="8535" nimi="T??rvase k??la"/><asula kood="8696" nimi="Unik??la"/><asula kood="8918" nimi="Valga linn"/><asula kood="8969" nimi="Valtina k??la"/><asula kood="9326" nimi="Vilaski k??la"/><asula kood="9618" nimi="V??heru k??la"/><asula kood="9651" nimi="V??ljak??la"/><asula kood="9699" nimi="??latu k??la"/><asula kood="9710" nimi="??ru alevik"/><asula kood="9713" nimi="??ruste k??la"/></vald></maakond><maakond kood="0084" nimi="Viljandi maakond"><vald kood="0480" nimi="Mulgi vald"><asula kood="1060" nimi="Abja-Paluoja linn"/><asula kood="8593" nimi="Abja-Vanam??isa k??la"/><asula kood="1061" nimi="Abjaku k??la"/><asula kood="1149" nimi="Ainja k??la"/><asula kood="1199" nimi="Allaste k??la"/><asula kood="1433" nimi="Atika k??la"/><asula kood="1625" nimi="Ereste k??la"/><asula kood="1749" nimi="Halliste alevik"/><asula kood="1868" nimi="Hirmuk??la"/><asula kood="1926" nimi="H??bem??e k??la"/><asula kood="2406" nimi="Kaarli k??la"/><asula kood="2628" nimi="Kalvre k??la"/><asula kood="2634" nimi="Kamara k??la"/><asula kood="2759" nimi="Karksi k??la"/><asula kood="2761" nimi="Karksi-Nuia linn"/><asula kood="3580" nimi="Kulla k??la"/><asula kood="3837" nimi="K??vak??la"/><asula kood="4030" nimi="Laatre k??la"/><asula kood="4120" nimi="Lasari k??la"/><asula kood="4183" nimi="Leeli k??la"/><asula kood="4370" nimi="Lilli k??la"/><asula kood="4802" nimi="Maru k??la"/><asula kood="4893" nimi="Metsak??la"/><asula kood="4989" nimi="Morna k??la"/><asula kood="5020" nimi="Mulgi k??la"/><asula kood="5047" nimi="Muri k??la"/><asula kood="5145" nimi="M??isak??la linn"/><asula kood="5178" nimi="M????naste k??la"/><asula kood="7211" nimi="M??ek??la"/><asula kood="5349" nimi="Naistevalla k??la"/><asula kood="5411" nimi="Niguli k??la"/><asula kood="5758" nimi="Oti k??la"/><asula kood="6106" nimi="Penuja k??la"/><asula kood="6317" nimi="Polli k??la"/><asula kood="6335" nimi="Pornuse k??la"/><asula kood="6510" nimi="P??lde k??la"/><asula kood="6572" nimi="P??idre k??la"/><asula kood="6575" nimi="P??igiste k??la"/><asula kood="6621" nimi="P??rsi k??la"/><asula kood="6641" nimi="P????gle k??la"/><asula kood="6689" nimi="Raamatu k??la"/><asula kood="6765" nimi="Raja k??la"/><asula kood="7002" nimi="Rimmu k??la"/><asula kood="7238" nimi="R????gu k??la"/><asula kood="7313" nimi="Saate k??la"/><asula kood="7356" nimi="Saksak??la"/><asula kood="7410" nimi="Sammaste k??la"/><asula kood="7433" nimi="Sarja k??la"/><asula kood="7767" nimi="Sudiste k??la"/><asula kood="7825" nimi="Suuga k??la"/><asula kood="8240" nimi="Tilla k??la"/><asula kood="8310" nimi="Toosi k??la"/><asula kood="8398" nimi="Tuhalaane k??la"/><asula kood="8672" nimi="Umbsoo k??la"/><asula kood="8701" nimi="Univere k??la"/><asula kood="8759" nimi="Uue-Kariste k??la"/><asula kood="8816" nimi="Vabamatsi k??la"/><asula kood="8984" nimi="Vana-Kariste k??la"/><asula kood="9167" nimi="Veelikse k??la"/><asula kood="9235" nimi="Veskim??e k??la"/><asula kood="9695" nimi="??isu alevik"/><asula kood="9780" nimi="??rik??la"/><asula kood="9830" nimi="??lem??isa k??la"/></vald><vald kood="0615" nimi="P??hja-Sakala vald"><asula kood="1144" nimi="Aimla k??la"/><asula kood="1354" nimi="Arjadi k??la"/><asula kood="1356" nimi="Arjassaare k??la"/><asula kood="1386" nimi="Arussaare k??la"/><asula kood="1613" nimi="Epra k??la"/><asula kood="2013" nimi="Iia k??la"/><asula kood="2033" nimi="Ilbaku k??la"/><asula kood="2116" nimi="Ivaski k??la"/><asula kood="2175" nimi="Jaska k??la"/><asula kood="2304" nimi="J??levere k??la"/><asula kood="2456" nimi="Kabila k??la"/><asula kood="2674" nimi="Kangrussaare k??la"/><asula kood="2754" nimi="Karjasoo k??la"/><asula kood="2973" nimi="Kerita k??la"/><asula kood="2993" nimi="Kibaru k??la"/><asula kood="3079" nimi="Kildu k??la"/><asula kood="3142" nimi="Kirivere k??la"/><asula kood="3226" nimi="Kobruvere k??la"/><asula kood="3328" nimi="Koksvere k??la"/><asula kood="3430" nimi="Kootsi k??la"/><asula kood="3523" nimi="Kuhjavere k??la"/><asula kood="3529" nimi="Kuiavere k??la"/><asula kood="3619" nimi="Kuninga k??la"/><asula kood="3690" nimi="Kurnuvere k??la"/><asula kood="3741" nimi="K??idama k??la"/><asula kood="3775" nimi="K??o k??la"/><asula kood="3782" nimi="K??pu alevik"/><asula kood="3901" nimi="K??revere k??la"/><asula kood="4018" nimi="Laane k??la"/><asula kood="4060" nimi="Lahmuse k??la"/><asula kood="4261" nimi="Lemmak??nnu k??la"/><asula kood="4514" nimi="Loopre k??la"/><asula kood="4598" nimi="L??havere k??la"/><asula kood="4699" nimi="Maalasti k??la"/><asula kood="4925" nimi="Metsk??la"/><asula kood="4998" nimi="Mudiste k??la"/><asula kood="5031" nimi="Munsi k??la"/><asula kood="5196" nimi="M??ek??la"/><asula kood="5375" nimi="Navesti k??la"/><asula kood="5488" nimi="Nuutre k??la"/><asula kood="5669" nimi="Olustvere alevik"/><asula kood="5781" nimi="Paaksima k??la"/><asula kood="5828" nimi="Paelama k??la"/><asula kood="5833" nimi="Paenasti k??la"/><asula kood="6247" nimi="Pilistvere k??la"/><asula kood="6429" nimi="Punak??la"/><asula kood="6502" nimi="P??hjaka k??la"/><asula kood="6596" nimi="P??rak??la"/><asula kood="6897" nimi="Reegoldi k??la"/><asula kood="6974" nimi="Riiassaare k??la"/><asula kood="7240" nimi="R????ka k??la"/><asula kood="7415" nimi="Sandra k??la"/><asula kood="7489" nimi="Saviaugu k??la"/><asula kood="7550" nimi="Seruk??la"/><asula kood="7720" nimi="Soomevere k??la"/><asula kood="7804" nimi="Supsi k??la"/><asula kood="7836" nimi="Suure-Jaani linn"/><asula kood="7978" nimi="S??rgavere k??la"/><asula kood="8030" nimi="Taevere k??la"/><asula kood="8251" nimi="Tipu k??la"/><asula kood="8566" nimi="T??llevere k??la"/><asula kood="8586" nimi="T????ksi k??la"/><asula kood="8641" nimi="Uia k??la"/><asula kood="8681" nimi="Unakvere k??la"/><asula kood="9036" nimi="Vanaveski k??la"/><asula kood="9123" nimi="Vastem??isa k??la"/><asula kood="9205" nimi="Venevere k??la"/><asula kood="9262" nimi="Vihi k??la"/><asula kood="9500" nimi="V??hma linn"/><asula kood="9503" nimi="V??hmassaare k??la"/><asula kood="9546" nimi="V??ivaku k??la"/><asula kood="9561" nimi="V??lli k??la"/><asula kood="9765" nimi="??ngi k??la"/><asula kood="9824" nimi="??lde k??la"/></vald><vald kood="0897" nimi="Viljandi linn"/><vald kood="0899" nimi="Viljandi vald"><asula kood="1138" nimi="Aidu k??la"/><asula kood="1147" nimi="Aindu k??la"/><asula kood="1240" nimi="Alustre k??la"/><asula kood="1283" nimi="Anikatsi k??la"/><asula kood="1461" nimi="Auksi k??la"/><asula kood="1539" nimi="Eesnurga k??la"/><asula kood="1794" nimi="Heimtali k??la"/><asula kood="1821" nimi="Hendrikum??isa k??la"/><asula kood="1888" nimi="Holstre k??la"/><asula kood="2093" nimi="Intsu k??la"/><asula kood="2153" nimi="Jakobim??isa k??la"/><asula kood="2229" nimi="J??ek??la"/><asula kood="2312" nimi="J??mejala k??la"/><asula kood="2338" nimi="J??rtsaare k??la"/><asula kood="2355" nimi="J??rvek??la"/><asula kood="2439" nimi="Kaavere k??la"/><asula kood="2570" nimi="Kalbuse k??la"/><asula kood="2685" nimi="Kannuk??la"/><asula kood="2776" nimi="Karula k??la"/><asula kood="2813" nimi="Kassi k??la"/><asula kood="2996" nimi="Kibek??la"/><asula kood="3042" nimi="Kiini k??la"/><asula kood="3047" nimi="Kiisa k??la"/><asula kood="3100" nimi="Kingu k??la"/><asula kood="3185" nimi="Kivil??ppe k??la"/><asula kood="3275" nimi="Koidu k??la"/><asula kood="3313" nimi="Kokaviidika k??la"/><asula kood="3340" nimi="Kolga-Jaani alevik"/><asula kood="3396" nimi="Kookla k??la"/><asula kood="3658" nimi="Kuressaare k??la"/><asula kood="3711" nimi="Kuudek??la"/><asula kood="3927" nimi="K??rstna k??la"/><asula kood="4021" nimi="Laanekuru k??la"/><asula kood="4088" nimi="Lalsi k??la"/><asula kood="4185" nimi="Leemeti k??la"/><asula kood="4225" nimi="Leie k??la"/><asula kood="4462" nimi="Loime k??la"/><asula kood="4484" nimi="Lolu k??la"/><asula kood="4501" nimi="Loodi k??la"/><asula kood="4548" nimi="Luiga k??la"/><asula kood="4650" nimi="L??tkalu k??la"/><asula kood="4763" nimi="Maltsa k??la"/><asula kood="4789" nimi="Marjam??e k??la"/><asula kood="4794" nimi="Marna k??la"/><asula kood="4814" nimi="Matapera k??la"/><asula kood="4865" nimi="Meleski k??la"/><asula kood="4928" nimi="Metsla k??la"/><asula kood="4981" nimi="Moori k??la"/><asula kood="5017" nimi="Muksi k??la"/><asula kood="5070" nimi="Mustapali k??la"/><asula kood="5075" nimi="Mustivere k??la"/><asula kood="5084" nimi="Mustla alevik"/><asula kood="5152" nimi="M??nnaste k??la"/><asula kood="5201" nimi="M??eltk??la"/><asula kood="5237" nimi="M??hma k??la"/><asula kood="5595" nimi="Odiste k??la"/><asula kood="5647" nimi="Oiu k??la"/><asula kood="5701" nimi="Oorgu k??la"/><asula kood="5763" nimi="Otik??la"/><asula kood="5859" nimi="Pahuvere k??la"/><asula kood="5872" nimi="Paistu k??la"/><asula kood="6007" nimi="Parika k??la"/><asula kood="6090" nimi="Peetrim??isa k??la"/><asula kood="6239" nimi="Pikru k??la"/><asula kood="6271" nimi="Pinska k??la"/><asula kood="6276" nimi="Pirmastu k??la"/><asula kood="6338" nimi="Porsa k??la"/><asula kood="6406" nimi="Puiatu k??la"/><asula kood="6423" nimi="Pulleritsu k??la"/><asula kood="6541" nimi="P??rga k??la"/><asula kood="6601" nimi="P??ri k??la"/><asula kood="6626" nimi="P??rsti k??la"/><asula kood="6697" nimi="Raassilla k??la"/><asula kood="6789" nimi="Ramsi alevik"/><asula kood="6852" nimi="Raudna k??la"/><asula kood="6885" nimi="Rebase k??la"/><asula kood="6891" nimi="Rebaste k??la"/><asula kood="6956" nimi="Ridak??la"/><asula kood="6971" nimi="Rihkama k??la"/><asula kood="7024" nimi="Riuma k??la"/><asula kood="7076" nimi="Roosilla k??la"/><asula kood="7143" nimi="Ruudik??la"/><asula kood="7290" nimi="Saarek??la"/><asula kood="7295" nimi="Saarepeedi k??la"/><asula kood="7494" nimi="Savikoti k??la"/><asula kood="7611" nimi="Sinialliku k??la"/><asula kood="7653" nimi="Soe k??la"/><asula kood="7750" nimi="Sooviku k??la"/><asula kood="7779" nimi="Suislepa k??la"/><asula kood="7790" nimi="Sultsi k??la"/><asula kood="7812" nimi="Surva k??la"/><asula kood="8003" nimi="Taari k??la"/><asula kood="8048" nimi="Tagam??isa k??la"/><asula kood="8050" nimi="Taganurga k??la"/><asula kood="8159" nimi="Tarvastu k??la"/><asula kood="8247" nimi="Tinnikuru k??la"/><asula kood="8264" nimi="Tobraselja k??la"/><asula kood="8272" nimi="Tohvri k??la"/><asula kood="8431" nimi="Turva k??la"/><asula kood="8439" nimi="Tusti k??la"/><asula kood="8504" nimi="T??nissaare k??la"/><asula kood="8507" nimi="T??nuk??la"/><asula kood="8522" nimi="T??rrek??la"/><asula kood="8569" nimi="T??nassilma k??la"/><asula kood="8496" nimi="T??mbi k??la"/><asula kood="8684" nimi="Unametsa k??la"/><asula kood="8790" nimi="Uusna k??la"/><asula kood="8864" nimi="Vaibla k??la"/><asula kood="8964" nimi="Valma k??la"/><asula kood="9012" nimi="Vana-V??idu k??la"/><asula kood="9026" nimi="Vanam??isa k??la"/><asula kood="9034" nimi="Vanausse k??la"/><asula kood="9039" nimi="Vanav??lja k??la"/><asula kood="9068" nimi="Vardi k??la"/><asula kood="9073" nimi="Vardja k??la"/><asula kood="9103" nimi="Vasara k??la"/><asula kood="9186" nimi="Veisj??rve k??la"/><asula kood="9221" nimi="Verilaske k??la"/><asula kood="9292" nimi="Viiratsi alevik"/><asula kood="9305" nimi="Viisuk??la"/><asula kood="9331" nimi="Vilimeeste k??la"/><asula kood="9344" nimi="Villa k??la"/><asula kood="9426" nimi="Vissuvere k??la"/><asula kood="9477" nimi="Vooru k??la"/><asula kood="9541" nimi="V??istre k??la"/><asula kood="9626" nimi="V??ike-K??pu k??la"/><asula kood="9646" nimi="V??lgita k??la"/><asula kood="9661" nimi="V??luste k??la"/><asula kood="9758" nimi="??mmuste k??la"/><asula kood="9833" nimi="??lensi k??la"/></vald></maakond><maakond kood="0087" nimi="V??ru maakond"><vald kood="0142" nimi="Antsla vald"><asula kood="1288" nimi="Anne k??la"/><asula kood="1301" nimi="Antsla linn"/><asula kood="1303" nimi="Antsu k??la"/><asula kood="1678" nimi="Haabsaare k??la"/><asula kood="2242" nimi="J??epera k??la"/><asula kood="2535" nimi="Kaika k??la"/><asula kood="2812" nimi="Kassi k??la"/><asula kood="3069" nimi="Kikkaoja k??la"/><asula kood="3125" nimi="Kirikuk??la"/><asula kood="3214" nimi="Kobela alevik"/><asula kood="3287" nimi="Koigu k??la"/><asula kood="3355" nimi="Kollino k??la"/><asula kood="3486" nimi="Kraavi k??la"/><asula kood="3575" nimi="Kuldre k??la"/><asula kood="3752" nimi="K??lbi k??la"/><asula kood="4427" nimi="Litsmetsa k??la"/><asula kood="4543" nimi="Luhametsa k??la"/><asula kood="4564" nimi="Lusti k??la"/><asula kood="4689" nimi="L??matu k??la"/><asula kood="4721" nimi="Madise k??la"/><asula kood="5234" nimi="M??hkli k??la"/><asula kood="5605" nimi="Oe k??la"/><asula kood="6150" nimi="Pihleni k??la"/><asula kood="6196" nimi="Piisi k??la"/><asula kood="7000" nimi="Rimmi k??la"/><asula kood="7073" nimi="Roosiku k??la"/><asula kood="7102" nimi="Ruhingu k??la"/><asula kood="7496" nimi="Savil????vi k??la"/><asula kood="7714" nimi="Soome k??la"/><asula kood="7933" nimi="S??re k??la"/><asula kood="8011" nimi="Taberlaane k??la"/><asula kood="8280" nimi="Toku k??la"/><asula kood="8378" nimi="Tsooru k??la"/><asula kood="8634" nimi="Uhtj??rve k??la"/><asula kood="8733" nimi="Urvaste k??la"/><asula kood="8757" nimi="Uue-Antsla k??la"/><asula kood="8801" nimi="Vaabina k??la"/><asula kood="8977" nimi="Vana-Antsla alevik"/><asula kood="9290" nimi="Viirapalu k??la"/><asula kood="9414" nimi="Visela k??la"/><asula kood="9737" nimi="??hij??rve k??la"/></vald><vald kood="0698" nimi="R??uge vald"><asula kood="1005" nimi="Aabra k??la"/><asula kood="1111" nimi="Ahitsa k??la"/><asula kood="1161" nimi="Ala-Palo k??la"/><asula kood="1164" nimi="Ala-Suhka k??la"/><asula kood="1162" nimi="Ala-Tilga k??la"/><asula kood="1262" nimi="Andsum??e k??la"/><asula kood="1456" nimi="Augli k??la"/><asula kood="1676" nimi="Haabsilla k??la"/><asula kood="1689" nimi="Haanja k??la"/><asula kood="1703" nimi="Haavistu k??la"/><asula kood="1728" nimi="Haki k??la"/><asula kood="1745" nimi="Hallim??e k??la"/><asula kood="1753" nimi="Handimiku k??la"/><asula kood="1750" nimi="Hanija k??la"/><asula kood="1758" nimi="Hansi k??la"/><asula kood="1756" nimi="Hapsu k??la"/><asula kood="1772" nimi="Harjuk??la"/><asula kood="1789" nimi="Heedu k??la"/><asula kood="1791" nimi="Heibri k??la"/><asula kood="1858" nimi="Hino k??la"/><asula kood="1863" nimi="Hintsiko k??la"/><asula kood="1861" nimi="Hinu k??la"/><asula kood="1881" nimi="Holdi k??la"/><asula kood="1890" nimi="Horoski k??la"/><asula kood="1893" nimi="Horosuu k??la"/><asula kood="1898" nimi="Horsa k??la"/><asula kood="1896" nimi="Hot??m??e k??la"/><asula kood="1895" nimi="Hulaku k??la"/><asula kood="1911" nimi="Hurda k??la"/><asula kood="1933" nimi="H??mkoti k??la"/><asula kood="1956" nimi="H??r??m??e k??la"/><asula kood="1958" nimi="H????rm??ni k??la"/><asula kood="1968" nimi="H??rova k??la"/><asula kood="1966" nimi="H??rsi k??la"/><asula kood="1972" nimi="H??ti k??la"/><asula kood="2008" nimi="Ihatsi k??la"/><asula kood="2145" nimi="Jaanim??e k??la"/><asula kood="2146" nimi="Jaanipeebu k??la"/><asula kood="2206" nimi="Jugu k??la"/><asula kood="2358" nimi="J??rvek??l?? k??la"/><asula kood="2357" nimi="J??rvepalu k??la"/><asula kood="2401" nimi="Kaaratautsa k??la"/><asula kood="2491" nimi="Kad??ni k??la"/><asula kood="2516" nimi="Kahrila-Mustahamba k??la"/><asula kood="2513" nimi="Kahru k??la"/><asula kood="2554" nimi="Kaku k??la"/><asula kood="2571" nimi="Kaldem??e k??la"/><asula kood="2598" nimi="Kallaste k??la"/><asula kood="2625" nimi="Kaloga k??la"/><asula kood="2627" nimi="Kaluka k??la"/><asula kood="2677" nimi="Kangsti k??la"/><asula kood="2704" nimi="Karaski k??la"/><asula kood="2708" nimi="Karba k??la"/><asula kood="2738" nimi="Karis????di k??la"/><asula kood="2854" nimi="Kaubi k??la"/><asula kood="2866" nimi="Kaugu k??la"/><asula kood="2899" nimi="Kav??ldi k??la"/><asula kood="2936" nimi="Kell??m??e k??la"/><asula kood="2968" nimi="Kergatsi k??la"/><asula kood="3026" nimi="Kiidi k??la"/><asula kood="3089" nimi="Kilomani k??la"/><asula kood="3095" nimi="Kimalas?? k??la"/><asula kood="3115" nimi="Kirbu k??la"/><asula kood="3193" nimi="Kiviora k??la"/><asula kood="3250" nimi="Koemetsa k??la"/><asula kood="3256" nimi="Kogr?? k??la"/><asula kood="3329" nimi="Kok?? k??la"/><asula kood="3327" nimi="Kok??j??ri k??la"/><asula kood="3318" nimi="Kok??m??e k??la"/><asula kood="3334" nimi="Kolga k??la"/><asula kood="3794" nimi="Korg??ssaar?? k??la"/><asula kood="3478" nimi="Kotka k??la"/><asula kood="3489" nimi="Krabi k??la"/><asula kood="3493" nimi="Kriguli k??la"/><asula kood="3522" nimi="Kuiandi k??la"/><asula kood="3559" nimi="Kuklase k??la"/><asula kood="3558" nimi="Kuklas?? k??la"/><asula kood="3374" nimi="Kundsa k??la"/><asula kood="3664" nimi="Kurgj??rve k??la"/><asula kood="3698" nimi="Kurvitsa k??la"/><asula kood="3635" nimi="Kur?? k??la"/><asula kood="3706" nimi="Kuuda k??la"/><asula kood="3713" nimi="Kuura k??la"/><asula kood="3728" nimi="Kuutsi k??la"/><asula kood="3780" nimi="K??om??e k??la"/><asula kood="3793" nimi="K??rgepalu k??la"/><asula kood="3851" nimi="K??bli k??la"/><asula kood="3861" nimi="K??hri k??la"/><asula kood="3873" nimi="K??ngsep?? k??la"/><asula kood="3906" nimi="K??rin?? k??la"/><asula kood="3941" nimi="K????nu k??la"/><asula kood="3946" nimi="K????raku k??la"/><asula kood="3990" nimi="K??lma k??la"/><asula kood="4071" nimi="Laisi k??la"/><asula kood="4076" nimi="Laitsna-Hurda k??la"/><asula kood="4111" nimi="Laossaar?? k??la"/><asula kood="4158" nimi="Lauri k??la"/><asula kood="4160" nimi="Laurim??e k??la"/><asula kood="4277" nimi="Leoski k??la"/><asula kood="4324" nimi="Liguri k??la"/><asula kood="4358" nimi="Liivakupalu k??la"/><asula kood="4372" nimi="Lillim??isa k??la"/><asula kood="4422" nimi="Listaku k??la"/><asula kood="4502" nimi="Loogam??e k??la"/><asula kood="4568" nimi="Lutika k??la"/><asula kood="4591" nimi="Luutsniku k??la"/><asula kood="4670" nimi="L??kk?? k??la"/><asula kood="4694" nimi="L????tsepa k??la"/><asula kood="4731" nimi="Mahtja k??la"/><asula kood="4760" nimi="Mallika k??la"/><asula kood="4825" nimi="Matsi k??la"/><asula kood="4830" nimi="Mauri k??la"/><asula kood="4846" nimi="Meelaku k??la"/><asula kood="4933" nimi="Metstaga k??la"/><asula kood="4946" nimi="Miilim??e k??la"/><asula kood="4947" nimi="Mikita k??la"/><asula kood="4954" nimi="Misso alevik"/><asula kood="4957" nimi="Misso-Saika k??la"/><asula kood="4956" nimi="Missok??l?? k??la"/><asula kood="4996" nimi="Muduri k??la"/><asula kood="5001" nimi="Muhkam??tsa k??la"/><asula kood="5024" nimi="Muna k??la"/><asula kood="5035" nimi="Muraski k??la"/><asula kood="5041" nimi="Murati k??la"/><asula kood="5042" nimi="Murd??m??e k??la"/><asula kood="5054" nimi="Mustahamba k??la"/><asula kood="5099" nimi="Mutemetsa k??la"/><asula kood="5149" nimi="M??niste k??la"/><asula kood="5176" nimi="M????lu k??la"/><asula kood="5199" nimi="M??e-L????tsep?? k??la"/><asula kood="5187" nimi="M??e-Palo k??la"/><asula kood="7773" nimi="M??e-Suhka k??la"/><asula kood="5189" nimi="M??e-Tilga k??la"/><asula kood="5283" nimi="M??rdi k??la"/><asula kood="5278" nimi="M??rdimiku k??la"/><asula kood="5305" nimi="M??ldre k??la"/><asula kood="5306" nimi="M??ldri k??la"/><asula kood="5323" nimi="Naapka k??la"/><asula kood="5423" nimi="Nilb?? k??la"/><asula kood="5434" nimi="Nogu k??la"/><asula kood="5477" nimi="Nursi k??la"/><asula kood="5732" nimi="Ortum??e k??la"/><asula kood="5770" nimi="Paaburissa k??la"/><asula kood="5822" nimi="Paeboja k??la"/><asula kood="5839" nimi="Paganamaa k??la"/><asula kood="5918" nimi="Palanum??e k??la"/><asula kood="5933" nimi="Palli k??la"/><asula kood="5942" nimi="Paluj??ri k??la"/><asula kood="6015" nimi="Parmu k??la"/><asula kood="6019" nimi="Parmupalu k??la"/><asula kood="6051" nimi="Pausakunnu k??la"/><asula kood="6069" nimi="Pedej?? k??la"/><asula kood="6076" nimi="Peebu k??la"/><asula kood="6078" nimi="Peedo k??la"/><asula kood="6128" nimi="Petrakuudi k??la"/><asula kood="6179" nimi="Piipsem??e k??la"/><asula kood="6253" nimi="Pillardi k??la"/><asula kood="6290" nimi="Plaani k??la"/><asula kood="6287" nimi="Plaksi k??la"/><asula kood="6336" nimi="Posti k??la"/><asula kood="6358" nimi="Preeksa k??la"/><asula kood="6362" nimi="Pressi k??la"/><asula kood="6386" nimi="Pug??stu k??la"/><asula kood="6433" nimi="Pulli k??la"/><asula kood="6428" nimi="Pundi k??la"/><asula kood="6434" nimi="Punsa k??la"/><asula kood="6435" nimi="Pupli k??la"/><asula kood="6439" nimi="Purka k??la"/><asula kood="6463" nimi="Puspuri k??la"/><asula kood="6485" nimi="P??dra k??la"/><asula kood="6490" nimi="P??dram??tsa k??la"/><asula kood="6538" nimi="P??nni k??la"/><asula kood="6545" nimi="P??ru k??la"/><asula kood="6564" nimi="P??hni k??la"/><asula kood="6592" nimi="P??ltre k??la"/><asula kood="6611" nimi="P??rlij??e k??la"/><asula kood="6670" nimi="P??ss?? k??la"/><asula kood="6687" nimi="Raagi k??la"/><asula kood="6784" nimi="Rammuka k??la"/><asula kood="6839" nimi="Rasva k??la"/><asula kood="6858" nimi="Raudsepa k??la"/><asula kood="6859" nimi="Raudsep?? k??la"/><asula kood="6892" nimi="Reb??se k??la"/><asula kood="6895" nimi="Reb??sem??isa k??la"/><asula kood="6938" nimi="Resto k??la"/><asula kood="6991" nimi="Riitsilla k??la"/><asula kood="7008" nimi="Ristem??e k??la"/><asula kood="7021" nimi="Ritsiko k??la"/><asula kood="7027" nimi="Rogosi-Mikita k??la"/><asula kood="7052" nimi="Roobi k??la"/><asula kood="7125" nimi="Rusa k??la"/><asula kood="7144" nimi="Ruuksu k??la"/><asula kood="7153" nimi="Ruusm??e k??la"/><asula kood="7181" nimi="R??uge alevik"/><asula kood="7168" nimi="R??uge-Matsi k??la"/><asula kood="7271" nimi="Saagri k??la"/><asula kood="7272" nimi="Saagrim??e k??la"/><asula kood="7305" nimi="Saarlas?? k??la"/><asula kood="7321" nimi="Sadram??tsa k??la"/><asula kood="7341" nimi="Saika k??la"/><asula kood="7346" nimi="Saki k??la"/><asula kood="7364" nimi="Sakudi k??la"/><asula kood="7363" nimi="Sakurgi k??la"/><asula kood="7397" nimi="Saluora k??la"/><asula kood="7411" nimi="Sandi k??la"/><asula kood="7409" nimi="Sandisuu k??la"/><asula kood="7419" nimi="Sapi k??la"/><asula kood="7431" nimi="Sarise k??la"/><asula kood="7436" nimi="Saru k??la"/><asula kood="7506" nimi="Savim??e k??la"/><asula kood="7504" nimi="Savioja k??la"/><asula kood="7507" nimi="Savioru k??la"/><asula kood="7574" nimi="Sika k??la"/><asula kood="7575" nimi="Sikalaan?? k??la"/><asula kood="7585" nimi="Siks??l?? k??la"/><asula kood="7600" nimi="Simmuli k??la"/><asula kood="7599" nimi="Simula k??la"/><asula kood="7609" nimi="Singa k??la"/><asula kood="7650" nimi="Soek??rdsi k??la"/><asula kood="7656" nimi="Soem??isa k??la"/><asula kood="7691" nimi="Soodi k??la"/><asula kood="7712" nimi="Sool??tte k??la"/><asula kood="7721" nimi="Soom??oru k??la"/><asula kood="7751" nimi="Sormuli k??la"/><asula kood="7146" nimi="Suur??-Ruuga k??la"/><asula kood="7849" nimi="Suur??suu k??la"/><asula kood="7930" nimi="S??nna/S??nn?? k??la"/><asula kood="7968" nimi="S????di k??la"/><asula kood="8038" nimi="Tagakolga k??la"/><asula kood="8086" nimi="Tallima k??la"/><asula kood="8170" nimi="Taudsa k??la"/><asula kood="8200" nimi="Tialas?? k??la"/><asula kood="8218" nimi="Tiidu k??la"/><asula kood="8229" nimi="Tiitsa k??la"/><asula kood="8233" nimi="Tika k??la"/><asula kood="8237" nimi="Tilgu k??la"/><asula kood="8241" nimi="Tindi k??la"/><asula kood="8284" nimi="Toodsi k??la"/><asula kood="8351" nimi="Trolla k??la"/><asula kood="8354" nimi="Tsiam??e k??la"/><asula kood="8357" nimi="Tsiiruli k??la"/><asula kood="8360" nimi="Tsiistre k??la"/><asula kood="8358" nimi="Tsilgutaja k??la"/><asula kood="8366" nimi="Tsirgupalu k??la"/><asula kood="8374" nimi="Tsolli k??la"/><asula kood="8379" nimi="Tsutsu k??la"/><asula kood="8410" nimi="Tummelka k??la"/><asula kood="8415" nimi="Tundu k??la"/><asula kood="8429" nimi="Tursa k??la"/><asula kood="8448" nimi="Tuuka k??la"/><asula kood="8503" nimi="T??nkova k??la"/><asula kood="8603" nimi="T????tsi k??la"/><asula kood="8623" nimi="Udsali k??la"/><asula kood="8738" nimi="Utessuu k??la"/><asula kood="8762" nimi="Uue-Saaluse k??la"/><asula kood="8802" nimi="Vaalim??e k??la"/><asula kood="8809" nimi="Vaarkali k??la"/><asula kood="8817" nimi="Vadsa k??la"/><asula kood="8906" nimi="Vakari k??la"/><asula kood="9002" nimi="Vana-Roosa k??la"/><asula kood="9030" nimi="Vanam??isa k??la"/><asula kood="9095" nimi="Varstu alevik"/><asula kood="9131" nimi="Vastse-Roosa k??la"/><asula kood="9129" nimi="Vastsekivi k??la"/><asula kood="9261" nimi="Vihkla k??la"/><asula kood="9307" nimi="Viitina k??la"/><asula kood="9329" nimi="Viliksaar?? k??la"/><asula kood="9345" nimi="Villa k??la"/><asula kood="9354" nimi="Villike k??la"/><asula kood="9391" nimi="Viru k??la"/><asula kood="9445" nimi="Vodi k??la"/><asula kood="9487" nimi="Vorstim??e k??la"/><asula kood="9488" nimi="Vungi k??la"/><asula kood="9640" nimi="V??iko-Tiilige k??la"/><asula kood="9643" nimi="V??iku-Ruuga k??la"/><asula kood="9665" nimi="V??nni k??la"/></vald><vald kood="0732" nimi="Setomaa vald"><asula kood="1170" nimi="Ala-Tsumba k??la"/><asula kood="1264" nimi="Antkruva k??la"/><asula kood="1453" nimi="Audjassaare k??la"/><asula kood="1489" nimi="Beresje k??la"/><asula kood="1626" nimi="Ermakova k??la"/><asula kood="1804" nimi="Helbi k??la"/><asula kood="1838" nimi="Hilana k??la"/><asula kood="1839" nimi="Hill??keste k??la"/><asula kood="1859" nimi="Hindsa k??la"/><asula kood="1876" nimi="Holdi k??la"/><asula kood="1953" nimi="H??rm?? k??la"/><asula kood="1998" nimi="Ignas?? k??la"/><asula kood="2003" nimi="Igrise k??la"/><asula kood="2143" nimi="Jaanim??e k??la"/><asula kood="2221" nimi="Juusa k??la"/><asula kood="2278" nimi="J??ksi k??la"/><asula kood="2362" nimi="J??rvep???? k??la"/><asula kood="2512" nimi="Kahkva k??la"/><asula kood="2565" nimi="Kalatsova k??la"/><asula kood="2665" nimi="Kangavitsa k??la"/><asula kood="2703" nimi="Karamsina k??la"/><asula kood="2736" nimi="Karisilla k??la"/><asula kood="2786" nimi="Kasakova k??la"/><asula kood="2821" nimi="Kastamara k??la"/><asula kood="2961" nimi="Keerba k??la"/><asula kood="3041" nimi="Kiiova k??la"/><asula kood="3053" nimi="Kiislova k??la"/><asula kood="3071" nimi="Kiksova k??la"/><asula kood="3164" nimi="Kits?? k??la"/><asula kood="3197" nimi="Klistina k??la"/><asula kood="3277" nimi="Koidula k??la"/><asula kood="3358" nimi="Kolodavitsa k??la"/><asula kood="3359" nimi="Kolossova k??la"/><asula kood="3451" nimi="Koorla k??la"/><asula kood="3444" nimi="Korela k??la"/><asula kood="3454" nimi="Korski k??la"/><asula kood="3468" nimi="Kossa k??la"/><asula kood="3470" nimi="Kostkova k??la"/><asula kood="3494" nimi="Kremessova k??la"/><asula kood="3502" nimi="Kriiva k??la"/><asula kood="3536" nimi="Kuig?? k??la"/><asula kood="3567" nimi="Kuksina k??la"/><asula kood="3609" nimi="Kundruse k??la"/><asula kood="3701" nimi="Kusnetsova k??la"/><asula kood="3845" nimi="K????ru k??la"/><asula kood="3988" nimi="K??ll??t??v?? k??la"/><asula kood="4114" nimi="Laossina k??la"/><asula kood="4228" nimi="Leimani k??la"/><asula kood="4297" nimi="Lep?? k??la"/><asula kood="4387" nimi="Lindsi k??la"/><asula kood="4425" nimi="Litvina k??la"/><asula kood="4434" nimi="Lobotka k??la"/><asula kood="4570" nimi="Lutep???? k??la"/><asula kood="4571" nimi="Lutja k??la"/><asula kood="4540" nimi="L??t?? k??la"/><asula kood="4692" nimi="L????bnitsa k??la"/><asula kood="4710" nimi="Maaslova k??la"/><asula kood="4785" nimi="Marinova k??la"/><asula kood="4798" nimi="Martsina k??la"/><asula kood="4804" nimi="Masluva k??la"/><asula kood="4827" nimi="Matsuri k??la"/><asula kood="4866" nimi="Melso k??la"/><asula kood="4872" nimi="Merek??l?? k??la"/><asula kood="4879" nimi="Merem??e k??la"/><asula kood="4843" nimi="Miikse k??la"/><asula kood="4951" nimi="Mikitam??e k??la"/><asula kood="4950" nimi="Miku k??la"/><asula kood="4970" nimi="Mokra k??la"/><asula kood="5297" nimi="M????si k??la"/><asula kood="5300" nimi="M????sovitsa k??la"/><asula kood="5354" nimi="Napi k??la"/><asula kood="5376" nimi="Navik?? k??la"/><asula kood="5387" nimi="Nedsaja k??la"/><asula kood="5422" nimi="Niitsiku k??la"/><asula kood="5582" nimi="Obinitsa k??la"/><asula kood="5658" nimi="Olehkova k??la"/><asula kood="5746" nimi="Ostrova k??la"/><asula kood="5900" nimi="Paklova k??la"/><asula kood="5914" nimi="Paland?? k??la"/><asula kood="5938" nimi="Palo k??la"/><asula kood="5945" nimi="Paloveere k??la"/><asula kood="6045" nimi="Pattina k??la"/><asula kood="6094" nimi="Pelsi k??la"/><asula kood="6115" nimi="Perdaku k??la"/><asula kood="6288" nimi="Pliia k??la"/><asula kood="6305" nimi="Podmotsa k??la"/><asula kood="6313" nimi="Poksa k??la"/><asula kood="6319" nimi="Polovina k??la"/><asula kood="6326" nimi="Popovitsa k??la"/><asula kood="6375" nimi="Pruntova k??la"/><asula kood="6412" nimi="Puista k??la"/><asula kood="6474" nimi="Puugnitsa k??la"/><asula kood="6543" nimi="P??rst?? k??la"/><asula kood="6823" nimi="Raotu k??la"/><asula kood="7045" nimi="Rokina k??la"/><asula kood="7152" nimi="Ruutsi k??la"/><asula kood="7170" nimi="R??sna k??la"/><asula kood="7243" nimi="R????ptsova k??la"/><asula kood="7250" nimi="R????solaane k??la"/><asula kood="7270" nimi="Saabolda k??la"/><asula kood="7274" nimi="Saagri k??la"/><asula kood="7315" nimi="Saatse k??la"/><asula kood="7404" nimi="Samarina k??la"/><asula kood="7523" nimi="Selise k??la"/><asula kood="7549" nimi="Serets??v?? k??la"/><asula kood="7547" nimi="Serga k??la"/><asula kood="7553" nimi="Sesniki k??la"/><asula kood="7628" nimi="Sirgova k??la"/><asula kood="7786" nimi="Sulbi k??la"/><asula kood="7928" nimi="S??pina k??la"/><asula kood="8082" nimi="Talka k??la"/><asula kood="8175" nimi="Tedre k??la"/><asula kood="8191" nimi="Tepia k??la"/><asula kood="8199" nimi="Tessova k??la"/><asula kood="8204" nimi="Teter??v?? k??la"/><asula kood="8177" nimi="Tiast?? k??la"/><asula kood="8224" nimi="Tiilige k??la"/><asula kood="8223" nimi="Tiirhanna k??la"/><asula kood="8231" nimi="Tiklas?? k??la"/><asula kood="8266" nimi="Tobrova k??la"/><asula kood="8286" nimi="Tonja k??la"/><asula kood="8314" nimi="Toodsi k??la"/><asula kood="8300" nimi="Toomasm??e k??la"/><asula kood="8337" nimi="Treiali k??la"/><asula kood="8343" nimi="Treski k??la"/><asula kood="8341" nimi="Trigin?? k??la"/><asula kood="8359" nimi="Tserebi k??la"/><asula kood="8355" nimi="Tsergond?? k??la"/><asula kood="8363" nimi="Tsirgu k??la"/><asula kood="8375" nimi="Tsumba k??la"/><asula kood="8416" nimi="Tuplova k??la"/><asula kood="8459" nimi="Tuulova k??la"/><asula kood="8584" nimi="T????glova k??la"/><asula kood="8648" nimi="Ulaskova k??la"/><asula kood="8657" nimi="Ulitina k??la"/><asula kood="8737" nimi="Usinitsa k??la"/><asula kood="8793" nimi="Uusvada k??la"/><asula kood="8797" nimi="Vaaksaar?? k??la"/><asula kood="8813" nimi="Vaartsi k??la"/><asula kood="9078" nimi="Varesm??e k??la"/><asula kood="9112" nimi="Vasla k??la"/><asula kood="9151" nimi="Vedernika k??la"/><asula kood="9194" nimi="Velna k??la"/><asula kood="9208" nimi="Veretin?? k??la"/><asula kood="9216" nimi="Verhulitsa k??la"/><asula kood="9373" nimi="Vinski k??la"/><asula kood="9384" nimi="Viro k??la"/><asula kood="9484" nimi="Voropi k??la"/><asula kood="9567" nimi="V??mmorski k??la"/><asula kood="9571" nimi="V??polsova k??la"/><asula kood="9607" nimi="V????psu k??la"/><asula kood="9635" nimi="V??ike-R??sna k??la"/><asula kood="9639" nimi="V??iko-H??rm?? k??la"/><asula kood="9637" nimi="V??iko-Serga k??la"/><asula kood="9672" nimi="V??rska alevik"/><asula kood="9707" nimi="??rsava k??la"/></vald><vald kood="0919" nimi="V??ru linn"/><vald kood="0917" nimi="V??ru vald"><asula kood="1163" nimi="Alak??l?? k??la"/><asula kood="1172" nimi="Alap??dra k??la"/><asula kood="1305" nimi="Andsum??e k??la"/><asula kood="1751" nimi="Haamaste k??la"/><asula kood="1697" nimi="Haava k??la"/><asula kood="1698" nimi="Haava-Ts??psi k??la"/><asula kood="1134" nimi="Haidaku k??la"/><asula kood="1744" nimi="Halla k??la"/><asula kood="1755" nimi="Hanikase k??la"/><asula kood="1759" nimi="Hannuste k??la"/><asula kood="1764" nimi="Hargi k??la"/><asula kood="1786" nimi="Heeska k??la"/><asula kood="1796" nimi="Heinasoo k??la"/><asula kood="1810" nimi="Hellekunnu k??la"/><asula kood="1856" nimi="Hinniala k??la"/><asula kood="1860" nimi="Hinsa k??la"/><asula kood="1886" nimi="Holsta k??la"/><asula kood="1894" nimi="Horma k??la"/><asula kood="1917" nimi="Husari k??la"/><asula kood="8744" nimi="Hutita k??la"/><asula kood="1942" nimi="H??nike k??la"/><asula kood="2040" nimi="Illi k??la"/><asula kood="2082" nimi="Indra k??la"/><asula kood="2172" nimi="Jantra k??la"/><asula kood="2184" nimi="Jeedask??la"/><asula kood="2203" nimi="Juba k??la"/><asula kood="2212" nimi="Juraski k??la"/><asula kood="2365" nimi="J??rvere k??la"/><asula kood="2389" nimi="Kaagu k??la"/><asula kood="2514" nimi="Kahkva k??la"/><asula kood="2515" nimi="Kahro k??la"/><asula kood="2551" nimi="Kaku k??la"/><asula kood="2559" nimi="Kakusuu k??la"/><asula kood="2646" nimi="Kamnitsa k??la"/><asula kood="2683" nimi="Kannu k??la"/><asula kood="2694" nimi="Kapera k??la"/><asula kood="2789" nimi="Kasaritsa k??la"/><asula kood="2911" nimi="Keema k??la"/><asula kood="2963" nimi="Kerep????lse k??la"/><asula kood="3130" nimi="Kirikum??e k??la"/><asula kood="3153" nimi="Kirump???? k??la"/><asula kood="3199" nimi="Kliima k??la"/><asula kood="3333" nimi="Kolepi k??la"/><asula kood="3360" nimi="Koloreino k??la"/><asula kood="3446" nimi="Korg??m??isa k??la"/><asula kood="3450" nimi="Kornitsa k??la"/><asula kood="3462" nimi="Kose alevik"/><asula kood="3649" nimi="Kurenurme k??la"/><asula kood="3704" nimi="Kusma k??la"/><asula kood="3750" nimi="K??ivsaare k??la"/><asula kood="3755" nimi="K??lik??la"/><asula kood="3776" nimi="K??o k??la"/><asula kood="3796" nimi="K??rgessaare k??la"/><asula kood="3818" nimi="K??rve k??la"/><asula kood="3838" nimi="K??vera k??la"/><asula kood="3883" nimi="K??pa k??la"/><asula kood="3903" nimi="K??rgula k??la"/><asula kood="3921" nimi="K??rnam??e k??la"/><asula kood="3944" nimi="K????pa k??la"/><asula kood="3956" nimi="K????tso k??la"/><asula kood="3965" nimi="K??hmam??e k??la"/><asula kood="3981" nimi="K??laoru k??la"/><asula kood="3991" nimi="K??ndja k??la"/><asula kood="4079" nimi="Lakovitsa k??la"/><asula kood="4118" nimi="Lapi k??la"/><asula kood="4130" nimi="Lasva k??la"/><asula kood="4136" nimi="Lauga k??la"/><asula kood="4203" nimi="Lehemetsa k??la"/><asula kood="4240" nimi="Leiso k??la"/><asula kood="4286" nimi="Lepassaare k??la"/><asula kood="4348" nimi="Liinam??e k??la"/><asula kood="4357" nimi="Liiva k??la"/><asula kood="4373" nimi="Lilli-Anne k??la"/><asula kood="4386" nimi="Lindora k??la"/><asula kood="4401" nimi="Linnam??e k??la"/><asula kood="4424" nimi="Listaku k??la"/><asula kood="4490" nimi="Lompka k??la"/><asula kood="4517" nimi="Loosi k??la"/><asula kood="4519" nimi="Loosu k??la"/><asula kood="4544" nimi="Luhte k??la"/><asula kood="4594" nimi="Luuska k??la"/><asula kood="4715" nimi="Madala k??la"/><asula kood="4716" nimi="Madi k??la"/><asula kood="4750" nimi="Majala k??la"/><asula kood="4784" nimi="Marga k??la"/><asula kood="4839" nimi="Meegom??e k??la"/><asula kood="4845" nimi="Meeliku k??la"/><asula kood="5071" nimi="Mustassaare k??la"/><asula kood="5077" nimi="Mustja k??la"/><asula kood="5100" nimi="Mutsu k??la"/><asula kood="5135" nimi="M??isam??e k??la"/><asula kood="5141" nimi="M??ksi k??la"/><asula kood="5167" nimi="M??rgi k??la"/><asula kood="5192" nimi="M??e-K??ok??la"/><asula kood="5188" nimi="M??ek??l?? k??la"/><asula kood="5210" nimi="M??essaare k??la"/><asula kood="5307" nimi="M??ldri k??la"/><asula kood="5378" nimi="Navi k??la"/><asula kood="5440" nimi="Noodask??la"/><asula kood="5450" nimi="Nooska k??la"/><asula kood="5531" nimi="N??nova k??la"/><asula kood="5660" nimi="Oleski k??la"/><asula kood="5708" nimi="Orava k??la"/><asula kood="5731" nimi="Oro k??la"/><asula kood="5734" nimi="Ortuma k??la"/><asula kood="5749" nimi="Osula k??la"/><asula kood="5766" nimi="Otsa k??la"/><asula kood="5862" nimi="Paidra k??la"/><asula kood="5941" nimi="Palometsa k??la"/><asula kood="5943" nimi="Paloveere k??la"/><asula kood="6002" nimi="Pari k??la"/><asula kood="6017" nimi="Parksepa alevik"/><asula kood="6107" nimi="Perak??la"/><asula kood="6112" nimi="Perametsa k??la"/><asula kood="6212" nimi="Pikakannu k??la"/><asula kood="6220" nimi="Pikasilla k??la"/><asula kood="6255" nimi="Pille k??la"/><asula kood="6269" nimi="Pindi k??la"/><asula kood="6283" nimi="Piusa k??la"/><asula kood="6293" nimi="Plessi k??la"/><asula kood="6345" nimi="Praakmani k??la"/><asula kood="6376" nimi="Pritsi k??la"/><asula kood="6411" nimi="Puiga k??la"/><asula kood="6430" nimi="Pulli k??la"/><asula kood="6431" nimi="Punak??l?? k??la"/><asula kood="6482" nimi="Puusepa k??la"/><asula kood="6484" nimi="Puutli k??la"/><asula kood="6585" nimi="P??ka k??la"/><asula kood="6625" nimi="P??ss?? k??la"/><asula kood="6633" nimi="P????v??kese k??la"/><asula kood="6673" nimi="Raadi k??la"/><asula kood="6761" nimi="Raiste k??la"/><asula kood="6856" nimi="Raudsepa k??la"/><asula kood="6864" nimi="Rauskapalu k??la"/><asula kood="6896" nimi="Rebasm??e k??la"/><asula kood="6985" nimi="Riihora k??la"/><asula kood="7078" nimi="Roosisaare k??la"/><asula kood="7119" nimi="Rummi k??la"/><asula kood="7128" nimi="Rusima k??la"/><asula kood="7173" nimi="R??ssa k??la"/><asula kood="7217" nimi="R??po k??la"/><asula kood="7281" nimi="Saarde k??la"/><asula kood="7292" nimi="Saaremaa k??la"/><asula kood="7503" nimi="Savioja k??la"/><asula kood="7576" nimi="Sika k??la"/><asula kood="7652" nimi="Soe k??la"/><asula kood="7657" nimi="Soena k??la"/><asula kood="7707" nimi="Sook??la"/><asula kood="7787" nimi="Sulbi k??la"/><asula kood="7820" nimi="Sutte k??la"/><asula kood="7843" nimi="Suuremetsa k??la"/><asula kood="7887" nimi="S??merpalu alevik"/><asula kood="7888" nimi="S??merpalu k??la"/><asula kood="8014" nimi="Tabina k??la"/><asula kood="8040" nimi="Tagak??la"/><asula kood="8081" nimi="Tallikeste k??la"/><asula kood="7326" nimi="Tamme k??la"/><asula kood="8124" nimi="Tammsaare k??la"/><asula kood="8192" nimi="Tellaste k??la"/><asula kood="8252" nimi="Tiri k??la"/><asula kood="8267" nimi="Tohkri k??la"/><asula kood="8315" nimi="Tootsi k??la"/><asula kood="8372" nimi="Tsolgo k??la"/><asula kood="8376" nimi="Tsolli k??la"/><asula kood="8385" nimi="Tuderna k??la"/><asula kood="8601" nimi="T????tsm??e k??la"/><asula kood="8620" nimi="Udsali k??la"/><asula kood="8669" nimi="Umbsaare k??la"/><asula kood="8811" nimi="Vaarkali k??la"/><asula kood="8833" nimi="Vagula k??la"/><asula kood="8994" nimi="Vana-Nursi k??la"/><asula kood="9004" nimi="Vana-Saaluse k??la"/><asula kood="8855" nimi="Vana-Vastseliina k??la"/><asula kood="9074" nimi="Varese k??la"/><asula kood="9133" nimi="Vastseliina alevik"/><asula kood="9144" nimi="Vatsa k??la"/><asula kood="9218" nimi="Verij??rve k??la"/><asula kood="9310" nimi="Viitka k??la"/><asula kood="9346" nimi="Villa k??la"/><asula kood="9440" nimi="Vivva k??la"/><asula kood="9458" nimi="Voki k??la"/><asula kood="8109" nimi="Voki-Tamme k??la"/><asula kood="9564" nimi="V??lsi k??la"/><asula kood="9585" nimi="V??rum??isa k??la"/><asula kood="9588" nimi="V??rusoo k??la"/><asula kood="9636" nimi="V??imela alevik"/><asula kood="9641" nimi="V??iso k??la"/></vald></maakond></ehak>	ehak	2021-01-27 10:25:45.773688	2021-01-27 10:25:45.773688	admin	\N	\N	\N	\N	\N	\N	\N	\N
16	<ehak><maakond kood="0037" nimi="Harju maakond"/><maakond kood="0039" nimi="Hiiu maakond"/><maakond kood="0044" nimi="Ida-Viru maakond"/><maakond kood="0049" nimi="J??geva maakond"/><maakond kood="0051" nimi="J??rva maakond"/><maakond kood="0057" nimi="L????ne maakond"/><maakond kood="0059" nimi="L????ne-Viru maakond"/><maakond kood="0065" nimi="P??lva maakond"/><maakond kood="0067" nimi="P??rnu maakond"/><maakond kood="0070" nimi="Rapla maakond"/><maakond kood="0074" nimi="Saare maakond"/><maakond kood="0078" nimi="Tartu maakond"/><maakond kood="0082" nimi="Valga maakond"/><maakond kood="0084" nimi="Viljandi maakond"/><maakond kood="0086" nimi="V??ru maakond"/></ehak>	maakonnad	2021-01-27 10:25:45.780031	2021-01-27 10:25:45.780031	admin	\N	\N	\N	\N	\N	\N	\N	\N
17	<ehak><maakond kood="0037"><vald kood="0296" nimi="Keila linn"/><vald kood="0424" nimi="Loksa linn"/><vald kood="0446" nimi="Maardu linn"/><vald kood="0580" nimi="Paldiski linn"/><vald kood="0728" nimi="Saue linn"/><vald kood="0784" nimi="Tallinn"/><vald kood="0112" nimi="Aegviidu vald"/><vald kood="0140" nimi="Anija vald"/><vald kood="0198" nimi="Harku vald"/><vald kood="0245" nimi="J??el??htme vald"/><vald kood="0295" nimi="Keila vald"/><vald kood="0297" nimi="Kernu vald"/><vald kood="0304" nimi="Kiili vald"/><vald kood="0338" nimi="Kose vald"/><vald kood="0353" nimi="Kuusalu vald"/><vald kood="0518" nimi="Nissi vald"/><vald kood="0562" nimi="Padise vald"/><vald kood="0651" nimi="Raasiku vald"/><vald kood="0653" nimi="Rae vald"/><vald kood="0718" nimi="Saku vald"/><vald kood="0727" nimi="Saue vald"/><vald kood="0868" nimi="Vasalemma vald"/><vald kood="0890" nimi="Viimsi vald"/></maakond><maakond kood="0039"><vald kood="0175" nimi="Emmaste vald"/><vald kood="0204" nimi="Hiiu vald"/><vald kood="0368" nimi="K??ina vald"/><vald kood="0639" nimi="P??halepa vald"/></maakond><maakond kood="0044"><vald kood="0309" nimi="Kivi??li linn"/><vald kood="0322" nimi="Kohtla-J??rve linn"/><vald kood="0513" nimi="Narva-J??esuu linn"/><vald kood="0511" nimi="Narva linn"/><vald kood="0735" nimi="Sillam??e linn"/><vald kood="0122" nimi="Alaj??e vald"/><vald kood="0154" nimi="Aseri vald"/><vald kood="0164" nimi="Avinurme vald"/><vald kood="0224" nimi="Iisaku vald"/><vald kood="0229" nimi="Illuka vald"/><vald kood="0251" nimi="J??hvi vald"/><vald kood="0323" nimi="Kohtla-N??mme vald"/><vald kood="0320" nimi="Kohtla vald"/><vald kood="0420" nimi="Lohusuu vald"/><vald kood="0438" nimi="L??ganuse vald"/><vald kood="0498" nimi="M??etaguse vald"/><vald kood="0751" nimi="Sonda vald"/><vald kood="0802" nimi="Toila vald"/><vald kood="0815" nimi="Tudulinna vald"/><vald kood="0851" nimi="Vaivara vald"/></maakond><maakond kood="0049"><vald kood="0249" nimi="J??geva linn"/><vald kood="0485" nimi="Mustvee linn"/><vald kood="0617" nimi="P??ltsamaa linn"/><vald kood="0248" nimi="J??geva vald"/><vald kood="0657" nimi="Kasep???? vald"/><vald kood="0573" nimi="Pajusi vald"/><vald kood="0578" nimi="Palamuse vald"/><vald kood="0576" nimi="Pala vald"/><vald kood="0611" nimi="Puurmani vald"/><vald kood="0616" nimi="P??ltsamaa vald"/><vald kood="0713" nimi="Saare vald"/><vald kood="0773" nimi="Tabivere vald"/><vald kood="0810" nimi="Torma vald"/></maakond><maakond kood="0051"><vald kood="0566" nimi="Paide linn"/><vald kood="0129" nimi="Albu vald"/><vald kood="0134" nimi="Ambla vald"/><vald kood="0234" nimi="Imavere vald"/><vald kood="0257" nimi="J??rva-Jaani vald"/><vald kood="0288" nimi="Kareda vald"/><vald kood="0314" nimi="Koeru vald"/><vald kood="0325" nimi="Koigi vald"/><vald kood="0565" nimi="Paide vald"/><vald kood="0684" nimi="Roosna-Alliku vald"/><vald kood="0835" nimi="T??ri vald"/><vald kood="0937" nimi="V????tsa vald"/></maakond><maakond kood="0057"><vald kood="0183" nimi="Haapsalu linn"/><vald kood="0195" nimi="Hanila vald"/><vald kood="0342" nimi="Kullamaa vald"/><vald kood="0411" nimi="Lihula vald"/><vald kood="0436" nimi="L????ne-Nigula vald"/><vald kood="0452" nimi="Martna vald"/><vald kood="0520" nimi="Noarootsi vald"/><vald kood="0531" nimi="N??va vald"/><vald kood="0674" nimi="Ridala vald"/><vald kood="0907" nimi="Vormsi vald"/></maakond><maakond kood="0059"><vald kood="0345" nimi="Kunda linn"/><vald kood="0663" nimi="Rakvere linn"/><vald kood="0190" nimi="Haljala vald"/><vald kood="0272" nimi="Kadrina vald"/><vald kood="0381" nimi="Laekvere vald"/><vald kood="0660" nimi="Rakke vald"/><vald kood="0662" nimi="Rakvere vald"/><vald kood="0702" nimi="R??gavere vald"/><vald kood="0770" nimi="S??meru vald"/><vald kood="0786" nimi="Tamsalu vald"/><vald kood="0790" nimi="Tapa vald"/><vald kood="0887" nimi="Vihula vald"/><vald kood="0900" nimi="Vinni vald"/><vald kood="0902" nimi="Viru-Nigula vald"/><vald kood="0926" nimi="V??ike-Maarja vald"/></maakond><maakond kood="0065"><vald kood="0117" nimi="Ahja vald"/><vald kood="0285" nimi="Kanepi vald"/><vald kood="0354" nimi="K??lleste vald"/><vald kood="0385" nimi="Laheda vald"/><vald kood="0465" nimi="Mikitam??e vald"/><vald kood="0473" nimi="Mooste vald"/><vald kood="0547" nimi="Orava vald"/><vald kood="0621" nimi="P??lva vald"/><vald kood="0707" nimi="R??pina vald"/><vald kood="0856" nimi="Valgj??rve vald"/><vald kood="0872" nimi="Vastse-Kuuste vald"/><vald kood="0879" nimi="Veriora vald"/><vald kood="0934" nimi="V??rska vald"/></maakond><maakond kood="0067"><vald kood="0625" nimi="P??rnu linn"/><vald kood="0741" nimi="Sindi linn"/><vald kood="0149" nimi="Are vald"/><vald kood="0160" nimi="Audru vald"/><vald kood="0188" nimi="Halinga vald"/><vald kood="0213" nimi="H????demeeste vald"/><vald kood="0303" nimi="Kihnu vald"/><vald kood="0334" nimi="Koonga vald"/><vald kood="0568" nimi="Paikuse vald"/><vald kood="0710" nimi="Saarde vald"/><vald kood="0730" nimi="Sauga vald"/><vald kood="0756" nimi="Surju vald"/><vald kood="0848" nimi="Tahkuranna vald"/><vald kood="0805" nimi="Tootsi vald"/><vald kood="0808" nimi="Tori vald"/><vald kood="0826" nimi="T??stamaa vald"/><vald kood="0863" nimi="Varbla vald"/><vald kood="0929" nimi="V??ndra vald"/><vald kood="0931" nimi="V??ndra vald (alev)"/></maakond><maakond kood="0070"><vald kood="0240" nimi="Juuru vald"/><vald kood="0260" nimi="J??rvakandi vald"/><vald kood="0277" nimi="Kaiu vald"/><vald kood="0292" nimi="Kehtna vald"/><vald kood="0317" nimi="Kohila vald"/><vald kood="0375" nimi="K??ru vald"/><vald kood="0504" nimi="M??rjamaa vald"/><vald kood="0654" nimi="Raikk??la vald"/><vald kood="0669" nimi="Rapla vald"/><vald kood="0884" nimi="Vigala vald"/></maakond><maakond kood="0074"><vald kood="0349" nimi="Kuressaare linn"/><vald kood="0301" nimi="Kihelkonna vald"/><vald kood="0386" nimi="Laimjala vald"/><vald kood="0403" nimi="Leisi vald"/><vald kood="0433" nimi="L????ne-Saare vald"/><vald kood="0478" nimi="Muhu vald"/><vald kood="0483" nimi="Mustjala vald"/><vald kood="0550" nimi="Orissaare vald"/><vald kood="0592" nimi="Pihtla vald"/><vald kood="0634" nimi="P??ide vald"/><vald kood="0689" nimi="Ruhnu vald"/><vald kood="0721" nimi="Salme vald"/><vald kood="0807" nimi="Torgu vald"/><vald kood="0858" nimi="Valjala vald"/></maakond><maakond kood="0078"><vald kood="0170" nimi="Elva linn"/><vald kood="0279" nimi="Kallaste linn"/><vald kood="0795" nimi="Tartu linn"/><vald kood="0126" nimi="Alatskivi vald"/><vald kood="0185" nimi="Haaslava vald"/><vald kood="0282" nimi="Kambja vald"/><vald kood="0331" nimi="Konguta vald"/><vald kood="0383" nimi="Laeva vald"/><vald kood="0432" nimi="Luunja vald"/><vald kood="0454" nimi="Meeksi vald"/><vald kood="0501" nimi="M??ksa vald"/><vald kood="0528" nimi="N??o vald"/><vald kood="0587" nimi="Peipsi????re vald"/><vald kood="0595" nimi="Piirissaare vald"/><vald kood="0605" nimi="Puhja vald"/><vald kood="0666" nimi="Rannu vald"/><vald kood="0694" nimi="R??ngu vald"/><vald kood="0794" nimi="Tartu vald"/><vald kood="0831" nimi="T??htvere vald"/><vald kood="0861" nimi="Vara vald"/><vald kood="0915" nimi="V??nnu vald"/><vald kood="0949" nimi="??lenurme vald"/></maakond><maakond kood="0082"><vald kood="0823" nimi="T??rva linn"/><vald kood="0854" nimi="Valga linn"/><vald kood="0203" nimi="Helme vald"/><vald kood="0208" nimi="Hummuli vald"/><vald kood="0289" nimi="Karula vald"/><vald kood="0636" nimi="Otep???? vald"/><vald kood="0582" nimi="Palupera vald"/><vald kood="0608" nimi="Puka vald"/><vald kood="0613" nimi="P??drala vald"/><vald kood="0724" nimi="Sangaste vald"/><vald kood="0779" nimi="Taheva vald"/><vald kood="0820" nimi="T??lliste vald"/><vald kood="0943" nimi="??ru vald"/></maakond><maakond kood="0084"><vald kood="0490" nimi="M??isak??la linn"/><vald kood="0897" nimi="Viljandi linn"/><vald kood="0912" nimi="V??hma linn"/><vald kood="0105" nimi="Abja vald"/><vald kood="0192" nimi="Halliste vald"/><vald kood="0600" nimi="Karksi vald"/><vald kood="0328" nimi="Kolga-Jaani vald"/><vald kood="0357" nimi="K??o vald"/><vald kood="0360" nimi="K??pu vald"/><vald kood="0758" nimi="Suure-Jaani vald"/><vald kood="0797" nimi="Tarvastu vald"/><vald kood="0898" nimi="Viljandi vald"/></maakond><maakond kood="0086"><vald kood="0919" nimi="V??ru linn"/><vald kood="0143" nimi="Antsla vald"/><vald kood="0181" nimi="Haanja vald"/><vald kood="0389" nimi="Lasva vald"/><vald kood="0460" nimi="Merem??e vald"/><vald kood="0468" nimi="Misso vald"/><vald kood="0493" nimi="M??niste vald"/><vald kood="0697" nimi="R??uge vald"/><vald kood="0767" nimi="S??merpalu vald"/><vald kood="0843" nimi="Urvaste vald"/><vald kood="0865" nimi="Varstu vald"/><vald kood="0874" nimi="Vastseliina vald"/><vald kood="0918" nimi="V??ru vald"/></maakond></ehak>	vallad	2021-01-27 10:25:45.780843	2021-01-27 10:25:45.780843	admin	\N	\N	\N	\N	\N	\N	\N	\N
18	<ehak><maakond kood="0037"><vald kood="0784"><asula kood="0176" nimi="Haabersti linnaosa"/><asula kood="0298" nimi="Kesklinna linnaosa"/><asula kood="0339" nimi="Kristiine linnaosa"/><asula kood="0387" nimi="Lasnam??e linnaosa"/><asula kood="0482" nimi="Mustam??e linnaosa"/><asula kood="0524" nimi="N??mme linnaosa"/><asula kood="0596" nimi="Pirita linnaosa"/><asula kood="0614" nimi="P??hja-Tallinna linnaosa"/></vald><vald kood="0112"><asula kood="1088" nimi="Aegviidu alev"/></vald><vald kood="0140"><asula kood="1046" nimi="Aavere k??la"/><asula kood="1184" nimi="Alavere k??la"/><asula kood="1278" nimi="Anija k??la"/><asula kood="1321" nimi="Arava k??la"/><asula kood="1961" nimi="H??rmakosu k??la"/><asula kood="2877" nimi="Kaunissaare k??la"/><asula kood="2925" nimi="Kehra k??la"/><asula kood="2928" nimi="Kehra linn"/><asula kood="3022" nimi="Kihmla k??la"/><asula kood="3716" nimi="Kuusem??e k??la"/><asula kood="4213" nimi="Lehtmetsa k??la"/><asula kood="4369" nimi="Lilli k??la"/><asula kood="4397" nimi="Linnakse k??la"/><asula kood="4506" nimi="Look??la"/><asula kood="4672" nimi="L??kati k??la"/><asula kood="5082" nimi="Mustj??e k??la"/><asula kood="5789" nimi="Paasiku k??la"/><asula kood="6009" nimi="Parila k??la"/><asula kood="6022" nimi="Partsaare k??la"/><asula kood="6241" nimi="Pikva k??la"/><asula kood="6254" nimi="Pillapalu k??la"/><asula kood="6828" nimi="Rasivere k??la"/><asula kood="6855" nimi="Raudoja k??la"/><asula kood="7068" nimi="Rook??la"/><asula kood="7396" nimi="Salumetsa k??la"/><asula kood="7398" nimi="Salum??e k??la"/><asula kood="7693" nimi="Soodla k??la"/><asula kood="8764" nimi="Uuearu k??la"/><asula kood="9248" nimi="Vetla k??la"/><asula kood="9318" nimi="Vikipalu k??la"/><asula kood="9480" nimi="Voose k??la"/><asula kood="9827" nimi="??lej??e k??la"/></vald><vald kood="0198"><asula kood="1084" nimi="Adra k??la"/><asula kood="1774" nimi="Harku alevik"/><asula kood="1776" nimi="Harkuj??rve k??la"/><asula kood="1903" nimi="Humala k??la"/><asula kood="2048" nimi="Ilmandu k??la"/><asula kood="3608" nimi="Kumna k??la"/><asula kood="3997" nimi="K??tke k??la"/><asula kood="4002" nimi="Laabi k??la"/><asula kood="4344" nimi="Liikva k??la"/><asula kood="5039" nimi="Muraste k??la"/><asula kood="5327" nimi="Naage k??la"/><asula kood="6814" nimi="Rannam??isa k??la"/><asula kood="7871" nimi="Suurupi k??la"/><asula kood="7905" nimi="S??rve k??la"/><asula kood="8009" nimi="Tabasalu alevik"/><asula kood="8257" nimi="Tiskre k??la"/><asula kood="8442" nimi="Tutermaa k??la"/><asula kood="8599" nimi="T??risalu k??la"/><asula kood="8848" nimi="Vahi k??la"/><asula kood="8877" nimi="Vaila k??la"/><asula kood="9434" nimi="Viti k??la"/><asula kood="9685" nimi="V????na-J??esuu k??la"/><asula kood="9683" nimi="V????na k??la"/></vald><vald kood="0245"><asula kood="1367" nimi="Aruaru k??la"/><asula kood="1691" nimi="Haapse k??la"/><asula kood="1741" nimi="Haljava k??la"/><asula kood="2009" nimi="Ihasalu k??la"/><asula kood="2100" nimi="Iru k??la"/><asula kood="2234" nimi="J??el??htme k??la"/><asula kood="2248" nimi="J??esuu k??la"/><asula kood="2301" nimi="J??gala-Joa k??la"/><asula kood="2299" nimi="J??gala k??la"/><asula kood="2452" nimi="Kaberneeme k??la"/><asula kood="2601" nimi="Kallavere k??la"/><asula kood="3296" nimi="Koila k??la"/><asula kood="3301" nimi="Koipsi k??la"/><asula kood="3385" nimi="Koogi k??la"/><asula kood="3471" nimi="Kostiranna k??la"/><asula kood="3472" nimi="Kostivere alevik"/><asula kood="3588" nimi="Kullam??e k??la"/><asula kood="4359" nimi="Liivam??e k??la"/><asula kood="4496" nimi="Loo alevik"/><asula kood="4494" nimi="Loo k??la"/><asula kood="4704" nimi="Maardu k??la"/><asula kood="4776" nimi="Manniva k??la"/><asula kood="5389" nimi="Neeme k??la"/><asula kood="5400" nimi="Nehatu k??la"/><asula kood="5997" nimi="Parasm??e k??la"/><asula kood="6785" nimi="Rammu k??la"/><asula kood="6882" nimi="Rebala k??la"/><asula kood="7037" nimi="Rohusi k??la"/><asula kood="7141" nimi="Ruu k??la"/><asula kood="7335" nimi="Saha k??la"/><asula kood="7405" nimi="Sambu k??la"/><asula kood="7498" nimi="Saviranna k??la"/><asula kood="8783" nimi="Uusk??la"/><asula kood="9041" nimi="Vandjala k??la"/><asula kood="9491" nimi="V??erdla k??la"/><asula kood="9838" nimi="??lgase k??la"/></vald><vald kood="0295"><asula kood="2045" nimi="Illurma k??la"/><asula kood="2749" nimi="Karjak??la alevik"/><asula kood="2909" nimi="Keelva k??la"/><asula kood="2930" nimi="Keila-Joa alevik"/><asula kood="2978" nimi="Kersalu k??la"/><asula kood="3205" nimi="Klooga alevik"/><asula kood="3207" nimi="Kloogaranna k??la"/><asula kood="3603" nimi="Kulna k??la"/><asula kood="3857" nimi="K??esalu k??la"/><asula kood="4112" nimi="Laok??la"/><asula kood="4148" nimi="Laulasmaa k??la"/><asula kood="4211" nimi="Lehola k??la"/><asula kood="4456" nimi="Lohusalu k??la"/><asula kood="4725" nimi="Maeru k??la"/><asula kood="4876" nimi="Merem??isa k??la"/><asula kood="5343" nimi="Nahkjala k??la"/><asula kood="5424" nimi="Niitv??lja k??la"/><asula kood="5628" nimi="Ohtu k??la"/><asula kood="6528" nimi="P??llk??la"/><asula kood="8460" nimi="Tuulna k??la"/><asula kood="8499" nimi="T??mmiku k??la"/><asula kood="8956" nimi="Valkse k??la"/></vald><vald kood="0297"><asula kood="1206" nimi="Allika k??la"/><asula kood="1720" nimi="Haiba k??la"/><asula kood="1854" nimi="Hingu k??la"/><asula kood="2427" nimi="Kaasiku k??la"/><asula kood="2455" nimi="Kabila k??la"/><asula kood="2976" nimi="Kernu k??la"/><asula kood="3001" nimi="Kibuna k??la"/><asula kood="3120" nimi="Kirikla k??la"/><asula kood="3266" nimi="Kohatu k??la"/><asula kood="3705" nimi="Kustja k??la"/><asula kood="4075" nimi="Laitse k??la"/><asula kood="4903" nimi="Metsanurga k??la"/><asula kood="5110" nimi="Muusika k??la"/><asula kood="5157" nimi="M??nuste k??la"/><asula kood="6308" nimi="Pohla k??la"/><asula kood="7110" nimi="Ruila k??la"/><asula kood="9049" nimi="Vansi k??la"/></vald><vald kood="0304"><asula kood="1388" nimi="Arusta k??la"/><asula kood="2671" nimi="Kangru alevik"/><asula kood="3039" nimi="Kiili alev"/><asula kood="3656" nimi="Kurevere k??la"/><asula kood="4550" nimi="Luige alevik"/><asula kood="4633" nimi="L??htse k??la"/><asula kood="4902" nimi="Metsanurga k??la"/><asula kood="5125" nimi="M??isak??la"/><asula kood="5329" nimi="Nabala k??la"/><asula kood="5824" nimi="Paekna k??la"/><asula kood="6198" nimi="Piissoo k??la"/><asula kood="7472" nimi="Sausti k??la"/><asula kood="7701" nimi="Sookaera k??la"/><asula kood="7880" nimi="S??gula k??la"/><asula kood="7894" nimi="S??meru k??la"/><asula kood="8824" nimi="Vaela k??la"/></vald><vald kood="0338"><asula kood="1089" nimi="Aela k??la"/><asula kood="1113" nimi="Ahisilla k??la"/><asula kood="1174" nimi="Alansi k??la"/><asula kood="1340" nimi="Ardu alevik"/><asula kood="1708" nimi="Habaja alevik"/><asula kood="1779" nimi="Harmi k??la"/><asula kood="2485" nimi="Kadja k??la"/><asula kood="2657" nimi="Kanavere k??la"/><asula kood="2690" nimi="Kantk??la"/><asula kood="2764" nimi="Karla k??la"/><asula kood="2848" nimi="Kata k??la"/><asula kood="2852" nimi="Katsina k??la"/><asula kood="3140" nimi="Kirivalla k??la"/><asula kood="3156" nimi="Kiruvere k??la"/><asula kood="3363" nimi="Kolu k??la"/><asula kood="3460" nimi="Kose alevik"/><asula kood="3464" nimi="Kose-Uuem??isa alevik"/><asula kood="3492" nimi="Krei k??la"/><asula kood="3546" nimi="Kuivaj??e k??la"/><asula kood="3553" nimi="Kukepala k??la"/><asula kood="3829" nimi="K??rvenurga k??la"/><asula kood="3834" nimi="K??ue k??la"/><asula kood="4020" nimi="Laane k??la"/><asula kood="4242" nimi="Leistu k??la"/><asula kood="4352" nimi="Liiva k??la"/><asula kood="4577" nimi="Lutsu k??la"/><asula kood="4667" nimi="L????ra k??la"/><asula kood="4788" nimi="Marguse k??la"/><asula kood="5485" nimi="Nutu k??la"/><asula kood="5506" nimi="N??mbra k??la"/><asula kood="5518" nimi="N??mmeri k??la"/><asula kood="5537" nimi="N??rava k??la"/><asula kood="5656" nimi="Ojasoo k??la"/><asula kood="5738" nimi="Oru k??la"/><asula kood="5907" nimi="Pala k??la"/><asula kood="5962" nimi="Palvere k??la"/><asula kood="6052" nimi="Paunaste k??la"/><asula kood="6053" nimi="Paunk??la"/><asula kood="6483" nimi="Puusepa k??la"/><asula kood="6869" nimi="Rava k??la"/><asula kood="6872" nimi="Raveliku k??la"/><asula kood="6875" nimi="Ravila alevik"/><asula kood="6981" nimi="Riidam??e k??la"/><asula kood="7191" nimi="R????sa k??la"/><asula kood="7308" nimi="Saarnak??rve k??la"/><asula kood="7324" nimi="Sae k??la"/><asula kood="7457" nimi="Saula k??la"/><asula kood="7597" nimi="Silmsi k??la"/><asula kood="7891" nimi="S??meru k??la"/><asula kood="7963" nimi="S????sk??la"/><asula kood="8022" nimi="Tade k??la"/><asula kood="8112" nimi="Tammiku k??la"/><asula kood="8346" nimi="Triigi k??la"/><asula kood="8396" nimi="Tuhala k??la"/><asula kood="8773" nimi="Uueveski k??la"/><asula kood="8847" nimi="Vahet??ki k??la"/><asula kood="9032" nimi="Vanam??isa k??la"/><asula kood="9071" nimi="Vardja k??la"/><asula kood="9323" nimi="Vilama k??la"/><asula kood="9385" nimi="Virla k??la"/><asula kood="9417" nimi="Viskla k??la"/><asula kood="9558" nimi="V??lle k??la"/><asula kood="9749" nimi="??ksi k??la"/></vald><vald kood="0353"><asula kood="1202" nimi="Allika k??la"/><asula kood="1256" nimi="Andineeme k??la"/><asula kood="1363" nimi="Aru k??la"/><asula kood="1701" nimi="Haavakannu k??la"/><asula kood="1761" nimi="Hara k??la"/><asula kood="1877" nimi="Hirvli k??la"/><asula kood="2046" nimi="Ilmastalu k??la"/><asula kood="2194" nimi="Joaveski k??la"/><asula kood="2209" nimi="Juminda k??la"/><asula kood="2450" nimi="Kaberla k??la"/><asula kood="2509" nimi="Kahala k??la"/><asula kood="2629" nimi="Kalme k??la"/><asula kood="2804" nimi="Kasispea k??la"/><asula kood="2949" nimi="Kemba k??la"/><asula kood="3055" nimi="Kiiu-Aabla k??la"/><asula kood="3056" nimi="Kiiu alevik"/><asula kood="3232" nimi="Kodasoo k??la"/><asula kood="3300" nimi="Koitj??rve k??la"/><asula kood="1007" nimi="Kolga-Aabla k??la"/><asula kood="3336" nimi="Kolga alevik"/><asula kood="3343" nimi="Kolgak??la"/><asula kood="3342" nimi="Kolgu k??la"/><asula kood="3474" nimi="Kosu k??la"/><asula kood="3480" nimi="Kotka k??la"/><asula kood="3630" nimi="Kupu k??la"/><asula kood="3691" nimi="Kursi k??la"/><asula kood="3714" nimi="Kuusalu alevik"/><asula kood="3718" nimi="Kuusalu k??la"/><asula kood="3768" nimi="K??nnu k??la"/><asula kood="3993" nimi="K??lmaallika k??la"/><asula kood="4188" nimi="Leesi k??la"/><asula kood="4334" nimi="Liiapeksi k??la"/><asula kood="4471" nimi="Loksa k??la"/><asula kood="5048" nimi="Murksi k??la"/><asula kood="5064" nimi="Mustametsa k??la"/><asula kood="5108" nimi="Muuksi k??la"/><asula kood="5208" nimi="M??epea k??la"/><asula kood="5533" nimi="N??mmeveski k??la"/><asula kood="5901" nimi="Pala k??la"/><asula kood="6016" nimi="Parksi k??la"/><asula kood="6065" nimi="Pedaspea k??la"/><asula kood="6378" nimi="Pudisoo k??la"/><asula kood="6497" nimi="P??hja k??la"/><asula kood="6606" nimi="P??rispea k??la"/><asula kood="6898" nimi="Rehatse k??la"/><asula kood="7122" nimi="Rummu k??la"/><asula kood="7390" nimi="Salmistu k??la"/><asula kood="7466" nimi="Saunja k??la"/><asula kood="7562" nimi="Sigula k??la"/><asula kood="7734" nimi="Soorinna k??la"/><asula kood="7809" nimi="Suru k??la"/><asula kood="7866" nimi="Suurpea k??la"/><asula kood="7882" nimi="S??itme k??la"/><asula kood="8118" nimi="Tammispea k??la"/><asula kood="8125" nimi="Tammistu k??la"/><asula kood="8144" nimi="Tapurla k??la"/><asula kood="8367" nimi="Tsitre k??la"/><asula kood="8424" nimi="Turbuneeme k??la"/><asula kood="8193" nimi="T??reska k??la"/><asula kood="8782" nimi="Uuri k??la"/><asula kood="8839" nimi="Vahastu k??la"/><asula kood="8919" nimi="Valgej??e k??la"/><asula kood="8954" nimi="Valkla k??la"/><asula kood="9014" nimi="Vanak??la"/><asula kood="9257" nimi="Vihasoo k??la"/><asula kood="9283" nimi="Viinistu k??la"/><asula kood="9411" nimi="Virve k??la"/></vald><vald kood="0518"><asula kood="1449" nimi="Aude k??la"/><asula kood="1585" nimi="Ellamaa k??la"/><asula kood="2135" nimi="Jaanika k??la"/><asula kood="3195" nimi="Kivitammi k??la"/><asula kood="4206" nimi="Lehetu k??la"/><asula kood="4289" nimi="Lepaste k??la"/><asula kood="4717" nimi="Madila k??la"/><asula kood="5028" nimi="Munalaskme k??la"/><asula kood="5093" nimi="Mustu k??la"/><asula kood="5467" nimi="Nurme k??la"/><asula kood="5601" nimi="Odulemma k??la"/><asula kood="6905" nimi="Rehem??e k??la"/><asula kood="6989" nimi="Riisipere alevik"/><asula kood="7571" nimi="Siimika k??la"/><asula kood="8006" nimi="Tabara k??la"/><asula kood="8421" nimi="Turba alevik"/><asula kood="9362" nimi="Vilum??e k??la"/><asula kood="9401" nimi="Viruk??la"/><asula kood="9846" nimi="??rjaste k??la"/></vald><vald kood="0562"><asula kood="1208" nimi="Alliklepa k??la"/><asula kood="1221" nimi="Altk??la"/><asula kood="1450" nimi="Audev??lja k??la"/><asula kood="1771" nimi="Harju-Risti k??la"/><asula kood="1782" nimi="Hatu k??la"/><asula kood="2731" nimi="Karilepa k??la"/><asula kood="2797" nimi="Kasepere k??la"/><asula kood="2927" nimi="Keibu k??la"/><asula kood="3224" nimi="Kobru k??la"/><asula kood="3682" nimi="Kurkse k??la"/><asula kood="3762" nimi="K??mmaste k??la"/><asula kood="4019" nimi="Laane k??la"/><asula kood="4096" nimi="Langa k??la"/><asula kood="4722" nimi="Madise k??la"/><asula kood="4931" nimi="Metsl??ugu k??la"/><asula kood="5290" nimi="M????ra k??la"/><asula kood="5812" nimi="Padise k??la"/><asula kood="5821" nimi="Pae k??la"/><asula kood="6062" nimi="Pedase k??la"/><asula kood="7856" nimi="Suurk??la"/><asula kood="9265" nimi="Vihterpalu k??la"/><asula kood="9339" nimi="Vilivalla k??la"/><asula kood="9380" nimi="Vintse k??la"/><asula kood="9767" nimi="??nglema k??la"/></vald><vald kood="0651"><asula kood="1373" nimi="Aruk??la alevik"/><asula kood="1954" nimi="H??rma k??la"/><asula kood="1994" nimi="Igavere k??la"/><asula kood="2335" nimi="J??rsi k??la"/><asula kood="2575" nimi="Kalesi k??la"/><asula kood="3183" nimi="Kiviloo k??la"/><asula kood="3597" nimi="Kulli k??la"/><asula kood="3668" nimi="Kurgla k??la"/><asula kood="4758" nimi="Mallavere k??la"/><asula kood="6098" nimi="Peningi k??la"/><asula kood="6122" nimi="Perila k??la"/><asula kood="6228" nimi="Pikavere k??la"/><asula kood="6694" nimi="Raasiku alevik"/><asula kood="7226" nimi="R??tla k??la"/><asula kood="8477" nimi="T??helgi k??la"/></vald><vald kood="0653"><asula kood="1050" nimi="Aaviku k??la"/><asula kood="1391" nimi="Aruvalla k??la"/><asula kood="1408" nimi="Assaku alevik"/><asula kood="2353" nimi="J??rvek??la"/><asula kood="2377" nimi="J??ri alevik"/><asula kood="2474" nimi="Kadaka k??la"/><asula kood="2763" nimi="Karla k??la"/><asula kood="2885" nimi="Kautjala k??la"/><asula kood="3435" nimi="Kopli k??la"/><asula kood="3687" nimi="Kurna k??la"/><asula kood="4043" nimi="Lagedi alevik"/><asula kood="4208" nimi="Lehmja k??la"/><asula kood="4378" nimi="Limu k??la"/><asula kood="5891" nimi="Pajupea k??la"/><asula kood="6036" nimi="Patika k??la"/><asula kood="6086" nimi="Peetri alevik"/><asula kood="6240" nimi="Pildik??la"/><asula kood="6713" nimi="Rae k??la"/><asula kood="7392" nimi="Salu k??la"/><asula kood="7517" nimi="Seli k??la"/><asula kood="7688" nimi="Soodevahe k??la"/><asula kood="7852" nimi="Suuresta k??la"/><asula kood="7868" nimi="Suursoo k??la"/><asula kood="8454" nimi="Tuulev??lja k??la"/><asula kood="8731" nimi="Urvaste k??la"/><asula kood="8774" nimi="Uuesalu k??la"/><asula kood="8867" nimi="Vaida alevik"/><asula kood="8869" nimi="Vaidasoo k??la"/><asula kood="9108" nimi="Vaskjala k??la"/><asula kood="9202" nimi="Venek??la"/><asula kood="9236" nimi="Veskitaguse k??la"/><asula kood="9832" nimi="??lej??e k??la"/></vald><vald kood="0718"><asula kood="2220" nimi="Juuliku k??la"/><asula kood="2307" nimi="J??lgim??e k??la"/><asula kood="2552" nimi="Kajamaa k??la"/><asula kood="2794" nimi="Kasemetsa k??la"/><asula kood="3048" nimi="Kiisa alevik"/><asula kood="3119" nimi="Kirdalu k??la"/><asula kood="3697" nimi="Kurtna k??la"/><asula kood="4481" nimi="Lokuti k??la"/><asula kood="4912" nimi="Metsanurme k??la"/><asula kood="5261" nimi="M??nniku k??la"/><asula kood="6739" nimi="Rahula k??la"/><asula kood="7056" nimi="Roobuka k??la"/><asula kood="7361" nimi="Saku alevik"/><asula kood="2652" nimi="Saue k??la"/><asula kood="7469" nimi="Saustin??mme k??la"/><asula kood="7704" nimi="Sookaera-Metsanurga k??la"/><asula kood="8033" nimi="Tagadi k??la"/><asula kood="8096" nimi="Tammej??rve k??la"/><asula kood="8098" nimi="Tammem??e k??la"/><asula kood="8472" nimi="T??dva k??la"/><asula kood="8572" nimi="T??nassilma k??la"/><asula kood="9820" nimi="??ksnurme k??la"/></vald><vald kood="0727"><asula kood="1141" nimi="Aila k??la"/><asula kood="1216" nimi="Alliku k??la"/><asula kood="1975" nimi="H????ru k??la"/><asula kood="2267" nimi="J??gisoo k??la"/><asula kood="3025" nimi="Kiia k??la"/><asula kood="3285" nimi="Koidu k??la"/><asula kood="3439" nimi="Koppelmaa k??la"/><asula kood="4014" nimi="Laagri alevik"/><asula kood="4739" nimi="Maidla k??la"/><asula kood="6588" nimi="P??llu k??la"/><asula kood="6603" nimi="P??rinurme k??la"/><asula kood="6652" nimi="P??ha k??la"/><asula kood="8045" nimi="Tagametsa k??la"/><asula kood="8450" nimi="Tuula k??la"/><asula kood="8946" nimi="Valingu k??la"/><asula kood="9033" nimi="Vanam??isa k??la"/><asula kood="9146" nimi="Vatsla k??la"/><asula kood="9794" nimi="????sm??e k??la"/></vald><vald kood="0868"><asula kood="4263" nimi="Lemmaru k??la"/><asula kood="7121" nimi="Rummu alevik"/><asula kood="9101" nimi="Vasalemma alevik"/><asula kood="9231" nimi="Veskik??la"/><asula kood="9752" nimi="??mari alevik"/></vald><vald kood="0890"><asula kood="1675" nimi="Haabneeme alevik"/><asula kood="1984" nimi="Idaotsa k??la"/><asula kood="2944" nimi="Kelnase k??la"/><asula kood="2945" nimi="Kelvingi k??la"/><asula kood="4064" nimi="Laiak??la"/><asula kood="4299" nimi="Leppneeme k??la"/><asula kood="4534" nimi="Lubja k??la"/><asula kood="4618" nimi="L??unak??la k??la"/><asula kood="4656" nimi="L????neotsa k??la"/><asula kood="4887" nimi="Metsakasti k??la"/><asula kood="4943" nimi="Miiduranna k??la"/><asula kood="5104" nimi="Muuga k??la"/><asula kood="6370" nimi="Pringi k??la"/><asula kood="6613" nimi="P??rnam??e k??la"/><asula kood="6672" nimi="P????nsi k??la"/><asula kood="6797" nimi="Randvere k??la"/><asula kood="7039" nimi="Rohuneeme k??la"/><asula kood="8039" nimi="Tagak??la"/><asula kood="8126" nimi="Tammneeme k??la"/><asula kood="9280" nimi="Viimsi alevik"/><asula kood="9619" nimi="V??ikeheinamaa k??la"/><asula kood="9744" nimi="??igrum??e k??la"/></vald></maakond><maakond kood="0039"><vald kood="0175"><asula kood="1589" nimi="Emmaste k??la"/><asula kood="1734" nimi="Haldi k??la"/><asula kood="1732" nimi="Haldreka k??la"/><asula kood="1769" nimi="Harju k??la"/><asula kood="1851" nimi="Hindu k??la"/><asula kood="1952" nimi="H??rma k??la"/><asula kood="2180" nimi="Jausa k??la"/><asula kood="2467" nimi="Kabuna k??la"/><asula kood="2481" nimi="Kaderna k??la"/><asula kood="3160" nimi="Kitsa k??la"/><asula kood="3678" nimi="Kurisu k??la"/><asula kood="3717" nimi="Kuusiku k??la"/><asula kood="3760" nimi="K??mmusselja k??la"/><asula kood="3976" nimi="K??lak??la"/><asula kood="3978" nimi="K??lama k??la"/><asula kood="4025" nimi="Laartsa k??la"/><asula kood="4128" nimi="Lassi k??la"/><asula kood="4245" nimi="Leisu k??la"/><asula kood="4290" nimi="Lepiku k??la"/><asula kood="4898" nimi="Metsalauka k??la"/><asula kood="4910" nimi="Metsapere k??la"/><asula kood="4993" nimi="Muda k??la"/><asula kood="5272" nimi="M??nspe k??la"/><asula kood="5479" nimi="Nurste k??la"/><asula kood="5654" nimi="Ole k??la"/><asula kood="6357" nimi="Prassi k??la"/><asula kood="6372" nimi="Pr??hnu k??la"/><asula kood="6609" nimi="P??rna k??la"/><asula kood="6801" nimi="Rannak??la"/><asula kood="6903" nimi="Reheselja k??la"/><asula kood="6972" nimi="Riidak??la"/><asula kood="7527" nimi="Selja k??la"/><asula kood="7548" nimi="Sepaste k??la"/><asula kood="7616" nimi="Sinima k??la"/><asula kood="7900" nimi="S??ru k??la"/><asula kood="8236" nimi="Tilga k??la"/><asula kood="8271" nimi="Tohvri k??la"/><asula kood="8576" nimi="T??rkma k??la"/><asula kood="8656" nimi="Ulja k??la"/><asula kood="8938" nimi="Valgu k??la"/><asula kood="9019" nimi="Vanam??isa k??la"/><asula kood="9295" nimi="Viiri k??la"/><asula kood="9703" nimi="??ngu k??la"/></vald><vald kood="0204"><asula kood="1788" nimi="Heigi k??la"/><asula kood="1801" nimi="Heiste k??la"/><asula kood="1800" nimi="Heistesoo k??la"/><asula kood="1873" nimi="Hirmuste k??la"/><asula kood="1971" nimi="H??ti k??la"/><asula kood="2109" nimi="Isabella k??la"/><asula kood="2247" nimi="J??eranna k??la"/><asula kood="2250" nimi="J??esuu k??la"/><asula kood="2561" nimi="Kalana k??la"/><asula kood="2577" nimi="Kaleste k??la"/><asula kood="2650" nimi="Kanapeeksi k??la"/><asula kood="2881" nimi="Kauste k??la"/><asula kood="3004" nimi="Kidaste k??la"/><asula kood="3009" nimi="Kiduspe k??la"/><asula kood="3054" nimi="Kiivera k??la"/><asula kood="3235" nimi="Kodeste k??la"/><asula kood="3271" nimi="Koidma k??la"/><asula kood="3433" nimi="Kopa k??la"/><asula kood="3679" nimi="Kurisu k??la"/><asula kood="3781" nimi="K??pu k??la"/><asula kood="3795" nimi="K??rgessaare alevik"/><asula kood="3895" nimi="K??rdla linn"/><asula kood="4023" nimi="Laasi k??la"/><asula kood="4141" nimi="Lauka k??la"/><asula kood="4209" nimi="Lehtma k??la"/><asula kood="4223" nimi="Leigri k??la"/><asula kood="4371" nimi="Lilbi k??la"/><asula kood="4546" nimi="Luidja k??la"/><asula kood="4765" nimi="Malvaste k??la"/><asula kood="4766" nimi="Mangu k??la"/><asula kood="4780" nimi="Mardihansu k??la"/><asula kood="4844" nimi="Meelste k??la"/><asula kood="4890" nimi="Metsak??la"/><asula kood="4995" nimi="Mudaste k??la"/><asula kood="5224" nimi="M??gipe k??la"/><asula kood="5350" nimi="Napi k??la"/><asula kood="5507" nimi="N??mme k??la"/><asula kood="5613" nimi="Ogandi k??la"/><asula kood="5649" nimi="Ojak??la"/><asula kood="5767" nimi="Otste k??la"/><asula kood="5932" nimi="Palli k??la"/><asula kood="5978" nimi="Paope k??la"/><asula kood="6145" nimi="Pihla k??la"/><asula kood="6297" nimi="Poama k??la"/><asula kood="6459" nimi="Puski k??la"/><asula kood="6908" nimi="Reigi k??la"/><asula kood="7009" nimi="Risti k??la"/><asula kood="7084" nimi="Rootsi k??la"/><asula kood="7554" nimi="Sigala k??la"/><asula kood="7848" nimi="Suurepsi k??la"/><asula kood="7850" nimi="Suureranna k??la"/><asula kood="7972" nimi="S??lluste k??la"/><asula kood="8067" nimi="Tahkuna k??la"/><asula kood="8122" nimi="Tammistu k??la"/><asula kood="8209" nimi="Tiharu k??la"/><asula kood="9303" nimi="Viita k??la"/><asula kood="9306" nimi="Viitasoo k??la"/><asula kood="9327" nimi="Vilima k??la"/><asula kood="9349" nimi="Villamaa k??la"/><asula kood="9826" nimi="??lendi k??la"/></vald><vald kood="0368"><asula kood="1013" nimi="Aadma k??la"/><asula kood="1200" nimi="Allika k??la"/><asula kood="1647" nimi="Esik??la"/><asula kood="2227" nimi="J??ek??la"/><asula kood="2428" nimi="Kaasiku k??la"/><asula kood="2533" nimi="Kaigutsi k??la"/><asula kood="2807" nimi="Kassari k??la"/><asula kood="3196" nimi="Kleemu k??la"/><asula kood="3253" nimi="Kogri k??la"/><asula kood="3337" nimi="Kolga k??la"/><asula kood="3680" nimi="Kuriste k??la"/><asula kood="3869" nimi="K??ina alevik"/><asula kood="4056" nimi="Lahek??la"/><asula kood="4253" nimi="Lelu k??la"/><asula kood="4319" nimi="Ligema k??la"/><asula kood="4537" nimi="Luguse k??la"/><asula kood="4966" nimi="Moka k??la"/><asula kood="5183" nimi="M??ek??la"/><asula kood="5203" nimi="M??eltse k??la"/><asula kood="5258" nimi="M??nnamaa k??la"/><asula kood="5360" nimi="Nasva k??la"/><asula kood="5412" nimi="Niidik??la"/><asula kood="5512" nimi="N??mme k??la"/><asula kood="5514" nimi="N??mmerga k??la"/><asula kood="5728" nimi="Orjaku k??la"/><asula kood="6460" nimi="Putkaste k??la"/><asula kood="6615" nimi="P??rnselja k??la"/><asula kood="7014" nimi="Ristiv??lja k??la"/><asula kood="7528" nimi="Selja k??la"/><asula kood="8061" nimi="Taguk??la"/><asula kood="8162" nimi="Taterma k??la"/><asula kood="8747" nimi="Utu k??la"/><asula kood="8827" nimi="Vaemla k??la"/><asula kood="8911" nimi="Villemi k??la"/><asula kood="9816" nimi="??htri k??la"/></vald><vald kood="0639"><asula kood="1157" nimi="Ala k??la"/><asula kood="1374" nimi="Aruk??la"/><asula kood="1713" nimi="Hagaste k??la"/><asula kood="1767" nimi="Harju k??la"/><asula kood="1787" nimi="Hausma k??la"/><asula kood="1807" nimi="Hellamaa k??la"/><asula kood="1818" nimi="Heltermaa k??la"/><asula kood="1835" nimi="Hiiessaare k??la"/><asula kood="1841" nimi="Hilleste k??la"/><asula kood="2578" nimi="Kalgi k??la"/><asula kood="2959" nimi="Kerema k??la"/><asula kood="3557" nimi="Kukka k??la"/><asula kood="3671" nimi="Kuri k??la"/><asula kood="3759" nimi="K??lun??mme k??la"/><asula kood="4184" nimi="Leerimetsa k??la"/><asula kood="4402" nimi="Linnum??e k??la"/><asula kood="4465" nimi="Loja k??la"/><asula kood="4590" nimi="L??bembe k??la"/><asula kood="4612" nimi="L??pe k??la"/><asula kood="5298" nimi="M????vli k??la"/><asula kood="5503" nimi="N??mba k??la"/><asula kood="5515" nimi="N??mme k??la"/><asula kood="5908" nimi="Palade k??la"/><asula kood="5946" nimi="Paluk??la"/><asula kood="6024" nimi="Partsi k??la"/><asula kood="6258" nimi="Pilpak??la"/><asula kood="6373" nimi="Pr??hlam??e k??la"/><asula kood="6419" nimi="Puliste k??la"/><asula kood="6661" nimi="P??halepa k??la"/><asula kood="6910" nimi="Reikama k??la"/><asula kood="7349" nimi="Sakla k??la"/><asula kood="7382" nimi="Salin??mme k??la"/><asula kood="7438" nimi="Sarve k??la"/><asula kood="7728" nimi="Soonlepa k??la"/><asula kood="7846" nimi="Suurem??isa k??la"/><asula kood="7864" nimi="Suuresadama k??la"/><asula kood="7949" nimi="S????re k??la"/><asula kood="8095" nimi="Tammela k??la"/><asula kood="8150" nimi="Tareste k??la"/><asula kood="8190" nimi="Tempa k??la"/><asula kood="8382" nimi="Tubala k??la"/><asula kood="8682" nimi="Undama k??la"/><asula kood="8853" nimi="Vahtrepa k??la"/><asula kood="8949" nimi="Valipe k??la"/><asula kood="9278" nimi="Viilupi k??la"/><asula kood="9338" nimi="Vilivalla k??la"/><asula kood="9674" nimi="V??rssu k??la"/></vald></maakond><maakond kood="0044"><vald kood="0322"><asula kood="0120" nimi="Ahtme linnaosa"/><asula kood="0265" nimi="J??rve linnaosa"/><asula kood="0340" nimi="Kukruse linnaosa"/><asula kood="0553" nimi="Oru linnaosa"/><asula kood="0747" nimi="Sompa linnaosa"/><asula kood="0893" nimi="Viivikonna linnaosa"/></vald><vald kood="0122"><asula kood="1165" nimi="Alaj??e k??la"/><asula kood="2752" nimi="Karjamaa k??la"/><asula kood="2850" nimi="Katase k??la"/><asula kood="6927" nimi="Remniku k??la"/><asula kood="7649" nimi="Smolnitsa k??la"/><asula kood="8786" nimi="Uusk??la"/><asula kood="9111" nimi="Vasknarva k??la"/></vald><vald kood="0154"><asula kood="1402" nimi="Aseri alevik"/><asula kood="1405" nimi="Aseriaru k??la"/><asula kood="2626" nimi="Kalvi k??la"/><asula kood="2986" nimi="Kestla k??la"/><asula kood="3394" nimi="Koogu k??la"/><asula kood="3803" nimi="K??rkk??la"/><asula kood="3814" nimi="K??rtsialuse k??la"/><asula kood="5739" nimi="Oru k??la"/><asula kood="6821" nimi="Rannu k??la"/></vald><vald kood="0164"><asula kood="1087" nimi="Adraku k??la"/><asula kood="1191" nimi="Alekere k??la"/><asula kood="1481" nimi="Avinurme alevik"/><asula kood="2503" nimi="Kaevussaare k??la"/><asula kood="3052" nimi="Kiissa k??la"/><asula kood="3819" nimi="K??rve k??la"/><asula kood="3826" nimi="K??rvemetsa k??la"/><asula kood="3842" nimi="K??veriku k??la"/><asula kood="4033" nimi="Laekannu k??la"/><asula kood="4287" nimi="Lepiksaare k??la"/><asula kood="4727" nimi="Maetsma k??la"/><asula kood="5774" nimi="Paadenurme k??la"/><asula kood="7921" nimi="S??lliksaare k??la"/><asula kood="8102" nimi="Tammessaare k??la"/><asula kood="8664" nimi="Ulvi k??la"/><asula kood="8819" nimi="Vadi k??la"/><asula kood="9773" nimi="??nniksaare k??la"/></vald><vald kood="0224"><asula kood="1211" nimi="Alliku k??la"/><asula kood="2025" nimi="Iisaku alevik"/><asula kood="2071" nimi="Imatu k??la"/><asula kood="2281" nimi="J??uga k??la"/><asula kood="2802" nimi="Kasev??lja k??la"/><asula kood="2868" nimi="Kauksi k??la"/><asula kood="3331" nimi="Koldam??e k??la"/><asula kood="3700" nimi="Kuru k??la"/><asula kood="4418" nimi="Lipniku k??la"/><asula kood="4610" nimi="L??pe k??la"/><asula kood="6327" nimi="Pootsiku k??la"/><asula kood="7902" nimi="S??rum??e k??la"/><asula kood="7924" nimi="S??lliku k??la"/><asula kood="1534" nimi="Taga-Roostoja k??la"/><asula kood="8104" nimi="Tammetaguse k??la"/><asula kood="8578" nimi="T??rivere k??la"/><asula kood="8874" nimi="Vaikla k??la"/><asula kood="9075" nimi="Varesmetsa k??la"/></vald><vald kood="0229"><asula kood="1103" nimi="Agusalu k??la"/><asula kood="1526" nimi="Edivere k??la"/><asula kood="2042" nimi="Illuka k??la"/><asula kood="2130" nimi="Jaama k??la"/><asula kood="2431" nimi="Kaatermu k??la"/><asula kood="2528" nimi="Kaidma k??la"/><asula kood="2639" nimi="Kamarna k??la"/><asula kood="2767" nimi="Karoli k??la"/><asula kood="3190" nimi="Kivin??mme k??la"/><asula kood="3377" nimi="Konsu k??la"/><asula kood="3621" nimi="Kuningak??la"/><asula kood="3644" nimi="Kurem??e k??la"/><asula kood="3696" nimi="Kurtna k??la"/><asula kood="5615" nimi="Ohakvere k??la"/><asula kood="5677" nimi="Ongassaare k??la"/><asula kood="6127" nimi="Permisk??la"/><asula kood="6391" nimi="Puhatu k??la"/><asula kood="6866" nimi="Rausvere k??la"/><asula kood="9106" nimi="Vasavere k??la"/></vald><vald kood="0251"><asula kood="1524" nimi="Edise k??la"/><asula kood="2271" nimi="J??hvi k??la"/><asula kood="2270" nimi="J??hvi linn"/><asula kood="2520" nimi="Kahula k??la"/><asula kood="3461" nimi="Kose k??la"/><asula kood="3477" nimi="Kotinuka k??la"/><asula kood="4389" nimi="Linna k??la"/><asula kood="5884" nimi="Pajualuse k??la"/><asula kood="5999" nimi="Pargitaguse k??la"/><asula kood="6050" nimi="Pauliku k??la"/><asula kood="6455" nimi="Puru k??la"/><asula kood="7677" nimi="Sompa k??la"/><asula kood="8114" nimi="Tammiku alevik"/></vald><vald kood="0323"><asula kood="3270" nimi="Kohtla-N??mme alev"/></vald><vald kood="0320"><asula kood="1253" nimi="Amula k??la"/><asula kood="2350" nimi="J??rve k??la"/><asula kood="2420" nimi="Kaasikaia k??la"/><asula kood="2429" nimi="Kaasikv??lja k??la"/><asula kood="2448" nimi="Kabelimetsa k??la"/><asula kood="3269" nimi="Kohtla k??la"/><asula kood="3562" nimi="Kukruse k??la"/><asula kood="5142" nimi="M??isamaa k??la"/><asula kood="5680" nimi="Ontika k??la"/><asula kood="5793" nimi="Paate k??la"/><asula kood="6081" nimi="Peeri k??la"/><asula kood="7063" nimi="Roodu k??la"/><asula kood="7348" nimi="Saka k??la"/><asula kood="7551" nimi="Serva????re k??la"/><asula kood="8563" nimi="T??kumetsa k??la"/><asula kood="8914" nimi="Valaste k??la"/><asula kood="9432" nimi="Vitsiku k??la"/></vald><vald kood="0420"><asula kood="2236" nimi="J??emetsa k??la"/><asula kood="2616" nimi="Kalmak??la"/><asula kood="3884" nimi="K??rasi k??la"/><asula kood="4459" nimi="Lohusuu alevik"/><asula kood="5430" nimi="Ninasi k??la"/><asula kood="6174" nimi="Piilsi k??la"/><asula kood="6682" nimi="Raadna k??la"/><asula kood="7544" nimi="Separa k??la"/><asula kood="8117" nimi="Tammisp???? k??la"/><asula kood="9364" nimi="Vilusi k??la"/></vald><vald kood="0438"><asula kood="1004" nimi="Aa k??la"/><asula kood="1132" nimi="Aidu k??la"/><asula kood="1139" nimi="Aidu-Liiva k??la"/><asula kood="1133" nimi="Aidu-N??mme k??la"/><asula kood="1140" nimi="Aidu-Sook??la"/><asula kood="1368" nimi="Aruk??la"/><asula kood="1382" nimi="Arup????lse k??la"/><asula kood="1393" nimi="Aruv??lja k??la"/><asula kood="1871" nimi="Hirmuse k??la"/><asula kood="2105" nimi="Irvala k??la"/><asula kood="2150" nimi="Jabara k??la"/><asula kood="3404" nimi="Koolma k??la"/><asula kood="3436" nimi="Kopli k??la"/><asula kood="3576" nimi="Kulja k??la"/><asula kood="4347" nimi="Liimala k??la"/><asula kood="4419" nimi="Lipu k??la"/><asula kood="4449" nimi="Lohkuse k??la"/><asula kood="4669" nimi="L??ganuse alevik"/><asula kood="4688" nimi="L??matu k??la"/><asula kood="4740" nimi="Maidla k??la"/><asula kood="4819" nimi="Matka k??la"/><asula kood="4857" nimi="Mehide k??la"/><asula kood="4975" nimi="Moldova k??la"/><asula kood="5088" nimi="Mustm??tta k??la"/><asula kood="5574" nimi="Oandu k??la"/><asula kood="5652" nimi="Ojamaa k??la"/><asula kood="6172" nimi="Piilse k??la"/><asula kood="6450" nimi="Purtse k??la"/><asula kood="6671" nimi="P??ssi linn"/><asula kood="6894" nimi="Rebu k??la"/><asula kood="7245" nimi="R????sa k??la"/><asula kood="7371" nimi="Salak??la"/><asula kood="7477" nimi="Savala k??la"/><asula kood="7640" nimi="Sirtsi k??la"/><asula kood="7735" nimi="Soonurme k??la"/><asula kood="8154" nimi="Tarumaa k??la"/><asula kood="8691" nimi="Unik??la"/><asula kood="9088" nimi="Varja k??la"/><asula kood="9200" nimi="Veneoja k??la"/><asula kood="9406" nimi="Virunurme k??la"/><asula kood="9475" nimi="Voorepera k??la"/></vald><vald kood="0498"><asula kood="1310" nimi="Apandiku k??la"/><asula kood="1377" nimi="Aruk??la"/><asula kood="1398" nimi="Arvila k??la"/><asula kood="1443" nimi="Atsalama k??la"/><asula kood="1623" nimi="Ereda k??la"/><asula kood="2249" nimi="J??etaguse k??la"/><asula kood="2586" nimi="Kalina k??la"/><asula kood="3035" nimi="Kiikla k??la"/><asula kood="4374" nimi="Liivak??nka k??la"/><asula kood="4923" nimi="Metsk??la"/><asula kood="5213" nimi="M??etaguse alevik"/><asula kood="5217" nimi="M??etaguse k??la"/><asula kood="5841" nimi="Pagari k??la"/><asula kood="6767" nimi="Rajak??la"/><asula kood="6844" nimi="Ratva k??la"/><asula kood="8147" nimi="Tarakuse k??la"/><asula kood="8624" nimi="Uhe k??la"/><asula kood="9494" nimi="V??hma k??la"/><asula kood="9516" nimi="V??ide k??la"/><asula kood="9580" nimi="V??rnu k??la"/><asula kood="9631" nimi="V??ike-Pungerja k??la"/></vald><vald kood="0751"><asula kood="1631" nimi="Erra alevik"/><asula kood="1629" nimi="Erra-Liiva k??la"/><asula kood="2051" nimi="Ilmaste k??la"/><asula kood="3348" nimi="Koljala k??la"/><asula kood="5569" nimi="N??ri k??la"/><asula kood="7447" nimi="Satsu k??la"/><asula kood="7680" nimi="Sonda alevik"/><asula kood="8660" nimi="Uljaste k??la"/><asula kood="8884" nimi="Vainu k??la"/><asula kood="9005" nimi="Vana-Sonda k??la"/><asula kood="9086" nimi="Varinurme k??la"/></vald><vald kood="0802"><asula kood="1212" nimi="Altk??la"/><asula kood="3375" nimi="Konju k??la"/><asula kood="4799" nimi="Martsa k??la"/><asula kood="4896" nimi="Metsam??gara k??la"/><asula kood="6582" nimi="P??ite k??la"/><asula kood="6656" nimi="P??haj??e k??la"/><asula kood="8275" nimi="Toila alevik"/><asula kood="8647" nimi="Uikala k??la"/><asula kood="8900" nimi="Vaivina k??la"/><asula kood="9455" nimi="Voka alevik"/><asula kood="9453" nimi="Voka k??la"/></vald><vald kood="0815"><asula kood="2939" nimi="Kellassaare k??la"/><asula kood="4258" nimi="Lemmaku k??la"/><asula kood="5695" nimi="Oonurme k??la"/><asula kood="6117" nimi="Peressaare k??la"/><asula kood="6224" nimi="Pikati k??la"/><asula kood="6816" nimi="Rannapungerja k??la"/><asula kood="7086" nimi="Roostoja k??la"/><asula kood="7337" nimi="Sahargu k??la"/><asula kood="8035" nimi="Tagaj??e k??la"/><asula kood="8393" nimi="Tudulinna alevik"/></vald><vald kood="0851"><asula kood="1381" nimi="Arum??e k??la"/><asula kood="1472" nimi="Auvere k??la"/><asula kood="1833" nimi="Hiiemetsa k??la"/><asula kood="1908" nimi="Hundinurga k??la"/><asula kood="3520" nimi="Kudruk??la"/><asula kood="4012" nimi="Laagna k??la"/><asula kood="4884" nimi="Merik??la"/><asula kood="5067" nimi="Mustanina k??la"/><asula kood="5663" nimi="Olgina alevik"/><asula kood="6084" nimi="Peeterristi k??la"/><asula kood="6125" nimi="Perjatsi k??la"/><asula kood="6265" nimi="Pimestiku k??la"/><asula kood="6396" nimi="Puhkova k??la"/><asula kood="7619" nimi="Sinim??e alevik"/><asula kood="7674" nimi="Soldina k??la"/><asula kood="7908" nimi="S??tke k??la"/><asula kood="8530" nimi="T??rvaj??e k??la"/><asula kood="8619" nimi="Udria k??la"/><asula kood="8895" nimi="Vaivara k??la"/><asula kood="9444" nimi="Vodava k??la"/></vald></maakond><maakond kood="0049"><vald kood="0248"><asula kood="1185" nimi="Alavere k??la"/><asula kood="1582" nimi="Ellakvere k??la"/><asula kood="1598" nimi="Endla k??la"/><asula kood="2261" nimi="J??geva alevik"/><asula kood="2495" nimi="Kaera k??la"/><asula kood="2818" nimi="Kassinurme k??la"/><asula kood="2861" nimi="Kaude k??la"/><asula kood="3178" nimi="Kivij??rve k??la"/><asula kood="3642" nimi="Kuremaa alevik"/><asula kood="3676" nimi="Kurista k??la"/><asula kood="3778" nimi="K??ola k??la"/><asula kood="3894" nimi="K??rde k??la"/><asula kood="4078" nimi="Laiuse alevik"/><asula kood="4080" nimi="Laiusev??lja k??la"/><asula kood="4278" nimi="Lemuvere k??la"/><asula kood="4364" nimi="Liivoja k??la"/><asula kood="4613" nimi="L??pe k??la"/><asula kood="4983" nimi="Mooritsa k??la"/><asula kood="5131" nimi="M??isamaa k??la"/><asula kood="5817" nimi="Paduvere k??la"/><asula kood="5870" nimi="Paink??la"/><asula kood="5902" nimi="Pakaste k??la"/><asula kood="5954" nimi="Palupere k??la"/><asula kood="6040" nimi="Patjala k??la"/><asula kood="6073" nimi="Pedja k??la"/><asula kood="6684" nimi="Raaduvere k??la"/><asula kood="7031" nimi="Rohe k??la"/><asula kood="7539" nimi="Selli k??la"/><asula kood="7573" nimi="Siimusti alevik"/><asula kood="7719" nimi="Soomevere k??la"/><asula kood="8188" nimi="Teilma k??la"/><asula kood="8295" nimi="Tooma k??la"/><asula kood="8879" nimi="Vaimastvere k??la"/><asula kood="8979" nimi="Vana-J??geva k??la"/><asula kood="9333" nimi="Vilina k??la"/><asula kood="9409" nimi="Viruvere k??la"/><asula kood="9489" nimi="V??duvere k??la"/><asula kood="9529" nimi="V??ikvere k??la"/><asula kood="9615" nimi="V??geva k??la"/><asula kood="9655" nimi="V??ljaotsa k??la"/><asula kood="9721" nimi="??una k??la"/></vald><vald kood="0657"><asula kood="2430" nimi="Kaasiku k??la"/><asula kood="2800" nimi="Kasep???? k??la"/><asula kood="3968" nimi="K??kita k??la"/><asula kood="5052" nimi="Metsak??la"/><asula kood="5532" nimi="N??mme k??la"/><asula kood="5673" nimi="Omedu k??la"/><asula kood="6764" nimi="Raja k??la"/><asula kood="8210" nimi="Tiheda k??la"/></vald><vald kood="0573"><asula kood="1137" nimi="Aidu k??la"/><asula kood="1351" nimi="Arisvere k??la"/><asula kood="2436" nimi="Kaave k??la"/><asula kood="2562" nimi="Kalana k??la"/><asula kood="2875" nimi="Kauru k??la"/><asula kood="3458" nimi="Kose k??la"/><asula kood="3779" nimi="K??pu k??la"/><asula kood="3801" nimi="K??rkk??la"/><asula kood="4049" nimi="Lahavere k??la"/><asula kood="4513" nimi="Loopre k??la"/><asula kood="4551" nimi="Luige k??la"/><asula kood="5136" nimi="M??isak??la"/><asula kood="5166" nimi="M??rtsi k??la"/><asula kood="5462" nimi="Nurga k??la"/><asula kood="5894" nimi="Pajusi k??la"/><asula kood="6280" nimi="Pisisaare k??la"/><asula kood="7753" nimi="Sopimetsa k??la"/><asula kood="8141" nimi="Tapiku k??la"/><asula kood="8483" nimi="T??ivere k??la"/><asula kood="8772" nimi="Uuev??lja k??la"/><asula kood="9486" nimi="Vorsti k??la"/><asula kood="9612" nimi="V??gari k??la"/><asula kood="9654" nimi="V??ljataguse k??la"/></vald><vald kood="0578"><asula kood="1533" nimi="Eerikvere k??la"/><asula kood="1543" nimi="Ehavere k??la"/><asula kood="2079" nimi="Imukvere k??la"/><asula kood="2360" nimi="J??rvepera k??la"/><asula kood="2403" nimi="Kaarepere k??la"/><asula kood="2523" nimi="Kaiavere k??la"/><asula kood="2819" nimi="Kassivere k??la"/><asula kood="3188" nimi="Kivim??e k??la"/><asula kood="3518" nimi="Kudina k??la"/><asula kood="4579" nimi="Luua k??la"/><asula kood="5023" nimi="Mullavere k??la"/><asula kood="5373" nimi="Nava k??la"/><asula kood="5913" nimi="Palamuse alevik"/><asula kood="6233" nimi="Pikkj??rve k??la"/><asula kood="6344" nimi="Praaklima k??la"/><asula kood="6679" nimi="Raadivere k??la"/><asula kood="6727" nimi="Rahivere k??la"/><asula kood="7048" nimi="Ronivere k??la"/><asula kood="7762" nimi="Sudiste k??la"/><asula kood="7983" nimi="S??valepa k??la"/><asula kood="8318" nimi="Toovere k??la"/><asula kood="8872" nimi="Vaidavere k??la"/><asula kood="9037" nimi="Vanav??lja k??la"/><asula kood="9058" nimi="Varbevere k??la"/><asula kood="9431" nimi="Visusti k??la"/><asula kood="9770" nimi="??nkk??la"/></vald><vald kood="0576"><asula kood="1413" nimi="Assikvere k??la"/><asula kood="1702" nimi="Haavakivi k??la"/><asula kood="2489" nimi="Kadrina k??la"/><asula kood="3151" nimi="Kirtsi k??la"/><asula kood="3234" nimi="Kodavere k??la"/><asula kood="3310" nimi="Kokanurga k??la"/><asula kood="4685" nimi="L??mati k??la"/><asula kood="4904" nimi="Metsanurga k??la"/><asula kood="4972" nimi="Moku k??la"/><asula kood="5544" nimi="N??va k??la"/><asula kood="5905" nimi="Pala k??la"/><asula kood="6111" nimi="Perametsa k??la"/><asula kood="6161" nimi="Piibum??e k??la"/><asula kood="6189" nimi="Piirivarbe k??la"/><asula kood="6432" nimi="Punikvere k??la"/><asula kood="6699" nimi="Raatvere k??la"/><asula kood="6803" nimi="Ranna k??la"/><asula kood="7444" nimi="Sassukvere k??la"/><asula kood="7913" nimi="S????ru k??la"/><asula kood="7953" nimi="S????ritsa k??la"/><asula kood="8066" nimi="Tagumaa k??la"/><asula kood="9150" nimi="Vea k??la"/><asula kood="9787" nimi="??teniidi k??la"/></vald><vald kood="0611"><asula kood="1226" nimi="Altnurga k??la"/><asula kood="1950" nimi="H??rjanurme k??la"/><asula kood="2284" nimi="J??une k??la"/><asula kood="2379" nimi="J??rik??la"/><asula kood="3132" nimi="Kirikuvalla k??la"/><asula kood="3693" nimi="Kursi k??la"/><asula kood="4026" nimi="Laasme k??la"/><asula kood="6236" nimi="Pikknurme k??la"/><asula kood="6479" nimi="Puurmani alevik"/><asula kood="6643" nimi="P????ra k??la"/><asula kood="7323" nimi="Saduk??la"/><asula kood="8113" nimi="Tammiku k??la"/><asula kood="8537" nimi="T??rve k??la"/></vald><vald kood="0616"><asula kood="1076" nimi="Adavere alevik"/><asula kood="1179" nimi="Alastvere k??la"/><asula kood="1293" nimi="Annikvere k??la"/><asula kood="1652" nimi="Esku k??la"/><asula kood="2438" nimi="Kaavere k??la"/><asula kood="2461" nimi="Kablak??la"/><asula kood="2582" nimi="Kalik??la"/><asula kood="2621" nimi="Kalme k??la"/><asula kood="2636" nimi="Kamari alevik"/><asula kood="3624" nimi="Kuningam??e k??la"/><asula kood="4170" nimi="Lebavere k??la"/><asula kood="4567" nimi="Lustivere k??la"/><asula kood="5123" nimi="M??hk??la"/><asula kood="5253" nimi="M??llikvere k??la"/><asula kood="5382" nimi="Neanurme k??la"/><asula kood="5501" nimi="N??mavere k??la"/><asula kood="6048" nimi="Pauastvere k??la"/><asula kood="6262" nimi="Pilu k??la"/><asula kood="6381" nimi="Pudivere k??la"/><asula kood="6385" nimi="Puduk??la"/><asula kood="6404" nimi="Puiatu k??la"/><asula kood="7175" nimi="R??stla k??la"/><asula kood="7220" nimi="R??sna k??la"/><asula kood="7798" nimi="Sulustvere k??la"/><asula kood="8515" nimi="T??renurme k??la"/><asula kood="8674" nimi="Umbusi k??la"/><asula kood="9437" nimi="Vitsj??rve k??la"/><asula kood="9501" nimi="V??hman??mme k??la"/><asula kood="9536" nimi="V??isiku k??la"/><asula kood="9621" nimi="V??ike-Kamari k??la"/></vald><vald kood="0713"><asula kood="1746" nimi="Halliku k??la"/><asula kood="2129" nimi="Jaama k??la"/><asula kood="2611" nimi="Kallivere k??la"/><asula kood="3051" nimi="Kiisli k??la"/><asula kood="3467" nimi="Koseveski k??la"/><asula kood="7285" nimi="K????pa k??la"/><asula kood="4308" nimi="Levala k??la"/><asula kood="4702" nimi="Maardla k??la"/><asula kood="5367" nimi="Nautrasi k??la"/><asula kood="5598" nimi="Odivere k??la"/><asula kood="6067" nimi="Pedassaare k??la"/><asula kood="6469" nimi="Putu k??la"/><asula kood="6589" nimi="P??llu k??la"/><asula kood="7130" nimi="Ruskavere k??la"/><asula kood="7303" nimi="Saarj??rve k??la"/><asula kood="7637" nimi="Sirguvere k??la"/><asula kood="8149" nimi="Tarakvere k??la"/><asula kood="8453" nimi="Tuulavere k??la"/><asula kood="9029" nimi="Vanassaare k??la"/><asula kood="9116" nimi="Vassevere k??la"/><asula kood="9181" nimi="Veia k??la"/><asula kood="9466" nimi="Voore k??la"/></vald><vald kood="0773"><asula kood="1579" nimi="Elistvere k??la"/><asula kood="2218" nimi="Juula k??la"/><asula kood="2525" nimi="Kaiavere k??la"/><asula kood="2550" nimi="Kaitsem??isa k??la"/><asula kood="2809" nimi="Kassema k??la"/><asula kood="3386" nimi="Koogi k??la"/><asula kood="3737" nimi="K??duk??la"/><asula kood="3777" nimi="K??nnuj??e k??la"/><asula kood="3788" nimi="K??renduse k??la"/><asula kood="3913" nimi="K??rksi k??la"/><asula kood="4375" nimi="Lilu k??la"/><asula kood="4709" nimi="Maarja-Magdaleena k??la"/><asula kood="5769" nimi="Otslava k??la"/><asula kood="6034" nimi="Pataste k??la"/><asula kood="6751" nimi="Raigastvere k??la"/><asula kood="6918" nimi="Reinu k??la"/><asula kood="7542" nimi="Sepa k??la"/><asula kood="7756" nimi="Sortsi k??la"/><asula kood="8016" nimi="Tabivere alevik"/><asula kood="8334" nimi="Tormi k??la"/><asula kood="8629" nimi="Uhmardu k??la"/><asula kood="8849" nimi="Vahi k??la"/><asula kood="8934" nimi="Valgma k??la"/><asula kood="9461" nimi="Voldi k??la"/><asula kood="9725" nimi="??vanurme k??la"/></vald><vald kood="0810"><asula kood="2099" nimi="Iravere k??la"/><asula kood="2688" nimi="Kantk??la"/><asula kood="3244" nimi="Kodismaa k??la"/><asula kood="3302" nimi="Koimula k??la"/><asula kood="3769" nimi="K??nnu k??la"/><asula kood="4175" nimi="Leedi k??la"/><asula kood="4342" nimi="Liikatku k??la"/><asula kood="4367" nimi="Lilastvere k??la"/><asula kood="5548" nimi="N??duvere k??la"/><asula kood="5684" nimi="Ookatku k??la"/><asula kood="5756" nimi="Oti k??la"/><asula kood="6834" nimi="Rassiku k??la"/><asula kood="6879" nimi="Reastvere k??la"/><asula kood="7232" nimi="R????bise k??la"/><asula kood="7318" nimi="Sadala alevik"/><asula kood="7943" nimi="S??tsuvere k??la"/><asula kood="8174" nimi="Tealama k??la"/><asula kood="8331" nimi="Torma alevik"/><asula kood="8404" nimi="Tuim??isa k??la"/><asula kood="8480" nimi="T??ikvere k??la"/><asula kood="8558" nimi="T??hkvere k??la"/><asula kood="8861" nimi="Vaiatu k??la"/><asula kood="9021" nimi="Vanam??isa k??la"/><asula kood="9519" nimi="V??idivere k??la"/><asula kood="9596" nimi="V??tikvere k??la"/></vald></maakond><maakond kood="0051"><vald kood="0129"><asula kood="1100" nimi="Ageri k??la"/><asula kood="1122" nimi="Ahula k??la"/><asula kood="1188" nimi="Albu k??la"/><asula kood="2343" nimi="J??rva-Madise k??la"/><asula kood="2395" nimi="Kaalepi k??la"/><asula kood="4214" nimi="Lehtmetsa k??la"/><asula kood="5156" nimi="M??nuvere k??la"/><asula kood="5215" nimi="M??gede k??la"/><asula kood="5402" nimi="Neitla k??la"/><asula kood="5714" nimi="Orgmetsa k??la"/><asula kood="6079" nimi="Peedu k??la"/><asula kood="6422" nimi="Pullevere k??la"/><asula kood="7505" nimi="Seidla k??la"/><asula kood="7741" nimi="Soosalu k??la"/><asula kood="7770" nimi="Sugalepa k??la"/><asula kood="9243" nimi="Vetepere k??la"/></vald><vald kood="0134"><asula kood="1250" nimi="Ambla alevik"/><asula kood="1326" nimi="Aravete alevik"/><asula kood="2268" nimi="J??gisoo k??la"/><asula kood="3554" nimi="Kukevere k??la"/><asula kood="3673" nimi="Kurisoo k??la"/><asula kood="3886" nimi="K??ravete alevik"/><asula kood="5226" nimi="M??gise k??la"/><asula kood="5281" nimi="M??rjandi k??la"/><asula kood="6771" nimi="Raka k??la"/><asula kood="6870" nimi="Rava k??la"/><asula kood="6915" nimi="Reinevere k??la"/><asula kood="7081" nimi="Roosna k??la"/><asula kood="7961" nimi="S????sk??la"/></vald><vald kood="0234"><asula kood="1567" nimi="Eistvere k??la"/><asula kood="2073" nimi="Imavere k??la"/><asula kood="2159" nimi="Jalametsa k??la"/><asula kood="2321" nimi="J??ravere k??la"/><asula kood="3032" nimi="Kiigevere k??la"/><asula kood="3936" nimi="K??sukonna k??la"/><asula kood="4070" nimi="Laimetsa k??la"/><asula kood="6402" nimi="Puiatu k??la"/><asula kood="6583" nimi="P??llastvere k??la"/><asula kood="7991" nimi="Taadikvere k??la"/><asula kood="8097" nimi="Tammek??la"/><asula kood="9575" nimi="V??revere k??la"/></vald><vald kood="0257"><asula kood="2156" nimi="Jalal??pe k??la"/><asula kood="2164" nimi="Jalgsema k??la"/><asula kood="2341" nimi="J??rva-Jaani alev"/><asula kood="2506" nimi="Kagavere k??la"/><asula kood="2733" nimi="Karinu k??la"/><asula kood="3564" nimi="Kuksema k??la"/><asula kood="4927" nimi="Metsla k??la"/><asula kood="4936" nimi="Metstaguse k??la"/><asula kood="6780" nimi="Ramma k??la"/><asula kood="7521" nimi="Selik??la"/></vald><vald kood="0288"><asula kood="1252" nimi="Ammuta k??la"/><asula kood="1441" nimi="Ataste k??la"/><asula kood="1655" nimi="Esna k??la"/><asula kood="2712" nimi="Kareda k??la"/><asula kood="3960" nimi="K??isi k??la"/><asula kood="3992" nimi="K??ti k??la"/><asula kood="5322" nimi="M????sleri k??la"/><asula kood="6085" nimi="Peetri alevik"/><asula kood="9446" nimi="Vodja k??la"/><asula kood="9696" nimi="??le k??la"/><asula kood="9755" nimi="??mbra k??la"/><asula kood="9807" nimi="????tla k??la"/></vald><vald kood="0314"><asula kood="1055" nimi="Abaja k??la"/><asula kood="1371" nimi="Aruk??la"/><asula kood="1640" nimi="Ervita k??la"/><asula kood="2230" nimi="J??ek??la"/><asula kood="2591" nimi="Kalitsa k??la"/><asula kood="2702" nimi="Kapu k??la"/><asula kood="3255" nimi="Koeru alevik"/><asula kood="3273" nimi="Koidu-Ellavere k??la"/><asula kood="3723" nimi="Kuusna k??la"/><asula kood="4022" nimi="Laaneotsa k??la"/><asula kood="4428" nimi="Liusvere k??la"/><asula kood="4882" nimi="Merja k??la"/><asula kood="5455" nimi="Norra k??la"/><asula kood="6360" nimi="Preedi k??la"/><asula kood="6398" nimi="Puhmu k??la"/><asula kood="7157" nimi="R??hu k??la"/><asula kood="7399" nimi="Salutaguse k??la"/><asula kood="7408" nimi="Santovi k??la"/><asula kood="8110" nimi="Tammiku k??la"/><asula kood="8388" nimi="Tudre k??la"/><asula kood="8616" nimi="Udeva k??la"/><asula kood="8858" nimi="Vahuk??la"/><asula kood="8944" nimi="Valila k??la"/><asula kood="9047" nimi="Vao k??la"/><asula kood="9430" nimi="Visusti k??la"/><asula kood="9492" nimi="Vuti k??la"/><asula kood="9638" nimi="V??inj??rve k??la"/></vald><vald kood="0325"><asula kood="1920" nimi="Huuksi k??la"/><asula kood="2339" nimi="Kahala k??la"/><asula kood="2971" nimi="Keri k??la"/><asula kood="3282" nimi="Koigi k??la"/><asula kood="4626" nimi="L??hevere k??la"/><asula kood="6349" nimi="Prandi k??la"/><asula kood="6580" nimi="P??inurme k??la"/><asula kood="6627" nimi="P??tsavere k??la"/><asula kood="7135" nimi="Rutikvere k??la"/><asula kood="7598" nimi="Silmsi k??la"/><asula kood="7895" nimi="S??randu k??la"/><asula kood="8137" nimi="Tamsi k??la"/><asula kood="8803" nimi="Vaali k??la"/><asula kood="9623" nimi="V??ike-Kareda k??la"/><asula kood="9825" nimi="??lej??e k??la"/></vald><vald kood="0565"><asula kood="1286" nimi="Anna k??la"/><asula kood="1570" nimi="Eivere k??la"/><asula kood="3131" nimi="Kirila k??la"/><asula kood="3442" nimi="Korba k??la"/><asula kood="3497" nimi="Kriilev??lja k??la"/><asula kood="5083" nimi="Mustla k??la"/><asula kood="5090" nimi="Mustla-N??mme k??la"/><asula kood="5193" nimi="M??ek??la"/><asula kood="5275" nimi="M??o k??la"/><asula kood="5317" nimi="M??ndi k??la"/><asula kood="5466" nimi="Nurme k??la"/><asula kood="5474" nimi="Nurmsi k??la"/><asula kood="5648" nimi="Ojak??la"/><asula kood="5761" nimi="Otiku k??la"/><asula kood="6214" nimi="Pikak??la"/><asula kood="6377" nimi="Pr????ma k??la"/><asula kood="6405" nimi="Puiatu k??la"/><asula kood="6440" nimi="Purdi k??la"/><asula kood="7428" nimi="Sargvere k??la"/><asula kood="7508" nimi="Seinapalu k??la"/><asula kood="7593" nimi="Sillaotsa k??la"/><asula kood="7863" nimi="Suurpalu k??la"/><asula kood="7889" nimi="S??meru k??la"/><asula kood="8152" nimi="Tarbja k??la"/><asula kood="8935" nimi="Valgma k??la"/><asula kood="9227" nimi="Veskiaru k??la"/><asula kood="9379" nimi="Viraksaare k??la"/><asula kood="9602" nimi="V????bu k??la"/></vald><vald kood="0684"><asula kood="1205" nimi="Allikj??rve k??la"/><asula kood="1653" nimi="Esna k??la"/><asula kood="2421" nimi="Kaaruka k??la"/><asula kood="3019" nimi="Kihme k??la"/><asula kood="3137" nimi="Kirisaare k??la"/><asula kood="3229" nimi="Kodasema k??la"/><asula kood="3417" nimi="Koordi k??la"/><asula kood="5609" nimi="Oeti k??la"/><asula kood="7083" nimi="Roosna-Alliku alevik"/><asula kood="8570" nimi="T??nnapere k??la"/><asula kood="8917" nimi="Valasti k??la"/><asula kood="9689" nimi="Vedruka k??la"/><asula kood="9302" nimi="Viisu k??la"/></vald><vald kood="0835"><asula kood="1359" nimi="Arkma k??la"/><asula kood="2315" nimi="J??ndja k??la"/><asula kood="2445" nimi="Kabala k??la"/><asula kood="2510" nimi="Kahala k??la"/><asula kood="5144" nimi="Karjak??la"/><asula kood="3148" nimi="Kirna k??la"/><asula kood="3364" nimi="Kolu k??la"/><asula kood="3684" nimi="Kurla k??la"/><asula kood="3899" nimi="K??revere k??la"/><asula kood="4153" nimi="Laupa k??la"/><asula kood="4475" nimi="Lokuta k??la"/><asula kood="4873" nimi="Meossaare k??la"/><asula kood="4897" nimi="Metsak??la"/><asula kood="5197" nimi="M??ek??la"/><asula kood="5562" nimi="N??suvere k??la"/><asula kood="5641" nimi="Oisu alevik"/><asula kood="5666" nimi="Ollepa k??la"/><asula kood="5906" nimi="Pala k??la"/><asula kood="6134" nimi="Pibari k??la"/><asula kood="6300" nimi="Poaka k??la"/><asula kood="6505" nimi="P??ikva k??la"/><asula kood="6831" nimi="Rassi k??la"/><asula kood="6863" nimi="Raukla k??la"/><asula kood="6948" nimi="Retla k??la"/><asula kood="6995" nimi="Rikassaare k??la"/><asula kood="7293" nimi="Saareotsa k??la"/><asula kood="7332" nimi="Sagevere k??la"/><asula kood="7935" nimi="S??revere alevik"/><asula kood="8080" nimi="Taikse k??la"/><asula kood="8325" nimi="Tori k??la"/><asula kood="8573" nimi="T??nnassilma k??la"/><asula kood="8596" nimi="T??ri-Alliku k??la"/><asula kood="8595" nimi="T??ri linn"/><asula kood="9336" nimi="Vilita k??la"/><asula kood="9352" nimi="Villevere k??la"/><asula kood="9653" nimi="V??ljaotsa k??la"/><asula kood="9741" nimi="??iamaa k??la"/><asula kood="9762" nimi="??nari k??la"/></vald><vald kood="0937"><asula kood="1042" nimi="Aasuv??lja k??la"/><asula kood="4623" nimi="L????la k??la"/><asula kood="6206" nimi="Piiumetsa k??la"/><asula kood="6940" nimi="Reopalu k??la"/><asula kood="7095" nimi="Roovere k??la"/><asula kood="7254" nimi="R??a k??la"/><asula kood="7452" nimi="Saueaugu k??la"/><asula kood="9425" nimi="Vissuvere k??la"/><asula kood="9656" nimi="V??ljataguse k??la"/><asula kood="9690" nimi="V????tsa alevik"/><asula kood="9828" nimi="??lej??e k??la"/></vald></maakond><maakond kood="0057"><vald kood="0195"><asula kood="1649" nimi="Esivere k??la"/><asula kood="1757" nimi="Hanila k??la"/><asula kood="2784" nimi="Karuse k??la"/><asula kood="2792" nimi="Kasek??la"/><asula kood="2879" nimi="Kause k??la"/><asula kood="3099" nimi="Kinksi k??la"/><asula kood="3159" nimi="Kiska k??la"/><asula kood="3326" nimi="Kokuta k??la"/><asula kood="3552" nimi="Kuke k??la"/><asula kood="3739" nimi="K??era k??la"/><asula kood="3765" nimi="K??msi k??la"/><asula kood="4406" nimi="Linnuse k??la"/><asula kood="4607" nimi="L??o k??la"/><asula kood="4807" nimi="Massu k??la"/><asula kood="5127" nimi="M??isak??la"/><asula kood="5202" nimi="M??ense k??la"/><asula kood="5399" nimi="Nehatu k??la"/><asula kood="5473" nimi="Nurmsi k??la"/><asula kood="5889" nimi="Pajumaa k??la"/><asula kood="6286" nimi="Pivarootsi k??la"/><asula kood="6778" nimi="Rame k??la"/><asula kood="6807" nimi="Rannak??la"/><asula kood="6961" nimi="Ridase k??la"/><asula kood="7379" nimi="Salevere k??la"/><asula kood="8663" nimi="Ullaste k??la"/><asula kood="9141" nimi="Vatla k??la"/><asula kood="9388" nimi="Virtsu alevik"/><asula kood="9478" nimi="Voose k??la"/><asula kood="9742" nimi="??ila k??la"/></vald><vald kood="0342"><asula kood="2266" nimi="J??gisoo k??la"/><asula kood="2593" nimi="Kalju k??la"/><asula kood="2826" nimi="Kastja k??la"/><asula kood="3366" nimi="Koluvere k??la"/><asula kood="3587" nimi="Kullamaa k??la"/><asula kood="3590" nimi="Kullametsa k??la"/><asula kood="4230" nimi="Leila k??la"/><asula kood="4271" nimi="Lemmikk??la"/><asula kood="4361" nimi="Liivi k??la"/><asula kood="5165" nimi="M??rdu k??la"/><asula kood="6599" nimi="P??ri k??la"/><asula kood="7589" nimi="Silla k??la"/><asula kood="8607" nimi="Ubasalu k??la"/><asula kood="9812" nimi="??druma k??la"/></vald><vald kood="0411"><asula kood="1169" nimi="Alak??la"/><asula kood="1369" nimi="Aruk??la"/><asula kood="1936" nimi="H??lvati k??la"/><asula kood="2255" nimi="J??e????re k??la"/><asula kood="2323" nimi="J??rise k??la"/><asula kood="2912" nimi="Keemu k??la"/><asula kood="2946" nimi="Kelu k??la"/><asula kood="3113" nimi="Kirbla k??la"/><asula kood="7782" nimi="Kirikuk??la"/><asula kood="3210" nimi="Kloostri k??la"/><asula kood="3616" nimi="Kunila k??la"/><asula kood="4149" nimi="Laulepa k??la"/><asula kood="4163" nimi="Lautna k??la"/><asula kood="4330" nimi="Lihula linn"/><asula kood="4429" nimi="Liustem??e k??la"/><asula kood="4820" nimi="Matsalu k??la"/><asula kood="4847" nimi="Meelva k??la"/><asula kood="4929" nimi="Metsk??la"/><asula kood="5174" nimi="M??isimaa k??la"/><asula kood="5464" nimi="Nurme k??la"/><asula kood="5845" nimi="Pagasi k??la"/><asula kood="6013" nimi="Parivere k??la"/><asula kood="6055" nimi="Peanse k??la"/><asula kood="6096" nimi="Penij??e k??la"/><asula kood="6131" nimi="Petaaluse k??la"/><asula kood="6302" nimi="Poanse k??la"/><asula kood="6827" nimi="Rannu k??la"/><asula kood="7087" nimi="Rootsi k??la"/><asula kood="7117" nimi="Rumba k??la"/><asula kood="7310" nimi="Saastna k??la"/><asula kood="7511" nimi="Seira k??la"/><asula kood="7519" nimi="Seli k??la"/><asula kood="7749" nimi="Soov??lja k??la"/><asula kood="8401" nimi="Tuhu k??la"/><asula kood="8446" nimi="Tuudi k??la"/><asula kood="8666" nimi="Uluste k??la"/><asula kood="8830" nimi="Vagivere k??la"/><asula kood="8974" nimi="Valuste k??la"/><asula kood="9035" nimi="Vanam??isa k??la"/><asula kood="9499" nimi="V??hma k??la"/><asula kood="9528" nimi="V??igaste k??la"/></vald><vald kood="0436"><asula kood="1210" nimi="Allikmaa k??la"/><asula kood="1447" nimi="Auaste k??la"/><asula kood="2084" nimi="Ingk??la"/><asula kood="2126" nimi="Jaakna k??la"/><asula kood="2166" nimi="Jalukse k??la"/><asula kood="2479" nimi="Kadarpiku k??la"/><asula kood="2904" nimi="Kedre k??la"/><asula kood="2906" nimi="Keedika k??la"/><asula kood="3135" nimi="Kirim??e k??la"/><asula kood="3247" nimi="Koela k??la"/><asula kood="3539" nimi="Kuij??e k??la"/><asula kood="3889" nimi="K??rbla k??la"/><asula kood="4178" nimi="Leedik??la"/><asula kood="4400" nimi="Linnam??e k??la"/><asula kood="4553" nimi="Luigu k??la"/><asula kood="5143" nimi="M??isak??la"/><asula kood="5407" nimi="Nigula k??la"/><asula kood="5413" nimi="Nihka k??la"/><asula kood="5415" nimi="Niibi k??la"/><asula kood="5737" nimi="Oru k??la"/><asula kood="5926" nimi="Palivere alevik"/><asula kood="6191" nimi="Piirsalu k??la"/><asula kood="6586" nimi="P??lli k??la"/><asula kood="7011" nimi="Risti alevik"/><asula kood="7183" nimi="R??uma k??la"/><asula kood="7369" nimi="Salaj??e k??la"/><asula kood="7465" nimi="Saunja k??la"/><asula kood="7534" nimi="Seljak??la"/><asula kood="7709" nimi="Soolu k??la"/><asula kood="8025" nimi="Taebla alevik"/><asula kood="8058" nimi="Tagavere k??la"/><asula kood="8434" nimi="Turvalepa k??la"/><asula kood="8776" nimi="Uugla k??la"/><asula kood="9156" nimi="Vedra k??la"/><asula kood="9254" nimi="Vidruka k??la"/><asula kood="9572" nimi="V??ntk??la"/><asula kood="9686" nimi="V????nla k??la"/></vald><vald kood="0452"><asula kood="1209" nimi="Allikotsa k??la"/><asula kood="1546" nimi="Ehmja k??la"/><asula kood="1600" nimi="Enivere k??la"/><asula kood="2246" nimi="J??esse k??la"/><asula kood="2399" nimi="Kaare k??la"/><asula kood="2426" nimi="Kaasiku k??la"/><asula kood="2446" nimi="Kabeli k??la"/><asula kood="2787" nimi="Kasari k??la"/><asula kood="2958" nimi="Keravere k??la"/><asula kood="2983" nimi="Keskk??la"/><asula kood="2984" nimi="Keskvere k??la"/><asula kood="2991" nimi="Kesu k??la"/><asula kood="3147" nimi="Kirna k??la"/><asula kood="3321" nimi="Kokre k??la"/><asula kood="3605" nimi="Kuluse k??la"/><asula kood="3660" nimi="Kurevere k??la"/><asula kood="4068" nimi="Laik??la"/><asula kood="4350" nimi="Liivak??la"/><asula kood="4796" nimi="Martna k??la"/><asula kood="5259" nimi="M??nniku k??la"/><asula kood="5419" nimi="Niinja k??la"/><asula kood="5526" nimi="N??mme k??la"/><asula kood="5626" nimi="Ohtla k??la"/><asula kood="5693" nimi="Oonga k??la"/><asula kood="6464" nimi="Putkaste k??la"/><asula kood="6805" nimi="Rannaj??e k??la"/><asula kood="7178" nimi="R??ude k??la"/><asula kood="7682" nimi="Soo-otsa k??la"/><asula kood="7832" nimi="Suure-L??htru k??la"/><asula kood="8111" nimi="Tammiku k??la"/><asula kood="8405" nimi="Tuka k??la"/><asula kood="8785" nimi="Uusk??la"/><asula kood="9017" nimi="Vanak??la"/><asula kood="4632" nimi="V??ike-L??htru k??la"/></vald><vald kood="0520"><asula kood="1469" nimi="Aulepa k??la"/><asula kood="1505" nimi="Dirhami k??la"/><asula kood="1556" nimi="Einbi k??la"/><asula kood="1571" nimi="Elbiku k??la "/><asula kood="1760" nimi="Hara k??la"/><asula kood="1889" nimi="Hosby k??la"/><asula kood="1964" nimi="H??bringi k??la"/><asula kood="3514" nimi="Kudani k??la"/><asula kood="5743" nimi="Osmussaare k??la"/><asula kood="6029" nimi="Paslepa k??la"/><asula kood="6669" nimi="P??rksi k??la"/><asula kood="6968" nimi="Riguldi k??la"/><asula kood="7077" nimi="Rooslepa k??la"/><asula kood="7284" nimi="Saare k??la"/><asula kood="7760" nimi="Spithami k??la"/><asula kood="7817" nimi="Sutlepa k??la"/><asula kood="7829" nimi="Suur-N??mmk??la"/><asula kood="8074" nimi="Tahu k??la"/><asula kood="8187" nimi="Telise k??la"/><asula kood="8409" nimi="Tuksi k??la"/><asula kood="9011" nimi="Vanak??la"/><asula kood="5523" nimi="V??ike-N??mmk??la"/><asula kood="9803" nimi="??sterby k??la"/></vald><vald kood="0531"><asula kood="1852" nimi="Hindaste k??la"/><asula kood="5513" nimi="N??mmemaa k??la"/><asula kood="5543" nimi="N??va k??la"/><asula kood="6109" nimi="Perak??la"/><asula kood="6808" nimi="Rannak??la"/><asula kood="8437" nimi="Tusari k??la"/><asula kood="8890" nimi="Vaisi k??la"/><asula kood="9083" nimi="Variku k??la"/></vald><vald kood="0674"><asula kood="1017" nimi="Aamse k??la"/><asula kood="1201" nimi="Allika k??la"/><asula kood="1251" nimi="Ammuta k??la"/><asula kood="1592" nimi="Emmuvere k??la"/><asula kood="1624" nimi="Erja k??la"/><asula kood="1658" nimi="Espre k??la"/><asula kood="1711" nimi="Haeska k??la"/><asula kood="1824" nimi="Herjava k??la"/><asula kood="1875" nimi="Hobulaiu k??la"/><asula kood="2285" nimi="J????dre k??la"/><asula kood="2466" nimi="Kabrametsa k??la"/><asula kood="2472" nimi="Kadaka k??la"/><asula kood="2497" nimi="Kaevere k??la"/><asula kood="3027" nimi="Kiideva k??la"/><asula kood="3090" nimi="Kiltsi k??la"/><asula kood="3171" nimi="Kivik??la"/><asula kood="3276" nimi="Koheri k??la"/><asula kood="3281" nimi="Koidu k??la"/><asula kood="3341" nimi="Kolila k??la"/><asula kood="3361" nimi="Kolu k??la"/><asula kood="3849" nimi="K??pla k??la"/><asula kood="4063" nimi="Laheva k??la"/><asula kood="4102" nimi="Lannuste k??la"/><asula kood="4351" nimi="Liivak??la"/><asula kood="4426" nimi="Litu k??la"/><asula kood="4592" nimi="L??be k??la"/><asula kood="4883" nimi="Metsak??la"/><asula kood="5186" nimi="M??ek??la"/><asula kood="5216" nimi="M??gari k??la"/><asula kood="5527" nimi="N??mme k??la"/><asula kood="5971" nimi="Panga k??la"/><asula kood="5989" nimi="Paralepa alevik"/><asula kood="6959" nimi="Parila k??la"/><asula kood="6403" nimi="Puiatu k??la"/><asula kood="6413" nimi="Puise k??la"/><asula kood="6462" nimi="Pusku k??la"/><asula kood="6496" nimi="P??gari-Sassi k??la"/><asula kood="7029" nimi="Rohense k??la"/><asula kood="7036" nimi="Rohuk??la"/><asula kood="7120" nimi="Rummu k??la"/><asula kood="7275" nimi="Saanika k??la"/><asula kood="7283" nimi="Saardu k??la"/><asula kood="7540" nimi="Sepak??la"/><asula kood="7606" nimi="Sinalepa k??la"/><asula kood="1119" nimi="Suure-Ahli k??la"/><asula kood="8116" nimi="Tammiku k??la"/><asula kood="8321" nimi="Tanska k??la"/><asula kood="8465" nimi="Tuuru k??la"/><asula kood="8690" nimi="Uneste k??la"/><asula kood="8769" nimi="Uuem??isa alevik"/><asula kood="8768" nimi="Uuem??isa k??la"/><asula kood="8929" nimi="Valgev??lja k??la"/><asula kood="9091" nimi="Varni k??la"/><asula kood="9343" nimi="Vilkla k??la"/><asula kood="9568" nimi="V??nnu k??la"/><asula kood="9616" nimi="V??ike-Ahli k??la"/><asula kood="9673" nimi="V??tse k??la"/><asula kood="9853" nimi="??sse k??la"/></vald><vald kood="0907"><asula kood="1493" nimi="Borrby k??la"/><asula kood="1502" nimi="Diby k??la"/><asula kood="1662" nimi="F??llarna k??la"/><asula kood="1670" nimi="F??rby k??la"/><asula kood="1892" nimi="Hosby k??la"/><asula kood="1900" nimi="Hullo k??la"/><asula kood="2981" nimi="Kersleti k??la"/><asula kood="5453" nimi="Norrby k??la"/><asula kood="7124" nimi="Rumpo k??la"/><asula kood="7205" nimi="R??lby k??la"/><asula kood="7502" nimi="Saxby k??la"/><asula kood="7845" nimi="Suurem??isa k??la"/><asula kood="7875" nimi="Sviby k??la"/><asula kood="7971" nimi="S??derby k??la"/></vald></maakond><maakond kood="0059"><vald kood="0190"><asula kood="1032" nimi="Aaspere k??la"/><asula kood="1035" nimi="Aasu k??la"/><asula kood="1051" nimi="Aaviku k??la"/><asula kood="1463" nimi="Auk??la"/><asula kood="1661" nimi="Essu k??la"/><asula kood="1739" nimi="Haljala alevik"/><asula kood="1986" nimi="Idavere k??la"/><asula kood="2664" nimi="Kandle k??la"/><asula kood="2896" nimi="Kavastu k??la"/><asula kood="3161" nimi="Kisuvere k??la"/><asula kood="3754" nimi="K??ldu k??la"/><asula kood="3918" nimi="K??rmu k??la"/><asula kood="4331" nimi="Lihul??pe k??la"/><asula kood="4337" nimi="Liiguste k??la"/><asula kood="6093" nimi="Pehka k??la"/><asula kood="6493" nimi="P??druse k??la"/><asula kood="7468" nimi="Sauste k??la"/><asula kood="8167" nimi="Tatruse k??la"/><asula kood="9024" nimi="Vanam??isa k??la"/><asula kood="2779" nimi="Varangu k??la"/><asula kood="9552" nimi="V??le k??la"/></vald><vald kood="0272"><asula kood="1246" nimi="Ama k??la"/><asula kood="1334" nimi="Arbavere k??la"/><asula kood="1897" nimi="Hulja alevik"/><asula kood="1924" nimi="H??beda k??la"/><asula kood="1947" nimi="H??rjadi k??la"/><asula kood="2245" nimi="J??epere k??la"/><asula kood="2253" nimi="J??etaguse k??la"/><asula kood="2476" nimi="Kadapiku k??la"/><asula kood="2490" nimi="Kadrina alevik"/><asula kood="2614" nimi="Kallukse k??la"/><asula kood="3017" nimi="Kihlevere k??la"/><asula kood="3074" nimi="Kiku k??la"/><asula kood="3823" nimi="K??rvek??la"/><asula kood="4106" nimi="Lante k??la"/><asula kood="4227" nimi="Leikude k??la"/><asula kood="4498" nimi="Loobu k??la"/><asula kood="4641" nimi="L??sna k??la"/><asula kood="5147" nimi="M??ndavere k??la"/><asula kood="5276" nimi="M??o k??la"/><asula kood="5395" nimi="Neeruti k??la"/><asula kood="5620" nimi="Ohepalu k??la"/><asula kood="5741" nimi="Orutaguse k??la"/><asula kood="6004" nimi="Pariisi k??la"/><asula kood="6507" nimi="P??ima k??la"/><asula kood="6953" nimi="Ridak??la"/><asula kood="7164" nimi="R??meda k??la"/><asula kood="7376" nimi="Salda k??la"/><asula kood="7456" nimi="Saukse k??la"/><asula kood="8254" nimi="Tirbiku k??la"/><asula kood="8278" nimi="Tokolopi k??la"/><asula kood="8622" nimi="Udriku k??la"/><asula kood="8651" nimi="Uku k??la"/><asula kood="8689" nimi="Undla k??la"/><asula kood="8862" nimi="Vaiatu k??la"/><asula kood="9043" nimi="Vandu k??la"/><asula kood="9312" nimi="Viitna k??la"/><asula kood="9449" nimi="Vohnja k??la"/><asula kood="9490" nimi="V??duvere k??la"/><asula kood="9534" nimi="V??ipere k??la"/></vald><vald kood="0381"><asula kood="1193" nimi="Alekvere k??la"/><asula kood="1370" nimi="Arukse k??la"/><asula kood="2036" nimi="Ilistvere k??la"/><asula kood="2424" nimi="Kaasiksaare k??la"/><asula kood="2941" nimi="Kellavere k??la"/><asula kood="4035" nimi="Laekvere alevik"/><asula kood="4589" nimi="Luusika k??la"/><asula kood="4978" nimi="Moora k??la"/><asula kood="5105" nimi="Muuga k??la"/><asula kood="5794" nimi="Paasvere k??la"/><asula kood="5814" nimi="Padu k??la"/><asula kood="6729" nimi="Rahkla k??la"/><asula kood="6768" nimi="Rajak??la"/><asula kood="7034" nimi="Rohu k??la"/><asula kood="7401" nimi="Salutaguse k??la"/><asula kood="7630" nimi="Sirevere k??la"/><asula kood="7748" nimi="Sootaguse k??la"/><asula kood="9118" nimi="Vassivere k??la"/><asula kood="9204" nimi="Venevere k??la"/></vald><vald kood="0660"><asula kood="1309" nimi="Ao k??la"/><asula kood="1529" nimi="Edru k??la"/><asula kood="1594" nimi="Emum??e k??la"/><asula kood="2371" nimi="J????tma k??la"/><asula kood="2437" nimi="Kaavere k??la"/><asula kood="2480" nimi="Kadik??la"/><asula kood="2635" nimi="Kamariku k??la"/><asula kood="2934" nimi="Kellam??e k??la"/><asula kood="3162" nimi="Kitsemetsa k??la"/><asula kood="3297" nimi="Koila k??la"/><asula kood="3367" nimi="Koluvere k??la"/><asula kood="3783" nimi="K??psta k??la"/><asula kood="4065" nimi="Lahu k??la"/><asula kood="4091" nimi="Lammask??la"/><asula kood="4125" nimi="Lasinurme k??la"/><asula kood="4339" nimi="Liigvalla k??la"/><asula kood="5132" nimi="M??isamaa k??la"/><asula kood="5235" nimi="M??iste k??la"/><asula kood="5529" nimi="N??mmk??la"/><asula kood="5661" nimi="Olju k??la"/><asula kood="5805" nimi="Padak??la"/><asula kood="6158" nimi="Piibe k??la"/><asula kood="6775" nimi="Rakke alevik"/><asula kood="7202" nimi="R??itsvere k??la"/><asula kood="7385" nimi="Salla k??la"/><asula kood="7746" nimi="Sootaguse k??la"/><asula kood="7831" nimi="Suure-Rakke k??la"/><asula kood="8115" nimi="Tammiku k??la"/><asula kood="9347" nimi="Villakvere k??la"/><asula kood="9647" nimi="V??ike-Rakke k??la"/><asula kood="9648" nimi="V??ike-Tammiku k??la"/></vald><vald kood="0662"><asula kood="1362" nimi="Arkna k??la"/><asula kood="1536" nimi="Eesk??la"/><asula kood="2332" nimi="J??rni k??la"/><asula kood="2741" nimi="Karitsa k??la"/><asula kood="2744" nimi="Kariv??rava k??la"/><asula kood="2781" nimi="Karunga k??la"/><asula kood="3202" nimi="Kloodi k??la"/><asula kood="3582" nimi="Kullaaru k??la"/><asula kood="3790" nimi="K??rgem??e k??la"/><asula kood="4123" nimi="Lasila k??la"/><asula kood="4294" nimi="Lepna alevik"/><asula kood="4309" nimi="Levala k??la"/><asula kood="5182" nimi="M??dapea k??la"/><asula kood="5796" nimi="Paatna k??la"/><asula kood="6567" nimi="P??ide k??la"/><asula kood="8001" nimi="Taaravainu k??la"/><asula kood="8261" nimi="Tobia k??la"/><asula kood="8520" nimi="T??rma k??la"/><asula kood="8525" nimi="T??rrem??e k??la"/><asula kood="9196" nimi="Veltsi k??la"/></vald><vald kood="0702"><asula kood="1043" nimi="Aasuv??lja k??la"/><asula kood="2689" nimi="Kantk??la"/><asula kood="3809" nimi="K??rma k??la"/><asula kood="4166" nimi="Lavi k??la"/><asula kood="4948" nimi="Miila k??la"/><asula kood="5117" nimi="M??edaka k??la"/><asula kood="5267" nimi="M??nnikv??lja k??la"/><asula kood="5465" nimi="Nurkse k??la"/><asula kood="5521" nimi="N??mmise k??la"/><asula kood="6535" nimi="P??lula k??la"/><asula kood="7325" nimi="Sae k??la"/><asula kood="8661" nimi="Uljaste k??la"/><asula kood="8665" nimi="Ulvi k??la"/><asula kood="9396" nimi="Viru-Kabala k??la"/></vald><vald kood="0770"><asula kood="1242" nimi="Aluvere k??la"/><asula kood="1259" nimi="Andja k??la"/><asula kood="1345" nimi="Aresi k??la"/><asula kood="2373" nimi="J????tma k??la"/><asula kood="2405" nimi="Kaarli k??la"/><asula kood="2853" nimi="Katela k??la"/><asula kood="2851" nimi="Katku k??la"/><asula kood="3261" nimi="Kohala-Eesk??la"/><asula kood="3263" nimi="Kohala k??la"/><asula kood="3432" nimi="Koov??lja k??la"/><asula kood="5055" nimi="Muru k??la"/><asula kood="5478" nimi="Nurme k??la"/><asula kood="5554" nimi="N??pi alevik"/><asula kood="5979" nimi="Papiaru k??la"/><asula kood="6726" nimi="Rahkla k??la"/><asula kood="6850" nimi="Raudlepa k??la"/><asula kood="6860" nimi="Raudvere k??la"/><asula kood="7058" nimi="Roodev??lja k??la"/><asula kood="7199" nimi="R??gavere k??la"/><asula kood="7684" nimi="Sooaluse k??la"/><asula kood="7892" nimi="S??meru alevik"/><asula kood="7927" nimi="S??mi k??la"/><asula kood="7925" nimi="S??mi-Tagak??la"/><asula kood="8304" nimi="Toomla k??la"/><asula kood="8610" nimi="Ubja k??la"/><asula kood="8637" nimi="Uhtna alevik"/><asula kood="8740" nimi="Ussim??e k??la"/><asula kood="8822" nimi="Vaek??la"/><asula kood="9099" nimi="Varudi-Altk??la"/><asula kood="9098" nimi="Varudi-Vanak??la"/><asula kood="9495" nimi="V??hma k??la"/></vald><vald kood="0786"><asula kood="1048" nimi="Aavere k??la"/><asula kood="1235" nimi="Alupere k??la"/><asula kood="1315" nimi="Araski k??la"/><asula kood="1410" nimi="Assamalla k??la"/><asula kood="2334" nimi="J??rsi k??la"/><asula kood="2345" nimi="J??rvaj??e k??la"/><asula kood="2482" nimi="Kadapiku k??la"/><asula kood="2500" nimi="Kaeva k??la"/><asula kood="2970" nimi="Kerguta k??la"/><asula kood="3288" nimi="Koiduk??la"/><asula kood="3438" nimi="Koplitaguse k??la"/><asula kood="3531" nimi="Kuie k??la"/><asula kood="3592" nimi="Kullenga k??la"/><asula kood="3694" nimi="Kursi k??la"/><asula kood="4273" nimi="Lemmk??la"/><asula kood="4470" nimi="Loksa k??la"/><asula kood="4920" nimi="Metskaevu k??la"/><asula kood="5352" nimi="Naistev??lja k??la"/><asula kood="6204" nimi="Piisupi k??la"/><asula kood="6333" nimi="Porkuni k??la"/><asula kood="6491" nimi="P??drangu k??la"/><asula kood="7476" nimi="Sauv??lja k??la"/><asula kood="7481" nimi="Savalduma k??la"/><asula kood="7956" nimi="S????se alevik"/><asula kood="8130" nimi="Tamsalu linn"/><asula kood="8604" nimi="T??rje k??la"/><asula kood="8754" nimi="Uudek??la"/><asula kood="8820" nimi="Vadik??la"/><asula kood="8903" nimi="Vajangu k??la"/><asula kood="9429" nimi="Vistla k??la"/><asula kood="9505" nimi="V??hmetu k??la"/><asula kood="9506" nimi="V??hmuta k??la"/></vald><vald kood="0790"><asula kood="2068" nimi="Imastu k??la"/><asula kood="2199" nimi="Jootme k??la"/><asula kood="2318" nimi="J??neda k??la"/><asula kood="2762" nimi="Karkuse k??la"/><asula kood="3702" nimi="Kuru k??la"/><asula kood="3822" nimi="K??rvek??la"/><asula kood="4217" nimi="Lehtse alevik"/><asula kood="4403" nimi="Linnape k??la"/><asula kood="4473" nimi="Loksu k??la"/><asula kood="4474" nimi="Lokuta k??la"/><asula kood="4638" nimi="L??pi k??la"/><asula kood="4644" nimi="L??ste k??la"/><asula kood="4963" nimi="Moe k??la"/><asula kood="5525" nimi="N??mmk??la"/><asula kood="5551" nimi="N??o k??la"/><asula kood="6037" nimi="Patika k??la"/><asula kood="6177" nimi="Piilu k??la"/><asula kood="6374" nimi="Pruuna k??la"/><asula kood="6703" nimi="Rabasaare k??la"/><asula kood="6847" nimi="Raudla k??la"/><asula kood="7198" nimi="R??gavere k??la"/><asula kood="7221" nimi="R??sna k??la"/><asula kood="7343" nimi="Saiakopli k??la"/><asula kood="7358" nimi="Saksi k??la"/><asula kood="8140" nimi="Tapa linn"/><asula kood="8549" nimi="T????rak??rve k??la"/><asula kood="8836" nimi="Vahakulmu k??la"/></vald><vald kood="0887"><asula kood="1040" nimi="Aasumetsa k??la"/><asula kood="1073" nimi="Adaka k??la"/><asula kood="1218" nimi="Altja k??la"/><asula kood="1255" nimi="Andi k??la"/><asula kood="1294" nimi="Annikvere k??la"/><asula kood="1562" nimi="Eisma k??la"/><asula kood="1637" nimi="Eru k??la"/><asula kood="1723" nimi="Haili k??la"/><asula kood="2059" nimi="Ilum??e k??la"/><asula kood="2191" nimi="Joandu k??la"/><asula kood="2558" nimi="Kakuv??lja k??la"/><asula kood="2715" nimi="Karepa k??la"/><asula kood="2774" nimi="Karula k??la"/><asula kood="3173" nimi="Kiva k??la"/><asula kood="3345" nimi="Koljaku k??la"/><asula kood="3401" nimi="Koolim??e k??la"/><asula kood="3449" nimi="Korjuse k??la"/><asula kood="3473" nimi="Kosta k??la"/><asula kood="3934" nimi="K??smu k??la"/><asula kood="4052" nimi="Lahe k??la"/><asula kood="4151" nimi="Lauli k??la"/><asula kood="4437" nimi="Lobi k??la"/><asula kood="4905" nimi="Metsanurga k??la"/><asula kood="4918" nimi="Metsiku k??la"/><asula kood="5009" nimi="Muike k??la"/><asula kood="5091" nimi="Mustoja k??la"/><asula kood="5364" nimi="Natturi k??la"/><asula kood="5442" nimi="Noonu k??la"/><asula kood="5575" nimi="Oandu k??la"/><asula kood="5786" nimi="Paasi k??la"/><asula kood="5899" nimi="Pajuveski k??la"/><asula kood="5936" nimi="Palmse k??la"/><asula kood="6068" nimi="Pedassaare k??la"/><asula kood="6148" nimi="Pihlaspea k??la"/><asula kood="7138" nimi="Rutja k??la"/><asula kood="7329" nimi="Sagadi k??la"/><asula kood="7366" nimi="Sakussaare k??la"/><asula kood="7374" nimi="Salatse k??la"/><asula kood="8195" nimi="Tepelv??lja k??la"/><asula kood="8178" nimi="Tidriku k??la"/><asula kood="8222" nimi="Tiigi k??la"/><asula kood="8293" nimi="Toolse k??la"/><asula kood="8543" nimi="T??ugu k??la"/><asula kood="8787" nimi="Uusk??la"/><asula kood="8888" nimi="Vainupea k??la"/><asula kood="9139" nimi="Vatku k??la"/><asula kood="9213" nimi="Vergi k??la"/><asula kood="9270" nimi="Vihula k??la"/><asula kood="9321" nimi="Vila k??la"/><asula kood="9350" nimi="Villandi k??la"/><asula kood="9498" nimi="V??hma k??la"/><asula kood="9592" nimi="V??su alevik"/><asula kood="9593" nimi="V??supere k??la"/></vald><vald kood="0900"><asula kood="1182" nimi="Alavere k??la"/><asula kood="1203" nimi="Allika k??la"/><asula kood="1275" nimi="Anguse k??la"/><asula kood="1331" nimi="Aravuse k??la"/><asula kood="1372" nimi="Aruk??la"/><asula kood="1395" nimi="Aruv??lja k??la"/><asula kood="2090" nimi="Inju k??la"/><asula kood="2484" nimi="Kadila k??la"/><asula kood="2555" nimi="Kakum??e k??la"/><asula kood="2679" nimi="Kannastiku k??la"/><asula kood="2760" nimi="Karkuse k??la"/><asula kood="2872" nimi="Kaukvere k??la"/><asula kood="2919" nimi="Kehala k??la"/><asula kood="3252" nimi="Koeravere k??la"/><asula kood="3577" nimi="Kulina k??la"/><asula kood="3994" nimi="K??ti k??la"/><asula kood="4293" nimi="Lepiku k??la"/><asula kood="4634" nimi="L??htse k??la"/><asula kood="5114" nimi="M??driku k??la"/><asula kood="5212" nimi="M??etaguse k??la"/><asula kood="5471" nimi="Nurmetu k??la"/><asula kood="5585" nimi="Obja k??la"/><asula kood="5896" nimi="Pajusti alevik"/><asula kood="5923" nimi="Palasi k??la"/><asula kood="6182" nimi="Piira k??la"/><asula kood="6416" nimi="Puka k??la"/><asula kood="6829" nimi="Rasivere k??la"/><asula kood="7012" nimi="Ristik??la"/><asula kood="7028" nimi="Roela alevik"/><asula kood="7262" nimi="R??nga k??la"/><asula kood="7278" nimi="Saara k??la"/><asula kood="7733" nimi="Soonuka k??la"/><asula kood="7777" nimi="Suigu k??la"/><asula kood="8108" nimi="Tammiku k??la"/><asula kood="8390" nimi="Tudu alevik"/><asula kood="9009" nimi="Vana-Vinni k??la"/><asula kood="9153" nimi="Veadla k??la"/><asula kood="9245" nimi="Vetiku k??la"/><asula kood="9375" nimi="Vinni alevik"/><asula kood="9394" nimi="Viru-Jaagupi alevik"/><asula kood="9467" nimi="Voore k??la"/><asula kood="9508" nimi="V??hu k??la"/></vald><vald kood="0902"><asula kood="1037" nimi="Aasukalda k??la"/><asula kood="2019" nimi="Iila k??la"/><asula kood="2447" nimi="Kabeli k??la"/><asula kood="2583" nimi="Kalik??la"/><asula kood="2675" nimi="Kanguristi k??la"/><asula kood="3179" nimi="Kivik??la"/><asula kood="3295" nimi="Koila k??la"/><asula kood="3610" nimi="Kunda k??la"/><asula kood="3688" nimi="Kurna k??la"/><asula kood="3709" nimi="Kutsala k??la"/><asula kood="3725" nimi="Kuura k??la"/><asula kood="4305" nimi="Letipea k??la"/><asula kood="4408" nimi="Linnuse k??la"/><asula kood="4736" nimi="Mahu k??la"/><asula kood="4755" nimi="Malla k??la"/><asula kood="4786" nimi="Marinu k??la"/><asula kood="4926" nimi="Metsav??lja k??la"/><asula kood="5456" nimi="Nugeri k??la"/><asula kood="5651" nimi="Ojak??la"/><asula kood="5791" nimi="Paask??la"/><asula kood="5802" nimi="Pada-Aruk??la"/><asula kood="5804" nimi="Pada k??la"/><asula kood="6219" nimi="Pikaristi k??la"/><asula kood="6612" nimi="P??rna k??la"/><asula kood="7407" nimi="Samma k??la"/><asula kood="7530" nimi="Selja k??la"/><asula kood="7557" nimi="Siberi k??la"/><asula kood="7602" nimi="Simunam??e k??la"/><asula kood="8303" nimi="Toomika k??la"/><asula kood="8602" nimi="T????kri k??la"/><asula kood="8704" nimi="Unukse k??la"/><asula kood="9096" nimi="Varudi k??la"/><asula kood="9121" nimi="Vasta k??la"/><asula kood="9351" nimi="Villavere k??la"/><asula kood="9399" nimi="Viru-Nigula alevik"/><asula kood="9578" nimi="V??rkla k??la"/></vald><vald kood="0926"><asula kood="1047" nimi="Aavere k??la"/><asula kood="1069" nimi="Aburi k??la"/><asula kood="1476" nimi="Avanduse k??la"/><asula kood="1484" nimi="Avispea k??la"/><asula kood="1521" nimi="Ebavere k??la"/><asula kood="1559" nimi="Eipri k??la"/><asula kood="1866" nimi="Hirla k??la"/><asula kood="2080" nimi="Imukvere k??la"/><asula kood="3092" nimi="Kiltsi alevik"/><asula kood="3410" nimi="Koonu k??la"/><asula kood="3692" nimi="Kurtna k??la"/><asula kood="3878" nimi="K??nnuk??la"/><asula kood="3924" nimi="K??rsa k??la"/><asula kood="3932" nimi="K??ru k??la"/><asula kood="4356" nimi="Liivak??la"/><asula kood="5295" nimi="M????ri k??la"/><asula kood="5320" nimi="M????riku k??la"/><asula kood="5333" nimi="Nadalama k??la"/><asula kood="5508" nimi="N??mme k??la"/><asula kood="5716" nimi="Orguse k??la"/><asula kood="5970" nimi="Pandivere k??la"/><asula kood="6230" nimi="Pikevere k??la"/><asula kood="6382" nimi="Pudivere k??la"/><asula kood="6716" nimi="Raek??la"/><asula kood="6756" nimi="Raigu k??la"/><asula kood="6836" nimi="Rastla k??la"/><asula kood="7412" nimi="Sandimetsa k??la"/><asula kood="7603" nimi="Simuna alevik"/><asula kood="8348" nimi="Triigi k??la"/><asula kood="8770" nimi="Uuem??isa k??la"/><asula kood="9048" nimi="Vao k??la"/><asula kood="9056" nimi="Varangu k??la"/><asula kood="9485" nimi="Vorsti k??la"/><asula kood="9549" nimi="V??ivere k??la"/><asula kood="9628" nimi="V??ike-Maarja alevik"/><asula kood="9777" nimi="??ntu k??la"/><asula kood="9783" nimi="??rina k??la"/></vald></maakond><maakond kood="0065"><vald kood="0117"><asula kood="1116" nimi="Ahja alevik"/><asula kood="1156" nimi="Akste k??la"/><asula kood="1980" nimi="Ibaste k??la"/><asula kood="3469" nimi="Kosova k??la"/><asula kood="3923" nimi="K??rsa k??la"/><asula kood="4468" nimi="Loko k??la"/><asula kood="5061" nimi="Mustakurmu k??la"/><asula kood="5170" nimi="M??tsk??la"/><asula kood="9023" nimi="Vanam??isa k??la"/></vald><vald kood="0285"><asula kood="1620" nimi="Erastvere k??la"/><asula kood="1799" nimi="Heisri k??la"/><asula kood="1857" nimi="Hino k??la"/><asula kood="1914" nimi="Hurmi k??la"/><asula kood="2259" nimi="J??gehara k??la"/><asula kood="2277" nimi="J??ksi k??la"/><asula kood="2387" nimi="Kaagna k??la"/><asula kood="2392" nimi="Kaagvere k??la"/><asula kood="2667" nimi="Kanepi alevik"/><asula kood="2769" nimi="Karste k??la"/><asula kood="3280" nimi="Koigera k??la"/><asula kood="3415" nimi="Kooraste k??la"/><asula kood="4156" nimi="Lauri k??la"/><asula kood="4730" nimi="Magari k??la"/><asula kood="5557" nimi="N??rap???? k??la"/><asula kood="6089" nimi="Peetrim??isa k??la"/><asula kood="6163" nimi="Piigandi k??la"/><asula kood="6520" nimi="P??lgaste k??la"/><asula kood="6889" nimi="Rebaste k??la"/><asula kood="7696" nimi="Soodoma k??la"/><asula kood="7897" nimi="S??reste k??la"/><asula kood="9066" nimi="Varbuse k??la"/></vald><vald kood="0354"><asula kood="1960" nimi="H????taru k??la"/><asula kood="2007" nimi="Ihamaru k??la"/><asula kood="2707" nimi="Karaski k??la"/><asula kood="2727" nimi="Karilatsi k??la"/><asula kood="3505" nimi="Krootuse k??la"/><asula kood="5959" nimi="Palutaja k??la"/><asula kood="6167" nimi="Piigaste k??la"/><asula kood="6354" nimi="Prangli k??la"/><asula kood="8455" nimi="Tuulem??e k??la"/><asula kood="8469" nimi="T??du k??la"/><asula kood="9229" nimi="Veski k??la"/><asula kood="9472" nimi="Voorepalu k??la"/></vald><vald kood="0385"><asula kood="1844" nimi="Himma k??la"/><asula kood="2197" nimi="Joosu k??la"/><asula kood="4051" nimi="Lahe k??la"/><asula kood="5059" nimi="Mustaj??e k??la"/><asula kood="5355" nimi="Naruski k??la"/><asula kood="6347" nimi="Pragi k??la"/><asula kood="7071" nimi="Roosi k??la"/><asula kood="7855" nimi="Suurk??la"/><asula kood="8243" nimi="Tilsi k??la"/><asula kood="8989" nimi="Vana-Koiola k??la"/><asula kood="9072" nimi="Vardja k??la"/></vald><vald kood="0465"><asula kood="1453" nimi="Audjassaare k??la"/><asula kood="1489" nimi="Beresje k??la"/><asula kood="2003" nimi="Igrise k??la"/><asula kood="2362" nimi="J??rvep???? k??la"/><asula kood="2512" nimi="Kahkva k??la"/><asula kood="2736" nimi="Karisilla k??la"/><asula kood="4114" nimi="Laossina k??la"/><asula kood="4692" nimi="L????bnitsa k??la"/><asula kood="4951" nimi="Mikitam??e k??la"/><asula kood="5422" nimi="Niitsiku k??la"/><asula kood="6474" nimi="Puugnitsa k??la"/><asula kood="7170" nimi="R??sna k??la"/><asula kood="7250" nimi="R????solaane k??la"/><asula kood="7523" nimi="Selise k??la"/><asula kood="8300" nimi="Toomasm??e k??la"/><asula kood="8737" nimi="Usinitsa k??la"/><asula kood="9078" nimi="Varesm??e k??la"/><asula kood="9607" nimi="V????psu k??la"/></vald><vald kood="0473"><asula kood="2142" nimi="Jaanim??isa k??la"/><asula kood="2419" nimi="Kaaru k??la"/><asula kood="2471" nimi="Kadaja k??la"/><asula kood="2654" nimi="Kanassaare k??la"/><asula kood="2831" nimi="Kastmekoja k??la"/><asula kood="2869" nimi="Kauksi k??la"/><asula kood="4062" nimi="Laho k??la"/><asula kood="4986" nimi="Mooste alevik"/><asula kood="6825" nimi="Rasina k??la"/><asula kood="7501" nimi="Savim??e k??la"/><asula kood="7858" nimi="Suurmetsa k??la"/><asula kood="7918" nimi="S??kna k??la"/><asula kood="7964" nimi="S????ssaare k??la"/><asula kood="8198" nimi="Terepi k??la"/><asula kood="9300" nimi="Viisli k??la"/></vald><vald kood="0547"><asula kood="1755" nimi="Hanikase k??la"/><asula kood="2172" nimi="Jantra k??la"/><asula kood="2514" nimi="Kahkva k??la"/><asula kood="2559" nimi="Kakusuu k??la"/><asula kood="2646" nimi="Kamnitsa k??la"/><asula kood="3199" nimi="Kliima k??la"/><asula kood="3446" nimi="Korg??m??isa k??la"/><asula kood="3750" nimi="K??ivsaare k??la"/><asula kood="3755" nimi="K??lik??la"/><asula kood="3838" nimi="K??vera k??la"/><asula kood="4286" nimi="Lepassaare k??la"/><asula kood="4348" nimi="Liinam??e k??la"/><asula kood="4594" nimi="Luuska k??la"/><asula kood="4716" nimi="Madi k??la"/><asula kood="4784" nimi="Marga k??la"/><asula kood="5708" nimi="Orava k??la"/><asula kood="5731" nimi="Oro k??la"/><asula kood="6283" nimi="Piusa k??la"/><asula kood="6345" nimi="Praakmani k??la"/><asula kood="6585" nimi="P??ka k??la"/><asula kood="6633" nimi="P????v??kese k??la"/><asula kood="6896" nimi="Rebasm??e k??la"/><asula kood="6985" nimi="Riihora k??la"/><asula kood="7173" nimi="R??ssa k??la"/><asula kood="7652" nimi="Soe k??la"/><asula kood="7657" nimi="Soena k??la"/><asula kood="7843" nimi="Suuremetsa k??la"/><asula kood="7326" nimi="Tamme k??la"/><asula kood="8385" nimi="Tuderna k??la"/><asula kood="9440" nimi="Vivva k??la"/></vald><vald kood="0621"><asula kood="1027" nimi="Aarna k??la"/><asula kood="1081" nimi="Adiste k??la"/><asula kood="1261" nimi="Andre k??la"/><asula kood="1609" nimi="Eoste k??la"/><asula kood="1846" nimi="Himmaste k??la"/><asula kood="1891" nimi="Holvandi k??la"/><asula kood="3170" nimi="Kiuma k??la"/><asula kood="3863" nimi="K??hri k??la"/><asula kood="4575" nimi="Lutsu k??la"/><asula kood="4768" nimi="Mammaste k??la"/><asula kood="4851" nimi="Meemaste k??la"/><asula kood="4938" nimi="Metste k??la"/><asula kood="4945" nimi="Miiaste k??la"/><asula kood="5445" nimi="Nooritsmetsa k??la"/><asula kood="5705" nimi="Oraj??e k??la"/><asula kood="6025" nimi="Partsi k??la"/><asula kood="6120" nimi="Peri k??la"/><asula kood="6461" nimi="Puskaru k??la"/><asula kood="6477" nimi="Puuri k??la"/><asula kood="6536" nimi="P??lva linn"/><asula kood="7098" nimi="Rosma k??la"/><asula kood="7660" nimi="Soesaare k??la"/><asula kood="8027" nimi="Taevaskoja k??la"/><asula kood="8353" nimi="Tromsi k??la"/><asula kood="8574" nimi="T??nnassilma k??la"/><asula kood="8644" nimi="Uibuj??rve k??la"/><asula kood="8927" nimi="Valgesoo k??la"/><asula kood="9015" nimi="Vanak??la"/></vald><vald kood="0707"><asula kood="2140" nimi="Jaanikeste k??la"/><asula kood="2815" nimi="Kassilaane k??la"/><asula kood="3770" nimi="K??nnu k??la"/><asula kood="3963" nimi="K??strim??e k??la"/><asula kood="4193" nimi="Leevaku k??la"/><asula kood="4410" nimi="Linte k??la"/><asula kood="4849" nimi="Meelva k??la"/><asula kood="5221" nimi="M??giotsa k??la"/><asula kood="5340" nimi="Naha k??la"/><asula kood="5459" nimi="Nulga k??la"/><asula kood="6268" nimi="Pindi k??la"/><asula kood="6631" nimi="P????sna k??la"/><asula kood="6677" nimi="Raadama k??la"/><asula kood="6743" nimi="Rahum??e k??la"/><asula kood="6753" nimi="Raigla k??la"/><asula kood="7016" nimi="Ristipalo k??la"/><asula kood="7151" nimi="Ruusa k??la"/><asula kood="7216" nimi="R??pina linn"/><asula kood="7289" nimi="Saarek??la"/><asula kood="7595" nimi="Sillap???? k??la"/><asula kood="7835" nimi="Suure-Veerksu k??la"/><asula kood="7975" nimi="S??lgoja k??la"/><asula kood="8289" nimi="Toolamaa k??la"/><asula kood="8313" nimi="Tooste k??la"/><asula kood="8370" nimi="Tsirksi k??la"/><asula kood="9511" nimi="V??iardi k??la"/><asula kood="9599" nimi="V??uk??la"/><asula kood="9608" nimi="V????psu alevik"/></vald><vald kood="0856"><asula kood="1058" nimi="Abissaare k??la"/><asula kood="1131" nimi="Aiaste k??la"/><asula kood="1785" nimi="Hauka k??la"/><asula kood="3399" nimi="Kooli k??la"/><asula kood="3511" nimi="Kr????dneri k??la"/><asula kood="4707" nimi="Maaritsa k??la"/><asula kood="5314" nimi="M??gra k??la"/><asula kood="6209" nimi="Pikaj??rve k??la"/><asula kood="6217" nimi="Pikareinu k??la"/><asula kood="6472" nimi="Puugi k??la"/><asula kood="7486" nimi="Saverna k??la"/><asula kood="7645" nimi="Sirvaste k??la"/><asula kood="7785" nimi="Sulaoja k??la"/><asula kood="8217" nimi="Tiido k??la"/><asula kood="8932" nimi="Valgj??rve k??la"/><asula kood="9422" nimi="Vissi k??la"/></vald><vald kood="0872"><asula kood="2728" nimi="Karilatsi k??la"/><asula kood="3030" nimi="Kiidj??rve k??la"/><asula kood="3422" nimi="Koorvere k??la"/><asula kood="4198" nimi="Leevij??e k??la"/><asula kood="4446" nimi="Logina k??la"/><asula kood="4522" nimi="Lootvina k??la"/><asula kood="5809" nimi="Padari k??la"/><asula kood="8922" nimi="Valgemetsa k??la"/><asula kood="9128" nimi="Vastse-Kuuste alevik"/><asula kood="9470" nimi="Voorek??la"/></vald><vald kood="0879"><asula kood="1706" nimi="Haavap???? k??la"/><asula kood="1849" nimi="Himmiste k??la"/><asula kood="2252" nimi="J??evaara k??la"/><asula kood="2256" nimi="J??eveere k??la"/><asula kood="3066" nimi="Kikka k??la"/><asula kood="3145" nimi="Kirmsi k??la"/><asula kood="3406" nimi="Koolmaj??rve k??la"/><asula kood="3405" nimi="Koolma k??la"/><asula kood="3589" nimi="Kullam??e k??la"/><asula kood="3629" nimi="Kunksilla k??la"/><asula kood="4066" nimi="Laho k??la"/><asula kood="4195" nimi="Leevi k??la"/><asula kood="4326" nimi="Lihtensteini k??la"/><asula kood="4911" nimi="M??tsavaara k??la"/><asula kood="5269" nimi="M??nnisalu k??la"/><asula kood="5437" nimi="Nohipalo k??la"/><asula kood="5857" nimi="Pahtp???? k??la"/><asula kood="7439" nimi="Sarvem??e k??la"/><asula kood="7698" nimi="Soohara k??la"/><asula kood="7981" nimi="S??vahavva k??la"/><asula kood="8244" nimi="Timo k??la"/><asula kood="9080" nimi="Vareste k??la"/><asula kood="9223" nimi="Veriora alevik"/><asula kood="9224" nimi="Verioram??isa k??la"/><asula kood="9294" nimi="Viira k??la"/><asula kood="9369" nimi="Viluste k??la"/><asula kood="9377" nimi="Vinso k??la"/><asula kood="9527" nimi="V??ika k??la"/><asula kood="9175" nimi="V??ike-Veerksu k??la"/><asula kood="9664" nimi="V??ndra k??la"/></vald><vald kood="0934"><asula kood="3277" nimi="Koidula k??la"/><asula kood="3358" nimi="Kolodavitsa k??la"/><asula kood="3359" nimi="Kolossova k??la"/><asula kood="3444" nimi="Korela k??la"/><asula kood="3470" nimi="Kostkova k??la"/><asula kood="3494" nimi="Kremessova k??la"/><asula kood="3609" nimi="Kundruse k??la"/><asula kood="4425" nimi="Litvina k??la"/><asula kood="4434" nimi="Lobotka k??la"/><asula kood="4570" nimi="Lutep???? k??la"/><asula kood="4827" nimi="Matsuri k??la"/><asula kood="5300" nimi="M????sovitsa k??la"/><asula kood="5387" nimi="Nedsaja k??la"/><asula kood="6045" nimi="Pattina k??la"/><asula kood="6115" nimi="Perdaku k??la"/><asula kood="6305" nimi="Podmotsa k??la"/><asula kood="6326" nimi="Popovitsa k??la"/><asula kood="7243" nimi="R????ptsova k??la"/><asula kood="7270" nimi="Saabolda k??la"/><asula kood="7315" nimi="Saatse k??la"/><asula kood="7404" nimi="Samarina k??la"/><asula kood="7553" nimi="Sesniki k??la"/><asula kood="7928" nimi="S??pina k??la"/><asula kood="8286" nimi="Tonja k??la"/><asula kood="8343" nimi="Treski k??la"/><asula kood="8657" nimi="Ulitina k??la"/><asula kood="8813" nimi="Vaartsi k??la"/><asula kood="9151" nimi="Vedernika k??la"/><asula kood="9194" nimi="Velna k??la"/><asula kood="9216" nimi="Verhulitsa k??la"/><asula kood="9484" nimi="Voropi k??la"/><asula kood="9571" nimi="V??polsova k??la"/><asula kood="9635" nimi="V??ike-R??sna k??la"/><asula kood="9672" nimi="V??rska alevik"/><asula kood="9707" nimi="??rsava k??la"/></vald></maakond><maakond kood="0067"><vald kood="0149"><asula kood="1344" nimi="Are alevik"/><asula kood="1516" nimi="Eavere k??la"/><asula kood="1576" nimi="Elbu k??la"/><asula kood="3648" nimi="Kurena k??la"/><asula kood="4296" nimi="Lepplaane k??la"/><asula kood="5053" nimi="Murru k??la"/><asula kood="5417" nimi="Niidu k??la"/><asula kood="6012" nimi="Parisselja k??la"/><asula kood="6608" nimi="P??rivere k??la"/><asula kood="7776" nimi="Suigu k??la"/><asula kood="8019" nimi="Tabria k??la"/><asula kood="9555" nimi="V??lla k??la"/></vald><vald kood="0160"><asula kood="1107" nimi="Ahaste k??la"/><asula kood="1394" nimi="Aruv??lja k??la"/><asula kood="1458" nimi="Audru alevik"/><asula kood="1513" nimi="Eassalu k??la"/><asula kood="2289" nimi="J????pre k??la"/><asula kood="2468" nimi="Kabriste k??la"/><asula kood="3014" nimi="Kihlepa k??la"/><asula kood="3746" nimi="K??ima k??la"/><asula kood="3891" nimi="K??rbu k??la"/><asula kood="4165" nimi="Lavassaare alev"/><asula kood="4268" nimi="Lemmetsa k??la"/><asula kood="4354" nimi="Liiva k??la"/><asula kood="4384" nimi="Lindi k??la"/><asula kood="4430" nimi="Liu k??la"/><asula kood="4753" nimi="Malda k??la"/><asula kood="4792" nimi="Marksa k??la"/><asula kood="5578" nimi="Oara k??la"/><asula kood="5986" nimi="Papsaare k??la"/><asula kood="6499" nimi="P??hara k??la"/><asula kood="6513" nimi="P??ldeotsa k??la"/><asula kood="6962" nimi="Ridalepa k??la"/><asula kood="7300" nimi="Saari k??la"/><asula kood="7460" nimi="Saulepa k??la"/><asula kood="7663" nimi="Soeva k??la"/><asula kood="7723" nimi="Soomra k??la"/><asula kood="8463" nimi="Tuuraste k??la"/><asula kood="8924" nimi="Valgeranna k??la"/></vald><vald kood="0188"><asula kood="1030" nimi="Aasa k??la"/><asula kood="1214" nimi="Altk??la"/><asula kood="1267" nimi="Anelema k??la"/><asula kood="1314" nimi="Arase k??la"/><asula kood="1506" nimi="Eametsa k??la"/><asula kood="1527" nimi="Eense k??la"/><asula kood="1531" nimi="Eerma k??la"/><asula kood="1602" nimi="Enge k??la"/><asula kood="1634" nimi="Ertsma k??la"/><asula kood="1736" nimi="Halinga k??la"/><asula kood="1802" nimi="Helenurme k??la"/><asula kood="2462" nimi="Kablima k??la"/><asula kood="2493" nimi="Kaelase k??la"/><asula kood="2669" nimi="Kangru k??la"/><asula kood="3237" nimi="Kodesmaa k??la"/><asula kood="3617" nimi="Kuninga k??la"/><asula kood="4101" nimi="Langerma k??la"/><asula kood="4216" nimi="Lehtmetsa k??la"/><asula kood="4219" nimi="Lehu k??la"/><asula kood="4320" nimi="Libatse k??la"/><asula kood="4504" nimi="Loomse k??la"/><asula kood="4743" nimi="Maima k??la"/><asula kood="5137" nimi="M??isak??la"/><asula kood="5191" nimi="M??ek??la"/><asula kood="5328" nimi="Naartse k??la"/><asula kood="5610" nimi="Oese k??la"/><asula kood="5935" nimi="Pallika k??la"/><asula kood="6113" nimi="Perek??la"/><asula kood="6278" nimi="Pitsalu k??la"/><asula kood="6617" nimi="P??rnu-Jaagupi alev"/><asula kood="6646" nimi="P????ravere k??la"/><asula kood="7061" nimi="Roodi k??la"/><asula kood="7108" nimi="Rukkik??la"/><asula kood="7391" nimi="Salu k??la"/><asula kood="7541" nimi="Sepak??la"/><asula kood="7739" nimi="Soosalu k??la"/><asula kood="7912" nimi="S????rike k??la"/><asula kood="8156" nimi="Tarva k??la"/><asula kood="8510" nimi="T??rdu k??la"/><asula kood="8588" nimi="T??hjasma k??la"/><asula kood="8843" nimi="Vahenurme k??la"/><asula kood="8901" nimi="Vakalepa k??la"/><asula kood="8947" nimi="Valistre k??la"/><asula kood="9164" nimi="Vee k??la"/></vald><vald kood="0213"><asula kood="1378" nimi="Arumetsa k??la"/><asula kood="1957" nimi="H????demeeste alevik"/><asula kood="2029" nimi="Ikla k??la"/><asula kood="2124" nimi="Jaagupi k??la"/><asula kood="2463" nimi="Kabli k??la"/><asula kood="3508" nimi="Krundik??la"/><asula kood="4746" nimi="Majaka k??la"/><asula kood="4805" nimi="Massiaru k??la"/><asula kood="4908" nimi="Metsapoole k??la"/><asula kood="5403" nimi="Nepste k??la"/><asula kood="5706" nimi="Oraj??e k??la"/><asula kood="5984" nimi="Papisilla k??la"/><asula kood="6103" nimi="Penu k??la"/><asula kood="6420" nimi="Pulgoja k??la"/><asula kood="6811" nimi="Rannametsa k??la"/><asula kood="7706" nimi="Sook??la"/><asula kood="7717" nimi="Soometsa k??la"/><asula kood="8340" nimi="Treimani k??la"/><asula kood="8724" nimi="Urissaare k??la"/><asula kood="8767" nimi="Uuemaa k??la"/><asula kood="9521" nimi="V??idu k??la"/></vald><vald kood="0303"><asula kood="4276" nimi="Lemsi k??la"/><asula kood="4381" nimi="Linak??la"/><asula kood="7089" nimi="Rootsik??la"/><asula kood="7951" nimi="S????re k??la"/></vald><vald kood="0334"><asula kood="1591" nimi="Emmu k??la"/><asula kood="1921" nimi="H??beda k??la"/><asula kood="2102" nimi="Irta k??la"/><asula kood="2106" nimi="Iska k??la"/><asula kood="2192" nimi="Joonuse k??la"/><asula kood="2316" nimi="J??nistvere k??la"/><asula kood="2349" nimi="J??rve k??la"/><asula kood="2606" nimi="Kalli k??la"/><asula kood="2732" nimi="Karin??mme k??la"/><asula kood="2777" nimi="Karuba k??la"/><asula kood="2999" nimi="Kibura k??la"/><asula kood="3049" nimi="Kiisamaa k??la"/><asula kood="3407" nimi="Koonga k??la"/><asula kood="3524" nimi="Kuhu k??la"/><asula kood="3654" nimi="Kurese k??la"/><asula kood="8091" nimi="K??ima k??la"/><asula kood="4611" nimi="L??pe k??la"/><asula kood="4742" nimi="Maikse k??la"/><asula kood="4942" nimi="Mihkli k??la"/><asula kood="5344" nimi="Naissoo k??la"/><asula kood="5385" nimi="Nedrema k??la"/><asula kood="5563" nimi="N??tsi k??la"/><asula kood="5638" nimi="Oidrema k??la"/><asula kood="5869" nimi="Paimvere k??la"/><asula kood="5924" nimi="Palatu k??la"/><asula kood="5990" nimi="Parasmaa k??la"/><asula kood="6054" nimi="Peantse k??la"/><asula kood="6200" nimi="Piisu k??la"/><asula kood="6227" nimi="Pikavere k??la"/><asula kood="6707" nimi="Rabavere k??la"/><asula kood="7380" nimi="Salevere k??la"/><asula kood="7702" nimi="Sookatse k??la"/><asula kood="8092" nimi="Tamme k??la"/><asula kood="8157" nimi="Tarva k??la"/><asula kood="8478" nimi="T??itse k??la"/><asula kood="8712" nimi="Ura k??la"/><asula kood="8722" nimi="Urita k??la"/><asula kood="9134" nimi="Vastaba k??la"/><asula kood="9192" nimi="Veltsa k??la"/><asula kood="9544" nimi="V??itra k??la"/><asula kood="9584" nimi="V??rungi k??la"/><asula kood="9691" nimi="??epa k??la"/></vald><vald kood="0568"><asula kood="5864" nimi="Paikuse alev"/><asula kood="6518" nimi="P??lendmaa k??la"/><asula kood="7536" nimi="Seljametsa k??la"/><asula kood="7591" nimi="Silla k??la"/><asula kood="8131" nimi="Tammuru k??la"/><asula kood="9113" nimi="Vaskr????ma k??la"/></vald><vald kood="0710"><asula kood="2370" nimi="J????rja k??la"/><asula kood="2588" nimi="Kalita k??la"/><asula kood="2631" nimi="Kamali k??la"/><asula kood="2648" nimi="Kanak??la"/><asula kood="3083" nimi="Kilingi-N??mme linn"/><asula kood="3929" nimi="K??rsu k??la"/><asula kood="1421" nimi="Laiksaare k??la"/><asula kood="4104" nimi="Lanksaare k??la"/><asula kood="4235" nimi="Leipste k??la"/><asula kood="4440" nimi="Lodja k??la"/><asula kood="4782" nimi="Marana k??la"/><asula kood="4787" nimi="Marina k??la"/><asula kood="5085" nimi="Mustla k??la"/><asula kood="5640" nimi="Oissaare k??la"/><asula kood="6143" nimi="Pihke k??la"/><asula kood="6919" nimi="Reinu k??la"/><asula kood="7280" nimi="Saarde k??la"/><asula kood="7560" nimi="Sigaste k??la"/><asula kood="8083" nimi="Tali k??la"/><asula kood="8214" nimi="Tihemetsa alevik"/><asula kood="8458" nimi="Tuuliku k??la"/><asula kood="8486" nimi="T??lla k??la"/><asula kood="9166" nimi="Veelikse k??la"/><asula kood="9297" nimi="Viisireiu k??la"/><asula kood="9650" nimi="V??ljak??la"/></vald><vald kood="0730"><asula kood="1510" nimi="Eametsa k??la"/><asula kood="3046" nimi="Kiisa k??la"/><asula kood="3084" nimi="Kilksama k??la"/><asula kood="5468" nimi="Nurme k??la"/><asula kood="6425" nimi="Pulli k??la"/><asula kood="7237" nimi="R????gu k??la"/><asula kood="7265" nimi="R??tavere k??la"/><asula kood="7455" nimi="Sauga alevik"/><asula kood="8120" nimi="Tammiste k??la"/><asula kood="8720" nimi="Urge k??la"/><asula kood="8885" nimi="Vainu k??la"/></vald><vald kood="0756"><asula kood="2062" nimi="Ilvese k??la"/><asula kood="2132" nimi="Jaamak??la"/><asula kood="2572" nimi="Kalda k??la"/><asula kood="3061" nimi="Kikepera k??la"/><asula kood="3840" nimi="K??veri k??la"/><asula kood="4628" nimi="L??hkma k??la"/><asula kood="4916" nimi="Metsa????re k??la"/><asula kood="6705" nimi="Rabak??la"/><asula kood="7013" nimi="Ristik??la"/><asula kood="7463" nimi="Saunametsa k??la"/><asula kood="7807" nimi="Surju k??la"/></vald><vald kood="0848"><asula kood="4004" nimi="Laadi k??la"/><asula kood="4232" nimi="Leina k??la"/><asula kood="4284" nimi="Lepak??la"/><asula kood="4892" nimi="Metsak??la"/><asula kood="6194" nimi="Piirumi k??la"/><asula kood="6924" nimi="Reiu k??la"/><asula kood="8072" nimi="Tahkuranna k??la"/><asula kood="8779" nimi="Uulu k??la"/><asula kood="9539" nimi="V??iste alevik"/></vald><vald kood="0805"><asula kood="8316" nimi="Tootsi alev"/></vald><vald kood="0808"><asula kood="1091" nimi="Aesoo k??la"/><asula kood="1574" nimi="Elbi k??la"/><asula kood="2251" nimi="J??esuu k??la"/><asula kood="3077" nimi="Kildemaa k??la"/><asula kood="3526" nimi="Kuiaru k??la"/><asula kood="3812" nimi="K??rsa k??la"/><asula kood="4314" nimi="Levi k??la"/><asula kood="4774" nimi="Mannare k??la"/><asula kood="5036" nimi="Muraka k??la"/><asula kood="5101" nimi="Muti k??la"/><asula kood="5698" nimi="Oore k??la"/><asula kood="6201" nimi="Piistaoja k??la"/><asula kood="6792" nimi="Randiv??lja k??la"/><asula kood="6986" nimi="Riisa k??la"/><asula kood="5292" nimi="R??tsepa k??la"/><asula kood="7529" nimi="Selja k??la"/><asula kood="7996" nimi="Taali k??la"/><asula kood="8269" nimi="Tohera k??la"/><asula kood="8326" nimi="Tori alevik"/><asula kood="8730" nimi="Urumarja k??la"/><asula kood="9560" nimi="V??lli k??la"/></vald><vald kood="0826"><asula kood="1229" nimi="Alu k??la"/><asula kood="1628" nimi="Ermistu k??la"/><asula kood="2834" nimi="Kastna k??la"/><asula kood="2893" nimi="Kavaru k??la"/><asula kood="3109" nimi="Kiraste k??la"/><asula kood="3784" nimi="K??pu k??la"/><asula kood="4109" nimi="Lao k??la"/><asula kood="4617" nimi="L??uka k??la"/><asula kood="4771" nimi="Manija k??la"/><asula kood="5264" nimi="M??nnikuste k??la"/><asula kood="6082" nimi="Peerni k??la"/><asula kood="6325" nimi="Pootsi k??la"/><asula kood="6595" nimi="P??rak??la"/><asula kood="6783" nimi="Rammuka k??la"/><asula kood="6819" nimi="Ranniku k??la"/><asula kood="7526" nimi="Seliste k??la"/><asula kood="8475" nimi="T??hela k??la"/><asula kood="8488" nimi="T??lli k??la"/><asula kood="8540" nimi="T??stamaa alevik"/><asula kood="9669" nimi="V??rati k??la"/></vald><vald kood="0863"><asula kood="1204" nimi="Allika k??la"/><asula kood="1366" nimi="Aruk??la"/><asula kood="1690" nimi="Haapsi k??la"/><asula kood="1814" nimi="Helmk??la"/><asula kood="1929" nimi="H??besalu k??la"/><asula kood="2473" nimi="Kadaka k??la"/><asula kood="2651" nimi="Kanamardi k??la"/><asula kood="3006" nimi="Kidise k??la"/><asula kood="3082" nimi="Kilgi k??la"/><asula kood="3251" nimi="Koeri k??la"/><asula kood="3445" nimi="Korju k??la"/><asula kood="3593" nimi="Kulli k??la"/><asula kood="3930" nimi="K??ru k??la"/><asula kood="4695" nimi="Maade k??la"/><asula kood="4824" nimi="Matsi k??la"/><asula kood="4881" nimi="Mere????rse k??la"/><asula kood="5049" nimi="Muriste k??la"/><asula kood="5173" nimi="M??tsu k??la"/><asula kood="5247" nimi="M??lik??la"/><asula kood="5530" nimi="N??mme k??la"/><asula kood="5776" nimi="Paadrema k??la"/><asula kood="5801" nimi="Paatsalu k??la"/><asula kood="6135" nimi="Piha k??la"/><asula kood="6717" nimi="Raespa k??la"/><asula kood="6722" nimi="Raheste k??la"/><asula kood="6802" nimi="Rannak??la"/><asula kood="6865" nimi="Rauksi k??la"/><asula kood="7259" nimi="R??di k??la"/><asula kood="7287" nimi="Saare k??la"/><asula kood="7462" nimi="Saulepi k??la"/><asula kood="7532" nimi="Selja k??la"/><asula kood="7699" nimi="Sookalda k??la"/><asula kood="8088" nimi="Tamba k??la"/><asula kood="8220" nimi="Tiilima k??la"/><asula kood="8541" nimi="T??usi k??la"/><asula kood="8577" nimi="T??psi k??la"/><asula kood="8893" nimi="Vaiste k??la"/><asula kood="9061" nimi="Varbla k??la"/><asula kood="9791" nimi="??hu k??la"/><asula kood="1603" nimi="??nnikse k??la"/></vald><vald kood="0929"><asula kood="1215" nimi="Allik??nnu k??la"/><asula kood="1237" nimi="Aluste k??la"/><asula kood="2400" nimi="Kaansoo k??la"/><asula kood="2486" nimi="Kadjaste k??la"/><asula kood="2545" nimi="Kaisma k??la"/><asula kood="2619" nimi="Kalmaru k??la"/><asula kood="2969" nimi="Kergu k??la"/><asula kood="3127" nimi="Kirikum??isa k??la"/><asula kood="3219" nimi="Kobra k??la"/><asula kood="3459" nimi="Kose k??la"/><asula kood="3599" nimi="Kullimaa k??la"/><asula kood="3666" nimi="Kurgja k??la"/><asula kood="3771" nimi="K??nnu k??la"/><asula kood="4190" nimi="Leetva k??la"/><asula kood="4586" nimi="Luuri k??la"/><asula kood="4696" nimi="L????ste k??la"/><asula kood="4808" nimi="Massu k??la"/><asula kood="4891" nimi="Metsak??la"/><asula kood="4913" nimi="Metsavere k??la"/><asula kood="5072" nimi="Mustaru k??la"/><asula kood="5185" nimi="M??dara k??la"/><asula kood="5720" nimi="Orik??la"/><asula kood="6616" nimi="P??rnj??e k??la"/><asula kood="6714" nimi="Rae k??la"/><asula kood="6725" nimi="Rahkama k??la"/><asula kood="6732" nimi="Rahnoja k??la"/><asula kood="6921" nimi="Reinumurru k??la"/><asula kood="7186" nimi="R??usa k??la"/><asula kood="7229" nimi="R??tsepa k??la"/><asula kood="7406" nimi="Samliku k??la"/><asula kood="7581" nimi="Sikana k??la"/><asula kood="7661" nimi="Sohlu k??la"/><asula kood="7838" nimi="Suurej??e k??la"/><asula kood="7967" nimi="S????stla k??la"/><asula kood="8055" nimi="Tagassaare k??la"/><asula kood="8909" nimi="Vaki k??la"/><asula kood="9199" nimi="Venekuusiku k??la"/><asula kood="9237" nimi="Veskisoo k??la"/><asula kood="9267" nimi="Vihtra k??la"/><asula kood="9372" nimi="Viluvere k??la"/><asula kood="9524" nimi="V??idula k??la"/><asula kood="9526" nimi="V??iera k??la"/><asula kood="9842" nimi="??nnaste k??la"/></vald><vald kood="0931"><asula kood="9663" nimi="V??ndra alev"/></vald></maakond><maakond kood="0070"><vald kood="0240"><asula kood="1437" nimi="Atla k??la"/><asula kood="1805" nimi="Helda k??la"/><asula kood="1931" nimi="H??reda k??la"/><asula kood="1944" nimi="H??rgla k??la"/><asula kood="2169" nimi="Jaluse k??la"/><asula kood="2223" nimi="Juuru alevik"/><asula kood="2330" nimi="J??rlepa k??la"/><asula kood="2569" nimi="Kalda k??la"/><asula kood="4602" nimi="L??iuse k??la"/><asula kood="4733" nimi="Mahtra k??la"/><asula kood="4741" nimi="Maidla k??la"/><asula kood="5717" nimi="Orguse k??la"/><asula kood="6274" nimi="Pirgu k??la"/><asula kood="7319" nimi="Sadala k??la"/><asula kood="9046" nimi="Vankse k??la"/></vald><vald kood="0260"><asula kood="2346" nimi="J??rvakandi alev"/></vald><vald kood="0277"><asula kood="2553" nimi="Kaiu alevik"/><asula kood="2742" nimi="Karitsa k??la"/><asula kood="2845" nimi="Kasvandu k??la"/><asula kood="3541" nimi="Kuimetsa k??la"/><asula kood="5588" nimi="Oblu k??la"/><asula kood="6525" nimi="P??lliku k??la"/><asula kood="7840" nimi="Suurekivi k??la"/><asula kood="8138" nimi="Tamsi k??la"/><asula kood="8279" nimi="Tolla k??la"/><asula kood="8305" nimi="Toomja k??la"/><asula kood="8841" nimi="Vahastu k??la"/><asula kood="8982" nimi="Vana-Kaiu k??la"/><asula kood="9050" nimi="Vaopere k??la"/></vald><vald kood="0292"><asula kood="1110" nimi="Ahek??nnu k??la"/><asula kood="1550" nimi="Eidapere alevik"/><asula kood="1583" nimi="Ellamaa k??la"/><asula kood="1684" nimi="Haakla k??la"/><asula kood="1826" nimi="Hertu k??la"/><asula kood="1830" nimi="Hiie k??la"/><asula kood="2087" nimi="Ingliste k??la"/><asula kood="2496" nimi="Kaerepere alevik"/><asula kood="2498" nimi="Kaerepere k??la"/><asula kood="2567" nimi="Kalbu k??la"/><asula kood="2835" nimi="Kastna k??la"/><asula kood="2903" nimi="Keava alevik"/><asula kood="2924" nimi="Kehtna alevik"/><asula kood="2900" nimi="Kehtna-Nurme k??la"/><asula kood="2952" nimi="Kenni k??la"/><asula kood="3389" nimi="Koogim??e k??la"/><asula kood="3391" nimi="Koogiste k??la"/><asula kood="3606" nimi="Kumma k??la"/><asula kood="3785" nimi="K??rbja k??la"/><asula kood="3846" nimi="K??bik??la"/><asula kood="3919" nimi="K??rpla k??la"/><asula kood="4038" nimi="Laeste k??la"/><asula kood="4084" nimi="Lalli k??la"/><asula kood="4133" nimi="Lau k??la"/><asula kood="4248" nimi="Lellapere k??la"/><asula kood="2923" nimi="Lellapere-Nurme k??la"/><asula kood="4250" nimi="Lelle alevik"/><asula kood="4392" nimi="Linnaaluste k??la"/><asula kood="4476" nimi="Lokuta k??la"/><asula kood="4914" nimi="Metsa????re k??la"/><asula kood="5015" nimi="Mukri k??la"/><asula kood="5334" nimi="Nadalama k??la"/><asula kood="5498" nimi="N??lva k??la"/><asula kood="5618" nimi="Ohekatku k??la"/><asula kood="5820" nimi="Pae k??la"/><asula kood="5922" nimi="Palasi k??la"/><asula kood="5947" nimi="Paluk??la"/><asula kood="6530" nimi="P??llu k??la"/><asula kood="6546" nimi="P??rsaku k??la"/><asula kood="6937" nimi="Reonda k??la"/><asula kood="7176" nimi="R??ue k??la"/><asula kood="7298" nimi="Saarep??llu k??la"/><asula kood="7353" nimi="Saksa k??la"/><asula kood="7461" nimi="Saunak??la"/><asula kood="7531" nimi="Selja k??la"/><asula kood="7681" nimi="Sooaluste k??la"/><asula kood="8970" nimi="Valtu-Nurme k??la"/><asula kood="9126" nimi="Vastja k??la"/></vald><vald kood="0317"><asula kood="1021" nimi="Aandu k??la"/><asula kood="1079" nimi="Adila k??la"/><asula kood="1094" nimi="Aespa alevik"/><asula kood="1270" nimi="Angerja k??la"/><asula kood="1714" nimi="Hageri alevik"/><asula kood="1715" nimi="Hageri k??la"/><asula kood="2475" nimi="Kadaka k??la"/><asula kood="3268" nimi="Kohila alev"/><asula kood="4453" nimi="Lohu k??la"/><asula kood="4511" nimi="Loone k??la"/><asula kood="4681" nimi="L??mandu k??la"/><asula kood="4811" nimi="Masti k??la"/><asula kood="5250" nimi="M??livere k??la"/><asula kood="5854" nimi="Pahkla k??la"/><asula kood="6140" nimi="Pihali k??la"/><asula kood="6368" nimi="Prillim??e alevik"/><asula kood="6415" nimi="Pukam??e k??la"/><asula kood="6503" nimi="P??ikma k??la"/><asula kood="6710" nimi="Rabivere k??la"/><asula kood="7085" nimi="Rootsi k??la"/><asula kood="7402" nimi="Salutaguse k??la"/><asula kood="7815" nimi="Sutlema k??la"/><asula kood="8721" nimi="Urge k??la"/><asula kood="8976" nimi="Vana-Aespa k??la"/><asula kood="9341" nimi="Vilivere k??la"/></vald><vald kood="0375"><asula kood="2228" nimi="J??ek??la"/><asula kood="3600" nimi="Kullimaa k??la"/><asula kood="3735" nimi="K??du k??la"/><asula kood="3854" nimi="K??dva k??la"/><asula kood="3875" nimi="K??ndliku k??la"/><asula kood="3933" nimi="K??ru alevik"/><asula kood="4157" nimi="Lauri k??la"/><asula kood="4560" nimi="Lungu k??la"/><asula kood="7683" nimi="Sonni k??la"/></vald><vald kood="0504"><asula kood="1168" nimi="Alak??la"/><asula kood="1219" nimi="Altk??la"/><asula kood="1324" nimi="Aravere k??la"/><asula kood="1375" nimi="Aruk??la"/><asula kood="1725" nimi="Haimre k??la"/><asula kood="1834" nimi="Hiietse k??la"/><asula kood="2081" nimi="Inda k??la"/><asula kood="2147" nimi="Jaaniveski k??la"/><asula kood="2254" nimi="J??e????re k??la"/><asula kood="2504" nimi="Kaguvere k??la"/><asula kood="2668" nimi="Kangru k??la"/><asula kood="2824" nimi="Kasti k??la"/><asula kood="2980" nimi="Keskk??la"/><asula kood="3037" nimi="Kiilaspere k??la"/><asula kood="3080" nimi="Kilgi k??la"/><asula kood="3146" nimi="Kirna k??la"/><asula kood="3267" nimi="Kohatu k??la"/><asula kood="3272" nimi="Kohtru k??la"/><asula kood="3365" nimi="Koluta k??la"/><asula kood="3380" nimi="Konuvere k??la"/><asula kood="3627" nimi="Kunsu k??la"/><asula kood="3813" nimi="K??rtsuotsa k??la"/><asula kood="3844" nimi="K??bik??la"/><asula kood="3908" nimi="K??riselja k??la"/><asula kood="4143" nimi="Laukna k??la"/><asula kood="4200" nimi="Leevre k??la"/><asula kood="4302" nimi="Lestima k??la"/><asula kood="4479" nimi="Lokuta k??la"/><asula kood="4503" nimi="Loodna k??la"/><asula kood="4554" nimi="Luiste k??la"/><asula kood="4683" nimi="L??mandu k??la"/><asula kood="8232" nimi="Maidla k??la"/><asula kood="4915" nimi="Metsa????re k??la"/><asula kood="4919" nimi="Metsk??la"/><asula kood="4967" nimi="Moka k??la"/><asula kood="5133" nimi="M??isamaa k??la"/><asula kood="5162" nimi="M??raste k??la"/><asula kood="5246" nimi="M??liste k??la"/><asula kood="5262" nimi="M??nniku k??la"/><asula kood="5280" nimi="M??rjamaa alev"/><asula kood="5348" nimi="Naistevalla k??la"/><asula kood="5351" nimi="Napanurga k??la"/><asula kood="5469" nimi="Nurme k??la"/><asula kood="5482" nimi="Nurtu-N??lva k??la"/><asula kood="5517" nimi="N??mmeotsa k??la"/><asula kood="5561" nimi="N????ri k??la"/><asula kood="5631" nimi="Ohukotsu k??la"/><asula kood="5655" nimi="Oja????rse k??la"/><asula kood="5711" nimi="Orgita k??la"/><asula kood="5779" nimi="Paaduotsa k??la"/><asula kood="5826" nimi="Paek??la"/><asula kood="5875" nimi="Paisumaa k??la"/><asula kood="5878" nimi="Pajaka k??la"/><asula kood="6438" nimi="Purga k??la"/><asula kood="6523" nimi="P??lli k??la"/><asula kood="6624" nimi="P????deva k??la"/><asula kood="6800" nimi="Rangu k??la"/><asula kood="6832" nimi="Rassiotsa k??la"/><asula kood="7003" nimi="Ringuta k??la"/><asula kood="7015" nimi="Risu-Suurk??la"/><asula kood="7132" nimi="Russalu k??la"/><asula kood="7622" nimi="Sipa k??la"/><asula kood="7725" nimi="Sooniste k??la"/><asula kood="7740" nimi="Soosalu k??la"/><asula kood="7792" nimi="Sulu k??la"/><asula kood="7853" nimi="Suurk??la"/><asula kood="7890" nimi="S??meru k??la"/><asula kood="7909" nimi="S??tke k??la"/><asula kood="8182" nimi="Teenuse k??la"/><asula kood="8283" nimi="Tolli k??la"/><asula kood="8717" nimi="Urevere k??la"/><asula kood="8882" nimi="Vaim??isa k??la"/><asula kood="8939" nimi="Valgu k??la"/><asula kood="9016" nimi="Vanam??isa k??la"/><asula kood="8997" nimi="Vana-Nurtu k??la"/><asula kood="9063" nimi="Varbola k??la"/><asula kood="9189" nimi="Velise k??la"/><asula kood="9187" nimi="Velisem??isa k??la"/><asula kood="9190" nimi="Velise-N??lva k??la"/><asula kood="9228" nimi="Veski k??la"/><asula kood="9359" nimi="Vilta k??la"/><asula kood="9493" nimi="V??eva k??la"/><asula kood="9829" nimi="??lej??e k??la"/></vald><vald kood="0654"><asula kood="2161" nimi="Jalase k??la"/><asula kood="2530" nimi="Kaigepere k??la"/><asula kood="2955" nimi="Keo k??la"/><asula kood="3294" nimi="Koikse k??la"/><asula kood="3831" nimi="K??rvetaguse k??la"/><asula kood="4413" nimi="Lipa k??la"/><asula kood="4416" nimi="Lipametsa k??la"/><asula kood="4443" nimi="Loe k??la"/><asula kood="4614" nimi="L??pemetsa k??la"/><asula kood="4924" nimi="Metsk??la"/><asula kood="5516" nimi="N??mmemetsa k??la"/><asula kood="5522" nimi="N??mmk??la"/><asula kood="6445" nimi="Purku k??la"/><asula kood="6533" nimi="P??lma k??la"/><asula kood="6662" nimi="P??hatu k??la"/><asula kood="6719" nimi="Raela k??la"/><asula kood="6758" nimi="Raikk??la"/><asula kood="6979" nimi="Riidaku k??la"/><asula kood="8093" nimi="Tamme k??la"/><asula kood="8677" nimi="Ummaru k??la"/><asula kood="8838" nimi="Vahak??nnu k??la"/><asula kood="8961" nimi="Valli k??la"/></vald><vald kood="0669"><asula kood="1230" nimi="Alu alevik"/><asula kood="1232" nimi="Alu-Metsk??la"/><asula kood="1316" nimi="Arank??la"/><asula kood="1716" nimi="Hagudi alevik"/><asula kood="1717" nimi="Hagudi k??la"/><asula kood="2020" nimi="Iira k??la"/><asula kood="2216" nimi="Juula k??la"/><asula kood="2580" nimi="Kalevi k??la"/><asula kood="2933" nimi="Kelba k??la"/><asula kood="3242" nimi="Kodila k??la"/><asula kood="3240" nimi="Kodila-Metsk??la"/><asula kood="3283" nimi="Koigi k??la"/><asula kood="3569" nimi="Kuku k??la"/><asula kood="3720" nimi="Kuusiku alevik"/><asula kood="3724" nimi="Kuusiku-N??mme k??la"/><asula kood="3799" nimi="K??rgu k??la"/><asula kood="4421" nimi="Lipstu k??la"/><asula kood="4728" nimi="Mahlam??e k??la"/><asula kood="5126" nimi="M??isaaseme k??la"/><asula kood="5254" nimi="M??llu k??la"/><asula kood="5520" nimi="N??mme k??la"/><asula kood="5608" nimi="Oela k??la"/><asula kood="5634" nimi="Ohulepa k??la"/><asula kood="5687" nimi="Oola k??la"/><asula kood="5911" nimi="Palamulla k??la"/><asula kood="6443" nimi="Purila k??la"/><asula kood="6772" nimi="Raka k??la"/><asula kood="6826" nimi="Rapla linn"/><asula kood="6954" nimi="Ridak??la"/><asula kood="7255" nimi="R??a k??la"/><asula kood="7518" nimi="Seli k??la"/><asula kood="5470" nimi="Seli-Nurme k??la"/><asula kood="7586" nimi="Sikeldi k??la"/><asula kood="7796" nimi="Sulupere k??la"/><asula kood="8139" nimi="Tapupere k??la"/><asula kood="8441" nimi="Tuti k??la"/><asula kood="8518" nimi="T??rma k??la"/><asula kood="8788" nimi="Uusk??la"/><asula kood="8971" nimi="Valtu k??la"/><asula kood="4318" nimi="V??ljataguse k??la"/><asula kood="9729" nimi="??herdi k??la"/><asula kood="9831" nimi="??lej??e k??la"/></vald><vald kood="0884"><asula kood="1319" nimi="Araste k??la"/><asula kood="1478" nimi="Avaste k??la"/><asula kood="2296" nimi="J??divere k??la"/><asula kood="2883" nimi="Kausi k??la"/><asula kood="2990" nimi="Kesu k??la"/><asula kood="3175" nimi="Kivi-Vigala k??la"/><asula kood="3307" nimi="Kojastu k??la"/><asula kood="3373" nimi="Konnapere k??la"/><asula kood="3662" nimi="Kurevere k??la"/><asula kood="4221" nimi="Leibre k??la"/><asula kood="4647" nimi="L??ti k??la"/><asula kood="4775" nimi="Manni k??la"/><asula kood="5353" nimi="Naravere k??la"/><asula kood="5611" nimi="Oese k??la"/><asula kood="5653" nimi="Ojapere k??la"/><asula kood="5921" nimi="Palase k??la"/><asula kood="5928" nimi="Paljasmaa k??la"/><asula kood="5937" nimi="Pallika k??la"/><asula kood="6629" nimi="P????rdu k??la"/><asula kood="7248" nimi="R????ski k??la"/><asula kood="7946" nimi="S????la k??la"/><asula kood="8208" nimi="Tiduvere k??la"/><asula kood="8509" nimi="T??numaa k??la"/><asula kood="8834" nimi="Vaguja k??la"/><asula kood="9028" nimi="Vanam??isa k??la"/><asula kood="9007" nimi="Vana-Vigala k??la"/><asula kood="9666" nimi="V??ngla k??la"/></vald></maakond><maakond kood="0074"><vald kood="0301"><asula kood="1054" nimi="Abaja k??la"/><asula kood="1067" nimi="Abula k??la"/><asula kood="2599" nimi="Kallaste k??la"/><asula kood="2624" nimi="Kalmu k??la"/><asula kood="1498" nimi="Karuj??rve k??la"/><asula kood="2922" nimi="Kehila k??la"/><asula kood="3012" nimi="Kihelkonna alevik"/><asula kood="3045" nimi="Kiirassaare k??la"/><asula kood="3483" nimi="Kotsma k??la"/><asula kood="3632" nimi="Kuralase k??la"/><asula kood="3643" nimi="Kuremetsa k??la"/><asula kood="3661" nimi="Kurevere k??la"/><asula kood="3712" nimi="Kuumi k??la"/><asula kood="3722" nimi="Kuusiku k??la"/><asula kood="3817" nimi="K??ruse k??la"/><asula kood="3843" nimi="K????ru k??la"/><asula kood="4355" nimi="Liiva k??la"/><asula kood="4509" nimi="Loona k??la"/><asula kood="4649" nimi="L??tiniidi k??la"/><asula kood="4653" nimi="L????gi k??la"/><asula kood="4886" nimi="Metsak??la"/><asula kood="5209" nimi="M??ebe k??la"/><asula kood="5388" nimi="Neeme k??la"/><asula kood="5592" nimi="Odal??tsi k??la"/><asula kood="5657" nimi="Oju k??la"/><asula kood="5890" nimi="Pajum??isa k??la"/><asula kood="6137" nimi="Pidula k??la"/><asula kood="6804" nimi="Rannak??la"/><asula kood="7088" nimi="Rootsik??la"/><asula kood="7545" nimi="Sepise k??la"/><asula kood="8049" nimi="Tagam??isa k??la"/><asula kood="8099" nimi="Tammese k??la"/><asula kood="8270" nimi="Tohku k??la"/><asula kood="8692" nimi="Undva k??la"/><asula kood="8870" nimi="Vaigu k??la"/><asula kood="9089" nimi="Varkja k??la"/><asula kood="9158" nimi="Vedruka k??la"/><asula kood="9170" nimi="Veere k??la"/><asula kood="9315" nimi="Viki k??la"/><asula kood="9357" nimi="Vilsandi k??la"/><asula kood="9383" nimi="Virita k??la"/><asula kood="9849" nimi="??ru k??la"/></vald><vald kood="0386"><asula kood="1052" nimi="Aaviku k??la"/><asula kood="1429" nimi="Asva k??la"/><asula kood="1455" nimi="Audla k??la"/><asula kood="2225" nimi="J??e k??la"/><asula kood="2517" nimi="Kahtla k??la"/><asula kood="2697" nimi="Kapra k??la"/><asula kood="3098" nimi="Kingli k??la"/><asula kood="3744" nimi="K??iguste k??la"/><asula kood="3882" nimi="K??o k??la"/><asula kood="4054" nimi="Lahek??la"/><asula kood="4073" nimi="Laimjala k??la"/><asula kood="5087" nimi="Mustla k??la"/><asula kood="5220" nimi="M??gi-Kurdla k??la"/><asula kood="5510" nimi="N??mme k??la"/><asula kood="5849" nimi="Pahavalla k??la"/><asula kood="5882" nimi="Paju-Kurdla k??la"/><asula kood="6799" nimi="Randvere k??la"/><asula kood="6806" nimi="Rannak??la"/><asula kood="6960" nimi="Ridala k??la"/><asula kood="7107" nimi="Ruhve k??la"/><asula kood="7288" nimi="Saarek??la"/><asula kood="7291" nimi="Saaremetsa k??la"/><asula kood="9360" nimi="Viltina k??la"/><asula kood="9854" nimi="????vere k??la"/></vald><vald kood="0403"><asula kood="1272" nimi="Angla k??la"/><asula kood="1364" nimi="Aru k??la"/><asula kood="1389" nimi="Aruste k??la"/><asula kood="1424" nimi="Asuka k??la"/><asula kood="1836" nimi="Hiiev??lja k??la"/><asula kood="2274" nimi="J??iste k??la"/><asula kood="2543" nimi="Kaisa k??la"/><asula kood="2747" nimi="Karja k??la"/><asula kood="3279" nimi="Koiduv??lja k??la"/><asula kood="3292" nimi="Koikla k??la"/><asula kood="3437" nimi="Kopli k??la"/><asula kood="3989" nimi="K??lma k??la"/><asula kood="4138" nimi="Laugu k??la"/><asula kood="4237" nimi="Leisi alevik"/><asula kood="4360" nimi="Liiva k??la"/><asula kood="4395" nimi="Linnaka k??la"/><asula kood="4409" nimi="Linnuse k??la"/><asula kood="4581" nimi="Luulupe k??la"/><asula kood="4615" nimi="L??pi k??la"/><asula kood="4862" nimi="Meiuste k??la"/><asula kood="4917" nimi="Metsa????re k??la"/><asula kood="4922" nimi="Metsk??la"/><asula kood="4984" nimi="Moosi k??la"/><asula kood="5012" nimi="Mujaste k??la"/><asula kood="5050" nimi="Murika k??la"/><asula kood="5287" nimi="M??tja k??la"/><asula kood="5374" nimi="Nava k??la"/><asula kood="5414" nimi="Nihatu k??la"/><asula kood="5472" nimi="Nurme k??la"/><asula kood="5519" nimi="N??mme k??la"/><asula kood="5644" nimi="Oitme k??la"/><asula kood="5792" nimi="Paaste k??la"/><asula kood="5965" nimi="Pamma k??la"/><asula kood="5967" nimi="Pammana k??la"/><asula kood="5994" nimi="Parasmetsa k??la"/><asula kood="6077" nimi="Peederga k??la"/><asula kood="6312" nimi="Poka k??la"/><asula kood="6448" nimi="Purtsa k??la"/><asula kood="6618" nimi="P??rsama k??la"/><asula kood="6639" nimi="P??itse k??la"/><asula kood="6842" nimi="Ratla k??la"/><asula kood="7051" nimi="Roobaka k??la"/><asula kood="7234" nimi="R????gi k??la"/><asula kood="7537" nimi="Selja k??la"/><asula kood="7658" nimi="Soela k??la"/><asula kood="8153" nimi="Tareste k??la"/><asula kood="8230" nimi="Tiitsuotsa k??la"/><asula kood="8347" nimi="Triigi k??la"/><asula kood="8443" nimi="Tutku k??la"/><asula kood="8516" nimi="T??re k??la"/><asula kood="8587" nimi="T????tsi k??la"/><asula kood="9226" nimi="Veske k??la"/><asula kood="9293" nimi="Viira k??la"/><asula kood="9799" nimi="??este k??la"/></vald><vald kood="0433"><asula kood="1064" nimi="Abruka k??la"/><asula kood="1268" nimi="Anepesa k??la"/><asula kood="1280" nimi="Anijala k??la"/><asula kood="1300" nimi="Ansi k??la"/><asula kood="1313" nimi="Arandi k??la"/><asula kood="1416" nimi="Aste alevik"/><asula kood="1417" nimi="Aste k??la"/><asula kood="1426" nimi="Asuk??la"/><asula kood="1436" nimi="Atla k??la"/><asula kood="1466" nimi="Aula-Vintri k??la"/><asula kood="1470" nimi="Austla k??la"/><asula kood="1530" nimi="Eeriksaare k??la"/><asula kood="1553" nimi="Eikla k??la"/><asula kood="1599" nimi="Endla k??la"/><asula kood="1686" nimi="Haamse k??la"/><asula kood="1731" nimi="Hakjala k??la"/><asula kood="1850" nimi="Himmiste k??la"/><asula kood="1874" nimi="Hirmuste k??la"/><asula kood="1965" nimi="H??bja k??la"/><asula kood="2097" nimi="Irase k??la"/><asula kood="2200" nimi="Jootme k??la"/><asula kood="2224" nimi="J??e k??la"/><asula kood="2239" nimi="J??empa k??la"/><asula kood="2260" nimi="J??gela k??la"/><asula kood="3122" nimi="Kaarma-Kirikuk??la"/><asula kood="2414" nimi="Kaarma k??la"/><asula kood="2416" nimi="Kaarmise k??la"/><asula kood="2548" nimi="Kaisvere k??la"/><asula kood="2662" nimi="Kandla k??la"/><asula kood="2705" nimi="Karala k??la"/><asula kood="2722" nimi="Karida k??la"/><asula kood="2823" nimi="Kasti k??la"/><asula kood="2857" nimi="Kaubi k??la"/><asula kood="2935" nimi="Kellam??e k??la"/><asula kood="2982" nimi="Keskranna k??la"/><asula kood="2985" nimi="Keskvere k??la"/><asula kood="3106" nimi="Kipi k??la"/><asula kood="3111" nimi="Kiratsi k??la"/><asula kood="3258" nimi="Kogula k??la"/><asula kood="3274" nimi="Koidu k??la"/><asula kood="3278" nimi="Koidula k??la"/><asula kood="3299" nimi="Koimla k??la"/><asula kood="3320" nimi="Koki k??la"/><asula kood="3431" nimi="Koovi k??la"/><asula kood="3482" nimi="Kotlandi k??la"/><asula kood="3519" nimi="Kudjape alevik"/><asula kood="3550" nimi="Kuke k??la"/><asula kood="3615" nimi="Kungla k??la"/><asula kood="3715" nimi="Kuuse k??la"/><asula kood="3726" nimi="Kuusn??mme k??la"/><asula kood="3802" nimi="K??rkk??la"/><asula kood="3860" nimi="K??esla k??la"/><asula kood="3870" nimi="K??ku k??la"/><asula kood="3896" nimi="K??rdu k??la"/><asula kood="3916" nimi="K??rla alevik"/><asula kood="3123" nimi="K??rla-Kirikuk??la"/><asula kood="3598" nimi="K??rla-Kulli k??la"/><asula kood="4007" nimi="Laadjala k??la"/><asula kood="4053" nimi="Lahek??la"/><asula kood="4110" nimi="Laok??la"/><asula kood="4180" nimi="Leedri k??la"/><asula kood="4368" nimi="Lilbi k??la"/><asula kood="3601" nimi="L??manda-Kulli k??la"/><asula kood="4679" nimi="L??manda k??la"/><asula kood="4754" nimi="Maleva k??la"/><asula kood="4834" nimi="Meedla k??la"/><asula kood="4885" nimi="Metsak??la"/><asula kood="4907" nimi="Metsapere k??la"/><asula kood="5025" nimi="Mullutu k??la"/><asula kood="5044" nimi="Muratsi k??la"/><asula kood="5139" nimi="M??isak??la"/><asula kood="5154" nimi="M??nnuste k??la"/><asula kood="5256" nimi="M??ndjala k??la"/><asula kood="5284" nimi="M??tasselja k??la"/><asula kood="5361" nimi="Nasva alevik"/><asula kood="5509" nimi="N??mme k??la"/><asula kood="5528" nimi="N??mpa k??la"/><asula kood="5836" nimi="Paevere k??la"/><asula kood="5867" nimi="Paik??la"/><asula kood="5868" nimi="Paimala k??la"/><asula kood="6010" nimi="Parila k??la"/><asula kood="6169" nimi="Piila k??la"/><asula kood="6343" nimi="Praakli k??la"/><asula kood="6531" nimi="P??lluk??la"/><asula kood="6562" nimi="P??hkla k??la"/><asula kood="6614" nimi="P??rni k??la"/><asula kood="6798" nimi="Randvere k??la"/><asula kood="6997" nimi="Riksu k??la"/><asula kood="7340" nimi="Saia k??la"/><asula kood="7473" nimi="Sauvere k??la"/><asula kood="7543" nimi="Sepa k??la"/><asula kood="7584" nimi="Sikassaare k??la"/><asula kood="7885" nimi="S??mera k??la"/><asula kood="8076" nimi="Tahula k??la"/><asula kood="8127" nimi="Tamsalu k??la"/><asula kood="8155" nimi="Taritu k??la"/><asula kood="8489" nimi="T??lli k??la"/><asula kood="8517" nimi="T??rise k??la"/><asula kood="8526" nimi="T??ru k??la"/><asula kood="8625" nimi="Uduvere k??la"/><asula kood="8662" nimi="Ulje k??la"/><asula kood="8697" nimi="Unim??e k??la"/><asula kood="8708" nimi="Upa k??la"/><asula kood="8859" nimi="Vahva k??la"/><asula kood="8898" nimi="Vaivere k??la"/><asula kood="8990" nimi="Vana-Lahetaguse k??la"/><asula kood="9045" nimi="Vantri k??la"/><asula kood="9093" nimi="Varpe k??la"/><asula kood="9145" nimi="Vatsk??la"/><asula kood="9197" nimi="Vendise k??la"/><asula kood="9206" nimi="Vennati k??la"/><asula kood="9241" nimi="Vestla k??la"/><asula kood="9275" nimi="Viidu k??la"/><asula kood="9284" nimi="Viira k??la"/><asula kood="9800" nimi="??ha k??la"/></vald><vald kood="0478"><asula kood="1196" nimi="Aljava k??la"/><asula kood="1808" nimi="Hellamaa k??la"/><asula kood="1990" nimi="Igak??la"/><asula kood="2597" nimi="Kallaste k??la"/><asula kood="2691" nimi="Kantsi k??la"/><asula kood="2695" nimi="Kapi k??la"/><asula kood="2987" nimi="Kesse k??la"/><asula kood="3260" nimi="Koguva k??la"/><asula kood="3549" nimi="Kuivastu k??la"/><asula kood="3983" nimi="K??lasema k??la"/><asula kood="4058" nimi="Lahek??la"/><asula kood="4083" nimi="Lalli k??la"/><asula kood="4189" nimi="Leeskopa k??la"/><asula kood="4215" nimi="Lehtmetsa k??la"/><asula kood="4292" nimi="Lepiku k??la"/><asula kood="4311" nimi="Leval??pme k??la"/><asula kood="4353" nimi="Liiva k??la"/><asula kood="4407" nimi="Linnuse k??la"/><asula kood="4595" nimi="L??etsa k??la"/><asula kood="5120" nimi="M??ega k??la"/><asula kood="5130" nimi="M??isak??la"/><asula kood="5243" nimi="M??la k??la"/><asula kood="5370" nimi="Nautse k??la"/><asula kood="5475" nimi="Nurme k??la"/><asula kood="5524" nimi="N??mmk??la"/><asula kood="5639" nimi="Oina k??la"/><asula kood="5831" nimi="Paenase k??la"/><asula kood="5931" nimi="Pallasmaa k??la"/><asula kood="6184" nimi="Piiri k??la"/><asula kood="6638" nimi="P??itse k??la"/><asula kood="6556" nimi="P??daste k??la"/><asula kood="6559" nimi="P??elda k??la"/><asula kood="6598" nimi="P??rase k??la"/><asula kood="6715" nimi="Raegma k??la"/><asula kood="6817" nimi="Rannak??la"/><asula kood="6861" nimi="Raugi k??la"/><asula kood="6888" nimi="Rebaski k??la"/><asula kood="6965" nimi="Ridasi k??la"/><asula kood="7006" nimi="Rinsi k??la"/><asula kood="7093" nimi="Rootsivere k??la"/><asula kood="7223" nimi="R??ssa k??la"/><asula kood="7601" nimi="Simisti k??la"/><asula kood="7724" nimi="Soonda k??la"/><asula kood="7847" nimi="Suurem??isa k??la"/><asula kood="8136" nimi="Tamse k??la"/><asula kood="8418" nimi="Tupenurme k??la"/><asula kood="8440" nimi="Tusti k??la"/><asula kood="8851" nimi="Vahtraste k??la"/><asula kood="9027" nimi="Vanam??isa k??la"/><asula kood="9285" nimi="Viira k??la"/><asula kood="9531" nimi="V??ik??la"/><asula kood="9554" nimi="V??lla k??la"/></vald><vald kood="0483"><asula kood="2178" nimi="Jauni k??la"/><asula kood="2324" nimi="J??rise k??la"/><asula kood="3152" nimi="Kiruma k??la"/><asula kood="3521" nimi="Kugalepa k??la"/><asula kood="3967" nimi="K??dema k??la"/><asula kood="4345" nimi="Liik??la"/><asula kood="4362" nimi="Liiva k??la"/><asula kood="4888" nimi="Merise k??la"/><asula kood="5080" nimi="Mustjala k??la"/><asula kood="5428" nimi="Ninase k??la"/><asula kood="5623" nimi="Ohtja k??la"/><asula kood="5799" nimi="Paatsa k??la"/><asula kood="5847" nimi="Pahapilli k??la"/><asula kood="5973" nimi="Panga k??la"/><asula kood="6734" nimi="Rahtla k??la"/><asula kood="7513" nimi="Selgase k??la"/><asula kood="7596" nimi="Silla k??la"/><asula kood="8053" nimi="Tagaranna k??la"/><asula kood="8406" nimi="Tuiu k??la"/><asula kood="9013" nimi="Vanakubja k??la"/><asula kood="9497" nimi="V??hma k??la"/></vald><vald kood="0550"><asula kood="1348" nimi="Ariste k??la"/><asula kood="1357" nimi="Arju k??la"/><asula kood="1695" nimi="Haapsu k??la"/><asula kood="1853" nimi="Hindu k??la"/><asula kood="2074" nimi="Imavere k??la"/><asula kood="2148" nimi="Jaani k??la"/><asula kood="2356" nimi="J??rvek??la"/><asula kood="2620" nimi="Kalma k??la"/><asula kood="2713" nimi="Kareda k??la"/><asula kood="2888" nimi="Kavandi k??la"/><asula kood="3625" nimi="Kuninguste k??la"/><asula kood="3747" nimi="K??inastu k??la"/><asula kood="4059" nimi="Lahek??la"/><asula kood="4335" nimi="Liigalaskma k??la"/><asula kood="4363" nimi="Liiva k??la"/><asula kood="4712" nimi="Maasi k??la"/><asula kood="4855" nimi="Mehama k??la"/><asula kood="5214" nimi="M??ek??la"/><asula kood="5723" nimi="Orin??mme k??la"/><asula kood="5725" nimi="Orissaare alevik"/><asula kood="6427" nimi="Pulli k??la"/><asula kood="6542" nimi="P??rip??llu k??la"/><asula kood="6794" nimi="Randk??la"/><asula kood="6810" nimi="Rannak??la"/><asula kood="6862" nimi="Raugu k??la"/><asula kood="7345" nimi="Saikla k??la"/><asula kood="7403" nimi="Salu k??la"/><asula kood="7826" nimi="Suur-Pahila k??la"/><asula kood="7827" nimi="Suur-Rahula k??la"/><asula kood="7998" nimi="Taaliku k??la"/><asula kood="8059" nimi="Tagavere k??la"/><asula kood="8412" nimi="Tumala k??la"/><asula kood="9504" nimi="V??hma k??la"/><asula kood="9629" nimi="V??ike-Pahila k??la"/><asula kood="9632" nimi="V??ike-Rahula k??la"/><asula kood="9657" nimi="V??ljak??la"/><asula kood="9804" nimi="????riku k??la"/></vald><vald kood="0592"><asula kood="1564" nimi="Eiste k??la"/><asula kood="1606" nimi="Ennu k??la"/><asula kood="1712" nimi="Haeska k??la"/><asula kood="1939" nimi="H??mmelepa k??la"/><asula kood="2022" nimi="Iilaste k??la"/><asula kood="2056" nimi="Ilpla k??la"/><asula kood="2398" nimi="Kaali k??la"/><asula kood="2538" nimi="Kailuka k??la"/><asula kood="2672" nimi="Kangrusselja k??la"/><asula kood="3138" nimi="Kiritu k??la"/><asula kood="3719" nimi="Kuusiku k??la"/><asula kood="3757" nimi="K??ljala k??la"/><asula kood="3773" nimi="K??nnu k??la"/><asula kood="4061" nimi="Lahek??la"/><asula kood="4233" nimi="Leina k??la"/><asula kood="4365" nimi="Liiva k??la"/><asula kood="4366" nimi="Liiva-Putla k??la"/><asula kood="4803" nimi="Masa k??la"/><asula kood="4826" nimi="Matsiranna k??la"/><asula kood="4894" nimi="Metsak??la"/><asula kood="5089" nimi="Mustla k??la"/><asula kood="5560" nimi="N??ssuma k??la"/><asula kood="6153" nimi="Pihtla k??la"/><asula kood="6653" nimi="P??ha k??la"/><asula kood="6730" nimi="Rahniku k??la"/><asula kood="6818" nimi="Rannak??la"/><asula kood="6899" nimi="Reek??la"/><asula kood="6930" nimi="Reo k??la"/><asula kood="7200" nimi="R??imaste k??la"/><asula kood="7330" nimi="Sagariste k??la"/><asula kood="7375" nimi="Salavere k??la"/><asula kood="7413" nimi="Sandla k??la"/><asula kood="7450" nimi="Sauaru k??la"/><asula kood="7451" nimi="Saue-Putla k??la"/><asula kood="7546" nimi="Sepa k??la"/><asula kood="7822" nimi="Sutu k??la"/><asula kood="7834" nimi="Suure-Rootsi k??la"/><asula kood="8493" nimi="T??lluste k??la"/><asula kood="9022" nimi="Vanam??isa k??la"/><asula kood="9634" nimi="V??ike-Rootsi k??la"/><asula kood="9659" nimi="V??ljak??la"/></vald><vald kood="0634"><asula kood="1337" nimi="Ardla k??la"/><asula kood="1346" nimi="Are k??la"/><asula kood="2103" nimi="Iruste k??la"/><asula kood="2522" nimi="Kahutsi k??la"/><asula kood="2557" nimi="Kakuna k??la"/><asula kood="2878" nimi="Kanissaare k??la"/><asula kood="2988" nimi="Keskvere k??la"/><asula kood="3284" nimi="Koigi k??la"/><asula kood="3807" nimi="K??rkvere k??la"/><asula kood="3922" nimi="K??rneri k??la"/><asula kood="3964" nimi="K??bassaare k??la"/><asula kood="4238" nimi="Leisi k??la"/><asula kood="4310" nimi="Levala k??la"/><asula kood="4909" nimi="Metsara k??la"/><asula kood="5006" nimi="Mui k??la"/><asula kood="5034" nimi="Muraja k??la"/><asula kood="5390" nimi="Neemi k??la"/><asula kood="5401" nimi="Nenu k??la"/><asula kood="5757" nimi="Oti k??la"/><asula kood="6418" nimi="Puka k??la"/><asula kood="6635" nimi="P??ide k??la"/><asula kood="6913" nimi="Reina k??la"/><asula kood="7799" nimi="Sundimetsa k??la"/><asula kood="8084" nimi="Talila k??la"/><asula kood="8336" nimi="Tornim??e k??la"/><asula kood="8652" nimi="Ula k??la"/><asula kood="8693" nimi="Unguma k??la"/><asula kood="8771" nimi="Uuem??isa k??la"/><asula kood="9171" nimi="Veere k??la"/><asula kood="9658" nimi="V??lta k??la"/></vald><vald kood="0689"><asula kood="7105" nimi="Ruhnu k??la"/></vald><vald kood="0721"><asula kood="1297" nimi="Ansek??la"/><asula kood="1514" nimi="Easte k??la"/><asula kood="1855" nimi="Hindu k??la"/><asula kood="2066" nimi="Imara k??la"/><asula kood="2366" nimi="J??rve k??la"/><asula kood="2541" nimi="Kaimri k??la"/><asula kood="2863" nimi="Kaugatoma k??la"/><asula kood="4057" nimi="Lahetaguse k??la"/><asula kood="4129" nimi="Lassi k??la"/><asula kood="4604" nimi="L??mala k??la"/><asula kood="4608" nimi="L??u k??la"/><asula kood="4636" nimi="L??nga k??la"/><asula kood="4661" nimi="L????tsa k??la"/><asula kood="4899" nimi="Metsal??uka k??la"/><asula kood="5140" nimi="M??isak??la"/><asula kood="5308" nimi="M??ldri k??la"/><asula kood="6745" nimi="Rahuste k??la"/><asula kood="7387" nimi="Salme alevik"/><asula kood="7861" nimi="Suurna k??la"/><asula kood="8185" nimi="Tehumardi k??la"/><asula kood="8227" nimi="Tiirimetsa k??la"/><asula kood="8298" nimi="Toomal??uka k??la"/><asula kood="8649" nimi="Ula k??la"/><asula kood="9378" nimi="Vintri k??la"/><asula kood="9855" nimi="????dibe k??la"/></vald><vald kood="0807"><asula kood="1940" nimi="H??nga k??la"/><asula kood="2014" nimi="Iide k??la"/><asula kood="2310" nimi="J??maja k??la"/><asula kood="2442" nimi="Kaavi k??la"/><asula kood="2720" nimi="Kargi k??la"/><asula kood="2785" nimi="Karuste k??la"/><asula kood="2874" nimi="Kaunispe k??la"/><asula kood="4009" nimi="Laadla k??la"/><asula kood="4385" nimi="Lindmetsa k??la"/><asula kood="4609" nimi="L??up??llu k??la"/><asula kood="4666" nimi="L??bara k??la"/><asula kood="4675" nimi="L??lle k??la"/><asula kood="4700" nimi="Maantee k??la"/><asula kood="5134" nimi="M??isak??la"/><asula kood="5155" nimi="M??ntu k??la"/><asula kood="5190" nimi="M??ebe k??la"/><asula kood="5282" nimi="M??ssa k??la"/><asula kood="5621" nimi="Ohessaare k??la"/><asula kood="7689" nimi="Soodevahe k??la"/><asula kood="7950" nimi="S????re k??la"/><asula kood="8128" nimi="Tammuna k??la"/><asula kood="8600" nimi="T??rju k??la"/></vald><vald kood="0858"><asula kood="1349" nimi="Ariste k??la"/><asula kood="2215" nimi="Jursi k??la"/><asula kood="2231" nimi="J??elepa k??la"/><asula kood="2292" nimi="J????ri k??la"/><asula kood="2594" nimi="Kalju k??la"/><asula kood="2603" nimi="Kallem??e k??la"/><asula kood="2605" nimi="Kalli k??la"/><asula kood="3259" nimi="Kogula k??la"/><asula kood="3325" nimi="Koksi k??la"/><asula kood="3544" nimi="Kuiste k??la"/><asula kood="3614" nimi="Kungla k??la"/><asula kood="3774" nimi="K??nnu k??la"/><asula kood="3800" nimi="K??riska k??la"/><asula kood="4665" nimi="L????ne k??la"/><asula kood="5265" nimi="M??nniku k??la"/><asula kood="5476" nimi="Nurme k??la"/><asula kood="5612" nimi="Oessaare k??la"/><asula kood="6534" nimi="P??lluk??la"/><asula kood="6737" nimi="Rahu k??la"/><asula kood="6820" nimi="Rannak??la"/><asula kood="7258" nimi="R????sa k??la"/><asula kood="7351" nimi="Sakla k??la"/><asula kood="7568" nimi="Siiksaare k??la"/><asula kood="8426" nimi="Turja k??la"/><asula kood="8502" nimi="T??nija k??la"/><asula kood="8683" nimi="Undim??e k??la"/><asula kood="8951" nimi="Valjala alevik"/><asula kood="9018" nimi="Vanal??ve k??la"/><asula kood="9172" nimi="Veeriku k??la"/><asula kood="9328" nimi="Vilidu k??la"/><asula kood="9581" nimi="V??rsna k??la"/><asula kood="9642" nimi="V??kra k??la"/><asula kood="9649" nimi="V??ljak??la"/></vald></maakond><maakond kood="0078"><vald kood="0126"><asula kood="1176" nimi="Alasoo k??la"/><asula kood="1181" nimi="Alatskivi alevik"/><asula kood="1694" nimi="Haapsipea k??la"/><asula kood="2979" nimi="Kesklahe k??la"/><asula kood="3323" nimi="Kokora k??la"/><asula kood="3626" nimi="Kuningvere k??la"/><asula kood="3732" nimi="K??desi k??la"/><asula kood="4050" nimi="Lahe k??la"/><asula kood="4055" nimi="Lahepera k??la"/><asula kood="4379" nimi="Linaleo k??la"/><asula kood="5337" nimi="Naelavere k??la"/><asula kood="5427" nimi="Nina k??la"/><asula kood="5709" nimi="Orgem??e k??la"/><asula kood="5807" nimi="Padak??rve k??la"/><asula kood="6026" nimi="Passi k??la"/><asula kood="6057" nimi="Peatskivi k??la"/><asula kood="6458" nimi="Pusi k??la"/><asula kood="6577" nimi="P??iksi k??la"/><asula kood="6623" nimi="P??rsikivi k??la"/><asula kood="6984" nimi="Riidma k??la"/><asula kood="7043" nimi="Ronisoo k??la"/><asula kood="7090" nimi="Rootsik??la"/><asula kood="7127" nimi="Rupsi k??la"/><asula kood="7314" nimi="Saburi k??la"/><asula kood="7484" nimi="Savastvere k??la"/><asula kood="7499" nimi="Savimetsa k??la"/><asula kood="7761" nimi="Sudem??e k??la"/><asula kood="8329" nimi="Torila k??la"/><asula kood="8335" nimi="Toruk??la"/><asula kood="8527" nimi="T??ruvere k??la"/><asula kood="9389" nimi="Virtsu k??la"/><asula kood="9645" nimi="V??ljak??la"/></vald><vald kood="0185"><asula kood="1010" nimi="Aadami k??la"/><asula kood="1024" nimi="Aardla k??la"/><asula kood="1022" nimi="Aardlapalu k??la"/><asula kood="1167" nimi="Alak??la"/><asula kood="1696" nimi="Haaslava k??la"/><asula kood="1997" nimi="Igevere k??la"/><asula kood="2000" nimi="Ignase k??la"/><asula kood="3167" nimi="Kitsek??la"/><asula kood="3315" nimi="Koke k??la"/><asula kood="3500" nimi="Kriimani k??la"/><asula kood="3652" nimi="Kurepalu k??la"/><asula kood="3748" nimi="K??ivuk??la"/><asula kood="4099" nimi="Lange k??la"/><asula kood="4906" nimi="Metsanurga k??la"/><asula kood="5160" nimi="M??ra k??la"/><asula kood="5944" nimi="Paluk??la"/><asula kood="6584" nimi="P??kste k??la"/><asula kood="7042" nimi="Roiu alevik"/><asula kood="8551" nimi="T????raste k??la"/><asula kood="8695" nimi="Unik??la"/></vald><vald kood="0282"><asula kood="1016" nimi="Aakaru k??la"/><asula kood="2119" nimi="Ivaste k??la"/><asula kood="2433" nimi="Kaatsi k??la"/><asula kood="2641" nimi="Kambja alevik"/><asula kood="2644" nimi="Kammeri k??la"/><asula kood="2891" nimi="Kavandu k??la"/><asula kood="3239" nimi="Kodij??rve k??la"/><asula kood="3585" nimi="Kullaga k??la"/><asula kood="3804" nimi="K??rkk??la"/><asula kood="4085" nimi="Lalli k??la"/><asula kood="4720" nimi="Madise k??la"/><asula kood="5194" nimi="M??ek??la"/><asula kood="5690" nimi="Oomiste k??la"/><asula kood="5784" nimi="Paali k??la"/><asula kood="5949" nimi="Palum??e k??la"/><asula kood="5975" nimi="Pangodi k??la"/><asula kood="6426" nimi="Pulli k??la"/><asula kood="6666" nimi="P??hi k??la"/><asula kood="6692" nimi="Raanitsa k??la"/><asula kood="6884" nimi="Rebase k??la"/><asula kood="6935" nimi="Reolasoo k??la"/><asula kood="6994" nimi="Riiviku k??la"/><asula kood="7624" nimi="Sipe k??la"/><asula kood="7642" nimi="Sirvaku k??la"/><asula kood="7793" nimi="Sulu k??la"/><asula kood="7828" nimi="Suure-Kambja k??la"/><asula kood="8085" nimi="Talvikese k??la"/><asula kood="8165" nimi="Tatra k??la"/><asula kood="8992" nimi="Vana-Kuuste k??la"/><asula kood="9404" nimi="Virulase k??la"/><asula kood="9419" nimi="Visnapuu k??la"/></vald><vald kood="0331"><asula kood="1291" nimi="Annikoru k??la"/><asula kood="2699" nimi="Kapsta k??la"/><asula kood="2725" nimi="Karij??rve k??la"/><asula kood="3216" nimi="Kobilu k??la"/><asula kood="3372" nimi="Konguta k??la"/><asula kood="3639" nimi="Kurelaane k??la"/><asula kood="3973" nimi="K??laaseme k??la"/><asula kood="4256" nimi="Lembevere k??la"/><asula kood="4749" nimi="Majala k??la"/><asula kood="4895" nimi="Metsalaane k??la"/><asula kood="5206" nimi="M??eotsa k??la"/><asula kood="5248" nimi="M??lgi k??la"/><asula kood="6322" nimi="Poole k??la"/><asula kood="6648" nimi="P????ritsa k??la"/><asula kood="8846" nimi="Vahessaare k??la"/><asula kood="9191" nimi="Vellavere k??la"/></vald><vald kood="0383"><asula kood="3872" nimi="K??mara k??la"/><asula kood="3900" nimi="K??revere k??la"/><asula kood="4040" nimi="Laeva k??la"/><asula kood="7614" nimi="Sinik??la"/><asula kood="8966" nimi="Valmaotsa k??la"/><asula kood="9688" nimi="V????nikvere k??la"/></vald><vald kood="0432"><asula kood="2458" nimi="Kabina k??la"/><asula kood="2556" nimi="Kakumetsa k??la"/><asula kood="2897" nimi="Kavastu k??la"/><asula kood="3059" nimi="Kikaste k??la"/><asula kood="3749" nimi="K??ivu k??la"/><asula kood="4451" nimi="Lohkva k??la"/><asula kood="4584" nimi="Luunja alevik"/><asula kood="5046" nimi="Muri k??la"/><asula kood="5886" nimi="Pajukurmu k??la"/><asula kood="6249" nimi="Pilka k??la"/><asula kood="6314" nimi="Poksi k??la"/><asula kood="6552" nimi="P??vvatu k??la"/><asula kood="7189" nimi="R????mu k??la"/><asula kood="7479" nimi="Sava k??la"/><asula kood="7491" nimi="Savikoja k??la"/><asula kood="7632" nimi="Sirgu k??la"/><asula kood="7635" nimi="Sirgumetsa k??la"/><asula kood="7958" nimi="S????sek??rva k??la"/><asula kood="7962" nimi="S????sk??la"/><asula kood="9183" nimi="Veibri k??la"/><asula kood="9286" nimi="Viira k??la"/></vald><vald kood="0454"><asula kood="1329" nimi="Aravu k??la"/><asula kood="1705" nimi="Haavametsa k??la"/><asula kood="2241" nimi="J??epera k??la"/><asula kood="2367" nimi="J??rvselja k??la"/><asula kood="4842" nimi="Meeksi k??la"/><asula kood="4854" nimi="Meerapalu k??la"/><asula kood="4859" nimi="Mehikoorma alevik"/><asula kood="5992" nimi="Parapalu k??la"/><asula kood="7161" nimi="R??ka k??la"/><asula kood="7579" nimi="Sikakurmu k??la"/></vald><vald kood="0501"><asula kood="1365" nimi="Aruaia k??la"/><asula kood="2393" nimi="Kaagvere k??la"/><asula kood="2411" nimi="Kaarlim??isa k??la"/><asula kood="2840" nimi="Kastre k??la"/><asula kood="4868" nimi="Melliste k??la"/><asula kood="5240" nimi="M??ksa k??la"/><asula kood="5245" nimi="M??letj??rve k??la"/><asula kood="6311" nimi="Poka k??la"/><asula kood="7423" nimi="Sarakuste k??la"/><asula kood="7764" nimi="Sudaste k??la"/><asula kood="8107" nimi="Tammevaldma k??la"/><asula kood="8211" nimi="Tigase k??la"/><asula kood="8987" nimi="Vana-Kastre k??la"/><asula kood="9234" nimi="Veskim??e k??la"/><asula kood="9583" nimi="V??ruk??la"/><asula kood="9605" nimi="V????pste k??la"/></vald><vald kood="0528"><asula kood="1129" nimi="Aiamaa k??la"/><asula kood="1223" nimi="Altm??e k??la"/><asula kood="1605" nimi="Enno k??la"/><asula kood="1665" nimi="Etsaste k??la"/><asula kood="2039" nimi="Illi k??la"/><asula kood="2327" nimi="J??riste k??la"/><asula kood="2916" nimi="Keeri k??la"/><asula kood="2989" nimi="Ketneri k??la"/><asula kood="3338" nimi="Kolga k??la"/><asula kood="3939" nimi="K????ni k??la"/><asula kood="4046" nimi="Laguja k??la"/><asula kood="4557" nimi="Luke k??la"/><asula kood="4856" nimi="Meeri k??la"/><asula kood="5495" nimi="N??giaru k??la"/><asula kood="5534" nimi="N??o alevik"/><asula kood="7441" nimi="Sassi k??la"/><asula kood="8133" nimi="Tamsa k??la"/><asula kood="8512" nimi="T??ravere alevik"/><asula kood="8698" nimi="Unipiha k??la"/><asula kood="8796" nimi="Uuta k??la"/><asula kood="9423" nimi="Vissi k??la"/><asula kood="9452" nimi="Voika k??la"/></vald><vald kood="0587"><asula kood="2799" nimi="Kasep???? alevik"/><asula kood="3350" nimi="Kolkja alevik"/><asula kood="7500" nimi="Savka k??la"/><asula kood="7627" nimi="Sipelga k??la"/><asula kood="9090" nimi="Varnja alevik"/></vald><vald kood="0595"><asula kood="6185" nimi="Piiri k??la"/><asula kood="7286" nimi="Saare k??la"/><asula kood="8308" nimi="Tooni k??la"/></vald><vald kood="0605"><asula kood="1951" nimi="H??rjanurme k??la"/><asula kood="2348" nimi="J??rvak??la"/><asula kood="2540" nimi="Kaimi k??la"/><asula kood="3633" nimi="Kurek??la"/><asula kood="5138" nimi="M??isanurme k??la"/><asula kood="5211" nimi="M??eselja k??la"/><asula kood="5358" nimi="Nasja k??la"/><asula kood="5957" nimi="Palup??hja k??la"/><asula kood="6328" nimi="Porik??la"/><asula kood="6393" nimi="Puhja alevik"/><asula kood="6955" nimi="Ridak??la"/><asula kood="7208" nimi="R??msi k??la"/><asula kood="7282" nimi="Saare k??la"/><asula kood="8189" nimi="Teilma k??la"/><asula kood="8575" nimi="T??nnassilma k??la"/><asula kood="8655" nimi="Ulila alevik"/><asula kood="9260" nimi="Vihavu k??la"/><asula kood="2842" nimi="V??llinge k??la"/><asula kood="9591" nimi="V??sivere k??la"/></vald><vald kood="0666"><asula kood="1643" nimi="Ervu k??la"/><asula kood="2351" nimi="J??rvek??la"/><asula kood="2409" nimi="Kaarlij??rve k??la"/><asula kood="3103" nimi="Kipastu k??la"/><asula kood="3412" nimi="Koopsi k??la"/><asula kood="3595" nimi="Kulli k??la"/><asula kood="3637" nimi="Kurek??la alevik"/><asula kood="5393" nimi="Neemisk??la"/><asula kood="5447" nimi="Noorma k??la"/><asula kood="5880" nimi="Paju k??la"/><asula kood="6822" nimi="Rannu alevik"/><asula kood="7420" nimi="Sangla k??la"/><asula kood="7833" nimi="Suure-Rakke k??la"/><asula kood="8094" nimi="Tamme k??la"/><asula kood="8750" nimi="Utukolga k??la"/><asula kood="8959" nimi="Vallapalu k??la"/><asula kood="9178" nimi="Vehendi k??la"/><asula kood="9211" nimi="Verevi k??la"/><asula kood="9633" nimi="V??ike-Rakke k??la"/></vald><vald kood="0694"><asula kood="2622" nimi="Kalme k??la"/><asula kood="3121" nimi="Kirepi k??la"/><asula kood="3457" nimi="Koruste k??la"/><asula kood="3738" nimi="K??duk??la"/><asula kood="3881" nimi="K??o k??la"/><asula kood="3949" nimi="K????rdi alevik"/><asula kood="4117" nimi="Lapetukme k??la"/><asula kood="4527" nimi="Lossim??e k??la"/><asula kood="6164" nimi="Piigandi k??la"/><asula kood="6748" nimi="Raigaste k??la"/><asula kood="6809" nimi="Rannak??la"/><asula kood="7167" nimi="R??ngu alevik"/><asula kood="8121" nimi="Tammiste k??la"/><asula kood="8180" nimi="Teedla k??la"/><asula kood="8238" nimi="Tilga k??la"/><asula kood="8614" nimi="Uderna k??la"/><asula kood="8941" nimi="Valguta k??la"/></vald><vald kood="0794"><asula kood="1312" nimi="Aovere k??la"/><asula kood="1383" nimi="Arup???? k??la"/><asula kood="1617" nimi="Erala k??la"/><asula kood="1699" nimi="Haava k??la"/><asula kood="1993" nimi="Igavere k??la"/><asula kood="2286" nimi="J??usa k??la"/><asula kood="2829" nimi="Kastli k??la"/><asula kood="3064" nimi="Kikivere k??la"/><asula kood="3221" nimi="Kobratu k??la"/><asula kood="3572" nimi="Kukulinna k??la"/><asula kood="3824" nimi="K??rvek??la alevik"/><asula kood="3911" nimi="K??rkna k??la"/><asula kood="3970" nimi="K??kitaja k??la"/><asula kood="4093" nimi="Lammiku k??la"/><asula kood="4487" nimi="Lombi k??la"/><asula kood="4629" nimi="L??hte alevik"/><asula kood="4779" nimi="Maramaa k??la"/><asula kood="4900" nimi="Metsanuka k??la"/><asula kood="5310" nimi="M??llatsi k??la"/><asula kood="5408" nimi="Nigula k??la"/><asula kood="5492" nimi="N??ela k??la"/><asula kood="6401" nimi="Puhtaleiva k??la"/><asula kood="6437" nimi="Pupastvere k??la"/><asula kood="7273" nimi="Saadj??rve k??la"/><asula kood="7393" nimi="Salu k??la"/><asula kood="7655" nimi="Soek??la"/><asula kood="7668" nimi="Soitsj??rve k??la"/><asula kood="7671" nimi="Sojamaa k??la"/><asula kood="7745" nimi="Sootaga k??la"/><asula kood="7988" nimi="Taabri k??la"/><asula kood="8123" nimi="Tammistu k??la"/><asula kood="8235" nimi="Tila k??la"/><asula kood="8290" nimi="Toolamaa k??la"/><asula kood="8850" nimi="Vahi alevik"/><asula kood="9136" nimi="Vasula alevik"/><asula kood="9161" nimi="Vedu k??la"/><asula kood="9240" nimi="Vesneri k??la"/><asula kood="9273" nimi="Viidike k??la"/><asula kood="9367" nimi="Vilussaare k??la"/><asula kood="9514" nimi="V??ibla k??la"/><asula kood="9680" nimi="V????gvere k??la"/><asula kood="9728" nimi="??vi k??la"/><asula kood="9748" nimi="??ksi alevik"/></vald><vald kood="0831"><asula kood="1681" nimi="Haage k??la"/><asula kood="2050" nimi="Ilmatsalu alevik"/><asula kood="2049" nimi="Ilmatsalu k??la"/><asula kood="2659" nimi="Kandik??la"/><asula kood="2710" nimi="Kardla k??la"/><asula kood="5277" nimi="M??rja alevik"/><asula kood="6155" nimi="Pihva k??la"/><asula kood="6724" nimi="Rahinge k??la"/><asula kood="7158" nimi="R??hu k??la"/><asula kood="8560" nimi="T??htvere k??la"/><asula kood="8590" nimi="T??ki k??la"/><asula kood="9483" nimi="Vorbuse k??la"/></vald><vald kood="0861"><asula kood="1166" nimi="Alaj??e k??la"/><asula kood="2717" nimi="Kargaja k??la"/><asula kood="2858" nimi="Kauda k??la"/><asula kood="2966" nimi="Keressaare k??la"/><asula kood="3425" nimi="Koosa k??la"/><asula kood="3427" nimi="Koosalaane k??la"/><asula kood="3703" nimi="Kusma k??la"/><asula kood="3721" nimi="Kuusiku k??la"/><asula kood="4816" nimi="Matjama k??la"/><asula kood="4871" nimi="Meoma k??la"/><asula kood="4889" nimi="Metsakivi k??la"/><asula kood="5065" nimi="Mustametsa k??la"/><asula kood="5981" nimi="Papiaru k??la"/><asula kood="6259" nimi="Pilpak??la"/><asula kood="6342" nimi="Praaga k??la"/><asula kood="6488" nimi="P??dra k??la"/><asula kood="6515" nimi="P??ldmaa k??la"/><asula kood="6544" nimi="P??rgu k??la"/><asula kood="6902" nimi="Rehemetsa k??la"/><asula kood="7516" nimi="Selgise k??la"/><asula kood="7703" nimi="Sookalduse k??la"/><asula kood="7938" nimi="S??rgla k??la"/><asula kood="8555" nimi="T??hemaa k??la"/><asula kood="8687" nimi="Undi k??la"/><asula kood="9031" nimi="Vanaussaia k??la"/><asula kood="9053" nimi="Vara k??la"/><asula kood="9644" nimi="V??lgi k??la"/><asula kood="9790" nimi="??tte k??la"/></vald><vald kood="0915"><asula kood="1097" nimi="Agali k??la"/><asula kood="1125" nimi="Ahunapalu k??la"/><asula kood="1752" nimi="Hammaste k??la"/><asula kood="2076" nimi="Imste k??la"/><asula kood="2112" nimi="Issaku k??la"/><asula kood="2682" nimi="Kannu k??la"/><asula kood="3677" nimi="Kurista k??la"/><asula kood="3772" nimi="K??nnu k??la"/><asula kood="4349" nimi="Liisp??llu k??la"/><asula kood="4658" nimi="L????niste k??la"/><asula kood="7066" nimi="Rookse k??la"/><asula kood="8201" nimi="Terikeste k??la"/><asula kood="9570" nimi="V??nnu alevik"/></vald><vald kood="0949"><asula kood="3986" nimi="K??litse alevik"/><asula kood="4017" nimi="Laane k??la"/><asula kood="4266" nimi="Lemmatsi k??la"/><asula kood="4291" nimi="Lepiku k??la"/><asula kood="4648" nimi="L??ti k??la"/><asula kood="6932" nimi="Reola k??la"/><asula kood="7214" nimi="R??ni alevik"/><asula kood="7666" nimi="Soinaste k??la"/><asula kood="7743" nimi="Soosilla k??la"/><asula kood="8532" nimi="T??rvandi alevik"/><asula kood="8581" nimi="T??svere k??la"/><asula kood="8632" nimi="Uhti k??la"/><asula kood="9717" nimi="??ssu k??la"/><asula kood="9835" nimi="??lenurme alevik"/></vald></maakond><maakond kood="0082"><vald kood="0203"><asula kood="1160" nimi="Ala k??la"/><asula kood="1815" nimi="Helme alevik"/><asula kood="1883" nimi="Holdre k??la"/><asula kood="2264" nimi="J??geveste k??la"/><asula kood="2623" nimi="Kalme k??la"/><asula kood="2757" nimi="Karjatnurme k??la"/><asula kood="3124" nimi="Kirikuk??la"/><asula kood="3420" nimi="Koork??la"/><asula kood="3866" nimi="K??hu k??la"/><asula kood="4390" nimi="Linna k??la"/><asula kood="5304" nimi="M??ldre k??la"/><asula kood="6042" nimi="Patk??la"/><asula kood="6257" nimi="Pilpa k??la"/><asula kood="7053" nimi="Roobe k??la"/><asula kood="7993" nimi="Taagepera k??la"/></vald><vald kood="0208"><asula kood="1152" nimi="Aitsra k??la"/><asula kood="1171" nimi="Alam??isa k??la"/><asula kood="1905" nimi="Hummuli alevik"/><asula kood="2187" nimi="Jeti k??la"/><asula kood="3596" nimi="Kulli k??la"/><asula kood="6186" nimi="Piiri k??la"/><asula kood="6408" nimi="Puide k??la"/><asula kood="6824" nimi="Ransi k??la"/><asula kood="7654" nimi="Soe k??la"/></vald><vald kood="0289"><asula kood="2384" nimi="Kaagj??rve k??la"/><asula kood="2775" nimi="Karula k??la"/><asula kood="3116" nimi="Kirbu k??la"/><asula kood="3383" nimi="Koobassaare k??la"/><asula kood="3951" nimi="K????rikm??e k??la"/><asula kood="4493" nimi="Londi k??la"/><asula kood="4563" nimi="Lusti k??la"/><asula kood="4677" nimi="L??llem??e k??la"/><asula kood="6234" nimi="Pikkj??rve k??la"/><asula kood="6388" nimi="Pugritsa k??la"/><asula kood="6702" nimi="Raavitsa k??la"/><asula kood="6887" nimi="Rebasem??isa k??la"/><asula kood="8969" nimi="Valtina k??la"/><asula kood="9618" nimi="V??heru k??la"/></vald><vald kood="0636"><asula kood="1376" nimi="Arula k??la"/><asula kood="2053" nimi="Ilmj??rve k??la"/><asula kood="2820" nimi="Kassiratta k??la"/><asula kood="2837" nimi="Kastolatsi k??la"/><asula kood="2880" nimi="Kaurutootsi k??la"/><asula kood="3286" nimi="Koigu k??la"/><asula kood="3954" nimi="K????riku k??la"/><asula kood="5219" nimi="M??gestiku k??la"/><asula kood="5232" nimi="M??ha k??la"/><asula kood="5279" nimi="M??rdi k??la"/><asula kood="5566" nimi="N??pli k??la"/><asula kood="5753" nimi="Otep???? k??la"/><asula kood="5754" nimi="Otep???? linn"/><asula kood="6060" nimi="Pedajam??e k??la"/><asula kood="6252" nimi="Pilkuse k??la"/><asula kood="6658" nimi="P??haj??rve k??la"/><asula kood="6857" nimi="Raudsepa k??la"/><asula kood="7565" nimi="Sihva k??la"/><asula kood="8356" nimi="Truuta k??la"/><asula kood="8546" nimi="T??utsi k??la"/><asula kood="8999" nimi="Vana-Otep???? k??la"/><asula kood="9252" nimi="Vidrike k??la"/></vald><vald kood="0582"><asula kood="1418" nimi="Astuvere k??la"/><asula kood="1440" nimi="Atra k??la"/><asula kood="1813" nimi="Hellenurme k??la"/><asula kood="4573" nimi="Lutike k??la"/><asula kood="4751" nimi="Makita k??la"/><asula kood="4959" nimi="Miti k??la"/><asula kood="5198" nimi="M??elooga k??la"/><asula kood="5396" nimi="Neeruti k??la"/><asula kood="5540" nimi="N??uni k??la"/><asula kood="5952" nimi="Palupera k??la"/><asula kood="6031" nimi="Pastaku k??la"/><asula kood="6570" nimi="P??idla k??la"/><asula kood="7195" nimi="R??bi k??la"/><asula kood="8727" nimi="Urmi k??la"/></vald><vald kood="0608"><asula kood="1018" nimi="Aakre k??la"/><asula kood="2998" nimi="Kibena k??la"/><asula kood="3353" nimi="Kolli k??la"/><asula kood="3369" nimi="Komsi k??la"/><asula kood="3534" nimi="Kuigatsi k??la"/><asula kood="3864" nimi="K??hri k??la"/><asula kood="4837" nimi="Meegaste k??la"/><asula kood="5916" nimi="Palamuste k??la"/><asula kood="6071" nimi="Pedaste k??la"/><asula kood="6296" nimi="Plika k??la"/><asula kood="6352" nimi="Prange k??la"/><asula kood="6417" nimi="Puka alevik"/><asula kood="6453" nimi="Purtsi k??la"/><asula kood="6549" nimi="P??ru k??la"/><asula kood="6663" nimi="P??haste k??la"/><asula kood="6890" nimi="Rebaste k??la"/><asula kood="7148" nimi="Ruuna k??la"/><asula kood="7730" nimi="Soontaga k??la"/><asula kood="8808" nimi="Vaardi k??la"/></vald><vald kood="0613"><asula kood="2772" nimi="Karu k??la"/><asula kood="2856" nimi="Kaubi k??la"/><asula kood="3611" nimi="Kungi k??la"/><asula kood="4173" nimi="Leebiku k??la"/><asula kood="4433" nimi="Liva k??la"/><asula kood="4620" nimi="L??ve k??la"/><asula kood="6222" nimi="Pikasilla k??la"/><asula kood="6330" nimi="Pori k??la"/><asula kood="6946" nimi="Reti k??la"/><asula kood="6976" nimi="Riidaja k??la"/><asula kood="7113" nimi="Rulli k??la"/><asula kood="8714" nimi="Uralaane k??la"/><asula kood="9025" nimi="Vanam??isa k??la"/><asula kood="9464" nimi="Voorbahi k??la"/></vald><vald kood="0724"><asula kood="2914" nimi="Keeni k??la"/><asula kood="3663" nimi="Kurevere k??la"/><asula kood="4146" nimi="Lauk??la"/><asula kood="4525" nimi="Lossik??la"/><asula kood="5195" nimi="M??ek??la"/><asula kood="5229" nimi="M??giste k??la"/><asula kood="6371" nimi="Pringi k??la"/><asula kood="6943" nimi="Restu k??la"/><asula kood="7018" nimi="Risttee k??la"/><asula kood="7418" nimi="Sangaste alevik"/><asula kood="7426" nimi="Sarapuu k??la"/><asula kood="8219" nimi="Tiidu k??la"/><asula kood="8806" nimi="Vaalu k??la"/><asula kood="9733" nimi="??du k??la"/></vald><vald kood="0779"><asula kood="1766" nimi="Hargla k??la"/><asula kood="2609" nimi="Kallik??la"/><asula kood="3289" nimi="Koikk??la"/><asula kood="3304" nimi="Koiva k??la"/><asula kood="3452" nimi="Korkuna k??la"/><asula kood="4024" nimi="Laanemetsa k??la"/><asula kood="4281" nimi="Lepa k??la"/><asula kood="4576" nimi="Lutsu k??la"/><asula kood="7005" nimi="Ringiste k??la"/><asula kood="7686" nimi="Sooblase k??la"/><asula kood="8069" nimi="Taheva k??la"/><asula kood="8368" nimi="Tsirgum??e k??la"/><asula kood="8535" nimi="T??rvase k??la"/></vald><vald kood="0820"><asula kood="2016" nimi="Iigaste k??la"/><asula kood="2137" nimi="Jaanikese k??la"/><asula kood="3447" nimi="Korij??rve k??la"/><asula kood="4029" nimi="Laatre alevik"/><asula kood="5003" nimi="Muhkva k??la"/><asula kood="5881" nimi="Paju k??la"/><asula kood="6786" nimi="Rampe k??la"/><asula kood="7738" nimi="Sooru k??la"/><asula kood="7801" nimi="Supa k??la"/><asula kood="8064" nimi="Tagula k??la"/><asula kood="8248" nimi="Tinu k??la"/><asula kood="8365" nimi="Tsirguliina alevik"/><asula kood="8491" nimi="T??lliste k??la"/><asula kood="9326" nimi="Vilaski k??la"/><asula kood="9651" nimi="V??ljak??la"/></vald><vald kood="0943"><asula kood="3087" nimi="Killinge k??la"/><asula kood="3180" nimi="Kivik??la"/><asula kood="4530" nimi="Lota k??la"/><asula kood="5096" nimi="Mustumetsa k??la"/><asula kood="6365" nimi="Priipalu k??la"/><asula kood="8696" nimi="Unik??la"/><asula kood="9699" nimi="??latu k??la"/><asula kood="9710" nimi="??ru alevik"/><asula kood="9713" nimi="??ruste k??la"/></vald></maakond><maakond kood="0084"><vald kood="0105"><asula kood="1061" nimi="Abjaku k??la"/><asula kood="1060" nimi="Abja-Paluoja linn"/><asula kood="8593" nimi="Abja-Vanam??isa k??la"/><asula kood="1433" nimi="Atika k??la"/><asula kood="2634" nimi="Kamara k??la"/><asula kood="4030" nimi="Laatre k??la"/><asula kood="4120" nimi="Lasari k??la"/><asula kood="6106" nimi="Penuja k??la"/><asula kood="6510" nimi="P??lde k??la"/><asula kood="6689" nimi="Raamatu k??la"/><asula kood="7238" nimi="R????gu k??la"/><asula kood="7313" nimi="Saate k??la"/><asula kood="7433" nimi="Sarja k??la"/><asula kood="8672" nimi="Umbsoo k??la"/><asula kood="9167" nimi="Veelikse k??la"/><asula kood="9235" nimi="Veskim??e k??la"/></vald><vald kood="0192"><asula kood="1625" nimi="Ereste k??la"/><asula kood="1749" nimi="Halliste alevik"/><asula kood="1926" nimi="H??bem??e k??la"/><asula kood="2406" nimi="Kaarli k??la"/><asula kood="2628" nimi="Kalvre k??la"/><asula kood="3580" nimi="Kulla k??la"/><asula kood="4802" nimi="Maru k??la"/><asula kood="5020" nimi="Mulgi k??la"/><asula kood="5178" nimi="M????naste k??la"/><asula kood="5349" nimi="Naistevalla k??la"/><asula kood="5411" nimi="Niguli k??la"/><asula kood="6335" nimi="Pornuse k??la"/><asula kood="6572" nimi="P??idre k??la"/><asula kood="6575" nimi="P??igiste k??la"/><asula kood="6765" nimi="Raja k??la"/><asula kood="7002" nimi="Rimmu k??la"/><asula kood="7356" nimi="Saksak??la"/><asula kood="7410" nimi="Sammaste k??la"/><asula kood="8240" nimi="Tilla k??la"/><asula kood="8310" nimi="Toosi k??la"/><asula kood="8759" nimi="Uue-Kariste k??la"/><asula kood="8816" nimi="Vabamatsi k??la"/><asula kood="8984" nimi="Vana-Kariste k??la"/><asula kood="9695" nimi="??isu alevik"/><asula kood="9830" nimi="??lem??isa k??la"/></vald><vald kood="0600"><asula kood="1149" nimi="Ainja k??la"/><asula kood="1199" nimi="Allaste k??la"/><asula kood="1868" nimi="Hirmuk??la"/><asula kood="2759" nimi="Karksi k??la"/><asula kood="2761" nimi="Karksi-Nuia linn"/><asula kood="3837" nimi="K??vak??la"/><asula kood="4183" nimi="Leeli k??la"/><asula kood="4370" nimi="Lilli k??la"/><asula kood="4893" nimi="Metsak??la"/><asula kood="4989" nimi="Morna k??la"/><asula kood="5047" nimi="Muri k??la"/><asula kood="7211" nimi="M??ek??la"/><asula kood="5758" nimi="Oti k??la"/><asula kood="6317" nimi="Polli k??la"/><asula kood="6621" nimi="P??rsi k??la"/><asula kood="6641" nimi="P????gle k??la"/><asula kood="7767" nimi="Sudiste k??la"/><asula kood="7825" nimi="Suuga k??la"/><asula kood="8398" nimi="Tuhalaane k??la"/><asula kood="8701" nimi="Univere k??la"/><asula kood="9780" nimi="??rik??la"/></vald><vald kood="0328"><asula kood="1539" nimi="Eesnurga k??la"/><asula kood="2338" nimi="J??rtsaare k??la"/><asula kood="2439" nimi="Kaavere k??la"/><asula kood="3340" nimi="Kolga-Jaani alevik"/><asula kood="4088" nimi="Lalsi k??la"/><asula kood="4225" nimi="Leie k??la"/><asula kood="4650" nimi="L??tkalu k??la"/><asula kood="4865" nimi="Meleski k??la"/><asula kood="5595" nimi="Odiste k??la"/><asula kood="5647" nimi="Oiu k??la"/><asula kood="5701" nimi="Oorgu k??la"/><asula kood="5763" nimi="Otik??la"/><asula kood="6007" nimi="Parika k??la"/><asula kood="8050" nimi="Taganurga k??la"/><asula kood="8864" nimi="Vaibla k??la"/><asula kood="9426" nimi="Vissuvere k??la"/></vald><vald kood="0357"><asula kood="1356" nimi="Arjassaare k??la"/><asula kood="1386" nimi="Arussaare k??la"/><asula kood="2674" nimi="Kangrussaare k??la"/><asula kood="3142" nimi="Kirivere k??la"/><asula kood="3328" nimi="Koksvere k??la"/><asula kood="3775" nimi="K??o k??la"/><asula kood="4514" nimi="Loopre k??la"/><asula kood="4699" nimi="Maalasti k??la"/><asula kood="5781" nimi="Paaksima k??la"/><asula kood="5833" nimi="Paenasti k??la"/><asula kood="6247" nimi="Pilistvere k??la"/><asula kood="7489" nimi="Saviaugu k??la"/><asula kood="7720" nimi="Soomevere k??la"/><asula kood="8681" nimi="Unakvere k??la"/><asula kood="9205" nimi="Venevere k??la"/></vald><vald kood="0360"><asula kood="2013" nimi="Iia k??la"/><asula kood="3619" nimi="Kuninga k??la"/><asula kood="3782" nimi="K??pu alevik"/><asula kood="4018" nimi="Laane k??la"/><asula kood="6429" nimi="Punak??la"/><asula kood="7550" nimi="Seruk??la"/><asula kood="7804" nimi="Supsi k??la"/><asula kood="8251" nimi="Tipu k??la"/><asula kood="8641" nimi="Uia k??la"/><asula kood="9036" nimi="Vanaveski k??la"/></vald><vald kood="0758"><asula kood="1144" nimi="Aimla k??la"/><asula kood="1354" nimi="Arjadi k??la"/><asula kood="1613" nimi="Epra k??la"/><asula kood="2033" nimi="Ilbaku k??la"/><asula kood="2116" nimi="Ivaski k??la"/><asula kood="2175" nimi="Jaska k??la"/><asula kood="2304" nimi="J??levere k??la"/><asula kood="2456" nimi="Kabila k??la"/><asula kood="2754" nimi="Karjasoo k??la"/><asula kood="2973" nimi="Kerita k??la"/><asula kood="2993" nimi="Kibaru k??la"/><asula kood="3079" nimi="Kildu k??la"/><asula kood="3226" nimi="Kobruvere k??la"/><asula kood="3430" nimi="Kootsi k??la"/><asula kood="3523" nimi="Kuhjavere k??la"/><asula kood="3529" nimi="Kuiavere k??la"/><asula kood="3690" nimi="Kurnuvere k??la"/><asula kood="3741" nimi="K??idama k??la"/><asula kood="3901" nimi="K??revere k??la"/><asula kood="4060" nimi="Lahmuse k??la"/><asula kood="4261" nimi="Lemmak??nnu k??la"/><asula kood="4598" nimi="L??havere k??la"/><asula kood="4925" nimi="Metsk??la"/><asula kood="4998" nimi="Mudiste k??la"/><asula kood="5031" nimi="Munsi k??la"/><asula kood="5196" nimi="M??ek??la"/><asula kood="5375" nimi="Navesti k??la"/><asula kood="5488" nimi="Nuutre k??la"/><asula kood="5669" nimi="Olustvere alevik"/><asula kood="5828" nimi="Paelama k??la"/><asula kood="6502" nimi="P??hjaka k??la"/><asula kood="6596" nimi="P??rak??la"/><asula kood="6897" nimi="Reegoldi k??la"/><asula kood="6974" nimi="Riiassaare k??la"/><asula kood="7240" nimi="R????ka k??la"/><asula kood="7415" nimi="Sandra k??la"/><asula kood="7836" nimi="Suure-Jaani linn"/><asula kood="7978" nimi="S??rgavere k??la"/><asula kood="8030" nimi="Taevere k??la"/><asula kood="8566" nimi="T??llevere k??la"/><asula kood="8586" nimi="T????ksi k??la"/><asula kood="9123" nimi="Vastem??isa k??la"/><asula kood="9262" nimi="Vihi k??la"/><asula kood="9503" nimi="V??hmassaare k??la"/><asula kood="9546" nimi="V??ivaku k??la"/><asula kood="9561" nimi="V??lli k??la"/><asula kood="9765" nimi="??ngi k??la"/><asula kood="9824" nimi="??lde k??la"/></vald><vald kood="0797"><asula kood="1283" nimi="Anikatsi k??la"/><asula kood="2153" nimi="Jakobim??isa k??la"/><asula kood="2355" nimi="J??rvek??la"/><asula kood="2570" nimi="Kalbuse k??la"/><asula kood="2685" nimi="Kannuk??la"/><asula kood="3185" nimi="Kivil??ppe k??la"/><asula kood="3275" nimi="Koidu k??la"/><asula kood="3658" nimi="Kuressaare k??la"/><asula kood="3927" nimi="K??rstna k??la"/><asula kood="4763" nimi="Maltsa k??la"/><asula kood="4789" nimi="Marjam??e k??la"/><asula kood="4928" nimi="Metsla k??la"/><asula kood="5017" nimi="Muksi k??la"/><asula kood="5086" nimi="Mustla alevik"/><asula kood="5152" nimi="M??nnaste k??la"/><asula kood="5859" nimi="Pahuvere k??la"/><asula kood="6239" nimi="Pikru k??la"/><asula kood="6338" nimi="Porsa k??la"/><asula kood="6541" nimi="P??rga k??la"/><asula kood="6697" nimi="Raassilla k??la"/><asula kood="7024" nimi="Riuma k??la"/><asula kood="7076" nimi="Roosilla k??la"/><asula kood="7653" nimi="Soe k??la"/><asula kood="7750" nimi="Sooviku k??la"/><asula kood="7779" nimi="Suislepa k??la"/><asula kood="8048" nimi="Tagam??isa k??la"/><asula kood="8159" nimi="Tarvastu k??la"/><asula kood="8246" nimi="Tinnikuru k??la"/><asula kood="8684" nimi="Unametsa k??la"/><asula kood="9034" nimi="Vanausse k??la"/><asula kood="9186" nimi="Veisj??rve k??la"/><asula kood="9331" nimi="Vilimeeste k??la"/><asula kood="9344" nimi="Villa k??la"/><asula kood="9477" nimi="Vooru k??la"/><asula kood="9661" nimi="V??luste k??la"/><asula kood="9758" nimi="??mmuste k??la"/><asula kood="9833" nimi="??lensi k??la"/></vald><vald kood="0898"><asula kood="1138" nimi="Aidu k??la"/><asula kood="1147" nimi="Aindu k??la"/><asula kood="1240" nimi="Alustre k??la"/><asula kood="1461" nimi="Auksi k??la"/><asula kood="1794" nimi="Heimtali k??la"/><asula kood="1821" nimi="Hendrikum??isa k??la"/><asula kood="1888" nimi="Holstre k??la"/><asula kood="2093" nimi="Intsu k??la"/><asula kood="2229" nimi="J??ek??la"/><asula kood="2312" nimi="J??mejala k??la"/><asula kood="2776" nimi="Karula k??la"/><asula kood="2813" nimi="Kassi k??la"/><asula kood="2996" nimi="Kibek??la"/><asula kood="3042" nimi="Kiini k??la"/><asula kood="3047" nimi="Kiisa k??la"/><asula kood="3100" nimi="Kingu k??la"/><asula kood="3313" nimi="Kokaviidika k??la"/><asula kood="3396" nimi="Kookla k??la"/><asula kood="3711" nimi="Kuudek??la"/><asula kood="4021" nimi="Laanekuru k??la"/><asula kood="4185" nimi="Leemeti k??la"/><asula kood="4462" nimi="Loime k??la"/><asula kood="4484" nimi="Lolu k??la"/><asula kood="4501" nimi="Loodi k??la"/><asula kood="4548" nimi="Luiga k??la"/><asula kood="4794" nimi="Marna k??la"/><asula kood="4814" nimi="Matapera k??la"/><asula kood="4981" nimi="Moori k??la"/><asula kood="5070" nimi="Mustapali k??la"/><asula kood="5075" nimi="Mustivere k??la"/><asula kood="5201" nimi="M??eltk??la"/><asula kood="5237" nimi="M??hma k??la"/><asula kood="5872" nimi="Paistu k??la"/><asula kood="6090" nimi="Peetrim??isa k??la"/><asula kood="6271" nimi="Pinska k??la"/><asula kood="6276" nimi="Pirmastu k??la"/><asula kood="6406" nimi="Puiatu k??la"/><asula kood="6423" nimi="Pulleritsu k??la"/><asula kood="6601" nimi="P??ri k??la"/><asula kood="6626" nimi="P??rsti k??la"/><asula kood="6789" nimi="Ramsi alevik"/><asula kood="6852" nimi="Raudna k??la"/><asula kood="6885" nimi="Rebase k??la"/><asula kood="6891" nimi="Rebaste k??la"/><asula kood="6956" nimi="Ridak??la"/><asula kood="6971" nimi="Rihkama k??la"/><asula kood="7143" nimi="Ruudik??la"/><asula kood="7290" nimi="Saarek??la"/><asula kood="7295" nimi="Saarepeedi k??la"/><asula kood="7494" nimi="Savikoti k??la"/><asula kood="7611" nimi="Sinialliku k??la"/><asula kood="7790" nimi="Sultsi k??la"/><asula kood="7812" nimi="Surva k??la"/><asula kood="8003" nimi="Taari k??la"/><asula kood="8264" nimi="Tobraselja k??la"/><asula kood="8272" nimi="Tohvri k??la"/><asula kood="8431" nimi="Turva k??la"/><asula kood="8439" nimi="Tusti k??la"/><asula kood="8504" nimi="T??nissaare k??la"/><asula kood="8507" nimi="T??nuk??la"/><asula kood="8522" nimi="T??rrek??la"/><asula kood="8569" nimi="T??nassilma k??la"/><asula kood="8496" nimi="T??mbi k??la"/><asula kood="8790" nimi="Uusna k??la"/><asula kood="8964" nimi="Valma k??la"/><asula kood="9026" nimi="Vanam??isa k??la"/><asula kood="9012" nimi="Vana-V??idu k??la"/><asula kood="9039" nimi="Vanav??lja k??la"/><asula kood="9068" nimi="Vardi k??la"/><asula kood="9073" nimi="Vardja k??la"/><asula kood="9103" nimi="Vasara k??la"/><asula kood="9221" nimi="Verilaske k??la"/><asula kood="9292" nimi="Viiratsi alevik"/><asula kood="9305" nimi="Viisuk??la"/><asula kood="9541" nimi="V??istre k??la"/><asula kood="9626" nimi="V??ike-K??pu k??la"/><asula kood="9646" nimi="V??lgita k??la"/></vald></maakond><maakond kood="0086"><vald kood="0143"><asula kood="1288" nimi="Anne k??la"/><asula kood="1301" nimi="Antsla linn"/><asula kood="1303" nimi="Antsu k??la"/><asula kood="1678" nimi="Haabsaare k??la"/><asula kood="2242" nimi="J??epera k??la"/><asula kood="2535" nimi="Kaika k??la"/><asula kood="3069" nimi="Kikkaoja k??la"/><asula kood="3214" nimi="Kobela alevik"/><asula kood="3355" nimi="Kollino k??la"/><asula kood="3486" nimi="Kraavi k??la"/><asula kood="4427" nimi="Litsmetsa k??la"/><asula kood="4543" nimi="Luhametsa k??la"/><asula kood="4564" nimi="Lusti k??la"/><asula kood="4721" nimi="Madise k??la"/><asula kood="5234" nimi="M??hkli k??la"/><asula kood="5605" nimi="Oe k??la"/><asula kood="6196" nimi="Piisi k??la"/><asula kood="7000" nimi="Rimmi k??la"/><asula kood="7073" nimi="Roosiku k??la"/><asula kood="7496" nimi="Savil????vi k??la"/><asula kood="7714" nimi="Soome k??la"/><asula kood="7933" nimi="S??re k??la"/><asula kood="8011" nimi="Taberlaane k??la"/><asula kood="8378" nimi="Tsooru k??la"/><asula kood="8977" nimi="Vana-Antsla alevik"/><asula kood="9290" nimi="Viirapalu k??la"/><asula kood="9737" nimi="??hij??rve k??la"/></vald><vald kood="0181"><asula kood="1161" nimi="Ala-Palo k??la"/><asula kood="1164" nimi="Ala-Suhka k??la"/><asula kood="1162" nimi="Ala-Tilga k??la"/><asula kood="1262" nimi="Andsum??e k??la"/><asula kood="1689" nimi="Haanja k??la"/><asula kood="1703" nimi="Haavistu k??la"/><asula kood="1750" nimi="Hanija k??la"/><asula kood="1881" nimi="Holdi k??la"/><asula kood="1890" nimi="Horoski k??la"/><asula kood="1895" nimi="Hulaku k??la"/><asula kood="1909" nimi="Hurda k??la"/><asula kood="1933" nimi="H??mkoti k??la"/><asula kood="2008" nimi="Ihatsi k??la"/><asula kood="2145" nimi="Jaanim??e k??la"/><asula kood="2401" nimi="Kaaratautsa k??la"/><asula kood="2571" nimi="Kaldem??e k??la"/><asula kood="2595" nimi="Kallaste k??la"/><asula kood="2625" nimi="Kaloga k??la"/><asula kood="2968" nimi="Kergatsi k??la"/><asula kood="3089" nimi="Kilomani k??la"/><asula kood="3115" nimi="Kirbu k??la"/><asula kood="3478" nimi="Kotka k??la"/><asula kood="3493" nimi="Kriguli k??la"/><asula kood="3522" nimi="Kuiandi k??la"/><asula kood="3559" nimi="Kuklase k??la"/><asula kood="3713" nimi="Kuura k??la"/><asula kood="3780" nimi="K??om??e k??la"/><asula kood="3941" nimi="K????nu k??la"/><asula kood="3946" nimi="K????raku k??la"/><asula kood="3990" nimi="K??lma k??la"/><asula kood="4277" nimi="Leoski k??la"/><asula kood="4372" nimi="Lillim??isa k??la"/><asula kood="4502" nimi="Loogam??e k??la"/><asula kood="4591" nimi="Luutsniku k??la"/><asula kood="4693" nimi="L????tsep?? k??la"/><asula kood="4731" nimi="Mahtja k??la"/><asula kood="4760" nimi="Mallika k??la"/><asula kood="4846" nimi="Meelaku k??la"/><asula kood="4946" nimi="Miilim??e k??la"/><asula kood="4949" nimi="Mikita k??la"/><asula kood="5041" nimi="Murati k??la"/><asula kood="5054" nimi="Mustahamba k??la"/><asula kood="5187" nimi="M??e-Palo k??la"/><asula kood="7773" nimi="M??e-Suhka k??la"/><asula kood="5189" nimi="M??e-Tilga k??la"/><asula kood="5278" nimi="M??rdimiku k??la"/><asula kood="5323" nimi="Naapka k??la"/><asula kood="5918" nimi="Palanum??e k??la"/><asula kood="5933" nimi="Palli k??la"/><asula kood="5942" nimi="Paluj??ri k??la"/><asula kood="6051" nimi="Pausakunnu k??la"/><asula kood="6078" nimi="Peedo k??la"/><asula kood="6179" nimi="Piipsem??e k??la"/><asula kood="6253" nimi="Pillardi k??la"/><asula kood="6290" nimi="Plaani k??la"/><asula kood="6287" nimi="Plaksi k??la"/><asula kood="6336" nimi="Posti k??la"/><asula kood="6358" nimi="Preeksa k??la"/><asula kood="6362" nimi="Pressi k??la"/><asula kood="6428" nimi="Pundi k??la"/><asula kood="6439" nimi="Purka k??la"/><asula kood="6463" nimi="Puspuri k??la"/><asula kood="6687" nimi="Raagi k??la"/><asula kood="6938" nimi="Resto k??la"/><asula kood="7125" nimi="Rusa k??la"/><asula kood="7153" nimi="Ruusm??e k??la"/><asula kood="7271" nimi="Saagri k??la"/><asula kood="7341" nimi="Saika k??la"/><asula kood="7397" nimi="Saluora k??la"/><asula kood="7431" nimi="Sarise k??la"/><asula kood="7599" nimi="Simula k??la"/><asula kood="7691" nimi="Soodi k??la"/><asula kood="7751" nimi="Sormuli k??la"/><asula kood="7968" nimi="S????di k??la"/><asula kood="8351" nimi="Trolla k??la"/><asula kood="8354" nimi="Tsiam??e k??la"/><asula kood="8357" nimi="Tsiiruli k??la"/><asula kood="8358" nimi="Tsilgutaja k??la"/><asula kood="8374" nimi="Tsolli k??la"/><asula kood="8410" nimi="Tummelka k??la"/><asula kood="8448" nimi="Tuuka k??la"/><asula kood="8503" nimi="T??nkova k??la"/><asula kood="8762" nimi="Uue-Saaluse k??la"/><asula kood="8802" nimi="Vaalim??e k??la"/><asula kood="8809" nimi="Vaarkali k??la"/><asula kood="8906" nimi="Vakari k??la"/><asula kood="9129" nimi="Vastsekivi k??la"/><asula kood="9261" nimi="Vihkla k??la"/><asula kood="9345" nimi="Villa k??la"/><asula kood="9487" nimi="Vorstim??e k??la"/><asula kood="9488" nimi="Vungi k??la"/><asula kood="9665" nimi="V??nni k??la"/></vald><vald kood="0389"><asula kood="1305" nimi="Andsum??e k??la"/><asula kood="1810" nimi="Hellekunnu k??la"/><asula kood="1917" nimi="Husari k??la"/><asula kood="2551" nimi="Kaku k??la"/><asula kood="2683" nimi="Kannu k??la"/><asula kood="3796" nimi="K??rgessaare k??la"/><asula kood="3944" nimi="K????pa k??la"/><asula kood="3965" nimi="K??hmam??e k??la"/><asula kood="4130" nimi="Lasva k??la"/><asula kood="4136" nimi="Lauga k??la"/><asula kood="4203" nimi="Lehemetsa k??la"/><asula kood="4424" nimi="Listaku k??la"/><asula kood="4715" nimi="Madala k??la"/><asula kood="5167" nimi="M??rgi k??la"/><asula kood="5210" nimi="M??essaare k??la"/><asula kood="5440" nimi="Noodask??la"/><asula kood="5531" nimi="N??nova k??la"/><asula kood="5660" nimi="Oleski k??la"/><asula kood="5766" nimi="Otsa k??la"/><asula kood="5862" nimi="Paidra k??la"/><asula kood="6107" nimi="Perak??la"/><asula kood="6212" nimi="Pikakannu k??la"/><asula kood="6220" nimi="Pikasilla k??la"/><asula kood="6255" nimi="Pille k??la"/><asula kood="6269" nimi="Pindi k??la"/><asula kood="6482" nimi="Puusepa k??la"/><asula kood="6625" nimi="P??ss?? k??la"/><asula kood="7128" nimi="Rusima k??la"/><asula kood="7292" nimi="Saaremaa k??la"/><asula kood="7707" nimi="Sook??la"/><asula kood="8124" nimi="Tammsaare k??la"/><asula kood="8252" nimi="Tiri k??la"/><asula kood="8267" nimi="Tohkri k??la"/><asula kood="8372" nimi="Tsolgo k??la"/><asula kood="8601" nimi="T????tsm??e k??la"/><asula kood="9346" nimi="Villa k??la"/><asula kood="8109" nimi="Voki-Tamme k??la"/></vald><vald kood="0460"><asula kood="1170" nimi="Ala-Tsumba k??la"/><asula kood="1264" nimi="Antkruva k??la"/><asula kood="1626" nimi="Ermakova k??la"/><asula kood="1804" nimi="Helbi k??la"/><asula kood="1838" nimi="Hilana k??la"/><asula kood="1839" nimi="Hill??keste k??la"/><asula kood="1876" nimi="Holdi k??la"/><asula kood="1953" nimi="H??rm?? k??la"/><asula kood="1998" nimi="Ignas?? k??la"/><asula kood="2143" nimi="Jaanim??e k??la"/><asula kood="2221" nimi="Juusa k??la"/><asula kood="2278" nimi="J??ksi k??la"/><asula kood="2565" nimi="Kalatsova k??la"/><asula kood="2665" nimi="Kangavitsa k??la"/><asula kood="2703" nimi="Karamsina k??la"/><asula kood="2786" nimi="Kasakova k??la"/><asula kood="2821" nimi="Kastamara k??la"/><asula kood="2961" nimi="Keerba k??la"/><asula kood="3041" nimi="Kiiova k??la"/><asula kood="3053" nimi="Kiislova k??la"/><asula kood="3071" nimi="Kiksova k??la"/><asula kood="3164" nimi="Kits?? k??la"/><asula kood="3197" nimi="Klistina k??la"/><asula kood="3454" nimi="Korski k??la"/><asula kood="3536" nimi="Kuig?? k??la"/><asula kood="3567" nimi="Kuksina k??la"/><asula kood="3701" nimi="Kusnetsova k??la"/><asula kood="3845" nimi="K????ru k??la"/><asula kood="3988" nimi="K??ll??t??v?? k??la"/><asula kood="4297" nimi="Lep?? k??la"/><asula kood="4387" nimi="Lindsi k??la"/><asula kood="4571" nimi="Lutja k??la"/><asula kood="4710" nimi="Maaslova k??la"/><asula kood="4785" nimi="Marinova k??la"/><asula kood="4798" nimi="Martsina k??la"/><asula kood="4804" nimi="Masluva k??la"/><asula kood="4866" nimi="Melso k??la"/><asula kood="4872" nimi="Merek??l?? k??la"/><asula kood="4879" nimi="Merem??e k??la"/><asula kood="4843" nimi="Miikse k??la"/><asula kood="4950" nimi="Miku k??la"/><asula kood="5376" nimi="Navik?? k??la"/><asula kood="5582" nimi="Obinitsa k??la"/><asula kood="5658" nimi="Olehkova k??la"/><asula kood="5746" nimi="Ostrova k??la"/><asula kood="5900" nimi="Paklova k??la"/><asula kood="5914" nimi="Paland?? k??la"/><asula kood="5938" nimi="Palo k??la"/><asula kood="5945" nimi="Paloveere k??la"/><asula kood="6094" nimi="Pelsi k??la"/><asula kood="6288" nimi="Pliia k??la"/><asula kood="6313" nimi="Poksa k??la"/><asula kood="6319" nimi="Polovina k??la"/><asula kood="6412" nimi="Puista k??la"/><asula kood="6823" nimi="Raotu k??la"/><asula kood="7045" nimi="Rokina k??la"/><asula kood="7152" nimi="Ruutsi k??la"/><asula kood="7549" nimi="Serets??v?? k??la"/><asula kood="7547" nimi="Serga k??la"/><asula kood="7628" nimi="Sirgova k??la"/><asula kood="7786" nimi="Sulbi k??la"/><asula kood="8082" nimi="Talka k??la"/><asula kood="8175" nimi="Tedre k??la"/><asula kood="8191" nimi="Tepia k??la"/><asula kood="8199" nimi="Tessova k??la"/><asula kood="8204" nimi="Teter??v?? k??la"/><asula kood="8223" nimi="Tiirhanna k??la"/><asula kood="8231" nimi="Tiklas?? k??la"/><asula kood="8266" nimi="Tobrova k??la"/><asula kood="8337" nimi="Treiali k??la"/><asula kood="8341" nimi="Trigin?? k??la"/><asula kood="8355" nimi="Tsergond?? k??la"/><asula kood="8363" nimi="Tsirgu k??la"/><asula kood="8375" nimi="Tsumba k??la"/><asula kood="8416" nimi="Tuplova k??la"/><asula kood="8459" nimi="Tuulova k??la"/><asula kood="8584" nimi="T????glova k??la"/><asula kood="8648" nimi="Ulaskova k??la"/><asula kood="8793" nimi="Uusvada k??la"/><asula kood="8797" nimi="Vaaksaar?? k??la"/><asula kood="9112" nimi="Vasla k??la"/><asula kood="9208" nimi="Veretin?? k??la"/><asula kood="9373" nimi="Vinski k??la"/><asula kood="9384" nimi="Viro k??la"/><asula kood="9567" nimi="V??mmorski k??la"/><asula kood="9639" nimi="V??iko-H??rm?? k??la"/><asula kood="9637" nimi="V??iko-Serga k??la"/></vald><vald kood="0468"><asula kood="1859" nimi="Hindsa k??la"/><asula kood="1858" nimi="Hino k??la"/><asula kood="1893" nimi="Horosuu k??la"/><asula kood="1955" nimi="H????rm??ni k??la"/><asula kood="1966" nimi="H??rsi k??la"/><asula kood="2854" nimi="Kaubi k??la"/><asula kood="3095" nimi="Kimalas?? k??la"/><asula kood="3193" nimi="Kiviora k??la"/><asula kood="3451" nimi="Koorla k??la"/><asula kood="3794" nimi="Korg??ssaar?? k??la"/><asula kood="3468" nimi="Kossa k??la"/><asula kood="3502" nimi="Kriiva k??la"/><asula kood="3374" nimi="Kundsa k??la"/><asula kood="3635" nimi="Kur?? k??la"/><asula kood="3851" nimi="K??bli k??la"/><asula kood="3906" nimi="K??rin?? k??la"/><asula kood="4071" nimi="Laisi k??la"/><asula kood="4228" nimi="Leimani k??la"/><asula kood="4540" nimi="L??t?? k??la"/><asula kood="4830" nimi="Mauri k??la"/><asula kood="4954" nimi="Misso alevik"/><asula kood="4956" nimi="Missok??l?? k??la"/><asula kood="4970" nimi="Mokra k??la"/><asula kood="5035" nimi="Muraski k??la"/><asula kood="5297" nimi="M????si k??la"/><asula kood="5305" nimi="M??ldre k??la"/><asula kood="5354" nimi="Napi k??la"/><asula kood="6015" nimi="Parmu k??la"/><asula kood="6069" nimi="Pedej?? k??la"/><asula kood="6375" nimi="Pruntova k??la"/><asula kood="6424" nimi="Pulli k??la"/><asula kood="6435" nimi="Pupli k??la"/><asula kood="6538" nimi="P??nni k??la"/><asula kood="6543" nimi="P??rst?? k??la"/><asula kood="6592" nimi="P??ltre k??la"/><asula kood="6784" nimi="Rammuka k??la"/><asula kood="6883" nimi="Reb??se k??la"/><asula kood="7021" nimi="Ritsiko k??la"/><asula kood="7274" nimi="Saagri k??la"/><asula kood="7272" nimi="Saagrim??e k??la"/><asula kood="7344" nimi="Saika k??la"/><asula kood="7364" nimi="Sakudi k??la"/><asula kood="7411" nimi="Sandi k??la"/><asula kood="7419" nimi="Sapi k??la"/><asula kood="7506" nimi="Savim??e k??la"/><asula kood="7504" nimi="Savioja k??la"/><asula kood="7585" nimi="Siks??l?? k??la"/><asula kood="7849" nimi="Suur??suu k??la"/><asula kood="8177" nimi="Tiast?? k??la"/><asula kood="8224" nimi="Tiilige k??la"/><asula kood="8233" nimi="Tika k??la"/><asula kood="8314" nimi="Toodsi k??la"/><asula kood="8359" nimi="Tserebi k??la"/><asula kood="8360" nimi="Tsiistre k??la"/><asula kood="9640" nimi="V??iko-Tiilige k??la"/></vald><vald kood="0493"><asula kood="1968" nimi="H??rova k??la"/><asula kood="1972" nimi="H??ti k??la"/><asula kood="2598" nimi="Kallaste k??la"/><asula kood="2738" nimi="Karis????di k??la"/><asula kood="3250" nimi="Koemetsa k??la"/><asula kood="3728" nimi="Kuutsi k??la"/><asula kood="5149" nimi="M??niste k??la"/><asula kood="6019" nimi="Parmupalu k??la"/><asula kood="6076" nimi="Peebu k??la"/><asula kood="7363" nimi="Sakurgi k??la"/><asula kood="7436" nimi="Saru k??la"/><asula kood="7609" nimi="Singa k??la"/><asula kood="8229" nimi="Tiitsa k??la"/><asula kood="8415" nimi="Tundu k??la"/><asula kood="8429" nimi="Tursa k??la"/><asula kood="9131" nimi="Vastse-Roosa k??la"/><asula kood="9354" nimi="Villike k??la"/></vald><vald kood="0697"><asula kood="1005" nimi="Aabra k??la"/><asula kood="1111" nimi="Ahitsa k??la"/><asula kood="1456" nimi="Augli k??la"/><asula kood="1676" nimi="Haabsilla k??la"/><asula kood="1728" nimi="Haki k??la"/><asula kood="1745" nimi="Hallim??e k??la"/><asula kood="1753" nimi="Handimiku k??la"/><asula kood="1758" nimi="Hansi k??la"/><asula kood="1756" nimi="Hapsu k??la"/><asula kood="1789" nimi="Heedu k??la"/><asula kood="1791" nimi="Heibri k??la"/><asula kood="1861" nimi="Hinu k??la"/><asula kood="1898" nimi="Horsa k??la"/><asula kood="1896" nimi="Hot??m??e k??la"/><asula kood="1911" nimi="Hurda k??la"/><asula kood="1956" nimi="H??r??m??e k??la"/><asula kood="2146" nimi="Jaanipeebu k??la"/><asula kood="2206" nimi="Jugu k??la"/><asula kood="2358" nimi="J??rvek??l?? k??la"/><asula kood="2357" nimi="J??rvepalu k??la"/><asula kood="2491" nimi="Kad??ni k??la"/><asula kood="2513" nimi="Kahru k??la"/><asula kood="2554" nimi="Kaku k??la"/><asula kood="2627" nimi="Kaluka k??la"/><asula kood="2704" nimi="Karaski k??la"/><asula kood="2708" nimi="Karba k??la"/><asula kood="2866" nimi="Kaugu k??la"/><asula kood="2899" nimi="Kav??ldi k??la"/><asula kood="2936" nimi="Kell??m??e k??la"/><asula kood="3026" nimi="Kiidi k??la"/><asula kood="3256" nimi="Kogr?? k??la"/><asula kood="3327" nimi="Kok??j??ri k??la"/><asula kood="3329" nimi="Kok?? k??la"/><asula kood="3318" nimi="Kok??m??e k??la"/><asula kood="3334" nimi="Kolga k??la"/><asula kood="3558" nimi="Kuklas?? k??la"/><asula kood="3664" nimi="Kurgj??rve k??la"/><asula kood="3698" nimi="Kurvitsa k??la"/><asula kood="3706" nimi="Kuuda k??la"/><asula kood="3861" nimi="K??hri k??la"/><asula kood="3873" nimi="K??ngsep?? k??la"/><asula kood="4111" nimi="Laossaar?? k??la"/><asula kood="4158" nimi="Lauri k??la"/><asula kood="4358" nimi="Liivakupalu k??la"/><asula kood="4422" nimi="Listaku k??la"/><asula kood="4568" nimi="Lutika k??la"/><asula kood="4670" nimi="L??kk?? k??la"/><asula kood="4822" nimi="Matsi k??la"/><asula kood="4947" nimi="Mikita k??la"/><asula kood="4996" nimi="Muduri k??la"/><asula kood="5001" nimi="Muhkam??tsa k??la"/><asula kood="5024" nimi="Muna k??la"/><asula kood="5042" nimi="Murd??m??e k??la"/><asula kood="5056" nimi="Mustahamba k??la"/><asula kood="5176" nimi="M????lu k??la"/><asula kood="5283" nimi="M??rdi k??la"/><asula kood="5306" nimi="M??ldri k??la"/><asula kood="5423" nimi="Nilb?? k??la"/><asula kood="5434" nimi="Nogu k??la"/><asula kood="5477" nimi="Nursi k??la"/><asula kood="5732" nimi="Ortum??e k??la"/><asula kood="5770" nimi="Paaburissa k??la"/><asula kood="5822" nimi="Paeboja k??la"/><asula kood="6128" nimi="Petrakuudi k??la"/><asula kood="6386" nimi="Pug??stu k??la"/><asula kood="6433" nimi="Pulli k??la"/><asula kood="6485" nimi="P??dra k??la"/><asula kood="6545" nimi="P??ru k??la"/><asula kood="6611" nimi="P??rlij??e k??la"/><asula kood="6670" nimi="P??ss?? k??la"/><asula kood="6839" nimi="Rasva k??la"/><asula kood="6859" nimi="Raudsep?? k??la"/><asula kood="6892" nimi="Reb??se k??la"/><asula kood="6895" nimi="Reb??sem??isa k??la"/><asula kood="6991" nimi="Riitsilla k??la"/><asula kood="7008" nimi="Ristem??e k??la"/><asula kood="7052" nimi="Roobi k??la"/><asula kood="7144" nimi="Ruuksu k??la"/><asula kood="7181" nimi="R??uge alevik"/><asula kood="7305" nimi="Saarlas?? k??la"/><asula kood="7321" nimi="Sadram??tsa k??la"/><asula kood="7346" nimi="Saki k??la"/><asula kood="7409" nimi="Sandisuu k??la"/><asula kood="7507" nimi="Savioru k??la"/><asula kood="7574" nimi="Sika k??la"/><asula kood="7575" nimi="Sikalaan?? k??la"/><asula kood="7600" nimi="Simmuli k??la"/><asula kood="7650" nimi="Soek??rdsi k??la"/><asula kood="7656" nimi="Soem??isa k??la"/><asula kood="7721" nimi="Soom??oru k??la"/><asula kood="7146" nimi="Suur??-Ruuga k??la"/><asula kood="7930" nimi="S??nna k??la"/><asula kood="8086" nimi="Tallima k??la"/><asula kood="8170" nimi="Taudsa k??la"/><asula kood="8200" nimi="Tialas?? k??la"/><asula kood="8218" nimi="Tiidu k??la"/><asula kood="8237" nimi="Tilgu k??la"/><asula kood="8241" nimi="Tindi k??la"/><asula kood="8284" nimi="Toodsi k??la"/><asula kood="8366" nimi="Tsirgupalu k??la"/><asula kood="8379" nimi="Tsutsu k??la"/><asula kood="8603" nimi="T????tsi k??la"/><asula kood="8623" nimi="Udsali k??la"/><asula kood="8738" nimi="Utessuu k??la"/><asula kood="8817" nimi="Vadsa k??la"/><asula kood="9030" nimi="Vanam??isa k??la"/><asula kood="9307" nimi="Viitina k??la"/><asula kood="9329" nimi="Viliksaar?? k??la"/><asula kood="9643" nimi="V??iku-Ruuga k??la"/></vald><vald kood="0767"><asula kood="1163" nimi="Alak??l?? k??la"/><asula kood="1172" nimi="Alap??dra k??la"/><asula kood="1751" nimi="Haamaste k??la"/><asula kood="1697" nimi="Haava k??la"/><asula kood="1134" nimi="Haidaku k??la"/><asula kood="1764" nimi="Hargi k??la"/><asula kood="1786" nimi="Heeska k??la"/><asula kood="1894" nimi="Horma k??la"/><asula kood="8744" nimi="Hutita k??la"/><asula kood="1942" nimi="H??nike k??la"/><asula kood="2365" nimi="J??rvere k??la"/><asula kood="2515" nimi="Kahro k??la"/><asula kood="2911" nimi="Keema k??la"/><asula kood="3649" nimi="Kurenurme k??la"/><asula kood="3903" nimi="K??rgula k??la"/><asula kood="4079" nimi="Lakovitsa k??la"/><asula kood="4240" nimi="Leiso k??la"/><asula kood="4357" nimi="Liiva k??la"/><asula kood="4373" nimi="Lilli-Anne k??la"/><asula kood="4401" nimi="Linnam??e k??la"/><asula kood="4750" nimi="Majala k??la"/><asula kood="5071" nimi="Mustassaare k??la"/><asula kood="5077" nimi="Mustja k??la"/><asula kood="5188" nimi="M??ek??l?? k??la"/><asula kood="5749" nimi="Osula k??la"/><asula kood="6376" nimi="Pritsi k??la"/><asula kood="6430" nimi="Pulli k??la"/><asula kood="6431" nimi="Punak??l?? k??la"/><asula kood="6864" nimi="Rauskapalu k??la"/><asula kood="7119" nimi="Rummi k??la"/><asula kood="7787" nimi="Sulbi k??la"/><asula kood="7887" nimi="S??merpalu alevik"/><asula kood="7888" nimi="S??merpalu k??la"/><asula kood="8620" nimi="Udsali k??la"/><asula kood="9074" nimi="Varese k??la"/></vald><vald kood="0843"><asula kood="2812" nimi="Kassi k??la"/><asula kood="3125" nimi="Kirikuk??la"/><asula kood="3287" nimi="Koigu k??la"/><asula kood="3575" nimi="Kuldre k??la"/><asula kood="3752" nimi="K??lbi k??la"/><asula kood="4689" nimi="L??matu k??la"/><asula kood="6150" nimi="Pihleni k??la"/><asula kood="7102" nimi="Ruhingu k??la"/><asula kood="8280" nimi="Toku k??la"/><asula kood="8634" nimi="Uhtj??rve k??la"/><asula kood="8733" nimi="Urvaste k??la"/><asula kood="8757" nimi="Uue-Antsla k??la"/><asula kood="8801" nimi="Vaabina k??la"/><asula kood="9414" nimi="Visela k??la"/></vald><vald kood="0865"><asula kood="1772" nimi="Harjuk??la k??la"/><asula kood="1863" nimi="Hintsiko k??la"/><asula kood="2677" nimi="Kangsti k??la"/><asula kood="3489" nimi="Krabi k??la"/><asula kood="3793" nimi="K??rgepalu k??la"/><asula kood="4160" nimi="Laurim??e k??la"/><asula kood="4324" nimi="Liguri k??la"/><asula kood="4694" nimi="L????tsepa k??la"/><asula kood="4825" nimi="Matsi k??la"/><asula kood="4933" nimi="Metstaga k??la"/><asula kood="5099" nimi="Mutemetsa k??la"/><asula kood="5839" nimi="Paganamaa k??la"/><asula kood="6434" nimi="Punsa k??la"/><asula kood="6564" nimi="P??hni k??la"/><asula kood="6858" nimi="Raudsepa k??la"/><asula kood="7712" nimi="Sool??tte k??la"/><asula kood="8038" nimi="Tagakolga k??la"/><asula kood="9002" nimi="Vana-Roosa k??la"/><asula kood="9095" nimi="Varstu alevik"/><asula kood="9391" nimi="Viru k??la"/></vald><vald kood="0874"><asula kood="1700" nimi="Haava k??la"/><asula kood="1744" nimi="Halla k??la"/><asula kood="1796" nimi="Heinasoo k??la"/><asula kood="1856" nimi="Hinniala k??la"/><asula kood="1860" nimi="Hinsa k??la"/><asula kood="1886" nimi="Holsta k??la"/><asula kood="2040" nimi="Illi k??la"/><asula kood="2082" nimi="Indra k??la"/><asula kood="2184" nimi="Jeedask??la"/><asula kood="2212" nimi="Juraski k??la"/><asula kood="2389" nimi="Kaagu k??la"/><asula kood="2694" nimi="Kapera k??la"/><asula kood="2963" nimi="Kerep????lse k??la"/><asula kood="3130" nimi="Kirikum??e k??la"/><asula kood="3450" nimi="Kornitsa k??la"/><asula kood="3776" nimi="K??o k??la"/><asula kood="3818" nimi="K??rve k??la"/><asula kood="3883" nimi="K??pa k??la"/><asula kood="3981" nimi="K??laoru k??la"/><asula kood="3991" nimi="K??ndja k??la"/><asula kood="4386" nimi="Lindora k??la"/><asula kood="4517" nimi="Loosi k??la"/><asula kood="4544" nimi="Luhte k??la"/><asula kood="5100" nimi="Mutsu k??la"/><asula kood="5192" nimi="M??e-K??ok??la"/><asula kood="5307" nimi="M??ldri k??la"/><asula kood="5734" nimi="Ortuma k??la"/><asula kood="5943" nimi="Paloveere k??la"/><asula kood="6002" nimi="Pari k??la"/><asula kood="6112" nimi="Perametsa k??la"/><asula kood="6293" nimi="Plessi k??la"/><asula kood="6484" nimi="Puutli k??la"/><asula kood="6673" nimi="Raadi k??la"/><asula kood="7281" nimi="Saarde k??la"/><asula kood="7503" nimi="Savioja k??la"/><asula kood="7820" nimi="Sutte k??la"/><asula kood="8014" nimi="Tabina k??la"/><asula kood="8081" nimi="Tallikeste k??la"/><asula kood="8192" nimi="Tellaste k??la"/><asula kood="8376" nimi="Tsolli k??la"/><asula kood="8811" nimi="Vaarkali k??la"/><asula kood="9004" nimi="Vana-Saaluse k??la"/><asula kood="8855" nimi="Vana-Vastseliina k??la"/><asula kood="9133" nimi="Vastseliina alevik"/><asula kood="9144" nimi="Vatsa k??la"/><asula kood="9310" nimi="Viitka k??la"/><asula kood="9458" nimi="Voki k??la"/></vald><vald kood="0918"><asula kood="1759" nimi="Hannuste k??la"/><asula kood="2203" nimi="Juba k??la"/><asula kood="2789" nimi="Kasaritsa k??la"/><asula kood="3153" nimi="Kirump???? k??la"/><asula kood="3333" nimi="Kolepi k??la"/><asula kood="3360" nimi="Koloreino k??la"/><asula kood="3462" nimi="Kose alevik"/><asula kood="3704" nimi="Kusma k??la"/><asula kood="3921" nimi="K??rnam??e k??la"/><asula kood="3956" nimi="K????tso k??la"/><asula kood="4118" nimi="Lapi k??la"/><asula kood="4490" nimi="Lompka k??la"/><asula kood="4519" nimi="Loosu k??la"/><asula kood="4839" nimi="Meegom??e k??la"/><asula kood="4845" nimi="Meeliku k??la"/><asula kood="5135" nimi="M??isam??e k??la"/><asula kood="5141" nimi="M??ksi k??la"/><asula kood="5378" nimi="Navi k??la"/><asula kood="5450" nimi="Nooska k??la"/><asula kood="5941" nimi="Palometsa k??la"/><asula kood="6017" nimi="Parksepa alevik"/><asula kood="6411" nimi="Puiga k??la"/><asula kood="6761" nimi="Raiste k??la"/><asula kood="6856" nimi="Raudsepa k??la"/><asula kood="7078" nimi="Roosisaare k??la"/><asula kood="7217" nimi="R??po k??la"/><asula kood="7576" nimi="Sika k??la"/><asula kood="8040" nimi="Tagak??la"/><asula kood="8315" nimi="Tootsi k??la"/><asula kood="8669" nimi="Umbsaare k??la"/><asula kood="8833" nimi="Vagula k??la"/><asula kood="8994" nimi="Vana-Nursi k??la"/><asula kood="9218" nimi="Verij??rve k??la"/><asula kood="9564" nimi="V??lsi k??la"/><asula kood="9585" nimi="V??rum??isa k??la"/><asula kood="9588" nimi="V??rusoo k??la"/><asula kood="9636" nimi="V??imela alevik"/><asula kood="9641" nimi="V??iso k??la"/></vald></maakond></ehak>	asulad	2021-01-27 10:25:45.782999	2021-01-27 10:25:45.782999	admin	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: group_; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.group_ (id, created, last_modified, username, org_id, portal_id, name) FROM stdin;
1	2021-02-16 08:05:12.179	2021-02-16 08:05:50.635	EE49002124277	1	1	Tester
\.


--
-- Data for Name: group_item; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.group_item (id, created, last_modified, username, group_id, invisible, org_query_id) FROM stdin;
1	2021-02-16 08:05:45.635	2021-02-16 08:05:45.635	EE49002124277	1	f	2
2	2021-02-16 08:05:45.636	2021-02-16 08:05:45.636	EE49002124277	1	f	1
3	2021-02-16 08:05:45.636	2021-02-16 08:05:45.636	EE49002124277	1	f	3
4	2021-02-16 08:05:45.637	2021-02-16 08:05:45.637	EE49002124277	1	f	15
5	2021-02-16 08:05:45.637	2021-02-16 08:05:45.637	EE49002124277	1	f	16
6	2021-02-16 08:05:45.637	2021-02-16 08:05:45.637	EE49002124277	1	f	17
7	2021-02-16 08:05:45.638	2021-02-16 08:05:45.638	EE49002124277	1	f	14
8	2021-02-16 08:05:45.638	2021-02-16 08:05:45.638	EE49002124277	1	f	22
9	2021-02-16 08:05:45.638	2021-02-16 08:05:45.638	EE49002124277	1	f	9
10	2021-02-16 08:05:45.638	2021-02-16 08:05:45.638	EE49002124277	1	f	7
11	2021-02-16 08:05:45.639	2021-02-16 08:05:45.639	EE49002124277	1	f	13
12	2021-02-16 08:05:45.639	2021-02-16 08:05:45.639	EE49002124277	1	f	5
13	2021-02-16 08:05:45.639	2021-02-16 08:05:45.639	EE49002124277	1	f	6
14	2021-02-16 08:05:45.639	2021-02-16 08:05:45.639	EE49002124277	1	f	20
15	2021-02-16 08:05:45.64	2021-02-16 08:05:45.64	EE49002124277	1	f	19
16	2021-02-16 08:05:45.64	2021-02-16 08:05:45.64	EE49002124277	1	f	18
17	2021-02-16 08:05:45.64	2021-02-16 08:05:45.64	EE49002124277	1	f	12
18	2021-02-16 08:05:45.64	2021-02-16 08:05:45.64	EE49002124277	1	f	11
19	2021-02-16 08:05:45.64	2021-02-16 08:05:45.64	EE49002124277	1	f	4
20	2021-02-16 08:05:45.64	2021-02-16 08:05:45.64	EE49002124277	1	f	21
21	2021-02-16 08:05:45.641	2021-02-16 08:05:45.641	EE49002124277	1	f	8
22	2021-02-16 08:05:45.641	2021-02-16 08:05:45.641	EE49002124277	1	f	10
\.


--
-- Data for Name: group_person; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.group_person (id, created, last_modified, username, group_id, person_id, org_id, validuntil) FROM stdin;
1	2021-02-16 08:05:50.635	2021-02-16 08:05:50.635	EE49002124277	1	1	1	\N
\.


--
-- Data for Name: manager_candidate; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.manager_candidate (id, created, last_modified, username, manager_id, org_id, auth_ssn, portal_id) FROM stdin;
\.


--
-- Data for Name: news; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.news (id, created, last_modified, username, lang, portal_id, news) FROM stdin;
\.


--
-- Data for Name: org; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.org (id, created, last_modified, username, member_class, subsystem_code, code, sup_org_id) FROM stdin;
1	2021-02-16 07:23:33.915	2021-02-16 07:23:33.915	admin	ORG	Client	1111	\N
\.


--
-- Data for Name: org_name; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.org_name (id, description, lang, org_id, created, last_modified, username) FROM stdin;
1	NIIS	en	1	2021-02-16 07:23:33.976	2021-02-16 07:23:33.976	admin
\.


--
-- Data for Name: org_person; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.org_person (id, created, last_modified, username, org_id, person_id, portal_id, role, profession) FROM stdin;
1	2021-02-16 08:06:04.822	2021-02-16 08:06:04.822	EE49002124277	1	1	1	15	Mgr
\.


--
-- Data for Name: org_query; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.org_query (id, org_id, query_id, created, last_modified, username) FROM stdin;
1	1	1	2021-02-16 07:49:10.671	2021-02-16 07:49:10.671	EE49002124277
2	1	2	2021-02-16 07:49:10.679	2021-02-16 07:49:10.679	EE49002124277
3	1	3	2021-02-16 07:51:59.837	2021-02-16 07:51:59.837	EE49002124277
4	1	4	2021-02-16 07:51:59.847	2021-02-16 07:51:59.847	EE49002124277
5	1	5	2021-02-16 07:51:59.854	2021-02-16 07:51:59.854	EE49002124277
6	1	6	2021-02-16 07:51:59.862	2021-02-16 07:51:59.862	EE49002124277
7	1	7	2021-02-16 07:51:59.871	2021-02-16 07:51:59.871	EE49002124277
8	1	8	2021-02-16 07:51:59.878	2021-02-16 07:51:59.878	EE49002124277
9	1	9	2021-02-16 07:51:59.884	2021-02-16 07:51:59.884	EE49002124277
10	1	10	2021-02-16 07:51:59.889	2021-02-16 07:51:59.889	EE49002124277
11	1	11	2021-02-16 07:51:59.894	2021-02-16 07:51:59.894	EE49002124277
12	1	12	2021-02-16 07:51:59.9	2021-02-16 07:51:59.9	EE49002124277
13	1	13	2021-02-16 07:51:59.904	2021-02-16 07:51:59.904	EE49002124277
14	1	14	2021-02-16 07:51:59.91	2021-02-16 07:51:59.91	EE49002124277
15	1	15	2021-02-16 07:51:59.915	2021-02-16 07:51:59.915	EE49002124277
16	1	16	2021-02-16 07:51:59.921	2021-02-16 07:51:59.921	EE49002124277
17	1	17	2021-02-16 07:51:59.926	2021-02-16 07:51:59.926	EE49002124277
18	1	18	2021-02-16 07:51:59.933	2021-02-16 07:51:59.933	EE49002124277
19	1	19	2021-02-16 07:51:59.938	2021-02-16 07:51:59.938	EE49002124277
20	1	20	2021-02-16 07:51:59.944	2021-02-16 07:51:59.944	EE49002124277
21	1	21	2021-02-16 07:51:59.949	2021-02-16 07:51:59.949	EE49002124277
22	1	22	2021-02-16 07:51:59.955	2021-02-16 07:51:59.955	EE49002124277
\.


--
-- Data for Name: org_valid; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.org_valid (id, created, last_modified, username, org_id, valid_date) FROM stdin;
\.


--
-- Data for Name: package; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.package (id, name, url, created, last_modified, username) FROM stdin;
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.person (id, created, last_modified, username, ssn, givenname, surname, password, password_salt, overtake_code, overtake_code_salt, certificate, last_portal) FROM stdin;
1	2021-02-16 07:35:03.529	2021-02-16 08:06:04.822	EE49002124277	EE49002124277	EEAdmin	Test	frGPpv46So8LYQOJ5OjnojzRQ3s=	kiO3O6pOsT73mRso3NjXjk8nFE0=	\N		\N	\N
\.


--
-- Data for Name: person_eula; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.person_eula (id, person_id, portal_id, accepted, auth_method, src_addr, created, last_modified, username) FROM stdin;
\.


--
-- Data for Name: person_mail_org; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.person_mail_org (id, org_id, person_id, mail, notify_changes, created, last_modified, username) FROM stdin;
1	1	1	test@localhost	f	2021-02-16 07:35:03.532	2021-02-16 07:35:03.532	admin
\.


--
-- Data for Name: portal; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.portal (id, short_name, org_id, misp_type, security_host, message_mediator, bpel_engine, debug, univ_auth_query, univ_check_query, univ_check_valid_time, univ_check_max_valid_time, univ_use_manager, use_topics, use_xrd_issue, log_query, register_units, unit_is_consumer, created, last_modified, username, client_xroad_instance, xroad_protocol_ver, misp2_xroad_service_member_class, misp2_xroad_service_member_code, misp2_xroad_service_subsystem_code, eula_in_use) FROM stdin;
1		1	1	http://172.17.0.1:4101	http://172.17.0.1:4101	\N	0			\N	\N	f	f	f	f	f	f	2021-02-16 07:23:33.944	2021-02-16 07:47:18.175	admin	CS	4.0	COM			f
\.


--
-- Data for Name: portal_eula; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.portal_eula (id, portal_id, lang, content, created, last_modified, username) FROM stdin;
1	1	en		2021-02-16 07:23:34.004	2021-02-16 07:23:34.004	admin
\.


--
-- Data for Name: portal_name; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.portal_name (id, description, lang, portal_id, created, last_modified, username) FROM stdin;
1	Test Portal(ET)	en	1	2021-02-16 07:23:33.965	2021-02-16 07:23:33.965	admin
\.


--
-- Data for Name: producer; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.producer (id, created, last_modified, username, xroad_instance, short_name, member_class, subsystem_code, protocol, in_use, is_complex, wsdl_url, repository_url, portal_id) FROM stdin;
1	2021-02-16 07:48:43.627	2021-02-16 07:48:43.627	EE49002124277	CS	1111	ORG	MANAGEMENT	SOAP	f	\N	\N	\N	1
3	2021-02-16 07:48:43.632	2021-02-16 07:48:53.002	EE49002124277	CS	1111	ORG	Server	SOAP	t	\N	\N	\N	1
2	2021-02-16 07:48:43.63	2021-02-16 07:49:10.658	EE49002124277	CS	1111	ORG	Client	SOAP	t	\N		http://172.17.0.1:4101/cgi-bin/uriproxy?service=	1
4	2021-02-16 07:51:41.811	2021-02-16 07:51:41.811	EE49002124277	CS	1111	ORG	MANAGEMENT	REST	f	\N	\N	\N	1
6	2021-02-16 07:51:41.815	2021-02-16 07:51:48.918	EE49002124277	CS	1111	ORG	Server	REST	t	\N	\N	\N	1
5	2021-02-16 07:51:41.813	2021-02-16 07:51:59.829	EE49002124277	CS	1111	ORG	Client	REST	t	\N		http://172.17.0.1:4101/cgi-bin/uriproxy?service=	1
\.


--
-- Data for Name: producer_name; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.producer_name (id, description, lang, producer_id, created, last_modified, username) FROM stdin;
1	NIIS	en	\N	2021-02-16 07:48:43.637	2021-02-16 07:48:43.637	EE49002124277
2	NIIS	en	1	2021-02-16 07:48:43.643	2021-02-16 07:48:43.643	EE49002124277
3	NIIS	en	2	2021-02-16 07:48:43.645	2021-02-16 07:48:43.645	EE49002124277
4	NIIS	en	3	2021-02-16 07:48:43.648	2021-02-16 07:48:43.648	EE49002124277
5	NIIS	en	\N	2021-02-16 07:51:41.817	2021-02-16 07:51:41.817	EE49002124277
6	NIIS	en	4	2021-02-16 07:51:41.819	2021-02-16 07:51:41.819	EE49002124277
8	NIIS	en	6	2021-02-16 07:51:41.824	2021-02-16 07:51:41.824	EE49002124277
7	Swagger Petstore	en	5	2021-02-16 07:51:59.97	2021-02-16 07:51:59.986	EE49002124277
\.


--
-- Data for Name: query; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.query (id, type, name, xroad_request_namespace, sub_query_names, producer_id, package_id, openapi_service_code, created, last_modified, username) FROM stdin;
1	0	helloService.v1	\N	\N	2	\N	\N	2021-02-16 07:49:10.67	2021-02-16 07:49:10.67	EE49002124277
2	0	getRandom.v1	\N	\N	2	\N	\N	2021-02-16 07:49:10.678	2021-02-16 07:49:10.678	EE49002124277
4	0	updatePet	\N	\N	5	\N	pets	2021-02-16 07:51:59.846	2021-02-16 07:51:59.846	EE49002124277
6	0	findPetsByTags	\N	\N	5	\N	pets	2021-02-16 07:51:59.86	2021-02-16 07:51:59.86	EE49002124277
7	0	getPetById	\N	\N	5	\N	pets	2021-02-16 07:51:59.869	2021-02-16 07:51:59.869	EE49002124277
8	0	updatePetWithForm	\N	\N	5	\N	pets	2021-02-16 07:51:59.877	2021-02-16 07:51:59.877	EE49002124277
9	0	deletePet	\N	\N	5	\N	pets	2021-02-16 07:51:59.883	2021-02-16 07:51:59.883	EE49002124277
10	0	uploadFile	\N	\N	5	\N	pets	2021-02-16 07:51:59.888	2021-02-16 07:51:59.888	EE49002124277
11	0	getInventory	\N	\N	5	\N	pets	2021-02-16 07:51:59.893	2021-02-16 07:51:59.893	EE49002124277
12	0	placeOrder	\N	\N	5	\N	pets	2021-02-16 07:51:59.899	2021-02-16 07:51:59.899	EE49002124277
13	0	getOrderById	\N	\N	5	\N	pets	2021-02-16 07:51:59.904	2021-02-16 07:51:59.904	EE49002124277
14	0	deleteOrder	\N	\N	5	\N	pets	2021-02-16 07:51:59.909	2021-02-16 07:51:59.909	EE49002124277
15	0	createUser	\N	\N	5	\N	pets	2021-02-16 07:51:59.914	2021-02-16 07:51:59.914	EE49002124277
16	0	createUsersWithArrayInput	\N	\N	5	\N	pets	2021-02-16 07:51:59.92	2021-02-16 07:51:59.92	EE49002124277
17	0	createUsersWithListInput	\N	\N	5	\N	pets	2021-02-16 07:51:59.925	2021-02-16 07:51:59.925	EE49002124277
18	0	loginUser	\N	\N	5	\N	pets	2021-02-16 07:51:59.932	2021-02-16 07:51:59.932	EE49002124277
19	0	logoutUser	\N	\N	5	\N	pets	2021-02-16 07:51:59.937	2021-02-16 07:51:59.937	EE49002124277
20	0	getUserByName	\N	\N	5	\N	pets	2021-02-16 07:51:59.943	2021-02-16 07:51:59.943	EE49002124277
21	0	updateUser	\N	\N	5	\N	pets	2021-02-16 07:51:59.948	2021-02-16 07:51:59.948	EE49002124277
22	0	deleteUser	\N	\N	5	\N	pets	2021-02-16 07:51:59.954	2021-02-16 07:51:59.954	EE49002124277
3	0	addPet	\N	POST CS/ORG/1111/Client/pets/pet	5	\N	pets	2021-02-16 07:51:59.834	2021-02-16 07:52:11.084	EE49002124277
5	0	findPetsByStatus	\N	GET CS/ORG/1111/Client/pets/pet/findByStatus	5	\N	pets	2021-02-16 07:51:59.853	2021-02-16 07:53:04.405	EE49002124277
\.


--
-- Data for Name: query_error_log; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.query_error_log (id, query_log_id, code, description, detail, created, last_modified, username) FROM stdin;
\.


--
-- Data for Name: query_log; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.query_log (id, query_name, main_query_name, query_id, description, org_code, unit_code, query_time, person_ssn, portal_id, query_time_sec, success, query_size, created, username, last_modified) FROM stdin;
\.


--
-- Data for Name: query_name; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.query_name (id, description, lang, query_id, query_note, created, last_modified, username) FROM stdin;
1	Add a new pet to the store	all	\N	\N	2021-02-16 07:51:59.836	2021-02-16 07:51:59.836	EE49002124277
2	Update an existing pet	all	\N	\N	2021-02-16 07:51:59.846	2021-02-16 07:51:59.846	EE49002124277
3	Finds Pets by status	all	\N	\N	2021-02-16 07:51:59.853	2021-02-16 07:51:59.853	EE49002124277
4	Finds Pets by tags	all	\N	\N	2021-02-16 07:51:59.861	2021-02-16 07:51:59.861	EE49002124277
5	Find pet by ID	all	\N	\N	2021-02-16 07:51:59.87	2021-02-16 07:51:59.87	EE49002124277
6	Updates a pet in the store with form data	all	\N	\N	2021-02-16 07:51:59.878	2021-02-16 07:51:59.878	EE49002124277
7	Deletes a pet	all	\N	\N	2021-02-16 07:51:59.883	2021-02-16 07:51:59.883	EE49002124277
8	uploads an image	all	\N	\N	2021-02-16 07:51:59.889	2021-02-16 07:51:59.889	EE49002124277
9	Returns pet inventories by status	all	\N	\N	2021-02-16 07:51:59.894	2021-02-16 07:51:59.894	EE49002124277
10	Place an order for a pet	all	\N	\N	2021-02-16 07:51:59.899	2021-02-16 07:51:59.899	EE49002124277
11	Find purchase order by ID	all	\N	\N	2021-02-16 07:51:59.904	2021-02-16 07:51:59.904	EE49002124277
12	Delete purchase order by ID	all	\N	\N	2021-02-16 07:51:59.909	2021-02-16 07:51:59.909	EE49002124277
13	Create user	all	\N	\N	2021-02-16 07:51:59.915	2021-02-16 07:51:59.915	EE49002124277
14	Creates list of users with given input array	all	\N	\N	2021-02-16 07:51:59.92	2021-02-16 07:51:59.92	EE49002124277
15	Creates list of users with given input array	all	\N	\N	2021-02-16 07:51:59.926	2021-02-16 07:51:59.926	EE49002124277
16	Logs user into the system	all	\N	\N	2021-02-16 07:51:59.932	2021-02-16 07:51:59.932	EE49002124277
17	Logs out current logged in user session	all	\N	\N	2021-02-16 07:51:59.937	2021-02-16 07:51:59.937	EE49002124277
18	Get user by user name	all	\N	\N	2021-02-16 07:51:59.943	2021-02-16 07:51:59.943	EE49002124277
19	Updated user	all	\N	\N	2021-02-16 07:51:59.949	2021-02-16 07:51:59.949	EE49002124277
20	Delete user	all	\N	\N	2021-02-16 07:51:59.955	2021-02-16 07:51:59.955	EE49002124277
21	Add a new pet to the store	all	3	\N	2021-02-16 07:51:59.98	2021-02-16 07:51:59.98	EE49002124277
22	Update an existing pet	all	4	\N	2021-02-16 07:51:59.992	2021-02-16 07:51:59.992	EE49002124277
23	Finds Pets by status	all	5	\N	2021-02-16 07:52:00.003	2021-02-16 07:52:00.003	EE49002124277
24	Finds Pets by tags	all	6	\N	2021-02-16 07:52:00.014	2021-02-16 07:52:00.014	EE49002124277
25	Find pet by ID	all	7	\N	2021-02-16 07:52:00.024	2021-02-16 07:52:00.024	EE49002124277
26	Updates a pet in the store with form data	all	8	\N	2021-02-16 07:52:00.035	2021-02-16 07:52:00.035	EE49002124277
27	Deletes a pet	all	9	\N	2021-02-16 07:52:00.046	2021-02-16 07:52:00.046	EE49002124277
28	uploads an image	all	10	\N	2021-02-16 07:52:00.055	2021-02-16 07:52:00.055	EE49002124277
29	Returns pet inventories by status	all	11	\N	2021-02-16 07:52:00.062	2021-02-16 07:52:00.062	EE49002124277
30	Place an order for a pet	all	12	\N	2021-02-16 07:52:00.069	2021-02-16 07:52:00.069	EE49002124277
31	Find purchase order by ID	all	13	\N	2021-02-16 07:52:00.076	2021-02-16 07:52:00.076	EE49002124277
32	Delete purchase order by ID	all	14	\N	2021-02-16 07:52:00.083	2021-02-16 07:52:00.083	EE49002124277
33	Create user	all	15	\N	2021-02-16 07:52:00.09	2021-02-16 07:52:00.09	EE49002124277
34	Creates list of users with given input array	all	16	\N	2021-02-16 07:52:00.096	2021-02-16 07:52:00.096	EE49002124277
35	Creates list of users with given input array	all	17	\N	2021-02-16 07:52:00.102	2021-02-16 07:52:00.102	EE49002124277
36	Logs user into the system	all	18	\N	2021-02-16 07:52:00.109	2021-02-16 07:52:00.109	EE49002124277
37	Logs out current logged in user session	all	19	\N	2021-02-16 07:52:00.115	2021-02-16 07:52:00.115	EE49002124277
38	Get user by user name	all	20	\N	2021-02-16 07:52:00.121	2021-02-16 07:52:00.121	EE49002124277
39	Updated user	all	21	\N	2021-02-16 07:52:00.128	2021-02-16 07:52:00.128	EE49002124277
40	Delete user	all	22	\N	2021-02-16 07:52:00.134	2021-02-16 07:52:00.134	EE49002124277
\.


--
-- Data for Name: query_topic; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.query_topic (id, created, last_modified, username, query_id, topic_id) FROM stdin;
\.


--
-- Data for Name: t3_sec; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.t3_sec (id, created, last_modified, username, user_from, user_to, action_id, query, group_name, org_code, portal_name, valid_until, query_id) FROM stdin;
1	2021-02-16 07:35:03.519	2021-02-16 07:35:03.519	admin	admin	EE49002124277	8	\N	\N	1111		\N	\N
2	2021-02-16 07:35:03.525	2021-02-16 07:35:03.525	admin	admin	EE49002124277	0	\N	\N	1111		\N	\N
3	2021-02-16 08:04:12.303	2021-02-16 08:04:12.303	EE49002124277	EE49002124277	EE49002124277	0	\N	\N	1111		\N	\N
4	2021-02-16 08:05:12.172	2021-02-16 08:05:12.172	EE49002124277	EE49002124277	\N	6	\N	Tester	1111		\N	\N
5	2021-02-16 08:05:45.634	2021-02-16 08:05:45.634	EE49002124277	EE49002124277	\N	4	getRandom.v1	Tester	1111		\N	\N
6	2021-02-16 08:05:45.655	2021-02-16 08:05:45.655	EE49002124277	EE49002124277	\N	4	helloService.v1	Tester	1111		\N	\N
7	2021-02-16 08:05:45.659	2021-02-16 08:05:45.659	EE49002124277	EE49002124277	\N	4	addPet	Tester	1111		\N	\N
8	2021-02-16 08:05:45.662	2021-02-16 08:05:45.662	EE49002124277	EE49002124277	\N	4	createUser	Tester	1111		\N	\N
9	2021-02-16 08:05:45.666	2021-02-16 08:05:45.666	EE49002124277	EE49002124277	\N	4	createUsersWithArrayInput	Tester	1111		\N	\N
10	2021-02-16 08:05:45.67	2021-02-16 08:05:45.67	EE49002124277	EE49002124277	\N	4	createUsersWithListInput	Tester	1111		\N	\N
11	2021-02-16 08:05:45.673	2021-02-16 08:05:45.673	EE49002124277	EE49002124277	\N	4	deleteOrder	Tester	1111		\N	\N
12	2021-02-16 08:05:45.676	2021-02-16 08:05:45.676	EE49002124277	EE49002124277	\N	4	deleteUser	Tester	1111		\N	\N
13	2021-02-16 08:05:45.679	2021-02-16 08:05:45.679	EE49002124277	EE49002124277	\N	4	deletePet	Tester	1111		\N	\N
14	2021-02-16 08:05:45.682	2021-02-16 08:05:45.682	EE49002124277	EE49002124277	\N	4	getPetById	Tester	1111		\N	\N
15	2021-02-16 08:05:45.685	2021-02-16 08:05:45.685	EE49002124277	EE49002124277	\N	4	getOrderById	Tester	1111		\N	\N
16	2021-02-16 08:05:45.688	2021-02-16 08:05:45.688	EE49002124277	EE49002124277	\N	4	findPetsByStatus	Tester	1111		\N	\N
17	2021-02-16 08:05:45.691	2021-02-16 08:05:45.691	EE49002124277	EE49002124277	\N	4	findPetsByTags	Tester	1111		\N	\N
18	2021-02-16 08:05:45.694	2021-02-16 08:05:45.694	EE49002124277	EE49002124277	\N	4	getUserByName	Tester	1111		\N	\N
19	2021-02-16 08:05:45.697	2021-02-16 08:05:45.697	EE49002124277	EE49002124277	\N	4	logoutUser	Tester	1111		\N	\N
20	2021-02-16 08:05:45.7	2021-02-16 08:05:45.7	EE49002124277	EE49002124277	\N	4	loginUser	Tester	1111		\N	\N
21	2021-02-16 08:05:45.704	2021-02-16 08:05:45.704	EE49002124277	EE49002124277	\N	4	placeOrder	Tester	1111		\N	\N
22	2021-02-16 08:05:45.707	2021-02-16 08:05:45.707	EE49002124277	EE49002124277	\N	4	getInventory	Tester	1111		\N	\N
23	2021-02-16 08:05:45.71	2021-02-16 08:05:45.71	EE49002124277	EE49002124277	\N	4	updatePet	Tester	1111		\N	\N
24	2021-02-16 08:05:45.713	2021-02-16 08:05:45.713	EE49002124277	EE49002124277	\N	4	updateUser	Tester	1111		\N	\N
25	2021-02-16 08:05:45.717	2021-02-16 08:05:45.717	EE49002124277	EE49002124277	\N	4	updatePetWithForm	Tester	1111		\N	\N
26	2021-02-16 08:05:45.721	2021-02-16 08:05:45.721	EE49002124277	EE49002124277	\N	4	uploadFile	Tester	1111		\N	\N
27	2021-02-16 08:05:50.633	2021-02-16 08:05:50.633	EE49002124277	EE49002124277	EE49002124277	2	\N	Tester	1111		\N	\N
\.


--
-- Data for Name: topic; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.topic (id, name, priority, portal_id, created, last_modified, username) FROM stdin;
\.


--
-- Data for Name: topic_name; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.topic_name (id, description, lang, topic_id, created, last_modified, username) FROM stdin;
\.


--
-- Data for Name: xforms; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.xforms (id, form, query_id, created, last_modified, username, url) FROM stdin;
1		1	2021-02-16 07:49:10.671	2021-02-16 07:49:10.671	EE49002124277	http://
2		2	2021-02-16 07:49:10.678	2021-02-16 07:49:10.678	EE49002124277	http://
4		4	2021-02-16 07:51:59.847	2021-02-16 07:51:59.847	EE49002124277	http://
6		6	2021-02-16 07:51:59.861	2021-02-16 07:51:59.861	EE49002124277	http://
7		7	2021-02-16 07:51:59.87	2021-02-16 07:51:59.87	EE49002124277	http://
8		8	2021-02-16 07:51:59.878	2021-02-16 07:51:59.878	EE49002124277	http://
9		9	2021-02-16 07:51:59.883	2021-02-16 07:51:59.883	EE49002124277	http://
10		10	2021-02-16 07:51:59.889	2021-02-16 07:51:59.889	EE49002124277	http://
11		11	2021-02-16 07:51:59.894	2021-02-16 07:51:59.894	EE49002124277	http://
12		12	2021-02-16 07:51:59.899	2021-02-16 07:51:59.899	EE49002124277	http://
13		13	2021-02-16 07:51:59.904	2021-02-16 07:51:59.904	EE49002124277	http://
14		14	2021-02-16 07:51:59.909	2021-02-16 07:51:59.909	EE49002124277	http://
15		15	2021-02-16 07:51:59.915	2021-02-16 07:51:59.915	EE49002124277	http://
16		16	2021-02-16 07:51:59.92	2021-02-16 07:51:59.92	EE49002124277	http://
17		17	2021-02-16 07:51:59.926	2021-02-16 07:51:59.926	EE49002124277	http://
18		18	2021-02-16 07:51:59.933	2021-02-16 07:51:59.933	EE49002124277	http://
19		19	2021-02-16 07:51:59.938	2021-02-16 07:51:59.938	EE49002124277	http://
20		20	2021-02-16 07:51:59.944	2021-02-16 07:51:59.944	EE49002124277	http://
21		21	2021-02-16 07:51:59.949	2021-02-16 07:51:59.949	EE49002124277	http://
22		22	2021-02-16 07:51:59.955	2021-02-16 07:51:59.955	EE49002124277	http://
3	<html data-rf-version="1.0">\n <head></head>\n <body>\n  <h1>Add a new pet to the store</h1>\n  <!------------------------------------------------------------------------------------>\n  <!---                                 addPet.input                                 --->\n  <!------------------------------------------------------------------------------------>\n  <div class="view" id="addPet.input">\n   <form action="CS/ORG/1111/Client/pets/pet" method="POST" data-rf-content-type="application/json">\n    <h2>Pet object that needs to be added to the store</h2>\n    <div class="field">\n     <label class="property-derived">id</label>\n     <input type="number" data-rf-type="integer" data-rf-validate-format="int64" name="id" />\n    </div>\n    <div class="field">\n     <label class="property-derived">category.id</label>\n     <input type="number" data-rf-type="integer" data-rf-validate-format="int64" name="category.id" />\n    </div>\n    <div class="field">\n     <label class="property-derived">category.name</label>\n     <input type="text" name="category.name" />\n    </div>\n    <div class="field">\n     <label class="property-derived">name</label>\n     <input type="text" name="name" />\n    </div>\n    <div class="field">\n     <label class="property-derived">photoUrls</label>\n     <div class="repeat-container">\n      <div data-rf-repeat-template-path="photoUrls">\n       <div class="field">\n        <input type="text" name="" />\n        <button class="delete delete_btn">-</button>\n       </div>\n      </div>\n      <button class="add regular_btn">+</button>\n     </div>\n    </div>\n    <div class="field">\n     <label class="property-derived">tags</label>\n     <div class="repeat-container">\n      <div data-rf-repeat-template-path="tags">\n       <div class="field">\n        <label class="property-derived">id</label>\n        <input type="number" data-rf-type="integer" data-rf-validate-format="int64" name="id" />\n       </div>\n       <div class="field">\n        <label class="property-derived">name</label>\n        <input type="text" name="name" />\n       </div>\n       <div class="align-right">\n        <button class="delete delete_btn">-</button>\n       </div>\n      </div>\n      <button class="add regular_btn">+</button>\n     </div>\n    </div>\n    <div class="field">\n     <label>pet status in the store</label>\n     <select name="status"><option value="available">available</option><option value="pending">pending</option><option value="sold">sold</option></select>\n    </div>\n    <div>\n     <span><button class="send" data-rf-target="addPet.output" data-rf-lang="en">Submit</button><button class="send" data-rf-target="addPet.output" data-rf-lang="et">Esita p&auml;ring</button></span>\n    </div>\n   </form>\n  </div>\n  <!------------------------------------------------------------------------------------>\n  <!---                                addPet.output                                 --->\n  <!------------------------------------------------------------------------------------>\n  <div class="view" id="addPet.output">\n   <div data-rf-resp-code="405">\n    <div class="field">\n     <label>Response code</label>\n     <span class="output-field resp-code">405</span>\n    </div>\n    <div class="field">\n     <label>Response status</label>\n     <span class="output-field">Invalid input</span>\n    </div>\n   </div>\n   <div data-rf-resp-code="default">\n    <h2 data-rf-lang="en">Unspecified response</h2>\n    <h2 data-rf-lang="et">Tundmatu vastus</h2>\n    <div class="field">\n     <label>Response code</label>\n     <span data-rf-path="X-REST-Response-Code" data-rf-param-location="header" class="resp-code"></span>\n    </div>\n    <div class=" dynamic"></div>\n   </div>\n   <div>\n    <button class="toggle" data-rf-target="addPet.input" data-rf-lang="en">Back</button>\n    <button class="toggle" data-rf-target="addPet.input" data-rf-lang="et">Tagasi</button>\n   </div>\n  </div>\n </body>\n</html>	3	2021-02-16 07:51:59.836	2021-02-16 07:52:11.084	EE49002124277	Generated to database 02/16/2021 07:52:10
5	<html data-rf-version="1.0">\n <head></head>\n <body>\n  <h1 title="Multiple status values can be provided with comma separated strings">Finds Pets by status</h1>\n  <!------------------------------------------------------------------------------------>\n  <!---                            findPetsByStatus.input                            --->\n  <!------------------------------------------------------------------------------------>\n  <div class="view" id="findPetsByStatus.input">\n   <form action="CS/ORG/1111/Client/pets/pet/findByStatus" method="GET">\n    <div class="field">\n     <label>Status values that need to be considered for filter</label>\n     <input type="text" name="status" data-rf-param-location="url" class=" required" />\n    </div>\n    <div>\n     <span><button class="send" data-rf-target="findPetsByStatus.output" data-rf-lang="en">Submit</button><button class="send" data-rf-target="findPetsByStatus.output" data-rf-lang="et">Esita p&auml;ring</button></span>\n    </div>\n   </form>\n  </div>\n  <!------------------------------------------------------------------------------------>\n  <!---                           findPetsByStatus.output                            --->\n  <!------------------------------------------------------------------------------------>\n  <div class="view" id="findPetsByStatus.output">\n   <div data-rf-resp-code="200" data-rf-content-type="application/json">\n    <div class="field">\n     <label>Response code</label>\n     <span class="output-field resp-code">200</span>\n    </div>\n    <div class="field">\n     <label>Response status</label>\n     <span class="output-field">successful operation</span>\n    </div>\n    <div class="field">\n     <div class="repeat-container">\n      <div data-rf-repeat-template-path="">\n       <div class="field">\n        <label class="property-derived">id</label>\n        <span data-rf-path="id" class=" int64" data-rf-type="integer"></span>\n       </div>\n       <div class="field">\n        <label class="property-derived">category.id</label>\n        <span data-rf-path="category.id" class=" int64" data-rf-type="integer"></span>\n       </div>\n       <div class="field">\n        <label class="property-derived">category.name</label>\n        <span data-rf-path="category.name"></span>\n       </div>\n       <div class="field">\n        <label class="property-derived">name</label>\n        <span data-rf-path="name"></span>\n       </div>\n       <div class="field">\n        <label class="property-derived">photoUrls</label>\n        <div class="repeat-container">\n         <div data-rf-repeat-template-path="photoUrls">\n          <div class="field">\n           <span data-rf-path=""></span>\n          </div>\n         </div>\n        </div>\n       </div>\n       <div class="field">\n        <label class="property-derived">tags</label>\n        <div class="repeat-container">\n         <div data-rf-repeat-template-path="tags">\n          <div class="field">\n           <label class="property-derived">id</label>\n           <span data-rf-path="id" class=" int64" data-rf-type="integer"></span>\n          </div>\n          <div class="field">\n           <label class="property-derived">name</label>\n           <span data-rf-path="name"></span>\n          </div>\n         </div>\n        </div>\n       </div>\n       <div class="field">\n        <label>pet status in the store</label>\n        <span data-rf-path="status"></span>\n       </div>\n      </div>\n     </div>\n    </div>\n   </div>\n   <div data-rf-resp-code="400">\n    <div class="field">\n     <label>Response code</label>\n     <span class="output-field resp-code">400</span>\n    </div>\n    <div class="field">\n     <label>Response status</label>\n     <span class="output-field">Invalid status value</span>\n    </div>\n   </div>\n   <div data-rf-resp-code="default">\n    <h2 data-rf-lang="en">Unspecified response</h2>\n    <h2 data-rf-lang="et">Tundmatu vastus</h2>\n    <div class="field">\n     <label>Response code</label>\n     <span data-rf-path="X-REST-Response-Code" data-rf-param-location="header" class="resp-code"></span>\n    </div>\n    <div class=" dynamic"></div>\n   </div>\n   <div>\n    <button class="toggle" data-rf-target="findPetsByStatus.input" data-rf-lang="en">Back</button>\n    <button class="toggle" data-rf-target="findPetsByStatus.input" data-rf-lang="et">Tagasi</button>\n   </div>\n  </div>\n </body>\n</html>	5	2021-02-16 07:51:59.853	2021-02-16 07:53:04.405	EE49002124277	Generated to database 02/16/2021 07:53:04
\.


--
-- Data for Name: xroad_instance; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.xroad_instance (id, portal_id, code, in_use, selected, created, last_modified, username) FROM stdin;
4	1	CS	t	t	2021-02-16 07:47:18.208	2021-02-16 07:47:18.208	admin
\.


--
-- Data for Name: xslt; Type: TABLE DATA; Schema: misp2; Owner: postgres
--

COPY misp2.xslt (id, query_id, portal_id, xsl, priority, created, last_modified, username, name, form_type, in_use, producer_id, url) FROM stdin;
11	\N	\N	<?xml version="1.0" encoding="UTF-8"?>\n<xsl:stylesheet version="2.0"\n  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\n  xmlns:xforms="http://www.w3.org/2002/xforms"\n  xmlns:xhtml="http://www.w3.org/1999/xhtml"\n  xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"\n  xmlns:events="http://www.w3.org/2001/xml-events"\n  xmlns:xrd="http://x-road.ee/xsd/x-road.xsd"\n  xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"  \n  xmlns:xs="http://www.w3.org/2001/XMLSchema"\n  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n  xmlns:f="http://orbeon.org/oxf/xml/formatting"\n  xmlns:fr="http://orbeon.org/oxf/xml/form-runner"\n>\n<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />\n\n<xsl:param name="query"/>\n<xsl:param name="description"/>\n<xsl:param name="descriptionEncoded"/>\n<xsl:param name="xrdVersion"/>\n<xsl:param name="useIssue" select="'false'"/>\n<xsl:param name="echoURI" select="'/echo'"/>\n<xsl:param name="logURI" select="'/saveQueryLog.action'"/>\n<xsl:param name="pdfURI" select="''"/>\n<xsl:param name="basepath" select="'http://localhost:8080/misp2'"/>\n<xsl:param name="language" select="'et'"/>\n<xsl:param name="mail" select="'kasutaja@domeen.ee'"/>\n<xsl:param name="mailEncryptAllowed" select="'false'"/>\n<xsl:param name="mailSignAllowed" select="'false'"/>\n<xsl:param name="mainServiceName" select="''"/>\n<!-- copy all nodes to proceed -->\n<xsl:template match="*|@*|text()" name="copy">\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n  </xsl:copy>\n</xsl:template>\n\n<xsl:template match="xhtml:html">\n    <xsl:copy>\n      <xsl:apply-templates select="@*"/>\n      <xsl:attribute name="lang"><xsl:value-of select="$language"/></xsl:attribute>  \n      <xsl:apply-templates select="*|text()"/>\n  </xsl:copy>\n</xsl:template>  \n  \n<xsl:template match="xforms:switch">\n  <xsl:copy>\n    <div id="footer"><span id="footer-left" class="xforms-control xforms-input xforms-static xforms-readonly xforms-type-string"></span><span id="pagenumber"/></div>\n    <xsl:apply-templates select="*|text()"/>\n  </xsl:copy>\n</xsl:template> \n \n<!-- replace classifier src with basepath -->\n<xsl:template match="xforms:instance[ends-with(@id, '.classifier')]">\n  <xsl:variable name="classifierURL" select="concat($basepath, '/classifier?name=', substring-before(@id, '.classifier'))"/>\n  <xsl:copy>\n    <xsl:apply-templates select="@*"/>\n    <xsl:attribute name="src">\n      <xsl:value-of select="$classifierURL"/>\n    </xsl:attribute>\n    <xsl:apply-templates select="*|text()"/>\n  </xsl:copy>\n</xsl:template>\n\n<!-- add to submission logging function and add submission instance for XML button -->\n<xsl:template match="xforms:submission[ends-with(@id, '.submission')]">\n  <xsl:variable name="req" select="substring-before(@id, '.submission')"/>\n    <xsl:copy>\n      <xsl:apply-templates select="*|@*|text()"/>\n      <xforms:setvalue ref="instance('temp')/pdf/description" value="'{$descriptionEncoded}'" events:event="xforms-submit"/>\n      <xforms:setvalue ref="instance('temp')/pdf/email" value="'{$mail}'" events:event="xforms-submit"/>\n      <xforms:insert context="." origin="xxforms:set-session-attribute('{$req}.output', instance('{$req}.output'))" events:event="xforms-submit-done"/>\n\t  <!-- Remove all xsi:nil elements, because Orbeon does not handle them as NULLs (element not represented) -->\n      <xforms:delete nodeset="instance('{substring-before(@id, '.submission')}.output')//*[@xsi:nil = 'true']" events:event="xforms-submit-done"/>\n\t  \n    </xsl:copy>\n  <xforms:submission id="{$req}.log" xxforms:show-progress="false"\n    action="{$logURI}"\n    ref="instance('temp')/queryLog"\n    method="get"\n    replace="none"/>\n   <xforms:submission id="{$req}.pdf" xxforms:show-progress="false"\n    action="{$pdfURI}&amp;case={$req}.response&amp;"\n    ref="instance('temp')/pdf"\n    method="get"\n    replace="all"/>\n  <xforms:submission id="{$req}.xml" xxforms:show-progress="false"\n    action="{$echoURI}"\n    ref="instance('{$req}.output')"\n    method="post" \n\tvalidate="false"\n    replace="all"/>\n</xsl:template>\n\n<xsl:template match="xforms:instance[@id='temp']"/>\n<!-- instance for encrypting the query -->\n<xsl:template match="xforms:model">\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n    <xforms:instance id="temp">\n      <temp>\n        <relevant xsi:type="boolean">true</relevant>    \n        <logStart/>\n        <logEnd/>\n        <queryLog>\n          <userId/>\n          <queryId/>\n          <serviceName/>\n          <mainServiceName/>\n          <description/>\n          <queryTimeSec/>\n          <consumer/>\n\t\t  <unit/>\n        </queryLog>\n        <pdf>\n          <description/>\n          <sign xsi:type="boolean">false</sign>\n          <encrypt xsi:type="boolean">false</encrypt>\n          <sendPdfByMail xsi:type="boolean">false</sendPdfByMail>\n          <email/>\n        </pdf>\n      </temp>\n    </xforms:instance>\n    <xforms:bind nodeset="instance('temp')/pdf/sendPdfByMail" type="xs:boolean"  />\n    <xforms:bind nodeset="instance('temp')/pdf/sign" type="xs:boolean"  />\n    <xforms:bind nodeset="instance('temp')/pdf/encrypt" type="xs:boolean"  />\n    <xforms:action events:event="xforms-ready">\n       <xforms:setfocus control="input-1" />\n    </xforms:action>\n  </xsl:copy>\n</xsl:template>\n          \n<!-- Add XML and >>> buttons  (in simple query response)-->\n<xsl:template match="xforms:case[ends-with(@id, '.response')]/xforms:group[@class='actions']">\n  <xsl:variable name="form" select="substring-before(../@id, '.response')"/>\n  <xsl:copy>    \n    <xsl:apply-templates select="*|@*|text()"/>     \n      <xforms:trigger id="{substring-before(../@id, '.response')}-buttons_trigger" class="button">\n         <xforms:label xml:lang="et">Salvesta...</xforms:label>\n         <xforms:label xml:lang="en">Save...</xforms:label>\n         <xxforms:show events:event="DOMActivate" dialog="save-dialog-{substring-before(../@id, '.response')}"/>\n      </xforms:trigger>\n      <xxforms:dialog id="save-dialog-{substring-before(../@id, '.response')}" class="results-save-dialog" appearance="full" level="modal" close="true" draggable="true" visible="false" neighbor="{substring-before(../@id, '.response')}-buttons_trigger">\n        <xforms:label xml:lang="et">Teenuse vastuse salvestamine</xforms:label>\n        <xforms:label xml:lang="en">Service response saving</xforms:label>\n        <xhtml:div id="save">\n          <xhtml:div id="pdf">\n            <xhtml:h2 xml:lang="et">Salvesta failina</xhtml:h2>\n            <xhtml:h2 xml:lang="en">Save to file</xhtml:h2>\n            <xforms:trigger class="button">\n              <xforms:label>PDF</xforms:label>\n              <xforms:setvalue ref="instance('temp')/pdf/sendPdfByMail" value="'false'"/>\n              <xforms:send events:event="DOMActivate" submission="{substring-before(../@id, '.response')}.pdf"/>\n            </xforms:trigger>\n            <xforms:trigger class="button">\n              <xforms:label>XML</xforms:label>\n              <xforms:send events:event="DOMActivate" submission="{substring-before(../@id, '.response')}.xml"/>\n            </xforms:trigger> \n          </xhtml:div>\n          <xhtml:div id="email">\n            <xforms:input ref="instance('temp')/pdf/email" id="email-input-{$form}">\n\t\t\t\t<xforms:label xml:lang="et">E-post</xforms:label>\n\t\t\t\t<xforms:label xml:lang="en">E-mail</xforms:label>\n\t\t\t</xforms:input>\n            <xsl:if test="$mailSignAllowed">\n              <xforms:input ref="instance('temp')/pdf/sign" id="sign-input-{$form}">\n\t\t\t\t<xforms:label xml:lang="et">Signeeritud</xforms:label>\n\t\t\t\t<xforms:label xml:lang="en">Signed</xforms:label>\n\t\t\t</xforms:input>\n            </xsl:if>\n            <xsl:if test="$mailEncryptAllowed">\n              <xforms:input ref="instance('temp')/pdf/encrypt" id="encrypt-input-{$form}">\n\t\t\t\t<xforms:label xml:lang="et">Kr??pteeritud</xforms:label>\n\t\t\t\t<xforms:label xml:lang="en">Encrypted</xforms:label>\n\t\t\t</xforms:input>\n            </xsl:if>\n            <xforms:trigger class="button">\n              <xforms:label xml:lang="et">Saada PDF e-postile</xforms:label>\n              <xforms:label xml:lang="en">Send PDF to e-mail</xforms:label>\n              <xxforms:script events:event="DOMActivate">\n                sign = 'false';\n                encrypt = 'false';\n                try{\n                  emailInput = $("#email-input-<xsl:value-of select="$form"/>>input");\n                  signInput = ORBEON.util.Dom.getElementById("sign-input-<xsl:value-of select="$form"/>");\n                  encryptInput = ORBEON.util.Dom.getElementById("encrypt-input-<xsl:value-of select="$form"/>");\n                 \n                }catch(err){  \n                  emailInput = $("#email-input-<xsl:value-of select="$form"/>>input");\n                  signInput = ORBEON.util.Dom.get("sign-input-<xsl:value-of select="$form"/>");             \n                  encryptInput = ORBEON.util.Dom.get("encrypt-input-<xsl:value-of select="$form"/>");\n                }                 \n                if(emailInput != null){\n                   email = $("#email-input-<xsl:value-of select="$form"/>>input").val();\n                <xsl:if test="$mailSignAllowed">\n                   sign = ORBEON.xforms.Document.getValue("sign-input-<xsl:value-of select="$form"/>");\n                </xsl:if>\n                <xsl:if test="$mailEncryptAllowed">\n                   encrypt = ORBEON.xforms.Document.getValue("encrypt-input-<xsl:value-of select="$form"/>");\n                </xsl:if>\n                }                \n                sendPDFByMail("<xsl:value-of select="concat($form, '.response')"/>", email, sign, encrypt, "<xsl:value-of select="$descriptionEncoded"/>");\n              </xxforms:script>\n            </xforms:trigger>\n          </xhtml:div>        \n        </xhtml:div>\n        <xforms:action events:event="xxforms-dialog-open">\n          <xforms:setfocus control="{substring-before(../@id, '.response')}-buttons_trigger"/>\n        </xforms:action>\n      </xxforms:dialog>\n  </xsl:copy>\n</xsl:template>\n\n\n<!-- invisible values for query logging -->\n<xsl:template match="xforms:case[ends-with(@id, '.request')]">\n  <xsl:param name="serviceName" select="substring-before(@id, '.request')"/>\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n   <xsl:if test="$useIssue='true'">\n       <xhtml:br/>\n       <xforms:input ref="instance('{$serviceName}.input')//xrd:issue" class="issue">\n        <xforms:label xml:lang="et">Toimik: </xforms:label>\n        <xforms:label xml:lang="en">Issue: </xforms:label>\n        <xforms:label xml:lang="ru">Toimik: </xforms:label>\n       </xforms:input>\n       <xforms:input ref="instance('{$serviceName}.input')//xtee:toimik" class="issue">\n        <xforms:label xml:lang="et">Toimik: </xforms:label>\n        <xforms:label xml:lang="en">Issue: </xforms:label>\n        <xforms:label xml:lang="ru">Toimik: </xforms:label>\n       </xforms:input>\n       <br/>\n     </xsl:if>\n<!--    <fr:error-summary observer="{$serviceName}-xforms-request-group" id="{$serviceName}-xforms-error-summary">\n      <fr:label xml:lang="et">Vormil esinevad vead: </fr:label>\n    </fr:error-summary>-->\n  </xsl:copy>\n</xsl:template>\n  \n  \n  <xsl:template match="xforms:case[ends-with(@id, '.request')]//xforms:input">\n      <xsl:variable name="nodeset-ref" select="@ref"/>     \n      <xsl:variable name="alert-et" select="xforms:alert[@xml:lang='et']"/>\n      <xsl:variable name="alert-en" select="xforms:alert[@xml:lang='en']"/>\n      <xsl:variable name="alert-ru" select="xforms:alert[@xml:lang='ru']"/>\n      <xsl:variable name="alert-default" select="'V??li peab olema t??idetud vastavalt reeglitele'"/>\n      <xsl:choose>\n        <xsl:when test="//xforms:bind[(@constraint!='' or @required!='') and @nodeset=$nodeset-ref]/@nodeset!=''">\n           <xsl:copy>\n              <xsl:apply-templates select="*|@*"/>\n              <xforms:alert><xsl:value-of select="$alert-default"/></xforms:alert>\n              <xforms:alert xml:lang="et"><xsl:choose><xsl:when test="$alert-et!=''"><xsl:value-of select="$alert-et"/></xsl:when><xsl:otherwise><xsl:value-of select="$alert-default"/></xsl:otherwise></xsl:choose></xforms:alert>\n             <xforms:alert xml:lang="ru"><xsl:choose><xsl:when test="$alert-ru!=''"><xsl:value-of select="$alert-ru"/></xsl:when><xsl:otherwise><xsl:value-of select="$alert-default"/></xsl:otherwise></xsl:choose></xforms:alert>\n             <xforms:alert xml:lang="en"><xsl:choose><xsl:when test="$alert-en!=''"><xsl:value-of select="$alert-en"/></xsl:when><xsl:otherwise><xsl:value-of select="$alert-default"/></xsl:otherwise></xsl:choose></xforms:alert>\n            </xsl:copy> \n          </xsl:when>\n          <xsl:otherwise>\n            <xsl:copy>\n              <xsl:apply-templates select="*|@*"/>\n            </xsl:copy> \n          </xsl:otherwise>\n      </xsl:choose>  \n   </xsl:template>  \n  \n<!--<xsl:template match="xforms:submit[ends-with(@submission, '.submission')]">\n  <xsl:variable name="form" select="substring-before(@submission, '.submission')"/>\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n    <xforms:dispatch events:event="DOMActivate" name="fr-visit-all" targetid="{$form}-xforms-error-summary"/>\n  </xsl:copy>\n</xsl:template>\n  \n<xsl:template match="xforms:case[ends-with(@id, '.request')]//xforms:group[@ref='request'] | xforms:case[ends-with(@id, '.request')]//xforms:group[@ref='keha']">\n  <xsl:copy>\n   <xsl:apply-templates select="@*"/>\n   <xsl:attribute name="id">\n    <xsl:value-of select="concat(substring-before((./ancestor::xforms:case[ends-with(@id, 'request')]/@id), '.request'), '-xforms-request-group')"/>\n   </xsl:attribute>\n   <xsl:apply-templates select="*|text()"/>\n </xsl:copy>\n</xsl:template>\n   -->  \n</xsl:stylesheet>	10	2021-01-27 10:25:45.802303	2021-01-27 10:25:45.802303	admin	debug	0	t	\N	http://www.aktors.ee/support/xroad/xsl/debug.xsl
12	\N	\N	<?xml version="1.0" encoding="UTF-8"?>\n<xsl:stylesheet version="2.0" \n  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\n  xmlns:xforms="http://www.w3.org/2002/xforms"\n  xmlns:xhtml="http://www.w3.org/1999/xhtml"\n  xmlns:events="http://www.w3.org/2001/xml-events"\n  xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"\n  xmlns:xrd="http://x-road.ee/xsd/x-road.xsd"\n  xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"\n  xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"\n  xmlns:xrd6="http://x-road.eu/xsd/xroad.xsd"\n  xmlns:iden="http://x-road.eu/xsd/identifiers"\n  xmlns:repr="http://x-road.eu/xsd/representation.xsd">\n  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />\n  <xsl:param name="producer"/>\n  <xsl:param name="query"/>\n  <xsl:param name="userId"/>\n  <xsl:param name="messageMediator"/>\n  <xsl:param name="orgCode"/>\n  <xsl:param name="queryId"/>\n  <xsl:param name="suborgCode"/>\n  <xsl:param name="xrdVersion"/>\n  <xsl:param name="basepath"/>\n  <xsl:param name="descriptionEncoded"/>    \n  <xsl:param name="description"/>\n  <xsl:param name="portalName"/>\n  <xsl:param name="authenticator"/>\n  <xsl:param name="userName"/>\n  <xsl:param name="userFirstName"/>\n  <xsl:param name="userLastName"/>  \n  <xsl:param name="version"/>\n  <xsl:param name="xroad6-client-xroad-instance"/>\n  <xsl:param name="xroad6-client-member-class"/>\n  <xsl:param name="xroad6-client-member-code"/>\n  <xsl:param name="xroad6-client-subsystem-code"/>\n  <xsl:param name="xroad6-represented-party-class"/>\n  <xsl:param name="xroad6-represented-party-code"/>\n  <xsl:param name="xroad6-represented-party-name"/>\n  \n  <xsl:template match="*|@*|text()">\n    <xsl:copy>\n      <xsl:apply-templates select="*|@*|text()"/>\n    </xsl:copy>\n  </xsl:template>\n\n  <xsl:template match="xrd:userId|xtee:isikukood">\n    <xsl:copy>\n      <xsl:value-of select="$userId"/>\n    </xsl:copy>\n  </xsl:template>\n    \n  <xsl:template match="xrd6:client/iden:xRoadInstance">\n    <xsl:copy>\n      <xsl:value-of select="$xroad6-client-xroad-instance"/>\n    </xsl:copy>\n  </xsl:template>\n    \n  <xsl:template match="xrd6:client/iden:memberClass">\n    <xsl:copy>\n      <xsl:value-of select="$xroad6-client-member-class"/>\n    </xsl:copy>\n  </xsl:template>\n    \n  <xsl:template match="xrd6:client/iden:memberCode">\n    <xsl:copy>\n      <xsl:value-of select="$xroad6-client-member-code"/>\n    </xsl:copy>\n  </xsl:template>\n  \n  <xsl:template match="xrd6:client/iden:subsystemCode">\n    <xsl:copy>\n      <xsl:value-of select="$xroad6-client-subsystem-code"/>\n    </xsl:copy>\n  </xsl:template>\n\n \n  <!-- Remove representedPartyElement if it exists -->\n  <xsl:template match="SOAP-ENV:Header/repr:representedParty"/>\n  <!-- Append represented party element with class and code elements if the values are given as parameters -->\n  <xsl:template match="SOAP-ENV:Header[$xroad6-represented-party-class and $xroad6-represented-party-code]">\n     <!-- Copy the element -->\n    <xsl:copy>\n      <xsl:apply-templates select="@* | *"/> \n      <!-- Add new node (or whatever else you wanna do) -->\n      <repr:representedParty>\n        <repr:partyClass><xsl:value-of select="$xroad6-represented-party-class"/></repr:partyClass>\n        <repr:partyCode><xsl:value-of select="$xroad6-represented-party-code"/></repr:partyCode>\n      </repr:representedParty>\n    </xsl:copy>\n  </xsl:template>\n\n  <xsl:template match="xrd:consumer">\n    <xsl:copy>\n      <xsl:value-of select="$orgCode"/>\n    </xsl:copy>\n    <xsl:if test="$suborgCode!=''">\n      <xrd:unit>\n        <xsl:value-of select="$suborgCode"/>\n      </xrd:unit>\n    </xsl:if>\n  </xsl:template>\n\n  <xsl:template match="xtee:asutus">\n    <xsl:copy>\n      <xsl:value-of select="$orgCode"/>\n    </xsl:copy>\n    <xsl:if test="$suborgCode!=''">\n      <xtee:allasutus>\n        <xsl:value-of select="$suborgCode"/>\n      </xtee:allasutus>\n    </xsl:if>\n  </xsl:template>\n    \n    \n  <xsl:template match="xrd:id|xtee:id">\n    <xsl:copy>\n      <xsl:value-of select="$queryId"/>\n    </xsl:copy>\n  </xsl:template>\n\n  <xsl:template match="xtee:ametnik">\n    <xsl:copy>\n      <xsl:value-of select="substring($userId,3)"/>\n    </xsl:copy>\n  </xsl:template>\n  \n  <xsl:template match="xtee:autentija|xrd:authenticator">\n    <xsl:copy>\n      <xsl:value-of select="$authenticator"/>\n    </xsl:copy>\n  </xsl:template>\n    \n  <xsl:template match="xtee:ametniknimi|xrd:userName">\n    <xsl:copy>\n      <xsl:value-of select="$userName"/>\n    </xsl:copy>\n  </xsl:template>\n  \n  <xsl:template match="xforms:submission[ends-with(@id, '.submission')]">\n   <xsl:copy>\n      <xsl:apply-templates select="@*"/>\n     <xsl:choose>\n      <xsl:when test="//xforms:bind[@type='xforms:base64Binary'] or //xforms:bind[@type='xforms:hexBinary']"> \n        <xsl:attribute name="action">\n          <xsl:value-of select="concat($messageMediator, '&amp;attachment=true')"/>\n        </xsl:attribute>\n       </xsl:when>\n       <xsl:otherwise>\n         <xsl:attribute name="action">\n            <xsl:value-of select="$messageMediator"/>\n         </xsl:attribute>\n       </xsl:otherwise>     \n     </xsl:choose>\n      <xsl:apply-templates select="*|text()"/>\n    </xsl:copy>\n  </xsl:template>\n  <xsl:template match="xforms:model/xforms:instance[@id='temp']/temp">\n    <xsl:copy>      \n      <xsl:apply-templates select="*|@*|text()"/>\n      <xsl:element name="userFirstName"><xsl:value-of select="$userFirstName"/></xsl:element>\n      <xsl:element name="userLastName"><xsl:value-of select="$userLastName"/></xsl:element>\n      <xsl:if test="$xroad6-represented-party-name != ''"> \n        <xsl:element name="unitName"><xsl:value-of select="$xroad6-represented-party-name"/></xsl:element>\n      </xsl:if>\n    </xsl:copy>\n  </xsl:template>  \n</xsl:stylesheet>	20	2021-01-27 10:25:45.804349	2021-01-27 10:25:45.804349	admin	headers	0	t	\N	http://www.aktors.ee/support/xroad/xsl/headers.xsl
13	\N	\N	<?xml version="1.0" encoding="UTF-8"?>\n<xsl:stylesheet version="2.0" \n    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">\n<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />\n<xsl:param name="language" select="'et'"/>\n\n<!-- Default template, that copies node to output and applies templates to all child nodes. -->\n<xsl:template match="@*|*|text()">\n  <!--xsl:message><xsl:value-of select="name()" /></xsl:message-->\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n  </xsl:copy>\n</xsl:template>\n\n<xsl:template match="*[@xml:lang != $language]"/>\n\n</xsl:stylesheet>	30	2021-01-27 10:25:45.805379	2021-01-27 10:25:45.805379	admin	i18n	0	t	\N	http://www.aktors.ee/support/xroad/xsl/i18n.xsl
14	\N	\N	<?xml version="1.0" encoding="UTF-8"?>\n<xsl:stylesheet version="2.0" \n    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" \n    xmlns:xhtml="http://www.w3.org/1999/xhtml"\n    xmlns:xforms="http://www.w3.org/2002/xforms"\n    xmlns:events="http://www.w3.org/2001/xml-events"\n    xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"\n    xmlns:exf="http://www.exforms.org/exf/1-0"\n\txmlns:xs="http://www.w3.org/2001/XMLSchema"\n>\n<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />\n\n<!-- Default template, that copies node to output and applies templates to all child nodes. -->\n<xsl:template match="@*|*|text()">\n  <!--xsl:message><xsl:value-of select="name()" /></xsl:message-->\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n  </xsl:copy>\n</xsl:template>\n\n<!-- Dummy template to get xxforms namespace mentioned at root level. -->\n<xsl:template match="xhtml:html">\n  <xsl:copy>\n    <xsl:namespace name="xxforms" select="'http://orbeon.org/oxf/xml/xforms'"/>\n    <xsl:namespace name="exf" select="'http://www.exforms.org/exf/1-0'"/>\n    <xsl:namespace name="xsd" select="'http://www.w3.org/2001/XMLSchema'"/>\n    <xsl:apply-templates select="@* | *">\n      <xsl:with-param name="heading-level" select="2" tunnel="yes" />\n    </xsl:apply-templates>\n  </xsl:copy>\n</xsl:template>\n\n<!-- Creates heading for a group label. -->\n<xsl:template match="xforms:group" mode="group-label-as-heading">\n  <xsl:param name="heading-level" tunnel="yes" />\n  <xsl:if test="xforms:label">\n    <!-- Generate id for the group that can be referenced by label. -->\n    <xsl:if test="not(@id)">\n      <xsl:attribute name="id" select="generate-id()"/>\n    </xsl:if>\n    <xsl:element name="h{$heading-level}" namespace="http://www.w3.org/1999/xhtml">\n      <xsl:apply-templates select="." mode="copy-label-only" />\n    </xsl:element>\n  </xsl:if>\n</xsl:template>\n\n<!-- Copies only label. -->\n<xsl:template match="*" mode="copy-label-only">\n  <xsl:choose>\n    <!-- Label of trigger is not copied. -->\n    <xsl:when test="local-name() = ('trigger','submit') and namespace-uri() = 'http://www.w3.org/2002/xforms'">\n    </xsl:when>\n    <!-- Add for attribute to all labels. -->\n    <xsl:otherwise>\n      <xsl:for-each select="xforms:label">\n        <xsl:copy>\n          <xsl:attribute name="for" select="if (../@id) then ../@id else generate-id(..)"/>\n          <xsl:copy-of select="@* | * | text()" />\n        </xsl:copy>\n      </xsl:for-each>\n    </xsl:otherwise>\n  </xsl:choose>\n</xsl:template>\n\n<!-- Creates xforms:output, that outputs the same as label. -->\n<xsl:template match="*" mode="copy-header-only">\n  <xsl:choose>\n    <!-- Label of trigger is not copied. -->\n    <xsl:when test="local-name() = ('trigger','submit') and namespace-uri() = 'http://www.w3.org/2002/xforms'">\n    </xsl:when>\n    <!-- HACK: Add a dummy <xforms:output> around label and help. -->\n    <xsl:otherwise>\n      <xforms:output value="''">\n        <xsl:copy-of select="xforms:label | xforms:help" />\n      </xforms:output>\n    </xsl:otherwise>\n  </xsl:choose>\n</xsl:template>\n\n<!-- Copies a node and all of its children except xforms:label. -->\n<xsl:template match="*" mode="copy-all-but-label">\n  <xsl:variable name="temp">\n    <xsl:choose>\n      <!-- Trigger is copied intact. -->\n      <xsl:when test="local-name() = ('trigger','submit') and namespace-uri(..) = 'http://www.w3.org/2002/xforms'">\n        <xsl:copy-of select="." />\n      </xsl:when>\n      <xsl:otherwise>\n        <xsl:copy>\n          <!-- Generate id for the control that can be referenced by label. -->\n          <xsl:if test="not(@id)">\n            <xsl:attribute name="id" select="generate-id()"/>\n          </xsl:if>\n          <xsl:copy-of select="@* | (* except xforms:label) | text()" />\n        </xsl:copy>\n      </xsl:otherwise>\n    </xsl:choose>\n  </xsl:variable>\n  <xsl:apply-templates select="$temp" />\n</xsl:template>\n\n<!-- Copies a node and all of its children except xforms:label and xforms:help. -->\n<xsl:template match="*" mode="copy-all-but-header">\n  <xsl:variable name="temp">\n    <xsl:choose>\n      <!-- Trigger is copied intact. -->\n      <xsl:when test="local-name() = ('trigger','submit') and namespace-uri(..) = 'http://www.w3.org/2002/xforms'">\n        <xsl:copy-of select="." />\n      </xsl:when>\n      <xsl:otherwise>\n        <xsl:copy>\n          <xsl:copy-of select="@* | (* except (xforms:label | xforms:help)) | text()" />\n        </xsl:copy>\n      </xsl:otherwise>\n    </xsl:choose>\n  </xsl:variable>\n  <xsl:apply-templates select="$temp" />\n</xsl:template>\n\n<!-- Creates vertical table for group with appearance="full". -->\n<xsl:template match="xforms:group[@appearance='full']" name="group-full">\n  <xsl:param name="heading-level" tunnel="yes" />\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:apply-templates select="." mode="group-label-as-heading"/>\n    <xhtml:table class="group-full">\n      <xhtml:tbody>\n        <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert)">\n          <xhtml:tr>\n            <xsl:if test="@ref or @nodeset">\n              <xsl:attribute name="class" select="concat('{if (not(.[', if (@ref) then @ref else @nodeset, '])) then ''xforms-disabled-subsequent'' else ''''}')" />\n            </xsl:if>\n            <xsl:choose>\n              <xsl:when test="namespace-uri() != 'http://www.w3.org/2002/xforms' or local-name() = ('trigger', 'submit', 'repeat') or (local-name() = 'group' and not(xforms:label))">\n                <xhtml:td class="group-full-value" colspan="2">\n                  <xsl:apply-templates select=".">\n                    <xsl:with-param name="heading-level" select="if (../xforms:label) then $heading-level + 1 else $heading-level" tunnel="yes" />\n                  </xsl:apply-templates>\n                </xhtml:td>\n              </xsl:when>\n              <xsl:otherwise>\n                <xhtml:th class="group-full-label">\n                  <xsl:apply-templates select="." mode="copy-label-only" />\n                </xhtml:th>\n                <xhtml:td class="group-full-value">\n                  <xsl:apply-templates select="." mode="copy-all-but-label">\n                    <xsl:with-param name="heading-level" select="if (../xforms:label) then $heading-level + 1 else $heading-level" tunnel="yes" />\n                  </xsl:apply-templates>\n                </xhtml:td>\n              </xsl:otherwise>\n            </xsl:choose>\n          </xhtml:tr>\n        </xsl:for-each>\n      </xhtml:tbody>\n    </xhtml:table>\n  </xsl:copy>\n</xsl:template>\n\n<!-- Creates horizontal table for group with appearance="compact". -->\n<xsl:template match="xforms:group[@appearance='compact']" name="group-compact">\n  <xsl:param name="heading-level" tunnel="yes" />\n  <!--xsl:message select="concat('xforms:group[@ref=',@ref,'] and @appearance=compact')" /-->\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:apply-templates select="." mode="group-label-as-heading"/>\n    <xhtml:table class="group-compact">\n      <xhtml:thead>\n        <xhtml:tr>\n          <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert)">\n            <xhtml:th class="group-compact-label">\n              <xsl:apply-templates select="." mode="copy-label-only" />\n            </xhtml:th>\n          </xsl:for-each>\n        </xhtml:tr>\n      </xhtml:thead>\n      <xhtml:tbody>\n        <xhtml:tr>\n          <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert)">\n            <xhtml:td class="group-compact-value">\n              <xsl:apply-templates select="." mode="copy-all-but-label">\n                <xsl:with-param name="heading-level" select="if (../xforms:label) then $heading-level + 1 else $heading-level" tunnel="yes" />\n              </xsl:apply-templates>\n            </xhtml:td>\n          </xsl:for-each>\n        </xhtml:tr>\n      </xhtml:tbody>\n    </xhtml:table>\n  </xsl:copy>\n</xsl:template>\n\n<!-- No specific layout when appearance="minimal". -->\n<xsl:template match="xforms:group[@appearance='minimal']" name="group-minimal">\n  <xsl:param name="heading-level" tunnel="yes" />\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:apply-templates select="." mode="group-label-as-heading"/>\n    <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert)">\n      <xhtml:span class="group-minimal-field">\n        <xsl:apply-templates select=".">\n          <xsl:with-param name="heading-level" select="if (../xforms:label) then $heading-level + 1 else $heading-level" tunnel="yes" />\n        </xsl:apply-templates>\n      </xhtml:span>\n    </xsl:for-each>\n  </xsl:copy>\n</xsl:template>\n\n<!-- Determines best layout for xforms:group with no appearance attribute. -->\n<xsl:template match="xforms:group">\n  <!--xsl:message select="concat('xforms:group[@ref=',@ref,']')" /-->\n  <xsl:choose>\n    <!-- Ignore xforms:groups with class="help". -->\n    <xsl:when test="@class = 'help'">\n      <xsl:copy>\n        <xsl:apply-templates select="@*|node()"/>\n      </xsl:copy>\n    </xsl:when>\n    <!-- If all children are missing xforms:label, then minimal appearance is better choice than full. -->\n    <xsl:when test="count(xforms:*[xforms:label]) = 0">\n      <xsl:call-template name="group-minimal" />\n    </xsl:when>\n    <!-- If there are more than one children, that are common UI components, then use full group. -->\n    <xsl:when test="count(xforms:* except (xforms:label | xforms:help | xforms:hint | xforms:alert | xforms:group | xforms:repeat | xforms:trigger | xforms:submit)) > 1">\n      <xsl:call-template name="group-full" />\n    </xsl:when>\n    <!-- Otherwise minimal appearance. -->\n    <xsl:otherwise>\n      <xsl:call-template name="group-minimal" />\n    </xsl:otherwise>\n  </xsl:choose>\n</xsl:template>\n\n<!-- Creates vertical table for repeats with appearance="full". -->\n<xsl:template match="xforms:repeat[@appearance='full']" name="repeat-full">\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xhtml:table class="repeat-full">\n      <xhtml:tbody>\n        <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert)">\n          <xhtml:tr>\n            <xsl:if test="@ref or @nodeset">\n              <xsl:attribute name="class" select="concat('{if (not(.[', if (@ref) then @ref else @nodeset, '])) then ''xforms-disabled-subsequent'' else ''''}')" />\n            </xsl:if>\n            <xhtml:th class="repeat-full-label">\n              <xsl:apply-templates select="." mode="copy-label-only" />\n            </xhtml:th>\n            <xhtml:td class="repeat-full-value">\n              <xsl:apply-templates select="." mode="copy-all-but-label" />\n            </xhtml:td>\n          </xhtml:tr>\n        </xsl:for-each>\n      </xhtml:tbody>\n    </xhtml:table>\n  </xsl:copy>\n</xsl:template>\n\n<!-- Creates horizontal table for repeats with appearance="compact". -->\n<xsl:template match="xforms:repeat[@appearance='compact']" name="repeat-compact">\n  <!--xsl:message select="concat('xforms:repeat[@nodeset=',@nodeset,'] and @appearance=compact')" /-->\n  <xhtml:div class="{{if (not({@nodeset})) then ' xforms-disabled-subsequent' else ''}}">\n    <xhtml:table class="repeat-compact">\n      <xhtml:thead>\n        <xhtml:tr>\n          <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert | xxforms:variable)">\n            <xhtml:th class="repeat-compact-label">\n              <xsl:apply-templates select="." mode="copy-header-only" />\n            </xhtml:th>\n          </xsl:for-each>\n        </xhtml:tr>\n      </xhtml:thead>\n      <xsl:copy>\n        <xsl:copy-of select="@*" />\n        <xhtml:tbody>\n          <xhtml:tr>\n            <xsl:for-each select="xxforms:variable">\n                <xsl:apply-templates select="." mode="copy-all-but-header" />\n            </xsl:for-each>\n            <xsl:for-each select="* except (xxforms:variable | xforms:label | xforms:help | xforms:hint | xforms:alert)">\n              <xhtml:td class="repeat-compact-value">\n                <xsl:apply-templates select="." mode="copy-all-but-header" />\n              </xhtml:td>\n            </xsl:for-each>     \n            <xsl:for-each select="xhtml:tr">\n                <xsl:apply-templates select="." mode="copy-all-but-header" />\n            </xsl:for-each>\n          </xhtml:tr>\n        </xhtml:tbody>\n      </xsl:copy>\n    </xhtml:table>\n  </xhtml:div>\n</xsl:template>\n\n<!-- Creates horizontal table for repeats with appearance="small". -->\n<xsl:template match="xforms:repeat[@appearance='']" name="repeat-small">\n  <!--xsl:message select="concat('xforms:repeat[@nodeset=',@nodeset,'] and @appearance=compact')" /-->\n  <xhtml:div class="{{if (not({@nodeset})) then ' xforms-disabled-subsequent' else ''}}">\n    <xhtml:table class="repeat-small">\n      <xhtml:thead>\n        <xhtml:tr>\n          <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert | xxforms:variable)">\n            <xhtml:th class="repeat-small-label">\n              <xsl:apply-templates select="." mode="copy-header-only" />\n            </xhtml:th>\n          </xsl:for-each>\n        </xhtml:tr>\n      </xhtml:thead>\n      <xsl:copy>\n        <xsl:copy-of select="@*" />\n        <xhtml:tbody>\n          <xhtml:tr>\n            <xsl:for-each select="xxforms:variable">\n                <xsl:apply-templates select="." mode="copy-all-but-header" />\n            </xsl:for-each>\n            <xsl:for-each select="* except (xxforms:variable | xforms:label | xforms:help | xforms:hint | xforms:alert)">\n              <xhtml:td class="repeat-small-value">\n                <xsl:apply-templates select="." mode="copy-all-but-header" />\n              </xhtml:td>\n            </xsl:for-each>            \n          </xhtml:tr>\n        </xhtml:tbody>\n      </xsl:copy>\n    </xhtml:table>\n  </xhtml:div>\n</xsl:template>\n\n<!-- Every repeat instance in separate block when appearance="minimal". -->\n<xsl:template match="xforms:repeat[@appearance='minimal']" name="repeat-minimal">\n  <!--xsl:message select="concat('xforms:repeat[@nodeset=',@nodeset,' and @appearance=minimal]')" /-->\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:for-each select="* except (xforms:label | xforms:help | xforms:hint | xforms:alert)">\n      <xhtml:div>\n        <xsl:apply-templates select="."/>\n      </xhtml:div>\n    </xsl:for-each>\n  </xsl:copy>\n</xsl:template>\n\n<!-- Determines best layout for xforms:repeat when there is no appearance attribute. -->\n<xsl:template match="xforms:repeat">\n  <!--xsl:message select="concat('xforms:repeat[@nodeset=',@nodeset,']')" /-->\n  <xsl:choose>\n    <!-- When there is one child then minimal appearance. -->\n    <xsl:when test="count(*) = 1">\n      <xsl:call-template name="repeat-minimal" />\n    </xsl:when>\n    <!-- When there are 3-4 children, then use compact appearance. -->\n    <xsl:when test="count(*) &gt; 2 and count(*) &lt; 6">\n      <xsl:call-template name="repeat-small" />\n    </xsl:when>\n    <!-- When there are 5-7 children, then use compact appearance. -->\n    <xsl:when test="count(*) &gt; 5 and count(*) &lt; 8">\n      <xsl:call-template name="repeat-compact" />\n    </xsl:when>\n    <!-- Otherwise use full appearance. -->\n    <xsl:otherwise>\n      <xsl:call-template name="repeat-full" />\n    </xsl:otherwise>\n  </xsl:choose>\n</xsl:template>\n\n<!-- Set texts and lookup instances read-only, this should speed up form a bit. -->\n<xsl:template match="xforms:instance[ends-with(@id, 'texts') or starts-with(@id, 'lookup')]">\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:attribute name="xxforms:readonly" select="'true'" />\n    <xsl:apply-templates />\n  </xsl:copy>\n</xsl:template>\n\n<!-- Set classifier instances as read-only and cached. -->\n<xsl:template match="xforms:instance[ends-with(@id, 'classifier')]">\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:attribute name="xxforms:readonly" select="'true'" />\n    <xsl:attribute name="xxforms:cache" select="'true'" />\n    <xsl:apply-templates />\n  </xsl:copy>\n</xsl:template>\n\n<xsl:template match="xforms:bind[@type='xforms:float'] | xforms:bind[@type='xforms:double']">\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:attribute name="readonly" select="'false'" />\n    <xsl:attribute name="calculate" select="'if (translate(., '','', ''.'') castable as xs:double) then format-number(xs:decimal(xs:double(translate(., '','', ''.''))), ''###0.000'') else '''''" />\n    <xsl:apply-templates />\n  </xsl:copy>\n</xsl:template>\n      \n<xsl:template match="xforms:bind[@type='xforms:decimal']">\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:attribute name="readonly" select="'false'" />\n    <xsl:attribute name="calculate" select="'if (translate(., '','', ''.'') castable as xs:double) then format-number(xs:decimal(xs:double(translate(., '','', ''.''))), ''###0.00'') else '''''" />\n    <xsl:apply-templates />\n  </xsl:copy>\n</xsl:template>\n      \n<xsl:template match="xforms:bind[@type='xforms:integer']">\n  <xsl:copy>\n    <xsl:copy-of select="@*" />\n    <xsl:attribute name="readonly" select="'false'" />\n    <xsl:attribute name="calculate" select="'if (translate(., '','', ''.'') castable as xs:double) then format-number(xs:decimal(xs:double(translate(., '','', ''.''))), ''###0'') else '''''" />\n    <xsl:apply-templates />\n  </xsl:copy>\n</xsl:template>\n\n</xsl:stylesheet>	40	2021-01-27 10:25:45.806977	2021-01-27 10:25:45.806977	admin	orbeon	0	t	\N	http://www.aktors.ee/support/xroad/xsl/orbeon.xsl
15	\N	\N	<?xml version="1.0" encoding="UTF-8"?>\n<xsl:stylesheet version="2.0" \n  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\n  xmlns:xforms="http://www.w3.org/2002/xforms"\n  xmlns:xhtml="http://www.w3.org/1999/xhtml"\n  xmlns:events="http://www.w3.org/2001/xml-events"\n  xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"\n  xmlns:xxforms="http://orbeon.org/oxf/xml/xforms">\n  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />\n\n  <xsl:template match="*|@*|text()" name="copy">\n    <xsl:copy>\n      <xsl:apply-templates select="*|@*|text()"/>\n    </xsl:copy>\n  </xsl:template>\n   <xsl:template match="xforms:instance[ends-with(@id, '.input')]//*">\n    <xsl:variable name="nodeset-ref" select="name()"/>\n    <xsl:choose>\n\t  <xsl:when test="//xforms:bind[@type='xforms:hexBinary' and @nodeset=$nodeset-ref]">\n\t    <xsl:copy>\n          <xsl:apply-templates select="*|@*|text()"/>\n          <xsl:attribute name="hexBinaryFileType">\n            <xsl:value-of select="'true'"/>\n          </xsl:attribute>  \n        </xsl:copy>\n      </xsl:when>\n      <xsl:otherwise>\n        <xsl:copy>\n          <xsl:apply-templates select="*|@*|text()"/>\n        </xsl:copy> \n      </xsl:otherwise>\n    </xsl:choose>\n   </xsl:template>\n   <xsl:template match="xforms:bind[@type='xforms:hexBinary']">\n     <xsl:copy>      \n       <xsl:apply-templates select="@*"/>\n       <xsl:attribute name="type">\n         <xsl:value-of select="'xforms:anyURI'"/>\n       </xsl:attribute>  \n       <xsl:apply-templates select="*|text()"/>\n     </xsl:copy>\n   </xsl:template>\n   \n    <xsl:template match="xforms:case[ends-with(@id, '.response')]//xforms:trigger[@ref]">\n      <xsl:variable name="nodeset-ref" select="@ref"/>\n\t  <!-- Find itself or first ancestor that is not '.', because '.' does not mach xforms:bind element and file download content is not replaced -->\n      <xsl:variable name="nodeset-name" select="if(@ref = '.') then ancestor::*[@ref and @ref != '.'][1]/@ref else @ref"/>\n      <xsl:variable name="label-et" select="xforms:label[@xml:lang='et']"/>\n      <xsl:variable name="label-en" select="xforms:label[@xml:lang='en']"/>\n      <xsl:variable name="label-ru" select="xforms:label[@xml:lang='ru']"/>\n      <xsl:variable name="label-default" select="'Laadi alla'"/>\n      <!--DEBUG: <xhtml:script>alert("type-count: <xsl:value-of select="count(//xforms:bind[@type='xforms:base64Binary'])"/> \nnodeset: <xsl:value-of select="//xforms:bind[@type='xforms:base64Binary']/@nodeset"/> nodeset-name: <xsl:value-of select="$nodeset-name"/>");</xhtml:script> -->\n       <xsl:choose>\n        <xsl:when test="//xforms:bind[@type='xforms:base64Binary' and @nodeset=$nodeset-name]">  \n          <!--DEBUG: <xhtml:script>alert("2");</xhtml:script>-->  \n           <xforms:output ref="{$nodeset-ref}" appearance="xxforms:download">\n            <xforms:filename ref="replace(@filename | ../filename, '&#34;', '')"/>\n            <xforms:label xml:lang="et"><xsl:choose><xsl:when test="$label-et!=''"><xsl:value-of select="$label-et"/></xsl:when><xsl:otherwise><xsl:value-of select="$label-default"/></xsl:otherwise></xsl:choose></xforms:label>\n            <xforms:label xml:lang="ru"><xsl:choose><xsl:when test="$label-ru!=''"><xsl:value-of select="$label-ru"/></xsl:when><xsl:otherwise><xsl:value-of select="$label-default"/></xsl:otherwise></xsl:choose></xforms:label>\n            <xforms:label xml:lang="en"><xsl:choose><xsl:when test="$label-en!=''"><xsl:value-of select="$label-en"/></xsl:when><xsl:otherwise><xsl:value-of select="$label-default"/></xsl:otherwise></xsl:choose></xforms:label>\n            <xforms:label><xsl:value-of select="$label-default"/></xforms:label>\n         </xforms:output> \n        </xsl:when>\n        <xsl:otherwise>\n            <xsl:copy>\n              <xsl:apply-templates select="*|@*"/>\n            </xsl:copy> \n          </xsl:otherwise>\n      </xsl:choose>  \n    </xsl:template>\n    \n    <xsl:template match="xforms:case[ends-with(@id, '.response')]//xforms:output[@ref]">\n      <xsl:variable name="nodeset-ref" select="@ref"/> \n      <xsl:variable name="label-et" select="xforms:label[@xml:lang='et']"/>\n      <xsl:variable name="label-en" select="xforms:label[@xml:lang='en']"/>\n      <xsl:variable name="label-ru" select="xforms:label[@xml:lang='ru']"/>\n      <xsl:variable name="label-default" select="'Laadi alla'"/>\n      <xsl:choose>\n        <xsl:when test="//xforms:bind[@type='xforms:base64Binary' and @nodeset=$nodeset-ref]/@nodeset!='' and not(contains(@mediatype,  'image'))">\n           <xforms:output ref="{$nodeset-ref}" appearance="xxforms:download">\n            <xforms:filename ref="@filename | ../filename"/>\n            <xforms:label xml:lang="et"><xsl:choose><xsl:when test="$label-et!=''"><xsl:value-of select="$label-et"/></xsl:when><xsl:otherwise><xsl:value-of select="$label-default"/></xsl:otherwise></xsl:choose></xforms:label>\n            <xforms:label xml:lang="ru"><xsl:choose><xsl:when test="$label-ru!=''"><xsl:value-of select="$label-ru"/></xsl:when><xsl:otherwise><xsl:value-of select="$label-default"/></xsl:otherwise></xsl:choose></xforms:label>\n            <xforms:label xml:lang="en"><xsl:choose><xsl:when test="$label-en!=''"><xsl:value-of select="$label-en"/></xsl:when><xsl:otherwise><xsl:value-of select="$label-default"/></xsl:otherwise></xsl:choose></xforms:label>\n            <xforms:label><xsl:value-of select="$label-default"/></xforms:label>\n           </xforms:output>\n          </xsl:when>\n          <xsl:otherwise>\n            <xsl:copy>\n              <xsl:apply-templates select="*|@*"/>\n            </xsl:copy> \n          </xsl:otherwise>\n      </xsl:choose>  \n   </xsl:template>\n</xsl:stylesheet>	50	2021-01-27 10:25:45.808431	2021-01-27 10:25:45.808431	admin	attachments	0	t	\N	http://www.aktors.ee/support/xroad/xsl/attachments.xsl
\.


--
-- Name: admin_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.admin_id_seq', 1, true);


--
-- Name: check_register_status_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.check_register_status_id_seq', 1, false);


--
-- Name: classifier_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.classifier_id_seq', 18, true);


--
-- Name: group__id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.group__id_seq', 1, true);


--
-- Name: group_item_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.group_item_id_seq', 22, true);


--
-- Name: group_person_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.group_person_id_seq', 1, true);


--
-- Name: manager_candidate_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.manager_candidate_id_seq', 1, false);


--
-- Name: news_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.news_id_seq', 1, false);


--
-- Name: org_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.org_id_seq', 1, true);


--
-- Name: org_name_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.org_name_id_seq', 1, true);


--
-- Name: org_person_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.org_person_id_seq', 1, true);


--
-- Name: org_query_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.org_query_id_seq', 22, true);


--
-- Name: org_valid_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.org_valid_id_seq', 1, false);


--
-- Name: package_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.package_id_seq', 1, false);


--
-- Name: person_eula_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.person_eula_id_seq', 1, false);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.person_id_seq', 1, true);


--
-- Name: person_mail_org_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.person_mail_org_id_seq', 1, true);


--
-- Name: portal_eula_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.portal_eula_id_seq', 1, true);


--
-- Name: portal_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.portal_id_seq', 1, true);


--
-- Name: portal_name_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.portal_name_id_seq', 1, true);


--
-- Name: producer_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.producer_id_seq', 6, true);


--
-- Name: producer_name_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.producer_name_id_seq', 8, true);


--
-- Name: query_error_log_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.query_error_log_id_seq', 1, false);


--
-- Name: query_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.query_id_seq', 22, true);


--
-- Name: query_log_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.query_log_id_seq', 1, false);


--
-- Name: query_name_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.query_name_id_seq', 40, true);


--
-- Name: query_topic_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.query_topic_id_seq', 1, false);


--
-- Name: t3_sec_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.t3_sec_id_seq', 27, true);


--
-- Name: topic_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.topic_id_seq', 1, false);


--
-- Name: topic_name_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.topic_name_id_seq', 1, false);


--
-- Name: xforms_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.xforms_id_seq', 22, true);


--
-- Name: xroad_instance_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.xroad_instance_id_seq', 4, true);


--
-- Name: xslt_id_seq; Type: SEQUENCE SET; Schema: misp2; Owner: postgres
--

SELECT pg_catalog.setval('misp2.xslt_id_seq', 15, true);


--
-- Name: admin admin_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.admin
    ADD CONSTRAINT admin_pk PRIMARY KEY (id);


--
-- Name: group_ group_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_
    ADD CONSTRAINT group_pk PRIMARY KEY (id);


--
-- Name: org_person org_person_id_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_person
    ADD CONSTRAINT org_person_id_pk PRIMARY KEY (id);


--
-- Name: org org_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org
    ADD CONSTRAINT org_pk PRIMARY KEY (id);


--
-- Name: org_valid org_valid_id_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_valid
    ADD CONSTRAINT org_valid_id_pk PRIMARY KEY (id);


--
-- Name: person_eula person_eula_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_eula
    ADD CONSTRAINT person_eula_pk PRIMARY KEY (id);


--
-- Name: person person_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person
    ADD CONSTRAINT person_pk PRIMARY KEY (id);


--
-- Name: check_register_status pk_check_register_status; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.check_register_status
    ADD CONSTRAINT pk_check_register_status PRIMARY KEY (id);


--
-- Name: classifier pk_classifier; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.classifier
    ADD CONSTRAINT pk_classifier PRIMARY KEY (id);


--
-- Name: group_item pk_group_item; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_item
    ADD CONSTRAINT pk_group_item PRIMARY KEY (group_id, org_query_id);


--
-- Name: group_person pk_group_person; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_person
    ADD CONSTRAINT pk_group_person PRIMARY KEY (group_id, person_id, org_id);


--
-- Name: manager_candidate pk_manager_candidate; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.manager_candidate
    ADD CONSTRAINT pk_manager_candidate PRIMARY KEY (id);


--
-- Name: news pk_news; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.news
    ADD CONSTRAINT pk_news PRIMARY KEY (id);


--
-- Name: org_name pk_org_name; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_name
    ADD CONSTRAINT pk_org_name PRIMARY KEY (id);


--
-- Name: org_query pk_org_query; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_query
    ADD CONSTRAINT pk_org_query PRIMARY KEY (id);


--
-- Name: package pk_package; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.package
    ADD CONSTRAINT pk_package PRIMARY KEY (id);


--
-- Name: person_mail_org pk_person_mail_org; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_mail_org
    ADD CONSTRAINT pk_person_mail_org PRIMARY KEY (id);


--
-- Name: portal pk_portal; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal
    ADD CONSTRAINT pk_portal PRIMARY KEY (id);


--
-- Name: portal_name pk_portal_name; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal_name
    ADD CONSTRAINT pk_portal_name PRIMARY KEY (id);


--
-- Name: producer pk_producer; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.producer
    ADD CONSTRAINT pk_producer PRIMARY KEY (id);


--
-- Name: producer_name pk_producer_name; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.producer_name
    ADD CONSTRAINT pk_producer_name PRIMARY KEY (id);


--
-- Name: query pk_query; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query
    ADD CONSTRAINT pk_query PRIMARY KEY (id);


--
-- Name: query_error_log pk_query_error_log; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_error_log
    ADD CONSTRAINT pk_query_error_log PRIMARY KEY (id);


--
-- Name: query_log pk_query_log; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_log
    ADD CONSTRAINT pk_query_log PRIMARY KEY (id);


--
-- Name: query_name pk_query_name; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_name
    ADD CONSTRAINT pk_query_name PRIMARY KEY (id);


--
-- Name: query_topic pk_query_topic; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_topic
    ADD CONSTRAINT pk_query_topic PRIMARY KEY (id);


--
-- Name: topic pk_topic; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.topic
    ADD CONSTRAINT pk_topic PRIMARY KEY (id);


--
-- Name: topic_name pk_topic_name; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.topic_name
    ADD CONSTRAINT pk_topic_name PRIMARY KEY (id);


--
-- Name: xforms pk_xforms; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xforms
    ADD CONSTRAINT pk_xforms PRIMARY KEY (id);


--
-- Name: xslt pk_xslt; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xslt
    ADD CONSTRAINT pk_xslt PRIMARY KEY (id);


--
-- Name: portal_eula portal_eula_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal_eula
    ADD CONSTRAINT portal_eula_pk PRIMARY KEY (id);


--
-- Name: t3_sec t3_sec_id_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.t3_sec
    ADD CONSTRAINT t3_sec_id_pk PRIMARY KEY (id);


--
-- Name: topic uniq_topics_portal; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.topic
    ADD CONSTRAINT uniq_topics_portal UNIQUE (name, portal_id);


--
-- Name: xroad_instance xroad_instance_pk; Type: CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xroad_instance
    ADD CONSTRAINT xroad_instance_pk PRIMARY KEY (id);


--
-- Name: in_admin_login_username; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_admin_login_username ON misp2.admin USING btree (login_username);


--
-- Name: in_check_register_status; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_check_register_status ON misp2.check_register_status USING btree (query_name);


--
-- Name: in_classifier_name_idx; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_classifier_name_idx ON misp2.classifier USING btree (name, xroad_query_member_code, xroad_query_xroad_protocol_ver, xroad_query_xroad_instance, xroad_query_member_class, xroad_query_subsystem_code, xroad_query_service_code, xroad_query_service_version);


--
-- Name: in_group_item_group; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_group_item_group ON misp2.group_item USING btree (group_id);


--
-- Name: in_group_item_org_query; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_group_item_org_query ON misp2.group_item USING btree (org_query_id);


--
-- Name: in_group_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_group_org ON misp2.group_ USING btree (org_id);


--
-- Name: in_group_person_group; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_group_person_group ON misp2.group_person USING btree (group_id);


--
-- Name: in_group_person_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_group_person_org ON misp2.group_person USING btree (org_id);


--
-- Name: in_group_person_person; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_group_person_person ON misp2.group_person USING btree (person_id);


--
-- Name: in_group_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_group_portal ON misp2.group_ USING btree (portal_id);


--
-- Name: in_last_portal_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_last_portal_portal ON misp2.person USING btree (last_portal);


--
-- Name: in_manager_candidate_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_manager_candidate_org ON misp2.manager_candidate USING btree (org_id);


--
-- Name: in_manager_candidate_person; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_manager_candidate_person ON misp2.manager_candidate USING btree (manager_id);


--
-- Name: in_manager_candidate_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_manager_candidate_portal ON misp2.manager_candidate USING btree (portal_id);


--
-- Name: in_on_oid_lang; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_on_oid_lang ON misp2.org_name USING btree (org_id, lang);


--
-- Name: in_org_name; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_name ON misp2.org_name USING btree (org_id);


--
-- Name: in_org_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_org ON misp2.org USING btree (sup_org_id);


--
-- Name: in_org_person_idx; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_org_person_idx ON misp2.org_person USING btree (org_id, person_id, portal_id);


--
-- Name: in_org_person_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_person_org ON misp2.org_person USING btree (org_id);


--
-- Name: in_org_person_person; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_person_person ON misp2.org_person USING btree (person_id);


--
-- Name: in_org_person_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_person_portal ON misp2.org_person USING btree (portal_id);


--
-- Name: in_org_query_idx; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_org_query_idx ON misp2.org_query USING btree (org_id, query_id);


--
-- Name: in_org_query_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_query_org ON misp2.org_query USING btree (org_id);


--
-- Name: in_org_query_query; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_query_query ON misp2.org_query USING btree (query_id);


--
-- Name: in_org_valid; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_org_valid ON misp2.org_valid USING btree (org_id);


--
-- Name: in_org_valid_idx; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_org_valid_idx ON misp2.org_valid USING btree (org_id);


--
-- Name: in_person_cert; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_person_cert ON misp2.person USING btree (certificate);


--
-- Name: in_person_eula_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_person_eula_portal ON misp2.person_eula USING btree (portal_id);


--
-- Name: in_person_mail_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_person_mail_org ON misp2.person_mail_org USING btree (org_id, person_id);


--
-- Name: in_person_mail_org_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_person_mail_org_org ON misp2.person_mail_org USING btree (org_id);


--
-- Name: in_person_mail_org_person; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_person_mail_org_person ON misp2.person_mail_org USING btree (person_id);


--
-- Name: in_person_ssn; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_person_ssn ON misp2.person USING btree (ssn);


--
-- Name: in_pn_pid_lang; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_pn_pid_lang ON misp2.portal_name USING btree (portal_id, lang);


--
-- Name: in_portal_name_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_portal_name_portal ON misp2.portal_name USING btree (portal_id);


--
-- Name: in_portal_org; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_portal_org ON misp2.portal USING btree (org_id);


--
-- Name: in_producer_name; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_producer_name ON misp2.producer_name USING btree (producer_id);


--
-- Name: in_producer_name_pid_lang; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_producer_name_pid_lang ON misp2.producer_name USING btree (producer_id, lang);


--
-- Name: in_producer_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_producer_portal ON misp2.producer USING btree (portal_id);


--
-- Name: in_producer_portal_id_name_protocol; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_producer_portal_id_name_protocol ON misp2.producer USING btree (portal_id, short_name, xroad_instance, member_class, subsystem_code, protocol);


--
-- Name: in_q_t_query; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_q_t_query ON misp2.query_topic USING btree (query_id);


--
-- Name: in_q_t_topic; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_q_t_topic ON misp2.query_topic USING btree (topic_id);


--
-- Name: in_qn_qid_lang; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_qn_qid_lang ON misp2.query_name USING btree (query_id, lang);


--
-- Name: in_query_error_log_query_log; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_query_error_log_query_log ON misp2.query_error_log USING btree (query_log_id);


--
-- Name: in_query_log_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_query_log_portal ON misp2.query_log USING btree (portal_id);


--
-- Name: in_query_log_query_name; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_query_log_query_name ON misp2.query_log USING btree (query_name);


--
-- Name: in_query_log_query_time; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_query_log_query_time ON misp2.query_log USING btree (query_time);


--
-- Name: in_query_name_id; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_query_name_id ON misp2.query_name USING btree (query_id);


--
-- Name: in_query_package; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_query_package ON misp2.query USING btree (package_id);


--
-- Name: in_query_partial_producer_name; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_query_partial_producer_name ON misp2.query USING btree (producer_id, name) WHERE (openapi_service_code IS NULL);


--
-- Name: in_query_partial_producer_name_service_code; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_query_partial_producer_name_service_code ON misp2.query USING btree (producer_id, name, openapi_service_code) WHERE (openapi_service_code IS NOT NULL);


--
-- Name: in_query_producer; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_query_producer ON misp2.query USING btree (producer_id);


--
-- Name: in_query_topic; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_query_topic ON misp2.query_topic USING btree (query_id, topic_id);


--
-- Name: in_topic_name; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_topic_name ON misp2.topic_name USING btree (lang, topic_id);


--
-- Name: in_topic_name_topic; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_topic_name_topic ON misp2.topic_name USING btree (topic_id);


--
-- Name: in_topic_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_topic_portal ON misp2.topic USING btree (portal_id);


--
-- Name: in_uq_eula_portal_id_lang; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_uq_eula_portal_id_lang ON misp2.portal_eula USING btree (portal_id, lang);


--
-- Name: in_uq_mgr_cand; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_uq_mgr_cand ON misp2.manager_candidate USING btree (manager_id, org_id, auth_ssn, portal_id);


--
-- Name: in_uq_query_producer_id_name; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_uq_query_producer_id_name ON misp2.query USING btree (producer_id, name);


--
-- Name: in_uq_query_producer_id_name_openapi_service_code; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_uq_query_producer_id_name_openapi_service_code ON misp2.query USING btree (producer_id, name, COALESCE(openapi_service_code, ''::character varying));


--
-- Name: in_xforms_query; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_xforms_query ON misp2.xforms USING btree (query_id);


--
-- Name: in_xroad_instance_code; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_xroad_instance_code ON misp2.xroad_instance USING btree (portal_id, code);


--
-- Name: in_xroad_instance_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_xroad_instance_portal ON misp2.xroad_instance USING btree (portal_id);


--
-- Name: in_xslt_name_idx; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX in_xslt_name_idx ON misp2.xslt USING btree (portal_id, name);


--
-- Name: in_xslt_portal; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_xslt_portal ON misp2.xslt USING btree (portal_id);


--
-- Name: in_xslt_query; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE INDEX in_xslt_query ON misp2.xslt USING btree (query_id);


--
-- Name: uq_portal_short_name; Type: INDEX; Schema: misp2; Owner: postgres
--

CREATE UNIQUE INDEX uq_portal_short_name ON misp2.portal USING btree (short_name);


--
-- Name: group_item fk_group_item_group; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_item
    ADD CONSTRAINT fk_group_item_group FOREIGN KEY (group_id) REFERENCES misp2.group_(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_item fk_group_item_org_query; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_item
    ADD CONSTRAINT fk_group_item_org_query FOREIGN KEY (org_query_id) REFERENCES misp2.org_query(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_ fk_group_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_
    ADD CONSTRAINT fk_group_org FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_person fk_group_person_group; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_person
    ADD CONSTRAINT fk_group_person_group FOREIGN KEY (group_id) REFERENCES misp2.group_(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_person fk_group_person_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_person
    ADD CONSTRAINT fk_group_person_org FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_person fk_group_person_person; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_person
    ADD CONSTRAINT fk_group_person_person FOREIGN KEY (person_id) REFERENCES misp2.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_ fk_group_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.group_
    ADD CONSTRAINT fk_group_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person fk_last_portal_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person
    ADD CONSTRAINT fk_last_portal_portal FOREIGN KEY (last_portal) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: manager_candidate fk_manager_candidate_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.manager_candidate
    ADD CONSTRAINT fk_manager_candidate_org FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: manager_candidate fk_manager_candidate_person; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.manager_candidate
    ADD CONSTRAINT fk_manager_candidate_person FOREIGN KEY (manager_id) REFERENCES misp2.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: manager_candidate fk_manager_candidate_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.manager_candidate
    ADD CONSTRAINT fk_manager_candidate_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org_name fk_org_name; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_name
    ADD CONSTRAINT fk_org_name FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org fk_org_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org
    ADD CONSTRAINT fk_org_org FOREIGN KEY (sup_org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org_person fk_org_person_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_person
    ADD CONSTRAINT fk_org_person_org FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org_person fk_org_person_person; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_person
    ADD CONSTRAINT fk_org_person_person FOREIGN KEY (person_id) REFERENCES misp2.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org_person fk_org_person_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_person
    ADD CONSTRAINT fk_org_person_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org_query fk_org_query_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_query
    ADD CONSTRAINT fk_org_query_org FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org_query fk_org_query_query; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_query
    ADD CONSTRAINT fk_org_query_query FOREIGN KEY (query_id) REFERENCES misp2.query(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: org_valid fk_org_valid; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.org_valid
    ADD CONSTRAINT fk_org_valid FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_eula fk_person_eula_person; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_eula
    ADD CONSTRAINT fk_person_eula_person FOREIGN KEY (person_id) REFERENCES misp2.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_eula fk_person_eula_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_eula
    ADD CONSTRAINT fk_person_eula_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_mail_org fk_person_mail_org_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_mail_org
    ADD CONSTRAINT fk_person_mail_org_org FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_mail_org fk_person_mail_org_person; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.person_mail_org
    ADD CONSTRAINT fk_person_mail_org_person FOREIGN KEY (person_id) REFERENCES misp2.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: portal_eula fk_portal_eula_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal_eula
    ADD CONSTRAINT fk_portal_eula_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: portal_name fk_portal_name_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal_name
    ADD CONSTRAINT fk_portal_name_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: portal fk_portal_org; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.portal
    ADD CONSTRAINT fk_portal_org FOREIGN KEY (org_id) REFERENCES misp2.org(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: producer_name fk_producer_name; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.producer_name
    ADD CONSTRAINT fk_producer_name FOREIGN KEY (producer_id) REFERENCES misp2.producer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: producer fk_producer_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.producer
    ADD CONSTRAINT fk_producer_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: query_topic fk_q_t_query; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_topic
    ADD CONSTRAINT fk_q_t_query FOREIGN KEY (query_id) REFERENCES misp2.query(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: query_topic fk_q_t_topic; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_topic
    ADD CONSTRAINT fk_q_t_topic FOREIGN KEY (topic_id) REFERENCES misp2.topic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: query_error_log fk_query_error_log_query_log; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_error_log
    ADD CONSTRAINT fk_query_error_log_query_log FOREIGN KEY (query_log_id) REFERENCES misp2.query_log(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: query_log fk_query_log_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_log
    ADD CONSTRAINT fk_query_log_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: query_name fk_query_name_id; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query_name
    ADD CONSTRAINT fk_query_name_id FOREIGN KEY (query_id) REFERENCES misp2.query(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: query fk_query_package; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query
    ADD CONSTRAINT fk_query_package FOREIGN KEY (package_id) REFERENCES misp2.package(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: query fk_query_producer; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.query
    ADD CONSTRAINT fk_query_producer FOREIGN KEY (producer_id) REFERENCES misp2.producer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topic_name fk_topic_name_topic; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.topic_name
    ADD CONSTRAINT fk_topic_name_topic FOREIGN KEY (topic_id) REFERENCES misp2.topic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topic fk_topic_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.topic
    ADD CONSTRAINT fk_topic_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: xforms fk_xforms_query; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xforms
    ADD CONSTRAINT fk_xforms_query FOREIGN KEY (query_id) REFERENCES misp2.query(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: xroad_instance fk_xroad_instance_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xroad_instance
    ADD CONSTRAINT fk_xroad_instance_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: xslt fk_xslt_portal; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xslt
    ADD CONSTRAINT fk_xslt_portal FOREIGN KEY (portal_id) REFERENCES misp2.portal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: xslt fk_xslt_query; Type: FK CONSTRAINT; Schema: misp2; Owner: postgres
--

ALTER TABLE ONLY misp2.xslt
    ADD CONSTRAINT fk_xslt_query FOREIGN KEY (query_id) REFERENCES misp2.query(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA misp2; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA misp2 TO misp2;


--
-- Name: TABLE admin; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.admin TO misp2;


--
-- Name: SEQUENCE admin_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.admin_id_seq TO misp2;


--
-- Name: TABLE check_register_status; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.check_register_status TO misp2;


--
-- Name: SEQUENCE check_register_status_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.check_register_status_id_seq TO misp2;


--
-- Name: TABLE classifier; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.classifier TO misp2;


--
-- Name: SEQUENCE classifier_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.classifier_id_seq TO misp2;


--
-- Name: TABLE group_; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.group_ TO misp2;


--
-- Name: SEQUENCE group__id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.group__id_seq TO misp2;


--
-- Name: TABLE group_item; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.group_item TO misp2;


--
-- Name: SEQUENCE group_item_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.group_item_id_seq TO misp2;


--
-- Name: TABLE group_person; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.group_person TO misp2;


--
-- Name: SEQUENCE group_person_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.group_person_id_seq TO misp2;


--
-- Name: TABLE manager_candidate; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.manager_candidate TO misp2;


--
-- Name: SEQUENCE manager_candidate_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.manager_candidate_id_seq TO misp2;


--
-- Name: TABLE news; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.news TO misp2;


--
-- Name: SEQUENCE news_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.news_id_seq TO misp2;


--
-- Name: TABLE org; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.org TO misp2;


--
-- Name: SEQUENCE org_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.org_id_seq TO misp2;


--
-- Name: TABLE org_name; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.org_name TO misp2;


--
-- Name: SEQUENCE org_name_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.org_name_id_seq TO misp2;


--
-- Name: TABLE org_person; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.org_person TO misp2;


--
-- Name: SEQUENCE org_person_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.org_person_id_seq TO misp2;


--
-- Name: TABLE org_query; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.org_query TO misp2;


--
-- Name: SEQUENCE org_query_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.org_query_id_seq TO misp2;


--
-- Name: TABLE org_valid; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.org_valid TO misp2;


--
-- Name: SEQUENCE org_valid_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.org_valid_id_seq TO misp2;


--
-- Name: TABLE package; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.package TO misp2;


--
-- Name: SEQUENCE package_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.package_id_seq TO misp2;


--
-- Name: TABLE person; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.person TO misp2;


--
-- Name: TABLE person_eula; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.person_eula TO misp2;


--
-- Name: SEQUENCE person_eula_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.person_eula_id_seq TO misp2;


--
-- Name: SEQUENCE person_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.person_id_seq TO misp2;


--
-- Name: TABLE person_mail_org; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.person_mail_org TO misp2;


--
-- Name: SEQUENCE person_mail_org_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.person_mail_org_id_seq TO misp2;


--
-- Name: TABLE portal; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.portal TO misp2;


--
-- Name: TABLE portal_eula; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.portal_eula TO misp2;


--
-- Name: SEQUENCE portal_eula_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.portal_eula_id_seq TO misp2;


--
-- Name: SEQUENCE portal_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.portal_id_seq TO misp2;


--
-- Name: TABLE portal_name; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.portal_name TO misp2;


--
-- Name: SEQUENCE portal_name_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.portal_name_id_seq TO misp2;


--
-- Name: TABLE producer; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.producer TO misp2;


--
-- Name: SEQUENCE producer_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.producer_id_seq TO misp2;


--
-- Name: TABLE producer_name; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.producer_name TO misp2;


--
-- Name: SEQUENCE producer_name_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.producer_name_id_seq TO misp2;


--
-- Name: TABLE query; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.query TO misp2;


--
-- Name: TABLE query_error_log; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.query_error_log TO misp2;


--
-- Name: SEQUENCE query_error_log_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.query_error_log_id_seq TO misp2;


--
-- Name: SEQUENCE query_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.query_id_seq TO misp2;


--
-- Name: TABLE query_log; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.query_log TO misp2;


--
-- Name: SEQUENCE query_log_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.query_log_id_seq TO misp2;


--
-- Name: TABLE query_name; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.query_name TO misp2;


--
-- Name: SEQUENCE query_name_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.query_name_id_seq TO misp2;


--
-- Name: TABLE query_topic; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.query_topic TO misp2;


--
-- Name: SEQUENCE query_topic_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.query_topic_id_seq TO misp2;


--
-- Name: TABLE t3_sec; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.t3_sec TO misp2;


--
-- Name: SEQUENCE t3_sec_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.t3_sec_id_seq TO misp2;


--
-- Name: TABLE topic; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.topic TO misp2;


--
-- Name: SEQUENCE topic_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.topic_id_seq TO misp2;


--
-- Name: TABLE topic_name; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.topic_name TO misp2;


--
-- Name: SEQUENCE topic_name_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.topic_name_id_seq TO misp2;


--
-- Name: TABLE xforms; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.xforms TO misp2;


--
-- Name: SEQUENCE xforms_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.xforms_id_seq TO misp2;


--
-- Name: TABLE xroad_instance; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.xroad_instance TO misp2;


--
-- Name: SEQUENCE xroad_instance_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.xroad_instance_id_seq TO misp2;


--
-- Name: TABLE xslt; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON TABLE misp2.xslt TO misp2;


--
-- Name: SEQUENCE xslt_id_seq; Type: ACL; Schema: misp2; Owner: postgres
--

GRANT ALL ON SEQUENCE misp2.xslt_id_seq TO misp2;


--
-- PostgreSQL database dump complete
--

