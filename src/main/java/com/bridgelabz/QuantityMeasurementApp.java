package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) { this.value=value; this.unit=Objects.requireNonNull(unit); }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit t) {
            return new QuantityLength(Math.round(t.convertFromBaseUnit(unit.convertToBaseUnit(value))*100.0)/100.0, t);
        }
        public QuantityLength add(QuantityLength o) { return add(o,unit); }
        public QuantityLength add(QuantityLength o, LengthUnit t) {
            Objects.requireNonNull(o); Objects.requireNonNull(t);
            double sum = unit.convertToBaseUnit(value)+o.unit.convertToBaseUnit(o.value);
            return new QuantityLength(Math.round(t.convertFromBaseUnit(sum)*100.0)/100.0, t);
        }
        @Override public boolean equals(Object obj) {
            if(!(obj instanceof QuantityLength o)) return false;
            return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value))<EPS;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
    }
    public static void main(String[] args) {
        System.out.println("1ft==12in: "+new QuantityLength(1.0,LengthUnit.FEET).equals(new QuantityLength(12.0,LengthUnit.INCH)));
    }
}