#!perl
#
# Install cgi-bus database
#

my $MySQLbin='c:/mysql/bin/';  # where is MySQL, while scripts are in the current dir
my $MySQLupw='-u root';        # '-u root -ppassword'

run("${MySQLbin}mysqladmin -v -u $MySQLupw create cgibus");
run("${MySQLbin}mysql -v $MySQLupw cgibus <adduser.sql");
run("${MySQLbin}mysql -v $MySQLupw cgibus <gwo.sql");
run("${MySQLbin}mysql -v $MySQLupw cgibus <notes.sql");
run("${MySQLbin}mysql -v $MySQLupw cgibus <notes-u01.sql");
run("${MySQLbin}mysql -v $MySQLupw cgibus <gwo-u01.sql");


sub run {
 print '->',join(' ',@_), "\n";
 system(@_);
 my $r =$?>>8;
 warn("->Retcode '$r'") if $r;
 !$r;
}
