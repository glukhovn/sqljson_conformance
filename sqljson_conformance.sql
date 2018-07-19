SET SESSION sql_mode = concat(@@SESSION.sql_mode, ',NO_BACKSLASH_ESCAPES'); -- for MySQL only !!!

CREATE TABLE house(js VARCHAR(1000));

INSERT INTO house(js) VALUES ('
{
  "info": {
    "contacts": "Postgres Professional\n+7 (495) 150-06-91\ninfo@postgrespro.ru",
    "dates": ["01-02-2015", "04-10-1957 19:28:34 +00", "12-04-1961 09:07:00 +03"]
  },
  "address": {
    "country": "Russia",
    "city": "Moscow",
    "street": "117036, Dmitriya Ulyanova, 7A"
  },
  "lift": false,
  "floor": [
    {
      "level": 1,
      "apt": [
        {"no": 1, "area": 40, "rooms": 1},
        {"no": 2, "area": 80, "rooms": 3},
        {"no": 3, "area": null, "rooms": 2}
      ]
    },
    {
      "level": 2,
      "apt": [
        {"no": 4, "area": 100, "rooms": 3},
        {"no": 5, "area": 60, "rooms": 2}
      ]
    }
  ]
}
');

-- JSON_OBJECT(k : v)
SELECT JSON_OBJECT('a': 2 + 3, 'b': 'ccc', 'c': NULL) FROM house;

-- JSON_OBJECT(KEY k VALUE v)
SELECT JSON_OBJECT(KEY 'a' VALUE 2 + 3, KEY 'b' VALUE 'ccc', KEY 'c' VALUE NULL) FROM house;

-- JSON_OBJECT(k VALUE v)
SELECT JSON_OBJECT('a' VALUE 2 + 3, 'b' VALUE 'ccc', 'c' VALUE NULL) FROM house;

-- JSON_OBJECT(k, v)
SELECT JSON_OBJECT('a', 2 + 3, 'b', 'ccc', 'c', NULL) FROM house;

-- JSON_OBJECT(WITH UNIQUE KEYS)
SELECT JSON_OBJECT('a' VALUE 1, 'a' VALUE 2 WITH UNIQUE KEYS) FROM house;

-- JSON_OBJECT(WITHOUT UNIQUE KEYS)
SELECT JSON_OBJECT('a' VALUE 1, 'a' VALUE 2 WITHOUT UNIQUE KEYS) FROM house;

-- JSON_OBJECT(ABSENT ON NULL)
SELECT JSON_OBJECT('a' VALUE 1, 'b' VALUE NULL ABSENT ON NULL) FROM house;

-- JSON_OBJECT(NULL ON NULL)
SELECT JSON_OBJECT('a' VALUE 1, 'b' VALUE NULL NULL ON NULL) FROM house;


-- JSON_ARRAY()
SELECT JSON_ARRAY('a', 2 + 3, NULL, 'c') FROM house;

-- JSON_ARRAY(ABSENT ON NULL)
SELECT JSON_ARRAY('a', 2 + 3, NULL, 'c' ABSENT ON NULL) FROM house;

-- JSON_ARRAY(NULL ON NULL)
SELECT JSON_ARRAY('a', 2 + 3, NULL, 'c' ABSENT ON NULL) FROM house;

-- JSON_ARRAY(subquery)
SELECT JSON_ARRAY(SELECT 123 FROM house) FROM house;


-- JSON_OBJECTAGG()
SELECT JSON_OBJECTAGG('a' VALUE 2 + 3) FROM house;

-- JSON_ARRAYAGG()
SELECT JSON_ARRAYAGG('a') FROM house;


-- JSON_<CTOR>(RETURNING type)
SELECT JSON_ARRAY('a', 1 RETURNING char(20)) FROM house;

-- JSON_<CTOR>(RETURNING type FORMAT JSON)
SELECT JSON_ARRAY('a', 1 RETURNING char(20) FORMAT JSON) FROM house;

-- JSON_<CTOR>(RETURNING type FORMAT JSON ENCODING UTF8)
SELECT JSON_ARRAY('a', 1 RETURNING char(20) FORMAT JSON ENCODING UTF8) FROM house;


-- FORMAT JSON
SELECT JSON_ARRAY('1', '1' FORMAT JSON) FROM house;
SELECT JSON_ARRAY('1', 'err' FORMAT JSON) FROM house;


-- IS JSON
SELECT js IS JSON FROM house;
SELECT js IS NOT JSON FROM house;

-- IS JSON in WHERE
SELECT 1 FROM house WHERE js IS JSON;
SELECT 1 FROM house WHERE js IS NOT JSON;

-- IS JSON <type>
SELECT 1 FROM house WHERE js IS JSON OBJECT;
SELECT 1 FROM house WHERE js IS JSON ARRAY;
SELECT 1 FROM house WHERE js IS JSON SCALAR;


-- JSON_EXISTS()
SELECT JSON_EXISTS(js, '$.info') FROM house;

-- JSON_EXISTS() in WHERE
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.info');

-- JSON_EXISTS(ON ERROR)
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.info' TRUE ON ERROR);
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.info' FALSE ON ERROR);
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.info' UNKNOWN ON ERROR);
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.info' ERROR ON ERROR);


-- JSON_VALUE()
SELECT JSON_VALUE(js, '$.address.street') FROM house;

-- JSON_VALUE(RETURNING)
SELECT JSON_VALUE(js, '$.floor[1].level' RETURNING int) FROM house;
SELECT JSON_VALUE(js, '$.floor[1].level' RETURNING number) FROM house;
SELECT JSON_VALUE(js, '$.floor[1].level' RETURNING char(10)) FROM house;
SELECT JSON_VALUE(js, '$.floor[1].level' RETURNING varchar2(10)) FROM house;

-- JSON_VALUE(ON EMPTY/ERROR)
SELECT JSON_VALUE(js, '$.foo' ERROR ON EMPTY) FROM house;
SELECT JSON_VALUE(js, '$.foo' ERROR ON EMPTY ERROR ON ERROR) FROM house;
SELECT JSON_VALUE(js, '$.foo' NULL ON EMPTY) FROM house;
SELECT JSON_VALUE(js, '$.foo' DEFAULT 'aaa' ON EMPTY) FROM house;
SELECT JSON_VALUE(js, '$.foo' DEFAULT 123 ON EMPTY) FROM house;

-- JSON_VALUE(DEFAULT ON ..)
SELECT JSON_VALUE(js, '$.foo' DEFAULT 'aaa' ON EMPTY) FROM house;
SELECT JSON_VALUE(js, '$.foo' DEFAULT 123 ON EMPTY) FROM house;

-- JSON path strict/lax
SELECT JSON_VALUE(js, 'strict $.foo') FROM house;
SELECT JSON_VALUE(js, 'strict $.foo' ERROR ON ERROR) FROM house;
SELECT JSON_VALUE(js, 'lax $.foo') FROM house;
SELECT JSON_VALUE(js, 'lax $.foo' ERROR ON ERROR) FROM house;

-- JSON_QUERY()
SELECT JSON_QUERY(js, '$.address') FROM house;

-- JSON_QUERY(WITH WRAPPER)
SELECT JSON_QUERY(js, '$.address.city' WITH WRAPPER) FROM house;
SELECT JSON_QUERY(js, '$.address.city' WITHOUT WRAPPER) FROM house;
SELECT JSON_QUERY(js, '$.address.city' WITH CONDITIONAL WRAPPER) FROM house;
SELECT JSON_QUERY(js, '$.floor[*].apt[*].no' WITH WRAPPER) FROM house;


-- JSON_TABLE

-- PostgreSQL
SELECT
  jt.*
FROM
  house,
  JSON_TABLE(js, '$.floor[*]' COLUMNS (
    "level" int,
    num_apt int PATH '$.apt.size()', 
    apts jsonb FORMAT JSON PATH '$.apt'
  )) jt;
  
-- Oracle
SELECT
  jt.*
FROM
  house,
  JSON_TABLE(js, '$.floor[*]' COLUMNS (
    "level" number,
    num_apt number PATH '$.apt.size()', 
    apts varchar2 FORMAT JSON PATH '$.apt'
  )) jt;

-- MySQL
SELECT
  jt.*
FROM
  house,
  JSON_TABLE(js, '$.floor[*]' COLUMNS (
    "level" int PATH "$.level",
--  num_apt number PATH '$.apt.size()',
    apts JSON PATH '$.apt'
  )) jt;



-- JSON_TABLE nested columns

-- PostgreSQL
SELECT
  jt.*
FROM
  house,
  JSON_TABLE(js, '$.floor[*]' COLUMNS (
    "level" int,
    NESTED PATH '$.apt[*]' COLUMNS (
      "no" int,
      area float,
      rooms int
    )
  )) jt;

-- Oracle
SELECT
  jt.*
FROM
  house,
  JSON_TABLE(js, '$.floor[*]' COLUMNS (
    "level" number,
    NESTED PATH '$.apt[*]' COLUMNS (
      "no" number,
      area number,
      rooms number
    )
  )) jt;

-- MySQL
SELECT
  jt.*
FROM
  house,
  JSON_TABLE(js, '$.floor[*]' COLUMNS (
    "level" int PATH "$.level",
    NESTED PATH '$.apt[*]' COLUMNS (
      "no" int PATH "$.no",
      area float PATH "$.area",
      rooms int PATH "$.rooms"
    )
  )) jt;

-- JSON_TABLE plans

-- PostgreSQL
SELECT
  jt.*
FROM
  house,
  JSON_TABLE(js, '$.floor[*]' AS floor COLUMNS (
    "level" int,
    NESTED PATH '$.apt[*]' AS apt1 COLUMNS (
      no1 int PATH '$.no'
    ),
    NESTED PATH '$.apt[*]' AS apt2 COLUMNS (
      no2 int PATH '$.no'
    )
  ) PLAN DEFAULT (CROSS)) jt;


-- JSON path

-- JSON path filters
SELECT JSON_VALUE(js, '$.floor[*].apt[*].no ? (@ == 3)') FROM house;
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.floor[*].apt[*].no ? (@ == 3)');
SELECT JSON_EXTRACT(js, '$.floor[*].apt[*].no ? (@ == 3)') FROM house; -- MySQL variant

-- JSON path .*
SELECT JSON_QUERY(js, '$.info.*' WITH WRAPPER) FROM house;
SELECT JSON_EXTRACT(js, '$.info.*') FROM house; -- MySQL variant

-- JSON path [*]
SELECT JSON_QUERY(js, '$.floor[*].apt[*]' WITH WRAPPER) FROM house;
SELECT JSON_EXTRACT(js, '$.floor[*].apt[*]') FROM house; -- MySQL variant

-- JSON path [x, y]
SELECT JSON_QUERY(js, '$.floor[0, 1].apt[1, 2]' WITH WRAPPER) FROM house;
SELECT JSON_EXTRACT(js, "$.floor[0, 1].apt[1, 2]") FROM house; -- MySQL variant

-- JSON path [x to y]
SELECT JSON_QUERY(js, "$.floor[0 to 1].apt[1 to 2]" WITH WRAPPER) FROM house;
SELECT JSON_EXTRACT(js, "$.floor[0 to 1].apt[1 to 2]") FROM house; -- MySQL variant

-- JSON path [last]
SELECT JSON_QUERY(js, '$.floor[last].apt[last - 1]' WITH WRAPPER) FROM house;
SELECT JSON_EXTRACT(js, '$.floor[last].apt[last - 1]') FROM house; -- MySQL variant

-- JSON path [expr]
SELECT JSON_QUERY(js, '$.floor[0 + 1].apt[0 / 2]' WITH WRAPPER) FROM house;
SELECT JSON_EXTRACT(js, '$.floor[0 + 1].apt[0 / 2]') FROM house; -- MySQL variant

-- JSON path arithmetic expressions
SELECT JSON_VALUE(js, '$.floor[0 + 1].apt[0].no + 100' WITH WRAPPER) FROM house;
SELECT JSON_EXTRACT(js, '$.floor[0 + 1].apt[0].no + 100') FROM house; -- MySQL variant

-- JSON path starts_with
SELECT JSON_VALUE(js, '$.address.city ? (@ starts with "Mo")') FROM house;
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.address ? (@.city starts with "Mo")');
SELECT JSON_EXTRACT(js, '$.address.city ? (@ starts with "Mo")') FROM house; -- MySQL variant

-- JSON path like_regex
SELECT JSON_VALUE(js, '$.address.city ? (@ like_regex "^Mo.[abc]")') FROM house;
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.address.city ? (@ like_regex "^Mo.[abc]")');
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.address.city ? (@ like_regex "^mo.[abc]" flag "i")');
SELECT JSON_EXTRACT(js, '$.address.city ? (@ like_regex "^Mo.[abc]")') FROM house; -- MySQL variant

-- JSON path item methods
SELECT JSON_VALUE(js, '$.floor[0].apt.size()') FROM house;
SELECT JSON_VALUE(js, '$.floor[0].apt.size().size()') FROM house;
SELECT JSON_EXTRACT(js, '$.floor[0].apt.size()') FROM house; -- MySQL variant

-- JSON path PASSING parameters
SELECT JSON_VALUE(js, '$x' PASSING 123 AS "x") FROM house;
SELECT 1 FROM house WHERE JSON_EXISTS(js, '$.floor[*] ? (@.level > $lev)' PASSING 1 AS "lev");
