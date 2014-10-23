#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

binmode STDOUT,":encoding(UTF-8)";

use Net::Twitter::Lite::WithAPIv1_1;
use Encode;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;
use JSON;

my $fh;
my $datafile = qq{config.dat};

open $fh,"<",$datafile or die $!;
my @entries = <$fh>;
close $fh;

$datafile = 'idfile.dat';
open $fh,"<",$datafile or die $!;
my $latested_txt = <$fh>;
my ($latestId,$dummy) = split(":",$latested_txt);
chomp($dummy);
close $fh;

my %config;
for my $item(@entries){
    chomp($item);
    my($key,$val) = split(":",$item);
    $config{$key} = $val;
};

my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
    consumer_key    =>$config{Consumerkey},
    consumer_secret =>$config{Consumersecret},
    apiurl          =>'https://api.twitter.com/1.1',
    searchapiurl    =>'https://api.twitter.com/1.1',
    ssl             => 1,
#    legacy_lists_api =>0,
);
$nt->access_token($config{Accesstoken});
$nt->access_token_secret($config{Accesstokensecret});

#print Dumper $nt;
my $res = $nt->mentions({since_id       =>  $latestId,
                         count          => 20,
                        });

print Dumper $res;
my %resUserName;
for my $ref_items(@$res){
    if(defined($ref_items->{in_reply_to_user_id_str})&&($ref_items->{in_reply_to_user_id_str} eq '1439898558')){
#    if(defined($ref_items->{in_reply_to_user_id_str})&&($ref_items->{in_reply_to_user_id_str} eq '2872636650')){
        $resUserName{$ref_items->{id}} = {screen_name   =>  $ref_items->{user}->{screen_name},
                                          user_name     =>  $ref_items->{user}->{name}};
        if ($latestId <$ref_items->{id}){
            $latestId = $ref_items->{id};
        }
    }
};

$datafile = 'idfile.dat';
open $fh,">",$datafile or die $!;
print $fh $latestId.":".$dummy;
close $fh;

#print Dumper \%resUserName;
# 'in_reply_to_user_id_str' => '1439898558' のものだけピックアップ

for my $item(keys(%resUserName)){
    my $user_name = $resUserName{$item}->{user_name};
    my @rep_string = (
        " もぉー、だからあの時言ったじゃないですかー",
        " もぉー、だからあの時言ったじゃないですかー ",
        " もぉー、だからあの時言ったじゃないですかー  ",
        " だーかーらー、あの時言ったじゃないですかー",
        " だーかーらー、あの時言ったじゃないですかー ",
        " だーかーらー、あの時言ったじゃないですかー  ",
        " だからあの時言ったじゃないですかー",
        " だからあの時言ったじゃないですかー ",
        " だからあの時言ったじゃないですかー  ",
        " ".$user_name."くん、だからあの時言ったじゃないですかー",
        " ".$user_name."くん、だからあの時言ったじゃないですかー ",
        " ".$user_name."くん、だからあの時言ったじゃないですかー  ",
        " だから、私があの時ちゃんと言ったじゃないですかー",
        " だから、私があの時ちゃんと言ったじゃないですかー ",
        " だから、私があの時ちゃんと言ったじゃないですかー  "
    );
    if($dummy eq " "){
        $dummy = "";
    }else{
        $dummy = " ";
    }

    $nt->update({status                 => "@".$resUserName{$item}->{screen_name}.$rep_string[int(rand(@rep_string))].$dummy,
                 in_reply_to_status_id  => $item,
                });
}

