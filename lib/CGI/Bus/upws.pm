#!perl -w
#
# CGI::Bus::upws - User Personal WorkSpace
#
# admiral 
#
# 

package CGI::Bus::upws;
require 5.000;
use strict;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Bus::Base;
use vars qw(@ISA);
@ISA =qw(CGI::Bus::Base);

my %img =(-logo     =>'portal.gif'        # portal  world1
         ,'Home'    =>'small/burst.gif'
         ,'Overview'=>'small/movie.gif'
         ,'Index'   =>'small/comp1.gif'
         ,'USites'  =>'small/image2.gif'
         ,-usite    =>'small/image2.gif'
         ,-udir     =>'small/blank.gif'   # dir2 blank
         ,'USFHomes'=>'small/dir.gif'
         ,'USFHome' =>'small/dir.gif'
         ,'Setup'   =>'small/patch.gif'
         ,_blank    =>'small/dir.gif'     # generic dir
         ,_top      =>'small/back.gif'    # back    transfer
         ,-href     =>'small/text.gif'    # doc     text     generic forward blank
         ,-hgen     =>'small/generic.gif'
         ,-host     =>'small/comp2.gif'   # comp2 comp1
         ,-hcgi     =>'small/doc.gif'
         ,'Logout'  =>'small/key.gif'
         ,'Login'   =>'small/key.gif'
   );

1;


#######################


sub _img {
 $_[0]->parent->{-iurl} && $img{$_[1]} 
 ? ('<img src="' .$_[0]->parent->{-iurl} .'/' .$img{$_[1]} .'" alt="" border=0 />')
 : ''
}



sub urls {      # urls array
 my $s =shift;
 my $l =[];
 my $hu=$s->udata->paramj('upws_urlh');
 my $hf=$s->udata->paramj('upws_frmurls');
    $hf=scalar(@$hf) if $hf;
 my $ht;
 push @$l, $s->cgi->a({-href=>$hu, -title=>$s->lng(1, 'Home')}
           ,$s->_img('Home') .$s->lng(0, 'Home'))
           if $hu;
 push @$l, $s->cgi->a({-href=>$s->qurl('', '_run'=>'RIGHT')
           ,-title=>$s->lng(1, 'Overview')}
           ,$s->_img('Overview') .$s->lng(0, 'Overview'))
           if $hf;
 push @$l, $s->cgi->a({-href=>$s->{-index}
           ,-title=>$s->lng(1, 'Index')}
           ,$s->_img('Index') .$s->lng(0, 'Index'))
           if $s->{-index} && !ref($s->{-index});
 push @$l, @{$s->{-index}}
           if $s->{-index} &&  ref($s->{-index});
 push @$l, @{$s->{-indexes}}
           if $s->{-indexes};
 push @$l, $s->cgi->a({-href=>$s->qurl('', '_run'=>'USITES')
           ,-title=>$s->lng(1, 'USites', $s->{-uspfile} ? join(', ', @{$s->{-uspfile}}) : '')}
           ,$s->_img('USites') .$s->lng(0, 'USites'))
           if $s->{-usurl};
 if ($s->parent->urfcnd && $s->{-uspurf}) {
    $s->_usdflt if !$s->{-uspath};
    my ($hu, $ho) =('',$s->{-uspurf});
    if (!$s->parent->uguest) {$hu =$s->usfhome; $ho =$s->usohome($hu)}
 push @$l, $s->cgi->a({-href=> $ho =~/^\w{3,5}:\/\// ? $ho : (($s->{-uspurf} ||$s->{-usurl}) ."/$ho")
           ,-target=>'_blank'
           ,-title =>$s->lng(1, 'USFHomes')}
           ,$s->_img('USFHomes') .$s->lng(0, 'USFHomes') .'&nbsp;&nbsp;&nbsp;')
           if $hu;
 push @$l, $s->cgi->a({-href=> $hu =~/^\w{3,5}:\/\// ? $hu : (($s->{-uspurf} ||$s->{-usurl}) ."/$hu")
           ,-target=>'_blank'
           ,-title =>$s->lng(1, 'USFHome')}
           ,$s->_img('USFHome') .$s->lng(0, 'USFHome') .'&nbsp;&nbsp;&nbsp;')
           if $hu;
 }
 push @$l, @{ref($s->{-urlst}) eq 'CODE' ? &{$s->{-urlst}}($s) : $s->{-urlst}}
           if $s->{-urlst};
 push @$l, ''
           if scalar(@$l) >2;
 push @$l, @{$s->parent->udata->paramj('upws_urls') ||[]};
 push @$l, @{ref ($s->{-urls}) eq 'CODE' ? &{$s->{-urls}}($s)  : $s->{-urls}}
           if $s->{-urls};
 $l
}



sub urltop {    # topmost url to open first
 my $s =shift;
 my $u =$s->urls->[0];
 if    ($u =~/ +href *= *"([^"\s>]+)"/i) { $u =$1 }
 elsif ($u =~/^([^|]+)\|+(.+)$/)         { $u =$2 }
 $u
}



sub scrbot {    # print bottom of the screen
 my $s =shift;
 my $p =$s->parent;
 my $r =join(';' .$p->cgi->br, map {$p->htmlescape($_)} @{$p->pushmsg});
 $r  ='<hr /><font size=-1>' .$r .'</font>' if $r;
 $s->print->text($r);
}



sub scrtop {    # top screen (top frameset)
 my $s =shift;
 my $ft=0; # top frame
 $s->print->httpheader({-target=>'_parent', -expires=>undef});
 $s->print('<html><head><title>' 
          .$s->server_name() 
          .' - '
          .$s->lng(0,'WorkSpace')
          .'</title></head>');
 $s->print("<frameset cols=\"15%,*\">\n");
 $s->print("<frame name=\"LEFT\" src=\""
          .$s->qurl('', '_run'=>'LEFT') .'"'
          .' onfocus="{var e; try {self.document.title = self.LEFT.document.title;} catch(e){}};"'
          ." target=\"RIGHT\" />\n");
 $s->print("<frameset rows=\"0%,*\">\n") if $ft; # 5%
 $s->print("<frame name=\"TOPR\" src=\""
          .$s->qurl('', '_run'=>'TOPR') .'"'
          ." target=\"RIGHT\" />\n") if $ft;
 $s->print('<frame name="RIGHT" src="'
          .$s->urltop .'"'
          .' onfocus ="{var e; try {self.document.title = (self.RIGHT.document && self.RIGHT.document.title) || &quot;'
            .$s->parent->htmlescape($s->parent->set('-htmlstart')->{-title} || '') 
            .'&quot; || self.RIGHT.location.href || &quot;&quot;} catch(e) {}};";'
          ." />\n");
#(self.RIGHT && self.RIGHT.document && self.RIGHT.document.title)
#' onfocus ="self.document.title = self.RIGHT.document.title || self.RIGHT.location.href;"'
#' onfocus ="self.document.title = self.RIGHT.document.title +&quot; - &quot; +self.RIGHT.location.href;"'
# onfocus ="self.parent.status = self.RIGHT.document.title;"
# onfocus ="self.status = self.RIGHT.document.title;"
# self.RIGHT.contentWindow.location.href
 $s->print("</frameset>\n") if $ft;
 $s->print("</frameset>\n");
 $s->print("</html>\n");
}


sub scrleft {   # left screen (urls)
 my $s =shift;
 my $p =$s->parent;
#$s->print->htpgstart(undef, $p->hmerge($p->{-htpnstart},-target=>'RIGHT',-style=>"{margin-top:0px}"));
 $s->print->htpgstart(undef, $p->hmerge($p->{-htpnstart},-target=>'RIGHT'));
 $s->{-logo} =$s->a({-href=>$s->qurl('', '_run'=>'LEFT'), -target=>'_blank'}
                   #{-href=>$s->surl, -target=>'_parent'}
                   ,$s->{-logo} ? '<img src="' .$s->{-logo} .'" alt="" border=0 />' : $s->_img('-logo'))
            if (!defined($s->{-logo}) && $img{-logo} && $p->{-iurl})
            || ($s->{-logo} && $s->{-logo} !~/</);
 $s->{-logo} ='<img src="/icons/portal.gif" alt="" border=0 />' 
            if !defined($s->{-logo}) && $ENV{SERVER_SOFTWARE} =~/Apache/i;
            # /icons/apache_pb.gif; world1.gif
 $s->{-logo} ='<img src="/web.gif" alt="" border=0 />' 
            if !defined($s->{-logo}) && $ENV{SERVER_SOFTWARE} =~/IIS/;
 $s->print($s->{-logo}) if $s->{-logo};
 $s->print->strong($s->user)->br;
#$s->print->strong($s->a({-href=>$s->uauth->authurl($s->qurl), -target=>'_parent'}, $s->user))->br;
 $s->print('<NOBR>');
 if ($s->uguest) {
    $s->print->a({-href  =>$s->uauth->authurl($s->qurl)
                        || $s->qurl('','_run'=>'LOGIN')
                 ,-target=>'_parent'   #'_top' # _parent
                 ,-title =>$s->lng(1,'Login')}
                ,$s->_img('Login') .$s->lng(0,'Login') .'...')->br->br;
 }

 my $l =$s->urls;
 foreach my $e (@$l) {
   if ($e =~/<\w/i || $e eq '') {
      $s->print((!$e ||$e =~/<img\s|<hr|<br/i ? '' : $s->_img('-hgen')) .$e .$s->cgi->br ."\n");
   }
   elsif ($e =~/^([^|]+)\|(_blank)\|(.+)$/i) {
      my ($c,$t,$u) =($1, $2, $3);
      $s->print->a({-href=>$u, -target=>$t,-title=>$e}
                  , $s->_img('_blank') .$s->htmlescape($c) .'&nbsp;&nbsp;&nbsp;')->br;
   }
   elsif ($e =~/^([^|]+)\|(_top|_parent)\|(.+)$/i) {
      my ($c,$t,$u) =($1, $2, $3);
      $s->print->a({-href=>$u, -target=>$t,-title=>$e}
                  ,$s->_img('_top') .$s->htmlescape($c) .'&nbsp;')->br;
   }
   elsif ($e =~/^([^|]+)\|+(.+)$/) {
      my ($c,$u) =($1, $2);
      $s->print->a({-href=>$u,-title=>$c}
      , $s->_img($u !~m{\w/\w}i ? '-host' : $u =~m{\.(cgi|pl|php|asp)\b}i ? '-hcgi' : '-href') 
      . $s->htmlescape($c))->br;
   }
   else {
      $s->print->a({-href=>$e,-title=>$e}, $s->_img('-href') .$s->htmlescape($e))->br;
   }
 }

 if (!$s->parent->uguest) {
    $s->print->br;
    $s->print->a({-href=> $s->qurl('','_run'=>'SETUP')
                 ,-title=>$s->lng(1,'Setup')}
                ,$s->_img('Setup') .$s->lng(0,'Setup'))->br;
    $s->print->a({-href  =>$s->qurl('','_run'=>'LOGOUT')
                 ,-target=>'_parent' #'_top' # _parent
                 ,-title =>$s->lng(1,'Logout')}
                ,$s->_img('Logout') .$s->lng(0,'Logout') .'!')->br
        if $s->parent->uauth->signget;
 }
 $s->print('</NOBR>');
 $s->scrbot;
 $s->print->htpgend;
}



sub scrtopr  {  # top right screen (frame)
 my $s =shift;
#$s->print->htpgstart();
#$s->print->htpgstart(undef, $s->parent->hmerge($s->parent->{-htpnstart}, -style=>"{margin-top:0px}"));
 $s->print->htpgstart(undef, $s->parent->{-htpnstart});
 $s->print->startform(-action=>$s->qurl, -acceptcharset=>$s->parent->{-httpheader} ?$s->parent->{-httpheader}->{-charset} :undef);
 $s->print->htpfend();
}



sub scrright {  # right screen (frameset)
 my $s =shift;
 my $d =$s->udata->param;
    $d =$s->udata->paramj if !$d->{'upws_frmurls'} || !scalar(@{$d->{'upws_frmurls'}});

 if ($d->{'upws_frmurls'}
 && $s->parent->ishtml($d->{'upws_frmurls'}->[0])) {
    $s->print->httpheader;
    $s->print(join("\n", @{$d->{'upws_frmurls'}}));
    return(1)
 }

 if (!$d->{upws_frmrows} && !$d->{upws_frmcols} 
 && $d->{upws_frmurls} && scalar(@{$d->{upws_frmurls}})) {
    my $r =scalar(@{$d->{upws_frmurls}});
    $d->{upws_frmrows} = (int(100/$r) .'%,') x $r;
    chop($d->{upws_frmrows})
 }

 $s->print->httpheader;
 $s->print("<frameset" 
          .($d->{upws_frmrows} ? (' rows="' .$d->{upws_frmrows} .'"') :'')
          .($d->{upws_frmcols} ? (' cols="' .$d->{upws_frmcols} .'"') :'')
          .">\n");
 if ($d->{upws_frmurls}) {
    foreach my $e (@{$d->{upws_frmurls}}) {
      $s->print("<frame src=\""
               .$e
               ."\">\n");
    }
 }
 $s->print("</frameset>\n");
 $s->print("</html>\n");

}



sub _usdflt {   # Users Sites Defaults
 my $s =shift;
 if (!$s->{-uspath}) { # users sites dir
    foreach my $d ('/share/users','/share/home','d:/share/users','d:/share/home','/users','/home','d:/users','d:/home') {
       next if !-d $d;
       $s->{-uspath} =$d;
       my $dn =($d =~/^(\/|\w:\/)(.+)/ ? $2 : $d);
       $s->{-usurl}  =~s/\$_/$dn/   if  $s->{-usurl};
       $s->{-usurl}  =$s->surl($dn) if !$s->{-usurl};
       $s->{-uspurf} =~s/\$_/$dn/   if  $s->{-uspurf};
       $s->{-uspurl} =~s/\$_/$dn/   if  $s->{-uspurl};
       last;
    }
 }
 $s->{-usudir} =['users','home','']  # users subdirs
               if !$s->{-usudir};
 $s->{-uspdir} =['pub',''] 
               if !$s->{-uspdir};    # publish subdirs
 $s->{-uspfile}=['index.url','index.html','index.htm'
                ,'default.url','default.html','default.htm'] # publish files
               if !$s->{-uspfile};
 $s->{-ushref}                       # sites hyperlinks
 || $s->{-ushome}                    # current user's home
}


sub _usjt {     # join trim
 my $r ='';
 shift if ref($_[0]);
 foreach my $e (@_) {
   $r .='/' .$e if $e ne '';
 }
 substr($r,1);
}


sub _usdirscn { # Users Sites Collect Dirs
 my ($s,$o,$d) =@_; # options, subdir
 my $j;             # jump trigger
 if (!defined($d)) {
    $s->_usdflt;
    $s->{-ushref} =[];
    $s->{-ushome} ='';
    $d ='';
 }
 $o ='' if !defined($o);
 my $un=$s->parent->user;
 if (1) {               # publish subdirs & files
    foreach my $e (@{$s->{-uspdir}}) {
       $j =1 if $d && $e && -d _usjt($s->{-uspath},$d,$e);
       foreach my $f (@{$s->{-uspfile}}) {
          my $n =_usjt($s->{-uspath},$d,$e,$f);
          next if !-f $n;
        # $s->print('f: ' .$n .'<br />');
          $j =1;
          my $u =($n =~/\.url$/ ? [$s->fut->fload(-a=>$n)]->[0]
                                : _usjt($d,$e,$f));
          push @{$s->{-ushref}}, [$u,$d];
        # print ' ', $s->cgi->a({-href => $u =~/^\w{3,5}:\/\// ? $u : ($s->{-usurl} .'/' .$u)}, '.'), ' ';
       }
    }
 }
 if ($o !~/u/) {        # users subdirs
    foreach my $e (@{$s->{-usudir}}) {
       next if $e eq '';
       next if !-d _usjt($s->{-uspath},$d,$e);
       $j =1;
       foreach my $u (eval {sort $s->fut->globn(_usjt($s->{-uspath},$d,$e,'*'))}) {
          my $n =_usjt($s->{-uspath},$d,$e,$u);
        # $s->print('u: ' .$n .'<br />');
          next if !-d $n;
        # print ', ';
          $s->_usdirscn($o .'u',_usjt($d,$e,$u));
          return($s->{-ushome}) if $s->{-ushome} && $o =~/!/;
          if (lc($un) eq lc($u)) {
             return($s->{-ushome} =_usjt($d,$e,$u)) if $o =~/!/;
             foreach my $h (@{$s->{-uspdir}}) {
                next if !-d _usjt($n,$h);
                $s->{-ushome} =_usjt($d,$e,$u,$h);
                last
             }
          }
       }
    }
 }
 if (!$j && $o !~/u/) { # scan subdirs
    my $sub =$s->{-usfirst};
    local $_;
    foreach my $a (0,1) {
    foreach my $e (eval {sort $s->fut->globn(_usjt($s->{-uspath},$d,'*'))}) {
       $_ =$e;
       next if $a ==0 ? ($sub && !&$sub($_)) : (!$sub ||&$sub($_));
       my $n =_usjt($s->{-uspath},$d,$e);
     # $s->print('l: ' .$n .'<br />');
       next if !-d $n;
     # print '. ';
       $s->_usdirscn($o,_usjt($d,$e));
       return($s->{-ushome}) if $s->{-ushome} && $o =~/!/;
       if (lc($un) eq lc($e)) {
          return($s->{-ushome} =_usjt($d,$e)) if $o =~/!/;
          foreach my $h (@{$s->{-uspdir}}) {
             next if !-d _usjt($n,$h);
             $s->{-ushome} =_usjt($d,$e,$h);
             last
          }
       }
    }}
 }
 $s->{-ushref};
}


sub uscollect { # Users Sites Collect
 my $s =shift;
 $s->_usdflt;
 my $dc =$s->_usdirscn;
 my $ds =[];
 my $op ='';
 my $lv =0;
 my @ops;
#print ' /';
 my $ug=$s->parent->uglist({});
 foreach my $k (keys %$ug) {
    if ($ug->{$k} =~/^[^,-]+[,-]+ *(.*)/) {$ug->{$k} =$1}
    $ug->{lc($k)} =$ug->{$k}
 }
#print '/ ';
 foreach my $r (@$dc) {
   my ($np, $nu) =($r->[1] =~/^(.*?)[\\\/]*([^\\\/]+)$/ ? ($1,$2) : ('',$r->[1]));
   if ($np ne $op) {
      my @nps =split /[\\\/]/, $np;
      $lv =0;
      for (my $i =0; $i <scalar(@nps); $i++) {
          my $tp =join('/',@ops[0..($#ops <$i ? $#ops : $i)]);
          if   (length($tp) >0 && $#ops >=$i && substr($np,0,length($tp)) eq $tp) {}
          elsif(grep {lc($_) eq lc($nps[$i])} @{$s->{-usudir}}) {}
          elsif(grep {lc($_) eq lc($nps[$i])} @{$s->{-uspdir}}) {}
        # elsif($i <$#nps
        #    ||($i !=($#ops +1)) 
        #    ||(length($op) >0 && substr($np,0,length($op)) ne $op)) {
          else {
             push @$ds, [$lv       # nest level
                        ,$nps[$i]  # name
                        ,$ug->{$nps[$i]} ||$ug->{lc($nps[$i])} ||$nps[$i] # label
                        ,''        # URL
                        ,''        # fdir
                        ,substr($np,0,length($tp)) #hier
                        ];
           # print ' / ';
          }
          $lv +=1
      }
      $op  =$np;
      @ops =(@nps,$nu);
   }
   else {
      @ops =((split /[\\\/]/, $np), $nu)
   }
   push @$ds, [$lv  # nest level
              ,$nu  # name
              ,$ug->{$nu} ||$ug->{lc($nu)} ||$nu # label
              ,$r->[0] =~/^\w{3,5}:\/\// ? $r->[0] 
               : (($s->{-usurl} ||$s->{-uspurl} ||$s->{-uspurf}) .'/' .$r->[0])
              ,@$r  # fdir, hier
              ];
 # print ' . ';
 }
 $s->{-ushref} =$ds;
}



sub scrusites { # Users Sites Display
 my $s =shift;
 my $p =$s->parent;
 my $ha={-align=>'left',-valign=>'top'};
 my $hl={-align=>'left',-valign=>'top',-colspan=>10};
 my $lv =0;
 my $lr =2;

#$p->print->htpgstart;
#$p->print->htpgstart(undef, {-style=>"{margin-top:0px}"});
 $p->print->htpgstart;
 $p->print->startform(-action=>$s->qurl);

 $p->print->hidden('_run' =>'USITES');
 $s->_usdflt;
 $p->print->text('<table width="100%"><tr><td>')
   ->h1($p->htmlescape($s->lng(0, 'USites')));
 my $tf =$p->fut->mkdir($p->tpath('upws')) .'/usites.pl';
 if (!-f $tf || $p->param('refresh')) {
    $s->uscollect;
    $p->fut->fdumpstore($tf, $s->{-ushref});
    $p->udata->store('upws_usphome'=>$s->{-ushome}) if !$p->uguest;
 }
 else {
    $s->{-ushref} =$p->fut->fdumpload($tf);
    $s->{-ushome}=$p->udata->param('upws_usphome');
 }
 $p->print->text('</td>');
 $p->print->td({-valign=>'top',-align=>'right'}
       ,$p->uguest ? '' :
       ($p->submit(-name=>'refresh'
                  ,-value=>$s->lng(0, 'Refresh')
                  ,-title=>$s->lng(1, 'Refresh'))
       .($s->{-ushome}
        ? ($p->cgi->br .$p->cgi->a({-href=>($s->{-uspurf} ||$s->{-uspurl} ||$s->{-usurl}) 
                                       .'/' .$s->{-ushome}
                               ,-target => '_blank'
                               }
                              ,$s->_img('USFHome') .$s->{-ushome}))
        : ''))
       )
   ->text('</tr><tr>')
   ->td($hl,$p->htmlescape($s->lng(1, 'USites', join(', ',@{$s->{-uspfile}}))))
   ->text('</tr></table>');

 $p->print->endform;
 $p->print->text("<table>\n");
 foreach my $r (@{$s->{-ushref}}) {
   $p->print('<tr>');
   $p->print('<td>&nbsp;&nbsp;&nbsp;</td>' x $r->[0]);
   if ($r->[3]) {
      $p->print->td($hl, '<nobr>' .$p->a({-href=> $r->[3]}, $s->_img('-usite') .$p->htmlescape($r->[2])) .'</nobr>');
   }
   else {
      $p->print->th($hl, '<nobr>' .$s->_img('-udir') .$p->htmlescape($r->[2]) .'</nobr>');
   }
   $p->print('</tr>');
   $lv =$r->[0];
 }
 $p->print->text("</table>\n");
 $s->scrbot;
 $p->print->htpgend;
}



sub usfhome {   # User's files home link
 my $s =shift;
 my $p =$s->parent;
 return '' if $p->uguest;
 my $r =$p->udata->param('upws_usfhome');
 if (!defined($r) ||scalar(@_)) {
    $s->{-ushome} =undef;
    $s->_usdirscn('!');
    $r=$s->{-ushome};
    $r='' if !defined($r);
    $p->udata->store('upws_usfhome'=> $r);
 }
 elsif (!$s->{-uspath}) {
    $s->_usdflt
 }
 $r
}


sub usohome {   # User's office home
 my ($s,$u) =@_;
 $u =$s->usfhome if !defined($u);
 if ($u =~/^(.+?)[\\\/]([^\\\/]+)$/) {
     $u =$1;     
     foreach my $e (@{$s->{-usudir}}) {
        next if !$e || $u !~/^(.+?)[\\\/]\Q$e/i;
        return $1
     }
 }
 $u =''
}


sub scrsetup {  # setup screen
 my $s =shift;
 $s->die("Prohibited\n") if $s->uguest;
 my $g =$s->cgi;
 my $d =$s->udata->param;
 my $u0=$s->parent->user;
 my $un=$g->param('user');
 my $ua=$s->parent->uadmin([]);
 my $aa=$s->parent->uadmin();
 my $wr=$g->param('save');
 my $rd=!$g->param('_run1') ||$g->param('read');
 my $ha={-align=>'left',-valign=>'top'};
 my $hd={-align=>'left',-valign=>'top',-colspan=>3};

 if ($un && $s->parent->uadmin($un)) {
     $s->parent->set('-cache')->{-user} =$un;
     $s->udata->load;
     $d =$s->udata->param;
 }

#$s->print->htpgstart(undef, $s->parent->hmerge($s->parent->{-htpnstart}, -style=>"{margin-top:0px}"));
 $s->print->htpgstart(undef, $s->parent->{-htpnstart});
 $s->print->startform(-action=>$s->qurl);

 $s->print->hidden('_run' =>'SETUP');
 $s->print->hidden('_run1'=>'SETUP');
 $s->print('<table width="100%"><tr><td>');
 $s->print->h1($s->lng(0, 'Setup') .' - ' .$s->parent->user)
          ->text($s->lng(1, 'Setup') .$g->br);
 $s->print('</td>');
 $s->print->td({-valign=>'top',-align=>'right'}
              ,$g->submit(-name =>'save'
                         ,-value=>$s->lng(0, 'Save')
                         ,-title=>$s->lng(1, 'Save')))
     if !$aa && !scalar(@$ua);
 $s->print('</tr></table>');

 foreach my $p (qw(upws_urlh upws_frmrows upws_frmcols upws_usfhome urole)) {
    if    ($wr) {$d->{$p} =$g->param($p)}
    elsif ($rd) {$g->param($p, defined($d->{$p}) ? $d->{$p} : '')}
 }
 if    ($wr) {
    $d->{'upws_urls'}     =[split / *\r*\n\r* */, $g->param('upws_urls')];
    $d->{'upws_frmurls'}  =[split / *\r*\n\r* */, $g->param('upws_frmurls')];
    $d->{'uauth_managed'} =[split / *, */,        $g->param('uauth_managed')] 
                          if $aa;
    $d->{'uauth_groups'}  =[split / *, */,        $g->param('uauth_groups')]  
                          if $aa && $s->parent->uauth->set('-udata');
 }
 elsif ($rd) {
    foreach my $p (qw(upws_urls upws_frmurls uauth_managed uauth_groups)) {
      $g->param($p, '')
    }
    $g->param('upws_urls',     join("\n", @{$d->{'upws_urls'}}))     if $d->{'upws_urls'};
    $g->param('upws_frmurls',  join("\n", @{$d->{'upws_frmurls'}}))  if $d->{'upws_frmurls'};
    $g->param('uauth_managed', join(",",  @{$d->{'uauth_managed'}})) if $d->{'uauth_managed'} && $aa;
    $g->param('uauth_groups',  join(",",  @{$d->{'uauth_groups'}}))  if $d->{'uauth_groups'}  && $aa;
 }
 if    ($wr) {
    $s->udata->store;
    $s->pushmsg('Data Saved')
 }
 elsif ($rd) {
    $s->pushmsg('Data Loaded')
 }

 $s->print("<table>\n");
 $s->print('<tr>');
 if (scalar(@$ua)) {
 unshift @$ua, $u0;
 $s->print->th($ha, $s->lng(0, 'User'));
 $s->print->td($hd, $g->popup_menu(-name=>'user'
                              ,-values=>$ua
                              ,-labels=>$s->uglist({},37)
                              ,-default=>($un||$u0)) 
                  . $g->submit(-name=>'read'
                              ,-value=>$s->lng(0, 'Read')
                              ,-title=>$s->lng(1, 'Read'))
                  . $g->submit(-name=>'save'
                              ,-value=>$s->lng(0, 'Save')
                              ,-title=>$s->lng(1, 'Save')));
 $s->print("</tr>\n<tr>");
 }
 if ($aa) {
 $s->print->th($ha, $s->lng(0, 'Managed'));
 $s->print->td($hd, $s->htmltextfield(-name=>'uauth_managed', -asize=>70)
                  . $s->htmlddlb('uauth_managed_',sub{$_[0]->uglist({})}, ["\tuauth_managed"=>' '])
                  . $s->_ssfcmt('Managed')
              );
 $s->print("</tr>\n<tr>");
 if ($s->parent->uauth->set('-udata')) {
 $s->print->th($ha, $s->lng(0, 'Groups'));
 $s->print->td($hd, $s->htmltextfield(-name=>'uauth_groups', -asize=>70)
                  . $s->htmlddlb('uauth_groups_',sub{$_[0]->uglist({})}, ["\tuauth_groups"=>' '])
                  . $s->_ssfcmt('Groups')
              );
 $s->print("</tr>\n<tr>");
 }
 }
 $s->print->th($ha, $s->lng(0, 'FavoriteURLs'));
 $s->print->td($hd, $s->htmltextarea(-name=>'upws_urls', -cols=>58, -arows=>4, -wrap=>'off')
              .$s->_ssfcmt('FavoriteURLs'));
 $s->print("</tr>\n<tr>");
 $s->print->th($ha, $s->lng(0, 'HomeURL'));
 $s->print->td($hd, $s->htmltextfield(-name=>'upws_urlh', -asize=>70)
              .$s->_ssfcmt('HomeURL'));
 $s->print("</tr>\n<tr>");
 $s->print->th($ha, $s->lng(0, 'FramesetURLs'));
 $s->print->td($hd, $s->htmltextarea(-name=>'upws_frmurls', -cols=>58, -arows=>4, -wrap=>'off')
              .$s->_ssfcmt('FramesetURLs'));
 $s->print("</tr>\n<tr>");
 $s->print->th($ha, '..' .$s->lng(0, 'FramesetRows'));
 $s->print->td($ha, $s->htmltextfield(-name=>'upws_frmrows')
              .$s->_ssfcmt('FramesetRows'));
#$s->print("</tr>\n<tr>"); # -asize=>70
 $s->print->th($ha, '..' .$s->lng(0, 'FramesetCols'));
 $s->print->td($ha, $s->htmltextfield(-name=>'upws_frmcols')
              .$s->_ssfcmt('FramesetCols'));
 $s->print("</tr>\n<tr>");

 if ($s->{-uspurf}) {
 $s->print("</tr>\n<tr>");
 $s->print->th($ha, $s->lng(0, 'USFHome'));
 $s->param('upws_usfhome',$s->usfhome(1)) if $s->param('upws_usfhome_');
 $s->print->td($hd, $s->htmltextfield(-name=>'upws_usfhome', -asize=>70)
              .$s->submit(-name=>'upws_usfhome_', -value=>'<-', -title=>$s->lng(1, 'Refresh'))
              .$s->_ssfcmt('USFHome'));
 }

 $s->print("</tr>\n<tr>");
 $s->print->th($ha, $s->lng(0, 'PrimaryRole'));
 $s->print->td($hd, $s->popup_menu(-name=>'urole', -values=>['',@{$s->ugroups}])
              .$s->_ssfcmt('PrimaryRole'));

 $s->print("</tr>\n<tr>");
 $s->print->th($ha, '');
 $s->print->td($hd, $g->submit(-name=>'save'
                              ,-value=>$s->lng(0, 'Save')
                              ,-title=>$s->lng(1, 'Save')));
 $s->print("</tr>\n");
 $s->print("</table>\n");
 $s->scrbot;
 $s->print->htpfend;
}


sub _ssfcmt {
 '<br /><font size=-1>' .$_[0]->lng(1, $_[1]) .'</font>'
}


sub evaluate {  # execute workspace
 my $s =shift;
 my $c =$s->qparam('login')  ? 'LOGIN' 
       :$s->qparam('logout') ? 'LOGOUT'
       :$s->qparam('usites') ? 'USITES'
       :($s->qrun ||'');
 $s->userauthopt() if $c ne 'LOGIN';
 if    ($c eq 'LEFT')   { $s->scrleft  }
 elsif ($c eq 'TOPR')   { $s->scrtopr  }
 elsif ($c eq 'RIGHT')  { $s->scrright }
 elsif ($c eq 'SETUP')  { $s->scrsetup }
 elsif ($c eq 'LOGIN')  { $s->parent->userauth($s->qurl)}
 elsif ($c eq 'LOGOUT') { $s->parent->uauth->logout($s->qurl)}
 elsif ($c eq 'USITES') { $s->scrusites}
 else                   { $s->scrtop   }
}


