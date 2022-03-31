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

COMMENT ON TABLE misp2.check_register_status IS 'kehtivuse kontrollpäringu  registri olek';


--
-- Name: COLUMN check_register_status.query_name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.check_register_status.query_name IS 'kehtivuse kontrollpäringu  nimi';


--
-- Name: COLUMN check_register_status.query_time; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.check_register_status.query_time IS 'kehtivuse kontrollpäringu  viimase sooritamise aeg';


--
-- Name: COLUMN check_register_status.is_ok; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.check_register_status.is_ok IS 'kehtivuse kontrollpäringu  registri staatus: 1 - ok, 0 - vigane (annab veaga vastust)';


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

COMMENT ON TABLE misp2.classifier IS 'andmekogu klassifikaatorid, mis laetakse andmekogust MISPi baasi loadclassifier päringuga, kasutatakse XML - formaadis klassifikatoreid';


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

COMMENT ON TABLE misp2.group_item IS 'grupi päringuõigused';


--
-- Name: COLUMN group_item.group_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_item.group_id IS 'viide grupile';


--
-- Name: COLUMN group_item.invisible; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_item.invisible IS 'varjatud teenuste menüüs';


--
-- Name: COLUMN group_item.org_query_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_item.org_query_id IS 'viide lubatud päringule ';


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

COMMENT ON COLUMN misp2.group_person.org_id IS 'asutus, mille all kehtib see kirje (millise asutuse esindajana võib antud päringut sooritada) see võib olla sama asutus, mis group.org_id või ka viimase allasutus';


--
-- Name: COLUMN group_person.validuntil; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.group_person.validuntil IS 'aegumiskuupäev, mis ajani gruppikuuluvus kehtib';


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

COMMENT ON TABLE misp2.manager_candidate IS 'asutuse pääsuõiguste halduri kandidaadid, kelle puhul on vajalik mitme esindusõigusliku isiku poolt kinnitamine halduriks';


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

COMMENT ON COLUMN misp2.org.sup_org_id IS 'viide ülemasutusele';


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

COMMENT ON TABLE misp2.org_person IS 'asutuse ja isiku seos, mis näitab, et isikul on õigus seda asutust esindada, teha päringuid selle asutuse nime all';


--
-- Name: COLUMN org_person.role; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.org_person.role IS 'kasutajaroll: 0 - asutuse tavakasutaja 1 - asutuse pääsuõiguste haldur 2 - portaali haldur';


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

COMMENT ON TABLE misp2.org_query IS 'asutusele turvaserveris avatud päringud';


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

COMMENT ON TABLE misp2.org_valid IS 'Asutuste kehtivuspäringu sooritamiste ajad';


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

COMMENT ON COLUMN misp2.person.password IS 'ülevõtmiskood';


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

COMMENT ON TABLE misp2.person_eula IS 'Tabel sisaldab kasutajate portaali kasutajalitsensi tingimustega nõustumise tulemusi.
		Kui portaali sisseloginud kasutaja on litsensi tingimustega nõustunud, tehakse käesolevasse
		tabelisse kirje ja järgmisel sisselogimisel litsensiga nõustumise ekraani enam ei näidata.
		
		Tabeli kirje määrab ennekõike seose kasutajate tabeli ''person'' ja portaali tabeli ''portal''
		vahel koos nõustumise olekuga tõeväärtuse tüüpi veerus ''accepted''. Lisaks sellele salvestatakse
		nõustumise juurde metaandmed nagu nõustumise aeg ja autentimismeetod.
	   ';


--
-- Name: COLUMN person_eula.id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.id IS 'tabeli primaarvõti';


--
-- Name: COLUMN person_eula.person_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.person_id IS 'viide isikule, kes portaali EULA-ga on nõustunud (või nõustumise tagasi lükanud)';


--
-- Name: COLUMN person_eula.portal_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.portal_id IS 'viide portaalile ''portal'' tabelis, millega EULA seotud on';


--
-- Name: COLUMN person_eula.accepted; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.person_eula.accepted IS 'tõeväärtus, mis näitab nõustumise olekut. Välja väärtus on
		 - tõene, kui kasutaja on EULA-ga nõustunud;
		 - väär, kui kasutaja on nõustumise tagasi lükanud;';


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

COMMENT ON COLUMN misp2.portal.short_name IS 'lühinimi, mida kasutatakse antud portaali poole pöördumisel URLis parameetrina (vanas MISPis portaali kataloogi nimi)';


--
-- Name: COLUMN portal.org_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.org_id IS 'portaali (pea)asutus';


--
-- Name: COLUMN portal.misp_type; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.misp_type IS 'portaali tüüp, vanas MISPis konfiparemeeter "misp"';


--
-- Name: COLUMN portal.security_host; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.security_host IS 'turvaserveri aadress, vanas MISPis konfiparemeeter "security_host"';


--
-- Name: COLUMN portal.message_mediator; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.message_mediator IS 'päringute saatmise aadress (turvaserver või sõnumimootor)';


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

COMMENT ON COLUMN misp2.portal.univ_auth_query IS 'universaalse portaalitüübi korral: üksuse esindusõiguse kontrollpäringu nimi';


--
-- Name: COLUMN portal.univ_check_query; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.univ_check_query IS 'universaalse portaalitüübi korral üksuse kehtivuse kontrollpäringu nimi';


--
-- Name: COLUMN portal.univ_check_valid_time; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.univ_check_valid_time IS 'universaalse portaalitüübi korral: üksuse kehtivuse kontrollpäringu tulemuse kehtivusaeg tundides';


--
-- Name: COLUMN portal.univ_use_manager; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.univ_use_manager IS 'universaalse portaalitüübi korral: näitab, kas antud portaali puhul kasutada üksuse halduri rolli, või selle asemel nn lihtsustatud õiguste andmist ilma üksuse halduri määramiseta; vanas MISPis konfiparameeter  ''lihtsustatud_oigused''';


--
-- Name: COLUMN portal.log_query; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.log_query IS 'logimispäringu nimi';


--
-- Name: COLUMN portal.client_xroad_instance; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.client_xroad_instance IS 'X-Tee v6 kliendi instants';


--
-- Name: COLUMN portal.eula_in_use; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal.eula_in_use IS 'tõene, kui portaalis on EULA kasutusel ja kasutajatelt küsitakse sellega nõustumist';


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
        Ühel portaalil saab olla mitu kasutajalitsensi teksti,
        sellisel juhul iga kanne sisaldab sama litsensi teksti erinevas keeles.
        Tabelisse tehakse kirjeid rakenduse administraatori rollis
        portaali loomise/muutmise vormilt administreerimisliideses.
        Tabeli kirjeid loetakse kasutaja esmasel sisenemisel portaali, et
        kasutajale litsensi sisu nõustumiseks kuvada.';


--
-- Name: COLUMN portal_eula.id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.id IS 'tabeli primaarvõti';


--
-- Name: COLUMN portal_eula.portal_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.portal_id IS 'viide portaalile ''portal'' tabelis, millega käesolev EULA sisu seotud on';


--
-- Name: COLUMN portal_eula.lang; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.portal_eula.lang IS 'EULA sisu kahetäheline keelekood';


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

COMMENT ON COLUMN misp2.producer.protocol IS 'Protokolli, mida produceri querid kasutavad sõnumivahetuses.';


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

COMMENT ON COLUMN misp2.query.type IS 'teenuse tüüp 0 - X-tee teenus  1-  WS-BPEL teenus  (2- portaali päringuõiguste andmekogu teenus)';


--
-- Name: COLUMN query.name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.name IS 'Teenuse lühinimi, X-tee v6 korral serviceCode ja serviceVersion punktiga eraldatuna. REST teenuste puhul operationId.';


--
-- Name: COLUMN query.xroad_request_namespace; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.xroad_request_namespace IS 'kasutatakse x-tee v6 klassifikaatorite päringul';


--
-- Name: COLUMN query.sub_query_names; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query.sub_query_names IS 'Kasutatakse kompleksteenuse puhul alampäringute nimistu hoidmiseks.';


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

COMMENT ON TABLE misp2.query_log IS 'sooritatud päringute metainfo logi';


--
-- Name: COLUMN query_log.query_name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query_log.query_name IS 'andmekogu.päring.versioon';


--
-- Name: COLUMN query_log.query_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query_log.query_id IS 'päringu ID';


--
-- Name: COLUMN query_log.person_ssn; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.query_log.person_ssn IS 'päringu sooritaja isikukood';


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

COMMENT ON TABLE misp2.t3_sec IS 'õiguste haldamisega seotud tegevuste logitabel, need tegevused salvestatakse ka X-tee logipäringuga';


--
-- Name: COLUMN t3_sec.user_from; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.user_from IS 'isikukood, kes andis õigusi';


--
-- Name: COLUMN t3_sec.user_to; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.user_to IS 'isikukood, kellele anti päringuõigused';


--
-- Name: COLUMN t3_sec.action_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.t3_sec.action_id IS 'tegevuse tyyp: 0 - halduri määramine, 1 - haldiri kustutamine, 2 - isiku kasutajagruppi lisamine, 3 - isiku kasutajagrupist eemaldamine,  4 - päringuõiguste lisamine,  5 - päringuõiguste eemaldamine, 6 - kasutajagruppide lisamine,  7 - kasutajagruppide eemaldamine, 8 - esindusõiguse kontroll, 9 - isiku lisamine, 10 - isiku kustutamine, 11 - asutuse lisamine, 12 - asutuse kustutamine, 14 - portaali kustutamine, 15 - grupi parameetrite muutmine';


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

COMMENT ON COLUMN misp2.t3_sec.query_id IS 'päringu id';


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

COMMENT ON COLUMN misp2.xforms.query_id IS 'viide päringule';


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
	Veerg ''in_use'' määrab, millised instantsid on portaalis parasjagu kasutusel.
	Kasutusel olevatest instantside jaoks on teenuste halduril võimalik värskendada
	teenuste nimekirja ja hallata vastavate andmekogude teenuseid.';


--
-- Name: COLUMN xroad_instance.id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.id IS 'tabeli primaarvõti';


--
-- Name: COLUMN xroad_instance.portal_id; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.portal_id IS 'viide portaalile ''portal'' tabelis, millega käesolev X-Tee instants seotud on';


--
-- Name: COLUMN xroad_instance.code; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.code IS 'X-Tee instantsi väärtus, mis X-Tee sõnumite päiseväljadele kirjutatakse';


--
-- Name: COLUMN xroad_instance.in_use; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.in_use IS 'tõene, kui käesolev X-Tee instants on portaalis aktiivne, st selle teenuseid saab laadida;
	väär, kui käesolev X-Tee instants ei ole portaalis kasutusel';


--
-- Name: COLUMN xroad_instance.selected; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xroad_instance.selected IS 'tõene, kui käesolev X-Tee instants on portaalis andmekogude päringul vaikimisi valitud;
    väär, kui käesolev X-Tee instants ei ole vaikimisi valitud';


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

COMMENT ON COLUMN misp2.xslt.query_id IS 'viide päringule, kui null, siis rakendatakse kõigile';


--
-- Name: COLUMN xslt.xsl; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.xsl IS 'XSL stiililileht';


--
-- Name: COLUMN xslt.priority; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.priority IS 'XSL rakendamise järjekorranumber 0-esimene';


--
-- Name: COLUMN xslt.name; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.name IS 'XSL stiililehe nimetus ';


--
-- Name: COLUMN xslt.form_type; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.form_type IS 'mis tüüpi vormile rakendatakse 0-HTML 1-PDF';


--
-- Name: COLUMN xslt.in_use; Type: COMMENT; Schema: misp2; Owner: postgres
--

COMMENT ON COLUMN misp2.xslt.in_use IS 'näitab, kas XSL on kasutusel või mitte';


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
13	<xtee.riigid><item><name>Afganistan</name><code>AF</code></item><item><name>Ahvenamaa</name><code>AX</code></item><item><name>Albaania</name><code>AL</code></item><item><name>Alžeeria</name><code>DZ</code></item><item><name>Ameerika Samoa</name><code>AS</code></item><item><name>Ameerika Ühendriigid</name><code>US</code></item><item><name>Andorra</name><code>AD</code></item><item><name>Angola</name><code>AO</code></item><item><name>Anguilla</name><code>AI</code></item><item><name>Antarktis</name><code>AQ</code></item><item><name>Antigua ja Barbuda</name><code>AG</code></item><item><name>Araabia Ühendemiraadid</name><code>AE</code></item><item><name>Argentina</name><code>AR</code></item><item><name>Armeenia</name><code>AM</code></item><item><name>Aruba</name><code>AW</code></item><item><name>Aserbaidžaan</name><code>AZ</code></item><item><name>Austraalia</name><code>AU</code></item><item><name>Austria</name><code>AT</code></item><item><name>Bahama</name><code>BS</code></item><item><name>Bahrein</name><code>BH</code></item><item><name>Bangladesh</name><code>BD</code></item><item><name>Barbados</name><code>BB</code></item><item><name>Belau</name><code>PW</code></item><item><name>Belgia</name><code>BE</code></item><item><name>Belize</name><code>BZ</code></item><item><name>Benin</name><code>BJ</code></item><item><name>Bermuda</name><code>BM</code></item><item><name>Bhutan</name><code>BT</code></item><item><name>Boliivia</name><code>BO</code></item><item><name>Bosnia- ja Hertsegoviina</name><code>BA</code></item><item><name>Botswana</name><code>BW</code></item><item><name>Bouvet saar</name><code>BV</code></item><item><name>Brasiilia</name><code>BR</code></item><item><name>Briti India ookeani ala</name><code>IO</code></item><item><name>Briti Neitsisaared</name><code>VG</code></item><item><name>Brunei Darussalam</name><code>BN</code></item><item><name>Bulgaaria</name><code>BG</code></item><item><name>Burkina Faso</name><code>BF</code></item><item><name>Burundi</name><code>BI</code></item><item><name>Cabo Verde</name><code>CV</code></item><item><name>Colombia</name><code>CO</code></item><item><name>Cooki saared</name><code>CK</code></item><item><name>Costa Rica</name><code>CR</code></item><item><name>Cote dIvoire</name><code>CI</code></item><item><name>Djibouti</name><code>DJ</code></item><item><name>Dominica</name><code>DM</code></item><item><name>Dominikaani Vabariik</name><code>DO</code></item><item><name>Ecuador</name><code>EC</code></item><item><name>Eesti</name><code>EE</code></item><item><name>Egiptus</name><code>EG</code></item><item><name>Ekvatoriaal-Guinea</name><code>GQ</code></item><item><name>El Salvador</name><code>SV</code></item><item><name>Eritrea</name><code>ER</code></item><item><name>Etioopia</name><code>ET</code></item><item><name>Falklandi (Malviini) saared</name><code>FK</code></item><item><name>Fidži</name><code>FJ</code></item><item><name>Filipiinid</name><code>PH</code></item><item><name>Fääri saared</name><code>FO</code></item><item><name>Gabon</name><code>GA</code></item><item><name>Gambia</name><code>GM</code></item><item><name>Ghana</name><code>GH</code></item><item><name>Gibraltar</name><code>GI</code></item><item><name>Grenada</name><code>GD</code></item><item><name>Gruusia</name><code>GE</code></item><item><name>Gröönimaa</name><code>GL</code></item><item><name>Guadeloupe</name><code>GP</code></item><item><name>Prantsuse Guajaana</name><code>GF</code></item><item><name>Guam</name><code>GU</code></item><item><name>Guatemala</name><code>GT</code></item><item><name>Guernsey</name><code>GG</code></item><item><name>Guinea</name><code>GN</code></item><item><name>Guinea-Bissau</name><code>GW</code></item><item><name>Guyana</name><code>GY</code></item><item><name>Haiti</name><code>HT</code></item><item><name>Heard ja McDonald</name><code>HM</code></item><item><name>Aomen</name><code>MO</code></item><item><name>Hongkong</name><code>HK</code></item><item><name>Hiina</name><code>CN</code></item><item><name>Hispaania</name><code>ES</code></item><item><name>Hollandi Antillid</name><code>AN</code></item><item><name>Honduras</name><code>HN</code></item><item><name>Horvaatia</name><code>HR</code></item><item><name>Iirimaa</name><code>IE</code></item><item><name>Iisrael</name><code>IL</code></item><item><name>India</name><code>IN</code></item><item><name>Indoneesia</name><code>ID</code></item><item><name>Iraak</name><code>IQ</code></item><item><name>Iraan</name><code>IR</code></item><item><name>Island</name><code>IS</code></item><item><name>Itaalia</name><code>IT</code></item><item><name>Jaapan</name><code>JP</code></item><item><name>Jamaica</name><code>JM</code></item><item><name>Jeemen</name><code>YE</code></item><item><name>Jersey</name><code>JE</code></item><item><name>Jordaania</name><code>JO</code></item><item><name>Jõulusaar</name><code>CX</code></item><item><name>Kaimanisaared</name><code>KY</code></item><item><name>Kambodža</name><code>KH</code></item><item><name>Kamerun</name><code>CM</code></item><item><name>Kanada</name><code>CA</code></item><item><name>Kasahstan</name><code>KZ</code></item><item><name>Katar</name><code>QA</code></item><item><name>Kenya</name><code>KE</code></item><item><name>Kesk-Aafrika Vabariik</name><code>CF</code></item><item><name>Kõrgõzstan</name><code>KG</code></item><item><name>Kiribati</name><code>KI</code></item><item><name>Komoorid</name><code>KM</code></item><item><name>Kongo DV</name><code>CD</code></item><item><name>Kongo</name><code>CG</code></item><item><name>Kookossaared (Keelingi saared)</name><code>CC</code></item><item><name>Korea RDV</name><code>KP</code></item><item><name>Korea Vabariik</name><code>KR</code></item><item><name>Kreeka</name><code>GR</code></item><item><name>Kuuba</name><code>CU</code></item><item><name>Kuveit</name><code>KW</code></item><item><name>Küpros</name><code>CY</code></item><item><name>Laos</name><code>LA</code></item><item><name>Leedu</name><code>LT</code></item><item><name>Lesotho</name><code>LS</code></item><item><name>Libeeria</name><code>LR</code></item><item><name>Liechtenstein</name><code>LI</code></item><item><name>Liibanon</name><code>LB</code></item><item><name>Luksemburg</name><code>LU</code></item><item><name>Lõuna-Aafrika Vabariik</name><code>ZA</code></item><item><name>Lõuna-Georgia ja Lõuna-Sandwich</name><code>GS</code></item><item><name>Läti</name><code>LV</code></item><item><name>Lääne-Sahara</name><code>EH</code></item><item><name>Madagaskar</name><code>MG</code></item><item><name>Holland</name><code>NL</code></item><item><name>Makedoonia</name><code>MK</code></item><item><name>Malaisia</name><code>MY</code></item><item><name>Malawi</name><code>MW</code></item><item><name>Maldiivid</name><code>MV</code></item><item><name>Mali</name><code>ML</code></item><item><name>Malta</name><code>MT</code></item><item><name>Mani saar</name><code>IM</code></item><item><name>Maroko</name><code>MA</code></item><item><name>Marshalli Saared</name><code>MH</code></item><item><name>Martinique</name><code>MQ</code></item><item><name>Mauritaania</name><code>MR</code></item><item><name>Mauritius</name><code>MU</code></item><item><name>Mayotte</name><code>YT</code></item><item><name>Mehhiko</name><code>MX</code></item><item><name>Mikroneesia</name><code>FM</code></item><item><name>Moldova</name><code>MD</code></item><item><name>Monaco</name><code>MC</code></item><item><name>Mongoolia</name><code>MN</code></item><item><name>Montenegro</name><code>ME</code></item><item><name>Montserrat</name><code>MS</code></item><item><name>Mosambiik</name><code>MZ</code></item><item><name>Mujal nimetamata territooriumid</name><code>XY</code></item><item><name>Määramata</name><code>XX</code></item><item><name>Myanmar (Birma)</name><code>MM</code></item><item><name>Namiibia</name><code>NA</code></item><item><name>Nauru</name><code>NR</code></item><item><name>Nepal</name><code>NP</code></item><item><name>Nicaragua</name><code>NI</code></item><item><name>Nigeeria</name><code>NG</code></item><item><name>Niger</name><code>NE</code></item><item><name>Niue</name><code>NU</code></item><item><name>Norfolk</name><code>NF</code></item><item><name>Norra</name><code>NO</code></item><item><name>Omaan</name><code>OM</code></item><item><name>Paapua Uus-Guinea</name><code>PG</code></item><item><name>Pakistan</name><code>PK</code></item><item><name>Palestiina okupeeritud alad</name><code>PS</code></item><item><name>Panama</name><code>PA</code></item><item><name>Paraguay</name><code>PY</code></item><item><name>Peruu</name><code>PE</code></item><item><name>Pitcairn</name><code>PN</code></item><item><name>Poola</name><code>PL</code></item><item><name>Portugal</name><code>PT</code></item><item><name>Prantsuse Lõunaalad</name><code>TF</code></item><item><name>Prantsuse Polüneesia</name><code>PF</code></item><item><name>Prantsusmaa</name><code>FR</code></item><item><name>Puerto Rico</name><code>PR</code></item><item><name>Põhja-Mariaanid</name><code>MP</code></item><item><name>Püha Tool (Vatikan)</name><code>VA</code></item><item><name>Réunion</name><code>RE</code></item><item><name>Rootsi</name><code>SE</code></item><item><name>Rumeenia</name><code>RO</code></item><item><name>Rwanda</name><code>RW</code></item><item><name>Saalomoni Saared</name><code>SB</code></item><item><name>Saint Kitts ja Nevis</name><code>KN</code></item><item><name>Saint Helena</name><code>SH</code></item><item><name>Saint Lucia</name><code>LC</code></item><item><name>Saint Pierre ja Miquelon</name><code>PM</code></item><item><name>Saint Vincent ja Grenadiinid</name><code>VC</code></item><item><name>Saksamaa</name><code>DE</code></item><item><name>Sambia</name><code>ZM</code></item><item><name>Samoa</name><code>WS</code></item><item><name>San Marino</name><code>SM</code></item><item><name>Sao Tomé ja Principe</name><code>ST</code></item><item><name>Saudi Araabia</name><code>SA</code></item><item><name>Seišellid</name><code>SC</code></item><item><name>Senegal</name><code>SN</code></item><item><name>Serbia</name><code>RS</code></item><item><name>Sierra Leone</name><code>SL</code></item><item><name>Singapur</name><code>SG</code></item><item><name>Slovakkia</name><code>SK</code></item><item><name>Sloveenia</name><code>SI</code></item><item><name>Somaalia</name><code>SO</code></item><item><name>Soome</name><code>FI</code></item><item><name>Sri Lanka</name><code>LK</code></item><item><name>Sudaan</name><code>SD</code></item><item><name>Suriname</name><code>SR</code></item><item><name>Liibüa</name><code>LY</code></item><item><name>Suurbritannia</name><code>GB</code></item><item><name>Svaasimaa</name><code>SZ</code></item><item><name>Svalbard ja Jan Mayen</name><code>SJ</code></item><item><name>Süüria</name><code>SY</code></item><item><name>veits</name><code>CH</code></item><item><name>Zimbabwe</name><code>ZW</code></item><item><name>Taani</name><code>DK</code></item><item><name>Tadžikistan</name><code>TJ</code></item><item><name>Tai</name><code>TH</code></item><item><name>Taiwan</name><code>TW</code></item><item><name>Tansaania</name><code>TZ</code></item><item><name>Timor-Leste</name><code>TL</code></item><item><name>Togo</name><code>TG</code></item><item><name>Tokelau</name><code>TK</code></item><item><name>Tonga</name><code>TO</code></item><item><name>Trinidad ja Tobago</name><code>TT</code></item><item><name>Tšaad</name><code>TD</code></item><item><name>Tšehhi</name><code>CZ</code></item><item><name>Tšiili</name><code>CL</code></item><item><name>Tuneesia</name><code>TN</code></item><item><name>Turks ja Caicos</name><code>TC</code></item><item><name>Tuvalu</name><code>TV</code></item><item><name>Türgi</name><code>TR</code></item><item><name>Türkmenistan</name><code>TM</code></item><item><name>Uganda</name><code>UG</code></item><item><name>Ukraina</name><code>UA</code></item><item><name>Ungari</name><code>HU</code></item><item><name>Uruguay</name><code>UY</code></item><item><name>Usbekistan</name><code>UZ</code></item><item><name>Uus-Kaledoonia</name><code>NC</code></item><item><name>Uus-Meremaa</name><code>NZ</code></item><item><name>Valgevene</name><code>BY</code></item><item><name>Wallis ja Futuna</name><code>WF</code></item><item><name>Vanuatu</name><code>VU</code></item><item><name>Venemaa</name><code>RU</code></item><item><name>Venezuela</name><code>VE</code></item><item><name>Vietnam</name><code>VN</code></item><item><name>USA Neitsisaared</name><code>VI</code></item><item><name>Ühendriikide hajasaared</name><code>UM</code></item></xtee.riigid>	xtee.riigid	2021-01-27 10:25:45.76905	2021-01-27 10:25:45.76905	admin	\N	\N	\N	\N	\N	\N	\N	\N
14	<xroad.countries><item><name>Afghanistan</name><code>AF</code></item><item><name>Åland Islands</name><code>AX</code></item><item><name>Albania</name><code>AL</code></item><item><name>Algeria</name><code>DZ</code></item><item><name>American Samoa</name><code>AS</code></item><item><name>United States of America</name><code>US</code></item><item><name>Andorra</name><code>AD</code></item><item><name>Angola</name><code>AO</code></item><item><name>Anguilla</name><code>AI</code></item><item><name>Antarctica</name><code>AQ</code></item><item><name>Antigua and Barbuda</name><code>AG</code></item><item><name>United Arab Emirates</name><code>AE</code></item><item><name>Argentina</name><code>AR</code></item><item><name>Armenia</name><code>AM</code></item><item><name>Aruba</name><code>AW</code></item><item><name>Azerbaijan</name><code>AZ</code></item><item><name>Australia</name><code>AU</code></item><item><name>Austria</name><code>AT</code></item><item><name>Bahamas</name><code>BS</code></item><item><name>Bahrain</name><code>BH</code></item><item><name>Bangladesh</name><code>BD</code></item><item><name>Barbados</name><code>BB</code></item><item><name>Palau</name><code>PW</code></item><item><name>Belgium</name><code>BE</code></item><item><name>Belize</name><code>BZ</code></item><item><name>Benin</name><code>BJ</code></item><item><name>Bermuda</name><code>BM</code></item><item><name>Bhutan</name><code>BT</code></item><item><name>Bolivia</name><code>BO</code></item><item><name>Bosnia and Hertzegovina</name><code>BA</code></item><item><name>Botswana</name><code>BW</code></item><item><name>Bouvet Island</name><code>BV</code></item><item><name>Brazil</name><code>BR</code></item><item><name>British Indian Ocean Territory</name><code>IO</code></item><item><name>Virgin Islands (British)</name><code>VG</code></item><item><name>Brunei Darussalam</name><code>BN</code></item><item><name>Bulgaria</name><code>BG</code></item><item><name>Burkina Faso</name><code>BF</code></item><item><name>Burundi</name><code>BI</code></item><item><name>Cape Verde</name><code>CV</code></item><item><name>Colombia</name><code>CO</code></item><item><name>Cook Islands</name><code>CK</code></item><item><name>Costa Rica</name><code>CR</code></item><item><name>Cote dIvoire</name><code>CI</code></item><item><name>Djibouti</name><code>DJ</code></item><item><name>Dominica</name><code>DM</code></item><item><name>Dominican Republic</name><code>DO</code></item><item><name>Ecuador</name><code>EC</code></item><item><name>Estonia</name><code>EE</code></item><item><name>Egypt</name><code>EG</code></item><item><name>Equatorial Guinea</name><code>GQ</code></item><item><name>El Salvador</name><code>SV</code></item><item><name>Eritrea</name><code>ER</code></item><item><name>Ethiopia</name><code>ET</code></item><item><name>Falkland Islands (Malvinas)</name><code>FK</code></item><item><name>Fiji</name><code>FJ</code></item><item><name>Philippines</name><code>PH</code></item><item><name>Faroe Islands</name><code>FO</code></item><item><name>Gabon</name><code>GA</code></item><item><name>Gambia</name><code>GM</code></item><item><name>Ghana</name><code>GH</code></item><item><name>Gibraltar</name><code>GI</code></item><item><name>Grenada</name><code>GD</code></item><item><name>Georgia</name><code>GE</code></item><item><name>Greenland</name><code>GL</code></item><item><name>Guadeloupe</name><code>GP</code></item><item><name>French Guiana</name><code>GF</code></item><item><name>Guam</name><code>GU</code></item><item><name>Guatemala</name><code>GT</code></item><item><name>Guernsey</name><code>GG</code></item><item><name>Guinea</name><code>GN</code></item><item><name>Guinea-Bissau</name><code>GW</code></item><item><name>Guyana</name><code>GY</code></item><item><name>Haiti</name><code>HT</code></item><item><name>Heard and McDonald Islands</name><code>HM</code></item><item><name>Macao</name><code>MO</code></item><item><name>Hong Kong</name><code>HK</code></item><item><name>China</name><code>CN</code></item><item><name>Spain</name><code>ES</code></item><item><name>Netherlands Antilles</name><code>AN</code></item><item><name>Honduras</name><code>HN</code></item><item><name>Croatia</name><code>HR</code></item><item><name>Ireland</name><code>IE</code></item><item><name>Israel</name><code>IL</code></item><item><name>India</name><code>IN</code></item><item><name>Indonesia</name><code>ID</code></item><item><name>Iraq</name><code>IQ</code></item><item><name>Iran</name><code>IR</code></item><item><name>Iceland</name><code>IS</code></item><item><name>Italy</name><code>IT</code></item><item><name>Japan</name><code>JP</code></item><item><name>Jamaica</name><code>JM</code></item><item><name>Yemen</name><code>YE</code></item><item><name>Jersey</name><code>JE</code></item><item><name>Jordan</name><code>JO</code></item><item><name>Christmas Island</name><code>CX</code></item><item><name>Cayman Islands</name><code>KY</code></item><item><name>Cambodia</name><code>KH</code></item><item><name>Cameroon</name><code>CM</code></item><item><name>Canada</name><code>CA</code></item><item><name>Kazakhstan</name><code>KZ</code></item><item><name>Qatar</name><code>QA</code></item><item><name>Kenya</name><code>KE</code></item><item><name>Central African Republik</name><code>CF</code></item><item><name>Kyrgyzstan</name><code>KG</code></item><item><name>Kiribati</name><code>KI</code></item><item><name>Comoros</name><code>KM</code></item><item><name>Congo, the Democratic Republik of the</name><code>CD</code></item><item><name>Congo</name><code>CG</code></item><item><name>Cocos (Keeling) Islands</name><code>CC</code></item><item><name>Korea, Democratic Peoples Republic of</name><code>KP</code></item><item><name>Korea, Republic of</name><code>KR</code></item><item><name>Greece</name><code>GR</code></item><item><name>Cuba</name><code>CU</code></item><item><name>Kuwait</name><code>KW</code></item><item><name>Cyprus</name><code>CY</code></item><item><name>Lao Peoples Democratic Republic</name><code>LA</code></item><item><name>Lithuania</name><code>LT</code></item><item><name>Lesotho</name><code>LS</code></item><item><name>Liberia</name><code>LR</code></item><item><name>Liechtenstein</name><code>LI</code></item><item><name>Lebanon</name><code>LB</code></item><item><name>Luxembourg</name><code>LU</code></item><item><name>South Africa</name><code>ZA</code></item><item><name>South Georgia and the South Sandwich Islands</name><code>GS</code></item><item><name>Latvia</name><code>LV</code></item><item><name>Western Sahara</name><code>EH</code></item><item><name>Madagascar</name><code>MG</code></item><item><name>Netherlands</name><code>NL</code></item><item><name>Macedonia</name><code>MK</code></item><item><name>Malaysia</name><code>MY</code></item><item><name>Malawi</name><code>MW</code></item><item><name>Maldives</name><code>MV</code></item><item><name>Mali</name><code>ML</code></item><item><name>Malta</name><code>MT</code></item><item><name>Isle of Man</name><code>IM</code></item><item><name>Morocco</name><code>MA</code></item><item><name>Marshall Islands</name><code>MH</code></item><item><name>Martinique</name><code>MQ</code></item><item><name>Mauritania</name><code>MR</code></item><item><name>Mauritius</name><code>MU</code></item><item><name>Mayotte</name><code>YT</code></item><item><name>Mexico</name><code>MX</code></item><item><name>Micronesia</name><code>FM</code></item><item><name>Moldova, Republic of</name><code>MD</code></item><item><name>Monaco</name><code>MC</code></item><item><name>Mongolia</name><code>MN</code></item><item><name>Montenegro</name><code>ME</code></item><item><name>Montserrat</name><code>MS</code></item><item><name>Mozambique</name><code>MZ</code></item><item><name>Areas not elsewhere specified</name><code>XY</code></item><item><name>Not specified</name><code>XX</code></item><item><name>Myanmar</name><code>MM</code></item><item><name>Namibia</name><code>NA</code></item><item><name>Nauru</name><code>NR</code></item><item><name>Nepal</name><code>NP</code></item><item><name>Nicaragua</name><code>NI</code></item><item><name>Nigeria</name><code>NG</code></item><item><name>Niger</name><code>NE</code></item><item><name>Niue</name><code>NU</code></item><item><name>Norfolk Island</name><code>NF</code></item><item><name>Norway</name><code>NO</code></item><item><name>Oman</name><code>OM</code></item><item><name>Papua New Guinea</name><code>PG</code></item><item><name>Pakistan</name><code>PK</code></item><item><name>Palestinian Territory, Occupied</name><code>PS</code></item><item><name>Panama</name><code>PA</code></item><item><name>Paraguay</name><code>PY</code></item><item><name>Peru</name><code>PE</code></item><item><name>Pitcairn</name><code>PN</code></item><item><name>Poland</name><code>PL</code></item><item><name>Portugal</name><code>PT</code></item><item><name>French Southern Territories</name><code>TF</code></item><item><name>French Polynesia</name><code>PF</code></item><item><name>France</name><code>FR</code></item><item><name>Puerto Rico</name><code>PR</code></item><item><name>Northern Mariana Islands</name><code>MP</code></item><item><name>Holy See (Vatican City State)</name><code>VA</code></item><item><name>Réunion</name><code>RE</code></item><item><name>Sweden</name><code>SE</code></item><item><name>Romania</name><code>RO</code></item><item><name>Rwanda</name><code>RW</code></item><item><name>Solomon Islands</name><code>SB</code></item><item><name>Saint Kitts and Nevis</name><code>KN</code></item><item><name>Saint Helena</name><code>SH</code></item><item><name>Saint Lucia</name><code>LC</code></item><item><name>Saint Pierre and Miquelon</name><code>PM</code></item><item><name>Saint Vincent and the Grenadines</name><code>VC</code></item><item><name>Germany</name><code>DE</code></item><item><name>Zambia</name><code>ZM</code></item><item><name>Samoa</name><code>WS</code></item><item><name>San Marino</name><code>SM</code></item><item><name>Sao Tome and Principe</name><code>ST</code></item><item><name>Saudi Arabia</name><code>SA</code></item><item><name>Seychelles</name><code>SC</code></item><item><name>Senegal</name><code>SN</code></item><item><name>Serbia</name><code>RS</code></item><item><name>Sierra Leone</name><code>SL</code></item><item><name>Singapore</name><code>SG</code></item><item><name>Slovakia</name><code>SK</code></item><item><name>Slovenia</name><code>SI</code></item><item><name>Somalia</name><code>SO</code></item><item><name>Finland</name><code>FI</code></item><item><name>Sri Lanka</name><code>LK</code></item><item><name>Sudan</name><code>SD</code></item><item><name>Suriname</name><code>SR</code></item><item><name>Libyan Arab Jamahiriya</name><code>LY</code></item><item><name>United Kingdom</name><code>GB</code></item><item><name>Swaziland</name><code>SZ</code></item><item><name>Svalbard and Jan Mayen</name><code>SJ</code></item><item><name>Syrian Arab Republic</name><code>SY</code></item><item><name>Switzerland</name><code>CH</code></item><item><name>Zimbabwe</name><code>ZW</code></item><item><name>Denmark</name><code>DK</code></item><item><name>Tajikistan</name><code>TJ</code></item><item><name>Thailand</name><code>TH</code></item><item><name>Taiwan</name><code>TW</code></item><item><name>Tanzania, United Republic of</name><code>TZ</code></item><item><name>Timor-Leste</name><code>TL</code></item><item><name>Togo</name><code>TG</code></item><item><name>Tokelau</name><code>TK</code></item><item><name>Tonga</name><code>TO</code></item><item><name>Trinidad and Tobago</name><code>TT</code></item><item><name>Chad</name><code>TD</code></item><item><name>Czech Republic</name><code>CZ</code></item><item><name>Chile</name><code>CL</code></item><item><name>Tunisia</name><code>TN</code></item><item><name>Turks and Caicos Islands</name><code>TC</code></item><item><name>Tuvalu</name><code>TV</code></item><item><name>Turkey</name><code>TR</code></item><item><name>Turkmenistan</name><code>TM</code></item><item><name>Uganda</name><code>UG</code></item><item><name>Ukraine</name><code>UA</code></item><item><name>Hungary</name><code>HU</code></item><item><name>Uruguay</name><code>UY</code></item><item><name>Uzbekistan</name><code>UZ</code></item><item><name>New Caledonia</name><code>NC</code></item><item><name>New Zealand</name><code>NZ</code></item><item><name>Belarus</name><code>BY</code></item><item><name>Wallis and Futuna Islands</name><code>WF</code></item><item><name>Vanuatu</name><code>VU</code></item><item><name>Russian Federation</name><code>RU</code></item><item><name>Venezuela</name><code>VE</code></item><item><name>Viet Nam</name><code>VN</code></item><item><name>Virgin Islands (U.S.)</name><code>VI</code></item><item><name>United States Minor Outlying Islands</name><code>UM</code></item></xroad.countries>	xroad.countries	2021-01-27 10:25:45.770569	2021-01-27 10:25:45.770569	admin	\N	\N	\N	\N	\N	\N	\N	\N
15	<ehak><maakond kood="0037" nimi="Harju maakond"><vald kood="0141" nimi="Anija vald"><asula kood="1046" nimi="Aavere küla"/><asula kood="1088" nimi="Aegviidu alev"/><asula kood="1184" nimi="Alavere küla"/><asula kood="1278" nimi="Anija küla"/><asula kood="1321" nimi="Arava küla"/><asula kood="1961" nimi="Härmakosu küla"/><asula kood="2877" nimi="Kaunissaare küla"/><asula kood="2925" nimi="Kehra küla"/><asula kood="2928" nimi="Kehra linn"/><asula kood="3022" nimi="Kihmla küla"/><asula kood="3716" nimi="Kuusemäe küla"/><asula kood="4213" nimi="Lehtmetsa küla"/><asula kood="4369" nimi="Lilli küla"/><asula kood="4397" nimi="Linnakse küla"/><asula kood="4506" nimi="Looküla"/><asula kood="4672" nimi="Lükati küla"/><asula kood="5082" nimi="Mustjõe küla"/><asula kood="5789" nimi="Paasiku küla"/><asula kood="6009" nimi="Parila küla"/><asula kood="6022" nimi="Partsaare küla"/><asula kood="6241" nimi="Pikva küla"/><asula kood="6254" nimi="Pillapalu küla"/><asula kood="6828" nimi="Rasivere küla"/><asula kood="6855" nimi="Raudoja küla"/><asula kood="7068" nimi="Rooküla"/><asula kood="7396" nimi="Salumetsa küla"/><asula kood="7398" nimi="Salumäe küla"/><asula kood="7693" nimi="Soodla küla"/><asula kood="8764" nimi="Uuearu küla"/><asula kood="9248" nimi="Vetla küla"/><asula kood="9318" nimi="Vikipalu küla"/><asula kood="9480" nimi="Voose küla"/><asula kood="9827" nimi="Ülejõe küla"/></vald><vald kood="0198" nimi="Harku vald"><asula kood="1084" nimi="Adra küla"/><asula kood="1774" nimi="Harku alevik"/><asula kood="1776" nimi="Harkujärve küla"/><asula kood="1903" nimi="Humala küla"/><asula kood="2047" nimi="Ilmandu küla"/><asula kood="3608" nimi="Kumna küla"/><asula kood="3997" nimi="Kütke küla"/><asula kood="4002" nimi="Laabi küla"/><asula kood="4344" nimi="Liikva küla"/><asula kood="4880" nimi="Meriküla"/><asula kood="5038" nimi="Muraste küla"/><asula kood="5327" nimi="Naage küla"/><asula kood="6814" nimi="Rannamõisa küla"/><asula kood="7870" nimi="Suurupi küla"/><asula kood="7905" nimi="Sõrve küla"/><asula kood="8009" nimi="Tabasalu alevik"/><asula kood="8257" nimi="Tiskre küla"/><asula kood="8442" nimi="Tutermaa küla"/><asula kood="8599" nimi="Türisalu küla"/><asula kood="8848" nimi="Vahi küla"/><asula kood="8877" nimi="Vaila küla"/><asula kood="9434" nimi="Viti küla"/><asula kood="9683" nimi="Vääna küla"/><asula kood="9685" nimi="Vääna-Jõesuu küla"/></vald><vald kood="0245" nimi="Jõelähtme vald"><asula kood="1367" nimi="Aruaru küla"/><asula kood="1691" nimi="Haapse küla"/><asula kood="1741" nimi="Haljava küla"/><asula kood="2009" nimi="Ihasalu küla"/><asula kood="2100" nimi="Iru küla"/><asula kood="2234" nimi="Jõelähtme küla"/><asula kood="2248" nimi="Jõesuu küla"/><asula kood="2299" nimi="Jägala küla"/><asula kood="2301" nimi="Jägala-Joa küla"/><asula kood="2452" nimi="Kaberneeme küla"/><asula kood="2601" nimi="Kallavere küla"/><asula kood="3296" nimi="Koila küla"/><asula kood="3301" nimi="Koipsi küla"/><asula kood="3385" nimi="Koogi küla"/><asula kood="3471" nimi="Kostiranna küla"/><asula kood="3472" nimi="Kostivere alevik"/><asula kood="3588" nimi="Kullamäe küla"/><asula kood="4359" nimi="Liivamäe küla"/><asula kood="4496" nimi="Loo alevik"/><asula kood="4494" nimi="Loo küla"/><asula kood="4704" nimi="Maardu küla"/><asula kood="4776" nimi="Manniva küla"/><asula kood="5389" nimi="Neeme küla"/><asula kood="5400" nimi="Nehatu küla"/><asula kood="5997" nimi="Parasmäe küla"/><asula kood="6785" nimi="Rammu küla"/><asula kood="6882" nimi="Rebala küla"/><asula kood="7037" nimi="Rohusi küla"/><asula kood="7141" nimi="Ruu küla"/><asula kood="7335" nimi="Saha küla"/><asula kood="7405" nimi="Sambu küla"/><asula kood="7498" nimi="Saviranna küla"/><asula kood="8783" nimi="Uusküla"/><asula kood="9041" nimi="Vandjala küla"/><asula kood="9491" nimi="Võerdla küla"/><asula kood="9838" nimi="Ülgase küla"/></vald><vald kood="0296" nimi="Keila linn"/><vald kood="0304" nimi="Kiili vald"><asula kood="1388" nimi="Arusta küla"/><asula kood="2671" nimi="Kangru alevik"/><asula kood="3039" nimi="Kiili alev"/><asula kood="3656" nimi="Kurevere küla"/><asula kood="4550" nimi="Luige alevik"/><asula kood="4633" nimi="Lähtse küla"/><asula kood="4902" nimi="Metsanurga küla"/><asula kood="5125" nimi="Mõisaküla"/><asula kood="5329" nimi="Nabala küla"/><asula kood="5824" nimi="Paekna küla"/><asula kood="6198" nimi="Piissoo küla"/><asula kood="7472" nimi="Sausti küla"/><asula kood="7701" nimi="Sookaera küla"/><asula kood="7880" nimi="Sõgula küla"/><asula kood="7894" nimi="Sõmeru küla"/><asula kood="8824" nimi="Vaela küla"/></vald><vald kood="0338" nimi="Kose vald"><asula kood="1089" nimi="Aela küla"/><asula kood="1113" nimi="Ahisilla küla"/><asula kood="1174" nimi="Alansi küla"/><asula kood="1340" nimi="Ardu alevik"/><asula kood="1708" nimi="Habaja alevik"/><asula kood="1779" nimi="Harmi küla"/><asula kood="2485" nimi="Kadja küla"/><asula kood="2657" nimi="Kanavere küla"/><asula kood="2690" nimi="Kantküla"/><asula kood="2764" nimi="Karla küla"/><asula kood="2848" nimi="Kata küla"/><asula kood="2852" nimi="Katsina küla"/><asula kood="3140" nimi="Kirivalla küla"/><asula kood="3156" nimi="Kiruvere küla"/><asula kood="3363" nimi="Kolu küla"/><asula kood="3460" nimi="Kose alevik"/><asula kood="3464" nimi="Kose-Uuemõisa alevik"/><asula kood="3492" nimi="Krei küla"/><asula kood="3546" nimi="Kuivajõe küla"/><asula kood="3553" nimi="Kukepala küla"/><asula kood="3829" nimi="Kõrvenurga küla"/><asula kood="3834" nimi="Kõue küla"/><asula kood="4020" nimi="Laane küla"/><asula kood="4242" nimi="Leistu küla"/><asula kood="4352" nimi="Liiva küla"/><asula kood="4577" nimi="Lutsu küla"/><asula kood="4667" nimi="Lööra küla"/><asula kood="4788" nimi="Marguse küla"/><asula kood="5485" nimi="Nutu küla"/><asula kood="5506" nimi="Nõmbra küla"/><asula kood="5518" nimi="Nõmmeri küla"/><asula kood="5537" nimi="Nõrava küla"/><asula kood="5656" nimi="Ojasoo küla"/><asula kood="5738" nimi="Oru küla"/><asula kood="5907" nimi="Pala küla"/><asula kood="5962" nimi="Palvere küla"/><asula kood="6052" nimi="Paunaste küla"/><asula kood="6053" nimi="Paunküla"/><asula kood="6483" nimi="Puusepa küla"/><asula kood="6869" nimi="Rava küla"/><asula kood="6872" nimi="Raveliku küla"/><asula kood="6875" nimi="Ravila alevik"/><asula kood="6981" nimi="Riidamäe küla"/><asula kood="7191" nimi="Rõõsa küla"/><asula kood="7308" nimi="Saarnakõrve küla"/><asula kood="7324" nimi="Sae küla"/><asula kood="7457" nimi="Saula küla"/><asula kood="7597" nimi="Silmsi küla"/><asula kood="7891" nimi="Sõmeru küla"/><asula kood="7963" nimi="Sääsküla"/><asula kood="8022" nimi="Tade küla"/><asula kood="8112" nimi="Tammiku küla"/><asula kood="8346" nimi="Triigi küla"/><asula kood="8396" nimi="Tuhala küla"/><asula kood="8773" nimi="Uueveski küla"/><asula kood="8847" nimi="Vahetüki küla"/><asula kood="9032" nimi="Vanamõisa küla"/><asula kood="9071" nimi="Vardja küla"/><asula kood="9323" nimi="Vilama küla"/><asula kood="9385" nimi="Virla küla"/><asula kood="9417" nimi="Viskla küla"/><asula kood="9558" nimi="Võlle küla"/><asula kood="9749" nimi="Äksi küla"/></vald><vald kood="0353" nimi="Kuusalu vald"><asula kood="1202" nimi="Allika küla"/><asula kood="1256" nimi="Andineeme küla"/><asula kood="1363" nimi="Aru küla"/><asula kood="1701" nimi="Haavakannu küla"/><asula kood="1761" nimi="Hara küla"/><asula kood="1877" nimi="Hirvli küla"/><asula kood="2046" nimi="Ilmastalu küla"/><asula kood="2194" nimi="Joaveski küla"/><asula kood="2209" nimi="Juminda küla"/><asula kood="2450" nimi="Kaberla küla"/><asula kood="2509" nimi="Kahala küla"/><asula kood="2629" nimi="Kalme küla"/><asula kood="2804" nimi="Kasispea küla"/><asula kood="2949" nimi="Kemba küla"/><asula kood="3056" nimi="Kiiu alevik"/><asula kood="3055" nimi="Kiiu-Aabla küla"/><asula kood="3232" nimi="Kodasoo küla"/><asula kood="3300" nimi="Koitjärve küla"/><asula kood="3336" nimi="Kolga alevik"/><asula kood="1007" nimi="Kolga-Aabla küla"/><asula kood="3343" nimi="Kolgaküla"/><asula kood="3342" nimi="Kolgu küla"/><asula kood="3474" nimi="Kosu küla"/><asula kood="3480" nimi="Kotka küla"/><asula kood="3630" nimi="Kupu küla"/><asula kood="3691" nimi="Kursi küla"/><asula kood="3714" nimi="Kuusalu alevik"/><asula kood="3718" nimi="Kuusalu küla"/><asula kood="3768" nimi="Kõnnu küla"/><asula kood="3993" nimi="Külmaallika küla"/><asula kood="4188" nimi="Leesi küla"/><asula kood="4334" nimi="Liiapeksi küla"/><asula kood="4471" nimi="Loksa küla"/><asula kood="5048" nimi="Murksi küla"/><asula kood="5064" nimi="Mustametsa küla"/><asula kood="5108" nimi="Muuksi küla"/><asula kood="5208" nimi="Mäepea küla"/><asula kood="5533" nimi="Nõmmeveski küla"/><asula kood="5901" nimi="Pala küla"/><asula kood="6016" nimi="Parksi küla"/><asula kood="6065" nimi="Pedaspea küla"/><asula kood="6378" nimi="Pudisoo küla"/><asula kood="6497" nimi="Põhja küla"/><asula kood="6606" nimi="Pärispea küla"/><asula kood="6898" nimi="Rehatse küla"/><asula kood="7122" nimi="Rummu küla"/><asula kood="7390" nimi="Salmistu küla"/><asula kood="7466" nimi="Saunja küla"/><asula kood="7562" nimi="Sigula küla"/><asula kood="7734" nimi="Soorinna küla"/><asula kood="7809" nimi="Suru küla"/><asula kood="7866" nimi="Suurpea küla"/><asula kood="7882" nimi="Sõitme küla"/><asula kood="8118" nimi="Tammispea küla"/><asula kood="8125" nimi="Tammistu küla"/><asula kood="8144" nimi="Tapurla küla"/><asula kood="8367" nimi="Tsitre küla"/><asula kood="8424" nimi="Turbuneeme küla"/><asula kood="8193" nimi="Tõreska küla"/><asula kood="8782" nimi="Uuri küla"/><asula kood="8839" nimi="Vahastu küla"/><asula kood="8919" nimi="Valgejõe küla"/><asula kood="8954" nimi="Valkla küla"/><asula kood="9014" nimi="Vanaküla"/><asula kood="9257" nimi="Vihasoo küla"/><asula kood="9283" nimi="Viinistu küla"/><asula kood="9411" nimi="Virve küla"/></vald><vald kood="0424" nimi="Loksa linn"/><vald kood="0431" nimi="Lääne-Harju vald"><asula kood="1208" nimi="Alliklepa küla"/><asula kood="1221" nimi="Altküla"/><asula kood="1450" nimi="Audevälja küla"/><asula kood="1771" nimi="Harju-Risti küla"/><asula kood="1782" nimi="Hatu küla"/><asula kood="2045" nimi="Illurma küla"/><asula kood="2731" nimi="Karilepa küla"/><asula kood="2749" nimi="Karjaküla alevik"/><asula kood="2797" nimi="Kasepere küla"/><asula kood="2909" nimi="Keelva küla"/><asula kood="2927" nimi="Keibu küla"/><asula kood="2930" nimi="Keila-Joa alevik"/><asula kood="2978" nimi="Kersalu küla"/><asula kood="3205" nimi="Klooga alevik"/><asula kood="3207" nimi="Kloogaranna küla"/><asula kood="3224" nimi="Kobru küla"/><asula kood="3603" nimi="Kulna küla"/><asula kood="3682" nimi="Kurkse küla"/><asula kood="3762" nimi="Kõmmaste küla"/><asula kood="3857" nimi="Käesalu küla"/><asula kood="4019" nimi="Laane küla"/><asula kood="4096" nimi="Langa küla"/><asula kood="4112" nimi="Laoküla"/><asula kood="4148" nimi="Laulasmaa küla"/><asula kood="4211" nimi="Lehola küla"/><asula kood="4263" nimi="Lemmaru küla"/><asula kood="4456" nimi="Lohusalu küla"/><asula kood="4722" nimi="Madise küla"/><asula kood="4725" nimi="Maeru küla"/><asula kood="4876" nimi="Meremõisa küla"/><asula kood="4931" nimi="Metslõugu küla"/><asula kood="5290" nimi="Määra küla"/><asula kood="5343" nimi="Nahkjala küla"/><asula kood="5424" nimi="Niitvälja küla"/><asula kood="5628" nimi="Ohtu küla"/><asula kood="5812" nimi="Padise küla"/><asula kood="5821" nimi="Pae küla"/><asula kood="5925" nimi="Paldiski linn"/><asula kood="6062" nimi="Pedase küla"/><asula kood="6528" nimi="Põllküla"/><asula kood="7121" nimi="Rummu alevik"/><asula kood="7856" nimi="Suurküla"/><asula kood="8460" nimi="Tuulna küla"/><asula kood="8499" nimi="Tõmmiku küla"/><asula kood="8956" nimi="Valkse küla"/><asula kood="9101" nimi="Vasalemma alevik"/><asula kood="9231" nimi="Veskiküla"/><asula kood="9265" nimi="Vihterpalu küla"/><asula kood="9339" nimi="Vilivalla küla"/><asula kood="9380" nimi="Vintse küla"/><asula kood="9752" nimi="Ämari alevik"/><asula kood="9767" nimi="Änglema küla"/></vald><vald kood="0446" nimi="Maardu linn"/><vald kood="0651" nimi="Raasiku vald"><asula kood="1373" nimi="Aruküla alevik"/><asula kood="1954" nimi="Härma küla"/><asula kood="1994" nimi="Igavere küla"/><asula kood="2335" nimi="Järsi küla"/><asula kood="2575" nimi="Kalesi küla"/><asula kood="3183" nimi="Kiviloo küla"/><asula kood="3597" nimi="Kulli küla"/><asula kood="3668" nimi="Kurgla küla"/><asula kood="4758" nimi="Mallavere küla"/><asula kood="6098" nimi="Peningi küla"/><asula kood="6122" nimi="Perila küla"/><asula kood="6228" nimi="Pikavere küla"/><asula kood="6694" nimi="Raasiku alevik"/><asula kood="7226" nimi="Rätla küla"/><asula kood="8477" nimi="Tõhelgi küla"/></vald><vald kood="0653" nimi="Rae vald"><asula kood="1050" nimi="Aaviku küla"/><asula kood="1391" nimi="Aruvalla küla"/><asula kood="1408" nimi="Assaku alevik"/><asula kood="2353" nimi="Järveküla"/><asula kood="2377" nimi="Jüri alevik"/><asula kood="2474" nimi="Kadaka küla"/><asula kood="2763" nimi="Karla küla"/><asula kood="2885" nimi="Kautjala küla"/><asula kood="3435" nimi="Kopli küla"/><asula kood="3687" nimi="Kurna küla"/><asula kood="4043" nimi="Lagedi alevik"/><asula kood="4208" nimi="Lehmja küla"/><asula kood="4378" nimi="Limu küla"/><asula kood="5891" nimi="Pajupea küla"/><asula kood="6036" nimi="Patika küla"/><asula kood="6086" nimi="Peetri alevik"/><asula kood="6240" nimi="Pildiküla"/><asula kood="6713" nimi="Rae küla"/><asula kood="7392" nimi="Salu küla"/><asula kood="7517" nimi="Seli küla"/><asula kood="7688" nimi="Soodevahe küla"/><asula kood="7852" nimi="Suuresta küla"/><asula kood="7868" nimi="Suursoo küla"/><asula kood="8454" nimi="Tuulevälja küla"/><asula kood="8731" nimi="Urvaste küla"/><asula kood="8774" nimi="Uuesalu küla"/><asula kood="8867" nimi="Vaida alevik"/><asula kood="8869" nimi="Vaidasoo küla"/><asula kood="9108" nimi="Vaskjala küla"/><asula kood="9202" nimi="Veneküla"/><asula kood="9236" nimi="Veskitaguse küla"/><asula kood="9832" nimi="Ülejõe küla"/></vald><vald kood="0718" nimi="Saku vald"><asula kood="2220" nimi="Juuliku küla"/><asula kood="2307" nimi="Jälgimäe küla"/><asula kood="2552" nimi="Kajamaa küla"/><asula kood="2794" nimi="Kasemetsa küla"/><asula kood="3048" nimi="Kiisa alevik"/><asula kood="3119" nimi="Kirdalu küla"/><asula kood="3697" nimi="Kurtna küla"/><asula kood="4481" nimi="Lokuti küla"/><asula kood="4912" nimi="Metsanurme küla"/><asula kood="5261" nimi="Männiku küla"/><asula kood="6739" nimi="Rahula küla"/><asula kood="7056" nimi="Roobuka küla"/><asula kood="7361" nimi="Saku alevik"/><asula kood="2652" nimi="Saue küla"/><asula kood="7469" nimi="Saustinõmme küla"/><asula kood="7704" nimi="Sookaera-Metsanurga küla"/><asula kood="8033" nimi="Tagadi küla"/><asula kood="8096" nimi="Tammejärve küla"/><asula kood="8098" nimi="Tammemäe küla"/><asula kood="8472" nimi="Tõdva küla"/><asula kood="8572" nimi="Tänassilma küla"/><asula kood="9820" nimi="Üksnurme küla"/></vald><vald kood="0726" nimi="Saue vald"><asula kood="1141" nimi="Aila küla"/><asula kood="1206" nimi="Allika küla"/><asula kood="1216" nimi="Alliku küla"/><asula kood="1449" nimi="Aude küla"/><asula kood="1585" nimi="Ellamaa küla"/><asula kood="1720" nimi="Haiba küla"/><asula kood="1854" nimi="Hingu küla"/><asula kood="1975" nimi="Hüüru küla"/><asula kood="2135" nimi="Jaanika küla"/><asula kood="2267" nimi="Jõgisoo küla"/><asula kood="2427" nimi="Kaasiku küla"/><asula kood="2455" nimi="Kabila küla"/><asula kood="2976" nimi="Kernu küla"/><asula kood="3001" nimi="Kibuna küla"/><asula kood="3025" nimi="Kiia küla"/><asula kood="3120" nimi="Kirikla küla"/><asula kood="3195" nimi="Kivitammi küla"/><asula kood="3266" nimi="Kohatu küla"/><asula kood="3285" nimi="Koidu küla"/><asula kood="3439" nimi="Koppelmaa küla"/><asula kood="3705" nimi="Kustja küla"/><asula kood="4014" nimi="Laagri alevik"/><asula kood="4075" nimi="Laitse küla"/><asula kood="4206" nimi="Lehetu küla"/><asula kood="4289" nimi="Lepaste küla"/><asula kood="4717" nimi="Madila küla"/><asula kood="4739" nimi="Maidla küla"/><asula kood="4903" nimi="Metsanurga küla"/><asula kood="5028" nimi="Munalaskme küla"/><asula kood="5093" nimi="Mustu küla"/><asula kood="5110" nimi="Muusika küla"/><asula kood="5157" nimi="Mõnuste küla"/><asula kood="5467" nimi="Nurme küla"/><asula kood="5601" nimi="Odulemma küla"/><asula kood="6308" nimi="Pohla küla"/><asula kood="6588" nimi="Pällu küla"/><asula kood="6603" nimi="Pärinurme küla"/><asula kood="6652" nimi="Püha küla"/><asula kood="6989" nimi="Riisipere alevik"/><asula kood="7110" nimi="Ruila küla"/><asula kood="7453" nimi="Saue linn"/><asula kood="7571" nimi="Siimika küla"/><asula kood="8006" nimi="Tabara küla"/><asula kood="8045" nimi="Tagametsa küla"/><asula kood="8421" nimi="Turba alevik"/><asula kood="8450" nimi="Tuula küla"/><asula kood="8946" nimi="Valingu küla"/><asula kood="9033" nimi="Vanamõisa küla"/><asula kood="9049" nimi="Vansi küla"/><asula kood="9146" nimi="Vatsla küla"/><asula kood="9362" nimi="Vilumäe küla"/><asula kood="9401" nimi="Viruküla"/><asula kood="9794" nimi="Ääsmäe küla"/><asula kood="9846" nimi="Ürjaste küla"/></vald><vald kood="0784" nimi="Tallinn"><asula kood="0176" nimi="Haabersti linnaosa"/><asula kood="0298" nimi="Kesklinna linnaosa"/><asula kood="0339" nimi="Kristiine linnaosa"/><asula kood="0387" nimi="Lasnamäe linnaosa"/><asula kood="0482" nimi="Mustamäe linnaosa"/><asula kood="0524" nimi="Nõmme linnaosa"/><asula kood="0596" nimi="Pirita linnaosa"/><asula kood="0614" nimi="Põhja-Tallinna linnaosa"/></vald><vald kood="0890" nimi="Viimsi vald"><asula kood="1675" nimi="Haabneeme alevik"/><asula kood="1984" nimi="Idaotsa küla"/><asula kood="2944" nimi="Kelnase küla"/><asula kood="2945" nimi="Kelvingi küla"/><asula kood="4064" nimi="Laiaküla"/><asula kood="4299" nimi="Leppneeme küla"/><asula kood="4534" nimi="Lubja küla"/><asula kood="4618" nimi="Lõunaküla / Storbyn"/><asula kood="4656" nimi="Lääneotsa küla"/><asula kood="4887" nimi="Metsakasti küla"/><asula kood="4943" nimi="Miiduranna küla"/><asula kood="5104" nimi="Muuga küla"/><asula kood="6370" nimi="Pringi küla"/><asula kood="6613" nimi="Pärnamäe küla"/><asula kood="6672" nimi="Püünsi küla"/><asula kood="6797" nimi="Randvere küla"/><asula kood="7039" nimi="Rohuneeme küla"/><asula kood="8039" nimi="Tagaküla / Bakbyn"/><asula kood="8126" nimi="Tammneeme küla"/><asula kood="9280" nimi="Viimsi alevik"/><asula kood="9619" nimi="Väikeheinamaa küla / Lillängin"/><asula kood="9744" nimi="Äigrumäe küla"/></vald></maakond><maakond kood="0039" nimi="Hiiu maakond"><vald kood="0205" nimi="Hiiumaa vald"><asula kood="1013" nimi="Aadma küla"/><asula kood="1157" nimi="Ala küla"/><asula kood="1200" nimi="Allika küla"/><asula kood="1374" nimi="Aruküla"/><asula kood="1589" nimi="Emmaste küla"/><asula kood="1587" nimi="Emmaste-Kurisu küla"/><asula kood="1588" nimi="Emmaste-Selja küla"/><asula kood="1647" nimi="Esiküla"/><asula kood="1713" nimi="Hagaste küla"/><asula kood="1734" nimi="Haldi küla"/><asula kood="1732" nimi="Haldreka küla"/><asula kood="1769" nimi="Harju küla"/><asula kood="1787" nimi="Hausma küla"/><asula kood="1788" nimi="Heigi küla"/><asula kood="1801" nimi="Heiste küla"/><asula kood="1800" nimi="Heistesoo küla"/><asula kood="1807" nimi="Hellamaa küla"/><asula kood="1818" nimi="Heltermaa küla"/><asula kood="1835" nimi="Hiiessaare küla"/><asula kood="1841" nimi="Hilleste küla"/><asula kood="1851" nimi="Hindu küla"/><asula kood="1873" nimi="Hirmuste küla"/><asula kood="1952" nimi="Härma küla"/><asula kood="1971" nimi="Hüti küla"/><asula kood="2109" nimi="Isabella küla"/><asula kood="2180" nimi="Jausa küla"/><asula kood="2227" nimi="Jõeküla"/><asula kood="2247" nimi="Jõeranna küla"/><asula kood="2250" nimi="Jõesuu küla"/><asula kood="2428" nimi="Kaasiku küla"/><asula kood="2467" nimi="Kabuna küla"/><asula kood="2481" nimi="Kaderna küla"/><asula kood="2533" nimi="Kaigutsi küla"/><asula kood="2561" nimi="Kalana küla"/><asula kood="2577" nimi="Kaleste küla"/><asula kood="2578" nimi="Kalgi küla"/><asula kood="2650" nimi="Kanapeeksi küla"/><asula kood="2807" nimi="Kassari küla"/><asula kood="2881" nimi="Kauste küla"/><asula kood="2959" nimi="Kerema küla"/><asula kood="3004" nimi="Kidaste küla"/><asula kood="3009" nimi="Kiduspe küla"/><asula kood="3054" nimi="Kiivera küla"/><asula kood="3160" nimi="Kitsa küla"/><asula kood="3196" nimi="Kleemu küla"/><asula kood="3235" nimi="Kodeste küla"/><asula kood="3253" nimi="Kogri küla"/><asula kood="3271" nimi="Koidma küla"/><asula kood="3337" nimi="Kolga küla"/><asula kood="3433" nimi="Kopa küla"/><asula kood="3557" nimi="Kukka küla"/><asula kood="3671" nimi="Kuri küla"/><asula kood="3680" nimi="Kuriste küla"/><asula kood="3679" nimi="Kurisu küla"/><asula kood="3717" nimi="Kuusiku küla"/><asula kood="3759" nimi="Kõlunõmme küla"/><asula kood="3760" nimi="Kõmmusselja küla"/><asula kood="3781" nimi="Kõpu küla"/><asula kood="3795" nimi="Kõrgessaare alevik"/><asula kood="3869" nimi="Käina alevik"/><asula kood="3895" nimi="Kärdla linn"/><asula kood="3893" nimi="Kärdla-Nõmme küla"/><asula kood="3976" nimi="Külaküla"/><asula kood="3978" nimi="Külama küla"/><asula kood="4025" nimi="Laartsa küla"/><asula kood="4023" nimi="Laasi küla"/><asula kood="4056" nimi="Laheküla"/><asula kood="4128" nimi="Lassi küla"/><asula kood="4141" nimi="Lauka küla"/><asula kood="4184" nimi="Leerimetsa küla"/><asula kood="4209" nimi="Lehtma küla"/><asula kood="4223" nimi="Leigri küla"/><asula kood="4245" nimi="Leisu küla"/><asula kood="4253" nimi="Lelu küla"/><asula kood="4290" nimi="Lepiku küla"/><asula kood="4319" nimi="Ligema küla"/><asula kood="4371" nimi="Lilbi küla"/><asula kood="4402" nimi="Linnumäe küla"/><asula kood="4465" nimi="Loja küla"/><asula kood="4537" nimi="Luguse küla"/><asula kood="4546" nimi="Luidja küla"/><asula kood="4590" nimi="Lõbembe küla"/><asula kood="4612" nimi="Lõpe küla"/><asula kood="4765" nimi="Malvaste küla"/><asula kood="4766" nimi="Mangu küla"/><asula kood="4780" nimi="Mardihansu küla"/><asula kood="4844" nimi="Meelste küla"/><asula kood="4890" nimi="Metsaküla"/><asula kood="4898" nimi="Metsalauka küla"/><asula kood="4910" nimi="Metsapere küla"/><asula kood="4966" nimi="Moka küla"/><asula kood="4993" nimi="Muda küla"/><asula kood="4995" nimi="Mudaste küla"/><asula kood="5183" nimi="Mäeküla"/><asula kood="5203" nimi="Mäeltse küla"/><asula kood="5224" nimi="Mägipe küla"/><asula kood="5258" nimi="Männamaa küla"/><asula kood="5272" nimi="Mänspe küla"/><asula kood="5298" nimi="Määvli küla"/><asula kood="5350" nimi="Napi küla"/><asula kood="5360" nimi="Nasva küla"/><asula kood="5412" nimi="Niidiküla"/><asula kood="5479" nimi="Nurste küla"/><asula kood="5503" nimi="Nõmba küla"/><asula kood="5512" nimi="Nõmme küla"/><asula kood="5514" nimi="Nõmmerga küla"/><asula kood="5613" nimi="Ogandi küla"/><asula kood="5649" nimi="Ojaküla"/><asula kood="5654" nimi="Ole küla"/><asula kood="5728" nimi="Orjaku küla"/><asula kood="5767" nimi="Otste küla"/><asula kood="5908" nimi="Palade küla"/><asula kood="5932" nimi="Palli küla"/><asula kood="5946" nimi="Paluküla"/><asula kood="5978" nimi="Paope küla"/><asula kood="6024" nimi="Partsi küla"/><asula kood="6145" nimi="Pihla küla"/><asula kood="6258" nimi="Pilpaküla"/><asula kood="6297" nimi="Poama küla"/><asula kood="6357" nimi="Prassi küla"/><asula kood="6373" nimi="Prählamäe küla"/><asula kood="6372" nimi="Prähnu küla"/><asula kood="6419" nimi="Puliste küla"/><asula kood="6459" nimi="Puski küla"/><asula kood="6460" nimi="Putkaste küla"/><asula kood="6609" nimi="Pärna küla"/><asula kood="6615" nimi="Pärnselja küla"/><asula kood="6661" nimi="Pühalepa küla"/><asula kood="6660" nimi="Pühalepa-Harju küla"/><asula kood="6801" nimi="Rannaküla"/><asula kood="6903" nimi="Reheselja küla"/><asula kood="6908" nimi="Reigi küla"/><asula kood="6909" nimi="Reigi-Nõmme küla"/><asula kood="6910" nimi="Reikama küla"/><asula kood="6972" nimi="Riidaküla"/><asula kood="7009" nimi="Risti küla"/><asula kood="7014" nimi="Ristivälja küla"/><asula kood="7084" nimi="Rootsi küla"/><asula kood="7349" nimi="Sakla küla"/><asula kood="7382" nimi="Salinõmme küla"/><asula kood="7438" nimi="Sarve küla"/><asula kood="7528" nimi="Selja küla"/><asula kood="7548" nimi="Sepaste küla"/><asula kood="7554" nimi="Sigala küla"/><asula kood="7616" nimi="Sinima küla"/><asula kood="7728" nimi="Soonlepa küla"/><asula kood="7846" nimi="Suuremõisa küla"/><asula kood="7848" nimi="Suurepsi küla"/><asula kood="7850" nimi="Suureranna küla"/><asula kood="7864" nimi="Suuresadama küla"/><asula kood="7900" nimi="Sõru küla"/><asula kood="7949" nimi="Sääre küla"/><asula kood="7972" nimi="Sülluste küla"/><asula kood="8061" nimi="Taguküla"/><asula kood="8067" nimi="Tahkuna küla"/><asula kood="8095" nimi="Tammela küla"/><asula kood="8122" nimi="Tammistu küla"/><asula kood="8150" nimi="Tareste küla"/><asula kood="8162" nimi="Taterma küla"/><asula kood="8190" nimi="Tempa küla"/><asula kood="8209" nimi="Tiharu küla"/><asula kood="8236" nimi="Tilga küla"/><asula kood="8271" nimi="Tohvri küla"/><asula kood="8382" nimi="Tubala küla"/><asula kood="8576" nimi="Tärkma küla"/><asula kood="8656" nimi="Ulja küla"/><asula kood="8682" nimi="Undama küla"/><asula kood="8747" nimi="Utu küla"/><asula kood="8827" nimi="Vaemla küla"/><asula kood="8853" nimi="Vahtrepa küla"/><asula kood="8938" nimi="Valgu küla"/><asula kood="8949" nimi="Valipe küla"/><asula kood="9019" nimi="Vanamõisa küla"/><asula kood="9278" nimi="Viilupi küla"/><asula kood="9295" nimi="Viiri küla"/><asula kood="9303" nimi="Viita küla"/><asula kood="9306" nimi="Viitasoo küla"/><asula kood="9327" nimi="Vilima küla"/><asula kood="9338" nimi="Vilivalla küla"/><asula kood="9349" nimi="Villamaa küla"/><asula kood="8911" nimi="Villemi küla"/><asula kood="9674" nimi="Värssu küla"/><asula kood="9703" nimi="Õngu küla"/><asula kood="9816" nimi="Ühtri küla"/><asula kood="9826" nimi="Ülendi küla"/></vald></maakond><maakond kood="0045" nimi="Ida-Viru maakond"><vald kood="0130" nimi="Alutaguse vald"><asula kood="1103" nimi="Agusalu küla"/><asula kood="1165" nimi="Alajõe küla"/><asula kood="1211" nimi="Alliku küla"/><asula kood="1310" nimi="Apandiku küla"/><asula kood="1377" nimi="Aruküla"/><asula kood="1398" nimi="Arvila küla"/><asula kood="1443" nimi="Atsalama küla"/><asula kood="1526" nimi="Edivere küla"/><asula kood="1623" nimi="Ereda küla"/><asula kood="2025" nimi="Iisaku alevik"/><asula kood="2042" nimi="Illuka küla"/><asula kood="2071" nimi="Imatu küla"/><asula kood="2130" nimi="Jaama küla"/><asula kood="2249" nimi="Jõetaguse küla"/><asula kood="2281" nimi="Jõuga küla"/><asula kood="2431" nimi="Kaatermu küla"/><asula kood="2528" nimi="Kaidma küla"/><asula kood="2586" nimi="Kalina küla"/><asula kood="2639" nimi="Kamarna küla"/><asula kood="2752" nimi="Karjamaa küla"/><asula kood="2767" nimi="Karoli küla"/><asula kood="2802" nimi="Kasevälja küla"/><asula kood="2850" nimi="Katase küla"/><asula kood="2868" nimi="Kauksi küla"/><asula kood="2939" nimi="Kellassaare küla"/><asula kood="3035" nimi="Kiikla küla"/><asula kood="3190" nimi="Kivinõmme küla"/><asula kood="3331" nimi="Koldamäe küla"/><asula kood="3377" nimi="Konsu küla"/><asula kood="3621" nimi="Kuningaküla"/><asula kood="3644" nimi="Kuremäe küla"/><asula kood="3696" nimi="Kurtna küla"/><asula kood="3700" nimi="Kuru küla"/><asula kood="4258" nimi="Lemmaku küla"/><asula kood="4374" nimi="Liivakünka küla"/><asula kood="4418" nimi="Lipniku küla"/><asula kood="4610" nimi="Lõpe küla"/><asula kood="4923" nimi="Metsküla"/><asula kood="5213" nimi="Mäetaguse alevik"/><asula kood="5217" nimi="Mäetaguse küla"/><asula kood="5615" nimi="Ohakvere küla"/><asula kood="5677" nimi="Ongassaare küla"/><asula kood="5695" nimi="Oonurme küla"/><asula kood="5841" nimi="Pagari küla"/><asula kood="6117" nimi="Peressaare küla"/><asula kood="6127" nimi="Permisküla"/><asula kood="6224" nimi="Pikati küla"/><asula kood="6327" nimi="Pootsiku küla"/><asula kood="6391" nimi="Puhatu küla"/><asula kood="6767" nimi="Rajaküla"/><asula kood="6816" nimi="Rannapungerja küla"/><asula kood="6844" nimi="Ratva küla"/><asula kood="6866" nimi="Rausvere küla"/><asula kood="6927" nimi="Remniku küla"/><asula kood="7086" nimi="Roostoja küla"/><asula kood="7337" nimi="Sahargu küla"/><asula kood="7649" nimi="Smolnitsa küla"/><asula kood="7902" nimi="Sõrumäe küla"/><asula kood="7924" nimi="Sälliku küla"/><asula kood="1534" nimi="Taga-Roostoja küla"/><asula kood="8035" nimi="Tagajõe küla"/><asula kood="8104" nimi="Tammetaguse küla"/><asula kood="8147" nimi="Tarakuse küla"/><asula kood="8393" nimi="Tudulinna alevik"/><asula kood="8578" nimi="Tärivere küla"/><asula kood="8624" nimi="Uhe küla"/><asula kood="8786" nimi="Uusküla"/><asula kood="8874" nimi="Vaikla küla"/><asula kood="9075" nimi="Varesmetsa küla"/><asula kood="9106" nimi="Vasavere küla"/><asula kood="9111" nimi="Vasknarva küla"/><asula kood="9494" nimi="Võhma küla"/><asula kood="9516" nimi="Võide küla"/><asula kood="9580" nimi="Võrnu küla"/><asula kood="9631" nimi="Väike-Pungerja küla"/></vald><vald kood="0251" nimi="Jõhvi vald"><asula kood="1524" nimi="Edise küla"/><asula kood="2271" nimi="Jõhvi küla"/><asula kood="2270" nimi="Jõhvi linn"/><asula kood="2520" nimi="Kahula küla"/><asula kood="3461" nimi="Kose küla"/><asula kood="3477" nimi="Kotinuka küla"/><asula kood="4389" nimi="Linna küla"/><asula kood="5884" nimi="Pajualuse küla"/><asula kood="5999" nimi="Pargitaguse küla"/><asula kood="6050" nimi="Pauliku küla"/><asula kood="6455" nimi="Puru küla"/><asula kood="7677" nimi="Sompa küla"/><asula kood="8114" nimi="Tammiku alevik"/></vald><vald kood="0321" nimi="Kohtla-Järve linn"><asula kood="0120" nimi="Ahtme linnaosa"/><asula kood="0265" nimi="Järve linnaosa"/><asula kood="0340" nimi="Kukruse linnaosa"/><asula kood="0553" nimi="Oru linnaosa"/><asula kood="0747" nimi="Sompa linnaosa"/></vald><vald kood="0442" nimi="Lüganuse vald"><asula kood="1004" nimi="Aa küla"/><asula kood="1132" nimi="Aidu küla"/><asula kood="1139" nimi="Aidu-Liiva küla"/><asula kood="1133" nimi="Aidu-Nõmme küla"/><asula kood="1140" nimi="Aidu-Sooküla"/><asula kood="1368" nimi="Aruküla"/><asula kood="1382" nimi="Arupäälse küla"/><asula kood="1393" nimi="Aruvälja küla"/><asula kood="1631" nimi="Erra alevik"/><asula kood="1629" nimi="Erra-Liiva küla"/><asula kood="1871" nimi="Hirmuse küla"/><asula kood="2051" nimi="Ilmaste küla"/><asula kood="2105" nimi="Irvala küla"/><asula kood="2150" nimi="Jabara küla"/><asula kood="3194" nimi="Kiviõli linn"/><asula kood="3348" nimi="Koljala küla"/><asula kood="3404" nimi="Koolma küla"/><asula kood="3436" nimi="Kopli küla"/><asula kood="3576" nimi="Kulja küla"/><asula kood="4347" nimi="Liimala küla"/><asula kood="4419" nimi="Lipu küla"/><asula kood="4449" nimi="Lohkuse küla"/><asula kood="4669" nimi="Lüganuse alevik"/><asula kood="4688" nimi="Lümatu küla"/><asula kood="4740" nimi="Maidla küla"/><asula kood="4819" nimi="Matka küla"/><asula kood="4857" nimi="Mehide küla"/><asula kood="4975" nimi="Moldova küla"/><asula kood="5088" nimi="Mustmätta küla"/><asula kood="5569" nimi="Nüri küla"/><asula kood="5574" nimi="Oandu küla"/><asula kood="5652" nimi="Ojamaa küla"/><asula kood="6172" nimi="Piilse küla"/><asula kood="6450" nimi="Purtse küla"/><asula kood="6671" nimi="Püssi linn"/><asula kood="6894" nimi="Rebu küla"/><asula kood="7245" nimi="Rääsa küla"/><asula kood="7371" nimi="Salaküla"/><asula kood="7447" nimi="Satsu küla"/><asula kood="7477" nimi="Savala küla"/><asula kood="7640" nimi="Sirtsi küla"/><asula kood="7680" nimi="Sonda alevik"/><asula kood="7735" nimi="Soonurme küla"/><asula kood="8154" nimi="Tarumaa küla"/><asula kood="8660" nimi="Uljaste küla"/><asula kood="8691" nimi="Uniküla"/><asula kood="8884" nimi="Vainu küla"/><asula kood="9005" nimi="Vana-Sonda küla"/><asula kood="9086" nimi="Varinurme küla"/><asula kood="9088" nimi="Varja küla"/><asula kood="9200" nimi="Veneoja küla"/><asula kood="9406" nimi="Virunurme küla"/><asula kood="9475" nimi="Voorepera küla"/></vald><vald kood="0511" nimi="Narva linn"/><vald kood="0514" nimi="Narva-Jõesuu linn"><asula kood="1381" nimi="Arumäe küla"/><asula kood="1472" nimi="Auvere küla"/><asula kood="1833" nimi="Hiiemetsa küla"/><asula kood="1908" nimi="Hundinurga küla"/><asula kood="3520" nimi="Kudruküla"/><asula kood="4012" nimi="Laagna küla"/><asula kood="4884" nimi="Meriküla"/><asula kood="5067" nimi="Mustanina küla"/><asula kood="5356" nimi="Narva-Jõesuu linn"/><asula kood="5663" nimi="Olgina alevik"/><asula kood="6084" nimi="Peeterristi küla"/><asula kood="6125" nimi="Perjatsi küla"/><asula kood="6265" nimi="Pimestiku küla"/><asula kood="6396" nimi="Puhkova küla"/><asula kood="7619" nimi="Sinimäe alevik"/><asula kood="7631" nimi="Sirgala küla"/><asula kood="7674" nimi="Soldina küla"/><asula kood="7908" nimi="Sõtke küla"/><asula kood="8530" nimi="Tõrvajõe küla"/><asula kood="8619" nimi="Udria küla"/><asula kood="8895" nimi="Vaivara küla"/><asula kood="9314" nimi="Viivikonna küla"/><asula kood="9444" nimi="Vodava küla"/></vald><vald kood="0735" nimi="Sillamäe linn"/><vald kood="0803" nimi="Toila vald"><asula kood="1212" nimi="Altküla"/><asula kood="1253" nimi="Amula küla"/><asula kood="2350" nimi="Järve küla"/><asula kood="2420" nimi="Kaasikaia küla"/><asula kood="2429" nimi="Kaasikvälja küla"/><asula kood="2448" nimi="Kabelimetsa küla"/><asula kood="3269" nimi="Kohtla küla"/><asula kood="3270" nimi="Kohtla-Nõmme alev"/><asula kood="3375" nimi="Konju küla"/><asula kood="3562" nimi="Kukruse küla"/><asula kood="4799" nimi="Martsa küla"/><asula kood="4896" nimi="Metsamägara küla"/><asula kood="5142" nimi="Mõisamaa küla"/><asula kood="5680" nimi="Ontika küla"/><asula kood="5793" nimi="Paate küla"/><asula kood="6081" nimi="Peeri küla"/><asula kood="6582" nimi="Päite küla"/><asula kood="6656" nimi="Pühajõe küla"/><asula kood="7063" nimi="Roodu küla"/><asula kood="7348" nimi="Saka küla"/><asula kood="7551" nimi="Servaääre küla"/><asula kood="8275" nimi="Toila alevik"/><asula kood="8563" nimi="Täkumetsa küla"/><asula kood="8647" nimi="Uikala küla"/><asula kood="8900" nimi="Vaivina küla"/><asula kood="8914" nimi="Valaste küla"/><asula kood="9432" nimi="Vitsiku küla"/><asula kood="9455" nimi="Voka alevik"/><asula kood="9453" nimi="Voka küla"/></vald></maakond><maakond kood="0050" nimi="Jõgeva maakond"><vald kood="0247" nimi="Jõgeva vald"><asula kood="1185" nimi="Alavere küla"/><asula kood="1533" nimi="Eerikvere küla"/><asula kood="1543" nimi="Ehavere küla"/><asula kood="1582" nimi="Ellakvere küla"/><asula kood="1598" nimi="Endla küla"/><asula kood="1950" nimi="Härjanurme küla"/><asula kood="2079" nimi="Imukvere küla"/><asula kood="2099" nimi="Iravere küla"/><asula kood="2261" nimi="Jõgeva alevik"/><asula kood="2262" nimi="Jõgeva linn"/><asula kood="2284" nimi="Jõune küla"/><asula kood="2360" nimi="Järvepera küla"/><asula kood="2403" nimi="Kaarepere küla"/><asula kood="2436" nimi="Kaave küla"/><asula kood="2495" nimi="Kaera küla"/><asula kood="2523" nimi="Kaiavere küla"/><asula kood="2688" nimi="Kantküla"/><asula kood="2818" nimi="Kassinurme küla"/><asula kood="2819" nimi="Kassivere küla"/><asula kood="2861" nimi="Kaude küla"/><asula kood="3178" nimi="Kivijärve küla"/><asula kood="3188" nimi="Kivimäe küla"/><asula kood="3244" nimi="Kodismaa küla"/><asula kood="3302" nimi="Koimula küla"/><asula kood="3518" nimi="Kudina küla"/><asula kood="3642" nimi="Kuremaa alevik"/><asula kood="3676" nimi="Kurista küla"/><asula kood="3769" nimi="Kõnnu küla"/><asula kood="3778" nimi="Kõola küla"/><asula kood="3894" nimi="Kärde küla"/><asula kood="4078" nimi="Laiuse alevik"/><asula kood="4080" nimi="Laiusevälja küla"/><asula kood="4175" nimi="Leedi küla"/><asula kood="4278" nimi="Lemuvere küla"/><asula kood="4342" nimi="Liikatku küla"/><asula kood="4364" nimi="Liivoja küla"/><asula kood="4367" nimi="Lilastvere küla"/><asula kood="4579" nimi="Luua küla"/><asula kood="4613" nimi="Lõpe küla"/><asula kood="4983" nimi="Mooritsa küla"/><asula kood="5023" nimi="Mullavere küla"/><asula kood="5131" nimi="Mõisamaa küla"/><asula kood="5373" nimi="Nava küla"/><asula kood="5548" nimi="Näduvere küla"/><asula kood="5684" nimi="Ookatku küla"/><asula kood="5756" nimi="Oti küla"/><asula kood="5817" nimi="Paduvere küla"/><asula kood="5870" nimi="Painküla"/><asula kood="5902" nimi="Pakaste küla"/><asula kood="5913" nimi="Palamuse alevik"/><asula kood="5954" nimi="Palupere küla"/><asula kood="6040" nimi="Patjala küla"/><asula kood="6073" nimi="Pedja küla"/><asula kood="6233" nimi="Pikkjärve küla"/><asula kood="6344" nimi="Praaklima küla"/><asula kood="6643" nimi="Pööra küla"/><asula kood="6679" nimi="Raadivere küla"/><asula kood="6684" nimi="Raaduvere küla"/><asula kood="6727" nimi="Rahivere küla"/><asula kood="6834" nimi="Rassiku küla"/><asula kood="6879" nimi="Reastvere küla"/><asula kood="7031" nimi="Rohe küla"/><asula kood="7048" nimi="Ronivere küla"/><asula kood="7232" nimi="Rääbise küla"/><asula kood="7318" nimi="Sadala alevik"/><asula kood="7323" nimi="Saduküla"/><asula kood="7539" nimi="Selli küla"/><asula kood="7573" nimi="Siimusti alevik"/><asula kood="7719" nimi="Soomevere küla"/><asula kood="7762" nimi="Sudiste küla"/><asula kood="7943" nimi="Sätsuvere küla"/><asula kood="7983" nimi="Süvalepa küla"/><asula kood="8174" nimi="Tealama küla"/><asula kood="8188" nimi="Teilma küla"/><asula kood="8295" nimi="Tooma küla"/><asula kood="8318" nimi="Toovere küla"/><asula kood="8331" nimi="Torma alevik"/><asula kood="8404" nimi="Tuimõisa küla"/><asula kood="8480" nimi="Tõikvere küla"/><asula kood="8558" nimi="Tähkvere küla"/><asula kood="8861" nimi="Vaiatu küla"/><asula kood="8872" nimi="Vaidavere küla"/><asula kood="8879" nimi="Vaimastvere küla"/><asula kood="8979" nimi="Vana-Jõgeva küla"/><asula kood="9021" nimi="Vanamõisa küla"/><asula kood="9037" nimi="Vanavälja küla"/><asula kood="9058" nimi="Varbevere küla"/><asula kood="9333" nimi="Vilina küla"/><asula kood="9409" nimi="Viruvere küla"/><asula kood="9431" nimi="Visusti küla"/><asula kood="9489" nimi="Võduvere küla"/><asula kood="9519" nimi="Võidivere küla"/><asula kood="9529" nimi="Võikvere küla"/><asula kood="9615" nimi="Vägeva küla"/><asula kood="9655" nimi="Väljaotsa küla"/><asula kood="9721" nimi="Õuna küla"/><asula kood="9770" nimi="Änkküla"/></vald><vald kood="0486" nimi="Mustvee vald"><asula kood="1087" nimi="Adraku küla"/><asula kood="1191" nimi="Alekere küla"/><asula kood="1481" nimi="Avinurme alevik"/><asula kood="1746" nimi="Halliku küla"/><asula kood="2129" nimi="Jaama küla"/><asula kood="2236" nimi="Jõemetsa küla"/><asula kood="2430" nimi="Kaasiku küla"/><asula kood="2503" nimi="Kaevussaare küla"/><asula kood="2611" nimi="Kallivere küla"/><asula kood="2616" nimi="Kalmaküla"/><asula kood="2800" nimi="Kasepää küla"/><asula kood="3051" nimi="Kiisli küla"/><asula kood="3052" nimi="Kiissa küla"/><asula kood="3467" nimi="Koseveski küla"/><asula kood="3819" nimi="Kõrve küla"/><asula kood="3826" nimi="Kõrvemetsa küla"/><asula kood="3842" nimi="Kõveriku küla"/><asula kood="3884" nimi="Kärasi küla"/><asula kood="7285" nimi="Kääpa küla"/><asula kood="3968" nimi="Kükita küla"/><asula kood="4033" nimi="Laekannu küla"/><asula kood="4287" nimi="Lepiksaare küla"/><asula kood="4308" nimi="Levala küla"/><asula kood="4459" nimi="Lohusuu alevik"/><asula kood="4702" nimi="Maardla küla"/><asula kood="4727" nimi="Maetsma küla"/><asula kood="5052" nimi="Metsaküla"/><asula kood="5097" nimi="Mustvee linn"/><asula kood="5367" nimi="Nautrasi küla"/><asula kood="5430" nimi="Ninasi küla"/><asula kood="5532" nimi="Nõmme küla"/><asula kood="5598" nimi="Odivere küla"/><asula kood="5673" nimi="Omedu küla"/><asula kood="5774" nimi="Paadenurme küla"/><asula kood="6067" nimi="Pedassaare küla"/><asula kood="6174" nimi="Piilsi küla"/><asula kood="6469" nimi="Putu küla"/><asula kood="6589" nimi="Pällu küla"/><asula kood="6682" nimi="Raadna küla"/><asula kood="6764" nimi="Raja küla"/><asula kood="7130" nimi="Ruskavere küla"/><asula kood="7303" nimi="Saarjärve küla"/><asula kood="7544" nimi="Separa küla"/><asula kood="7637" nimi="Sirguvere küla"/><asula kood="7921" nimi="Sälliksaare küla"/><asula kood="8102" nimi="Tammessaare küla"/><asula kood="8117" nimi="Tammispää küla"/><asula kood="8149" nimi="Tarakvere küla"/><asula kood="8210" nimi="Tiheda küla"/><asula kood="8453" nimi="Tuulavere küla"/><asula kood="8664" nimi="Ulvi küla"/><asula kood="8819" nimi="Vadi küla"/><asula kood="9029" nimi="Vanassaare küla"/><asula kood="9116" nimi="Vassevere küla"/><asula kood="9181" nimi="Veia küla"/><asula kood="9364" nimi="Vilusi küla"/><asula kood="9466" nimi="Voore küla"/><asula kood="9596" nimi="Võtikvere küla"/><asula kood="9773" nimi="Änniksaare küla"/></vald><vald kood="0618" nimi="Põltsamaa vald"><asula kood="1076" nimi="Adavere alevik"/><asula kood="1137" nimi="Aidu küla"/><asula kood="1179" nimi="Alastvere küla"/><asula kood="1226" nimi="Altnurga küla"/><asula kood="1293" nimi="Annikvere küla"/><asula kood="1351" nimi="Arisvere küla"/><asula kood="1652" nimi="Esku küla"/><asula kood="2379" nimi="Jüriküla"/><asula kood="2438" nimi="Kaavere küla"/><asula kood="2461" nimi="Kablaküla"/><asula kood="2562" nimi="Kalana küla"/><asula kood="2582" nimi="Kaliküla"/><asula kood="2621" nimi="Kalme küla"/><asula kood="2636" nimi="Kamari alevik"/><asula kood="2875" nimi="Kauru küla"/><asula kood="3132" nimi="Kirikuvalla küla"/><asula kood="3458" nimi="Kose küla"/><asula kood="3624" nimi="Kuningamäe küla"/><asula kood="3693" nimi="Kursi küla"/><asula kood="3779" nimi="Kõpu küla"/><asula kood="3801" nimi="Kõrkküla"/><asula kood="4026" nimi="Laasme küla"/><asula kood="4049" nimi="Lahavere küla"/><asula kood="4170" nimi="Lebavere küla"/><asula kood="4513" nimi="Loopre küla"/><asula kood="4551" nimi="Luige küla"/><asula kood="4567" nimi="Lustivere küla"/><asula kood="5123" nimi="Mõhküla"/><asula kood="5136" nimi="Mõisaküla"/><asula kood="5166" nimi="Mõrtsi küla"/><asula kood="5253" nimi="Mällikvere küla"/><asula kood="5382" nimi="Neanurme küla"/><asula kood="5462" nimi="Nurga küla"/><asula kood="5501" nimi="Nõmavere küla"/><asula kood="5894" nimi="Pajusi küla"/><asula kood="6048" nimi="Pauastvere küla"/><asula kood="6236" nimi="Pikknurme küla"/><asula kood="6262" nimi="Pilu küla"/><asula kood="6280" nimi="Pisisaare küla"/><asula kood="6381" nimi="Pudivere küla"/><asula kood="6385" nimi="Puduküla"/><asula kood="6404" nimi="Puiatu küla"/><asula kood="6479" nimi="Puurmani alevik"/><asula kood="6537" nimi="Põltsamaa linn"/><asula kood="7175" nimi="Rõstla küla"/><asula kood="7220" nimi="Räsna küla"/><asula kood="7753" nimi="Sopimetsa küla"/><asula kood="7798" nimi="Sulustvere küla"/><asula kood="8113" nimi="Tammiku küla"/><asula kood="8141" nimi="Tapiku küla"/><asula kood="8483" nimi="Tõivere küla"/><asula kood="8515" nimi="Tõrenurme küla"/><asula kood="8537" nimi="Tõrve küla"/><asula kood="8674" nimi="Umbusi küla"/><asula kood="8772" nimi="Uuevälja küla"/><asula kood="9437" nimi="Vitsjärve küla"/><asula kood="9486" nimi="Vorsti küla"/><asula kood="9501" nimi="Võhmanõmme küla"/><asula kood="9536" nimi="Võisiku küla"/><asula kood="9612" nimi="Vägari küla"/><asula kood="9621" nimi="Väike-Kamari küla"/><asula kood="9654" nimi="Väljataguse küla"/></vald></maakond><maakond kood="0052" nimi="Järva maakond"><vald kood="0255" nimi="Järva vald"><asula kood="1055" nimi="Abaja küla"/><asula kood="1100" nimi="Ageri küla"/><asula kood="1122" nimi="Ahula küla"/><asula kood="1188" nimi="Albu küla"/><asula kood="1250" nimi="Ambla alevik"/><asula kood="1252" nimi="Ammuta küla"/><asula kood="1326" nimi="Aravete alevik"/><asula kood="1371" nimi="Aruküla"/><asula kood="1441" nimi="Ataste küla"/><asula kood="1567" nimi="Eistvere küla"/><asula kood="1640" nimi="Ervita küla"/><asula kood="1655" nimi="Esna küla"/><asula kood="1825" nimi="Hermani küla"/><asula kood="1920" nimi="Huuksi küla"/><asula kood="2073" nimi="Imavere küla"/><asula kood="2156" nimi="Jalalõpe küla"/><asula kood="2159" nimi="Jalametsa küla"/><asula kood="2164" nimi="Jalgsema küla"/><asula kood="2230" nimi="Jõeküla"/><asula kood="2268" nimi="Jõgisoo küla"/><asula kood="2321" nimi="Järavere küla"/><asula kood="2341" nimi="Järva-Jaani alev"/><asula kood="2343" nimi="Järva-Madise küla"/><asula kood="2395" nimi="Kaalepi küla"/><asula kood="2506" nimi="Kagavere küla"/><asula kood="2339" nimi="Kahala küla"/><asula kood="2591" nimi="Kalitsa küla"/><asula kood="2702" nimi="Kapu küla"/><asula kood="2712" nimi="Kareda küla"/><asula kood="2733" nimi="Karinu küla"/><asula kood="2971" nimi="Keri küla"/><asula kood="3032" nimi="Kiigevere küla"/><asula kood="3255" nimi="Koeru alevik"/><asula kood="3273" nimi="Koidu-Ellavere küla"/><asula kood="3282" nimi="Koigi küla"/><asula kood="3554" nimi="Kukevere küla"/><asula kood="3564" nimi="Kuksema küla"/><asula kood="3673" nimi="Kurisoo küla"/><asula kood="3723" nimi="Kuusna küla"/><asula kood="3886" nimi="Käravete alevik"/><asula kood="3937" nimi="Käsukonna küla"/><asula kood="3960" nimi="Köisi küla"/><asula kood="3992" nimi="Küti küla"/><asula kood="4022" nimi="Laaneotsa küla"/><asula kood="4070" nimi="Laimetsa küla"/><asula kood="4214" nimi="Lehtmetsa küla"/><asula kood="4428" nimi="Liusvere küla"/><asula kood="4626" nimi="Lähevere küla"/><asula kood="4882" nimi="Merja küla"/><asula kood="4927" nimi="Metsla küla"/><asula kood="4936" nimi="Metstaguse küla"/><asula kood="5156" nimi="Mõnuvere küla"/><asula kood="5215" nimi="Mägede küla"/><asula kood="5226" nimi="Mägise küla"/><asula kood="5281" nimi="Märjandi küla"/><asula kood="5322" nimi="Müüsleri küla"/><asula kood="5402" nimi="Neitla küla"/><asula kood="5455" nimi="Norra küla"/><asula kood="5714" nimi="Orgmetsa küla"/><asula kood="6079" nimi="Peedu küla"/><asula kood="6085" nimi="Peetri alevik"/><asula kood="6349" nimi="Prandi küla"/><asula kood="6360" nimi="Preedi küla"/><asula kood="6398" nimi="Puhmu küla"/><asula kood="6402" nimi="Puiatu küla"/><asula kood="6422" nimi="Pullevere küla"/><asula kood="6580" nimi="Päinurme küla"/><asula kood="6583" nimi="Pällastvere küla"/><asula kood="6627" nimi="Pätsavere küla"/><asula kood="6771" nimi="Raka küla"/><asula kood="6780" nimi="Ramma küla"/><asula kood="6870" nimi="Rava küla"/><asula kood="6915" nimi="Reinevere küla"/><asula kood="7081" nimi="Roosna küla"/><asula kood="7135" nimi="Rutikvere küla"/><asula kood="7157" nimi="Rõhu küla"/><asula kood="7399" nimi="Salutaguse küla"/><asula kood="7408" nimi="Santovi küla"/><asula kood="7505" nimi="Seidla küla"/><asula kood="7521" nimi="Seliküla"/><asula kood="7598" nimi="Silmsi küla"/><asula kood="7741" nimi="Soosalu küla"/><asula kood="7770" nimi="Sugalepa küla"/><asula kood="7895" nimi="Sõrandu küla"/><asula kood="7961" nimi="Sääsküla"/><asula kood="7991" nimi="Taadikvere küla"/><asula kood="8097" nimi="Tammeküla"/><asula kood="8110" nimi="Tammiku küla"/><asula kood="8137" nimi="Tamsi küla"/><asula kood="8388" nimi="Tudre küla"/><asula kood="8616" nimi="Udeva küla"/><asula kood="8803" nimi="Vaali küla"/><asula kood="8858" nimi="Vahuküla"/><asula kood="8944" nimi="Valila küla"/><asula kood="9047" nimi="Vao küla"/><asula kood="9243" nimi="Vetepere küla"/><asula kood="9430" nimi="Visusti küla"/><asula kood="9446" nimi="Vodja küla"/><asula kood="9492" nimi="Vuti küla"/><asula kood="9575" nimi="Võrevere küla"/><asula kood="9623" nimi="Väike-Kareda küla"/><asula kood="9638" nimi="Väinjärve küla"/><asula kood="9696" nimi="Õle küla"/><asula kood="9755" nimi="Ämbra küla"/><asula kood="9807" nimi="Öötla küla"/><asula kood="9825" nimi="Ülejõe küla"/></vald><vald kood="0567" nimi="Paide linn"><asula kood="1205" nimi="Allikjärve küla"/><asula kood="1286" nimi="Anna küla"/><asula kood="1570" nimi="Eivere küla"/><asula kood="1653" nimi="Esna küla"/><asula kood="2421" nimi="Kaaruka küla"/><asula kood="3019" nimi="Kihme küla"/><asula kood="3131" nimi="Kirila küla"/><asula kood="3137" nimi="Kirisaare küla"/><asula kood="3229" nimi="Kodasema küla"/><asula kood="3417" nimi="Koordi küla"/><asula kood="3442" nimi="Korba küla"/><asula kood="3497" nimi="Kriilevälja küla"/><asula kood="5083" nimi="Mustla küla"/><asula kood="5090" nimi="Mustla-Nõmme küla"/><asula kood="5193" nimi="Mäeküla"/><asula kood="5275" nimi="Mäo küla"/><asula kood="5317" nimi="Mündi küla"/><asula kood="5466" nimi="Nurme küla"/><asula kood="5474" nimi="Nurmsi küla"/><asula kood="5609" nimi="Oeti küla"/><asula kood="5648" nimi="Ojaküla"/><asula kood="5761" nimi="Otiku küla"/><asula kood="5860" nimi="Paide linn"/><asula kood="6214" nimi="Pikaküla"/><asula kood="6377" nimi="Prääma küla"/><asula kood="6405" nimi="Puiatu küla"/><asula kood="6440" nimi="Purdi küla"/><asula kood="7083" nimi="Roosna-Alliku alevik"/><asula kood="7428" nimi="Sargvere küla"/><asula kood="7508" nimi="Seinapalu küla"/><asula kood="7593" nimi="Sillaotsa küla"/><asula kood="7863" nimi="Suurpalu küla"/><asula kood="7889" nimi="Sõmeru küla"/><asula kood="8152" nimi="Tarbja küla"/><asula kood="8570" nimi="Tännapere küla"/><asula kood="8917" nimi="Valasti küla"/><asula kood="8935" nimi="Valgma küla"/><asula kood="9689" nimi="Vedruka küla"/><asula kood="9227" nimi="Veskiaru küla"/><asula kood="9302" nimi="Viisu küla"/><asula kood="9379" nimi="Viraksaare küla"/><asula kood="9602" nimi="Võõbu küla"/></vald><vald kood="0834" nimi="Türi vald"><asula kood="1042" nimi="Aasuvälja küla"/><asula kood="1359" nimi="Arkma küla"/><asula kood="2228" nimi="Jõeküla"/><asula kood="2315" nimi="Jändja küla"/><asula kood="2445" nimi="Kabala küla"/><asula kood="2510" nimi="Kahala küla"/><asula kood="5144" nimi="Karjaküla"/><asula kood="3148" nimi="Kirna küla"/><asula kood="3364" nimi="Kolu küla"/><asula kood="3600" nimi="Kullimaa küla"/><asula kood="3684" nimi="Kurla küla"/><asula kood="3735" nimi="Kõdu küla"/><asula kood="3854" nimi="Kädva küla"/><asula kood="3875" nimi="Kändliku küla"/><asula kood="3899" nimi="Kärevere küla"/><asula kood="3933" nimi="Käru alevik"/><asula kood="4153" nimi="Laupa küla"/><asula kood="4157" nimi="Lauri küla"/><asula kood="4475" nimi="Lokuta küla"/><asula kood="4560" nimi="Lungu küla"/><asula kood="4623" nimi="Lõõla küla"/><asula kood="4873" nimi="Meossaare küla"/><asula kood="4897" nimi="Metsaküla"/><asula kood="5197" nimi="Mäeküla"/><asula kood="5562" nimi="Näsuvere küla"/><asula kood="5641" nimi="Oisu alevik"/><asula kood="5666" nimi="Ollepa küla"/><asula kood="5906" nimi="Pala küla"/><asula kood="6134" nimi="Pibari küla"/><asula kood="6206" nimi="Piiumetsa küla"/><asula kood="6300" nimi="Poaka küla"/><asula kood="6505" nimi="Põikva küla"/><asula kood="6831" nimi="Rassi küla"/><asula kood="6863" nimi="Raukla küla"/><asula kood="6940" nimi="Reopalu küla"/><asula kood="6948" nimi="Retla küla"/><asula kood="6995" nimi="Rikassaare küla"/><asula kood="7095" nimi="Roovere küla"/><asula kood="7254" nimi="Röa küla"/><asula kood="7293" nimi="Saareotsa küla"/><asula kood="7332" nimi="Sagevere küla"/><asula kood="7452" nimi="Saueaugu küla"/><asula kood="7683" nimi="Sonni küla"/><asula kood="7935" nimi="Särevere alevik"/><asula kood="8080" nimi="Taikse küla"/><asula kood="8325" nimi="Tori küla"/><asula kood="8573" nimi="Tännassilma küla"/><asula kood="8595" nimi="Türi linn"/><asula kood="8596" nimi="Türi-Alliku küla"/><asula kood="9336" nimi="Vilita küla"/><asula kood="9352" nimi="Villevere küla"/><asula kood="9425" nimi="Vissuvere küla"/><asula kood="9653" nimi="Väljaotsa küla"/><asula kood="9656" nimi="Väljataguse küla"/><asula kood="9690" nimi="Väätsa alevik"/><asula kood="9741" nimi="Äiamaa küla"/><asula kood="9762" nimi="Änari küla"/><asula kood="9828" nimi="Ülejõe küla"/></vald></maakond><maakond kood="0056" nimi="Lääne maakond"><vald kood="0184" nimi="Haapsalu linn"><asula kood="1017" nimi="Aamse küla"/><asula kood="1201" nimi="Allika küla"/><asula kood="1251" nimi="Ammuta küla"/><asula kood="1592" nimi="Emmuvere küla"/><asula kood="1624" nimi="Erja küla"/><asula kood="1658" nimi="Espre küla"/><asula kood="1692" nimi="Haapsalu linn"/><asula kood="1711" nimi="Haeska küla"/><asula kood="1824" nimi="Herjava küla"/><asula kood="1875" nimi="Hobulaiu küla"/><asula kood="2285" nimi="Jõõdre küla"/><asula kood="2466" nimi="Kabrametsa küla"/><asula kood="2472" nimi="Kadaka küla"/><asula kood="2497" nimi="Kaevere küla"/><asula kood="3027" nimi="Kiideva küla"/><asula kood="3090" nimi="Kiltsi küla"/><asula kood="3171" nimi="Kiviküla"/><asula kood="3276" nimi="Koheri küla"/><asula kood="3281" nimi="Koidu küla"/><asula kood="3341" nimi="Kolila küla"/><asula kood="3361" nimi="Kolu küla"/><asula kood="3849" nimi="Käpla küla"/><asula kood="4063" nimi="Laheva küla"/><asula kood="4102" nimi="Lannuste küla"/><asula kood="4351" nimi="Liivaküla"/><asula kood="4426" nimi="Litu küla"/><asula kood="4592" nimi="Lõbe küla"/><asula kood="4883" nimi="Metsaküla"/><asula kood="5186" nimi="Mäeküla"/><asula kood="5216" nimi="Mägari küla"/><asula kood="5527" nimi="Nõmme küla"/><asula kood="5971" nimi="Panga küla"/><asula kood="5989" nimi="Paralepa alevik"/><asula kood="6959" nimi="Parila küla"/><asula kood="6403" nimi="Puiatu küla"/><asula kood="6413" nimi="Puise küla"/><asula kood="6462" nimi="Pusku küla"/><asula kood="6496" nimi="Põgari-Sassi küla"/><asula kood="7029" nimi="Rohense küla"/><asula kood="7036" nimi="Rohuküla"/><asula kood="7120" nimi="Rummu küla"/><asula kood="7275" nimi="Saanika küla"/><asula kood="7283" nimi="Saardu küla"/><asula kood="7540" nimi="Sepaküla"/><asula kood="7606" nimi="Sinalepa küla"/><asula kood="1119" nimi="Suure-Ahli küla"/><asula kood="8116" nimi="Tammiku küla"/><asula kood="8321" nimi="Tanska küla"/><asula kood="8465" nimi="Tuuru küla"/><asula kood="8690" nimi="Uneste küla"/><asula kood="8769" nimi="Uuemõisa alevik"/><asula kood="8768" nimi="Uuemõisa küla"/><asula kood="8929" nimi="Valgevälja küla"/><asula kood="9091" nimi="Varni küla"/><asula kood="9343" nimi="Vilkla küla"/><asula kood="9568" nimi="Võnnu küla"/><asula kood="9616" nimi="Väike-Ahli küla"/><asula kood="9673" nimi="Vätse küla"/><asula kood="9853" nimi="Üsse küla"/></vald><vald kood="0441" nimi="Lääne-Nigula vald"><asula kood="1210" nimi="Allikmaa küla"/><asula kood="1209" nimi="Allikotsa küla"/><asula kood="1447" nimi="Auaste küla"/><asula kood="1469" nimi="Aulepa küla / Dirslätt"/><asula kood="1505" nimi="Dirhami küla / Derhamn"/><asula kood="1546" nimi="Ehmja küla"/><asula kood="1556" nimi="Einbi küla / Enby"/><asula kood="1571" nimi="Elbiku küla / Ölbäck"/><asula kood="1600" nimi="Enivere küla"/><asula kood="1760" nimi="Hara küla / Harga"/><asula kood="1852" nimi="Hindaste küla"/><asula kood="1889" nimi="Hosby küla"/><asula kood="1964" nimi="Höbringi küla / Höbring"/><asula kood="2084" nimi="Ingküla"/><asula kood="2126" nimi="Jaakna küla"/><asula kood="2166" nimi="Jalukse küla"/><asula kood="2246" nimi="Jõesse küla"/><asula kood="2266" nimi="Jõgisoo küla"/><asula kood="2399" nimi="Kaare küla"/><asula kood="2426" nimi="Kaasiku küla"/><asula kood="2446" nimi="Kabeli küla"/><asula kood="2479" nimi="Kadarpiku küla"/><asula kood="2593" nimi="Kalju küla"/><asula kood="2787" nimi="Kasari küla"/><asula kood="2826" nimi="Kastja küla"/><asula kood="2904" nimi="Kedre küla"/><asula kood="2906" nimi="Keedika küla"/><asula kood="2958" nimi="Keravere küla"/><asula kood="2983" nimi="Keskküla"/><asula kood="2977" nimi="Keskvere küla"/><asula kood="2991" nimi="Kesu küla"/><asula kood="3135" nimi="Kirimäe küla"/><asula kood="3147" nimi="Kirna küla"/><asula kood="3247" nimi="Koela küla"/><asula kood="3321" nimi="Kokre küla"/><asula kood="3366" nimi="Koluvere küla"/><asula kood="3514" nimi="Kudani küla / Gutanäs"/><asula kood="3539" nimi="Kuijõe küla"/><asula kood="3551" nimi="Kuke küla"/><asula kood="3587" nimi="Kullamaa küla"/><asula kood="3590" nimi="Kullametsa küla"/><asula kood="3605" nimi="Kuluse küla"/><asula kood="3665" nimi="Kurevere küla"/><asula kood="3889" nimi="Kärbla küla"/><asula kood="4068" nimi="Laiküla"/><asula kood="4178" nimi="Leediküla"/><asula kood="4230" nimi="Leila küla"/><asula kood="4271" nimi="Lemmikküla"/><asula kood="4350" nimi="Liivaküla"/><asula kood="4361" nimi="Liivi küla"/><asula kood="4400" nimi="Linnamäe küla"/><asula kood="4553" nimi="Luigu küla"/><asula kood="4796" nimi="Martna küla"/><asula kood="5143" nimi="Mõisaküla"/><asula kood="5165" nimi="Mõrdu küla"/><asula kood="5259" nimi="Männiku küla"/><asula kood="5407" nimi="Nigula küla"/><asula kood="5413" nimi="Nihka küla"/><asula kood="5415" nimi="Niibi küla"/><asula kood="5419" nimi="Niinja küla"/><asula kood="5526" nimi="Nõmme küla"/><asula kood="5513" nimi="Nõmmemaa küla"/><asula kood="5543" nimi="Nõva küla"/><asula kood="5626" nimi="Ohtla küla"/><asula kood="5693" nimi="Oonga küla"/><asula kood="5737" nimi="Oru küla"/><asula kood="5743" nimi="Osmussaare küla / Odensholm"/><asula kood="5926" nimi="Palivere alevik"/><asula kood="6029" nimi="Paslepa küla / Pasklep"/><asula kood="6109" nimi="Peraküla"/><asula kood="6191" nimi="Piirsalu küla"/><asula kood="6464" nimi="Putkaste küla"/><asula kood="6586" nimi="Pälli küla"/><asula kood="6599" nimi="Päri küla"/><asula kood="6669" nimi="Pürksi küla / Birkas"/><asula kood="6805" nimi="Rannajõe küla"/><asula kood="6808" nimi="Rannaküla"/><asula kood="6904" nimi="Rehemäe küla"/><asula kood="6968" nimi="Riguldi küla / Rickul"/><asula kood="7011" nimi="Risti alevik"/><asula kood="7077" nimi="Rooslepa küla / Roslep"/><asula kood="7178" nimi="Rõude küla"/><asula kood="7183" nimi="Rõuma küla"/><asula kood="7284" nimi="Saare küla / Lyckholm"/><asula kood="7369" nimi="Salajõe küla"/><asula kood="7465" nimi="Saunja küla"/><asula kood="7534" nimi="Seljaküla"/><asula kood="7589" nimi="Silla küla"/><asula kood="7682" nimi="Soo-otsa küla"/><asula kood="7709" nimi="Soolu küla"/><asula kood="7760" nimi="Spithami küla / Spithamn"/><asula kood="7817" nimi="Sutlepa küla / Sutlep"/><asula kood="7829" nimi="Suur-Nõmmküla / Klottorp"/><asula kood="7832" nimi="Suure-Lähtru küla"/><asula kood="8025" nimi="Taebla alevik"/><asula kood="8058" nimi="Tagavere küla"/><asula kood="8074" nimi="Tahu küla / Skåtanäs"/><asula kood="8106" nimi="Tammiku küla"/><asula kood="8187" nimi="Telise küla / Tällnäs"/><asula kood="8405" nimi="Tuka küla"/><asula kood="8409" nimi="Tuksi küla / Bergsby"/><asula kood="8434" nimi="Turvalepa küla"/><asula kood="8437" nimi="Tusari küla"/><asula kood="8607" nimi="Ubasalu küla"/><asula kood="8776" nimi="Uugla küla"/><asula kood="8785" nimi="Uusküla"/><asula kood="8890" nimi="Vaisi küla"/><asula kood="9017" nimi="Vanaküla"/><asula kood="9011" nimi="Vanaküla / Gambyn"/><asula kood="9083" nimi="Variku küla"/><asula kood="9156" nimi="Vedra küla"/><asula kood="9254" nimi="Vidruka küla"/><asula kood="9572" nimi="Võntküla"/><asula kood="4632" nimi="Väike-Lähtru küla"/><asula kood="5523" nimi="Väike-Nõmmküla / Persåker"/><asula kood="9686" nimi="Väänla küla"/><asula kood="9803" nimi="Österby küla"/><asula kood="9812" nimi="Üdruma küla"/></vald><vald kood="0907" nimi="Vormsi vald"><asula kood="1493" nimi="Borrby küla"/><asula kood="1502" nimi="Diby küla"/><asula kood="1662" nimi="Fällarna küla"/><asula kood="1670" nimi="Förby küla"/><asula kood="1892" nimi="Hosby küla"/><asula kood="1900" nimi="Hullo küla"/><asula kood="2981" nimi="Kersleti küla"/><asula kood="5453" nimi="Norrby küla"/><asula kood="7124" nimi="Rumpo küla"/><asula kood="7205" nimi="Rälby küla"/><asula kood="7502" nimi="Saxby küla"/><asula kood="7845" nimi="Suuremõisa küla"/><asula kood="7875" nimi="Sviby küla"/><asula kood="7971" nimi="Söderby küla"/></vald></maakond><maakond kood="0060" nimi="Lääne-Viru maakond"><vald kood="0191" nimi="Haljala vald"><asula kood="1032" nimi="Aaspere küla"/><asula kood="1035" nimi="Aasu küla"/><asula kood="1040" nimi="Aasumetsa küla"/><asula kood="1051" nimi="Aaviku küla"/><asula kood="1073" nimi="Adaka küla"/><asula kood="1218" nimi="Altja küla"/><asula kood="1255" nimi="Andi küla"/><asula kood="1294" nimi="Annikvere küla"/><asula kood="1463" nimi="Auküla"/><asula kood="1562" nimi="Eisma küla"/><asula kood="1637" nimi="Eru küla"/><asula kood="1661" nimi="Essu küla"/><asula kood="1723" nimi="Haili küla"/><asula kood="1739" nimi="Haljala alevik"/><asula kood="1986" nimi="Idavere küla"/><asula kood="2059" nimi="Ilumäe küla"/><asula kood="2191" nimi="Joandu küla"/><asula kood="2558" nimi="Kakuvälja küla"/><asula kood="2664" nimi="Kandle küla"/><asula kood="2715" nimi="Karepa küla"/><asula kood="2774" nimi="Karula küla"/><asula kood="2896" nimi="Kavastu küla"/><asula kood="3161" nimi="Kisuvere küla"/><asula kood="3173" nimi="Kiva küla"/><asula kood="3345" nimi="Koljaku küla"/><asula kood="3401" nimi="Koolimäe küla"/><asula kood="3449" nimi="Korjuse küla"/><asula kood="3473" nimi="Kosta küla"/><asula kood="3754" nimi="Kõldu küla"/><asula kood="3918" nimi="Kärmu küla"/><asula kood="3934" nimi="Käsmu küla"/><asula kood="4052" nimi="Lahe küla"/><asula kood="4151" nimi="Lauli küla"/><asula kood="4331" nimi="Lihulõpe küla"/><asula kood="4337" nimi="Liiguste küla"/><asula kood="4437" nimi="Lobi küla"/><asula kood="4905" nimi="Metsanurga küla"/><asula kood="4918" nimi="Metsiku küla"/><asula kood="5009" nimi="Muike küla"/><asula kood="5091" nimi="Mustoja küla"/><asula kood="5364" nimi="Natturi küla"/><asula kood="5442" nimi="Noonu küla"/><asula kood="5575" nimi="Oandu küla"/><asula kood="5786" nimi="Paasi küla"/><asula kood="5899" nimi="Pajuveski küla"/><asula kood="5936" nimi="Palmse küla"/><asula kood="6068" nimi="Pedassaare küla"/><asula kood="6093" nimi="Pehka küla"/><asula kood="6148" nimi="Pihlaspea küla"/><asula kood="6493" nimi="Põdruse küla"/><asula kood="7138" nimi="Rutja küla"/><asula kood="7329" nimi="Sagadi küla"/><asula kood="7366" nimi="Sakussaare küla"/><asula kood="7374" nimi="Salatse küla"/><asula kood="7468" nimi="Sauste küla"/><asula kood="8167" nimi="Tatruse küla"/><asula kood="8195" nimi="Tepelvälja küla"/><asula kood="8178" nimi="Tidriku küla"/><asula kood="8222" nimi="Tiigi küla"/><asula kood="8293" nimi="Toolse küla"/><asula kood="8543" nimi="Tõugu küla"/><asula kood="8787" nimi="Uusküla"/><asula kood="8888" nimi="Vainupea küla"/><asula kood="9024" nimi="Vanamõisa küla"/><asula kood="2779" nimi="Varangu küla"/><asula kood="9139" nimi="Vatku küla"/><asula kood="9213" nimi="Vergi küla"/><asula kood="9270" nimi="Vihula küla"/><asula kood="9321" nimi="Vila küla"/><asula kood="9350" nimi="Villandi küla"/><asula kood="9498" nimi="Võhma küla"/><asula kood="9552" nimi="Võle küla"/><asula kood="9592" nimi="Võsu alevik"/><asula kood="9593" nimi="Võsupere küla"/></vald><vald kood="0272" nimi="Kadrina vald"><asula kood="1245" nimi="Ama küla"/><asula kood="1334" nimi="Arbavere küla"/><asula kood="1897" nimi="Hulja alevik"/><asula kood="1924" nimi="Hõbeda küla"/><asula kood="1947" nimi="Härjadi küla"/><asula kood="2245" nimi="Jõepere küla"/><asula kood="2253" nimi="Jõetaguse küla"/><asula kood="2380" nimi="Jürimõisa küla"/><asula kood="2476" nimi="Kadapiku küla"/><asula kood="2490" nimi="Kadrina alevik"/><asula kood="2614" nimi="Kallukse küla"/><asula kood="3017" nimi="Kihlevere küla"/><asula kood="3074" nimi="Kiku küla"/><asula kood="3362" nimi="Kolu küla"/><asula kood="3823" nimi="Kõrveküla"/><asula kood="4106" nimi="Lante küla"/><asula kood="4224" nimi="Leikude küla"/><asula kood="4498" nimi="Loobu küla"/><asula kood="4641" nimi="Läsna küla"/><asula kood="5147" nimi="Mõndavere küla"/><asula kood="5276" nimi="Mäo küla"/><asula kood="5395" nimi="Neeruti küla"/><asula kood="5620" nimi="Ohepalu küla"/><asula kood="5741" nimi="Orutaguse küla"/><asula kood="6004" nimi="Pariisi küla"/><asula kood="6507" nimi="Põima küla"/><asula kood="6953" nimi="Ridaküla"/><asula kood="7164" nimi="Rõmeda küla"/><asula kood="7376" nimi="Salda küla"/><asula kood="7456" nimi="Saukse küla"/><asula kood="7747" nimi="Sootaguse küla"/><asula kood="8254" nimi="Tirbiku küla"/><asula kood="8278" nimi="Tokolopi küla"/><asula kood="8622" nimi="Udriku küla"/><asula kood="8651" nimi="Uku küla"/><asula kood="8688" nimi="Undla küla"/><asula kood="8860" nimi="Vaiatu küla"/><asula kood="9043" nimi="Vandu küla"/><asula kood="9311" nimi="Viitna küla"/><asula kood="9449" nimi="Vohnja küla"/><asula kood="9490" nimi="Võduvere küla"/><asula kood="9534" nimi="Võipere küla"/></vald><vald kood="0663" nimi="Rakvere linn"/><vald kood="0661" nimi="Rakvere vald"><asula kood="1242" nimi="Aluvere küla"/><asula kood="1259" nimi="Andja küla"/><asula kood="1345" nimi="Aresi küla"/><asula kood="1362" nimi="Arkna küla"/><asula kood="1536" nimi="Eesküla"/><asula kood="2332" nimi="Järni küla"/><asula kood="2373" nimi="Jäätma küla"/><asula kood="2405" nimi="Kaarli küla"/><asula kood="2741" nimi="Karitsa küla"/><asula kood="2744" nimi="Karivärava küla"/><asula kood="2781" nimi="Karunga küla"/><asula kood="2853" nimi="Katela küla"/><asula kood="2851" nimi="Katku küla"/><asula kood="3202" nimi="Kloodi küla"/><asula kood="3263" nimi="Kohala küla"/><asula kood="3261" nimi="Kohala-Eesküla"/><asula kood="3432" nimi="Koovälja küla"/><asula kood="3582" nimi="Kullaaru küla"/><asula kood="3790" nimi="Kõrgemäe küla"/><asula kood="4123" nimi="Lasila küla"/><asula kood="4294" nimi="Lepna alevik"/><asula kood="4309" nimi="Levala küla"/><asula kood="5055" nimi="Muru küla"/><asula kood="5182" nimi="Mädapea küla"/><asula kood="5478" nimi="Nurme küla"/><asula kood="5554" nimi="Näpi alevik"/><asula kood="5796" nimi="Paatna küla"/><asula kood="5979" nimi="Papiaru küla"/><asula kood="6567" nimi="Päide küla"/><asula kood="6726" nimi="Rahkla küla"/><asula kood="6850" nimi="Raudlepa küla"/><asula kood="6860" nimi="Raudvere küla"/><asula kood="7058" nimi="Roodevälja küla"/><asula kood="7199" nimi="Rägavere küla"/><asula kood="7684" nimi="Sooaluse küla"/><asula kood="7892" nimi="Sõmeru alevik"/><asula kood="7927" nimi="Sämi küla"/><asula kood="7925" nimi="Sämi-Tagaküla"/><asula kood="8001" nimi="Taaravainu küla"/><asula kood="8261" nimi="Tobia küla"/><asula kood="8304" nimi="Toomla küla"/><asula kood="8520" nimi="Tõrma küla"/><asula kood="8525" nimi="Tõrremäe küla"/><asula kood="8610" nimi="Ubja küla"/><asula kood="8637" nimi="Uhtna alevik"/><asula kood="8740" nimi="Ussimäe küla"/><asula kood="8822" nimi="Vaeküla"/><asula kood="9099" nimi="Varudi-Altküla"/><asula kood="9098" nimi="Varudi-Vanaküla"/><asula kood="9196" nimi="Veltsi küla"/><asula kood="9495" nimi="Võhma küla"/></vald><vald kood="0792" nimi="Tapa vald"><asula kood="1048" nimi="Aavere küla"/><asula kood="1235" nimi="Alupere küla"/><asula kood="1315" nimi="Araski küla"/><asula kood="1410" nimi="Assamalla küla"/><asula kood="2068" nimi="Imastu küla"/><asula kood="2199" nimi="Jootme küla"/><asula kood="2318" nimi="Jäneda küla"/><asula kood="2334" nimi="Järsi küla"/><asula kood="2345" nimi="Järvajõe küla"/><asula kood="2482" nimi="Kadapiku küla"/><asula kood="2500" nimi="Kaeva küla"/><asula kood="2762" nimi="Karkuse küla"/><asula kood="2970" nimi="Kerguta küla"/><asula kood="3288" nimi="Koiduküla"/><asula kood="3438" nimi="Koplitaguse küla"/><asula kood="3531" nimi="Kuie küla"/><asula kood="3592" nimi="Kullenga küla"/><asula kood="3694" nimi="Kursi küla"/><asula kood="3702" nimi="Kuru küla"/><asula kood="3822" nimi="Kõrveküla"/><asula kood="4217" nimi="Lehtse alevik"/><asula kood="4273" nimi="Lemmküla"/><asula kood="4403" nimi="Linnape küla"/><asula kood="4470" nimi="Loksa küla"/><asula kood="4473" nimi="Loksu küla"/><asula kood="4474" nimi="Lokuta küla"/><asula kood="4638" nimi="Läpi küla"/><asula kood="4644" nimi="Läste küla"/><asula kood="4920" nimi="Metskaevu küla"/><asula kood="4963" nimi="Moe küla"/><asula kood="5352" nimi="Naistevälja küla"/><asula kood="5525" nimi="Nõmmküla"/><asula kood="5551" nimi="Näo küla"/><asula kood="6037" nimi="Patika küla"/><asula kood="6177" nimi="Piilu küla"/><asula kood="6204" nimi="Piisupi küla"/><asula kood="6333" nimi="Porkuni küla"/><asula kood="6374" nimi="Pruuna küla"/><asula kood="6491" nimi="Põdrangu küla"/><asula kood="6703" nimi="Rabasaare küla"/><asula kood="6847" nimi="Raudla küla"/><asula kood="7198" nimi="Rägavere küla"/><asula kood="7221" nimi="Räsna küla"/><asula kood="7343" nimi="Saiakopli küla"/><asula kood="7358" nimi="Saksi küla"/><asula kood="7476" nimi="Sauvälja küla"/><asula kood="7481" nimi="Savalduma küla"/><asula kood="7956" nimi="Sääse alevik"/><asula kood="8130" nimi="Tamsalu linn"/><asula kood="8140" nimi="Tapa linn"/><asula kood="8549" nimi="Tõõrakõrve küla"/><asula kood="8604" nimi="Türje küla"/><asula kood="8754" nimi="Uudeküla"/><asula kood="8820" nimi="Vadiküla"/><asula kood="8836" nimi="Vahakulmu küla"/><asula kood="8903" nimi="Vajangu küla"/><asula kood="9429" nimi="Vistla küla"/><asula kood="9505" nimi="Võhmetu küla"/><asula kood="9506" nimi="Võhmuta küla"/></vald><vald kood="0901" nimi="Vinni vald"><asula kood="1025" nimi="Aarla küla"/><asula kood="1043" nimi="Aasuvälja küla"/><asula kood="1182" nimi="Alavere küla"/><asula kood="1193" nimi="Alekvere küla"/><asula kood="1203" nimi="Allika küla"/><asula kood="1275" nimi="Anguse küla"/><asula kood="1331" nimi="Aravuse küla"/><asula kood="1370" nimi="Arukse küla"/><asula kood="1372" nimi="Aruküla"/><asula kood="1395" nimi="Aruvälja küla"/><asula kood="2036" nimi="Ilistvere küla"/><asula kood="2090" nimi="Inju küla"/><asula kood="2424" nimi="Kaasiksaare küla"/><asula kood="2484" nimi="Kadila küla"/><asula kood="2555" nimi="Kakumäe küla"/><asula kood="2679" nimi="Kannastiku küla"/><asula kood="2689" nimi="Kantküla"/><asula kood="2760" nimi="Karkuse küla"/><asula kood="2872" nimi="Kaukvere küla"/><asula kood="2919" nimi="Kehala küla"/><asula kood="2941" nimi="Kellavere küla"/><asula kood="3252" nimi="Koeravere küla"/><asula kood="3577" nimi="Kulina küla"/><asula kood="3809" nimi="Kõrma küla"/><asula kood="3994" nimi="Küti küla"/><asula kood="4035" nimi="Laekvere alevik"/><asula kood="4166" nimi="Lavi küla"/><asula kood="4293" nimi="Lepiku küla"/><asula kood="4589" nimi="Luusika küla"/><asula kood="4634" nimi="Lähtse küla"/><asula kood="4948" nimi="Miila küla"/><asula kood="4978" nimi="Moora küla"/><asula kood="5105" nimi="Muuga küla"/><asula kood="5114" nimi="Mõdriku küla"/><asula kood="5117" nimi="Mõedaka küla"/><asula kood="5212" nimi="Mäetaguse küla"/><asula kood="5267" nimi="Männikvälja küla"/><asula kood="5465" nimi="Nurkse küla"/><asula kood="5471" nimi="Nurmetu küla"/><asula kood="5521" nimi="Nõmmise küla"/><asula kood="5585" nimi="Obja küla"/><asula kood="5794" nimi="Paasvere küla"/><asula kood="5814" nimi="Padu küla"/><asula kood="5896" nimi="Pajusti alevik"/><asula kood="5923" nimi="Palasi küla"/><asula kood="6182" nimi="Piira küla"/><asula kood="6416" nimi="Puka küla"/><asula kood="6535" nimi="Põlula küla"/><asula kood="6729" nimi="Rahkla küla"/><asula kood="6768" nimi="Rajaküla"/><asula kood="6829" nimi="Rasivere küla"/><asula kood="7012" nimi="Ristiküla"/><asula kood="7028" nimi="Roela alevik"/><asula kood="7034" nimi="Rohu küla"/><asula kood="7262" nimi="Rünga küla"/><asula kood="7278" nimi="Saara küla"/><asula kood="7325" nimi="Sae küla"/><asula kood="7401" nimi="Salutaguse küla"/><asula kood="7630" nimi="Sirevere küla"/><asula kood="7733" nimi="Soonuka küla"/><asula kood="7748" nimi="Sootaguse küla"/><asula kood="7777" nimi="Suigu küla"/><asula kood="8108" nimi="Tammiku küla"/><asula kood="8390" nimi="Tudu alevik"/><asula kood="8661" nimi="Uljaste küla"/><asula kood="8665" nimi="Ulvi küla"/><asula kood="9009" nimi="Vana-Vinni küla"/><asula kood="9118" nimi="Vassivere küla"/><asula kood="9153" nimi="Veadla küla"/><asula kood="9204" nimi="Venevere küla"/><asula kood="9245" nimi="Vetiku küla"/><asula kood="9375" nimi="Vinni alevik"/><asula kood="9394" nimi="Viru-Jaagupi alevik"/><asula kood="9395" nimi="Viru-Kabala küla"/><asula kood="9467" nimi="Voore küla"/><asula kood="9508" nimi="Võhu küla"/></vald><vald kood="0903" nimi="Viru-Nigula vald"><asula kood="1037" nimi="Aasukalda küla"/><asula kood="1402" nimi="Aseri alevik"/><asula kood="1405" nimi="Aseriaru küla"/><asula kood="2019" nimi="Iila küla"/><asula kood="2447" nimi="Kabeli küla"/><asula kood="2583" nimi="Kaliküla"/><asula kood="2626" nimi="Kalvi küla"/><asula kood="2675" nimi="Kanguristi küla"/><asula kood="2986" nimi="Kestla küla"/><asula kood="3179" nimi="Kiviküla"/><asula kood="3295" nimi="Koila küla"/><asula kood="3394" nimi="Koogu küla"/><asula kood="3610" nimi="Kunda küla"/><asula kood="3612" nimi="Kunda linn"/><asula kood="3688" nimi="Kurna küla"/><asula kood="3709" nimi="Kutsala küla"/><asula kood="3725" nimi="Kuura küla"/><asula kood="3803" nimi="Kõrkküla"/><asula kood="3814" nimi="Kõrtsialuse küla"/><asula kood="4305" nimi="Letipea küla"/><asula kood="4408" nimi="Linnuse küla"/><asula kood="4736" nimi="Mahu küla"/><asula kood="4755" nimi="Malla küla"/><asula kood="4786" nimi="Marinu küla"/><asula kood="4926" nimi="Metsavälja küla"/><asula kood="5456" nimi="Nugeri küla"/><asula kood="5651" nimi="Ojaküla"/><asula kood="5739" nimi="Oru küla"/><asula kood="5791" nimi="Paasküla"/><asula kood="5804" nimi="Pada küla"/><asula kood="5802" nimi="Pada-Aruküla"/><asula kood="6219" nimi="Pikaristi küla"/><asula kood="6612" nimi="Pärna küla"/><asula kood="6821" nimi="Rannu küla"/><asula kood="7407" nimi="Samma küla"/><asula kood="7530" nimi="Selja küla"/><asula kood="7557" nimi="Siberi küla"/><asula kood="7602" nimi="Simunamäe küla"/><asula kood="8303" nimi="Toomika küla"/><asula kood="8602" nimi="Tüükri küla"/><asula kood="8704" nimi="Unukse küla"/><asula kood="9096" nimi="Varudi küla"/><asula kood="9121" nimi="Vasta küla"/><asula kood="9351" nimi="Villavere küla"/><asula kood="9399" nimi="Viru-Nigula alevik"/><asula kood="9578" nimi="Võrkla küla"/></vald><vald kood="0928" nimi="Väike-Maarja vald"><asula kood="1047" nimi="Aavere küla"/><asula kood="1069" nimi="Aburi küla"/><asula kood="1309" nimi="Ao küla"/><asula kood="1476" nimi="Avanduse küla"/><asula kood="1484" nimi="Avispea küla"/><asula kood="1521" nimi="Ebavere küla"/><asula kood="1529" nimi="Edru küla"/><asula kood="1559" nimi="Eipri küla"/><asula kood="1594" nimi="Emumäe küla"/><asula kood="1866" nimi="Hirla küla"/><asula kood="2080" nimi="Imukvere küla"/><asula kood="2371" nimi="Jäätma küla"/><asula kood="2437" nimi="Kaavere küla"/><asula kood="2480" nimi="Kadiküla"/><asula kood="2635" nimi="Kamariku küla"/><asula kood="2934" nimi="Kellamäe küla"/><asula kood="3092" nimi="Kiltsi alevik"/><asula kood="3162" nimi="Kitsemetsa küla"/><asula kood="3297" nimi="Koila küla"/><asula kood="3367" nimi="Koluvere küla"/><asula kood="3410" nimi="Koonu küla"/><asula kood="3692" nimi="Kurtna küla"/><asula kood="3783" nimi="Kõpsta küla"/><asula kood="3878" nimi="Kännuküla"/><asula kood="3924" nimi="Kärsa küla"/><asula kood="3932" nimi="Käru küla"/><asula kood="4065" nimi="Lahu küla"/><asula kood="4091" nimi="Lammasküla"/><asula kood="4125" nimi="Lasinurme küla"/><asula kood="4339" nimi="Liigvalla küla"/><asula kood="4356" nimi="Liivaküla"/><asula kood="5132" nimi="Mõisamaa küla"/><asula kood="5235" nimi="Mäiste küla"/><asula kood="5295" nimi="Määri küla"/><asula kood="5320" nimi="Müüriku küla"/><asula kood="5333" nimi="Nadalama küla"/><asula kood="5508" nimi="Nõmme küla"/><asula kood="5529" nimi="Nõmmküla"/><asula kood="5661" nimi="Olju küla"/><asula kood="5716" nimi="Orguse küla"/><asula kood="5805" nimi="Padaküla"/><asula kood="5970" nimi="Pandivere küla"/><asula kood="6158" nimi="Piibe küla"/><asula kood="6230" nimi="Pikevere küla"/><asula kood="6382" nimi="Pudivere küla"/><asula kood="6716" nimi="Raeküla"/><asula kood="6756" nimi="Raigu küla"/><asula kood="6775" nimi="Rakke alevik"/><asula kood="6836" nimi="Rastla küla"/><asula kood="7202" nimi="Räitsvere küla"/><asula kood="7385" nimi="Salla küla"/><asula kood="7412" nimi="Sandimetsa küla"/><asula kood="7603" nimi="Simuna alevik"/><asula kood="7746" nimi="Sootaguse küla"/><asula kood="7831" nimi="Suure-Rakke küla"/><asula kood="8115" nimi="Tammiku küla"/><asula kood="8348" nimi="Triigi küla"/><asula kood="8770" nimi="Uuemõisa küla"/><asula kood="9048" nimi="Vao küla"/><asula kood="9056" nimi="Varangu küla"/><asula kood="9347" nimi="Villakvere küla"/><asula kood="9485" nimi="Vorsti küla"/><asula kood="9549" nimi="Võivere küla"/><asula kood="9628" nimi="Väike-Maarja alevik"/><asula kood="9647" nimi="Väike-Rakke küla"/><asula kood="9648" nimi="Väike-Tammiku küla"/><asula kood="9777" nimi="Äntu küla"/><asula kood="9783" nimi="Ärina küla"/></vald></maakond><maakond kood="0064" nimi="Põlva maakond"><vald kood="0284" nimi="Kanepi vald"><asula kood="1058" nimi="Abissaare küla"/><asula kood="1131" nimi="Aiaste küla"/><asula kood="1620" nimi="Erastvere küla"/><asula kood="1785" nimi="Hauka küla"/><asula kood="1799" nimi="Heisri küla"/><asula kood="1857" nimi="Hino küla"/><asula kood="1914" nimi="Hurmi küla"/><asula kood="1960" nimi="Häätaru küla"/><asula kood="2007" nimi="Ihamaru küla"/><asula kood="2259" nimi="Jõgehara küla"/><asula kood="2277" nimi="Jõksi küla"/><asula kood="2387" nimi="Kaagna küla"/><asula kood="2392" nimi="Kaagvere küla"/><asula kood="2667" nimi="Kanepi alevik"/><asula kood="2707" nimi="Karaski küla"/><asula kood="2727" nimi="Karilatsi küla"/><asula kood="2769" nimi="Karste küla"/><asula kood="3280" nimi="Koigera küla"/><asula kood="3399" nimi="Kooli küla"/><asula kood="3415" nimi="Kooraste küla"/><asula kood="3505" nimi="Krootuse küla"/><asula kood="3511" nimi="Krüüdneri küla"/><asula kood="4156" nimi="Lauri küla"/><asula kood="4707" nimi="Maaritsa küla"/><asula kood="4730" nimi="Magari küla"/><asula kood="5314" nimi="Mügra küla"/><asula kood="5557" nimi="Närapää küla"/><asula kood="5959" nimi="Palutaja küla"/><asula kood="6089" nimi="Peetrimõisa küla"/><asula kood="6163" nimi="Piigandi küla"/><asula kood="6167" nimi="Piigaste küla"/><asula kood="6209" nimi="Pikajärve küla"/><asula kood="6217" nimi="Pikareinu küla"/><asula kood="6354" nimi="Prangli küla"/><asula kood="6472" nimi="Puugi küla"/><asula kood="6520" nimi="Põlgaste küla"/><asula kood="6889" nimi="Rebaste küla"/><asula kood="7486" nimi="Saverna küla"/><asula kood="7645" nimi="Sirvaste küla"/><asula kood="7696" nimi="Soodoma küla"/><asula kood="7785" nimi="Sulaoja küla"/><asula kood="7897" nimi="Sõreste küla"/><asula kood="8217" nimi="Tiido küla"/><asula kood="8455" nimi="Tuulemäe küla"/><asula kood="8469" nimi="Tõdu küla"/><asula kood="8932" nimi="Valgjärve küla"/><asula kood="9066" nimi="Varbuse küla"/><asula kood="9229" nimi="Veski küla"/><asula kood="9422" nimi="Vissi küla"/><asula kood="9472" nimi="Voorepalu küla"/></vald><vald kood="0622" nimi="Põlva vald"><asula kood="1027" nimi="Aarna küla"/><asula kood="1081" nimi="Adiste küla"/><asula kood="1116" nimi="Ahja alevik"/><asula kood="1156" nimi="Akste küla"/><asula kood="1261" nimi="Andre küla"/><asula kood="1609" nimi="Eoste küla"/><asula kood="1844" nimi="Himma küla"/><asula kood="1846" nimi="Himmaste küla"/><asula kood="1885" nimi="Holvandi küla"/><asula kood="1980" nimi="Ibaste küla"/><asula kood="2142" nimi="Jaanimõisa küla"/><asula kood="2197" nimi="Joosu küla"/><asula kood="2419" nimi="Kaaru küla"/><asula kood="2471" nimi="Kadaja küla"/><asula kood="2654" nimi="Kanassaare küla"/><asula kood="2728" nimi="Karilatsi küla"/><asula kood="2831" nimi="Kastmekoja küla"/><asula kood="2869" nimi="Kauksi küla"/><asula kood="3030" nimi="Kiidjärve küla"/><asula kood="3050" nimi="Kiisa küla"/><asula kood="3170" nimi="Kiuma küla"/><asula kood="3422" nimi="Koorvere küla"/><asula kood="3469" nimi="Kosova küla"/><asula kood="3863" nimi="Kähri küla"/><asula kood="3923" nimi="Kärsa küla"/><asula kood="4051" nimi="Lahe küla"/><asula kood="4062" nimi="Laho küla"/><asula kood="4198" nimi="Leevijõe küla"/><asula kood="4446" nimi="Logina küla"/><asula kood="4468" nimi="Loko küla"/><asula kood="4522" nimi="Lootvina küla"/><asula kood="4575" nimi="Lutsu küla"/><asula kood="4769" nimi="Mammaste küla"/><asula kood="4851" nimi="Meemaste küla"/><asula kood="4938" nimi="Metste küla"/><asula kood="4945" nimi="Miiaste küla"/><asula kood="4986" nimi="Mooste alevik"/><asula kood="5059" nimi="Mustajõe küla"/><asula kood="5061" nimi="Mustakurmu küla"/><asula kood="5170" nimi="Mõtsküla"/><asula kood="5355" nimi="Naruski küla"/><asula kood="5445" nimi="Nooritsmetsa küla"/><asula kood="5705" nimi="Orajõe küla"/><asula kood="5809" nimi="Padari küla"/><asula kood="6025" nimi="Partsi küla"/><asula kood="6120" nimi="Peri küla"/><asula kood="6347" nimi="Pragi küla"/><asula kood="6461" nimi="Puskaru küla"/><asula kood="6477" nimi="Puuri küla"/><asula kood="6536" nimi="Põlva linn"/><asula kood="6825" nimi="Rasina küla"/><asula kood="7071" nimi="Roosi küla"/><asula kood="7098" nimi="Rosma küla"/><asula kood="7501" nimi="Savimäe küla"/><asula kood="7660" nimi="Soesaare küla"/><asula kood="7855" nimi="Suurküla"/><asula kood="7858" nimi="Suurmetsa küla"/><asula kood="7918" nimi="Säkna küla"/><asula kood="7964" nimi="Säässaare küla"/><asula kood="8028" nimi="Taevaskoja küla"/><asula kood="8198" nimi="Terepi küla"/><asula kood="8243" nimi="Tilsi küla"/><asula kood="8353" nimi="Tromsi küla"/><asula kood="8574" nimi="Tännassilma küla"/><asula kood="8644" nimi="Uibujärve küla"/><asula kood="8922" nimi="Valgemetsa küla"/><asula kood="8927" nimi="Valgesoo küla"/><asula kood="8989" nimi="Vana-Koiola küla"/><asula kood="9010" nimi="Vanaküla"/><asula kood="9023" nimi="Vanamõisa küla"/><asula kood="9072" nimi="Vardja küla"/><asula kood="9128" nimi="Vastse-Kuuste alevik"/><asula kood="9300" nimi="Viisli küla"/><asula kood="9470" nimi="Vooreküla"/></vald><vald kood="0708" nimi="Räpina vald"><asula kood="1329" nimi="Aravu küla"/><asula kood="1705" nimi="Haavametsa küla"/><asula kood="1706" nimi="Haavapää küla"/><asula kood="1849" nimi="Himmiste küla"/><asula kood="2140" nimi="Jaanikeste küla"/><asula kood="2241" nimi="Jõepera küla"/><asula kood="2252" nimi="Jõevaara küla"/><asula kood="2256" nimi="Jõeveere küla"/><asula kood="2815" nimi="Kassilaane küla"/><asula kood="3066" nimi="Kikka küla"/><asula kood="3145" nimi="Kirmsi küla"/><asula kood="3405" nimi="Koolma küla"/><asula kood="3406" nimi="Koolmajärve küla"/><asula kood="3589" nimi="Kullamäe küla"/><asula kood="3629" nimi="Kunksilla küla"/><asula kood="3770" nimi="Kõnnu küla"/><asula kood="3963" nimi="Köstrimäe küla"/><asula kood="4066" nimi="Laho küla"/><asula kood="4193" nimi="Leevaku küla"/><asula kood="4195" nimi="Leevi küla"/><asula kood="4326" nimi="Lihtensteini küla"/><asula kood="4410" nimi="Linte küla"/><asula kood="4842" nimi="Meeksi küla"/><asula kood="4849" nimi="Meelva küla"/><asula kood="4854" nimi="Meerapalu küla"/><asula kood="4859" nimi="Mehikoorma alevik"/><asula kood="4911" nimi="Mõtsavaara küla"/><asula kood="5221" nimi="Mägiotsa küla"/><asula kood="5269" nimi="Männisalu küla"/><asula kood="5340" nimi="Naha küla"/><asula kood="5437" nimi="Nohipalo küla"/><asula kood="5459" nimi="Nulga küla"/><asula kood="5857" nimi="Pahtpää küla"/><asula kood="5992" nimi="Parapalu küla"/><asula kood="6268" nimi="Pindi küla"/><asula kood="6631" nimi="Pääsna küla"/><asula kood="6677" nimi="Raadama küla"/><asula kood="6743" nimi="Rahumäe küla"/><asula kood="6753" nimi="Raigla küla"/><asula kood="7016" nimi="Ristipalo küla"/><asula kood="7151" nimi="Ruusa küla"/><asula kood="7216" nimi="Räpina linn"/><asula kood="7289" nimi="Saareküla"/><asula kood="7439" nimi="Sarvemäe küla"/><asula kood="7579" nimi="Sikakurmu küla"/><asula kood="7595" nimi="Sillapää küla"/><asula kood="7698" nimi="Soohara küla"/><asula kood="7835" nimi="Suure-Veerksu küla"/><asula kood="7975" nimi="Sülgoja küla"/><asula kood="7981" nimi="Süvahavva küla"/><asula kood="8244" nimi="Timo küla"/><asula kood="8289" nimi="Toolamaa küla"/><asula kood="8313" nimi="Tooste küla"/><asula kood="8370" nimi="Tsirksi küla"/><asula kood="9080" nimi="Vareste küla"/><asula kood="9223" nimi="Veriora alevik"/><asula kood="9224" nimi="Verioramõisa küla"/><asula kood="9294" nimi="Viira küla"/><asula kood="9369" nimi="Viluste küla"/><asula kood="9377" nimi="Vinso küla"/><asula kood="9511" nimi="Võiardi küla"/><asula kood="9527" nimi="Võika küla"/><asula kood="9599" nimi="Võuküla"/><asula kood="9608" nimi="Võõpsu alevik"/><asula kood="9175" nimi="Väike-Veerksu küla"/><asula kood="9664" nimi="Vändra küla"/></vald></maakond><maakond kood="0068" nimi="Pärnu maakond"><vald kood="0214" nimi="Häädemeeste vald"><asula kood="1378" nimi="Arumetsa küla"/><asula kood="1957" nimi="Häädemeeste alevik"/><asula kood="2029" nimi="Ikla küla"/><asula kood="2124" nimi="Jaagupi küla"/><asula kood="2463" nimi="Kabli küla"/><asula kood="3508" nimi="Krundiküla"/><asula kood="4004" nimi="Laadi küla"/><asula kood="4232" nimi="Leina küla"/><asula kood="4284" nimi="Lepaküla"/><asula kood="4746" nimi="Majaka küla"/><asula kood="4805" nimi="Massiaru küla"/><asula kood="4874" nimi="Mereküla"/><asula kood="4892" nimi="Metsaküla"/><asula kood="4908" nimi="Metsapoole küla"/><asula kood="5403" nimi="Nepste küla"/><asula kood="5706" nimi="Orajõe küla"/><asula kood="5984" nimi="Papisilla küla"/><asula kood="6103" nimi="Penu küla"/><asula kood="6194" nimi="Piirumi küla"/><asula kood="6420" nimi="Pulgoja küla"/><asula kood="6811" nimi="Rannametsa küla"/><asula kood="6925" nimi="Reiu küla"/><asula kood="7706" nimi="Sooküla"/><asula kood="7717" nimi="Soometsa küla"/><asula kood="8072" nimi="Tahkuranna küla"/><asula kood="8340" nimi="Treimani küla"/><asula kood="8724" nimi="Urissaare küla"/><asula kood="8767" nimi="Uuemaa küla"/><asula kood="8779" nimi="Uulu küla"/><asula kood="9521" nimi="Võidu küla"/><asula kood="9539" nimi="Võiste alevik"/></vald><vald kood="0303" nimi="Kihnu vald"><asula kood="4276" nimi="Lemsi küla"/><asula kood="4381" nimi="Linaküla"/><asula kood="7089" nimi="Rootsiküla"/><asula kood="7951" nimi="Sääre küla"/></vald><vald kood="0430" nimi="Lääneranna vald"><asula kood="1169" nimi="Alaküla"/><asula kood="1204" nimi="Allika küla"/><asula kood="1366" nimi="Aruküla"/><asula kood="1591" nimi="Emmu küla"/><asula kood="1649" nimi="Esivere küla"/><asula kood="1690" nimi="Haapsi küla"/><asula kood="1757" nimi="Hanila küla"/><asula kood="1814" nimi="Helmküla"/><asula kood="1921" nimi="Hõbeda küla"/><asula kood="1929" nimi="Hõbesalu küla"/><asula kood="1936" nimi="Hälvati küla"/><asula kood="2102" nimi="Irta küla"/><asula kood="2106" nimi="Iska küla"/><asula kood="2192" nimi="Joonuse küla"/><asula kood="2255" nimi="Jõeääre küla"/><asula kood="2316" nimi="Jänistvere küla"/><asula kood="2323" nimi="Järise küla"/><asula kood="2349" nimi="Järve küla"/><asula kood="2473" nimi="Kadaka küla"/><asula kood="2606" nimi="Kalli küla"/><asula kood="2651" nimi="Kanamardi küla"/><asula kood="2732" nimi="Karinõmme küla"/><asula kood="2777" nimi="Karuba küla"/><asula kood="2784" nimi="Karuse küla"/><asula kood="2792" nimi="Kaseküla"/><asula kood="2879" nimi="Kause küla"/><asula kood="2912" nimi="Keemu küla"/><asula kood="2946" nimi="Kelu küla"/><asula kood="2999" nimi="Kibura küla"/><asula kood="3006" nimi="Kidise küla"/><asula kood="3049" nimi="Kiisamaa küla"/><asula kood="3082" nimi="Kilgi küla"/><asula kood="3099" nimi="Kinksi küla"/><asula kood="3113" nimi="Kirbla küla"/><asula kood="7782" nimi="Kirikuküla"/><asula kood="3159" nimi="Kiska küla"/><asula kood="3210" nimi="Kloostri küla"/><asula kood="3251" nimi="Koeri küla"/><asula kood="3326" nimi="Kokuta küla"/><asula kood="3407" nimi="Koonga küla"/><asula kood="3445" nimi="Korju küla"/><asula kood="3524" nimi="Kuhu küla"/><asula kood="3552" nimi="Kuke küla"/><asula kood="3593" nimi="Kulli küla"/><asula kood="3616" nimi="Kunila küla"/><asula kood="3654" nimi="Kurese küla"/><asula kood="3739" nimi="Kõera küla"/><asula kood="8091" nimi="Kõima küla"/><asula kood="3765" nimi="Kõmsi küla"/><asula kood="3930" nimi="Käru küla"/><asula kood="4149" nimi="Laulepa küla"/><asula kood="4163" nimi="Lautna küla"/><asula kood="4330" nimi="Lihula linn"/><asula kood="4406" nimi="Linnuse küla"/><asula kood="4429" nimi="Liustemäe küla"/><asula kood="4607" nimi="Lõo küla"/><asula kood="4611" nimi="Lõpe küla"/><asula kood="4695" nimi="Maade küla"/><asula kood="4742" nimi="Maikse küla"/><asula kood="4807" nimi="Massu küla"/><asula kood="4820" nimi="Matsalu küla"/><asula kood="4824" nimi="Matsi küla"/><asula kood="4847" nimi="Meelva küla"/><asula kood="4881" nimi="Mereäärse küla"/><asula kood="4929" nimi="Metsküla"/><asula kood="4942" nimi="Mihkli küla"/><asula kood="5049" nimi="Muriste küla"/><asula kood="5127" nimi="Mõisaküla"/><asula kood="5174" nimi="Mõisimaa küla"/><asula kood="5173" nimi="Mõtsu küla"/><asula kood="5202" nimi="Mäense küla"/><asula kood="5247" nimi="Mäliküla"/><asula kood="5344" nimi="Naissoo küla"/><asula kood="5385" nimi="Nedrema küla"/><asula kood="5399" nimi="Nehatu küla"/><asula kood="5464" nimi="Nurme küla"/><asula kood="5473" nimi="Nurmsi küla"/><asula kood="5530" nimi="Nõmme küla"/><asula kood="5563" nimi="Nätsi küla"/><asula kood="5638" nimi="Oidrema küla"/><asula kood="5776" nimi="Paadrema küla"/><asula kood="5801" nimi="Paatsalu küla"/><asula kood="5845" nimi="Pagasi küla"/><asula kood="5869" nimi="Paimvere küla"/><asula kood="5889" nimi="Pajumaa küla"/><asula kood="5924" nimi="Palatu küla"/><asula kood="5990" nimi="Parasmaa küla"/><asula kood="6013" nimi="Parivere küla"/><asula kood="6055" nimi="Peanse küla"/><asula kood="6054" nimi="Peantse küla"/><asula kood="6096" nimi="Penijõe küla"/><asula kood="6131" nimi="Petaaluse küla"/><asula kood="6135" nimi="Piha küla"/><asula kood="6200" nimi="Piisu küla"/><asula kood="6227" nimi="Pikavere küla"/><asula kood="6286" nimi="Pivarootsi küla"/><asula kood="6302" nimi="Poanse küla"/><asula kood="6707" nimi="Rabavere küla"/><asula kood="6717" nimi="Raespa küla"/><asula kood="6722" nimi="Raheste küla"/><asula kood="6778" nimi="Rame küla"/><asula kood="6802" nimi="Rannaküla"/><asula kood="6827" nimi="Rannu küla"/><asula kood="6865" nimi="Rauksi küla"/><asula kood="6961" nimi="Ridase küla"/><asula kood="7064" nimi="Rooglaiu küla"/><asula kood="7087" nimi="Rootsi küla"/><asula kood="7091" nimi="Rootsi-Aruküla"/><asula kood="7117" nimi="Rumba küla"/><asula kood="7259" nimi="Rädi küla"/><asula kood="7287" nimi="Saare küla"/><asula kood="7310" nimi="Saastna küla"/><asula kood="7373" nimi="Salavere küla"/><asula kood="7379" nimi="Salevere küla"/><asula kood="7462" nimi="Saulepi küla"/><asula kood="7511" nimi="Seira küla"/><asula kood="7519" nimi="Seli küla"/><asula kood="7532" nimi="Selja küla"/><asula kood="7699" nimi="Sookalda küla"/><asula kood="7702" nimi="Sookatse küla"/><asula kood="7749" nimi="Soovälja küla"/><asula kood="8088" nimi="Tamba küla"/><asula kood="8092" nimi="Tamme küla"/><asula kood="8157" nimi="Tarva küla"/><asula kood="8220" nimi="Tiilima küla"/><asula kood="8401" nimi="Tuhu küla"/><asula kood="8446" nimi="Tuudi küla"/><asula kood="8478" nimi="Tõitse küla"/><asula kood="8541" nimi="Tõusi küla"/><asula kood="8577" nimi="Täpsi küla"/><asula kood="8663" nimi="Ullaste küla"/><asula kood="8666" nimi="Uluste küla"/><asula kood="8712" nimi="Ura küla"/><asula kood="8722" nimi="Urita küla"/><asula kood="8830" nimi="Vagivere küla"/><asula kood="8893" nimi="Vaiste küla"/><asula kood="8974" nimi="Valuste küla"/><asula kood="9035" nimi="Vanamõisa küla"/><asula kood="9061" nimi="Varbla küla"/><asula kood="9134" nimi="Vastaba küla"/><asula kood="9141" nimi="Vatla küla"/><asula kood="9192" nimi="Veltsa küla"/><asula kood="9388" nimi="Virtsu alevik"/><asula kood="9478" nimi="Voose küla"/><asula kood="9499" nimi="Võhma küla"/><asula kood="9528" nimi="Võigaste küla"/><asula kood="9544" nimi="Võitra küla"/><asula kood="9584" nimi="Võrungi küla"/><asula kood="9691" nimi="Õepa küla"/><asula kood="9791" nimi="Õhu küla"/><asula kood="9742" nimi="Äila küla"/><asula kood="1603" nimi="Ännikse küla"/></vald><vald kood="0638" nimi="Põhja-Pärnumaa vald"><asula kood="1030" nimi="Aasa küla"/><asula kood="1215" nimi="Allikõnnu küla"/><asula kood="1214" nimi="Altküla"/><asula kood="1237" nimi="Aluste küla"/><asula kood="1267" nimi="Anelema küla"/><asula kood="1314" nimi="Arase küla"/><asula kood="1506" nimi="Eametsa küla"/><asula kood="1527" nimi="Eense küla"/><asula kood="1531" nimi="Eerma küla"/><asula kood="1602" nimi="Enge küla"/><asula kood="1634" nimi="Ertsma küla"/><asula kood="1736" nimi="Halinga küla"/><asula kood="1802" nimi="Helenurme küla"/><asula kood="2400" nimi="Kaansoo küla"/><asula kood="2462" nimi="Kablima küla"/><asula kood="2486" nimi="Kadjaste küla"/><asula kood="2493" nimi="Kaelase küla"/><asula kood="2545" nimi="Kaisma küla"/><asula kood="2619" nimi="Kalmaru küla"/><asula kood="2669" nimi="Kangru küla"/><asula kood="2969" nimi="Kergu küla"/><asula kood="3127" nimi="Kirikumõisa küla"/><asula kood="3219" nimi="Kobra küla"/><asula kood="3237" nimi="Kodesmaa küla"/><asula kood="3459" nimi="Kose küla"/><asula kood="3599" nimi="Kullimaa küla"/><asula kood="3617" nimi="Kuninga küla"/><asula kood="3666" nimi="Kurgja küla"/><asula kood="3771" nimi="Kõnnu küla"/><asula kood="4101" nimi="Langerma küla"/><asula kood="4190" nimi="Leetva küla"/><asula kood="4216" nimi="Lehtmetsa küla"/><asula kood="4219" nimi="Lehu küla"/><asula kood="4320" nimi="Libatse küla"/><asula kood="4504" nimi="Loomse küla"/><asula kood="4586" nimi="Luuri küla"/><asula kood="4696" nimi="Lüüste küla"/><asula kood="4743" nimi="Maima küla"/><asula kood="4808" nimi="Massu küla"/><asula kood="4891" nimi="Metsaküla"/><asula kood="4913" nimi="Metsavere küla"/><asula kood="5072" nimi="Mustaru küla"/><asula kood="5137" nimi="Mõisaküla"/><asula kood="5185" nimi="Mädara küla"/><asula kood="5191" nimi="Mäeküla"/><asula kood="5328" nimi="Naartse küla"/><asula kood="5610" nimi="Oese küla"/><asula kood="5720" nimi="Oriküla"/><asula kood="5935" nimi="Pallika küla"/><asula kood="6113" nimi="Pereküla"/><asula kood="6278" nimi="Pitsalu küla"/><asula kood="6616" nimi="Pärnjõe küla"/><asula kood="6617" nimi="Pärnu-Jaagupi alev"/><asula kood="6646" nimi="Pööravere küla"/><asula kood="6714" nimi="Rae küla"/><asula kood="6725" nimi="Rahkama küla"/><asula kood="6732" nimi="Rahnoja küla"/><asula kood="6921" nimi="Reinumurru küla"/><asula kood="7061" nimi="Roodi küla"/><asula kood="7108" nimi="Rukkiküla"/><asula kood="7186" nimi="Rõusa küla"/><asula kood="7229" nimi="Rätsepa küla"/><asula kood="7391" nimi="Salu küla"/><asula kood="7406" nimi="Samliku küla"/><asula kood="7541" nimi="Sepaküla"/><asula kood="7581" nimi="Sikana küla"/><asula kood="7661" nimi="Sohlu küla"/><asula kood="7739" nimi="Soosalu küla"/><asula kood="7838" nimi="Suurejõe küla"/><asula kood="7912" nimi="Sõõrike küla"/><asula kood="7967" nimi="Säästla küla"/><asula kood="8055" nimi="Tagassaare küla"/><asula kood="8156" nimi="Tarva küla"/><asula kood="8316" nimi="Tootsi alev"/><asula kood="8510" nimi="Tõrdu küla"/><asula kood="8588" nimi="Tühjasma küla"/><asula kood="8843" nimi="Vahenurme küla"/><asula kood="8901" nimi="Vakalepa küla"/><asula kood="8909" nimi="Vaki küla"/><asula kood="8947" nimi="Valistre küla"/><asula kood="9164" nimi="Vee küla"/><asula kood="9199" nimi="Venekuusiku küla"/><asula kood="9237" nimi="Veskisoo küla"/><asula kood="9267" nimi="Vihtra küla"/><asula kood="9372" nimi="Viluvere küla"/><asula kood="9524" nimi="Võidula küla"/><asula kood="9526" nimi="Võiera küla"/><asula kood="9663" nimi="Vändra alev"/><asula kood="9842" nimi="Ünnaste küla"/></vald><vald kood="0624" nimi="Pärnu linn"><asula kood="1107" nimi="Ahaste küla"/><asula kood="1229" nimi="Alu küla"/><asula kood="1394" nimi="Aruvälja küla"/><asula kood="1458" nimi="Audru alevik"/><asula kood="1513" nimi="Eassalu küla"/><asula kood="1628" nimi="Ermistu küla"/><asula kood="2289" nimi="Jõõpre küla"/><asula kood="2468" nimi="Kabriste küla"/><asula kood="2834" nimi="Kastna küla"/><asula kood="2893" nimi="Kavaru küla"/><asula kood="3014" nimi="Kihlepa küla"/><asula kood="3109" nimi="Kiraste küla"/><asula kood="3746" nimi="Kõima küla"/><asula kood="3784" nimi="Kõpu küla"/><asula kood="3891" nimi="Kärbu küla"/><asula kood="4109" nimi="Lao küla"/><asula kood="4165" nimi="Lavassaare alev"/><asula kood="4268" nimi="Lemmetsa küla"/><asula kood="4354" nimi="Liiva küla"/><asula kood="4384" nimi="Lindi küla"/><asula kood="4430" nimi="Liu küla"/><asula kood="4617" nimi="Lõuka küla"/><asula kood="4753" nimi="Malda küla"/><asula kood="4771" nimi="Manija küla"/><asula kood="4792" nimi="Marksa küla"/><asula kood="5264" nimi="Männikuste küla"/><asula kood="5578" nimi="Oara küla"/><asula kood="5864" nimi="Paikuse alev"/><asula kood="5986" nimi="Papsaare küla"/><asula kood="6082" nimi="Peerni küla"/><asula kood="6325" nimi="Pootsi küla"/><asula kood="6499" nimi="Põhara küla"/><asula kood="6513" nimi="Põldeotsa küla"/><asula kood="6518" nimi="Põlendmaa küla"/><asula kood="6595" nimi="Päraküla"/><asula kood="6619" nimi="Pärnu linn"/><asula kood="6783" nimi="Rammuka küla"/><asula kood="6819" nimi="Ranniku küla"/><asula kood="6962" nimi="Ridalepa küla"/><asula kood="7300" nimi="Saari küla"/><asula kood="7460" nimi="Saulepa küla"/><asula kood="7526" nimi="Seliste küla"/><asula kood="7536" nimi="Seljametsa küla"/><asula kood="7591" nimi="Silla küla"/><asula kood="7663" nimi="Soeva küla"/><asula kood="7723" nimi="Soomra küla"/><asula kood="8131" nimi="Tammuru küla"/><asula kood="8463" nimi="Tuuraste küla"/><asula kood="8475" nimi="Tõhela küla"/><asula kood="8488" nimi="Tõlli küla"/><asula kood="8540" nimi="Tõstamaa alevik"/><asula kood="8924" nimi="Valgeranna küla"/><asula kood="9113" nimi="Vaskrääma küla"/><asula kood="9669" nimi="Värati küla"/></vald><vald kood="0712" nimi="Saarde vald"><asula kood="1217" nimi="Allikukivi küla"/><asula kood="2062" nimi="Ilvese küla"/><asula kood="2132" nimi="Jaamaküla"/><asula kood="2370" nimi="Jäärja küla"/><asula kood="2572" nimi="Kalda küla"/><asula kood="2588" nimi="Kalita küla"/><asula kood="2631" nimi="Kamali küla"/><asula kood="2648" nimi="Kanaküla"/><asula kood="3061" nimi="Kikepera küla"/><asula kood="3083" nimi="Kilingi-Nõmme linn"/><asula kood="3840" nimi="Kõveri küla"/><asula kood="3928" nimi="Kärsu küla"/><asula kood="1421" nimi="Laiksaare küla"/><asula kood="4104" nimi="Lanksaare küla"/><asula kood="4235" nimi="Leipste küla"/><asula kood="4440" nimi="Lodja küla"/><asula kood="4628" nimi="Lähkma küla"/><asula kood="4782" nimi="Marana küla"/><asula kood="4787" nimi="Marina küla"/><asula kood="4916" nimi="Metsaääre küla"/><asula kood="5085" nimi="Mustla küla"/><asula kood="5640" nimi="Oissaare küla"/><asula kood="6143" nimi="Pihke küla"/><asula kood="6705" nimi="Rabaküla"/><asula kood="6919" nimi="Reinu küla"/><asula kood="7013" nimi="Ristiküla"/><asula kood="7280" nimi="Saarde küla"/><asula kood="7463" nimi="Saunametsa küla"/><asula kood="7560" nimi="Sigaste küla"/><asula kood="7807" nimi="Surju küla"/><asula kood="8083" nimi="Tali küla"/><asula kood="8213" nimi="Tihemetsa alevik"/><asula kood="8458" nimi="Tuuliku küla"/><asula kood="8485" nimi="Tõlla küla"/><asula kood="9166" nimi="Veelikse küla"/><asula kood="9297" nimi="Viisireiu küla"/><asula kood="9652" nimi="Väljaküla"/></vald><vald kood="0809" nimi="Tori vald"><asula kood="1091" nimi="Aesoo küla"/><asula kood="1344" nimi="Are alevik"/><asula kood="1510" nimi="Eametsa küla"/><asula kood="1516" nimi="Eavere küla"/><asula kood="1574" nimi="Elbi küla"/><asula kood="1576" nimi="Elbu küla"/><asula kood="2251" nimi="Jõesuu küla"/><asula kood="3046" nimi="Kiisa küla"/><asula kood="3077" nimi="Kildemaa küla"/><asula kood="3084" nimi="Kilksama küla"/><asula kood="3526" nimi="Kuiaru küla"/><asula kood="3648" nimi="Kurena küla"/><asula kood="3812" nimi="Kõrsa küla"/><asula kood="4296" nimi="Lepplaane küla"/><asula kood="4314" nimi="Levi küla"/><asula kood="4774" nimi="Mannare küla"/><asula kood="5036" nimi="Muraka küla"/><asula kood="5053" nimi="Murru küla"/><asula kood="5101" nimi="Muti küla"/><asula kood="5417" nimi="Niidu küla"/><asula kood="5468" nimi="Nurme küla"/><asula kood="5698" nimi="Oore küla"/><asula kood="6012" nimi="Parisselja küla"/><asula kood="6201" nimi="Piistaoja küla"/><asula kood="6425" nimi="Pulli küla"/><asula kood="6608" nimi="Pärivere küla"/><asula kood="6792" nimi="Randivälja küla"/><asula kood="6986" nimi="Riisa küla"/><asula kood="5292" nimi="Rätsepa küla"/><asula kood="7237" nimi="Räägu küla"/><asula kood="7265" nimi="Rütavere küla"/><asula kood="7455" nimi="Sauga alevik"/><asula kood="7529" nimi="Selja küla"/><asula kood="7607" nimi="Sindi linn"/><asula kood="7776" nimi="Suigu küla"/><asula kood="7996" nimi="Taali küla"/><asula kood="8019" nimi="Tabria küla"/><asula kood="8120" nimi="Tammiste küla"/><asula kood="8269" nimi="Tohera küla"/><asula kood="8326" nimi="Tori alevik"/><asula kood="8720" nimi="Urge küla"/><asula kood="8730" nimi="Urumarja küla"/><asula kood="8885" nimi="Vainu küla"/><asula kood="9555" nimi="Võlla küla"/><asula kood="9560" nimi="Võlli küla"/></vald></maakond><maakond kood="0071" nimi="Rapla maakond"><vald kood="0293" nimi="Kehtna vald"><asula kood="1110" nimi="Ahekõnnu küla"/><asula kood="1550" nimi="Eidapere alevik"/><asula kood="1583" nimi="Ellamaa küla"/><asula kood="1684" nimi="Haakla küla"/><asula kood="1826" nimi="Hertu küla"/><asula kood="1830" nimi="Hiie küla"/><asula kood="2087" nimi="Ingliste küla"/><asula kood="2346" nimi="Järvakandi alev"/><asula kood="2496" nimi="Kaerepere alevik"/><asula kood="2498" nimi="Kaerepere küla"/><asula kood="2567" nimi="Kalbu küla"/><asula kood="2835" nimi="Kastna küla"/><asula kood="2903" nimi="Keava alevik"/><asula kood="2924" nimi="Kehtna alevik"/><asula kood="2900" nimi="Kehtna-Nurme küla"/><asula kood="2952" nimi="Kenni küla"/><asula kood="3389" nimi="Koogimäe küla"/><asula kood="3391" nimi="Koogiste küla"/><asula kood="3606" nimi="Kumma küla"/><asula kood="3785" nimi="Kõrbja küla"/><asula kood="3846" nimi="Käbiküla"/><asula kood="3919" nimi="Kärpla küla"/><asula kood="4038" nimi="Laeste küla"/><asula kood="4084" nimi="Lalli küla"/><asula kood="4133" nimi="Lau küla"/><asula kood="4248" nimi="Lellapere küla"/><asula kood="2923" nimi="Lellapere-Nurme küla"/><asula kood="4250" nimi="Lelle alevik"/><asula kood="4392" nimi="Linnaaluste küla"/><asula kood="4476" nimi="Lokuta küla"/><asula kood="4914" nimi="Metsaääre küla"/><asula kood="5015" nimi="Mukri küla"/><asula kood="5334" nimi="Nadalama küla"/><asula kood="5498" nimi="Nõlva küla"/><asula kood="5618" nimi="Ohekatku küla"/><asula kood="5820" nimi="Pae küla"/><asula kood="5922" nimi="Palasi küla"/><asula kood="5947" nimi="Paluküla"/><asula kood="6530" nimi="Põllu küla"/><asula kood="6546" nimi="Põrsaku küla"/><asula kood="6937" nimi="Reonda küla"/><asula kood="7176" nimi="Rõue küla"/><asula kood="7298" nimi="Saarepõllu küla"/><asula kood="7353" nimi="Saksa küla"/><asula kood="7461" nimi="Saunaküla"/><asula kood="7531" nimi="Selja küla"/><asula kood="7681" nimi="Sooaluste küla"/><asula kood="8970" nimi="Valtu-Nurme küla"/><asula kood="9126" nimi="Vastja küla"/></vald><vald kood="0317" nimi="Kohila vald"><asula kood="1021" nimi="Aandu küla"/><asula kood="1079" nimi="Adila küla"/><asula kood="1094" nimi="Aespa alevik"/><asula kood="1270" nimi="Angerja küla"/><asula kood="1714" nimi="Hageri alevik"/><asula kood="1715" nimi="Hageri küla"/><asula kood="2475" nimi="Kadaka küla"/><asula kood="3268" nimi="Kohila alev"/><asula kood="4453" nimi="Lohu küla"/><asula kood="4511" nimi="Loone küla"/><asula kood="4681" nimi="Lümandu küla"/><asula kood="4811" nimi="Masti küla"/><asula kood="5250" nimi="Mälivere küla"/><asula kood="5854" nimi="Pahkla küla"/><asula kood="6140" nimi="Pihali küla"/><asula kood="6368" nimi="Prillimäe alevik"/><asula kood="6415" nimi="Pukamäe küla"/><asula kood="6503" nimi="Põikma küla"/><asula kood="6710" nimi="Rabivere küla"/><asula kood="7085" nimi="Rootsi küla"/><asula kood="7402" nimi="Salutaguse küla"/><asula kood="7815" nimi="Sutlema küla"/><asula kood="8721" nimi="Urge küla"/><asula kood="8976" nimi="Vana-Aespa küla"/><asula kood="9341" nimi="Vilivere küla"/></vald><vald kood="0503" nimi="Märjamaa vald"><asula kood="1168" nimi="Alaküla"/><asula kood="1219" nimi="Altküla"/><asula kood="1319" nimi="Araste küla"/><asula kood="1324" nimi="Aravere küla"/><asula kood="1375" nimi="Aruküla"/><asula kood="1478" nimi="Avaste küla"/><asula kood="1725" nimi="Haimre küla"/><asula kood="1834" nimi="Hiietse küla"/><asula kood="2081" nimi="Inda küla"/><asula kood="2147" nimi="Jaaniveski küla"/><asula kood="2254" nimi="Jõeääre küla"/><asula kood="2296" nimi="Jädivere küla"/><asula kood="2504" nimi="Kaguvere küla"/><asula kood="2668" nimi="Kangru küla"/><asula kood="2824" nimi="Kasti küla"/><asula kood="2883" nimi="Kausi küla"/><asula kood="2980" nimi="Keskküla"/><asula kood="2990" nimi="Kesu küla"/><asula kood="3037" nimi="Kiilaspere küla"/><asula kood="3080" nimi="Kilgi küla"/><asula kood="3146" nimi="Kirna küla"/><asula kood="3175" nimi="Kivi-Vigala küla"/><asula kood="3267" nimi="Kohatu küla"/><asula kood="3272" nimi="Kohtru küla"/><asula kood="3307" nimi="Kojastu küla"/><asula kood="3365" nimi="Koluta küla"/><asula kood="3373" nimi="Konnapere küla"/><asula kood="3380" nimi="Konuvere küla"/><asula kood="3627" nimi="Kunsu küla"/><asula kood="3662" nimi="Kurevere küla"/><asula kood="3813" nimi="Kõrtsuotsa küla"/><asula kood="3831" nimi="Kõrvetaguse küla"/><asula kood="3844" nimi="Käbiküla"/><asula kood="3908" nimi="Käriselja küla"/><asula kood="4143" nimi="Laukna küla"/><asula kood="4200" nimi="Leevre küla"/><asula kood="4221" nimi="Leibre küla"/><asula kood="4302" nimi="Lestima küla"/><asula kood="4479" nimi="Lokuta küla"/><asula kood="4503" nimi="Loodna küla"/><asula kood="4554" nimi="Luiste küla"/><asula kood="4647" nimi="Läti küla"/><asula kood="4683" nimi="Lümandu küla"/><asula kood="8232" nimi="Maidla küla"/><asula kood="4775" nimi="Manni küla"/><asula kood="4915" nimi="Metsaääre küla"/><asula kood="4919" nimi="Metsküla"/><asula kood="4967" nimi="Moka küla"/><asula kood="5133" nimi="Mõisamaa küla"/><asula kood="5162" nimi="Mõraste küla"/><asula kood="5246" nimi="Mäliste küla"/><asula kood="5262" nimi="Männiku küla"/><asula kood="5280" nimi="Märjamaa alev"/><asula kood="5348" nimi="Naistevalla küla"/><asula kood="5351" nimi="Napanurga küla"/><asula kood="5353" nimi="Naravere küla"/><asula kood="5469" nimi="Nurme küla"/><asula kood="5482" nimi="Nurtu-Nõlva küla"/><asula kood="5517" nimi="Nõmmeotsa küla"/><asula kood="5561" nimi="Nääri küla"/><asula kood="5611" nimi="Oese küla"/><asula kood="5631" nimi="Ohukotsu küla"/><asula kood="5653" nimi="Ojapere küla"/><asula kood="5655" nimi="Ojaäärse küla"/><asula kood="5711" nimi="Orgita küla"/><asula kood="5779" nimi="Paaduotsa küla"/><asula kood="5826" nimi="Paeküla"/><asula kood="5875" nimi="Paisumaa küla"/><asula kood="5878" nimi="Pajaka küla"/><asula kood="5921" nimi="Palase küla"/><asula kood="5928" nimi="Paljasmaa küla"/><asula kood="5937" nimi="Pallika küla"/><asula kood="6438" nimi="Purga küla"/><asula kood="6523" nimi="Põlli küla"/><asula kood="6624" nimi="Päädeva küla"/><asula kood="6629" nimi="Päärdu küla"/><asula kood="6662" nimi="Pühatu küla"/><asula kood="6800" nimi="Rangu küla"/><asula kood="6832" nimi="Rassiotsa küla"/><asula kood="6979" nimi="Riidaku küla"/><asula kood="7003" nimi="Ringuta küla"/><asula kood="7015" nimi="Risu-Suurküla"/><asula kood="7132" nimi="Russalu küla"/><asula kood="7248" nimi="Rääski küla"/><asula kood="7622" nimi="Sipa küla"/><asula kood="7725" nimi="Sooniste küla"/><asula kood="7740" nimi="Soosalu küla"/><asula kood="7792" nimi="Sulu küla"/><asula kood="7853" nimi="Suurküla"/><asula kood="7890" nimi="Sõmeru küla"/><asula kood="7909" nimi="Sõtke küla"/><asula kood="7946" nimi="Sääla küla"/><asula kood="8182" nimi="Teenuse küla"/><asula kood="8208" nimi="Tiduvere küla"/><asula kood="8283" nimi="Tolli küla"/><asula kood="8509" nimi="Tõnumaa küla"/><asula kood="8717" nimi="Urevere küla"/><asula kood="8834" nimi="Vaguja küla"/><asula kood="8882" nimi="Vaimõisa küla"/><asula kood="8939" nimi="Valgu küla"/><asula kood="9340" nimi="Valgu-Vanamõisa küla"/><asula kood="8997" nimi="Vana-Nurtu küla"/><asula kood="9007" nimi="Vana-Vigala küla"/><asula kood="9063" nimi="Varbola küla"/><asula kood="9189" nimi="Velise küla"/><asula kood="9190" nimi="Velise-Nõlva küla"/><asula kood="9187" nimi="Velisemõisa küla"/><asula kood="9228" nimi="Veski küla"/><asula kood="9256" nimi="Vigala-Vanamõisa küla"/><asula kood="9359" nimi="Vilta küla"/><asula kood="9493" nimi="Võeva küla"/><asula kood="9666" nimi="Vängla küla"/><asula kood="9829" nimi="Ülejõe küla"/></vald><vald kood="0668" nimi="Rapla vald"><asula kood="1230" nimi="Alu alevik"/><asula kood="1232" nimi="Alu-Metsküla"/><asula kood="1316" nimi="Aranküla"/><asula kood="1437" nimi="Atla küla"/><asula kood="1716" nimi="Hagudi alevik"/><asula kood="1717" nimi="Hagudi küla"/><asula kood="1805" nimi="Helda küla"/><asula kood="1931" nimi="Hõreda küla"/><asula kood="1944" nimi="Härgla küla"/><asula kood="2020" nimi="Iira küla"/><asula kood="2161" nimi="Jalase küla"/><asula kood="2169" nimi="Jaluse küla"/><asula kood="2216" nimi="Juula küla"/><asula kood="2223" nimi="Juuru alevik"/><asula kood="2330" nimi="Järlepa küla"/><asula kood="2444" nimi="Kabala küla"/><asula kood="2530" nimi="Kaigepere küla"/><asula kood="2553" nimi="Kaiu alevik"/><asula kood="2569" nimi="Kalda küla"/><asula kood="2580" nimi="Kalevi küla"/><asula kood="2742" nimi="Karitsa küla"/><asula kood="2845" nimi="Kasvandu küla"/><asula kood="2933" nimi="Kelba küla"/><asula kood="2955" nimi="Keo küla"/><asula kood="3242" nimi="Kodila küla"/><asula kood="3240" nimi="Kodila-Metsküla"/><asula kood="3283" nimi="Koigi küla"/><asula kood="3294" nimi="Koikse küla"/><asula kood="3541" nimi="Kuimetsa küla"/><asula kood="3569" nimi="Kuku küla"/><asula kood="3720" nimi="Kuusiku alevik"/><asula kood="3724" nimi="Kuusiku-Nõmme küla"/><asula kood="3799" nimi="Kõrgu küla"/><asula kood="4413" nimi="Lipa küla"/><asula kood="4416" nimi="Lipametsa küla"/><asula kood="4421" nimi="Lipstu küla"/><asula kood="4443" nimi="Loe küla"/><asula kood="4602" nimi="Lõiuse küla"/><asula kood="4614" nimi="Lõpemetsa küla"/><asula kood="4728" nimi="Mahlamäe küla"/><asula kood="4733" nimi="Mahtra küla"/><asula kood="4741" nimi="Maidla küla"/><asula kood="4924" nimi="Metsküla"/><asula kood="5126" nimi="Mõisaaseme küla"/><asula kood="5254" nimi="Mällu küla"/><asula kood="5520" nimi="Nõmme küla"/><asula kood="5516" nimi="Nõmmemetsa küla"/><asula kood="5522" nimi="Nõmmküla"/><asula kood="5588" nimi="Oblu küla"/><asula kood="5608" nimi="Oela küla"/><asula kood="5634" nimi="Ohulepa küla"/><asula kood="5687" nimi="Oola küla"/><asula kood="5717" nimi="Orguse küla"/><asula kood="5911" nimi="Palamulla küla"/><asula kood="6274" nimi="Pirgu küla"/><asula kood="6443" nimi="Purila küla"/><asula kood="6445" nimi="Purku küla"/><asula kood="6526" nimi="Põlliku küla"/><asula kood="6533" nimi="Põlma küla"/><asula kood="6719" nimi="Raela küla"/><asula kood="6758" nimi="Raikküla"/><asula kood="6772" nimi="Raka küla"/><asula kood="6826" nimi="Rapla linn"/><asula kood="6954" nimi="Ridaküla"/><asula kood="7255" nimi="Röa küla"/><asula kood="7319" nimi="Sadala küla"/><asula kood="7518" nimi="Seli küla"/><asula kood="5470" nimi="Seli-Nurme küla"/><asula kood="7586" nimi="Sikeldi küla"/><asula kood="7796" nimi="Sulupere küla"/><asula kood="7840" nimi="Suurekivi küla"/><asula kood="8138" nimi="Tamsi küla"/><asula kood="8139" nimi="Tapupere küla"/><asula kood="8279" nimi="Tolla küla"/><asula kood="8305" nimi="Toomja küla"/><asula kood="8441" nimi="Tuti küla"/><asula kood="8518" nimi="Tõrma küla"/><asula kood="8677" nimi="Ummaru küla"/><asula kood="8788" nimi="Uusküla"/><asula kood="8838" nimi="Vahakõnnu küla"/><asula kood="8842" nimi="Vahastu küla"/><asula kood="8961" nimi="Valli küla"/><asula kood="8971" nimi="Valtu küla"/><asula kood="8982" nimi="Vana-Kaiu küla"/><asula kood="9046" nimi="Vankse küla"/><asula kood="9050" nimi="Vaopere küla"/><asula kood="4318" nimi="Väljataguse küla"/><asula kood="9729" nimi="Äherdi küla"/><asula kood="9831" nimi="Ülejõe küla"/></vald></maakond><maakond kood="0074" nimi="Saare maakond"><vald kood="0478" nimi="Muhu vald"><asula kood="1196" nimi="Aljava küla"/><asula kood="1808" nimi="Hellamaa küla"/><asula kood="1990" nimi="Igaküla"/><asula kood="2597" nimi="Kallaste küla"/><asula kood="2691" nimi="Kantsi küla"/><asula kood="2695" nimi="Kapi küla"/><asula kood="2987" nimi="Kesse küla"/><asula kood="3260" nimi="Koguva küla"/><asula kood="3549" nimi="Kuivastu küla"/><asula kood="3983" nimi="Külasema küla"/><asula kood="4058" nimi="Laheküla"/><asula kood="4083" nimi="Lalli küla"/><asula kood="4189" nimi="Leeskopa küla"/><asula kood="4215" nimi="Lehtmetsa küla"/><asula kood="4292" nimi="Lepiku küla"/><asula kood="4311" nimi="Levalõpme küla"/><asula kood="4353" nimi="Liiva küla"/><asula kood="4407" nimi="Linnuse küla"/><asula kood="4595" nimi="Lõetsa küla"/><asula kood="5120" nimi="Mõega küla"/><asula kood="5130" nimi="Mõisaküla"/><asula kood="5243" nimi="Mäla küla"/><asula kood="5370" nimi="Nautse küla"/><asula kood="5475" nimi="Nurme küla"/><asula kood="5524" nimi="Nõmmküla"/><asula kood="5639" nimi="Oina küla"/><asula kood="5831" nimi="Paenase küla"/><asula kood="5931" nimi="Pallasmaa küla"/><asula kood="6184" nimi="Piiri küla"/><asula kood="6638" nimi="Põitse küla"/><asula kood="6556" nimi="Pädaste küla"/><asula kood="6559" nimi="Päelda küla"/><asula kood="6598" nimi="Pärase küla"/><asula kood="6715" nimi="Raegma küla"/><asula kood="6817" nimi="Rannaküla"/><asula kood="6861" nimi="Raugi küla"/><asula kood="6888" nimi="Rebaski küla"/><asula kood="6965" nimi="Ridasi küla"/><asula kood="7006" nimi="Rinsi küla"/><asula kood="7093" nimi="Rootsivere küla"/><asula kood="7223" nimi="Rässa küla"/><asula kood="7601" nimi="Simiste küla"/><asula kood="7724" nimi="Soonda küla"/><asula kood="7847" nimi="Suuremõisa küla"/><asula kood="8136" nimi="Tamse küla"/><asula kood="8418" nimi="Tupenurme küla"/><asula kood="8440" nimi="Tusti küla"/><asula kood="8851" nimi="Vahtraste küla"/><asula kood="9027" nimi="Vanamõisa küla"/><asula kood="9285" nimi="Viira küla"/><asula kood="9531" nimi="Võiküla"/><asula kood="9554" nimi="Võlla küla"/></vald><vald kood="0689" nimi="Ruhnu vald"><asula kood="7105" nimi="Ruhnu küla"/></vald><vald kood="0714" nimi="Saaremaa vald"><asula kood="1052" nimi="Aaviku küla"/><asula kood="1054" nimi="Abaja küla"/><asula kood="1064" nimi="Abruka küla"/><asula kood="1067" nimi="Abula küla"/><asula kood="1207" nimi="Allikalahe küla"/><asula kood="1268" nimi="Anepesa küla"/><asula kood="1272" nimi="Angla küla"/><asula kood="1280" nimi="Anijala küla"/><asula kood="1297" nimi="Anseküla"/><asula kood="1300" nimi="Ansi küla"/><asula kood="1313" nimi="Arandi küla"/><asula kood="1337" nimi="Ardla küla"/><asula kood="1346" nimi="Are küla"/><asula kood="1348" nimi="Ariste küla"/><asula kood="1357" nimi="Arju küla"/><asula kood="1364" nimi="Aru küla"/><asula kood="1389" nimi="Aruste küla"/><asula kood="1416" nimi="Aste alevik"/><asula kood="1417" nimi="Aste küla"/><asula kood="1424" nimi="Asuka küla"/><asula kood="1426" nimi="Asuküla"/><asula kood="1429" nimi="Asva küla"/><asula kood="1436" nimi="Atla küla"/><asula kood="1455" nimi="Audla küla"/><asula kood="1466" nimi="Aula-Vintri küla"/><asula kood="1470" nimi="Austla küla"/><asula kood="1514" nimi="Easte küla"/><asula kood="1530" nimi="Eeriksaare küla"/><asula kood="1553" nimi="Eikla küla"/><asula kood="1564" nimi="Eiste küla"/><asula kood="1599" nimi="Endla küla"/><asula kood="1606" nimi="Ennu küla"/><asula kood="1686" nimi="Haamse küla"/><asula kood="1695" nimi="Haapsu küla"/><asula kood="1712" nimi="Haeska küla"/><asula kood="1731" nimi="Hakjala küla"/><asula kood="1836" nimi="Hiievälja küla"/><asula kood="1850" nimi="Himmiste küla"/><asula kood="1853" nimi="Hindu küla"/><asula kood="1874" nimi="Hirmuste küla"/><asula kood="1939" nimi="Hämmelepa küla"/><asula kood="1940" nimi="Hänga küla"/><asula kood="1965" nimi="Hübja küla"/><asula kood="2014" nimi="Iide küla"/><asula kood="2022" nimi="Iilaste küla"/><asula kood="2056" nimi="Ilpla küla"/><asula kood="2066" nimi="Imara küla"/><asula kood="2074" nimi="Imavere küla"/><asula kood="2097" nimi="Irase küla"/><asula kood="2103" nimi="Iruste küla"/><asula kood="2148" nimi="Jaani küla"/><asula kood="2178" nimi="Jauni küla"/><asula kood="2200" nimi="Jootme küla"/><asula kood="2215" nimi="Jursi küla"/><asula kood="2225" nimi="Jõe küla"/><asula kood="2231" nimi="Jõelepa küla"/><asula kood="2239" nimi="Jõempa küla"/><asula kood="2260" nimi="Jõgela küla"/><asula kood="2274" nimi="Jõiste küla"/><asula kood="2310" nimi="Jämaja küla"/><asula kood="2324" nimi="Järise küla"/><asula kood="2366" nimi="Järve küla"/><asula kood="2356" nimi="Järveküla"/><asula kood="2292" nimi="Jööri küla"/><asula kood="2398" nimi="Kaali küla"/><asula kood="2397" nimi="Kaali-Liiva küla"/><asula kood="2414" nimi="Kaarma küla"/><asula kood="2412" nimi="Kaarma-Jõe küla"/><asula kood="3122" nimi="Kaarma-Kirikuküla"/><asula kood="2413" nimi="Kaarma-Kungla küla"/><asula kood="2416" nimi="Kaarmise küla"/><asula kood="2442" nimi="Kaavi küla"/><asula kood="2517" nimi="Kahtla küla"/><asula kood="2522" nimi="Kahutsi küla"/><asula kood="2538" nimi="Kailuka küla"/><asula kood="2541" nimi="Kaimri küla"/><asula kood="2543" nimi="Kaisa küla"/><asula kood="2548" nimi="Kaisvere küla"/><asula kood="2557" nimi="Kakuna küla"/><asula kood="2594" nimi="Kalju küla"/><asula kood="2599" nimi="Kallaste küla"/><asula kood="2603" nimi="Kallemäe küla"/><asula kood="2605" nimi="Kalli küla"/><asula kood="2620" nimi="Kalma küla"/><asula kood="2624" nimi="Kalmu küla"/><asula kood="2662" nimi="Kandla küla"/><asula kood="2672" nimi="Kangrusselja küla"/><asula kood="2878" nimi="Kanissaare küla"/><asula kood="2697" nimi="Kapra küla"/><asula kood="2705" nimi="Karala küla"/><asula kood="2713" nimi="Kareda küla"/><asula kood="2720" nimi="Kargi küla"/><asula kood="2722" nimi="Karida küla"/><asula kood="2747" nimi="Karja küla"/><asula kood="1498" nimi="Karujärve küla"/><asula kood="2785" nimi="Karuste küla"/><asula kood="2823" nimi="Kasti küla"/><asula kood="2857" nimi="Kaubi küla"/><asula kood="2864" nimi="Kaugatoma küla"/><asula kood="2874" nimi="Kaunispe küla"/><asula kood="2888" nimi="Kavandi küla"/><asula kood="2922" nimi="Kehila küla"/><asula kood="2935" nimi="Kellamäe küla"/><asula kood="2982" nimi="Keskranna küla"/><asula kood="2985" nimi="Keskvere küla"/><asula kood="3012" nimi="Kihelkonna alevik"/><asula kood="3013" nimi="Kihelkonna-Liiva küla"/><asula kood="3045" nimi="Kiirassaare küla"/><asula kood="3098" nimi="Kingli küla"/><asula kood="3106" nimi="Kipi küla"/><asula kood="3111" nimi="Kiratsi küla"/><asula kood="3118" nimi="Kirderanna küla"/><asula kood="3138" nimi="Kiritu küla"/><asula kood="3152" nimi="Kiruma küla"/><asula kood="3258" nimi="Kogula küla"/><asula kood="3278" nimi="Koidula küla"/><asula kood="3279" nimi="Koiduvälja küla"/><asula kood="3284" nimi="Koigi küla"/><asula kood="3290" nimi="Koigi-Väljaküla"/><asula kood="3292" nimi="Koikla küla"/><asula kood="3298" nimi="Koimla küla"/><asula kood="3320" nimi="Koki küla"/><asula kood="3325" nimi="Koksi küla"/><asula kood="3431" nimi="Koovi küla"/><asula kood="3437" nimi="Kopli küla"/><asula kood="3482" nimi="Kotlandi küla"/><asula kood="3483" nimi="Kotsma küla"/><asula kood="3519" nimi="Kudjape alevik"/><asula kood="3521" nimi="Kugalepa küla"/><asula kood="3544" nimi="Kuiste küla"/><asula kood="3550" nimi="Kuke küla"/><asula kood="3614" nimi="Kungla küla"/><asula kood="3625" nimi="Kuninguste küla"/><asula kood="3632" nimi="Kuralase küla"/><asula kood="3643" nimi="Kuremetsa küla"/><asula kood="3655" nimi="Kuressaare linn"/><asula kood="3661" nimi="Kurevere küla"/><asula kood="3712" nimi="Kuumi küla"/><asula kood="3715" nimi="Kuuse küla"/><asula kood="3719" nimi="Kuusiku küla"/><asula kood="3726" nimi="Kuusnõmme küla"/><asula kood="3744" nimi="Kõiguste küla"/><asula kood="3747" nimi="Kõinastu küla"/><asula kood="3757" nimi="Kõljala küla"/><asula kood="3774" nimi="Kõnnu küla"/><asula kood="3800" nimi="Kõriska küla"/><asula kood="3805" nimi="Kõrkküla"/><asula kood="3807" nimi="Kõrkvere küla"/><asula kood="3817" nimi="Kõruse küla"/><asula kood="3816" nimi="Kõruse-Metsaküla"/><asula kood="3843" nimi="Kõõru küla"/><asula kood="3860" nimi="Käesla küla"/><asula kood="3870" nimi="Käku küla"/><asula kood="3882" nimi="Käo küla"/><asula kood="3896" nimi="Kärdu küla"/><asula kood="3916" nimi="Kärla alevik"/><asula kood="3123" nimi="Kärla-Kirikuküla"/><asula kood="3598" nimi="Kärla-Kulli küla"/><asula kood="3922" nimi="Kärneri küla"/><asula kood="3964" nimi="Kübassaare küla"/><asula kood="3967" nimi="Küdema küla"/><asula kood="3989" nimi="Külma küla"/><asula kood="4007" nimi="Laadjala küla"/><asula kood="4009" nimi="Laadla küla"/><asula kood="4041" nimi="Laevaranna küla"/><asula kood="4053" nimi="Laheküla"/><asula kood="4057" nimi="Lahetaguse küla"/><asula kood="4073" nimi="Laimjala küla"/><asula kood="4110" nimi="Laoküla"/><asula kood="4129" nimi="Lassi küla"/><asula kood="4138" nimi="Laugu küla"/><asula kood="4137" nimi="Laugu-Liiva küla"/><asula kood="4180" nimi="Leedri küla"/><asula kood="4233" nimi="Leina küla"/><asula kood="4237" nimi="Leisi alevik"/><asula kood="4238" nimi="Leisi küla"/><asula kood="4310" nimi="Levala küla"/><asula kood="4335" nimi="Liigalaskma küla"/><asula kood="4345" nimi="Liiküla"/><asula kood="4363" nimi="Liiva küla"/><asula kood="4366" nimi="Liiva-Putla küla"/><asula kood="4346" nimi="Liivanõmme küla"/><asula kood="4343" nimi="Liivaranna küla"/><asula kood="4368" nimi="Lilbi küla"/><asula kood="4385" nimi="Lindmetsa küla"/><asula kood="4395" nimi="Linnaka küla"/><asula kood="4409" nimi="Linnuse küla"/><asula kood="4509" nimi="Loona küla"/><asula kood="4561" nimi="Lussu küla"/><asula kood="4581" nimi="Luulupe küla"/><asula kood="4604" nimi="Lõmala küla"/><asula kood="4615" nimi="Lõpi küla"/><asula kood="4608" nimi="Lõu küla"/><asula kood="4609" nimi="Lõupõllu küla"/><asula kood="4666" nimi="Läbara küla"/><asula kood="4636" nimi="Länga küla"/><asula kood="4649" nimi="Lätiniidi küla"/><asula kood="4653" nimi="Läägi küla"/><asula kood="4661" nimi="Läätsa küla"/><asula kood="4665" nimi="Lööne küla"/><asula kood="4675" nimi="Lülle küla"/><asula kood="4679" nimi="Lümanda küla"/><asula kood="3601" nimi="Lümanda-Kulli küla"/><asula kood="4700" nimi="Maantee küla"/><asula kood="4713" nimi="Maasi küla"/><asula kood="4754" nimi="Maleva küla"/><asula kood="4803" nimi="Masa küla"/><asula kood="4826" nimi="Matsiranna küla"/><asula kood="4834" nimi="Meedla küla"/><asula kood="4855" nimi="Mehama küla"/><asula kood="4862" nimi="Meiuste küla"/><asula kood="4888" nimi="Merise küla"/><asula kood="4894" nimi="Metsaküla"/><asula kood="4899" nimi="Metsalõuka küla"/><asula kood="4907" nimi="Metsapere küla"/><asula kood="4909" nimi="Metsara küla"/><asula kood="4917" nimi="Metsaääre küla"/><asula kood="4922" nimi="Metsküla"/><asula kood="4984" nimi="Moosi küla"/><asula kood="5006" nimi="Mui küla"/><asula kood="5012" nimi="Mujaste küla"/><asula kood="5025" nimi="Mullutu küla"/><asula kood="5034" nimi="Muraja küla"/><asula kood="5044" nimi="Muratsi küla"/><asula kood="5050" nimi="Murika küla"/><asula kood="5080" nimi="Mustjala küla"/><asula kood="5087" nimi="Mustla küla"/><asula kood="5139" nimi="Mõisaküla"/><asula kood="5154" nimi="Mõnnuste küla"/><asula kood="5155" nimi="Mõntu küla"/><asula kood="5190" nimi="Mäebe küla"/><asula kood="5214" nimi="Mäeküla"/><asula kood="5220" nimi="Mägi-Kurdla küla"/><asula kood="5257" nimi="Mändjala küla"/><asula kood="5265" nimi="Männiku küla"/><asula kood="5282" nimi="Mässa küla"/><asula kood="5284" nimi="Mätasselja küla"/><asula kood="5287" nimi="Mätja küla"/><asula kood="5308" nimi="Möldri küla"/><asula kood="5361" nimi="Nasva alevik"/><asula kood="5374" nimi="Nava küla"/><asula kood="5388" nimi="Neeme küla"/><asula kood="5390" nimi="Neemi küla"/><asula kood="5401" nimi="Nenu küla"/><asula kood="5414" nimi="Nihatu küla"/><asula kood="5428" nimi="Ninase küla"/><asula kood="5472" nimi="Nurme küla"/><asula kood="5505" nimi="Nõmjala küla"/><asula kood="5519" nimi="Nõmme küla"/><asula kood="5528" nimi="Nõmpa küla"/><asula kood="5560" nimi="Nässuma küla"/><asula kood="5592" nimi="Odalätsi küla"/><asula kood="5612" nimi="Oessaare küla"/><asula kood="5621" nimi="Ohessaare küla"/><asula kood="5623" nimi="Ohtja küla"/><asula kood="5644" nimi="Oitme küla"/><asula kood="5657" nimi="Oju küla"/><asula kood="5723" nimi="Orinõmme küla"/><asula kood="5725" nimi="Orissaare alevik"/><asula kood="5757" nimi="Oti küla"/><asula kood="5792" nimi="Paaste küla"/><asula kood="5799" nimi="Paatsa küla"/><asula kood="5836" nimi="Paevere küla"/><asula kood="5847" nimi="Pahapilli küla"/><asula kood="5849" nimi="Pahavalla küla"/><asula kood="5867" nimi="Paiküla"/><asula kood="5868" nimi="Paimala küla"/><asula kood="5882" nimi="Paju-Kurdla küla"/><asula kood="5890" nimi="Pajumõisa küla"/><asula kood="5965" nimi="Pamma küla"/><asula kood="5967" nimi="Pammana küla"/><asula kood="5973" nimi="Panga küla"/><asula kood="5994" nimi="Parasmetsa küla"/><asula kood="6010" nimi="Parila küla"/><asula kood="6077" nimi="Peederga küla"/><asula kood="6137" nimi="Pidula küla"/><asula kood="6138" nimi="Pidula-Kuusiku küla"/><asula kood="6153" nimi="Pihtla küla"/><asula kood="6169" nimi="Piila küla"/><asula kood="6312" nimi="Poka küla"/><asula kood="6343" nimi="Praakli küla"/><asula kood="6418" nimi="Puka küla"/><asula kood="6427" nimi="Pulli küla"/><asula kood="6448" nimi="Purtsa küla"/><asula kood="6534" nimi="Põlluküla"/><asula kood="6542" nimi="Põripõllu küla"/><asula kood="6562" nimi="Pähkla küla"/><asula kood="6614" nimi="Pärni küla"/><asula kood="6618" nimi="Pärsama küla"/><asula kood="6635" nimi="Pöide küla"/><asula kood="6636" nimi="Pöide-Keskvere küla"/><asula kood="6639" nimi="Pöitse küla"/><asula kood="6653" nimi="Püha küla"/><asula kood="6654" nimi="Püha-Kõnnu küla"/><asula kood="6730" nimi="Rahniku küla"/><asula kood="6734" nimi="Rahtla küla"/><asula kood="6737" nimi="Rahu küla"/><asula kood="6745" nimi="Rahuste küla"/><asula kood="6794" nimi="Randküla"/><asula kood="6799" nimi="Randvere küla"/><asula kood="6818" nimi="Rannaküla"/><asula kood="6842" nimi="Ratla küla"/><asula kood="6862" nimi="Raugu küla"/><asula kood="6899" nimi="Reeküla"/><asula kood="6913" nimi="Reina küla"/><asula kood="6930" nimi="Reo küla"/><asula kood="6960" nimi="Ridala küla"/><asula kood="6997" nimi="Riksu küla"/><asula kood="7051" nimi="Roobaka küla"/><asula kood="7088" nimi="Rootsiküla"/><asula kood="7107" nimi="Ruhve küla"/><asula kood="7200" nimi="Räimaste küla"/><asula kood="7234" nimi="Räägi küla"/><asula kood="7258" nimi="Röösa küla"/><asula kood="7294" nimi="Saareküla"/><asula kood="7291" nimi="Saaremetsa küla"/><asula kood="7330" nimi="Sagariste küla"/><asula kood="7340" nimi="Saia küla"/><asula kood="7345" nimi="Saikla küla"/><asula kood="7351" nimi="Sakla küla"/><asula kood="7372" nimi="Salavere küla"/><asula kood="7387" nimi="Salme alevik"/><asula kood="7403" nimi="Salu küla"/><asula kood="7413" nimi="Sandla küla"/><asula kood="7450" nimi="Sauaru küla"/><asula kood="7470" nimi="Saue-Mustla küla"/><asula kood="7451" nimi="Saue-Putla küla"/><asula kood="7473" nimi="Sauvere küla"/><asula kood="7513" nimi="Selgase küla"/><asula kood="7537" nimi="Selja küla"/><asula kood="7543" nimi="Sepa küla"/><asula kood="7545" nimi="Sepise küla"/><asula kood="7568" nimi="Siiksaare küla"/><asula kood="7584" nimi="Sikassaare küla"/><asula kood="7596" nimi="Silla küla"/><asula kood="7658" nimi="Soela küla"/><asula kood="7689" nimi="Soodevahe küla"/><asula kood="7799" nimi="Sundimetsa küla"/><asula kood="7822" nimi="Sutu küla"/><asula kood="7826" nimi="Suur-Pahila küla"/><asula kood="7827" nimi="Suur-Rahula küla"/><asula kood="7837" nimi="Suur-Randvere küla"/><asula kood="7834" nimi="Suure-Rootsi küla"/><asula kood="7861" nimi="Suurna küla"/><asula kood="7885" nimi="Sõmera küla"/><asula kood="7906" nimi="Sõrve-Hindu küla"/><asula kood="7950" nimi="Sääre küla"/><asula kood="7998" nimi="Taaliku küla"/><asula kood="8049" nimi="Tagamõisa küla"/><asula kood="8053" nimi="Tagaranna küla"/><asula kood="8059" nimi="Tagavere küla"/><asula kood="8076" nimi="Tahula küla"/><asula kood="8084" nimi="Talila küla"/><asula kood="8099" nimi="Tammese küla"/><asula kood="8128" nimi="Tammuna küla"/><asula kood="8153" nimi="Tareste küla"/><asula kood="8158" nimi="Taritu küla"/><asula kood="8185" nimi="Tehumardi küla"/><asula kood="8227" nimi="Tiirimetsa küla"/><asula kood="8230" nimi="Tiitsuotsa küla"/><asula kood="8253" nimi="Tirbi küla"/><asula kood="8270" nimi="Tohku küla"/><asula kood="8298" nimi="Toomalõuka küla"/><asula kood="8323" nimi="Torgu-Mõisaküla"/><asula kood="8336" nimi="Tornimäe küla"/><asula kood="8347" nimi="Triigi küla"/><asula kood="8406" nimi="Tuiu küla"/><asula kood="8412" nimi="Tumala küla"/><asula kood="8426" nimi="Turja küla"/><asula kood="8443" nimi="Tutku küla"/><asula kood="8489" nimi="Tõlli küla"/><asula kood="8493" nimi="Tõlluste küla"/><asula kood="8502" nimi="Tõnija küla"/><asula kood="8516" nimi="Tõre küla"/><asula kood="8517" nimi="Tõrise küla"/><asula kood="8526" nimi="Tõru küla"/><asula kood="8587" nimi="Täätsi küla"/><asula kood="8600" nimi="Türju küla"/><asula kood="8625" nimi="Uduvere küla"/><asula kood="8652" nimi="Ula küla"/><asula kood="8662" nimi="Ulje küla"/><asula kood="8683" nimi="Undimäe küla"/><asula kood="8692" nimi="Undva küla"/><asula kood="8693" nimi="Unguma küla"/><asula kood="8697" nimi="Unimäe küla"/><asula kood="8708" nimi="Upa küla"/><asula kood="8771" nimi="Uuemõisa küla"/><asula kood="8859" nimi="Vahva küla"/><asula kood="8870" nimi="Vaigu küla"/><asula kood="8871" nimi="Vaigu-Rannaküla"/><asula kood="8898" nimi="Vaivere küla"/><asula kood="8951" nimi="Valjala alevik"/><asula kood="8950" nimi="Valjala-Ariste küla"/><asula kood="8952" nimi="Valjala-Kogula küla"/><asula kood="8953" nimi="Valjala-Nurme küla"/><asula kood="8990" nimi="Vana-Lahetaguse küla"/><asula kood="9013" nimi="Vanakubja küla"/><asula kood="9018" nimi="Vanalõve küla"/><asula kood="9022" nimi="Vanamõisa küla"/><asula kood="9045" nimi="Vantri küla"/><asula kood="9089" nimi="Varkja küla"/><asula kood="9093" nimi="Varpe küla"/><asula kood="9145" nimi="Vatsküla"/><asula kood="9158" nimi="Vedruka küla"/><asula kood="9171" nimi="Veere küla"/><asula kood="9173" nimi="Veeremäe küla"/><asula kood="9172" nimi="Veeriku küla"/><asula kood="9197" nimi="Vendise küla"/><asula kood="9206" nimi="Vennati küla"/><asula kood="9226" nimi="Veske küla"/><asula kood="9241" nimi="Vestla küla"/><asula kood="9275" nimi="Viidu küla"/><asula kood="9276" nimi="Viidu-Mäebe küla"/><asula kood="9293" nimi="Viira küla"/><asula kood="9315" nimi="Viki küla"/><asula kood="9328" nimi="Vilidu küla"/><asula kood="9357" nimi="Vilsandi küla"/><asula kood="9360" nimi="Viltina küla"/><asula kood="9378" nimi="Vintri küla"/><asula kood="9383" nimi="Virita küla"/><asula kood="9497" nimi="Võhma küla"/><asula kood="9581" nimi="Võrsna küla"/><asula kood="9629" nimi="Väike-Pahila küla"/><asula kood="9632" nimi="Väike-Rahula küla"/><asula kood="9634" nimi="Väike-Rootsi küla"/><asula kood="9627" nimi="Väike-Ula küla"/><asula kood="9630" nimi="Väike-Võhma küla"/><asula kood="9642" nimi="Väkra küla"/><asula kood="9649" nimi="Väljaküla"/><asula kood="9660" nimi="Väljamõisa küla"/><asula kood="9658" nimi="Välta küla"/><asula kood="9799" nimi="Õeste küla"/><asula kood="9800" nimi="Õha küla"/><asula kood="9804" nimi="Ööriku küla"/><asula kood="9849" nimi="Üru küla"/><asula kood="9855" nimi="Üüdibe küla"/><asula kood="9854" nimi="Üüvere küla"/></vald></maakond><maakond kood="0079" nimi="Tartu maakond"><vald kood="0171" nimi="Elva vald"><asula kood="1018" nimi="Aakre küla"/><asula kood="1291" nimi="Annikoru küla"/><asula kood="1418" nimi="Astuvere küla"/><asula kood="1440" nimi="Atra küla"/><asula kood="1586" nimi="Elva linn"/><asula kood="1643" nimi="Ervu küla"/><asula kood="1813" nimi="Hellenurme küla"/><asula kood="1951" nimi="Härjanurme küla"/><asula kood="2348" nimi="Järvaküla"/><asula kood="2351" nimi="Järveküla"/><asula kood="2409" nimi="Kaarlijärve küla"/><asula kood="2540" nimi="Kaimi küla"/><asula kood="2622" nimi="Kalme küla"/><asula kood="2699" nimi="Kapsta küla"/><asula kood="2725" nimi="Karijärve küla"/><asula kood="3103" nimi="Kipastu küla"/><asula kood="3121" nimi="Kirepi küla"/><asula kood="3216" nimi="Kobilu küla"/><asula kood="3372" nimi="Konguta küla"/><asula kood="3412" nimi="Koopsi küla"/><asula kood="3457" nimi="Koruste küla"/><asula kood="3595" nimi="Kulli küla"/><asula kood="3633" nimi="Kureküla"/><asula kood="3637" nimi="Kureküla alevik"/><asula kood="3639" nimi="Kurelaane küla"/><asula kood="3738" nimi="Kõduküla"/><asula kood="3881" nimi="Käo küla"/><asula kood="3949" nimi="Käärdi alevik"/><asula kood="3973" nimi="Külaaseme küla"/><asula kood="4117" nimi="Lapetukme küla"/><asula kood="4256" nimi="Lembevere küla"/><asula kood="4527" nimi="Lossimäe küla"/><asula kood="4749" nimi="Majala küla"/><asula kood="4895" nimi="Metsalaane küla"/><asula kood="5138" nimi="Mõisanurme küla"/><asula kood="5198" nimi="Mäelooga küla"/><asula kood="5206" nimi="Mäeotsa küla"/><asula kood="5211" nimi="Mäeselja küla"/><asula kood="5248" nimi="Mälgi küla"/><asula kood="5358" nimi="Nasja küla"/><asula kood="5393" nimi="Neemisküla"/><asula kood="5447" nimi="Noorma küla"/><asula kood="5880" nimi="Paju küla"/><asula kood="5916" nimi="Palamuste küla"/><asula kood="5952" nimi="Palupera küla"/><asula kood="5957" nimi="Palupõhja küla"/><asula kood="6031" nimi="Pastaku küla"/><asula kood="6071" nimi="Pedaste küla"/><asula kood="6164" nimi="Piigandi küla"/><asula kood="6322" nimi="Poole küla"/><asula kood="6328" nimi="Poriküla"/><asula kood="6393" nimi="Puhja alevik"/><asula kood="6453" nimi="Purtsi küla"/><asula kood="6648" nimi="Pööritsa küla"/><asula kood="6663" nimi="Pühaste küla"/><asula kood="6748" nimi="Raigaste küla"/><asula kood="6809" nimi="Rannaküla"/><asula kood="6822" nimi="Rannu alevik"/><asula kood="6890" nimi="Rebaste küla"/><asula kood="6955" nimi="Ridaküla"/><asula kood="7167" nimi="Rõngu alevik"/><asula kood="7208" nimi="Rämsi küla"/><asula kood="7282" nimi="Saare küla"/><asula kood="7420" nimi="Sangla küla"/><asula kood="7833" nimi="Suure-Rakke küla"/><asula kood="8094" nimi="Tamme küla"/><asula kood="8121" nimi="Tammiste küla"/><asula kood="8180" nimi="Teedla küla"/><asula kood="8189" nimi="Teilma küla"/><asula kood="8238" nimi="Tilga küla"/><asula kood="8575" nimi="Tännassilma küla"/><asula kood="8614" nimi="Uderna küla"/><asula kood="8655" nimi="Ulila alevik"/><asula kood="8727" nimi="Urmi küla"/><asula kood="8750" nimi="Utukolga küla"/><asula kood="8846" nimi="Vahessaare küla"/><asula kood="8941" nimi="Valguta küla"/><asula kood="8959" nimi="Vallapalu küla"/><asula kood="9178" nimi="Vehendi küla"/><asula kood="9191" nimi="Vellavere küla"/><asula kood="9211" nimi="Verevi küla"/><asula kood="9260" nimi="Vihavu küla"/><asula kood="2842" nimi="Võllinge küla"/><asula kood="9591" nimi="Võsivere küla"/><asula kood="9633" nimi="Väike-Rakke küla"/></vald><vald kood="0283" nimi="Kambja vald"><asula kood="1016" nimi="Aakaru küla"/><asula kood="2119" nimi="Ivaste küla"/><asula kood="2433" nimi="Kaatsi küla"/><asula kood="2641" nimi="Kambja alevik"/><asula kood="2644" nimi="Kammeri küla"/><asula kood="2891" nimi="Kavandu küla"/><asula kood="3239" nimi="Kodijärve küla"/><asula kood="3585" nimi="Kullaga küla"/><asula kood="3804" nimi="Kõrkküla"/><asula kood="3986" nimi="Külitse alevik"/><asula kood="4017" nimi="Laane küla"/><asula kood="4085" nimi="Lalli küla"/><asula kood="4266" nimi="Lemmatsi küla"/><asula kood="4291" nimi="Lepiku küla"/><asula kood="4648" nimi="Läti küla"/><asula kood="4720" nimi="Madise küla"/><asula kood="5194" nimi="Mäeküla"/><asula kood="5690" nimi="Oomiste küla"/><asula kood="5784" nimi="Paali küla"/><asula kood="5949" nimi="Palumäe küla"/><asula kood="5975" nimi="Pangodi küla"/><asula kood="6426" nimi="Pulli küla"/><asula kood="6666" nimi="Pühi küla"/><asula kood="6692" nimi="Raanitsa küla"/><asula kood="6884" nimi="Rebase küla"/><asula kood="6932" nimi="Reola küla"/><asula kood="6935" nimi="Reolasoo küla"/><asula kood="6994" nimi="Riiviku küla"/><asula kood="7214" nimi="Räni alevik"/><asula kood="7624" nimi="Sipe küla"/><asula kood="7642" nimi="Sirvaku küla"/><asula kood="7666" nimi="Soinaste küla"/><asula kood="7743" nimi="Soosilla küla"/><asula kood="7793" nimi="Sulu küla"/><asula kood="7828" nimi="Suure-Kambja küla"/><asula kood="8085" nimi="Talvikese küla"/><asula kood="8165" nimi="Tatra küla"/><asula kood="8532" nimi="Tõrvandi alevik"/><asula kood="8581" nimi="Täsvere küla"/><asula kood="8632" nimi="Uhti küla"/><asula kood="8992" nimi="Vana-Kuuste küla"/><asula kood="9404" nimi="Virulase küla"/><asula kood="9419" nimi="Visnapuu küla"/><asula kood="9717" nimi="Õssu küla"/><asula kood="9835" nimi="Ülenurme alevik"/></vald><vald kood="0291" nimi="Kastre vald"><asula kood="1010" nimi="Aadami küla"/><asula kood="1024" nimi="Aardla küla"/><asula kood="1022" nimi="Aardlapalu küla"/><asula kood="1097" nimi="Agali küla"/><asula kood="1125" nimi="Ahunapalu küla"/><asula kood="1167" nimi="Alaküla"/><asula kood="1365" nimi="Aruaia küla"/><asula kood="1696" nimi="Haaslava küla"/><asula kood="1752" nimi="Hammaste küla"/><asula kood="1997" nimi="Igevere küla"/><asula kood="2000" nimi="Ignase küla"/><asula kood="2076" nimi="Imste küla"/><asula kood="2112" nimi="Issaku küla"/><asula kood="2367" nimi="Järvselja küla"/><asula kood="2393" nimi="Kaagvere küla"/><asula kood="2411" nimi="Kaarlimõisa küla"/><asula kood="2682" nimi="Kannu küla"/><asula kood="2840" nimi="Kastre küla"/><asula kood="3167" nimi="Kitseküla"/><asula kood="3315" nimi="Koke küla"/><asula kood="3500" nimi="Kriimani küla"/><asula kood="3652" nimi="Kurepalu küla"/><asula kood="3677" nimi="Kurista küla"/><asula kood="3748" nimi="Kõivuküla"/><asula kood="3772" nimi="Kõnnu küla"/><asula kood="4099" nimi="Lange küla"/><asula kood="4349" nimi="Liispõllu küla"/><asula kood="4658" nimi="Lääniste küla"/><asula kood="4868" nimi="Melliste küla"/><asula kood="4906" nimi="Metsanurga küla"/><asula kood="5160" nimi="Mõra küla"/><asula kood="5240" nimi="Mäksa küla"/><asula kood="5245" nimi="Mäletjärve küla"/><asula kood="5944" nimi="Paluküla"/><asula kood="6311" nimi="Poka küla"/><asula kood="6584" nimi="Päkste küla"/><asula kood="7042" nimi="Roiu alevik"/><asula kood="7066" nimi="Rookse küla"/><asula kood="7161" nimi="Rõka küla"/><asula kood="7423" nimi="Sarakuste küla"/><asula kood="7764" nimi="Sudaste küla"/><asula kood="8107" nimi="Tammevaldma küla"/><asula kood="8201" nimi="Terikeste küla"/><asula kood="8211" nimi="Tigase küla"/><asula kood="8551" nimi="Tõõraste küla"/><asula kood="8695" nimi="Uniküla"/><asula kood="8987" nimi="Vana-Kastre küla"/><asula kood="9234" nimi="Veskimäe küla"/><asula kood="9570" nimi="Võnnu alevik"/><asula kood="9583" nimi="Võruküla"/><asula kood="9605" nimi="Võõpste küla"/></vald><vald kood="0432" nimi="Luunja vald"><asula kood="2459" nimi="Kabina küla"/><asula kood="2556" nimi="Kakumetsa küla"/><asula kood="2897" nimi="Kavastu küla"/><asula kood="3059" nimi="Kikaste küla"/><asula kood="3749" nimi="Kõivu küla"/><asula kood="4451" nimi="Lohkva küla"/><asula kood="4583" nimi="Luunja alevik"/><asula kood="5046" nimi="Muri küla"/><asula kood="5886" nimi="Pajukurmu küla"/><asula kood="6249" nimi="Pilka küla"/><asula kood="6314" nimi="Poksi küla"/><asula kood="6552" nimi="Põvvatu küla"/><asula kood="7189" nimi="Rõõmu küla"/><asula kood="7479" nimi="Sava küla"/><asula kood="7491" nimi="Savikoja küla"/><asula kood="7632" nimi="Sirgu küla"/><asula kood="7635" nimi="Sirgumetsa küla"/><asula kood="7958" nimi="Sääsekõrva küla"/><asula kood="7962" nimi="Sääsküla"/><asula kood="9183" nimi="Veibri küla"/><asula kood="9286" nimi="Viira küla"/></vald><vald kood="0528" nimi="Nõo vald"><asula kood="1129" nimi="Aiamaa küla"/><asula kood="1223" nimi="Altmäe küla"/><asula kood="1605" nimi="Enno küla"/><asula kood="1665" nimi="Etsaste küla"/><asula kood="2039" nimi="Illi küla"/><asula kood="2327" nimi="Järiste küla"/><asula kood="2916" nimi="Keeri küla"/><asula kood="2989" nimi="Ketneri küla"/><asula kood="3338" nimi="Kolga küla"/><asula kood="3939" nimi="Kääni küla"/><asula kood="4046" nimi="Laguja küla"/><asula kood="4557" nimi="Luke küla"/><asula kood="4856" nimi="Meeri küla"/><asula kood="5495" nimi="Nõgiaru küla"/><asula kood="5534" nimi="Nõo alevik"/><asula kood="7441" nimi="Sassi küla"/><asula kood="8133" nimi="Tamsa küla"/><asula kood="8512" nimi="Tõravere alevik"/><asula kood="8698" nimi="Unipiha küla"/><asula kood="8796" nimi="Uuta küla"/><asula kood="9423" nimi="Vissi küla"/><asula kood="9452" nimi="Voika küla"/></vald><vald kood="0586" nimi="Peipsiääre vald"><asula kood="1166" nimi="Alajõe küla"/><asula kood="1176" nimi="Alasoo küla"/><asula kood="1181" nimi="Alatskivi alevik"/><asula kood="1413" nimi="Assikvere küla"/><asula kood="1694" nimi="Haapsipea küla"/><asula kood="1702" nimi="Haavakivi küla"/><asula kood="2489" nimi="Kadrina küla"/><asula kood="2596" nimi="Kallaste linn"/><asula kood="2717" nimi="Kargaja küla"/><asula kood="2799" nimi="Kasepää alevik"/><asula kood="2858" nimi="Kauda küla"/><asula kood="2966" nimi="Keressaare küla"/><asula kood="2979" nimi="Kesklahe küla"/><asula kood="3151" nimi="Kirtsi küla"/><asula kood="3234" nimi="Kodavere küla"/><asula kood="3310" nimi="Kokanurga küla"/><asula kood="3323" nimi="Kokora küla"/><asula kood="3350" nimi="Kolkja alevik"/><asula kood="3425" nimi="Koosa küla"/><asula kood="3427" nimi="Koosalaane küla"/><asula kood="3626" nimi="Kuningvere küla"/><asula kood="3703" nimi="Kusma küla"/><asula kood="3721" nimi="Kuusiku küla"/><asula kood="3732" nimi="Kõdesi küla"/><asula kood="4050" nimi="Lahe küla"/><asula kood="4055" nimi="Lahepera küla"/><asula kood="4379" nimi="Linaleo küla"/><asula kood="4685" nimi="Lümati küla"/><asula kood="4816" nimi="Matjama küla"/><asula kood="4871" nimi="Meoma küla"/><asula kood="4889" nimi="Metsakivi küla"/><asula kood="4904" nimi="Metsanurga küla"/><asula kood="4972" nimi="Moku küla"/><asula kood="5065" nimi="Mustametsa küla"/><asula kood="5337" nimi="Naelavere küla"/><asula kood="5427" nimi="Nina küla"/><asula kood="5544" nimi="Nõva küla"/><asula kood="5709" nimi="Orgemäe küla"/><asula kood="5807" nimi="Padakõrve küla"/><asula kood="5905" nimi="Pala küla"/><asula kood="5981" nimi="Papiaru küla"/><asula kood="6026" nimi="Passi küla"/><asula kood="6057" nimi="Peatskivi küla"/><asula kood="6111" nimi="Perametsa küla"/><asula kood="6161" nimi="Piibumäe küla"/><asula kood="6189" nimi="Piirivarbe küla"/><asula kood="6259" nimi="Pilpaküla"/><asula kood="6342" nimi="Praaga küla"/><asula kood="6432" nimi="Punikvere küla"/><asula kood="6458" nimi="Pusi küla"/><asula kood="6488" nimi="Põdra küla"/><asula kood="6515" nimi="Põldmaa küla"/><asula kood="6544" nimi="Põrgu küla"/><asula kood="6577" nimi="Päiksi küla"/><asula kood="6623" nimi="Pärsikivi küla"/><asula kood="6699" nimi="Raatvere küla"/><asula kood="6803" nimi="Ranna küla"/><asula kood="6902" nimi="Rehemetsa küla"/><asula kood="6984" nimi="Riidma küla"/><asula kood="7043" nimi="Ronisoo küla"/><asula kood="7090" nimi="Rootsiküla"/><asula kood="7127" nimi="Rupsi küla"/><asula kood="7314" nimi="Saburi küla"/><asula kood="7444" nimi="Sassukvere küla"/><asula kood="7484" nimi="Savastvere küla"/><asula kood="7499" nimi="Savimetsa küla"/><asula kood="7500" nimi="Savka küla"/><asula kood="7516" nimi="Selgise küla"/><asula kood="7627" nimi="Sipelga küla"/><asula kood="7703" nimi="Sookalduse küla"/><asula kood="7761" nimi="Sudemäe küla"/><asula kood="7913" nimi="Sõõru küla"/><asula kood="7938" nimi="Särgla küla"/><asula kood="7953" nimi="Sääritsa küla"/><asula kood="8066" nimi="Tagumaa küla"/><asula kood="8329" nimi="Torila küla"/><asula kood="8335" nimi="Toruküla"/><asula kood="8527" nimi="Tõruvere küla"/><asula kood="8555" nimi="Tähemaa küla"/><asula kood="8687" nimi="Undi küla"/><asula kood="9031" nimi="Vanaussaia küla"/><asula kood="9053" nimi="Vara küla"/><asula kood="9090" nimi="Varnja alevik"/><asula kood="9150" nimi="Vea küla"/><asula kood="9389" nimi="Virtsu küla"/><asula kood="9644" nimi="Välgi küla"/><asula kood="9645" nimi="Väljaküla"/><asula kood="9787" nimi="Äteniidi küla"/><asula kood="9790" nimi="Ätte küla"/></vald><vald kood="0793" nimi="Tartu linn"><asula kood="1681" nimi="Haage küla"/><asula kood="2050" nimi="Ilmatsalu alevik"/><asula kood="2049" nimi="Ilmatsalu küla"/><asula kood="2659" nimi="Kandiküla"/><asula kood="2710" nimi="Kardla küla"/><asula kood="5277" nimi="Märja alevik"/><asula kood="6155" nimi="Pihva küla"/><asula kood="6724" nimi="Rahinge küla"/><asula kood="7158" nimi="Rõhu küla"/><asula kood="8151" nimi="Tartu linn"/><asula kood="8560" nimi="Tähtvere küla"/><asula kood="8590" nimi="Tüki küla"/><asula kood="9483" nimi="Vorbuse küla"/></vald><vald kood="0796" nimi="Tartu vald"><asula kood="1312" nimi="Aovere küla"/><asula kood="1383" nimi="Arupää küla"/><asula kood="1579" nimi="Elistvere küla"/><asula kood="1617" nimi="Erala küla"/><asula kood="1699" nimi="Haava küla"/><asula kood="1993" nimi="Igavere küla"/><asula kood="2218" nimi="Juula küla"/><asula kood="2286" nimi="Jõusa küla"/><asula kood="2525" nimi="Kaiavere küla"/><asula kood="2550" nimi="Kaitsemõisa küla"/><asula kood="2809" nimi="Kassema küla"/><asula kood="2829" nimi="Kastli küla"/><asula kood="3064" nimi="Kikivere küla"/><asula kood="3221" nimi="Kobratu küla"/><asula kood="3386" nimi="Koogi küla"/><asula kood="3572" nimi="Kukulinna küla"/><asula kood="3737" nimi="Kõduküla"/><asula kood="3777" nimi="Kõnnujõe küla"/><asula kood="3788" nimi="Kõrenduse küla"/><asula kood="3824" nimi="Kõrveküla alevik"/><asula kood="3872" nimi="Kämara küla"/><asula kood="3900" nimi="Kärevere küla"/><asula kood="3911" nimi="Kärkna küla"/><asula kood="3913" nimi="Kärksi küla"/><asula kood="3970" nimi="Kükitaja küla"/><asula kood="4040" nimi="Laeva küla"/><asula kood="4093" nimi="Lammiku küla"/><asula kood="4375" nimi="Lilu küla"/><asula kood="4487" nimi="Lombi küla"/><asula kood="4629" nimi="Lähte alevik"/><asula kood="4709" nimi="Maarja-Magdaleena küla"/><asula kood="4779" nimi="Maramaa küla"/><asula kood="4900" nimi="Metsanuka küla"/><asula kood="5310" nimi="Möllatsi küla"/><asula kood="5408" nimi="Nigula küla"/><asula kood="5492" nimi="Nõela küla"/><asula kood="5769" nimi="Otslava küla"/><asula kood="6034" nimi="Pataste küla"/><asula kood="6185" nimi="Piiri küla"/><asula kood="6401" nimi="Puhtaleiva küla"/><asula kood="6437" nimi="Pupastvere küla"/><asula kood="6751" nimi="Raigastvere küla"/><asula kood="6918" nimi="Reinu küla"/><asula kood="7273" nimi="Saadjärve küla"/><asula kood="7286" nimi="Saare küla"/><asula kood="7393" nimi="Salu küla"/><asula kood="7542" nimi="Sepa küla"/><asula kood="7614" nimi="Siniküla"/><asula kood="7655" nimi="Soeküla"/><asula kood="7668" nimi="Soitsjärve küla"/><asula kood="7671" nimi="Sojamaa küla"/><asula kood="7745" nimi="Sootaga küla"/><asula kood="7756" nimi="Sortsi küla"/><asula kood="7988" nimi="Taabri küla"/><asula kood="8016" nimi="Tabivere alevik"/><asula kood="8123" nimi="Tammistu küla"/><asula kood="8235" nimi="Tila küla"/><asula kood="8290" nimi="Toolamaa küla"/><asula kood="8308" nimi="Tooni küla"/><asula kood="8334" nimi="Tormi küla"/><asula kood="8629" nimi="Uhmardu küla"/><asula kood="8850" nimi="Vahi alevik"/><asula kood="8849" nimi="Vahi küla"/><asula kood="8934" nimi="Valgma küla"/><asula kood="8966" nimi="Valmaotsa küla"/><asula kood="9136" nimi="Vasula alevik"/><asula kood="9161" nimi="Vedu küla"/><asula kood="9240" nimi="Vesneri küla"/><asula kood="9273" nimi="Viidike küla"/><asula kood="9367" nimi="Vilussaare küla"/><asula kood="9461" nimi="Voldi küla"/><asula kood="9514" nimi="Võibla küla"/><asula kood="9680" nimi="Väägvere küla"/><asula kood="9688" nimi="Väänikvere küla"/><asula kood="9725" nimi="Õvanurme küla"/><asula kood="9728" nimi="Õvi küla"/><asula kood="9748" nimi="Äksi alevik"/></vald></maakond><maakond kood="0081" nimi="Valga maakond"><vald kood="0557" nimi="Otepää vald"><asula kood="1376" nimi="Arula küla"/><asula kood="2053" nimi="Ilmjärve küla"/><asula kood="2820" nimi="Kassiratta küla"/><asula kood="2837" nimi="Kastolatsi küla"/><asula kood="2880" nimi="Kaurutootsi küla"/><asula kood="2914" nimi="Keeni küla"/><asula kood="2998" nimi="Kibena küla"/><asula kood="3286" nimi="Koigu küla"/><asula kood="3353" nimi="Kolli küla"/><asula kood="3369" nimi="Komsi küla"/><asula kood="3534" nimi="Kuigatsi küla"/><asula kood="3663" nimi="Kurevere küla"/><asula kood="3864" nimi="Kähri küla"/><asula kood="3954" nimi="Kääriku küla"/><asula kood="4146" nimi="Lauküla"/><asula kood="4525" nimi="Lossiküla"/><asula kood="4573" nimi="Lutike küla"/><asula kood="4751" nimi="Makita küla"/><asula kood="4837" nimi="Meegaste küla"/><asula kood="4959" nimi="Miti küla"/><asula kood="5195" nimi="Mäeküla"/><asula kood="5219" nimi="Mägestiku küla"/><asula kood="5229" nimi="Mägiste küla"/><asula kood="5232" nimi="Mäha küla"/><asula kood="5279" nimi="Märdi küla"/><asula kood="5396" nimi="Neeruti küla"/><asula kood="5540" nimi="Nõuni küla"/><asula kood="5567" nimi="Nüpli küla"/><asula kood="5752" nimi="Otepää küla"/><asula kood="5755" nimi="Otepää linn"/><asula kood="6060" nimi="Pedajamäe küla"/><asula kood="6252" nimi="Pilkuse küla"/><asula kood="6296" nimi="Plika küla"/><asula kood="6352" nimi="Prange küla"/><asula kood="6371" nimi="Pringi küla"/><asula kood="6417" nimi="Puka alevik"/><asula kood="6549" nimi="Põru küla"/><asula kood="6570" nimi="Päidla küla"/><asula kood="6659" nimi="Pühajärve küla"/><asula kood="6857" nimi="Raudsepa küla"/><asula kood="6943" nimi="Restu küla"/><asula kood="7018" nimi="Risttee küla"/><asula kood="7148" nimi="Ruuna küla"/><asula kood="7195" nimi="Räbi küla"/><asula kood="7418" nimi="Sangaste alevik"/><asula kood="7426" nimi="Sarapuu küla"/><asula kood="7565" nimi="Sihva küla"/><asula kood="8219" nimi="Tiidu küla"/><asula kood="8356" nimi="Truuta küla"/><asula kood="8546" nimi="Tõutsi küla"/><asula kood="8806" nimi="Vaalu küla"/><asula kood="8808" nimi="Vaardi küla"/><asula kood="8999" nimi="Vana-Otepää küla"/><asula kood="9252" nimi="Vidrike küla"/><asula kood="9733" nimi="Ädu küla"/></vald><vald kood="0824" nimi="Tõrva vald"><asula kood="1152" nimi="Aitsra küla"/><asula kood="1160" nimi="Ala küla"/><asula kood="1171" nimi="Alamõisa küla"/><asula kood="1815" nimi="Helme alevik"/><asula kood="1883" nimi="Holdre küla"/><asula kood="1905" nimi="Hummuli alevik"/><asula kood="2187" nimi="Jeti küla"/><asula kood="2264" nimi="Jõgeveste küla"/><asula kood="2623" nimi="Kalme küla"/><asula kood="2757" nimi="Karjatnurme küla"/><asula kood="2772" nimi="Karu küla"/><asula kood="2856" nimi="Kaubi küla"/><asula kood="3124" nimi="Kirikuküla"/><asula kood="3420" nimi="Koorküla"/><asula kood="3596" nimi="Kulli küla"/><asula kood="3611" nimi="Kungi küla"/><asula kood="3866" nimi="Kähu küla"/><asula kood="4173" nimi="Leebiku küla"/><asula kood="4390" nimi="Linna küla"/><asula kood="4433" nimi="Liva küla"/><asula kood="4620" nimi="Lõve küla"/><asula kood="5304" nimi="Möldre küla"/><asula kood="6042" nimi="Patküla"/><asula kood="6186" nimi="Piiri küla"/><asula kood="6222" nimi="Pikasilla küla"/><asula kood="6257" nimi="Pilpa küla"/><asula kood="6330" nimi="Pori küla"/><asula kood="6408" nimi="Puide küla"/><asula kood="6824" nimi="Ransi küla"/><asula kood="6946" nimi="Reti küla"/><asula kood="6976" nimi="Riidaja küla"/><asula kood="7053" nimi="Roobe küla"/><asula kood="7113" nimi="Rulli küla"/><asula kood="7654" nimi="Soe küla"/><asula kood="7730" nimi="Soontaga küla"/><asula kood="7993" nimi="Taagepera küla"/><asula kood="8529" nimi="Tõrva linn"/><asula kood="8714" nimi="Uralaane küla"/><asula kood="9025" nimi="Vanamõisa küla"/><asula kood="9464" nimi="Voorbahi küla"/></vald><vald kood="0855" nimi="Valga vald"><asula kood="1766" nimi="Hargla küla"/><asula kood="2016" nimi="Iigaste küla"/><asula kood="2137" nimi="Jaanikese küla"/><asula kood="2384" nimi="Kaagjärve küla"/><asula kood="2609" nimi="Kalliküla"/><asula kood="2775" nimi="Karula küla"/><asula kood="3087" nimi="Killinge küla"/><asula kood="3116" nimi="Kirbu küla"/><asula kood="3180" nimi="Kiviküla"/><asula kood="3289" nimi="Koikküla"/><asula kood="3304" nimi="Koiva küla"/><asula kood="3383" nimi="Koobassaare küla"/><asula kood="3447" nimi="Korijärve küla"/><asula kood="3452" nimi="Korkuna küla"/><asula kood="3951" nimi="Käärikmäe küla"/><asula kood="4024" nimi="Laanemetsa küla"/><asula kood="4029" nimi="Laatre alevik"/><asula kood="4281" nimi="Lepa küla"/><asula kood="4493" nimi="Londi küla"/><asula kood="4530" nimi="Lota küla"/><asula kood="4563" nimi="Lusti küla"/><asula kood="4576" nimi="Lutsu küla"/><asula kood="4677" nimi="Lüllemäe küla"/><asula kood="5003" nimi="Muhkva küla"/><asula kood="5096" nimi="Mustumetsa küla"/><asula kood="5881" nimi="Paju küla"/><asula kood="6234" nimi="Pikkjärve küla"/><asula kood="6365" nimi="Priipalu küla"/><asula kood="6388" nimi="Pugritsa küla"/><asula kood="6702" nimi="Raavitsa küla"/><asula kood="6786" nimi="Rampe küla"/><asula kood="6887" nimi="Rebasemõisa küla"/><asula kood="7005" nimi="Ringiste küla"/><asula kood="7686" nimi="Sooblase küla"/><asula kood="7738" nimi="Sooru küla"/><asula kood="7801" nimi="Supa küla"/><asula kood="8064" nimi="Tagula küla"/><asula kood="8069" nimi="Taheva küla"/><asula kood="8248" nimi="Tinu küla"/><asula kood="8365" nimi="Tsirguliina alevik"/><asula kood="8368" nimi="Tsirgumäe küla"/><asula kood="8491" nimi="Tõlliste küla"/><asula kood="8535" nimi="Tõrvase küla"/><asula kood="8696" nimi="Uniküla"/><asula kood="8918" nimi="Valga linn"/><asula kood="8969" nimi="Valtina küla"/><asula kood="9326" nimi="Vilaski küla"/><asula kood="9618" nimi="Väheru küla"/><asula kood="9651" nimi="Väljaküla"/><asula kood="9699" nimi="Õlatu küla"/><asula kood="9710" nimi="Õru alevik"/><asula kood="9713" nimi="Õruste küla"/></vald></maakond><maakond kood="0084" nimi="Viljandi maakond"><vald kood="0480" nimi="Mulgi vald"><asula kood="1060" nimi="Abja-Paluoja linn"/><asula kood="8593" nimi="Abja-Vanamõisa küla"/><asula kood="1061" nimi="Abjaku küla"/><asula kood="1149" nimi="Ainja küla"/><asula kood="1199" nimi="Allaste küla"/><asula kood="1433" nimi="Atika küla"/><asula kood="1625" nimi="Ereste küla"/><asula kood="1749" nimi="Halliste alevik"/><asula kood="1868" nimi="Hirmuküla"/><asula kood="1926" nimi="Hõbemäe küla"/><asula kood="2406" nimi="Kaarli küla"/><asula kood="2628" nimi="Kalvre küla"/><asula kood="2634" nimi="Kamara küla"/><asula kood="2759" nimi="Karksi küla"/><asula kood="2761" nimi="Karksi-Nuia linn"/><asula kood="3580" nimi="Kulla küla"/><asula kood="3837" nimi="Kõvaküla"/><asula kood="4030" nimi="Laatre küla"/><asula kood="4120" nimi="Lasari küla"/><asula kood="4183" nimi="Leeli küla"/><asula kood="4370" nimi="Lilli küla"/><asula kood="4802" nimi="Maru küla"/><asula kood="4893" nimi="Metsaküla"/><asula kood="4989" nimi="Morna küla"/><asula kood="5020" nimi="Mulgi küla"/><asula kood="5047" nimi="Muri küla"/><asula kood="5145" nimi="Mõisaküla linn"/><asula kood="5178" nimi="Mõõnaste küla"/><asula kood="7211" nimi="Mäeküla"/><asula kood="5349" nimi="Naistevalla küla"/><asula kood="5411" nimi="Niguli küla"/><asula kood="5758" nimi="Oti küla"/><asula kood="6106" nimi="Penuja küla"/><asula kood="6317" nimi="Polli küla"/><asula kood="6335" nimi="Pornuse küla"/><asula kood="6510" nimi="Põlde küla"/><asula kood="6572" nimi="Päidre küla"/><asula kood="6575" nimi="Päigiste küla"/><asula kood="6621" nimi="Pärsi küla"/><asula kood="6641" nimi="Pöögle küla"/><asula kood="6689" nimi="Raamatu küla"/><asula kood="6765" nimi="Raja küla"/><asula kood="7002" nimi="Rimmu küla"/><asula kood="7238" nimi="Räägu küla"/><asula kood="7313" nimi="Saate küla"/><asula kood="7356" nimi="Saksaküla"/><asula kood="7410" nimi="Sammaste küla"/><asula kood="7433" nimi="Sarja küla"/><asula kood="7767" nimi="Sudiste küla"/><asula kood="7825" nimi="Suuga küla"/><asula kood="8240" nimi="Tilla küla"/><asula kood="8310" nimi="Toosi küla"/><asula kood="8398" nimi="Tuhalaane küla"/><asula kood="8672" nimi="Umbsoo küla"/><asula kood="8701" nimi="Univere küla"/><asula kood="8759" nimi="Uue-Kariste küla"/><asula kood="8816" nimi="Vabamatsi küla"/><asula kood="8984" nimi="Vana-Kariste küla"/><asula kood="9167" nimi="Veelikse küla"/><asula kood="9235" nimi="Veskimäe küla"/><asula kood="9695" nimi="Õisu alevik"/><asula kood="9780" nimi="Äriküla"/><asula kood="9830" nimi="Ülemõisa küla"/></vald><vald kood="0615" nimi="Põhja-Sakala vald"><asula kood="1144" nimi="Aimla küla"/><asula kood="1354" nimi="Arjadi küla"/><asula kood="1356" nimi="Arjassaare küla"/><asula kood="1386" nimi="Arussaare küla"/><asula kood="1613" nimi="Epra küla"/><asula kood="2013" nimi="Iia küla"/><asula kood="2033" nimi="Ilbaku küla"/><asula kood="2116" nimi="Ivaski küla"/><asula kood="2175" nimi="Jaska küla"/><asula kood="2304" nimi="Jälevere küla"/><asula kood="2456" nimi="Kabila küla"/><asula kood="2674" nimi="Kangrussaare küla"/><asula kood="2754" nimi="Karjasoo küla"/><asula kood="2973" nimi="Kerita küla"/><asula kood="2993" nimi="Kibaru küla"/><asula kood="3079" nimi="Kildu küla"/><asula kood="3142" nimi="Kirivere küla"/><asula kood="3226" nimi="Kobruvere küla"/><asula kood="3328" nimi="Koksvere küla"/><asula kood="3430" nimi="Kootsi küla"/><asula kood="3523" nimi="Kuhjavere küla"/><asula kood="3529" nimi="Kuiavere küla"/><asula kood="3619" nimi="Kuninga küla"/><asula kood="3690" nimi="Kurnuvere küla"/><asula kood="3741" nimi="Kõidama küla"/><asula kood="3775" nimi="Kõo küla"/><asula kood="3782" nimi="Kõpu alevik"/><asula kood="3901" nimi="Kärevere küla"/><asula kood="4018" nimi="Laane küla"/><asula kood="4060" nimi="Lahmuse küla"/><asula kood="4261" nimi="Lemmakõnnu küla"/><asula kood="4514" nimi="Loopre küla"/><asula kood="4598" nimi="Lõhavere küla"/><asula kood="4699" nimi="Maalasti küla"/><asula kood="4925" nimi="Metsküla"/><asula kood="4998" nimi="Mudiste küla"/><asula kood="5031" nimi="Munsi küla"/><asula kood="5196" nimi="Mäeküla"/><asula kood="5375" nimi="Navesti küla"/><asula kood="5488" nimi="Nuutre küla"/><asula kood="5669" nimi="Olustvere alevik"/><asula kood="5781" nimi="Paaksima küla"/><asula kood="5828" nimi="Paelama küla"/><asula kood="5833" nimi="Paenasti küla"/><asula kood="6247" nimi="Pilistvere küla"/><asula kood="6429" nimi="Punaküla"/><asula kood="6502" nimi="Põhjaka küla"/><asula kood="6596" nimi="Päraküla"/><asula kood="6897" nimi="Reegoldi küla"/><asula kood="6974" nimi="Riiassaare küla"/><asula kood="7240" nimi="Rääka küla"/><asula kood="7415" nimi="Sandra küla"/><asula kood="7489" nimi="Saviaugu küla"/><asula kood="7550" nimi="Seruküla"/><asula kood="7720" nimi="Soomevere küla"/><asula kood="7804" nimi="Supsi küla"/><asula kood="7836" nimi="Suure-Jaani linn"/><asula kood="7978" nimi="Sürgavere küla"/><asula kood="8030" nimi="Taevere küla"/><asula kood="8251" nimi="Tipu küla"/><asula kood="8566" nimi="Tällevere küla"/><asula kood="8586" nimi="Tääksi küla"/><asula kood="8641" nimi="Uia küla"/><asula kood="8681" nimi="Unakvere küla"/><asula kood="9036" nimi="Vanaveski küla"/><asula kood="9123" nimi="Vastemõisa küla"/><asula kood="9205" nimi="Venevere küla"/><asula kood="9262" nimi="Vihi küla"/><asula kood="9500" nimi="Võhma linn"/><asula kood="9503" nimi="Võhmassaare küla"/><asula kood="9546" nimi="Võivaku küla"/><asula kood="9561" nimi="Võlli küla"/><asula kood="9765" nimi="Ängi küla"/><asula kood="9824" nimi="Ülde küla"/></vald><vald kood="0897" nimi="Viljandi linn"/><vald kood="0899" nimi="Viljandi vald"><asula kood="1138" nimi="Aidu küla"/><asula kood="1147" nimi="Aindu küla"/><asula kood="1240" nimi="Alustre küla"/><asula kood="1283" nimi="Anikatsi küla"/><asula kood="1461" nimi="Auksi küla"/><asula kood="1539" nimi="Eesnurga küla"/><asula kood="1794" nimi="Heimtali küla"/><asula kood="1821" nimi="Hendrikumõisa küla"/><asula kood="1888" nimi="Holstre küla"/><asula kood="2093" nimi="Intsu küla"/><asula kood="2153" nimi="Jakobimõisa küla"/><asula kood="2229" nimi="Jõeküla"/><asula kood="2312" nimi="Jämejala küla"/><asula kood="2338" nimi="Järtsaare küla"/><asula kood="2355" nimi="Järveküla"/><asula kood="2439" nimi="Kaavere küla"/><asula kood="2570" nimi="Kalbuse küla"/><asula kood="2685" nimi="Kannuküla"/><asula kood="2776" nimi="Karula küla"/><asula kood="2813" nimi="Kassi küla"/><asula kood="2996" nimi="Kibeküla"/><asula kood="3042" nimi="Kiini küla"/><asula kood="3047" nimi="Kiisa küla"/><asula kood="3100" nimi="Kingu küla"/><asula kood="3185" nimi="Kivilõppe küla"/><asula kood="3275" nimi="Koidu küla"/><asula kood="3313" nimi="Kokaviidika küla"/><asula kood="3340" nimi="Kolga-Jaani alevik"/><asula kood="3396" nimi="Kookla küla"/><asula kood="3658" nimi="Kuressaare küla"/><asula kood="3711" nimi="Kuudeküla"/><asula kood="3927" nimi="Kärstna küla"/><asula kood="4021" nimi="Laanekuru küla"/><asula kood="4088" nimi="Lalsi küla"/><asula kood="4185" nimi="Leemeti küla"/><asula kood="4225" nimi="Leie küla"/><asula kood="4462" nimi="Loime küla"/><asula kood="4484" nimi="Lolu küla"/><asula kood="4501" nimi="Loodi küla"/><asula kood="4548" nimi="Luiga küla"/><asula kood="4650" nimi="Lätkalu küla"/><asula kood="4763" nimi="Maltsa küla"/><asula kood="4789" nimi="Marjamäe küla"/><asula kood="4794" nimi="Marna küla"/><asula kood="4814" nimi="Matapera küla"/><asula kood="4865" nimi="Meleski küla"/><asula kood="4928" nimi="Metsla küla"/><asula kood="4981" nimi="Moori küla"/><asula kood="5017" nimi="Muksi küla"/><asula kood="5070" nimi="Mustapali küla"/><asula kood="5075" nimi="Mustivere küla"/><asula kood="5084" nimi="Mustla alevik"/><asula kood="5152" nimi="Mõnnaste küla"/><asula kood="5201" nimi="Mäeltküla"/><asula kood="5237" nimi="Mähma küla"/><asula kood="5595" nimi="Odiste küla"/><asula kood="5647" nimi="Oiu küla"/><asula kood="5701" nimi="Oorgu küla"/><asula kood="5763" nimi="Otiküla"/><asula kood="5859" nimi="Pahuvere küla"/><asula kood="5872" nimi="Paistu küla"/><asula kood="6007" nimi="Parika küla"/><asula kood="6090" nimi="Peetrimõisa küla"/><asula kood="6239" nimi="Pikru küla"/><asula kood="6271" nimi="Pinska küla"/><asula kood="6276" nimi="Pirmastu küla"/><asula kood="6338" nimi="Porsa küla"/><asula kood="6406" nimi="Puiatu küla"/><asula kood="6423" nimi="Pulleritsu küla"/><asula kood="6541" nimi="Põrga küla"/><asula kood="6601" nimi="Päri küla"/><asula kood="6626" nimi="Pärsti küla"/><asula kood="6697" nimi="Raassilla küla"/><asula kood="6789" nimi="Ramsi alevik"/><asula kood="6852" nimi="Raudna küla"/><asula kood="6885" nimi="Rebase küla"/><asula kood="6891" nimi="Rebaste küla"/><asula kood="6956" nimi="Ridaküla"/><asula kood="6971" nimi="Rihkama küla"/><asula kood="7024" nimi="Riuma küla"/><asula kood="7076" nimi="Roosilla küla"/><asula kood="7143" nimi="Ruudiküla"/><asula kood="7290" nimi="Saareküla"/><asula kood="7295" nimi="Saarepeedi küla"/><asula kood="7494" nimi="Savikoti küla"/><asula kood="7611" nimi="Sinialliku küla"/><asula kood="7653" nimi="Soe küla"/><asula kood="7750" nimi="Sooviku küla"/><asula kood="7779" nimi="Suislepa küla"/><asula kood="7790" nimi="Sultsi küla"/><asula kood="7812" nimi="Surva küla"/><asula kood="8003" nimi="Taari küla"/><asula kood="8048" nimi="Tagamõisa küla"/><asula kood="8050" nimi="Taganurga küla"/><asula kood="8159" nimi="Tarvastu küla"/><asula kood="8247" nimi="Tinnikuru küla"/><asula kood="8264" nimi="Tobraselja küla"/><asula kood="8272" nimi="Tohvri küla"/><asula kood="8431" nimi="Turva küla"/><asula kood="8439" nimi="Tusti küla"/><asula kood="8504" nimi="Tõnissaare küla"/><asula kood="8507" nimi="Tõnuküla"/><asula kood="8522" nimi="Tõrreküla"/><asula kood="8569" nimi="Tänassilma küla"/><asula kood="8496" nimi="Tömbi küla"/><asula kood="8684" nimi="Unametsa küla"/><asula kood="8790" nimi="Uusna küla"/><asula kood="8864" nimi="Vaibla küla"/><asula kood="8964" nimi="Valma küla"/><asula kood="9012" nimi="Vana-Võidu küla"/><asula kood="9026" nimi="Vanamõisa küla"/><asula kood="9034" nimi="Vanausse küla"/><asula kood="9039" nimi="Vanavälja küla"/><asula kood="9068" nimi="Vardi küla"/><asula kood="9073" nimi="Vardja küla"/><asula kood="9103" nimi="Vasara küla"/><asula kood="9186" nimi="Veisjärve küla"/><asula kood="9221" nimi="Verilaske küla"/><asula kood="9292" nimi="Viiratsi alevik"/><asula kood="9305" nimi="Viisuküla"/><asula kood="9331" nimi="Vilimeeste küla"/><asula kood="9344" nimi="Villa küla"/><asula kood="9426" nimi="Vissuvere küla"/><asula kood="9477" nimi="Vooru küla"/><asula kood="9541" nimi="Võistre küla"/><asula kood="9626" nimi="Väike-Kõpu küla"/><asula kood="9646" nimi="Välgita küla"/><asula kood="9661" nimi="Väluste küla"/><asula kood="9758" nimi="Ämmuste küla"/><asula kood="9833" nimi="Ülensi küla"/></vald></maakond><maakond kood="0087" nimi="Võru maakond"><vald kood="0142" nimi="Antsla vald"><asula kood="1288" nimi="Anne küla"/><asula kood="1301" nimi="Antsla linn"/><asula kood="1303" nimi="Antsu küla"/><asula kood="1678" nimi="Haabsaare küla"/><asula kood="2242" nimi="Jõepera küla"/><asula kood="2535" nimi="Kaika küla"/><asula kood="2812" nimi="Kassi küla"/><asula kood="3069" nimi="Kikkaoja küla"/><asula kood="3125" nimi="Kirikuküla"/><asula kood="3214" nimi="Kobela alevik"/><asula kood="3287" nimi="Koigu küla"/><asula kood="3355" nimi="Kollino küla"/><asula kood="3486" nimi="Kraavi küla"/><asula kood="3575" nimi="Kuldre küla"/><asula kood="3752" nimi="Kõlbi küla"/><asula kood="4427" nimi="Litsmetsa küla"/><asula kood="4543" nimi="Luhametsa küla"/><asula kood="4564" nimi="Lusti küla"/><asula kood="4689" nimi="Lümatu küla"/><asula kood="4721" nimi="Madise küla"/><asula kood="5234" nimi="Mähkli küla"/><asula kood="5605" nimi="Oe küla"/><asula kood="6150" nimi="Pihleni küla"/><asula kood="6196" nimi="Piisi küla"/><asula kood="7000" nimi="Rimmi küla"/><asula kood="7073" nimi="Roosiku küla"/><asula kood="7102" nimi="Ruhingu küla"/><asula kood="7496" nimi="Savilöövi küla"/><asula kood="7714" nimi="Soome küla"/><asula kood="7933" nimi="Säre küla"/><asula kood="8011" nimi="Taberlaane küla"/><asula kood="8280" nimi="Toku küla"/><asula kood="8378" nimi="Tsooru küla"/><asula kood="8634" nimi="Uhtjärve küla"/><asula kood="8733" nimi="Urvaste küla"/><asula kood="8757" nimi="Uue-Antsla küla"/><asula kood="8801" nimi="Vaabina küla"/><asula kood="8977" nimi="Vana-Antsla alevik"/><asula kood="9290" nimi="Viirapalu küla"/><asula kood="9414" nimi="Visela küla"/><asula kood="9737" nimi="Ähijärve küla"/></vald><vald kood="0698" nimi="Rõuge vald"><asula kood="1005" nimi="Aabra küla"/><asula kood="1111" nimi="Ahitsa küla"/><asula kood="1161" nimi="Ala-Palo küla"/><asula kood="1164" nimi="Ala-Suhka küla"/><asula kood="1162" nimi="Ala-Tilga küla"/><asula kood="1262" nimi="Andsumäe küla"/><asula kood="1456" nimi="Augli küla"/><asula kood="1676" nimi="Haabsilla küla"/><asula kood="1689" nimi="Haanja küla"/><asula kood="1703" nimi="Haavistu küla"/><asula kood="1728" nimi="Haki küla"/><asula kood="1745" nimi="Hallimäe küla"/><asula kood="1753" nimi="Handimiku küla"/><asula kood="1750" nimi="Hanija küla"/><asula kood="1758" nimi="Hansi küla"/><asula kood="1756" nimi="Hapsu küla"/><asula kood="1772" nimi="Harjuküla"/><asula kood="1789" nimi="Heedu küla"/><asula kood="1791" nimi="Heibri küla"/><asula kood="1858" nimi="Hino küla"/><asula kood="1863" nimi="Hintsiko küla"/><asula kood="1861" nimi="Hinu küla"/><asula kood="1881" nimi="Holdi küla"/><asula kood="1890" nimi="Horoski küla"/><asula kood="1893" nimi="Horosuu küla"/><asula kood="1898" nimi="Horsa küla"/><asula kood="1896" nimi="Hotõmäe küla"/><asula kood="1895" nimi="Hulaku küla"/><asula kood="1911" nimi="Hurda küla"/><asula kood="1933" nimi="Hämkoti küla"/><asula kood="1956" nimi="Härämäe küla"/><asula kood="1958" nimi="Häärmäni küla"/><asula kood="1968" nimi="Hürova küla"/><asula kood="1966" nimi="Hürsi küla"/><asula kood="1972" nimi="Hüti küla"/><asula kood="2008" nimi="Ihatsi küla"/><asula kood="2145" nimi="Jaanimäe küla"/><asula kood="2146" nimi="Jaanipeebu küla"/><asula kood="2206" nimi="Jugu küla"/><asula kood="2358" nimi="Järvekülä küla"/><asula kood="2357" nimi="Järvepalu küla"/><asula kood="2401" nimi="Kaaratautsa küla"/><asula kood="2491" nimi="Kadõni küla"/><asula kood="2516" nimi="Kahrila-Mustahamba küla"/><asula kood="2513" nimi="Kahru küla"/><asula kood="2554" nimi="Kaku küla"/><asula kood="2571" nimi="Kaldemäe küla"/><asula kood="2598" nimi="Kallaste küla"/><asula kood="2625" nimi="Kaloga küla"/><asula kood="2627" nimi="Kaluka küla"/><asula kood="2677" nimi="Kangsti küla"/><asula kood="2704" nimi="Karaski küla"/><asula kood="2708" nimi="Karba küla"/><asula kood="2738" nimi="Karisöödi küla"/><asula kood="2854" nimi="Kaubi küla"/><asula kood="2866" nimi="Kaugu küla"/><asula kood="2899" nimi="Kavõldi küla"/><asula kood="2936" nimi="Kellämäe küla"/><asula kood="2968" nimi="Kergatsi küla"/><asula kood="3026" nimi="Kiidi küla"/><asula kood="3089" nimi="Kilomani küla"/><asula kood="3095" nimi="Kimalasõ küla"/><asula kood="3115" nimi="Kirbu küla"/><asula kood="3193" nimi="Kiviora küla"/><asula kood="3250" nimi="Koemetsa küla"/><asula kood="3256" nimi="Kogrõ küla"/><asula kood="3329" nimi="Kokõ küla"/><asula kood="3327" nimi="Kokõjüri küla"/><asula kood="3318" nimi="Kokõmäe küla"/><asula kood="3334" nimi="Kolga küla"/><asula kood="3794" nimi="Korgõssaarõ küla"/><asula kood="3478" nimi="Kotka küla"/><asula kood="3489" nimi="Krabi küla"/><asula kood="3493" nimi="Kriguli küla"/><asula kood="3522" nimi="Kuiandi küla"/><asula kood="3559" nimi="Kuklase küla"/><asula kood="3558" nimi="Kuklasõ küla"/><asula kood="3374" nimi="Kundsa küla"/><asula kood="3664" nimi="Kurgjärve küla"/><asula kood="3698" nimi="Kurvitsa küla"/><asula kood="3635" nimi="Kurõ küla"/><asula kood="3706" nimi="Kuuda küla"/><asula kood="3713" nimi="Kuura küla"/><asula kood="3728" nimi="Kuutsi küla"/><asula kood="3780" nimi="Kõomäe küla"/><asula kood="3793" nimi="Kõrgepalu küla"/><asula kood="3851" nimi="Käbli küla"/><asula kood="3861" nimi="Kähri küla"/><asula kood="3873" nimi="Kängsepä küla"/><asula kood="3906" nimi="Kärinä küla"/><asula kood="3941" nimi="Käänu küla"/><asula kood="3946" nimi="Kääraku küla"/><asula kood="3990" nimi="Külma küla"/><asula kood="4071" nimi="Laisi küla"/><asula kood="4076" nimi="Laitsna-Hurda küla"/><asula kood="4111" nimi="Laossaarõ küla"/><asula kood="4158" nimi="Lauri küla"/><asula kood="4160" nimi="Laurimäe küla"/><asula kood="4277" nimi="Leoski küla"/><asula kood="4324" nimi="Liguri küla"/><asula kood="4358" nimi="Liivakupalu küla"/><asula kood="4372" nimi="Lillimõisa küla"/><asula kood="4422" nimi="Listaku küla"/><asula kood="4502" nimi="Loogamäe küla"/><asula kood="4568" nimi="Lutika küla"/><asula kood="4591" nimi="Luutsniku küla"/><asula kood="4670" nimi="Lükkä küla"/><asula kood="4694" nimi="Lüütsepa küla"/><asula kood="4731" nimi="Mahtja küla"/><asula kood="4760" nimi="Mallika küla"/><asula kood="4825" nimi="Matsi küla"/><asula kood="4830" nimi="Mauri küla"/><asula kood="4846" nimi="Meelaku küla"/><asula kood="4933" nimi="Metstaga küla"/><asula kood="4946" nimi="Miilimäe küla"/><asula kood="4947" nimi="Mikita küla"/><asula kood="4954" nimi="Misso alevik"/><asula kood="4957" nimi="Misso-Saika küla"/><asula kood="4956" nimi="Missokülä küla"/><asula kood="4996" nimi="Muduri küla"/><asula kood="5001" nimi="Muhkamõtsa küla"/><asula kood="5024" nimi="Muna küla"/><asula kood="5035" nimi="Muraski küla"/><asula kood="5041" nimi="Murati küla"/><asula kood="5042" nimi="Murdõmäe küla"/><asula kood="5054" nimi="Mustahamba küla"/><asula kood="5099" nimi="Mutemetsa küla"/><asula kood="5149" nimi="Mõniste küla"/><asula kood="5176" nimi="Mõõlu küla"/><asula kood="5199" nimi="Mäe-Lüütsepä küla"/><asula kood="5187" nimi="Mäe-Palo küla"/><asula kood="7773" nimi="Mäe-Suhka küla"/><asula kood="5189" nimi="Mäe-Tilga küla"/><asula kood="5283" nimi="Märdi küla"/><asula kood="5278" nimi="Märdimiku küla"/><asula kood="5305" nimi="Möldre küla"/><asula kood="5306" nimi="Möldri küla"/><asula kood="5323" nimi="Naapka küla"/><asula kood="5423" nimi="Nilbõ küla"/><asula kood="5434" nimi="Nogu küla"/><asula kood="5477" nimi="Nursi küla"/><asula kood="5732" nimi="Ortumäe küla"/><asula kood="5770" nimi="Paaburissa küla"/><asula kood="5822" nimi="Paeboja küla"/><asula kood="5839" nimi="Paganamaa küla"/><asula kood="5918" nimi="Palanumäe küla"/><asula kood="5933" nimi="Palli küla"/><asula kood="5942" nimi="Palujüri küla"/><asula kood="6015" nimi="Parmu küla"/><asula kood="6019" nimi="Parmupalu küla"/><asula kood="6051" nimi="Pausakunnu küla"/><asula kood="6069" nimi="Pedejä küla"/><asula kood="6076" nimi="Peebu küla"/><asula kood="6078" nimi="Peedo küla"/><asula kood="6128" nimi="Petrakuudi küla"/><asula kood="6179" nimi="Piipsemäe küla"/><asula kood="6253" nimi="Pillardi küla"/><asula kood="6290" nimi="Plaani küla"/><asula kood="6287" nimi="Plaksi küla"/><asula kood="6336" nimi="Posti küla"/><asula kood="6358" nimi="Preeksa küla"/><asula kood="6362" nimi="Pressi küla"/><asula kood="6386" nimi="Pugõstu küla"/><asula kood="6433" nimi="Pulli küla"/><asula kood="6428" nimi="Pundi küla"/><asula kood="6434" nimi="Punsa küla"/><asula kood="6435" nimi="Pupli küla"/><asula kood="6439" nimi="Purka küla"/><asula kood="6463" nimi="Puspuri küla"/><asula kood="6485" nimi="Põdra küla"/><asula kood="6490" nimi="Põdramõtsa küla"/><asula kood="6538" nimi="Põnni küla"/><asula kood="6545" nimi="Põru küla"/><asula kood="6564" nimi="Pähni küla"/><asula kood="6592" nimi="Pältre küla"/><asula kood="6611" nimi="Pärlijõe küla"/><asula kood="6670" nimi="Püssä küla"/><asula kood="6687" nimi="Raagi küla"/><asula kood="6784" nimi="Rammuka küla"/><asula kood="6839" nimi="Rasva küla"/><asula kood="6858" nimi="Raudsepa küla"/><asula kood="6859" nimi="Raudsepä küla"/><asula kood="6892" nimi="Rebäse küla"/><asula kood="6895" nimi="Rebäsemõisa küla"/><asula kood="6938" nimi="Resto küla"/><asula kood="6991" nimi="Riitsilla küla"/><asula kood="7008" nimi="Ristemäe küla"/><asula kood="7021" nimi="Ritsiko küla"/><asula kood="7027" nimi="Rogosi-Mikita küla"/><asula kood="7052" nimi="Roobi küla"/><asula kood="7125" nimi="Rusa küla"/><asula kood="7144" nimi="Ruuksu küla"/><asula kood="7153" nimi="Ruusmäe küla"/><asula kood="7181" nimi="Rõuge alevik"/><asula kood="7168" nimi="Rõuge-Matsi küla"/><asula kood="7271" nimi="Saagri küla"/><asula kood="7272" nimi="Saagrimäe küla"/><asula kood="7305" nimi="Saarlasõ küla"/><asula kood="7321" nimi="Sadramõtsa küla"/><asula kood="7341" nimi="Saika küla"/><asula kood="7346" nimi="Saki küla"/><asula kood="7364" nimi="Sakudi küla"/><asula kood="7363" nimi="Sakurgi küla"/><asula kood="7397" nimi="Saluora küla"/><asula kood="7411" nimi="Sandi küla"/><asula kood="7409" nimi="Sandisuu küla"/><asula kood="7419" nimi="Sapi küla"/><asula kood="7431" nimi="Sarise küla"/><asula kood="7436" nimi="Saru küla"/><asula kood="7506" nimi="Savimäe küla"/><asula kood="7504" nimi="Savioja küla"/><asula kood="7507" nimi="Savioru küla"/><asula kood="7574" nimi="Sika küla"/><asula kood="7575" nimi="Sikalaanõ küla"/><asula kood="7585" nimi="Siksälä küla"/><asula kood="7600" nimi="Simmuli küla"/><asula kood="7599" nimi="Simula küla"/><asula kood="7609" nimi="Singa küla"/><asula kood="7650" nimi="Soekõrdsi küla"/><asula kood="7656" nimi="Soemõisa küla"/><asula kood="7691" nimi="Soodi küla"/><asula kood="7712" nimi="Soolätte küla"/><asula kood="7721" nimi="Soomõoru küla"/><asula kood="7751" nimi="Sormuli küla"/><asula kood="7146" nimi="Suurõ-Ruuga küla"/><asula kood="7849" nimi="Suurõsuu küla"/><asula kood="7930" nimi="Sänna/Sännä küla"/><asula kood="7968" nimi="Söödi küla"/><asula kood="8038" nimi="Tagakolga küla"/><asula kood="8086" nimi="Tallima küla"/><asula kood="8170" nimi="Taudsa küla"/><asula kood="8200" nimi="Tialasõ küla"/><asula kood="8218" nimi="Tiidu küla"/><asula kood="8229" nimi="Tiitsa küla"/><asula kood="8233" nimi="Tika küla"/><asula kood="8237" nimi="Tilgu küla"/><asula kood="8241" nimi="Tindi küla"/><asula kood="8284" nimi="Toodsi küla"/><asula kood="8351" nimi="Trolla küla"/><asula kood="8354" nimi="Tsiamäe küla"/><asula kood="8357" nimi="Tsiiruli küla"/><asula kood="8360" nimi="Tsiistre küla"/><asula kood="8358" nimi="Tsilgutaja küla"/><asula kood="8366" nimi="Tsirgupalu küla"/><asula kood="8374" nimi="Tsolli küla"/><asula kood="8379" nimi="Tsutsu küla"/><asula kood="8410" nimi="Tummelka küla"/><asula kood="8415" nimi="Tundu küla"/><asula kood="8429" nimi="Tursa küla"/><asula kood="8448" nimi="Tuuka küla"/><asula kood="8503" nimi="Tõnkova küla"/><asula kood="8603" nimi="Tüütsi küla"/><asula kood="8623" nimi="Udsali küla"/><asula kood="8738" nimi="Utessuu küla"/><asula kood="8762" nimi="Uue-Saaluse küla"/><asula kood="8802" nimi="Vaalimäe küla"/><asula kood="8809" nimi="Vaarkali küla"/><asula kood="8817" nimi="Vadsa küla"/><asula kood="8906" nimi="Vakari küla"/><asula kood="9002" nimi="Vana-Roosa küla"/><asula kood="9030" nimi="Vanamõisa küla"/><asula kood="9095" nimi="Varstu alevik"/><asula kood="9131" nimi="Vastse-Roosa küla"/><asula kood="9129" nimi="Vastsekivi küla"/><asula kood="9261" nimi="Vihkla küla"/><asula kood="9307" nimi="Viitina küla"/><asula kood="9329" nimi="Viliksaarõ küla"/><asula kood="9345" nimi="Villa küla"/><asula kood="9354" nimi="Villike küla"/><asula kood="9391" nimi="Viru küla"/><asula kood="9445" nimi="Vodi küla"/><asula kood="9487" nimi="Vorstimäe küla"/><asula kood="9488" nimi="Vungi küla"/><asula kood="9640" nimi="Väiko-Tiilige küla"/><asula kood="9643" nimi="Väiku-Ruuga küla"/><asula kood="9665" nimi="Vänni küla"/></vald><vald kood="0732" nimi="Setomaa vald"><asula kood="1170" nimi="Ala-Tsumba küla"/><asula kood="1264" nimi="Antkruva küla"/><asula kood="1453" nimi="Audjassaare küla"/><asula kood="1489" nimi="Beresje küla"/><asula kood="1626" nimi="Ermakova küla"/><asula kood="1804" nimi="Helbi küla"/><asula kood="1838" nimi="Hilana küla"/><asula kood="1839" nimi="Hilläkeste küla"/><asula kood="1859" nimi="Hindsa küla"/><asula kood="1876" nimi="Holdi küla"/><asula kood="1953" nimi="Härmä küla"/><asula kood="1998" nimi="Ignasõ küla"/><asula kood="2003" nimi="Igrise küla"/><asula kood="2143" nimi="Jaanimäe küla"/><asula kood="2221" nimi="Juusa küla"/><asula kood="2278" nimi="Jõksi küla"/><asula kood="2362" nimi="Järvepää küla"/><asula kood="2512" nimi="Kahkva küla"/><asula kood="2565" nimi="Kalatsova küla"/><asula kood="2665" nimi="Kangavitsa küla"/><asula kood="2703" nimi="Karamsina küla"/><asula kood="2736" nimi="Karisilla küla"/><asula kood="2786" nimi="Kasakova küla"/><asula kood="2821" nimi="Kastamara küla"/><asula kood="2961" nimi="Keerba küla"/><asula kood="3041" nimi="Kiiova küla"/><asula kood="3053" nimi="Kiislova küla"/><asula kood="3071" nimi="Kiksova küla"/><asula kood="3164" nimi="Kitsõ küla"/><asula kood="3197" nimi="Klistina küla"/><asula kood="3277" nimi="Koidula küla"/><asula kood="3358" nimi="Kolodavitsa küla"/><asula kood="3359" nimi="Kolossova küla"/><asula kood="3451" nimi="Koorla küla"/><asula kood="3444" nimi="Korela küla"/><asula kood="3454" nimi="Korski küla"/><asula kood="3468" nimi="Kossa küla"/><asula kood="3470" nimi="Kostkova küla"/><asula kood="3494" nimi="Kremessova küla"/><asula kood="3502" nimi="Kriiva küla"/><asula kood="3536" nimi="Kuigõ küla"/><asula kood="3567" nimi="Kuksina küla"/><asula kood="3609" nimi="Kundruse küla"/><asula kood="3701" nimi="Kusnetsova küla"/><asula kood="3845" nimi="Kõõru küla"/><asula kood="3988" nimi="Küllätüvä küla"/><asula kood="4114" nimi="Laossina küla"/><asula kood="4228" nimi="Leimani küla"/><asula kood="4297" nimi="Lepä küla"/><asula kood="4387" nimi="Lindsi küla"/><asula kood="4425" nimi="Litvina küla"/><asula kood="4434" nimi="Lobotka küla"/><asula kood="4570" nimi="Lutepää küla"/><asula kood="4571" nimi="Lutja küla"/><asula kood="4540" nimi="Lütä küla"/><asula kood="4692" nimi="Lüübnitsa küla"/><asula kood="4710" nimi="Maaslova küla"/><asula kood="4785" nimi="Marinova küla"/><asula kood="4798" nimi="Martsina küla"/><asula kood="4804" nimi="Masluva küla"/><asula kood="4827" nimi="Matsuri küla"/><asula kood="4866" nimi="Melso küla"/><asula kood="4872" nimi="Merekülä küla"/><asula kood="4879" nimi="Meremäe küla"/><asula kood="4843" nimi="Miikse küla"/><asula kood="4951" nimi="Mikitamäe küla"/><asula kood="4950" nimi="Miku küla"/><asula kood="4970" nimi="Mokra küla"/><asula kood="5297" nimi="Määsi küla"/><asula kood="5300" nimi="Määsovitsa küla"/><asula kood="5354" nimi="Napi küla"/><asula kood="5376" nimi="Navikõ küla"/><asula kood="5387" nimi="Nedsaja küla"/><asula kood="5422" nimi="Niitsiku küla"/><asula kood="5582" nimi="Obinitsa küla"/><asula kood="5658" nimi="Olehkova küla"/><asula kood="5746" nimi="Ostrova küla"/><asula kood="5900" nimi="Paklova küla"/><asula kood="5914" nimi="Palandõ küla"/><asula kood="5938" nimi="Palo küla"/><asula kood="5945" nimi="Paloveere küla"/><asula kood="6045" nimi="Pattina küla"/><asula kood="6094" nimi="Pelsi küla"/><asula kood="6115" nimi="Perdaku küla"/><asula kood="6288" nimi="Pliia küla"/><asula kood="6305" nimi="Podmotsa küla"/><asula kood="6313" nimi="Poksa küla"/><asula kood="6319" nimi="Polovina küla"/><asula kood="6326" nimi="Popovitsa küla"/><asula kood="6375" nimi="Pruntova küla"/><asula kood="6412" nimi="Puista küla"/><asula kood="6474" nimi="Puugnitsa küla"/><asula kood="6543" nimi="Põrstõ küla"/><asula kood="6823" nimi="Raotu küla"/><asula kood="7045" nimi="Rokina küla"/><asula kood="7152" nimi="Ruutsi küla"/><asula kood="7170" nimi="Rõsna küla"/><asula kood="7243" nimi="Rääptsova küla"/><asula kood="7250" nimi="Rääsolaane küla"/><asula kood="7270" nimi="Saabolda küla"/><asula kood="7274" nimi="Saagri küla"/><asula kood="7315" nimi="Saatse küla"/><asula kood="7404" nimi="Samarina küla"/><asula kood="7523" nimi="Selise küla"/><asula kood="7549" nimi="Seretsüvä küla"/><asula kood="7547" nimi="Serga küla"/><asula kood="7553" nimi="Sesniki küla"/><asula kood="7628" nimi="Sirgova küla"/><asula kood="7786" nimi="Sulbi küla"/><asula kood="7928" nimi="Säpina küla"/><asula kood="8082" nimi="Talka küla"/><asula kood="8175" nimi="Tedre küla"/><asula kood="8191" nimi="Tepia küla"/><asula kood="8199" nimi="Tessova küla"/><asula kood="8204" nimi="Teterüvä küla"/><asula kood="8177" nimi="Tiastõ küla"/><asula kood="8224" nimi="Tiilige küla"/><asula kood="8223" nimi="Tiirhanna küla"/><asula kood="8231" nimi="Tiklasõ küla"/><asula kood="8266" nimi="Tobrova küla"/><asula kood="8286" nimi="Tonja küla"/><asula kood="8314" nimi="Toodsi küla"/><asula kood="8300" nimi="Toomasmäe küla"/><asula kood="8337" nimi="Treiali küla"/><asula kood="8343" nimi="Treski küla"/><asula kood="8341" nimi="Triginä küla"/><asula kood="8359" nimi="Tserebi küla"/><asula kood="8355" nimi="Tsergondõ küla"/><asula kood="8363" nimi="Tsirgu küla"/><asula kood="8375" nimi="Tsumba küla"/><asula kood="8416" nimi="Tuplova küla"/><asula kood="8459" nimi="Tuulova küla"/><asula kood="8584" nimi="Tääglova küla"/><asula kood="8648" nimi="Ulaskova küla"/><asula kood="8657" nimi="Ulitina küla"/><asula kood="8737" nimi="Usinitsa küla"/><asula kood="8793" nimi="Uusvada küla"/><asula kood="8797" nimi="Vaaksaarõ küla"/><asula kood="8813" nimi="Vaartsi küla"/><asula kood="9078" nimi="Varesmäe küla"/><asula kood="9112" nimi="Vasla küla"/><asula kood="9151" nimi="Vedernika küla"/><asula kood="9194" nimi="Velna küla"/><asula kood="9208" nimi="Veretinä küla"/><asula kood="9216" nimi="Verhulitsa küla"/><asula kood="9373" nimi="Vinski küla"/><asula kood="9384" nimi="Viro küla"/><asula kood="9484" nimi="Voropi küla"/><asula kood="9567" nimi="Võmmorski küla"/><asula kood="9571" nimi="Võpolsova küla"/><asula kood="9607" nimi="Võõpsu küla"/><asula kood="9635" nimi="Väike-Rõsna küla"/><asula kood="9639" nimi="Väiko-Härmä küla"/><asula kood="9637" nimi="Väiko-Serga küla"/><asula kood="9672" nimi="Värska alevik"/><asula kood="9707" nimi="Õrsava küla"/></vald><vald kood="0919" nimi="Võru linn"/><vald kood="0917" nimi="Võru vald"><asula kood="1163" nimi="Alakülä küla"/><asula kood="1172" nimi="Alapõdra küla"/><asula kood="1305" nimi="Andsumäe küla"/><asula kood="1751" nimi="Haamaste küla"/><asula kood="1697" nimi="Haava küla"/><asula kood="1698" nimi="Haava-Tsäpsi küla"/><asula kood="1134" nimi="Haidaku küla"/><asula kood="1744" nimi="Halla küla"/><asula kood="1755" nimi="Hanikase küla"/><asula kood="1759" nimi="Hannuste küla"/><asula kood="1764" nimi="Hargi küla"/><asula kood="1786" nimi="Heeska küla"/><asula kood="1796" nimi="Heinasoo küla"/><asula kood="1810" nimi="Hellekunnu küla"/><asula kood="1856" nimi="Hinniala küla"/><asula kood="1860" nimi="Hinsa küla"/><asula kood="1886" nimi="Holsta küla"/><asula kood="1894" nimi="Horma küla"/><asula kood="1917" nimi="Husari küla"/><asula kood="8744" nimi="Hutita küla"/><asula kood="1942" nimi="Hänike küla"/><asula kood="2040" nimi="Illi küla"/><asula kood="2082" nimi="Indra küla"/><asula kood="2172" nimi="Jantra küla"/><asula kood="2184" nimi="Jeedasküla"/><asula kood="2203" nimi="Juba küla"/><asula kood="2212" nimi="Juraski küla"/><asula kood="2365" nimi="Järvere küla"/><asula kood="2389" nimi="Kaagu küla"/><asula kood="2514" nimi="Kahkva küla"/><asula kood="2515" nimi="Kahro küla"/><asula kood="2551" nimi="Kaku küla"/><asula kood="2559" nimi="Kakusuu küla"/><asula kood="2646" nimi="Kamnitsa küla"/><asula kood="2683" nimi="Kannu küla"/><asula kood="2694" nimi="Kapera küla"/><asula kood="2789" nimi="Kasaritsa küla"/><asula kood="2911" nimi="Keema küla"/><asula kood="2963" nimi="Kerepäälse küla"/><asula kood="3130" nimi="Kirikumäe küla"/><asula kood="3153" nimi="Kirumpää küla"/><asula kood="3199" nimi="Kliima küla"/><asula kood="3333" nimi="Kolepi küla"/><asula kood="3360" nimi="Koloreino küla"/><asula kood="3446" nimi="Korgõmõisa küla"/><asula kood="3450" nimi="Kornitsa küla"/><asula kood="3462" nimi="Kose alevik"/><asula kood="3649" nimi="Kurenurme küla"/><asula kood="3704" nimi="Kusma küla"/><asula kood="3750" nimi="Kõivsaare küla"/><asula kood="3755" nimi="Kõliküla"/><asula kood="3776" nimi="Kõo küla"/><asula kood="3796" nimi="Kõrgessaare küla"/><asula kood="3818" nimi="Kõrve küla"/><asula kood="3838" nimi="Kõvera küla"/><asula kood="3883" nimi="Käpa küla"/><asula kood="3903" nimi="Kärgula küla"/><asula kood="3921" nimi="Kärnamäe küla"/><asula kood="3944" nimi="Kääpa küla"/><asula kood="3956" nimi="Käätso küla"/><asula kood="3965" nimi="Kühmamäe küla"/><asula kood="3981" nimi="Külaoru küla"/><asula kood="3991" nimi="Kündja küla"/><asula kood="4079" nimi="Lakovitsa küla"/><asula kood="4118" nimi="Lapi küla"/><asula kood="4130" nimi="Lasva küla"/><asula kood="4136" nimi="Lauga küla"/><asula kood="4203" nimi="Lehemetsa küla"/><asula kood="4240" nimi="Leiso küla"/><asula kood="4286" nimi="Lepassaare küla"/><asula kood="4348" nimi="Liinamäe küla"/><asula kood="4357" nimi="Liiva küla"/><asula kood="4373" nimi="Lilli-Anne küla"/><asula kood="4386" nimi="Lindora küla"/><asula kood="4401" nimi="Linnamäe küla"/><asula kood="4424" nimi="Listaku küla"/><asula kood="4490" nimi="Lompka küla"/><asula kood="4517" nimi="Loosi küla"/><asula kood="4519" nimi="Loosu küla"/><asula kood="4544" nimi="Luhte küla"/><asula kood="4594" nimi="Luuska küla"/><asula kood="4715" nimi="Madala küla"/><asula kood="4716" nimi="Madi küla"/><asula kood="4750" nimi="Majala küla"/><asula kood="4784" nimi="Marga küla"/><asula kood="4839" nimi="Meegomäe küla"/><asula kood="4845" nimi="Meeliku küla"/><asula kood="5071" nimi="Mustassaare küla"/><asula kood="5077" nimi="Mustja küla"/><asula kood="5100" nimi="Mutsu küla"/><asula kood="5135" nimi="Mõisamäe küla"/><asula kood="5141" nimi="Mõksi küla"/><asula kood="5167" nimi="Mõrgi küla"/><asula kood="5192" nimi="Mäe-Kõoküla"/><asula kood="5188" nimi="Mäekülä küla"/><asula kood="5210" nimi="Mäessaare küla"/><asula kood="5307" nimi="Möldri küla"/><asula kood="5378" nimi="Navi küla"/><asula kood="5440" nimi="Noodasküla"/><asula kood="5450" nimi="Nooska küla"/><asula kood="5531" nimi="Nõnova küla"/><asula kood="5660" nimi="Oleski küla"/><asula kood="5708" nimi="Orava küla"/><asula kood="5731" nimi="Oro küla"/><asula kood="5734" nimi="Ortuma küla"/><asula kood="5749" nimi="Osula küla"/><asula kood="5766" nimi="Otsa küla"/><asula kood="5862" nimi="Paidra küla"/><asula kood="5941" nimi="Palometsa küla"/><asula kood="5943" nimi="Paloveere küla"/><asula kood="6002" nimi="Pari küla"/><asula kood="6017" nimi="Parksepa alevik"/><asula kood="6107" nimi="Peraküla"/><asula kood="6112" nimi="Perametsa küla"/><asula kood="6212" nimi="Pikakannu küla"/><asula kood="6220" nimi="Pikasilla küla"/><asula kood="6255" nimi="Pille küla"/><asula kood="6269" nimi="Pindi küla"/><asula kood="6283" nimi="Piusa küla"/><asula kood="6293" nimi="Plessi küla"/><asula kood="6345" nimi="Praakmani küla"/><asula kood="6376" nimi="Pritsi küla"/><asula kood="6411" nimi="Puiga küla"/><asula kood="6430" nimi="Pulli küla"/><asula kood="6431" nimi="Punakülä küla"/><asula kood="6482" nimi="Puusepa küla"/><asula kood="6484" nimi="Puutli küla"/><asula kood="6585" nimi="Päka küla"/><asula kood="6625" nimi="Pässä küla"/><asula kood="6633" nimi="Pääväkese küla"/><asula kood="6673" nimi="Raadi küla"/><asula kood="6761" nimi="Raiste küla"/><asula kood="6856" nimi="Raudsepa küla"/><asula kood="6864" nimi="Rauskapalu küla"/><asula kood="6896" nimi="Rebasmäe küla"/><asula kood="6985" nimi="Riihora küla"/><asula kood="7078" nimi="Roosisaare küla"/><asula kood="7119" nimi="Rummi küla"/><asula kood="7128" nimi="Rusima küla"/><asula kood="7173" nimi="Rõssa küla"/><asula kood="7217" nimi="Räpo küla"/><asula kood="7281" nimi="Saarde küla"/><asula kood="7292" nimi="Saaremaa küla"/><asula kood="7503" nimi="Savioja küla"/><asula kood="7576" nimi="Sika küla"/><asula kood="7652" nimi="Soe küla"/><asula kood="7657" nimi="Soena küla"/><asula kood="7707" nimi="Sooküla"/><asula kood="7787" nimi="Sulbi küla"/><asula kood="7820" nimi="Sutte küla"/><asula kood="7843" nimi="Suuremetsa küla"/><asula kood="7887" nimi="Sõmerpalu alevik"/><asula kood="7888" nimi="Sõmerpalu küla"/><asula kood="8014" nimi="Tabina küla"/><asula kood="8040" nimi="Tagaküla"/><asula kood="8081" nimi="Tallikeste küla"/><asula kood="7326" nimi="Tamme küla"/><asula kood="8124" nimi="Tammsaare küla"/><asula kood="8192" nimi="Tellaste küla"/><asula kood="8252" nimi="Tiri küla"/><asula kood="8267" nimi="Tohkri küla"/><asula kood="8315" nimi="Tootsi küla"/><asula kood="8372" nimi="Tsolgo küla"/><asula kood="8376" nimi="Tsolli küla"/><asula kood="8385" nimi="Tuderna küla"/><asula kood="8601" nimi="Tüütsmäe küla"/><asula kood="8620" nimi="Udsali küla"/><asula kood="8669" nimi="Umbsaare küla"/><asula kood="8811" nimi="Vaarkali küla"/><asula kood="8833" nimi="Vagula küla"/><asula kood="8994" nimi="Vana-Nursi küla"/><asula kood="9004" nimi="Vana-Saaluse küla"/><asula kood="8855" nimi="Vana-Vastseliina küla"/><asula kood="9074" nimi="Varese küla"/><asula kood="9133" nimi="Vastseliina alevik"/><asula kood="9144" nimi="Vatsa küla"/><asula kood="9218" nimi="Verijärve küla"/><asula kood="9310" nimi="Viitka küla"/><asula kood="9346" nimi="Villa küla"/><asula kood="9440" nimi="Vivva küla"/><asula kood="9458" nimi="Voki küla"/><asula kood="8109" nimi="Voki-Tamme küla"/><asula kood="9564" nimi="Võlsi küla"/><asula kood="9585" nimi="Võrumõisa küla"/><asula kood="9588" nimi="Võrusoo küla"/><asula kood="9636" nimi="Väimela alevik"/><asula kood="9641" nimi="Väiso küla"/></vald></maakond></ehak>	ehak	2021-01-27 10:25:45.773688	2021-01-27 10:25:45.773688	admin	\N	\N	\N	\N	\N	\N	\N	\N
16	<ehak><maakond kood="0037" nimi="Harju maakond"/><maakond kood="0039" nimi="Hiiu maakond"/><maakond kood="0044" nimi="Ida-Viru maakond"/><maakond kood="0049" nimi="Jõgeva maakond"/><maakond kood="0051" nimi="Järva maakond"/><maakond kood="0057" nimi="Lääne maakond"/><maakond kood="0059" nimi="Lääne-Viru maakond"/><maakond kood="0065" nimi="Põlva maakond"/><maakond kood="0067" nimi="Pärnu maakond"/><maakond kood="0070" nimi="Rapla maakond"/><maakond kood="0074" nimi="Saare maakond"/><maakond kood="0078" nimi="Tartu maakond"/><maakond kood="0082" nimi="Valga maakond"/><maakond kood="0084" nimi="Viljandi maakond"/><maakond kood="0086" nimi="Võru maakond"/></ehak>	maakonnad	2021-01-27 10:25:45.780031	2021-01-27 10:25:45.780031	admin	\N	\N	\N	\N	\N	\N	\N	\N
17	<ehak><maakond kood="0037"><vald kood="0296" nimi="Keila linn"/><vald kood="0424" nimi="Loksa linn"/><vald kood="0446" nimi="Maardu linn"/><vald kood="0580" nimi="Paldiski linn"/><vald kood="0728" nimi="Saue linn"/><vald kood="0784" nimi="Tallinn"/><vald kood="0112" nimi="Aegviidu vald"/><vald kood="0140" nimi="Anija vald"/><vald kood="0198" nimi="Harku vald"/><vald kood="0245" nimi="Jõelähtme vald"/><vald kood="0295" nimi="Keila vald"/><vald kood="0297" nimi="Kernu vald"/><vald kood="0304" nimi="Kiili vald"/><vald kood="0338" nimi="Kose vald"/><vald kood="0353" nimi="Kuusalu vald"/><vald kood="0518" nimi="Nissi vald"/><vald kood="0562" nimi="Padise vald"/><vald kood="0651" nimi="Raasiku vald"/><vald kood="0653" nimi="Rae vald"/><vald kood="0718" nimi="Saku vald"/><vald kood="0727" nimi="Saue vald"/><vald kood="0868" nimi="Vasalemma vald"/><vald kood="0890" nimi="Viimsi vald"/></maakond><maakond kood="0039"><vald kood="0175" nimi="Emmaste vald"/><vald kood="0204" nimi="Hiiu vald"/><vald kood="0368" nimi="Käina vald"/><vald kood="0639" nimi="Pühalepa vald"/></maakond><maakond kood="0044"><vald kood="0309" nimi="Kiviõli linn"/><vald kood="0322" nimi="Kohtla-Järve linn"/><vald kood="0513" nimi="Narva-Jõesuu linn"/><vald kood="0511" nimi="Narva linn"/><vald kood="0735" nimi="Sillamäe linn"/><vald kood="0122" nimi="Alajõe vald"/><vald kood="0154" nimi="Aseri vald"/><vald kood="0164" nimi="Avinurme vald"/><vald kood="0224" nimi="Iisaku vald"/><vald kood="0229" nimi="Illuka vald"/><vald kood="0251" nimi="Jõhvi vald"/><vald kood="0323" nimi="Kohtla-Nõmme vald"/><vald kood="0320" nimi="Kohtla vald"/><vald kood="0420" nimi="Lohusuu vald"/><vald kood="0438" nimi="Lüganuse vald"/><vald kood="0498" nimi="Mäetaguse vald"/><vald kood="0751" nimi="Sonda vald"/><vald kood="0802" nimi="Toila vald"/><vald kood="0815" nimi="Tudulinna vald"/><vald kood="0851" nimi="Vaivara vald"/></maakond><maakond kood="0049"><vald kood="0249" nimi="Jõgeva linn"/><vald kood="0485" nimi="Mustvee linn"/><vald kood="0617" nimi="Põltsamaa linn"/><vald kood="0248" nimi="Jõgeva vald"/><vald kood="0657" nimi="Kasepää vald"/><vald kood="0573" nimi="Pajusi vald"/><vald kood="0578" nimi="Palamuse vald"/><vald kood="0576" nimi="Pala vald"/><vald kood="0611" nimi="Puurmani vald"/><vald kood="0616" nimi="Põltsamaa vald"/><vald kood="0713" nimi="Saare vald"/><vald kood="0773" nimi="Tabivere vald"/><vald kood="0810" nimi="Torma vald"/></maakond><maakond kood="0051"><vald kood="0566" nimi="Paide linn"/><vald kood="0129" nimi="Albu vald"/><vald kood="0134" nimi="Ambla vald"/><vald kood="0234" nimi="Imavere vald"/><vald kood="0257" nimi="Järva-Jaani vald"/><vald kood="0288" nimi="Kareda vald"/><vald kood="0314" nimi="Koeru vald"/><vald kood="0325" nimi="Koigi vald"/><vald kood="0565" nimi="Paide vald"/><vald kood="0684" nimi="Roosna-Alliku vald"/><vald kood="0835" nimi="Türi vald"/><vald kood="0937" nimi="Väätsa vald"/></maakond><maakond kood="0057"><vald kood="0183" nimi="Haapsalu linn"/><vald kood="0195" nimi="Hanila vald"/><vald kood="0342" nimi="Kullamaa vald"/><vald kood="0411" nimi="Lihula vald"/><vald kood="0436" nimi="Lääne-Nigula vald"/><vald kood="0452" nimi="Martna vald"/><vald kood="0520" nimi="Noarootsi vald"/><vald kood="0531" nimi="Nõva vald"/><vald kood="0674" nimi="Ridala vald"/><vald kood="0907" nimi="Vormsi vald"/></maakond><maakond kood="0059"><vald kood="0345" nimi="Kunda linn"/><vald kood="0663" nimi="Rakvere linn"/><vald kood="0190" nimi="Haljala vald"/><vald kood="0272" nimi="Kadrina vald"/><vald kood="0381" nimi="Laekvere vald"/><vald kood="0660" nimi="Rakke vald"/><vald kood="0662" nimi="Rakvere vald"/><vald kood="0702" nimi="Rägavere vald"/><vald kood="0770" nimi="Sõmeru vald"/><vald kood="0786" nimi="Tamsalu vald"/><vald kood="0790" nimi="Tapa vald"/><vald kood="0887" nimi="Vihula vald"/><vald kood="0900" nimi="Vinni vald"/><vald kood="0902" nimi="Viru-Nigula vald"/><vald kood="0926" nimi="Väike-Maarja vald"/></maakond><maakond kood="0065"><vald kood="0117" nimi="Ahja vald"/><vald kood="0285" nimi="Kanepi vald"/><vald kood="0354" nimi="Kõlleste vald"/><vald kood="0385" nimi="Laheda vald"/><vald kood="0465" nimi="Mikitamäe vald"/><vald kood="0473" nimi="Mooste vald"/><vald kood="0547" nimi="Orava vald"/><vald kood="0621" nimi="Põlva vald"/><vald kood="0707" nimi="Räpina vald"/><vald kood="0856" nimi="Valgjärve vald"/><vald kood="0872" nimi="Vastse-Kuuste vald"/><vald kood="0879" nimi="Veriora vald"/><vald kood="0934" nimi="Värska vald"/></maakond><maakond kood="0067"><vald kood="0625" nimi="Pärnu linn"/><vald kood="0741" nimi="Sindi linn"/><vald kood="0149" nimi="Are vald"/><vald kood="0160" nimi="Audru vald"/><vald kood="0188" nimi="Halinga vald"/><vald kood="0213" nimi="Häädemeeste vald"/><vald kood="0303" nimi="Kihnu vald"/><vald kood="0334" nimi="Koonga vald"/><vald kood="0568" nimi="Paikuse vald"/><vald kood="0710" nimi="Saarde vald"/><vald kood="0730" nimi="Sauga vald"/><vald kood="0756" nimi="Surju vald"/><vald kood="0848" nimi="Tahkuranna vald"/><vald kood="0805" nimi="Tootsi vald"/><vald kood="0808" nimi="Tori vald"/><vald kood="0826" nimi="Tõstamaa vald"/><vald kood="0863" nimi="Varbla vald"/><vald kood="0929" nimi="Vändra vald"/><vald kood="0931" nimi="Vändra vald (alev)"/></maakond><maakond kood="0070"><vald kood="0240" nimi="Juuru vald"/><vald kood="0260" nimi="Järvakandi vald"/><vald kood="0277" nimi="Kaiu vald"/><vald kood="0292" nimi="Kehtna vald"/><vald kood="0317" nimi="Kohila vald"/><vald kood="0375" nimi="Käru vald"/><vald kood="0504" nimi="Märjamaa vald"/><vald kood="0654" nimi="Raikküla vald"/><vald kood="0669" nimi="Rapla vald"/><vald kood="0884" nimi="Vigala vald"/></maakond><maakond kood="0074"><vald kood="0349" nimi="Kuressaare linn"/><vald kood="0301" nimi="Kihelkonna vald"/><vald kood="0386" nimi="Laimjala vald"/><vald kood="0403" nimi="Leisi vald"/><vald kood="0433" nimi="Lääne-Saare vald"/><vald kood="0478" nimi="Muhu vald"/><vald kood="0483" nimi="Mustjala vald"/><vald kood="0550" nimi="Orissaare vald"/><vald kood="0592" nimi="Pihtla vald"/><vald kood="0634" nimi="Pöide vald"/><vald kood="0689" nimi="Ruhnu vald"/><vald kood="0721" nimi="Salme vald"/><vald kood="0807" nimi="Torgu vald"/><vald kood="0858" nimi="Valjala vald"/></maakond><maakond kood="0078"><vald kood="0170" nimi="Elva linn"/><vald kood="0279" nimi="Kallaste linn"/><vald kood="0795" nimi="Tartu linn"/><vald kood="0126" nimi="Alatskivi vald"/><vald kood="0185" nimi="Haaslava vald"/><vald kood="0282" nimi="Kambja vald"/><vald kood="0331" nimi="Konguta vald"/><vald kood="0383" nimi="Laeva vald"/><vald kood="0432" nimi="Luunja vald"/><vald kood="0454" nimi="Meeksi vald"/><vald kood="0501" nimi="Mäksa vald"/><vald kood="0528" nimi="Nõo vald"/><vald kood="0587" nimi="Peipsiääre vald"/><vald kood="0595" nimi="Piirissaare vald"/><vald kood="0605" nimi="Puhja vald"/><vald kood="0666" nimi="Rannu vald"/><vald kood="0694" nimi="Rõngu vald"/><vald kood="0794" nimi="Tartu vald"/><vald kood="0831" nimi="Tähtvere vald"/><vald kood="0861" nimi="Vara vald"/><vald kood="0915" nimi="Võnnu vald"/><vald kood="0949" nimi="Ülenurme vald"/></maakond><maakond kood="0082"><vald kood="0823" nimi="Tõrva linn"/><vald kood="0854" nimi="Valga linn"/><vald kood="0203" nimi="Helme vald"/><vald kood="0208" nimi="Hummuli vald"/><vald kood="0289" nimi="Karula vald"/><vald kood="0636" nimi="Otepää vald"/><vald kood="0582" nimi="Palupera vald"/><vald kood="0608" nimi="Puka vald"/><vald kood="0613" nimi="Põdrala vald"/><vald kood="0724" nimi="Sangaste vald"/><vald kood="0779" nimi="Taheva vald"/><vald kood="0820" nimi="Tõlliste vald"/><vald kood="0943" nimi="Õru vald"/></maakond><maakond kood="0084"><vald kood="0490" nimi="Mõisaküla linn"/><vald kood="0897" nimi="Viljandi linn"/><vald kood="0912" nimi="Võhma linn"/><vald kood="0105" nimi="Abja vald"/><vald kood="0192" nimi="Halliste vald"/><vald kood="0600" nimi="Karksi vald"/><vald kood="0328" nimi="Kolga-Jaani vald"/><vald kood="0357" nimi="Kõo vald"/><vald kood="0360" nimi="Kõpu vald"/><vald kood="0758" nimi="Suure-Jaani vald"/><vald kood="0797" nimi="Tarvastu vald"/><vald kood="0898" nimi="Viljandi vald"/></maakond><maakond kood="0086"><vald kood="0919" nimi="Võru linn"/><vald kood="0143" nimi="Antsla vald"/><vald kood="0181" nimi="Haanja vald"/><vald kood="0389" nimi="Lasva vald"/><vald kood="0460" nimi="Meremäe vald"/><vald kood="0468" nimi="Misso vald"/><vald kood="0493" nimi="Mõniste vald"/><vald kood="0697" nimi="Rõuge vald"/><vald kood="0767" nimi="Sõmerpalu vald"/><vald kood="0843" nimi="Urvaste vald"/><vald kood="0865" nimi="Varstu vald"/><vald kood="0874" nimi="Vastseliina vald"/><vald kood="0918" nimi="Võru vald"/></maakond></ehak>	vallad	2021-01-27 10:25:45.780843	2021-01-27 10:25:45.780843	admin	\N	\N	\N	\N	\N	\N	\N	\N
18	<ehak><maakond kood="0037"><vald kood="0784"><asula kood="0176" nimi="Haabersti linnaosa"/><asula kood="0298" nimi="Kesklinna linnaosa"/><asula kood="0339" nimi="Kristiine linnaosa"/><asula kood="0387" nimi="Lasnamäe linnaosa"/><asula kood="0482" nimi="Mustamäe linnaosa"/><asula kood="0524" nimi="Nõmme linnaosa"/><asula kood="0596" nimi="Pirita linnaosa"/><asula kood="0614" nimi="Põhja-Tallinna linnaosa"/></vald><vald kood="0112"><asula kood="1088" nimi="Aegviidu alev"/></vald><vald kood="0140"><asula kood="1046" nimi="Aavere küla"/><asula kood="1184" nimi="Alavere küla"/><asula kood="1278" nimi="Anija küla"/><asula kood="1321" nimi="Arava küla"/><asula kood="1961" nimi="Härmakosu küla"/><asula kood="2877" nimi="Kaunissaare küla"/><asula kood="2925" nimi="Kehra küla"/><asula kood="2928" nimi="Kehra linn"/><asula kood="3022" nimi="Kihmla küla"/><asula kood="3716" nimi="Kuusemäe küla"/><asula kood="4213" nimi="Lehtmetsa küla"/><asula kood="4369" nimi="Lilli küla"/><asula kood="4397" nimi="Linnakse küla"/><asula kood="4506" nimi="Looküla"/><asula kood="4672" nimi="Lükati küla"/><asula kood="5082" nimi="Mustjõe küla"/><asula kood="5789" nimi="Paasiku küla"/><asula kood="6009" nimi="Parila küla"/><asula kood="6022" nimi="Partsaare küla"/><asula kood="6241" nimi="Pikva küla"/><asula kood="6254" nimi="Pillapalu küla"/><asula kood="6828" nimi="Rasivere küla"/><asula kood="6855" nimi="Raudoja küla"/><asula kood="7068" nimi="Rooküla"/><asula kood="7396" nimi="Salumetsa küla"/><asula kood="7398" nimi="Salumäe küla"/><asula kood="7693" nimi="Soodla küla"/><asula kood="8764" nimi="Uuearu küla"/><asula kood="9248" nimi="Vetla küla"/><asula kood="9318" nimi="Vikipalu küla"/><asula kood="9480" nimi="Voose küla"/><asula kood="9827" nimi="Ülejõe küla"/></vald><vald kood="0198"><asula kood="1084" nimi="Adra küla"/><asula kood="1774" nimi="Harku alevik"/><asula kood="1776" nimi="Harkujärve küla"/><asula kood="1903" nimi="Humala küla"/><asula kood="2048" nimi="Ilmandu küla"/><asula kood="3608" nimi="Kumna küla"/><asula kood="3997" nimi="Kütke küla"/><asula kood="4002" nimi="Laabi küla"/><asula kood="4344" nimi="Liikva küla"/><asula kood="5039" nimi="Muraste küla"/><asula kood="5327" nimi="Naage küla"/><asula kood="6814" nimi="Rannamõisa küla"/><asula kood="7871" nimi="Suurupi küla"/><asula kood="7905" nimi="Sõrve küla"/><asula kood="8009" nimi="Tabasalu alevik"/><asula kood="8257" nimi="Tiskre küla"/><asula kood="8442" nimi="Tutermaa küla"/><asula kood="8599" nimi="Türisalu küla"/><asula kood="8848" nimi="Vahi küla"/><asula kood="8877" nimi="Vaila küla"/><asula kood="9434" nimi="Viti küla"/><asula kood="9685" nimi="Vääna-Jõesuu küla"/><asula kood="9683" nimi="Vääna küla"/></vald><vald kood="0245"><asula kood="1367" nimi="Aruaru küla"/><asula kood="1691" nimi="Haapse küla"/><asula kood="1741" nimi="Haljava küla"/><asula kood="2009" nimi="Ihasalu küla"/><asula kood="2100" nimi="Iru küla"/><asula kood="2234" nimi="Jõelähtme küla"/><asula kood="2248" nimi="Jõesuu küla"/><asula kood="2301" nimi="Jägala-Joa küla"/><asula kood="2299" nimi="Jägala küla"/><asula kood="2452" nimi="Kaberneeme küla"/><asula kood="2601" nimi="Kallavere küla"/><asula kood="3296" nimi="Koila küla"/><asula kood="3301" nimi="Koipsi küla"/><asula kood="3385" nimi="Koogi küla"/><asula kood="3471" nimi="Kostiranna küla"/><asula kood="3472" nimi="Kostivere alevik"/><asula kood="3588" nimi="Kullamäe küla"/><asula kood="4359" nimi="Liivamäe küla"/><asula kood="4496" nimi="Loo alevik"/><asula kood="4494" nimi="Loo küla"/><asula kood="4704" nimi="Maardu küla"/><asula kood="4776" nimi="Manniva küla"/><asula kood="5389" nimi="Neeme küla"/><asula kood="5400" nimi="Nehatu küla"/><asula kood="5997" nimi="Parasmäe küla"/><asula kood="6785" nimi="Rammu küla"/><asula kood="6882" nimi="Rebala küla"/><asula kood="7037" nimi="Rohusi küla"/><asula kood="7141" nimi="Ruu küla"/><asula kood="7335" nimi="Saha küla"/><asula kood="7405" nimi="Sambu küla"/><asula kood="7498" nimi="Saviranna küla"/><asula kood="8783" nimi="Uusküla"/><asula kood="9041" nimi="Vandjala küla"/><asula kood="9491" nimi="Võerdla küla"/><asula kood="9838" nimi="Ülgase küla"/></vald><vald kood="0295"><asula kood="2045" nimi="Illurma küla"/><asula kood="2749" nimi="Karjaküla alevik"/><asula kood="2909" nimi="Keelva küla"/><asula kood="2930" nimi="Keila-Joa alevik"/><asula kood="2978" nimi="Kersalu küla"/><asula kood="3205" nimi="Klooga alevik"/><asula kood="3207" nimi="Kloogaranna küla"/><asula kood="3603" nimi="Kulna küla"/><asula kood="3857" nimi="Käesalu küla"/><asula kood="4112" nimi="Laoküla"/><asula kood="4148" nimi="Laulasmaa küla"/><asula kood="4211" nimi="Lehola küla"/><asula kood="4456" nimi="Lohusalu küla"/><asula kood="4725" nimi="Maeru küla"/><asula kood="4876" nimi="Meremõisa küla"/><asula kood="5343" nimi="Nahkjala küla"/><asula kood="5424" nimi="Niitvälja küla"/><asula kood="5628" nimi="Ohtu küla"/><asula kood="6528" nimi="Põllküla"/><asula kood="8460" nimi="Tuulna küla"/><asula kood="8499" nimi="Tõmmiku küla"/><asula kood="8956" nimi="Valkse küla"/></vald><vald kood="0297"><asula kood="1206" nimi="Allika küla"/><asula kood="1720" nimi="Haiba küla"/><asula kood="1854" nimi="Hingu küla"/><asula kood="2427" nimi="Kaasiku küla"/><asula kood="2455" nimi="Kabila küla"/><asula kood="2976" nimi="Kernu küla"/><asula kood="3001" nimi="Kibuna küla"/><asula kood="3120" nimi="Kirikla küla"/><asula kood="3266" nimi="Kohatu küla"/><asula kood="3705" nimi="Kustja küla"/><asula kood="4075" nimi="Laitse küla"/><asula kood="4903" nimi="Metsanurga küla"/><asula kood="5110" nimi="Muusika küla"/><asula kood="5157" nimi="Mõnuste küla"/><asula kood="6308" nimi="Pohla küla"/><asula kood="7110" nimi="Ruila küla"/><asula kood="9049" nimi="Vansi küla"/></vald><vald kood="0304"><asula kood="1388" nimi="Arusta küla"/><asula kood="2671" nimi="Kangru alevik"/><asula kood="3039" nimi="Kiili alev"/><asula kood="3656" nimi="Kurevere küla"/><asula kood="4550" nimi="Luige alevik"/><asula kood="4633" nimi="Lähtse küla"/><asula kood="4902" nimi="Metsanurga küla"/><asula kood="5125" nimi="Mõisaküla"/><asula kood="5329" nimi="Nabala küla"/><asula kood="5824" nimi="Paekna küla"/><asula kood="6198" nimi="Piissoo küla"/><asula kood="7472" nimi="Sausti küla"/><asula kood="7701" nimi="Sookaera küla"/><asula kood="7880" nimi="Sõgula küla"/><asula kood="7894" nimi="Sõmeru küla"/><asula kood="8824" nimi="Vaela küla"/></vald><vald kood="0338"><asula kood="1089" nimi="Aela küla"/><asula kood="1113" nimi="Ahisilla küla"/><asula kood="1174" nimi="Alansi küla"/><asula kood="1340" nimi="Ardu alevik"/><asula kood="1708" nimi="Habaja alevik"/><asula kood="1779" nimi="Harmi küla"/><asula kood="2485" nimi="Kadja küla"/><asula kood="2657" nimi="Kanavere küla"/><asula kood="2690" nimi="Kantküla"/><asula kood="2764" nimi="Karla küla"/><asula kood="2848" nimi="Kata küla"/><asula kood="2852" nimi="Katsina küla"/><asula kood="3140" nimi="Kirivalla küla"/><asula kood="3156" nimi="Kiruvere küla"/><asula kood="3363" nimi="Kolu küla"/><asula kood="3460" nimi="Kose alevik"/><asula kood="3464" nimi="Kose-Uuemõisa alevik"/><asula kood="3492" nimi="Krei küla"/><asula kood="3546" nimi="Kuivajõe küla"/><asula kood="3553" nimi="Kukepala küla"/><asula kood="3829" nimi="Kõrvenurga küla"/><asula kood="3834" nimi="Kõue küla"/><asula kood="4020" nimi="Laane küla"/><asula kood="4242" nimi="Leistu küla"/><asula kood="4352" nimi="Liiva küla"/><asula kood="4577" nimi="Lutsu küla"/><asula kood="4667" nimi="Lööra küla"/><asula kood="4788" nimi="Marguse küla"/><asula kood="5485" nimi="Nutu küla"/><asula kood="5506" nimi="Nõmbra küla"/><asula kood="5518" nimi="Nõmmeri küla"/><asula kood="5537" nimi="Nõrava küla"/><asula kood="5656" nimi="Ojasoo küla"/><asula kood="5738" nimi="Oru küla"/><asula kood="5907" nimi="Pala küla"/><asula kood="5962" nimi="Palvere küla"/><asula kood="6052" nimi="Paunaste küla"/><asula kood="6053" nimi="Paunküla"/><asula kood="6483" nimi="Puusepa küla"/><asula kood="6869" nimi="Rava küla"/><asula kood="6872" nimi="Raveliku küla"/><asula kood="6875" nimi="Ravila alevik"/><asula kood="6981" nimi="Riidamäe küla"/><asula kood="7191" nimi="Rõõsa küla"/><asula kood="7308" nimi="Saarnakõrve küla"/><asula kood="7324" nimi="Sae küla"/><asula kood="7457" nimi="Saula küla"/><asula kood="7597" nimi="Silmsi küla"/><asula kood="7891" nimi="Sõmeru küla"/><asula kood="7963" nimi="Sääsküla"/><asula kood="8022" nimi="Tade küla"/><asula kood="8112" nimi="Tammiku küla"/><asula kood="8346" nimi="Triigi küla"/><asula kood="8396" nimi="Tuhala küla"/><asula kood="8773" nimi="Uueveski küla"/><asula kood="8847" nimi="Vahetüki küla"/><asula kood="9032" nimi="Vanamõisa küla"/><asula kood="9071" nimi="Vardja küla"/><asula kood="9323" nimi="Vilama küla"/><asula kood="9385" nimi="Virla küla"/><asula kood="9417" nimi="Viskla küla"/><asula kood="9558" nimi="Võlle küla"/><asula kood="9749" nimi="Äksi küla"/></vald><vald kood="0353"><asula kood="1202" nimi="Allika küla"/><asula kood="1256" nimi="Andineeme küla"/><asula kood="1363" nimi="Aru küla"/><asula kood="1701" nimi="Haavakannu küla"/><asula kood="1761" nimi="Hara küla"/><asula kood="1877" nimi="Hirvli küla"/><asula kood="2046" nimi="Ilmastalu küla"/><asula kood="2194" nimi="Joaveski küla"/><asula kood="2209" nimi="Juminda küla"/><asula kood="2450" nimi="Kaberla küla"/><asula kood="2509" nimi="Kahala küla"/><asula kood="2629" nimi="Kalme küla"/><asula kood="2804" nimi="Kasispea küla"/><asula kood="2949" nimi="Kemba küla"/><asula kood="3055" nimi="Kiiu-Aabla küla"/><asula kood="3056" nimi="Kiiu alevik"/><asula kood="3232" nimi="Kodasoo küla"/><asula kood="3300" nimi="Koitjärve küla"/><asula kood="1007" nimi="Kolga-Aabla küla"/><asula kood="3336" nimi="Kolga alevik"/><asula kood="3343" nimi="Kolgaküla"/><asula kood="3342" nimi="Kolgu küla"/><asula kood="3474" nimi="Kosu küla"/><asula kood="3480" nimi="Kotka küla"/><asula kood="3630" nimi="Kupu küla"/><asula kood="3691" nimi="Kursi küla"/><asula kood="3714" nimi="Kuusalu alevik"/><asula kood="3718" nimi="Kuusalu küla"/><asula kood="3768" nimi="Kõnnu küla"/><asula kood="3993" nimi="Külmaallika küla"/><asula kood="4188" nimi="Leesi küla"/><asula kood="4334" nimi="Liiapeksi küla"/><asula kood="4471" nimi="Loksa küla"/><asula kood="5048" nimi="Murksi küla"/><asula kood="5064" nimi="Mustametsa küla"/><asula kood="5108" nimi="Muuksi küla"/><asula kood="5208" nimi="Mäepea küla"/><asula kood="5533" nimi="Nõmmeveski küla"/><asula kood="5901" nimi="Pala küla"/><asula kood="6016" nimi="Parksi küla"/><asula kood="6065" nimi="Pedaspea küla"/><asula kood="6378" nimi="Pudisoo küla"/><asula kood="6497" nimi="Põhja küla"/><asula kood="6606" nimi="Pärispea küla"/><asula kood="6898" nimi="Rehatse küla"/><asula kood="7122" nimi="Rummu küla"/><asula kood="7390" nimi="Salmistu küla"/><asula kood="7466" nimi="Saunja küla"/><asula kood="7562" nimi="Sigula küla"/><asula kood="7734" nimi="Soorinna küla"/><asula kood="7809" nimi="Suru küla"/><asula kood="7866" nimi="Suurpea küla"/><asula kood="7882" nimi="Sõitme küla"/><asula kood="8118" nimi="Tammispea küla"/><asula kood="8125" nimi="Tammistu küla"/><asula kood="8144" nimi="Tapurla küla"/><asula kood="8367" nimi="Tsitre küla"/><asula kood="8424" nimi="Turbuneeme küla"/><asula kood="8193" nimi="Tõreska küla"/><asula kood="8782" nimi="Uuri küla"/><asula kood="8839" nimi="Vahastu küla"/><asula kood="8919" nimi="Valgejõe küla"/><asula kood="8954" nimi="Valkla küla"/><asula kood="9014" nimi="Vanaküla"/><asula kood="9257" nimi="Vihasoo küla"/><asula kood="9283" nimi="Viinistu küla"/><asula kood="9411" nimi="Virve küla"/></vald><vald kood="0518"><asula kood="1449" nimi="Aude küla"/><asula kood="1585" nimi="Ellamaa küla"/><asula kood="2135" nimi="Jaanika küla"/><asula kood="3195" nimi="Kivitammi küla"/><asula kood="4206" nimi="Lehetu küla"/><asula kood="4289" nimi="Lepaste küla"/><asula kood="4717" nimi="Madila küla"/><asula kood="5028" nimi="Munalaskme küla"/><asula kood="5093" nimi="Mustu küla"/><asula kood="5467" nimi="Nurme küla"/><asula kood="5601" nimi="Odulemma küla"/><asula kood="6905" nimi="Rehemäe küla"/><asula kood="6989" nimi="Riisipere alevik"/><asula kood="7571" nimi="Siimika küla"/><asula kood="8006" nimi="Tabara küla"/><asula kood="8421" nimi="Turba alevik"/><asula kood="9362" nimi="Vilumäe küla"/><asula kood="9401" nimi="Viruküla"/><asula kood="9846" nimi="Ürjaste küla"/></vald><vald kood="0562"><asula kood="1208" nimi="Alliklepa küla"/><asula kood="1221" nimi="Altküla"/><asula kood="1450" nimi="Audevälja küla"/><asula kood="1771" nimi="Harju-Risti küla"/><asula kood="1782" nimi="Hatu küla"/><asula kood="2731" nimi="Karilepa küla"/><asula kood="2797" nimi="Kasepere küla"/><asula kood="2927" nimi="Keibu küla"/><asula kood="3224" nimi="Kobru küla"/><asula kood="3682" nimi="Kurkse küla"/><asula kood="3762" nimi="Kõmmaste küla"/><asula kood="4019" nimi="Laane küla"/><asula kood="4096" nimi="Langa küla"/><asula kood="4722" nimi="Madise küla"/><asula kood="4931" nimi="Metslõugu küla"/><asula kood="5290" nimi="Määra küla"/><asula kood="5812" nimi="Padise küla"/><asula kood="5821" nimi="Pae küla"/><asula kood="6062" nimi="Pedase küla"/><asula kood="7856" nimi="Suurküla"/><asula kood="9265" nimi="Vihterpalu küla"/><asula kood="9339" nimi="Vilivalla küla"/><asula kood="9380" nimi="Vintse küla"/><asula kood="9767" nimi="Änglema küla"/></vald><vald kood="0651"><asula kood="1373" nimi="Aruküla alevik"/><asula kood="1954" nimi="Härma küla"/><asula kood="1994" nimi="Igavere küla"/><asula kood="2335" nimi="Järsi küla"/><asula kood="2575" nimi="Kalesi küla"/><asula kood="3183" nimi="Kiviloo küla"/><asula kood="3597" nimi="Kulli küla"/><asula kood="3668" nimi="Kurgla küla"/><asula kood="4758" nimi="Mallavere küla"/><asula kood="6098" nimi="Peningi küla"/><asula kood="6122" nimi="Perila küla"/><asula kood="6228" nimi="Pikavere küla"/><asula kood="6694" nimi="Raasiku alevik"/><asula kood="7226" nimi="Rätla küla"/><asula kood="8477" nimi="Tõhelgi küla"/></vald><vald kood="0653"><asula kood="1050" nimi="Aaviku küla"/><asula kood="1391" nimi="Aruvalla küla"/><asula kood="1408" nimi="Assaku alevik"/><asula kood="2353" nimi="Järveküla"/><asula kood="2377" nimi="Jüri alevik"/><asula kood="2474" nimi="Kadaka küla"/><asula kood="2763" nimi="Karla küla"/><asula kood="2885" nimi="Kautjala küla"/><asula kood="3435" nimi="Kopli küla"/><asula kood="3687" nimi="Kurna küla"/><asula kood="4043" nimi="Lagedi alevik"/><asula kood="4208" nimi="Lehmja küla"/><asula kood="4378" nimi="Limu küla"/><asula kood="5891" nimi="Pajupea küla"/><asula kood="6036" nimi="Patika küla"/><asula kood="6086" nimi="Peetri alevik"/><asula kood="6240" nimi="Pildiküla"/><asula kood="6713" nimi="Rae küla"/><asula kood="7392" nimi="Salu küla"/><asula kood="7517" nimi="Seli küla"/><asula kood="7688" nimi="Soodevahe küla"/><asula kood="7852" nimi="Suuresta küla"/><asula kood="7868" nimi="Suursoo küla"/><asula kood="8454" nimi="Tuulevälja küla"/><asula kood="8731" nimi="Urvaste küla"/><asula kood="8774" nimi="Uuesalu küla"/><asula kood="8867" nimi="Vaida alevik"/><asula kood="8869" nimi="Vaidasoo küla"/><asula kood="9108" nimi="Vaskjala küla"/><asula kood="9202" nimi="Veneküla"/><asula kood="9236" nimi="Veskitaguse küla"/><asula kood="9832" nimi="Ülejõe küla"/></vald><vald kood="0718"><asula kood="2220" nimi="Juuliku küla"/><asula kood="2307" nimi="Jälgimäe küla"/><asula kood="2552" nimi="Kajamaa küla"/><asula kood="2794" nimi="Kasemetsa küla"/><asula kood="3048" nimi="Kiisa alevik"/><asula kood="3119" nimi="Kirdalu küla"/><asula kood="3697" nimi="Kurtna küla"/><asula kood="4481" nimi="Lokuti küla"/><asula kood="4912" nimi="Metsanurme küla"/><asula kood="5261" nimi="Männiku küla"/><asula kood="6739" nimi="Rahula küla"/><asula kood="7056" nimi="Roobuka küla"/><asula kood="7361" nimi="Saku alevik"/><asula kood="2652" nimi="Saue küla"/><asula kood="7469" nimi="Saustinõmme küla"/><asula kood="7704" nimi="Sookaera-Metsanurga küla"/><asula kood="8033" nimi="Tagadi küla"/><asula kood="8096" nimi="Tammejärve küla"/><asula kood="8098" nimi="Tammemäe küla"/><asula kood="8472" nimi="Tõdva küla"/><asula kood="8572" nimi="Tänassilma küla"/><asula kood="9820" nimi="Üksnurme küla"/></vald><vald kood="0727"><asula kood="1141" nimi="Aila küla"/><asula kood="1216" nimi="Alliku küla"/><asula kood="1975" nimi="Hüüru küla"/><asula kood="2267" nimi="Jõgisoo küla"/><asula kood="3025" nimi="Kiia küla"/><asula kood="3285" nimi="Koidu küla"/><asula kood="3439" nimi="Koppelmaa küla"/><asula kood="4014" nimi="Laagri alevik"/><asula kood="4739" nimi="Maidla küla"/><asula kood="6588" nimi="Pällu küla"/><asula kood="6603" nimi="Pärinurme küla"/><asula kood="6652" nimi="Püha küla"/><asula kood="8045" nimi="Tagametsa küla"/><asula kood="8450" nimi="Tuula küla"/><asula kood="8946" nimi="Valingu küla"/><asula kood="9033" nimi="Vanamõisa küla"/><asula kood="9146" nimi="Vatsla küla"/><asula kood="9794" nimi="Ääsmäe küla"/></vald><vald kood="0868"><asula kood="4263" nimi="Lemmaru küla"/><asula kood="7121" nimi="Rummu alevik"/><asula kood="9101" nimi="Vasalemma alevik"/><asula kood="9231" nimi="Veskiküla"/><asula kood="9752" nimi="Ämari alevik"/></vald><vald kood="0890"><asula kood="1675" nimi="Haabneeme alevik"/><asula kood="1984" nimi="Idaotsa küla"/><asula kood="2944" nimi="Kelnase küla"/><asula kood="2945" nimi="Kelvingi küla"/><asula kood="4064" nimi="Laiaküla"/><asula kood="4299" nimi="Leppneeme küla"/><asula kood="4534" nimi="Lubja küla"/><asula kood="4618" nimi="Lõunaküla küla"/><asula kood="4656" nimi="Lääneotsa küla"/><asula kood="4887" nimi="Metsakasti küla"/><asula kood="4943" nimi="Miiduranna küla"/><asula kood="5104" nimi="Muuga küla"/><asula kood="6370" nimi="Pringi küla"/><asula kood="6613" nimi="Pärnamäe küla"/><asula kood="6672" nimi="Püünsi küla"/><asula kood="6797" nimi="Randvere küla"/><asula kood="7039" nimi="Rohuneeme küla"/><asula kood="8039" nimi="Tagaküla"/><asula kood="8126" nimi="Tammneeme küla"/><asula kood="9280" nimi="Viimsi alevik"/><asula kood="9619" nimi="Väikeheinamaa küla"/><asula kood="9744" nimi="Äigrumäe küla"/></vald></maakond><maakond kood="0039"><vald kood="0175"><asula kood="1589" nimi="Emmaste küla"/><asula kood="1734" nimi="Haldi küla"/><asula kood="1732" nimi="Haldreka küla"/><asula kood="1769" nimi="Harju küla"/><asula kood="1851" nimi="Hindu küla"/><asula kood="1952" nimi="Härma küla"/><asula kood="2180" nimi="Jausa küla"/><asula kood="2467" nimi="Kabuna küla"/><asula kood="2481" nimi="Kaderna küla"/><asula kood="3160" nimi="Kitsa küla"/><asula kood="3678" nimi="Kurisu küla"/><asula kood="3717" nimi="Kuusiku küla"/><asula kood="3760" nimi="Kõmmusselja küla"/><asula kood="3976" nimi="Külaküla"/><asula kood="3978" nimi="Külama küla"/><asula kood="4025" nimi="Laartsa küla"/><asula kood="4128" nimi="Lassi küla"/><asula kood="4245" nimi="Leisu küla"/><asula kood="4290" nimi="Lepiku küla"/><asula kood="4898" nimi="Metsalauka küla"/><asula kood="4910" nimi="Metsapere küla"/><asula kood="4993" nimi="Muda küla"/><asula kood="5272" nimi="Mänspe küla"/><asula kood="5479" nimi="Nurste küla"/><asula kood="5654" nimi="Ole küla"/><asula kood="6357" nimi="Prassi küla"/><asula kood="6372" nimi="Prähnu küla"/><asula kood="6609" nimi="Pärna küla"/><asula kood="6801" nimi="Rannaküla"/><asula kood="6903" nimi="Reheselja küla"/><asula kood="6972" nimi="Riidaküla"/><asula kood="7527" nimi="Selja küla"/><asula kood="7548" nimi="Sepaste küla"/><asula kood="7616" nimi="Sinima küla"/><asula kood="7900" nimi="Sõru küla"/><asula kood="8236" nimi="Tilga küla"/><asula kood="8271" nimi="Tohvri küla"/><asula kood="8576" nimi="Tärkma küla"/><asula kood="8656" nimi="Ulja küla"/><asula kood="8938" nimi="Valgu küla"/><asula kood="9019" nimi="Vanamõisa küla"/><asula kood="9295" nimi="Viiri küla"/><asula kood="9703" nimi="Õngu küla"/></vald><vald kood="0204"><asula kood="1788" nimi="Heigi küla"/><asula kood="1801" nimi="Heiste küla"/><asula kood="1800" nimi="Heistesoo küla"/><asula kood="1873" nimi="Hirmuste küla"/><asula kood="1971" nimi="Hüti küla"/><asula kood="2109" nimi="Isabella küla"/><asula kood="2247" nimi="Jõeranna küla"/><asula kood="2250" nimi="Jõesuu küla"/><asula kood="2561" nimi="Kalana küla"/><asula kood="2577" nimi="Kaleste küla"/><asula kood="2650" nimi="Kanapeeksi küla"/><asula kood="2881" nimi="Kauste küla"/><asula kood="3004" nimi="Kidaste küla"/><asula kood="3009" nimi="Kiduspe küla"/><asula kood="3054" nimi="Kiivera küla"/><asula kood="3235" nimi="Kodeste küla"/><asula kood="3271" nimi="Koidma küla"/><asula kood="3433" nimi="Kopa küla"/><asula kood="3679" nimi="Kurisu küla"/><asula kood="3781" nimi="Kõpu küla"/><asula kood="3795" nimi="Kõrgessaare alevik"/><asula kood="3895" nimi="Kärdla linn"/><asula kood="4023" nimi="Laasi küla"/><asula kood="4141" nimi="Lauka küla"/><asula kood="4209" nimi="Lehtma küla"/><asula kood="4223" nimi="Leigri küla"/><asula kood="4371" nimi="Lilbi küla"/><asula kood="4546" nimi="Luidja küla"/><asula kood="4765" nimi="Malvaste küla"/><asula kood="4766" nimi="Mangu küla"/><asula kood="4780" nimi="Mardihansu küla"/><asula kood="4844" nimi="Meelste küla"/><asula kood="4890" nimi="Metsaküla"/><asula kood="4995" nimi="Mudaste küla"/><asula kood="5224" nimi="Mägipe küla"/><asula kood="5350" nimi="Napi küla"/><asula kood="5507" nimi="Nõmme küla"/><asula kood="5613" nimi="Ogandi küla"/><asula kood="5649" nimi="Ojaküla"/><asula kood="5767" nimi="Otste küla"/><asula kood="5932" nimi="Palli küla"/><asula kood="5978" nimi="Paope küla"/><asula kood="6145" nimi="Pihla küla"/><asula kood="6297" nimi="Poama küla"/><asula kood="6459" nimi="Puski küla"/><asula kood="6908" nimi="Reigi küla"/><asula kood="7009" nimi="Risti küla"/><asula kood="7084" nimi="Rootsi küla"/><asula kood="7554" nimi="Sigala küla"/><asula kood="7848" nimi="Suurepsi küla"/><asula kood="7850" nimi="Suureranna küla"/><asula kood="7972" nimi="Sülluste küla"/><asula kood="8067" nimi="Tahkuna küla"/><asula kood="8122" nimi="Tammistu küla"/><asula kood="8209" nimi="Tiharu küla"/><asula kood="9303" nimi="Viita küla"/><asula kood="9306" nimi="Viitasoo küla"/><asula kood="9327" nimi="Vilima küla"/><asula kood="9349" nimi="Villamaa küla"/><asula kood="9826" nimi="Ülendi küla"/></vald><vald kood="0368"><asula kood="1013" nimi="Aadma küla"/><asula kood="1200" nimi="Allika küla"/><asula kood="1647" nimi="Esiküla"/><asula kood="2227" nimi="Jõeküla"/><asula kood="2428" nimi="Kaasiku küla"/><asula kood="2533" nimi="Kaigutsi küla"/><asula kood="2807" nimi="Kassari küla"/><asula kood="3196" nimi="Kleemu küla"/><asula kood="3253" nimi="Kogri küla"/><asula kood="3337" nimi="Kolga küla"/><asula kood="3680" nimi="Kuriste küla"/><asula kood="3869" nimi="Käina alevik"/><asula kood="4056" nimi="Laheküla"/><asula kood="4253" nimi="Lelu küla"/><asula kood="4319" nimi="Ligema küla"/><asula kood="4537" nimi="Luguse küla"/><asula kood="4966" nimi="Moka küla"/><asula kood="5183" nimi="Mäeküla"/><asula kood="5203" nimi="Mäeltse küla"/><asula kood="5258" nimi="Männamaa küla"/><asula kood="5360" nimi="Nasva küla"/><asula kood="5412" nimi="Niidiküla"/><asula kood="5512" nimi="Nõmme küla"/><asula kood="5514" nimi="Nõmmerga küla"/><asula kood="5728" nimi="Orjaku küla"/><asula kood="6460" nimi="Putkaste küla"/><asula kood="6615" nimi="Pärnselja küla"/><asula kood="7014" nimi="Ristivälja küla"/><asula kood="7528" nimi="Selja küla"/><asula kood="8061" nimi="Taguküla"/><asula kood="8162" nimi="Taterma küla"/><asula kood="8747" nimi="Utu küla"/><asula kood="8827" nimi="Vaemla küla"/><asula kood="8911" nimi="Villemi küla"/><asula kood="9816" nimi="Ühtri küla"/></vald><vald kood="0639"><asula kood="1157" nimi="Ala küla"/><asula kood="1374" nimi="Aruküla"/><asula kood="1713" nimi="Hagaste küla"/><asula kood="1767" nimi="Harju küla"/><asula kood="1787" nimi="Hausma küla"/><asula kood="1807" nimi="Hellamaa küla"/><asula kood="1818" nimi="Heltermaa küla"/><asula kood="1835" nimi="Hiiessaare küla"/><asula kood="1841" nimi="Hilleste küla"/><asula kood="2578" nimi="Kalgi küla"/><asula kood="2959" nimi="Kerema küla"/><asula kood="3557" nimi="Kukka küla"/><asula kood="3671" nimi="Kuri küla"/><asula kood="3759" nimi="Kõlunõmme küla"/><asula kood="4184" nimi="Leerimetsa küla"/><asula kood="4402" nimi="Linnumäe küla"/><asula kood="4465" nimi="Loja küla"/><asula kood="4590" nimi="Lõbembe küla"/><asula kood="4612" nimi="Lõpe küla"/><asula kood="5298" nimi="Määvli küla"/><asula kood="5503" nimi="Nõmba küla"/><asula kood="5515" nimi="Nõmme küla"/><asula kood="5908" nimi="Palade küla"/><asula kood="5946" nimi="Paluküla"/><asula kood="6024" nimi="Partsi küla"/><asula kood="6258" nimi="Pilpaküla"/><asula kood="6373" nimi="Prählamäe küla"/><asula kood="6419" nimi="Puliste küla"/><asula kood="6661" nimi="Pühalepa küla"/><asula kood="6910" nimi="Reikama küla"/><asula kood="7349" nimi="Sakla küla"/><asula kood="7382" nimi="Salinõmme küla"/><asula kood="7438" nimi="Sarve küla"/><asula kood="7728" nimi="Soonlepa küla"/><asula kood="7846" nimi="Suuremõisa küla"/><asula kood="7864" nimi="Suuresadama küla"/><asula kood="7949" nimi="Sääre küla"/><asula kood="8095" nimi="Tammela küla"/><asula kood="8150" nimi="Tareste küla"/><asula kood="8190" nimi="Tempa küla"/><asula kood="8382" nimi="Tubala küla"/><asula kood="8682" nimi="Undama küla"/><asula kood="8853" nimi="Vahtrepa küla"/><asula kood="8949" nimi="Valipe küla"/><asula kood="9278" nimi="Viilupi küla"/><asula kood="9338" nimi="Vilivalla küla"/><asula kood="9674" nimi="Värssu küla"/></vald></maakond><maakond kood="0044"><vald kood="0322"><asula kood="0120" nimi="Ahtme linnaosa"/><asula kood="0265" nimi="Järve linnaosa"/><asula kood="0340" nimi="Kukruse linnaosa"/><asula kood="0553" nimi="Oru linnaosa"/><asula kood="0747" nimi="Sompa linnaosa"/><asula kood="0893" nimi="Viivikonna linnaosa"/></vald><vald kood="0122"><asula kood="1165" nimi="Alajõe küla"/><asula kood="2752" nimi="Karjamaa küla"/><asula kood="2850" nimi="Katase küla"/><asula kood="6927" nimi="Remniku küla"/><asula kood="7649" nimi="Smolnitsa küla"/><asula kood="8786" nimi="Uusküla"/><asula kood="9111" nimi="Vasknarva küla"/></vald><vald kood="0154"><asula kood="1402" nimi="Aseri alevik"/><asula kood="1405" nimi="Aseriaru küla"/><asula kood="2626" nimi="Kalvi küla"/><asula kood="2986" nimi="Kestla küla"/><asula kood="3394" nimi="Koogu küla"/><asula kood="3803" nimi="Kõrkküla"/><asula kood="3814" nimi="Kõrtsialuse küla"/><asula kood="5739" nimi="Oru küla"/><asula kood="6821" nimi="Rannu küla"/></vald><vald kood="0164"><asula kood="1087" nimi="Adraku küla"/><asula kood="1191" nimi="Alekere küla"/><asula kood="1481" nimi="Avinurme alevik"/><asula kood="2503" nimi="Kaevussaare küla"/><asula kood="3052" nimi="Kiissa küla"/><asula kood="3819" nimi="Kõrve küla"/><asula kood="3826" nimi="Kõrvemetsa küla"/><asula kood="3842" nimi="Kõveriku küla"/><asula kood="4033" nimi="Laekannu küla"/><asula kood="4287" nimi="Lepiksaare küla"/><asula kood="4727" nimi="Maetsma küla"/><asula kood="5774" nimi="Paadenurme küla"/><asula kood="7921" nimi="Sälliksaare küla"/><asula kood="8102" nimi="Tammessaare küla"/><asula kood="8664" nimi="Ulvi küla"/><asula kood="8819" nimi="Vadi küla"/><asula kood="9773" nimi="Änniksaare küla"/></vald><vald kood="0224"><asula kood="1211" nimi="Alliku küla"/><asula kood="2025" nimi="Iisaku alevik"/><asula kood="2071" nimi="Imatu küla"/><asula kood="2281" nimi="Jõuga küla"/><asula kood="2802" nimi="Kasevälja küla"/><asula kood="2868" nimi="Kauksi küla"/><asula kood="3331" nimi="Koldamäe küla"/><asula kood="3700" nimi="Kuru küla"/><asula kood="4418" nimi="Lipniku küla"/><asula kood="4610" nimi="Lõpe küla"/><asula kood="6327" nimi="Pootsiku küla"/><asula kood="7902" nimi="Sõrumäe küla"/><asula kood="7924" nimi="Sälliku küla"/><asula kood="1534" nimi="Taga-Roostoja küla"/><asula kood="8104" nimi="Tammetaguse küla"/><asula kood="8578" nimi="Tärivere küla"/><asula kood="8874" nimi="Vaikla küla"/><asula kood="9075" nimi="Varesmetsa küla"/></vald><vald kood="0229"><asula kood="1103" nimi="Agusalu küla"/><asula kood="1526" nimi="Edivere küla"/><asula kood="2042" nimi="Illuka küla"/><asula kood="2130" nimi="Jaama küla"/><asula kood="2431" nimi="Kaatermu küla"/><asula kood="2528" nimi="Kaidma küla"/><asula kood="2639" nimi="Kamarna küla"/><asula kood="2767" nimi="Karoli küla"/><asula kood="3190" nimi="Kivinõmme küla"/><asula kood="3377" nimi="Konsu küla"/><asula kood="3621" nimi="Kuningaküla"/><asula kood="3644" nimi="Kuremäe küla"/><asula kood="3696" nimi="Kurtna küla"/><asula kood="5615" nimi="Ohakvere küla"/><asula kood="5677" nimi="Ongassaare küla"/><asula kood="6127" nimi="Permisküla"/><asula kood="6391" nimi="Puhatu küla"/><asula kood="6866" nimi="Rausvere küla"/><asula kood="9106" nimi="Vasavere küla"/></vald><vald kood="0251"><asula kood="1524" nimi="Edise küla"/><asula kood="2271" nimi="Jõhvi küla"/><asula kood="2270" nimi="Jõhvi linn"/><asula kood="2520" nimi="Kahula küla"/><asula kood="3461" nimi="Kose küla"/><asula kood="3477" nimi="Kotinuka küla"/><asula kood="4389" nimi="Linna küla"/><asula kood="5884" nimi="Pajualuse küla"/><asula kood="5999" nimi="Pargitaguse küla"/><asula kood="6050" nimi="Pauliku küla"/><asula kood="6455" nimi="Puru küla"/><asula kood="7677" nimi="Sompa küla"/><asula kood="8114" nimi="Tammiku alevik"/></vald><vald kood="0323"><asula kood="3270" nimi="Kohtla-Nõmme alev"/></vald><vald kood="0320"><asula kood="1253" nimi="Amula küla"/><asula kood="2350" nimi="Järve küla"/><asula kood="2420" nimi="Kaasikaia küla"/><asula kood="2429" nimi="Kaasikvälja küla"/><asula kood="2448" nimi="Kabelimetsa küla"/><asula kood="3269" nimi="Kohtla küla"/><asula kood="3562" nimi="Kukruse küla"/><asula kood="5142" nimi="Mõisamaa küla"/><asula kood="5680" nimi="Ontika küla"/><asula kood="5793" nimi="Paate küla"/><asula kood="6081" nimi="Peeri küla"/><asula kood="7063" nimi="Roodu küla"/><asula kood="7348" nimi="Saka küla"/><asula kood="7551" nimi="Servaääre küla"/><asula kood="8563" nimi="Täkumetsa küla"/><asula kood="8914" nimi="Valaste küla"/><asula kood="9432" nimi="Vitsiku küla"/></vald><vald kood="0420"><asula kood="2236" nimi="Jõemetsa küla"/><asula kood="2616" nimi="Kalmaküla"/><asula kood="3884" nimi="Kärasi küla"/><asula kood="4459" nimi="Lohusuu alevik"/><asula kood="5430" nimi="Ninasi küla"/><asula kood="6174" nimi="Piilsi küla"/><asula kood="6682" nimi="Raadna küla"/><asula kood="7544" nimi="Separa küla"/><asula kood="8117" nimi="Tammispää küla"/><asula kood="9364" nimi="Vilusi küla"/></vald><vald kood="0438"><asula kood="1004" nimi="Aa küla"/><asula kood="1132" nimi="Aidu küla"/><asula kood="1139" nimi="Aidu-Liiva küla"/><asula kood="1133" nimi="Aidu-Nõmme küla"/><asula kood="1140" nimi="Aidu-Sooküla"/><asula kood="1368" nimi="Aruküla"/><asula kood="1382" nimi="Arupäälse küla"/><asula kood="1393" nimi="Aruvälja küla"/><asula kood="1871" nimi="Hirmuse küla"/><asula kood="2105" nimi="Irvala küla"/><asula kood="2150" nimi="Jabara küla"/><asula kood="3404" nimi="Koolma küla"/><asula kood="3436" nimi="Kopli küla"/><asula kood="3576" nimi="Kulja küla"/><asula kood="4347" nimi="Liimala küla"/><asula kood="4419" nimi="Lipu küla"/><asula kood="4449" nimi="Lohkuse küla"/><asula kood="4669" nimi="Lüganuse alevik"/><asula kood="4688" nimi="Lümatu küla"/><asula kood="4740" nimi="Maidla küla"/><asula kood="4819" nimi="Matka küla"/><asula kood="4857" nimi="Mehide küla"/><asula kood="4975" nimi="Moldova küla"/><asula kood="5088" nimi="Mustmätta küla"/><asula kood="5574" nimi="Oandu küla"/><asula kood="5652" nimi="Ojamaa küla"/><asula kood="6172" nimi="Piilse küla"/><asula kood="6450" nimi="Purtse küla"/><asula kood="6671" nimi="Püssi linn"/><asula kood="6894" nimi="Rebu küla"/><asula kood="7245" nimi="Rääsa küla"/><asula kood="7371" nimi="Salaküla"/><asula kood="7477" nimi="Savala küla"/><asula kood="7640" nimi="Sirtsi küla"/><asula kood="7735" nimi="Soonurme küla"/><asula kood="8154" nimi="Tarumaa küla"/><asula kood="8691" nimi="Uniküla"/><asula kood="9088" nimi="Varja küla"/><asula kood="9200" nimi="Veneoja küla"/><asula kood="9406" nimi="Virunurme küla"/><asula kood="9475" nimi="Voorepera küla"/></vald><vald kood="0498"><asula kood="1310" nimi="Apandiku küla"/><asula kood="1377" nimi="Aruküla"/><asula kood="1398" nimi="Arvila küla"/><asula kood="1443" nimi="Atsalama küla"/><asula kood="1623" nimi="Ereda küla"/><asula kood="2249" nimi="Jõetaguse küla"/><asula kood="2586" nimi="Kalina küla"/><asula kood="3035" nimi="Kiikla küla"/><asula kood="4374" nimi="Liivakünka küla"/><asula kood="4923" nimi="Metsküla"/><asula kood="5213" nimi="Mäetaguse alevik"/><asula kood="5217" nimi="Mäetaguse küla"/><asula kood="5841" nimi="Pagari küla"/><asula kood="6767" nimi="Rajaküla"/><asula kood="6844" nimi="Ratva küla"/><asula kood="8147" nimi="Tarakuse küla"/><asula kood="8624" nimi="Uhe küla"/><asula kood="9494" nimi="Võhma küla"/><asula kood="9516" nimi="Võide küla"/><asula kood="9580" nimi="Võrnu küla"/><asula kood="9631" nimi="Väike-Pungerja küla"/></vald><vald kood="0751"><asula kood="1631" nimi="Erra alevik"/><asula kood="1629" nimi="Erra-Liiva küla"/><asula kood="2051" nimi="Ilmaste küla"/><asula kood="3348" nimi="Koljala küla"/><asula kood="5569" nimi="Nüri küla"/><asula kood="7447" nimi="Satsu küla"/><asula kood="7680" nimi="Sonda alevik"/><asula kood="8660" nimi="Uljaste küla"/><asula kood="8884" nimi="Vainu küla"/><asula kood="9005" nimi="Vana-Sonda küla"/><asula kood="9086" nimi="Varinurme küla"/></vald><vald kood="0802"><asula kood="1212" nimi="Altküla"/><asula kood="3375" nimi="Konju küla"/><asula kood="4799" nimi="Martsa küla"/><asula kood="4896" nimi="Metsamägara küla"/><asula kood="6582" nimi="Päite küla"/><asula kood="6656" nimi="Pühajõe küla"/><asula kood="8275" nimi="Toila alevik"/><asula kood="8647" nimi="Uikala küla"/><asula kood="8900" nimi="Vaivina küla"/><asula kood="9455" nimi="Voka alevik"/><asula kood="9453" nimi="Voka küla"/></vald><vald kood="0815"><asula kood="2939" nimi="Kellassaare küla"/><asula kood="4258" nimi="Lemmaku küla"/><asula kood="5695" nimi="Oonurme küla"/><asula kood="6117" nimi="Peressaare küla"/><asula kood="6224" nimi="Pikati küla"/><asula kood="6816" nimi="Rannapungerja küla"/><asula kood="7086" nimi="Roostoja küla"/><asula kood="7337" nimi="Sahargu küla"/><asula kood="8035" nimi="Tagajõe küla"/><asula kood="8393" nimi="Tudulinna alevik"/></vald><vald kood="0851"><asula kood="1381" nimi="Arumäe küla"/><asula kood="1472" nimi="Auvere küla"/><asula kood="1833" nimi="Hiiemetsa küla"/><asula kood="1908" nimi="Hundinurga küla"/><asula kood="3520" nimi="Kudruküla"/><asula kood="4012" nimi="Laagna küla"/><asula kood="4884" nimi="Meriküla"/><asula kood="5067" nimi="Mustanina küla"/><asula kood="5663" nimi="Olgina alevik"/><asula kood="6084" nimi="Peeterristi küla"/><asula kood="6125" nimi="Perjatsi küla"/><asula kood="6265" nimi="Pimestiku küla"/><asula kood="6396" nimi="Puhkova küla"/><asula kood="7619" nimi="Sinimäe alevik"/><asula kood="7674" nimi="Soldina küla"/><asula kood="7908" nimi="Sõtke küla"/><asula kood="8530" nimi="Tõrvajõe küla"/><asula kood="8619" nimi="Udria küla"/><asula kood="8895" nimi="Vaivara küla"/><asula kood="9444" nimi="Vodava küla"/></vald></maakond><maakond kood="0049"><vald kood="0248"><asula kood="1185" nimi="Alavere küla"/><asula kood="1582" nimi="Ellakvere küla"/><asula kood="1598" nimi="Endla küla"/><asula kood="2261" nimi="Jõgeva alevik"/><asula kood="2495" nimi="Kaera küla"/><asula kood="2818" nimi="Kassinurme küla"/><asula kood="2861" nimi="Kaude küla"/><asula kood="3178" nimi="Kivijärve küla"/><asula kood="3642" nimi="Kuremaa alevik"/><asula kood="3676" nimi="Kurista küla"/><asula kood="3778" nimi="Kõola küla"/><asula kood="3894" nimi="Kärde küla"/><asula kood="4078" nimi="Laiuse alevik"/><asula kood="4080" nimi="Laiusevälja küla"/><asula kood="4278" nimi="Lemuvere küla"/><asula kood="4364" nimi="Liivoja küla"/><asula kood="4613" nimi="Lõpe küla"/><asula kood="4983" nimi="Mooritsa küla"/><asula kood="5131" nimi="Mõisamaa küla"/><asula kood="5817" nimi="Paduvere küla"/><asula kood="5870" nimi="Painküla"/><asula kood="5902" nimi="Pakaste küla"/><asula kood="5954" nimi="Palupere küla"/><asula kood="6040" nimi="Patjala küla"/><asula kood="6073" nimi="Pedja küla"/><asula kood="6684" nimi="Raaduvere küla"/><asula kood="7031" nimi="Rohe küla"/><asula kood="7539" nimi="Selli küla"/><asula kood="7573" nimi="Siimusti alevik"/><asula kood="7719" nimi="Soomevere küla"/><asula kood="8188" nimi="Teilma küla"/><asula kood="8295" nimi="Tooma küla"/><asula kood="8879" nimi="Vaimastvere küla"/><asula kood="8979" nimi="Vana-Jõgeva küla"/><asula kood="9333" nimi="Vilina küla"/><asula kood="9409" nimi="Viruvere küla"/><asula kood="9489" nimi="Võduvere küla"/><asula kood="9529" nimi="Võikvere küla"/><asula kood="9615" nimi="Vägeva küla"/><asula kood="9655" nimi="Väljaotsa küla"/><asula kood="9721" nimi="Õuna küla"/></vald><vald kood="0657"><asula kood="2430" nimi="Kaasiku küla"/><asula kood="2800" nimi="Kasepää küla"/><asula kood="3968" nimi="Kükita küla"/><asula kood="5052" nimi="Metsaküla"/><asula kood="5532" nimi="Nõmme küla"/><asula kood="5673" nimi="Omedu küla"/><asula kood="6764" nimi="Raja küla"/><asula kood="8210" nimi="Tiheda küla"/></vald><vald kood="0573"><asula kood="1137" nimi="Aidu küla"/><asula kood="1351" nimi="Arisvere küla"/><asula kood="2436" nimi="Kaave küla"/><asula kood="2562" nimi="Kalana küla"/><asula kood="2875" nimi="Kauru küla"/><asula kood="3458" nimi="Kose küla"/><asula kood="3779" nimi="Kõpu küla"/><asula kood="3801" nimi="Kõrkküla"/><asula kood="4049" nimi="Lahavere küla"/><asula kood="4513" nimi="Loopre küla"/><asula kood="4551" nimi="Luige küla"/><asula kood="5136" nimi="Mõisaküla"/><asula kood="5166" nimi="Mõrtsi küla"/><asula kood="5462" nimi="Nurga küla"/><asula kood="5894" nimi="Pajusi küla"/><asula kood="6280" nimi="Pisisaare küla"/><asula kood="7753" nimi="Sopimetsa küla"/><asula kood="8141" nimi="Tapiku küla"/><asula kood="8483" nimi="Tõivere küla"/><asula kood="8772" nimi="Uuevälja küla"/><asula kood="9486" nimi="Vorsti küla"/><asula kood="9612" nimi="Vägari küla"/><asula kood="9654" nimi="Väljataguse küla"/></vald><vald kood="0578"><asula kood="1533" nimi="Eerikvere küla"/><asula kood="1543" nimi="Ehavere küla"/><asula kood="2079" nimi="Imukvere küla"/><asula kood="2360" nimi="Järvepera küla"/><asula kood="2403" nimi="Kaarepere küla"/><asula kood="2523" nimi="Kaiavere küla"/><asula kood="2819" nimi="Kassivere küla"/><asula kood="3188" nimi="Kivimäe küla"/><asula kood="3518" nimi="Kudina küla"/><asula kood="4579" nimi="Luua küla"/><asula kood="5023" nimi="Mullavere küla"/><asula kood="5373" nimi="Nava küla"/><asula kood="5913" nimi="Palamuse alevik"/><asula kood="6233" nimi="Pikkjärve küla"/><asula kood="6344" nimi="Praaklima küla"/><asula kood="6679" nimi="Raadivere küla"/><asula kood="6727" nimi="Rahivere küla"/><asula kood="7048" nimi="Ronivere küla"/><asula kood="7762" nimi="Sudiste küla"/><asula kood="7983" nimi="Süvalepa küla"/><asula kood="8318" nimi="Toovere küla"/><asula kood="8872" nimi="Vaidavere küla"/><asula kood="9037" nimi="Vanavälja küla"/><asula kood="9058" nimi="Varbevere küla"/><asula kood="9431" nimi="Visusti küla"/><asula kood="9770" nimi="Änkküla"/></vald><vald kood="0576"><asula kood="1413" nimi="Assikvere küla"/><asula kood="1702" nimi="Haavakivi küla"/><asula kood="2489" nimi="Kadrina küla"/><asula kood="3151" nimi="Kirtsi küla"/><asula kood="3234" nimi="Kodavere küla"/><asula kood="3310" nimi="Kokanurga küla"/><asula kood="4685" nimi="Lümati küla"/><asula kood="4904" nimi="Metsanurga küla"/><asula kood="4972" nimi="Moku küla"/><asula kood="5544" nimi="Nõva küla"/><asula kood="5905" nimi="Pala küla"/><asula kood="6111" nimi="Perametsa küla"/><asula kood="6161" nimi="Piibumäe küla"/><asula kood="6189" nimi="Piirivarbe küla"/><asula kood="6432" nimi="Punikvere küla"/><asula kood="6699" nimi="Raatvere küla"/><asula kood="6803" nimi="Ranna küla"/><asula kood="7444" nimi="Sassukvere küla"/><asula kood="7913" nimi="Sõõru küla"/><asula kood="7953" nimi="Sääritsa küla"/><asula kood="8066" nimi="Tagumaa küla"/><asula kood="9150" nimi="Vea küla"/><asula kood="9787" nimi="Äteniidi küla"/></vald><vald kood="0611"><asula kood="1226" nimi="Altnurga küla"/><asula kood="1950" nimi="Härjanurme küla"/><asula kood="2284" nimi="Jõune küla"/><asula kood="2379" nimi="Jüriküla"/><asula kood="3132" nimi="Kirikuvalla küla"/><asula kood="3693" nimi="Kursi küla"/><asula kood="4026" nimi="Laasme küla"/><asula kood="6236" nimi="Pikknurme küla"/><asula kood="6479" nimi="Puurmani alevik"/><asula kood="6643" nimi="Pööra küla"/><asula kood="7323" nimi="Saduküla"/><asula kood="8113" nimi="Tammiku küla"/><asula kood="8537" nimi="Tõrve küla"/></vald><vald kood="0616"><asula kood="1076" nimi="Adavere alevik"/><asula kood="1179" nimi="Alastvere küla"/><asula kood="1293" nimi="Annikvere küla"/><asula kood="1652" nimi="Esku küla"/><asula kood="2438" nimi="Kaavere küla"/><asula kood="2461" nimi="Kablaküla"/><asula kood="2582" nimi="Kaliküla"/><asula kood="2621" nimi="Kalme küla"/><asula kood="2636" nimi="Kamari alevik"/><asula kood="3624" nimi="Kuningamäe küla"/><asula kood="4170" nimi="Lebavere küla"/><asula kood="4567" nimi="Lustivere küla"/><asula kood="5123" nimi="Mõhküla"/><asula kood="5253" nimi="Mällikvere küla"/><asula kood="5382" nimi="Neanurme küla"/><asula kood="5501" nimi="Nõmavere küla"/><asula kood="6048" nimi="Pauastvere küla"/><asula kood="6262" nimi="Pilu küla"/><asula kood="6381" nimi="Pudivere küla"/><asula kood="6385" nimi="Puduküla"/><asula kood="6404" nimi="Puiatu küla"/><asula kood="7175" nimi="Rõstla küla"/><asula kood="7220" nimi="Räsna küla"/><asula kood="7798" nimi="Sulustvere küla"/><asula kood="8515" nimi="Tõrenurme küla"/><asula kood="8674" nimi="Umbusi küla"/><asula kood="9437" nimi="Vitsjärve küla"/><asula kood="9501" nimi="Võhmanõmme küla"/><asula kood="9536" nimi="Võisiku küla"/><asula kood="9621" nimi="Väike-Kamari küla"/></vald><vald kood="0713"><asula kood="1746" nimi="Halliku küla"/><asula kood="2129" nimi="Jaama küla"/><asula kood="2611" nimi="Kallivere küla"/><asula kood="3051" nimi="Kiisli küla"/><asula kood="3467" nimi="Koseveski küla"/><asula kood="7285" nimi="Kääpa küla"/><asula kood="4308" nimi="Levala küla"/><asula kood="4702" nimi="Maardla küla"/><asula kood="5367" nimi="Nautrasi küla"/><asula kood="5598" nimi="Odivere küla"/><asula kood="6067" nimi="Pedassaare küla"/><asula kood="6469" nimi="Putu küla"/><asula kood="6589" nimi="Pällu küla"/><asula kood="7130" nimi="Ruskavere küla"/><asula kood="7303" nimi="Saarjärve küla"/><asula kood="7637" nimi="Sirguvere küla"/><asula kood="8149" nimi="Tarakvere küla"/><asula kood="8453" nimi="Tuulavere küla"/><asula kood="9029" nimi="Vanassaare küla"/><asula kood="9116" nimi="Vassevere küla"/><asula kood="9181" nimi="Veia küla"/><asula kood="9466" nimi="Voore küla"/></vald><vald kood="0773"><asula kood="1579" nimi="Elistvere küla"/><asula kood="2218" nimi="Juula küla"/><asula kood="2525" nimi="Kaiavere küla"/><asula kood="2550" nimi="Kaitsemõisa küla"/><asula kood="2809" nimi="Kassema küla"/><asula kood="3386" nimi="Koogi küla"/><asula kood="3737" nimi="Kõduküla"/><asula kood="3777" nimi="Kõnnujõe küla"/><asula kood="3788" nimi="Kõrenduse küla"/><asula kood="3913" nimi="Kärksi küla"/><asula kood="4375" nimi="Lilu küla"/><asula kood="4709" nimi="Maarja-Magdaleena küla"/><asula kood="5769" nimi="Otslava küla"/><asula kood="6034" nimi="Pataste küla"/><asula kood="6751" nimi="Raigastvere küla"/><asula kood="6918" nimi="Reinu küla"/><asula kood="7542" nimi="Sepa küla"/><asula kood="7756" nimi="Sortsi küla"/><asula kood="8016" nimi="Tabivere alevik"/><asula kood="8334" nimi="Tormi küla"/><asula kood="8629" nimi="Uhmardu küla"/><asula kood="8849" nimi="Vahi küla"/><asula kood="8934" nimi="Valgma küla"/><asula kood="9461" nimi="Voldi küla"/><asula kood="9725" nimi="Õvanurme küla"/></vald><vald kood="0810"><asula kood="2099" nimi="Iravere küla"/><asula kood="2688" nimi="Kantküla"/><asula kood="3244" nimi="Kodismaa küla"/><asula kood="3302" nimi="Koimula küla"/><asula kood="3769" nimi="Kõnnu küla"/><asula kood="4175" nimi="Leedi küla"/><asula kood="4342" nimi="Liikatku küla"/><asula kood="4367" nimi="Lilastvere küla"/><asula kood="5548" nimi="Näduvere küla"/><asula kood="5684" nimi="Ookatku küla"/><asula kood="5756" nimi="Oti küla"/><asula kood="6834" nimi="Rassiku küla"/><asula kood="6879" nimi="Reastvere küla"/><asula kood="7232" nimi="Rääbise küla"/><asula kood="7318" nimi="Sadala alevik"/><asula kood="7943" nimi="Sätsuvere küla"/><asula kood="8174" nimi="Tealama küla"/><asula kood="8331" nimi="Torma alevik"/><asula kood="8404" nimi="Tuimõisa küla"/><asula kood="8480" nimi="Tõikvere küla"/><asula kood="8558" nimi="Tähkvere küla"/><asula kood="8861" nimi="Vaiatu küla"/><asula kood="9021" nimi="Vanamõisa küla"/><asula kood="9519" nimi="Võidivere küla"/><asula kood="9596" nimi="Võtikvere küla"/></vald></maakond><maakond kood="0051"><vald kood="0129"><asula kood="1100" nimi="Ageri küla"/><asula kood="1122" nimi="Ahula küla"/><asula kood="1188" nimi="Albu küla"/><asula kood="2343" nimi="Järva-Madise küla"/><asula kood="2395" nimi="Kaalepi küla"/><asula kood="4214" nimi="Lehtmetsa küla"/><asula kood="5156" nimi="Mõnuvere küla"/><asula kood="5215" nimi="Mägede küla"/><asula kood="5402" nimi="Neitla küla"/><asula kood="5714" nimi="Orgmetsa küla"/><asula kood="6079" nimi="Peedu küla"/><asula kood="6422" nimi="Pullevere küla"/><asula kood="7505" nimi="Seidla küla"/><asula kood="7741" nimi="Soosalu küla"/><asula kood="7770" nimi="Sugalepa küla"/><asula kood="9243" nimi="Vetepere küla"/></vald><vald kood="0134"><asula kood="1250" nimi="Ambla alevik"/><asula kood="1326" nimi="Aravete alevik"/><asula kood="2268" nimi="Jõgisoo küla"/><asula kood="3554" nimi="Kukevere küla"/><asula kood="3673" nimi="Kurisoo küla"/><asula kood="3886" nimi="Käravete alevik"/><asula kood="5226" nimi="Mägise küla"/><asula kood="5281" nimi="Märjandi küla"/><asula kood="6771" nimi="Raka küla"/><asula kood="6870" nimi="Rava küla"/><asula kood="6915" nimi="Reinevere küla"/><asula kood="7081" nimi="Roosna küla"/><asula kood="7961" nimi="Sääsküla"/></vald><vald kood="0234"><asula kood="1567" nimi="Eistvere küla"/><asula kood="2073" nimi="Imavere küla"/><asula kood="2159" nimi="Jalametsa küla"/><asula kood="2321" nimi="Järavere küla"/><asula kood="3032" nimi="Kiigevere küla"/><asula kood="3936" nimi="Käsukonna küla"/><asula kood="4070" nimi="Laimetsa küla"/><asula kood="6402" nimi="Puiatu küla"/><asula kood="6583" nimi="Pällastvere küla"/><asula kood="7991" nimi="Taadikvere küla"/><asula kood="8097" nimi="Tammeküla"/><asula kood="9575" nimi="Võrevere küla"/></vald><vald kood="0257"><asula kood="2156" nimi="Jalalõpe küla"/><asula kood="2164" nimi="Jalgsema küla"/><asula kood="2341" nimi="Järva-Jaani alev"/><asula kood="2506" nimi="Kagavere küla"/><asula kood="2733" nimi="Karinu küla"/><asula kood="3564" nimi="Kuksema küla"/><asula kood="4927" nimi="Metsla küla"/><asula kood="4936" nimi="Metstaguse küla"/><asula kood="6780" nimi="Ramma küla"/><asula kood="7521" nimi="Seliküla"/></vald><vald kood="0288"><asula kood="1252" nimi="Ammuta küla"/><asula kood="1441" nimi="Ataste küla"/><asula kood="1655" nimi="Esna küla"/><asula kood="2712" nimi="Kareda küla"/><asula kood="3960" nimi="Köisi küla"/><asula kood="3992" nimi="Küti küla"/><asula kood="5322" nimi="Müüsleri küla"/><asula kood="6085" nimi="Peetri alevik"/><asula kood="9446" nimi="Vodja küla"/><asula kood="9696" nimi="Õle küla"/><asula kood="9755" nimi="Ämbra küla"/><asula kood="9807" nimi="Öötla küla"/></vald><vald kood="0314"><asula kood="1055" nimi="Abaja küla"/><asula kood="1371" nimi="Aruküla"/><asula kood="1640" nimi="Ervita küla"/><asula kood="2230" nimi="Jõeküla"/><asula kood="2591" nimi="Kalitsa küla"/><asula kood="2702" nimi="Kapu küla"/><asula kood="3255" nimi="Koeru alevik"/><asula kood="3273" nimi="Koidu-Ellavere küla"/><asula kood="3723" nimi="Kuusna küla"/><asula kood="4022" nimi="Laaneotsa küla"/><asula kood="4428" nimi="Liusvere küla"/><asula kood="4882" nimi="Merja küla"/><asula kood="5455" nimi="Norra küla"/><asula kood="6360" nimi="Preedi küla"/><asula kood="6398" nimi="Puhmu küla"/><asula kood="7157" nimi="Rõhu küla"/><asula kood="7399" nimi="Salutaguse küla"/><asula kood="7408" nimi="Santovi küla"/><asula kood="8110" nimi="Tammiku küla"/><asula kood="8388" nimi="Tudre küla"/><asula kood="8616" nimi="Udeva küla"/><asula kood="8858" nimi="Vahuküla"/><asula kood="8944" nimi="Valila küla"/><asula kood="9047" nimi="Vao küla"/><asula kood="9430" nimi="Visusti küla"/><asula kood="9492" nimi="Vuti küla"/><asula kood="9638" nimi="Väinjärve küla"/></vald><vald kood="0325"><asula kood="1920" nimi="Huuksi küla"/><asula kood="2339" nimi="Kahala küla"/><asula kood="2971" nimi="Keri küla"/><asula kood="3282" nimi="Koigi küla"/><asula kood="4626" nimi="Lähevere küla"/><asula kood="6349" nimi="Prandi küla"/><asula kood="6580" nimi="Päinurme küla"/><asula kood="6627" nimi="Pätsavere küla"/><asula kood="7135" nimi="Rutikvere küla"/><asula kood="7598" nimi="Silmsi küla"/><asula kood="7895" nimi="Sõrandu küla"/><asula kood="8137" nimi="Tamsi küla"/><asula kood="8803" nimi="Vaali küla"/><asula kood="9623" nimi="Väike-Kareda küla"/><asula kood="9825" nimi="Ülejõe küla"/></vald><vald kood="0565"><asula kood="1286" nimi="Anna küla"/><asula kood="1570" nimi="Eivere küla"/><asula kood="3131" nimi="Kirila küla"/><asula kood="3442" nimi="Korba küla"/><asula kood="3497" nimi="Kriilevälja küla"/><asula kood="5083" nimi="Mustla küla"/><asula kood="5090" nimi="Mustla-Nõmme küla"/><asula kood="5193" nimi="Mäeküla"/><asula kood="5275" nimi="Mäo küla"/><asula kood="5317" nimi="Mündi küla"/><asula kood="5466" nimi="Nurme küla"/><asula kood="5474" nimi="Nurmsi küla"/><asula kood="5648" nimi="Ojaküla"/><asula kood="5761" nimi="Otiku küla"/><asula kood="6214" nimi="Pikaküla"/><asula kood="6377" nimi="Prääma küla"/><asula kood="6405" nimi="Puiatu küla"/><asula kood="6440" nimi="Purdi küla"/><asula kood="7428" nimi="Sargvere küla"/><asula kood="7508" nimi="Seinapalu küla"/><asula kood="7593" nimi="Sillaotsa küla"/><asula kood="7863" nimi="Suurpalu küla"/><asula kood="7889" nimi="Sõmeru küla"/><asula kood="8152" nimi="Tarbja küla"/><asula kood="8935" nimi="Valgma küla"/><asula kood="9227" nimi="Veskiaru küla"/><asula kood="9379" nimi="Viraksaare küla"/><asula kood="9602" nimi="Võõbu küla"/></vald><vald kood="0684"><asula kood="1205" nimi="Allikjärve küla"/><asula kood="1653" nimi="Esna küla"/><asula kood="2421" nimi="Kaaruka küla"/><asula kood="3019" nimi="Kihme küla"/><asula kood="3137" nimi="Kirisaare küla"/><asula kood="3229" nimi="Kodasema küla"/><asula kood="3417" nimi="Koordi küla"/><asula kood="5609" nimi="Oeti küla"/><asula kood="7083" nimi="Roosna-Alliku alevik"/><asula kood="8570" nimi="Tännapere küla"/><asula kood="8917" nimi="Valasti küla"/><asula kood="9689" nimi="Vedruka küla"/><asula kood="9302" nimi="Viisu küla"/></vald><vald kood="0835"><asula kood="1359" nimi="Arkma küla"/><asula kood="2315" nimi="Jändja küla"/><asula kood="2445" nimi="Kabala küla"/><asula kood="2510" nimi="Kahala küla"/><asula kood="5144" nimi="Karjaküla"/><asula kood="3148" nimi="Kirna küla"/><asula kood="3364" nimi="Kolu küla"/><asula kood="3684" nimi="Kurla küla"/><asula kood="3899" nimi="Kärevere küla"/><asula kood="4153" nimi="Laupa küla"/><asula kood="4475" nimi="Lokuta küla"/><asula kood="4873" nimi="Meossaare küla"/><asula kood="4897" nimi="Metsaküla"/><asula kood="5197" nimi="Mäeküla"/><asula kood="5562" nimi="Näsuvere küla"/><asula kood="5641" nimi="Oisu alevik"/><asula kood="5666" nimi="Ollepa küla"/><asula kood="5906" nimi="Pala küla"/><asula kood="6134" nimi="Pibari küla"/><asula kood="6300" nimi="Poaka küla"/><asula kood="6505" nimi="Põikva küla"/><asula kood="6831" nimi="Rassi küla"/><asula kood="6863" nimi="Raukla küla"/><asula kood="6948" nimi="Retla küla"/><asula kood="6995" nimi="Rikassaare küla"/><asula kood="7293" nimi="Saareotsa küla"/><asula kood="7332" nimi="Sagevere küla"/><asula kood="7935" nimi="Särevere alevik"/><asula kood="8080" nimi="Taikse küla"/><asula kood="8325" nimi="Tori küla"/><asula kood="8573" nimi="Tännassilma küla"/><asula kood="8596" nimi="Türi-Alliku küla"/><asula kood="8595" nimi="Türi linn"/><asula kood="9336" nimi="Vilita küla"/><asula kood="9352" nimi="Villevere küla"/><asula kood="9653" nimi="Väljaotsa küla"/><asula kood="9741" nimi="Äiamaa küla"/><asula kood="9762" nimi="Änari küla"/></vald><vald kood="0937"><asula kood="1042" nimi="Aasuvälja küla"/><asula kood="4623" nimi="Lõõla küla"/><asula kood="6206" nimi="Piiumetsa küla"/><asula kood="6940" nimi="Reopalu küla"/><asula kood="7095" nimi="Roovere küla"/><asula kood="7254" nimi="Röa küla"/><asula kood="7452" nimi="Saueaugu küla"/><asula kood="9425" nimi="Vissuvere küla"/><asula kood="9656" nimi="Väljataguse küla"/><asula kood="9690" nimi="Väätsa alevik"/><asula kood="9828" nimi="Ülejõe küla"/></vald></maakond><maakond kood="0057"><vald kood="0195"><asula kood="1649" nimi="Esivere küla"/><asula kood="1757" nimi="Hanila küla"/><asula kood="2784" nimi="Karuse küla"/><asula kood="2792" nimi="Kaseküla"/><asula kood="2879" nimi="Kause küla"/><asula kood="3099" nimi="Kinksi küla"/><asula kood="3159" nimi="Kiska küla"/><asula kood="3326" nimi="Kokuta küla"/><asula kood="3552" nimi="Kuke küla"/><asula kood="3739" nimi="Kõera küla"/><asula kood="3765" nimi="Kõmsi küla"/><asula kood="4406" nimi="Linnuse küla"/><asula kood="4607" nimi="Lõo küla"/><asula kood="4807" nimi="Massu küla"/><asula kood="5127" nimi="Mõisaküla"/><asula kood="5202" nimi="Mäense küla"/><asula kood="5399" nimi="Nehatu küla"/><asula kood="5473" nimi="Nurmsi küla"/><asula kood="5889" nimi="Pajumaa küla"/><asula kood="6286" nimi="Pivarootsi küla"/><asula kood="6778" nimi="Rame küla"/><asula kood="6807" nimi="Rannaküla"/><asula kood="6961" nimi="Ridase küla"/><asula kood="7379" nimi="Salevere küla"/><asula kood="8663" nimi="Ullaste küla"/><asula kood="9141" nimi="Vatla küla"/><asula kood="9388" nimi="Virtsu alevik"/><asula kood="9478" nimi="Voose küla"/><asula kood="9742" nimi="Äila küla"/></vald><vald kood="0342"><asula kood="2266" nimi="Jõgisoo küla"/><asula kood="2593" nimi="Kalju küla"/><asula kood="2826" nimi="Kastja küla"/><asula kood="3366" nimi="Koluvere küla"/><asula kood="3587" nimi="Kullamaa küla"/><asula kood="3590" nimi="Kullametsa küla"/><asula kood="4230" nimi="Leila küla"/><asula kood="4271" nimi="Lemmikküla"/><asula kood="4361" nimi="Liivi küla"/><asula kood="5165" nimi="Mõrdu küla"/><asula kood="6599" nimi="Päri küla"/><asula kood="7589" nimi="Silla küla"/><asula kood="8607" nimi="Ubasalu küla"/><asula kood="9812" nimi="Üdruma küla"/></vald><vald kood="0411"><asula kood="1169" nimi="Alaküla"/><asula kood="1369" nimi="Aruküla"/><asula kood="1936" nimi="Hälvati küla"/><asula kood="2255" nimi="Jõeääre küla"/><asula kood="2323" nimi="Järise küla"/><asula kood="2912" nimi="Keemu küla"/><asula kood="2946" nimi="Kelu küla"/><asula kood="3113" nimi="Kirbla küla"/><asula kood="7782" nimi="Kirikuküla"/><asula kood="3210" nimi="Kloostri küla"/><asula kood="3616" nimi="Kunila küla"/><asula kood="4149" nimi="Laulepa küla"/><asula kood="4163" nimi="Lautna küla"/><asula kood="4330" nimi="Lihula linn"/><asula kood="4429" nimi="Liustemäe küla"/><asula kood="4820" nimi="Matsalu küla"/><asula kood="4847" nimi="Meelva küla"/><asula kood="4929" nimi="Metsküla"/><asula kood="5174" nimi="Mõisimaa küla"/><asula kood="5464" nimi="Nurme küla"/><asula kood="5845" nimi="Pagasi küla"/><asula kood="6013" nimi="Parivere küla"/><asula kood="6055" nimi="Peanse küla"/><asula kood="6096" nimi="Penijõe küla"/><asula kood="6131" nimi="Petaaluse küla"/><asula kood="6302" nimi="Poanse küla"/><asula kood="6827" nimi="Rannu küla"/><asula kood="7087" nimi="Rootsi küla"/><asula kood="7117" nimi="Rumba küla"/><asula kood="7310" nimi="Saastna küla"/><asula kood="7511" nimi="Seira küla"/><asula kood="7519" nimi="Seli küla"/><asula kood="7749" nimi="Soovälja küla"/><asula kood="8401" nimi="Tuhu küla"/><asula kood="8446" nimi="Tuudi küla"/><asula kood="8666" nimi="Uluste küla"/><asula kood="8830" nimi="Vagivere küla"/><asula kood="8974" nimi="Valuste küla"/><asula kood="9035" nimi="Vanamõisa küla"/><asula kood="9499" nimi="Võhma küla"/><asula kood="9528" nimi="Võigaste küla"/></vald><vald kood="0436"><asula kood="1210" nimi="Allikmaa küla"/><asula kood="1447" nimi="Auaste küla"/><asula kood="2084" nimi="Ingküla"/><asula kood="2126" nimi="Jaakna küla"/><asula kood="2166" nimi="Jalukse küla"/><asula kood="2479" nimi="Kadarpiku küla"/><asula kood="2904" nimi="Kedre küla"/><asula kood="2906" nimi="Keedika küla"/><asula kood="3135" nimi="Kirimäe küla"/><asula kood="3247" nimi="Koela küla"/><asula kood="3539" nimi="Kuijõe küla"/><asula kood="3889" nimi="Kärbla küla"/><asula kood="4178" nimi="Leediküla"/><asula kood="4400" nimi="Linnamäe küla"/><asula kood="4553" nimi="Luigu küla"/><asula kood="5143" nimi="Mõisaküla"/><asula kood="5407" nimi="Nigula küla"/><asula kood="5413" nimi="Nihka küla"/><asula kood="5415" nimi="Niibi küla"/><asula kood="5737" nimi="Oru küla"/><asula kood="5926" nimi="Palivere alevik"/><asula kood="6191" nimi="Piirsalu küla"/><asula kood="6586" nimi="Pälli küla"/><asula kood="7011" nimi="Risti alevik"/><asula kood="7183" nimi="Rõuma küla"/><asula kood="7369" nimi="Salajõe küla"/><asula kood="7465" nimi="Saunja küla"/><asula kood="7534" nimi="Seljaküla"/><asula kood="7709" nimi="Soolu küla"/><asula kood="8025" nimi="Taebla alevik"/><asula kood="8058" nimi="Tagavere küla"/><asula kood="8434" nimi="Turvalepa küla"/><asula kood="8776" nimi="Uugla küla"/><asula kood="9156" nimi="Vedra küla"/><asula kood="9254" nimi="Vidruka küla"/><asula kood="9572" nimi="Võntküla"/><asula kood="9686" nimi="Väänla küla"/></vald><vald kood="0452"><asula kood="1209" nimi="Allikotsa küla"/><asula kood="1546" nimi="Ehmja küla"/><asula kood="1600" nimi="Enivere küla"/><asula kood="2246" nimi="Jõesse küla"/><asula kood="2399" nimi="Kaare küla"/><asula kood="2426" nimi="Kaasiku küla"/><asula kood="2446" nimi="Kabeli küla"/><asula kood="2787" nimi="Kasari küla"/><asula kood="2958" nimi="Keravere küla"/><asula kood="2983" nimi="Keskküla"/><asula kood="2984" nimi="Keskvere küla"/><asula kood="2991" nimi="Kesu küla"/><asula kood="3147" nimi="Kirna küla"/><asula kood="3321" nimi="Kokre küla"/><asula kood="3605" nimi="Kuluse küla"/><asula kood="3660" nimi="Kurevere küla"/><asula kood="4068" nimi="Laiküla"/><asula kood="4350" nimi="Liivaküla"/><asula kood="4796" nimi="Martna küla"/><asula kood="5259" nimi="Männiku küla"/><asula kood="5419" nimi="Niinja küla"/><asula kood="5526" nimi="Nõmme küla"/><asula kood="5626" nimi="Ohtla küla"/><asula kood="5693" nimi="Oonga küla"/><asula kood="6464" nimi="Putkaste küla"/><asula kood="6805" nimi="Rannajõe küla"/><asula kood="7178" nimi="Rõude küla"/><asula kood="7682" nimi="Soo-otsa küla"/><asula kood="7832" nimi="Suure-Lähtru küla"/><asula kood="8111" nimi="Tammiku küla"/><asula kood="8405" nimi="Tuka küla"/><asula kood="8785" nimi="Uusküla"/><asula kood="9017" nimi="Vanaküla"/><asula kood="4632" nimi="Väike-Lähtru küla"/></vald><vald kood="0520"><asula kood="1469" nimi="Aulepa küla"/><asula kood="1505" nimi="Dirhami küla"/><asula kood="1556" nimi="Einbi küla"/><asula kood="1571" nimi="Elbiku küla "/><asula kood="1760" nimi="Hara küla"/><asula kood="1889" nimi="Hosby küla"/><asula kood="1964" nimi="Höbringi küla"/><asula kood="3514" nimi="Kudani küla"/><asula kood="5743" nimi="Osmussaare küla"/><asula kood="6029" nimi="Paslepa küla"/><asula kood="6669" nimi="Pürksi küla"/><asula kood="6968" nimi="Riguldi küla"/><asula kood="7077" nimi="Rooslepa küla"/><asula kood="7284" nimi="Saare küla"/><asula kood="7760" nimi="Spithami küla"/><asula kood="7817" nimi="Sutlepa küla"/><asula kood="7829" nimi="Suur-Nõmmküla"/><asula kood="8074" nimi="Tahu küla"/><asula kood="8187" nimi="Telise küla"/><asula kood="8409" nimi="Tuksi küla"/><asula kood="9011" nimi="Vanaküla"/><asula kood="5523" nimi="Väike-Nõmmküla"/><asula kood="9803" nimi="Österby küla"/></vald><vald kood="0531"><asula kood="1852" nimi="Hindaste küla"/><asula kood="5513" nimi="Nõmmemaa küla"/><asula kood="5543" nimi="Nõva küla"/><asula kood="6109" nimi="Peraküla"/><asula kood="6808" nimi="Rannaküla"/><asula kood="8437" nimi="Tusari küla"/><asula kood="8890" nimi="Vaisi küla"/><asula kood="9083" nimi="Variku küla"/></vald><vald kood="0674"><asula kood="1017" nimi="Aamse küla"/><asula kood="1201" nimi="Allika küla"/><asula kood="1251" nimi="Ammuta küla"/><asula kood="1592" nimi="Emmuvere küla"/><asula kood="1624" nimi="Erja küla"/><asula kood="1658" nimi="Espre küla"/><asula kood="1711" nimi="Haeska küla"/><asula kood="1824" nimi="Herjava küla"/><asula kood="1875" nimi="Hobulaiu küla"/><asula kood="2285" nimi="Jõõdre küla"/><asula kood="2466" nimi="Kabrametsa küla"/><asula kood="2472" nimi="Kadaka küla"/><asula kood="2497" nimi="Kaevere küla"/><asula kood="3027" nimi="Kiideva küla"/><asula kood="3090" nimi="Kiltsi küla"/><asula kood="3171" nimi="Kiviküla"/><asula kood="3276" nimi="Koheri küla"/><asula kood="3281" nimi="Koidu küla"/><asula kood="3341" nimi="Kolila küla"/><asula kood="3361" nimi="Kolu küla"/><asula kood="3849" nimi="Käpla küla"/><asula kood="4063" nimi="Laheva küla"/><asula kood="4102" nimi="Lannuste küla"/><asula kood="4351" nimi="Liivaküla"/><asula kood="4426" nimi="Litu küla"/><asula kood="4592" nimi="Lõbe küla"/><asula kood="4883" nimi="Metsaküla"/><asula kood="5186" nimi="Mäeküla"/><asula kood="5216" nimi="Mägari küla"/><asula kood="5527" nimi="Nõmme küla"/><asula kood="5971" nimi="Panga küla"/><asula kood="5989" nimi="Paralepa alevik"/><asula kood="6959" nimi="Parila küla"/><asula kood="6403" nimi="Puiatu küla"/><asula kood="6413" nimi="Puise küla"/><asula kood="6462" nimi="Pusku küla"/><asula kood="6496" nimi="Põgari-Sassi küla"/><asula kood="7029" nimi="Rohense küla"/><asula kood="7036" nimi="Rohuküla"/><asula kood="7120" nimi="Rummu küla"/><asula kood="7275" nimi="Saanika küla"/><asula kood="7283" nimi="Saardu küla"/><asula kood="7540" nimi="Sepaküla"/><asula kood="7606" nimi="Sinalepa küla"/><asula kood="1119" nimi="Suure-Ahli küla"/><asula kood="8116" nimi="Tammiku küla"/><asula kood="8321" nimi="Tanska küla"/><asula kood="8465" nimi="Tuuru küla"/><asula kood="8690" nimi="Uneste küla"/><asula kood="8769" nimi="Uuemõisa alevik"/><asula kood="8768" nimi="Uuemõisa küla"/><asula kood="8929" nimi="Valgevälja küla"/><asula kood="9091" nimi="Varni küla"/><asula kood="9343" nimi="Vilkla küla"/><asula kood="9568" nimi="Võnnu küla"/><asula kood="9616" nimi="Väike-Ahli küla"/><asula kood="9673" nimi="Vätse küla"/><asula kood="9853" nimi="Üsse küla"/></vald><vald kood="0907"><asula kood="1493" nimi="Borrby küla"/><asula kood="1502" nimi="Diby küla"/><asula kood="1662" nimi="Fällarna küla"/><asula kood="1670" nimi="Förby küla"/><asula kood="1892" nimi="Hosby küla"/><asula kood="1900" nimi="Hullo küla"/><asula kood="2981" nimi="Kersleti küla"/><asula kood="5453" nimi="Norrby küla"/><asula kood="7124" nimi="Rumpo küla"/><asula kood="7205" nimi="Rälby küla"/><asula kood="7502" nimi="Saxby küla"/><asula kood="7845" nimi="Suuremõisa küla"/><asula kood="7875" nimi="Sviby küla"/><asula kood="7971" nimi="Söderby küla"/></vald></maakond><maakond kood="0059"><vald kood="0190"><asula kood="1032" nimi="Aaspere küla"/><asula kood="1035" nimi="Aasu küla"/><asula kood="1051" nimi="Aaviku küla"/><asula kood="1463" nimi="Auküla"/><asula kood="1661" nimi="Essu küla"/><asula kood="1739" nimi="Haljala alevik"/><asula kood="1986" nimi="Idavere küla"/><asula kood="2664" nimi="Kandle küla"/><asula kood="2896" nimi="Kavastu küla"/><asula kood="3161" nimi="Kisuvere küla"/><asula kood="3754" nimi="Kõldu küla"/><asula kood="3918" nimi="Kärmu küla"/><asula kood="4331" nimi="Lihulõpe küla"/><asula kood="4337" nimi="Liiguste küla"/><asula kood="6093" nimi="Pehka küla"/><asula kood="6493" nimi="Põdruse küla"/><asula kood="7468" nimi="Sauste küla"/><asula kood="8167" nimi="Tatruse küla"/><asula kood="9024" nimi="Vanamõisa küla"/><asula kood="2779" nimi="Varangu küla"/><asula kood="9552" nimi="Võle küla"/></vald><vald kood="0272"><asula kood="1246" nimi="Ama küla"/><asula kood="1334" nimi="Arbavere küla"/><asula kood="1897" nimi="Hulja alevik"/><asula kood="1924" nimi="Hõbeda küla"/><asula kood="1947" nimi="Härjadi küla"/><asula kood="2245" nimi="Jõepere küla"/><asula kood="2253" nimi="Jõetaguse küla"/><asula kood="2476" nimi="Kadapiku küla"/><asula kood="2490" nimi="Kadrina alevik"/><asula kood="2614" nimi="Kallukse küla"/><asula kood="3017" nimi="Kihlevere küla"/><asula kood="3074" nimi="Kiku küla"/><asula kood="3823" nimi="Kõrveküla"/><asula kood="4106" nimi="Lante küla"/><asula kood="4227" nimi="Leikude küla"/><asula kood="4498" nimi="Loobu küla"/><asula kood="4641" nimi="Läsna küla"/><asula kood="5147" nimi="Mõndavere küla"/><asula kood="5276" nimi="Mäo küla"/><asula kood="5395" nimi="Neeruti küla"/><asula kood="5620" nimi="Ohepalu küla"/><asula kood="5741" nimi="Orutaguse küla"/><asula kood="6004" nimi="Pariisi küla"/><asula kood="6507" nimi="Põima küla"/><asula kood="6953" nimi="Ridaküla"/><asula kood="7164" nimi="Rõmeda küla"/><asula kood="7376" nimi="Salda küla"/><asula kood="7456" nimi="Saukse küla"/><asula kood="8254" nimi="Tirbiku küla"/><asula kood="8278" nimi="Tokolopi küla"/><asula kood="8622" nimi="Udriku küla"/><asula kood="8651" nimi="Uku küla"/><asula kood="8689" nimi="Undla küla"/><asula kood="8862" nimi="Vaiatu küla"/><asula kood="9043" nimi="Vandu küla"/><asula kood="9312" nimi="Viitna küla"/><asula kood="9449" nimi="Vohnja küla"/><asula kood="9490" nimi="Võduvere küla"/><asula kood="9534" nimi="Võipere küla"/></vald><vald kood="0381"><asula kood="1193" nimi="Alekvere küla"/><asula kood="1370" nimi="Arukse küla"/><asula kood="2036" nimi="Ilistvere küla"/><asula kood="2424" nimi="Kaasiksaare küla"/><asula kood="2941" nimi="Kellavere küla"/><asula kood="4035" nimi="Laekvere alevik"/><asula kood="4589" nimi="Luusika küla"/><asula kood="4978" nimi="Moora küla"/><asula kood="5105" nimi="Muuga küla"/><asula kood="5794" nimi="Paasvere küla"/><asula kood="5814" nimi="Padu küla"/><asula kood="6729" nimi="Rahkla küla"/><asula kood="6768" nimi="Rajaküla"/><asula kood="7034" nimi="Rohu küla"/><asula kood="7401" nimi="Salutaguse küla"/><asula kood="7630" nimi="Sirevere küla"/><asula kood="7748" nimi="Sootaguse küla"/><asula kood="9118" nimi="Vassivere küla"/><asula kood="9204" nimi="Venevere küla"/></vald><vald kood="0660"><asula kood="1309" nimi="Ao küla"/><asula kood="1529" nimi="Edru küla"/><asula kood="1594" nimi="Emumäe küla"/><asula kood="2371" nimi="Jäätma küla"/><asula kood="2437" nimi="Kaavere küla"/><asula kood="2480" nimi="Kadiküla"/><asula kood="2635" nimi="Kamariku küla"/><asula kood="2934" nimi="Kellamäe küla"/><asula kood="3162" nimi="Kitsemetsa küla"/><asula kood="3297" nimi="Koila küla"/><asula kood="3367" nimi="Koluvere küla"/><asula kood="3783" nimi="Kõpsta küla"/><asula kood="4065" nimi="Lahu küla"/><asula kood="4091" nimi="Lammasküla"/><asula kood="4125" nimi="Lasinurme küla"/><asula kood="4339" nimi="Liigvalla küla"/><asula kood="5132" nimi="Mõisamaa küla"/><asula kood="5235" nimi="Mäiste küla"/><asula kood="5529" nimi="Nõmmküla"/><asula kood="5661" nimi="Olju küla"/><asula kood="5805" nimi="Padaküla"/><asula kood="6158" nimi="Piibe küla"/><asula kood="6775" nimi="Rakke alevik"/><asula kood="7202" nimi="Räitsvere küla"/><asula kood="7385" nimi="Salla küla"/><asula kood="7746" nimi="Sootaguse küla"/><asula kood="7831" nimi="Suure-Rakke küla"/><asula kood="8115" nimi="Tammiku küla"/><asula kood="9347" nimi="Villakvere küla"/><asula kood="9647" nimi="Väike-Rakke küla"/><asula kood="9648" nimi="Väike-Tammiku küla"/></vald><vald kood="0662"><asula kood="1362" nimi="Arkna küla"/><asula kood="1536" nimi="Eesküla"/><asula kood="2332" nimi="Järni küla"/><asula kood="2741" nimi="Karitsa küla"/><asula kood="2744" nimi="Karivärava küla"/><asula kood="2781" nimi="Karunga küla"/><asula kood="3202" nimi="Kloodi küla"/><asula kood="3582" nimi="Kullaaru küla"/><asula kood="3790" nimi="Kõrgemäe küla"/><asula kood="4123" nimi="Lasila küla"/><asula kood="4294" nimi="Lepna alevik"/><asula kood="4309" nimi="Levala küla"/><asula kood="5182" nimi="Mädapea küla"/><asula kood="5796" nimi="Paatna küla"/><asula kood="6567" nimi="Päide küla"/><asula kood="8001" nimi="Taaravainu küla"/><asula kood="8261" nimi="Tobia küla"/><asula kood="8520" nimi="Tõrma küla"/><asula kood="8525" nimi="Tõrremäe küla"/><asula kood="9196" nimi="Veltsi küla"/></vald><vald kood="0702"><asula kood="1043" nimi="Aasuvälja küla"/><asula kood="2689" nimi="Kantküla"/><asula kood="3809" nimi="Kõrma küla"/><asula kood="4166" nimi="Lavi küla"/><asula kood="4948" nimi="Miila küla"/><asula kood="5117" nimi="Mõedaka küla"/><asula kood="5267" nimi="Männikvälja küla"/><asula kood="5465" nimi="Nurkse küla"/><asula kood="5521" nimi="Nõmmise küla"/><asula kood="6535" nimi="Põlula küla"/><asula kood="7325" nimi="Sae küla"/><asula kood="8661" nimi="Uljaste küla"/><asula kood="8665" nimi="Ulvi küla"/><asula kood="9396" nimi="Viru-Kabala küla"/></vald><vald kood="0770"><asula kood="1242" nimi="Aluvere küla"/><asula kood="1259" nimi="Andja küla"/><asula kood="1345" nimi="Aresi küla"/><asula kood="2373" nimi="Jäätma küla"/><asula kood="2405" nimi="Kaarli küla"/><asula kood="2853" nimi="Katela küla"/><asula kood="2851" nimi="Katku küla"/><asula kood="3261" nimi="Kohala-Eesküla"/><asula kood="3263" nimi="Kohala küla"/><asula kood="3432" nimi="Koovälja küla"/><asula kood="5055" nimi="Muru küla"/><asula kood="5478" nimi="Nurme küla"/><asula kood="5554" nimi="Näpi alevik"/><asula kood="5979" nimi="Papiaru küla"/><asula kood="6726" nimi="Rahkla küla"/><asula kood="6850" nimi="Raudlepa küla"/><asula kood="6860" nimi="Raudvere küla"/><asula kood="7058" nimi="Roodevälja küla"/><asula kood="7199" nimi="Rägavere küla"/><asula kood="7684" nimi="Sooaluse küla"/><asula kood="7892" nimi="Sõmeru alevik"/><asula kood="7927" nimi="Sämi küla"/><asula kood="7925" nimi="Sämi-Tagaküla"/><asula kood="8304" nimi="Toomla küla"/><asula kood="8610" nimi="Ubja küla"/><asula kood="8637" nimi="Uhtna alevik"/><asula kood="8740" nimi="Ussimäe küla"/><asula kood="8822" nimi="Vaeküla"/><asula kood="9099" nimi="Varudi-Altküla"/><asula kood="9098" nimi="Varudi-Vanaküla"/><asula kood="9495" nimi="Võhma küla"/></vald><vald kood="0786"><asula kood="1048" nimi="Aavere küla"/><asula kood="1235" nimi="Alupere küla"/><asula kood="1315" nimi="Araski küla"/><asula kood="1410" nimi="Assamalla küla"/><asula kood="2334" nimi="Järsi küla"/><asula kood="2345" nimi="Järvajõe küla"/><asula kood="2482" nimi="Kadapiku küla"/><asula kood="2500" nimi="Kaeva küla"/><asula kood="2970" nimi="Kerguta küla"/><asula kood="3288" nimi="Koiduküla"/><asula kood="3438" nimi="Koplitaguse küla"/><asula kood="3531" nimi="Kuie küla"/><asula kood="3592" nimi="Kullenga küla"/><asula kood="3694" nimi="Kursi küla"/><asula kood="4273" nimi="Lemmküla"/><asula kood="4470" nimi="Loksa küla"/><asula kood="4920" nimi="Metskaevu küla"/><asula kood="5352" nimi="Naistevälja küla"/><asula kood="6204" nimi="Piisupi küla"/><asula kood="6333" nimi="Porkuni küla"/><asula kood="6491" nimi="Põdrangu küla"/><asula kood="7476" nimi="Sauvälja küla"/><asula kood="7481" nimi="Savalduma küla"/><asula kood="7956" nimi="Sääse alevik"/><asula kood="8130" nimi="Tamsalu linn"/><asula kood="8604" nimi="Türje küla"/><asula kood="8754" nimi="Uudeküla"/><asula kood="8820" nimi="Vadiküla"/><asula kood="8903" nimi="Vajangu küla"/><asula kood="9429" nimi="Vistla küla"/><asula kood="9505" nimi="Võhmetu küla"/><asula kood="9506" nimi="Võhmuta küla"/></vald><vald kood="0790"><asula kood="2068" nimi="Imastu küla"/><asula kood="2199" nimi="Jootme küla"/><asula kood="2318" nimi="Jäneda küla"/><asula kood="2762" nimi="Karkuse küla"/><asula kood="3702" nimi="Kuru küla"/><asula kood="3822" nimi="Kõrveküla"/><asula kood="4217" nimi="Lehtse alevik"/><asula kood="4403" nimi="Linnape küla"/><asula kood="4473" nimi="Loksu küla"/><asula kood="4474" nimi="Lokuta küla"/><asula kood="4638" nimi="Läpi küla"/><asula kood="4644" nimi="Läste küla"/><asula kood="4963" nimi="Moe küla"/><asula kood="5525" nimi="Nõmmküla"/><asula kood="5551" nimi="Näo küla"/><asula kood="6037" nimi="Patika küla"/><asula kood="6177" nimi="Piilu küla"/><asula kood="6374" nimi="Pruuna küla"/><asula kood="6703" nimi="Rabasaare küla"/><asula kood="6847" nimi="Raudla küla"/><asula kood="7198" nimi="Rägavere küla"/><asula kood="7221" nimi="Räsna küla"/><asula kood="7343" nimi="Saiakopli küla"/><asula kood="7358" nimi="Saksi küla"/><asula kood="8140" nimi="Tapa linn"/><asula kood="8549" nimi="Tõõrakõrve küla"/><asula kood="8836" nimi="Vahakulmu küla"/></vald><vald kood="0887"><asula kood="1040" nimi="Aasumetsa küla"/><asula kood="1073" nimi="Adaka küla"/><asula kood="1218" nimi="Altja küla"/><asula kood="1255" nimi="Andi küla"/><asula kood="1294" nimi="Annikvere küla"/><asula kood="1562" nimi="Eisma küla"/><asula kood="1637" nimi="Eru küla"/><asula kood="1723" nimi="Haili küla"/><asula kood="2059" nimi="Ilumäe küla"/><asula kood="2191" nimi="Joandu küla"/><asula kood="2558" nimi="Kakuvälja küla"/><asula kood="2715" nimi="Karepa küla"/><asula kood="2774" nimi="Karula küla"/><asula kood="3173" nimi="Kiva küla"/><asula kood="3345" nimi="Koljaku küla"/><asula kood="3401" nimi="Koolimäe küla"/><asula kood="3449" nimi="Korjuse küla"/><asula kood="3473" nimi="Kosta küla"/><asula kood="3934" nimi="Käsmu küla"/><asula kood="4052" nimi="Lahe küla"/><asula kood="4151" nimi="Lauli küla"/><asula kood="4437" nimi="Lobi küla"/><asula kood="4905" nimi="Metsanurga küla"/><asula kood="4918" nimi="Metsiku küla"/><asula kood="5009" nimi="Muike küla"/><asula kood="5091" nimi="Mustoja küla"/><asula kood="5364" nimi="Natturi küla"/><asula kood="5442" nimi="Noonu küla"/><asula kood="5575" nimi="Oandu küla"/><asula kood="5786" nimi="Paasi küla"/><asula kood="5899" nimi="Pajuveski küla"/><asula kood="5936" nimi="Palmse küla"/><asula kood="6068" nimi="Pedassaare küla"/><asula kood="6148" nimi="Pihlaspea küla"/><asula kood="7138" nimi="Rutja küla"/><asula kood="7329" nimi="Sagadi küla"/><asula kood="7366" nimi="Sakussaare küla"/><asula kood="7374" nimi="Salatse küla"/><asula kood="8195" nimi="Tepelvälja küla"/><asula kood="8178" nimi="Tidriku küla"/><asula kood="8222" nimi="Tiigi küla"/><asula kood="8293" nimi="Toolse küla"/><asula kood="8543" nimi="Tõugu küla"/><asula kood="8787" nimi="Uusküla"/><asula kood="8888" nimi="Vainupea küla"/><asula kood="9139" nimi="Vatku küla"/><asula kood="9213" nimi="Vergi küla"/><asula kood="9270" nimi="Vihula küla"/><asula kood="9321" nimi="Vila küla"/><asula kood="9350" nimi="Villandi küla"/><asula kood="9498" nimi="Võhma küla"/><asula kood="9592" nimi="Võsu alevik"/><asula kood="9593" nimi="Võsupere küla"/></vald><vald kood="0900"><asula kood="1182" nimi="Alavere küla"/><asula kood="1203" nimi="Allika küla"/><asula kood="1275" nimi="Anguse küla"/><asula kood="1331" nimi="Aravuse küla"/><asula kood="1372" nimi="Aruküla"/><asula kood="1395" nimi="Aruvälja küla"/><asula kood="2090" nimi="Inju küla"/><asula kood="2484" nimi="Kadila küla"/><asula kood="2555" nimi="Kakumäe küla"/><asula kood="2679" nimi="Kannastiku küla"/><asula kood="2760" nimi="Karkuse küla"/><asula kood="2872" nimi="Kaukvere küla"/><asula kood="2919" nimi="Kehala küla"/><asula kood="3252" nimi="Koeravere küla"/><asula kood="3577" nimi="Kulina küla"/><asula kood="3994" nimi="Küti küla"/><asula kood="4293" nimi="Lepiku küla"/><asula kood="4634" nimi="Lähtse küla"/><asula kood="5114" nimi="Mõdriku küla"/><asula kood="5212" nimi="Mäetaguse küla"/><asula kood="5471" nimi="Nurmetu küla"/><asula kood="5585" nimi="Obja küla"/><asula kood="5896" nimi="Pajusti alevik"/><asula kood="5923" nimi="Palasi küla"/><asula kood="6182" nimi="Piira küla"/><asula kood="6416" nimi="Puka küla"/><asula kood="6829" nimi="Rasivere küla"/><asula kood="7012" nimi="Ristiküla"/><asula kood="7028" nimi="Roela alevik"/><asula kood="7262" nimi="Rünga küla"/><asula kood="7278" nimi="Saara küla"/><asula kood="7733" nimi="Soonuka küla"/><asula kood="7777" nimi="Suigu küla"/><asula kood="8108" nimi="Tammiku küla"/><asula kood="8390" nimi="Tudu alevik"/><asula kood="9009" nimi="Vana-Vinni küla"/><asula kood="9153" nimi="Veadla küla"/><asula kood="9245" nimi="Vetiku küla"/><asula kood="9375" nimi="Vinni alevik"/><asula kood="9394" nimi="Viru-Jaagupi alevik"/><asula kood="9467" nimi="Voore küla"/><asula kood="9508" nimi="Võhu küla"/></vald><vald kood="0902"><asula kood="1037" nimi="Aasukalda küla"/><asula kood="2019" nimi="Iila küla"/><asula kood="2447" nimi="Kabeli küla"/><asula kood="2583" nimi="Kaliküla"/><asula kood="2675" nimi="Kanguristi küla"/><asula kood="3179" nimi="Kiviküla"/><asula kood="3295" nimi="Koila küla"/><asula kood="3610" nimi="Kunda küla"/><asula kood="3688" nimi="Kurna küla"/><asula kood="3709" nimi="Kutsala küla"/><asula kood="3725" nimi="Kuura küla"/><asula kood="4305" nimi="Letipea küla"/><asula kood="4408" nimi="Linnuse küla"/><asula kood="4736" nimi="Mahu küla"/><asula kood="4755" nimi="Malla küla"/><asula kood="4786" nimi="Marinu küla"/><asula kood="4926" nimi="Metsavälja küla"/><asula kood="5456" nimi="Nugeri küla"/><asula kood="5651" nimi="Ojaküla"/><asula kood="5791" nimi="Paasküla"/><asula kood="5802" nimi="Pada-Aruküla"/><asula kood="5804" nimi="Pada küla"/><asula kood="6219" nimi="Pikaristi küla"/><asula kood="6612" nimi="Pärna küla"/><asula kood="7407" nimi="Samma küla"/><asula kood="7530" nimi="Selja küla"/><asula kood="7557" nimi="Siberi küla"/><asula kood="7602" nimi="Simunamäe küla"/><asula kood="8303" nimi="Toomika küla"/><asula kood="8602" nimi="Tüükri küla"/><asula kood="8704" nimi="Unukse küla"/><asula kood="9096" nimi="Varudi küla"/><asula kood="9121" nimi="Vasta küla"/><asula kood="9351" nimi="Villavere küla"/><asula kood="9399" nimi="Viru-Nigula alevik"/><asula kood="9578" nimi="Võrkla küla"/></vald><vald kood="0926"><asula kood="1047" nimi="Aavere küla"/><asula kood="1069" nimi="Aburi küla"/><asula kood="1476" nimi="Avanduse küla"/><asula kood="1484" nimi="Avispea küla"/><asula kood="1521" nimi="Ebavere küla"/><asula kood="1559" nimi="Eipri küla"/><asula kood="1866" nimi="Hirla küla"/><asula kood="2080" nimi="Imukvere küla"/><asula kood="3092" nimi="Kiltsi alevik"/><asula kood="3410" nimi="Koonu küla"/><asula kood="3692" nimi="Kurtna küla"/><asula kood="3878" nimi="Kännuküla"/><asula kood="3924" nimi="Kärsa küla"/><asula kood="3932" nimi="Käru küla"/><asula kood="4356" nimi="Liivaküla"/><asula kood="5295" nimi="Määri küla"/><asula kood="5320" nimi="Müüriku küla"/><asula kood="5333" nimi="Nadalama küla"/><asula kood="5508" nimi="Nõmme küla"/><asula kood="5716" nimi="Orguse küla"/><asula kood="5970" nimi="Pandivere küla"/><asula kood="6230" nimi="Pikevere küla"/><asula kood="6382" nimi="Pudivere küla"/><asula kood="6716" nimi="Raeküla"/><asula kood="6756" nimi="Raigu küla"/><asula kood="6836" nimi="Rastla küla"/><asula kood="7412" nimi="Sandimetsa küla"/><asula kood="7603" nimi="Simuna alevik"/><asula kood="8348" nimi="Triigi küla"/><asula kood="8770" nimi="Uuemõisa küla"/><asula kood="9048" nimi="Vao küla"/><asula kood="9056" nimi="Varangu küla"/><asula kood="9485" nimi="Vorsti küla"/><asula kood="9549" nimi="Võivere küla"/><asula kood="9628" nimi="Väike-Maarja alevik"/><asula kood="9777" nimi="Äntu küla"/><asula kood="9783" nimi="Ärina küla"/></vald></maakond><maakond kood="0065"><vald kood="0117"><asula kood="1116" nimi="Ahja alevik"/><asula kood="1156" nimi="Akste küla"/><asula kood="1980" nimi="Ibaste küla"/><asula kood="3469" nimi="Kosova küla"/><asula kood="3923" nimi="Kärsa küla"/><asula kood="4468" nimi="Loko küla"/><asula kood="5061" nimi="Mustakurmu küla"/><asula kood="5170" nimi="Mõtsküla"/><asula kood="9023" nimi="Vanamõisa küla"/></vald><vald kood="0285"><asula kood="1620" nimi="Erastvere küla"/><asula kood="1799" nimi="Heisri küla"/><asula kood="1857" nimi="Hino küla"/><asula kood="1914" nimi="Hurmi küla"/><asula kood="2259" nimi="Jõgehara küla"/><asula kood="2277" nimi="Jõksi küla"/><asula kood="2387" nimi="Kaagna küla"/><asula kood="2392" nimi="Kaagvere küla"/><asula kood="2667" nimi="Kanepi alevik"/><asula kood="2769" nimi="Karste küla"/><asula kood="3280" nimi="Koigera küla"/><asula kood="3415" nimi="Kooraste küla"/><asula kood="4156" nimi="Lauri küla"/><asula kood="4730" nimi="Magari küla"/><asula kood="5557" nimi="Närapää küla"/><asula kood="6089" nimi="Peetrimõisa küla"/><asula kood="6163" nimi="Piigandi küla"/><asula kood="6520" nimi="Põlgaste küla"/><asula kood="6889" nimi="Rebaste küla"/><asula kood="7696" nimi="Soodoma küla"/><asula kood="7897" nimi="Sõreste küla"/><asula kood="9066" nimi="Varbuse küla"/></vald><vald kood="0354"><asula kood="1960" nimi="Häätaru küla"/><asula kood="2007" nimi="Ihamaru küla"/><asula kood="2707" nimi="Karaski küla"/><asula kood="2727" nimi="Karilatsi küla"/><asula kood="3505" nimi="Krootuse küla"/><asula kood="5959" nimi="Palutaja küla"/><asula kood="6167" nimi="Piigaste küla"/><asula kood="6354" nimi="Prangli küla"/><asula kood="8455" nimi="Tuulemäe küla"/><asula kood="8469" nimi="Tõdu küla"/><asula kood="9229" nimi="Veski küla"/><asula kood="9472" nimi="Voorepalu küla"/></vald><vald kood="0385"><asula kood="1844" nimi="Himma küla"/><asula kood="2197" nimi="Joosu küla"/><asula kood="4051" nimi="Lahe küla"/><asula kood="5059" nimi="Mustajõe küla"/><asula kood="5355" nimi="Naruski küla"/><asula kood="6347" nimi="Pragi küla"/><asula kood="7071" nimi="Roosi küla"/><asula kood="7855" nimi="Suurküla"/><asula kood="8243" nimi="Tilsi küla"/><asula kood="8989" nimi="Vana-Koiola küla"/><asula kood="9072" nimi="Vardja küla"/></vald><vald kood="0465"><asula kood="1453" nimi="Audjassaare küla"/><asula kood="1489" nimi="Beresje küla"/><asula kood="2003" nimi="Igrise küla"/><asula kood="2362" nimi="Järvepää küla"/><asula kood="2512" nimi="Kahkva küla"/><asula kood="2736" nimi="Karisilla küla"/><asula kood="4114" nimi="Laossina küla"/><asula kood="4692" nimi="Lüübnitsa küla"/><asula kood="4951" nimi="Mikitamäe küla"/><asula kood="5422" nimi="Niitsiku küla"/><asula kood="6474" nimi="Puugnitsa küla"/><asula kood="7170" nimi="Rõsna küla"/><asula kood="7250" nimi="Rääsolaane küla"/><asula kood="7523" nimi="Selise küla"/><asula kood="8300" nimi="Toomasmäe küla"/><asula kood="8737" nimi="Usinitsa küla"/><asula kood="9078" nimi="Varesmäe küla"/><asula kood="9607" nimi="Võõpsu küla"/></vald><vald kood="0473"><asula kood="2142" nimi="Jaanimõisa küla"/><asula kood="2419" nimi="Kaaru küla"/><asula kood="2471" nimi="Kadaja küla"/><asula kood="2654" nimi="Kanassaare küla"/><asula kood="2831" nimi="Kastmekoja küla"/><asula kood="2869" nimi="Kauksi küla"/><asula kood="4062" nimi="Laho küla"/><asula kood="4986" nimi="Mooste alevik"/><asula kood="6825" nimi="Rasina küla"/><asula kood="7501" nimi="Savimäe küla"/><asula kood="7858" nimi="Suurmetsa küla"/><asula kood="7918" nimi="Säkna küla"/><asula kood="7964" nimi="Säässaare küla"/><asula kood="8198" nimi="Terepi küla"/><asula kood="9300" nimi="Viisli küla"/></vald><vald kood="0547"><asula kood="1755" nimi="Hanikase küla"/><asula kood="2172" nimi="Jantra küla"/><asula kood="2514" nimi="Kahkva küla"/><asula kood="2559" nimi="Kakusuu küla"/><asula kood="2646" nimi="Kamnitsa küla"/><asula kood="3199" nimi="Kliima küla"/><asula kood="3446" nimi="Korgõmõisa küla"/><asula kood="3750" nimi="Kõivsaare küla"/><asula kood="3755" nimi="Kõliküla"/><asula kood="3838" nimi="Kõvera küla"/><asula kood="4286" nimi="Lepassaare küla"/><asula kood="4348" nimi="Liinamäe küla"/><asula kood="4594" nimi="Luuska küla"/><asula kood="4716" nimi="Madi küla"/><asula kood="4784" nimi="Marga küla"/><asula kood="5708" nimi="Orava küla"/><asula kood="5731" nimi="Oro küla"/><asula kood="6283" nimi="Piusa küla"/><asula kood="6345" nimi="Praakmani küla"/><asula kood="6585" nimi="Päka küla"/><asula kood="6633" nimi="Pääväkese küla"/><asula kood="6896" nimi="Rebasmäe küla"/><asula kood="6985" nimi="Riihora küla"/><asula kood="7173" nimi="Rõssa küla"/><asula kood="7652" nimi="Soe küla"/><asula kood="7657" nimi="Soena küla"/><asula kood="7843" nimi="Suuremetsa küla"/><asula kood="7326" nimi="Tamme küla"/><asula kood="8385" nimi="Tuderna küla"/><asula kood="9440" nimi="Vivva küla"/></vald><vald kood="0621"><asula kood="1027" nimi="Aarna küla"/><asula kood="1081" nimi="Adiste küla"/><asula kood="1261" nimi="Andre küla"/><asula kood="1609" nimi="Eoste küla"/><asula kood="1846" nimi="Himmaste küla"/><asula kood="1891" nimi="Holvandi küla"/><asula kood="3170" nimi="Kiuma küla"/><asula kood="3863" nimi="Kähri küla"/><asula kood="4575" nimi="Lutsu küla"/><asula kood="4768" nimi="Mammaste küla"/><asula kood="4851" nimi="Meemaste küla"/><asula kood="4938" nimi="Metste küla"/><asula kood="4945" nimi="Miiaste küla"/><asula kood="5445" nimi="Nooritsmetsa küla"/><asula kood="5705" nimi="Orajõe küla"/><asula kood="6025" nimi="Partsi küla"/><asula kood="6120" nimi="Peri küla"/><asula kood="6461" nimi="Puskaru küla"/><asula kood="6477" nimi="Puuri küla"/><asula kood="6536" nimi="Põlva linn"/><asula kood="7098" nimi="Rosma küla"/><asula kood="7660" nimi="Soesaare küla"/><asula kood="8027" nimi="Taevaskoja küla"/><asula kood="8353" nimi="Tromsi küla"/><asula kood="8574" nimi="Tännassilma küla"/><asula kood="8644" nimi="Uibujärve küla"/><asula kood="8927" nimi="Valgesoo küla"/><asula kood="9015" nimi="Vanaküla"/></vald><vald kood="0707"><asula kood="2140" nimi="Jaanikeste küla"/><asula kood="2815" nimi="Kassilaane küla"/><asula kood="3770" nimi="Kõnnu küla"/><asula kood="3963" nimi="Köstrimäe küla"/><asula kood="4193" nimi="Leevaku küla"/><asula kood="4410" nimi="Linte küla"/><asula kood="4849" nimi="Meelva küla"/><asula kood="5221" nimi="Mägiotsa küla"/><asula kood="5340" nimi="Naha küla"/><asula kood="5459" nimi="Nulga küla"/><asula kood="6268" nimi="Pindi küla"/><asula kood="6631" nimi="Pääsna küla"/><asula kood="6677" nimi="Raadama küla"/><asula kood="6743" nimi="Rahumäe küla"/><asula kood="6753" nimi="Raigla küla"/><asula kood="7016" nimi="Ristipalo küla"/><asula kood="7151" nimi="Ruusa küla"/><asula kood="7216" nimi="Räpina linn"/><asula kood="7289" nimi="Saareküla"/><asula kood="7595" nimi="Sillapää küla"/><asula kood="7835" nimi="Suure-Veerksu küla"/><asula kood="7975" nimi="Sülgoja küla"/><asula kood="8289" nimi="Toolamaa küla"/><asula kood="8313" nimi="Tooste küla"/><asula kood="8370" nimi="Tsirksi küla"/><asula kood="9511" nimi="Võiardi küla"/><asula kood="9599" nimi="Võuküla"/><asula kood="9608" nimi="Võõpsu alevik"/></vald><vald kood="0856"><asula kood="1058" nimi="Abissaare küla"/><asula kood="1131" nimi="Aiaste küla"/><asula kood="1785" nimi="Hauka küla"/><asula kood="3399" nimi="Kooli küla"/><asula kood="3511" nimi="Krüüdneri küla"/><asula kood="4707" nimi="Maaritsa küla"/><asula kood="5314" nimi="Mügra küla"/><asula kood="6209" nimi="Pikajärve küla"/><asula kood="6217" nimi="Pikareinu küla"/><asula kood="6472" nimi="Puugi küla"/><asula kood="7486" nimi="Saverna küla"/><asula kood="7645" nimi="Sirvaste küla"/><asula kood="7785" nimi="Sulaoja küla"/><asula kood="8217" nimi="Tiido küla"/><asula kood="8932" nimi="Valgjärve küla"/><asula kood="9422" nimi="Vissi küla"/></vald><vald kood="0872"><asula kood="2728" nimi="Karilatsi küla"/><asula kood="3030" nimi="Kiidjärve küla"/><asula kood="3422" nimi="Koorvere küla"/><asula kood="4198" nimi="Leevijõe küla"/><asula kood="4446" nimi="Logina küla"/><asula kood="4522" nimi="Lootvina küla"/><asula kood="5809" nimi="Padari küla"/><asula kood="8922" nimi="Valgemetsa küla"/><asula kood="9128" nimi="Vastse-Kuuste alevik"/><asula kood="9470" nimi="Vooreküla"/></vald><vald kood="0879"><asula kood="1706" nimi="Haavapää küla"/><asula kood="1849" nimi="Himmiste küla"/><asula kood="2252" nimi="Jõevaara küla"/><asula kood="2256" nimi="Jõeveere küla"/><asula kood="3066" nimi="Kikka küla"/><asula kood="3145" nimi="Kirmsi küla"/><asula kood="3406" nimi="Koolmajärve küla"/><asula kood="3405" nimi="Koolma küla"/><asula kood="3589" nimi="Kullamäe küla"/><asula kood="3629" nimi="Kunksilla küla"/><asula kood="4066" nimi="Laho küla"/><asula kood="4195" nimi="Leevi küla"/><asula kood="4326" nimi="Lihtensteini küla"/><asula kood="4911" nimi="Mõtsavaara küla"/><asula kood="5269" nimi="Männisalu küla"/><asula kood="5437" nimi="Nohipalo küla"/><asula kood="5857" nimi="Pahtpää küla"/><asula kood="7439" nimi="Sarvemäe küla"/><asula kood="7698" nimi="Soohara küla"/><asula kood="7981" nimi="Süvahavva küla"/><asula kood="8244" nimi="Timo küla"/><asula kood="9080" nimi="Vareste küla"/><asula kood="9223" nimi="Veriora alevik"/><asula kood="9224" nimi="Verioramõisa küla"/><asula kood="9294" nimi="Viira küla"/><asula kood="9369" nimi="Viluste küla"/><asula kood="9377" nimi="Vinso küla"/><asula kood="9527" nimi="Võika küla"/><asula kood="9175" nimi="Väike-Veerksu küla"/><asula kood="9664" nimi="Vändra küla"/></vald><vald kood="0934"><asula kood="3277" nimi="Koidula küla"/><asula kood="3358" nimi="Kolodavitsa küla"/><asula kood="3359" nimi="Kolossova küla"/><asula kood="3444" nimi="Korela küla"/><asula kood="3470" nimi="Kostkova küla"/><asula kood="3494" nimi="Kremessova küla"/><asula kood="3609" nimi="Kundruse küla"/><asula kood="4425" nimi="Litvina küla"/><asula kood="4434" nimi="Lobotka küla"/><asula kood="4570" nimi="Lutepää küla"/><asula kood="4827" nimi="Matsuri küla"/><asula kood="5300" nimi="Määsovitsa küla"/><asula kood="5387" nimi="Nedsaja küla"/><asula kood="6045" nimi="Pattina küla"/><asula kood="6115" nimi="Perdaku küla"/><asula kood="6305" nimi="Podmotsa küla"/><asula kood="6326" nimi="Popovitsa küla"/><asula kood="7243" nimi="Rääptsova küla"/><asula kood="7270" nimi="Saabolda küla"/><asula kood="7315" nimi="Saatse küla"/><asula kood="7404" nimi="Samarina küla"/><asula kood="7553" nimi="Sesniki küla"/><asula kood="7928" nimi="Säpina küla"/><asula kood="8286" nimi="Tonja küla"/><asula kood="8343" nimi="Treski küla"/><asula kood="8657" nimi="Ulitina küla"/><asula kood="8813" nimi="Vaartsi küla"/><asula kood="9151" nimi="Vedernika küla"/><asula kood="9194" nimi="Velna küla"/><asula kood="9216" nimi="Verhulitsa küla"/><asula kood="9484" nimi="Voropi küla"/><asula kood="9571" nimi="Võpolsova küla"/><asula kood="9635" nimi="Väike-Rõsna küla"/><asula kood="9672" nimi="Värska alevik"/><asula kood="9707" nimi="Õrsava küla"/></vald></maakond><maakond kood="0067"><vald kood="0149"><asula kood="1344" nimi="Are alevik"/><asula kood="1516" nimi="Eavere küla"/><asula kood="1576" nimi="Elbu küla"/><asula kood="3648" nimi="Kurena küla"/><asula kood="4296" nimi="Lepplaane küla"/><asula kood="5053" nimi="Murru küla"/><asula kood="5417" nimi="Niidu küla"/><asula kood="6012" nimi="Parisselja küla"/><asula kood="6608" nimi="Pärivere küla"/><asula kood="7776" nimi="Suigu küla"/><asula kood="8019" nimi="Tabria küla"/><asula kood="9555" nimi="Võlla küla"/></vald><vald kood="0160"><asula kood="1107" nimi="Ahaste küla"/><asula kood="1394" nimi="Aruvälja küla"/><asula kood="1458" nimi="Audru alevik"/><asula kood="1513" nimi="Eassalu küla"/><asula kood="2289" nimi="Jõõpre küla"/><asula kood="2468" nimi="Kabriste küla"/><asula kood="3014" nimi="Kihlepa küla"/><asula kood="3746" nimi="Kõima küla"/><asula kood="3891" nimi="Kärbu küla"/><asula kood="4165" nimi="Lavassaare alev"/><asula kood="4268" nimi="Lemmetsa küla"/><asula kood="4354" nimi="Liiva küla"/><asula kood="4384" nimi="Lindi küla"/><asula kood="4430" nimi="Liu küla"/><asula kood="4753" nimi="Malda küla"/><asula kood="4792" nimi="Marksa küla"/><asula kood="5578" nimi="Oara küla"/><asula kood="5986" nimi="Papsaare küla"/><asula kood="6499" nimi="Põhara küla"/><asula kood="6513" nimi="Põldeotsa küla"/><asula kood="6962" nimi="Ridalepa küla"/><asula kood="7300" nimi="Saari küla"/><asula kood="7460" nimi="Saulepa küla"/><asula kood="7663" nimi="Soeva küla"/><asula kood="7723" nimi="Soomra küla"/><asula kood="8463" nimi="Tuuraste küla"/><asula kood="8924" nimi="Valgeranna küla"/></vald><vald kood="0188"><asula kood="1030" nimi="Aasa küla"/><asula kood="1214" nimi="Altküla"/><asula kood="1267" nimi="Anelema küla"/><asula kood="1314" nimi="Arase küla"/><asula kood="1506" nimi="Eametsa küla"/><asula kood="1527" nimi="Eense küla"/><asula kood="1531" nimi="Eerma küla"/><asula kood="1602" nimi="Enge küla"/><asula kood="1634" nimi="Ertsma küla"/><asula kood="1736" nimi="Halinga küla"/><asula kood="1802" nimi="Helenurme küla"/><asula kood="2462" nimi="Kablima küla"/><asula kood="2493" nimi="Kaelase küla"/><asula kood="2669" nimi="Kangru küla"/><asula kood="3237" nimi="Kodesmaa küla"/><asula kood="3617" nimi="Kuninga küla"/><asula kood="4101" nimi="Langerma küla"/><asula kood="4216" nimi="Lehtmetsa küla"/><asula kood="4219" nimi="Lehu küla"/><asula kood="4320" nimi="Libatse küla"/><asula kood="4504" nimi="Loomse küla"/><asula kood="4743" nimi="Maima küla"/><asula kood="5137" nimi="Mõisaküla"/><asula kood="5191" nimi="Mäeküla"/><asula kood="5328" nimi="Naartse küla"/><asula kood="5610" nimi="Oese küla"/><asula kood="5935" nimi="Pallika küla"/><asula kood="6113" nimi="Pereküla"/><asula kood="6278" nimi="Pitsalu küla"/><asula kood="6617" nimi="Pärnu-Jaagupi alev"/><asula kood="6646" nimi="Pööravere küla"/><asula kood="7061" nimi="Roodi küla"/><asula kood="7108" nimi="Rukkiküla"/><asula kood="7391" nimi="Salu küla"/><asula kood="7541" nimi="Sepaküla"/><asula kood="7739" nimi="Soosalu küla"/><asula kood="7912" nimi="Sõõrike küla"/><asula kood="8156" nimi="Tarva küla"/><asula kood="8510" nimi="Tõrdu küla"/><asula kood="8588" nimi="Tühjasma küla"/><asula kood="8843" nimi="Vahenurme küla"/><asula kood="8901" nimi="Vakalepa küla"/><asula kood="8947" nimi="Valistre küla"/><asula kood="9164" nimi="Vee küla"/></vald><vald kood="0213"><asula kood="1378" nimi="Arumetsa küla"/><asula kood="1957" nimi="Häädemeeste alevik"/><asula kood="2029" nimi="Ikla küla"/><asula kood="2124" nimi="Jaagupi küla"/><asula kood="2463" nimi="Kabli küla"/><asula kood="3508" nimi="Krundiküla"/><asula kood="4746" nimi="Majaka küla"/><asula kood="4805" nimi="Massiaru küla"/><asula kood="4908" nimi="Metsapoole küla"/><asula kood="5403" nimi="Nepste küla"/><asula kood="5706" nimi="Orajõe küla"/><asula kood="5984" nimi="Papisilla küla"/><asula kood="6103" nimi="Penu küla"/><asula kood="6420" nimi="Pulgoja küla"/><asula kood="6811" nimi="Rannametsa küla"/><asula kood="7706" nimi="Sooküla"/><asula kood="7717" nimi="Soometsa küla"/><asula kood="8340" nimi="Treimani küla"/><asula kood="8724" nimi="Urissaare küla"/><asula kood="8767" nimi="Uuemaa küla"/><asula kood="9521" nimi="Võidu küla"/></vald><vald kood="0303"><asula kood="4276" nimi="Lemsi küla"/><asula kood="4381" nimi="Linaküla"/><asula kood="7089" nimi="Rootsiküla"/><asula kood="7951" nimi="Sääre küla"/></vald><vald kood="0334"><asula kood="1591" nimi="Emmu küla"/><asula kood="1921" nimi="Hõbeda küla"/><asula kood="2102" nimi="Irta küla"/><asula kood="2106" nimi="Iska küla"/><asula kood="2192" nimi="Joonuse küla"/><asula kood="2316" nimi="Jänistvere küla"/><asula kood="2349" nimi="Järve küla"/><asula kood="2606" nimi="Kalli küla"/><asula kood="2732" nimi="Karinõmme küla"/><asula kood="2777" nimi="Karuba küla"/><asula kood="2999" nimi="Kibura küla"/><asula kood="3049" nimi="Kiisamaa küla"/><asula kood="3407" nimi="Koonga küla"/><asula kood="3524" nimi="Kuhu küla"/><asula kood="3654" nimi="Kurese küla"/><asula kood="8091" nimi="Kõima küla"/><asula kood="4611" nimi="Lõpe küla"/><asula kood="4742" nimi="Maikse küla"/><asula kood="4942" nimi="Mihkli küla"/><asula kood="5344" nimi="Naissoo küla"/><asula kood="5385" nimi="Nedrema küla"/><asula kood="5563" nimi="Nätsi küla"/><asula kood="5638" nimi="Oidrema küla"/><asula kood="5869" nimi="Paimvere küla"/><asula kood="5924" nimi="Palatu küla"/><asula kood="5990" nimi="Parasmaa küla"/><asula kood="6054" nimi="Peantse küla"/><asula kood="6200" nimi="Piisu küla"/><asula kood="6227" nimi="Pikavere küla"/><asula kood="6707" nimi="Rabavere küla"/><asula kood="7380" nimi="Salevere küla"/><asula kood="7702" nimi="Sookatse küla"/><asula kood="8092" nimi="Tamme küla"/><asula kood="8157" nimi="Tarva küla"/><asula kood="8478" nimi="Tõitse küla"/><asula kood="8712" nimi="Ura küla"/><asula kood="8722" nimi="Urita küla"/><asula kood="9134" nimi="Vastaba küla"/><asula kood="9192" nimi="Veltsa küla"/><asula kood="9544" nimi="Võitra küla"/><asula kood="9584" nimi="Võrungi küla"/><asula kood="9691" nimi="Õepa küla"/></vald><vald kood="0568"><asula kood="5864" nimi="Paikuse alev"/><asula kood="6518" nimi="Põlendmaa küla"/><asula kood="7536" nimi="Seljametsa küla"/><asula kood="7591" nimi="Silla küla"/><asula kood="8131" nimi="Tammuru küla"/><asula kood="9113" nimi="Vaskrääma küla"/></vald><vald kood="0710"><asula kood="2370" nimi="Jäärja küla"/><asula kood="2588" nimi="Kalita küla"/><asula kood="2631" nimi="Kamali küla"/><asula kood="2648" nimi="Kanaküla"/><asula kood="3083" nimi="Kilingi-Nõmme linn"/><asula kood="3929" nimi="Kärsu küla"/><asula kood="1421" nimi="Laiksaare küla"/><asula kood="4104" nimi="Lanksaare küla"/><asula kood="4235" nimi="Leipste küla"/><asula kood="4440" nimi="Lodja küla"/><asula kood="4782" nimi="Marana küla"/><asula kood="4787" nimi="Marina küla"/><asula kood="5085" nimi="Mustla küla"/><asula kood="5640" nimi="Oissaare küla"/><asula kood="6143" nimi="Pihke küla"/><asula kood="6919" nimi="Reinu küla"/><asula kood="7280" nimi="Saarde küla"/><asula kood="7560" nimi="Sigaste küla"/><asula kood="8083" nimi="Tali küla"/><asula kood="8214" nimi="Tihemetsa alevik"/><asula kood="8458" nimi="Tuuliku küla"/><asula kood="8486" nimi="Tõlla küla"/><asula kood="9166" nimi="Veelikse küla"/><asula kood="9297" nimi="Viisireiu küla"/><asula kood="9650" nimi="Väljaküla"/></vald><vald kood="0730"><asula kood="1510" nimi="Eametsa küla"/><asula kood="3046" nimi="Kiisa küla"/><asula kood="3084" nimi="Kilksama küla"/><asula kood="5468" nimi="Nurme küla"/><asula kood="6425" nimi="Pulli küla"/><asula kood="7237" nimi="Räägu küla"/><asula kood="7265" nimi="Rütavere küla"/><asula kood="7455" nimi="Sauga alevik"/><asula kood="8120" nimi="Tammiste küla"/><asula kood="8720" nimi="Urge küla"/><asula kood="8885" nimi="Vainu küla"/></vald><vald kood="0756"><asula kood="2062" nimi="Ilvese küla"/><asula kood="2132" nimi="Jaamaküla"/><asula kood="2572" nimi="Kalda küla"/><asula kood="3061" nimi="Kikepera küla"/><asula kood="3840" nimi="Kõveri küla"/><asula kood="4628" nimi="Lähkma küla"/><asula kood="4916" nimi="Metsaääre küla"/><asula kood="6705" nimi="Rabaküla"/><asula kood="7013" nimi="Ristiküla"/><asula kood="7463" nimi="Saunametsa küla"/><asula kood="7807" nimi="Surju küla"/></vald><vald kood="0848"><asula kood="4004" nimi="Laadi küla"/><asula kood="4232" nimi="Leina küla"/><asula kood="4284" nimi="Lepaküla"/><asula kood="4892" nimi="Metsaküla"/><asula kood="6194" nimi="Piirumi küla"/><asula kood="6924" nimi="Reiu küla"/><asula kood="8072" nimi="Tahkuranna küla"/><asula kood="8779" nimi="Uulu küla"/><asula kood="9539" nimi="Võiste alevik"/></vald><vald kood="0805"><asula kood="8316" nimi="Tootsi alev"/></vald><vald kood="0808"><asula kood="1091" nimi="Aesoo küla"/><asula kood="1574" nimi="Elbi küla"/><asula kood="2251" nimi="Jõesuu küla"/><asula kood="3077" nimi="Kildemaa küla"/><asula kood="3526" nimi="Kuiaru küla"/><asula kood="3812" nimi="Kõrsa küla"/><asula kood="4314" nimi="Levi küla"/><asula kood="4774" nimi="Mannare küla"/><asula kood="5036" nimi="Muraka küla"/><asula kood="5101" nimi="Muti küla"/><asula kood="5698" nimi="Oore küla"/><asula kood="6201" nimi="Piistaoja küla"/><asula kood="6792" nimi="Randivälja küla"/><asula kood="6986" nimi="Riisa küla"/><asula kood="5292" nimi="Rätsepa küla"/><asula kood="7529" nimi="Selja küla"/><asula kood="7996" nimi="Taali küla"/><asula kood="8269" nimi="Tohera küla"/><asula kood="8326" nimi="Tori alevik"/><asula kood="8730" nimi="Urumarja küla"/><asula kood="9560" nimi="Võlli küla"/></vald><vald kood="0826"><asula kood="1229" nimi="Alu küla"/><asula kood="1628" nimi="Ermistu küla"/><asula kood="2834" nimi="Kastna küla"/><asula kood="2893" nimi="Kavaru küla"/><asula kood="3109" nimi="Kiraste küla"/><asula kood="3784" nimi="Kõpu küla"/><asula kood="4109" nimi="Lao küla"/><asula kood="4617" nimi="Lõuka küla"/><asula kood="4771" nimi="Manija küla"/><asula kood="5264" nimi="Männikuste küla"/><asula kood="6082" nimi="Peerni küla"/><asula kood="6325" nimi="Pootsi küla"/><asula kood="6595" nimi="Päraküla"/><asula kood="6783" nimi="Rammuka küla"/><asula kood="6819" nimi="Ranniku küla"/><asula kood="7526" nimi="Seliste küla"/><asula kood="8475" nimi="Tõhela küla"/><asula kood="8488" nimi="Tõlli küla"/><asula kood="8540" nimi="Tõstamaa alevik"/><asula kood="9669" nimi="Värati küla"/></vald><vald kood="0863"><asula kood="1204" nimi="Allika küla"/><asula kood="1366" nimi="Aruküla"/><asula kood="1690" nimi="Haapsi küla"/><asula kood="1814" nimi="Helmküla"/><asula kood="1929" nimi="Hõbesalu küla"/><asula kood="2473" nimi="Kadaka küla"/><asula kood="2651" nimi="Kanamardi küla"/><asula kood="3006" nimi="Kidise küla"/><asula kood="3082" nimi="Kilgi küla"/><asula kood="3251" nimi="Koeri küla"/><asula kood="3445" nimi="Korju küla"/><asula kood="3593" nimi="Kulli küla"/><asula kood="3930" nimi="Käru küla"/><asula kood="4695" nimi="Maade küla"/><asula kood="4824" nimi="Matsi küla"/><asula kood="4881" nimi="Mereäärse küla"/><asula kood="5049" nimi="Muriste küla"/><asula kood="5173" nimi="Mõtsu küla"/><asula kood="5247" nimi="Mäliküla"/><asula kood="5530" nimi="Nõmme küla"/><asula kood="5776" nimi="Paadrema küla"/><asula kood="5801" nimi="Paatsalu küla"/><asula kood="6135" nimi="Piha küla"/><asula kood="6717" nimi="Raespa küla"/><asula kood="6722" nimi="Raheste küla"/><asula kood="6802" nimi="Rannaküla"/><asula kood="6865" nimi="Rauksi küla"/><asula kood="7259" nimi="Rädi küla"/><asula kood="7287" nimi="Saare küla"/><asula kood="7462" nimi="Saulepi küla"/><asula kood="7532" nimi="Selja küla"/><asula kood="7699" nimi="Sookalda küla"/><asula kood="8088" nimi="Tamba küla"/><asula kood="8220" nimi="Tiilima küla"/><asula kood="8541" nimi="Tõusi küla"/><asula kood="8577" nimi="Täpsi küla"/><asula kood="8893" nimi="Vaiste küla"/><asula kood="9061" nimi="Varbla küla"/><asula kood="9791" nimi="Õhu küla"/><asula kood="1603" nimi="Ännikse küla"/></vald><vald kood="0929"><asula kood="1215" nimi="Allikõnnu küla"/><asula kood="1237" nimi="Aluste küla"/><asula kood="2400" nimi="Kaansoo küla"/><asula kood="2486" nimi="Kadjaste küla"/><asula kood="2545" nimi="Kaisma küla"/><asula kood="2619" nimi="Kalmaru küla"/><asula kood="2969" nimi="Kergu küla"/><asula kood="3127" nimi="Kirikumõisa küla"/><asula kood="3219" nimi="Kobra küla"/><asula kood="3459" nimi="Kose küla"/><asula kood="3599" nimi="Kullimaa küla"/><asula kood="3666" nimi="Kurgja küla"/><asula kood="3771" nimi="Kõnnu küla"/><asula kood="4190" nimi="Leetva küla"/><asula kood="4586" nimi="Luuri küla"/><asula kood="4696" nimi="Lüüste küla"/><asula kood="4808" nimi="Massu küla"/><asula kood="4891" nimi="Metsaküla"/><asula kood="4913" nimi="Metsavere küla"/><asula kood="5072" nimi="Mustaru küla"/><asula kood="5185" nimi="Mädara küla"/><asula kood="5720" nimi="Oriküla"/><asula kood="6616" nimi="Pärnjõe küla"/><asula kood="6714" nimi="Rae küla"/><asula kood="6725" nimi="Rahkama küla"/><asula kood="6732" nimi="Rahnoja küla"/><asula kood="6921" nimi="Reinumurru küla"/><asula kood="7186" nimi="Rõusa küla"/><asula kood="7229" nimi="Rätsepa küla"/><asula kood="7406" nimi="Samliku küla"/><asula kood="7581" nimi="Sikana küla"/><asula kood="7661" nimi="Sohlu küla"/><asula kood="7838" nimi="Suurejõe küla"/><asula kood="7967" nimi="Säästla küla"/><asula kood="8055" nimi="Tagassaare küla"/><asula kood="8909" nimi="Vaki küla"/><asula kood="9199" nimi="Venekuusiku küla"/><asula kood="9237" nimi="Veskisoo küla"/><asula kood="9267" nimi="Vihtra küla"/><asula kood="9372" nimi="Viluvere küla"/><asula kood="9524" nimi="Võidula küla"/><asula kood="9526" nimi="Võiera küla"/><asula kood="9842" nimi="Ünnaste küla"/></vald><vald kood="0931"><asula kood="9663" nimi="Vändra alev"/></vald></maakond><maakond kood="0070"><vald kood="0240"><asula kood="1437" nimi="Atla küla"/><asula kood="1805" nimi="Helda küla"/><asula kood="1931" nimi="Hõreda küla"/><asula kood="1944" nimi="Härgla küla"/><asula kood="2169" nimi="Jaluse küla"/><asula kood="2223" nimi="Juuru alevik"/><asula kood="2330" nimi="Järlepa küla"/><asula kood="2569" nimi="Kalda küla"/><asula kood="4602" nimi="Lõiuse küla"/><asula kood="4733" nimi="Mahtra küla"/><asula kood="4741" nimi="Maidla küla"/><asula kood="5717" nimi="Orguse küla"/><asula kood="6274" nimi="Pirgu küla"/><asula kood="7319" nimi="Sadala küla"/><asula kood="9046" nimi="Vankse küla"/></vald><vald kood="0260"><asula kood="2346" nimi="Järvakandi alev"/></vald><vald kood="0277"><asula kood="2553" nimi="Kaiu alevik"/><asula kood="2742" nimi="Karitsa küla"/><asula kood="2845" nimi="Kasvandu küla"/><asula kood="3541" nimi="Kuimetsa küla"/><asula kood="5588" nimi="Oblu küla"/><asula kood="6525" nimi="Põlliku küla"/><asula kood="7840" nimi="Suurekivi küla"/><asula kood="8138" nimi="Tamsi küla"/><asula kood="8279" nimi="Tolla küla"/><asula kood="8305" nimi="Toomja küla"/><asula kood="8841" nimi="Vahastu küla"/><asula kood="8982" nimi="Vana-Kaiu küla"/><asula kood="9050" nimi="Vaopere küla"/></vald><vald kood="0292"><asula kood="1110" nimi="Ahekõnnu küla"/><asula kood="1550" nimi="Eidapere alevik"/><asula kood="1583" nimi="Ellamaa küla"/><asula kood="1684" nimi="Haakla küla"/><asula kood="1826" nimi="Hertu küla"/><asula kood="1830" nimi="Hiie küla"/><asula kood="2087" nimi="Ingliste küla"/><asula kood="2496" nimi="Kaerepere alevik"/><asula kood="2498" nimi="Kaerepere küla"/><asula kood="2567" nimi="Kalbu küla"/><asula kood="2835" nimi="Kastna küla"/><asula kood="2903" nimi="Keava alevik"/><asula kood="2924" nimi="Kehtna alevik"/><asula kood="2900" nimi="Kehtna-Nurme küla"/><asula kood="2952" nimi="Kenni küla"/><asula kood="3389" nimi="Koogimäe küla"/><asula kood="3391" nimi="Koogiste küla"/><asula kood="3606" nimi="Kumma küla"/><asula kood="3785" nimi="Kõrbja küla"/><asula kood="3846" nimi="Käbiküla"/><asula kood="3919" nimi="Kärpla küla"/><asula kood="4038" nimi="Laeste küla"/><asula kood="4084" nimi="Lalli küla"/><asula kood="4133" nimi="Lau küla"/><asula kood="4248" nimi="Lellapere küla"/><asula kood="2923" nimi="Lellapere-Nurme küla"/><asula kood="4250" nimi="Lelle alevik"/><asula kood="4392" nimi="Linnaaluste küla"/><asula kood="4476" nimi="Lokuta küla"/><asula kood="4914" nimi="Metsaääre küla"/><asula kood="5015" nimi="Mukri küla"/><asula kood="5334" nimi="Nadalama küla"/><asula kood="5498" nimi="Nõlva küla"/><asula kood="5618" nimi="Ohekatku küla"/><asula kood="5820" nimi="Pae küla"/><asula kood="5922" nimi="Palasi küla"/><asula kood="5947" nimi="Paluküla"/><asula kood="6530" nimi="Põllu küla"/><asula kood="6546" nimi="Põrsaku küla"/><asula kood="6937" nimi="Reonda küla"/><asula kood="7176" nimi="Rõue küla"/><asula kood="7298" nimi="Saarepõllu küla"/><asula kood="7353" nimi="Saksa küla"/><asula kood="7461" nimi="Saunaküla"/><asula kood="7531" nimi="Selja küla"/><asula kood="7681" nimi="Sooaluste küla"/><asula kood="8970" nimi="Valtu-Nurme küla"/><asula kood="9126" nimi="Vastja küla"/></vald><vald kood="0317"><asula kood="1021" nimi="Aandu küla"/><asula kood="1079" nimi="Adila küla"/><asula kood="1094" nimi="Aespa alevik"/><asula kood="1270" nimi="Angerja küla"/><asula kood="1714" nimi="Hageri alevik"/><asula kood="1715" nimi="Hageri küla"/><asula kood="2475" nimi="Kadaka küla"/><asula kood="3268" nimi="Kohila alev"/><asula kood="4453" nimi="Lohu küla"/><asula kood="4511" nimi="Loone küla"/><asula kood="4681" nimi="Lümandu küla"/><asula kood="4811" nimi="Masti küla"/><asula kood="5250" nimi="Mälivere küla"/><asula kood="5854" nimi="Pahkla küla"/><asula kood="6140" nimi="Pihali küla"/><asula kood="6368" nimi="Prillimäe alevik"/><asula kood="6415" nimi="Pukamäe küla"/><asula kood="6503" nimi="Põikma küla"/><asula kood="6710" nimi="Rabivere küla"/><asula kood="7085" nimi="Rootsi küla"/><asula kood="7402" nimi="Salutaguse küla"/><asula kood="7815" nimi="Sutlema küla"/><asula kood="8721" nimi="Urge küla"/><asula kood="8976" nimi="Vana-Aespa küla"/><asula kood="9341" nimi="Vilivere küla"/></vald><vald kood="0375"><asula kood="2228" nimi="Jõeküla"/><asula kood="3600" nimi="Kullimaa küla"/><asula kood="3735" nimi="Kõdu küla"/><asula kood="3854" nimi="Kädva küla"/><asula kood="3875" nimi="Kändliku küla"/><asula kood="3933" nimi="Käru alevik"/><asula kood="4157" nimi="Lauri küla"/><asula kood="4560" nimi="Lungu küla"/><asula kood="7683" nimi="Sonni küla"/></vald><vald kood="0504"><asula kood="1168" nimi="Alaküla"/><asula kood="1219" nimi="Altküla"/><asula kood="1324" nimi="Aravere küla"/><asula kood="1375" nimi="Aruküla"/><asula kood="1725" nimi="Haimre küla"/><asula kood="1834" nimi="Hiietse küla"/><asula kood="2081" nimi="Inda küla"/><asula kood="2147" nimi="Jaaniveski küla"/><asula kood="2254" nimi="Jõeääre küla"/><asula kood="2504" nimi="Kaguvere küla"/><asula kood="2668" nimi="Kangru küla"/><asula kood="2824" nimi="Kasti küla"/><asula kood="2980" nimi="Keskküla"/><asula kood="3037" nimi="Kiilaspere küla"/><asula kood="3080" nimi="Kilgi küla"/><asula kood="3146" nimi="Kirna küla"/><asula kood="3267" nimi="Kohatu küla"/><asula kood="3272" nimi="Kohtru küla"/><asula kood="3365" nimi="Koluta küla"/><asula kood="3380" nimi="Konuvere küla"/><asula kood="3627" nimi="Kunsu küla"/><asula kood="3813" nimi="Kõrtsuotsa küla"/><asula kood="3844" nimi="Käbiküla"/><asula kood="3908" nimi="Käriselja küla"/><asula kood="4143" nimi="Laukna küla"/><asula kood="4200" nimi="Leevre küla"/><asula kood="4302" nimi="Lestima küla"/><asula kood="4479" nimi="Lokuta küla"/><asula kood="4503" nimi="Loodna küla"/><asula kood="4554" nimi="Luiste küla"/><asula kood="4683" nimi="Lümandu küla"/><asula kood="8232" nimi="Maidla küla"/><asula kood="4915" nimi="Metsaääre küla"/><asula kood="4919" nimi="Metsküla"/><asula kood="4967" nimi="Moka küla"/><asula kood="5133" nimi="Mõisamaa küla"/><asula kood="5162" nimi="Mõraste küla"/><asula kood="5246" nimi="Mäliste küla"/><asula kood="5262" nimi="Männiku küla"/><asula kood="5280" nimi="Märjamaa alev"/><asula kood="5348" nimi="Naistevalla küla"/><asula kood="5351" nimi="Napanurga küla"/><asula kood="5469" nimi="Nurme küla"/><asula kood="5482" nimi="Nurtu-Nõlva küla"/><asula kood="5517" nimi="Nõmmeotsa küla"/><asula kood="5561" nimi="Nääri küla"/><asula kood="5631" nimi="Ohukotsu küla"/><asula kood="5655" nimi="Ojaäärse küla"/><asula kood="5711" nimi="Orgita küla"/><asula kood="5779" nimi="Paaduotsa küla"/><asula kood="5826" nimi="Paeküla"/><asula kood="5875" nimi="Paisumaa küla"/><asula kood="5878" nimi="Pajaka küla"/><asula kood="6438" nimi="Purga küla"/><asula kood="6523" nimi="Põlli küla"/><asula kood="6624" nimi="Päädeva küla"/><asula kood="6800" nimi="Rangu küla"/><asula kood="6832" nimi="Rassiotsa küla"/><asula kood="7003" nimi="Ringuta küla"/><asula kood="7015" nimi="Risu-Suurküla"/><asula kood="7132" nimi="Russalu küla"/><asula kood="7622" nimi="Sipa küla"/><asula kood="7725" nimi="Sooniste küla"/><asula kood="7740" nimi="Soosalu küla"/><asula kood="7792" nimi="Sulu küla"/><asula kood="7853" nimi="Suurküla"/><asula kood="7890" nimi="Sõmeru küla"/><asula kood="7909" nimi="Sõtke küla"/><asula kood="8182" nimi="Teenuse küla"/><asula kood="8283" nimi="Tolli küla"/><asula kood="8717" nimi="Urevere küla"/><asula kood="8882" nimi="Vaimõisa küla"/><asula kood="8939" nimi="Valgu küla"/><asula kood="9016" nimi="Vanamõisa küla"/><asula kood="8997" nimi="Vana-Nurtu küla"/><asula kood="9063" nimi="Varbola küla"/><asula kood="9189" nimi="Velise küla"/><asula kood="9187" nimi="Velisemõisa küla"/><asula kood="9190" nimi="Velise-Nõlva küla"/><asula kood="9228" nimi="Veski küla"/><asula kood="9359" nimi="Vilta küla"/><asula kood="9493" nimi="Võeva küla"/><asula kood="9829" nimi="Ülejõe küla"/></vald><vald kood="0654"><asula kood="2161" nimi="Jalase küla"/><asula kood="2530" nimi="Kaigepere küla"/><asula kood="2955" nimi="Keo küla"/><asula kood="3294" nimi="Koikse küla"/><asula kood="3831" nimi="Kõrvetaguse küla"/><asula kood="4413" nimi="Lipa küla"/><asula kood="4416" nimi="Lipametsa küla"/><asula kood="4443" nimi="Loe küla"/><asula kood="4614" nimi="Lõpemetsa küla"/><asula kood="4924" nimi="Metsküla"/><asula kood="5516" nimi="Nõmmemetsa küla"/><asula kood="5522" nimi="Nõmmküla"/><asula kood="6445" nimi="Purku küla"/><asula kood="6533" nimi="Põlma küla"/><asula kood="6662" nimi="Pühatu küla"/><asula kood="6719" nimi="Raela küla"/><asula kood="6758" nimi="Raikküla"/><asula kood="6979" nimi="Riidaku küla"/><asula kood="8093" nimi="Tamme küla"/><asula kood="8677" nimi="Ummaru küla"/><asula kood="8838" nimi="Vahakõnnu küla"/><asula kood="8961" nimi="Valli küla"/></vald><vald kood="0669"><asula kood="1230" nimi="Alu alevik"/><asula kood="1232" nimi="Alu-Metsküla"/><asula kood="1316" nimi="Aranküla"/><asula kood="1716" nimi="Hagudi alevik"/><asula kood="1717" nimi="Hagudi küla"/><asula kood="2020" nimi="Iira küla"/><asula kood="2216" nimi="Juula küla"/><asula kood="2580" nimi="Kalevi küla"/><asula kood="2933" nimi="Kelba küla"/><asula kood="3242" nimi="Kodila küla"/><asula kood="3240" nimi="Kodila-Metsküla"/><asula kood="3283" nimi="Koigi küla"/><asula kood="3569" nimi="Kuku küla"/><asula kood="3720" nimi="Kuusiku alevik"/><asula kood="3724" nimi="Kuusiku-Nõmme küla"/><asula kood="3799" nimi="Kõrgu küla"/><asula kood="4421" nimi="Lipstu küla"/><asula kood="4728" nimi="Mahlamäe küla"/><asula kood="5126" nimi="Mõisaaseme küla"/><asula kood="5254" nimi="Mällu küla"/><asula kood="5520" nimi="Nõmme küla"/><asula kood="5608" nimi="Oela küla"/><asula kood="5634" nimi="Ohulepa küla"/><asula kood="5687" nimi="Oola küla"/><asula kood="5911" nimi="Palamulla küla"/><asula kood="6443" nimi="Purila küla"/><asula kood="6772" nimi="Raka küla"/><asula kood="6826" nimi="Rapla linn"/><asula kood="6954" nimi="Ridaküla"/><asula kood="7255" nimi="Röa küla"/><asula kood="7518" nimi="Seli küla"/><asula kood="5470" nimi="Seli-Nurme küla"/><asula kood="7586" nimi="Sikeldi küla"/><asula kood="7796" nimi="Sulupere küla"/><asula kood="8139" nimi="Tapupere küla"/><asula kood="8441" nimi="Tuti küla"/><asula kood="8518" nimi="Tõrma küla"/><asula kood="8788" nimi="Uusküla"/><asula kood="8971" nimi="Valtu küla"/><asula kood="4318" nimi="Väljataguse küla"/><asula kood="9729" nimi="Äherdi küla"/><asula kood="9831" nimi="Ülejõe küla"/></vald><vald kood="0884"><asula kood="1319" nimi="Araste küla"/><asula kood="1478" nimi="Avaste küla"/><asula kood="2296" nimi="Jädivere küla"/><asula kood="2883" nimi="Kausi küla"/><asula kood="2990" nimi="Kesu küla"/><asula kood="3175" nimi="Kivi-Vigala küla"/><asula kood="3307" nimi="Kojastu küla"/><asula kood="3373" nimi="Konnapere küla"/><asula kood="3662" nimi="Kurevere küla"/><asula kood="4221" nimi="Leibre küla"/><asula kood="4647" nimi="Läti küla"/><asula kood="4775" nimi="Manni küla"/><asula kood="5353" nimi="Naravere küla"/><asula kood="5611" nimi="Oese küla"/><asula kood="5653" nimi="Ojapere küla"/><asula kood="5921" nimi="Palase küla"/><asula kood="5928" nimi="Paljasmaa küla"/><asula kood="5937" nimi="Pallika küla"/><asula kood="6629" nimi="Päärdu küla"/><asula kood="7248" nimi="Rääski küla"/><asula kood="7946" nimi="Sääla küla"/><asula kood="8208" nimi="Tiduvere küla"/><asula kood="8509" nimi="Tõnumaa küla"/><asula kood="8834" nimi="Vaguja küla"/><asula kood="9028" nimi="Vanamõisa küla"/><asula kood="9007" nimi="Vana-Vigala küla"/><asula kood="9666" nimi="Vängla küla"/></vald></maakond><maakond kood="0074"><vald kood="0301"><asula kood="1054" nimi="Abaja küla"/><asula kood="1067" nimi="Abula küla"/><asula kood="2599" nimi="Kallaste küla"/><asula kood="2624" nimi="Kalmu küla"/><asula kood="1498" nimi="Karujärve küla"/><asula kood="2922" nimi="Kehila küla"/><asula kood="3012" nimi="Kihelkonna alevik"/><asula kood="3045" nimi="Kiirassaare küla"/><asula kood="3483" nimi="Kotsma küla"/><asula kood="3632" nimi="Kuralase küla"/><asula kood="3643" nimi="Kuremetsa küla"/><asula kood="3661" nimi="Kurevere küla"/><asula kood="3712" nimi="Kuumi küla"/><asula kood="3722" nimi="Kuusiku küla"/><asula kood="3817" nimi="Kõruse küla"/><asula kood="3843" nimi="Kõõru küla"/><asula kood="4355" nimi="Liiva küla"/><asula kood="4509" nimi="Loona küla"/><asula kood="4649" nimi="Lätiniidi küla"/><asula kood="4653" nimi="Läägi küla"/><asula kood="4886" nimi="Metsaküla"/><asula kood="5209" nimi="Mäebe küla"/><asula kood="5388" nimi="Neeme küla"/><asula kood="5592" nimi="Odalätsi küla"/><asula kood="5657" nimi="Oju küla"/><asula kood="5890" nimi="Pajumõisa küla"/><asula kood="6137" nimi="Pidula küla"/><asula kood="6804" nimi="Rannaküla"/><asula kood="7088" nimi="Rootsiküla"/><asula kood="7545" nimi="Sepise küla"/><asula kood="8049" nimi="Tagamõisa küla"/><asula kood="8099" nimi="Tammese küla"/><asula kood="8270" nimi="Tohku küla"/><asula kood="8692" nimi="Undva küla"/><asula kood="8870" nimi="Vaigu küla"/><asula kood="9089" nimi="Varkja küla"/><asula kood="9158" nimi="Vedruka küla"/><asula kood="9170" nimi="Veere küla"/><asula kood="9315" nimi="Viki küla"/><asula kood="9357" nimi="Vilsandi küla"/><asula kood="9383" nimi="Virita küla"/><asula kood="9849" nimi="Üru küla"/></vald><vald kood="0386"><asula kood="1052" nimi="Aaviku küla"/><asula kood="1429" nimi="Asva küla"/><asula kood="1455" nimi="Audla küla"/><asula kood="2225" nimi="Jõe küla"/><asula kood="2517" nimi="Kahtla küla"/><asula kood="2697" nimi="Kapra küla"/><asula kood="3098" nimi="Kingli küla"/><asula kood="3744" nimi="Kõiguste küla"/><asula kood="3882" nimi="Käo küla"/><asula kood="4054" nimi="Laheküla"/><asula kood="4073" nimi="Laimjala küla"/><asula kood="5087" nimi="Mustla küla"/><asula kood="5220" nimi="Mägi-Kurdla küla"/><asula kood="5510" nimi="Nõmme küla"/><asula kood="5849" nimi="Pahavalla küla"/><asula kood="5882" nimi="Paju-Kurdla küla"/><asula kood="6799" nimi="Randvere küla"/><asula kood="6806" nimi="Rannaküla"/><asula kood="6960" nimi="Ridala küla"/><asula kood="7107" nimi="Ruhve küla"/><asula kood="7288" nimi="Saareküla"/><asula kood="7291" nimi="Saaremetsa küla"/><asula kood="9360" nimi="Viltina küla"/><asula kood="9854" nimi="Üüvere küla"/></vald><vald kood="0403"><asula kood="1272" nimi="Angla küla"/><asula kood="1364" nimi="Aru küla"/><asula kood="1389" nimi="Aruste küla"/><asula kood="1424" nimi="Asuka küla"/><asula kood="1836" nimi="Hiievälja küla"/><asula kood="2274" nimi="Jõiste küla"/><asula kood="2543" nimi="Kaisa küla"/><asula kood="2747" nimi="Karja küla"/><asula kood="3279" nimi="Koiduvälja küla"/><asula kood="3292" nimi="Koikla küla"/><asula kood="3437" nimi="Kopli küla"/><asula kood="3989" nimi="Külma küla"/><asula kood="4138" nimi="Laugu küla"/><asula kood="4237" nimi="Leisi alevik"/><asula kood="4360" nimi="Liiva küla"/><asula kood="4395" nimi="Linnaka küla"/><asula kood="4409" nimi="Linnuse küla"/><asula kood="4581" nimi="Luulupe küla"/><asula kood="4615" nimi="Lõpi küla"/><asula kood="4862" nimi="Meiuste küla"/><asula kood="4917" nimi="Metsaääre küla"/><asula kood="4922" nimi="Metsküla"/><asula kood="4984" nimi="Moosi küla"/><asula kood="5012" nimi="Mujaste küla"/><asula kood="5050" nimi="Murika küla"/><asula kood="5287" nimi="Mätja küla"/><asula kood="5374" nimi="Nava küla"/><asula kood="5414" nimi="Nihatu küla"/><asula kood="5472" nimi="Nurme küla"/><asula kood="5519" nimi="Nõmme küla"/><asula kood="5644" nimi="Oitme küla"/><asula kood="5792" nimi="Paaste küla"/><asula kood="5965" nimi="Pamma küla"/><asula kood="5967" nimi="Pammana küla"/><asula kood="5994" nimi="Parasmetsa küla"/><asula kood="6077" nimi="Peederga küla"/><asula kood="6312" nimi="Poka küla"/><asula kood="6448" nimi="Purtsa küla"/><asula kood="6618" nimi="Pärsama küla"/><asula kood="6639" nimi="Pöitse küla"/><asula kood="6842" nimi="Ratla küla"/><asula kood="7051" nimi="Roobaka küla"/><asula kood="7234" nimi="Räägi küla"/><asula kood="7537" nimi="Selja küla"/><asula kood="7658" nimi="Soela küla"/><asula kood="8153" nimi="Tareste küla"/><asula kood="8230" nimi="Tiitsuotsa küla"/><asula kood="8347" nimi="Triigi küla"/><asula kood="8443" nimi="Tutku küla"/><asula kood="8516" nimi="Tõre küla"/><asula kood="8587" nimi="Täätsi küla"/><asula kood="9226" nimi="Veske küla"/><asula kood="9293" nimi="Viira küla"/><asula kood="9799" nimi="Õeste küla"/></vald><vald kood="0433"><asula kood="1064" nimi="Abruka küla"/><asula kood="1268" nimi="Anepesa küla"/><asula kood="1280" nimi="Anijala küla"/><asula kood="1300" nimi="Ansi küla"/><asula kood="1313" nimi="Arandi küla"/><asula kood="1416" nimi="Aste alevik"/><asula kood="1417" nimi="Aste küla"/><asula kood="1426" nimi="Asuküla"/><asula kood="1436" nimi="Atla küla"/><asula kood="1466" nimi="Aula-Vintri küla"/><asula kood="1470" nimi="Austla küla"/><asula kood="1530" nimi="Eeriksaare küla"/><asula kood="1553" nimi="Eikla küla"/><asula kood="1599" nimi="Endla küla"/><asula kood="1686" nimi="Haamse küla"/><asula kood="1731" nimi="Hakjala küla"/><asula kood="1850" nimi="Himmiste küla"/><asula kood="1874" nimi="Hirmuste küla"/><asula kood="1965" nimi="Hübja küla"/><asula kood="2097" nimi="Irase küla"/><asula kood="2200" nimi="Jootme küla"/><asula kood="2224" nimi="Jõe küla"/><asula kood="2239" nimi="Jõempa küla"/><asula kood="2260" nimi="Jõgela küla"/><asula kood="3122" nimi="Kaarma-Kirikuküla"/><asula kood="2414" nimi="Kaarma küla"/><asula kood="2416" nimi="Kaarmise küla"/><asula kood="2548" nimi="Kaisvere küla"/><asula kood="2662" nimi="Kandla küla"/><asula kood="2705" nimi="Karala küla"/><asula kood="2722" nimi="Karida küla"/><asula kood="2823" nimi="Kasti küla"/><asula kood="2857" nimi="Kaubi küla"/><asula kood="2935" nimi="Kellamäe küla"/><asula kood="2982" nimi="Keskranna küla"/><asula kood="2985" nimi="Keskvere küla"/><asula kood="3106" nimi="Kipi küla"/><asula kood="3111" nimi="Kiratsi küla"/><asula kood="3258" nimi="Kogula küla"/><asula kood="3274" nimi="Koidu küla"/><asula kood="3278" nimi="Koidula küla"/><asula kood="3299" nimi="Koimla küla"/><asula kood="3320" nimi="Koki küla"/><asula kood="3431" nimi="Koovi küla"/><asula kood="3482" nimi="Kotlandi küla"/><asula kood="3519" nimi="Kudjape alevik"/><asula kood="3550" nimi="Kuke küla"/><asula kood="3615" nimi="Kungla küla"/><asula kood="3715" nimi="Kuuse küla"/><asula kood="3726" nimi="Kuusnõmme küla"/><asula kood="3802" nimi="Kõrkküla"/><asula kood="3860" nimi="Käesla küla"/><asula kood="3870" nimi="Käku küla"/><asula kood="3896" nimi="Kärdu küla"/><asula kood="3916" nimi="Kärla alevik"/><asula kood="3123" nimi="Kärla-Kirikuküla"/><asula kood="3598" nimi="Kärla-Kulli küla"/><asula kood="4007" nimi="Laadjala küla"/><asula kood="4053" nimi="Laheküla"/><asula kood="4110" nimi="Laoküla"/><asula kood="4180" nimi="Leedri küla"/><asula kood="4368" nimi="Lilbi küla"/><asula kood="3601" nimi="Lümanda-Kulli küla"/><asula kood="4679" nimi="Lümanda küla"/><asula kood="4754" nimi="Maleva küla"/><asula kood="4834" nimi="Meedla küla"/><asula kood="4885" nimi="Metsaküla"/><asula kood="4907" nimi="Metsapere küla"/><asula kood="5025" nimi="Mullutu küla"/><asula kood="5044" nimi="Muratsi küla"/><asula kood="5139" nimi="Mõisaküla"/><asula kood="5154" nimi="Mõnnuste küla"/><asula kood="5256" nimi="Mändjala küla"/><asula kood="5284" nimi="Mätasselja küla"/><asula kood="5361" nimi="Nasva alevik"/><asula kood="5509" nimi="Nõmme küla"/><asula kood="5528" nimi="Nõmpa küla"/><asula kood="5836" nimi="Paevere küla"/><asula kood="5867" nimi="Paiküla"/><asula kood="5868" nimi="Paimala küla"/><asula kood="6010" nimi="Parila küla"/><asula kood="6169" nimi="Piila küla"/><asula kood="6343" nimi="Praakli küla"/><asula kood="6531" nimi="Põlluküla"/><asula kood="6562" nimi="Pähkla küla"/><asula kood="6614" nimi="Pärni küla"/><asula kood="6798" nimi="Randvere küla"/><asula kood="6997" nimi="Riksu küla"/><asula kood="7340" nimi="Saia küla"/><asula kood="7473" nimi="Sauvere küla"/><asula kood="7543" nimi="Sepa küla"/><asula kood="7584" nimi="Sikassaare küla"/><asula kood="7885" nimi="Sõmera küla"/><asula kood="8076" nimi="Tahula küla"/><asula kood="8127" nimi="Tamsalu küla"/><asula kood="8155" nimi="Taritu küla"/><asula kood="8489" nimi="Tõlli küla"/><asula kood="8517" nimi="Tõrise küla"/><asula kood="8526" nimi="Tõru küla"/><asula kood="8625" nimi="Uduvere küla"/><asula kood="8662" nimi="Ulje küla"/><asula kood="8697" nimi="Unimäe küla"/><asula kood="8708" nimi="Upa küla"/><asula kood="8859" nimi="Vahva küla"/><asula kood="8898" nimi="Vaivere küla"/><asula kood="8990" nimi="Vana-Lahetaguse küla"/><asula kood="9045" nimi="Vantri küla"/><asula kood="9093" nimi="Varpe küla"/><asula kood="9145" nimi="Vatsküla"/><asula kood="9197" nimi="Vendise küla"/><asula kood="9206" nimi="Vennati küla"/><asula kood="9241" nimi="Vestla küla"/><asula kood="9275" nimi="Viidu küla"/><asula kood="9284" nimi="Viira küla"/><asula kood="9800" nimi="Õha küla"/></vald><vald kood="0478"><asula kood="1196" nimi="Aljava küla"/><asula kood="1808" nimi="Hellamaa küla"/><asula kood="1990" nimi="Igaküla"/><asula kood="2597" nimi="Kallaste küla"/><asula kood="2691" nimi="Kantsi küla"/><asula kood="2695" nimi="Kapi küla"/><asula kood="2987" nimi="Kesse küla"/><asula kood="3260" nimi="Koguva küla"/><asula kood="3549" nimi="Kuivastu küla"/><asula kood="3983" nimi="Külasema küla"/><asula kood="4058" nimi="Laheküla"/><asula kood="4083" nimi="Lalli küla"/><asula kood="4189" nimi="Leeskopa küla"/><asula kood="4215" nimi="Lehtmetsa küla"/><asula kood="4292" nimi="Lepiku küla"/><asula kood="4311" nimi="Levalõpme küla"/><asula kood="4353" nimi="Liiva küla"/><asula kood="4407" nimi="Linnuse küla"/><asula kood="4595" nimi="Lõetsa küla"/><asula kood="5120" nimi="Mõega küla"/><asula kood="5130" nimi="Mõisaküla"/><asula kood="5243" nimi="Mäla küla"/><asula kood="5370" nimi="Nautse küla"/><asula kood="5475" nimi="Nurme küla"/><asula kood="5524" nimi="Nõmmküla"/><asula kood="5639" nimi="Oina küla"/><asula kood="5831" nimi="Paenase küla"/><asula kood="5931" nimi="Pallasmaa küla"/><asula kood="6184" nimi="Piiri küla"/><asula kood="6638" nimi="Põitse küla"/><asula kood="6556" nimi="Pädaste küla"/><asula kood="6559" nimi="Päelda küla"/><asula kood="6598" nimi="Pärase küla"/><asula kood="6715" nimi="Raegma küla"/><asula kood="6817" nimi="Rannaküla"/><asula kood="6861" nimi="Raugi küla"/><asula kood="6888" nimi="Rebaski küla"/><asula kood="6965" nimi="Ridasi küla"/><asula kood="7006" nimi="Rinsi küla"/><asula kood="7093" nimi="Rootsivere küla"/><asula kood="7223" nimi="Rässa küla"/><asula kood="7601" nimi="Simisti küla"/><asula kood="7724" nimi="Soonda küla"/><asula kood="7847" nimi="Suuremõisa küla"/><asula kood="8136" nimi="Tamse küla"/><asula kood="8418" nimi="Tupenurme küla"/><asula kood="8440" nimi="Tusti küla"/><asula kood="8851" nimi="Vahtraste küla"/><asula kood="9027" nimi="Vanamõisa küla"/><asula kood="9285" nimi="Viira küla"/><asula kood="9531" nimi="Võiküla"/><asula kood="9554" nimi="Võlla küla"/></vald><vald kood="0483"><asula kood="2178" nimi="Jauni küla"/><asula kood="2324" nimi="Järise küla"/><asula kood="3152" nimi="Kiruma küla"/><asula kood="3521" nimi="Kugalepa küla"/><asula kood="3967" nimi="Küdema küla"/><asula kood="4345" nimi="Liiküla"/><asula kood="4362" nimi="Liiva küla"/><asula kood="4888" nimi="Merise küla"/><asula kood="5080" nimi="Mustjala küla"/><asula kood="5428" nimi="Ninase küla"/><asula kood="5623" nimi="Ohtja küla"/><asula kood="5799" nimi="Paatsa küla"/><asula kood="5847" nimi="Pahapilli küla"/><asula kood="5973" nimi="Panga küla"/><asula kood="6734" nimi="Rahtla küla"/><asula kood="7513" nimi="Selgase küla"/><asula kood="7596" nimi="Silla küla"/><asula kood="8053" nimi="Tagaranna küla"/><asula kood="8406" nimi="Tuiu küla"/><asula kood="9013" nimi="Vanakubja küla"/><asula kood="9497" nimi="Võhma küla"/></vald><vald kood="0550"><asula kood="1348" nimi="Ariste küla"/><asula kood="1357" nimi="Arju küla"/><asula kood="1695" nimi="Haapsu küla"/><asula kood="1853" nimi="Hindu küla"/><asula kood="2074" nimi="Imavere küla"/><asula kood="2148" nimi="Jaani küla"/><asula kood="2356" nimi="Järveküla"/><asula kood="2620" nimi="Kalma küla"/><asula kood="2713" nimi="Kareda küla"/><asula kood="2888" nimi="Kavandi küla"/><asula kood="3625" nimi="Kuninguste küla"/><asula kood="3747" nimi="Kõinastu küla"/><asula kood="4059" nimi="Laheküla"/><asula kood="4335" nimi="Liigalaskma küla"/><asula kood="4363" nimi="Liiva küla"/><asula kood="4712" nimi="Maasi küla"/><asula kood="4855" nimi="Mehama küla"/><asula kood="5214" nimi="Mäeküla"/><asula kood="5723" nimi="Orinõmme küla"/><asula kood="5725" nimi="Orissaare alevik"/><asula kood="6427" nimi="Pulli küla"/><asula kood="6542" nimi="Põripõllu küla"/><asula kood="6794" nimi="Randküla"/><asula kood="6810" nimi="Rannaküla"/><asula kood="6862" nimi="Raugu küla"/><asula kood="7345" nimi="Saikla küla"/><asula kood="7403" nimi="Salu küla"/><asula kood="7826" nimi="Suur-Pahila küla"/><asula kood="7827" nimi="Suur-Rahula küla"/><asula kood="7998" nimi="Taaliku küla"/><asula kood="8059" nimi="Tagavere küla"/><asula kood="8412" nimi="Tumala küla"/><asula kood="9504" nimi="Võhma küla"/><asula kood="9629" nimi="Väike-Pahila küla"/><asula kood="9632" nimi="Väike-Rahula küla"/><asula kood="9657" nimi="Väljaküla"/><asula kood="9804" nimi="Ööriku küla"/></vald><vald kood="0592"><asula kood="1564" nimi="Eiste küla"/><asula kood="1606" nimi="Ennu küla"/><asula kood="1712" nimi="Haeska küla"/><asula kood="1939" nimi="Hämmelepa küla"/><asula kood="2022" nimi="Iilaste küla"/><asula kood="2056" nimi="Ilpla küla"/><asula kood="2398" nimi="Kaali küla"/><asula kood="2538" nimi="Kailuka küla"/><asula kood="2672" nimi="Kangrusselja küla"/><asula kood="3138" nimi="Kiritu küla"/><asula kood="3719" nimi="Kuusiku küla"/><asula kood="3757" nimi="Kõljala küla"/><asula kood="3773" nimi="Kõnnu küla"/><asula kood="4061" nimi="Laheküla"/><asula kood="4233" nimi="Leina küla"/><asula kood="4365" nimi="Liiva küla"/><asula kood="4366" nimi="Liiva-Putla küla"/><asula kood="4803" nimi="Masa küla"/><asula kood="4826" nimi="Matsiranna küla"/><asula kood="4894" nimi="Metsaküla"/><asula kood="5089" nimi="Mustla küla"/><asula kood="5560" nimi="Nässuma küla"/><asula kood="6153" nimi="Pihtla küla"/><asula kood="6653" nimi="Püha küla"/><asula kood="6730" nimi="Rahniku küla"/><asula kood="6818" nimi="Rannaküla"/><asula kood="6899" nimi="Reeküla"/><asula kood="6930" nimi="Reo küla"/><asula kood="7200" nimi="Räimaste küla"/><asula kood="7330" nimi="Sagariste küla"/><asula kood="7375" nimi="Salavere küla"/><asula kood="7413" nimi="Sandla küla"/><asula kood="7450" nimi="Sauaru küla"/><asula kood="7451" nimi="Saue-Putla küla"/><asula kood="7546" nimi="Sepa küla"/><asula kood="7822" nimi="Sutu küla"/><asula kood="7834" nimi="Suure-Rootsi küla"/><asula kood="8493" nimi="Tõlluste küla"/><asula kood="9022" nimi="Vanamõisa küla"/><asula kood="9634" nimi="Väike-Rootsi küla"/><asula kood="9659" nimi="Väljaküla"/></vald><vald kood="0634"><asula kood="1337" nimi="Ardla küla"/><asula kood="1346" nimi="Are küla"/><asula kood="2103" nimi="Iruste küla"/><asula kood="2522" nimi="Kahutsi küla"/><asula kood="2557" nimi="Kakuna küla"/><asula kood="2878" nimi="Kanissaare küla"/><asula kood="2988" nimi="Keskvere küla"/><asula kood="3284" nimi="Koigi küla"/><asula kood="3807" nimi="Kõrkvere küla"/><asula kood="3922" nimi="Kärneri küla"/><asula kood="3964" nimi="Kübassaare küla"/><asula kood="4238" nimi="Leisi küla"/><asula kood="4310" nimi="Levala küla"/><asula kood="4909" nimi="Metsara küla"/><asula kood="5006" nimi="Mui küla"/><asula kood="5034" nimi="Muraja küla"/><asula kood="5390" nimi="Neemi küla"/><asula kood="5401" nimi="Nenu küla"/><asula kood="5757" nimi="Oti küla"/><asula kood="6418" nimi="Puka küla"/><asula kood="6635" nimi="Pöide küla"/><asula kood="6913" nimi="Reina küla"/><asula kood="7799" nimi="Sundimetsa küla"/><asula kood="8084" nimi="Talila küla"/><asula kood="8336" nimi="Tornimäe küla"/><asula kood="8652" nimi="Ula küla"/><asula kood="8693" nimi="Unguma küla"/><asula kood="8771" nimi="Uuemõisa küla"/><asula kood="9171" nimi="Veere küla"/><asula kood="9658" nimi="Välta küla"/></vald><vald kood="0689"><asula kood="7105" nimi="Ruhnu küla"/></vald><vald kood="0721"><asula kood="1297" nimi="Anseküla"/><asula kood="1514" nimi="Easte küla"/><asula kood="1855" nimi="Hindu küla"/><asula kood="2066" nimi="Imara küla"/><asula kood="2366" nimi="Järve küla"/><asula kood="2541" nimi="Kaimri küla"/><asula kood="2863" nimi="Kaugatoma küla"/><asula kood="4057" nimi="Lahetaguse küla"/><asula kood="4129" nimi="Lassi küla"/><asula kood="4604" nimi="Lõmala küla"/><asula kood="4608" nimi="Lõu küla"/><asula kood="4636" nimi="Länga küla"/><asula kood="4661" nimi="Läätsa küla"/><asula kood="4899" nimi="Metsalõuka küla"/><asula kood="5140" nimi="Mõisaküla"/><asula kood="5308" nimi="Möldri küla"/><asula kood="6745" nimi="Rahuste küla"/><asula kood="7387" nimi="Salme alevik"/><asula kood="7861" nimi="Suurna küla"/><asula kood="8185" nimi="Tehumardi küla"/><asula kood="8227" nimi="Tiirimetsa küla"/><asula kood="8298" nimi="Toomalõuka küla"/><asula kood="8649" nimi="Ula küla"/><asula kood="9378" nimi="Vintri küla"/><asula kood="9855" nimi="Üüdibe küla"/></vald><vald kood="0807"><asula kood="1940" nimi="Hänga küla"/><asula kood="2014" nimi="Iide küla"/><asula kood="2310" nimi="Jämaja küla"/><asula kood="2442" nimi="Kaavi küla"/><asula kood="2720" nimi="Kargi küla"/><asula kood="2785" nimi="Karuste küla"/><asula kood="2874" nimi="Kaunispe küla"/><asula kood="4009" nimi="Laadla küla"/><asula kood="4385" nimi="Lindmetsa küla"/><asula kood="4609" nimi="Lõupõllu küla"/><asula kood="4666" nimi="Läbara küla"/><asula kood="4675" nimi="Lülle küla"/><asula kood="4700" nimi="Maantee küla"/><asula kood="5134" nimi="Mõisaküla"/><asula kood="5155" nimi="Mõntu küla"/><asula kood="5190" nimi="Mäebe küla"/><asula kood="5282" nimi="Mässa küla"/><asula kood="5621" nimi="Ohessaare küla"/><asula kood="7689" nimi="Soodevahe küla"/><asula kood="7950" nimi="Sääre küla"/><asula kood="8128" nimi="Tammuna küla"/><asula kood="8600" nimi="Türju küla"/></vald><vald kood="0858"><asula kood="1349" nimi="Ariste küla"/><asula kood="2215" nimi="Jursi küla"/><asula kood="2231" nimi="Jõelepa küla"/><asula kood="2292" nimi="Jööri küla"/><asula kood="2594" nimi="Kalju küla"/><asula kood="2603" nimi="Kallemäe küla"/><asula kood="2605" nimi="Kalli küla"/><asula kood="3259" nimi="Kogula küla"/><asula kood="3325" nimi="Koksi küla"/><asula kood="3544" nimi="Kuiste küla"/><asula kood="3614" nimi="Kungla küla"/><asula kood="3774" nimi="Kõnnu küla"/><asula kood="3800" nimi="Kõriska küla"/><asula kood="4665" nimi="Lööne küla"/><asula kood="5265" nimi="Männiku küla"/><asula kood="5476" nimi="Nurme küla"/><asula kood="5612" nimi="Oessaare küla"/><asula kood="6534" nimi="Põlluküla"/><asula kood="6737" nimi="Rahu küla"/><asula kood="6820" nimi="Rannaküla"/><asula kood="7258" nimi="Röösa küla"/><asula kood="7351" nimi="Sakla küla"/><asula kood="7568" nimi="Siiksaare küla"/><asula kood="8426" nimi="Turja küla"/><asula kood="8502" nimi="Tõnija küla"/><asula kood="8683" nimi="Undimäe küla"/><asula kood="8951" nimi="Valjala alevik"/><asula kood="9018" nimi="Vanalõve küla"/><asula kood="9172" nimi="Veeriku küla"/><asula kood="9328" nimi="Vilidu küla"/><asula kood="9581" nimi="Võrsna küla"/><asula kood="9642" nimi="Väkra küla"/><asula kood="9649" nimi="Väljaküla"/></vald></maakond><maakond kood="0078"><vald kood="0126"><asula kood="1176" nimi="Alasoo küla"/><asula kood="1181" nimi="Alatskivi alevik"/><asula kood="1694" nimi="Haapsipea küla"/><asula kood="2979" nimi="Kesklahe küla"/><asula kood="3323" nimi="Kokora küla"/><asula kood="3626" nimi="Kuningvere küla"/><asula kood="3732" nimi="Kõdesi küla"/><asula kood="4050" nimi="Lahe küla"/><asula kood="4055" nimi="Lahepera küla"/><asula kood="4379" nimi="Linaleo küla"/><asula kood="5337" nimi="Naelavere küla"/><asula kood="5427" nimi="Nina küla"/><asula kood="5709" nimi="Orgemäe küla"/><asula kood="5807" nimi="Padakõrve küla"/><asula kood="6026" nimi="Passi küla"/><asula kood="6057" nimi="Peatskivi küla"/><asula kood="6458" nimi="Pusi küla"/><asula kood="6577" nimi="Päiksi küla"/><asula kood="6623" nimi="Pärsikivi küla"/><asula kood="6984" nimi="Riidma küla"/><asula kood="7043" nimi="Ronisoo küla"/><asula kood="7090" nimi="Rootsiküla"/><asula kood="7127" nimi="Rupsi küla"/><asula kood="7314" nimi="Saburi küla"/><asula kood="7484" nimi="Savastvere küla"/><asula kood="7499" nimi="Savimetsa küla"/><asula kood="7761" nimi="Sudemäe küla"/><asula kood="8329" nimi="Torila küla"/><asula kood="8335" nimi="Toruküla"/><asula kood="8527" nimi="Tõruvere küla"/><asula kood="9389" nimi="Virtsu küla"/><asula kood="9645" nimi="Väljaküla"/></vald><vald kood="0185"><asula kood="1010" nimi="Aadami küla"/><asula kood="1024" nimi="Aardla küla"/><asula kood="1022" nimi="Aardlapalu küla"/><asula kood="1167" nimi="Alaküla"/><asula kood="1696" nimi="Haaslava küla"/><asula kood="1997" nimi="Igevere küla"/><asula kood="2000" nimi="Ignase küla"/><asula kood="3167" nimi="Kitseküla"/><asula kood="3315" nimi="Koke küla"/><asula kood="3500" nimi="Kriimani küla"/><asula kood="3652" nimi="Kurepalu küla"/><asula kood="3748" nimi="Kõivuküla"/><asula kood="4099" nimi="Lange küla"/><asula kood="4906" nimi="Metsanurga küla"/><asula kood="5160" nimi="Mõra küla"/><asula kood="5944" nimi="Paluküla"/><asula kood="6584" nimi="Päkste küla"/><asula kood="7042" nimi="Roiu alevik"/><asula kood="8551" nimi="Tõõraste küla"/><asula kood="8695" nimi="Uniküla"/></vald><vald kood="0282"><asula kood="1016" nimi="Aakaru küla"/><asula kood="2119" nimi="Ivaste küla"/><asula kood="2433" nimi="Kaatsi küla"/><asula kood="2641" nimi="Kambja alevik"/><asula kood="2644" nimi="Kammeri küla"/><asula kood="2891" nimi="Kavandu küla"/><asula kood="3239" nimi="Kodijärve küla"/><asula kood="3585" nimi="Kullaga küla"/><asula kood="3804" nimi="Kõrkküla"/><asula kood="4085" nimi="Lalli küla"/><asula kood="4720" nimi="Madise küla"/><asula kood="5194" nimi="Mäeküla"/><asula kood="5690" nimi="Oomiste küla"/><asula kood="5784" nimi="Paali küla"/><asula kood="5949" nimi="Palumäe küla"/><asula kood="5975" nimi="Pangodi küla"/><asula kood="6426" nimi="Pulli küla"/><asula kood="6666" nimi="Pühi küla"/><asula kood="6692" nimi="Raanitsa küla"/><asula kood="6884" nimi="Rebase küla"/><asula kood="6935" nimi="Reolasoo küla"/><asula kood="6994" nimi="Riiviku küla"/><asula kood="7624" nimi="Sipe küla"/><asula kood="7642" nimi="Sirvaku küla"/><asula kood="7793" nimi="Sulu küla"/><asula kood="7828" nimi="Suure-Kambja küla"/><asula kood="8085" nimi="Talvikese küla"/><asula kood="8165" nimi="Tatra küla"/><asula kood="8992" nimi="Vana-Kuuste küla"/><asula kood="9404" nimi="Virulase küla"/><asula kood="9419" nimi="Visnapuu küla"/></vald><vald kood="0331"><asula kood="1291" nimi="Annikoru küla"/><asula kood="2699" nimi="Kapsta küla"/><asula kood="2725" nimi="Karijärve küla"/><asula kood="3216" nimi="Kobilu küla"/><asula kood="3372" nimi="Konguta küla"/><asula kood="3639" nimi="Kurelaane küla"/><asula kood="3973" nimi="Külaaseme küla"/><asula kood="4256" nimi="Lembevere küla"/><asula kood="4749" nimi="Majala küla"/><asula kood="4895" nimi="Metsalaane küla"/><asula kood="5206" nimi="Mäeotsa küla"/><asula kood="5248" nimi="Mälgi küla"/><asula kood="6322" nimi="Poole küla"/><asula kood="6648" nimi="Pööritsa küla"/><asula kood="8846" nimi="Vahessaare küla"/><asula kood="9191" nimi="Vellavere küla"/></vald><vald kood="0383"><asula kood="3872" nimi="Kämara küla"/><asula kood="3900" nimi="Kärevere küla"/><asula kood="4040" nimi="Laeva küla"/><asula kood="7614" nimi="Siniküla"/><asula kood="8966" nimi="Valmaotsa küla"/><asula kood="9688" nimi="Väänikvere küla"/></vald><vald kood="0432"><asula kood="2458" nimi="Kabina küla"/><asula kood="2556" nimi="Kakumetsa küla"/><asula kood="2897" nimi="Kavastu küla"/><asula kood="3059" nimi="Kikaste küla"/><asula kood="3749" nimi="Kõivu küla"/><asula kood="4451" nimi="Lohkva küla"/><asula kood="4584" nimi="Luunja alevik"/><asula kood="5046" nimi="Muri küla"/><asula kood="5886" nimi="Pajukurmu küla"/><asula kood="6249" nimi="Pilka küla"/><asula kood="6314" nimi="Poksi küla"/><asula kood="6552" nimi="Põvvatu küla"/><asula kood="7189" nimi="Rõõmu küla"/><asula kood="7479" nimi="Sava küla"/><asula kood="7491" nimi="Savikoja küla"/><asula kood="7632" nimi="Sirgu küla"/><asula kood="7635" nimi="Sirgumetsa küla"/><asula kood="7958" nimi="Sääsekõrva küla"/><asula kood="7962" nimi="Sääsküla"/><asula kood="9183" nimi="Veibri küla"/><asula kood="9286" nimi="Viira küla"/></vald><vald kood="0454"><asula kood="1329" nimi="Aravu küla"/><asula kood="1705" nimi="Haavametsa küla"/><asula kood="2241" nimi="Jõepera küla"/><asula kood="2367" nimi="Järvselja küla"/><asula kood="4842" nimi="Meeksi küla"/><asula kood="4854" nimi="Meerapalu küla"/><asula kood="4859" nimi="Mehikoorma alevik"/><asula kood="5992" nimi="Parapalu küla"/><asula kood="7161" nimi="Rõka küla"/><asula kood="7579" nimi="Sikakurmu küla"/></vald><vald kood="0501"><asula kood="1365" nimi="Aruaia küla"/><asula kood="2393" nimi="Kaagvere küla"/><asula kood="2411" nimi="Kaarlimõisa küla"/><asula kood="2840" nimi="Kastre küla"/><asula kood="4868" nimi="Melliste küla"/><asula kood="5240" nimi="Mäksa küla"/><asula kood="5245" nimi="Mäletjärve küla"/><asula kood="6311" nimi="Poka küla"/><asula kood="7423" nimi="Sarakuste küla"/><asula kood="7764" nimi="Sudaste küla"/><asula kood="8107" nimi="Tammevaldma küla"/><asula kood="8211" nimi="Tigase küla"/><asula kood="8987" nimi="Vana-Kastre küla"/><asula kood="9234" nimi="Veskimäe küla"/><asula kood="9583" nimi="Võruküla"/><asula kood="9605" nimi="Võõpste küla"/></vald><vald kood="0528"><asula kood="1129" nimi="Aiamaa küla"/><asula kood="1223" nimi="Altmäe küla"/><asula kood="1605" nimi="Enno küla"/><asula kood="1665" nimi="Etsaste küla"/><asula kood="2039" nimi="Illi küla"/><asula kood="2327" nimi="Järiste küla"/><asula kood="2916" nimi="Keeri küla"/><asula kood="2989" nimi="Ketneri küla"/><asula kood="3338" nimi="Kolga küla"/><asula kood="3939" nimi="Kääni küla"/><asula kood="4046" nimi="Laguja küla"/><asula kood="4557" nimi="Luke küla"/><asula kood="4856" nimi="Meeri küla"/><asula kood="5495" nimi="Nõgiaru küla"/><asula kood="5534" nimi="Nõo alevik"/><asula kood="7441" nimi="Sassi küla"/><asula kood="8133" nimi="Tamsa küla"/><asula kood="8512" nimi="Tõravere alevik"/><asula kood="8698" nimi="Unipiha küla"/><asula kood="8796" nimi="Uuta küla"/><asula kood="9423" nimi="Vissi küla"/><asula kood="9452" nimi="Voika küla"/></vald><vald kood="0587"><asula kood="2799" nimi="Kasepää alevik"/><asula kood="3350" nimi="Kolkja alevik"/><asula kood="7500" nimi="Savka küla"/><asula kood="7627" nimi="Sipelga küla"/><asula kood="9090" nimi="Varnja alevik"/></vald><vald kood="0595"><asula kood="6185" nimi="Piiri küla"/><asula kood="7286" nimi="Saare küla"/><asula kood="8308" nimi="Tooni küla"/></vald><vald kood="0605"><asula kood="1951" nimi="Härjanurme küla"/><asula kood="2348" nimi="Järvaküla"/><asula kood="2540" nimi="Kaimi küla"/><asula kood="3633" nimi="Kureküla"/><asula kood="5138" nimi="Mõisanurme küla"/><asula kood="5211" nimi="Mäeselja küla"/><asula kood="5358" nimi="Nasja küla"/><asula kood="5957" nimi="Palupõhja küla"/><asula kood="6328" nimi="Poriküla"/><asula kood="6393" nimi="Puhja alevik"/><asula kood="6955" nimi="Ridaküla"/><asula kood="7208" nimi="Rämsi küla"/><asula kood="7282" nimi="Saare küla"/><asula kood="8189" nimi="Teilma küla"/><asula kood="8575" nimi="Tännassilma küla"/><asula kood="8655" nimi="Ulila alevik"/><asula kood="9260" nimi="Vihavu küla"/><asula kood="2842" nimi="Võllinge küla"/><asula kood="9591" nimi="Võsivere küla"/></vald><vald kood="0666"><asula kood="1643" nimi="Ervu küla"/><asula kood="2351" nimi="Järveküla"/><asula kood="2409" nimi="Kaarlijärve küla"/><asula kood="3103" nimi="Kipastu küla"/><asula kood="3412" nimi="Koopsi küla"/><asula kood="3595" nimi="Kulli küla"/><asula kood="3637" nimi="Kureküla alevik"/><asula kood="5393" nimi="Neemisküla"/><asula kood="5447" nimi="Noorma küla"/><asula kood="5880" nimi="Paju küla"/><asula kood="6822" nimi="Rannu alevik"/><asula kood="7420" nimi="Sangla küla"/><asula kood="7833" nimi="Suure-Rakke küla"/><asula kood="8094" nimi="Tamme küla"/><asula kood="8750" nimi="Utukolga küla"/><asula kood="8959" nimi="Vallapalu küla"/><asula kood="9178" nimi="Vehendi küla"/><asula kood="9211" nimi="Verevi küla"/><asula kood="9633" nimi="Väike-Rakke küla"/></vald><vald kood="0694"><asula kood="2622" nimi="Kalme küla"/><asula kood="3121" nimi="Kirepi küla"/><asula kood="3457" nimi="Koruste küla"/><asula kood="3738" nimi="Kõduküla"/><asula kood="3881" nimi="Käo küla"/><asula kood="3949" nimi="Käärdi alevik"/><asula kood="4117" nimi="Lapetukme küla"/><asula kood="4527" nimi="Lossimäe küla"/><asula kood="6164" nimi="Piigandi küla"/><asula kood="6748" nimi="Raigaste küla"/><asula kood="6809" nimi="Rannaküla"/><asula kood="7167" nimi="Rõngu alevik"/><asula kood="8121" nimi="Tammiste küla"/><asula kood="8180" nimi="Teedla küla"/><asula kood="8238" nimi="Tilga küla"/><asula kood="8614" nimi="Uderna küla"/><asula kood="8941" nimi="Valguta küla"/></vald><vald kood="0794"><asula kood="1312" nimi="Aovere küla"/><asula kood="1383" nimi="Arupää küla"/><asula kood="1617" nimi="Erala küla"/><asula kood="1699" nimi="Haava küla"/><asula kood="1993" nimi="Igavere küla"/><asula kood="2286" nimi="Jõusa küla"/><asula kood="2829" nimi="Kastli küla"/><asula kood="3064" nimi="Kikivere küla"/><asula kood="3221" nimi="Kobratu küla"/><asula kood="3572" nimi="Kukulinna küla"/><asula kood="3824" nimi="Kõrveküla alevik"/><asula kood="3911" nimi="Kärkna küla"/><asula kood="3970" nimi="Kükitaja küla"/><asula kood="4093" nimi="Lammiku küla"/><asula kood="4487" nimi="Lombi küla"/><asula kood="4629" nimi="Lähte alevik"/><asula kood="4779" nimi="Maramaa küla"/><asula kood="4900" nimi="Metsanuka küla"/><asula kood="5310" nimi="Möllatsi küla"/><asula kood="5408" nimi="Nigula küla"/><asula kood="5492" nimi="Nõela küla"/><asula kood="6401" nimi="Puhtaleiva küla"/><asula kood="6437" nimi="Pupastvere küla"/><asula kood="7273" nimi="Saadjärve küla"/><asula kood="7393" nimi="Salu küla"/><asula kood="7655" nimi="Soeküla"/><asula kood="7668" nimi="Soitsjärve küla"/><asula kood="7671" nimi="Sojamaa küla"/><asula kood="7745" nimi="Sootaga küla"/><asula kood="7988" nimi="Taabri küla"/><asula kood="8123" nimi="Tammistu küla"/><asula kood="8235" nimi="Tila küla"/><asula kood="8290" nimi="Toolamaa küla"/><asula kood="8850" nimi="Vahi alevik"/><asula kood="9136" nimi="Vasula alevik"/><asula kood="9161" nimi="Vedu küla"/><asula kood="9240" nimi="Vesneri küla"/><asula kood="9273" nimi="Viidike küla"/><asula kood="9367" nimi="Vilussaare küla"/><asula kood="9514" nimi="Võibla küla"/><asula kood="9680" nimi="Väägvere küla"/><asula kood="9728" nimi="Õvi küla"/><asula kood="9748" nimi="Äksi alevik"/></vald><vald kood="0831"><asula kood="1681" nimi="Haage küla"/><asula kood="2050" nimi="Ilmatsalu alevik"/><asula kood="2049" nimi="Ilmatsalu küla"/><asula kood="2659" nimi="Kandiküla"/><asula kood="2710" nimi="Kardla küla"/><asula kood="5277" nimi="Märja alevik"/><asula kood="6155" nimi="Pihva küla"/><asula kood="6724" nimi="Rahinge küla"/><asula kood="7158" nimi="Rõhu küla"/><asula kood="8560" nimi="Tähtvere küla"/><asula kood="8590" nimi="Tüki küla"/><asula kood="9483" nimi="Vorbuse küla"/></vald><vald kood="0861"><asula kood="1166" nimi="Alajõe küla"/><asula kood="2717" nimi="Kargaja küla"/><asula kood="2858" nimi="Kauda küla"/><asula kood="2966" nimi="Keressaare küla"/><asula kood="3425" nimi="Koosa küla"/><asula kood="3427" nimi="Koosalaane küla"/><asula kood="3703" nimi="Kusma küla"/><asula kood="3721" nimi="Kuusiku küla"/><asula kood="4816" nimi="Matjama küla"/><asula kood="4871" nimi="Meoma küla"/><asula kood="4889" nimi="Metsakivi küla"/><asula kood="5065" nimi="Mustametsa küla"/><asula kood="5981" nimi="Papiaru küla"/><asula kood="6259" nimi="Pilpaküla"/><asula kood="6342" nimi="Praaga küla"/><asula kood="6488" nimi="Põdra küla"/><asula kood="6515" nimi="Põldmaa küla"/><asula kood="6544" nimi="Põrgu küla"/><asula kood="6902" nimi="Rehemetsa küla"/><asula kood="7516" nimi="Selgise küla"/><asula kood="7703" nimi="Sookalduse küla"/><asula kood="7938" nimi="Särgla küla"/><asula kood="8555" nimi="Tähemaa küla"/><asula kood="8687" nimi="Undi küla"/><asula kood="9031" nimi="Vanaussaia küla"/><asula kood="9053" nimi="Vara küla"/><asula kood="9644" nimi="Välgi küla"/><asula kood="9790" nimi="Ätte küla"/></vald><vald kood="0915"><asula kood="1097" nimi="Agali küla"/><asula kood="1125" nimi="Ahunapalu küla"/><asula kood="1752" nimi="Hammaste küla"/><asula kood="2076" nimi="Imste küla"/><asula kood="2112" nimi="Issaku küla"/><asula kood="2682" nimi="Kannu küla"/><asula kood="3677" nimi="Kurista küla"/><asula kood="3772" nimi="Kõnnu küla"/><asula kood="4349" nimi="Liispõllu küla"/><asula kood="4658" nimi="Lääniste küla"/><asula kood="7066" nimi="Rookse küla"/><asula kood="8201" nimi="Terikeste küla"/><asula kood="9570" nimi="Võnnu alevik"/></vald><vald kood="0949"><asula kood="3986" nimi="Külitse alevik"/><asula kood="4017" nimi="Laane küla"/><asula kood="4266" nimi="Lemmatsi küla"/><asula kood="4291" nimi="Lepiku küla"/><asula kood="4648" nimi="Läti küla"/><asula kood="6932" nimi="Reola küla"/><asula kood="7214" nimi="Räni alevik"/><asula kood="7666" nimi="Soinaste küla"/><asula kood="7743" nimi="Soosilla küla"/><asula kood="8532" nimi="Tõrvandi alevik"/><asula kood="8581" nimi="Täsvere küla"/><asula kood="8632" nimi="Uhti küla"/><asula kood="9717" nimi="Õssu küla"/><asula kood="9835" nimi="Ülenurme alevik"/></vald></maakond><maakond kood="0082"><vald kood="0203"><asula kood="1160" nimi="Ala küla"/><asula kood="1815" nimi="Helme alevik"/><asula kood="1883" nimi="Holdre küla"/><asula kood="2264" nimi="Jõgeveste küla"/><asula kood="2623" nimi="Kalme küla"/><asula kood="2757" nimi="Karjatnurme küla"/><asula kood="3124" nimi="Kirikuküla"/><asula kood="3420" nimi="Koorküla"/><asula kood="3866" nimi="Kähu küla"/><asula kood="4390" nimi="Linna küla"/><asula kood="5304" nimi="Möldre küla"/><asula kood="6042" nimi="Patküla"/><asula kood="6257" nimi="Pilpa küla"/><asula kood="7053" nimi="Roobe küla"/><asula kood="7993" nimi="Taagepera küla"/></vald><vald kood="0208"><asula kood="1152" nimi="Aitsra küla"/><asula kood="1171" nimi="Alamõisa küla"/><asula kood="1905" nimi="Hummuli alevik"/><asula kood="2187" nimi="Jeti küla"/><asula kood="3596" nimi="Kulli küla"/><asula kood="6186" nimi="Piiri küla"/><asula kood="6408" nimi="Puide küla"/><asula kood="6824" nimi="Ransi küla"/><asula kood="7654" nimi="Soe küla"/></vald><vald kood="0289"><asula kood="2384" nimi="Kaagjärve küla"/><asula kood="2775" nimi="Karula küla"/><asula kood="3116" nimi="Kirbu küla"/><asula kood="3383" nimi="Koobassaare küla"/><asula kood="3951" nimi="Käärikmäe küla"/><asula kood="4493" nimi="Londi küla"/><asula kood="4563" nimi="Lusti küla"/><asula kood="4677" nimi="Lüllemäe küla"/><asula kood="6234" nimi="Pikkjärve küla"/><asula kood="6388" nimi="Pugritsa küla"/><asula kood="6702" nimi="Raavitsa küla"/><asula kood="6887" nimi="Rebasemõisa küla"/><asula kood="8969" nimi="Valtina küla"/><asula kood="9618" nimi="Väheru küla"/></vald><vald kood="0636"><asula kood="1376" nimi="Arula küla"/><asula kood="2053" nimi="Ilmjärve küla"/><asula kood="2820" nimi="Kassiratta küla"/><asula kood="2837" nimi="Kastolatsi küla"/><asula kood="2880" nimi="Kaurutootsi küla"/><asula kood="3286" nimi="Koigu küla"/><asula kood="3954" nimi="Kääriku küla"/><asula kood="5219" nimi="Mägestiku küla"/><asula kood="5232" nimi="Mäha küla"/><asula kood="5279" nimi="Märdi küla"/><asula kood="5566" nimi="Nüpli küla"/><asula kood="5753" nimi="Otepää küla"/><asula kood="5754" nimi="Otepää linn"/><asula kood="6060" nimi="Pedajamäe küla"/><asula kood="6252" nimi="Pilkuse küla"/><asula kood="6658" nimi="Pühajärve küla"/><asula kood="6857" nimi="Raudsepa küla"/><asula kood="7565" nimi="Sihva küla"/><asula kood="8356" nimi="Truuta küla"/><asula kood="8546" nimi="Tõutsi küla"/><asula kood="8999" nimi="Vana-Otepää küla"/><asula kood="9252" nimi="Vidrike küla"/></vald><vald kood="0582"><asula kood="1418" nimi="Astuvere küla"/><asula kood="1440" nimi="Atra küla"/><asula kood="1813" nimi="Hellenurme küla"/><asula kood="4573" nimi="Lutike küla"/><asula kood="4751" nimi="Makita küla"/><asula kood="4959" nimi="Miti küla"/><asula kood="5198" nimi="Mäelooga küla"/><asula kood="5396" nimi="Neeruti küla"/><asula kood="5540" nimi="Nõuni küla"/><asula kood="5952" nimi="Palupera küla"/><asula kood="6031" nimi="Pastaku küla"/><asula kood="6570" nimi="Päidla küla"/><asula kood="7195" nimi="Räbi küla"/><asula kood="8727" nimi="Urmi küla"/></vald><vald kood="0608"><asula kood="1018" nimi="Aakre küla"/><asula kood="2998" nimi="Kibena küla"/><asula kood="3353" nimi="Kolli küla"/><asula kood="3369" nimi="Komsi küla"/><asula kood="3534" nimi="Kuigatsi küla"/><asula kood="3864" nimi="Kähri küla"/><asula kood="4837" nimi="Meegaste küla"/><asula kood="5916" nimi="Palamuste küla"/><asula kood="6071" nimi="Pedaste küla"/><asula kood="6296" nimi="Plika küla"/><asula kood="6352" nimi="Prange küla"/><asula kood="6417" nimi="Puka alevik"/><asula kood="6453" nimi="Purtsi küla"/><asula kood="6549" nimi="Põru küla"/><asula kood="6663" nimi="Pühaste küla"/><asula kood="6890" nimi="Rebaste küla"/><asula kood="7148" nimi="Ruuna küla"/><asula kood="7730" nimi="Soontaga küla"/><asula kood="8808" nimi="Vaardi küla"/></vald><vald kood="0613"><asula kood="2772" nimi="Karu küla"/><asula kood="2856" nimi="Kaubi küla"/><asula kood="3611" nimi="Kungi küla"/><asula kood="4173" nimi="Leebiku küla"/><asula kood="4433" nimi="Liva küla"/><asula kood="4620" nimi="Lõve küla"/><asula kood="6222" nimi="Pikasilla küla"/><asula kood="6330" nimi="Pori küla"/><asula kood="6946" nimi="Reti küla"/><asula kood="6976" nimi="Riidaja küla"/><asula kood="7113" nimi="Rulli küla"/><asula kood="8714" nimi="Uralaane küla"/><asula kood="9025" nimi="Vanamõisa küla"/><asula kood="9464" nimi="Voorbahi küla"/></vald><vald kood="0724"><asula kood="2914" nimi="Keeni küla"/><asula kood="3663" nimi="Kurevere küla"/><asula kood="4146" nimi="Lauküla"/><asula kood="4525" nimi="Lossiküla"/><asula kood="5195" nimi="Mäeküla"/><asula kood="5229" nimi="Mägiste küla"/><asula kood="6371" nimi="Pringi küla"/><asula kood="6943" nimi="Restu küla"/><asula kood="7018" nimi="Risttee küla"/><asula kood="7418" nimi="Sangaste alevik"/><asula kood="7426" nimi="Sarapuu küla"/><asula kood="8219" nimi="Tiidu küla"/><asula kood="8806" nimi="Vaalu küla"/><asula kood="9733" nimi="Ädu küla"/></vald><vald kood="0779"><asula kood="1766" nimi="Hargla küla"/><asula kood="2609" nimi="Kalliküla"/><asula kood="3289" nimi="Koikküla"/><asula kood="3304" nimi="Koiva küla"/><asula kood="3452" nimi="Korkuna küla"/><asula kood="4024" nimi="Laanemetsa küla"/><asula kood="4281" nimi="Lepa küla"/><asula kood="4576" nimi="Lutsu küla"/><asula kood="7005" nimi="Ringiste küla"/><asula kood="7686" nimi="Sooblase küla"/><asula kood="8069" nimi="Taheva küla"/><asula kood="8368" nimi="Tsirgumäe küla"/><asula kood="8535" nimi="Tõrvase küla"/></vald><vald kood="0820"><asula kood="2016" nimi="Iigaste küla"/><asula kood="2137" nimi="Jaanikese küla"/><asula kood="3447" nimi="Korijärve küla"/><asula kood="4029" nimi="Laatre alevik"/><asula kood="5003" nimi="Muhkva küla"/><asula kood="5881" nimi="Paju küla"/><asula kood="6786" nimi="Rampe küla"/><asula kood="7738" nimi="Sooru küla"/><asula kood="7801" nimi="Supa küla"/><asula kood="8064" nimi="Tagula küla"/><asula kood="8248" nimi="Tinu küla"/><asula kood="8365" nimi="Tsirguliina alevik"/><asula kood="8491" nimi="Tõlliste küla"/><asula kood="9326" nimi="Vilaski küla"/><asula kood="9651" nimi="Väljaküla"/></vald><vald kood="0943"><asula kood="3087" nimi="Killinge küla"/><asula kood="3180" nimi="Kiviküla"/><asula kood="4530" nimi="Lota küla"/><asula kood="5096" nimi="Mustumetsa küla"/><asula kood="6365" nimi="Priipalu küla"/><asula kood="8696" nimi="Uniküla"/><asula kood="9699" nimi="Õlatu küla"/><asula kood="9710" nimi="Õru alevik"/><asula kood="9713" nimi="Õruste küla"/></vald></maakond><maakond kood="0084"><vald kood="0105"><asula kood="1061" nimi="Abjaku küla"/><asula kood="1060" nimi="Abja-Paluoja linn"/><asula kood="8593" nimi="Abja-Vanamõisa küla"/><asula kood="1433" nimi="Atika küla"/><asula kood="2634" nimi="Kamara küla"/><asula kood="4030" nimi="Laatre küla"/><asula kood="4120" nimi="Lasari küla"/><asula kood="6106" nimi="Penuja küla"/><asula kood="6510" nimi="Põlde küla"/><asula kood="6689" nimi="Raamatu küla"/><asula kood="7238" nimi="Räägu küla"/><asula kood="7313" nimi="Saate küla"/><asula kood="7433" nimi="Sarja küla"/><asula kood="8672" nimi="Umbsoo küla"/><asula kood="9167" nimi="Veelikse küla"/><asula kood="9235" nimi="Veskimäe küla"/></vald><vald kood="0192"><asula kood="1625" nimi="Ereste küla"/><asula kood="1749" nimi="Halliste alevik"/><asula kood="1926" nimi="Hõbemäe küla"/><asula kood="2406" nimi="Kaarli küla"/><asula kood="2628" nimi="Kalvre küla"/><asula kood="3580" nimi="Kulla küla"/><asula kood="4802" nimi="Maru küla"/><asula kood="5020" nimi="Mulgi küla"/><asula kood="5178" nimi="Mõõnaste küla"/><asula kood="5349" nimi="Naistevalla küla"/><asula kood="5411" nimi="Niguli küla"/><asula kood="6335" nimi="Pornuse küla"/><asula kood="6572" nimi="Päidre küla"/><asula kood="6575" nimi="Päigiste küla"/><asula kood="6765" nimi="Raja küla"/><asula kood="7002" nimi="Rimmu küla"/><asula kood="7356" nimi="Saksaküla"/><asula kood="7410" nimi="Sammaste küla"/><asula kood="8240" nimi="Tilla küla"/><asula kood="8310" nimi="Toosi küla"/><asula kood="8759" nimi="Uue-Kariste küla"/><asula kood="8816" nimi="Vabamatsi küla"/><asula kood="8984" nimi="Vana-Kariste küla"/><asula kood="9695" nimi="Õisu alevik"/><asula kood="9830" nimi="Ülemõisa küla"/></vald><vald kood="0600"><asula kood="1149" nimi="Ainja küla"/><asula kood="1199" nimi="Allaste küla"/><asula kood="1868" nimi="Hirmuküla"/><asula kood="2759" nimi="Karksi küla"/><asula kood="2761" nimi="Karksi-Nuia linn"/><asula kood="3837" nimi="Kõvaküla"/><asula kood="4183" nimi="Leeli küla"/><asula kood="4370" nimi="Lilli küla"/><asula kood="4893" nimi="Metsaküla"/><asula kood="4989" nimi="Morna küla"/><asula kood="5047" nimi="Muri küla"/><asula kood="7211" nimi="Mäeküla"/><asula kood="5758" nimi="Oti küla"/><asula kood="6317" nimi="Polli küla"/><asula kood="6621" nimi="Pärsi küla"/><asula kood="6641" nimi="Pöögle küla"/><asula kood="7767" nimi="Sudiste küla"/><asula kood="7825" nimi="Suuga küla"/><asula kood="8398" nimi="Tuhalaane küla"/><asula kood="8701" nimi="Univere küla"/><asula kood="9780" nimi="Äriküla"/></vald><vald kood="0328"><asula kood="1539" nimi="Eesnurga küla"/><asula kood="2338" nimi="Järtsaare küla"/><asula kood="2439" nimi="Kaavere küla"/><asula kood="3340" nimi="Kolga-Jaani alevik"/><asula kood="4088" nimi="Lalsi küla"/><asula kood="4225" nimi="Leie küla"/><asula kood="4650" nimi="Lätkalu küla"/><asula kood="4865" nimi="Meleski küla"/><asula kood="5595" nimi="Odiste küla"/><asula kood="5647" nimi="Oiu küla"/><asula kood="5701" nimi="Oorgu küla"/><asula kood="5763" nimi="Otiküla"/><asula kood="6007" nimi="Parika küla"/><asula kood="8050" nimi="Taganurga küla"/><asula kood="8864" nimi="Vaibla küla"/><asula kood="9426" nimi="Vissuvere küla"/></vald><vald kood="0357"><asula kood="1356" nimi="Arjassaare küla"/><asula kood="1386" nimi="Arussaare küla"/><asula kood="2674" nimi="Kangrussaare küla"/><asula kood="3142" nimi="Kirivere küla"/><asula kood="3328" nimi="Koksvere küla"/><asula kood="3775" nimi="Kõo küla"/><asula kood="4514" nimi="Loopre küla"/><asula kood="4699" nimi="Maalasti küla"/><asula kood="5781" nimi="Paaksima küla"/><asula kood="5833" nimi="Paenasti küla"/><asula kood="6247" nimi="Pilistvere küla"/><asula kood="7489" nimi="Saviaugu küla"/><asula kood="7720" nimi="Soomevere küla"/><asula kood="8681" nimi="Unakvere küla"/><asula kood="9205" nimi="Venevere küla"/></vald><vald kood="0360"><asula kood="2013" nimi="Iia küla"/><asula kood="3619" nimi="Kuninga küla"/><asula kood="3782" nimi="Kõpu alevik"/><asula kood="4018" nimi="Laane küla"/><asula kood="6429" nimi="Punaküla"/><asula kood="7550" nimi="Seruküla"/><asula kood="7804" nimi="Supsi küla"/><asula kood="8251" nimi="Tipu küla"/><asula kood="8641" nimi="Uia küla"/><asula kood="9036" nimi="Vanaveski küla"/></vald><vald kood="0758"><asula kood="1144" nimi="Aimla küla"/><asula kood="1354" nimi="Arjadi küla"/><asula kood="1613" nimi="Epra küla"/><asula kood="2033" nimi="Ilbaku küla"/><asula kood="2116" nimi="Ivaski küla"/><asula kood="2175" nimi="Jaska küla"/><asula kood="2304" nimi="Jälevere küla"/><asula kood="2456" nimi="Kabila küla"/><asula kood="2754" nimi="Karjasoo küla"/><asula kood="2973" nimi="Kerita küla"/><asula kood="2993" nimi="Kibaru küla"/><asula kood="3079" nimi="Kildu küla"/><asula kood="3226" nimi="Kobruvere küla"/><asula kood="3430" nimi="Kootsi küla"/><asula kood="3523" nimi="Kuhjavere küla"/><asula kood="3529" nimi="Kuiavere küla"/><asula kood="3690" nimi="Kurnuvere küla"/><asula kood="3741" nimi="Kõidama küla"/><asula kood="3901" nimi="Kärevere küla"/><asula kood="4060" nimi="Lahmuse küla"/><asula kood="4261" nimi="Lemmakõnnu küla"/><asula kood="4598" nimi="Lõhavere küla"/><asula kood="4925" nimi="Metsküla"/><asula kood="4998" nimi="Mudiste küla"/><asula kood="5031" nimi="Munsi küla"/><asula kood="5196" nimi="Mäeküla"/><asula kood="5375" nimi="Navesti küla"/><asula kood="5488" nimi="Nuutre küla"/><asula kood="5669" nimi="Olustvere alevik"/><asula kood="5828" nimi="Paelama küla"/><asula kood="6502" nimi="Põhjaka küla"/><asula kood="6596" nimi="Päraküla"/><asula kood="6897" nimi="Reegoldi küla"/><asula kood="6974" nimi="Riiassaare küla"/><asula kood="7240" nimi="Rääka küla"/><asula kood="7415" nimi="Sandra küla"/><asula kood="7836" nimi="Suure-Jaani linn"/><asula kood="7978" nimi="Sürgavere küla"/><asula kood="8030" nimi="Taevere küla"/><asula kood="8566" nimi="Tällevere küla"/><asula kood="8586" nimi="Tääksi küla"/><asula kood="9123" nimi="Vastemõisa küla"/><asula kood="9262" nimi="Vihi küla"/><asula kood="9503" nimi="Võhmassaare küla"/><asula kood="9546" nimi="Võivaku küla"/><asula kood="9561" nimi="Võlli küla"/><asula kood="9765" nimi="Ängi küla"/><asula kood="9824" nimi="Ülde küla"/></vald><vald kood="0797"><asula kood="1283" nimi="Anikatsi küla"/><asula kood="2153" nimi="Jakobimõisa küla"/><asula kood="2355" nimi="Järveküla"/><asula kood="2570" nimi="Kalbuse küla"/><asula kood="2685" nimi="Kannuküla"/><asula kood="3185" nimi="Kivilõppe küla"/><asula kood="3275" nimi="Koidu küla"/><asula kood="3658" nimi="Kuressaare küla"/><asula kood="3927" nimi="Kärstna küla"/><asula kood="4763" nimi="Maltsa küla"/><asula kood="4789" nimi="Marjamäe küla"/><asula kood="4928" nimi="Metsla küla"/><asula kood="5017" nimi="Muksi küla"/><asula kood="5086" nimi="Mustla alevik"/><asula kood="5152" nimi="Mõnnaste küla"/><asula kood="5859" nimi="Pahuvere küla"/><asula kood="6239" nimi="Pikru küla"/><asula kood="6338" nimi="Porsa küla"/><asula kood="6541" nimi="Põrga küla"/><asula kood="6697" nimi="Raassilla küla"/><asula kood="7024" nimi="Riuma küla"/><asula kood="7076" nimi="Roosilla küla"/><asula kood="7653" nimi="Soe küla"/><asula kood="7750" nimi="Sooviku küla"/><asula kood="7779" nimi="Suislepa küla"/><asula kood="8048" nimi="Tagamõisa küla"/><asula kood="8159" nimi="Tarvastu küla"/><asula kood="8246" nimi="Tinnikuru küla"/><asula kood="8684" nimi="Unametsa küla"/><asula kood="9034" nimi="Vanausse küla"/><asula kood="9186" nimi="Veisjärve küla"/><asula kood="9331" nimi="Vilimeeste küla"/><asula kood="9344" nimi="Villa küla"/><asula kood="9477" nimi="Vooru küla"/><asula kood="9661" nimi="Väluste küla"/><asula kood="9758" nimi="Ämmuste küla"/><asula kood="9833" nimi="Ülensi küla"/></vald><vald kood="0898"><asula kood="1138" nimi="Aidu küla"/><asula kood="1147" nimi="Aindu küla"/><asula kood="1240" nimi="Alustre küla"/><asula kood="1461" nimi="Auksi küla"/><asula kood="1794" nimi="Heimtali küla"/><asula kood="1821" nimi="Hendrikumõisa küla"/><asula kood="1888" nimi="Holstre küla"/><asula kood="2093" nimi="Intsu küla"/><asula kood="2229" nimi="Jõeküla"/><asula kood="2312" nimi="Jämejala küla"/><asula kood="2776" nimi="Karula küla"/><asula kood="2813" nimi="Kassi küla"/><asula kood="2996" nimi="Kibeküla"/><asula kood="3042" nimi="Kiini küla"/><asula kood="3047" nimi="Kiisa küla"/><asula kood="3100" nimi="Kingu küla"/><asula kood="3313" nimi="Kokaviidika küla"/><asula kood="3396" nimi="Kookla küla"/><asula kood="3711" nimi="Kuudeküla"/><asula kood="4021" nimi="Laanekuru küla"/><asula kood="4185" nimi="Leemeti küla"/><asula kood="4462" nimi="Loime küla"/><asula kood="4484" nimi="Lolu küla"/><asula kood="4501" nimi="Loodi küla"/><asula kood="4548" nimi="Luiga küla"/><asula kood="4794" nimi="Marna küla"/><asula kood="4814" nimi="Matapera küla"/><asula kood="4981" nimi="Moori küla"/><asula kood="5070" nimi="Mustapali küla"/><asula kood="5075" nimi="Mustivere küla"/><asula kood="5201" nimi="Mäeltküla"/><asula kood="5237" nimi="Mähma küla"/><asula kood="5872" nimi="Paistu küla"/><asula kood="6090" nimi="Peetrimõisa küla"/><asula kood="6271" nimi="Pinska küla"/><asula kood="6276" nimi="Pirmastu küla"/><asula kood="6406" nimi="Puiatu küla"/><asula kood="6423" nimi="Pulleritsu küla"/><asula kood="6601" nimi="Päri küla"/><asula kood="6626" nimi="Pärsti küla"/><asula kood="6789" nimi="Ramsi alevik"/><asula kood="6852" nimi="Raudna küla"/><asula kood="6885" nimi="Rebase küla"/><asula kood="6891" nimi="Rebaste küla"/><asula kood="6956" nimi="Ridaküla"/><asula kood="6971" nimi="Rihkama küla"/><asula kood="7143" nimi="Ruudiküla"/><asula kood="7290" nimi="Saareküla"/><asula kood="7295" nimi="Saarepeedi küla"/><asula kood="7494" nimi="Savikoti küla"/><asula kood="7611" nimi="Sinialliku küla"/><asula kood="7790" nimi="Sultsi küla"/><asula kood="7812" nimi="Surva küla"/><asula kood="8003" nimi="Taari küla"/><asula kood="8264" nimi="Tobraselja küla"/><asula kood="8272" nimi="Tohvri küla"/><asula kood="8431" nimi="Turva küla"/><asula kood="8439" nimi="Tusti küla"/><asula kood="8504" nimi="Tõnissaare küla"/><asula kood="8507" nimi="Tõnuküla"/><asula kood="8522" nimi="Tõrreküla"/><asula kood="8569" nimi="Tänassilma küla"/><asula kood="8496" nimi="Tömbi küla"/><asula kood="8790" nimi="Uusna küla"/><asula kood="8964" nimi="Valma küla"/><asula kood="9026" nimi="Vanamõisa küla"/><asula kood="9012" nimi="Vana-Võidu küla"/><asula kood="9039" nimi="Vanavälja küla"/><asula kood="9068" nimi="Vardi küla"/><asula kood="9073" nimi="Vardja küla"/><asula kood="9103" nimi="Vasara küla"/><asula kood="9221" nimi="Verilaske küla"/><asula kood="9292" nimi="Viiratsi alevik"/><asula kood="9305" nimi="Viisuküla"/><asula kood="9541" nimi="Võistre küla"/><asula kood="9626" nimi="Väike-Kõpu küla"/><asula kood="9646" nimi="Välgita küla"/></vald></maakond><maakond kood="0086"><vald kood="0143"><asula kood="1288" nimi="Anne küla"/><asula kood="1301" nimi="Antsla linn"/><asula kood="1303" nimi="Antsu küla"/><asula kood="1678" nimi="Haabsaare küla"/><asula kood="2242" nimi="Jõepera küla"/><asula kood="2535" nimi="Kaika küla"/><asula kood="3069" nimi="Kikkaoja küla"/><asula kood="3214" nimi="Kobela alevik"/><asula kood="3355" nimi="Kollino küla"/><asula kood="3486" nimi="Kraavi küla"/><asula kood="4427" nimi="Litsmetsa küla"/><asula kood="4543" nimi="Luhametsa küla"/><asula kood="4564" nimi="Lusti küla"/><asula kood="4721" nimi="Madise küla"/><asula kood="5234" nimi="Mähkli küla"/><asula kood="5605" nimi="Oe küla"/><asula kood="6196" nimi="Piisi küla"/><asula kood="7000" nimi="Rimmi küla"/><asula kood="7073" nimi="Roosiku küla"/><asula kood="7496" nimi="Savilöövi küla"/><asula kood="7714" nimi="Soome küla"/><asula kood="7933" nimi="Säre küla"/><asula kood="8011" nimi="Taberlaane küla"/><asula kood="8378" nimi="Tsooru küla"/><asula kood="8977" nimi="Vana-Antsla alevik"/><asula kood="9290" nimi="Viirapalu küla"/><asula kood="9737" nimi="Ähijärve küla"/></vald><vald kood="0181"><asula kood="1161" nimi="Ala-Palo küla"/><asula kood="1164" nimi="Ala-Suhka küla"/><asula kood="1162" nimi="Ala-Tilga küla"/><asula kood="1262" nimi="Andsumäe küla"/><asula kood="1689" nimi="Haanja küla"/><asula kood="1703" nimi="Haavistu küla"/><asula kood="1750" nimi="Hanija küla"/><asula kood="1881" nimi="Holdi küla"/><asula kood="1890" nimi="Horoski küla"/><asula kood="1895" nimi="Hulaku küla"/><asula kood="1909" nimi="Hurda küla"/><asula kood="1933" nimi="Hämkoti küla"/><asula kood="2008" nimi="Ihatsi küla"/><asula kood="2145" nimi="Jaanimäe küla"/><asula kood="2401" nimi="Kaaratautsa küla"/><asula kood="2571" nimi="Kaldemäe küla"/><asula kood="2595" nimi="Kallaste küla"/><asula kood="2625" nimi="Kaloga küla"/><asula kood="2968" nimi="Kergatsi küla"/><asula kood="3089" nimi="Kilomani küla"/><asula kood="3115" nimi="Kirbu küla"/><asula kood="3478" nimi="Kotka küla"/><asula kood="3493" nimi="Kriguli küla"/><asula kood="3522" nimi="Kuiandi küla"/><asula kood="3559" nimi="Kuklase küla"/><asula kood="3713" nimi="Kuura küla"/><asula kood="3780" nimi="Kõomäe küla"/><asula kood="3941" nimi="Käänu küla"/><asula kood="3946" nimi="Kääraku küla"/><asula kood="3990" nimi="Külma küla"/><asula kood="4277" nimi="Leoski küla"/><asula kood="4372" nimi="Lillimõisa küla"/><asula kood="4502" nimi="Loogamäe küla"/><asula kood="4591" nimi="Luutsniku küla"/><asula kood="4693" nimi="Lüütsepä küla"/><asula kood="4731" nimi="Mahtja küla"/><asula kood="4760" nimi="Mallika küla"/><asula kood="4846" nimi="Meelaku küla"/><asula kood="4946" nimi="Miilimäe küla"/><asula kood="4949" nimi="Mikita küla"/><asula kood="5041" nimi="Murati küla"/><asula kood="5054" nimi="Mustahamba küla"/><asula kood="5187" nimi="Mäe-Palo küla"/><asula kood="7773" nimi="Mäe-Suhka küla"/><asula kood="5189" nimi="Mäe-Tilga küla"/><asula kood="5278" nimi="Märdimiku küla"/><asula kood="5323" nimi="Naapka küla"/><asula kood="5918" nimi="Palanumäe küla"/><asula kood="5933" nimi="Palli küla"/><asula kood="5942" nimi="Palujüri küla"/><asula kood="6051" nimi="Pausakunnu küla"/><asula kood="6078" nimi="Peedo küla"/><asula kood="6179" nimi="Piipsemäe küla"/><asula kood="6253" nimi="Pillardi küla"/><asula kood="6290" nimi="Plaani küla"/><asula kood="6287" nimi="Plaksi küla"/><asula kood="6336" nimi="Posti küla"/><asula kood="6358" nimi="Preeksa küla"/><asula kood="6362" nimi="Pressi küla"/><asula kood="6428" nimi="Pundi küla"/><asula kood="6439" nimi="Purka küla"/><asula kood="6463" nimi="Puspuri küla"/><asula kood="6687" nimi="Raagi küla"/><asula kood="6938" nimi="Resto küla"/><asula kood="7125" nimi="Rusa küla"/><asula kood="7153" nimi="Ruusmäe küla"/><asula kood="7271" nimi="Saagri küla"/><asula kood="7341" nimi="Saika küla"/><asula kood="7397" nimi="Saluora küla"/><asula kood="7431" nimi="Sarise küla"/><asula kood="7599" nimi="Simula küla"/><asula kood="7691" nimi="Soodi küla"/><asula kood="7751" nimi="Sormuli küla"/><asula kood="7968" nimi="Söödi küla"/><asula kood="8351" nimi="Trolla küla"/><asula kood="8354" nimi="Tsiamäe küla"/><asula kood="8357" nimi="Tsiiruli küla"/><asula kood="8358" nimi="Tsilgutaja küla"/><asula kood="8374" nimi="Tsolli küla"/><asula kood="8410" nimi="Tummelka küla"/><asula kood="8448" nimi="Tuuka küla"/><asula kood="8503" nimi="Tõnkova küla"/><asula kood="8762" nimi="Uue-Saaluse küla"/><asula kood="8802" nimi="Vaalimäe küla"/><asula kood="8809" nimi="Vaarkali küla"/><asula kood="8906" nimi="Vakari küla"/><asula kood="9129" nimi="Vastsekivi küla"/><asula kood="9261" nimi="Vihkla küla"/><asula kood="9345" nimi="Villa küla"/><asula kood="9487" nimi="Vorstimäe küla"/><asula kood="9488" nimi="Vungi küla"/><asula kood="9665" nimi="Vänni küla"/></vald><vald kood="0389"><asula kood="1305" nimi="Andsumäe küla"/><asula kood="1810" nimi="Hellekunnu küla"/><asula kood="1917" nimi="Husari küla"/><asula kood="2551" nimi="Kaku küla"/><asula kood="2683" nimi="Kannu küla"/><asula kood="3796" nimi="Kõrgessaare küla"/><asula kood="3944" nimi="Kääpa küla"/><asula kood="3965" nimi="Kühmamäe küla"/><asula kood="4130" nimi="Lasva küla"/><asula kood="4136" nimi="Lauga küla"/><asula kood="4203" nimi="Lehemetsa küla"/><asula kood="4424" nimi="Listaku küla"/><asula kood="4715" nimi="Madala küla"/><asula kood="5167" nimi="Mõrgi küla"/><asula kood="5210" nimi="Mäessaare küla"/><asula kood="5440" nimi="Noodasküla"/><asula kood="5531" nimi="Nõnova küla"/><asula kood="5660" nimi="Oleski küla"/><asula kood="5766" nimi="Otsa küla"/><asula kood="5862" nimi="Paidra küla"/><asula kood="6107" nimi="Peraküla"/><asula kood="6212" nimi="Pikakannu küla"/><asula kood="6220" nimi="Pikasilla küla"/><asula kood="6255" nimi="Pille küla"/><asula kood="6269" nimi="Pindi küla"/><asula kood="6482" nimi="Puusepa küla"/><asula kood="6625" nimi="Pässä küla"/><asula kood="7128" nimi="Rusima küla"/><asula kood="7292" nimi="Saaremaa küla"/><asula kood="7707" nimi="Sooküla"/><asula kood="8124" nimi="Tammsaare küla"/><asula kood="8252" nimi="Tiri küla"/><asula kood="8267" nimi="Tohkri küla"/><asula kood="8372" nimi="Tsolgo küla"/><asula kood="8601" nimi="Tüütsmäe küla"/><asula kood="9346" nimi="Villa küla"/><asula kood="8109" nimi="Voki-Tamme küla"/></vald><vald kood="0460"><asula kood="1170" nimi="Ala-Tsumba küla"/><asula kood="1264" nimi="Antkruva küla"/><asula kood="1626" nimi="Ermakova küla"/><asula kood="1804" nimi="Helbi küla"/><asula kood="1838" nimi="Hilana küla"/><asula kood="1839" nimi="Hilläkeste küla"/><asula kood="1876" nimi="Holdi küla"/><asula kood="1953" nimi="Härmä küla"/><asula kood="1998" nimi="Ignasõ küla"/><asula kood="2143" nimi="Jaanimäe küla"/><asula kood="2221" nimi="Juusa küla"/><asula kood="2278" nimi="Jõksi küla"/><asula kood="2565" nimi="Kalatsova küla"/><asula kood="2665" nimi="Kangavitsa küla"/><asula kood="2703" nimi="Karamsina küla"/><asula kood="2786" nimi="Kasakova küla"/><asula kood="2821" nimi="Kastamara küla"/><asula kood="2961" nimi="Keerba küla"/><asula kood="3041" nimi="Kiiova küla"/><asula kood="3053" nimi="Kiislova küla"/><asula kood="3071" nimi="Kiksova küla"/><asula kood="3164" nimi="Kitsõ küla"/><asula kood="3197" nimi="Klistina küla"/><asula kood="3454" nimi="Korski küla"/><asula kood="3536" nimi="Kuigõ küla"/><asula kood="3567" nimi="Kuksina küla"/><asula kood="3701" nimi="Kusnetsova küla"/><asula kood="3845" nimi="Kõõru küla"/><asula kood="3988" nimi="Küllätüvä küla"/><asula kood="4297" nimi="Lepä küla"/><asula kood="4387" nimi="Lindsi küla"/><asula kood="4571" nimi="Lutja küla"/><asula kood="4710" nimi="Maaslova küla"/><asula kood="4785" nimi="Marinova küla"/><asula kood="4798" nimi="Martsina küla"/><asula kood="4804" nimi="Masluva küla"/><asula kood="4866" nimi="Melso küla"/><asula kood="4872" nimi="Merekülä küla"/><asula kood="4879" nimi="Meremäe küla"/><asula kood="4843" nimi="Miikse küla"/><asula kood="4950" nimi="Miku küla"/><asula kood="5376" nimi="Navikõ küla"/><asula kood="5582" nimi="Obinitsa küla"/><asula kood="5658" nimi="Olehkova küla"/><asula kood="5746" nimi="Ostrova küla"/><asula kood="5900" nimi="Paklova küla"/><asula kood="5914" nimi="Palandõ küla"/><asula kood="5938" nimi="Palo küla"/><asula kood="5945" nimi="Paloveere küla"/><asula kood="6094" nimi="Pelsi küla"/><asula kood="6288" nimi="Pliia küla"/><asula kood="6313" nimi="Poksa küla"/><asula kood="6319" nimi="Polovina küla"/><asula kood="6412" nimi="Puista küla"/><asula kood="6823" nimi="Raotu küla"/><asula kood="7045" nimi="Rokina küla"/><asula kood="7152" nimi="Ruutsi küla"/><asula kood="7549" nimi="Seretsüvä küla"/><asula kood="7547" nimi="Serga küla"/><asula kood="7628" nimi="Sirgova küla"/><asula kood="7786" nimi="Sulbi küla"/><asula kood="8082" nimi="Talka küla"/><asula kood="8175" nimi="Tedre küla"/><asula kood="8191" nimi="Tepia küla"/><asula kood="8199" nimi="Tessova küla"/><asula kood="8204" nimi="Teterüvä küla"/><asula kood="8223" nimi="Tiirhanna küla"/><asula kood="8231" nimi="Tiklasõ küla"/><asula kood="8266" nimi="Tobrova küla"/><asula kood="8337" nimi="Treiali küla"/><asula kood="8341" nimi="Triginä küla"/><asula kood="8355" nimi="Tsergondõ küla"/><asula kood="8363" nimi="Tsirgu küla"/><asula kood="8375" nimi="Tsumba küla"/><asula kood="8416" nimi="Tuplova küla"/><asula kood="8459" nimi="Tuulova küla"/><asula kood="8584" nimi="Tääglova küla"/><asula kood="8648" nimi="Ulaskova küla"/><asula kood="8793" nimi="Uusvada küla"/><asula kood="8797" nimi="Vaaksaarõ küla"/><asula kood="9112" nimi="Vasla küla"/><asula kood="9208" nimi="Veretinä küla"/><asula kood="9373" nimi="Vinski küla"/><asula kood="9384" nimi="Viro küla"/><asula kood="9567" nimi="Võmmorski küla"/><asula kood="9639" nimi="Väiko-Härmä küla"/><asula kood="9637" nimi="Väiko-Serga küla"/></vald><vald kood="0468"><asula kood="1859" nimi="Hindsa küla"/><asula kood="1858" nimi="Hino küla"/><asula kood="1893" nimi="Horosuu küla"/><asula kood="1955" nimi="Häärmäni küla"/><asula kood="1966" nimi="Hürsi küla"/><asula kood="2854" nimi="Kaubi küla"/><asula kood="3095" nimi="Kimalasõ küla"/><asula kood="3193" nimi="Kiviora küla"/><asula kood="3451" nimi="Koorla küla"/><asula kood="3794" nimi="Korgõssaarõ küla"/><asula kood="3468" nimi="Kossa küla"/><asula kood="3502" nimi="Kriiva küla"/><asula kood="3374" nimi="Kundsa küla"/><asula kood="3635" nimi="Kurõ küla"/><asula kood="3851" nimi="Käbli küla"/><asula kood="3906" nimi="Kärinä küla"/><asula kood="4071" nimi="Laisi küla"/><asula kood="4228" nimi="Leimani küla"/><asula kood="4540" nimi="Lütä küla"/><asula kood="4830" nimi="Mauri küla"/><asula kood="4954" nimi="Misso alevik"/><asula kood="4956" nimi="Missokülä küla"/><asula kood="4970" nimi="Mokra küla"/><asula kood="5035" nimi="Muraski küla"/><asula kood="5297" nimi="Määsi küla"/><asula kood="5305" nimi="Möldre küla"/><asula kood="5354" nimi="Napi küla"/><asula kood="6015" nimi="Parmu küla"/><asula kood="6069" nimi="Pedejä küla"/><asula kood="6375" nimi="Pruntova küla"/><asula kood="6424" nimi="Pulli küla"/><asula kood="6435" nimi="Pupli küla"/><asula kood="6538" nimi="Põnni küla"/><asula kood="6543" nimi="Põrstõ küla"/><asula kood="6592" nimi="Pältre küla"/><asula kood="6784" nimi="Rammuka küla"/><asula kood="6883" nimi="Rebäse küla"/><asula kood="7021" nimi="Ritsiko küla"/><asula kood="7274" nimi="Saagri küla"/><asula kood="7272" nimi="Saagrimäe küla"/><asula kood="7344" nimi="Saika küla"/><asula kood="7364" nimi="Sakudi küla"/><asula kood="7411" nimi="Sandi küla"/><asula kood="7419" nimi="Sapi küla"/><asula kood="7506" nimi="Savimäe küla"/><asula kood="7504" nimi="Savioja küla"/><asula kood="7585" nimi="Siksälä küla"/><asula kood="7849" nimi="Suurõsuu küla"/><asula kood="8177" nimi="Tiastõ küla"/><asula kood="8224" nimi="Tiilige küla"/><asula kood="8233" nimi="Tika küla"/><asula kood="8314" nimi="Toodsi küla"/><asula kood="8359" nimi="Tserebi küla"/><asula kood="8360" nimi="Tsiistre küla"/><asula kood="9640" nimi="Väiko-Tiilige küla"/></vald><vald kood="0493"><asula kood="1968" nimi="Hürova küla"/><asula kood="1972" nimi="Hüti küla"/><asula kood="2598" nimi="Kallaste küla"/><asula kood="2738" nimi="Karisöödi küla"/><asula kood="3250" nimi="Koemetsa küla"/><asula kood="3728" nimi="Kuutsi küla"/><asula kood="5149" nimi="Mõniste küla"/><asula kood="6019" nimi="Parmupalu küla"/><asula kood="6076" nimi="Peebu küla"/><asula kood="7363" nimi="Sakurgi küla"/><asula kood="7436" nimi="Saru küla"/><asula kood="7609" nimi="Singa küla"/><asula kood="8229" nimi="Tiitsa küla"/><asula kood="8415" nimi="Tundu küla"/><asula kood="8429" nimi="Tursa küla"/><asula kood="9131" nimi="Vastse-Roosa küla"/><asula kood="9354" nimi="Villike küla"/></vald><vald kood="0697"><asula kood="1005" nimi="Aabra küla"/><asula kood="1111" nimi="Ahitsa küla"/><asula kood="1456" nimi="Augli küla"/><asula kood="1676" nimi="Haabsilla küla"/><asula kood="1728" nimi="Haki küla"/><asula kood="1745" nimi="Hallimäe küla"/><asula kood="1753" nimi="Handimiku küla"/><asula kood="1758" nimi="Hansi küla"/><asula kood="1756" nimi="Hapsu küla"/><asula kood="1789" nimi="Heedu küla"/><asula kood="1791" nimi="Heibri küla"/><asula kood="1861" nimi="Hinu küla"/><asula kood="1898" nimi="Horsa küla"/><asula kood="1896" nimi="Hotõmäe küla"/><asula kood="1911" nimi="Hurda küla"/><asula kood="1956" nimi="Härämäe küla"/><asula kood="2146" nimi="Jaanipeebu küla"/><asula kood="2206" nimi="Jugu küla"/><asula kood="2358" nimi="Järvekülä küla"/><asula kood="2357" nimi="Järvepalu küla"/><asula kood="2491" nimi="Kadõni küla"/><asula kood="2513" nimi="Kahru küla"/><asula kood="2554" nimi="Kaku küla"/><asula kood="2627" nimi="Kaluka küla"/><asula kood="2704" nimi="Karaski küla"/><asula kood="2708" nimi="Karba küla"/><asula kood="2866" nimi="Kaugu küla"/><asula kood="2899" nimi="Kavõldi küla"/><asula kood="2936" nimi="Kellämäe küla"/><asula kood="3026" nimi="Kiidi küla"/><asula kood="3256" nimi="Kogrõ küla"/><asula kood="3327" nimi="Kokõjüri küla"/><asula kood="3329" nimi="Kokõ küla"/><asula kood="3318" nimi="Kokõmäe küla"/><asula kood="3334" nimi="Kolga küla"/><asula kood="3558" nimi="Kuklasõ küla"/><asula kood="3664" nimi="Kurgjärve küla"/><asula kood="3698" nimi="Kurvitsa küla"/><asula kood="3706" nimi="Kuuda küla"/><asula kood="3861" nimi="Kähri küla"/><asula kood="3873" nimi="Kängsepä küla"/><asula kood="4111" nimi="Laossaarõ küla"/><asula kood="4158" nimi="Lauri küla"/><asula kood="4358" nimi="Liivakupalu küla"/><asula kood="4422" nimi="Listaku küla"/><asula kood="4568" nimi="Lutika küla"/><asula kood="4670" nimi="Lükkä küla"/><asula kood="4822" nimi="Matsi küla"/><asula kood="4947" nimi="Mikita küla"/><asula kood="4996" nimi="Muduri küla"/><asula kood="5001" nimi="Muhkamõtsa küla"/><asula kood="5024" nimi="Muna küla"/><asula kood="5042" nimi="Murdõmäe küla"/><asula kood="5056" nimi="Mustahamba küla"/><asula kood="5176" nimi="Mõõlu küla"/><asula kood="5283" nimi="Märdi küla"/><asula kood="5306" nimi="Möldri küla"/><asula kood="5423" nimi="Nilbõ küla"/><asula kood="5434" nimi="Nogu küla"/><asula kood="5477" nimi="Nursi küla"/><asula kood="5732" nimi="Ortumäe küla"/><asula kood="5770" nimi="Paaburissa küla"/><asula kood="5822" nimi="Paeboja küla"/><asula kood="6128" nimi="Petrakuudi küla"/><asula kood="6386" nimi="Pugõstu küla"/><asula kood="6433" nimi="Pulli küla"/><asula kood="6485" nimi="Põdra küla"/><asula kood="6545" nimi="Põru küla"/><asula kood="6611" nimi="Pärlijõe küla"/><asula kood="6670" nimi="Püssä küla"/><asula kood="6839" nimi="Rasva küla"/><asula kood="6859" nimi="Raudsepä küla"/><asula kood="6892" nimi="Rebäse küla"/><asula kood="6895" nimi="Rebäsemõisa küla"/><asula kood="6991" nimi="Riitsilla küla"/><asula kood="7008" nimi="Ristemäe küla"/><asula kood="7052" nimi="Roobi küla"/><asula kood="7144" nimi="Ruuksu küla"/><asula kood="7181" nimi="Rõuge alevik"/><asula kood="7305" nimi="Saarlasõ küla"/><asula kood="7321" nimi="Sadramõtsa küla"/><asula kood="7346" nimi="Saki küla"/><asula kood="7409" nimi="Sandisuu küla"/><asula kood="7507" nimi="Savioru küla"/><asula kood="7574" nimi="Sika küla"/><asula kood="7575" nimi="Sikalaanõ küla"/><asula kood="7600" nimi="Simmuli küla"/><asula kood="7650" nimi="Soekõrdsi küla"/><asula kood="7656" nimi="Soemõisa küla"/><asula kood="7721" nimi="Soomõoru küla"/><asula kood="7146" nimi="Suurõ-Ruuga küla"/><asula kood="7930" nimi="Sänna küla"/><asula kood="8086" nimi="Tallima küla"/><asula kood="8170" nimi="Taudsa küla"/><asula kood="8200" nimi="Tialasõ küla"/><asula kood="8218" nimi="Tiidu küla"/><asula kood="8237" nimi="Tilgu küla"/><asula kood="8241" nimi="Tindi küla"/><asula kood="8284" nimi="Toodsi küla"/><asula kood="8366" nimi="Tsirgupalu küla"/><asula kood="8379" nimi="Tsutsu küla"/><asula kood="8603" nimi="Tüütsi küla"/><asula kood="8623" nimi="Udsali küla"/><asula kood="8738" nimi="Utessuu küla"/><asula kood="8817" nimi="Vadsa küla"/><asula kood="9030" nimi="Vanamõisa küla"/><asula kood="9307" nimi="Viitina küla"/><asula kood="9329" nimi="Viliksaarõ küla"/><asula kood="9643" nimi="Väiku-Ruuga küla"/></vald><vald kood="0767"><asula kood="1163" nimi="Alakülä küla"/><asula kood="1172" nimi="Alapõdra küla"/><asula kood="1751" nimi="Haamaste küla"/><asula kood="1697" nimi="Haava küla"/><asula kood="1134" nimi="Haidaku küla"/><asula kood="1764" nimi="Hargi küla"/><asula kood="1786" nimi="Heeska küla"/><asula kood="1894" nimi="Horma küla"/><asula kood="8744" nimi="Hutita küla"/><asula kood="1942" nimi="Hänike küla"/><asula kood="2365" nimi="Järvere küla"/><asula kood="2515" nimi="Kahro küla"/><asula kood="2911" nimi="Keema küla"/><asula kood="3649" nimi="Kurenurme küla"/><asula kood="3903" nimi="Kärgula küla"/><asula kood="4079" nimi="Lakovitsa küla"/><asula kood="4240" nimi="Leiso küla"/><asula kood="4357" nimi="Liiva küla"/><asula kood="4373" nimi="Lilli-Anne küla"/><asula kood="4401" nimi="Linnamäe küla"/><asula kood="4750" nimi="Majala küla"/><asula kood="5071" nimi="Mustassaare küla"/><asula kood="5077" nimi="Mustja küla"/><asula kood="5188" nimi="Mäekülä küla"/><asula kood="5749" nimi="Osula küla"/><asula kood="6376" nimi="Pritsi küla"/><asula kood="6430" nimi="Pulli küla"/><asula kood="6431" nimi="Punakülä küla"/><asula kood="6864" nimi="Rauskapalu küla"/><asula kood="7119" nimi="Rummi küla"/><asula kood="7787" nimi="Sulbi küla"/><asula kood="7887" nimi="Sõmerpalu alevik"/><asula kood="7888" nimi="Sõmerpalu küla"/><asula kood="8620" nimi="Udsali küla"/><asula kood="9074" nimi="Varese küla"/></vald><vald kood="0843"><asula kood="2812" nimi="Kassi küla"/><asula kood="3125" nimi="Kirikuküla"/><asula kood="3287" nimi="Koigu küla"/><asula kood="3575" nimi="Kuldre küla"/><asula kood="3752" nimi="Kõlbi küla"/><asula kood="4689" nimi="Lümatu küla"/><asula kood="6150" nimi="Pihleni küla"/><asula kood="7102" nimi="Ruhingu küla"/><asula kood="8280" nimi="Toku küla"/><asula kood="8634" nimi="Uhtjärve küla"/><asula kood="8733" nimi="Urvaste küla"/><asula kood="8757" nimi="Uue-Antsla küla"/><asula kood="8801" nimi="Vaabina küla"/><asula kood="9414" nimi="Visela küla"/></vald><vald kood="0865"><asula kood="1772" nimi="Harjuküla küla"/><asula kood="1863" nimi="Hintsiko küla"/><asula kood="2677" nimi="Kangsti küla"/><asula kood="3489" nimi="Krabi küla"/><asula kood="3793" nimi="Kõrgepalu küla"/><asula kood="4160" nimi="Laurimäe küla"/><asula kood="4324" nimi="Liguri küla"/><asula kood="4694" nimi="Lüütsepa küla"/><asula kood="4825" nimi="Matsi küla"/><asula kood="4933" nimi="Metstaga küla"/><asula kood="5099" nimi="Mutemetsa küla"/><asula kood="5839" nimi="Paganamaa küla"/><asula kood="6434" nimi="Punsa küla"/><asula kood="6564" nimi="Pähni küla"/><asula kood="6858" nimi="Raudsepa küla"/><asula kood="7712" nimi="Soolätte küla"/><asula kood="8038" nimi="Tagakolga küla"/><asula kood="9002" nimi="Vana-Roosa küla"/><asula kood="9095" nimi="Varstu alevik"/><asula kood="9391" nimi="Viru küla"/></vald><vald kood="0874"><asula kood="1700" nimi="Haava küla"/><asula kood="1744" nimi="Halla küla"/><asula kood="1796" nimi="Heinasoo küla"/><asula kood="1856" nimi="Hinniala küla"/><asula kood="1860" nimi="Hinsa küla"/><asula kood="1886" nimi="Holsta küla"/><asula kood="2040" nimi="Illi küla"/><asula kood="2082" nimi="Indra küla"/><asula kood="2184" nimi="Jeedasküla"/><asula kood="2212" nimi="Juraski küla"/><asula kood="2389" nimi="Kaagu küla"/><asula kood="2694" nimi="Kapera küla"/><asula kood="2963" nimi="Kerepäälse küla"/><asula kood="3130" nimi="Kirikumäe küla"/><asula kood="3450" nimi="Kornitsa küla"/><asula kood="3776" nimi="Kõo küla"/><asula kood="3818" nimi="Kõrve küla"/><asula kood="3883" nimi="Käpa küla"/><asula kood="3981" nimi="Külaoru küla"/><asula kood="3991" nimi="Kündja küla"/><asula kood="4386" nimi="Lindora küla"/><asula kood="4517" nimi="Loosi küla"/><asula kood="4544" nimi="Luhte küla"/><asula kood="5100" nimi="Mutsu küla"/><asula kood="5192" nimi="Mäe-Kõoküla"/><asula kood="5307" nimi="Möldri küla"/><asula kood="5734" nimi="Ortuma küla"/><asula kood="5943" nimi="Paloveere küla"/><asula kood="6002" nimi="Pari küla"/><asula kood="6112" nimi="Perametsa küla"/><asula kood="6293" nimi="Plessi küla"/><asula kood="6484" nimi="Puutli küla"/><asula kood="6673" nimi="Raadi küla"/><asula kood="7281" nimi="Saarde küla"/><asula kood="7503" nimi="Savioja küla"/><asula kood="7820" nimi="Sutte küla"/><asula kood="8014" nimi="Tabina küla"/><asula kood="8081" nimi="Tallikeste küla"/><asula kood="8192" nimi="Tellaste küla"/><asula kood="8376" nimi="Tsolli küla"/><asula kood="8811" nimi="Vaarkali küla"/><asula kood="9004" nimi="Vana-Saaluse küla"/><asula kood="8855" nimi="Vana-Vastseliina küla"/><asula kood="9133" nimi="Vastseliina alevik"/><asula kood="9144" nimi="Vatsa küla"/><asula kood="9310" nimi="Viitka küla"/><asula kood="9458" nimi="Voki küla"/></vald><vald kood="0918"><asula kood="1759" nimi="Hannuste küla"/><asula kood="2203" nimi="Juba küla"/><asula kood="2789" nimi="Kasaritsa küla"/><asula kood="3153" nimi="Kirumpää küla"/><asula kood="3333" nimi="Kolepi küla"/><asula kood="3360" nimi="Koloreino küla"/><asula kood="3462" nimi="Kose alevik"/><asula kood="3704" nimi="Kusma küla"/><asula kood="3921" nimi="Kärnamäe küla"/><asula kood="3956" nimi="Käätso küla"/><asula kood="4118" nimi="Lapi küla"/><asula kood="4490" nimi="Lompka küla"/><asula kood="4519" nimi="Loosu küla"/><asula kood="4839" nimi="Meegomäe küla"/><asula kood="4845" nimi="Meeliku küla"/><asula kood="5135" nimi="Mõisamäe küla"/><asula kood="5141" nimi="Mõksi küla"/><asula kood="5378" nimi="Navi küla"/><asula kood="5450" nimi="Nooska küla"/><asula kood="5941" nimi="Palometsa küla"/><asula kood="6017" nimi="Parksepa alevik"/><asula kood="6411" nimi="Puiga küla"/><asula kood="6761" nimi="Raiste küla"/><asula kood="6856" nimi="Raudsepa küla"/><asula kood="7078" nimi="Roosisaare küla"/><asula kood="7217" nimi="Räpo küla"/><asula kood="7576" nimi="Sika küla"/><asula kood="8040" nimi="Tagaküla"/><asula kood="8315" nimi="Tootsi küla"/><asula kood="8669" nimi="Umbsaare küla"/><asula kood="8833" nimi="Vagula küla"/><asula kood="8994" nimi="Vana-Nursi küla"/><asula kood="9218" nimi="Verijärve küla"/><asula kood="9564" nimi="Võlsi küla"/><asula kood="9585" nimi="Võrumõisa küla"/><asula kood="9588" nimi="Võrusoo küla"/><asula kood="9636" nimi="Väimela alevik"/><asula kood="9641" nimi="Väiso küla"/></vald></maakond></ehak>	asulad	2021-01-27 10:25:45.782999	2021-01-27 10:25:45.782999	admin	\N	\N	\N	\N	\N	\N	\N	\N
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
11	\N	\N	<?xml version="1.0" encoding="UTF-8"?>\n<xsl:stylesheet version="2.0"\n  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\n  xmlns:xforms="http://www.w3.org/2002/xforms"\n  xmlns:xhtml="http://www.w3.org/1999/xhtml"\n  xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"\n  xmlns:events="http://www.w3.org/2001/xml-events"\n  xmlns:xrd="http://x-road.ee/xsd/x-road.xsd"\n  xmlns:xtee="http://x-tee.riik.ee/xsd/xtee.xsd"  \n  xmlns:xs="http://www.w3.org/2001/XMLSchema"\n  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n  xmlns:f="http://orbeon.org/oxf/xml/formatting"\n  xmlns:fr="http://orbeon.org/oxf/xml/form-runner"\n>\n<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />\n\n<xsl:param name="query"/>\n<xsl:param name="description"/>\n<xsl:param name="descriptionEncoded"/>\n<xsl:param name="xrdVersion"/>\n<xsl:param name="useIssue" select="'false'"/>\n<xsl:param name="echoURI" select="'/echo'"/>\n<xsl:param name="logURI" select="'/saveQueryLog.action'"/>\n<xsl:param name="pdfURI" select="''"/>\n<xsl:param name="basepath" select="'http://localhost:8080/misp2'"/>\n<xsl:param name="language" select="'et'"/>\n<xsl:param name="mail" select="'kasutaja@domeen.ee'"/>\n<xsl:param name="mailEncryptAllowed" select="'false'"/>\n<xsl:param name="mailSignAllowed" select="'false'"/>\n<xsl:param name="mainServiceName" select="''"/>\n<!-- copy all nodes to proceed -->\n<xsl:template match="*|@*|text()" name="copy">\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n  </xsl:copy>\n</xsl:template>\n\n<xsl:template match="xhtml:html">\n    <xsl:copy>\n      <xsl:apply-templates select="@*"/>\n      <xsl:attribute name="lang"><xsl:value-of select="$language"/></xsl:attribute>  \n      <xsl:apply-templates select="*|text()"/>\n  </xsl:copy>\n</xsl:template>  \n  \n<xsl:template match="xforms:switch">\n  <xsl:copy>\n    <div id="footer"><span id="footer-left" class="xforms-control xforms-input xforms-static xforms-readonly xforms-type-string"></span><span id="pagenumber"/></div>\n    <xsl:apply-templates select="*|text()"/>\n  </xsl:copy>\n</xsl:template> \n \n<!-- replace classifier src with basepath -->\n<xsl:template match="xforms:instance[ends-with(@id, '.classifier')]">\n  <xsl:variable name="classifierURL" select="concat($basepath, '/classifier?name=', substring-before(@id, '.classifier'))"/>\n  <xsl:copy>\n    <xsl:apply-templates select="@*"/>\n    <xsl:attribute name="src">\n      <xsl:value-of select="$classifierURL"/>\n    </xsl:attribute>\n    <xsl:apply-templates select="*|text()"/>\n  </xsl:copy>\n</xsl:template>\n\n<!-- add to submission logging function and add submission instance for XML button -->\n<xsl:template match="xforms:submission[ends-with(@id, '.submission')]">\n  <xsl:variable name="req" select="substring-before(@id, '.submission')"/>\n    <xsl:copy>\n      <xsl:apply-templates select="*|@*|text()"/>\n      <xforms:setvalue ref="instance('temp')/pdf/description" value="'{$descriptionEncoded}'" events:event="xforms-submit"/>\n      <xforms:setvalue ref="instance('temp')/pdf/email" value="'{$mail}'" events:event="xforms-submit"/>\n      <xforms:insert context="." origin="xxforms:set-session-attribute('{$req}.output', instance('{$req}.output'))" events:event="xforms-submit-done"/>\n\t  <!-- Remove all xsi:nil elements, because Orbeon does not handle them as NULLs (element not represented) -->\n      <xforms:delete nodeset="instance('{substring-before(@id, '.submission')}.output')//*[@xsi:nil = 'true']" events:event="xforms-submit-done"/>\n\t  \n    </xsl:copy>\n  <xforms:submission id="{$req}.log" xxforms:show-progress="false"\n    action="{$logURI}"\n    ref="instance('temp')/queryLog"\n    method="get"\n    replace="none"/>\n   <xforms:submission id="{$req}.pdf" xxforms:show-progress="false"\n    action="{$pdfURI}&amp;case={$req}.response&amp;"\n    ref="instance('temp')/pdf"\n    method="get"\n    replace="all"/>\n  <xforms:submission id="{$req}.xml" xxforms:show-progress="false"\n    action="{$echoURI}"\n    ref="instance('{$req}.output')"\n    method="post" \n\tvalidate="false"\n    replace="all"/>\n</xsl:template>\n\n<xsl:template match="xforms:instance[@id='temp']"/>\n<!-- instance for encrypting the query -->\n<xsl:template match="xforms:model">\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n    <xforms:instance id="temp">\n      <temp>\n        <relevant xsi:type="boolean">true</relevant>    \n        <logStart/>\n        <logEnd/>\n        <queryLog>\n          <userId/>\n          <queryId/>\n          <serviceName/>\n          <mainServiceName/>\n          <description/>\n          <queryTimeSec/>\n          <consumer/>\n\t\t  <unit/>\n        </queryLog>\n        <pdf>\n          <description/>\n          <sign xsi:type="boolean">false</sign>\n          <encrypt xsi:type="boolean">false</encrypt>\n          <sendPdfByMail xsi:type="boolean">false</sendPdfByMail>\n          <email/>\n        </pdf>\n      </temp>\n    </xforms:instance>\n    <xforms:bind nodeset="instance('temp')/pdf/sendPdfByMail" type="xs:boolean"  />\n    <xforms:bind nodeset="instance('temp')/pdf/sign" type="xs:boolean"  />\n    <xforms:bind nodeset="instance('temp')/pdf/encrypt" type="xs:boolean"  />\n    <xforms:action events:event="xforms-ready">\n       <xforms:setfocus control="input-1" />\n    </xforms:action>\n  </xsl:copy>\n</xsl:template>\n          \n<!-- Add XML and >>> buttons  (in simple query response)-->\n<xsl:template match="xforms:case[ends-with(@id, '.response')]/xforms:group[@class='actions']">\n  <xsl:variable name="form" select="substring-before(../@id, '.response')"/>\n  <xsl:copy>    \n    <xsl:apply-templates select="*|@*|text()"/>     \n      <xforms:trigger id="{substring-before(../@id, '.response')}-buttons_trigger" class="button">\n         <xforms:label xml:lang="et">Salvesta...</xforms:label>\n         <xforms:label xml:lang="en">Save...</xforms:label>\n         <xxforms:show events:event="DOMActivate" dialog="save-dialog-{substring-before(../@id, '.response')}"/>\n      </xforms:trigger>\n      <xxforms:dialog id="save-dialog-{substring-before(../@id, '.response')}" class="results-save-dialog" appearance="full" level="modal" close="true" draggable="true" visible="false" neighbor="{substring-before(../@id, '.response')}-buttons_trigger">\n        <xforms:label xml:lang="et">Teenuse vastuse salvestamine</xforms:label>\n        <xforms:label xml:lang="en">Service response saving</xforms:label>\n        <xhtml:div id="save">\n          <xhtml:div id="pdf">\n            <xhtml:h2 xml:lang="et">Salvesta failina</xhtml:h2>\n            <xhtml:h2 xml:lang="en">Save to file</xhtml:h2>\n            <xforms:trigger class="button">\n              <xforms:label>PDF</xforms:label>\n              <xforms:setvalue ref="instance('temp')/pdf/sendPdfByMail" value="'false'"/>\n              <xforms:send events:event="DOMActivate" submission="{substring-before(../@id, '.response')}.pdf"/>\n            </xforms:trigger>\n            <xforms:trigger class="button">\n              <xforms:label>XML</xforms:label>\n              <xforms:send events:event="DOMActivate" submission="{substring-before(../@id, '.response')}.xml"/>\n            </xforms:trigger> \n          </xhtml:div>\n          <xhtml:div id="email">\n            <xforms:input ref="instance('temp')/pdf/email" id="email-input-{$form}">\n\t\t\t\t<xforms:label xml:lang="et">E-post</xforms:label>\n\t\t\t\t<xforms:label xml:lang="en">E-mail</xforms:label>\n\t\t\t</xforms:input>\n            <xsl:if test="$mailSignAllowed">\n              <xforms:input ref="instance('temp')/pdf/sign" id="sign-input-{$form}">\n\t\t\t\t<xforms:label xml:lang="et">Signeeritud</xforms:label>\n\t\t\t\t<xforms:label xml:lang="en">Signed</xforms:label>\n\t\t\t</xforms:input>\n            </xsl:if>\n            <xsl:if test="$mailEncryptAllowed">\n              <xforms:input ref="instance('temp')/pdf/encrypt" id="encrypt-input-{$form}">\n\t\t\t\t<xforms:label xml:lang="et">Krüpteeritud</xforms:label>\n\t\t\t\t<xforms:label xml:lang="en">Encrypted</xforms:label>\n\t\t\t</xforms:input>\n            </xsl:if>\n            <xforms:trigger class="button">\n              <xforms:label xml:lang="et">Saada PDF e-postile</xforms:label>\n              <xforms:label xml:lang="en">Send PDF to e-mail</xforms:label>\n              <xxforms:script events:event="DOMActivate">\n                sign = 'false';\n                encrypt = 'false';\n                try{\n                  emailInput = $("#email-input-<xsl:value-of select="$form"/>>input");\n                  signInput = ORBEON.util.Dom.getElementById("sign-input-<xsl:value-of select="$form"/>");\n                  encryptInput = ORBEON.util.Dom.getElementById("encrypt-input-<xsl:value-of select="$form"/>");\n                 \n                }catch(err){  \n                  emailInput = $("#email-input-<xsl:value-of select="$form"/>>input");\n                  signInput = ORBEON.util.Dom.get("sign-input-<xsl:value-of select="$form"/>");             \n                  encryptInput = ORBEON.util.Dom.get("encrypt-input-<xsl:value-of select="$form"/>");\n                }                 \n                if(emailInput != null){\n                   email = $("#email-input-<xsl:value-of select="$form"/>>input").val();\n                <xsl:if test="$mailSignAllowed">\n                   sign = ORBEON.xforms.Document.getValue("sign-input-<xsl:value-of select="$form"/>");\n                </xsl:if>\n                <xsl:if test="$mailEncryptAllowed">\n                   encrypt = ORBEON.xforms.Document.getValue("encrypt-input-<xsl:value-of select="$form"/>");\n                </xsl:if>\n                }                \n                sendPDFByMail("<xsl:value-of select="concat($form, '.response')"/>", email, sign, encrypt, "<xsl:value-of select="$descriptionEncoded"/>");\n              </xxforms:script>\n            </xforms:trigger>\n          </xhtml:div>        \n        </xhtml:div>\n        <xforms:action events:event="xxforms-dialog-open">\n          <xforms:setfocus control="{substring-before(../@id, '.response')}-buttons_trigger"/>\n        </xforms:action>\n      </xxforms:dialog>\n  </xsl:copy>\n</xsl:template>\n\n\n<!-- invisible values for query logging -->\n<xsl:template match="xforms:case[ends-with(@id, '.request')]">\n  <xsl:param name="serviceName" select="substring-before(@id, '.request')"/>\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n   <xsl:if test="$useIssue='true'">\n       <xhtml:br/>\n       <xforms:input ref="instance('{$serviceName}.input')//xrd:issue" class="issue">\n        <xforms:label xml:lang="et">Toimik: </xforms:label>\n        <xforms:label xml:lang="en">Issue: </xforms:label>\n        <xforms:label xml:lang="ru">Toimik: </xforms:label>\n       </xforms:input>\n       <xforms:input ref="instance('{$serviceName}.input')//xtee:toimik" class="issue">\n        <xforms:label xml:lang="et">Toimik: </xforms:label>\n        <xforms:label xml:lang="en">Issue: </xforms:label>\n        <xforms:label xml:lang="ru">Toimik: </xforms:label>\n       </xforms:input>\n       <br/>\n     </xsl:if>\n<!--    <fr:error-summary observer="{$serviceName}-xforms-request-group" id="{$serviceName}-xforms-error-summary">\n      <fr:label xml:lang="et">Vormil esinevad vead: </fr:label>\n    </fr:error-summary>-->\n  </xsl:copy>\n</xsl:template>\n  \n  \n  <xsl:template match="xforms:case[ends-with(@id, '.request')]//xforms:input">\n      <xsl:variable name="nodeset-ref" select="@ref"/>     \n      <xsl:variable name="alert-et" select="xforms:alert[@xml:lang='et']"/>\n      <xsl:variable name="alert-en" select="xforms:alert[@xml:lang='en']"/>\n      <xsl:variable name="alert-ru" select="xforms:alert[@xml:lang='ru']"/>\n      <xsl:variable name="alert-default" select="'Väli peab olema täidetud vastavalt reeglitele'"/>\n      <xsl:choose>\n        <xsl:when test="//xforms:bind[(@constraint!='' or @required!='') and @nodeset=$nodeset-ref]/@nodeset!=''">\n           <xsl:copy>\n              <xsl:apply-templates select="*|@*"/>\n              <xforms:alert><xsl:value-of select="$alert-default"/></xforms:alert>\n              <xforms:alert xml:lang="et"><xsl:choose><xsl:when test="$alert-et!=''"><xsl:value-of select="$alert-et"/></xsl:when><xsl:otherwise><xsl:value-of select="$alert-default"/></xsl:otherwise></xsl:choose></xforms:alert>\n             <xforms:alert xml:lang="ru"><xsl:choose><xsl:when test="$alert-ru!=''"><xsl:value-of select="$alert-ru"/></xsl:when><xsl:otherwise><xsl:value-of select="$alert-default"/></xsl:otherwise></xsl:choose></xforms:alert>\n             <xforms:alert xml:lang="en"><xsl:choose><xsl:when test="$alert-en!=''"><xsl:value-of select="$alert-en"/></xsl:when><xsl:otherwise><xsl:value-of select="$alert-default"/></xsl:otherwise></xsl:choose></xforms:alert>\n            </xsl:copy> \n          </xsl:when>\n          <xsl:otherwise>\n            <xsl:copy>\n              <xsl:apply-templates select="*|@*"/>\n            </xsl:copy> \n          </xsl:otherwise>\n      </xsl:choose>  \n   </xsl:template>  \n  \n<!--<xsl:template match="xforms:submit[ends-with(@submission, '.submission')]">\n  <xsl:variable name="form" select="substring-before(@submission, '.submission')"/>\n  <xsl:copy>\n    <xsl:apply-templates select="*|@*|text()"/>\n    <xforms:dispatch events:event="DOMActivate" name="fr-visit-all" targetid="{$form}-xforms-error-summary"/>\n  </xsl:copy>\n</xsl:template>\n  \n<xsl:template match="xforms:case[ends-with(@id, '.request')]//xforms:group[@ref='request'] | xforms:case[ends-with(@id, '.request')]//xforms:group[@ref='keha']">\n  <xsl:copy>\n   <xsl:apply-templates select="@*"/>\n   <xsl:attribute name="id">\n    <xsl:value-of select="concat(substring-before((./ancestor::xforms:case[ends-with(@id, 'request')]/@id), '.request'), '-xforms-request-group')"/>\n   </xsl:attribute>\n   <xsl:apply-templates select="*|text()"/>\n </xsl:copy>\n</xsl:template>\n   -->  \n</xsl:stylesheet>	10	2021-01-27 10:25:45.802303	2021-01-27 10:25:45.802303	admin	debug	0	t	\N	http://www.aktors.ee/support/xroad/xsl/debug.xsl
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

