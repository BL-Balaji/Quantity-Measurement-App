package com.bridgelabz;
import java.util.Objects;
public final class QuantityWeight {
    private static final double EPS = 1e-6;
    private final double value;
    private final WeightUnit unit;
    public QuantityWeight(double value, WeightUnit unit) {
        if (!Double.isFinite(value)) throw new IllegalArgumentException("Value must be finite");
        this.value = value;
        this.unit = Objects.requireNonNull(unit, "Unit must not be null");
    }
    public double getValue() { return value; }
    public WeightUnit getUnit() { return unit; }
    public QuantityWeight convertTo(WeightUnit target) {
        Objects.requireNonNull(target);
        double base = unit.convertToBaseUnit(value);
        return new QuantityWeight(target.convertFromBaseUnit(base), target);
    }
    public QuantityWeight add(QuantityWeight other) { return add(other, this.unit); }
    public QuantityWeight add(QuantityWeight other, WeightUnit targetUnit) {
        Objects.requireNonNull(other); Objects.requireNonNull(targetUnit);
        double sum = this.unit.convertToBaseUnit(this.value) + other.unit.convertToBaseUnit(other.value);
        return new QuantityWeight(targetUnit.convertFromBaseUnit(sum), targetUnit);
    }
    @Override public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof QuantityWeight other)) return false;
        return Math.abs(unit.convertToBaseUnit(value) - other.unit.convertToBaseUnit(other.value)) <= EPS;
    }
    @Override public int hashCode() { return Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
    @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
}