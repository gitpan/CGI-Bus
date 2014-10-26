#!perl -w
#
# CGI::Bus::tm - database Transaction page Manager to view and edit data
#
# admiral 
#
# 

package CGI::Bus::tm;
require 5.000;
use strict;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Bus::Base;
use vars qw(@ISA);
@ISA =qw(CGI::Bus::Base);

my %img =
    (-lgn=>'small/key.gif' # small/key link
    ,-nap=>'portal.gif'    # portal hand.up up
    ,-nup=>'hand.up.gif'   # hand.up up
    ,-nth=>'script.gif'
    ,-bck=>'back.gif'      # back left
    ,-lst=>'text.gif'
    ,-lsr=>'text.gif'
    ,-qry=>'index.gif'
    ,-crt=>'generic.gif'   # generic c burst
    ,-sel=>'up.gif'        # forward up
    ,-edt=>'quill.gif'     # quill image1
    ,-frm=>'forward.gif'   # f layout forward continued
    ,-upd=>'down.gif'      # quill down
    ,-del=>'broken.gif'    # bomb broken
    ,-ins=>'burst.gif'
    ,-hlp=>'unknown.gif'
   );
 # %img =();  # !!! comment to turn off toolbar image buttons !!!

1;



sub new {
 my $c=shift;
 my $s ={};
 bless $s,$c;
 $s =$s->CGI::Bus::Base::initialize(@_);
 $s->parent->set('-reset')->{'-' .$s->classt}=1 if $s->parent;
 $s =$s->initialize(@_);
}


sub initialize {
 my $s =shift;
 %$s =(                # Actual slots
                      ## Predefined for children only
                       # -----------------------
   -cmd    =>undef     # Transaction command
 #,-cmdg   =>undef     # Generic Transaction command (exclude -frm -ins -upd)
 #,-cmdc   =>undef     # Transaction command cached by cnd
 #,-cmde   =>undef     # Transaction edit mode

  ,-pxcb   =>'_tcb_'   # Transaction command or button prefix
  ,-pxsw   =>'_tsw_'   # Special widget prefix
  ,-pxpv   =>'_tpv_'   # Previous value parameter prefix for -upd
  ,-pxqc   =>'_tqc_'   # Query condition parameter prefix for save by -lst

 #,-cnd    =>undef     # Transaction condition string 

 #,-tbarl  =>undef     # ToolBar Left
 #,-tbarr  =>undef     # ToolBar Right

 #,-opflg  =>undef     # Operations allowed: '<','a'll,'c'reate,'e'dit,'v'iew,'l'ist,'q'uery,'i'nsert,'u'pdate,'d'elete,'s'elect
 # -form   =>undef    ## Data form description
 #,-fields =>undef    ## Fields from Form, by _formarrange()
 #,-keyfld =>undef    ## Key field (for versioning and file store)
 #,-ftext  =>undef    ## Full-text search expression template
 #,-formtgf=>undef     # Form Target Frame: '_BLANK', '', undef
 #,-lists  =>undef     # Data views description
  ,-listrnm=>256      ## View Rows Number Default Margin
  ,-lboxrnm=>1024     ## Listbox Rows Number Margin
 #,-filter =>undef    ## Data filter string or sub
 #,-fltsel =>undef    ## Select filter string or sub
 #,-fltlst =>undef    ## List filter string or sub
 #,-fltedt =>undef    ## Edit filter string or sub
 #,-rowlst =>undef    ## Row Listing filter
 #,-rowsel =>undef     # Row Select to view allow
 #,-rowedt =>undef     # Row Edit mode allow
 #,-rowsav =>undef    ## Row Save allow
 #,-rowsav1=>undef    ## Row Save allow before SQL for edited record
 #,-rowsav2=>undef    ## Row Save allow before each SQL
 #,-rowins =>undef    ## Row Insert allow
 #,-rowupd =>undef    ## Row Update allow
 #,-rowdel =>undef    ## Row Delete allow

 #,-vsd    =>undef    ## Version Store Definition
 #,-fsd    =>undef    ## File Store Definition
 #,-acd    =>undef    ## Access Control Definition

 #,-htmlts =>undef     # HTML table start for form or view, default is <table>
 #,-htmlte =>undef     # HTML table end   for form or view, default is </table>
 #,-width  =>undef     # HTML table width for form or view, default is window width

 #,-gensel =>undef    ## Generated SQL Select
 #,-genlstm=>undef    ## Genetared SQL Select List Message
 #,-genedt =>undef    ## Generated SQL Insert | Update | Delete
 #,-genwhr =>undef    ## Generated Where
 #,-genfrom=>undef    ## Generated From

 );
 $s->set(@_);
 $s
}


sub set {
 return(keys(%{$_[0]})) if scalar(@_) ==1;
 return($_[0]->{$_[1]}) if scalar(@_) ==2;
 my ($s, %opt) =@_;
 foreach my $k (keys(%opt)) {
  $s->{$k} =$opt{$k};
 }
 $s->_setform  if $opt{-form};
 $s->_setlists if $opt{-lists};
 $s
}


sub _setform {   # Arrange Form
 my $s =shift;
 $s->{-fields} ={};
 my ($st, $sta);
 my $lng  =$s->lngname;
 my $lngl ='-lbl' .($lng ? "_$lng" : '');
 my $lngc ='-cmt' .($lng ? "_$lng" : '');
 foreach my $f (@{$s->{-form}}) {
   next if !ref($f) || ref($f) eq 'CODE' ||!$f->{-fld};
   $s->{-fields}->{$f->{-fld}} =$f;
   if ($lng) {
      $f->{-lbl} =$f->{$lngl} if $f->{$lngl};
      $f->{-cmt} =$f->{$lngc} if $f->{$lngc};
   }
 }
 $s
}


sub _setlists {  # Arrange Lists
 my $s =shift;
 my $lng  =$s->lngname;
 my $lngl ='-lbl' .($lng ? "_$lng" : '');
 my $lngn ='-lst' .($lng ? "_$lng" : '');
 my $lngc ='-cmt' .($lng ? "_$lng" : '');
 return if !$lng;
 foreach my $f (values %{$s->{-lists}}) {
   next if !ref($f) || ref($f) eq 'CODE';
   if ($lng) {
      $f->{-lbl} =$f->{$lngl} if $f->{$lngl};
      $f->{-lst} =$f->{$lngn} if $f->{$lngn};
      $f->{-cmt} =$f->{$lngc} if $f->{$lngc};
   }
 }
 $s
}



###################################
# UTILITY METHODS
###################################


sub _img {
 $_[0]->parent->{-iurl} && $img{$_[1]} 
 ? ('<img src="' .$_[0]->parent->{-iurl} .'/' .$img{$_[1]} .'" alt="" border=0 />')
 : ''
}

sub pxnme {    # Prefixed Name
 $_[0]->{$_[1]} .(substr($_[2],0,1) eq '-' ? substr($_[2],1) : $_[2])
}

sub pxcb {     # Command button name
 shift->pxnme(-pxcb=>@_)
}

sub pxsw {     # Special widget name
 shift->pxnme(-pxsw=>@_)
}

sub pxpv {     # Previous value name
 shift->pxnme(-pxpv=>@_)
}

sub pxqc {     # Query condition name
 shift->pxnme(-pxqc=>@_)
}

sub qparamsw { # Special widget value
 $_[0]->parent->qparam(
    ref($_[1]) eq 'ARRAY' 
    ? [map {$_[0]->pxnme(-pxsw=>$_)} @{$_[1]}] 
    : $_[0]->pxnme(-pxsw=>$_[1])
 ,@_[2..$#_])
}

sub qparampv { # Query param previous value
 $_[0]->parent->qparam(
    ref($_[1]) eq 'ARRAY' 
    ? [map {$_[0]->pxnme(-pxpv=>$_)} @{$_[1]}] 
    : $_[0]->pxnme(-pxpv=>$_[1])
 ,@_[2..$#_])
}


sub qparampx { # Prefixed query parameters
 my $s  =shift;
 my $px =shift;  # param name prefix
    $px =!defined($px) ? ''   
          : substr($px,0,1) eq '-' ? ($s->{$px} ||$px)
          : $px;
 if    (!defined($_[0])) {}
 elsif (ref($_[0]) eq 'ARRAY') {return $s->parent->qparam([map {$px .$_} @{$_[0]}], @_[1..$#_])}
 elsif (ref($_[0]) eq 'HASH')  {return $s->parent->qparam({map {$px .$_ => $_[0]->{$_}} keys %{$_[0]}}, @_[1..$#_])}
 else  {return $s->parent->qparam($px .$_[0], @_[1..$#_])}
 my $r  =[];
 foreach my $e ($s->cgi->param) {
   next if $px ne '' ? substr($e,0,length($px)) ne $px
        : grep {$s->{$_} eq substr($e,0,length($s->{$_}))} qw(-pxpv -pxsw -pxcb -pxqc);
   push @$r, $e;
 }
 $r
}



###################################
# DECLARATIONS UTILITY METHODS
###################################


sub qlst {         # Query List Name
 my $s =shift;
 my $l =$s->qparamsw('LIST');
 return($l)    if $l && $s->{-lists} && $s->{-lists}->{$l};
 return(undef) if !$s->{-lists};
 my @a =sort keys %{$s->{-lists}};
 foreach my $v (@a) {
   next if substr($v,length($v)-1) ne '_';
   return($l =$v);
 }
 $l =$a[0];
}


sub qlstnmes {     # Lists Names
 my $l =$_[0]->{-lists};
 my $r =[];
 if ($l) {
    foreach my $e (keys %$l) {
      next if substr($e,0,1) eq '_';
      push @$r, $e
    }
 }
 [sort {($l->{$a}->{-lbl}||$l->{$a}->{-lst}||$a) cmp ($l->{$b}->{-lbl}||$l->{$b}->{-lst}||$b)} @$r]
}


sub qlstlbls {     # Lists Labels
 my $l =$_[0]->{-lists};
 my $r ={};
 if ($l) {
    foreach my $e (keys %$l) {
      next if substr($e,0,1) eq '_' || !($l->{$e}->{-lbl}||$l->{$e}->{-lst});
      $r->{$e} =($l->{$e}->{-lbl}||$l->{$e}->{-lst})
    }
 }
 $r
}



###################################
# TRANSACTION METHODS
###################################


sub cmd {      # Transaction command schema
 if (!defined($_[0]->{-cmd})) { # Init command
    my $s =$_[0];
    my $g =$s->cgi;
    if ($g->param($s->pxnme(-pxcb=>'-lgn'))) {
        $s->parent->userauth
    }
    $s->{-opflg} =$s->parent->uguest ? 'qv' : 'a!v' if !defined($s->{-opflg});
    foreach my $p (qw(-lst -lsr -qry -crt -sel -edt -frm -ins -upd -del -hlp)) { # post
      next if !($g->param($s->pxnme(-pxcb=>$p)) 
              ||$g->param($s->pxnme(-pxcb=>$p .'.x')));
      $g->delete($s->pxnme(-pxcb=>$p .'.x')); 
      $g->delete($s->pxnme(-pxcb=>$p .'.y'));
      $g->param ($s->pxnme(-pxcb=>$p), 1);
      $s->{-cmd} =$p; last
    }
    $s->{-cmd} =$g->param($s->pxnme(-pxcb=>'-cmdi')) if !$s->{-cmd};
    $s->{-cmdg}=$s->{-cmd} ||$g->param($s->pxnme(-pxcb=>'-cmd')) # get
              ||$g->param('_cmd') || $s->parent->qrun ||'-lst';
    if (!$s->{-cmd}) {
       $s->{-cmd} =$g->request_method() eq 'POST' 
                   && (!$s->{-cmdg} ||$s->{-cmdg} ne '-lst')
                   ? '-frm' : ($s->{-cmdg} ||'-lst' ||'');
    }
    foreach my $v (undef, $g->param($s->pxnme(-pxcb=>'-cmd')), '') {
       last if $s->{-cmdg} && !grep {$s->{-cmdg} eq $_} qw(-frm -ins -upd);
       $s->{-cmdg} =$v
    }
    if (($s->{-opflg} !~/!v/ ||$s->{-opflg} =~/[av]/) && $s->{-cmd} eq '-sel') {
       $g->delete($s->pxsw('EDIT')) # !!! !v <-> [av] !!!
    }
    if ($s->{-cmd} eq '-edt') {
       $s->{-cmd} =$s->{-cmdg} ='-sel';
     # $s->{-cmd} ='-frm';
       $s->qparamsw('EDIT',!$s->qparamsw('EDIT'));
       $g->delete($s->pxsw('EDIT')) if !$s->qparamsw('EDIT')
    }
    if ($s->{-cmd} eq '-lsr') { # convert '-lsr'->'-lst'
       $s->{-cmd} = $s->{-cmdg}='-lst';
       my $l=length($s->{-pxqc});
       foreach my $p ($g->param) {
         next if (substr($p, 0, $l) eq $s->{-pxqc});
         $g->delete($p)
       }
       foreach my $p ($g->param) {
         next if (substr($p, 0, $l) ne $s->{-pxqc});
         my $n =$s->pxnme(-pxqc=>$p);
         $g->param($p, $g->param($n));
         $g->delete($n)
       }
    }
    $s->{-cmde} =$s->cmdg('-crt')
              ||($s->cmdg('-sel') 
                && ($s->{-opflg} =~/!v/ 
                   ||  $s->{-opflg} !~/[av]/ 
                   || ($s->{-opflg} =~/[av]/ 
                      && $s->qparamsw('EDIT'))));
    $s->{-formtgf} ='_BLANK' if !defined($s->{-formtgf}) 
                  && $s->cgi->user_agent =~/Lotus-Notes/i; # & StarOffice without jvm
 }

 if    (!$_[1]) {               # Current command
    return $_[0]->{-cmd}
 }
 elsif ( $_[1] eq '-cmd') {     # Run all defined
    foreach my $c (qw(-chk -ins -upd -del -sel -crt -qry -htm -frm -lst -hlp)) {
       next if !$_[0]->cmd($c);
       my $cmd ='cmd' .substr($c,1);
       if ($_[0]->{"-$cmd"}) { &{$_[0]->{"-$cmd"}}($_[0],$c) }
       else  {$_[0]->$cmd()}
    }
    return 1
 }
 my $c =$_[0]->{-cmd};          # Used command
 my $f =$_[0]->{-opflg};        # Allow flags
 my $q =$_[1];                  # Queried command
 my $r =($q eq $c
  ||($q eq '-chk' && grep {$c eq $_} qw(-ins -upd -del)) 
                   # check fields before insert or update
  ||($q eq '-ret' && grep {$c eq $_} qw(-ins -upd -del)) 
                   # return after edit - optional
  ||($q eq '-sel' && grep {$c eq $_} qw(-ins -upd)) 
                   # select after insert, update
  ||($q eq '-htm' && $c ne '-hlp')
                   # html before list, create, select, message
  ||($q eq '-frm' && grep {$c eq $_} qw(-qry -ins -upd -crt -sel)) 
                   # form after create, select
  ||($q eq '-end') # end transaction; result message
 )&&($q eq '-sel' ? $f =~/[avcieud]/
    :$q eq '-qry' ? $f =~/[aq]/
    :$q eq '-ins' ? $f =~/[aci]/
    :$q eq '-upd' ? $f =~/[aeu]/
    :$q eq '-del' ? $f =~/[ad]/
    :$q
    );
 $r
}


sub cmdg {     # Transaction generic command
 my $c =$_[0]->{-cmdg} || ($_[0]->cmd, $_[0]->{-cmdg});
 return($c) if @_ <2;
 grep {$c eq $_} @_ 
}


sub cnd    {   # Transaction command SQL condition string
 my $s  =shift;
 return $s->{-cnd} if !defined($_[0]);

 my $g  =$s->cgi;
 my $c  =$s->{-cmdc} =substr($_[0],0,1) eq '-' ? shift : ($s->{-cmdc} ||'-sel');
 my $fb =$_[0] =~/\-(and|or)/i ? shift && $1 : ''; # prepend 'and' || 'or'
 my $fe =$_[0] =~/\+(and|or)/i ? shift && $1 : ''; # append  'and' || 'or'
 $s->cmd() if !$s->{-cmd};

 my $fl =$c eq '-lst';     # flag list: expressions use
 my $fp =$c =~/-upd|-del/  # flag param prefix
        ?$s->{-pxpv} :'';
 my $px ='';               # current colname prefix
 my $rs ='';               # return string
 while (@_) {
   my ($pp, $pf, $pm, $pv);
   if (substr($_[0],-1) eq '.') { # prefix
      $px = $_[0] eq '.' ? '' : $_[0]; shift 
   }
   $pp =shift;                    # field
   if (substr($_[0],-1) eq '=') { # column
      $pf = substr($_[0],0,-1); shift 
   }
   else {
      $pf =$pp 
   }
   $pf =$px .$pf;                 # full qualified colname
   if ($_[0] =~/^[kw'"]*$/
     ||$_[0] =~/\?/ ||ref($_[0])){# mask
      $pm =shift;                    
   }   
   else {
      $pm ='';
   }
   $pv =$g->param($fp .$pp);      # value
   next if $fl && (!defined($pv) || $pv eq '');
   if    ($fl && $pv =~/^([=><]|is |like |in )/i) {
         $pv  =~s/(\&|\|) +([=><]|is |like |in )/$1 $pf $2/ig;
         $rs .=' AND ' .$pf .$pv;
         next;
   }
   elsif ($fl && $pv =~/^null/i) {$rs .=' AND ' .$pf .' is NULL'; next}
   elsif (!defined($pv))  {$rs .=' AND ' .$pf .' is NULL'; next}

   $rs .=' AND ' .$pf .'=';
   if    (ref($pm)) {        # sub
      local $_ =$pv;
      $rs .=&{$pm}($s,$pv)
   }
   elsif ($pm =~/'"/) {      # quote
      $rs .=($s->dbi ? $s->dbi->quote($pv) :"'$pv'")
   }
   elsif ($pm =~/[^\\]\?/) { # text mask with '?' placeholders
      my $t =$pm; $t =~s/\?/$pv/g;
      $rs .=$t
   }
   else {                    # do not quote
      $rs .=$pv
   }

 }
 if ($rs) {                       # return string
    $rs =substr($rs,5);
    $rs =($fb ? " $fb " : '') ."($rs)" .($fe ? " $fe " : '');
 } 
 $s->{-cnd} =$rs
}


sub htmlbar {  # Transaction batton bar html
 my ($s, $o) =@_;
    $o =($s->{-opflg} ||($s->parent->uguest ? 'qv' : 'a!v')) if !defined($o);
 my $p =$s->parent;
 my $g =$p->cgi;
 my $r ='';
 $s->cmd() if !$s->{-cmd};
 if ($s->{-cmd} eq '-ins') {
  # $s->{-cmd}  ='-sel';
    $s->{-cmdg} ='-sel'
 }
 my $vm = !$s->{-cmde};
 if ($s->{-logo}) {
    $r .=$s->_htmlbare($s->{-logo} !~/<a /i 
         ? '<a href="' .$p->surl .'">' .($s->{-logo} !~/</ ? '<img src="' .$s->{-logo} .'" alt="" border=0 title="' .$s->lng(1,'-nap') .'" />' : $s->{-logo}) .'</a>' 
         : $s->{-logo});
 }
 if ((!$ENV{HTTP_REFERER}
     ||eval {my $rfr =lc(($ENV{HTTP_REFERER}||'') =~/^(.+?)\/([^\/]+)$/ ? $1 : $ENV{HTTP_REFERER}) ||'';
       lc(substr($s->parent->url, 0, length($rfr))) ne $rfr}) 
 && $s->parent->uguest) {

    $r .=$s->_htmlbare(-lgn => $s->uauth->authurl);
 }
 if (index($o,'<') >=0) {
    $r .=$s->_htmlbare(-nap, $p->surl) if !$s->{-logo};
    my $nth =$s->qurl;
    my $nup =$s->qparamsw('REFERER') ||$ENV{HTTP_REFERER} ||($s->burl .'/');
       $nup =$s->burl .'/' if lc(substr($nup,0,length($nth))) eq lc($nth);
  # $r .=$s->_htmlbare(-nup, $nup);
    $r .=$s->_htmlbare(-nth, $nth);
 }
 if ($s->{-tbarl}) {
    $r .=$s->_htmlbare($s->{-tbarl});
 }
 if ($s->cmdg('-lst')) {
    $r .=$s->_htmlbare(-bck => $p->{-iurl} && $img{-bck} ? $p->qurl : 0
                      ,-onClick=>'{window.history.back(); return(false)}') #window.event.returnValue=false;
             if !$s->{-formtgf};
    $r .=$s->_htmlbare($g->popup_menu(-name=>$s->pxnme(-pxsw=>'LIST')
                      ,-values=>$s->qlstnmes
                      ,-labels=>$s->qlstlbls
                      ,-default=>$s->qlst
                      ,-onChange=> (!$p->{-iurl}
                          ? $s->pxnme(-pxcb=>'-lst') .'.click()'
                          : '{' .$s->pxnme(-pxcb=>'-cmdi') .'.value="-lst"; submit(); return(false);}')
                      ))
             if $s->{-lists} && scalar(keys %{$s->{-lists}}) >1;
    $r .=$s->_htmlbare($p->htmltextfield(-name =>$s->pxsw('FTEXT')
                      ,-title=>$s->lng(1,'F-TEXT')
                      ,-asize=>4)) 
             if $s->{-ftext};
    $r .=$s->_htmlbare('-lst');
    $r .=$s->_htmlbare('-qry') if $o =~/[aq]/;
 }
 else {
    $s->cgi->delete($s->pxnme(-pxsw=>'FRMCOUNT')) if $s->cmd('-crt');
    $r .=$s->_htmlbare('-bck'=> $p->{-iurl} && $img{-bck} ? $p->qurl : 0
                      ,-onClick=>'{window.history.go('
                      .-($g->param($s->pxnme(-pxsw=>'FRMCOUNT'))||1) .'); return(false)}')
             if !$s->{-formtgf};
 }
 if ($s->cmdg('-qry') && $o =~/[aq]/) {
    $r .=$s->_htmlbare('-lst');
    $r .=$s->_htmlbare('-frm');
 }
 if (!$s->cmdg('-lst','-qry')) {
    $r .=$s->_htmlbare('-lsr') if !$s->{-formtgf};

    # !!! '-sel' may be useful; '-edt' does not saves changes; see 'cmd' -sel transition
    $r .=$s->_htmlbare('-sel') if $o =~/[aev]/ && $s->cmdg eq '-sel' && $o !~/!s/;
    $r .=$s->_htmlbare('-edt') if $o =~/[av]/  && $s->cmdg eq '-sel' && $o !~/!v/ && $vm;

    $r .=$s->_htmlbare('-frm') if $o =~/[aeu]/ && $s->cmdg ne '-del' && !$vm;
    $r .=$s->_htmlbare('-upd') if $o =~/[aeu]/ && $s->cmdg eq '-sel' && !$vm;
    $r .=$s->_htmlbare('-ins') if $o =~/[aci]/ && $s->cmdg ne '-del' && !$vm;
    $r .=$s->_htmlbare('-del') if $o =~/[ad]/  && $s->cmdg eq '-sel';
 }
 if ($o =~/[aci]/ && !$s->cmdg('-qry')) {
    if (!$s->{-formtgf}) {$r .=$s->_htmlbare('-crt')}
    else {
    $r .=$s->_htmlbare('-crt'
                      ,$s->htmlurl($s->qurl, $s->pxcb('-cmd')=>'-crt')
                      ,-target=>$s->{-formtgf})
    }
 }
 if ($s->{-tbarr}) {
    $r .=$s->_htmlbare($s->{-tbarr});
 }
 if (1) {
    $r .=$s->_htmlbare('-hlp'
                      ,$s->htmlurl($s->qurl,$s->pxcb('-cmd')=>'-hlp')
                      ,-target=>$s->{-formtgf});
 }
 if (1) {
    $r .='<td valign="middle" align="right">';
    $r .='&nbsp;[' .$s->lng(0,$s->cmd) 
             .(!$s->cmdg ||$s->cmd eq $s->cmdg ?'' : ('/' .$s->lng(0,$s->cmdg)))
             .']&nbsp;';
    $r .="</td>\n"
 }
 $r  ="<table cellpadding=0><tr>\n" .$r ."</tr></table>\n";
#$r .='<hr />';
 $r
}


sub _htmlbare { # Transaction batton bar element
 my ($s, $b, $u, %a) =@_;
 my $p =$s->parent;
 my $g =$p->cgi;
 my ($v, $t);
    ($v, $t) =($s->lng(0,$b), $s->lng(1,$b)) if !ref($b) && $s->lng($b);
 my $h = ref($b) ? join('</td><td valign="middle">', @$b)
       : $u ? $g->a({-href=>$u,%a,-title=>$t
                  # ,-style=>"{border-color:buttonface;border-width:thin;border-style:outset;background-color:buttonface}"
                  # ,-style=>"{background-color:buttonface;border-style:outset;border-width:thin}"
                  # ,-style=>"behavior:url(#default#behaviorName)"
                  # ,-style=>"behavior:url(behaviorFile.htc)"
                    }
                   , $p->{-iurl} && $img{$b} 
                   ? '<img src="' .$p->{-iurl} .'/' .$img{$b} .'" border=0 align=bottom />' .'<font size=-1>' .$p->htmlescape($v) .'</font>'
                   : $p->htmlescape($v)) .' '
       : $v ? ( $p->{-iurl} && $img{$b}
              ? $g->image_button(-name=>$s->pxnme(-pxcb=>$b)
                       ,-value=>$v
                       ,-src=>$p->{-iurl} .'/' .$img{$b}
                       ,-align=>'bottom'
                       ,-accesskey=>substr($v,0,1)
                       ,-title=>$v .'. ' .$t
                       , %a) 
                       .$g->a({href=>$s->qurl('',$s->pxnme(-pxcb=>'-cmd')=>$b),-title=>$t, -onClick=>'{' .$s->pxnme(-pxcb=>'-cmdi') .'.value="'.$b .'"; submit(); return(false)}'}, '<font size=-1>' .$p->htmlescape($v) .'</font>')
                     # !!! variants below does not works, -cmdi hidden variable added for above !!!
                     # .'<font size=-1>' .$g->a({href=>$s->qurl('',$s->pxnme(-pxcb=>'-cmd')=>$b), -onClick=>'{var o=new submit; o.name="' .$s->pxnme(-pxcb=>$b) .'"; o.value="1"; forms[0].submit(); return(false)}'}, $p->htmlescape($v)) .'</font>'
                     # .'<font size=-1>' .$g->a({href=>$s->qurl('',$s->pxnme(-pxcb=>'-cmd')=>$b), -onClick=>'{' .$s->pxnme(-pxcb=>$b).'.click(); return(false)}'}, $p->htmlescape($v)) .'</font>'
                     # .'<font size=-1>' .$g->a({href=>$s->qurl('',$s->pxnme(-pxcb=>'-cmd')=>$b), -onClick=>$s->pxnme(-pxcb=>$b).'.click()'}, $p->htmlescape($v)) .'</font>'
              : defined($u)
              ? $g->button(-name=>$s->pxnme(-pxcb=>$b)
                     # ,-style=>"{border-style:none}"
                       ,-value=>$b eq '-bck' ? '<-' : $v
                       ,-accesskey=>substr($v,0,1)
                       ,-title=>$t
                       ,%a
                       )
              : $g->submit(-name=>$s->pxnme(-pxcb=>$b)
                     # ,-style=>"{border-style:none}"
                       ,-value=>$v
                       ,-accesskey=>substr($v,0,1)
                       ,-title=>$t
                       ,%a)
              ) .' '
            : $b;
 chomp($h);
 '<td valign="middle"'
 .($p->{-iurl} ? ' style="{border-width:thin;border-style:outset;background-color:buttonface}"' :'')
 .'><nobr>' . # style="{border-width:thin;border-style:groove;background-color:buttonface}"
              # style="{border-width:thin;border-style:outset;background-color:buttonface}"
 $h # ($b eq $s->{-cmd} ? $g->strong(' ' .$h .' ') : $h)
 ."</nobr></td>\n"
}


sub htmlhid {   # Transaction hidden html
 my $s =shift;
 my $c =$_[0] && substr($_[0],0,1) eq '-' ? shift : '';
 my $r ='';
 my $g =$s->cgi;
 my $lp=length($s->{-pxpv});
 my $lb=length($s->{-pxcb});
 my $lq=length($s->{-pxqc});
 my $ls=length($s->{-pxsw});
                            # store generic transaction command
 $r .=$g->hidden(-name=>$s->pxnme(-pxcb=>'-cmd')
                ,-value=>$s->{-cmdg}
                ,-override=>1)
      if $c ne '-lst';
                            # declare immediate or image transaction command
 $r .=$g->hidden(-name=>$s->pxnme(-pxcb=>'-cmdi')
                ,-value=>''
                ,-override=>1);

                            # store/preserve up referer
 $r .=$g->hidden(-name=>$s->pxnme(-pxsw=>'REFERER'), -value=>
       ( $s->param($s->pxnme(-pxsw=>'REFERER'))
       ||$ENV{HTTP_REFERER}
       ||$s->burl)
      ,-override=>1);

 if ($s->cmd(-sel)) {       # -sel: save previos values after record selection
    foreach my $p ($g->param) {
      next if substr($p, 0, $lp) eq $s->{-pxpv};
      next if substr($p, 0, $lb) eq $s->{-pxcb};
      next if substr($p, 0, $lq) eq $s->{-pxqc};
      next if substr($p, 0, $ls) eq $s->{-pxsw};
      $r .=$g->hidden(-name=>$s->pxnme(-pxpv=>$p)
                     ,-value=>$g->param($p),-override=>1)
    }
 }

 if ($s->{-cmde}) {
    $r .=$g->hidden(-name=>$s->pxsw('EDIT'), -value=>'1')
 }

 if ($s->cmd eq '-frm') {   # -frm: preserve -pxpv in form recalculations
    foreach my $p ($g->param) {
      next if substr($p, 0, $lp) ne $s->{-pxpv};
      next if substr($p, 0, $lb) eq $s->{-pxcb};
      $r .=$g->hidden(-name=>$p 
                     ,-value=>$g->param($p),-override=>1)
    }
 }

 if ($s->cmd(-lst)) {       # -lst: set -pxqc, preserve other fields
    foreach my $p ($g->param) {
      next if substr($p, 0, $lq) eq $s->{-pxqc};
      next if substr($p, 0, $lb) eq $s->{-pxcb};
      next if $p eq $s->pxnme(-pxsw=>'FRMCOUNT');
      next if $p eq $s->pxnme(-pxsw=>'EDIT');
      $r .=$g->hidden(-name=>$s->pxnme(-pxqc=>$p)
                     ,-value=>$g->param($p),-override=>1);
      $r .=$g->hidden(-name=>$p
                     ,-value=>$g->param($p),-override=>1)
    }
 }
 else {                     # preserve -pxqc when data edit
    foreach my $p ($g->param) {
      next if substr($p, 0, $lq) ne $s->{-pxqc};
      next if substr($p, 0, $lb) eq $s->{-pxcb};
      $r .=$g->hidden(-name=>$p 
                     ,-value=>$g->param($p),-override=>1)
    }
    $r .=$g->hidden(-name=>$s->pxnme(-pxsw=>'FRMCOUNT')
                   ,-value=>($g->param($s->pxnme(-pxsw=>'FRMCOUNT'))||1) +1
                   ,-override=>1)
 }

 $r ."\n"
}


sub htmlself { # Self Hyperlink
 my $s =shift;
 my $d =pop;
 my $a =ref($_[$#_]) ? pop : ref($_[0]) ? shift :[];
 $s->a({href=>$s->htmlurl($s->qurl,$s->pxnme(-pxcb=>'-cmd'), @_)
       ,-target=>$s->{-formtgf}
       ,(ref($a) eq 'ARRAY' ? @$a : %$a)}
       ,$d)
}


sub htmlres {   # Transaction command result msg html
 my $s =$_[0];
 my $g =$s->cgi;
 my $c =defined($_[1]) ? $_[1] : !$@;
 my $m =defined($_[2]) ? $_[2] :  $@||'';
 my $t =scalar(@{$s->pushmsg}) >1 ||(scalar(@{$s->pushmsg}) ==1 && $s->pushmsg->[0] ne 'COMMIT');
 my $r ='';
 if (!$s->parent->{-cache} ||!$s->parent->{-cache}->{-httpheader}) {
    $r =$s->parent->htpgstart;
 }
 if (!$c) {
    my $h =$s->lng(0,'Failure') ." '" .$s->lng(0,$s->{-cmd}) ."': ";
    my $e =$s->htmlescape($m);
  # $r .=$g->hr ."<font color=red><strong>$h</strong></font>" .$e
    $r .=$g->hr ."<h1>$h</h1>" .$e
 }
 elsif ((grep {$s->{-cmd} eq $_} qw(-sel -ins -upd -del)) ||$t) {
    $r .=$g->hr .'<strong>'
       .($s->cmd('-lst') && $s->{-genlstm} ? $s->{-genlstm}
        : ($s->lng(0,'Success') ." '" .$s->lng(0,$s->{-cmd}) ."'"))
       .'</strong> ';
    $r.=$s->htmlescape($s->parent->set('-problem')) if $s->parent->set('-problem');
 }
 if ($r && (!$c || ($s->parent->{-debug} ||0) >0)) {
    my $r1 =join(';<br />', map {$s->htmlescape($_)} @{$s->pushmsg});
    $r1  ='<font size=-1>' .$r1 .'</font>' if $r1;
    $r  .='<br />' .$r1
 }
 if (!$c) {
    $s->pushlog('Error ' .$m, @{$s->pushmsg}, '<---Error');
 }
 elsif ($t && (grep {$s->{-cmd} eq $_} qw(-ins -upd -del))) {
    my @t;
    foreach my $t (@{$s->pushmsg}) {
       next if $t !~/^(insert|update|delete)\s/i;
       push @t, $t
    }
    $s->pushlog(@t);
 }
 $r
}


sub eval {     # Transaction run
 my $s =shift;
 my $r =ref($_[$#_]) eq 'CODE' ? pop : sub{$s->cmd('-cmd')};
 my $e =undef;
 local $s->parent->{-problem} ='';
 if (!CORE::eval {
   $r =&$r($s);
   1;
 }) {
    $e =$@ ||'Undefined Error';
    $r =undef
 }
 print $s->htmlres(!$e,$e);
 $r
}


sub evaluate { # Execution of tm
 my $s =shift;
 my $p =$s->parent;
 $s->userauthopt;
 $s->cmd;
 my $rfr =!$s->cmd('-lst') ? 0 
         :(($s->{-lists} && $s->qlst ? $s->{-lists}->{$s->qlst}->{-refresh} : 0) 
          ||$s->{-refresh});
 $s->{-cmdhtm} =sub{$s->cmdhtm(sub{;
 $p->print->htpgstart(undef
           , $rfr
           ? {$p->{-htpgstart} ? %{$p->{-htpgstart}} :()
             ,-head=>(($p->{-htpgstart} && $p->{-htpgstart}->{-head}) 
                    ||($p->{-htmlstart} && $p->{-htmlstart}->{-head})
                    ||'')
             ."<meta http-equiv=\"refresh\" content=$rfr>"}
           : $s->cmd('-lst') ||$s->cmd('-hlp')
           ? $p->{-htpgstart}
           : $p->{-htpfstart});
 # !!!Multipart forms should be escaped as possible: used only for file uploads
 $p->print( $s->{-fsd} && $s->{-fsd}->{-url} 
          && $s->cmdg !~/lst|qry/i
          && !($ENV{MOD_PERL} && $p->cgi->user_agent =~/Lotus-Notes|StarOffice/i)
          ? $s->start_multipart_form(-method=>$rfr ? 'get' : 'post', -action=>$s->qurl, -acceptcharset=>$p->{-httpheader} ?$p->{-httpheader}->{-charset} :undef)
          : $s->startform(-method=>$rfr ? 'get' : 'post', -action=>$s->qurl, -acceptcharset=>$p->{-httpheader} ?$p->{-httpheader}->{-charset} :undef));
 })} if !$s->{-cmdhtm};
 $p->print->htpfstart(undef, $p->{-htpgstart}) if $s->cmd('-hlp');
 $s->eval();
 $p->print->htpfend;
}



###################################
# TRANSACTION COMMANDS
###################################


sub cmdchk { # Check / Calculate Data before save
 my $s =shift;
 my $g =$s->cgi;
 my $c =$s->cmd;
 my @diag;
 foreach my $f (@{$s->{-form}}) { 
   next if !ref($f) || ref($f) eq 'CODE' || !$f->{-fld};
   local $_ =$g->param($f->{-fld});
   if (!$s->cmd('-del')) {
      my $n =$f->{-lbl}||$f->{-fld};
      if ($f->{-flg} =~/[mk]/ && $f->{-flg} !~/[g]/ && (!defined($_)|| $_ eq '')) {
            push @diag, $s->lng(1,'fldReq',$n)
      }
      elsif (!$f->{-chk}) {}
      elsif (!ref($f->{-chk})) {
            push @diag, "'$n' !'" .$f->{-chk} ."'" if !CORE::eval $f->{-chk};
      }
      elsif (ref($f->{-chk}) eq 'CODE') {
            push @diag, "'$n'" if !&{$f->{-chk}}($s);
      }
      elsif (ref($f->{-chk}) eq 'ARRAY') {
            push @diag, "'$n' !'" .$f->{-chk}->[1] ."'" if !&{$f->{-chk}->[0]}($s);
      }
   }
   foreach my $c (qw(-frm -sav)) {
      next if !defined($f->{$c});
      $g->param($f->{-fld}, ref($f->{$c}) ? &{$f->{$c}}($s) : $f->{$c})
   }
   if (grep {$c eq $_} qw(-ins -upd -del)) {
      next if !defined($f->{$c});
      $g->param($f->{-fld}, ref($f->{$c}) ? &{$f->{$c}}($s) : $f->{$c})
   }
 }
 $s->die($s->lng(1,'!constr') .': ' .join('; ',@diag) ."\n") if scalar(@diag);
 $s
}



sub cmdcrt { # Create Fields
 my $s   =shift;
 my $g   =$s->cgi;
 foreach my $f (@{$s->{-form}}) { 
   next if !ref($f) || ref($f) eq 'CODE' || !$f->{-fld} || !defined($f->{-crt});
   local $_ =$g->param($f->{-fld});
   my $v =ref($f->{-crt}) eq 'CODE' ? &{$f->{-crt}}($s)
         :$f->{-crt};
   $g->param($f->{-fld},$v) if defined($v);
 }
 foreach my $f (@{$s->{-form}}) { 
   next if !ref($f) || ref($f) eq 'CODE' || !$f->{-fld} || defined($f->{-crt});
   $g->delete($f->{-fld});
 }
 $s
}



sub cmdqry { # Query Condition Init
 my $s   =shift;
 my $g   =$s->cgi;
 foreach my $f (@{$s->{-form}}) { 
   next if !ref($f) || ref($f) eq 'CODE' || !$f->{-fld} || !defined($f->{-qry}) 
        || defined($g->param($f->{-fld}));
   my $v =ref($f->{-qry}) eq 'CODE' ? &{$f->{-qry}}($s)
         :$f->{-qry};
   $g->param($f->{-fld},$v) if defined($v);
 }
 $s
}



sub cmdhtm { # Common HTML
  my $s =shift;

  $s->die($s->lng(1,'op!let',$s->lng(0,'-sel')) ."\n")
                     if $s->{-rowsel} && $s->cmd(-sel) && !&{$s->{-rowsel}}($s);
  $s->{-cmde} =undef if $s->{-rowedt} && $s->{-cmde}   && !&{$s->{-rowedt}}($s);

  &{shift @_}(@_) if ref($_[0]) eq 'CODE';
  $s->print($s->htmlbar) if ($s->qparamsw('MIN')||'')  !~/b/;
  $s->print($s->htmlhid);
  $s
}



sub cmdfrm { # Record form for Query or Edit
 my $s =shift;
 my $p =$s->parent;
 my $g =$p->cgi;
 my $c =$_[1] ||substr($s->cmdg||$s->cmd,1,1);
    $c ='e' if $c eq 's' || $c eq 'f';
 my $vm = !$s->{-cmde} && $c eq 'e';
 my $rskip =1;
 $p->print->strong($p->htmlescape($p->{-htmlstart}->{-title}||$p->{-htpgstart}->{-title}||''));
 $p->print->hr;
 $p->print($s->{-htmlts} ? $s->{-htmlts} : '<table>', "\n<tr>\n");
 $p->print('<th colspan=20><nobr>' 
          ,('&nbsp;' x $s->{-width}) 
          ,"</nobr></th></tr>\n<tr>\n"
          ) if $s->{-width};
 foreach my $f (@{$s->{-form}}) {
   if    ($f eq '')          {$rskip =1; next}
   elsif ($f eq "\t")        {
          $p->print('</tr><tr>') if !$rskip;
          $rskip =1;
          $p->print->td(' ');
          next
   }
   elsif (!ref($f))          {$p->print($f); next}
   elsif (ref($f) eq 'CODE') {$p->print(&$f($s)); next}
   next if !$f->{-fld};

   local $_ =$s->param($f->{-fld});
   my $excl =$f->{-flg} !~/[a$c]/ && !($c =~/[ce]/ && $f->{-flg} =~/[av$c]/);
   my $hide =$c ne 'q' 
           && ((ref($f->{-hide})  eq 'CODE' ? &{$f->{-hide}}($s)  : $f->{-hide})
           ||  (ref($f->{-hidel}) eq 'CODE' ? &{$f->{-hidel}}($s) : $f->{-hidel}));
   my $view =$vm
           ||($f->{-flg} !~/$c[^v]/ 
             &&( $f->{-flg} =~/[a$c]v/ 
               ||($f->{-flg} !~/[a$c]/ && $f->{-flg} =~/v/)));

   $p->print('</tr><tr>') if !$rskip;
   my $lbl =$p->htmlescape($f->{-lbl}||$f->{-fld});
   my $cmt =($f->{-cmt}||$f->{-lbl}||$f->{-fld}) .' [' .$f->{-fld} .': ' .$f->{-flg} .']';

   if    ($excl||$hide) {
      $lbl =' '
   }
   elsif (defined($f->{-lblhtml})) {
      my $l =$f->{-lblhtml};
         $l =&$l($s) if ref($l) eq 'CODE';
      $l =~s/< *input[^<>]*>//ig if $vm;
      $l =~s/\$_/$lbl/;
      $lbl =$l
   }
   $p->print($lbl =~/<t[dh]\b/i ? $lbl 
                  : $p->th({-align=>'left',-valign=>'top'},$lbl))
       if !($hide && $f->{-hidel});

   if ($f->{-frm}) {
      local $_ =$s->param($f->{-fld});
      $s->param($f->{-fld}, &{$f->{-frm}}($s, $_))
   }

   my $wgh;
   if (!$hide && defined($f->{-inphtml})) {
      $wgh =$f->{-inphtml};
      $wgh =&$wgh($s) if ref($wgh) eq 'CODE';
      $wgh =~s/< *input[^<>]*>//ig if $vm;
   }

   my $wgp ='';
   if    ($excl) {}
   elsif ($hide) {
         $wgp .=$g->hidden(-name=>$f->{-fld});
       # $wgp =' '
   }
   elsif ($view) {
         my $v =$p->param($f->{-fld});
            $v ='' if !defined($v);
         $wgp .=$g->hidden(-name=>$f->{-fld});
         if (ref($f->{-inp}) eq 'ARRAY') {
            my $t  =$f->{-inp}->[0];
            my %a  =$f->{-inp}->[1] ? %{$f->{-inp}->[1]} : ();
            $wgp .=$s->$t(-name=>$f->{-fld},%a,-disabled=>'true',-title=>$cmt);
            # -readonly, -disabled
         }
         elsif (ref($f->{-inp}) ne 'HASH') {
            $wgp .=$p->htmlescape($v)
         }
         elsif ($f->{-inp}->{-htmlopt} && $p->ishtml($v)) {
            $wgp .=$v
         }
         elsif ($f->{-inp}->{-hrefs}) {
            $wgp .='<code>' if $v =~/ {2,}/;
            while ($v =~/\b(\w{3,5}:\/\/[^\s\t,()<>\[\]"']+[^\s\t.,;()<>\[\]"'])/) {
               my $r =$1;
               $v    =$';
               my $w =$p->htmlescape($`); $w =~s/( {2,})/'&nbsp;' x length($1)/ge; $w =~s/\n/<br \/>\n/g; $w =~s/\r//g;
               $wgp .=$w;
               $r    =~s/^host:\///;
               $r    =~s/^fsurl:\//$s->fsurl||$s->fsurf/e;
               $wgp .=$g->a({-href=>$r, -target=>'_blank'}, $p->htmlescape($r));
            }
            $v =$p->htmlescape($v); $v =~s/( {2,})/'&nbsp;' x length($1)/ge; $v =~s/\n/<br \/>\n/g; $v =~s/\r//g;
            $wgp .=$v;
            $wgp .='</code>' if $wgp =~/<code>/;
         }
         elsif (exists($f->{-inp}->{-arows}) ||exists($f->{-inp}->{-rows}) ||exists($f->{-inp}->{-cols})) {
            $v =$p->htmlescape($v); $v =~s/( {2,})/'&nbsp;' x length($1)/ge; $v =~s/\n/<br \/>\n/g; $v =~s/\r//g;
            $v ="<code>$v</code>" if $v =~/&nbsp;&nbsp/;
            $wgp .=$v;
         }
         elsif ($f->{-inp}->{-labels}) {
            my $fi =$f->{-inp};
               $fi->{-labels} =&{$fi->{-labels}}($s) if ref($fi->{-labels}) eq 'CODE';
               $v  =$fi->{-labels}->{$v} if defined($fi->{-labels}->{$v});
            $wgp .=$p->htmlescape($v)
         }
         elsif (ref($f->{-inp}->{-values}) eq 'HASH') {
            $wgp .=$p->htmlescape(exists($f->{-inp}->{-values}->{$v}) ? $f->{-inp}->{-values}->{$v} : $v)
         }
         else {
            $wgp .=$p->htmlescape($v)
         }
   }
   elsif (!$f->{-inp}) {
       # $wgp .=$g->textfield(-name=>$f->{-fld},-title=>$cmt)
         $wgp .=$p->htmltextfield(-name=>$f->{-fld},-asize=>20,-title=>$cmt)
   }
   elsif (ref($f->{-inp}) eq 'HASH') {
         if    (exists $f->{-inp}->{-arows}) {
             $f->{-inp}->{-arows} =$f->{-inp}->{-arows} ||3;
             $wgp .=$p->htmltextarea(-name=>$f->{-fld},%{$f->{-inp}},-title=>$cmt)
         }
         elsif (exists ($f->{-inp}->{-rows}) ||exists($f->{-inp}->{-cols}) || $f->{-inp}->{-hrefs}) {
             $wgp .=$p->htmltextarea(-name=>$f->{-fld},%{$f->{-inp}},-title=>$cmt)
         }
         elsif (exists $f->{-inp}->{-asize}) {
             $f->{-inp}->{-asize} =$f->{-inp}->{-asize} ||20;
             $wgp .=$p->htmltextfield(-name=>$f->{-fld},%{$f->{-inp}},-title=>$cmt)
         }
         elsif ($f->{-inp}->{-values} ||$f->{-inp}->{-labels}) {            
             my $fi =$f->{-inp};
             $fi->{-values} =&{$fi->{-values}}($s) if ref($fi->{-values}) eq 'CODE';
             $fi->{-labels} =&{$fi->{-labels}}($s) if ref($fi->{-labels}) eq 'CODE';
             $fi->{-values} =[sort map {$fi->{-labels}->{$a} cmp $fi->{-labels}->{$b}} keys %{$fi->{-labels}}]
                            if !$fi->{-values};
             $wgp .=$p->popup_menu(-name=>$f->{-fld},%{$f->{-inp}},-title=>$cmt)
         }
         else {
             $wgp .=$p->htmltextfield(-name=>$f->{-fld},%{$f->{-inp}},-title=>$cmt)
         }
   }
   elsif (ref($f->{-inp}) eq 'ARRAY') {
         my $t  =$f->{-inp}->[0];
         my %a  =$f->{-inp}->[1] ? %{$f->{-inp}->[1]} : ();
         $wgp .=$s->$t(-name=>$f->{-fld},%a,-title=>$cmt)
   }
   if (defined($wgh)) {
      $wgh =~s/\$_/$wgp/;
      $wgp =$wgh
   }

   $wgp ='<td valign="top" align="left" '
        .($f->{-colspan} ? ' colspan=' .$f->{-colspan} :'')
        .($f->{-width} && $f->{-width} =~/\D/ ? ' width='   .$f->{-width}   :'')
        .'>' .$wgp .'</td>' 
        if $wgp !~/<t[dh]\b/i && !($hide && $f->{-hidel});
   $p->print($wgp, "\n");
   $rskip =undef;
 }
 $p->print("\n</tr>\n", $s->{-htmlte} ? $s->{-htmlte} : "\n</table>\n");
 $s
}



sub cmdhlp { # Help Command
 my $s =shift;
 my $p =$s->parent;
 my $g =$p->cgi;
 my $o =defined($_[0]) && substr($_[0],0,1) eq '-' ? shift : '-tolfc';
        # 't'itle, 'o'ther, 'l'ists, 'f'ields, 'c'ommands
 my $ta={-align=>'left',-valign=>'top'};
 my $sh='';
 if ($o =~/t/) {
    $sh ='Help';
    my $t =$s->parent->{-htmlstart}->{-title}||$s->parent->{-htpgstart}->{-title}||'';
  # print $g->h1(
  # ($s->{-formtgf} ? ''
  # :$g->button(-value=>'<-',-onClick=>'window.history.back();',-title=>$s->lng(1,'-bck')))
  # .' '
  # .$s->htmlescape($s->lng(0, $sh) .($t ? " - $t" : '')))
  # , "\n";
    print '<table><tr><td valign="middle">'
  # , $s->{-formtgf} ? '' :$g->button(-value=>'<-',-onClick=>'window.history.back();',-title=>$s->lng(1,'-bck'))
    , $s->{-formtgf} ? '' :$s->_htmlbare(-bck=> $p->{-iurl} && $img{-bck} ? $p->qurl : 0, -onClick=>'{window.history.back(); return(false)}')
    , '</td><th valign="middle"><strong>'
  # , $s->_img('-hlp')
    , $s->htmlescape(($t ? "$t - " : '') .$s->lng(0, $sh))
    , "</strong></th></tr></table><hr />\n";
 }
 if ($o =~/[fo]/ && $s->{-form}) {
    $sh ='Fields';
    print $g->h2($s->htmlescape($s->lng(0, $sh))),"\n";
    $sh =$s->lng(1, $sh);
    print $g->p($s->htmlescape($sh)),"\n" if $sh;
    print "<table>\n";
    foreach my $f (@{$s->{-form}}) {
       next if !$f || ref($f) ne 'HASH' || !$f->{-fld} || !$f->{-cmt};
       print "<tr>";
       print $g->td($ta, '<code>' .$s->htmlescape('[' .$f->{-flg} .']') .'</code>');
       print $g->th($ta, $s->htmlescape($f->{-lbl}||$f->{-fld}));
       print $g->td($ta, '<code>' .$s->htmlescape($f->{-fld}) .'</code>');
       print $g->td($ta, $s->htmlescape($f->{-cmt})
                       .($f->{-col} && $f->{-col} =~/\(/ 
                        ? ('<br /><code> = ' .$s->htmlescape($f->{-col}) .'</code>')
                        : ''));
       print "</tr>\n";
    }
    print "</table>\n";
 }
 if ($o =~/[lo]/ && $s->{-lists}) {
    $sh ='Lists';
    print $g->h2($s->htmlescape($s->lng(0, $sh))),"\n";
    $sh =$s->lng(1, $sh);
    print $g->p($s->htmlescape($sh)),"\n" if $sh;
    my $l =$s->{-lists};
    my @a =sort {($l->{$a}->{-lbl}||$l->{$a}->{-lst}||$a) cmp ($l->{$b}->{-lbl}||$l->{$b}->{-lst}||$b)} keys %$l;
    print "<table>\n";
    foreach my $e (@a) {
      next if !$l->{$e}->{-cmt};
      print "<tr>";
      print $g->th($ta, $s->htmlescape($l->{$e}->{-lbl}||$l->{$e}->{-lst}||$e));
      print $g->td($ta, (ref($l->{$e}->{-cmt}) eq 'ARRAY' 
                        ? join('<br />', map {$s->htmlescape($_)} @{$l->{$e}->{-cmt}}) 
                        : $s->htmlescape($l->{$e}->{-cmt}))
                       .'<code>'
                       .(ref($l->{$e}->{-fields})
                        ? ('<br /> = ' .$s->htmlescape(join(', ',@{$l->{$e}->{-fields}})))
                        : '')
                       .(ref($l->{$e}->{-key})
                        ? (' KEY ' .$s->htmlescape(join(', ',@{$l->{$e}->{-key}})))
                        : '')
                       .(ref($l->{$e}->{-orderby})
                        ? (' ORDER BY ' .$s->htmlescape(join(', ',@{$l->{$e}->{-orderby}})))
                        : '')
                       .($l->{$e}->{-orderby}
                        ? (' ORDER BY ' .$s->htmlescape($l->{$e}->{-orderby}))
                        : '')
                       .'</code>'
                       );
      print "</tr>\n";
    }
    print "</table>\n";
 }
 if ($o =~/[co]/) {
    $sh ='Commands';
    print $g->h2($s->htmlescape($s->lng(0, $sh))),"\n";
    $sh =$s->lng(1, $sh);
    print $g->p($s->htmlescape($sh)),"\n" if $sh;
    print "<table>\n"; # -nup
    foreach my $c (index($s->{-opflg}||'','<') >=0 ? qw(-nap -nth) : ()
                  ,qw(-bck -lst -qry -crt -sel -frm -ins -upd -del -hlp)) {
       next if !$s->lng($c);
       print "<tr>";
       print $g->th($ta
                   ,'<nobr>'
                   ,($p->{-iurl} && $img{$c} ? '<img src="' . $p->{-iurl} .'/' .$img{$c} .'" border=0 align="top" />' : '') 
                   .$s->htmlescape($s->lng(0,$c))
                   .'</nobr>');
       print $g->td($ta, $s->htmlescape($s->lng(1,$c)));
       print "</tr>\n";
    }
    print "</table>\n";
 }
 $s
}


