package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_addInYards_shouldGiveCorrect() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        QuantityMeasurementApp.QuantityLength result = a.add(b, QuantityMeasurementApp.LengthUnit.YARDS);
        assertEquals(QuantityMeasurementApp.LengthUnit.YARDS, result.getUnit());
        assertEquals(0.67, result.getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addInInches_shouldGive24() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(24.0, a.add(b, QuantityMeasurementApp.LengthUnit.INCH).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addDefaultUnit_shouldGive2Feet() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(2.0, a.add(b).getValue(), 1e-2);
    }
}