package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import com.bridgelabz.QuantityMeasurementApp.Feet;
import com.bridgelabz.QuantityMeasurementApp.Inches;

public class QuantityMeasurementAppTest {

    // ---------- FEET TESTS ----------

    @Test
    void testFeetEquality_SameValue() {
        assertTrue(new Feet(1.0).equals(new Feet(1.0)));
    }

    @Test
    void testFeetEquality_DifferentValue() {
        assertFalse(new Feet(1.0).equals(new Feet(2.0)));
    }

    @Test
    void testFeetEquality_NullComparison() {
        assertFalse(new Feet(1.0).equals(null));
    }

    @Test
    void testFeetEquality_DifferentClass() {
        assertFalse(new Feet(1.0).equals("1.0"));
    }

    @Test
    void testFeetEquality_SameReference() {
        Feet f = new Feet(1.0);
        assertTrue(f.equals(f));
    }

    // ---------- INCHES TESTS ----------

    @Test
    void testInchesEquality_SameValue() {
        assertTrue(new Inches(1.0).equals(new Inches(1.0)));
    }

    @Test
    void testInchesEquality_DifferentValue() {
        assertFalse(new Inches(1.0).equals(new Inches(2.0)));
    }

    @Test
    void testInchesEquality_NullComparison() {
        assertFalse(new Inches(1.0).equals(null));
    }

    @Test
    void testInchesEquality_DifferentClass() {
        assertFalse(new Inches(1.0).equals(1.0));
    }

    @Test
    void testInchesEquality_SameReference() {
        Inches i = new Inches(1.0);
        assertTrue(i.equals(i));
    }
}