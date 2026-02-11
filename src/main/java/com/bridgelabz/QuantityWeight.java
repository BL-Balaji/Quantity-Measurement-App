package com.bridgelabz;
import java.util.Objects;
public final class QuantityWeight {
    private static final double EPS = 1e-6;
    private final double value; private final WeightUnit unit;
    public QuantityWeight(double value, WeightUnit unit) {
        if (!Double.isFinite(value)) throw new IllegalArgumentException("Value must be finite");
        this.value = value; this.unit = Objects.requireNonNull(unit, "Unit must not be null");
    }
    public double getValue() { return value; }
    public WeightUnit getUnit() { return unit; }
    public QuantityWeight convertTo(WeightUnit t) {
        Objects.requireNonNull(t);
        return new QuantityWeight(t.convertFromBaseUnit(unit.convertToBaseUnit(value)), t);
    }
    public QuantityWeight add(QuantityWeight o) { return add(o, unit); }
    public QuantityWeight add(QuantityWeight o, WeightUnit t) {
        Objects.requireNonNull(o); Objects.requireNonNull(t);
        return new QuantityWeight(t.convertFromBaseUnit(unit.convertToBaseUnit(value)+o.unit.convertToBaseUnit(o.value)), t);
    }
    @Override public boolean equals(Object obj) {
        if(!(obj instanceof QuantityWeight o)) return false;
        return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value))<=EPS;
    }
    @Override public int hashCode() { return Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
    @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
}