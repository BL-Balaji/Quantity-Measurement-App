package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    private static final double EPS = 1e-6;
    @Test void given10FeetDividedBy2Feet_shouldBe5() {
        assertEquals(5.0, new Quantity<>(10.0, LengthUnit.FEET).divide(new Quantity<>(2.0, LengthUnit.FEET)), EPS);
    }
    @Test void given24InchDividedBy2Feet_shouldBe1() {
        assertEquals(1.0, new Quantity<>(24.0, LengthUnit.INCH).divide(new Quantity<>(2.0, LengthUnit.FEET)), EPS);
    }
    @Test void given5FeetDividedBy10Feet_shouldBe0_5() {
        assertEquals(0.5, new Quantity<>(5.0, LengthUnit.FEET).divide(new Quantity<>(10.0, LengthUnit.FEET)), EPS);
    }
    @Test void givenDivideByZero_shouldThrow() {
        assertThrows(ArithmeticException.class, () ->
            new Quantity<>(10.0, LengthUnit.FEET).divide(new Quantity<>(0.0, LengthUnit.FEET)));
    }
    @Test void givenTemperatureDivide_shouldThrow() {
        assertThrows(UnsupportedOperationException.class, () ->
            new Quantity<>(100.0, TemperatureUnit.CELSIUS).divide(new Quantity<>(50.0, TemperatureUnit.CELSIUS)));
    }
    @Test void given10KgDividedBy2Kg_shouldBe5() {
        assertEquals(5.0, new Quantity<>(10.0, WeightUnit.KILOGRAM).divide(new Quantity<>(2.0, WeightUnit.KILOGRAM)), EPS);
    }
    @Test void given10FeetMinus5Feet_shouldBe5Feet() {
        assertEquals(5.0, new Quantity<>(10.0, LengthUnit.FEET).subtract(new Quantity<>(5.0, LengthUnit.FEET)).getValue(), EPS);
    }
    @Test void given0CelsiusAnd32Fahrenheit_shouldBeEqual() {
        assertEquals(new Quantity<>(0.0, TemperatureUnit.CELSIUS), new Quantity<>(32.0, TemperatureUnit.FAHRENHEIT));
    }
    @Test void divisionIsImmutable() {
        Quantity<LengthUnit> a = new Quantity<>(10.0, LengthUnit.FEET);
        Quantity<LengthUnit> b = new Quantity<>(5.0, LengthUnit.FEET);
        a.divide(b);
        assertEquals(10.0, a.getValue(), EPS);
    }
}