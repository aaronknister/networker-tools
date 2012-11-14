#!/usr/bin/perl
# Aaron Knister <aaron.knister@gmail.com>
# 
# Put networker savegroup names in the subject of the e-mail
#

use Getopt::Long qw(:config pass_through);


my @mail_commands=qw(/usr/ucb/mail /usr/bin/mail /bin/mail);

my $mail_command;
foreach(@mail_commands) {
	if ( -e $_ ) {
		$mail_command=$_;
		last;
	}
}

if ( ! defined($mail_command) )  {
	warn "ERROR: Unable to locate mail command. Exiting.\n";
	exit(1);
}

######
my $verbose;
my $mailSubject;
GetOptions("verbose" => \$verbose,
	"subject=s" => \$mailSubject);

my $recipients=join(" ",@ARGV);

my $line_num=1;
my @message_body;

while(<STDIN>) {
	chomp;
	if ( $line_num == 1 ) {
		#if ( /^NetWorker savegroup: \(([a-zA-Z]+)\) (^completed,) completed/ ) {
		#if ( /^NetWorker savegroup: \(([a-zA-Z]+)\) ([^\bcompleted\b]+) completed/ ) {
		my $groupName;
		my $exitState;

		if ( /^NetWorker savegroup: \(([a-zA-Z]+)\) ([\bGroup \b]*)(.*) (completed|aborted),.*$/ ) {
			$warningLevel=$1;
			$groupName=$3;
			$exitState=$4;

			# If the savegroup is already running then the word "Group" will appear after the status but before
			#     the group name
			my $part2=$2;
			if ( ! /savegrp is already running$/ ) {
			} 

		}
		$dateStr=`date '+%Y-%m-%d %H:%M:%S'`;
		#$mailSubject="Networker Savegroup $warningLevel | $groupName | $dateStr";
		$mailSubject="Networker Savegroup $warningLevel |  $groupName $exitState  |  $dateStr ";
	} 

	push(@message_body,$_);
	$line_num++;
}

open(MAIL, "| $mail_command -s \"$mailSubject\" $recipients ") || die "Mail failed $!\n";
foreach(@message_body) {
	print MAIL $_ . "\n";
}
close(MAIL);
