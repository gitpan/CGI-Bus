  DROP   INDEX idnv     ON gworganizer;
  CREATE INDEX idnv     ON gworganizer (idnv,    etime, utime);

##DROP   INDEX idnv_st  ON gworganizer;
##CREATE INDEX idnv_st  ON gworganizer (idnv,    status, etime);
# DROP   INDEX status   ON gworganizer;
# CREATE INDEX status   ON gworganizer (status,  idnv,   etime);

  DROP   INDEX idpr     ON gworganizer;
  CREATE INDEX idpr     ON gworganizer (idpr,    etime, utime);
  DROP   INDEX idrm     ON gworganizer;
  CREATE INDEX idrm     ON gworganizer (idrm,    etime, utime);
  DROP   INDEX idrr     ON gworganizer;
  CREATE INDEX idrr     ON gworganizer (idrr,    etime, utime);
  DROP   INDEX record   ON gworganizer;
  CREATE INDEX record   ON gworganizer (record,  etime, utime);
  DROP   INDEX object   ON gworganizer;
  CREATE INDEX object   ON gworganizer (object,  etime, utime);
  DROP   INDEX doctype  ON gworganizer;
  CREATE INDEX doctype  ON gworganizer (doctype, etime, utime);
  DROP   INDEX auser    ON gworganizer;
  CREATE INDEX auser    ON gworganizer (auser,   etime, utime);
  DROP   INDEX arole    ON gworganizer;
  CREATE INDEX arole    ON gworganizer (arole,   etime, utime);

# DROP   INDEX uuser    ON gworganizer;
# CREATE INDEX uuser    ON gworganizer (uuser,   etime, utime);
# DROP   INDEX cuser    ON gworganizer;
# CREATE INDEX cuser    ON gworganizer (cuser,   etime, utime);
# DROP   INDEX rrole    ON gworganizer;
# CREATE INDEX rrole    ON gworganizer (rrole,   etime, utime);

  DROP   INDEX ftext    ON gworganizer;
##CREATE FULLTEXT INDEX ftext ON gworganizer(object,doctype,subject,comment);
