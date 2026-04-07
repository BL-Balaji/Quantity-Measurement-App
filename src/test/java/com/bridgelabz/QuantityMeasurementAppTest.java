package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1Feet_convertToInches_shouldReturn12() {
        QuantityMeasurementApp.QuantityLength result =
            new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET)
                .convertTo(QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(12.0, result.getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.INCH, result.getUnit());
    }
    @Test void given12Inches_convertToFeet_shouldReturn1() {
        QuantityMeasurementApp.QuantityLength result =
            new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH)
                .convertTo(QuantityMeasurementApp.LengthUnit.FEET);
        assertEquals(1.0, result.getValue(), 1e-2);
    }
    @Test void given1Yard_convertToFeet_shouldReturn3() {
        QuantityMeasurementApp.QuantityLength result =
            new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS)
                .convertTo(QuantityMeasurementApp.LengthUnit.FEET);
        assertEquals(3.0, result.getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
}