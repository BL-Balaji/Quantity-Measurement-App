package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd1Feet_whenAdded_shouldReturn2Feet() {
        assertEquals(2.0, new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET)).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_whenAdded_shouldReturn2Feet() {
        QuantityMeasurementApp.QuantityLength r = new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH));
        assertEquals(2.0, r.getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.FEET, r.getUnit());
    }
    @Test void given3InchesAnd3Inches_whenAdded_shouldReturn6Inches() {
        assertEquals(6.0, new QuantityMeasurementApp.QuantityLength(3.0,QuantityMeasurementApp.LengthUnit.INCH).add(new QuantityMeasurementApp.QuantityLength(3.0,QuantityMeasurementApp.LengthUnit.INCH)).getValue(), 1e-2);
    }
    @Test void givenAddWithNull_shouldThrow() {
        assertThrows(NullPointerException.class, () -> new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(null));
    }
}