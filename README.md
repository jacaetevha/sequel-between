# sequel-between
Create BETWEEN and NOT BETWEEN comparison expressions in Sequel.

## between
```ruby
Sequel.between(Sequel::CURRENT_DATE, :a, :b)
Sequel.between(1, -1, Sequel.function(:max, :c))
Sequel.between(
  :something,
  DB[:foo].select(Sequel.function(:max, :blat)),
  DB[:bar].select(Sequel.function(:max, :baz)),
)
```

## not_between
```ruby
Sequel.not_between(Sequel::CURRENT_DATE, :a, :b)
Sequel.not_between(1, -1, Sequel.function(:max, :c))
Sequel.not_between(
  :something,
  DB[:foo].select(Sequel.function(:max, :blat)),
  DB[:bar].select(Sequel.function(:max, :baz)),
)
```

## with core_refinements
```ruby
Sequel.core_refinements
using CoreRefinements
:a.between(:b, :c)
:a.not_between(1, 10)
```

## with core_extensions
```ruby
Sequel.core_extensions
:a.between(:b, :c)
:a.not_between(1, 10)
```