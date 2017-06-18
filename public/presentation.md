# Variables, Scoping, and Namespaces

### Joel Berger

---

* I first gave this talk:
  - Chicago.pm on January 26, 2017
* I last updated it:
  - The Perl Conference, June 19, 2017
* The talk is hosted at:
  - <https://jberger.github.io/PresentationNamespaces>
* The source is available
  - <https://github.com/jberger/PresentationNamespaces>

---

## Disclaimer!

* This talk doesn't use strict/warnings
* You should ALWAYS use them
* This talk will actually teach you (partly) why :P

---

## Expectations/Target

This talk is intended for:

* People who have used Perl
* Not dug too deep
* Mostly written scripts or basic libraries
* Never were quite sure when or why to use `our`/`local`

---

This is a variable

```perl
$kitten
```

---

A variable is a place to put stuff

```perl
$kitten = 'Buttons';
```

---

As important as what it holds

```perl
$kitten = 'Buttons';

sub change_kitten_name { $kitten = 'Rufus' }

sub print_kitten_name  { print "$kitten\n" }

print_kitten_name(); # Buttons
change_kitten_name();
print_kitten_name(); # Rufus
```

* how do you find it (namespace, package, symbol)
* what code can see it (scope)

---

> packages are for finding things, ...

-- [Tom Christiansen](http://stackoverflow.com/questions/7523757/is-it-a-design-flaw-that-perl-subs-arent-lexically-scoped#comment9145532_7534272)

---

## Collisions

What if two pieces of code want to use the same variable?

```perl
sub set_person_name   { $name = 'Joel' }

sub print_person_name { print "$name\n" }

sub set_kitten_name   { $name = 'Buttons' }

set_person_name();
set_kitten_name();
print_person_name(); # Buttons (uh oh!)
```

---

## Prefixes

Naively, variables can be "prefixed"

```perl
sub set_person_name   { $person_name = 'Joel' }

sub print_person_name { print "$person_name\n" }

sub set_kitten_name   { $kitten_name = 'Buttons' }

set_person_name();
set_kitten_name();
print_person_name(); # Joel
```

---

## Namespaces

Better, variables can be "namespaced"

```perl
sub set_person_name   { $Person::name = 'Joel' }

sub print_person_name { print "$Person::name\n" }

sub set_kitten_name   { $Kitten::name = 'Buttons' }

set_person_name();
set_kitten_name();
print_person_name(); # Joel
```

---

## Namespaces

Actually, functions can too!

```perl
sub Person::set_name   { $Person::name = 'Joel' }

sub Person::print_name { print "$Person::name\n" }

sub Kitten::set_name   { $Kitten::name = 'Buttons' }

Person::set_name();
Kitten::set_name();
Person::print_name(); # Joel
```

---

### Why are namespaces better than prefixes?

---

## Packages

```package``` declares the "current" namespace

```perl
package Person;
sub set_name   { $name = 'Joel' }

sub print_name { print "$name\n" }

package Kitten;
sub set_name   { $name = 'Buttons' }

package main;
Person::set_name();
Kitten::set_name();
Person::print_name(); # Joel
```

---

### Package Variables Are Still Global

```perl
package Person;
$name = 'Joel';

package Kitten;
$name = 'Buttons';

package main;
print "$Person::name owns $Kitten::name\n";
# Joel owns Buttons
```

---

## The Stash

All of the package symbols are stored in a giant hash.

* The symbol table hash, or "stash"
* Not directly used very often!
* Represented with trailing colons:

```perl
use Data::Dumper;
print Dumper(\%::);
print Dumper(\%Data::Dumper::);
```

---

## Privacy

```perl
package Person;
$name = 'Joel';

package Kitten;
$name = 'Buttons';

package main;
$Person::name = 'Doug'; # Doug steals the kitten!
print "$Person::name owns $Kitten::name\n";
# Doug owns Buttons
```

---

## Privacy (better example)

```perl
@items = (qw[hi hello hippo]);
for $item (@items) {
  $upper = upper($item);
  print "$item becomes $upper\n";
};

sub upper {
  $item = uc $_[0];
  return $item;
}
# HI becomes HI
# HELLO becomes HELLO
# HIPPO becomes HIPPO
```

---

## Lexical Variables (my)

Only visible within a "block" ```{  }``` or "scope"

```perl
@items = (qw/hi hello hippo/);
for my $item (@items) {
  $upper = upper($item);
  print "$item becomes $upper\n";
};

sub upper {
  my $item = uc $_[0];
  return $item;
}
# hi becomes HI
# hello becomes HELLO
# hippo becomes HIPPO
```

---

## Lexicals

* prevent clobbering/overwriting
  - (intentional or accidental)
* prevent reading by other code
* not bound to ANY namespace
  - cannot be accessed with fully qualified name
  - are not in the stash
* bound to a scope

---

> packages are for finding things,</br>
> scopes are for hiding things

-- [Tom Christiansen](http://stackoverflow.com/questions/7523757/is-it-a-design-flaw-that-perl-subs-arent-lexically-scoped#comment9145532_7534272)

---

## Prevent Kitten Theft!

```perl
{
  package Person;
  my $name = 'Joel';
  sub name { return $name }
}

{
  package Kitten;
  my $name = 'Buttons';
  sub name { return $name }
}

package main;
print Person::name() . ' owns ' . Kitten::name() . "\n";
# Joel owns Buttons
```

---

## What is a scope?

* A block: `{ }`
* A file (if not within a block)

---

## Package keyword is lexically scoped

```perl
{
  package Person;
  my $name = 'Joel';
  sub name { return $name }
}

{
  package Kitten;
  my $name = 'Buttons';
  sub name { return $name }
}

package main; # actually this isn't necessary
print Person::name() . ' owns ' . Kitten::name() . "\n";
# Joel owns Buttons
```

---

## Package keyword is lexically scoped

```perl
{
  package Person;
  my $name = 'Joel';
  sub name { return $name }
}

{
  package Kitten;
  my $name = 'Buttons';
  sub name { return $name }
}

print Person::name() . ' owns ' . Kitten::name() . "\n";
# Joel owns Buttons
```

---

## Should I use globals or lexicals?

* Default to using lexicals
  - Safer (action at a distance)
  - Faster
* Use globals for truly global behavior
  - System resources
  - Functional behavior in non-OO libraries

---

## If lexicals are better why aren't they the default?

* IMO they should be but ...
* History, don't want to break old code

---

## If lexicals are better can I make sure I use them?

* Yes! This is what `use strict` does!
* `use strict 'vars'` requires declaring all variables.
* The rest of this talk is strict safe

---

## How do I create/access a global under strict?

* fully qualified name
  - `$Kitten::name`
* `our` keyword
  - `package Kitten; our $name`

---

## The our keyword

A lexical alias to a package variable

```perl
{
  package Kitten;
  my $name = 'Buttons';
  my $owner = 'Joel';
  our $caretaker = $owner;
  sub info { "$owner owns $name, cared for by $caretakter" }
}

print Kitten::info(); # Joel owns Buttons, cared for by Joel
$Kitten::caretaker = 'Doug';
print Kitten::info(); # Joel owns Buttons, cared for by Doug
```

---

## our is kinda strange

The alias is lexical, the effect is global

```perl
package Kitten;
our $caretaker;
{
  my $name = 'Buttons';
  my $owner = 'Joel';
  $caretaker = $owner;
  sub info { "$owner owns $name, cared for by $caretakter" }
}

package main;
$caretaker = 'Doug'; # Not fully qualified, still in lexical scope!
print Kitten::info();
```

---

## Be nice, use globals locally

The `local` keyword sets a global

  * For the rest of the current scope
  * ... and all inner scopes

---

```perl
{
  package Kitten;
  my $name = 'Buttons';
  my $owner = 'Joel';
  our $caretaker = $owner;
  sub info { "$owner owns $name, cared for by $caretakter" }
}

{
  local $Kitten::caretaker = 'Doug';
  print Kitten::info(); # Joel owns Buttons, cared for by Doug
}
print Kitten::info(); # Joel owns Buttons, cared for by Joel
```

---

## Local Perl Magic Vars

`$"`

the character printed between interpolated array items

---

## Local Perl Magic Vars

```perl
sub say_these { print "@_\n" }

# most of this code needs commas
$" = ',';
say_these(qw[parsley sage rosemary thyme]) #parsely,sage,rosemary,thyme
{
  # this block really needs pipes
  local $" = '|';
  say_these(qw[cows sheep goats]); #cows|sheep|goats
}
say_these(qw[trains planes automobiles]) #planes,trains,automobiles
```

---

## Local only works on globals ...

```perl
my $x = 12;
{
  local $x = 50; # error
}
```

---

## ... usually

Also works on datastructure elements.

```perl
my %data;
$data{x} = 12;
{
  local $data{x} = 50; # just fine
}
```

but you should probably wait to use that until you have a GREAT reason.

---

## Manipulating the stash

Mocking database access

```perl
# lib/MyApp/Database.pm

package MyApp::Database;

sub run_query {
  # connect to external resource, return data
}

# t/database.t

local *MyApp::Database::run_query = sub {
  return $known_result
}

...
```

---

## Evil Monkey-Patching

```perl
sub strange_function {
  local *Some::Library::foo = sub { ... };
  my $result = Some::Library::bar_calls_foo();
  return $result;
}
```

---

> With great power comes great responsiblity

---

## Summary

* packages are for finding things
  - globals
  - namespaces/packages
  - our
* scopes are for hiding things
  - lexicals
  - blocks
  - my

---

# Questions?

---

## But Wait, There's More

---

### One More Variable Declaration

```perl
state $var
```

---

### Function with a Counter

```perl
sub say_count {
  my $count = 0;
  printf "this has been called %i times\n", ++$count;
}
```

<span class="fragment">
Except of course that one doesn't work!
</span>

---

### Function with a (Working) Counter

```perl
my $count = 0;
sub say_count {
  printf "this has been called %i times\n", ++$count;
}
```

<span class="fragment">
Except of course that one isn't safe!
</span>

---

### Function with a (Safe, Working) Counter

```perl
{
  my $count = 0;
  sub say_count {
    printf "this has been called %i times\n", ++$count;
  }
}
```
<span class="fragment">
Except of course that's a lot to type!
</span>

---


### Function with a (Concise, Safe, Working) Counter

```perl
sub say_count {
  state $count = 0;
  printf "this has been called %i times\n", ++$count;
}
```

