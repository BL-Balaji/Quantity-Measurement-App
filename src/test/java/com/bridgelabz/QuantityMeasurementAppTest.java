package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_addInYards_shouldGiveCorrect() {
        QuantityMeasurementApp.QuantityLength r = new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH),QuantityMeasurementApp.LengthUnit.YARDS);
        assertEquals(QuantityMeasurementApp.LengthUnit.YARDS, r.getUnit());
        assertEquals(0.67, r.getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addInInches_shouldGive24() {
        assertEquals(24.0, new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH),QuantityMeasurementApp.LengthUnit.INCH).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addDefault_shouldGive2Feet() {
        assertEquals(2.0, new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH)).getValue(), 1e-2);
    }
}