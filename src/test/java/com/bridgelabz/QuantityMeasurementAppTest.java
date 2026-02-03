package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1Feet_convertToInches_shouldReturn12() {
        QuantityMeasurementApp.QuantityLength r = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET).convertTo(QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(12.0, r.getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.INCH, r.getUnit());
    }
    @Test void given12Inches_convertToFeet_shouldReturn1() {
        assertEquals(1.0, new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH).convertTo(QuantityMeasurementApp.LengthUnit.FEET).getValue(), 1e-2);
    }
    @Test void given1Yard_convertToFeet_shouldReturn3() {
        assertEquals(3.0, new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS).convertTo(QuantityMeasurementApp.LengthUnit.FEET).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
}