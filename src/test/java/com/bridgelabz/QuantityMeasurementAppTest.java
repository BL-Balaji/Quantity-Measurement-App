package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
    @Test void given1YardAnd3Feet_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS),
                     new QuantityMeasurementApp.QuantityLength(3.0, QuantityMeasurementApp.LengthUnit.FEET));
    }
    @Test void given1YardAnd36Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS),
                     new QuantityMeasurementApp.QuantityLength(36.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
    @Test void given2InchesAnd5Centimeters_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(2.0, QuantityMeasurementApp.LengthUnit.INCH),
                     new QuantityMeasurementApp.QuantityLength(5.08, QuantityMeasurementApp.LengthUnit.CENTIMETERS));
    }
    @Test void given1FeetAndBadCentimeters_shouldNotBeEqual() {
        assertNotEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                        new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.CENTIMETERS));
    }
}