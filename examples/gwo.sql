#
# Groupware Organizer PDM (mysql)
#
# '-' - reserved fields
#

create table gworganizer (
        id       varchar(60) primary key,
        idnv     varchar(60),  #   new version (value) pointer
        idpr     varchar(60),  #   previous record pointer
        idrm     varchar(60),  # + reply master pointer
        idrr     varchar(60),  # + reply root pointer
        idpt     varchar(60),  # - point to record
        idlr     varchar(60),  # - location record pointer
        lslote   varchar(60),  # - location slot
        cuser    varchar(60),  #   creator user
        ctime    datetime,     #   created time
        uuser    varchar(60),  #   updator user
        utime    datetime,     #   updated time
        puser    varchar(60),  #   principal user
        prole    varchar(60),  #   principal role
        auser    varchar(60),  #   actor user
        arole    varchar(60),  #   actor role
        aopt     varchar(10),  # - actor options: 'respond', 'see', 'edit'
        rrole    varchar(60),  #   reader role
        mailto   varchar(255), # + mail receipients
        mailtime datetime,     # - mailed time
        status   varchar(10),  #   record status
        progress decimal,      # - progress of the work
        etime    datetime,     #   end time
        stime    datetime,     #   start time
        period   varchar(20),  # + period of record (y, m, d, h)
        record   varchar(10),  #   record type
        object   varchar(60),  #   object name
        doctype  varchar(60),  #   document type
        subject  varchar(255), #   subject, title
        comment  text          #   comment, text
)
# TYPE = BDB  # use mysqld-max, do not use fulltext
;

CREATE INDEX idnv     ON gworganizer (idnv,    etime);
CREATE INDEX idpr     ON gworganizer (idpr,    etime);
CREATE INDEX idrm     ON gworganizer (idrm,    etime);
CREATE INDEX idrr     ON gworganizer (idrr,    etime);
CREATE INDEX record   ON gworganizer (record,  etime);
CREATE INDEX object   ON gworganizer (object,  etime);
CREATE INDEX doctype  ON gworganizer (doctype, etime);
CREATE INDEX auser    ON gworganizer (auser,   etime);
CREATE INDEX arole    ON gworganizer (arole,   etime);
CREATE FULLTEXT INDEX ftext ON gworganizer 
                     (object,doctype,subject,comment);

