package com.bridgelabz;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import com.bridgelabz.QuantityMeasurementApp.Feet;

public class QuantityMeasurementAppTest {

    @Test
    void testSameValue() {
        Feet f1 = new Feet(1.0);
        Feet f2 = new Feet(1.0);
        assertTrue(f1.equals(f2));
    }

    @Test
    void testDifferentValue() {
        Feet f1 = new Feet(1.0);
        Feet f2 = new Feet(2.0);
        assertFalse(f1.equals(f2));
    }

    @Test
    void testNull() {
        Feet f1 = new Feet(1.0);
        assertFalse(f1.equals(null));
    }

    @Test
    void testDifferentClass() {
        Feet f1 = new Feet(1.0);
        assertFalse(f1.equals("1.0"));
    }

    @Test
    void testSameReference() {
        Feet f1 = new Feet(1.0);
        assertTrue(f1.equals(f1));
    }
}
