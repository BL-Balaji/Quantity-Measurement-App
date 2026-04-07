package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1KgAnd1000Grams_shouldBeEqual() {
        assertEquals(new QuantityWeight(1.0, WeightUnit.KILOGRAM), new QuantityWeight(1000.0, WeightUnit.GRAM));
    }
    @Test void given1KgAnd1Gram_shouldNotBeEqual() {
        assertNotEquals(new QuantityWeight(1.0, WeightUnit.KILOGRAM), new QuantityWeight(1.0, WeightUnit.GRAM));
    }
    @Test void given1Kg_convertToGram_shouldBe1000() {
        assertEquals(1000.0, new QuantityWeight(1.0, WeightUnit.KILOGRAM).convertTo(WeightUnit.GRAM).getValue(), 1e-2);
    }
    @Test void given1KgAnd1000g_whenAdded_shouldBe2Kg() {
        QuantityWeight result = new QuantityWeight(1.0, WeightUnit.KILOGRAM).add(new QuantityWeight(1000.0, WeightUnit.GRAM));
        assertEquals(2.0, result.getValue(), 1e-2);
        assertEquals(WeightUnit.KILOGRAM, result.getUnit());
    }
    @Test void givenNullUnit_shouldThrow() {
        assertThrows(NullPointerException.class, () -> new QuantityWeight(1.0, null));
    }
    @Test void givenNonFiniteValue_shouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> new QuantityWeight(Double.NaN, WeightUnit.KILOGRAM));
    }
    @Test void given1FeetLength_stillWorks() {
        QuantityMeasurementApp.QuantityLength q = new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET);
        assertEquals(q, new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH));
    }
}