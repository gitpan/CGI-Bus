  DROP   INDEX idnv     ON notes;
  CREATE INDEX idnv     ON notes (idnv,    utime desc,  ctime desc);

##DROP   INDEX idnv_st  ON notes;
##CREATE INDEX idnv_st  ON notes (idnv,    status, utime desc, ctime desc);
##DROP   INDEX utime    ON notes;
##CREATE INDEX utime    ON notes (utime desc,  ctime desc);

  DROP   INDEX idrm     ON notes;
  CREATE INDEX idrm     ON notes (idrm,    utime desc,  ctime desc);
  DROP   INDEX cuser    ON notes;
  CREATE INDEX cuser    ON notes (cuser,   utime desc,  ctime desc);
  DROP   INDEX uuser    ON notes;
  CREATE INDEX uuser    ON notes (uuser,   utime desc,  ctime desc);
  DROP   INDEX prole    ON notes;
  CREATE INDEX prole    ON notes (prole,   utime desc,  ctime desc);
  DROP   INDEX rrole    ON notes;
  CREATE INDEX rrole    ON notes (rrole,   utime desc,  ctime desc);
  DROP   INDEX subject  ON notes;
  CREATE INDEX subject  ON notes (subject, utime desc,  ctime desc);

  DROP   INDEX ftext    ON notes;
##CREATE FULLTEXT INDEX ftext ON notes (subject, comment);