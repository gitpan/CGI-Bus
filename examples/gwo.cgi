#!perl -w
#
# Groupware Organizer application
#
# Initial Settings
#
use vars qw($s);
$s = do("config.pl");
$s->set('-htmlstart')->{-title} =$s->server_name() .' - Groupware Organizer';
#
# Form Description
#
$s->tmsql->set(-opflg =>'a') if !$s->uguest; #'<a!v'
$s->tmsql->set(
-form =>[
  {-tbl=>'cgibus.gworganizer', -alias=>'gwo'}
 ,{-flg=>'vqiskw"',-fld=>'id', -lbl=>'ID', -cmt=>'Unique identifier of Record'
        ,-crt=>'New', -cdbi=>sub{$_[0]->user .'/' .$_[0]->strtime('yyyymmddhhmmss')}
        ,-lblhtml=>sub{
          $_[0]->htmlself({-title=>'Open records list'},-lst=>,$_[0]->pxsw('LIST'),'AllActual','$_')
         .($_[0]->cmdg('-qry') ||$_[0]->param('idpr_b') ||($_[0]->param('idpr') && $_[0]->param('idrm')) ?''
          :$_[0]->submit(-name=>'idpr_b',-value=>'...',-title=>'Show record relations fields'))
         }
        ,-inphtml=>'<font size=-1>$_</font>'
        }
 ,''
 ,{-flg=>'vqis"',  -fld=>'cuser'
        ,-lbl=>'Creator', -cmt=>'Who was created Record'
        ,-crt=>sub{$_[0]->user}, -ins=>sub{$_[0]->user}
        }
 ,''
 ,{-flg=>'vqis"',  -fld=>'ctime'
        ,-lbl=>'Created', -cmt=>'When was created Record'
        ,-crt=>sub{$_[0]->strtime}, -ins=>sub{$_[0]->strtime}
        ,-lblhtml=>'', -inphtml=>'<nobr>$_</nobr>'
        }
 ,{-flg=>'vqis"',  -fld=>'idnv'
        ,-lbl=>'NewVer', -cmt=>'Pointer to new version of Record'
        ,-null=>'', -hide=>sub{!$_}
        ,-lblhtml=>sub{$_[0]->htmlself({-title=>'Open new version of this record'},-sel=>'id'=>$_,'$_')}
        ,-inphtml=>'<font size=-1>$_</font>'
        }
 ,''
 ,{-flg=>'avqiuw"',-fld=>'uuser'
        ,-lbl=>'Updator', -cmt=>'Who was updated Record'
        ,-crt=>'', -sav=>sub{$_[0]->user}}
 ,''
 ,{-flg=>'avqiu"',-fld=>'utime'
        ,-lbl=>'Updated', -cmt=>'When was updated Record'
        ,-crt=>'', -sav=>sub{$_[0]->strtime}
        ,-lblhtml=>'', -inphtml=>'<nobr>$_</nobr>'
        }
 ,{-flg=>'a"',     -fld=>'idrm'
        ,-lbl=>'ReplyTo', -cmt=>'Reply to record'
        ,-hidel=>sub{!$_ && !$_[0]->param('idpr_b')}
        ,-null=>'', -crt=>sub{$_[0]->qparampv('id')}, -inp=>{-maxlength=>60}
        ,-lblhtml=>sub{$_[0]->htmlself({-title=>'Reply to record'},-sel=>'id'=>$_,'$_')}
        ,-inphtml=>'<font size=-1>$_</font>'
        }
 ,''
 ,{-flg=>'vqius"', -fld=>'idrr'
        ,-lbl=>'ReplyRoot', -cmt=>'Root of replies'
        ,-hidel=>sub{!$_}, -null=>''
        ,-sav=>sub{return '' if !$_[0]->param('idrm');
             my $sql ="SELECT gwo.idrr AS idrr FROM cgibus.gworganizer AS gwo WHERE gwo.id="
                     .$_[0]->dbi->quote($_[0]->param('idrm'));
             $_[0]->pushmsg($sql);
             my $r =$_[0]->dbi->selectrow_array($sql);
             $r || $_[0]->param('idrm')
          }
        ,-lblhtml=>sub{$_[0]->htmlself({-title=>'Root of replies'},-sel=>'id'=>$_,'$_')}
        ,-inphtml=>'<font size=-1>$_</font>'
        }
 ,''
 ,{-flg=>'a"',     -fld=>'idpr'
        ,-lbl=>'PrevRec', -cmt=>'Previous Record' #'vqis"'
      # ,-crt=>sub{$_[0]->qparampv('id')} # !!! moved to 'idrm'
      # ,-ins=>sub{$_[0]->qparampv('id')} # !!! balance with 'idrm'
        ,-hide=>sub{!$_ && !$_[0]->param('idpr_b')}
        ,-null=>'', -inp=>{-maxlength=>60}
        ,-lblhtml=>sub{$_[0]->htmlself({-title=>'Open previous to this record'},-sel=>'id'=>$_,'$_')}
        ,-inphtml=>'<font size=-1>$_</font>'
        }
 ,{-flg=>'am"',    -fld=>'puser'
        ,-lbl=>'Principal', -cmt=>'Principal User'
        ,-crt=>sub{$_[0]->user}, -null=>'',-inp=>{-maxlength=>60}}
 ,''
 ,{-flg=>'a"',     -fld=>'prole'
        ,-lbl=>'PRole', -cmt=>'Principal Role, Group of Principals'
        ,-crt=>sub{
             return($_) if $_ ||($_ =$_[0]->udata->param('urole'));
             foreach my $u (@{$_[0]->ugroups}) {return $u if $u =~/^[o]/};
             foreach my $u (@{$_[0]->ugroups}) {return $u if $u =~/^[g]/};
             $_[0]->param('puser')
          }
        , -null=>'', -colspan=>10, -inp=>{-maxlength=>60}}
 ,{-flg=>'a"',  -fld=>'auser'
        ,-lbl=>'Actor', -cmt=>'Actor User'
        ,-crt=>sub{$_[0]->param('puser')}, -null=>'', -inp=>{-maxlength=>60}}
 ,''
 ,{-flg=>'a"',  -fld=>'arole'
        ,-lbl=>'ARole', -cmt=>'Actor Role, Group of Actors'
        ,-crt=>sub{$_ ||$_[0]->param('prole')}
        , -null=>'',-inp=>{-maxlength=>60}, -colspan=>10}
 ,{-flg=>'a"',  -fld=>'rrole'
        ,-lbl=>'Reader', -cmt=>'Reader Role, Group of Readers of the Record'
        ,-crt=>sub{$_}, -null=>'', -inp=>{-maxlength=>60}
        ,-lblhtml=>sub{$_[0]->htmlself({-title=>'Open Users'},-lst=>,$_[0]->pxsw('LIST'),'Users','$_')}
        ,-inphtml=>sub{'$_' .$_[0]->htmlddlb('auser_',sub{$_[0]->uglist({})}, qw(puser prole auser arole rrole), "\tmailto")}}
 ,''
 ,{-flg=>'a"',  -fld=>'mailto'
        ,-lbl=>'eMailTo', -cmt=>'Receipients of e-mail about this record'
        ,-null=>'', -inp=>{-maxlength=>255}}
 ,''
 ,{-flg=>'a"',  -fld=>'period'
        ,-lbl=>'Period',-cmt=>'Period (y,m,d,h) of Record described by'
        , -null=>'', -inp=>{-maxlength=>20}}
 ,{-flg=>'am"', -fld=>'status'
        ,-lbl=>'Status', -cmt=>'Status of Record'
        ,-crt=>'ok', -qry=>''
        ,-inp=>{-values=>[qw(ok no --- do goal progress --- edit deleted template), '']}
        ,-clst=>sub{$_ =~/^(do|edit|deleted)/ ? "<B><FONT COLOR=\"red\">$_</FONT></B>" : $_}}
 ,''
 ,{-flg=>'a"',  -fld=>'etime'
        ,-lbl=>'End', -cmt=>'End or Due time of Record described by'
        ,-crt=>sub{$_[0]->strtime}, -null=>'', -inp=>{-maxlength=>20}
        ,-inphtml=>'<nobr>$_</nobr>'
        ,-clst=>sub{$_ =~/^([^\s]+)[\s0:]*$/ ? $1 : $_}
        }
 ,''
 ,{-flg=>'a"',  -fld=>'stime'
        ,-lbl=>'Start', -cmt=>'Start time of Record described by'
        ,-null=>'', -inp=>{-maxlength=>20}
        ,-inphtml=>'<nobr>$_</nobr>'
        ,-clst=>sub{$_ =~/^([^\s]+)[\s0:]*$/ ? $1 : $_}
        }
 ,{-flg=>'ls"', -fld=>'ftime'
        ,-lbl=>'Finish', -cmt=>'Time finished or to finish or edited'
        ,-col=>'COALESCE(gwo.etime, gwo.utime)'
        ,-clst=>sub{$_ =~/^([^\s]+)[\s0:]*$/ ? $1 : $_}
        }
 ,{-flg=>'ls"', -fld=>'otime'
        ,-lbl=>'Ord', -cmt=>'Time to order records by'
        ,-col=>"IF(gwo.status = 'edit' OR (gwo.status = 'do' AND "
        ."(stime IS NULL OR stime <='" .$s->strtime('yyyy-mm-dd')."') "
        ."), 'do', gwo.utime)"
        ,-clst=>sub{$_ =~/^([^\s]+)[\s0:]*$/ ? $1 : $_}
        }
 ,{-flg=>'a"',  -fld=>'record'
        ,-lbl=>'Record', -cmt=>'Record type'
        ,-crt=>sub{$_}, -null=>''
        ,-inp=>{-values=>['', qw(note log incident problem experim --- draft paper manual --- object change upgrade install move delete serve --- msg contact address)]}}
 ,''
 ,{-flg=>'a"',  -fld=>'object'
        ,-lbl=>'Object', -cmt=>'Object or keyword, related to Record'
        ,-crt=>sub{$_}, -null=>'', -inp=>{-maxlength=>60}
        ,-lblhtml=>sub{$_[0]->htmlself({-title=>'Open Objects'},-lst=>$_[0]->pxsw('LIST')
                      ,$_ ? ('AllActual','object'=>$_) : ('Objects'), '$_')}
        ,-inphtml=>sub{'$_' .$_[0]->htmlddlb('object_','Objects','object')}}
 ,''
 ,{-flg=>'a"',  -fld=>'doctype'
        ,-lbl=>'DocType', -cmt=>'For buroucracy'
        ,-crt=>sub{$_}, -null=>'', -inp=>{-maxlength=>60}
        ,-lblhtml=>sub{$_[0]->htmlself({-title=>'Open DocTypes'},-lst=>,$_[0]->pxsw('LIST')
                      ,$_ ? ('AllActual','doctype'=>$_) : ('DocTypes'), '$_')}
        ,-inphtml=>sub{'$_' .$_[0]->htmlddlb('doctype_','DocTypes','doctype')}}
 ,{-flg=>'am"', -fld=>'subject'
        ,-lbl=>'Subject', -cmt=>'Subject or Title followed by optional |URL or |_blank|URL'
        ,-crt=>sub{$_}
        ,-inp=>{-asize=>89, -maxlength=>255}, -colspan=>10
        ,-lblhtml=>sub{$_ && /^([^\|]+)\s*\|\s*(_blank|)[\s|]*((\w{3,5}:\/\/|\/).+)/ ? $_[0]->a({-href=>$3,-target=>$2,-title=>'Open URL'},'$_') : '$_'}
      # ,-inphtml=>'<STRONG>$_</STRONG>'
        ,-clst=>sub{$_ && /^([^\|]+)\s*\|\s*(_blank|)[\s|]*((\w{3,5}:\/\/|\/).+)/ ? $_[0]->a({-href=>$3,-target=>$2},$_[0]->htmlescape($1)) : $_[0]->htmlescape($_)}
        }
 ,{-flg=>'a"',  -fld=>'comment'
        ,-lbl=>'Comment', -cmt=>'Comment text'
        ,-crt=>sub{$_}, -null=>''
        ,-inp=>{-cols=>68,-arows=>3,-maxlength=>4*1024,-hrefs=>1,-htmlopt=>1}
        ,-colspan=>10}
#,{-flg=>'"',   -fld=>'user'}
#,{-flg=>'"',   -fld=>$s->tmsql->pxsw('WHERE')}
 ]);
#
# Lists (views) Description
#
$s->tmsql->set(
-lists =>{
  'AllVersions'=> {-lbl=>'All Versions', -cmt=>'All records available, including old versions and deleted'
                  ,-fields=>[qw(utime idnv status record object subject)]
                  ,-orderby=>'utime desc, ctime desc'}
 ,'AllActual'=>   {-lbl=>,'All Actual', -cmt=>'All actual records available'
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'ftime desc, ctime desc'
                  ,-where=>"status NOT IN('deleted','template') AND gwo.idnv is NULL"}
 ,'AllTimeline'=> {-lbl=>,'All Timeline', -cmt=>'Timeline chart for all actual records'
                  ,-fields=>[qw(status record object subject auser arole), "DATE_FORMAT(stime,'%Y-%m-%d')", "DATE_FORMAT(etime,'%Y-%m-%d')"]
                  ,-gant1=>'stime', -gant2=>'etime'
                  ,-orderby=>'auser, arole, stime, etime'
                  ,-where=>"status NOT IN('deleted','template') AND gwo.idnv is NULL"}
 ,'AllToDo'=>     {-lbl=>'All ToDo', -cmt=>'All records to do'
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'ftime desc, ctime desc'
                  ,-where=>"status IN('do','edit') AND gwo.idnv is NULL"}
 ,'AllToday'=>    {-lbl=>,'All Today', -cmt=>'All actual records available'
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'otime desc, ftime desc, ctime desc'
                  ,-where=>"status NOT IN('deleted','template') AND gwo.idnv is NULL"}
 ,'OurActual'=>   {-lbl=>'Our Actual', -cmt=>('Records ' .$s->user .' involved in')
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'ftime desc, ctime desc'
                  ,-filter=>sub{"status NOT IN('deleted','template') AND gwo.idnv is NULL"
                   .$_[0]->aclsel('-','-and',qw(puser prole auser arole),$_[0]->unames,qw(cuser uuser))
                   }}
 ,'OurToday'=>    {-lbl=>'Our Today', -cmt=>('Records ' .$s->user .' involved in today')
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'otime desc, ftime desc, ctime desc'
                  ,-filter=>sub{
                     "gwo.idnv is NULL "
                    ."AND (status NOT IN ('deleted','template'))"
                    .$_[0]->aclsel('-','-and',qw(puser prole auser arole),$_[0]->unames,qw(cuser uuser))
                   }}
 ,'OurToDo'=>     {-lbl=>'Our ToDo', -cmt=>('ToDo records ' .$s->user .' involved in')
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'ftime desc, ctime desc'
                  ,-filter=>sub{"status IN('do','edit') AND gwo.idnv is NULL"
                   .$_[0]->aclsel('-','-and',qw(puser prole auser arole),$_[0]->unames,qw(cuser uuser))
                   }}
 ,'PersActual'=>  {-lbl=>'Pers Actual', -cmt=>('Personally ' .$s->user .' records')
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'ftime desc, ctime desc'
                  ,-filter=>sub{"status NOT IN ('deleted','template') AND gwo.idnv is NULL"
                    .$_[0]->aclsel('-','-and',$_[0]->ugnames,qw(auser puser),$_[0]->unames,qw(arole prole))
                   }}
 ,'PersToDo'=>    {-lbl=>'Pers ToDo', -cmt=>('Personally ' .$s->user .' records to do')
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'ftime desc, ctime desc'
                  ,-filter=>sub{"status IN('do','edit') AND gwo.idnv is NULL"
                    .$_[0]->aclsel('-','-and',$_[0]->ugnames,qw(auser puser),$_[0]->unames,qw(arole prole))
                   }}
 ,'PerToday_'=>   {-lbl=>'Pers Today_', -cmt=>('Personally ' .$s->user .' today records')
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'otime desc, ftime desc, ctime desc'
                  ,-filter=>sub{
                     "gwo.idnv is NULL "
                    ."AND (status NOT IN ('deleted','template'))"
                    .$_[0]->aclsel('-','-and',$_[0]->ugnames,qw(auser puser),$_[0]->unames,qw(arole prole))
                   }}
 ,'PersReqs'=>    {-lbl=>'Pers Reqs', -cmt=>('Records by ' .$s->user .' to others')
                  ,-fields=>[qw(ftime status record object subject)]
                  ,-orderby=>'ftime desc, ctime desc'
                  ,-filter=>sub{"status NOT IN ('deleted','template') AND gwo.idnv is NULL"
                   .$_[0]->aclsel('-','-and',qw(puser prole),$_[0]->unames,qw(uuser cuser))
                   .$_[0]->aclsel('-','-and','-not',qw(auser arole))
                   }}
 ,'Objects'=>     {-lbl=>'List Objects', -cmt=>'List of Objects'
                  ,-fields=>[qw(object)], -key=>[qw(object)]                  
                  ,-orderby=>'object', -groupby=>'object'
                  ,-href=>[undef,undef,'-lst',$s->tmsql->pxsw('LIST'),'AllActual']
                  ,-where=>"status NOT IN ('deleted','template') AND gwo.idnv is NULL"}
 ,'DocTypes'=>    {-lbl=>'List DocTypes', -cmt=>'List of DocTypes'
                  ,-fields=>[qw(doctype)], -key=>[qw(doctype)]                
                  ,-orderby=>'doctype', -groupby=>'doctype'
                  ,-href=>[undef,undef,'-lst',$s->tmsql->pxsw('LIST'),'AllActual']
                  ,-where=>"status NOT IN ('deleted','template') AND gwo.idnv is NULL"}
 ,'Users'=>       {-lbl=>'List Users', -cmt=>'List of Users'
                  ,-fields=>[qw(user)], -key=>[$s->tmsql->pxsw('WHERE')]
                  ,-href=>[undef,undef,'-lst',$s->tmsql->pxsw('LIST'),'AllActual']
                  ,-dsub=>sub{my $s =$_[0]; my %uh;
                     my @fl =qw(cuser uuser auser arole puser prole);
                     foreach my $f (@fl){
                       my $sql ="SELECT gwo.$f AS $f FROM cgibus.gworganizer AS gwo GROUP BY $f ORDER BY $f asc";
                       $s->pushmsg($sql);
                       foreach my $r (@{$s->dbi->selectcol_arrayref($sql)}) {
                          $uh{$r} =1 if $r;
                       }
                     }
                     [map {[$_, $s->dbi->quote($_) .' IN('
                              . join(',',map {'gwo.'.$_} @fl) .')']}
                          sort keys %uh]
                   }
                  }
 ,'Templates'=>   {-lbl=>'Templates', -cmt=>['Templates to create Records with'
                         ,'Open template, choose Status, invoke Insert action.'
                         ,'For file attachments editing new Status should be \'edit\'.']
                  ,-fields=>[qw(record object subject)]
                  ,-orderby=>'record, object, subject'
                  ,-where=>"status='template' AND gwo.idnv is NULL"}
 });
#
# Version Store Description
#
$s->tmsql->set(
-vsd =>{
  -npf=>'idnv'     # new version pointer field
 ,-sf =>'status'   # status field
 ,-svd=>'edit'     # status, where record versioning disable
 ,-sd =>'deleted'  # status, where record is logically deleted
 ,-uuf=>'uuser'    # updator user field
 ,-utf=>'utime'    # update  time field
 });
#
#  File Store Description 
#
$s->tmsql->set(
-fsd => {
  -path  =>$s->fpath('gwo/act') # actual records path
 ,-vspath=>$s->fpath('gwo/ver') # old versions path
 ,-urf   =>$s->furf ('gwo/act') # actual records base filesystem URL (for MSIE)
 ,-url   =>$s->furl ('gwo/act') # actual records base URL (for all browsers)
 ,-vsurf =>$s->furf ('gwo/ver') # old versions base filesystem URL
 ,-vsurl =>$s->furl ('gwo/ver') # old versions base URL
 ,-ksplit=>sub{                 # key to dir split sub
           my @v;
           while ($_ =~/([\\\/])/) {$_ =$'; push @v, $` .$1}
           push @v,substr($_,0,4),substr($_,4,2),substr($_,6,2)
                  ,substr($_,8,2),substr($_,10) if @v;
           return @v
           }
 });
#
# Access Control Description
#
$s->tmsql->set(
-acd=>{
  -swrite=>['Administrators']   # system writers
 ,-sread =>['Administrators']   # system readers
 ,-write =>[qw(auser arole puser prole uuser cuser)]       # writer fields
 ,-read  =>[qw(auser arole puser prole uuser cuser rrole)] # reader fields
 ,-readsub => sub {             # read right lookup sub
     my @c; my $idrr =$s->qparam('idrr');
     push @c, 'gwo.idrr=' .$s->dbi->quote($idrr) if $idrr;
     push @c, 'gwo.id='   .$s->dbi->quote($idrr) if $idrr;
     push @c, 'gwo.idrr=' .$s->dbi->quote($s->qparam('id'));
     $_[0]->cmdscan1('-!q','AllActual', join(' OR ', @c));
   }
 });
#
# Filter Description
#
$s->tmsql->set(-fltlst =>sub{$_[0]->aclsel('-',qw(puser prole auser arole rrole),$_[0]->unames,qw(cuser uuser))});
$s->tmsql->set(-ftext  =>'MATCH (gwo.object, gwo.doctype, gwo.subject, gwo.comment) AGAINST ($_)');
$s->tmsql->set(-ftext  =>'(' .join(' OR ', map {"gwo.$_ LIKE \%\$_"} qw(object doctype subject comment cuser uuser puser prole auser arole rrole)) .')');
#
#
#
$s->tmsql->set(-cmdfrm =>sub{  # view related records in record form
    my $s =shift;
    $s->cmdfrm(@_);
    if ($s->cmd('-sel')) {
       $s->print->hr;
       $s->cmdlst('-gxm!q','AllActual'
         ,'gwo.idpr=' .$s->dbi->quote($s->qparam('id'))
         .' OR gwo.idrm=' .$s->dbi->quote($s->qparam('id')))
    }
});
#
#
#
$s->tmsql->set(-rowsav1=>sub { # mail send
    my $s =shift;
    return($s) if !$s->param('mailto');
    return($s) if  $s->param('status') =~/edit|template|deleted/;
    my $subj =join(' ', map {$s->param($_)} qw(record object doctype subject));
    $s->smtp(-host=>'localhost',-domain=>$s->server_name()
     )->mailsend(
        "From: "    .$s->user
       ,"Subject: " .$s->cptran('1251','koi8',$subj)
       ,[split /\s*[;,]\s*/, $s->param('mailto')]
       ,"MIME-Version: 1.0"
       ,"Content-type: text/html; charset=windows-1251\n"
       ,$s->start_html($s->parent->{-htmlstart})  # $s->htpgstart()
       ,$s->htmlself(-sel=>'id'=>$s->param('id'),$subj),'<BR>'
       ,$s->{-fields}->{'comment'}->{-htmlopt} && $s->ishtml($s->param('comment'))
        ? $s->param('comment') : $s->htmlescape($s->param('comment'))
       ,$s->htpgend()
       );
    $s
});
#
#
#
$s->tmsql->set(-cmdupd =>sub{  # periodical records on update
    my $s =shift;
    if ($s->qparam  ('period') 
     && $s->qparampv('status') !~/^(edit|deleted)$/
     && $s->qparam  ('status') !~/^(do|deleted)$/) {
       $s->cmdsel(undef,'-pxpv');
       my $sv =$s->qparamh($s->qparampx('-pxpv'));
       foreach my $t (qw(stime etime)) { # adjust times todo
         next if !$s->qparampv($t);
         $s->qparampv($t
         , $s->strtime($s->timeadd($s->timestr($s->qparampv($t))
         , split /[,;]/, $s->qparam('period'))))
       }
       $s->qparampv('idpr',  $s->qparam('id'));
       $s->qparampv('status','do');
       $s->cmdins  (undef,'','-pxpv');
       $s->qparam  ($sv);
       $s->qparam  ('period','');
       sleep(1); # !!! for proper old version key generation !!!
       $s->cmdupd('-gx!s');
    }
    else {
       $s->cmdupd()
    }
});
#
# Run Application
#
$s->tmsql->evaluate;


