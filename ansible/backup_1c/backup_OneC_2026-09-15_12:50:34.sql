--
-- PostgreSQL database dump
--

\restrict o59Ra1CHaEMenCKXqwly5tcov7UdER4C799mnxsta49YAkNmSi7UC375eYcFV4Q

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
	Справочник.DevOpsTest.ФормаОбъекта/Такси/НастройкиОкнаТонкогоКлиента		\\xbeea1443d45311ba45fdf953493ba4b2		\\xffffff7f0002000001000000000000000d0a3030303030303063203030303030323030203766666666666666200d0a2f02000076020000ffffff7f6162829718240440043e043b043e04320420001d0438043a04380442043004200012043004410438043b044c0435043204380447049120d3432b65450200a48581cb239533dc5eba368912429ed2485e759203aa87a1cb4281a281cb23957dba494a2d0b494ba94b12bd57ad5b8b82d5ee10446cabae784cb2e5b974f7884287818181d5cde7f70e7995f34ba9a9087393ecba548195db854d86e6175b4cbb757eb06065c83ca1954869cbbfca11004b9b0ad5c18223b3a3812020204cbb757eb06065c83c9a096f6e655f635f6c6162d5db854d86e6175b4cbb757eb06065c83c818681818283202020202068e67f394e8198bf8a0a95752c9549392aa6567e3346a6a7471606c1440981a195921ffb870ec8cc4fbad50c8d0b3467c681202020ba4b0d11ab7a18938bd68181913c1dcfd1c72518658f16d8dfd084c1e19a0d4575726f70652f4d6f73636f77a18181818db0048f805101008181819a0f57494e2d424d334c49304b414d354f8d18068d9e07819a1b666538303a3a336537663a326332373a366330643a6434613925388181819511c7e36956e2d947811538134deb8bf39a04353832382020ab10818181818181818181818182cb2395969825b0fb9da14eb120c4dcb772ff4ac120a2cb239533dc5eba368912429ed2485e759203aa8ba4a1818181a3c120000025744558740d0a3030303030303238203030303030303238203766666666666666200d0a50bfb02e6545020050bfb02e65450200000000002400530074007200650061006d002400000000000d0a3030303030313135203030303030323030203766666666666666200d0aefbbbf7b2223222c36336132626435612d363765332d343064312d383664642d6335326133313230396461322c0d0a7b332c332c22466f726d53657474696e67735f544449222c227b342c312c0d0a7b307d0d0a7d222c2253657474696e677345637350616e656c53746174655f544449222c227b312c302c32352c307d222c22546f704c6576656c54617869506c75732f5f544449222c227b372c312c313034302c3439322c313339352c3637382c3338392c3231322c302c302c302c30303030303030302d303030302d303030302d303030302d3030303030303030303030302c302c4141414141414141414141414141414141414141414141414141413d2c302c302c302c302c302c312c307d227d0d0a7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768	2026-09-15 12:31:17	0	0
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
122dafb0-668a-4e23-bc24-b4b784da323b.ui	2026-09-15 15:05:23	2026-09-15 15:24:47	0	23430	\\xefbbbf7a514946724a366d4a77435173696e4e5159346a726b55545346687556536b71536458723875784772776c2f556e4c38755552765a392b7831696734584349660d0d0a7134576946445155464a42486450576c31557274372f782b4d5656766a6d5238483634477a694b4e56315a4e493533525963445167536f7357426b76386631640d0d0a6c374f654e4552366830537861346a74636f306a68766a68356d67564969462f33776132367273715354426b323771324d397346392f30526b2f3176736f4c4f0d0d0a413073384e45334b6557506e4753514c557639616f563475476c596d4c4f6268734c564f727770547550346e33525546494f3461796536384a4f6b4f634345350d0d0a642f4750714f475752454279447877306142565151434e69612b75366f436e39654737553578613234517649464c46386c71534a3742304d374d3867527562660d0d0a36334465304177383350786d724b6d356c6c57305a734e31573835554f7638774a6135765470414f415049656974746a6b6c4c73316d554b5272756f377153450d0d0a413151695577364c6459324f6b59587458455a6f41744a616b78436f33544e6c4865455a426d6369526c43467a74554e375a647a772f3973366b6159593257360d0d0a474b4e4d693878312b614b66392b734e514e72706161357549526d44596b54596c4e466b676c422f4b61614365687271776f51504f77516d476f68652f752b500d0d0a58734d6462734937344151526f684b5343334378664b2f54646136584d6d70796a3854734236703953536a3448392b315271785469666f5a78764a4a33664e650d0d0a76394c38765a68515259634477776f71394b384e33714469694f49584b6952623764305378797a5754314234777a55574d7958657672476c46736974396559520d0d0a4f6e5452415849694737376a3541306c442f7a536e7958666a6c51726d33726b524f492f616143755964733948494a333959345079417730505168452f55442f0d0d0a3966494b4a663774684a4f3377444d476252547355724668367a427a53686b55705043497452305a676c37624b47563057486d6b75347033487449706165384c0d0d0a35515a6a547a674f366e4b4f4b612f4c46512b694e7153372f4933666f7368354b776d794767504c65457446482b354f4c504d79787734446f496d6f67366a650d0d0a4e75465074594b326f395177793546546374544c584d68413276706e696c75625178506d366a7758326f66583737783367572f4c65366e476255712b667372380d0d0a61764a6b3862504b2b5a655443435168774630426c553735715066696c564c5a6c4e31624243496445594333526a636f376873486f35596c7a386d6f3174784f0d0d0a3631636c31324a7345536656335649696a72416c4747524e476b4f324f6d4633642f797949734e333935486a6871784644525a734876724f684b306a535978530d0d0a6f4e526c30544e4f70596a2b35634a39696e747a33697057304275316e3647737343426a637472723738567a7a646a724f73556e7864626c34536159694c73330d0d0a4d55747857394546324345334e39644f58774a5165675a37524c3172486b424d35733148766537334f65656c77435a542f34376e4b6a644c485249396e704d700d0d0a32394f4a6e4c74796f4a544848796337504b426c39345158686a714f72624b737945544e355378764d4671676b7267413842665a4847413475452b50636f64520d0d0a4e6b7934543641394f515731644d55327458737236627163326d466371385a4836616c6a533258353174696f543377394555712b6c635a53356b656b645161460d0d0a382f6a573665537750715730585359445736666f5a317671337550566e756b564b6c3835674670456a67792b644e382f556979765562373845506236326d586b0d0d0a454874315852706b6b364238503953456a7478557248626a787434624c315571686d6b536442614453586159496a6c303449786e7135517344485967563046460d0d0a4859626173384676387254482f4f32696d56794a756a496d6636756c4e6733614b6d52646563326274724a6a536266364e7841784b6748506d384f68675463690d0d0a7930307a7370523755696674493672585949614476454e777830476c71354a413876634b57354372417251394f775548716d7565346b4b64325751514d55414f0d0d0a395a545578435a41777744476a3453336b7a754f5236322b4139516647444a2f555468625a5350684f2f3672504336546c7a643665356e4f47385757463266370d0d0a6230735a4d57315858565335654f4b4a314946365351416541776330437774754b4d6562735078514d51455a41775848587557566a4443494d4f776a6f3136790d0d0a2f6c52715337416855363474553138356263586a4e45796a516956636e56775a534a4945714a4c3465677a454b2b5058784648505142586a2f4b2f484c4130590d0d0a3834446f72582b73734144452f626b304359746158657a3032685473515842645438475a7068626d336f3249553734673879536a6c5a487263334859634357690d0d0a787537616a5571664b417050743155335148614345587758464a59664e4d74655079617771363758676138725941574e326c3458324959464b594b5a757768590d0d0a684a694e6f3758376e4835386a6b644b584d6d35496172514741682f36487666775145476f723462434a6b42626d6955544b506d7154306453754d36466a6e710d0d0a4f4d5a534a50676a69674256483839575652426c3645343770554b5479624b58513669516371684b5a63733256696e37684974645a624a4e4c61426b734834510d0d0a59474a2f34476f4e734f466f762f63576b674b736475722b484f4436494a6365534e31746b4a564270534a486c6966474d785a347967723067516e6535684d700d0d0a55726b71564930544734544f74646f43596b51574f503163676844376571694e6d734f454c4b6e7131693376773072653841492b3776337045436631794751490d0d0a364d454d50336733525977712b483173586a2f4663567277327250457575484469536d4145643270434736373141584e5768397242554f6347786a4a64692b680d0d0a614e36722f544b3637696f5a5438685a4d61706776534933516d446a544f30616938315764447a436b7148474673576d6c646a644857313375306750545266540d0d0a42687a494f646b6634585239694d672b51545061385337747936735553442f4b6a516947586f6e376a6d7170306a737936364f7154762b68616a55636d37754c0d0d0a35766d6d7235435a424e6938303375364c4a396175363735636e58747146717375374759496737313961434d554947385563504e61367a6579465859567a36610d0d0a35323644554e66794f6c30554b75375848754d37305039596e426f7173714d6543555172783157474b73734574694f554e497735305754616950554d77324b510d0d0a6475544162664b6d5332422b36615533525071423864756e694d6d6e4458366d4a303046685055546a56355473365147663265527251577a31715539727645450d0d0a3933725944463178676f4c4a2f6c5a477146446e4d2b4434533731526d59796f522b4870364c557a4966497036526253716159444666492f4c4f3065382f79750d0d0a715770744d635439414f623975353653636e7870357a4f4d66452f33696b67766b7251712f4d716e4b7a316b6462734a4c323639616b712f58786d474a6255590d0d0a7538666867735662643449446967544d676364584161716e6162744e636d4d7a543351435a6847464a63695a2b30317a564b5736626b4c6b696a6f7a50375a310d0d0a41782b4d5a79646d2b7058447266584767784d6231353936595475707479645a6a444d6f46484a307031685a37356c6370512f47576d46436e2f656c6c4a75760d0d0a5366646f4a6f4555414663506b35634b474c45364e74526f7a732f2f796e56364e55626a32656e2f4454307446386a4d426e7750727344573868322b636273540d0d0a34535976644c697861514f444d68434c305465456c786c6372527334684c68507767716d546379594d6c527444712b7a666630357a6236304b694a442f3061650d0d0a422f6c4a795669427757477553656a453156784f41313362427a5355684f495241784b49756339544432346a696a72774d76574d346f6a566c382f35306e326f0d0d0a5a4c3772535274662b494d755279534e4d41344756526b7335436a5a4a31416f51374b4830632f555450397559326b487976735638336d7433565337465547350d0d0a6957726f7a3559754c7666554c5478556a522f4a776a73743479744454644d446a35687277505838734c474c486f49515651797647304a567331386f2b6d6f720d0d0a305934794b5169786247675a465061546a5568317a35576e4279394e39752b52676b47707a4b456773626971473146586a4370686b58366c546b75446a4446780d0d0a325a42792f774678312f454f514e516e366b3649752f4972562f5947667a364d56734670364159413943616b48632f6752696c36613135415873666a655152480d0d0a7072654f4550386c32454c70355447714662596e34555a4e6e754659534e6a335a41634a4b303462664343755a5a4a68326f51716d334f4a354749394f744a700d0d0a78426f4d773061744449476567762f346979794a7a724d577768556765303138715744634d784c524850735a4f506f7565746e5a45686e694c6a6354393872680d0d0a664f43686f33795a417978764146764174686a47487876525066567a6c716c4a4e6d564f367433764f447a674f546159716f55595a534b58676e6d756c7650770d0d0a70784e454a364546474a6a6f6f79305042386d574f56314e4842322b37496d416e38415869334b662b444f6a76364943485a39486e536f6c566f694f336d59330d0d0a2b7a7078456e656a5a464279327a6d34772b7069392b43454e6c637a424e433171746a5058776f797367323758737061424868426357414d43575164344e53770d0d0a656a66393371524e41355a2f42782f49764c43465145466d7a2f314e56516a645433504f5970662f52316c71384b30516f67644b372b646745496172777356350d0d0a483032384a576c2b78366b6376433452364c74305851436471492b73684559756555544e6a7863385a7779764a4e7a4f706735582f4e705334745a7a733264430d0d0a6c6d476e514c577356784a345261617a6142325777485a526c4a59577759364b4a304c456d6c2f786b4978744d586d395835397959643136666635664b66766e0d0d0a4f6e6c3330477348344e436c4c626b3656757545743254545041537a544d534e537646672b6363336f486b37654f6b443475724f5855707361625752755237440d0d0a302b374e46575734616270726b554774307348542b4437366d777046677379573964514e36565948496c6572722b42505a71305368686a5a767a783949785a510d0d0a796368397a426135394c4f36544432557264332f714e35306f44325a3433457037787443316e42516d6358796e6763504d447331595965506e68584d5074792f0d0d0a7779304a6e6f3755526574563645434147736456514c66646b5668506a664e44706e724b6433504751776c37586534322f5167384f354c6177462f45506433570d0d0a504c6a6f39795a4d424a6379474637384f654f6a712f73332b346f534275654a4945372b4c69786a7239314f724c4776353639755869383965665868554a562b0d0d0a534b71764f7879426c446e46666e32543141735666712b6736517450352f70412b69674561374c69675541465a56764f414f32796c4475796a516f50523349500d0d0a547679626a4c67344c31545261635a5732534555753252704847584a6569675771432f42384e5074433458333674726d54415a65494e74645335394d715348430d0d0a54506c55647455624455736365704f6c584d6a647663354a354348324130724d57493472454476324969354e68636f4742414c614569303764412b52393846790d0d0a49386e6e44795a67435a762f3847623756426c59462f744b7762773869654268536d42485443646a6a56654a596151573461564a366836382b4f59425068316a0d0d0a545645314237563543436f696a63417459437542636b656f5147417349707a71767769363135324b6d717752524154754431666b32694b3070784669584457590d0d0a2f6f51715a354839384d542b4351724f49635736306c513545785a2b6469656f42774c565966624958346d442f376d69366337434d4c535168796e756d6e476b0d0d0a786665452f3331537a432f7545506642797167595642472f4c782b7357544939314675343573466e61772b2f3656455950684e5441534a72525046656c4e78770d0d0a4757657358597753413156373862734a554a75616a53704c356f70565a4a5148494a3146392f4a327363584b694677614b4e5942323755745476414c7a4f574d0d0d0a33594f686a62787237786c4d624b5a7a4f2f4b30654548534e6c45755a6e475677587a363078616c6e71644836783472547464423135357a4d556939673831350d0d0a794f717276675245574c69734a414c4d7950303150532b714a6b4d79346249556b5341374a796441452f662b31792f4c42504a767073456773644259673348330d0d0a57686470593659373459484f70392f6c596c574331796d734d4a614e4c6850316770656e78794a74775553546f2b38447936502b44336335582b6c464f4634690d0d0a4157677976726179685042375037655468554b51462b4157312b536c56395432506d63512f6336432b63375845324d494e4f6e4d64582b4265625267354f56640d0d0a617044694b4c6171705257722f36353761704b4361455263485a636d357644314c412f6573775a4e6c555a384c4a305377346146626d32526e705830307444730d0d0a535276446141666e6e6b775462482f326b336845505261684c665570774e357165345630706f763947744d61356f6a7358536f61756f4b61736f316d4d7a794c0d0d0a6434727a724a584d436a6e5242316452397836565a4e4b6f457477336f5155636b48515977653632675332524b4e444144573138566868744a372b706544342f0d0d0a555547326868595631636d5a426c4d35373058553571743539434a483663546c336866614e5030397a2f553739756850426f514557507172587043314977756f0d0d0a4f4f59767376682f73794f622b37636b3073587a4a52644632694864737956416c61784e566939734d6f533355336f73747274756547446f43744c7732434d660d0d0a41394746726f76596e784c6b546a5961784b5235617a4155353936346749316546774467713636566d34394d63334b336f514a514d6d526c5655467a506159370d0d0a616864465936526f7263396f346c535166394d4b2f3853713867762f4c793962334661747278323735644633353569394a6b5754413576342b4d414f537079610d0d0a4574636455675139424b54666a4f6d38417973432f2f4247306232316543776a2b30535261596b33616b5579437a4847676e39307359514b415a777245756a580d0d0a327470434e713242424d306a4b37464f3735364972614a343972474f47624d554c2b446778346f386e7375504f6e3931514a6b484f554a5652576232674156750d0d0a2b7435714d495a616c557a2f7a323766563873676a75504d6a30544545696c633477592f67484c77356c663534496c47774549556a69636f4864725172492f360d0d0a58363770424579364a6b692b6b6e42507235377a794248337868564a644c41482b5a7750333262534a6c78494637435a57787a72565a31306a6336326e30464a0d0d0a43647630474676794b627668306a3455556835755250332b5a7a456445687355754369417a42594c78345651366a34332b6b5943384c464f747a337a565334440d0d0a62647a2b57754d5031427465327469623739566248375548794c38766f7857566f4f6a746d4a48375862513273423974613658706e73397372553956516d792b0d0d0a35674569634f32307672667731412b4d6e7664733361324d646e2f6c4c70462b6f772f455a2b76376473384b475569666b77662b6c456b4e6f4c2b34386356430d0d0a2f36616f4c664a676436616d61464a36306c50706579483042643335545932467332614a46527761514374384a6e4a4e785a3456664e684a6e574d344e7637550d0d0a346f5144547563396f5a4d396d6f5771474e4b4b6b444d4a744853544b2b54445a614830503546336d496a582b317a39316c51644f59756c6555644c314443630d0d0a676637633452552f414f70624d5a50654a5233307672337779474b6b4436416e33574a5973534c3446756c70544b50796a417a50776e507645584f6a2f4273670d0d0a42782b2f55527970346335564c474264446346376565482b39704a5244754a53682b3641587634783666685a6d4652625155714f3933513439717246625757560d0d0a4535482f67654c54434f695358486d6e41756571514e704e30554f55782f687362344c6e2f74632b4c75643175573452384b714955414e58707a61564132454c0d0d0a44714d354b6352646f5a41366c2f4d342f54313933685a495934556b316a2f39683062376c7463574f4c516a5a52712b6e553162472f2b424144524a564a42340d0d0a6f646e464a7361595153445a385a384b526f5374626a3876682f66496654412b6b6965664c594b51464e462b497873447867436d2f57655848303748515176480d0d0a635a615a524d426f586952587772356361635246644e7a7a51422b6b4a38342b6d6e325677427569415936787956634f524e55636e2b6763476741653658744e0d0d0a6376737465693069675a455a61526b5676714d2f45544668514d44686b6f796e3356705239354a65416661596a514c7434397a2b4e745a6442386e556e4155320d0d0a39466e646553504843424b75586b6e2f775164634a366d3861616a44482f74664c5649644e385174654b5a37517050684c75587131714373556e7773527876500d0d0a5a325467506f5858704d6f504f58754c633145794c65495646537545372f36624e4f7759683772564f585163386d7466505562557242747947306c466f4255360d0d0a304e4735542f6c47445049717538536e684e613133586f36527264334b4e61513649526b586431636973624339616b6b534d6236543848364137642f366337590d0d0a48447350585854597278547a552f695839523859355532493667595763795564474a477451354f76425868434f6f616442566b554c5a37553473754d6f784d6e0d0d0a2b61315851524c2f706b5a3574766a4b635637786233304a376c6655687645435a6d67563541704258667949496d79784573556e4362425445467a51656536660d0d0a337269666f4e45732b6c56646b67622f736b4e4c64505a337042694c644f384f77785477436c49524d562f524355656c305867432b6268707052574f4b7347430d0d0a49556f41705a4b57446777692f2f78533065426e4c2b6977434b41615341357436306474685a47566c514e6874727a4e6665456b575443434b6b646167382b4d0d0d0a2b70435676396c495654746672454a347546594c66596661326d386d754d396a64363966546d4d67582b5166543064746f31382b4d44746a45594756694461630d0d0a4f2f6d736d6e666737427770577361684e7147365051576b656357797230416357616f5a6d336a7a453430715752622b70713565464844436f6b6f734c556e610d0d0a4e6935524f5948513469544243426935457067504c7657484a5a3742543869683230464c647033314a367167465249495a636d62666253767461724d386e6d390d0d0a736f3134717545777754696a566b6544464b6241787577315a6b2f664f6242564e73515746587146677a5a775973394a46497235525149417432687a58744e630d0d0a39653756667a4459657a42456530632f744c4335482b584e376f67565a386d486f437045566a684b50466631644b64724357327158633147566b466441716e410d0d0a6772494353583762796e594c507441765664314b325234435169393253416149423445466e6f445a6d463261553244664e4d50316f356a5462625831654649620d0d0a3970517a34493068416949714765665463534959616637573377586b6e44386c4b463465664654424363672b32482b54705050576c536179715568662b722f6a0d0d0a64764a6a424444496f4b47476a38324e7a6b726959564e6877376345365a387958703644646b634e4d6a51354548466e79736e793779726f556d75734362614d0d0d0a465a34627a44437633594346705475316c554e693577307536753831316a4a644b476259534443453241356d4d4f3942416b467338656c48524e5a49767331670d0d0a3876527131585a30464d7a2b51566f7533686e4a50347169356d6e6c73736e51346d6836696d617a58644d4671683855714738494d47456e366f39766c306e5a0d0d0a52593575386d647954506671476a51343564345a416c4a6f58676b52462f37344c71546642684a762f396b364b7935396c79434e6f37397357685a585457686e0d0d0a7a4439512f75776a694e5363427745506e4d635664343364786955795734675358674c7270346568396f662f5454623448467a7a4f427143686a6c726d6e78300d0d0a566e7865616774424133316c6a6d777a667870384631696e373871777459654d6a47325251625a33366a5244705a2f5a4c55785554526844686544485379784d0d0d0a424d31786f575468434965426a4c632f346367534d7336426c2f745635424a774a66624442576e4533657a76595763337166567361534c4833385777695733680d0d0a3167754f3935673676666e73754a6465414461764e67532f6c39775158304e30614a557947426c706b756936457849596c4b6859312b38766e6e7072627364380d0d0a36574b64432f3444524a4b6c43374b4f7a4558642f5441694e37464f6c44667666582b34704e35492b636b5151354c5872656a4171354a2b4674326e475835450d0d0a64593144534a5a772f614a6478516166567461767a586764706f6e44527079396159572f3970785036514645692b6663544c7079796f484a693178643575486c0d0d0a4f373771704f6b4d5369784a323850535677763847524c594d6a54736a3832395966337a2b765734647857627051596f54767335394e6d3433576e56584134640d0d0a716c504b726e4c4e6d5a6573755855494d674e6a38506e70514575786175454852456d59473276514d5344662f33307072623648387368616c2f6267562f2f760d0d0a716a306939664132776d562b784475636558674c434846427531486a333644726879434d6c5a625452474b6141697662444e504b626f62714a31464a4441766b0d0d0a5957574948646d6c51435a386b464959304b49644b3850682b347a6157656667627439506155466d52314c686e376b335a4530766453684f58324b2b524e74570d0d0a6a754f326b5141473071485872424356444665504743322f6a45356879693034465155316a65526276664e4a706e51504349724d2f6f65346451334e6a704b670d0d0a462f4335735239697977576732537477616a7968596747345779794d334e675974766a72526c737158414a4a4e335574324463766e7a482b564641413265776d0d0d0a7933505951537a3649614374426448585a77452f747a37677231344b6f47784d565775434654467a63302b30754c36687430755134564873775730344d2f6a760d0d0a6b666971317a4a4577487470572f5a6b466236465467426b582b4e7746454b46647654334b37343757306d6672346c71366442717348506a6f4f696c706659710d0d0a4a6e535a492b38566173756d506b70325277656c38496670396278496766476e77344c42797a76776643327457702f7679305a31504153426f70476c6e6b75420d0d0a52537641756c5a443759483945336e34685476556952472f4361317931504e46664f4b4264704d3571375a6a5a6c653973346a665552654772705773494e767a0d0d0a5949454f766a69486466617a5a3976504563524a35346a75477049396349726c4e4d7456487071316557436634653737713465336169517656503244737637300d0d0a42794367625a3859654369302b4a2b4a753367514c4f48443844496c747549436e4d43506f7948384f4735656e39464739427a4b6272616646474232645269350d0d0a7a52396f7268446a3353666a355a30317174565635734532587a70356435396b646e4e394f4e516e4f2b344e44334159694b79515136624e325a6a3552304e6f0d0d0a387779327431583238504b42387857376771497059534135724c37697769734d38686e55554279746849504c3159336b75594b73535a61386265346e772f654a0d0d0a4d66465235554c6552535558624f7159413552394b39514c4431342b66616961326a694e68535041537978596a7936744c6b374b6f4134315a3653394f37364b0d0d0a5762696244746d5a6a494a4d4e78425135317865494a4e74587774626c454d4e61486d4d6c51644151335273324f34326a2f2f584e534a6e4a776779565a6b440d0d0a786335634e5775592f4c4e6c724f50516a2b5757565462443777744e6956704565577a34327a534e6a4d52356a716f666b4e724a394e59334d754972537839690d0d0a4435774b3278583951687532304a74442b6c482b63436e6b39776755716d7232383473693570635776445a4b357a3476757843733369333131734b6b534d2b650d0d0a59462f646f56622f6d33704b4d33527231736138646a645a4d703161684f595a724b38734b66574c7265617a6a63426a7859456f37574b6961304750435042560d0d0a6e64667449433552424e4f67682b3568656775644b444b346c464a5a76576f796e3952455a37594f6247393664447376332f7435364b387852465738387876330d0d0a394b2f4d79502f7a446142774f5966744e67715165635a6359366c496a6f734c584a5970715831435162616e61364f306c4a49505271324a5a6241356f6677500d0d0a516e716f73615575555676776b686f393670544e79335372424d36324e43714339304e436f2f37487a4543456a344271766166657454546e655246414f6144480d0d0a4872642f764351306e4a696e5943543962766a6c7a6134617334384464305937777648744f555670694e642b386b7054396972706b3772537639592b463242340d0d0a5174726e6f2f6a624d5436736b4644516b4c6c6f677944444753636b396d4465586a4e7a55734e6e4f78386733646f61505570486147506c5867623342664f4b0d0d0a32306d4d597244594e716e5931513855427a42575468704d4f466e7449314b6d4f4f3859774677414d6e4467524b413452462f78566653576d4d4858436652340d0d0a76473949553852465a77356b7247652f6742555a50613548395555307552535255704c4c3752467334736659784e33564f305072432f6b5346497351306530780d0d0a6b6d4d39417a416e3168756567436e6937472f635177512b52396f5746786572494a48487a4f323667384e46562f51536535575837656a4b426f7865374c44770d0d0a7779614f62474839547867616d5661436347544b547a3352536a7944674b504b744d4f5042383733473449734a6d4951696344693376387842504f6d546664370d0d0a6444374278797353496a49574d74337864726e707a576f4b6b574d726254374261735348553466534c5472716d326a7a692b6e387a3645377767634e5257414c0d0d0a6a50636a6c743567736f6a7a3432416a507772634e6a544e554e35387931736539736f566a586b6e345336743730524e306e57427241722b517670677a2b65730d0d0a30566c4e4461696e506a767874422b4672417862312f36457a776f633842383634516647674d37322f565661535056694f4c6a3376645951594136645835576a0d0d0a52596d6e445a4f6a67704b6679554445525536676f6a684971706d47586e4b594171744633754964427749336f524d6b307a71536967706643746533654263330d0d0a446b54366e722b793958784833495936666a424c436b53646863677937795667436b62565254645a664e637046335259594b546f46664c706e765050374b48370d0d0a54656c69666144576a6b73744a566777612b4732724579355a6369622b352f497164567a612f6a78574e69714c527a4646776f4958436f6a5766516c482b75350d0d0a41566c6173476a2b3966676d576e324a5734415267314e4c59595a4e7538625270694a45584f4c4e4157795233666748447a4761553271354f57652b6d666a550d0d0a4d36564463612b6544496e5a6651393742676c6e795a484b47466342565a7545557a505470665073412f7156484f77786c634968573462356a33396c2b474e4a0d0d0a6633376a794b58502b34736f75573359753431304b37677330306e50774d5a3148536c4f4c48795538716f6f5a6e4c503746722f6832586f764d5a46507637740d0d0a4177324e59572f35786f49684332786a346775776f79442f5a466e3571412f617141346751764f662b6466493451644d4d394a6d362f35716d634f77643853430d0d0a55554c613359714c562b69624c4f734838595736526d56524c446e45393759772b6f46354f3939553254594c4b6a7a377155417668636b616e30484f66316c360d0d0a72694e66596253452b4e7573306d776a4a476869533249617655416f424855757a553679624734374b45614d5976417351774d6b6d504a416f534a377a706a510d0d0a2b7961736e352b7a7471694b6974477066427a5a3968354776326c345064453974455a715765553664423332546e52616d724a57714f6b4c70334932613761630d0d0a4b47426a4c6275386e5a48577763397378424b6e796235626542536175345a41772b434a6b5667735a7a71787645584b6f6f5073556f454f5930586e343669320d0d0a5876636c2b52506e612f74796f6d4335764d754853662b76476a77485951702b316c6c7975394e586270506c335742374f417074466759475146307634594e790d0d0a616a6e342b656b626d5845365755482b2f456c7062316554517a4e366576706a432b396e67756949344c3338684f6a747337504f64486179727a566c2f3470610d0d0a4f4c544e6e7372796f71396b77594a3355776a642b6e62624f693271467532544a593046476344537535476f5978642f6833644968573878464b435a7878784e0d0d0a47542f58305a5a6f444c2b5473666b2f4d4263614547736466304b2b3571466c6c69486c57324836524a45364f41634d52394679492f585968765851556f54310d0d0a4a544677644765766a654e722f51346a627434393636772f6b676148684e3432753132516d4a6b5357525974747839436b6971386c4e553367694831514336780d0d0a6253596a4e462f6479436d6b7963477472554c64534a4a6b5571774f74315771436a75327841414376527449346c56307551494c4f7071432b715a624d5659420d0d0a47616b3648396e514c574c4e64516f747a414139714c434971626536516d6f335531672b5967394578512f7951422f2b3168544b6367506a716966446b4e5a690d0d0a7a4573736d7169742b4b346f3057555746426966707770622b6a414c46512b316f7a39524e66574e7531365836636f33726f634859326f4e5a6f2f63596656430d0d0a30356c652f685443774445474c7055374b44324d77386c526949654e757547326a726775743333366268425362756b32485637425446445432567038527a65740d0d0a6c724a574459582b4b4633384a33746a56454e6b436e766c50574b716b7352796e794c576676544c683079424831376f4c3341417a2f6d424c313056493631710d0d0a6e737a5479445a6864445330793256547750546151334d2f6f4430322f6174663249592b464649346a4f573872797868695762664f6577632f526b704442526e0d0d0a36364552447446426a74766d736562642f4f7357424a6c6d762f78376f4b735732675239692f6d44336834454d494e4c546e746a4f79384b62302f56396a6b680d0d0a49483832496a536259726e32796a4b324967734139494a47362f756e443971615050706e5061476548464156545473394d4859566d2f78314f364362675633610d0d0a7368512f4a717a684f374368483235776f384e75794b4f7845466f59374d7759486f786976726a5a48763145613476624156314f2b636a66723738534c714d690d0d0a6e6647594d6b343270505049374b715959696e75475169725a765a492f6d617339496c7574392b53397770394e533347757844494f756f4e4e4f584f5a6a49640d0d0a2b654c6173705a546d4f6f4e4e3376496d43474d714b51676e7130694455753063387938734446317948614d334d574f4631456a5954452f755030657a4c42530d0d0a4e39334a6c74334e6374544175784662345144615250393247313176482f712f43396f5359545a522f4250525379757951633837625a61416e2f64443644744f0d0d0a5869796f4578312f4744314363482f6d79574a597152476b504e423169715a477636484361596334384b647242763549377778344169544b72335a37775a624f0d0d0a7367662f5a3643313177715653596f364b55616538455a477673757a5465487a5256565a6a51784c2b7a4257526e532f67534979753642617172387a4b7274410d0d0a6c4566507665462b707849716e633430474c4b385872486c3073522b75642f7846696945426830766a2b34466139584457663738714d6153587263556b3965470d0d0a6855652f72387a6544356257674e4153374365734c5536716b5842674c4164663661666a657176513169746c534a7755427669533632782b4e436a45434d64750d0d0a38634274657351667137517132744f7a7035304d2f2f422b4b6f6466673847577445576f36625855327753336a4e416d30536b3946703861456a73777868792f0d0d0a70677a314a2f6c76325972746c662f41566434357577423749446533716c585455786c5968376f774756426c2f73774a5a3161686b34674367516b567a6c62730d0d0a314f426a53504c57502f644872474e6f334e4f5a6b526146796855476933523862642b3847774c763255706f43537361584a4379414e6670527a6f6c3038374a0d0d0a5550526b5541336a39736f32376c6b6d316a492b2b45394c774345464b4271544b34744b6d4d645955465a4d772b7a387a612b52322f6e574850614b574342430d0d0a3257522b47584c7a3033536c2b776f32516650424556456f7144423773586343716b7463794c4f77336973387a6c4b6e794735626766453769596553646469340d0d0a5a4338766e705756396f3434636162744c76337a325547357a376b626468564b354e41395561523874707133484e594e65544e57504c6c4d686a444a31684c540d0d0a4f646c79576d6b39796f514c422b6f72343575615543484634574e4f496c426c6841414e495635524e5a31313858514f655237655a2b664a775336784968356f0d0d0a6568597133477a646248555a726b474b5a5354534a494d6652466f7878446f716c41374c59416356337a346e6f39544d5670392b49522b70386e6452612b462f0d0d0a5147724d4f39776c76392f61395378482b2f3834695477573446464c473758776d4c77586b48696b464333566b453345344d647569746c44327836794d6c4e2f0d0d0a364b6a2b47464e6c716b485a3954397a3448732b443462477a725a54596945743050626c4a705241617a4f626b4534577658787a75624f6e4f63354d503965310d0d0a4547644242475350423533315079624c786746655670792b69646c47486b7a5a78757856495941563232674967626d672f3369577a3134574c4b5973784f30520d0d0a557155565655456e756c59326267675a2b5270326577316847772f774f735074566334784e39563131553547596747646a6839747746773677794937643275530d0d0a626a30736a52756e2b6767632f346d713755457168764b5673796a5442384230677052346a59516b49573069614b6c5a3244616f2b782b63623153544c3479750d0d0a486a4277534c784468754f51747149394a69724748696235686f76542f61654a61494648424b6969704e57393874666a4b6e57656b4a6e61466a4774316e74360d0d0a79386f562b427859387078516a46753048334b516770374f46556c70764d3139647274436b797355486c31476c7373356f6f7a5971396c4861742b39387a79510d0d0a782b3649666236646f706645587676454e615459356e67726e496179466b4557556951582f4e2b443846726e644876575374444c2f616d632f664a4c486978340d0d0a4551557a772b4a39484558686a6f376c4671534f4a665350684a4334696e3132664357644e703779784a6d687164376739613041636e414263657544634e66760d0d0a5a534967487a2b53474d6236376a7158677754546c6a7652496861647569635668326a67356d33794456745736664b6b65743936546d574268372f47462f6b680d0d0a364665544a5834356a326b4a58732b43344c7453587861626778786164774b6b7641355535336f325374574573356e665377677a62726a7272554d75437141530d0d0a706542322b2b77623168797947424454325463596d636c534a66724a32384233665246496771356b5373642f594756714e4d794d6b587045375a634939597a790d0d0a6c7072734230654d31343577706444617373396641625058544854382f4853616a465a6b547931735861797265666e30505761764969742b39376c5041734a680d0d0a505469432b74534c4a772b456a6c374434524245305569586430455453766733345254534472575952654a58552b7747504236543438417466726d4353506a740d0d0a71695279347a37584c7449616e36637a484b653761464649724e7155736c326d54523441473768774d684346537a67666c4f56353462645665514a41785547630d0d0a55784a7247664a526c4f46793375733355764b7050656e78306f37373153717570753649626343386c315569617178733750715166756e6d6a3234544e7677630d0d0a65317130546c65435365554b4d55724c3051647975737064354d586c4d77442b6b4b464a4550795a4e386765596559594b6e7464566c70596649573270427a310d0d0a6961383150616346594e6650375633326b706271716c37752b6b63654b7769737a396944336251654751436b46557270786f57532b2f456f316b68724e4258340d0d0a3878377a52734573324753684c7332464a5978756d504c4635525257782b696d556552426a44353277332f5330655559465649444b5a662b796d4543523279310d0d0a49315548314452463435512b75783671385967564c6f326f7057413844695853744650764f6d522f7145455739637754752b76636c4b2f30584a3859344337650d0d0a447653776a554d684a4d543938354f3969316d6f5a38366241706e70454b46554c6e42516a42774b6e596d7a4d6b4a2f75495668767a66556d2f6d4c2b3174630d0d0a55345a48666e6644544f4847395573415757695a57706f47584b4d413551487238426758424972504166572b72336c7a55646478426a53616553327a374e46450d0d0a374e6b4933396273563669716d7a5761664d345771664f6f694e554a686a666948752f2b62674a37714349347a73616b5636707654584f614c79644e656248700d0d0a357043476e4e687a5671556f5a57436f44466d32794d4d6757644a667a6b2b5768384d4e63475a4343344665517053697976785a5a57443354463059336d6a530d0d0a4f746f37574b736654364d31464e35454a752f707841487756307a556c456c703957674f55746d724a663532784d44634965366c38694a7354624b336f5a49790d0d0a53474d5a78645a4358424556376773773065573362464c3579516d344c5150314c6a4b7673416237717255485a7475366f5779474f744943666a4241646b356a0d0d0a7077696e68532b4f7434396662547a61746d3137574e716175443779452b4a54314167347073444e344f494f384477592f5a5a525664574a4730686e716833300d0d0a5978316a4e2f366b466366634d4e6d705570657149436a336f554e5535664c7a384753664b575576427a4230684879493456346565706a4477717455736466750d0d0a534d726f62676f4e6f30554e596331426f4947484770507047784c425070327061507863526e39614674734f6d4e716f596f5177373433446a4f6c69774752350d0d0a4575525a5a4c5350784e653251324846737073786e65556854582f4649556844464273715677715a612f415a45646942506344424661444c626646625a6e46670d0d0a307a2b7857795964504e577463366d74306d71364f6235326548323156617168634e496e74324f55734850724948536a4a69373352574e43724d5875573256690d0d0a364b6b55503348493331634a3146324646657a574246324862676d456930634844752f414e49566c6542676f6f66584c31436d416d544d5153735251656b67750d0d0a4251415a38696d517165516e487375456a382f6961652b326176705038594d497941305241644944506f524e36526731783065464d75774f78495641776232420d0d0a63716c71615448775933794a322f676951514f30475854317a2b6773346846537a79305379324169626e424c574b62784937736877306b4a644772737073704a0d0d0a6b71767147342b314243654956516e53736d3543445932344c2f314363444f59454f6655354e75424f43392f2b655a7363547532555252556c622f324661567a0d0d0a462f37726a414b424c32546c6354342b474867676f416b64516c42766a69422b4371774f61547769472f4e30456779346a76474d67474844674e5a70474547430d0d0a48484f38694d4a72697030495a39646e327667366335586953382b4f70447a38434c656d5343613543506e31383932577267497a504c54484937794a386954540d0d0a576e696355653274624c44344f724d5446425232764852643237362b594e6c43484d61435549486138336e776a46785378534a595261426c324a426c7a4743740d0d0a6b3975487a6d746b3346726b6f5764705a556b2b624e71687a326452467469382b597252777741337534372f574a524c4c6d7a37646d476144764d7341482f6c0d0d0a2f796b556548474b645831584c2f584148362f33683068666e58726e625a4e723667577756765645554b77687979506844584a7272394a4a6144487165376a4b0d0d0a4f5978393535427748794d614a6433436d697953526f35367a414143592f5043453471595142473462376a415878686d4174796c7477766d4d4e3532523359780d0d0a56396739634a654372545a4c747737313145496437344b6c3245654b6d7a7565682f3252683145506a6e44686f6254677930416644423933536c3561593879480d0d0a39654d57675a596b3856786157416c65627643625543463669547a70424b3648734649562b49557373344645665256775350366858514d4a6e6159554b5875530d0d0a4c56307a6773465455622f456d4f7576796334566d7935465561446b78704d2f734d424c32723872754a2f363042673343596552656a304a4e4a795a597466560d0d0a704d57464d79493449784b71396a732f433676577a54323465766a315971766c395369387956616c506f51456437565145636f38414671535079614d52744e640d0d0a4d7744485235517a484541504348533263553278754b7938624e4938584333757a745a6f6e697365476659674d4853476751615a5443594d49704165486d764a0d0d0a692f66345931775a73556c614556554a416a3049644b316d35624e3238483966644f6e50306166707135344d414e696848357538616e7535726c6e78787a68650d0d0a51634764615070384246756f5273782f43677156575245714f3466466c6c5276556f454a715974554b487661316d2b7a7869694c35306f4f70674d454f6251350d0d0a61696265335868697479574171662f625778536b33496d41506f446546655a505a795a57306130416b2b4d66554c514d3539685a52324e67503678554f4631410d0d0a5075656a3749446d346776334b79312b742b577536732b74732b7933536a363177526370353437567439622b5346766251436f625a7863332b75594969546d730d0d0a644c4b7267524d70495066734133644c6b33535472502b6975304b733854773237385636615a483832437367785250764d67426d724d68364b2f676c4f4c54450d0d0a416758564a367077686d5157366577465062453667597058436a394c4663364d643137704e2b37336e456e41706e2b385755366d45474e6751623564353946300d0d0a4c71346d76534b5833662b7a51426d6e375646493467703830484a6e6d747376744751546b6b3863706a364d554d6b52567059396f314968555a333465364e440d0d0a66467251725972664b333479655778702f5070574341746d4b42333334732f41413557496a6a41722b514c5446734e6a4e694f53636b6d33464f5946312f4a370d0d0a7332533230496f49616d52517749304c622b312f685451506e6b6e6c6a392f546b566e737647416578625473515753435266514a36562f6e49517a7375524e540d0d0a3137433758343756414679384246434530314d535073524d504d67657042516667504e5443317643655967623647783848575734714170494c774e52463356610d0d0a68426b7759697632735a4747414551363257734c5157464f6d5636546c46754655745364484e2f312f557231774d49634d574c393868305746423978577a6d360d0d0a377a4a4f424c2b786f346a30425343432f2f69437457564d4e4e6576414a76686a51666e49584c4b415059346c6a333054576b494f4357306b7a59734c6d31450d0d0a4f716b617a466f365578616d6d704b30642f6c393176615a4e4d646c536a616838505532317a775a7949346647546f37332f776d6658454a46625174395670570d0d0a58347536546d78573249683470556438633179686b6b4f415a6a383075414432665745684f4c37512f697069376f72795a686b4738334d34756d356962557a680d0d0a592b5950613058656a77464e6c4c34627943424375627a6e5056786a415173565052646d79493376785757335849395a34787852426233306b547568754b74790d0d0a5535563452736b4467794655455567306c4d47386e7855317a336f36766278654d5245764e4a574458794c747562513868637666616e666e4f752f464b3270360d0d0a64673957462f594c6844334b356e6d6e48305376497662486c464246367358516c4a6f3337485764684f5063446c3468756a41306e4a2b6673724661517667340d0d0a6447705975633845795672723342715a2f576e534b3776687153745a6a4973424f3969324a34422b67395937467064337941657a554176513852776743332b6e0d0d0a375775726e47414e626257773177742f36736f707250385262747a2f476d3364774937794345302b714b346e6a625243434e42364136573050574678654132370d0d0a7a4e7047776a6c555a756731557a576552664a6c3472426b2f6e4c4233544b69456d454b58656935686f49545666734f7269777342334b704c447a336c5a65780d0d0a3631422f696a35536e4a5a2b31674747314b634b6f6755776939795247795578737948397156353178597563433537564f47514e35306530767233392f7355530d0d0a51686e43665a5178783751743771516d6467786b67415770634d526c2f73547a2f7369724c2b4f6b4451652b46413430656b5545765347723439676d336859790d0d0a4e3352387377664238427248472f756d6f7534735447377a494b30745a676c3434783761624c4a57796f32532f325a694f5a75385964724966746464424676560d0d0a4a416230582b566877797a753345334f53557a4359346142784d324d34747134707057416b7645447651356b634250577a4b63594e546e76646d31644f6c55670d0d0a31787050694a58335a4331414d3769644c4c35675247344762634f5971562f5354544d5a32774b506f39396d5654477657416c4250314631736f69394f7638410d0d0a44784d723030424f684734715a316b6b6972542f5a6a7853424b484537613546376d362f5173463157576d56762f6464784c7a646c50426d62736f43456e4e6b0d0d0a56564e777335687441374f32734a6c4b6c4165542b50367532644230756e3148427569666e31686e4e6a7962642b47724f4165522f7a444464684c52664e68520d0d0a64715376327142515a614d766a5047755169336c79664852512b7546737a79746f3767757a6f567951354d47427932576832436651495a686733623641644b630d0d0a7975327a38352b5270513262645a4765364d53655a59324c2b444246497762696758526939695a4e63756f314a2f742f7039446271475741635a506b555655670d0d0a532f35427773617a4e34762b2b42436a48554b47574d64696c49525366396f4579307658646b6b374d6a56363558664b492b612b5a387773324453785651786a0d0d0a7a4a57386b305a6a6f55592f71663656674d62495035316c3365457875526e396b49662f704a504a4449302f3372776862434a4550324757374764763444346d0d0d0a474c4d4175597a6b622b53326d4157767a716d5855455a684835354e433534746142774d336f713530777a6e6550435041503268583462515a7a6c7941386e730d0d0a7a3357346242585a494b755a6844476a6851596b4535714d6e6b784642706e59304c376567314c6933656f7956694955456b71662b50474158432f76454a48510d0d0a48664a4242586764787575637164636369583761636f35434a633947726d567967444f436f725737573048646b512f4f395364527371646f653171694d3979490d0d0a612b62554e664a515942383958446e435865376c3969383868367a734f3838503557784545684750347377776b446b69744b304b77366a515a6443774f44594b0d0d0a454b7a4b58376c646f516b6d696c344e4d6869744c4d31357550452b32474f38674e322f6f2b5478494d3149335952712b50766c6272693979636e58723377620d0d0a5a42535a715a72386c51556d6738566266476e2f4b6a36316a6843733651396271345a655a385751475156583049732f4937446230636e426c5975486f4e735a0d0d0a4c2f744f774f6e686a7348635452507032414f5334456b6855614f4163774578682f35336e4238622f326b5357466c6a754e47776c394b35424e48353038726d0d0d0a636a45525639775879754944777a303748795073356e6939576f30534937494b6734356a68365451786c2b69452b6749354c6f4d6b4d58327a524536777779580d0d0a676b3771786b676a5a49707954477a5548544d4f65546c47585a6c6e326c43632f696b373856536e555567385533734650484e4e2f7965444c4f5635765632450d0d0a356e6e4d6e6d684f76545535497238623855446d6830494d34794f715a414469494e356e4f2f4c3573566556796445574c5667366f724e632b3265355848416d0d0d0a743949384d6742346c5877707171432b7441664a75546d693534663069656b6b656e78794f7a62526d30337858656a3244392b547779496c687a7150792b44700d0d0a4b7a5946396c64777358577a454657344c5a6161746a646a746e747239704359524430766430754a634a73574c42484576304a756b6b765432506832504c7a4b0d0d0a703542435748396b3739447158687057476c65416852654e517055324d6d7753596a2f304a52554f7469636b6170354f65786d634f73506f386b64484333536e0d0d0a5a5a626338376a64356d47627670626470354e39544751454759474e314a6d4b5a7634376774796474542f5765425856702b5872593850547467776c357843420d0d0a6c333769614a6f707636666866486975436533554d3779746f353065364f75703278594b4e67593659333379394a3273567a4a2f3465757457675468636642540d0d0a474943556b46556847304f3145387a30333672536e58454f456c5468786c4c5a6770714769704a326b6e2b6e4947624237526e38696d416a526734524542446e0d0d0a79335a6e69374833716d2f666179624176425070492f69623568644d70474b67444f396175727a354d364d4c3864776372436a5453643272666f35304a6566610d0d0a79366f4c6a554e5445426d4e4161743773314a73447679386b41546a464a75737a4a627231336159554f44413266655969316239514b745a653735664e4e66770d0d0a6478304256333741374d4c31695a46685a2f70446e483646583336364b535165504852413267746f785a6d666967774d59615756454e596f42593363576a36550d0d0a65755643476d4d797045337576424678687555683252334954596572795469333033577a31422f7268744d45326b794d414e453470634133573270532b774b450d0d0a713478636d7770335a454b4f6647565954623231514f306b6f2f6b533850342b476a7933574b6e4c524373752f56374e502b75554e776b74734b6e6f5965364a0d0d0a4b462f765867376e3074785638445a55486f6358473041782f76764f65344c764d535744445a306a3156674d454c45395332695a3337775041585735793162480d0d0a6e346d6a34593135465369762b70493034456133647151505674756f73514e58684742454362754c4b7532396949677756497356684e4870574257696b4665380d0d0a563943446c536a6639576332336141687769594844764c38574266514f556a794f4554554e51616159414a434c476862622f6357632f4435486e4654554874530d0d0a2f642f6d6f636534633043556232726336717a71744470754753534f39477739684f6d6963486d4f576c6656756830354d52714848433335576f52335171344f0d0d0a5039473446564638616972574834704a4b4c525651646c4d586f5a476c39356767337450436d716b4e694851424e5444535946634571723744327158777764420d0d0a456133524842522f7842556c633451556d64456a7077374c2b4155384f6c4c4a666e754f32357964663770424b55567a5450774f657068657464785a344331370d0d0a324744754e2f657635642b6f78634a7052727764366e513546564e3432724e6b4976436849516d4947466947526e7758552f6835433030484a306c796e4756500d0d0a53526c7a626c6e37737967346653575a61554f544d714535324a4b31447477457473355979416c4b5065385a4446594a34582b69304a304475417472716270720d0d0a366c51574f51636d6b764d655064383652486a356341305742536e43514e562b43586632717a6c763132657243464c6e2f45385a65473764316c66525a4d4f680d0d0a6d7547504334754871746c534d6350557631736152366542466a714f426f415a613251423431724b37544c6665386772587a417a4d30793333686d4d4b726e530d0d0a334d6242392f3576464c7a30506751744d47795330534e793943613058714752754b3230705530774e5a51527a4f426358696b63776d4b67427859563033684a0d0d0a5a74304f30593059506b7762466a42346a33635a5643726761496f6c5653664243587170736e6e4e4b556442566e52394d584766432b655a5955422f72334d2b0d0d0a394f3134544f486e48554773736f6e794346454467315a5a6b395351383069324a4d2b4f644d38447371436d6b776345346d452f4c434b464c4a4e4771534f460d0d0a5545644855726e30456f686d2b4f332f7449643065344a38784d67445243427a6a6e676745623473564b7831695a4532757a4445634c386a63667563344b6f540d0d0a6c624f54646175746d446173624b434c35393868457339475348467a7849576843524444456e526557705447616f687667475a45327961476677686f654e73590d0d0a62504f6a57363776446265584148587337686b7a4e7a424a71536143375a7a32735939412f4e452b3573766463785454433339485631707567634c367759342b0d0d0a433749717977366a61776c437435522b393247534c444b596b5a526473434b5833493868425a572b36506a462f6567464c6367586b776a722b4b464f724135550d0d0a7861535630644d5639675831412f4c6c5a426e33625a494675335373344234554251524c5178594e6e576b34524b4a44737259514e3276342b705956585771630d0d0a457061486e523732525763442b59756377756e687a57702f4773414b4d4c30586e657842386a79454247434735734b47334f2b7641694e572b554e32513176620d0d0a7a5776424a5a47524a4f35374377686b6d785661463832473745476f4c4e757435344565336549565066462b495479416f3668444c4c4e5a535a456e724c325a0d0d0a724e4f67796b437036494f58614a4a4e656c654a47414467726937336e7767504a66534a334e37472f756132717046616e53486846622b726e637258656951480d0d0a3157646f766a736a412b7532675a376267624b575032535256616637666851616a6e4d79696f4e337344376b593234436158434b532f504f34563849377a77480d0d0a4a6c586c3376354e383032544d684e5744764c7455734a31754f63666c39413758584a546b486f753231476468707a646f674531514e455466764e74364d38450d0d0a6959774451697a2b616452574661757731766b72496e446f4a6e58524d4f685054433351676564364b4a54544d2f6435354761426850734b7659454c6e646a560d0d0a41546b6b374d6a547a54557a424b3370373835714f554d67326f5a57656e486a437a735154356266514363717066534e703073472f4b7637683763356a5742300d0d0a504c6b6e50495343304a343462786e324f2f2f384b586848795354516a584c325733713859705332507a3057306b326842326c6333646f676631462f774f39730d0d0a722b38706b4b6b65366932366471433676325961446e5841526a436e3365585276484f3556704e4f5764345a74786f764a483158656f4e6172427a5443574c4d0d0d0a77474f5639356e6765472b324267693064494153546c42542b6c754f4d32662f6c78726c6c476c5a396865342b71667154765a497932774f57774e47543151610d0d0a714861445442443165386e466630327165556a785042377672725956636d6835456f476c6b573449744a3779496f6573526256707a6468726c4d33506d4267330d0d0a7033713442713470614b4c4559487866766b2b7947726666596f68514d3732564b4769596e4f3547797259427356484c34594756384a346858366b48375430300d0d0a2f6a42554e487055495a36637a536b4e2f5169366f2b6258416d7a7444557a687939516271364b796678416e6c4a314b462f687663525157686465364d3641390d0d0a624b4b445733764a4c5763767176384a6e5753326f524e385a7936495278772b76646f73444833494c7149734a2f5951536d647a7172645773684b636b34364c0d0d0a796c676c70462f706e68783038612f4159654339483551674433486f4c45476532746b456147344b4c646132783055453453765377497064626161673752746e0d0d0a684d7a3643492b764f7a4e34394a724761685a735a3735696d616b536d5768684f535a487439723167517948462b4f4771623179715051634943505a383770610d0d0a4531766273726f6c6a61634548357a46415272664b7133723077764b74644373454f4f7766714c46377a662b4c72794279755643724b656838675a414f59582b0d0d0a44776b63676c43517930773247424d4e6c686a58386835654a7073427a3662416b6d616237587a51492b5539577a7277355a76522f526c4859396148396e696f0d0d0a2f754c684637586833344b44543768796961507a6361534c663935795749472b6c386e2b654762466869425367324f58484947366f5a57716f524753684762700d0d0a533330624a51793438454b3477795a7649426b6e31366142515a4b3370623444446671736176616d3774634c6f4a5a74736e706b636375792f34356d4b7043590d0d0a68764b6a5570623275474a305675682f424f74347964314e666269355144454f71312f3043436c33346a4a7a3046386f70563673766b30677578466b57576b550d0d0a764845416b3031514a4139725371626f6446444157422f4d4450344d78696f4a584f545038437a754c434d3064305732646671612b51596365775877546c73720d0d0a33512f4b796d4f357131457333624d5156412f78676875482f585a61784d54754363477a527679796c436978356731516a6e62524c46475449456833513743530d0d0a4a57645a4f5a3477564e7854545a65586733547849583675693552714339774275704947454c2f703638376b4e6e6d476d5a754155614941532f4b4e52776f680d0d0a59316f36336b435149686c3744595757563332715a4d77374730374666564d58743568693037564a4f7844344151576f4b38766e5361513634526e776b6c43570d0d0a4b6f6754484a6569564c6f546c626e386f5657383172335467694542794447394865713542595a784d31767066534c35305071617250736577312f2f44644f410d0d0a344964585357724e366e39627363326d486368774979664d423752753132544169504b6759702b714241564d797164774949593866702f6271374472395543670d0d0a4935463351313131443735783839786f6852567938346a37706d326355537956586a4b5572785a557162707432436861366e77794d365365313430566d50425a0d0d0a5a2f7254776c4f4c4c525a7052666b566b4c767458374e527967744e4e644b754442304b724e486632597956312f6f3577477751476a2b594c335258394634380d0d0a314b7a682b4b5379766e3235716f7978677763536671506d76476374414c4c764545536837686c4456454e517238647747684744506a61774e6c434b706a61380d0d0a6f43464253786775416c466f6332656e3777476b696d44732f2b3173515a5458504e6a51336a503758454e547359697634576c353369664a77456432777174680d0d0a54742b49735147694e742b584a6d305451376954647a503877354b38424b345249754c6b79516962614e4162632f563636492b614b746d77596b31345663516c0d0d0a72654250706a5139536a46516a56336c775452324d74752f4257345048692b674461316d3263546a76634548326b503265392b586478332f735248556a7a54440d0d0a4863416133747330546a364f5044656a47384c794e734734515650656835495536665a64466d446f3531376f7a4e64315a73534c55736448304e442f6b3363500d0d0a47626651614c66713953594b4d65654d42592f315855532f6e444b642f476b5a35735a4e6a6d772b4352306463465132632b5537763478612b344b39534b56300d0d0a42597a7a31616c386e56575470557169572f316e476639667a414f515564485943746c6e70414a6a5a333479453635346153546d6a6f52777042436c347245740d0d0a46704a6b4e6459432f6b6c773650324962307a3533646752656e726c7430636946526258306e2b702f354474687a446f6f43614a654e49383157646538342b700d0d0a48694e6c306d304d2b4a7a5278763243767254486152457776463453515667686347446c47694f51683053302b476935366435475430787135322f473274682b0d0d0a7475334c4748656e4a69776f3255395333585a6c4f54426c64346f2f5969504f33316c41504435675269657750417978356a67696a5755754c344a414f3531750d0d0a6958636c367a4d4c6e697738444b646175615274654a57785471703765552f4d4754746c2b6c664b62354833734d7a362b7058745a533254522f43743862736b0d0d0a674276715a73324550654b6a6e39474364364c4a6144653153372f3162615348647759594b6a66516955413d	0
cb08873f-9adf-4f66-b995-0cb3d0d39b83.ui	2026-09-15 15:05:23	2026-09-15 15:24:47	0	362	\\xefbbbf4d6c3968462b682f526536664f48535141625a4b4e79664438327a77705079724737474344755358574c33455559793879616a5157627a7676636f4c6d4f6a370d0d0a57566e353170616945756c73394a544f456833317345664678574c385347756d6737684e786c697746323376443839676b304c5242444b634a3749685174364b0d0d0a69647436563667444c622b674e592b52465a2f41646167486b593047425662427a4445614178594558536d4c34476b487564486e6a624950714d6874794746360d0d0a3935526476522b6f597a446c79694c6c634a36336f446c6a4f48476c436154756637337479586747543977612b6269786a68466f4d39532b65717262643138700d0d0a39536b497833755879434c3445745459453165364a756162537470514c685558764a36536c37324b706b6242786a377a4b4c4b3854596f6e494d5a4c376c73430d0d0a556c38457146317a6a506c332f594b785a57616858513d3d	0
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

\unrestrict o59Ra1CHaEMenCKXqwly5tcov7UdER4C799mnxsta49YAkNmSi7UC375eYcFV4Q

