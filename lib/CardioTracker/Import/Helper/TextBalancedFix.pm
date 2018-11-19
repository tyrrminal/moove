package CardioTracker::Import::Helper::TextBalancedFix;

# hacky workaround for desperate folk
# intended to be copypasted into your app
    {
      require Text::Balanced;
      require overload;

      local $@;

      # this is what poisons $@
      Text::Balanced::extract_bracketed( '(foo', '()' );

      if ($@ and overload::Overloaded($@) and ! overload::Method($@,'fallback') ) {
        my $class = ref $@;
        eval "package $class; overload->import(fallback => 1);"
      }
    }
# end of hacky workaround

1;
