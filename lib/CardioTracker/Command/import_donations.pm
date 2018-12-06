package CardioTracker::Command::import_donations;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;
use Mojo::Util 'getopt';

use DateTime;
use DateTime::Span;
use DateTime::Format::Duration;
use CardioTracker::Import::Helper::TextBalancedFix;

use Spreadsheet::Reader::ExcelXML;

use DCS::Constants qw(:boolean :existence);

has 'description' => 'Import Cardio Activities from File';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE


sub run {
  my ($self, @args) = @_;
  local $| = 1;

  my $import_class= "CardioTracker::Import::Activity::";

  my $user_id = 1;
  getopt(
    \@args,
    'file=s' => \my $file,
    'user=s' => \$user_id,
  );

  my $user = $self->app->model('User')->find($user_id);

  my $parser = Spreadsheet::Reader::ExcelXML->new();
  my $wb = $parser->parse($file);

  die $parser->error() unless(defined($wb));

  foreach my $sheet ($wb->worksheets) {
    my ($year,$name) = split(" ",$sheet->get_name,2);

    my @events = $self->app->model('Event')->search({
      name => {'like' => "$name%"}
    })->all;
    my ($event) = grep { $_->scheduled_start->year == $year } @events;
    say $event->description;

    my $h_row = $sheet->fetchrow_arrayref; # headings

    my $row = $sheet->fetchrow_arrayref;
    do {
      my @v = map { defined($_) ? $_->value : $NULL } @$row;
      my $amt = $row->[3]->unformatted;
      my $date = $v[5];
      say join("\t", "", $amt, $date);

      my $person = $self->app->model('Person')->find_or_create_donor($row->[0],$row->[1]);
      my $location = $self->app->model('Location')->find_or_create({
        street1 => $v[6]                 || $NULL,
        street2 => $NULL,
        city    => $v[7]                 || $NULL,
        state   => $v[8]                 || $NULL,
        zip     => sprintf("%05d",$v[9]||0) || $NULL,
        phone   => $v[10]                || $NULL,
        country => 'United States',
        email   => $v[2]                 || $NULL
      });

      $self->app->model('Donation')->create({
        event_id => $event->id,
        user_id  => $user->id,
        amount   => $amt,
        date     => $date,
        person   => $person,
        location => $location
      });

    } until(($row = $sheet->fetchrow_arrayref) eq 'EOF');
  }
}

1;
