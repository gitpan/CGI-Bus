#!perl -w
#
#
BEGIN {}
#
# Common configuration for all CGI::Bus applications
#
# use findgrp.exe on WinNT !!!
#
use CGI::Bus;
use vars qw($s);
$s =CGI::Bus->new($s);

 $ENV{COMPUTERNAME} =eval{Win32::NodeName()} if $^O eq 'MSWin32' 
                                            and !$ENV{COMPUTERNAME};

 $s->set  (-tpath => 'c:/tmp/cgi-bus'           # temporary files path
          ,-iurl  => '/icons'                   # apache images
          ,-dpath => 'c:/Srv/Apache/cgi-bus');  # data files path
 $s->udata(-path=>$s->dpath('udata'));          # users data path

 $s->set  (-ppath => undef                      # publish path, unused yet
          ,-purl  => undef);                    # publish URL, unused yet

 $s->set  (-fpath => 'c:/Share/app/cgi-bus'     # files attachments path, may be -ppath
          ,-furf  => 'file://' .($ENV{COMPUTERNAME} ||$s->server_name) .'/share/app/cgi-bus');
 $s->set  (-furl  => $s->furf);                 # files attachments URL

 $s->set  (-hpath => 'c:/Share/users'           # users home dirs path
          ,-hurf  =>                            # home  dirs filesystem URL
                     'file://' .($ENV{COMPUTERNAME} ||$s->server_name) .'/users');
 $s->set  (-hurl  => '/users');                 # home  dirs URL

#$s->set  (-urfcnd=>                            # filesystem URLs usage condition
#                    sub{$ENV{REMOTE_ADDR} =~/^(127|10)\./});

#$s->set  (-login=>$s->burl('a/uauth.cgi'));    # login script
#$s->set  (-login=>$s->surl('cgi-bin/ntlm/cgi-bus/'));
 $s->set  (-login=>$s->surl('cgi-bin/cgi-bus/a/'));

 $s->set  (-usercnv=>sub{lc($_[0]->usercn($_))} # user names conversion
        # ,-ugrpcnv=>sub{$_[0]->usercn($_)}     # group names conversion
          ,-uadmins=>[]                         # admin users
          );

 $s->set(-debug  =>1);                          # debug switch
#$s->set(-pushlog=>$s->tpath('pushlog.txt'));   # log file

 $s->set  (-import=>                            # DBI connect code
                     {-dbi => sub{$s->dbi("DBI:mysql:cgibus","cgibus","d95nfmJR971Yv3gVI40")}});

$s->set(-httpheader=>{                          # common http header
          -charset        => 'windows-1251'
       # ,'-cache-control'=> 'no-cache'         # must-revalidate, max-age=sss
         ,-expires        => 'now'
       }
       ,-htmlstart=>{                           # common & default html header
          -head  => '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">'
       # ,-lang  => 'ru-RU'
         ,-title => $s->server_name()
       }
       ,-htpnstart=>{                           # navigator pane html header
          -BGCOLOR => '#C0D9D9'
       }
       ,-htpgstart=>{                           # pages and lists html header
          -BGCOLOR => '#FFF5EE'
       }
       ,-htpfstart=>{                           # form pages html header
          -BGCOLOR => '#FFF5EE'
       }
       );


$s;                                             # return application object
