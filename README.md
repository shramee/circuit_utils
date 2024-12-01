# Cairo circuit utils

### New single felt u192
* `BoundedInt<0, 6277101735386680763835789423207666416102355444464034512895>>`
* Same costs as u128
```toml
[PASS] circuit_utils::tests::test_u192_split (gas: ~1)
        steps: 72
        memory holes: 9
        builtins: (range_check: 6)
        syscalls: ()
        
[PASS] circuit_utils::tests::test_u128_split (gas: ~1)
        steps: 72
        memory holes: 9
        builtins: (range_check: 6)
        syscalls: ()
```
* Unfortunately this is quite useless without felt conversion with `downcast`


### Efficient u384 serde
* Uses 2 felts (instead of 4)
* Requires generic `downcast`, atm throws
  - Failed to specialize: `downcast<felt252, BoundedInt<0, 6277101735386680763835789423207666416102355444464034512895>>`. Error: Could not specialize libfunc `downcast` with generic_args: [[1], [2]]. Error: Provided generic argument is unsupported.
