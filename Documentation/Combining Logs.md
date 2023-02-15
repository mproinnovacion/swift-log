#  Combining Logs

##	Concat

A function concat is provided to combine two logs and produce both effects sequentially:

```
log1.concat(log2) // Will produce log1 output first and then log2
```

## Reduced

An extension of an Array of Log, that allows combining multiple logs into one.

```
let combined = [ log1, log2, log3 ].reduced
```
