#!perl -w
#
# admiral 
# 19/01/2002
#
# 

package CGI::Bus::lngbase::CGI_Bus_tm; # Language base
use strict;


1;

sub lngbase {
 (-lgn=>['Login',  'Login to the System']
 ,-nap=>['Top',    'The topmost level']
 ,-nup=>['Up',     'An upper level']
 ,-nth=>['This',   'This application hyperlink']
 ,-bck=>['Back',   'Back to previous screen']
 ,-lst=>['List',   'List records under query condition']
 ,-lsr=>['List',   'List records']
 ,-qry=>['Query',  'Query condition to list records by']
 ,-crt=>['New',    'New record creation to insert it to the database']
 ,-sel=>['Select', '(Re)read data from database, select record']
 ,-edt=>['Edit',   'Edit mode toggle']
 ,-frm=>['Form',   'Form reload and review, data recalculation']
 ,-upd=>['Update', 'Update this record in the database, save changes of this record']
 ,-del=>['Delete', 'Delete this record from the database']
 ,-ins=>['Insert', 'Insert new record into database']
 ,-hlp=>['Help',   'Open Help screen']

 ,'op!let'  => ['',       'Operation \'$_\' is not allowed']
 ,'!constr' => ['',       'Constraint violations']

 ,'Help'     =>['Help',         '']
 ,'Lists'    =>['Views (Lists)','Views (Lists of records) defined by application']
 ,'Fields'   =>['Fields',       'Data fields defined by application']
 ,'Commands' =>['Commands',     'Commands may be used']
 )
}

