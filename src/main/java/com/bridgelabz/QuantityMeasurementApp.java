package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit, "Unit must not be null");
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit target) {
            Objects.requireNonNull(target, "Target unit must not be null");
            double base = unit.convertToBaseUnit(value);
            double converted = target.convertFromBaseUnit(base);
            return new QuantityLength(Math.round(converted*100.0)/100.0, target);
        }
        public QuantityLength add(QuantityLength other) { return add(other, this.unit); }
        public QuantityLength add(QuantityLength other, LengthUnit targetUnit) {
            Objects.requireNonNull(other); Objects.requireNonNull(targetUnit);
            double sum = this.unit.convertToBaseUnit(this.value) + other.unit.convertToBaseUnit(other.value);
            return new QuantityLength(Math.round(targetUnit.convertFromBaseUnit(sum)*100.0)/100.0, targetUnit);
        }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (!(obj instanceof QuantityLength other)) return false;
            return Math.abs(unit.convertToBaseUnit(value) - other.unit.convertToBaseUnit(other.value)) < EPS;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        QuantityLength q1 = new QuantityLength(1.0, LengthUnit.FEET);
        QuantityLength q2 = new QuantityLength(12.0, LengthUnit.INCH);
        System.out.println("Equals: " + q1.equals(q2));
        System.out.println("Add: " + q1.add(q2));
        System.out.println("Convert: " + q1.convertTo(LengthUnit.INCH));
    }
}