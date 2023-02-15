package Moove::Import::Activity::Garmin;
use v5.36;
use builtin qw(true);
use Moose;

use File::Basename;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use Parser::FIT;

use experimental qw(builtin);

use Data::Printer;

has 'file' => (
  is       => 'ro',
  isa      => 'Str',
  required => true,
);

sub get_activities ($self) {
  my @activity_ids;
  if($self->file =~ /[.]zip$/) {
    my $z = IO::Uncompress::Unzip->new( $self->file ) or die "unzip failed: $UnzipError\n";

    my $status;
    for ($status = 1; $status > 0; $status = $z->nextStream()) {
      push(@activity_ids, $z->getHeaderInfo()->{Name});
      last if $status < 0;
    }
    
    die "Error processing ".$self->file.": $!\n" if $status < 0 ;
  } elsif($self->file =~ /[.]fit$/) {
    push(@activity_ids, basename($self->file));
  }
  return grep { /^[^.].*[.]fit$/ } map { basename($_)} @activity_ids;
}

sub get_activity_data ($self, $activity_id) {
  my $parser = Parser::FIT->new(on => {
    session => sub($msg) { $msg },
    sport =>sub($msg) { p $msg },
  });

  $self->_parse_activity($parser, $activity_id);
}

sub get_activity_location_points ($self, $activity_id) {
  my $parser = Parser::FIT->new(on => {
      record => sub($msg) { p $msg }
  });

  $self->_parse_activity($parser, $activity_id);
}

sub _parse_activity($self, $parser, $activity_id) {
  if($self->file =~ /[.]zip$/) {
    my $data;
    unzip($self->file => \$data, Name => $activity_id);
    $parser->parse_data($data)
  } elsif($self->file =~ /[.]fit$/ && basename($self->file) eq $activity_id) {
    $parser->parse($self->file)
  }
}

1;
