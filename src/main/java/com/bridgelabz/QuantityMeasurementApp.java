package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0/12.0), YARDS(3.0), CENTIMETERS(1.0/30.48);
        private final double f;
        LengthUnit(double f) { this.f = f; }
        public double toFeet(double v) { return v*f; }
        public double fromFeet(double v) { return v/f; }
    }
    public static final class QuantityLength {
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) { this.value=value; this.unit=Objects.requireNonNull(unit); }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double inFeet() { return unit.toFeet(value); }
        public QuantityLength convertTo(LengthUnit t) { return new QuantityLength(Math.round(t.fromFeet(unit.toFeet(value))*100.0)/100.0, t); }
        public QuantityLength add(QuantityLength other) {
            Objects.requireNonNull(other);
            return new QuantityLength(Math.round(unit.fromFeet(this.inFeet()+other.inFeet())*100.0)/100.0, unit);
        }
        @Override public boolean equals(Object obj) {
            if (!(obj instanceof QuantityLength o)) return false;
            return Math.abs(this.inFeet()-o.inFeet())<1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(inFeet()*1e6)); }
        @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
    }
    public static void main(String[] args) {
        System.out.println("1ft+12in="+new QuantityLength(1.0,LengthUnit.FEET).add(new QuantityLength(12.0,LengthUnit.INCH)));
    }
}