use v5.38;
use experimental qw(class);

class Moove::Import::Helper::CityService {
  use Mojo::JSON qw(from_json);
  use Readonly;

  Readonly::Scalar my $GIT_API_BASE   => q{https://api.github.com/};
  Readonly::Scalar my $GIT_USER_GISTS => q{users/%s/gists};
  Readonly::Scalar my $GIT_GIST       => q{gists/%s};

  Readonly::Scalar my $CITYLIST_AUTHOR   => 'tyrrminal';
  Readonly::Scalar my $CITYLIST_FILENAME => 'usaCities.json';

  Readonly::Scalar my $STATELIST_AUTHOR   => 'mshafrir';
  Readonly::Scalar my $STATELIST_FILENAME => 'states_hash.json';

  field @city_list;

  my sub get_gist_content($author, $filename) {
    my $ua     = Mojo::UserAgent->new();
    my $res    = $ua->get(sprintf($GIT_API_BASE . $GIT_USER_GISTS, $author))->result;
    my ($gist) = grep {exists($_->{files}->{$filename})} $res->json->@*;

    $res = $ua->get(sprintf($GIT_API_BASE . $GIT_GIST, $gist->{id}))->result;
    return $res->json->{files}->{$filename}->{content};
  }

  ADJUST {
    my %state_list = reverse from_json(get_gist_content($STATELIST_AUTHOR, $STATELIST_FILENAME))->%*;
    @city_list = from_json(get_gist_content($CITYLIST_AUTHOR, $CITYLIST_FILENAME))->@*;

    $_->{state_abbrv} = $state_list{$_->{state}} foreach (@city_list);
  }

  method combos_with_city($city) {
    return grep {$_->{city} eq $city} @city_list;
  }

  method is_valid_city_state($city, $state) {
    (grep {
      lc($_->{city}) eq lc($city) && 
        ( lc($_->{state}) eq lc($state) || 
         (defined($_->{state_abbrv}) && lc($_->{state_abbrv}) eq lc($state)) )
    } @city_list) > 0;
  }

}
