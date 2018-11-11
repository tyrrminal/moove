package CardioTracker::Import::Helper::CityService;
use Moose;
use Modern::Perl;
use Mojo::JSON qw(from_json);

use Readonly;

use DCS::Constants qw(:boolean :existence);

Readonly::Scalar my $GIT_API_BASE => q{https://api.github.com/};
Readonly::Scalar my $GIT_USER_GISTS => q{users/%s/gists};
Readonly::Scalar my $GIT_GIST => q{gists/%s};

Readonly::Scalar my $CITYLIST_AUTHOR => 'objcow';
Readonly::Scalar my $CITYLIST_FILENAME => 'usaCities.json';

Readonly::Scalar my $STATELIST_AUTHOR => 'mshafrir';
Readonly::Scalar my $STATELIST_FILENAME => 'states_hash.json';

has 'city_list' => (
  is => 'ro',
  isa => 'ArrayRef[HashRef[Str]]',
  init_arg => $NULL,
  builder => '_build_city_list'
);

sub _build_city_list {
  my $self=shift;

  my %sl = reverse %{from_json(_get_gist_content($STATELIST_AUTHOR,$STATELIST_FILENAME))};
  my $cl = from_json(_get_gist_content($CITYLIST_AUTHOR,$CITYLIST_FILENAME));

  foreach (@$cl) {
    $_->{state_abbrv} = $sl{$_->{state}};
  }
  return $cl;
}

sub _get_gist_content {
  my ($author,$filename) = @_;

    my $ua = Mojo::UserAgent->new();
  my $res = $ua->get(sprintf($GIT_API_BASE . $GIT_USER_GISTS, $author))->result;
  my ($gist) = grep { exists($_->{files}->{$filename}) } @{$res->json};

  $res = $ua->get(sprintf($GIT_API_BASE . $GIT_GIST, $gist->{id}))->result;
  return $res->json->{files}->{$filename}->{content};
}

sub combos_with_city {
  my $self=shift;
  my ($city) = @_;

  return grep { $_->{city} eq $city } @{$self->city_list};
}

sub is_valid_city_state {
  my $self=shift;
  my ($city,$state) = @_;

  grep { lc($_->{city}) eq lc($city) && ( lc($_->{state}) eq lc($state) || (defined($_->{state_abbrv}) && lc($_->{state_abbrv}) eq lc($state)) ) } @{$self->city_list};
}

1;
