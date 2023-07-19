package Moove::Controller::Role::ModelEncoding::ExternalDataSource;
use v5.36;

use Role::Tiny;

use Mojo::Util qw(class_to_path);

use DCS::Constants qw(:semantics :symbols);

sub encode_model_externaldatasource ($self, $entity) {
  my @fields;
  if(my $class_name = $entity->import_class) {
    require(class_to_path($class_name));
    if($class_name->can('import_param_schemas')) {
      foreach my $type (qw(event eventactivity)) {
        my $schema = $class_name->import_param_schemas->{$type}->schema->data;
        next unless(ref($schema->{properties}) eq 'HASH');
        my %props = $schema->{properties}->%*;
        push(@fields, map +{
            name     => $_,
            label    => encode_label($_),
            activity => $type eq 'eventactivity',
            required => defined({map { $_ => 1 } $schema->{required_props}->@*}->{$_}),
            $props{$_}->%*,
          }, keys(%props));
      }
    }
  }

  return {
    id   => $entity->id,
    name => $entity->name,
    type => (split($NAMESPACE_IDENTIFIER, $entity->import_class))[2],
    ($entity->base_url ? (baseURL => $entity->base_url) : ()),
    fields => \@fields,
  };
}

sub encode_label($name) {
  return join($SPACE, map { /^id$/i ? 'ID' : ucfirst } split(/_/, $name));

}

1;
