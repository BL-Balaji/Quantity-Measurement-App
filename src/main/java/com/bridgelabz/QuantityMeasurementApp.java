package com.bridgelabz;
public class QuantityMeasurementApp {
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value; this.unit = java.util.Objects.requireNonNull(unit);
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit t) {
            return new QuantityLength(Math.round(t.convertFromBaseUnit(unit.convertToBaseUnit(value))*100.0)/100.0, t);
        }
        public QuantityLength add(QuantityLength o) { return add(o, unit); }
        public QuantityLength add(QuantityLength o, LengthUnit t) {
            double sum = unit.convertToBaseUnit(value) + o.unit.convertToBaseUnit(o.value);
            return new QuantityLength(Math.round(t.convertFromBaseUnit(sum)*100.0)/100.0, t);
        }
        @Override public boolean equals(Object obj) {
            if (!(obj instanceof QuantityLength o)) return false;
            return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value)) < EPS;
        }
        @Override public int hashCode() { return java.util.Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        Quantity<VolumeUnit> v1 = new Quantity<>(1.0, VolumeUnit.LITRE);
        Quantity<VolumeUnit> v2 = new Quantity<>(1000.0, VolumeUnit.MILLILITRE);
        System.out.println("1 litre == 1000 ml: " + v1.equals(v2));
        System.out.println("1 gallon in litres: " + new Quantity<>(1.0, VolumeUnit.GALLON).convertTo(VolumeUnit.LITRE));
    }
}