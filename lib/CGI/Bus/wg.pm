#!perl -w
#
# CGI::Bus::wg - HTML Widgets
#
# admiral 
#
# 

package CGI::Bus::wg;
require 5.000;
use strict;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Bus::Base;
use vars qw(@ISA $AUTOLOAD);
@ISA =qw(CGI::Bus::Base);


1;


#######################


sub ddlb {     # Drop-Down List Box - Input helper
 my ($s,$n,$ds) =(shift, shift, shift);
 my $g =$s->cgi;
 my $r ='';
 if ($g->param($n .'_B')) {
    $r .=$g->submit(-name=>($n .'_C'), -value=>$s->lng(0,'ddlbclose'), -title=>$s->lng(1,'ddlbclose'));
    $r .='<br />';
    $ds = &$ds($s) if ref($ds) eq 'CODE';
    my $dl;
    if (ref($ds) eq 'HASH') {
       $dl =$ds;
       $ds =[sort {lc($ds->{$a}) cmp lc($ds->{$b})} keys %$ds];
       foreach my $k (keys %$dl) {$dl->{$k} =substr($dl->{$k},0,60)}
    }
    $r .=$g->scrolling_list(-name=>($n .'_L')
                           ,-values=>$ds
                           ,-labels=>$dl
                           ,-size=>(scalar(@$ds) <10 ? scalar(@$ds) : 10)
                           );
    chomp($r);
    $r .='<br />';
    if (scalar(@_) == 1 && (ref($_[0]) ? $_[0]->[0] : $_[0]) !~/^\t/) {
       $r .=$g->submit(-name=>($n .'_S')
                      ,-value=>'<' 
                       .(ref($_[0]) ?($_[0]->[1] || $_[0]->[0]) :($_[0] || ''))
                      ,-title=>$s->lng(1,'ddlbsetvalue'))
    }
    else {
       foreach my $fn (@_) {
          next if !$fn;
          my $l =$fn;
          if (ref($fn)) {
             $l =$fn->[1] || $fn->[0];
             $fn=$fn->[0];
             next if !$fn;
          }
          my $wn =($fn =~/^\t(.*)/ ? $1 : $fn);
          $r .=
          $g->button(-value=>(($fn eq $wn ? '<' :'<+') .$l)
           ,-onClick=>"var fs =window.document.forms[0].${n}_L; "
                     ."var ft =window.document.forms[0].$wn; "
                     ."var i  =fs.selectedIndex; "
           .($g->user_agent('MSIE') 
            ?($fn eq $wn ? "ft.value =(fs.options.item(i).value ==\"\" ? fs.options.item(i).text : fs.options.item(i).value); "
              : "ft.value =(ft.value ==\"\" ? \"\" : (ft.value +\",\")) +(fs.options.item(i).value ==\"\" ? fs.options.item(i).text : fs.options.item(i).value); ")
            :($fn eq $wn ? "ft.value =fs[i].value; "
              : "ft.value =(ft.value ==\"\" ? \"\" : (ft.value +\",\")) +fs[i].value; ")
             )
           ,-title=>$s->lng(1,'ddlbsetvalue'));
       }
    }
    $r .=$g->button(-value=>$s->lng(0,'ddlbfind'), -title=>$s->lng(1,'ddlbfind')
         ,-onClick=>
           '{var k;'
           ."var l=window.document.forms[0].${n}_L;"
           ."k=prompt('Enter search string',''); if(!k){return(false)}"
           .'k=k.toLowerCase();'
           .'for (var i=0; i <l.length; ++i) {'
           .'if (l.options.item(i).value.toLowerCase().indexOf(k)==0){'
           .'l.selectedIndex =i; return(false); break;}}};'
         );
    $r .=$g->submit(-name=>($n .'_C'), -value=>$s->lng(0,'ddlbclose'), -title=>$s->lng(1,'ddlbclose'));
 }
 else {
    $g->param(ref($_[0]) ? $_[0]->[0] : $_[0], $g->param($n .'_L')) 
        if scalar(@_) == 1 && $g->param($n .'_S');
    $r .=$g->submit(-name=>($n .'_B'), -value=>$s->lng(0,'ddlbopen'), -title=>$s->lng(1,'ddlbopen'));
 }
 $r
}


sub textfield {# Text filed with autosizing
 my $s =shift;
 my %a =@_;
 my $v =exists($a{-default}) ? $a{-default} : $s->qparam($a{-name});
    $v ='' if !defined($v);
 if ($a{-asize}) {
     $a{-size} =($a{-asize} >length($v) ? $a{-asize} :length($v));
     delete $a{-asize};
 }
 $s->cgi->textfield(%a)
}


sub textarea { # Text Area with autorowing and hrefs
 my $s =shift;
 my %a =@_;
 my $r ='';
 my $v =exists($a{-default}) ? $a{-default} : $s->qparam($a{-name});
    $v ='' if !defined($v);
 delete $a{-htmlopt};
 if ($a{-arows}) {
    my $h =0;
    $a{-cols} =20 if !$a{-cols};
    if ($a{-wrap} && lc($a{-wrap}) eq 'off') {
          my @a =split /\n/, $v;
          $h =scalar(@a)
    }
    else {
       foreach my $r (split /\n/, $v) {
          $h +=1 +(length($r) >$a{-cols} ? int(length($r)/$a{-cols}) +1 :0);
       }
    }
    $a{-rows} =($a{-arows} >$h ? $a{-arows} : $h);
    delete $a{-arows}
 }
 if (defined($a{-hrefs})) {
    my $v =$v;
    my @h;
    while ($v =~/\b(\w{3,5}:\/\/[^\s\t,()<>\[\]"']+[^\s\t.,;()<>\[\]"'])/) {
       push @h, $1;
       $v =$';
    }
    $r .=join(';&nbsp;', map {$s->a({-href=>$_},$s->htmlescape($_))} @h);
    $r .='<br />' if $r;
    delete $a{-hrefs};
 }
 $r .$s->cgi->textarea(%a)
}


sub fsdir {    # Filesystem dir field
 my ($s, $nm, $ed, $ea, $fp, $fu, $fr, $sr, $sc) =@_;
 my ($nml, $nma, $nmu) =("${nm}_l", "${nm}_d", "${nm}_u");
 my $r ='';            #path#URL #URF #rows#cols
 if ($s->parent->urfcnd && $ed && $fr) {
    my $fs ='';
    if ($fr =~/^file:(.*)/i) {
        $fs =$1;
        $fs =~s/\//\\/g;
    }
    $r .=$s->cgi->a({-href=>$fr,-target=>'_blank',-title=>$s->htmlescape($s->lng(1,'Files'))}
                   ,'<strong>' .$s->htmlescape($s->lng(0,'Files')) .'&nbsp;&nbsp;&nbsp;</strong>');
    $r .='<font size=-1> ( ' .$s->htmlescape($fs) .' )</font><br />' if $fs;
    $r .='<iframe scrolling="auto" src="' .$s->htmlescape($fr) .'"';
    $r .=' application=yes';
    $r .=' height="' .$sr .'"' if $sr;
    $r .=' width="'  .$sc .'"' if $sc;
    $r .='> </iframe>';
  # !!! filefield may be useful to attach files, but file creation time will not be saved !!!
  # $r .=$s->cgi->filefield(-name=>$nmu);
  # $s->_fsdirupload($nmu, $fp) if $ea && $s->cgi->param($nmu);
    return $r;
 }
 my $fb =$s->parent->urfcnd ? ($fr ||$fu) : ($fu ||$fr);
 $r =$s->cgi->a({-href=>$fb
                ,-target=>'_blank', -title=>$s->lng(1,'Files')}
               ,'<strong>' .$s->lng(0,'Files') .'&nbsp;&nbsp;</strong>') 
               .'&nbsp;&nbsp;';
 if (!$ed) {
    my $fl =join(', '
           , map {$s->cgi->a({-href=>"$fb/$_"}, $s->htmlescape($_))} 
             eval{$s->fut->globn("$fp/*")}
           );
    $r .=$fl if $fl;
    my  $fd;
    if ($fd =$s->parent->orarg('-f',"$fp/index.html","$fp/index.htm")) {
     my $fn =($fd =~/([^\\\/]+)$/ ? $1 : $fd);
     #  $fd ='<embed scr="' ."$fb/$fn" .'" height=100% width=100% />';
     #  $fd ='<iframe scroling="auto" src="' .$s->htmlescape("$fb/$fn") .'" width=100% height=100%></iframe>';
        $fd =$s->parent->fut->fload('-b',$fd);
        $fd =$' if $fd =~m/<body\b[^>]*>/i;
        $fd =$` if $fd =~m/<\/body\b/i;
        $fd ='<base href="' .($fb) .'/" />' .$fd if $fd !~m/<base\b/i; # !!! May be a problem
        $r .='<hr />' .$fd .'<br />';
    }
 }
 elsif ($ed) {
    $s->_fsdirupload($nmu, $fp) if $ea && $s->cgi->param($nmu);
    if ($ea && $s->cgi->param($nma)) {
       foreach my $fn ($s->cgi->param($nml)) {
         $s->fut->delete('-r',"$fp/$fn");
       }
    }
    $r .=$s->cgi->filefield(-name=>$nmu); # -size
    $r .=$s->cgi->submit(-name=>$nma, -value=>$s->lng(0,'+|-'), -title=>$s->lng(1,'+|-'));
    $r .='&nbsp;&nbsp;&nbsp;';
    foreach my $fn (eval{$s->fut->globn("$fp/*")}) {
       $r .=$s->cgi->a({-href=>"$fb/$fn"}
           ,$s->cgi->checkbox(-name=>$nml, -value=>$fn, -label=>$fn))
          .'&nbsp;&nbsp;&nbsp;';
    }
 }
 $r
}


sub _fsdirupload { # Filesystem dir field file upload
 my ($s, $nmu, $fp) =@_;
 my $fa =$s->cgi->param($nmu);
 if ($fa) {
    my $fn =$fa =~/[\\\/]([^\\\/]+)$/ ? $1 : $fa;
    my $fh =$s->cgi->upload($nmu);
    if ($fh) {
       $s->pushmsg("upload '$fn' from '$fa'");
       binmode($fh);
       eval('use File::Copy');
       File::Copy::copy($fh, "$fp/$fn")
       ||$s->die("Upload '$fn' from '$fa': $!\n");
       close($fh);
    }
    else {
      $s->die("Empty filehandle '$fn' from '$fa': " .($!||$@||'') ."\n");
    }
 }
}
