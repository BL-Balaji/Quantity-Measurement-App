package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH));
    }
    @Test void given1Yard3Feet_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.YARDS),
                     new QuantityMeasurementApp.QuantityLength(3.0, LengthUnit.FEET));
    }
    @Test void given1Feet_convertToInches_shouldBe12() {
        assertEquals(12.0, new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET)
            .convertTo(LengthUnit.INCH).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12In_add_shouldBe2Feet() {
        assertEquals(2.0, new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET)
            .add(new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH)).getValue(), 1e-2);
    }
    @Test void givenLengthUnit_convertToBase_isCorrect() {
        assertEquals(1.0, LengthUnit.FEET.convertToBaseUnit(1.0), 1e-6);
        assertEquals(1.0/12.0, LengthUnit.INCH.convertToBaseUnit(1.0), 1e-6);
        assertEquals(3.0, LengthUnit.YARDS.convertToBaseUnit(1.0), 1e-6);
    }
}