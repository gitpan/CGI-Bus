#!perl -w
#
# admiral 
# 30/01/2002
#
# 

package CGI::Bus::lngbase::CGI_Bus_wg_ru; # Language base
use CGI::Bus::lngbase::CGI_Bus_wg;
use strict;

1;

sub lngbase {
 my @msg =CGI::Bus::lngbase::CGI_Bus_wg::lngbase;
 push @msg,
 ('ddlbopen'     =>['...',   '�������']
 ,'ddlbfind'     =>['..',    '�����']
 ,'ddlbclose'    =>['x',     '�������']
 ,'ddlbsetvalue' =>['<',     '��������� ��������']
 ,'Files'        =>['�����', '�������������� �����']
 ,'+|-'          =>['+/-',   '�������� / ������� / �������']
 ,'fsopens'	 =>['...',   '�������� �����']
 ,'fsclose'	 =>['�������','������� ��������� �����']
 ,'fsbrowse'	 =>['�������','������� �������������� ����']
 ,'fsdelmrk'	 =>['�������','������� ��� ��������']
 );
 @msg
}

