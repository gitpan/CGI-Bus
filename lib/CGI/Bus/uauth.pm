#!perl -w
#
# CGI::Bus::uauth - User Authentication Base Class
#
# admiral 
#
# 

package CGI::Bus::uauth;
require 5.000;
use strict;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Bus::Base;
use vars qw(@ISA);
@ISA =qw(CGI::Bus::Base);


my $cooknme ='_cgi_bus_uauth';
my $guest   ='guest';
my $w32afg  =0; # 0 - findgrp, 1 - adsi, 2 - win32api::net
my $w32afl  =0; # 0 - findgrp, 1 - adsi, 2 - win32api::net


if ($ENV{MOD_PERL}) {
   eval('use Apache qw(exit);');
}


1;



#######################

sub adsi {    # Win2000 ADSI object
 my $s =shift;
 eval('use Win32::OLE');
 Win32::OLE->GetObject(@_)
}


sub usdomain {# User names Server Domain
 my $s =shift;
 ($^O eq 'MSWin32' 
 ? ( eval('use Win32::TieRegistry; $Registry->{\'LMachine\\\\SOFTWARE\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\\\\\\\\CachePrimaryDomain\'} || $Registry->{\'LMachine\\\\SOFTWARE\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\\\\\\\\DefaultDomainName\'}')
   ||eval('use Win32; Win32::DomainName()'))
 : '')
 || ($s->surl =~/^[^\/\.]+[\/]+w*\.*([^\/]+)/i ? $1 : '')
}


sub userver { # User names Server
 my $s =shift;
 if ($^O eq 'MSWin32') {
    eval('use Win32; use Win32API::Net');
    my $hn =$ENV{COMPUTERNAME} || eval{Win32::NodeName()};
    my $dc ='';
    eval {Win32API::Net::GetDCName($hn,$s->parent->usdomain,$dc)};
    $dc ||$hn ||''
 }
 else {
    eval ('use Sys::Hostname; Sys::Hostname')
 }
}


sub user {    # User name
 my $s =shift;
 my $u =
   ($_[0] || $ENV{REMOTE_USER} || $ENV{AUTH_USER}
    ||($ENV{CERT_SUBJECT} ? ($ENV{CERT_SUBJECT} .'/' .$ENV{CERT_ISSUER}) : '')
    ||$s->signchk ||$guest);
 $u
}


sub guest {   # Guest name
 $guest
}


sub ugroups { # User groups
 my $s =shift;
 my $u =[];
 return($u) if !$s->parent->user;
 if ($s->{-AuthGroupFile}) {
    foreach my $g ($s->parent->fut->fread('-a',$s->{-AuthGroupFile})) {
       next if $g !~/\b\Q$g\E\b/;
       push @$u, $g;
    }
 }
 elsif ($s->{-udata}) {
    $u =$s->parent->udata->param('uauth_groups') ||[]
 }
 elsif ($^O eq 'MSWin32') {
    my ($n, $d, $h, $f, $gd, $a, $ad, $au, @g);
    $n =$s->parent->useron ||$s->parent->user;
    $d =$s->parent->usdomain;
    $h =$ENV{COMPUTERNAME} || ($ENV{COMPUTERNAME} =eval{Win32::NodeName()});
    $h =$h ? "\\\\$h" : $d;
    $n ="$d\\$n" if index($n,'\\') <0;
    $f =($n =~/^$d\\/i ? '/q' : '');
    $gd=(!$f && $n =~/^([^\\]+)/ ? $1 : '');
    if ($n =~/([^\\]+)\\([^\\]+)/) {$ad =$1, $au =$2} else {$ad =$d; $au =$n}
    if (0) {}
    elsif (!$s->{-adsi} && $w32afg <1 && scalar((@g =`findgrp.exe $h $n $f`))) { 
     # !!! Command above is from Windows Resource Kit !!!
     # $s->pushmsg("ugroups via findgrp.exe '$n','$d','$f'");
       my $gd1;
       foreach my $v (@g) {
          next if !$v || $v =~/^\s*$/;
          if ($v =~/^[^\s]/) {
             $gd1 =$gd if !$f && $v=~/^User\s/i && $v=~/\sGlobal\s/i;
             next;
          }
          $v =$1 if $v =~/^[\s]*([^\n]+)/;         
          push @$u, $gd1 ? "$gd1\\$v" : $v
       }
    }
    elsif ($s->{-adsi} && $w32afg <2 && [Win32::GetOSVersion()]->[1]>=5
     &&($a =$s->adsi("WinNT://$ad/$au,user"))) {
     # !!! non recursive group membership !!!
     # !!! local groups for user from trusted domain !!!
     # $s->pushmsg('ugroups via adsi');
       $w32afg =1;
       foreach my $e (Win32::OLE::in($a->Groups)) {push @$u, $gd ? "$gd\\" .$e->{Name} : $e->{Name}}
    }
    else {
     # !!! failure Win32API::Net::UserGetGroups
     # $s->pushmsg("ugroups via Win32API::Net");
       $w32afg =2;
       my %g;
       my $srv =$ENV{COMPUTERNAME} ||eval{Win32::NodeName()};
       eval('use Win32API::Net');
       return $u if $@;
       if (Win32API::Net::UserGetGroups($s->parent->userver, $n, \@g)) {
          $gd ? (map {$g{"$gd\\$_"} =1} @g) : (map {$g{$_} =1} @g)
       } else { 
          $s->pushmsg("Win32API::Net::UserGetGroups('" .$s->parent->userver ."', '$n')-> " .Win32::GetLastError() ." $^E");
       }
       if (Win32API::Net::UserGetLocalGroups($srv, $n, \@g, Win32API::Net::LG_INCLUDE_INDIRECT())) {
          map {$g{$_} =1} @g 
       } else { 
          $s->pushmsg("Win32API::Net::UserGetLocalGroups('$srv', '$n')-> " .Win32::GetLastError() ." $^E");
       }
       delete $g{'None'};
       $u =[sort {lc($a) cmp lc($b)} keys(%g)];
    }
 }
 else {
 }
 $u
}


sub uglist {  # User & Group List
 my $s =shift;
 my $o =defined($_[0]) && substr($_[0],0,1) eq '-' ? shift : '-ug';
 my $r =shift ||[];
 my $a;
 if ($s->{-AuthUserFile} ||$s->{-AuthGroupFile}) {
    my @r;
    map {push @r, $1 if /^([^:]+):/}
        $s->parent->fut->fread('-a',$s->{-AuthUserFile})
        if $s->{-AuthUserFile} && $o =~/u/;
    map {push @r, $1 if /^([^:]+):/}
        $s->parent->fut->fread('-a',$s->{-AuthGroupFile})
        if $s->{-AuthGroupFile} && $o =~/g/;
    $r =ref($r) eq 'HASH'
       ? {map {($_ => $_)} @r}
       : [@r]
 }
 elsif ($s->{-udata}) {
    my $l =$s->parent->udata->uglist;
    $r =ref($r) eq 'HASH'
       ? {map {($_ => $_)} @$l}
       : $l
 }
 elsif ($^O eq 'MSWin32' && $s->{-adsi}
     && $w32afl <2 && [Win32::GetOSVersion()]->[1]>=5 
     &&($a =$s->adsi('WinNT://' .$s->parent->usdomain .',domain'))) {
    $a->{Filter} =['User','Group'];
    if (ref($r) eq 'ARRAY') {
       foreach my $e (Win32::OLE::in($a)) {
         next if $e->{Class} eq 'User' ? $o !~/u/ : $e->{Class} eq 'Group' ? $o !~/g/ : 1;
         push(@$r, $e->{Name});
       }
    }
    else {
       my $l;
       foreach my $e (Win32::OLE::in($a)) {
         if    ($e->{Class} eq 'User')  {next if $o !~/u/; $l =$e->{FullName} ||$e->{Description} ||''}
         elsif ($e->{Class} eq 'Group') {next if $o !~/g/; $l =$e->{Description} ||''}
         else  {next}
         $r->{$e->{Name}} =$e->{Name} .($l ? ', ' .$l :'');
       }
    }
 }
 elsif ($^O eq 'MSWin32') {
    $w32afl =2;
    eval("use Win32API::Net");
    return $r if $@;
    my $srv =$s->parent->userver;
    my @g;    
    my %i;
    my $l;
    if ($o =~/g/ && Win32API::Net::GroupEnum($srv, \@g)) {
       if (ref($r) eq 'ARRAY') {
          push(@$r, @g) 
       }
       else {
          foreach my $g (@g) {
             %i =() if !Win32API::Net::GroupGetInfo($srv,$g,1,\%i);
             $l =$i{comment} ||'';
             $r->{$g} =$g .($l ? ', ' .$l :'');
          }
       }
    }
    if ($o =~/g/ && Win32API::Net::LocalGroupEnum($srv, \@g)) {
       if (ref($r) eq 'ARRAY') {
          push(@$r, @g)
       }
       else {
          foreach my $g (@g) {
             %i =() if !Win32API::Net::LocalGroupGetInfo($srv,$g,1,\%i);
             $l =$i{comment} ||'';
             $r->{$g} =$g .($l ? ', ' .$l :'');
          }
       }
    }
    if ($o =~/u/ && Win32API::Net::UserEnum($srv, \@g)) {
       if (ref($r) eq 'ARRAY') {
          push(@$r, @g)
       }
       else {
          foreach my $g (@g) {
             %i =() if !Win32API::Net::UserGetInfo($srv,$g,10,\%i);
             $l =$i{fullName} || $i{usrComment} ||$i{comment} ||'';
             $r->{$g} =$g .($l ? ', ' .$l :'');
          }
       }
    }
 }
 else {
 }
 $r =[sort {lc($a) cmp lc($b)} @$r] if ref($r) eq 'ARRAY';
 $r
}



sub auth {    # Authenticate User
 my $s =shift;
 my $m =shift if ref($_[0]); # auth methods
                             # redirect url
 if ($s->parent->uguest && ($s->{-login}||$s->parent->set('-login'))) {
    my $l =$s->{-login}||$s->parent->set('-login');
    if ($l =~/\/$/) {
       $l.=($s->qurl =~m{/([^/]+)$} ? $1 : '') .($ENV{QUERY_STRING} ? ('?' .$ENV{QUERY_STRING}) :'');
    }
    else {
       $l =$s->parent->htmlurl($l,$cooknme,$s->url .($ENV{QUERY_STRING} ? ('?' .$ENV{QUERY_STRING}) :''));
    }
    my @p =(-uri=>$l);
    push @p, (-nph=>1) if ($ENV{SERVER_SOFTWARE}||'') =~/IIS/
                       || ($ENV{MOD_PERL} && !$ENV{PERL_SEND_HEADER}) # PerlSendHeader Off
                       ;
    $s->parent->print->redirect(@p);
    eval{$s->parent->reset};
    exit;
 }
 if (($ENV{SERVER_SOFTWARE}||'') =~/IIS/) {
    if    ($s->signchk)        {}
    elsif ($s->parent->uguest) {
       # 401 Access Denied
       # WWW-Authenticate: NTLM
       # WWW-Authenticate: Basic realm="194.1.1.32"
         push @$m, 'NTLM';
         push @$m, 'Basic realm="' .$s->surl .'"';
         print $s->cgi->header( #-nph=>1,
            -status=>'401 Access Denied'
          , -WWW_Authenticate => $m->[0] # [@m]
          , -Error =>'Authentication Required');
       # print "Status: 401 Access Denied\r\n";
       # print join("\r\n", map {'www-authenticate: ' .$_} @$m);
       # print "\r\nContent-Type: text/html; charset=ISO-8859-1\r\n";
       # print "error: Authentication Required\r\n\r\n";
         eval{$s->parent->reset};
         exit;
    }
    elsif (!$s->parent->uguest) {
       $s->signset(@_);
    }
 }
 elsif (!$s->parent->uguest && !$s->signchk) {
    $s->signset(@_);
 }
 $s->parent->user
}


sub _signrand { # generate a random key
 my $c =$_[1] || 32;
 my @a =('.', '/', 0..9, 'A'..'Z', 'a'..'z');
 my $r ='';
 for (my $i =0; $i <$c; $i ++) {$r .=$a[rand(64)]}
 $r
}


sub _signmk {   # generate auth cookie data
 my ($s,$k) =(shift,shift);
 my $m =$s->{-digest} ||'MD5';
 eval('use Digest');
 return '' if $@;
 [@_[0..2], Digest->new($m)->add(
      Digest->new($m)->add($k .':' .join("\t", @_[0..2]))->hexdigest
      .':' .$k)->hexdigest]
}


sub signget {   # Get authentication cookie
 my $s =shift;
 my $c =[$s->cgi->cookie($cooknme)];
 return undef if !scalar(@$c) ||!defined($c->[0]) ||$c->[0] eq '';
 $c
}


sub signchk {   # Check authentication
 my $s =shift;
 my $c =$s->signget;
 return '' if !$c;
 my $u =$c->[0]; $s->die("Invalid authentication cookie user\n") if !$u;
 my $a =$c->[1]; $s->die("Invalid authentication cookie address\n") if $ENV{REMOTE_ADDR} && $a ne $ENV{REMOTE_ADDR};
 my $t =$c->[2]; $s->die("Invalid authentication cookie time\n") if !$t;
 $s->parent->udata->unload;
 $s->parent->user($u);
 my $d =$s->udata->param('-ses');
 my $v =$u;
 $v =undef if !$d || !$d->{$t} || !ref($d->{$t}) || !$d->{$t}->{-key};
 if ($v) {
    $s->die("Invalid authentication cookie session\n") if !$d || !$d->{$t} || !ref($d->{$t}) || !$d->{$t}->{-key};
    $v =$s->_signmk($d->{$t}->{-key}, @$c);
 }
 if (!$v) {
    $s->parent->udata->unload;
    $s->parent->user($guest);
    $s->parent->{-cache}->{-unames}  =undef;
    $s->parent->{-cache}->{-ugroups} =undef;
    $s->parent->{-cache}->{-ugnames} =undef;
    return ''
 }
 $s->die("Invalid authentication cookie signature\n") if $v->[3] ne $c->[3];
#$ENV{REMOTE_USER} =$u;
 $u;
}


sub signset {   # Set authentication
 my $s =shift;
 my $u =$ENV{REMOTE_USER}||''; $s->parent->user($u);
 my $c =[$u, $ENV{REMOTE_ADDR}||'', time];
 my $d =$s->parent->udata->param; $d->{-ses} ={} if !$d->{-ses};
 foreach my $k (sort {$a <=> $b} keys %{$d->{-ses}}) {
    delete $d->{-ses}->{$k} if (time -$k) >(60*60*24);
 }
 $d->{-ses}->{$c->[2]} ={-key=> $s->_signrand
                        ,-time=>$s->parent->strtime($c->[2])
                        ,-addr=>$c->[1]
                        };
 $c =$s->_signmk($d->{-ses}->{$c->[2]}->{-key}, @$c);
 return '' if !$c;
 $s->udata->store();
 my $r =shift ||$s->cgi->param($cooknme) ||$s->cgi->url; #||$ENV{HTTP_REFERER}
 my @p =(-uri=>$r
        ,-cookie=>[$s->cgi->cookie(-name=>$cooknme,-value=>$c,-path=>'/')]
        );
 push @p, (-nph=>1) if ($ENV{SERVER_SOFTWARE}||'') =~/IIS/
                    || ($ENV{MOD_PERL} && !$ENV{PERL_SEND_HEADER}); # PerlSendHeader Off
 $s->parent->print->redirect(@p);
 eval{$s->parent->reset};  # for mod_perl
 delete $ENV{REMOTE_USER}; # for mod_perl
 exit;
}



sub logout {    # Clear authentication
 my $s =shift;
 my $r =$_[0] ||$ENV{HTTP_REFERER};
 my @p =(-uri=>$r
        ,-cookie=>[$s->cgi->cookie(-name=>$cooknme,-value=>['',''],-path=>'/',-expires=>'-1d')]
        );
 push @p, (-nph=>1) if ($ENV{SERVER_SOFTWARE}||'') =~/IIS/
                    || ($ENV{MOD_PERL} && !$ENV{PERL_SEND_HEADER}); # PerlSendHeader Off
 $s->parent->print->redirect(@p);
 eval{$s->parent->reset};  # for mod_perl
 delete $ENV{REMOTE_USER}; # for mod_perl
 exit;
}




sub authurl {   # URL to authentication screen with return address
 my $s =shift;
 my $l =scalar(@_) >1 ? shift : ($s->{-login}||$s->parent->set('-login'));
 return '' if !$l;
 return $l .($s->qurl =~m{/([^/]+)$} ? $1 : '') if $l =~m{/$};
 $s->parent->htmlurl($l, $cooknme, shift ||($s->url .($ENV{QUERY_STRING} ? ('?' .$ENV{QUERY_STRING}) :'')));
}



sub authscr {   # User authentication screen
 my $s =shift;
 my $g =$s->cgi;
 $s->parent->userauth(@_);
 my $ha={-align=>'left',-valign=>'top'};
 my $back =$s->cgi->param($cooknme) ||$ENV{HTTP_REFERER};
 $s->print->htpgstart(undef,$s->parent->{-htpnstart});
 $s->print->h1($s->lng(0,'Authentication'));
 $s->print('<table><tr>');
 $s->print->th($ha,$s->lng(0,'UserName'))    ->td($ha,$s->htmlescape($s->parent->user))->text('</tr><tr>');
 $s->print->th($ha,$s->lng(0,'OriginalName'))->td($ha,$s->htmlescape($s->parent->useron))->text('</tr><tr>');
 $s->print->th($ha,$s->lng(0,'Cookie'))      ->td($ha,$s->htmlescape(join(', ',$s->cookie($cooknme))))->text('</tr><tr>');
 $s->print->th($ha,$s->lng(0,'Return'))      ->td($ha,$g->a({href=>$back}, $s->htmlescape($back)))->text('</tr><tr>');
 $s->print('</tr></table>');
 $s->print->htpgend;
}



sub loginscr {  # login via cgi screen
 my $s =shift;
 my $o =shift ||'-lir'; # login, info, register
 my $g =$s->cgi;
 my $rdr =$g->param($cooknme)||$ENV{HTTP_REFERER};
 my $u;
 my $d;
 if ($o !~/l/) {
     $g->param('UserInfo',1) if $o =~/i/; # user info dialog only
     $g->param('Register',1) if $o =~/r/; # register user dialog only
 }
 if (($g->param('Login') || $g->param('UserInfo'))
 && $g->param('user') && $g->param('passwd')) { 
    $u =$s->parent->user($g->param('user'));
    $s->parent->udata->load;
    $d =$s->parent->udata->param;
    $s->die("Wrong password\n") if ($d->{-passwd}||'') ne crypt($g->param('passwd'||''),$u);
    $ENV{REMOTE_USER} =$s->parent->useron;
    if   (!$g->param('UserInfo')) {$s->signset($rdr)}
    else {$s->signset($s->qurl('', $cooknme =>$rdr, 'UserInfo'=>1))}
    exit; # above always
 }
 if ($g->param('UserInfo') ||$g->param('Register')) {
    $s->print->htpgstart(undef,$s->parent->{-htpnstart});
    $s->print('<form method=post>');
    $s->print->hidden($cooknme, $rdr);
    $u ='';
    if ($g->param('UserInfo')) {
       $u =$s->signchk;
       $s->die("No user cookie\n") if !defined($u) ||$u eq '';
       $u =$s->parent->user($u);
     # $s->parent->udata->load; # in signchk
       foreach my $p (qw(email firstname middlename lastname fullname comment)) {
          $g->param($p => $s->udata->param("-$p"))
       }
    }
    $s->print->h1( $g->param('Register')
                 ? $s->lng(0,'Register')
                 : ($s->lng(0,'UserInfo') ." - $u"));
    $s->print->text('<table>');
    my $ha={-align=>'left',-valign=>'top'};
    my @hd=(-size =>30, '-name');
    my @ht=(-cols =>23, -rows=>4, '-name');
    $s->print->tr($g->th($ha,'UserName'),   $g->td($ha,$g->textfield(@hd,'user'))) 
        if $g->param('Register');
    $s->print->tr($g->th($ha,'EMail'),      $g->td($ha,$g->textfield(@hd,'email')));
    $s->print->tr($g->th($ha,'FirstName'),  $g->td($ha,$g->textfield(@hd,'firstname')));
    $s->print->tr($g->th($ha,'MiddleName'), $g->td($ha,$g->textfield(@hd,'middlename')));
    $s->print->tr($g->th($ha,'LastName'),   $g->td($ha,$g->textfield(@hd,'lastname')));
    $s->print->tr($g->th($ha,'FullName'),   $g->td($ha,$g->textfield(@hd,'fullname')));
    $s->print->tr($g->th($ha,'Comment'),    $g->td($ha,$g->textarea (@ht,'comment')));
    $s->print->tr($g->th($ha,'Password'),   $g->td($ha,$g->textfield(@hd,'passwd1')));
    $s->print->tr($g->th($ha,'Password'),   $g->td($ha,$g->textfield(@hd,'passwd2')));
    $s->print->tr($g->th($ha,'&nbsp;'),     $g->td($ha,$g->submit('Register1',$s->lng(0, 'Register'))))
        if $g->param('Register');
    $s->print->tr($g->th($ha,'&nbsp;'),     $g->td($ha,$g->submit('UserInfo1',$s->lng(0, 'Update'))))
        if $g->param('UserInfo');
    $s->print("</table>");
    $s->print->htpfend();
    eval{$s->parent->reset}; # for mod_perl
    exit;
 }
 if ($g->param('Register1') ||($g->param('UserInfo1') && !$s->parent->uguest)) {
    if ($g->param('Register1')) {
       $u =$s->parent->user($g->param('user'));
       $s->parent->udata->load;
       $s->die("User '$u' already registered\n") if $s->udata->param('-passwd') 
                                                 || $s->udata->param('-ses');
    }
    else {
       $u =$s->signchk;
       $u =$s->parent->user($u);
     # $s->parent->udata->load; # in signchk
    }
    $s->die("Passwords does not match\n") if  $g->param('passwd1') ne $g->param('passwd2')
                                          ||(!$g->param('passwd1') && $g->param('Register1'));
    $g->param('passwd', crypt($g->param('passwd1'),$u)) if $g->param('passwd1');
    foreach my $p (qw(email firstname middlename lastname fullname comment passwd)) {
       $s->udata->param("-$p", $g->param($p));
    }
    $s->parent->udata->store;
    $ENV{REMOTE_USER} =$s->parent->useron;
    $s->signset($rdr);
 }
 if (1) {
    $s->print->htpgstart(undef,$s->parent->{-htpnstart});
    $s->print('<form method=post>');
    $s->print->h1('Authentication required');
    $s->print->hidden($cooknme, $rdr);
    my $ha={-align=>'left',-valign=>'top'};
    $s->print('<table><tr>')
      ->th($ha, 'UserName')
      ->td($ha, $g->textfield('user'))
      ->text('</tr><tr>')
      ->th($ha, 'Password')
      ->td($ha, $g->password_field('passwd'))
      ->text('</tr><tr>')
      ->th($ha, '&nbsp;')
      ->td($ha, $g->submit('Login','Login')
              .($o =~/i/ ? $g->submit('UserInfo',$s->lng(0, 'UserInfo')) :'') 
              .($o =~/r/ ? $g->submit('Register',$s->lng(0, 'Register')) : ''))
      ->text('</tr></table>');
    $s->print->htpfend;
    eval{$s->parent->reset}; # for mod_perl
    exit;
 }
 $s
}


