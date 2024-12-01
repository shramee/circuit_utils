# Cairo circuit utils

### New single felt u192
* `BoundedInt<0, 6277101735386680763835789423207666416102355444464034512895>>`

### Efficient u384 serde
* Uses 2 felts (instead of 4)
* Requires generic `downcast`, atm throws
  - Failed to specialize: `downcast<felt252, BoundedInt<0, 6277101735386680763835789423207666416102355444464034512895>>`. Error: Could not specialize libfunc `downcast` with generic_args: [[1], [2]]. Error: Provided generic argument is unsupported.
