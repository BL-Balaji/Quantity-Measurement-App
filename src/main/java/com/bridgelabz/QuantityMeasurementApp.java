package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
        private final double toFeetFactor;
        LengthUnit(double f) { this.toFeetFactor = f; }
        public double toFeet(double v) { return v * toFeetFactor; }
        public double fromFeet(double v) { return v / toFeetFactor; }
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
        public QuantityLength convertTo(LengthUnit target) {
            Objects.requireNonNull(target, "Target unit must not be null");
            double feet = unit.toFeet(value);
            double converted = target.fromFeet(feet);
            return new QuantityLength(Math.round(converted * 100.0) / 100.0, target);
        }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            QuantityLength other = (QuantityLength) obj;
            return Math.abs(this.valueInFeet() - other.valueInFeet()) < 1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(valueInFeet() * 1e6)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        QuantityLength q = new QuantityLength(1.0, LengthUnit.FEET);
        System.out.println("1 ft in inches: " + q.convertTo(LengthUnit.INCH));
    }
}