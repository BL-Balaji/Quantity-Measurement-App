package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    private static final double EPS = 1e-2;
    @Test void given10FeetMinus5Feet_shouldBe5Feet() {
        Quantity<LengthUnit> result = new Quantity<>(10.0, LengthUnit.FEET).subtract(new Quantity<>(5.0, LengthUnit.FEET));
        assertEquals(5.0, result.getValue(), EPS);
        assertEquals(LengthUnit.FEET, result.getUnit());
    }
    @Test void given10FeetMinus6Inches_shouldBe9_5Feet() {
        Quantity<LengthUnit> result = new Quantity<>(10.0, LengthUnit.FEET).subtract(new Quantity<>(6.0, LengthUnit.INCH));
        assertEquals(9.5, result.getValue(), EPS);
    }
    @Test void given10FeetMinus5Feet_inInches_shouldBe60() {
        Quantity<LengthUnit> result = new Quantity<>(10.0, LengthUnit.FEET)
            .subtract(new Quantity<>(5.0, LengthUnit.FEET), LengthUnit.INCH);
        assertEquals(60.0, result.getValue(), EPS);
    }
    @Test void givenSubtractResultsInNegative_works() {
        Quantity<LengthUnit> result = new Quantity<>(5.0, LengthUnit.FEET).subtract(new Quantity<>(10.0, LengthUnit.FEET));
        assertEquals(-5.0, result.getValue(), EPS);
    }
    @Test void givenTemperatureSubtract_shouldThrow() {
        assertThrows(UnsupportedOperationException.class, () ->
            new Quantity<>(100.0, TemperatureUnit.CELSIUS).subtract(new Quantity<>(50.0, TemperatureUnit.CELSIUS)));
    }
    @Test void givenSubtractNull_shouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> new Quantity<>(10.0, LengthUnit.FEET).subtract(null));
    }
    @Test void given1LitreAnd1000ML_stillWork() {
        assertEquals(new Quantity<>(1.0, VolumeUnit.LITRE), new Quantity<>(1000.0, VolumeUnit.MILLILITRE));
    }
    @Test void givenSubtract_isImmutable() {
        Quantity<LengthUnit> a = new Quantity<>(10.0, LengthUnit.FEET);
        Quantity<LengthUnit> b = new Quantity<>(5.0, LengthUnit.FEET);
        a.subtract(b);
        assertEquals(10.0, a.getValue(), EPS);
        assertEquals(5.0, b.getValue(), EPS);
    }
}