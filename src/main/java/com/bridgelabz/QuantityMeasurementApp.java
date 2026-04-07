package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0 / 12.0);
        private final double toFeetFactor;
        LengthUnit(double f) { this.toFeetFactor = f; }
        public double toFeet(double v) { return v * toFeetFactor; }
    }
    public static final class QuantityLength {
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit, "Unit must not be null");
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            QuantityLength other = (QuantityLength) obj;
            return Double.compare(this.valueInFeet(), other.valueInFeet()) == 0;
        }
        @Override public int hashCode() { return Objects.hash(valueInFeet()); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit.name().toLowerCase() + ")"; }
    }
    public static boolean areFeetEqual(double a, double b) {
        return new QuantityLength(a, LengthUnit.FEET).equals(new QuantityLength(b, LengthUnit.FEET));
    }
    public static boolean areInchesEqual(double a, double b) {
        return new QuantityLength(a, LengthUnit.INCH).equals(new QuantityLength(b, LengthUnit.INCH));
    }
    public static void main(String[] args) {
        QuantityLength q1 = new QuantityLength(1.0, LengthUnit.FEET);
        QuantityLength q2 = new QuantityLength(12.0, LengthUnit.INCH);
        System.out.println("1 ft == 12 in: " + q1.equals(q2));
    }
}