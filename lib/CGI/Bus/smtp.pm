#!perl -w
#
# CGI::Bus::smtp - SMTP Sender
#
# admiral 
#
# 

package CGI::Bus::smtp;
require 5.000;
use strict;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Bus::Base;
use Net::SMTP;
use vars qw(@ISA);
@ISA =qw(CGI::Bus::Base);


1;


#######################


sub smtp {
 my $s =shift;
 $s->set(@_);
 $s->{-smtp} =eval {Net::SMTP->new($s->{-host})};
 die("SMTP host '" .$s->{-host} ."' $@\n") if !$s->{-smtp} ||$@;
 $s->{-smtp}
}


sub mailsend { # from, to, msg rows
 my $s    =shift;
 my $host =$s->{-host};
 my $from =$_[0] !~/:/ ? shift : undef;
 my $to   =ref($_[0])  ? shift : undef;
 my $dom  =$s->{-domain};
 foreach my $r (@_) {last if $from && $to;
   if    (ref($r))  {$to =$r; $r ='To:'.join(',',@$r)}
   elsif (!$from && $r=~/^(from|sender):(.*)/i) {$from =$2}
   elsif (!$to   && $r=~/^to:(.*)/i)            {$to   =[split /,/,$1]}
 }
 $s->parent->pushmsg("SMTP msgsend $host $from -> ".join(',',@$to));
 my $smtp =$s->smtp(); $s->{-smtp} =undef;
 $smtp->mail(index($from,'@') <0 && $dom ? $from .'@' .$dom :$from)
                            || $s->die("SMTP From: $from\n");
 $smtp->to(map {index($_,'@') <0 && $dom ? $_ .'@' .$dom :$_} @$to)
                            || $s->die("SMTP To: " .join(', ',@$to) ."\n");
 $smtp->data(join("\n",@_)) || $s->die("SMTP Data\n");
 $smtp->dataend()           || $s->die("SMTP DataEnd\n");
 $smtp->quit;
 1
}
