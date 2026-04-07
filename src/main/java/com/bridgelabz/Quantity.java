package com.bridgelabz;
import java.util.Objects;
public class Quantity<U extends IMeasurable> {
    private final double value;
    private final U unit;
    private static final double EPSILON = 1e-6;
    public Quantity(double value, U unit) {
        if (unit == null) throw new IllegalArgumentException("Unit cannot be null");
        if (!Double.isFinite(value)) throw new IllegalArgumentException("Value must be finite");
        this.value = value;
        this.unit = unit;
    }
    public double getValue() { return value; }
    public U getUnit() { return unit; }
    public Quantity<U> convertTo(U targetUnit) {
        if (targetUnit == null) throw new IllegalArgumentException("Target unit cannot be null");
        if (this.unit.getClass() != targetUnit.getClass()) throw new IllegalArgumentException("Target unit must belong to same category");
        double base = unit.convertToBaseUnit(value);
        double converted = targetUnit.convertFromBaseUnit(base);
        return new Quantity<>(Math.round(converted*100.0)/100.0, targetUnit);
    }
    public Quantity<U> add(Quantity<U> other) { return add(other, this.unit); }
    public Quantity<U> add(Quantity<U> other, U targetUnit) {
        if (other == null) throw new IllegalArgumentException("Other cannot be null");
        if (this.unit.getClass() != other.unit.getClass()) throw new IllegalArgumentException("Cross-category not allowed");
        if (targetUnit == null) throw new IllegalArgumentException("Target unit cannot be null");
        this.unit.validateOperationSupport("addition");
        double sum = this.unit.convertToBaseUnit(this.value) + other.unit.convertToBaseUnit(other.value);
        return new Quantity<>(Math.round(targetUnit.convertFromBaseUnit(sum)*100.0)/100.0, targetUnit);
    }
    @Override public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof Quantity<?> other)) return false;
        if (this.unit.getClass() != other.unit.getClass()) return false;
        return Math.abs(unit.convertToBaseUnit(value) - other.unit.convertToBaseUnit(other.value)) < EPSILON;
    }
    @Override public int hashCode() {
        long rounded = Math.round(unit.convertToBaseUnit(value)/EPSILON);
        return Objects.hash(rounded, unit.getClass());
    }
    @Override public String toString() { return "Quantity(" + value + ", " + unit.getUnitName() + ")"; }
}