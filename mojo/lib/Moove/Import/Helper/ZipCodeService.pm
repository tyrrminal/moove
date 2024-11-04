use v5.38;
use experimental qw(class);

class Moove::Import::Helper::ZipCodeService {
  use Mojo::JSON qw(from_json);
  use Mojo::URL;
  use Readonly;

  Readonly::Scalar my $ZIPCODE_API => 'https://api.zipcodestack.com/v1/search';

  field $api_key : param;

  method zip_lookup($zipcode, $country = 'us') {
    my $ua = Mojo::UserAgent->new();

    my $url = Mojo::URL->new($ZIPCODE_API);
    $url->query(country => $country, codes => $zipcode, apikey => $api_key);
    my $res = $ua->get($url)->result;

    return $res->json->{results}->{$zipcode}->@*;
  }

}
