sub concat {
  $tmp = join '',  @_;
  return $tmp;
}

for $tmp (1..3) {
  print concat(concat($tmp, $tmp), $tmp) . "\n";
}
