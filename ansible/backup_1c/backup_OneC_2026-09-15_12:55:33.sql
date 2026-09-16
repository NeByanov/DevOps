--
-- PostgreSQL database dump
--

\restrict qMWgeSY5NWRciP8AolJcnGt69NeIfyZhFXGESUwy66h6p0I3zBTLuK6xH1XjyZn

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fasttrun; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fasttrun WITH SCHEMA public;


--
-- Name: EXTENSION fasttrun; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fasttrun IS 'fast transaction-unsafe truncate';


--
-- Name: fulleq; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fulleq WITH SCHEMA public;


--
-- Name: EXTENSION fulleq; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fulleq IS 'exact equal operation';


--
-- Name: mchar; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS mchar WITH SCHEMA public;


--
-- Name: EXTENSION mchar; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION mchar IS 'SQL Server text type';


--
-- Name: binrowver(integer); Type: FUNCTION; Schema: public; Owner: one_c_db_user
--

CREATE FUNCTION public.binrowver(p1 integer) RETURNS bytea
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
  SELECT decode('00000000', 'hex') || int4send($1)
$_$;


ALTER FUNCTION public.binrowver(p1 integer) OWNER TO one_c_db_user;

--
-- Name: datediff2(character varying, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: one_c_db_user
--

CREATE FUNCTION public.datediff2(character varying, timestamp without time zone, timestamp without time zone) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
    DECLARE
     arg_mode alias for $1;
     arg_d2 alias for $2;
     arg_d1 alias for $3;
    BEGIN
    if arg_mode = 'SECOND' then
     return date_part('epoch',arg_d1) - date_part('epoch',arg_d2) ;
    elsif arg_mode = 'MINUTE' then
     return trunc((date_part('epoch',arg_d1) - date_part('epoch',arg_d2)) / 60);
    elsif arg_mode = 'HOUR' then
     return trunc((date_part('epoch',arg_d1) - date_part('epoch',arg_d2)) /3600);
    elsif arg_mode = 'DAY' then
     return cast(arg_d1 as date) - cast(arg_d2 as date);
    elsif arg_mode = 'WEEK' then
            return trunc( ( cast(arg_d1 as date) - cast(arg_d2 as date) ) / 7.0);
    elsif arg_mode = 'MONTH' then
     return 12 * (date_part('year',arg_d1) - date_part('year',arg_d2))
          + date_part('month',arg_d1) - date_part('month',arg_d2);
    elsif arg_mode = 'QUARTER' then
     return 4 * (date_part('year',arg_d1) - date_part('year',arg_d2))
          + date_part('quarter',arg_d1) - date_part('quarter',arg_d2);
    elsif arg_mode = 'YEAR' then
     return (date_part('year',arg_d1) - date_part('year',arg_d2));
   end if;
    END
    $_$;


ALTER FUNCTION public.datediff2(character varying, timestamp without time zone, timestamp without time zone) OWNER TO one_c_db_user;

--
-- Name: format_number(numeric, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: one_c_db_user
--

CREATE FUNCTION public.format_number(num numeric, grplen integer, secgrplen integer, grpsep character varying, decsep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    numstr VARCHAR := CAST(num AS VARCHAR);
    dotpos SMALLINT := STRPOS(numstr, '.');
    numstrlen SMALLINT;
    outstr VARCHAR;
    startpos SMALLINT;
    curpos SMALLINT;
BEGIN
    if dotpos > 0 THEN
        numstr := RTRIM(CAST(num AS VARCHAR), '0.');
        dotpos := STRPOS(numstr, '.');
    END IF;

    numstrlen := LENGTH(numstr);

    IF grplen > 0 AND grplen < numstrlen THEN
        outstr := (CASE WHEN dotpos = 0 THEN '' ELSE decsep || right(numstr, numstrlen - dotpos) END);

        IF (dotpos = 0) THEN
            dotpos := numstrlen + 1;
        END IF;

        startpos := (CASE WHEN left(numstr, 1) = '-' THEN 2 ELSE 1 END);
        curpos := dotpos;
        WHILE curpos > 0 LOOP
            outstr := SUBSTR(numstr, curpos - grplen, grplen) || (CASE WHEN(curpos < dotpos AND curpos > startpos) THEN grpsep ELSE '' END) || outstr;
            curpos := curpos - grplen;
            IF secgrplen > 0 AND secgrplen < numstrlen THEN
                grplen := secgrplen;
            END IF;
        END LOOP;

        RETURN outstr;
    END IF;

    IF decsep != '.' AND dotpos > 0 THEN
        RETURN REPLACE(numstr, '.', decsep);
    END IF;

    RETURN numstr;
END $$;


ALTER FUNCTION public.format_number(num numeric, grplen integer, secgrplen integer, grpsep character varying, decsep character varying) OWNER TO one_c_db_user;

--
-- Name: vassn(boolean); Type: FUNCTION; Schema: public; Owner: one_c_db_user
--

CREATE FUNCTION public.vassn(boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE bexpr alias for $1;
BEGIN
if bexpr
then return 0;
else return 2000000000;
end if;
END
$_$;


ALTER FUNCTION public.vassn(boolean) OWNER TO one_c_db_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _accopt; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._accopt (
    _mdid bytea NOT NULL,
    _extid bytea NOT NULL,
    _pdupdmode numeric(1,0) NOT NULL
);
ALTER TABLE ONLY public._accopt ALTER COLUMN _mdid SET STORAGE PLAIN;
ALTER TABLE ONLY public._accopt ALTER COLUMN _extid SET STORAGE PLAIN;


ALTER TABLE public._accopt OWNER TO one_c_db_user;

--
-- Name: _bots; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._bots (
    _id bytea NOT NULL,
    _clientid public.mvarchar(100) NOT NULL,
    _ecsuserid public.mvarchar(100) NOT NULL,
    _mdbotid bytea NOT NULL,
    _ibusername public.mvarchar(100),
    _param bytea NOT NULL,
    _predefined boolean NOT NULL,
    _needsupdate boolean
);
ALTER TABLE ONLY public._bots ALTER COLUMN _id SET STORAGE PLAIN;
ALTER TABLE ONLY public._bots ALTER COLUMN _mdbotid SET STORAGE PLAIN;


ALTER TABLE public._bots OWNER TO one_c_db_user;

--
-- Name: _chrcopt; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._chrcopt (
    _mdid bytea NOT NULL,
    _extid bytea NOT NULL,
    _pdupdmode numeric(1,0) NOT NULL
);
ALTER TABLE ONLY public._chrcopt ALTER COLUMN _mdid SET STORAGE PLAIN;
ALTER TABLE ONLY public._chrcopt ALTER COLUMN _extid SET STORAGE PLAIN;


ALTER TABLE public._chrcopt OWNER TO one_c_db_user;

--
-- Name: _ckindsopt; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._ckindsopt (
    _mdid bytea NOT NULL,
    _extid bytea NOT NULL,
    _pdupdmode numeric(1,0) NOT NULL
);
ALTER TABLE ONLY public._ckindsopt ALTER COLUMN _mdid SET STORAGE PLAIN;
ALTER TABLE ONLY public._ckindsopt ALTER COLUMN _extid SET STORAGE PLAIN;


ALTER TABLE public._ckindsopt OWNER TO one_c_db_user;

--
-- Name: _commonsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._commonsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._commonsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._commonsettings OWNER TO one_c_db_user;

--
-- Name: _datahistoryafterwritequeue; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._datahistoryafterwritequeue (
    _metadataid bytea NOT NULL,
    _historydataid bytea NOT NULL,
    _versionnumber numeric(9,0) NOT NULL
);
ALTER TABLE ONLY public._datahistoryafterwritequeue ALTER COLUMN _metadataid SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistoryafterwritequeue ALTER COLUMN _historydataid SET STORAGE PLAIN;


ALTER TABLE public._datahistoryafterwritequeue OWNER TO one_c_db_user;

--
-- Name: _datahistorylatestversions; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._datahistorylatestversions (
    _metadataid bytea NOT NULL,
    _dataid bytea NOT NULL,
    _historydataid bytea NOT NULL,
    _versionnumber numeric(9,0) NOT NULL,
    _content bytea NOT NULL
);
ALTER TABLE ONLY public._datahistorylatestversions ALTER COLUMN _metadataid SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistorylatestversions ALTER COLUMN _dataid SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistorylatestversions ALTER COLUMN _historydataid SET STORAGE PLAIN;


ALTER TABLE public._datahistorylatestversions OWNER TO one_c_db_user;

--
-- Name: _datahistorymetadata; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._datahistorymetadata (
    _metadataid bytea NOT NULL,
    _issettings boolean NOT NULL,
    _isactual boolean NOT NULL,
    _metadataversionnumber numeric(9,0) NOT NULL,
    _content bytea NOT NULL,
    _isextensions boolean NOT NULL,
    _actiononaccept numeric(1,0) NOT NULL
);
ALTER TABLE ONLY public._datahistorymetadata ALTER COLUMN _metadataid SET STORAGE PLAIN;


ALTER TABLE public._datahistorymetadata OWNER TO one_c_db_user;

--
-- Name: _datahistoryqueue0; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._datahistoryqueue0 (
    _metadataid bytea NOT NULL,
    _dataid bytea NOT NULL,
    _position numeric(9,0) NOT NULL,
    _content bytea NOT NULL
);
ALTER TABLE ONLY public._datahistoryqueue0 ALTER COLUMN _metadataid SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistoryqueue0 ALTER COLUMN _dataid SET STORAGE PLAIN;


ALTER TABLE public._datahistoryqueue0 OWNER TO one_c_db_user;

--
-- Name: _datahistorysettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._datahistorysettings (
    _metadataid bytea NOT NULL,
    _content bytea NOT NULL
);
ALTER TABLE ONLY public._datahistorysettings ALTER COLUMN _metadataid SET STORAGE PLAIN;


ALTER TABLE public._datahistorysettings OWNER TO one_c_db_user;

--
-- Name: _datahistoryversions; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._datahistoryversions (
    _historydataid bytea NOT NULL,
    _versionnumber numeric(9,0) NOT NULL,
    _metadataversionnumber numeric(9,0) NOT NULL,
    _date timestamp without time zone NOT NULL,
    _changetype numeric(1,0) NOT NULL,
    _userid bytea NOT NULL,
    _username public.mvarchar(256) NOT NULL,
    _userfullname public.mvarchar(256) NOT NULL,
    _comment public.mvarchar(1024) NOT NULL,
    _transaction bytea NOT NULL,
    _node_type bytea NOT NULL,
    _node_rtref bytea NOT NULL,
    _node_rrref bytea NOT NULL,
    _content bytea NOT NULL
);
ALTER TABLE ONLY public._datahistoryversions ALTER COLUMN _historydataid SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistoryversions ALTER COLUMN _userid SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistoryversions ALTER COLUMN _transaction SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistoryversions ALTER COLUMN _node_type SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistoryversions ALTER COLUMN _node_rtref SET STORAGE PLAIN;
ALTER TABLE ONLY public._datahistoryversions ALTER COLUMN _node_rrref SET STORAGE PLAIN;


ALTER TABLE public._datahistoryversions OWNER TO one_c_db_user;

--
-- Name: _dbcopies; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopies (
    _copyid bytea NOT NULL,
    _copyname public.mvarchar(256) NOT NULL,
    _useintaccelerator boolean NOT NULL,
    _repltype integer NOT NULL,
    _dbtype integer NOT NULL,
    _dbserver public.mvarchar(256) NOT NULL,
    _dbname public.mvarchar(256) NOT NULL,
    _dbuser public.mvarchar(256) NOT NULL,
    _dbpassword public.mvarchar(256) NOT NULL,
    _createdb boolean NOT NULL,
    _version numeric(9,0) NOT NULL,
    _storagevariant numeric(1,0) NOT NULL
);
ALTER TABLE ONLY public._dbcopies ALTER COLUMN _copyid SET STORAGE PLAIN;


ALTER TABLE public._dbcopies OWNER TO one_c_db_user;

--
-- Name: _dbcopiesinfobaseuse; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiesinfobaseuse (
    _id bytea NOT NULL,
    _description public.mvarchar(256) NOT NULL
);
ALTER TABLE ONLY public._dbcopiesinfobaseuse ALTER COLUMN _id SET STORAGE PLAIN;


ALTER TABLE public._dbcopiesinfobaseuse OWNER TO one_c_db_user;

--
-- Name: _dbcopiesinitiallast; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiesinitiallast (
    _copyid bytea NOT NULL,
    _tablename public.mvarchar(256) NOT NULL,
    _blocknum integer NOT NULL,
    _firstkey bytea,
    _lastkey bytea,
    _blockstate integer NOT NULL
);
ALTER TABLE ONLY public._dbcopiesinitiallast ALTER COLUMN _copyid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiesinitiallast OWNER TO one_c_db_user;

--
-- Name: _dbcopiesinitiallast__blocknum_seq; Type: SEQUENCE; Schema: public; Owner: one_c_db_user
--

CREATE SEQUENCE public._dbcopiesinitiallast__blocknum_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


ALTER SEQUENCE public._dbcopiesinitiallast__blocknum_seq OWNER TO one_c_db_user;

--
-- Name: _dbcopiesinitiallast__blocknum_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: one_c_db_user
--

ALTER SEQUENCE public._dbcopiesinitiallast__blocknum_seq OWNED BY public._dbcopiesinitiallast._blocknum;


--
-- Name: _dbcopiessettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiessettings (
    _copyid bytea NOT NULL,
    _copycontent bytea NOT NULL,
    _copyschema bytea NOT NULL,
    _version numeric(9,0) NOT NULL
);
ALTER TABLE ONLY public._dbcopiessettings ALTER COLUMN _copyid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiessettings OWNER TO one_c_db_user;

--
-- Name: _dbcopiestablesstates; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiestablesstates (
    _copyid bytea NOT NULL,
    _tablename public.mvarchar(256) NOT NULL,
    _tablestate integer NOT NULL,
    _trnum integer
);
ALTER TABLE ONLY public._dbcopiestablesstates ALTER COLUMN _copyid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiestablesstates OWNER TO one_c_db_user;

--
-- Name: _dbcopiestrchanges; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiestrchanges (
    _copyid bytea NOT NULL,
    _tablename public.mvarchar(256) NOT NULL,
    _trnum integer NOT NULL,
    _chid bytea NOT NULL
);
ALTER TABLE ONLY public._dbcopiestrchanges ALTER COLUMN _copyid SET STORAGE PLAIN;
ALTER TABLE ONLY public._dbcopiestrchanges ALTER COLUMN _chid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiestrchanges OWNER TO one_c_db_user;

--
-- Name: _dbcopiestrchobj; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiestrchobj (
    _chid bytea NOT NULL,
    _chobj bytea
);
ALTER TABLE ONLY public._dbcopiestrchobj ALTER COLUMN _chid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiestrchobj OWNER TO one_c_db_user;

--
-- Name: _dbcopiestrlogs; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiestrlogs (
    _trnum integer NOT NULL,
    _trtime timestamp without time zone NOT NULL,
    _trid bytea NOT NULL,
    _trlog bytea
);
ALTER TABLE ONLY public._dbcopiestrlogs ALTER COLUMN _trid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiestrlogs OWNER TO one_c_db_user;

--
-- Name: _dbcopiestrlogs__trnum_seq; Type: SEQUENCE; Schema: public; Owner: one_c_db_user
--

CREATE SEQUENCE public._dbcopiestrlogs__trnum_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


ALTER SEQUENCE public._dbcopiestrlogs__trnum_seq OWNER TO one_c_db_user;

--
-- Name: _dbcopiestrlogs__trnum_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: one_c_db_user
--

ALTER SEQUENCE public._dbcopiestrlogs__trnum_seq OWNED BY public._dbcopiestrlogs._trnum;


--
-- Name: _dbcopiestrtables; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiestrtables (
    _trnum integer,
    _trtime timestamp without time zone,
    _tablename public.mvarchar(256) NOT NULL
);


ALTER TABLE public._dbcopiestrtables OWNER TO one_c_db_user;

--
-- Name: _dbcopiesupdates; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiesupdates (
    _copyid bytea NOT NULL,
    _trnum integer,
    _trtime timestamp without time zone,
    _updateid bytea,
    _lastupdateresult numeric(2,0),
    _lastupdateerror bytea
);
ALTER TABLE ONLY public._dbcopiesupdates ALTER COLUMN _copyid SET STORAGE PLAIN;
ALTER TABLE ONLY public._dbcopiesupdates ALTER COLUMN _updateid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiesupdates OWNER TO one_c_db_user;

--
-- Name: _dbcopiesupdatestat; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiesupdatestat (
    _copyid bytea NOT NULL,
    _updatetime timestamp without time zone NOT NULL,
    _tranpersec numeric(16,4) NOT NULL
);
ALTER TABLE ONLY public._dbcopiesupdatestat ALTER COLUMN _copyid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiesupdatestat OWNER TO one_c_db_user;

--
-- Name: _dbcopiesupdatetablestat; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbcopiesupdatetablestat (
    _copyid bytea NOT NULL,
    _tablename public.mvarchar(256) NOT NULL,
    _updatetime timestamp without time zone NOT NULL,
    _transfertime numeric(10,0) NOT NULL,
    _isportion boolean NOT NULL
);
ALTER TABLE ONLY public._dbcopiesupdatetablestat ALTER COLUMN _copyid SET STORAGE PLAIN;


ALTER TABLE public._dbcopiesupdatetablestat OWNER TO one_c_db_user;

--
-- Name: _dbsegments; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbsegments (
    _segmentid bytea NOT NULL,
    _segmentname public.mvarchar(256) NOT NULL,
    _path public.mvarchar(256) NOT NULL
);
ALTER TABLE ONLY public._dbsegments ALTER COLUMN _segmentid SET STORAGE PLAIN;


ALTER TABLE public._dbsegments OWNER TO one_c_db_user;

--
-- Name: _dbsegmentsitems; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dbsegmentsitems (
    _itemid public.mvarchar(256) NOT NULL,
    _segmentid bytea NOT NULL,
    _forindex boolean NOT NULL,
    _applied boolean NOT NULL
);
ALTER TABLE ONLY public._dbsegmentsitems ALTER COLUMN _segmentid SET STORAGE PLAIN;


ALTER TABLE public._dbsegmentsitems OWNER TO one_c_db_user;

--
-- Name: _defaultinternalsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._defaultinternalsettings (
    _objectkey public.mvarchar(256) NOT NULL,
    _version bytea NOT NULL,
    _settingsdata bytea,
    _changedate timestamp without time zone
);
ALTER TABLE ONLY public._defaultinternalsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._defaultinternalsettings OWNER TO one_c_db_user;

--
-- Name: _defaultsystemsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._defaultsystemsettings (
    _objectkey public.mvarchar(256) NOT NULL,
    _version bytea NOT NULL,
    _settingsdata bytea,
    _changedate timestamp without time zone
);
ALTER TABLE ONLY public._defaultsystemsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._defaultsystemsettings OWNER TO one_c_db_user;

--
-- Name: _dynlistsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._dynlistsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._dynlistsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._dynlistsettings OWNER TO one_c_db_user;

--
-- Name: _errorprocessingsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._errorprocessingsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._errorprocessingsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._errorprocessingsettings OWNER TO one_c_db_user;

--
-- Name: _extensionsinfo; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._extensionsinfo (
    _idrref bytea NOT NULL,
    _extensionorder numeric(9,0) NOT NULL,
    _extname public.mvarchar(255) NOT NULL,
    _updatetime timestamp without time zone NOT NULL,
    _extensionusepurpose numeric(2,0) NOT NULL,
    _extensionscope numeric(2,0) NOT NULL,
    _extensionzippedinfo bytea NOT NULL,
    _masternode public.mvarchar NOT NULL,
    _usedindistributedinfobase boolean NOT NULL,
    _version integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._extensionsinfo OWNER TO one_c_db_user;

--
-- Name: _extensionsinfongs; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._extensionsinfongs (
    _idrref bytea NOT NULL,
    _extensionorder numeric(9,0) NOT NULL,
    _extname public.mvarchar(255) NOT NULL,
    _updatetime timestamp without time zone NOT NULL,
    _extensionusepurpose numeric(2,0) NOT NULL,
    _extensionscope numeric(2,0) NOT NULL,
    _extensionzippedinfo bytea NOT NULL,
    _masternode public.mvarchar NOT NULL,
    _usedindistributedinfobase boolean NOT NULL,
    _version integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._extensionsinfongs OWNER TO one_c_db_user;

--
-- Name: _extensionsrestruct; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._extensionsrestruct (
    _extdataid bytea NOT NULL,
    _restructdata bytea NOT NULL,
    _restructdataint numeric(9,0) NOT NULL,
    _restructdatatype numeric(9,0) NOT NULL
);
ALTER TABLE ONLY public._extensionsrestruct ALTER COLUMN _extdataid SET STORAGE PLAIN;


ALTER TABLE public._extensionsrestruct OWNER TO one_c_db_user;

--
-- Name: _extensionsrestructngs; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._extensionsrestructngs (
    _extdataid bytea NOT NULL,
    _restructdata bytea NOT NULL,
    _restructdataint numeric(9,0) NOT NULL,
    _restructdatatype numeric(9,0) NOT NULL
);
ALTER TABLE ONLY public._extensionsrestructngs ALTER COLUMN _extdataid SET STORAGE PLAIN;


ALTER TABLE public._extensionsrestructngs OWNER TO one_c_db_user;

--
-- Name: _frmdtsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._frmdtsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._frmdtsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._frmdtsettings OWNER TO one_c_db_user;

--
-- Name: _internalsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._internalsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._internalsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._internalsettings OWNER TO one_c_db_user;

--
-- Name: _mobileclientdataexchange; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._mobileclientdataexchange (
    _id bytea NOT NULL,
    _version numeric(2,0) NOT NULL,
    _type numeric(2,0) NOT NULL,
    _data bytea,
    _date timestamp without time zone NOT NULL
);
ALTER TABLE ONLY public._mobileclientdataexchange ALTER COLUMN _id SET STORAGE PLAIN;


ALTER TABLE public._mobileclientdataexchange OWNER TO one_c_db_user;

--
-- Name: _odatasettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._odatasettings (
    _metadataobjectuuid bytea NOT NULL
);
ALTER TABLE ONLY public._odatasettings ALTER COLUMN _metadataobjectuuid SET STORAGE PLAIN;


ALTER TABLE public._odatasettings OWNER TO one_c_db_user;

--
-- Name: _reference53; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._reference53 (
    _idrref bytea NOT NULL,
    _version integer DEFAULT 0 NOT NULL,
    _marked boolean NOT NULL,
    _predefinedid bytea NOT NULL,
    _code public.mvarchar(9) NOT NULL,
    _description public.mvarchar(25) NOT NULL,
    _fld54 public.mvarchar(10) NOT NULL,
    _fld55 public.mvarchar(10) NOT NULL,
    _fld56 public.mvarchar(10) NOT NULL
);
ALTER TABLE ONLY public._reference53 ALTER COLUMN _predefinedid SET STORAGE PLAIN;


ALTER TABLE public._reference53 OWNER TO one_c_db_user;

--
-- Name: _refopt; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._refopt (
    _mdid bytea NOT NULL,
    _extid bytea NOT NULL,
    _pdupdmode numeric(1,0) NOT NULL
);
ALTER TABLE ONLY public._refopt ALTER COLUMN _mdid SET STORAGE PLAIN;
ALTER TABLE ONLY public._refopt ALTER COLUMN _extid SET STORAGE PLAIN;


ALTER TABLE public._refopt OWNER TO one_c_db_user;

--
-- Name: _repsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._repsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._repsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._repsettings OWNER TO one_c_db_user;

--
-- Name: _repvarsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._repvarsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._repvarsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._repvarsettings OWNER TO one_c_db_user;

--
-- Name: _sttgrammar; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttgrammar (
    _grammar public.mvarchar(100) NOT NULL,
    _phrase public.mvarchar(100)
);


ALTER TABLE public._sttgrammar OWNER TO one_c_db_user;

--
-- Name: _sttgrammarchecksum; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttgrammarchecksum (
    _grammar public.mvarchar(100) NOT NULL,
    _checksum numeric(10,0) NOT NULL
);


ALTER TABLE public._sttgrammarchecksum OWNER TO one_c_db_user;

--
-- Name: _sttmodels; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttmodels (
    _idrref bytea NOT NULL,
    _modelid bytea NOT NULL,
    _modelcompatibility numeric(5,0) NOT NULL,
    _acoustic public.mvarchar(100) NOT NULL,
    _acousticru public.mvarchar(100) NOT NULL,
    _languagemodel public.mvarchar(100) NOT NULL,
    _languagemodelru public.mvarchar(100) NOT NULL,
    _version public.mvarchar(100) NOT NULL,
    _language public.mvarchar(2) NOT NULL,
    _samplerate numeric(5,0) NOT NULL
);
ALTER TABLE ONLY public._sttmodels ALTER COLUMN _modelid SET STORAGE PLAIN;


ALTER TABLE public._sttmodels OWNER TO one_c_db_user;

--
-- Name: _sttmodelsdesc; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttmodelsdesc (
    _idrref bytea NOT NULL,
    _modelrref bytea NOT NULL
);


ALTER TABLE public._sttmodelsdesc OWNER TO one_c_db_user;

--
-- Name: _sttmodelsdesc_acoustic; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttmodelsdesc_acoustic (
    _sttmodelsdesc_idrref bytea NOT NULL,
    _keyfield bytea NOT NULL,
    _language public.mchar(2) NOT NULL,
    _description public.mvarchar NOT NULL
);


ALTER TABLE public._sttmodelsdesc_acoustic OWNER TO one_c_db_user;

--
-- Name: _sttmodelsdesc_descr; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttmodelsdesc_descr (
    _sttmodelsdesc_idrref bytea NOT NULL,
    _keyfield bytea NOT NULL,
    _language public.mchar(2) NOT NULL,
    _description public.mvarchar NOT NULL
);


ALTER TABLE public._sttmodelsdesc_descr OWNER TO one_c_db_user;

--
-- Name: _sttmodelsdesc_langmodel; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttmodelsdesc_langmodel (
    _sttmodelsdesc_idrref bytea NOT NULL,
    _keyfield bytea NOT NULL,
    _language public.mchar(2) NOT NULL,
    _description public.mvarchar NOT NULL
);


ALTER TABLE public._sttmodelsdesc_langmodel OWNER TO one_c_db_user;

--
-- Name: _sttsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._sttsettings (
    _token public.mvarchar(100) NOT NULL,
    _host public.mvarchar(100)
);


ALTER TABLE public._sttsettings OWNER TO one_c_db_user;

--
-- Name: _systemsettings; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._systemsettings (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._systemsettings ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._systemsettings OWNER TO one_c_db_user;

--
-- Name: _urlexternaldata; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._urlexternaldata (
    _userid public.mvarchar NOT NULL,
    _objectkey public.mvarchar(256) NOT NULL,
    _settingskey public.mvarchar NOT NULL,
    _version bytea NOT NULL,
    _settingspresentation public.mvarchar(256),
    _settingsdata bytea,
    _changedate timestamp without time zone,
    _useridhash numeric(10,0) NOT NULL,
    _settingskeyhash numeric(10,0) NOT NULL
);
ALTER TABLE ONLY public._urlexternaldata ALTER COLUMN _version SET STORAGE PLAIN;


ALTER TABLE public._urlexternaldata OWNER TO one_c_db_user;

--
-- Name: _usersworkhistory; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._usersworkhistory (
    _id bytea NOT NULL,
    _userid bytea NOT NULL,
    _url public.mvarchar NOT NULL,
    _date timestamp without time zone NOT NULL,
    _urlhash numeric(10,0) NOT NULL,
    _ecsactivity boolean
);
ALTER TABLE ONLY public._usersworkhistory ALTER COLUMN _id SET STORAGE PLAIN;
ALTER TABLE ONLY public._usersworkhistory ALTER COLUMN _userid SET STORAGE PLAIN;


ALTER TABLE public._usersworkhistory OWNER TO one_c_db_user;

--
-- Name: _websocketclients; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._websocketclients (
    _id bytea NOT NULL,
    _wsckey public.mvarchar(100) NOT NULL,
    _metadataid bytea NOT NULL,
    _serverurl public.mvarchar(255) NOT NULL,
    _predefined boolean NOT NULL,
    _connectionparameters bytea NOT NULL,
    _ibusername public.mvarchar(100),
    _autoconnect boolean NOT NULL
);
ALTER TABLE ONLY public._websocketclients ALTER COLUMN _id SET STORAGE PLAIN;
ALTER TABLE ONLY public._websocketclients ALTER COLUMN _metadataid SET STORAGE PLAIN;


ALTER TABLE public._websocketclients OWNER TO one_c_db_user;

--
-- Name: _yearoffset; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public._yearoffset (
    ofset integer NOT NULL
);


ALTER TABLE public._yearoffset OWNER TO one_c_db_user;

--
-- Name: binarydata; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.binarydata (
    f_key bytea NOT NULL,
    f_off numeric(18,0) NOT NULL,
    f_num numeric(18,0) NOT NULL,
    f_data bytea NOT NULL
);
ALTER TABLE ONLY public.binarydata ALTER COLUMN f_key SET STORAGE PLAIN;


ALTER TABLE public.binarydata OWNER TO one_c_db_user;

--
-- Name: binarydatastoragecontent; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.binarydatastoragecontent (
    f_key bytea NOT NULL,
    f_type public.mchar(16) NOT NULL,
    f_parent bytea NOT NULL,
    f_id1 bytea NOT NULL,
    f_id2 bytea NOT NULL,
    f_id3 bytea NOT NULL,
    f_id4 bytea NOT NULL,
    f_id5 bytea NOT NULL,
    f_id6 bytea NOT NULL,
    f_str1 public.mchar(80) NOT NULL,
    f_num1 numeric(18,0) NOT NULL,
    f_num2 numeric(18,0) NOT NULL,
    f_num3 numeric(18,0) NOT NULL,
    f_num4 numeric(18,0) NOT NULL,
    f_num5 numeric(18,0) NOT NULL,
    f_vstr1 public.mvarchar NOT NULL,
    f_vstr2 public.mvarchar NOT NULL,
    f_vstr3 public.mvarchar NOT NULL,
    f_vstr4 public.mvarchar NOT NULL
);
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_key SET STORAGE PLAIN;
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_parent SET STORAGE PLAIN;
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_id1 SET STORAGE PLAIN;
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_id2 SET STORAGE PLAIN;
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_id3 SET STORAGE PLAIN;
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_id4 SET STORAGE PLAIN;
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_id5 SET STORAGE PLAIN;
ALTER TABLE ONLY public.binarydatastoragecontent ALTER COLUMN f_id6 SET STORAGE PLAIN;


ALTER TABLE public.binarydatastoragecontent OWNER TO one_c_db_user;

--
-- Name: binarydatastorageversion; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.binarydatastorageversion (
    storageid bytea NOT NULL,
    version timestamp without time zone NOT NULL
);
ALTER TABLE ONLY public.binarydatastorageversion ALTER COLUMN storageid SET STORAGE PLAIN;


ALTER TABLE public.binarydatastorageversion OWNER TO one_c_db_user;

--
-- Name: config; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.config (
    filename public.mvarchar(128) NOT NULL,
    creation timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    attributes integer NOT NULL,
    datasize bigint NOT NULL,
    binarydata bytea NOT NULL,
    partno integer NOT NULL
);


ALTER TABLE public.config OWNER TO one_c_db_user;

--
-- Name: configcas; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.configcas (
    filename public.mvarchar(128) NOT NULL,
    creation timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    attributes integer NOT NULL,
    datasize bigint NOT NULL,
    binarydata bytea NOT NULL,
    partno integer NOT NULL
);


ALTER TABLE public.configcas OWNER TO one_c_db_user;

--
-- Name: configcassave; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.configcassave (
    filename public.mvarchar(128) NOT NULL,
    creation timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    attributes integer NOT NULL,
    datasize bigint NOT NULL,
    binarydata bytea NOT NULL,
    partno integer NOT NULL
);


ALTER TABLE public.configcassave OWNER TO one_c_db_user;

--
-- Name: configsave; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.configsave (
    filename public.mvarchar(128) NOT NULL,
    creation timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    attributes integer NOT NULL,
    datasize bigint NOT NULL,
    binarydata bytea NOT NULL,
    partno integer NOT NULL
);


ALTER TABLE public.configsave OWNER TO one_c_db_user;

--
-- Name: dbschema; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.dbschema (
    serializeddata bytea NOT NULL
);


ALTER TABLE public.dbschema OWNER TO one_c_db_user;

--
-- Name: depotfiles; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.depotfiles (
    filename public.mvarchar(128) NOT NULL,
    creation timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    attributes integer NOT NULL,
    datasize bigint NOT NULL,
    binarydata bytea NOT NULL,
    partno integer NOT NULL
);


ALTER TABLE public.depotfiles OWNER TO one_c_db_user;

--
-- Name: externalbindatastrgsblist; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.externalbindatastrgsblist (
    storageid bytea NOT NULL,
    blobid bytea NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    blobsize numeric(10,0) NOT NULL,
    isdeleted boolean NOT NULL
);
ALTER TABLE ONLY public.externalbindatastrgsblist ALTER COLUMN storageid SET STORAGE PLAIN;
ALTER TABLE ONLY public.externalbindatastrgsblist ALTER COLUMN blobid SET STORAGE PLAIN;


ALTER TABLE public.externalbindatastrgsblist OWNER TO one_c_db_user;

--
-- Name: externalbindatastrgslist; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.externalbindatastrgslist (
    storageid bytea NOT NULL,
    name public.mchar(80) NOT NULL,
    connectionsettings_url public.mvarchar NOT NULL,
    connectionsettings_urltype numeric(1,0) NOT NULL,
    accessid public.mvarchar NOT NULL,
    secretkey public.mvarchar NOT NULL,
    region public.mvarchar NOT NULL,
    minwritedatasize numeric(18,0) NOT NULL,
    enablewrite boolean NOT NULL,
    isdeleted boolean NOT NULL
);
ALTER TABLE ONLY public.externalbindatastrgslist ALTER COLUMN storageid SET STORAGE PLAIN;


ALTER TABLE public.externalbindatastrgslist OWNER TO one_c_db_user;

--
-- Name: files; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.files (
    filename public.mvarchar(128) NOT NULL,
    creation timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    attributes integer NOT NULL,
    datasize bigint NOT NULL,
    binarydata bytea NOT NULL,
    partno integer NOT NULL
);


ALTER TABLE public.files OWNER TO one_c_db_user;

--
-- Name: ibversion; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.ibversion (
    ibversion integer NOT NULL,
    platformversionreq integer NOT NULL
);


ALTER TABLE public.ibversion OWNER TO one_c_db_user;

--
-- Name: params; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.params (
    filename public.mvarchar(128) NOT NULL,
    creation timestamp without time zone NOT NULL,
    modified timestamp without time zone NOT NULL,
    attributes integer NOT NULL,
    datasize bigint NOT NULL,
    binarydata bytea NOT NULL,
    partno integer NOT NULL
);


ALTER TABLE public.params OWNER TO one_c_db_user;

--
-- Name: schemastorage; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.schemastorage (
    schemaid integer NOT NULL,
    status integer NOT NULL,
    currentschema bytea NOT NULL,
    newgencreated bytea NOT NULL,
    newgendropped bytea NOT NULL
);


ALTER TABLE public.schemastorage OWNER TO one_c_db_user;

--
-- Name: v8cmsdpwds; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.v8cmsdpwds (
    pwdhash public.mvarchar(256) NOT NULL
);


ALTER TABLE public.v8cmsdpwds OWNER TO one_c_db_user;

--
-- Name: v8userpwdplcs; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.v8userpwdplcs (
    name public.mvarchar(64) NOT NULL,
    data bytea NOT NULL
);


ALTER TABLE public.v8userpwdplcs OWNER TO one_c_db_user;

--
-- Name: v8users; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.v8users (
    id bytea NOT NULL,
    name public.mvarchar(64) NOT NULL,
    descr public.mvarchar(128) NOT NULL,
    osname public.mvarchar(128),
    changed timestamp without time zone NOT NULL,
    rolesid numeric(10,0) NOT NULL,
    show boolean NOT NULL,
    data bytea NOT NULL,
    eauth boolean,
    admrole boolean,
    ussprh numeric(10,0),
    email public.mvarchar(128)
);
ALTER TABLE ONLY public.v8users ALTER COLUMN id SET STORAGE PLAIN;


ALTER TABLE public.v8users OWNER TO one_c_db_user;

--
-- Name: v8usersmatkeys; Type: TABLE; Schema: public; Owner: one_c_db_user
--

CREATE TABLE public.v8usersmatkeys (
    id bytea NOT NULL,
    providersh public.mvarchar(128) NOT NULL,
    matkeysh public.mvarchar(128) NOT NULL,
    data bytea NOT NULL
);
ALTER TABLE ONLY public.v8usersmatkeys ALTER COLUMN id SET STORAGE PLAIN;


ALTER TABLE public.v8usersmatkeys OWNER TO one_c_db_user;

--
-- Name: _dbcopiesinitiallast _blocknum; Type: DEFAULT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public._dbcopiesinitiallast ALTER COLUMN _blocknum SET DEFAULT nextval('public._dbcopiesinitiallast__blocknum_seq'::regclass);


--
-- Name: _dbcopiestrlogs _trnum; Type: DEFAULT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public._dbcopiestrlogs ALTER COLUMN _trnum SET DEFAULT nextval('public._dbcopiestrlogs__trnum_seq'::regclass);


--
-- Data for Name: _accopt; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._accopt (_mdid, _extid, _pdupdmode) FROM stdin;
\.


--
-- Data for Name: _bots; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._bots (_id, _clientid, _ecsuserid, _mdbotid, _ibusername, _param, _predefined, _needsupdate) FROM stdin;
\.


--
-- Data for Name: _chrcopt; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._chrcopt (_mdid, _extid, _pdupdmode) FROM stdin;
\.


--
-- Data for Name: _ckindsopt; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._ckindsopt (_mdid, _extid, _pdupdmode) FROM stdin;
\.


--
-- Data for Name: _commonsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._commonsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
\.


--
-- Data for Name: _datahistoryafterwritequeue; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._datahistoryafterwritequeue (_metadataid, _historydataid, _versionnumber) FROM stdin;
\.


--
-- Data for Name: _datahistorylatestversions; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._datahistorylatestversions (_metadataid, _dataid, _historydataid, _versionnumber, _content) FROM stdin;
\.


--
-- Data for Name: _datahistorymetadata; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._datahistorymetadata (_metadataid, _issettings, _isactual, _metadataversionnumber, _content, _isextensions, _actiononaccept) FROM stdin;
\.


--
-- Data for Name: _datahistoryqueue0; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._datahistoryqueue0 (_metadataid, _dataid, _position, _content) FROM stdin;
\.


--
-- Data for Name: _datahistorysettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._datahistorysettings (_metadataid, _content) FROM stdin;
\.


--
-- Data for Name: _datahistoryversions; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._datahistoryversions (_historydataid, _versionnumber, _metadataversionnumber, _date, _changetype, _userid, _username, _userfullname, _comment, _transaction, _node_type, _node_rtref, _node_rrref, _content) FROM stdin;
\.


--
-- Data for Name: _dbcopies; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopies (_copyid, _copyname, _useintaccelerator, _repltype, _dbtype, _dbserver, _dbname, _dbuser, _dbpassword, _createdb, _version, _storagevariant) FROM stdin;
\.


--
-- Data for Name: _dbcopiesinfobaseuse; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiesinfobaseuse (_id, _description) FROM stdin;
\\xbb757eb06065c83c4c5b17e6864d85db	192.168.56.103:1541 : one_c_lab
\.


--
-- Data for Name: _dbcopiesinitiallast; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiesinitiallast (_copyid, _tablename, _blocknum, _firstkey, _lastkey, _blockstate) FROM stdin;
\.


--
-- Data for Name: _dbcopiessettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiessettings (_copyid, _copycontent, _copyschema, _version) FROM stdin;
\.


--
-- Data for Name: _dbcopiestablesstates; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiestablesstates (_copyid, _tablename, _tablestate, _trnum) FROM stdin;
\.


--
-- Data for Name: _dbcopiestrchanges; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiestrchanges (_copyid, _tablename, _trnum, _chid) FROM stdin;
\.


--
-- Data for Name: _dbcopiestrchobj; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiestrchobj (_chid, _chobj) FROM stdin;
\.


--
-- Data for Name: _dbcopiestrlogs; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiestrlogs (_trnum, _trtime, _trid, _trlog) FROM stdin;
\.


--
-- Data for Name: _dbcopiestrtables; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiestrtables (_trnum, _trtime, _tablename) FROM stdin;
\.


--
-- Data for Name: _dbcopiesupdates; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiesupdates (_copyid, _trnum, _trtime, _updateid, _lastupdateresult, _lastupdateerror) FROM stdin;
\.


--
-- Data for Name: _dbcopiesupdatestat; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiesupdatestat (_copyid, _updatetime, _tranpersec) FROM stdin;
\.


--
-- Data for Name: _dbcopiesupdatetablestat; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbcopiesupdatetablestat (_copyid, _tablename, _updatetime, _transfertime, _isportion) FROM stdin;
\.


--
-- Data for Name: _dbsegments; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbsegments (_segmentid, _segmentname, _path) FROM stdin;
\.


--
-- Data for Name: _dbsegmentsitems; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dbsegmentsitems (_itemid, _segmentid, _forindex, _applied) FROM stdin;
\.


--
-- Data for Name: _defaultinternalsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._defaultinternalsettings (_objectkey, _version, _settingsdata, _changedate) FROM stdin;
\.


--
-- Data for Name: _defaultsystemsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._defaultsystemsettings (_objectkey, _version, _settingsdata, _changedate) FROM stdin;
\.


--
-- Data for Name: _dynlistsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._dynlistsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
\.


--
-- Data for Name: _errorprocessingsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._errorprocessingsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
\.


--
-- Data for Name: _extensionsinfo; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._extensionsinfo (_idrref, _extensionorder, _extname, _updatetime, _extensionusepurpose, _extensionscope, _extensionzippedinfo, _masternode, _usedindistributedinfobase, _version) FROM stdin;
\.


--
-- Data for Name: _extensionsinfongs; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._extensionsinfongs (_idrref, _extensionorder, _extname, _updatetime, _extensionusepurpose, _extensionscope, _extensionzippedinfo, _masternode, _usedindistributedinfobase, _version) FROM stdin;
\.


--
-- Data for Name: _extensionsrestruct; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._extensionsrestruct (_extdataid, _restructdata, _restructdataint, _restructdatatype) FROM stdin;
\.


--
-- Data for Name: _extensionsrestructngs; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._extensionsrestructngs (_extdataid, _restructdata, _restructdataint, _restructdatatype) FROM stdin;
\.


--
-- Data for Name: _frmdtsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._frmdtsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
\.


--
-- Data for Name: _internalsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._internalsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
	Common/AllFormsSettingsVersion		\\xaa2c9a7b0649a64743e5a18c57382523		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7fc100000000000000004401b406c802b406000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000819a0a555401b4066448617300000000000020a102000000010000009801b4069801b4060100000001000000ffffffff00000000000000009801b40674f7884287818181d573d5058d0a21a145b85ecc0000000000000000a002b406b802b4060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0a3030303030303238203030303030303238203766666666666666200d0a60f7c82d6545020060f7c82d65450200000000002400530074007200650061006d002400000000000d0a3030303030303038203030303030323030203766666666666666200d0aefbbbf7b2255227d000000050000002c22d09ab002b406222c312c00000000000065001100000069006f00010000007b322c0d09000000390035005c01b406350061000a7b307d2c312c302c322c302c322c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c332c302c332c322c332c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b33382c0d0a7b332c307d2c302c302c322c322c312c322c322c322c322c322c322c322c322c322c0d0a7b2255227d2c0d0a7b2255227d2c22222c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c302c302c322c332c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c0d0a7b353030362c307d2c0d0a7b302c307d2c322c0d0a7b312c307d2c0d0a7b312c307d2c322c312c302c0d0a7b225061747465726e227d2c312c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c	2026-09-15 12:05:58	0	0
\.


--
-- Data for Name: _mobileclientdataexchange; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._mobileclientdataexchange (_id, _version, _type, _data, _date) FROM stdin;
\.


--
-- Data for Name: _odatasettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._odatasettings (_metadataobjectuuid) FROM stdin;
\.


--
-- Data for Name: _reference53; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._reference53 (_idrref, _version, _marked, _predefinedid, _code, _description, _fld54, _fld55, _fld56) FROM stdin;
\\x9412080027b9b2bd11f1b0fdff19dcc1	0	f	\\x00000000000000000000000000000000	000000001		Никита	Фролов	Васильевич
\.


--
-- Data for Name: _refopt; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._refopt (_mdid, _extid, _pdupdmode) FROM stdin;
\.


--
-- Data for Name: _repsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._repsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
\.


--
-- Data for Name: _repvarsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._repvarsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
\.


--
-- Data for Name: _sttgrammar; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttgrammar (_grammar, _phrase) FROM stdin;
\.


--
-- Data for Name: _sttgrammarchecksum; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttgrammarchecksum (_grammar, _checksum) FROM stdin;
\.


--
-- Data for Name: _sttmodels; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttmodels (_idrref, _modelid, _modelcompatibility, _acoustic, _acousticru, _languagemodel, _languagemodelru, _version, _language, _samplerate) FROM stdin;
\.


--
-- Data for Name: _sttmodelsdesc; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttmodelsdesc (_idrref, _modelrref) FROM stdin;
\.


--
-- Data for Name: _sttmodelsdesc_acoustic; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttmodelsdesc_acoustic (_sttmodelsdesc_idrref, _keyfield, _language, _description) FROM stdin;
\.


--
-- Data for Name: _sttmodelsdesc_descr; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttmodelsdesc_descr (_sttmodelsdesc_idrref, _keyfield, _language, _description) FROM stdin;
\.


--
-- Data for Name: _sttmodelsdesc_langmodel; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttmodelsdesc_langmodel (_sttmodelsdesc_idrref, _keyfield, _language, _description) FROM stdin;
\.


--
-- Data for Name: _sttsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._sttsettings (_token, _host) FROM stdin;
\.


--
-- Data for Name: _systemsettings; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._systemsettings (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
	HistoryDlgNew/Такси/НастройкиОкнаТонкогоКлиента		\\xba3768480f2dbc144dded0b860045a9e		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f9718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa82a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a3812020204cbb757eb06065c83c9a096f6e655f635f6c6162d5db854d86e6175b4cbb757eb06065c83c818681818283202020202000000000000000000000000000000000000000000000000000000000000000000500000049c5ad85546165155330b78d000000000000b78b208fbf5932b78db501ab74c18f3d5130b78b668fda6b30b7898f425932b787ab6ec18f4d5130b78b5e8fea6b30b78b10ab29c18f3d5130b78b268fda6b30b7828f425932b783a1c2ab10c18f095230b78b10af1b4332b78db390c18f3d5130b78d63798fda6b30b78dac0d8f425932b78da409adea0cc18f3d5130b78dc60c8fda6b30b78b108f425932b78b14af508ffc00c18f225330b78f0fa374008fea6b30b78fcf5939008fbf5932b78f72924e00ad4002c18f225330b78d80018fbf5932b78bc0ab14c18f225330b78b14af2a7515000d0a3030303030303238203030303030303238203766666666666666200d0a6033bf2d654502006033bf2d65450200000000002400530074007200650061006d002400000000000d0a3030303030303561203030303030323030203766666666666666200d0aefbbbf7b2223222c36336132626435612d363765332d343064312d383664642d6335326133313230396461322c0d0a7b332c312c22466f726d53657474696e67735f544449222c227b342c312c0d0a7b307d0d0a7d227d0d0a7d818181818181818181818182cb2395969825b0fb9da14eb120c4dcb772ff4ac120a2cb239533dc5eba368912429ed2485e759203aa8b52a1818181a3c120f21b1bcc5fdee323e7082e0cc282afceb540f52e5bb1ce52ee5c42537f5091a08a13543d6c66957a45ca5dc55609bf6695cebe311cc7a982a08410a41e1e20041d0882d1049230c00029815280849389044a3889796314b59b14cc379fd02e457a03945c0aec8e554cad2ba6599a8f09aff9cc6f6c3a5e834103ca608012366454da7ae61881381980a038c8f08da82c2ec1790d3b203002621083550fe7a4039e1cc81009be1683a25235425c580a44a0d281c1e62696e5a0090dab2093b039adc1128a0850a08bf42680856f7ad2962c6cbbd6fe34ca043806e466e1f5c0a50e56620199d2a1ccc4052446e04a0a42bf90ffe1b450324f497594d2c5ee9913ec3b511bd49c85d4c2412a5c921cbe055d2b5b113ddb83d218480a940542143f58f3757021ec7d4d4a57c2ba1901000000440051006f004a00430051006b004a005000430039006b00590033004e006a0062003300490036000d000a006100580052006c00620054	2026-09-15 12:04:54	0	0
	ОсновноеОкно/Такси/НастройкиОкнаТонкогоКлиента		\\x9cdcdf1c4b475e6a4fd74cdb802c5e19		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f9718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa82a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a3812020204cbb757eb06065c83c9a096f6e655f635f6c6162d5db854d86e6175b4cbb757eb06065c83c818681818283202020202000000000000000000000000000000000000000000000000000000000000000000500000049c5ad85546165155330b78d000000000000b78b208fbf5932b78db501ab74c18f3d5130b78b668fda6b30b7898f425932b787ab6ec18f4d5130b78b5e8fea6b30b78b10ab29c18f3d5130b78b268fda6b30b7828f425932b783a1c2ab10c18f095230b78b10af1b4332b78db390c18f3d5130b78d63798fda6b30b78dac0d8f425932b78da409adea0cc18f3d5130b78dc60c8fda6b30b78b108f425932b78b14af508ffc00c18f225330b78f0fa374008fea6b30b78fcf5939008fbf5932b78f72924e00ad4002c18f225330b78d80018fbf5932b78bc0ab14c18f225330b78b14af2a7515000d0a3030303030303238203030303030303238203766666666666666200d0a6033bf2d654502006033bf2d65450200000000002400530074007200650061006d002400000000000d0a3030303030313033203030303030323030203766666666666666200d0aefbbbf7b2223222c36336132626435612d363765332d343064312d383664642d6335326133313230396461322c0d0a7b332c322c2253657474696e677353706c69747461626c65466f726d53706c6974746572506f735f544449222c227b322c3465312c3465312c3465312c3465317d222c22546f704c6576656c54617869506c75732f5f544449222c227b372c312c3237372c3136312c323139352c313037382c302c302c302c302c302c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c302c4141414141414141414141414141414141414141414141414141413d2c302c302c302c302c302c312c307d227d0d0a7da6599a8f09aff9cc6f6c3a5e834103ca608012366454da7ae61881381980a038c8f08da82c2ec1790d3b203002621083550fe7a4039e1cc81009be1683a25235425c580a44a0d281c1e62696e5a0090dab2093b039adc1128a0850a08bf42680856f7ad2962c6cbbd6fe34ca043806e466e1f5c0a50e56620199d2a1ccc4052446e04a0a42bf90ffe1b450324f497594d2c5ee9913ec3b511bd49c85d4c2412a5c921cbe055d2b5b113ddb83d218480a940542143f58f3757021ec7d4d4a57c2ba1901000000440051006f004a00430051006b004a005000430039006b00590033004e006a0062003300490036000d000a006100580052006c00620054	2026-09-15 12:04:54	0	0
	Справочник.DevOpsTest.ФормаСписка/НастройкиФормы		\\xbceb6d97060df4be43a5518bc3af6a47		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f9718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa85a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a3812020204cbb757eb06065c83c9a096f6e655f635f6c6162d5db854d86e6175b4cbb757eb06065c83c81868181828320202020200000000000000000000000000000000000000000000000000000000000000000050000005231554454616918396861500000000000006d72010000000100000098616918986169180100000000000000010000000000000000000000986169187a4249733748526b486841424e71792b6732372f0000000000000000a0626918000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0a3030303030303238203030303030303238203766666666666666200d0a6015c42d654502006015c42d65450200000000002400530074007200650061006d002400000000000d0a3030303032626137203030303032626137203766666666666666200d0aefbbbf7b2223222c32366464373936362d373365322d343933652d623366322d6365656466366239663063392c0d0a7b372c0d0a7b342c38313761356262382d646438382d343361392d383130302d6463303866623737383639647d2c0d0a7b35392c302c302c302c302c312c302c302c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c312c0d0a7b312c307d2c312c302c312c312c312c302c312c312c312c0d0a7b224e222c307d2c0d0a7b302c312c307d2c0d0a7b307d2c312c0d0a7b32322c0d0a7b2d312c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c317d2c307d0d0a7d2c392c22d0a4d0bed180d0bcd0b0d09ad0bed0bcd0b0d0bdd0b4d0bdd0b0d18fd09fd0b0d0bdd0b5d0bbd18c222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c302c312c307d2c302c312c302c302c302c332c332c307d2c312c31343363303066372d613432642d346364372d393138392d3838653434363764633736382c0d0a7b37332c0d0a7b332c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c317d2c307d0d0a7d2c22d0a1d0bfd0b8d181d0bed0ba222c302c302c302c0d0a7b312c307d2c0d0a7b312c307d2c0d0a7b312c0d0a7b317d0d0a7d2c302c312c302c302c312c312c312c302c302c302c302c302c312c302c312c312c302c312c322c322c312c302c302c302c312c302c322c312c302c312c312c0d0a7b312c0d0a7b31303030303030307d0d0a7d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c302c31332c352c0d0a7b2242222c307d2c362c0d0a7b224e222c36307d2c372c0d0a7b2223222c32666463383865632d376339622d343363642d386261352d3837336630343362646438382c0d0a7b302c30303031303130313030303030302c30303031303130313030303030307d0d0a7d2c382c0d0a7b2223222c35396566326238302d633836622d313164352d613363312d3030353062616530613737362c307d2c392c0d0a7b2242222c307d2c31302c0d0a7b2255227d2c31312c0d0a7b2242222c317d2c31322c0d0a7b2242222c307d2c31342c0d0a7b2223222c65616337626661302d313062342d343336392d393936632d6432353838373161643531392c307d2c31352c0d0a7b2255227d2c31362c0d0a7b224e222c317d2c31392c0d0a7b2253222c22227d2c32302c0d0a7b2242222c317d2c0d0a7b302c312c307d2c0d0a7b307d2c312c0d0a7b32322c0d0a7b342c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d0a1d0bfd0b8d181d0bed0bad09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b32322c0d0a7b352c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c317d2c307d0d0a7d2c392c22d0a1d0bfd0b8d181d0bed0bad09ad0bed0bcd0b0d0bdd0b4d0bdd0b0d18fd09fd0b0d0bdd0b5d0bbd18c222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c302c302c307d2c302c312c302c302c302c332c332c307d2c322c37376666636332392d376632642d343232332d623232662d3139363636653732353062612c0d0a7b34382c0d0a7b32342c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c307d2c307d0d0a7d2c312c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5222c312c302c0d0a7b312c307d2c0d0a7b312c307d2c0d0a7b322c0d0a7b317d2c0d0a7b337d0d0a7d2c0d0a7b307d2c312c302c322c312c322c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c332c302c332c312c332c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b31322c302c302c322c322c322c0d0a7b312c307d2c302c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c322c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d2c312c302c302c312c302c327d2c0d0a7b302c312c307d2c312c0d0a7b32322c0d0a7b32352c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5d09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b225061747465726e222c0d0a7b2253222c32352c317d0d0a7d2c0d0a7b225061747465726e227d2c22d0a1d09fd098d0a1d09ed09a2e4445534352495054494f4e222c22222c0d0a7b307d2c302c302c312c0d0a7b31322c0d0a7b32362c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5d0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c332c332c302c302c302c302c322c302c312c312c0d0a7b32322c0d0a7b307d2c312c302c302c31302c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5d09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0ba222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b302c312c302c317d2c302c312c302c302c302c332c332c307d2c302c302c322c302c302c312c322c302c302c307d2c37376666636332392d376632642d343232332d623232662d3139363636653732353062612c0d0a7b34382c0d0a7b32382c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c307d2c307d0d0a7d2c312c22d09ad0bed0b4222c312c302c0d0a7b312c307d2c0d0a7b312c307d2c0d0a7b322c0d0a7b317d2c0d0a7b317d0d0a7d2c0d0a7b307d2c312c302c322c302c322c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c332c302c332c312c332c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b31322c302c302c322c322c322c0d0a7b312c307d2c302c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c322c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d2c312c302c302c312c302c327d2c0d0a7b302c312c307d2c312c0d0a7b32322c0d0a7b32392c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d09ad0bed0b4d09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b225061747465726e222c0d0a7b2253222c392c317d0d0a7d2c0d0a7b225061747465726e227d2c22d0a1d09fd098d0a1d09ed09a2e434f4445222c22222c0d0a7b307d2c302c302c312c0d0a7b31322c0d0a7b33302c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d09ad0bed0b4d0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c332c332c302c302c302c302c322c302c312c312c0d0a7b32322c0d0a7b307d2c312c302c302c31302c22d09ad0bed0b4d09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0ba222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b302c312c302c317d2c302c312c302c302c302c332c332c307d2c302c302c322c302c302c312c322c302c302c307d2c322c322c312c302c0d0a7b225061747465726e222c0d0a7b2223222c36356162616432342d383338622d343938372d386233352d6564396532626434643963387d0d0a7d2c22d0a1d09fd098d0a1d09ed09a222c2244454641554c5450494354555245222c322c322c302c312c0d0a7b31322c0d0a7b362c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c302c302c302c312c0d0a7b362c0d0a7b372c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad0a1d182d180d0bed0bad0b0d09fd0bed0b8d181d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c312c0d0a7b312c302c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c312c307d2c312c302c307d2c312c0d0a7b32322c0d0a7b382c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d0a1d0bfd0b8d181d0bed0bad0a1d182d180d0bed0bad0b0d09fd0bed0b8d181d0bad0b0d09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b31322c0d0a7b392c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad0a1d182d180d0bed0bad0b0d09fd0bed0b8d181d0bad0b0d0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c322c0d0a7b332c307d2c302c332c332c302c22227d2c312c0d0a7b362c0d0a7b31302c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c312c22d0a1d0bfd0b8d181d0bed0bad0a1d0bed181d182d0bed18fd0bdd0b8d0b5d09fd180d0bed181d0bcd0bed182d180d0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c312c0d0a7b312c302c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b382c332c302c312c3130307d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d2c332c0d0a7b302c312c307d2c312c302c307d2c312c0d0a7b32322c0d0a7b31312c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d0a1d0bfd0b8d181d0bed0bad0a1d0bed181d182d0bed18fd0bdd0b8d0b5d09fd180d0bed181d0bcd0bed182d180d0b0d09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b31322c0d0a7b31322c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad0a1d0bed181d182d0bed18fd0bdd0b8d0b5d09fd180d0bed181d0bcd0bed182d180d0b0d0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c322c0d0a7b332c317d2c302c332c332c302c22227d2c312c0d0a7b362c0d0a7b31332c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c322c22d0a1d0bfd0b8d181d0bed0bad0a3d0bfd180d0b0d0b2d0bbd0b5d0bdd0b8d0b5d09fd0bed0b8d181d0bad0bed0bc222c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c312c0d0a7b312c302c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c312c307d2c312c302c302c327d2c312c0d0a7b32322c0d0a7b31342c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d0a1d0bfd0b8d181d0bed0bad0a3d0bfd180d0b0d0b2d0bbd0b5d0bdd0b8d0b5d09fd0bed0b8d181d0bad0bed0bcd09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b31322c0d0a7b31352c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad0a3d0bfd180d0b0d0b2d0bbd0b5d0bdd0b8d0b5d09fd0bed0b8d181d0bad0bed0bcd0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c322c0d0a7b332c327d2c302c332c332c302c22227d2c302c312c302c302c312c302c332c332c302c312c302c302c302c302c312c302c322c322c302c302c22222c22222c302c312c0d0a7b32322c0d0a7b307d2c312c302c302c31302c22d0a1d0bfd0b8d181d0bed0bad09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0ba222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b302c312c302c317d2c302c312c302c302c302c332c332c307d2c302c322c312c302c312c0d0a7b32322c0d0a7b307d2c312c302c302c31312c22d0a1d0bfd0b8d181d0bed0bad094d0b5d0b9d181d182d0b2d0b8d18fd0a1d182d180d0bed0bad0b8222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b302c312c302c317d2c302c312c302c302c302c332c332c307d2c322c302c322c312c302c302c302c302c302c312c0d0a7b362c0d0a7b307d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0bad0a1d182d180d0bed0bad0b0d09fd0bed0b8d181d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c312c0d0a7b312c302c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c312c307d2c312c302c307d2c312c0d0a7b32322c0d0a7b307d2c302c302c302c382c22d0a1d0bfd0b8d181d0bed0bad09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0bad0a1d182d180d0bed0bad0b0d09fd0bed0b8d181d0bad0b0d09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b31322c0d0a7b307d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0bad0a1d182d180d0bed0bad0b0d09fd0bed0b8d181d0bad0b0d0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c322c0d0a7b332c307d2c302c332c332c302c22d0a1d0bfd0b8d181d0bed0bad0a1d182d180d0bed0bad0b0d09fd0bed0b8d181d0bad0b0227d2c312c0d0a7b362c0d0a7b307d2c302c302c302c322c22d0a1d0bfd0b8d181d0bed0bad09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0bad0a3d0bfd180d0b0d0b2d0bbd0b5d0bdd0b8d0b5d09fd0bed0b8d181d0bad0bed0bc222c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c312c0d0a7b312c302c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c312c307d2c312c302c302c327d2c312c0d0a7b32322c0d0a7b307d2c302c302c302c382c22d0a1d0bfd0b8d181d0bed0bad09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0bad0a3d0bfd180d0b0d0b2d0bbd0b5d0bdd0b8d0b5d09fd0bed0b8d181d0bad0bed0bcd09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b31322c0d0a7b307d2c302c302c302c302c22d0a1d0bfd0b8d181d0bed0bad09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0bad0a3d0bfd180d0b0d0b2d0bbd0b5d0bdd0b8d0b5d09fd0bed0b8d181d0bad0bed0bcd0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c322c0d0a7b332c327d2c302c332c332c302c22d0a1d0bfd0b8d181d0bed0bad0a3d0bfd180d0b0d0b2d0bbd0b5d0bdd0b8d0b5d09fd0bed0b8d181d0bad0bed0bc227d0d0a7d2c22222c22222c312c0d0a7b32322c0d0a7b302c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c372c224e6176696761746f72222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c302c302c312c302c312c0d0a7b31322c0d0a7b302c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c224e6176696761746f72457874656e646564546f6f6c746970222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c302c332c332c307d2c312c22222c302c302c302c302c302c302c332c332c302c312c302c3130302c312c312c302c302c302c0d0a7b35392c307d2c312c0d0a7b312c307d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c302c302c332c302c322c342c302c302c322c307d2c0d0a7b0d0a7b32322c0d0a7b307d2c302c302c302c372c224e6176696761746f72222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c302c302c312c302c312c0d0a7b31322c0d0a7b307d2c302c302c302c302c224e6176696761746f72457874656e646564546f6f6c746970222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c302c332c332c307d0d0a7d2c322c0d0a7b22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5222c0d0a7b312c302c302c312c312c0d0a7b312c307d2c302c322c0d0a7b312c307d2c302c302c302c302c22222c302c312c322c302c302c0d0a7b312c307d2c322c302c302c0d0a7b307d2c307d0d0a7d2c0d0a7b22d09ad0bed0b4222c0d0a7b312c302c302c312c312c0d0a7b312c307d2c302c322c0d0a7b312c307d2c302c302c302c302c22222c302c302c322c302c302c0d0a7b312c307d2c322c302c302c0d0a7b307d2c307d0d0a7d0d0a7d0d0a7d	2026-09-15 12:05:26	0	0
	lfcustomizer_Large.f/Такси/НастройкиОкнаТонкогоКлиента		\\x96b0b5c30c65061d457ebba127df13df		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f9718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa85a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a381202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000d72f34b754416c184d34b78b0000000000002f34b78b2f8fbb6034b78b10ab29c18fd72f34b78b178fdf4d34b78b12a1c2ab10c18fe13034b78b10afcf4d34b78fbd030100c18fd72f34b78d4c8a8fdf4d34b78d7179afaf540100c18fd72f34b78f232601008fdf4d34b78d8c2eafc7f61701c18fe72f34b78f737f18018fdf4d34b78eac88abc0c18f353034b78bc0a1c2af2a751500c18f353034b78fd01213008fdf4d34b78f5a620200a1a18b308d5b73819a0a382e352e312e3135323295a42315076f51ce4fba4b0d11ab7a18938bcb81819168589bc586205c618f16d8dfd084c1e19a0d0a3030303030303238203030303030303238203766666666666666200d0ab0d8c42d65450200b0d8c42d65450200000000002400530074007200650061006d002400000000000d0a3030303030306338203030303030323030203766666666666666200d0aefbbbf7b2223222c36336132626435612d363765332d343064312d383664642d6335326133313230396461322c0d0a7b332c312c22546f704c6576656c54617869506c75732f5f544449222c227b372c312c3836372c3337332c313630342c3836362c3733352c3435312c302c302c302c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c302c4141414141414141414141414141414141414141414141414141413d2c302c302c302c302c302c312c307d227d0d0a7df8cf77def39fff78f03ddf7906cff9ce47f8cf6f841d214708fe829f9ce7083b0ffec74f4de418a6160bec08acb6e9bcab26bb22762dd6b9ca9f4fe897cebe311c4feb9a0d0b5292936baa2f995f5a916b84828694a12027c9a0e14d02fcce73849c0f798f075fc26f849f6ff091ce8ec91c45e71051e739eff904e1e71d3cf81b61c87bbc86242729c9cac38394242449726a60900d128a9c4c28c9204d2629a148246542c94952322e7d03332040026288419b07faa4139ec35984bba74022570d6081e402cd01502288b10c95821a19a2d14980d580145850fc80256d8d13174b9d084c3a30d86b502cb1973707c5052b2050a60a49bf0040c385bd689ed27594d3c5f69917ec1ba236aa399bd4d2412a5c929cdf82582bb3881eee41690c2405658108c50fd27c0db8107c5f03a52b61cf0c0100000e	2026-09-15 12:05:31	0	0
	Справочник.DevOpsTest.ФормаСписка/Такси/НастройкиОкнаТонкогоКлиента		\\xada1111a7a961e0f4868687dff91c1fb		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f9718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa85a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a381202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000d72f34b754416c184d34b78b0000000000002f34b78b2f8fbb6034b78b10ab29c18fd72f34b78b178fdf4d34b78b12a1c2ab10c18fe13034b78b10afcf4d34b78fbd030100c18fd72f34b78d4c8a8fdf4d34b78d7179afaf540100c18fd72f34b78f232601008fdf4d34b78d8c2eafc7f61701c18fe72f34b78f737f18018fdf4d34b78eac88abc0c18f353034b78bc0a1c2af2a751500c18f353034b78fd01213008fdf4d34b78f5a620200a1a18b308d5b73819a0a382e352e312e3135323295a42315076f51ce4fba4b0d11ab7a18938bcb81819168589bc586205c618f16d8dfd084c1e19a0d0a3030303030303238203030303030303238203766666666666666200d0ab0d8c42d65450200b0d8c42d65450200000000002400530074007200650061006d002400000000000d0a3030303030303833203030303030323030203766666666666666200d0aefbbbf7b2223222c36336132626435612d363765332d343064312d383664642d6335326133313230396461322c0d0a7b332c322c22466f726d53657474696e67735f544449222c227b342c312c0d0a7b307d0d0a7d222c2253657474696e677345637350616e656c53746174655f544449222c227b312c302c32352c307d227d0d0a7d2d303030302d3030303030303030303030302c302c4141414141414141414141414141414141414141414141414141413d2c302c302c302c302c302c312c307d227d0d0a7df8cf77def39fff78f03ddf7906cff9ce47f8cf6f841d214708fe829f9ce7083b0ffec74f4de418a6160bec08acb6e9bcab26bb22762dd6b9ca9f4fe897cebe311c4feb9a0d0b5292936baa2f995f5a916b84828694a12027c9a0e14d02fcce73849c0f798f075fc26f849f6ff091ce8ec91c45e71051e739eff904e1e71d3cf81b61c87bbc86242729c9cac38394242449726a60900d128a9c4c28c9204d2629a148246542c94952322e7d03332040026288419b07faa4139ec35984bba74022570d6081e402cd01502288b10c95821a19a2d14980d580145850fc80256d8d13174b9d084c3a30d86b502cb1973707c5052b2050a60a49bf0040c385bd689ed27594d3c5f69917ec1ba236aa399bd4d2412a5c929cdf82582bb3881eee41690c2405658108c50fd27c0db8107c5f03a52b61cf0c0100000e	2026-09-15 12:05:31	0	0
	Справочник.DevOpsTest.ФормаОбъекта/НастройкиФормы		\\xa3149e8e0af6ad824ce5c922383c6a3a		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f6162829718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa87a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a38120202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000034b78b1f54a13218a5c434b7000000000000b784010000000100000098a1321898a13218010000000000000001000000000000000000000098a13218a5c434b78dc88a8fefe434b78d6405afd75701000000000000000000a0a23218000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0a3030303030303238203030303030303238203766666666666666200d0a60f7c82d6545020060f7c82d65450200000000002400530074007200650061006d002400000000000d0a3030303031343037203030303031343037203766666666666666200d0aefbbbf7b2223222c32366464373936362d373365322d343933652d623366322d6365656466366239663063392c0d0a7b372c0d0a7b302c38313761356262382d646438382d343361392d383130302d6463303866623737383639647d2c0d0a7b35392c302c312c302c302c312c302c302c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c312c0d0a7b312c307d2c312c302c312c312c312c302c312c342c302c0d0a7b2223222c35396566326238302d633836622d313164352d613363312d3030353062616530613737362c307d2c32342c0d0a7b2242222c307d2c32352c0d0a7b2223222c33656539383364372d616365372d343066392d626237652d3265393136666364646435362c0d0a7b307d0d0a7d2c32362c0d0a7b2242222c317d2c0d0a7b302c312c307d2c0d0a7b307d2c312c0d0a7b32322c0d0a7b2d312c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c317d2c307d0d0a7d2c392c22d0a4d0bed180d0bcd0b0d09ad0bed0bcd0b0d0bdd0b4d0bdd0b0d18fd09fd0b0d0bdd0b5d0bbd18c222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c302c312c307d2c302c312c302c302c302c332c332c307d2c322c37376666636332392d376632642d343232332d623232662d3139363636653732353062612c0d0a7b34382c0d0a7b312c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c307d2c307d0d0a7d2c322c22d09ad0bed0b4222c312c302c0d0a7b312c307d2c0d0a7b312c307d2c0d0a7b322c0d0a7b317d2c0d0a7b2d327d0d0a7d2c0d0a7b307d2c312c302c322c302c322c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c332c302c332c322c332c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b33382c0d0a7b332c307d2c302c302c322c322c312c322c322c322c322c322c322c322c322c322c0d0a7b2255227d2c0d0a7b2255227d2c22222c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c302c302c322c332c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c0d0a7b353030362c307d2c0d0a7b302c307d2c322c0d0a7b312c307d2c0d0a7b312c307d2c322c312c302c0d0a7b225061747465726e227d2c312c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c312c0d0a7b332c302c307d2c302c0d0a7b312c307d2c322c302c322c302c312c302c302c312c302c302c302c302c302c302c302c302c302c0d0a7b307d2c302c0d0a7b353030372c307d2c312c0d0a7b312c307d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b312c307d2c312c307d2c0d0a7b302c312c307d2c312c0d0a7b32322c0d0a7b322c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d09ad0bed0b4d09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b225061747465726e222c0d0a7b2253222c392c317d0d0a7d2c0d0a7b225061747465726e227d2c22d09ed091d0aad095d09ad0a22e434f4445222c22222c0d0a7b307d2c302c302c312c0d0a7b31322c0d0a7b332c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d09ad0bed0b4d0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c332c332c302c302c302c302c322c302c322c312c0d0a7b32322c0d0a7b307d2c312c302c302c31302c22d09ad0bed0b4d09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0ba222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b302c312c302c317d2c302c312c302c302c302c332c332c307d2c302c302c322c302c302c312c322c302c302c307d2c37376666636332392d376632642d343232332d623232662d3139363636653732353062612c0d0a7b34382c0d0a7b352c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c312c0d0a7b302c0d0a7b302c0d0a7b2242222c307d2c307d0d0a7d2c322c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5222c312c302c0d0a7b312c307d2c0d0a7b312c307d2c0d0a7b322c0d0a7b317d2c0d0a7b2d337d0d0a7d2c0d0a7b307d2c312c302c322c302c322c0d0a7b312c307d2c0d0a7b312c307d2c312c312c302c332c302c332c322c332c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b33382c0d0a7b332c307d2c302c302c322c322c312c322c322c322c322c322c322c322c322c322c0d0a7b2255227d2c0d0a7b2255227d2c22222c302c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c302c302c322c332c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c0d0a7b353030362c307d2c0d0a7b302c307d2c322c0d0a7b312c307d2c0d0a7b312c307d2c322c312c302c0d0a7b225061747465726e227d2c312c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c312c0d0a7b332c302c307d2c302c0d0a7b312c307d2c322c302c322c302c312c302c302c312c302c302c302c302c302c302c302c302c302c0d0a7b307d2c302c0d0a7b353030372c307d2c312c0d0a7b312c307d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c0d0a7b312c307d2c312c307d2c0d0a7b302c312c307d2c312c0d0a7b32322c0d0a7b362c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c382c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5d09ad0bed0bdd182d0b5d0bad181d182d0bdd0bed0b5d09cd0b5d0bdd18e222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b312c317d2c302c312c302c302c302c332c332c307d2c312c0d0a7b225061747465726e222c0d0a7b2253222c32352c317d0d0a7d2c0d0a7b225061747465726e227d2c22d09ed091d0aad095d09ad0a22e4445534352495054494f4e222c22222c0d0a7b307d2c302c302c312c0d0a7b31322c0d0a7b372c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5d0a0d0b0d181d188d0b8d180d0b5d0bdd0bdd0b0d18fd09fd0bed0b4d181d0bad0b0d0b7d0bad0b0222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c332c332c302c302c302c302c322c302c322c312c0d0a7b32322c0d0a7b307d2c312c302c302c31302c22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5d09fd0b0d0bdd0b5d0bbd18cd094d0b5d0b9d181d182d0b2d0b8d0b9d092d18bd0b4d0b5d0bbd0b5d0bdd0bdd18bd185d0a1d182d180d0bed0ba222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b302c312c302c317d2c302c312c302c302c302c332c332c307d2c302c302c322c302c302c312c322c302c302c307d2c22222c22222c312c0d0a7b32322c0d0a7b302c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c372c224e6176696761746f72222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c302c302c312c302c312c0d0a7b31322c0d0a7b302c30323032333633372d373836382d346135662d383537362d3833356137366530633962617d2c302c302c302c302c224e6176696761746f72457874656e646564546f6f6c746970222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c302c332c332c307d2c312c22222c302c302c302c302c302c302c332c332c302c312c302c3130302c312c312c302c302c302c0d0a7b35392c307d2c312c0d0a7b312c307d2c0d0a7b342c302c0d0a7b307d2c22222c2d312c2d312c312c302c22227d2c302c302c312c302c322c342c302c302c322c307d2c0d0a7b0d0a7b32322c0d0a7b307d2c302c302c302c372c224e6176696761746f72222c0d0a7b312c307d2c0d0a7b312c307d2c302c312c302c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c302c302c312c302c312c0d0a7b31322c0d0a7b307d2c302c302c302c302c224e6176696761746f72457874656e646564546f6f6c746970222c0d0a7b312c307d2c0d0a7b312c307d2c312c302c302c322c322c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b382c332c302c312c3130307d2c0d0a7b302c302c307d2c312c0d0a7b352c302c302c332c302c0d0a7b302c312c307d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b342c342c0d0a7b307d2c347d2c0d0a7b332c302c0d0a7b307d2c302c312c302c34383331326330392d323537662d346232392d623238302d3238346464383965666331657d0d0a7d2c302c312c322c0d0a7b312c0d0a7b312c307d2c307d2c302c302c312c302c302c312c302c332c332c302c307d2c302c332c332c307d0d0a7d2c322c0d0a7b22d09ad0bed0b4222c0d0a7b312c302c302c322c312c0d0a7b312c307d2c302c322c0d0a7b312c307d2c302c302c302c302c22222c302c302c322c302c302c0d0a7b312c307d2c322c302c302c0d0a7b307d2c307d0d0a7d2c0d0a7b22d09dd0b0d0b8d0bcd0b5d0bdd0bed0b2d0b0d0bdd0b8d0b5222c0d0a7b312c302c302c322c312c0d0a7b312c307d2c302c322c0d0a7b312c307d2c302c302c302c302c22222c302c302c322c302c302c0d0a7b312c307d2c322c302c302c0d0a7b307d2c307d0d0a7d0d0a7d0d0a7d	2026-09-15 12:05:58	0	0
	Справочник.DevOpsTest.ФормаОбъекта/Такси/НастройкиОкнаТонкогоКлиента		\\xa499ebe0d2b650bf4565291ed179a42b		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f6162829718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa87a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a3812020204cbb757eb06065c83c9a096f6e655f635f6c6162d5db854d86e6175b4cbb757eb06065c83c818681818283202020202068e67f394e8198bf8a0a95752c9549392aa6567e3346a6a7471606c1440981a195921ffb870ec8cc4fbad50c8d0b3467c681202020ce4fba4b0d11ab7a18938bd68181913c1dcfd1c72518658f16d8dfd084c1e19a0d4575726f70652f4d6f73636f77a18181818db0048f805101008181819a0f57494e2d424d334c49304b414d354f8d18068d9e07819a1b666538303a3a336537663a326332373a366330643a6434613925388181819511c7e36956e2d947811538134deb8bf39a04353832382020ab10818181818181818181818182cb2395969825b0fb9da14eb120c4dcb772ff4ac120a2cb239533dc5eba368912429ed2485e759203aa8bb4a1818181a3c120818181819a0d0a3030303030303238203030303030303238203766666666666666200d0a002e782f65450200002e782f65450200000000002400530074007200650061006d002400000000000d0a3030303030313135203030303030323030203766666666666666200d0aefbbbf7b2223222c36336132626435612d363765332d343064312d383664642d6335326133313230396461322c0d0a7b332c332c22466f726d53657474696e67735f544449222c227b342c312c0d0a7b307d0d0a7d222c2253657474696e677345637350616e656c53746174655f544449222c227b312c302c32352c307d222c22546f704c6576656c54617869506c75732f5f544449222c227b372c312c313034302c3439322c313339352c3637382c3338392c3231322c302c302c302c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c302c4141414141414141414141414141414141414141414141414141413d2c302c302c302c302c302c312c307d227d0d0a7db974f7884287818181d542cbd0b2cdedf547928c7fbb76c7b6bc8181a19590076cdb4c8c994d862f212daca7dfaf81202020204d696e69706f727420284c32545029222c224e45545f36222c225b30303030303030365d2057414e204d696e69706f727420285050545029222c224e45545f37222c225b30303030303030375d2057414e204d696e69706f727420285050504f4529222c224e45545f38222c225b30303030303030385d2057414e204d696e69706f7274202847524529222c224e45545f39222c225b30303030303030395d2057414e204d696e69706f72742028495029222c224e45545f	2026-09-15 12:53:04	0	0
\.


--
-- Data for Name: _urlexternaldata; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._urlexternaldata (_userid, _objectkey, _settingskey, _version, _settingspresentation, _settingsdata, _changedate, _useridhash, _settingskeyhash) FROM stdin;
\.


--
-- Data for Name: _usersworkhistory; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._usersworkhistory (_id, _userid, _url, _date, _urlhash, _ecsactivity) FROM stdin;
\\xb7ae94dde1a4fd884753b9b8f029de33	\\xba4b0d11ab7a18934fce516f071523a4	e1cib/list/Справочник.DevOpsTest	2026-09-15 15:05:15	1990237847	f
\\x8b589698dd4523d4474648e3aef3d4b8	\\xba4b0d11ab7a18934fce516f071523a4	e1cib/list/Справочник.DevOpsTest	2026-09-15 15:05:39	1990237847	f
\\x8f738ecc722da13f4e3478fbd6c9c1c0	\\xba4b0d11ab7a18934fce516f071523a4	e1cib/data/Справочник.DevOpsTest?ref=9412080027b9b2bd11f1b0fdff19dcc1	2026-09-15 15:07:18	1275791886	f
\\xa91a36b3ec2ace7949b224200fb26f45	\\xba4b0d11ab7a18934fce516f071523a4	e1cib/list/Справочник.DevOpsTest	2026-09-15 15:07:10	1990237847	f
\\x917d910f038c567d45907e2115b0de08	\\xba4b0d11ab7a18934fce516f071523a4	e1cib/data/Справочник.DevOpsTest?ref=9412080027b9b2bd11f1b0fdff19dcc1	2026-09-15 15:07:19	1275791886	f
\\xbcfc73dcc7863d5a49dfd05d80c67f2e	\\xba4b0d11ab7a18934fce516f071523a4	e1cib/list/Справочник.DevOpsTest	2026-09-15 15:05:49	1990237847	f
\.


--
-- Data for Name: _websocketclients; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._websocketclients (_id, _wsckey, _metadataid, _serverurl, _predefined, _connectionparameters, _ibusername, _autoconnect) FROM stdin;
\.


--
-- Data for Name: _yearoffset; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public._yearoffset (ofset) FROM stdin;
\.


--
-- Data for Name: binarydata; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.binarydata (f_key, f_off, f_num, f_data) FROM stdin;
\.


--
-- Data for Name: binarydatastoragecontent; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.binarydatastoragecontent (f_key, f_type, f_parent, f_id1, f_id2, f_id3, f_id4, f_id5, f_id6, f_str1, f_num1, f_num2, f_num3, f_num4, f_num5, f_vstr1, f_vstr2, f_vstr3, f_vstr4) FROM stdin;
\.


--
-- Data for Name: binarydatastorageversion; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.binarydatastorageversion (storageid, version) FROM stdin;
\.


--
-- Data for Name: config; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.config (filename, creation, modified, attributes, datasize, binarydata, partno) FROM stdin;
3d4a3adf-f901-411e-b7a6-54b2539fa21e	2026-09-15 15:04:46	2026-09-15 15:04:46	0	1990	\\xcd594b6e25b911dc0fd09790b74a80f9e16feb3bf8004c7e2e3168c0800d6fbd9f5318f06600c3f615d427f1151cf5deab2aa9a7a747e36a1823354a7c12990c66644626abfff38f7f7f2fcf1fbefb5e87356d63d1aa81c99827796e89a2b944adab09cf8fcf799b5afb881cfaa0e6ab13f330aaa6462158a871b2ac7e9bc7db23a7ed196e5bdc7f199edb2851a566129646e69ca8b20d9ae63d686cabebfaf8fcf4f2c3cbbf5efef9e9cf2f3fbefcfdd39f3efdf1e56f9ffef2f2e3a7bf3edd2c62c2136ce1fbf1455f78ec5fcfe1e387ef6e2bf8b1f8e79eefb2962cf19a5549a3e3003d746ad39904c0f35833f43edf89eb5d9336e0f77f77f838ce9bd137dcea9b4d2a218613e3fb89fa6693f6087cfa1ddc964359a335eade2799944aae5929e4165b369fb3f233df62e4db0190f74dd3c349f829657b3e504feb5157359a7165427e1a95ce0169537c14e6de263f4bbd2d7cfafdd3e300bf767db9b83e1febc3ffb43e5d5c1f2faeb78bebf5e27ab9b89eafade78bfcf145fef8e2f9f9eaf9c3b5f5f5daf2f2e5e57f78ba66f622a91739bd9a921729b998917c9152bd18915713e26742eaddf02f7affb3d36f16646b5dee0d01ffff1b8177f6475bf57d56db9bd4473d3e467a8ce2314ac7281fa3728cea31e2700e4fdb7c1ae7d3129fa6f8b4c5a731398dc92ba0a73139a18a9dc313b69cbbc9b91b5a0fde87f518eab99b9ebbe92bbf9cbbe9b99b9ebbe9b99b9ebbe9fd6c8ff83addade5fef91e4507a09384db4f3ba9d889d869d849d829380838dc7f38ff3ed86df26e9477abbc9be5dd2eef8679b72cafb9389838783858d839e08381c3ff87470f7f1ede3c7c7978f2f0e3e1c5fb60c7633b1ebbe1f975f79adb8d6abf216d6c6fdc7e787d3b7ae6dfe875e3373809ba77bffcd6acc98350edad934d5de406fd1c3a6bcca979b59dc6d04bedb90a71eaba5dad23794d0eb331789ba1d538f6a96b5aa905e21b656c531335edf99c9a733aa6aed543ed54960140ee1d00181f47ecb189f0c867a2c84a02aca60b37dbe0810a76a1d687969c7085ea7ea4928fb64aa411db201b95c95d8c5a0b734ed61ae2916331578b4909f76200e005ac453bcd8e3ae2b545ef47f65837cd56a8572d647100c060a3c026d6b238f33ca469c468c3291ae35207dc546a0ed4b8a7d1d774f17e24cc92d56a23979c8e5716f1ed2b8b3d937c8c951a850e8416c5a90a9c356aed0ba665f1ee019dd182b545692e60edb850b6c14c159e91b15ab77ee4e7ccbe7a4780a4fc0b6c5972eba3665a8315e1825b6bf326a4c03572aa40b35bb559a48c96282c33328f4eced8a4892b1c907df4dd03b11403818934cd8d58b8a114042c2ebed3adc61ac6ee8134e1be90657b01b4b1353302a714925c8644471048dbf576f4613a2ae2a345b22a893c5a252e263335e0eb6b97e498bb3504097a07608577a8244443062a498bd147ecc72a29e6a03229670bf0000f38cb1bc531d22c6d792ebbd5c7bba8f9d57751fcae1736377b2d27e39c33606dce8f3d5105bb54b14d2cb9a5d6779eda8a86b00ea492c0beda024af86a5a1e6948d2d27729efc162a87512ab579cddd36630d0ea2d04645bcd4750f75ec7cac8b8dcd1670136a6e6219491569ebd03c63e157b849a96e36f714bc0051a16920cfb07cb9911f07ef6609bb35607810d2e2d22bbb3b6dc0a2518e28879d57b35fdf07877f2e8855a5e7d8601dd5a0599c619a9de919e1ad89d3d29d7f2be1283b2126f92c460a7800687367c3d2143e251b2807e840a3c1226d588e899232339143e2f7ba50c79e20382b0e4c5bb7c42f7be209facac268169a5e0f7a93f9790dc639ecd118e8ad0367305ea3169fac2af5376387c57afc52d32602e074cf31071ac5269f42d768d450fa9d7d4ca5403bd0d190e15a9e4c30715f5a91d3158733e1481c5478e94d9b7b63b22757a8f241e3cc555570b3b0050e179a358ea94afeb4c9106ea22b615099b7e43baa17dc486ada0cab11d583de1cf0da1cec97ec12a2214ce87418d9085af4f5dc52233c248b283d802c5d9124e4a1c8222e252f7a97d190880d069f62372c37a1bb9b84c3352c1bdd018654bc956a93022107256a01ab9a43a6ef6a0ef2564b089d2058f068440895c49ebc6d45a124d8ed47964cfd45450989842bbc5a1404318825a975aacb6aa7b3b1227ecd788c6d119fa4688e804ee20103e67a4254874c827aa717cdc916e2d63997902bba232224d71d802e9c329a6fbec2e611ea136e61c1567856761782d68a0a10275090dcd031c78ab7eafb27f4cb61a20505d20120d23a807ca6b8ca86f9e3caa7f9ef80ac54b8e723d8b6213d1b1f92902d49cded0a9a0a539d16b70781b8c8339a0dfaa479be0be7be9ad34c865da437a013ee4b4503238c3e274142df431ae6d8e86bc0933bf411f194be228349b41ec42b2ad31817ba446ce31048584fec4fba3a05e05885d6641ea0e508c8364c2b9a76d2e3579e57d9d493522bb5833c2a74624faac5087313d42b4c1c0de8a434915b51f8a1e37671654a0eaa8bcb30f87b8a6628ddfe09fa97091adf48a227ab428bc9f515842e7a99ac156fedcfb08d0dc07385d1045a047bc7a2c4e32cd4b4d0d1575dcecdf1645c9c85254c1da75131488745911511100a939b89bf10da4e552648bfac101671803c7ed2ca04b32f25679acfe934ad06a4f6d6eec22e09004388140e54265041fab20644f48be368d450fb912e4cd18bae405e0508a07127a53aff106d26d97dbff74dc3e426f6a8c68eaa43e26fd17	0
6461fe93-35ba-4c0c-aeb1-2c3f7dfe0cce	2026-09-15 15:04:46	2026-09-15 15:04:46	0	104	\\x7bbf7b7fb5a10e2f57b50188300611863a063a6626668669a996c6bac6a64989ba26c906c9ba89a94986ba46c9c669e62969a906c9c9a9b53a4a17165c6cbed878b1f1c2ae0b3b2eec5482e8562a2a55c290022a56029a0b8450a08b8580011d835ab029b5400600	0
817a5bb8-dd88-43a9-8100-dc08fb77869d	2026-09-15 15:04:46	2026-09-15 15:04:46	0	795	\\xed563d8e1d370cee0df80ec6a41501fd51a2faf43190e40014299589e1dda4315e11372ed3a64a950304010218b0915ce1bd93e40ae1ccbcb7c65b04f02e907247036930f389e4f023bf997f3efcfd26b8e7cfde60756534ef531408be25c8c20db8b2024aad43c4d390e8246a88a81990a9400e3aa13131042e71145444ec2ea49a51b2070ed940323bd04c03ba34a55292606bae9651253143d18066492af0108432b096e2c58ee4822635bf09b0748ba95100a232a18e14a70a615471897345916e914c73d782d8559a20c293b5f690fb70513045a40c3e5482dc5580e2608843edf566c184e47a21a1e0190c9a0dd422f41408487cd7de27b1e89a2dbf4e699d82f38e4265ec9d4095cc74b2c499110f6a399bbd562a4d0f6ef972fcf8d5ab9b6fc6cdedb2ef5c5effb06cb75f7cffeae6c5edfac0608b59b4713ee03fa6cbe1fce1f9b3838b2eec31f9835dadc3bb6673c4f5f241769e40ff1fe81319deb1348f1413a45eac7cab28f46693279f8972689a8b1b448952b74623f590b90af4d127f4d0d0108dc394bd266c44e7f7e2d99cc47559be585cf18313b60989cb804cdd3a6ed4001a3963c51a5ba0150b692b99c7ee8aebaefddc0a6c757ef8cc1cee1ae552a69fe2deef9cdf24eeb9dac6c1e1d65aca837d28505aaf9087e94dcb9820c4da82a94b9ca3b8dd539e83aa50b39637544ea6006daa6981a943ea896a930bb4a518ec6d0d8a3d9ad55a8049d51425b7395050879ea13233f7c115523568085b007e1ad32b73ca21cce63601b0b3ac6bacdb7c250c755064ac2691b2e63744f3252627c5d4c6048894b45bc71f7f397e3cfd7c250ae75b8f95838dd8977c7b3b5e7fb7d95bbe5e5cb09abc90e7af28f2bbf915f7ed72b85b1fe8ee5c8ae8fd25c1c95d8238d7ff9db3358e65395c485e975da8f64c3dc0dd1efee1b32937ca095306692cd64cd6519ced4b54088b7d0c2420f29af2df8ebf1f3f1edf1f3f1cdfdf4ffdf5a3270a1e4b81fd42f48a1381954df454a3d5bffd27e0d03e22470cbdac14fc7a7a7b7a77fcf3f4d3e9edf18fe35fd724dc7ff844c37d1ace3a3e75522896e330ec5fcd940aed1353d176a0ef3c3c37d41dfd2f	0
versions	2026-09-15 15:04:46	2026-09-15 15:04:46	0	268	\\x3d90414e05300844efd275494aa1a53d4e2990b8f1276adc184fe6c2237905890bd7bc0c6fe6e7ebfb03abd452aac5e9b2db055d9381db7550391b6eb84db7dee49e5ac8f8d0b180d80d8111ffa80983b50fda99815e6ac7c94b90611d3cc05d06ac2101b274c4b0c91c56cbe489e19b80862675f3f77145e897422cbcdd9b59ed300a628719a9c477386c1c17628ab74d4a79ae65a19ca1bac06c2d604af185ad81ddb64245d6dc9659571bc950583d9df9ea0675eee0eb74dad62868d4f2f278bc953a5c89685212d6738f9decdc0b742bdb95a023d9e1dd5f5e9f1ecfa5ce6b8c411750a7028f2caf96c2ce390b310b7afbc75f5345fb3e3b5a0ec903d847cbe1474a5160a04fcbf69fbf	0
817a5bb8-dd88-43a9-8100-dc08fb77869d_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75	2026-09-15 15:06:57	2026-09-15 15:06:57	0	1905	\\xed9c3b8e24c711867d02bc03d1742b807c67844bc897009107887c99e282bb94438c213a32e5ca92c5031004041020215da1e724ba82feaceaee995d89a3194274b8d93da89eed8eca8c8ac71fdfcc60eb5f3ffcf32bbb7df8c157316fa98b31de55b2463c85aa429ab551ac39f75a0df7eab6ea9a75b1058aca89826d834459c96a723dc516632c9bf539c41a0ca90d30aaa3100fdfa954699c92af5164cba9e7ea5529351bb152cda4bd464a3de6944cc5c36fb6f9867d3dc554e093b025e6342877ef46ab1c5dab9bd79063ad059e0c6c27b6e23b3fa8561dda72b1a1f4cdd5e85de440c666a6505a25765dc9f586cb1b29fac85b495cd91a2598061889a3e22d1357535a2983b5b6192d330f7e1eec6636b65963294cad3196f6081c1631d410b35172e624ed6e3bfda6fff1b7af5e7fda5fbf391d679ebef8f2b4bffdd1e7af5e7ff4667e00b31356c4f3f2a0ff72b83e3673f7e107779bdbece193b9c377f36936c1d1c5f9edb3d65946ff3fa38764984dab98c8ce932f09e59b6ba32238183681395869216d9dd9b32f68346e8682e64aa59741c54a8485a81df5a8093cdd668ee2d93771f3e5f4f1694ba6ab8f32c86bea14b8a0e37ab6d49c869863766279da92df4be6a567b979d6f1b517d8d5038b429b9f5b7fb7456b8289cd935353290cf49624b4521ebd4729e85729fb3961af4ccbbeda3068b045a7494d24ce7b525f1d5a7d24a8c6d54d51c80ada985c90e9e6debaa190ef166fd481864d4743de5a223bdf8b309550ed940d254dc3533621402bb218f7b03a77e51e954a9c8a165c418e42800e79d8661f54f3cca62ba5684a858622398191502e0a650ac557b8cb92fabee627a7dd1c42127c83b2b90051a8619a4308bdc91093ee7ab0f191b9f735070d288264b17aa986a4431cb9398ba57d352a578fb5f96423a452b5c3e3ec22b1944ec896cbd1792d6db77d96dd11305fac490ee9b0dd37042c36e239055c742ef601edb4feba7d340ea29622522733d1285a99a71a750cb9ae464ade47ca73ec2edb771d1828854c6ad3d382d1517323952448751e418eabff0c0a19929831b2a1ee874eb90fb8229729a968ad715409b750713638dd338dea601b7c226d8a0a1f599a170c2917f656dadd08ad1b2f86918481a2f402eb643b5984ceeba8738347398b6caa93ee88759a63ba6038619b5c079bec7b42e67e9e23a9065c600ed433466de05ee61c2ae833c7d9a7945cbab5be8d7968102847ed42d6e204416d4194a6c8600f3be432a99e215fc7f6dde3346fc9671478688ac26189044568d20ca67849b762ac484333193b1787d4e54e5a3224258da92eb972db47e6b3ec769dd932fa0c93d3118062c6153e307324efa12acc488335b7ab775503b065d60b42100d288325c3f3a1835369b370912b46378a62f2a3b5d18e3965e2945170d8c3340b7271fde7e54a8cf650d030dd8cd93a7d9022f6d452aeb6e7683c3f2e1a71ccd01b0c021785424257e09f539a1a6741e10dd7ae8e603a74b5ce01470c64ac475c5c477e7b4a10cc1e40527b813dcbceeede16e3d818148a72b333b6939aaca39150b0e24a97c48fbcad296a0c50245304e6030a5d2a2067145545e18988bb35661d410b7289e023c5974a34e33f2af1e531beac1cfee7cabf0750c193169cc733917190f3e0d0c325b55946905d1e397897af9ef8c21d75d290b0591902c9d6e10621a88dc3e0dcda2ed4cfb23b820c0dd584914e35065c5ccc183f0e03a04809988223a776cb71c9492317c1d88c903e248b0a7a1d83d8046d32bcd57ea8a94917b5ec7340468cb3d2708095415292a18c6bc627bd38c3b7a4403a3b9401956990bcd01386678e9164a6b0d6964ce6c7a11b75a06401b3b61af8332f403206ba49c142d282629a5f7d1f0068edbbfe6a9eb22d242d0919c99c21da160a79a5a10b3decb460162d2c5a58b4b06861d1c2a285450b8b169ea2055eb0b06061c1c28285050b0b16162c2c58780a16f28285050b0b16162c2c5858b0b06061c1c253b090162c2c5858b0b06061c1c28285050b0b169e8285f82b8705fb8bc2827d7f61c12d5858b0b06061c1c28285f70616c2af1c167ed9df2cbcc7b0b07eb3b06061c1c28285050bef0f2cacff3bb9fe0cb16061c1c28285050b0b16162c3c090b6ec1c28285050b0b16162c2c5858b0b060e12760e10119cc4f1f2f7791ba65df1df2f5b0d0f56653eeb89dd5fe841cef596adad5d84409d30597bb574af484012190b4ec469f619ca6534c203bf059a7c882391094867e6815b9f3e8c67a3515ef6c9401d338c5abe734fb073392838c8e11db7abb985e4a353f59aafb2cc5d7aea24729ba83600ea1de72c720417fd1ec5f0ad661af6a99528abec0bfc6addc6da7f35fcf3fdeffe5adfbb65dde7ae91ddbf694fe4edfbce95ffce174ad07c8acbda6ccbc9522732c7f2db2ebeb33b7bbdc2dec52d20fe8764df1e3cdae757949f27c39ee25f7b291762cf664c891728e3e50c5943fba4a43309418a2acadda187586fc9bf3b7e71fcfdf9f7f387fff6ee8dffe68a5e0a529f0ae961c479ca360724773a8ff3628f6066256176d4933057fbbfffafecfe7bfdfffe9feebf377e77fbc9d84773f5c6978370d17051e0d3f7b25c4d8766d53a92206549ee0184dd18e1f38623bacff0d	0
version	2026-09-15 15:06:57	2026-09-15 15:06:57	0	28	\\x7bbf7b7f352f57b591a1998e810e906161606a60a86350cbcb054200	0
versions_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75	2026-09-15 15:06:57	2026-09-15 15:06:57	0	267	\\x3d90bd4d06300c0577491d4b71e2bf8c13c7b144c32701a2414c46c148ac4068a8dfe9747a3f5fdf1f58b59652cfcc9e190a4b94819a0cf0860c2e732e11f7a35ccb085a634542ce864088075c970093771e3357c7536a47215324b0850ba85fa1b126a83927871065d4222498670e18ec97da6dc33a8ed0f7488d3c6defeb6a8b50113b48ee73293e309137a4e86973f8b8732d86bad8dd20c20c68ac0986ad41ec66e9aa26334adde42d5827cc311d28296f972484ce6d7e5be7c25a5e1e8fb752856dface6b6454a0ab002342b8b61bbd73df9f6a793f2faf4f8fe7526324ddfa09d1edaac91698a083604b26f23be23ffe5a2a9d76fd6b43a3bfbba37758791c583982d0d51b7dfe02	0
root	2026-09-15 15:06:57	2026-09-15 15:06:57	0	312	\\x0dcc497282400000c07baa7c895a320b100e39000e20a00617146f8ce3a0a0c82e90cacb72c893f285f080eebf9fdf2f38410c8728647cca15014c310097299543692a620a45a4f01082cbe4b16aa919534cc1e375aabc63ea0a78768406b334ae294f121d32dbc1707610c6f7dd232365f239069b445de720ab9cd01d8dde66720d0216480b5f2410e79d30e884c65bc2bc7da32122a9dc78d56ea344567f6f6a5590b99e3ffdb0506456c2d81b0a968197a577d2a29545528058b252a30a4e7123791b27cd4d5e4659100528daf5633bcde6089aef9a293452b752b5c85e0ec5e22616199697f31bcdab1ee944d65b7d7f2df2dec7b69899eb757dbc21a405cffe34f38e3581d132955a23a7c8bf9e5d3614540c4b9e7a56e194ccdebc9fbbdd21806d854d35b91bab70f50c68b9ed1477b7787d7cff03	0
DynamicallyUpdated	2026-09-15 15:07:03	2026-09-15 15:07:03	0	45	\\xefbbbf7b312c312c65396632666664372d613637352d343036332d623031352d6236393961363662626537357d	0
\.


--
-- Data for Name: configcas; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.configcas (filename, creation, modified, attributes, datasize, binarydata, partno) FROM stdin;
\.


--
-- Data for Name: configcassave; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.configcassave (filename, creation, modified, attributes, datasize, binarydata, partno) FROM stdin;
\.


--
-- Data for Name: configsave; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.configsave (filename, creation, modified, attributes, datasize, binarydata, partno) FROM stdin;
\.


--
-- Data for Name: dbschema; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.dbschema (serializeddata) FROM stdin;
\\xefbbbf7b302c0d0a7b35302c0d0a7b2244625365676d656e7473222c224e222c312c22222c0d0a7b332c0d0a7b225365676d656e744964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225365676d656e744e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250617468222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b225365676d656e744e616d65222c312c0d0a7b312c225365676d656e744e616d65227d2c312c312c302c0d0a7b307d2c302c307d2c0d0a7b225365676d656e744964222c312c0d0a7b312c225365676d656e744964227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244625365676d656e74734974656d73222c224e222c322c22222c0d0a7b342c0d0a7b224974656d4964222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225365676d656e744964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466f72496e646578222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224170706c696564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b224974656d49645365676d656e744e616d65222c312c0d0a7b332c224974656d4964222c22466f72496e646578222c224170706c696564227d2c312c302c302c0d0a7b307d2c302c307d2c0d0a7b225365676d656e7449645365676d656e744e616d65222c302c0d0a7b322c225365676d656e744964222c22466f72496e646578227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22576562536f636b6574436c69656e7473222c224e222c332c22222c0d0a7b382c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225753434b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d657461646174614944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657276657255524c222c302c0d0a7b312c0d0a7b2253222c323134373438333930332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22507265646566696e6564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e6e656374696f6e506172616d6574657273222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224942557365724e616d65222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224175746f436f6e6e656374222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e735265737472756374222c224e222c342c22222c0d0a7b342c0d0a7b22457874446174614944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461496e74222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2252657374727563744461746154797065222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b22457874656e73696f6e735265737472756374536570617261746564496e646578222c302c0d0a7b312c22457874446174614944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b22457874656e73696f6e7352657374727563744d61696e496e646578222c302c0d0a7b322c22457874446174614944222c2252657374727563744461746154797065227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e7352657374727563744e4753222c224e222c352c22222c0d0a7b342c0d0a7b22457874446174614944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461496e74222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2252657374727563744461746154797065222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b22457874656e73696f6e7352657374727563744e4753536570617261746564496e646578222c302c0d0a7b312c22457874446174614944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b22457874656e73696f6e7352657374727563744e47534d61696e496e646578222c302c0d0a7b322c22457874446174614944222c2252657374727563744461746154797065227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e73496e666f222c224e222c362c22222c0d0a7b31302c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c22457874656e73696f6e73496e666f222c327d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e4f72646572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e557365507572706f7365222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e53636f7065222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e5a6970706564496e666f222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d61737465724e6f6465222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736564496e4469737472696275746564496e666f42617365222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2256222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e73496e666f4e4753222c224e222c372c22222c0d0a7b31302c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c22457874656e73696f6e73496e666f4e4753222c327d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e4f72646572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e557365507572706f7365222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e53636f7065222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e5a6970706564496e666f222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d61737465724e6f6465222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736564496e4469737472696275746564496e666f42617365222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2256222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2253797374656d53657474696e6773222c224e222c382c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22436f6d6d6f6e53657474696e6773222c224e222c392c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2252657053657474696e6773222c224e222c31302c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2252657056617253657474696e6773222c224e222c31312c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2246726d447453657474696e6773222c224e222c31322c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244796e4c69737453657474696e6773222c224e222c31332c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224572726f7250726f63657373696e6753657474696e6773222c224e222c31342c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2255524c45787465726e616c44617461222c224e222c31352c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22496e7465726e616c53657474696e6773222c224e222c31362c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244656661756c7453797374656d53657474696e6773222c224e222c31372c22222c0d0a7b342c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b312c224f626a6563744b6579227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244656661756c74496e7465726e616c53657474696e6773222c224e222c31382c22222c0d0a7b342c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b312c224f626a6563744b6579227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573496e666f42617365557365222c224e222c31392c22222c0d0a7b322c0d0a7b224964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f706965735570646174655461626c6553746174222c224e222c32302c22222c0d0a7b352c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225472616e7366657254696d65222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224973506f7274696f6e222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657355706461746553746174222c224e222c32312c22222c0d0a7b332c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225472616e506572536563222c302c0d0a7b312c0d0a7b224e222c31362c342c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573222c224e222c32322c22222c0d0a7b31322c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f70794e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365496e74416363656c657261746f72222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225265706c54797065222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b22446254797065222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b224462536572766572222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244624e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446255736572222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446250617373776f7264222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224372656174654462222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253746f7261676556617269616e74222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f70794964436f70794e616d65222c312c0d0a7b322c22436f70794964222c22436f70794e616d65227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657353657474696e6773222c224e222c32332c22222c0d0a7b342c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f7079436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f7079536368656d61222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f70794964222c302c0d0a7b312c22436f70794964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657354724c6f6773222c224e222c32342c22222c0d0a7b342c0d0a7b2254724e756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c327d0d0a7d2c22222c307d2c0d0a7b22547254696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724c6f67222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b2254724e756d222c312c0d0a7b312c2254724e756d227d2c312c312c302c0d0a7b307d2c302c307d2c0d0a7b2254724964222c312c0d0a7b312c2254724964227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657354725461626c6573222c224e222c32352c22222c0d0a7b332c0d0a7b2254724e756d222c312c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b22547254696d65222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b2254724e756d5461626c654e616d65222c312c0d0a7b332c225461626c654e616d65222c2254724e756d222c22547254696d65227d2c312c312c302c0d0a7b307d2c302c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c2254724e756d227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657355706461746573222c224e222c32362c22222c0d0a7b362c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724e756d222c312c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b22547254696d65222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225570646174654964222c312c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c617374557064617465526573756c74222c312c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c6173745570646174654572726f72222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f7079496454724e756d222c312c0d0a7b322c22436f70794964222c2254724e756d227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f706965735461626c6573537461746573222c224e222c32372c22222c0d0a7b342c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c655374617465222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b2254724e756d222c312c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f707949645461626c654e616d65222c312c0d0a7b322c22436f70794964222c225461626c654e616d65227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573496e697469616c4c617374222c224e222c32382c22222c0d0a7b362c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22426c6f636b4e756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c327d0d0a7d2c22222c307d2c0d0a7b2246697273744b6579222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c6173744b6579222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22426c6f636b5374617465222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f707949645461626c654e616d65426c6f636b4e756d222c312c0d0a7b332c22436f70794964222c225461626c654e616d65222c22426c6f636b4e756d227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657354724368616e676573222c224e222c32392c22222c0d0a7b342c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724e756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b2243684964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f707949645461626c654e616d65222c302c0d0a7b332c22436f70794964222c225461626c654e616d65222c2254724e756d227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573547243684f626a222c224e222c33302c22222c0d0a7b322c0d0a7b2243684964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2243684f626a222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2243684964222c312c0d0a7b312c2243684964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224d6f62696c65436c69656e744461746145786368616e6765222c224e222c33312c22222c0d0a7b352c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254797065222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617465222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224944222c302c0d0a7b312c224944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22426f7473222c224e222c33322c22222c0d0a7b382c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436c69656e744944222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22454353557365724944222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d44426f744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224942557365724e616d65222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22506172616d222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22507265646566696e6564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224e65656473557064617465222c312c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2253545453657474696e6773222c224e222c33332c22222c0d0a7b322c0d0a7b22546f6b656e222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22486f7374222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544772616d6d6172222c224e222c33342c22222c0d0a7b322c0d0a7b224772616d6d6172222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22506872617365222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b312c224772616d6d6172227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544772616d6d6172436865636b73756d222c224e222c33352c22222c0d0a7b322c0d0a7b224772616d6d6172222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436865636b73756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c312c0d0a7b312c224772616d6d6172227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544d6f64656c73222c224e222c33362c22222c0d0a7b31302c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c225354544d6f64656c73222c327d0d0a7d2c22222c307d2c0d0a7b224d6f64656c4944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d6f64656c436f6d7061746962696c697479222c302c0d0a7b312c0d0a7b224e222c352c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2241636f7573746963222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2241636f75737469635255222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c616e67756167654d6f64656c222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c616e67756167654d6f64656c5255222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c323134373438333635302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253616d706c6552617465222c302c0d0a7b312c0d0a7b224e222c352c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794d6f64656c4964222c312c0d0a7b312c224d6f64656c4944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544d6f64656c7344657363222c224e222c33372c22222c0d0a7b322c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c225354544d6f64656c7344657363222c327d0d0a7d2c22222c307d2c0d0a7b224d6f64656c222c302c0d0a7b312c0d0a7b2252222c302c302c225354544d6f64656c73222c337d0d0a7d2c22222c307d0d0a7d2c0d0a7b332c0d0a7b224465736372222c2249222c302c225354544d6f64656c7344657363222c0d0a7b322c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2241636f7573746963222c2249222c302c225354544d6f64656c7344657363222c0d0a7b322c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224c616e674d6f64656c222c2249222c302c225354544d6f64656c7344657363222c0d0a7b322c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d0d0a7d2c0d0a7b312c0d0a7b2242794d6f64656c222c312c0d0a7b312c224d6f64656c227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f7279517565756530222c224e222c34312c22222c0d0a7b342c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446174614964222c302c0d0a7b312c0d0a7b2242222c32302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22506f736974696f6e222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d657461646174614964446174614964506f736974696f6e222c312c0d0a7b332c224d657461646174614964222c22446174614964222c22506f736974696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f727956657273696f6e73222c224e222c34322c22222c0d0a7b31322c0d0a7b22486973746f7279446174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d6574616461746156657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617465222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676554797065222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365724e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225573657246756c6c4e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6d6d656e74222c302c0d0a7b312c0d0a7b2253222c323134373438343637322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225472616e73616374696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224e6f6465222c302c0d0a7b322c0d0a7b2245222c302c302c22222c307d2c0d0a7b2252222c302c302c22222c347d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22486973746f727944617461496456657273696f6e4e756d626572222c312c0d0a7b322c22486973746f7279446174614964222c2256657273696f6e4e756d626572227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f72794c617465737456657273696f6e73222c224e222c34332c22222c0d0a7b352c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446174614964222c302c0d0a7b312c0d0a7b2242222c32302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22486973746f7279446174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22536570617261746f72734d657461646174614964446174614964222c302c0d0a7b322c224d657461646174614964222c22446174614964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f72794d65746164617461222c224e222c34342c22222c0d0a7b372c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22497353657474696e6773222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22497341637475616c222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d6574616461746156657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224973457874656e73696f6e73222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22416374696f6e4f6e416363657074222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b22536570617261746f72734964497353657449734163744e756d626572222c312c0d0a7b352c224d657461646174614964222c22497353657474696e6773222c22497341637475616c222c224d6574616461746156657273696f6e4e756d626572222c224973457874656e73696f6e73227d2c312c302c302c0d0a7b307d2c302c307d2c0d0a7b224d6574616461746149644d6574616461746156657273696f6e222c312c0d0a7b322c224d657461646174614964222c224d6574616461746156657273696f6e4e756d626572227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f727953657474696e6773222c224e222c34352c22222c0d0a7b322c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22536570617261746f72734d657461646174614964222c312c0d0a7b312c224d657461646174614964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f7279416674657257726974655175657565222c224e222c34362c22222c0d0a7b332c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22486973746f7279446174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22536570617261746f72734d657461646174614964486973746f727944617461496456657273696f6e4e756d626572222c312c0d0a7b332c224d657461646174614964222c22486973746f7279446174614964222c2256657273696f6e4e756d626572227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225265664f7074222c224e222c34372c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22436872634f7074222c224e222c34382c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224163634f7074222c224e222c34392c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22434b696e64734f7074222c224e222c35302c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225573657273576f726b486973746f7279222c224e222c35312c22222c0d0a7b362c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365724944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255524c222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617465222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255524c48617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224543534163746976697479222c312c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b332c0d0a7b2242794944222c312c0d0a7b312c224944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b2242795573657244617465222c302c0d0a7b322c22557365724944222c2244617465227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b2242795573657255524c48617368222c302c0d0a7b332c22557365724944222c2255524c48617368222c2244617465227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224f4461746153657474696e6773222c224e222c35322c22222c0d0a7b312c0d0a7b224d657461646174614f626a65637455554944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225265666572656e63653533222c224e222c35332c22222c0d0a7b392c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c225265666572656e63653533222c327d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2256222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d61726b6564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22507265646566696e65644944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6465222c302c0d0a7b312c0d0a7b2253222c323134373438333635372c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333637332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466c643534222c302c0d0a7b312c0d0a7b2253222c323134373438333635382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466c643535222c302c0d0a7b312c0d0a7b2253222c323134373438333635382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466c643536222c302c0d0a7b312c0d0a7b2253222c323134373438333635382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b332c0d0a7b224279507265646566696e656449444e6f74556e6971222c302c0d0a7b312c22507265646566696e65644944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b22436f6465222c312c0d0a7b322c22436f6465222c224944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b224465736372222c312c0d0a7b322c224465736372697074696f6e222c224944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d0d0a7d0d0a7d
\.


--
-- Data for Name: depotfiles; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.depotfiles (filename, creation, modified, attributes, datasize, binarydata, partno) FROM stdin;
\.


--
-- Data for Name: externalbindatastrgsblist; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.externalbindatastrgsblist (storageid, blobid, "timestamp", blobsize, isdeleted) FROM stdin;
\.


--
-- Data for Name: externalbindatastrgslist; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.externalbindatastrgslist (storageid, name, connectionsettings_url, connectionsettings_urltype, accessid, secretkey, region, minwritedatasize, enablewrite, isdeleted) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.files (filename, creation, modified, attributes, datasize, binarydata, partno) FROM stdin;
dbcopiesparams	2026-09-15 12:32:58	2026-09-15 12:32:58	0	8	\\xefbbbf7b312c327d	0
c01b78f6-1525-41b1-9cc1-69e3da58d2ac.pfl	2026-09-15 15:02:38	2026-09-15 15:02:38	0	224	\\xc1b9e7c823dd36ba681370dfc2e2b75acbfa6eb4161b891aad10a580792060f15bc48fc8d6ee6f8b55e533c739d0df35fdd57014229f94ad989e506a1c627a70baee0cf2cdeb185b7ea64231947ce970ffc9188c8b2f8c9de13a6a12171d5ef0c98e80afbe80cdf6a679101bd340681ccc6d9df40ce4eba692346fb3af123fb6830652ceb091894b06e901780397a01d2f7ddaeea6f2cd8699934b2cf13b87a213beec1820fa899aa4c70ab1ec96d5abb2626df4fbb5c1469be91c200c440092866796eef26693440ec3bd2e32e6286d7ae38c82f7cb39e18d934b3728b0c11f	0
071523a4-516f-4fce-ba4b-0d11ab7a1893.pfl	2026-09-15 15:04:46	2026-09-15 15:04:46	0	752	\\xefbbbf7b0d0a7b22507265646566696e65645265666572656e6365566965775f4f7264657250617468222c0d0a7b2255227d2c22507265646566696e65645265666572656e6365566965775f54756e696e6750617468222c0d0a7b2255227d2c22507265646566696e65644368617261637465726973746963566965775f4f7264657250617468222c0d0a7b2255227d2c22507265646566696e65644368617261637465726973746963566965775f54756e696e6750617468222c0d0a7b2255227d2c22416363756d52656741676772656761746573566965775f4f7264657250617468222c0d0a7b2255227d2c22416363756d52656741676772656761746573566965775f54756e696e6750617468222c0d0a7b2255227d2c22416363756d52656741676772656761746573566965774f7074696d616c5f4f7264657250617468222c0d0a7b2255227d2c22416363756d52656741676772656761746573566965774f7074696d616c5f54756e696e6750617468222c0d0a7b2255227d2c22507265646566696e65644163636f756e7473566965775f4f7264657250617468222c0d0a7b2255227d2c22507265646566696e65644163636f756e7473566965775f54756e696e6750617468222c0d0a7b2255227d2c22507265646566696e65644163636f756e747345646974446c675f4f7264657250617468222c0d0a7b2255227d2c22507265646566696e65644163636f756e747345646974446c675f54756e696e6750617468222c0d0a7b2255227d2c22507265646566696e65644163636f756e747345646974446c675f4f72646572506174685f726573222c0d0a7b2255227d2c22507265646566696e65644163636f756e747345646974446c675f54756e696e67506174685f726573222c0d0a7b2255227d2c22227d2c0d0a7b0d0a7b22436f6e666967222c0d0a7b22227d2c0d0a7b0d0a7b22227d0d0a7d0d0a7d2c0d0a7b226465627567222c0d0a7b22227d2c0d0a7b0d0a7b22227d0d0a7d0d0a7d2c0d0a7b22227d0d0a7d0d0a7d	0
ib.pfl	2026-09-15 15:04:46	2026-09-15 15:04:46	0	60	\\xefbbbf7b0d0a7b22227d2c0d0a7b0d0a7b226465627567222c0d0a7b22227d2c0d0a7b0d0a7b22227d0d0a7d0d0a7d2c0d0a7b22227d0d0a7d0d0a7d	0
CAS_GC_Info	2026-09-15 15:05:21	2026-09-15 15:05:21	0	21	\\xefbbbf7b302c32303236303931353135303532317d	0
extd_props_cached/gc.mrk	2026-09-15 15:05:21	2026-09-15 15:04:49	0	9	\\x111070be2d65450200	0
MobileVersions.dat	2026-09-15 15:07:02	2026-09-15 15:07:02	0	80	\\xefbbbf7b322c36653837636533352d383164372d346535382d393830612d6165653162643539383164382c37623866663762352d356339382d343134362d383664642d3461313338653336376531397d	0
\.


--
-- Data for Name: ibversion; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.ibversion (ibversion, platformversionreq) FROM stdin;
7	80313
\.


--
-- Data for Name: params; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.params (filename, creation, modified, attributes, datasize, binarydata, partno) FROM stdin;
evlogparams.inf	2026-09-15 12:32:58	2026-09-15 15:06:57	0	6	\\xefbbbf7b317d	0
fe8acd6a-22c9-4b5a-aeae-232a1c8324cb.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	687	\\xa55431ae1d370cec0df8123fed2340519448de22579028aa4c11b833fec952e448b982e7b9f3265d1e160f2bac469c2167f4cf5f7f7fe7d7d72fdf65be6ab6bab69d6eaf467a7593af349a362b788846d87bebc7efebdbb7faf38f8f9f8bdf3e5ead9b8e54a6d57492e6051067d0ce383e67cf11f1f9f5cbe7ab24b717bef4768cb43636e6112cdd3286cf93f59f15de04b84b52e3e8a8b08296ad4323cd2a93bd527e56c854cf758b4abb93b63569f94dda5a63ede4db5bffa5c2e7abfbbe876d50af89b3d75ab4021c4387b4ee7c86c503724d76ca5bc2a8820e7172bdf8b302c2e6f2b11f90e0d9e3a00aa73129845284163573e5d3faeaf524a6a6d9f79dc4be0720276909448747d6b9ad0d7f423c9bde114e39e342be1c0c41847c9f399a858bea03c2b6668835dac24ae062d022456b64a1979cb1f3a9050c445da8ce00b10b76cbae91b0e327bc6cf893d8e5ce4d0f35e14d6a8cb9f0713ad1b41c27ccfbd42290b2147be65e2066eae00463cede650f7733e707a4b51ad7e7a036180ee69c18fc5162118eb124e61a0fc8946815bb939f0b2d8a027b6e01b15bccce6de6b3ca15f89865d29b01a91c26c7564c6880e912ed524f62b5e22e4b6236c83fd2c8ab31b5ece0ec6cdcef03b272f23c93419e03a31c01882659287c1c2dab3f9b6c6d8ff47b68f2410e77bfb4307818ad90041d87c77394262347376c947a37b92939a20c694babcfbba39e4ee635e4c629b25e0b096018061a684e69b66b1debeb01d96cb97935e84572b540113e516aca6569b7e6bf9c2cce775c464ad251251219bef3bc7b1733b3c1b5fdff5d46237a1e050b8695de9644b2da0ddac10b41e111fb9915dc5002024947d63b5e13667947007e80272e5c51f3d9e0d38ed74483114d742b1aa177e3bdecc7e0cbbb9eb74b365c613293f082dbe52c68b9288536354c36d669ed5708e4e0f901	0
locale.inf	2026-09-15 12:32:58	2026-09-15 15:05:23	0	112	\\xefbbbf7b22656e5f5553222c302c302c22222c2d312c22222c22222c22222c22222c312c302c34366632323739622d373862342d366335332d623733312d6462636562376435363332392c39666437306631342d383465312d366431362d623238302d3633636165336463636139317d	0
log.inf	2026-09-15 12:32:58	2026-09-15 12:32:58	0	123	\\xefbbbf7b38363464383564622d313765362d346335622d626237352d3765623036303635633833632c302c352c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c312c327d	0
42ed49cc-765d-4314-bc2d-af425af7bf13.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	59	\\x7bbf7b7fb5810e2f57b5412d8234d4b130344f344d4ab2d04d49b1b0d035314eb4d4b5303430d04d4936b0484b3237b730b34cd131a8e5e5aa0500	0
215d232c-9c9e-4f7c-8a87-142cd3797264.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
DBNamesVersion-DBNames	2026-09-15 12:32:59	2026-09-15 15:05:23	0	43	\\xefbbbf7b302c64643365343561332d313961302d346137342d613739312d3533343362623432626131647d	0
c4629235-4823-4320-b8b5-1d08f4c6d612.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	184	\\x9d4f416e033108bc47ca27b65790c0c6365cfb80fec1c6f627a27d590f7d52be105b4aa21e7aea082106cda0e1fefd7323b85e6e01e809fca3bd000142dcf2e3e300f39e987ac6daa62373173489b20c42960687e9656b09e8bc5e4e08f25fa772a9a935c5de55516235545ed1ba93ce568a66eb9056b87dffeb003e17dbf3e7b12e407eedd71cf81779bf329db8a53ed1ca1c28620d35ae5481b592d1c8ca033816492e849525a3f85ca2190736b7ae39474f663beeaa07	0
c77bc206-5935-48ea-b32e-508a572d94f4.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
fd1b2a86-b7df-4f32-84e2-befd4f3a2331.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	18	\\x7bbf7b7fb5a10e2f57b5412d84e4e5aa0500	0
cf8b5e0f-5e46-4cf4-bc6f-204eae2c4e8a.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
1a621f0f-5568-4183-bd9f-f6ef670e7090.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	408	\\x8d923d4e5c3110c77b24ee805eed913cfe764f9f860b8c3d761b942569a29580a0a44c1b51200a0e8012452281902bf89d2457889fd85d2d1f426f0a8fe4f96bfebf19fbdfeddf8f46eceef4235743a95002ed93024436108dac206590263021d62862668b3217a054f35aa44d1719196d4155b35f7772af765a89fc6ba2e544e68466439ab8428d12c1201648beb7b72629ab63258545c855c00bc73a8414433b6ff7edcf78d66eda8ff1d378dcaec7cfed66fc3a4c5e28e4524c32671cd61235689b084c9619a824049575f55c8bccb9cce3c26e79d98d4ec693f6bb9bfe5a19e1948677ef8767f5e5eece0344404f36a500cc2180d11421601f89b30c35791f5ce479104a0cfbe5c39bc3c541591c3d07e8b5bdb7878bbda3a9bab247e14b50647d85985de99d1543c818c039ab13e7c081d34cc63ee3b776b759f2f6ec0ff79b997dd221d8fea372a40c8658021923c105eb2a71466b69bee955bb6e777da9b75b2fbc6dfeb8be81d02a276fab0562d2609855df415fb12d9c8a226531b9f91017e3e9f8a5fdec2f7cdabeb7fb17309e2ad62053fe0f	0
c40aafd6-c889-4229-807a-851d0bc5bc97.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	18	\\x7bbf7b7fb5a10e2f57b5412d84e4e5aa0500	0
facbfffe-feb2-4d30-8930-a557b185e5c4.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	18	\\x7bbf7b7fb5810e2f57b5412df1242f572d00	0
e05c0074-0404-4b7a-835e-9cacd405960e.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
ibparams.inf	2026-09-15 12:32:58	2026-09-15 15:05:23	0	325	\\xefbbbf7b32302c302c302c312c22222c313230302c38363430302c34366632323739622d373862342d366335332d623733312d6462636562376435363332392c39666437306631342d383465312d366431362d623238302d3633636165336463636139312c2d312c302c342c352c33302c22222c0d0a7b302c22222c332c382c332c33302c22222c22222c22222c31323930383437373132303931303131303332372c3436352c312c22222c22222c22222c22222c3136302c302c302c302c3433323030302c312c302c302c22222c312c312c3630302c302c322c222f416363657373546f6b656e222c22227d2c302c302c302c302c302c3433323030302c302c302c322c302c302c302c0d0a7b332c362c332c36302c22222c22222c22222c302c3436352c312c22222c22222c22222c22222c3630302c302c322c22222c22227d2c307d	0
DBNames	2026-09-15 15:05:21	2026-09-15 15:05:21	0	713	\\xa5964b6edb301086f7057209af4dc07a50a297899ca6419da6b59c644d91a3448d1e06490309829cac8b1ea957e850b223a7c8665cc1d0eefb490f3fcdf0cfafdf2f5c4c4f3ebdf0d4bf67bb877df0da3fd3c9a2c8e1be81d6d9c934783d86bb74d0201c12e03b28f24e3d82cbea6a583a22d0e74f0e5a5b75ad5d817566abdc641aff17ffed229f4cf95111976dd94da6c9d16cbf744ac0f3678b05cfc1b9aabdc7ca09029b754dd3b5233b27b02bd88c6030a391b7d21cc014cf3e9b66e10e588a668be77659d9439aa499319df96e3a05d6227e904291ed66b5f4076e5a592fa49348533cbb6c07f460718a6a0b28e5b676ff2a13507cdb657cb0138a798b22eb3615f4ca9f490b37163081e2df3ee166a3a583b52c6ac89dc44f3fa4b8f83e651740eb7b430062241577d858be90e2e21e5f9b65d7c3140547b8af9ac7290ebe2f99a7490aee17ef97f605ef234806beb953b94ad64b69fda11d63dfda640fb2bdef77708c7b9ebf2e7ee2b8a23877d515550dc3a8f33de0fc49f5bbc0188a79675d3f2829d6e5ebf5285c44110ec90b239b461a0429b28d60f600ead16e1b0ca0e88601579d86daef9822da1bb700ab90a5f538abfc1fa53875aabaad75955f8aa2d2124fbedf27de59488d0bc5f982c3ac33cf3fb6b08519f2a4be35f2b760faeb0726905ad898b0f45fb13bc821f5b231e70a9cd4fd548c490d6d4c18f58e493d6d4c382d71b0dd99ca415f570ca258b782f27ae3ef9f14ddb207a3068a26dc0ea2e8967dad5a6d7b8e5374c3f96cec5d671e7755429c62dbb52ff078367cf04c04a9e4452198d642b0389273260264b59a89b2485391cc755f5230d02a3c0a3e78958208254f4b365709b0380835132a102c4978546825b4d005de146b8dc4e0515a4442f028666a2e158ba59e3119c73396089e9452ab8073b927066fa25015292f39432123166b1de26aba641c7401a10c7950247b822248861f88efdb5cbc9e7cf2bfbf	0
a07b62f0-1f01-484a-93d9-d42764cedac0.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	151	\\x55ca3b0ac2401000d03e904b6c3d2bbbec6fb6d65e102fb0bfd8888a09362160e739bc815889a2b9c2e4245ec1da57bfef6bec05d4552f81cd4317b6fbcd6c514ecb43bb2e6dc780d195c6e94c37bad367bad09b1ef4fc1b285d303122cf19916b153c472904cf4960139d43eb334810c056a529c7b24bc528064681544e9ba4050f525bae53133936aaf0987c466b5532de0f7535fc00	0
59274b8d-4447-4bf4-9d29-bfa099a1de37.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	10	\\x7bbf7b7fb5818e412d00	0
2203278d-ef4f-4f68-98f1-feb257d53ecc.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	291	\\x1d90c96d28300844ef91d289918c598ccb61b19bf84a65ff9092d24250388c383c31c3fcfcfffe87e3f3a3251f7b5c57a01d0b108be1f07c30a74db672c477060ec3ed12615065064c7ec0704ea89cf6626fd3534386de3327ad049c8780b331df5e20b9f7cd666fae91ab70491b899b02633d386e0ee8baae4a89488c3990364bf204476e2c5f803dba1079ca5429e59cb1f5ee2477d042e95bb9c16f0ae895ad3ab3873a3e16557b138846e73a8660a60ff6a5f52a4d56e520e72d99d1695e1b1eccdee841a63faf1dc871c71a2b859618c3c4dd554425d8ba0eeb563ff954486c845a76410e8d72436741101a58cea888679e3568789e29b60828b473ed2c88d3f257be319e621dd78c8ca25bb49ac0be13e2c683c0234d1cc79783bf3e3fbe7e01	0
0b698dcd-501d-42d9-892d-5a9157bc996a.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	16	\\x7bbf7b7fb5910e2f57b5412d2f572d00	0
ea13a2c9-0c2f-40fa-b855-710387e3271d.si	2026-09-15 15:05:21	2026-09-15 15:05:21	0	772	\\x9554cb729b4814ddbbca5f314ba76a78084764679069605a482001a277ea4623de569544f348cd97cd229f945fc86dc976ec4cec4caa5848d4edf3eccbd77fbf7c563ec81faeaf3ec3f307dd1e77b7934f1f3fb67f2e91cc098a8e8e9d9d28d2c6e5ca7d48eda05be4539e16fb761ecf5bd6847c614e7aac66658aa6f9d3ecf5f5d5a2c95e1f515315376cc4b53e90613acc67773d96336f6d79c51645a764e5ec77483ed2667ebbb3bd0340fcde71f9401b4f4a62ad202be766e63fb802c236b24439654409f729b206a244d2bab64e64e37549ec55ef9a52820c205274cf49ac4964e376acae46b2d28b74e30ee21d8e3d4e6b7220c385d15cf707ba31386bfc3d7da40188ffc324681205ccad1cbedc4b7f997e39ddc67247555702080769198da39121ab206b29dfda81c4660f1cabc9041756811b57c623c0aef432d9041956a23645d1c06cf7c0943007083c4e3c735fba4b9b64d48eaac8ae3ab2322634ee5b361ecab97ad7bfa752403c0a7d9d8773f10aaa7cc582067a4e64b722b9764f3664c96c2f841c242737848a6473cee2ccb628ad761706665847b5934f9f22e4497da8123508771ba3ba180f75a7f480da3a020455d2e565c46f0314296bd51823148da9f9d8024407be3903ffa95d3e5f2b320bba39a80488df8c8f272afcaee19d291754d16a0111b3fc595c25fc3afb54440a0c17a6c34c4051a437c2202e832a2df58ec941c554ff6523e019a2d43b8854daad8c36896591d13d89fb2a4515a7a59cb1fa08eb15680c011decd6a276f9398bbe4ae249fe0ba81955820a1a9044a4f07f02858f2998131035fbd57128d22ba0eceeace685d19d3dbf0508a606c336d69ae7127f68e0e97e8436e484a21a662b722fee92b51014e282ff449c50e6a09ea74a34f8b52ed3dad79de2eea76a01e2bb60ecd79e399592e9ebc8e0fb00265ad8d6a71583653006aa1a156b02ed79cd60fc6496129ef9dc332712e67eeba1e55b0a5faa1159fc273eec3727644ac9dffe2945869460ff78326fde827bb9a9a6fe6a17cea2d71d171f81ad6235640d7345c769ac9724ee6efeb9be12cf37	0
cb08873f-9adf-4f66-b995-0cb3d0d39b83.ui	2026-09-15 15:05:23	2026-09-15 15:53:40	0	362	\\xefbbbf3549316657766f55785665484e556a3164313530513747696941756a71505473564e5857507a5655454a2b59784c7345707250305746324c3657484954546e480d0d0a2f434351473553357333634d34636e53796f776d4a6466546b7175724f54697a4f5a6b4c6f50715330657453474b5a5836437877642f6a69583653736c752b780d0d0a4136597171784235633531434779636a6473454b45536e65574631367644793463324639326465364f387a356a4d333574686c2b756f3930684d6a714c3376520d0d0a633737584e5468375932744e486e76764a49396e4f645941392f54684f7830397a6536466253336e7a4d7163782f435261503841563850484250794a675438610d0d0a39324b676d69597938466e5076367163385a564a4b776d556c7935636c6431552b576959692b377943544e716d44392b683944614d376571444a77776f496a520d0d0a4c69635276526b67316c38755369485373637a3243413d3d	0
122dafb0-668a-4e23-bc24-b4b784da323b.ui	2026-09-15 15:05:23	2026-09-15 15:53:40	0	23430	\\xefbbbf6558766970514266357236703474452b6f4e4b67596647324b364848494a667030766e4a6677334e713571365533335339383534713652526b434877387543640d0d0a41535a4c2b6862454c6565394c767639337a58553243676e30396a35537a33766938756f447a44364e482b4c4c556e7a747034756e5234337841464a6366534b0d0d0a44576a41696d77345a463077634b75465656367870614f4f6c6770356c35486c3945447a7451516964704f4e7a6b6f306f5464364c65326d4b4e3850574e51470d0d0a312f47687259516c72776c694149417348777554796852354e56535953344e566c66494f31723742343467374a7875612f3844556e2f6e6c63617457416432510d0d0a614177766d375965644b5248674c564b577a624b5362312f634767363331476e7730346e3378626d5a4f35742f6647536e753168684d42466d6f6866596f43450d0d0a42756b7a2b434d71596c70556b70794566376d6d677375545a6b7544736861585259566948355a65762b587044534a34554a5049434836623732792b6453315a0d0d0a4f696f676643733336684a6f74496c392b64396732325865724c7463432f736134464d58746d675473344743526d63336c2f72423048394672334576534c4c440d0d0a6d555132636d54555867687a6d744e6241472f647a356a395047652f4a6d73674a39325a464f7a423644696e57685a76626c2b714b52457858465268426c616c0d0d0a31534a692b46494f6b68455036633949327a5876344c7046334872324e51796c3855484c6135553852454a736c4b564461597736346172464d7139714642754b0d0d0a384955343143455a6878507a2b7250496351764f4743354e4a424c393862544554576249316a74333633577a71474d507a49623973647a4a7678374d5a6657500d0d0a4c4f414c5836574f326148634353585352655957645757734833623847324461307364566c304c486455694170504847585a63323930756e694f4535497563390d0d0a56414e507132484a627441645163444b4b45676a764670456d4333314e2b4f3779527a507858645748794e65357732496375466736596d5a76626179322f71610d0d0a6d425434575342612f552b4b796751794c4c387a2f7a30796735307a37775a6f7259584b644663477948456141764a6f624d30764b54334937766f30663449690d0d0a63514a7244767a32425a6769396b6835704f42495234596a525a37535a42677a7341664e79535766457072424f554a414c5566767652436834334658673053390d0d0a2b39317874634b4d784a342b415239613435315734566661386d7a7561376c39444467353848666d32344679574861734f4d7564754f304f57736459767876670d0d0a62724c725378427275425069454f4c42594d65584c7456453664676145586357455a6e5a48752f377839622f3662566f46326932414a7a57667a6e7355504c4c0d0d0a444934732b5a3548553551325270526b58354d744676655637306453783247426276642b707067717645366a4d4e736e3246712b754b31394e6e2f4a6b3362730d0d0a623553535266644351634e495731455a69503170734b484a70703137585743572f484d667a37396741426a4647436263396c4a36504b6f794c5341562b2b46580d0d0a63722f58776868706e6a4c334432425736795162634f73536a61676d75673235674d614a67787a46655543546b7052617169697037326946504c2f353533324f0d0d0a2f4745416c74554b786b78307330757267344c627877766a74434d7666665872492f6b4773787a457a447371364876632f566e353833454749645751637672650d0d0a4974467a51346641384f52796f62687231357645586e454d4d504c6431447355554d55587a7136685a624e635756624a7265327253364e51772f6475797a59700d0d0a69654c594c6e5854594e32663953777a537431484b75477970674b646f56553975656a435a314a6d6232657656595076494e566c6f6b764b6f625a663264632f0d0d0a66354e6157626e626b635333366f44716770543531565450564268765556554a676955716563384d4157653059434b5a71523956716b5132394f7157456b6d650d0d0a627862613565337a6f355961343663506e585034456a70552b596834323357364d4e2f5874716e396f41316e2f6e7736566f5a76346d5657375a6a7470436f390d0d0a33584d59544d4e522b4950496b323376625a3865576252543357434834456c554733546850727052444254616e5951414855795a4335616d6b796b554e6737490d0d0a4b6130634a66484a70314d534e4d66504b6f396c523857667568695274334d7a43655243352b7a456d2b42444e68447670304847587a514d5039664956516a730d0d0a56774546774a72516b394d36476a373632305a7a676a5052624273555376393764794c6174574d4d686f3545786e374a5674316847434e6e2b2b65484a6138460d0d0a434936317244334b474444527a63666e4a3574506c4d464f62654659586d5a4a79365179586641766857766a4246456b6863647a72514c6f736864614c336f420d0d0a577243517542326672546e586243444a317575693538447974504232595a507a613271634833355238554c79552b2b36747051314e6a59635131556f513373730d0d0a6167755358336a414c3974477543466b654f58597934493465616f684d775972796a6f714f74414258655a3737637950785953513432394a496f75535133346f0d0d0a686b536c346d595a4a7258504c2f51704c5736784d56724242516437446b2b554a4b4b4f364f2b67786a6d676a59346a54596a6150794a71376869674c2b2b570d0d0a74316f496d69656f7172657846624864735748526f646943375130594865584f7142504c3244514751563143386d647a684b375a46592b5942736177474a37670d0d0a5757732b6133624c336f5a7a487a4d654a5575647374557737775468546a4c637650663870713145393161424a5463546847314963545a544e4b6d2f4a4142360d0d0a6442536d76596d386f3157467958556d632b6b346e4347586e42734b4170496434675a6f784e742b45784c773773312b63696f6c5563506f52645477464d63410d0d0a73697375506468507a7754706a754574416a36566b30327a70747a55797168344162682f30326e6461497152564e736c4b3142746d50366f344e574a304f47510d0d0a6f735a6c6b565347326f44585154703775715a376134706b4c7154734a756b69544246344a625034547451706a6856424a776d4d5773586f33584f59543961340d0d0a41447730772b582b674e70796d364e4d5961565238636566593745727a6d434d664e75524a6f624445596939655a6e323479737634375555644d382b6c4e56640d0d0a476a656c5a424d68592f7a6f513267614830304f436c55314d4b7a535663352f6d6f37304e4c38324b597479316974364571356f34306b79656c4b62455559390d0d0a79484f436a46694d5846797a774b75687730374a4d544f5a557a6d3646325776334377752f4b5a31556757567a4d616b712f56634e7536594b495a315638552f0d0d0a7a4f2f746777674957697a7a6f7a7332574f4152306535724c4d63455845466a7735617354766775704b4b4c6533434c39747336462f7646456a3056515061470d0d0a4c456578587a4a537975614c3358596132477837716251544654413261692f6e57627952366346714e345430376549332f4a7a496a41346d3444766a696a54430d0d0a7a564936715a6561574d536a627a744e6545336d323369615a53435a55375259512f6533667358776569723857674e307a4f6e4655796954615851446a7a655a0d0d0a683232722f58324a79355a2b64627557452f762f3661627a3870486b345a396e78466e3466516a6d766e4e3234516d576a7663394959485650676e794e4e6d6c0d0d0a785862744c2f4f516642307971583939524b39556530715068747578793269316f35396f45476c50454551766d536452766a5946742f334c345a7174693471750d0d0a6d4e4f376736773046464a446765374b744d49426671686462717a69635a673648646f744167524254463178305345625531326454374e444f785a6b2b512b4d0d0d0a5556613130506e6c74344458584261542b626c524e706c51786a67695972352b69334e715258755779796f6e74366774764c5353595172447359746a4f4c33620d0d0a687242416d69756452784d6d576544726a3937392b586b61646765697851382b6b37387370624e6854674c575871416f2b383355746c616d596a6b4f463858570d0d0a3041456c69465339596b69724c38674e6a4d42796f52315a78627966684c6d5a376b2f30594f4676544b726e4276523261746969617844447176626974516f580d0d0a51664a557659676d2b6d72455752724e61414d7548614e63343364656f79546d66534e44776c6a416d50422f3542376d4375376f6e4e6948654c5354763562520d0d0a30767a686753397337744c506257504637704c53437a33775352725534754c2f6c346a6b354467737966484b5a4c61546a4c5a494f6b5a444a704b69576b45780d0d0a6f6f455863774b6d68507a52386c544b763435476749306665384b475571706f6b41764d61464b3765576a6651387434506c6d536f496b76382b3573415236480d0d0a4f436572364837433339544c655041784f6d775574335546654d794138725557446c6a516e4432676a4c4c44646d54694c6645394c4856576a6761786c4563480d0d0a76774d63705778707733313249764b564d482f63762f4f756f59776456506767446755726f544d69526f436a734a5872416d42542b7343736578327a4c7a35680d0d0a6257484b4732647054783236754c4c30576b44504a3546544841436656346c4b2b614943737054516f6a423778497a4e72693043666f777a42313873486e474b0d0d0a375a6137516c53566b455a314e336e766976323154706e436946427449777747576a726c3972566b55475265357879624e58657744526a66507854324b695a570d0d0a77516b705335333371307173505561704f636e3667454d58326e774a7731774f2b3766324d5539496466576536633535612b524c35364e61644c6e36493762730d0d0a506b50594d7943797451544434724a6d7072614273586c35665969344f4d636e61312f436f4e51586453435a796252583458353366616b685731556d707672610d0d0a41352f39437834393763657a72766d2b2f3558556b79645043476b594e4c704e4c64465034704136626e61576b6e6e57567752594b587075376b31686c796f680d0d0a562b5578486a6e5a737061526f5768496662654575714733463154305842787a4551753638413977716f3476396a4d5167677434372f4835755a6a504d784d610d0d0a4253416b6b41763154435641477077353732457235304a69584d4d73306b3351386d686872744c535349554e38444645505653484e766269304a6166793747750d0d0a6941476f4e374168516a624b764c7039376c4542702f7850312b7a6f61684e325677323332467978764858416955463374594b485676626356414d33706933620d0d0a46787851723048384c6d7264496830427575673643565765737077377761596e6f2b75376f4b4f2b566971646e382f735073647756714339333032473976704b0d0d0a3150776e39376347425135684c48697434766e514b4d7072687672532f4b4d314c494d305761524573335935694d6a724547536c6b3765383575313159436a580d0d0a777078463173484543506f2b6e58784a54334d49436c6231506c35677863676b576846464d554e444d4d6877507855435a7a4467434c4d596364414a482f524f0d0d0a705252316c475954756c483335695954544c337245625137654e796f69487a786b3273567649525a354c70333531344a76785a5742622b4f437155344f6d7a6e0d0d0a474572447751734747576c58684e305777544958584d414d78754d336b5a5a6735383455494f6e6d715153696a4d325a355852317863414234524f454f51312f0d0d0a356f5745692f68436c3978686967663255457432314275714a426f393277546c6a52715375694b4d743168412f766e5a5a6559573067617755716e7032774b370d0d0a484d482f305a6f66484b493056697449726c6835647241702f2f6c446d77374d4374492f36674c437a772f58497935776d6c47326547697776625574744d742f0d0d0a4e58706a33634e385464335a33576f42496132426147356b594a732b7874736a6e556f39316f664859726169597358364c51494b33647743694164665a6346640d0d0a5774626b39526535532f63333975415a33423430732b594c4e324235576a6832464d675130646b4864544d616765695234476a356d4e2b634f45515436612f420d0d0a725844347971744e4335556d6d3567586c62536d612b573654616b386459486e516c77495249564f595a4f656365565234325a4e4a616e5161687674432b34510d0d0a6d6c68614d39744a7751766e693267492b772f78743974574e4f4d50366172487350544f6736472f55594d4268734752475256572b65365a484144527a594a770d0d0a65335370676271336659675a507072416d6d61484772464246383450666954673678766b465630306e5577456859575676466550614455364556563753376f690d0d0a58572f4879355839474678486169583155587372726f416e537a6f3939394a74394f78354c37716461747764454556496a775166516d473938545a54317946370d0d0a664d6b763253536d6d6e666a4b394f6d476c364141586e39374b386968536535454779456935574f4a724e2f336d6362655a5036654573336f58746f44466c330d0d0a6c534d616a3333754a356d52647271644a492f386568316b52776e4f3731434b5533434761514b7041564276726b61473846616b49444f3574313662583834480d0d0a3471675a4d397851592f31753561763346476f7a4634457266426159676f754d2f3863617565587370304a7656726b34306469355966672b53685757346856340d0d0a6e72322f6d6e2f74546e2f6a634973494d50464d626b4b5332554441697557636f52734a386c7876576e67334b6b4553565948466855633961466f62554248660d0d0a582f4a2b55514b67755733664e7a2f7a6d343934754f35723134307671395875525a4c65536f377959352b63797376302b6c366d582f6231314b3050564477420d0d0a324d4b62494e7a7a45654f72377278504a3667392b3362706635526b36494c4155465277412b4954704c334d7269577565716a7870546f583470732b576b4a470d0d0a5839695174347544384354623956555257387a6d44506d534734657a57415977416755664845494a74676252614c75473049493858726776703055666c5361690d0d0a774b5156686d4e6f78783134444d5358595048412b45446f2b64316b2f35563261786e2f4f6b3775312f4c2f64414a2f384f356f46574c35443046434f3454570d0d0a4e437958363848433677483764535a6b47715448654831366166442f2f5957314372766137626d5564315158326f2f3037677a66465270316c466254694d33450d0d0a4f68724c7373507676702b44496d71474930666734357a2f4575655643724965414877675671513179783966736b554a564e30373052784b6731427a6578375a0d0d0a34484d4e365235344f6a6547523363654d545742372f706c4f704f36324530736675484d6f73716875584d5265474b4b6371723736713661375435525a64514b0d0d0a382f38466b4368495a72546f70506148757854676d2b48485264494f67544639624645327979576c7850337643393373716f536669727337707450715571784c0d0d0a67745a427475644f6c71422f33466a44704a647642796542464c54317058734a5a323458667957334c7a614747334457593769574c57395330614d78615853730d0d0a786f2f54396e34714c66565a717a377a50346d72497657786d686432795757696c6951616f725945576e594d67565a6f724a447149714d5935544d2f4770774c0d0d0a7167614f586d39324e52485835784c627947777537597154796a425667575046796e45436c2f4a366a3039346a595a72304150744e3635466c4e667450364c310d0d0a4c57545830706776346e6b627a62626756646250384d5a63486636314b326c744a367661614f756d673473464733462f68736263427151653579354b644a46340d0d0a59694b634a6b6b587464486d395a33585a355068506341586f56306e303659524a465a422f685173635745526a594957783568473932396a754267546f2b47570d0d0a392f6671315035323970715072546b444773574b5a6a50326d4c726950466c634e415166454567767a52516452476c51755245452f6a474a7857374762327a380d0d0a7a527070306841644645376e6f666a526d4a6f4c677141724e48534b5a664e56476454596639323656314c556c517a486543692f583253313952674c6d3370540d0d0a6656426c5a3331445079336864726b71533164414c51516a43314f4b6c6f5566644d59444847546b523556575a77384d38434b3473356c4e624b756a485063380d0d0a764c6149706135743154312f644d73547167776f7469324c72795a594e4653514b53484539314d376a57776947323070335045376658485a676c362b775436540d0d0a592f396f42464e707053643153414d436d692f546d7a696d6138736a7a676557485631614b3869566562627346473442313765766c5a796656594356485648700d0d0a56596a624e486766354b644a6775646443532f57414f416f64754c7350634e50525951506238356e336347315a4b76576c62672f7262755637546177477343490d0d0a764e47525154466c2f7443743034784c4a54312b3344304d7347686a6c544a645a552b547374544c732b4a34306d3533576830426674713132704b785775715a0d0d0a514a5435644d74702b374c5a366c737a7159723341564c473549366a6c6d757657446e5464597a31334a656a76507469664a645146546c46764e6535645843420d0d0a6158764376764c636233494b434e624b414b73625543496e33432b426f696c2b4d73314e7356616d636a325441526a354b4e54334d6d683857384779705868450d0d0a7436666835634b597855717252774b4e62456236694d6f59725077676b6e72494f4f43374c4948757550327156745735542f486b48793574455646497a576e420d0d0a65674e7a4253496a7a474c795a70667532416f7a4635434f794f6a3673562f397661584475734643414a615056634a382b44457370624a41412b74707377564a0d0d0a617966503465654849513243534f5231703476524936612f55476e4c422f6974645265726c426b7336462b413943444c525178426474304649642f332b544f6c0d0d0a70504e4138425742642b6a635462566f7644395630716e56504b4778584657656b75553134713766724c31464439562f43694e774b2f4264414b7a63447a794b0d0d0a6475743764744b71626557444f6133557472576e72582f706775664b694557476c783578426c4e4f795a716953432b586b77572b6c66323341422b32303561760d0d0a596d566775574e76703776687a4b355674317938694d777a484d78763675437158306e784974787734567a625766502b614d7963463553354d544f69712f624f0d0d0a6a766648734b7445415678506448646c336e366137386e66494a6b6f74546b2b6c6e7349357032704d6758666f31423039686a6855346e354445486f716457640d0d0a44783846306254396467364d456a76546e3358324f517378387652312f76612f4d655977526f302b64356b38385732336e465156474f546c72354931523476320d0d0a52356449415944687178626a75707a6d5937674f7764465448526b4c5331693356695356564350782b45757266725a4934454e424f68444f594a51786d4b58560d0d0a334936754671726e764d47746b6777676e6a454e45456e61536e74764a765a62683745446d45703374735736624f593954545577554a7549774a2f4c4e48796b0d0d0a4b72754b7973526d534b4e774f3544737741364174472b5864453864485454514b704e3949677668454f74664b2f6c3971374f62715972626e646b6a6f4735390d0d0a73626a71744b7736434e6f4d326c5550654a50746a61724d5a796d46373770526b6256386c6d584f6c534f43416f6f6c4d4a58345565354b5a6a3241744647450d0d0a4c5371394d4b787549474f74457a794244465546486f307957736975783651655463686e6a4e736363794d77474157637731483947464d596f462f69655055710d0d0a4337637176503943722b78387538384c313441393356673572766878472b31653445546b3170375267384b4c53436f493351305355623155762f544c794f32420d0d0a6b44526931526435476e6e6743464d7858454f6c4d4b616a2f32572f32656666386769396454594a645973397064322f387758674a346d495259596b705061630d0d0a696b2b532f496351766b7034726273596b694d4c4d457837464339704359473578573378422f37544f5941362f626f5868393045486c4b756c683833456572700d0d0a663257456f744a4c2b474852567976302f49726d59307655386279415658576641684564566a536d576f454f4972535a7a622b727a2f744a5a32664c6d7a537a0d0d0a52695a367867474634486c7a55422b334d4c37374a4d64546a2f57306943305a696530624c334e7268474d302b516e58737573304d616f66744e52566e5a6e4b0d0d0a426b6b6a72352b54675334456238766f6b633555376b42784562643836487a7544346132516270794f356a6f4b662f553867534733396c4638664150597a494a0d0d0a6f4b70646f6a7977574f4957744953355265714e6b52535476665530494e463162556e6d344f47494c6d374d517533317565684e4f58792b47383553512b39430d0d0a486d7338676a46515556512f5464514f5439324d766b6251304f7a4b584257624c564f516e69787333624135307059667663495368726734513338387169782f0d0d0a544a78415a452b6e624b4e36754e7a79564c2f4d4b502b6d42335a3937755257796c49686c367a6d4d6e366a736f77474d3261505a756a776d527154446448410d0d0a646e35346a416b314c7574434e2b5954727a674273337a5856573664563678487a424b6e553137337376736238647864534b626f664b7533342b532b783137570d0d0a70347a4946616d37482b387a3264794d6733782f374336632b7131794e4e426549383433515170302f4d57523063672f514c545976537456694e436b6469776d0d0d0a714574632f505a6f5652512f6575787757306c62336e73694e6961636a4a5663533643512b38715a59424c7a55546a355534305667665774556b4d38735139490d0d0a64676e68656f37576364674e666c6a6d6549537462714575354152334b5a6b3958727635484a5a424a6e3677694c6d754c4c36725869435a43373253456a4a700d0d0a634f5a595172674956627176356745702b4d39545153746876696f69527251783167646448507335535673384a735a712b36676e4e776f795a4a39597452536f0d0d0a492b4e494243756b6d674b313567482b625476612f4351322b52435a4f6733644a2f553669784b626c73536b2b4a4236365974423754303063623858397744730d0d0a4968442b4e553831526178545356652f532f492b384d61363365414b585565473078596d376b61537675523476454a4a68506237423861357963572b704f4f350d0d0a4a2b4431464b426b5677697336304c4d7a4a66427039797a3541366f6762376b57396864552b537a67665461366e304c66697036767a393847583757707069470d0d0a414238594135457950474d44735872553478426d5a784668516661506848794f4a4a574745464b47466b6456737a39636d397849306d42455a775358514e4d560d0d0a554e75416665733564595765434a4334594d46484e34456e5635364b47696e4a3259474e706d323468695641784272786566725372622f6a4935695767736d390d0d0a766b4362437365442b37496d6d50714f5537646c53753946465772654f344f527234386d4c79705939304b57466e536b46366241706651315a5867354364644f0d0d0a326657385954467a4b2f45567a4f4a635942456d524d473976466c4779317362704e58784267796e4a4473494238796c5049794d325a354c36494a597a4b424d0d0d0a45754d686276474f46793139745a77695a56486146482f43787564685a6d49446e584241303766417670794d782b7248436f6153334732446a42624e523849520d0d0a584f664b2b48733756447969316b64422f717242695a6d6d79726f5359616f2f6650534a304673684f457967383479796c396f5a503944726549504e736647330d0d0a3230613648557643756a716375324a2f364e4c567745534f4c7a414d744b685846325a5a3143456a46356a4e6a4668665057597352494f7052786f44456432360d0d0a6476624667494d336e55703335722f2b617375302b4741686a595a684e58484668764f36576d587948676b793239465338617244496a5937757042735a7144350d0d0a5667464b477849745358612b363153472f56653372646d774c636b543858535131687a6b44346956746b79487a4373536d70627a6f39586b68516145647376510d0d0a68374c444c39495674432f2b346f6d34733256474442395143517851715a5973576c4657334f574d735a774832364b34474730496a755364464c3865624939550d0d0a45793951503550616d434656654368784d6e484978774c456b4c722f62646d4746304f5135453173644661536d694b3167622b37545354724c4166644d7144650d0d0a465668482f34394550394139694c4533676c62726338512f6c525952663971564c3732635272687934506a7979704e577750427242616e312b6d32416a6a444e0d0d0a4466526b57524a4c6b533049714f597469444c424277334464357045744a34564e425070337374706c4d5a51412b3068394c73315154314b546832447a6c59390d0d0a6f4a77594a7a42684761533541724365722b4548574a38557759365159334c4172555a30375a424e31534d35496549387730677076664563785259736f6d67430d0d0a356d49645437593255706b74774c786168752b636c72526c31576339633257327a684c7941736f674c55424d526b504c394d43452b66367642737a774f3875410d0d0a3946414a596a44505979673850686d3374542f7535536c6d676c73674d5036634a4779323830422f6a45757558644258526375314f39304f555a5774717066630d0d0a45476d2f454346504a6e4b4661745641306f484574655765693976436d48325570526956556242704a5566564d347a344a486f5535466433387a717275544e350d0d0a6872574c714b5037736267704c596d6b306d6c3662682b4b464272544376655a4f5874465553635757737250726e35667a63306462453969663375474b3246650d0d0a49646775704b3453384a435163432b474c5a476b5a6548344d71482f483654427069366c77644d42495a7949354f6f39697234773036692b693163436f5433620d0d0a717a7168567565316a4379656e52497a78432f782b656844344a3172556261714e7553565261472b304230734a2b53637a3733613161626947356744535738410d0d0a454641477a507361664b337348502f3654663758745a656335484d55486f35465a5349456575464e58302f7354526d644b2f62746743546c586b314b52565a490d0d0a6165547643767a532f57695345574e4c6a665438347259717155666567474e724e646d5967656853563235616e306e7530323068374c57665244674c3531554a0d0d0a6d2b364b594d754e4366436433474e494636627163384c48457a454e2f4d4f594c304e3236754a6e79615a676f625162585372317562694e4f6d6e417a56564e0d0d0a7151794731506c664c67376158687a4a6f6c3457756b7a73765863466e534e344b4359415149394277772b376d6d307366686c716d59564663706e6b6167324b0d0d0a484f5a4646554464386536345958534b6d6b6b4d76326c4a7a7766434d626c6e49716d4c4664464658664f7663734c7571346b6235682b62314d68522f756d740d0d0a663041362f774369554f4577464a77375532534e70733358355a4962383961526462775452674957646c3059305154326e6a77483878785664623446366366610d0d0a70482b6d6c4a3650396532317362656c6133665055766d51334a687565685150574f514a49532f4f4f38696456664e52785651367278455144375a315636712f0d0d0a51323678506e5870514c454876586f6838374454675846764d4269324a416b4c433161587938387a7861796f7669724d38454132477745554f746969676a74320d0d0a6a444a425164347a42485646714f3463685a5949646d444d6b456b634a4d484f78535971345a5a747057326e616452652f735033584b6552334e366b47734c4e0d0d0a394f58315a734a386633474758554d444b52454c53356f32763843645964374c49437777482f4361344b7431657a4379714b34454d494351624e774741636b360d0d0a737a496e722f4673536f613135374a6e32563871515833704c7a6136374b686c32596c7451786f6d385568674f456b77636547344a59717161654b31557630300d0d0a486434306d4978654c582f654e6151776f48466a4963527777582f667a6f7748644a4f4e7935796635397048767341362b466752693348446f5a6242653570440d0d0a684d75347331383435396e5a792f584a7343563136546b6358467a61377270463232625638524830337438756b794d5473346b364d4c7a5254593739595656790d0d0a5647475373537532394333443236626a614d7a345969452f7542523449634934354f31493553656361614457583143354d73524e4553767045337756526c6b430d0d0a456d6e376d4969754c333132364d56573772784843374d426e6c7a686b6a4461585755353341454f556e3332656f417946756a48415031796446416f59717a4b0d0d0a72465a513434565271504c4567312b74346456394e76784f487868393079506b496579736d59486f786b525a786d364236693342666b73314b4e4344364457470d0d0a2b51466d493733375a77506d6c6c785577736a7242737068434567586a7530362b5137363938374a4b324b39516d4b75584771433235355246366931567445300d0d0a3359355959454b702f737254456b356f3535477677716259557052596c76792b38544445656c7565745556634d562b644b436154764749336e6a456f465662530d0d0a566654542b796f2b5245714e6532573178747867545143627652754264764f43747266356c6f52657764367434642f3137426b5a664b6e6d79616b466b4935510d0d0a63354776356733594d4743795a6d57464637444672566a4854754e4c417074437a455659336457573273726a7575454756392b66594a552f74597744664e41710d0d0a366b58524d494d71657630346f704d6b6a6d4e6d6e6742356b626445334959632b7a6e4c6e414a444e666f6d52753277316e72526945502b7371386341476f680d0d0a51635a43444745704c4d625a756f4c55443676726b42764f6e61766965767076774a74744339722f536357424b767442475664766b4c384b4147356a546d6f5a0d0d0a3361494f73537169646a736447522b34317978453773642f6b4732765a7a512f317253515655346639334b36544755544873364a3353347a48494678704e79760d0d0a53555368594f6e5a6161783058336a68726754574f76576659464954583953626b764355504543526e7333687568644547475862454935626a5a30526f612b670d0d0a4a546e6538554a575645315551732f664838494a3631594f56667932554b49623368474f417258754e6b334c73317a5575387072664e783141474158634b78560d0d0a666f76684d764c316b614851375958374837766b436b7545582b464a56524c65353953364d7a2b753831623345466154624f38764f44776d6c4477365732426f0d0d0a78675a75626d645072444443723739364d4a6845682f644868524a4e6f7a6f4d7746736b59617245454b6a4b496635363662317479336b5976657034424232480d0d0a37334354734e4779324f4266454f365537644548676f4b704464502f615037554b5141442b3147785672724f52436f3842766c654238674b554a4f32777335480d0d0a6f566c422f6c4d766730366b6f684a5852442b7166466c7779763551506358506b53647157522b6d456d3776754a756d667a694551597546644137546f4e51340d0d0a70364536574f3378424f45535a6a61304534472f5774515755757861663957436f6133455256747058507430626c4c68756d534d735971496b5570374a7568530d0d0a717a2b626e6d4a353964337839457443344c3135786c4f2b7750386333786a4a685756664e384255793449743574725169566b6934557676734577466b3050550d0d0a534f457a6c462b6b68597a4d44516c545137776553554553334f4f3973595a6a4f473436454f314d57304847727a78586c466334507a59795a6b6d79587a745a0d0d0a346e4b577162457a4367423044582b77526547696a49747757775247345178587936474e4d7a6b533264644b4461373050616e4947785a2b78706676745935610d0d0a53547331364b44497534574a2f553454494b662f2f35684c7646493049763175356d6a5136514c67666a38414f616f356c556c574c4537576a6a7535754952420d0d0a61714866713977366c6a7a4a5158422f5878646c6762342b6f564b68415448306d4865374e424664704a68747a5150443258566854566772337547674b59546d0d0d0a7945517130494471764c6b705573646c57354a34593455586172374c74582b30753937645353567055587a2f652b6f4655304f522f4f545a532f38774c366b760d0d0a526d7964302f315a565376567643694b44635156686b554a784f2b61642b7634695457347a767365396257694b5052497467316966576562704e6f477a53506f0d0d0a65686e516c33374948386e3436447144622b7768566c694f4f537a454b496b77394e3745504e6343574c466a685176694f3652493735577679755343794a32390d0d0a3866476e74587a37457154343072697270516859552b43736761757a2b4a6d7174466d73435679576874574256413245704e6a7248374866534a57334e556a710d0d0a2b4f6237326770672f4e2b5a507451392b46556c78724553676465795a3038536443786545533937584469674f6c486e775731494b414a6c643053662b484c360d0d0a4235356574586c4e644175783832577754755270743539394466623463476d6f6f7834494a46594e6836486c5a577a5345645173697131643466525a54634b630d0d0a6f422f5a42734f357633336a556e325a416a6255397350564b7854332b65616f6d4a4e2f50597a4970564a7059554757674a4750777068533056572f59366d630d0d0a6643555a5378614d4766537a612f6a4c6c6b30367159377a3547435a766343774e70513349684c76706f6c47624779724c4230434c305137713332486f78516d0d0d0a356a302f6877686336645955664763485471782b6c464d6e6a4a7a634154575479665177742b747847447a6d30594d414c3142733074582b504c4433526564770d0d0a662b58706a62613742594f7a76674354437a3678694148527632574243387738424a382f717244596b4d446d36364d73413159704a6a62337a684556513674680d0d0a44565269327335344271756c6e7753767830444f337258584652414b7131304d4b786c65465168556a6b57366971783338637470684441304c796a57676b754f0d0d0a534a6f4b426e6942314839314d666d49724159487335444f716e682f78636b5a4b43694b79666b5843476a69334f794f3469755053454c424f5644475750766e0d0d0a7149734f4d566c78665272514f77444e6c5839452f484e7a6c307155545a316965706361764b685a422b6c6e4f434668464b623643703731714254454e734d740d0d0a7734317a4f6b587938447634715742647a7a313873464d306d693866447551546b4879412f556f6b78326b35632f4b614c4437724a2b777442355a436e4e45390d0d0a5a66664a426750522f6842747a39786b5358415832493930477241713438746e63677a2b2b35704a6b2b333047374a3663556e4b5a6a516f7067356c584145640d0d0a4b3839497953765464584b595931437763666b4936347078307778623155454d6a6e68312f3537324577755846695552496937443430316b4b586738345548740d0d0a33376133425137433657613961764a312f382f4f57566d7a79354231346c68623431527a345934312f716b6374315164664c6b6c76612f7769697a694c464f4d0d0d0a6a67774c6968503253475674415262375a464b6151316b7545542b44324f2b353938666857433446475355555164624d77684b714b566c7062585633787751520d0d0a4643755070534732386f54373245636f554662476d7277344654456a507a5a6f577654624846676a546f44426b6443766c5645633434635530366d4930795a730d0d0a322f696678746b31466b37575a61395253467945344c43715878415067586c393358727a6f347266514333742f3648756d6b64364845476775526562567536730d0d0a31704e52396877706e7236747968797334584668582f4e483564326230626e76437454796f396261506e483463644d796f422b6871594548474d454c4e62377a0d0d0a4b4f6d767a443742462b55666f5868495a495741577530504c774f6c3632582f62522f6937597478456d5a2b30362b3439614a6865696f5875575977564257650d0d0a4277783941755772557a2f514b484b51717141456f473270635a7839767666634c694478775348394b316a75642f7452676372765731586f34526f76624e52750d0d0a4657445334796a50336b6477643732464164714e385672394f30714b59626e38543932306636542f43506f4b4170535077374463774f7748524e6357735a484b0d0d0a6974433459724e6d39722f505437394e2b6371764e4f4a6539582f307135306832675938764c665562385339313165384b6166794c4c6758686a345568476f420d0d0a724e57624a4c6835774779367248536e652f79504e737134322b6246544c7438445777454d506641345434512b417948556b71386d436773787077644533396a0d0d0a65747732746268624e6f6f4771685950544c4f4d4b68414c414451716b392f4331385369454a506c55684b4259357248566745335639766e58524d304878524e0d0d0a4556776851775458636548397847377651744a555a31494c6337313579775648476d7275573733524c6e36416a7974617a7330514e767351643732766851386e0d0d0a723355794a2f6a666f4467616f765372484b5452677939505a6d6f4148354f615144567246744d42464a44703456567844705a5134384f6278434e49746463750d0d0a667549376c347a6d4c5349324f3632656d52317775756c646d5064347a34485a76596737554959575a2f47653567663659596a6b7a6f5877624d476a332b63470d0d0a2f74614a673532773776733648504f36626842394459536b5862574b6a4a5a34755679453237554645746a7771673039734b5a44744e685a472f7a424d56304a0d0d0a37627343755a48582b427655536373316e76765854455668655943324f466d5958634f5937615a494337756c7a374d2b6c6453797176787752706f446468674b0d0d0a35357455352b425833576d4d43716d32357470496c46795a2f483370336a4d453273766e524739493948777432675830634a38655241634f45764f717575574c0d0d0a794a4c51612f676552664f62584d61422f6d64706b6b4e535974654445592f702b48576a4134544e2f68614e6e50445a6443416646696c4d73546854734246450d0d0a564657454772556147652b30367641306339656e39314a67336e74334962474e6c69554a654d364b6e754171736544694c674375464f7372464649545459772b0d0d0a6f38565053346d4a46427a756d6a4b6e50673269767a4c4354617978487666434a5a586957383358526c53614f6e54707a664154683847356c3953364e536b6b0d0d0a30504238733331743357724d7871517a4c353053595647734131794473325048336c467376304972753241473357554a2f714b5967747745483072412f3349510d0d0a50465978746967786d4530782b774d75456468447a37476b633863436b6d794e786b5341646935374266307262517871385346516a384653555032444c734e6c0d0d0a3453354c7764426258797830415348394b5334623452543378327173346f77785936314b3256665043456f7769346d63507862445842637657566473354f78700d0d0a68334f5663554946426e6a655743504b46525a6836736a6542383653304a686170575267796479446e49674437484c3364304166716e492f5664596f515079330d0d0a6e4e59634d3468794b4d4b79306c4c45414c6e573039564447595a6877703839426d647966684d52644b67695652772f38434369325855453536384f5043576b0d0d0a554a5871694b763538674c4c4b575a74625378655558326a4d2b365566515a6d6b4a4944385a5252454b51687336612f6271444d6a637151523238646e6e567a0d0d0a326f6e4d5a6d6f43517a6849304f7830682f50754d524549567365302b2b564d6a426a323858514e415358336e4871716c5235326e79733663495755735068610d0d0a2f483355326673626d3472703368337259306d6837446d2f54714363664e6b7942476e7170566435335647337564597241663864317369306e5073736b45366d0d0d0a5476783748326b72663051543342514968527670744e6f4b4d6142394c73694d4d4e2f365734532b45796135496c5831354f584d4478592b2f434a786f7862630d0d0a464474354869505838636778785244467a696533787961665876537a6b6363466658747347507245454f72644138666b6c422f744156747a41375a307659504d0d0d0a756f3156394f786c4b6b567a767a716b4a6d546c39474f50313358704b3634724252587455474f4738764b574c376375444e4f5539776c7871714661647455700d0d0a7a55497a573052704577506c316a444a4169783556487a4e72766241486a4c32677969775847305a37664a4f515a79707350586f685a59734c656956744b2b6b0d0d0a4369596b43464d4f336d38726f75544157564b5877575130564b59625639554a5748355a796650674f58785135396b595346735975574f3831703159796d63450d0d0a6e3865775a534552586c733977583077786432583143734251497333326c31494e716752766c655a4c556f7a386b3142306a6536506c38434568662b796d454a0d0d0a597653424969702f4c4835576573434d4452454f4f37416141554351365a4e4442637a43695034353371464a794237677a754a57333765716e446f48447a68520d0d0a663354654e6d4f45574d626d514f585975506a5a6c692b5454554d485059754c536c617a6c646a4445734c35317a4639437573445071567a5a4d79453435336a0d0d0a7470413954385363334574536177675667755139767064336b326567374e754b5156394d44746b736958505765544a3872424d74394f387254634f59644e35610d0d0a4b594143356547746e684d44424349796d64373235505456424c4866577a2f514573543563466b414e7863684a327375444c5864704c354c3633793944416e4a0d0d0a4278636b52395a5653776e6d5173564f6a4b6c66774e4c71304130627866376b67642b6b346e5055515459575061596a683966354f493534484b66467a636a430d0d0a704a4c785a78747258795732326e566f39523435316c707168734f416d772b64622f4e45353253414d5974736736775368464744646a746d5a6e716c477230500d0d0a556d354364306635774e4f6a69766e664577536c6f736e2b6e764a6a66765362715875596f793370666c526f6b476146556454584a36743261326861365161320d0d0a666e644961415139326b4d6369505a423464615a5273414c33634a364b5331305164555057756452374c4648526e626969476c454d733549347a2b7277686f410d0d0a3752326376644e4f4751653470506e6350762b615858486c73786175767955572f44372b493651432f50617a4558596f4535732f5a335638347a6d72536e30390d0d0a7a304271734a364d4a6e546e526a4355786a6834656b52586635527a30674259525930726e44503530794d45316a514442367a3657464a6c48464d55456477720d0d0a2b435a627a412b36697a703276446e32336b6c6e6b426541394269474148325a4e727130334b564f787665676e4b744771796c7145326d4b6f413478474250650d0d0a436f723346584246474b53667766426d65515a48494d5739652b324769697942684a303755744b794b4d56566e3856727679453645514c7444634f71444f38780d0d0a4348686253556866465a56316f4d47644156447139374a756c66646b655244614d4655444456397451527435385455686931314c6a684448646b737655466b500d0d0a726a4f4f4a6b316f2f6176764634416b4b71727550684d66497541753330536b4132535865504f4c536277523737613354686c425a3959475961386e464238560d0d0a6e6f6d616763666576657043324a307939704565766a6e576559567042512f714f324b65746270664864707449616d413052665a4d366461556b346b527354650d0d0a34426743786b6b366f4766716b794a3544534b57756b5a4e32764179664e614365436237576a50763759724d665a7a557a474f52684e73725751554a64304d550d0d0a58304b447575696435614630663943677776494b5552373036674c59784d7a4b7a58703777764c6e75444232564d553030373970476c744a7968316c774574750d0d0a6b34506d6c5067706761576236434c61542f5364766c4144615a654a562b324f575467697152567748747065794652655136616a687551476b414e326f4949720d0d0a366f76376a475a756b474549664c58665056453847413959686949744f466e61634c5234754c672f3847505335356b65724e44493371324379775454397853570d0d0a657a2f2f733765344c57746969634b52516f336f65726f6a7176706e57544c627a343274316f68654d2b72745a7149704c323442526f5a796d424b77714a694e0d0d0a7944706c6c6f613138734b392f37587363594331374e457778766f3147357736396e354b6c6e6d356b4f4b704d504b6c375a4a502b49336a55447936793737360d0d0a567566336d566b2b756e5a49736e49476e534e746d5231796948326e48723841734c5a38756952327a4557716a2b6f5a6539504b6e6d414c6e686d75676956750d0d0a765264564a59354952655a334c44653063364c6f53322f4b7a71696b4238484c5563673264477a59697434544e69764e72725646495375664936324b6c6d36450d0d0a397530544b5444476743446c72367079445833324948724c495631666b4e316d7045797879727843664b7a505731376943314a6a706c4e5270366867444342370d0d0a6d646365304133667036704779497347337a504347756b34525a645567357568434a796e636f614a5a486a7270586a3371716b4d584e526144625071513866610d0d0a717a474c652f486a313172797444366843466b494a6936325a57675444777153426154707666304d4463435038596a35564c666f34316879666c36576f6141390d0d0a6659446e573231744b4c6e735667756451653867596749494f694f42456c70353066772b6639746f794f6255726668327a37344e65652f4a304d2f43734570740d0d0a6b744971614a4c552f3146754c4168514f496e76524f664658396b6a586f6d6a676970667a384a6e65307335776e464633413376476f67574c772b6c5a7842500d0d0a486f656b51735a68767267466130635478705a554e794f4c744b6c6e6d624a464f6c723651464f62676c746d6c70707a6946766e6d367479616f766e38694d380d0d0a5346714a594d4a695157773465447170667a63344d782f50674a634f6737426e4b7370465163755a4c4f58702b786e6d457969386b413035383949766b5949550d0d0a54445751306157713046726c4249334e4837773138486277352f4648774f573977774a49594c49346571523850326d454658396d375735394e2f4339326531720d0d0a597a7968756d7967336d376e6a504c70514a316d554f304d4e7655724e416950586d727774503148704c397141494f70694d6c70625a737431306f77437a734d0d0d0a526f762f3770612b34644533532f345a32573953562b6c417654646f664d7138744b426b794f38524f6f7773534161305672764d793252712b734f496e5248630d0d0a64322f4e617947494a533872466d6c4457575a7372384173317034554d5a34347568704b5933364b584375676e4c2f634b7764766f5159637a634435364c73690d0d0a4d4e5237692f4e67764342444d6f43522b476d5032447552436e57414d31354f576a66394949346e336247726b595933432f476f5a79494c6f395879636e2f690d0d0a504263664c5058575064716e462f4133716355583175767854704c51696e4d30415a53585a456a496d6c725778746d346364366a67746b5730734c556a4b6d6c0d0d0a4376656e43316631676e3352313730676e746d433478413965763274443755384c54663239744d755a6d737a565550737a446747484f632f36775345687966310d0d0a34427635502b6a577133586b4c6c654b35676138364950504e2b30496953666a305862694a567956626e4e676e4f3539685a316346466c544a703136763875440d0d0a627a414c4d7444707a7638656236313177467238516378394a474a303351764a457a4365504a7854364652342b41466a5071627256556d483059526c6b794d780d0d0a5a6677365a2b4f6f643337762b586330726e4d4f4c686d757a4464573848746766673945394167554531486b50396d7638507665646e65414f726c4651476a580d0d0a4c45384a6b5a6e6374556e676d6e6531366e7a446969304a614d4767476673616665426d796f353769464f7a68584753795834364352774c334f78317a3558770d0d0a7245627771514c463436586279626f2b774f30374c5a384b61474f76744c697a41412b744576576a41657742545950716c5a76684d61454d74394e6163637a6e0d0d0a6d6c337966564d426d586c72426930794e73573945746a51527276714942307a50466e44705066696543794d6961793632666a6832756d7a725a63726c624f450d0d0a3872394131594e7a4156354f4934645a7239466e48317a6631597167554c4864386e45692f44324b39687053472f53744e5863446c3939537450574234447a410d0d0a557755523238632b6361546a4f62626e6f7a4c454633446b436144412f354737356f5156514e5a4650366f5574414c4e41783147304259563861666e454735790d0d0a7a737843724a7279386e6b6d5a54567339375349736237484278595a77574d4f574b69677937654a7a41376a74792b696a734a4c36394d3572444d74656869360d0d0a393438385a616a734f5236496f724831566763632b43674837343537734762654e6a4a695845354651627a736a6745796353563464696f697278546d6e44362b0d0d0a523036617a6132486b6c474f65337a304366376d77747653533978574754315467634a7157302b37475a452b4e64646d6f4c5977636d5656506c58767652632f0d0d0a61384b6f5535714e53793443713372553338394157476d7571754863362b3244676c2b424e686f674b432b425a4d762f4b386c53316173304b7a3451526f67560d0d0a396c415a384e7250477a7367716c6d502b53496935364b5459565664624b7544714c5a62587a79306b42524769784c5551647a767969333279324c2f704b6a680d0d0a6a6c4d55433674726e66634259452f344e77656f6c67584279734c7867596b573533495056547a6470557030384b684e436f78434a394459462f4c6554615a330d0d0a6e5966507755557567452b6467586b7a5242424a374e76523374663645597542527544624b6a556565365a445974533953716e51536f63515131597354676e480d0d0a436a4e48686464697770557a3732467a45652b744d614c5a71686963384d2b446b55686a546135553858697354347475597a354f682b706e4e366233333170590d0d0a624f46666744676c687868624753656f69313854725735476766647632783043752b786d48373136484e7759554c316541433533414370395a2b775264574b560d0d0a734e794a35776c314770336b437476784947504e6a75304335415759557a6d314d33394847502b72324f653966434b6f6b78336b6f7a464f7278426b2b317a510d0d0a73704761456a3749575778556c5a7477703461754b7245386a6437653942505474786952373741357a57487153667a4b4e317070374a636f50764b2f5866584e0d0d0a784948384f75384f51756939322b312f4149305a773959696a33322b7332314e53636e48624f3371523461617a6c54494165644b71633354686e43476a6e346b0d0d0a786e6846704f6c42476c77753377796868466974316d496c4a73585a684f502f35702f32505863782b684e4954494652737235533971493257344e736b6b35350d0d0a2f743556334e596f727134456f44592f4952584446463838664846324a2b384f494f6d6749724874304855507853347a51424c596a65414d5745366d633942530d0d0a444c466a4d44775279327a476639654a6c5277586a4732576d74635a6f50434e32414f7149303779786b4d6a35696172714d6558487a35726478634e6d78726c0d0d0a55725162476a4c775234556e44574e4e3663596c4e4e6230496a33485a6975526f7a343241454c6744596d53776c307238394b586868335a596f7734663079730d0d0a3853643733383572666b30742b744d7279557a6632764b664f6b686b3072343644544f537544584f6b2b51416170337455546555366d593179563778432f30440d0d0a6354696a714a50382f674c693632554d35687a5a7163594a6c764662436b48376752556e6a667158644b4e325457566258633372476775737465786f4d7251440d0d0a557067395669387370454d445a5541504a306561497642525a477039585a33474f626c6c306a76654d6977556c6373414774363146352b3265755033526956520d0d0a375734386c584d3976345a786f55584265657a50393561657374726e34352b5642347679363061794446584d54342f2b427051344e444b4b443862477833614f0d0d0a716c664f75312f466f6e306b5a34636a6332586f476547754a4e473978434f594f2b4c3074756e4d2b4e376848436e6145754a79336a714b796c4a77726378340d0d0a4d4c486e49792b2b4a665770725550596f4361375148665a6b6e6f7a4b736874517938506c4b75536b616935756d2f44635157627a34446664524b50347977710d0d0a463454732b52376e7a614f2b546873396d494979665573615062774a506961557442347353644431664759582f6936563474414a67364536386f45676e66706e0d0d0a534d535348356343473231722b3150642f68737a2f587979412f594b483562766e74586f352b4c57494e2b4659744949736477436e6e477447726e7773794e6f0d0d0a6774384b794851385a50443438595078412f746a54396b6a47733864526d704e55664f6579537a744758477347677568762b7a6651494a736e773044775445390d0d0a524849432b4e347a4c52696f76424f536e5a2b63486e41444870314f616234764b37676946706c39474a6755586a6b6b5a766f4d7050744a6459552b754c2b370d0d0a724d3851695738645a76567559446570685a65593931383173642f664e4c526c2b457a377a74756d546d536b75504a646b3044557030744650785867415765550d0d0a51444e7170764c614a4938565a462b364a4e59664a4348642b4c542f57386841642f683967756e53314e7068774f552b53544c707148347462765265453438690d0d0a4d3359673538557468446f6e7157704c7043434457723774344a59744654752b38336c6e586269696a42416c73616e437a6749484d527a464c4b4675567039580d0d0a784235485a76574e483561356776366b6d7a4e746951444e50767667372b37735a4c505076717a6150426b425a7458436f6f7a6b51444d736931325164636d320d0d0a796c5333547670624a6d35386846714671683464444553374f5138786d654773646d77724146415433365648634d56754b534e4978383547486f6271364a68630d0d0a4b72754c70583133584a394c655a6d5148626c715257504167474f335676536757424b367756664878514b6e58636e6c6743686e417a49772b47614d425564370d0d0a726a513171324548746848674a746f51676d66585a46705a305750434e554756743749514a30515848667834575a49316d39656d356b3267304a773342784d380d0d0a4d7673373150503432732f62644e64427875586b6375686a6f3348766f696a565a537a7a6679783858432b4c4a654b43325a45324c4373696f534345555866370d0d0a49767542494458343741396b52444a4f652f6b6f4461463667694845324a6143416f774167664c31734d6470756d723958746630317463694c2b4f58416c47560d0d0a41542b44374d304a74776d447a7a746b614954487a35793237744369595230706d7744466c5469324432774c50375057677269306577456a4c774a4a666549530d0d0a7763437964476e7a5a5641466d416b794654584876433372656144466a49536768384c55545368324c597975474a615a66304b51474c6b65524934316379557a0d0d0a756c6e624539345734782f6e57773079506576446743503455564149703952742b666173665030466c7a4c386a31454134304978734369704451704f676164780d0d0a5139546c464b6f6c38312b344949626f437344456a2b67706c7259496c7a4731686d2b796a7671596d47712b62456d6d75794a66595542347a515a6d516b6e450d0d0a46547255564d4d576747616b6f74346c6166787142696469526e3545613561366d64464b592f34323332452b5634576665304d7572726b3151514941304f5a310d0d0a5744704f6d3939732f56366b58695a4b6b6e42675635664744375450794e665948416f5346576c44386f307279364c4458374a4c32574d34506d6b44517142390d0d0a6c6175314c31534c4271382b774e754e6630515a48554148636e716d4265324a5848556d393464726a6b7a66624f53706a466b59305872436e5839346d364f6e0d0d0a5738456a626151386d41716267346d7a3735414452744677754a2f65765859566f486559477448466b66444b392b385a6e36622f4636445236564350715638720d0d0a432f2b354d36616d4a6e5661385a4b4b394e3358644a34506a4b6f58506d5977323356546a64616d2f554b2b327631417a65735841327a6257696f363857594f0d0d0a307471646e566d632b722b5478314a683172796e377034306c412f5437326270355861386d396a5538687a75364644414263613254756a675378592f375770700d0d0a456430376f466f3730684a5a664e5a4d4455456a6f4656346b4b456635413871675051765755514744544c39416a34585a69362f6377504b2b73643178586d7a0d0d0a557771777936697964537677375077376b34743559715765744766587a7a3548704c4d59366a674a7941773664375476397633734c6c444e53343839504275720d0d0a4b4d727430457839364d68417a52424c514c6d5130593550364c69665561436e647873782b5761452b5348552f6e644c68417852576a3052764b4943654c58440d0d0a6e522f3058656f4a6e666741664d35552b556758746f79446f4e744a30597a4c55736e76516a2b6c4c61376d654d75474f4a4c417a324d524649633936316e630d0d0a68454c4d4f414e70783661565332326b5061346f4838544655635174784c37663644797079586c4e4b3758617231494d344c596f76474a2f75633572474271720d0d0a4471774e5a505268776e757a364b462b33732b41526f6d332f7172726b6834376c536a5077695a695758675373436f36337668623163562f744f6b6653597a4e0d0d0a6e446a4f557a33566a45672f6c4734637845526a37364b6c3044443053416558526e66364b477757505a4c7274797936636350773469637a56546b79556177300d0d0a3545564b5a6e7570474e6270433165686c316d3072305552767a784f6f74685a6246556f3464637566756a68364c2f366d6e48586239374c636b73506c4143640d0d0a7537684c66646a5559715558396e6e743451397136716768415a4f2f4272366e695a6e412b322b7a4736324576387a6f53724348414b69444730544e444351680d0d0a4a463846746f513561685a54716a504d4a766972376b6d4a4b6c5873725a464d546d577075794855426a78686832785a686f6e76592b73564f444a46517079560d0d0a424b66504f6a48786571536276584d43366c4c6b6f7544366f65484a4a424f594979757273552b5a32447663515a632f4e6132787765654e636f6365665532580d0d0a306f64782b3769736f554259354d4b55312b7a7a644848366e4c57634d444a39612b596d5233336c7865757a3673444b375a7a6173514e48766d6e724148692f0d0d0a4f44477168534d57707052584330594d65454b5075444a714e33724a6b474a6b4c733167375453324878427358634d386b4a4453306c6e3079464f5353594d470d0d0a306964726c2b6a47526d324e6a5944675272324573614a6d4643783057764334396948322f5a3451444f4d4c386942386a7a6350524252437743375555335a670d0d0a7838653762736666656a7968466d53787779794f5563775553654849704f4a6250415534714b7834344b516a6d365a5151707341546b496950716d37313638660d0d0a564137566a4b31634c346c694e6c696437576238745539664c55774a2b507462664c4a344c576c6e4e704f514d48797a573752492f39694371484675427a42500d0d0a3476654f382b2f4a545554376b4571635638752f754758495956506c4f4f337a49757835503237747330515a632f66786d45505a6b6d4c49377a5330707041310d0d0a4c756238464c67723566394d706d444a4d53592f42534f74715443454d39655a4d396e512f636d704b656365726f703255446875532f2f714652533079746c610d0d0a33553751614a4951356e7a5878334d5263417946505a567450563374734c506f46364b50484b59356d5137584e7779513663354e675345396d516f53437a73740d0d0a6e6f446f3632622b7131385a46474e7a74766b65566d6c652b67736e74724a2f3647365468317a6e576a314c527164776e58716e50323257487341786f505a4f0d0d0a325a347953654c762b563649544b686c38495066322f53312f487071525a61774a50694e5147325a7763656f79775053746e487854316f727759736d715659530d0d0a436c43787170434a4b373752566b344b5650775246343135464a4548386d616f5372756865527a656471354e785351696841556e2f6a397332554c2b484d59480d0d0a2f31587855424b762f513159644e6b3779306c316d6b584549316f46474c73436f576d72493070503172726c573375796b79742f78624670644b3567554c66740d0d0a4c45484d6a394470517a48316e424461546c304e386d45614f737a442b65652f664e43524e754851506b36624868365443366c62725462425539622b385034360d0d0a6866556b536e767844774b574c45667251316a5538707637444b7a4e7165685265376168474c50724a32453d	0
59274b8d-4447-4bf4-9d29-bfa099a1de37_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	10	\\x7bbf7b7fb5818e412d00	0
2203278d-ef4f-4f68-98f1-feb257d53ecc_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	291	\\x1d90c96d28300844ef91d289918c598ccb61b19bf84a65ff9092d24250388c383c31c3fcfcfffe87e3f3a3251f7b5c57a01d0b108be1f07c30a74db672c477060ec3ed12615065064c7ec0704ea89cf6626fd3534386de3327ad049c8780b331df5e20b9f7cd666fae91ab70491b899b02633d386e0ee8baae4a89488c3990364bf204476e2c5f803dba1079ca5429e59cb1f5ee2477d042e95bb9c16f0ae895ad3ab3873a3e16557b138846e73a8660a60ff6a5f52a4d56e520e72d99d1695e1b1eccdee841a63faf1dc871c71a2b859618c3c4dd554425d8ba0eeb563ff954486c845a76410e8d72436741101a58cea888679e3568789e29b60828b473ed2c88d3f257be319e621dd78c8ca25bb49ac0be13e2c683c0234d1cc79783bf3e3fbe7e01	0
0b698dcd-501d-42d9-892d-5a9157bc996a_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	16	\\x7bbf7b7fb5910e2f57b5412d2f572d00	0
c4629235-4823-4320-b8b5-1d08f4c6d612_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	184	\\x9d4f416e033108bc47ca27b65790c0c6365cfb80fec1c6f627a27d590f7d52be105b4aa21e7aea082106cda0e1fefd7323b85e6e01e809fca3bd000142dcf2e3e300f39e987ac6daa62373173489b20c42960687e9656b09e8bc5e4e08f25fa772a9a935c5de55516235545ed1ba93ce568a66eb9056b87dffeb003e17dbf3e7b12e407eedd71cf81779bf329db8a53ed1ca1c28620d35ae5481b592d1c8ca033816492e849525a3f85ca2190736b7ae39474f663beeaa07	0
a07b62f0-1f01-484a-93d9-d42764cedac0_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	151	\\x55ca3b0ac2401000d03e904b6c3d2bbbec6fb6d65e102fb0bfd8888a09362160e739bc815889a2b9c2e4245ec1da57bfef6bec05d4552f81cd4317b6fbcd6c514ecb43bb2e6dc780d195c6e94c37bad367bad09b1ef4fc1b285d303122cf19916b153c472904cf4960139d43eb334810c056a529c7b24bc528064681544e9ba4050f525bae53133936aaf0987c466b5532de0f7535fc00	0
c77bc206-5935-48ea-b32e-508a572d94f4_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
ea13a2c9-0c2f-40fa-b855-710387e3271d_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	772	\\x9554cb729b4814ddbbca5f314ba76a78084764679069605a482001a277ea4623de569544f348cd97cd229f945fc86dc976ec4cec4caa5848d4edf3eccbd77fbf7c563ec81faeaf3ec3f307dd1e77b7934f1f3fb67f2e91cc098a8e8e9d9d28d2c6e5ca7d48eda05be4539e16fb761ecf5bd6847c614e7aac66658aa6f9d3ecf5f5d5a2c95e1f515315376cc4b53e90613acc67773d96336f6d79c51645a764e5ec77483ed2667ebbb3bd0340fcde71f9401b4f4a62ad202be766e63fb802c236b24439654409f729b206a244d2bab64e64e37549ec55ef9a52820c205274cf49ac4964e376acae46b2d28b74e30ee21d8e3d4e6b7220c385d15cf707ba31386bfc3d7da40188ffc324681205ccad1cbedc4b7f997e39ddc67247555702080769198da39121ab206b29dfda81c4660f1cabc9041756811b57c623c0aef432d9041956a23645d1c06cf7c0943007083c4e3c735fba4b9b64d48eaac8ae3ab2322634ee5b361ecab97ad7bfa752403c0a7d9d8773f10aaa7cc582067a4e64b722b9764f3664c96c2f841c242737848a6473cee2ccb628ad761706665847b5934f9f22e4497da8123508771ba3ba180f75a7f480da3a020455d2e565c46f0314296bd51823148da9f9d8024407be3903ffa95d3e5f2b320bba39a80488df8c8f272afcaee19d291754d16a0111b3fc595c25fc3afb54440a0c17a6c34c4051a437c2202e832a2df58ec941c554ff6523e019a2d43b8854daad8c36896591d13d89fb2a4515a7a59cb1fa08eb15680c011decd6a276f9398bbe4ae249fe0ba81955820a1a9044a4f07f02858f2998131035fbd57128d22ba0eceeace685d19d3dbf0508a606c336d69ae7127f68e0e97e8436e484a21a662b722fee92b51014e282ff449c50e6a09ea74a34f8b52ed3dad79de2eea76a01e2bb60ecd79e399592e9ebc8e0fb00265ad8d6a71583653006aa1a156b02ed79cd60fc6496129ef9dc332712e67eeba1e55b0a5faa1159fc273eec3727644ac9dffe2945869460ff78326fde827bb9a9a6fe6a17cea2d71d171f81ad6235640d7345c769ac9724ee6efeb9be12cf37	0
fd1b2a86-b7df-4f32-84e2-befd4f3a2331_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	18	\\x7bbf7b7fb5a10e2f57b5412d84e4e5aa0500	0
cf8b5e0f-5e46-4cf4-bc6f-204eae2c4e8a_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
1a621f0f-5568-4183-bd9f-f6ef670e7090_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	408	\\x8d923d4e5c3110c77b24ee805eed913cfe764f9f860b8c3d761b942569a29580a0a44c1b51200a0e8012452281902bf89d2457889fd85d2d1f426f0a8fe4f96bfebf19fbdfeddf8f46eceef4235743a95002ed93024436108dac206590263021d62862668b3217a054f35aa44d1719196d4155b35f7772af765a89fc6ba2e544e68466439ab8428d12c1201648beb7b72629ab63258545c855c00bc73a8414433b6ff7edcf78d66eda8ff1d378dcaec7cfed66fc3a4c5e28e4524c32671cd61235689b084c9619a824049575f55c8bccb9cce3c26e79d98d4ec693f6bb9bfe5a19e1948677ef8767f5e5eece0344404f36a500cc2180d11421601f89b30c35791f5ce479104a0cfbe5c39bc3c541591c3d07e8b5bdb7878bbda3a9bab247e14b50647d85985de99d1543c818c039ab13e7c081d34cc63ee3b776b759f2f6ec0ff79b997dd221d8fea372a40c8658021923c105eb2a71466b69bee955bb6e777da9b75b2fbc6dfeb8be81d02a276fab0562d2609855df415fb12d9c8a226531b9f91017e3e9f8a5fdec2f7cdabeb7fb17309e2ad62053fe0f	0
c40aafd6-c889-4229-807a-851d0bc5bc97_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	18	\\x7bbf7b7fb5a10e2f57b5412d84e4e5aa0500	0
facbfffe-feb2-4d30-8930-a557b185e5c4_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	18	\\x7bbf7b7fb5810e2f57b5412df1242f572d00	0
e05c0074-0404-4b7a-835e-9cacd405960e_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
42ed49cc-765d-4314-bc2d-af425af7bf13_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	59	\\x7bbf7b7fb5810e2f57b5412d8234d4b130344f344d4ab2d04d49b1b0d035314eb4d4b5303430d04d4936b0484b3237b730b34cd131a8e5e5aa0500	0
215d232c-9c9e-4f7c-8a87-142cd3797264_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	16	\\x7bbf7b7fb5810e2f57b5412d2f572d00	0
fe8acd6a-22c9-4b5a-aeae-232a1c8324cb_dynupdate_e9f2ffd7-a675-4063-b015-b699a66bbe75.si	2026-09-15 15:07:02	2026-09-15 15:07:02	0	687	\\xa55431ae1d370cec0df8123fed2340519448de22579028aa4c11b833fec952e448b982e7b9f3265d1e160f2bac469c2167f4cf5f7f7fe7d7d72fdf65be6ab6bab69d6eaf467a7593af349a362b788846d87bebc7efebdbb7faf38f8f9f8bdf3e5ead9b8e54a6d57492e6051067d0ce383e67cf11f1f9f5cbe7ab24b717bef4768cb43636e6112cdd3286cf93f59f15de04b84b52e3e8a8b08296ad4323cd2a93bd527e56c854cf758b4abb93b63569f94dda5a63ede4db5bffa5c2e7abfbbe876d50af89b3d75ab4021c4387b4ee7c86c503724d76ca5bc2a8820e7172bdf8b302c2e6f2b11f90e0d9e3a00aa73129845284163573e5d3faeaf524a6a6d9f79dc4be0720276909448747d6b9ad0d7f423c9bde114e39e342be1c0c41847c9f399a858bea03c2b6668835dac24ae062d022456b64a1979cb1f3a9050c445da8ce00b10b76cbae91b0e327bc6cf893d8e5ce4d0f35e14d6a8cb9f0713ad1b41c27ccfbd42290b2147be65e2066eae00463cede650f7733e707a4b51ad7e7a036180ee69c18fc5162118eb124e61a0fc8946815bb939f0b2d8a027b6e01b15bccce6de6b3ca15f89865d29b01a91c26c7564c6880e912ed524f62b5e22e4b6236c83fd2c8ab31b5ece0ec6cdcef03b272f23c93419e03a31c01882659287c1c2dab3f9b6c6d8ff47b68f2410e77bfb4307818ad90041d87c77394262347376c947a37b92939a20c694babcfbba39e4ee635e4c629b25e0b096018061a684e69b66b1debeb01d96cb97935e84572b540113e516aca6569b7e6bf9c2cce775c464ad251251219bef3bc7b1733b3c1b5fdff5d46237a1e050b8695de9644b2da0ddac10b41e111fb9915dc5002024947d63b5e13667947007e80272e5c51f3d9e0d38ed74483114d742b1aa177e3bdecc7e0cbbb9eb74b365c613293f082dbe52c68b9288536354c36d669ed5708e4e0f901	0
siVersions	2026-09-15 15:05:23	2026-09-15 15:07:02	0	1273	\\xefbbbf7b302c31362c2261303762363266302d316630312d343834612d393364392d6434323736346365646163302e7369222c62316338653437622d613165382d343961642d613064362d3534336561623039326330322c2266653861636436612d323263392d346235612d616561652d3233326131633833323463622e7369222c65383330363932612d386633332d343331372d386661372d3538366465336232616132642c2235393237346238642d343434372d346266342d396432392d6266613039396131646533372e7369222c32303539333338382d333834352d343237372d623366392d6465666364653533326463642c2265613133613263392d306332662d343066612d623835352d3731303338376533323731642e7369222c66383331373139342d303532312d346530322d396262322d6130663037646435363539652c2234326564343963632d373635642d343331342d626332642d6166343235616637626631332e7369222c34333230343439632d323836362d346262322d613938382d3332306636313631336261632c2232313564323332632d396339652d346637632d386138372d3134326364333739373236342e7369222c65383963356363302d393963642d343934302d626332392d3637663463356132386638372c2263343061616664362d633838392d343232392d383037612d3835316430626335626339372e7369222c61376662383433632d303033662d343965382d396565632d3733363631323464666238322c2232323033323738642d656634662d346636382d393866312d6665623235376435336563632e7369222c33373330306433392d643134362d346639622d613631662d6236333464396665326235632c2263343632393233352d343832332d343332302d623862352d3164303866346336643631322e7369222c62333863346338662d653234622d343133382d393662382d6465336262393630396162332c2230623639386463642d353031642d343264392d383932642d3561393135376263393936612e7369222c37323233373162622d666433382d346534612d623264302d6235383135323235303264612c2263373762633230362d353933352d343865612d623332652d3530386135373264393466342e7369222c35633734636335612d313636362d346331352d393232302d6466353366653035343338392c2266643162326138362d623764662d346633322d383465322d6265666434663361323333312e7369222c36393030373435612d396131392d346363642d393932612d3161616237396165613962622c2263663862356530662d356534362d346366342d626336662d3230346561653263346538612e7369222c32306363613938332d373530332d346264632d616335312d3334303131663665306262372c2231613632316630662d353536382d343138332d626439662d6636656636373065373039302e7369222c64303033376533342d616361392d343830312d383164632d6164363764383035316362382c2266616362666666652d666562322d346433302d383933302d6135353762313835653563342e7369222c37383562636639362d643032382d346131362d616235612d6366343531356434613130622c2265303563303037342d303430342d346237612d383335652d3963616364343035393630652e7369222c38333438333961332d396263392d346264312d623935312d3862653165353535666134617d	0
DynamicallyUpdated	2026-09-15 15:07:02	2026-09-15 15:07:02	0	82	\\xefbbbf7b302c322c64666132373930632d623836342d343063652d623761392d6366656436656432303763612c65396632666664372d613637352d343036332d623031352d6236393961363662626537357d	0
\.


--
-- Data for Name: schemastorage; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.schemastorage (schemaid, status, currentschema, newgencreated, newgendropped) FROM stdin;
0	100	\\xefbbbf7b302c0d0a7b35302c0d0a7b2244625365676d656e7473222c224e222c312c22222c0d0a7b332c0d0a7b225365676d656e744964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225365676d656e744e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250617468222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b225365676d656e744e616d65222c312c0d0a7b312c225365676d656e744e616d65227d2c312c312c302c0d0a7b307d2c302c307d2c0d0a7b225365676d656e744964222c312c0d0a7b312c225365676d656e744964227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244625365676d656e74734974656d73222c224e222c322c22222c0d0a7b342c0d0a7b224974656d4964222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225365676d656e744964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466f72496e646578222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224170706c696564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b224974656d49645365676d656e744e616d65222c312c0d0a7b332c224974656d4964222c22466f72496e646578222c224170706c696564227d2c312c302c302c0d0a7b307d2c302c307d2c0d0a7b225365676d656e7449645365676d656e744e616d65222c302c0d0a7b322c225365676d656e744964222c22466f72496e646578227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22576562536f636b6574436c69656e7473222c224e222c332c22222c0d0a7b382c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225753434b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d657461646174614944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657276657255524c222c302c0d0a7b312c0d0a7b2253222c323134373438333930332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22507265646566696e6564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e6e656374696f6e506172616d6574657273222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224942557365724e616d65222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224175746f436f6e6e656374222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e735265737472756374222c224e222c342c22222c0d0a7b342c0d0a7b22457874446174614944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461496e74222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2252657374727563744461746154797065222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b22457874656e73696f6e735265737472756374536570617261746564496e646578222c302c0d0a7b312c22457874446174614944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b22457874656e73696f6e7352657374727563744d61696e496e646578222c302c0d0a7b322c22457874446174614944222c2252657374727563744461746154797065227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e7352657374727563744e4753222c224e222c352c22222c0d0a7b342c0d0a7b22457874446174614944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22526573747275637444617461496e74222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2252657374727563744461746154797065222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b22457874656e73696f6e7352657374727563744e4753536570617261746564496e646578222c302c0d0a7b312c22457874446174614944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b22457874656e73696f6e7352657374727563744e47534d61696e496e646578222c302c0d0a7b322c22457874446174614944222c2252657374727563744461746154797065227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e73496e666f222c224e222c362c22222c0d0a7b31302c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c22457874656e73696f6e73496e666f222c327d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e4f72646572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e557365507572706f7365222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e53636f7065222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e5a6970706564496e666f222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d61737465724e6f6465222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736564496e4469737472696275746564496e666f42617365222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2256222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22457874656e73696f6e73496e666f4e4753222c224e222c372c22222c0d0a7b31302c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c22457874656e73696f6e73496e666f4e4753222c327d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e4f72646572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e557365507572706f7365222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e53636f7065222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22457874656e73696f6e5a6970706564496e666f222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d61737465724e6f6465222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736564496e4469737472696275746564496e666f42617365222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2256222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2253797374656d53657474696e6773222c224e222c382c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22436f6d6d6f6e53657474696e6773222c224e222c392c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2252657053657474696e6773222c224e222c31302c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2252657056617253657474696e6773222c224e222c31312c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2246726d447453657474696e6773222c224e222c31322c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244796e4c69737453657474696e6773222c224e222c31332c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224572726f7250726f63657373696e6753657474696e6773222c224e222c31342c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2255524c45787465726e616c44617461222c224e222c31352c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22496e7465726e616c53657474696e6773222c224e222c31362c22222c0d0a7b392c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677350726573656e746174696f6e222c312c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255736572496448617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e67734b657948617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b342c2255736572496448617368222c224f626a6563744b6579222c2253657474696e67734b657948617368222c2256657273696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244656661756c7453797374656d53657474696e6773222c224e222c31372c22222c0d0a7b342c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b312c224f626a6563744b6579227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244656661756c74496e7465726e616c53657474696e6773222c224e222c31382c22222c0d0a7b342c0d0a7b224f626a6563744b6579222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253657474696e677344617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676544617465222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b312c224f626a6563744b6579227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573496e666f42617365557365222c224e222c31392c22222c0d0a7b322c0d0a7b224964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f706965735570646174655461626c6553746174222c224e222c32302c22222c0d0a7b352c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225472616e7366657254696d65222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224973506f7274696f6e222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657355706461746553746174222c224e222c32312c22222c0d0a7b332c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255706461746554696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225472616e506572536563222c302c0d0a7b312c0d0a7b224e222c31362c342c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573222c224e222c32322c22222c0d0a7b31322c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f70794e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365496e74416363656c657261746f72222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225265706c54797065222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b22446254797065222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b224462536572766572222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244624e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446255736572222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446250617373776f7264222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224372656174654462222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253746f7261676556617269616e74222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f70794964436f70794e616d65222c312c0d0a7b322c22436f70794964222c22436f70794e616d65227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657353657474696e6773222c224e222c32332c22222c0d0a7b342c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f7079436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f7079536368656d61222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f70794964222c302c0d0a7b312c22436f70794964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657354724c6f6773222c224e222c32342c22222c0d0a7b342c0d0a7b2254724e756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c327d0d0a7d2c22222c307d2c0d0a7b22547254696d65222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724c6f67222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b2254724e756d222c312c0d0a7b312c2254724e756d227d2c312c312c302c0d0a7b307d2c302c307d2c0d0a7b2254724964222c312c0d0a7b312c2254724964227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657354725461626c6573222c224e222c32352c22222c0d0a7b332c0d0a7b2254724e756d222c312c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b22547254696d65222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b2254724e756d5461626c654e616d65222c312c0d0a7b332c225461626c654e616d65222c2254724e756d222c22547254696d65227d2c312c312c302c0d0a7b307d2c302c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c2254724e756d227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657355706461746573222c224e222c32362c22222c0d0a7b362c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724e756d222c312c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b22547254696d65222c312c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225570646174654964222c312c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c617374557064617465526573756c74222c312c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c6173745570646174654572726f72222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f7079496454724e756d222c312c0d0a7b322c22436f70794964222c2254724e756d227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f706965735461626c6573537461746573222c224e222c32372c22222c0d0a7b342c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c655374617465222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b2254724e756d222c312c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f707949645461626c654e616d65222c312c0d0a7b322c22436f70794964222c225461626c654e616d65227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573496e697469616c4c617374222c224e222c32382c22222c0d0a7b362c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22426c6f636b4e756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c327d0d0a7d2c22222c307d2c0d0a7b2246697273744b6579222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c6173744b6579222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22426c6f636b5374617465222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f707949645461626c654e616d65426c6f636b4e756d222c312c0d0a7b332c22436f70794964222c225461626c654e616d65222c22426c6f636b4e756d227d2c312c312c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f7069657354724368616e676573222c224e222c32392c22222c0d0a7b342c0d0a7b22436f70794964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225461626c654e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254724e756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c302c317d0d0a7d2c22222c307d2c0d0a7b2243684964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22436f707949645461626c654e616d65222c302c0d0a7b332c22436f70794964222c225461626c654e616d65222c2254724e756d227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224462436f70696573547243684f626a222c224e222c33302c22222c0d0a7b322c0d0a7b2243684964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2243684f626a222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2243684964222c312c0d0a7b312c2243684964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224d6f62696c65436c69656e744461746145786368616e6765222c224e222c33312c22222c0d0a7b352c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2254797065222c302c0d0a7b312c0d0a7b224e222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617461222c312c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617465222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224944222c302c0d0a7b312c224944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22426f7473222c224e222c33322c22222c0d0a7b382c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436c69656e744944222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22454353557365724944222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d44426f744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224942557365724e616d65222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22506172616d222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22507265646566696e6564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224e65656473557064617465222c312c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2253545453657474696e6773222c224e222c33332c22222c0d0a7b322c0d0a7b22546f6b656e222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22486f7374222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544772616d6d6172222c224e222c33342c22222c0d0a7b322c0d0a7b224772616d6d6172222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22506872617365222c312c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c302c0d0a7b312c224772616d6d6172227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544772616d6d6172436865636b73756d222c224e222c33352c22222c0d0a7b322c0d0a7b224772616d6d6172222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436865636b73756d222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794b6579222c312c0d0a7b312c224772616d6d6172227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544d6f64656c73222c224e222c33362c22222c0d0a7b31302c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c225354544d6f64656c73222c327d0d0a7d2c22222c307d2c0d0a7b224d6f64656c4944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d6f64656c436f6d7061746962696c697479222c302c0d0a7b312c0d0a7b224e222c352c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2241636f7573746963222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2241636f75737469635255222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c616e67756167654d6f64656c222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c616e67756167654d6f64656c5255222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333734382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c323134373438333635302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2253616d706c6552617465222c302c0d0a7b312c0d0a7b224e222c352c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b2242794d6f64656c4964222c312c0d0a7b312c224d6f64656c4944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225354544d6f64656c7344657363222c224e222c33372c22222c0d0a7b322c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c225354544d6f64656c7344657363222c327d0d0a7d2c22222c307d2c0d0a7b224d6f64656c222c302c0d0a7b312c0d0a7b2252222c302c302c225354544d6f64656c73222c337d0d0a7d2c22222c307d0d0a7d2c0d0a7b332c0d0a7b224465736372222c2249222c302c225354544d6f64656c7344657363222c0d0a7b322c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2241636f7573746963222c2249222c302c225354544d6f64656c7344657363222c0d0a7b322c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224c616e674d6f64656c222c2249222c302c225354544d6f64656c7344657363222c0d0a7b322c0d0a7b224c616e6775616765222c302c0d0a7b312c0d0a7b2253222c322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d0d0a7d2c0d0a7b312c0d0a7b2242794d6f64656c222c312c0d0a7b312c224d6f64656c227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f7279517565756530222c224e222c34312c22222c0d0a7b342c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446174614964222c302c0d0a7b312c0d0a7b2242222c32302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22506f736974696f6e222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d657461646174614964446174614964506f736974696f6e222c312c0d0a7b332c224d657461646174614964222c22446174614964222c22506f736974696f6e227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f727956657273696f6e73222c224e222c34322c22222c0d0a7b31322c0d0a7b22486973746f7279446174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d6574616461746156657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617465222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224368616e676554797065222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365724964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365724e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225573657246756c6c4e616d65222c302c0d0a7b312c0d0a7b2253222c323134373438333930342c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6d6d656e74222c302c0d0a7b312c0d0a7b2253222c323134373438343637322c302c22222c307d0d0a7d2c22222c307d2c0d0a7b225472616e73616374696f6e222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224e6f6465222c302c0d0a7b322c0d0a7b2245222c302c302c22222c307d2c0d0a7b2252222c302c302c22222c347d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22486973746f727944617461496456657273696f6e4e756d626572222c312c0d0a7b322c22486973746f7279446174614964222c2256657273696f6e4e756d626572227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f72794c617465737456657273696f6e73222c224e222c34332c22222c0d0a7b352c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22446174614964222c302c0d0a7b312c0d0a7b2242222c32302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22486973746f7279446174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22536570617261746f72734d657461646174614964446174614964222c302c0d0a7b322c224d657461646174614964222c22446174614964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f72794d65746164617461222c224e222c34342c22222c0d0a7b372c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22497353657474696e6773222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22497341637475616c222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d6574616461746156657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224973457874656e73696f6e73222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22416374696f6e4f6e416363657074222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b322c0d0a7b22536570617261746f72734964497353657449734163744e756d626572222c312c0d0a7b352c224d657461646174614964222c22497353657474696e6773222c22497341637475616c222c224d6574616461746156657273696f6e4e756d626572222c224973457874656e73696f6e73227d2c312c302c302c0d0a7b307d2c302c307d2c0d0a7b224d6574616461746149644d6574616461746156657273696f6e222c312c0d0a7b322c224d657461646174614964222c224d6574616461746156657273696f6e4e756d626572227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f727953657474696e6773222c224e222c34352c22222c0d0a7b322c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6e74656e74222c302c0d0a7b312c0d0a7b2242222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22536570617261746f72734d657461646174614964222c312c0d0a7b312c224d657461646174614964227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b2244617461486973746f7279416674657257726974655175657565222c224e222c34362c22222c0d0a7b332c0d0a7b224d657461646174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22486973746f7279446174614964222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e4e756d626572222c302c0d0a7b312c0d0a7b224e222c392c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b22536570617261746f72734d657461646174614964486973746f727944617461496456657273696f6e4e756d626572222c312c0d0a7b332c224d657461646174614964222c22486973746f7279446174614964222c2256657273696f6e4e756d626572227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225265664f7074222c224e222c34372c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22436872634f7074222c224e222c34382c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224163634f7074222c224e222c34392c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b22434b696e64734f7074222c224e222c35302c22222c0d0a7b332c0d0a7b224d444944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224578744944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2250445570644d6f6465222c302c0d0a7b312c0d0a7b224e222c312c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b312c0d0a7b224d444944222c302c0d0a7b322c224d444944222c224578744944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225573657273576f726b486973746f7279222c224e222c35312c22222c0d0a7b362c0d0a7b224944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22557365724944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255524c222c302c0d0a7b312c0d0a7b2253222c323134373438333634382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2244617465222c302c0d0a7b312c0d0a7b2254222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b2255524c48617368222c302c0d0a7b312c0d0a7b224e222c31302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224543534163746976697479222c312c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b332c0d0a7b2242794944222c312c0d0a7b312c224944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b2242795573657244617465222c302c0d0a7b322c22557365724944222c2244617465227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b2242795573657255524c48617368222c302c0d0a7b332c22557365724944222c2255524c48617368222c2244617465227d2c312c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b224f4461746153657474696e6773222c224e222c35322c22222c0d0a7b312c0d0a7b224d657461646174614f626a65637455554944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b307d2c312c2253222c0d0a7b307d2c0d0a7b307d2c22222c302c307d2c0d0a7b225265666572656e63653533222c224e222c35332c22222c0d0a7b392c0d0a7b224944222c302c0d0a7b312c0d0a7b2252222c302c302c225265666572656e63653533222c327d0d0a7d2c22222c307d2c0d0a7b2256657273696f6e222c302c0d0a7b312c0d0a7b2256222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224d61726b6564222c302c0d0a7b312c0d0a7b224c222c302c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22507265646566696e65644944222c302c0d0a7b312c0d0a7b2242222c31362c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22436f6465222c302c0d0a7b312c0d0a7b2253222c323134373438333635372c302c22222c307d0d0a7d2c22222c307d2c0d0a7b224465736372697074696f6e222c302c0d0a7b312c0d0a7b2253222c323134373438333637332c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466c643534222c302c0d0a7b312c0d0a7b2253222c323134373438333635382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466c643535222c302c0d0a7b312c0d0a7b2253222c323134373438333635382c302c22222c307d0d0a7d2c22222c307d2c0d0a7b22466c643536222c302c0d0a7b312c0d0a7b2253222c323134373438333635382c302c22222c307d0d0a7d2c22222c307d0d0a7d2c0d0a7b307d2c0d0a7b332c0d0a7b224279507265646566696e656449444e6f74556e6971222c302c0d0a7b312c22507265646566696e65644944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b22436f6465222c312c0d0a7b322c22436f6465222c224944227d2c302c302c302c0d0a7b307d2c302c307d2c0d0a7b224465736372222c312c0d0a7b322c224465736372697074696f6e222c224944227d2c302c302c302c0d0a7b307d2c302c307d0d0a7d2c312c2252222c0d0a7b307d2c0d0a7b307d2c22222c302c307d0d0a7d0d0a7d	\\xefbbbf7b302c0d0a7b307d0d0a7d	\\xefbbbf7b302c0d0a7b307d0d0a7d
\.


--
-- Data for Name: v8cmsdpwds; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.v8cmsdpwds (pwdhash) FROM stdin;
\.


--
-- Data for Name: v8userpwdplcs; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.v8userpwdplcs (name, data) FROM stdin;
\.


--
-- Data for Name: v8users; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.v8users (id, name, descr, osname, changed, rolesid, show, data, eauth, admrole, ussprh, email) FROM stdin;
\.


--
-- Data for Name: v8usersmatkeys; Type: TABLE DATA; Schema: public; Owner: one_c_db_user
--

COPY public.v8usersmatkeys (id, providersh, matkeysh, data) FROM stdin;
\.


--
-- Name: _dbcopiesinitiallast__blocknum_seq; Type: SEQUENCE SET; Schema: public; Owner: one_c_db_user
--

SELECT pg_catalog.setval('public._dbcopiesinitiallast__blocknum_seq', 1, false);


--
-- Name: _dbcopiestrlogs__trnum_seq; Type: SEQUENCE SET; Schema: public; Owner: one_c_db_user
--

SELECT pg_catalog.setval('public._dbcopiestrlogs__trnum_seq', 1, false);


--
-- Name: _extensionsinfo _extensionsinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public._extensionsinfo
    ADD CONSTRAINT _extensionsinfo_pkey PRIMARY KEY (_idrref);


--
-- Name: _extensionsinfongs _extensionsinfongs_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public._extensionsinfongs
    ADD CONSTRAINT _extensionsinfongs_pkey PRIMARY KEY (_idrref);


--
-- Name: _reference53 _reference53ng_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public._reference53
    ADD CONSTRAINT _reference53ng_pkey PRIMARY KEY (_idrref);


--
-- Name: _sttmodels _sttmodels_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public._sttmodels
    ADD CONSTRAINT _sttmodels_pkey PRIMARY KEY (_idrref);


--
-- Name: _sttmodelsdesc _sttmodelsdesc_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public._sttmodelsdesc
    ADD CONSTRAINT _sttmodelsdesc_pkey PRIMARY KEY (_idrref);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (filename, partno);


--
-- Name: configcas configcas_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.configcas
    ADD CONSTRAINT configcas_pkey PRIMARY KEY (filename, partno);


--
-- Name: configcassave configcassave_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.configcassave
    ADD CONSTRAINT configcassave_pkey PRIMARY KEY (filename, partno);


--
-- Name: configsave configsave_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.configsave
    ADD CONSTRAINT configsave_pkey PRIMARY KEY (filename, partno);


--
-- Name: depotfiles depotfiles_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.depotfiles
    ADD CONSTRAINT depotfiles_pkey PRIMARY KEY (filename, partno);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (filename, partno);


--
-- Name: params params_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.params
    ADD CONSTRAINT params_pkey PRIMARY KEY (filename, partno);


--
-- Name: schemastorage schemastorage_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.schemastorage
    ADD CONSTRAINT schemastorage_pkey PRIMARY KEY (schemaid);


--
-- Name: v8cmsdpwds v8cmsdpwds_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.v8cmsdpwds
    ADD CONSTRAINT v8cmsdpwds_pkey PRIMARY KEY (pwdhash);


--
-- Name: v8users v8users_pkey; Type: CONSTRAINT; Schema: public; Owner: one_c_db_user
--

ALTER TABLE ONLY public.v8users
    ADD CONSTRAINT v8users_pkey PRIMARY KEY (id);


--
-- Name: _accopt_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _accopt_1 ON public._accopt USING btree (_mdid, _extid);


--
-- Name: _chrcopt_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _chrcopt_1 ON public._chrcopt USING btree (_mdid, _extid);


--
-- Name: _ckindsopt_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _ckindsopt_1 ON public._ckindsopt USING btree (_mdid, _extid);


--
-- Name: _commonsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _commonsettings_1 ON public._commonsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._commonsettings CLUSTER ON _commonsettings_1;


--
-- Name: _datahistoryafterwritequeue_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _datahistoryafterwritequeue_1 ON public._datahistoryafterwritequeue USING btree (_metadataid, _historydataid, _versionnumber);

ALTER TABLE public._datahistoryafterwritequeue CLUSTER ON _datahistoryafterwritequeue_1;


--
-- Name: _datahistorylatestversions_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _datahistorylatestversions_1 ON public._datahistorylatestversions USING btree (_metadataid, _dataid);

ALTER TABLE public._datahistorylatestversions CLUSTER ON _datahistorylatestversions_1;


--
-- Name: _datahistorymetadata_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _datahistorymetadata_1 ON public._datahistorymetadata USING btree (_metadataid, _issettings, _isactual, _metadataversionnumber, _isextensions);

ALTER TABLE public._datahistorymetadata CLUSTER ON _datahistorymetadata_1;


--
-- Name: _datahistorymetadata_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _datahistorymetadata_2 ON public._datahistorymetadata USING btree (_metadataid, _metadataversionnumber);


--
-- Name: _datahistoryqueue0_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _datahistoryqueue0_1 ON public._datahistoryqueue0 USING btree (_metadataid, _dataid, _position);

ALTER TABLE public._datahistoryqueue0 CLUSTER ON _datahistoryqueue0_1;


--
-- Name: _datahistorysettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _datahistorysettings_1 ON public._datahistorysettings USING btree (_metadataid);

ALTER TABLE public._datahistorysettings CLUSTER ON _datahistorysettings_1;


--
-- Name: _datahistoryversions_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _datahistoryversions_1 ON public._datahistoryversions USING btree (_historydataid, _versionnumber);

ALTER TABLE public._datahistoryversions CLUSTER ON _datahistoryversions_1;


--
-- Name: _dbcopies_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopies_1 ON public._dbcopies USING btree (_copyid, _copyname);

ALTER TABLE public._dbcopies CLUSTER ON _dbcopies_1;


--
-- Name: _dbcopiesinitiallast_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopiesinitiallast_1 ON public._dbcopiesinitiallast USING btree (_copyid, _tablename, _blocknum);

ALTER TABLE public._dbcopiesinitiallast CLUSTER ON _dbcopiesinitiallast_1;


--
-- Name: _dbcopiessettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _dbcopiessettings_1 ON public._dbcopiessettings USING btree (_copyid);

ALTER TABLE public._dbcopiessettings CLUSTER ON _dbcopiessettings_1;


--
-- Name: _dbcopiestablesstates_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopiestablesstates_1 ON public._dbcopiestablesstates USING btree (_copyid, _tablename);

ALTER TABLE public._dbcopiestablesstates CLUSTER ON _dbcopiestablesstates_1;


--
-- Name: _dbcopiestrchanges_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _dbcopiestrchanges_1 ON public._dbcopiestrchanges USING btree (_copyid, _tablename, _trnum);

ALTER TABLE public._dbcopiestrchanges CLUSTER ON _dbcopiestrchanges_1;


--
-- Name: _dbcopiestrchobj_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopiestrchobj_1 ON public._dbcopiestrchobj USING btree (_chid);

ALTER TABLE public._dbcopiestrchobj CLUSTER ON _dbcopiestrchobj_1;


--
-- Name: _dbcopiestrlogs_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopiestrlogs_1 ON public._dbcopiestrlogs USING btree (_trnum);

ALTER TABLE public._dbcopiestrlogs CLUSTER ON _dbcopiestrlogs_1;


--
-- Name: _dbcopiestrlogs_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopiestrlogs_2 ON public._dbcopiestrlogs USING btree (_trid);


--
-- Name: _dbcopiestrtables_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopiestrtables_1 ON public._dbcopiestrtables USING btree (_tablename, _trnum, _trtime);

ALTER TABLE public._dbcopiestrtables CLUSTER ON _dbcopiestrtables_1;


--
-- Name: _dbcopiestrtables_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _dbcopiestrtables_2 ON public._dbcopiestrtables USING btree (_trnum);


--
-- Name: _dbcopiesupdates_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbcopiesupdates_1 ON public._dbcopiesupdates USING btree (_copyid, _trnum);

ALTER TABLE public._dbcopiesupdates CLUSTER ON _dbcopiesupdates_1;


--
-- Name: _dbsegments_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbsegments_1 ON public._dbsegments USING btree (_segmentname);

ALTER TABLE public._dbsegments CLUSTER ON _dbsegments_1;


--
-- Name: _dbsegments_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbsegments_2 ON public._dbsegments USING btree (_segmentid);


--
-- Name: _dbsegmentsitems_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _dbsegmentsitems_1 ON public._dbsegmentsitems USING btree (_itemid, _forindex, _applied);

ALTER TABLE public._dbsegmentsitems CLUSTER ON _dbsegmentsitems_1;


--
-- Name: _dbsegmentsitems_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _dbsegmentsitems_2 ON public._dbsegmentsitems USING btree (_segmentid, _forindex);


--
-- Name: _defaultinternalsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _defaultinternalsettings_1 ON public._defaultinternalsettings USING btree (_objectkey);

ALTER TABLE public._defaultinternalsettings CLUSTER ON _defaultinternalsettings_1;


--
-- Name: _defaultsystemsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _defaultsystemsettings_1 ON public._defaultsystemsettings USING btree (_objectkey);

ALTER TABLE public._defaultsystemsettings CLUSTER ON _defaultsystemsettings_1;


--
-- Name: _dynlistsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _dynlistsettings_1 ON public._dynlistsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._dynlistsettings CLUSTER ON _dynlistsettings_1;


--
-- Name: _errorprocessingsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _errorprocessingsettings_1 ON public._errorprocessingsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._errorprocessingsettings CLUSTER ON _errorprocessingsettings_1;


--
-- Name: _extensionsrestruct_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _extensionsrestruct_1 ON public._extensionsrestruct USING btree (_extdataid);


--
-- Name: _extensionsrestruct_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _extensionsrestruct_2 ON public._extensionsrestruct USING btree (_extdataid, _restructdatatype);


--
-- Name: _extensionsrestructngs_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _extensionsrestructngs_1 ON public._extensionsrestructngs USING btree (_extdataid);


--
-- Name: _extensionsrestructngs_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _extensionsrestructngs_2 ON public._extensionsrestructngs USING btree (_extdataid, _restructdatatype);


--
-- Name: _frmdtsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _frmdtsettings_1 ON public._frmdtsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._frmdtsettings CLUSTER ON _frmdtsettings_1;


--
-- Name: _internalsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _internalsettings_1 ON public._internalsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._internalsettings CLUSTER ON _internalsettings_1;


--
-- Name: _mobileclientdataexchange_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _mobileclientdataexchange_1 ON public._mobileclientdataexchange USING btree (_id);


--
-- Name: _reference53_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _reference53_1 ON public._reference53 USING btree (_predefinedid);


--
-- Name: _reference53_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _reference53_2 ON public._reference53 USING btree (_code, _idrref);


--
-- Name: _reference53_3; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _reference53_3 ON public._reference53 USING btree (_description, _idrref);


--
-- Name: _refopt_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _refopt_1 ON public._refopt USING btree (_mdid, _extid);


--
-- Name: _repsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _repsettings_1 ON public._repsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._repsettings CLUSTER ON _repsettings_1;


--
-- Name: _repvarsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _repvarsettings_1 ON public._repvarsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._repvarsettings CLUSTER ON _repvarsettings_1;


--
-- Name: _sttgrammar_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _sttgrammar_1 ON public._sttgrammar USING btree (_grammar);


--
-- Name: _sttgrammarchecksum_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _sttgrammarchecksum_1 ON public._sttgrammarchecksum USING btree (_grammar);


--
-- Name: _sttmodels_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _sttmodels_1 ON public._sttmodels USING btree (_modelid);


--
-- Name: _sttmodelsdesc_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _sttmodelsdesc_1 ON public._sttmodelsdesc USING btree (_modelrref);


--
-- Name: _sttmodelsdesc_acoustic_sk; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _sttmodelsdesc_acoustic_sk ON public._sttmodelsdesc_acoustic USING btree (_sttmodelsdesc_idrref, _keyfield);

ALTER TABLE public._sttmodelsdesc_acoustic CLUSTER ON _sttmodelsdesc_acoustic_sk;


--
-- Name: _sttmodelsdesc_descr_sk; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _sttmodelsdesc_descr_sk ON public._sttmodelsdesc_descr USING btree (_sttmodelsdesc_idrref, _keyfield);

ALTER TABLE public._sttmodelsdesc_descr CLUSTER ON _sttmodelsdesc_descr_sk;


--
-- Name: _sttmodelsdesc_langmodel_sk; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _sttmodelsdesc_langmodel_sk ON public._sttmodelsdesc_langmodel USING btree (_sttmodelsdesc_idrref, _keyfield);

ALTER TABLE public._sttmodelsdesc_langmodel CLUSTER ON _sttmodelsdesc_langmodel_sk;


--
-- Name: _systemsettings_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _systemsettings_1 ON public._systemsettings USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._systemsettings CLUSTER ON _systemsettings_1;


--
-- Name: _urlexternaldata_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _urlexternaldata_1 ON public._urlexternaldata USING btree (_useridhash, _objectkey, _settingskeyhash, _version);

ALTER TABLE public._urlexternaldata CLUSTER ON _urlexternaldata_1;


--
-- Name: _usersworkhistory_1; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX _usersworkhistory_1 ON public._usersworkhistory USING btree (_id);


--
-- Name: _usersworkhistory_2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _usersworkhistory_2 ON public._usersworkhistory USING btree (_userid, _date);


--
-- Name: _usersworkhistory_3; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX _usersworkhistory_3 ON public._usersworkhistory USING btree (_userid, _urlhash, _date);

ALTER TABLE public._usersworkhistory CLUSTER ON _usersworkhistory_3;


--
-- Name: binarydataind; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX binarydataind ON public.binarydata USING btree (f_key, f_off);


--
-- Name: binarydataind2; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX binarydataind2 ON public.binarydata USING btree (f_num);


--
-- Name: binarydatastoragecontentind; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX binarydatastoragecontentind ON public.binarydatastoragecontent USING btree (f_key);


--
-- Name: binarydatastorageversionind; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX binarydatastorageversionind ON public.binarydatastorageversion USING btree (storageid);


--
-- Name: bydescr; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX bydescr ON public.v8users USING btree (descr);


--
-- Name: byeauth; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX byeauth ON public.v8users USING btree (admrole, eauth);


--
-- Name: byemail_v8users; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX byemail_v8users ON public.v8users USING btree (email);


--
-- Name: byid; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX byid ON public.v8usersmatkeys USING btree (id);


--
-- Name: bymatkey; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX bymatkey ON public.v8usersmatkeys USING btree (providersh, matkeysh);


--
-- Name: byname; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX byname ON public.v8users USING btree (name);


--
-- Name: byname_v8userpwdplcs; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX byname_v8userpwdplcs ON public.v8userpwdplcs USING btree (name);


--
-- Name: byosname; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX byosname ON public.v8users USING btree (osname);


--
-- Name: byrolesid; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX byrolesid ON public.v8users USING btree (rolesid);


--
-- Name: byshow; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE INDEX byshow ON public.v8users USING btree (show);


--
-- Name: externalbindatastrgsblistind; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX externalbindatastrgsblistind ON public.externalbindatastrgsblist USING btree (storageid, blobid);


--
-- Name: externalbindatastrgslistind; Type: INDEX; Schema: public; Owner: one_c_db_user
--

CREATE UNIQUE INDEX externalbindatastrgslistind ON public.externalbindatastrgslist USING btree (storageid);


--
-- PostgreSQL database dump complete
--

\unrestrict qMWgeSY5NWRciP8AolJcnGt69NeIfyZhFXGESUwy66h6p0I3zBTLuK6xH1XjyZn

