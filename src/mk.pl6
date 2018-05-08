use v6;

my @args;

for @*ARGS -> $arg {
  given $arg {
    when '-h'|'--help' {}
  }
}

my $name = @args[0];

open my $file, $name, :w or die

close $file or die "Failed to delete "
