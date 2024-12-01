use core::internal::bounded_int::{BoundedInt, DivRemHelper, div_rem};
use core::circuit::{u96, u384};

type ConstValue<const VALUE: felt252> = BoundedInt<VALUE, VALUE>;

pub type u192 = BoundedInt<0, { POW192 - 1 }>;

pub impl DivRemU192By96 of DivRemHelper<u192, ConstValue<POW96>> {
    type DivT = BoundedInt<0, { POW96 - 1 }>;
    type RemT = BoundedInt<0, { POW96 - 1 }>;
}

pub const POW96: felt252 = 0x1000000000000000000000000;
pub const POW192: felt252 = 0x1000000000000000000000000000000000000000000000000;
pub const u96_max: felt252 = 0xffffffffffffffffffffffff;
pub const u96_next: felt252 = 0x1000000000000000000000000;
pub const NZ_POW96_TYPED: NonZero<ConstValue<POW96>> = 0x1000000000000000000000000;

#[cfg(test)]
mod tests {
    use crate::{u192};

    use core::circuit::{u96, u384};

    #[test]
    fn test_felt_into_u192() {
        let a: felt252 = 1;
        let b: u192 = a.try_into().unwrap();
        assert(b == 1, 'incorrect value');
    }
}
