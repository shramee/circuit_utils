use core::internal::bounded_int::{BoundedInt, DivRemHelper, div_rem};
use core::circuit::{u96, u384, conversions::{POW96, NZ_POW96_TYPED}};

type ConstValue<const VALUE: felt252> = BoundedInt<VALUE, VALUE>;

pub type u192 = BoundedInt<0, { POW192 - 1 }>;

pub impl DivRemU192By96 of DivRemHelper<u192, ConstValue<POW96>> {
    type DivT = BoundedInt<0, { POW96 - 1 }>;
    type RemT = BoundedInt<0, { POW96 - 1 }>;
}

pub const POW192: felt252 = 0x1000000000000000000000000000000000000000000000000;

pub impl u384Serde of Serde<u384> {
    fn serialize(self: @u384, ref output: Array<felt252>) {
        let limb0 = (*self.limb0).into();
        let limb1 = (*self.limb1).into();
        let limb2 = (*self.limb2).into();
        let limb3 = (*self.limb3).into();
        output.append(limb0 + limb1 * POW96);
        output.append(limb2 + limb3 * POW96);
    }
    fn deserialize(ref serialized: Span<felt252>) -> Option<u384> {
        let [l0, l1] = (*serialized.multi_pop_front::<2>().unwrap()).unbox();
        let limb01: u192 = l0.try_into().unwrap();
        let limb23: u192 = l1.try_into().unwrap();
        let (limb1, limb0) = div_rem(limb01, NZ_POW96_TYPED);
        let (limb3, limb2) = div_rem(limb23, NZ_POW96_TYPED);
        return Option::Some(u384 { limb0: limb0, limb1: limb1, limb2: limb2, limb3: limb3 });
    }
}

#[cfg(test)]
mod tests {
    use crate::{u384Serde, u192, DivRemU192By96};
    use core::internal::bounded_int::{div_rem};

    use core::circuit::{u96, u384, conversions::{DivRemU128By64, NZ_POW64_TYPED, NZ_POW96_TYPED}};

    #[test]
    fn test_u192_split() {
        let b: u192 = 0xf00000000000000000000000000000000000000000000001;
        let (limb1, limb0) = div_rem(b, NZ_POW96_TYPED);

        assert(limb1 == 0xf00000000000000000000000, 'incorrect value');
        assert(limb0 == 0x1, 'incorrect value');
    }

    #[test]
    fn test_u128_split() {
        let b: u128 = 0xf0000000000000000000000000000001;
        let (limb1, limb0) = div_rem(b, NZ_POW64_TYPED);

        assert(limb1 == 0xf000000000000000, 'incorrect value');
        assert(limb0 == 0x1, 'incorrect value');
    }
    // #[test]
// fn test_felt_into_u192() {
//     let a: felt252 = 1;
//     let b: u192 = a.try_into().unwrap();
//     assert(b == 1, 'incorrect value');
// }
}
