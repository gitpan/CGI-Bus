#
# Notes PDM (mysql)
#
# '-' - reserved fields
#

create table notes (
        id       varchar(60) primary key,
        idnv     varchar(60),  #   new version (value) pointer
        idpr     varchar(60),  #   previous record pointer
        idrm     varchar(60),  #   reply master pointer
        cuser    varchar(60),  #   creator user
        ctime    datetime,     #   created time
        uuser    varchar(60),  #   updator user
        utime    datetime,     #   updated time
        prole    varchar(60),  #   principal role
        rrole    varchar(60),  #   reader role
        status   varchar(10),  #   record status
        record   varchar(10),  # - record type
        object   varchar(60),  # - object name
        doctype  varchar(60),  # - document type
        subject  varchar(255), #   subject, title
        comment  text          #   comment, text
)
# TYPE = BDB  # use mysqld-max, do not use fulltext
;

CREATE INDEX idnv     ON notes (idnv,    utime);
CREATE INDEX idrm     ON notes (idrm,    utime);
CREATE INDEX cuser    ON notes (cuser,   utime);
CREATE INDEX uuser    ON notes (uuser,   utime);
CREATE INDEX prole    ON notes (prole,   utime);
CREATE INDEX rrole    ON notes (rrole,   utime);
CREATE INDEX subject  ON notes (subject, utime);

CREATE FULLTEXT INDEX ftext ON notes 
                     (subject,comment);

