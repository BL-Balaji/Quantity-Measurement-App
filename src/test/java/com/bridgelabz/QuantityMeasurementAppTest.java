package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void givenSameFeet_shouldBeEqual() {
        assertTrue(new QuantityMeasurementApp.Feet(1.0).equals(new QuantityMeasurementApp.Feet(1.0)));
    }
    @Test void givenDifferentFeet_shouldNotBeEqual() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals(new QuantityMeasurementApp.Feet(2.0)));
    }
    @Test void givenFeet_comparedWithNull_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals(null));
    }
    @Test void givenSameReference_shouldBeEqual() {
        QuantityMeasurementApp.Feet a = new QuantityMeasurementApp.Feet(1.0);
        assertTrue(a.equals(a));
    }
    @Test void givenFeet_comparedWithDifferentType_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals("1.0"));
    }
}