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
    @Test void givenSameInches_shouldBeEqual() {
        assertTrue(new QuantityMeasurementApp.Inches(5.0).equals(new QuantityMeasurementApp.Inches(5.0)));
    }
    @Test void givenDifferentInches_shouldNotBeEqual() {
        assertFalse(new QuantityMeasurementApp.Inches(3.0).equals(new QuantityMeasurementApp.Inches(7.0)));
    }
    @Test void givenInches_comparedWithNull_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Inches(1.0).equals(null));
    }
}