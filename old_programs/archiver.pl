#!/perl/bin/perl

# archives dir per "archive_dir" setting.
# archives files per "archive_after_days" setting.
# deletes archives per "delete_after_days" setting.
# eugene.kerner@hpa.com.au

use strict;
use warnings;


init();


sub init{
my $self = bless {
    archive_dir        => 'E:\log',
    log_file           => "$0.log",
    archive_after_days => 5,
    delete_after_days  => 10,
    zip_app            => 'c:\PROGRA~1\7-Zip\7za',
    epoch              => time()
    };
$self->{dt}        = [localtime($self->{epoch})];
$self->{file_list} = [glob "$self->{archive_dir}\\*"];
$self->create();
$self->remove();
}



sub create {
    my $self = shift;
    my @files = ();
    for my $file (@{$self->{file_list}}) {
        next if -d $file;
        chmod 0666, $file;
        my $file_epoch = (stat $file)[8] or do {
            $self->report_error("Failed to stat $file: $!");
            next;
        };
    
        next if $self->{epoch} - $file_epoch < $self->{archive_after_days} * 86400;
        push @files, $file;
    }
    
    return unless scalar @files;
    for my $file (@files) {        # add -mx9 switch for max compression #
        $self->run_command("dir \\OD") or next;
    }
}



sub remove{
my $self = shift;
my @archives = ();
  for my $dir (grep {-d} @{$self->{file_list}}){
  next unless $dir =~ /\d{8}_(\d+)$/;
  my $dir_epoch = $1;
  next if $self->{epoch} - $dir_epoch < $self->{delete_after_days} * 86400;
  $self->remove_tree($dir);
  }
}



sub run_command{
my ($self, $command) = @_;
local $/;
local $? = 0;
open PIPE, '-|', "$command" or do{
    $self->report_error("Failed to run: $command: $!");
    return 0;
    };
my $result = <PIPE>;
close PIPE;
return 1 if $? == 0;
chomp $result;
$self->report_error("Exit failure $? for command: $command\n$result");
0;
}



sub remove_tree{
my ($self, $dir) = @_;
my $ok = 1;
  for my $file (glob "$dir/*"){
    unless(unlink $file){
    $self->report_error("Failed to remove $file: $!");
    $ok = 0;
    }
  }
rmdir $dir or $self->report_error("Failed to remove $dir: $!")
    if $ok;
}



sub report_error{
my ($self, $error) = @_;
print STDERR "$error\n";
my $timestamp = sprintf('%02d/%02d/%04d at %02d:%02d:%02d', 
                        $self->{dt}->[3], $self->{dt}->[4] + 1, $self->{dt}->[5] + 1900,
                        $self->{dt}->[2], $self->{dt}->[1]    , $self->{dt}->[0]);
open  O, ">>$self->{log_file}" or die "Failed to append $self->{log_file} with $error";
print O "[$timestamp $$] $error\n";
close O;
}


1;

__END__


# archives dir per "archive_dir" setting.
# archives files per "archive_after_days" setting.
# deletes archives per "delete_after_days" setting.
# eugene.kerner@hpa.com.au

