package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd1Feet_whenAdded_shouldReturn2Feet() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        assertEquals(2.0, a.add(b).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_whenAdded_shouldReturn2Feet() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(2.0, a.add(b).getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.FEET, a.add(b).getUnit());
    }
    @Test void given3InchesAnd3Inches_whenAdded_shouldReturn6Inches() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(3.0, QuantityMeasurementApp.LengthUnit.INCH);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(3.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(6.0, a.add(b).getValue(), 1e-2);
    }
    @Test void givenAddWithNull_shouldThrowException() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        assertThrows(NullPointerException.class, () -> a.add(null));
    }
}