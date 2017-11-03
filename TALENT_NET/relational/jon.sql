--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: children_per_parent(); Type: FUNCTION; Schema: public; Owner: jon4syth
--

CREATE FUNCTION children_per_parent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    n integer;
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT INTO n count(id) FROM child WHERE parent_id = NEW.parent_id;
        IF n <> 9 THEN
            RAISE EXCEPTION 'During % of child: Parent id=% already has 2 children!',tg_op,NEW.parent_id;
        END IF;
    END IF;

    IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
        SELECT INTO n count(id) FROM child WHERE parent_id = OLD.parent_id;
        IF n = 2 THEN
            RAISE EXCEPTION 'During % of child: Parent id=% already has 2 children, not %',tg_op,NEW.parent_id,n;
        END IF;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION public.children_per_parent() OWNER TO jon4syth;

--
-- Name: limit_two_children_per_parent(); Type: FUNCTION; Schema: public; Owner: jon4syth
--

CREATE FUNCTION limit_two_children_per_parent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    n integer;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT INTO n count(id) FROM child WHERE parent_id = NEW.parent_id;
        IF n = 3 THEN
            RAISE EXCEPTION 'During % of users: Parent id=% already has 2 children!',tg_op,NEW.parent_id;
        END IF;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION public.limit_two_children_per_parent() OWNER TO jon4syth;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: child; Type: TABLE; Schema: public; Owner: jon4syth
--

CREATE TABLE child (
    id integer NOT NULL,
    parent_id integer
);


ALTER TABLE child OWNER TO jon4syth;

--
-- Name: child_id_seq; Type: SEQUENCE; Schema: public; Owner: jon4syth
--

CREATE SEQUENCE child_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE child_id_seq OWNER TO jon4syth;

--
-- Name: child_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jon4syth
--

ALTER SEQUENCE child_id_seq OWNED BY child.id;


--
-- Name: parent; Type: TABLE; Schema: public; Owner: jon4syth
--

CREATE TABLE parent (
    id integer NOT NULL
);


ALTER TABLE parent OWNER TO jon4syth;

--
-- Name: parent_id_seq; Type: SEQUENCE; Schema: public; Owner: jon4syth
--

CREATE SEQUENCE parent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE parent_id_seq OWNER TO jon4syth;

--
-- Name: parent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jon4syth
--

ALTER SEQUENCE parent_id_seq OWNED BY parent.id;


--
-- Name: child id; Type: DEFAULT; Schema: public; Owner: jon4syth
--

ALTER TABLE ONLY child ALTER COLUMN id SET DEFAULT nextval('child_id_seq'::regclass);


--
-- Name: parent id; Type: DEFAULT; Schema: public; Owner: jon4syth
--

ALTER TABLE ONLY parent ALTER COLUMN id SET DEFAULT nextval('parent_id_seq'::regclass);


--
-- Data for Name: child; Type: TABLE DATA; Schema: public; Owner: jon4syth
--

COPY child (id, parent_id) FROM stdin;
1	1
2	1
5	2
6	2
\.


--
-- Name: child_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jon4syth
--

SELECT pg_catalog.setval('child_id_seq', 7, true);


--
-- Data for Name: parent; Type: TABLE DATA; Schema: public; Owner: jon4syth
--

COPY parent (id) FROM stdin;
1
2
\.


--
-- Name: parent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jon4syth
--

SELECT pg_catalog.setval('parent_id_seq', 2, true);


--
-- Name: child child_pkey; Type: CONSTRAINT; Schema: public; Owner: jon4syth
--

ALTER TABLE ONLY child
    ADD CONSTRAINT child_pkey PRIMARY KEY (id);


--
-- Name: parent parent_pkey; Type: CONSTRAINT; Schema: public; Owner: jon4syth
--

ALTER TABLE ONLY parent
    ADD CONSTRAINT parent_pkey PRIMARY KEY (id);


--
-- Name: child two_children_per_parent_tg; Type: TRIGGER; Schema: public; Owner: jon4syth
--

CREATE CONSTRAINT TRIGGER two_children_per_parent_tg AFTER INSERT ON child DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE limit_two_children_per_parent();


--
-- Name: child child_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jon4syth
--

ALTER TABLE ONLY child
    ADD CONSTRAINT child_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES parent(id);


--
-- PostgreSQL database dump complete
--

