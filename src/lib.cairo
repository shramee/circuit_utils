use core::internal::bounded_int::{BoundedInt, DivRemHelper, div_rem, mul, add};
use core::integer::{downcast};
use core::circuit::{u96, u384, conversions::{POW96}};
use core::circuit::conversions::{
    DivRemU128By64, DivRemU128By96, AddHelperTo96By32Impl, MulHelper64By32Impl, NZ_POW64_TYPED,
    NZ_POW96_TYPED, POW32, POW64, POW32_TYPED
};

type ConstValue<const VALUE: felt252> = BoundedInt<VALUE, VALUE>;

pub type u192 = BoundedInt<0, { POW192 - 1 }>;

pub impl DivRemU192By96 of DivRemHelper<u192, ConstValue<POW96>> {
    type DivT = BoundedInt<0, { POW96 - 1 }>;
    type RemT = BoundedInt<0, { POW96 - 1 }>;
}

pub const POW192: felt252 = 0x1000000000000000000000000000000000000000000000000;

pub type bu64 = BoundedInt<0, { POW64 - 1 }>;

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
        let [l0, l1] = (*serialized.multi_pop_front::<2>()?).unbox();
        let limbs_01: u256 = l0.into();
        let limbs_23: u256 = l1.into();

        let (limb1_low32, limb0) = div_rem(limbs_01.low, NZ_POW96_TYPED);
        let limb1_high64: bu64 = downcast(limbs_01.high)?;
        let limb1 = add(mul(limb1_high64, POW32_TYPED), limb1_low32);

        let (limb3_low32, limb2) = div_rem(limbs_23.low, NZ_POW96_TYPED);
        let limb3_high64: bu64 = downcast(limbs_23.high)?;
        let limb3 = add(mul(limb3_high64, POW32_TYPED), limb3_low32);

        return Option::Some(u384 { limb0, limb1, limb2, limb3 });
    }
}

fn makeshift_deser(ref serialized: Span<felt252>) -> Option<u384> {
    let [l0, l1] = (*serialized.multi_pop_front::<2>().unwrap()).unbox();
    let limbs_01: u128 = l0.try_into().unwrap();
    let limbs_23: u128 = l1.try_into().unwrap();

    let (_limb1, limb0) = div_rem(limbs_01, NZ_POW96_TYPED);
    let (_limb3, limb2) = div_rem(limbs_23, NZ_POW96_TYPED);

    return Option::Some(u384 { limb0, limb1: 0, limb2, limb3: 0 });
}

#[cfg(test)]
mod tests {
    use crate::{u384Serde, u192, DivRemU192By96, makeshift_deser};
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

    #[test]
    fn test_u384_serde_with_u256() {
        let l0: u96 = 0x7dfd0ecbea960d0dca2b3f07;
        let l1: u96 = 0xfc753d9e59bf8e2b5aab76dc;
        let l2: u96 = 0x3cd0d53524febdb746ec2b73;
        let l3: u96 = 0x7df34f316f979409408f5847;

        let l01: felt252 =
            0xfc753d9e59bf8e2b5aab76dc7dfd0ecbea960d0dca2b3f07; // contains first 2 u96
        let l23: felt252 =
            0x7df34f316f979409408f58473cd0d53524febdb746ec2b73; // // contains last 2 u96
        let mut span = [l01, l23].span();

        let b: u384 = u384Serde::deserialize(ref span).unwrap();
        assert(b.limb0 == l0, 'incorrect value');
        assert(b.limb1 == l1, 'incorrect value');
        assert(b.limb2 == l2, 'incorrect value');
        assert(b.limb3 == l3, 'incorrect value');
    }
    #[test]
    fn cost_u384_serde_with_u256() {
        let mut span = [
            0xfc753d9e59bf8e2b5aab76dc7dfd0ecbea960d0dca2b3f07, // contains first 2 u96
            0x7df34f316f979409408f58473cd0d53524febdb746ec2b73, // // contains last 2 u96
        ].span();

        let _b: u384 = u384Serde::deserialize(ref span).unwrap();
        assert(true, '')
    }

    #[test]
    fn projected_cost_u384_serde_with_u196_assuming_equiv() {
        let mut span = [
            0xfc753d9e59bf8e2b5aab76dc7dfd0ecb, // contains first u96 and u32
            0x7df34f316f979409408f58473cd0d535, // // contains last u96 and u32
        ].span();

        let _b: u384 = makeshift_deser(ref span).unwrap();
        assert(true, '')
    }
}
