#!perl -w
#
# Login, User Authentication
#
#<Location /cgi-bin/cgi-bus/uauth.cgi>
#    AuthType NTLM 
#    NTLMAuth On 
#    NTLMAuthoritative On 
#    NTLMOfferBasic On  
#    require valid-user  
#</Location>
#
use vars qw($s);
 $s =do("config.pl");
 $s->set(-login=>undef);               # login script is this script
 $s->uauth->authscr();                 # web server  authentication login screen
#$s->uauth->loginscr();                # application authentication login screen

