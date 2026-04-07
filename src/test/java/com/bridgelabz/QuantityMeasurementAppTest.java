package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1LitreAnd1000ML_shouldBeEqual() {
        assertEquals(new Quantity<>(1.0, VolumeUnit.LITRE), new Quantity<>(1000.0, VolumeUnit.MILLILITRE));
    }
    @Test void given1GallonConverted_shouldBe3_78Litres() {
        Quantity<VolumeUnit> result = new Quantity<>(1.0, VolumeUnit.GALLON).convertTo(VolumeUnit.LITRE);
        assertEquals(3.79, result.getValue(), 1e-2);
    }
    @Test void given1LitreAnd2Litres_add_shouldBe3() {
        Quantity<VolumeUnit> result = new Quantity<>(1.0, VolumeUnit.LITRE).add(new Quantity<>(2.0, VolumeUnit.LITRE));
        assertEquals(3.0, result.getValue(), 1e-2);
    }
    @Test void given1KgAnd1000g_stillWork() {
        assertEquals(new QuantityWeight(1.0, WeightUnit.KILOGRAM), new QuantityWeight(1000.0, WeightUnit.GRAM));
    }
    @Test void given1FeetAnd12Inches_stillWork() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH));
    }
    @Test void givenCrossCategory_shouldThrow() {
        Quantity<LengthUnit> l = new Quantity<>(1.0, LengthUnit.FEET);
        Quantity<WeightUnit> w = new Quantity<>(1.0, WeightUnit.KILOGRAM);
        assertThrows(IllegalArgumentException.class, () -> l.add((Quantity)w));
    }
}