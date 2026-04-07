package com.bridgelabz;
import java.util.Objects;
public class Quantity<U extends IMeasurable> {
    private final double value;
    private final U unit;
    private static final double EPSILON = 1e-6;
    private enum Op {
        ADD { @Override double compute(double a, double b) { return a+b; } },
        SUBTRACT { @Override double compute(double a, double b) { return a-b; } },
        DIVIDE { @Override double compute(double a, double b) {
            if (Math.abs(b) < EPSILON) throw new ArithmeticException("Cannot divide by zero quantity");
            return a/b;
        }};
        static final double EPSILON = 1e-6;
        abstract double compute(double a, double b);
    }
    public Quantity(double value, U unit) {
        if (unit == null) throw new IllegalArgumentException("Unit cannot be null");
        if (!Double.isFinite(value)) throw new IllegalArgumentException("Value must be finite");
        this.value = value; this.unit = unit;
    }
    public double getValue() { return value; }
    public U getUnit() { return unit; }
    public Quantity<U> convertTo(U targetUnit) {
        if (targetUnit == null) throw new IllegalArgumentException("Target unit cannot be null");
        if (this.unit.getClass() != targetUnit.getClass()) throw new IllegalArgumentException("Target unit must belong to same category");
        return new Quantity<>(Math.round(targetUnit.convertFromBaseUnit(unit.convertToBaseUnit(value))*100.0)/100.0, targetUnit);
    }
    public Quantity<U> add(Quantity<U> other) { return add(other, this.unit); }
    public Quantity<U> add(Quantity<U> other, U targetUnit) {
        validateOperands(other, targetUnit, "addition");
        double result = unit.convertToBaseUnit(value) + other.unit.convertToBaseUnit(other.value);
        return new Quantity<>(Math.round(targetUnit.convertFromBaseUnit(result)*100.0)/100.0, targetUnit);
    }
    public Quantity<U> subtract(Quantity<U> other) { return subtract(other, this.unit); }
    public Quantity<U> subtract(Quantity<U> other, U targetUnit) {
        validateOperands(other, targetUnit, "subtraction");
        double result = unit.convertToBaseUnit(value) - other.unit.convertToBaseUnit(other.value);
        return new Quantity<>(Math.round(targetUnit.convertFromBaseUnit(result)*100.0)/100.0, targetUnit);
    }
    public double divide(Quantity<U> other) {
        if (other == null) throw new IllegalArgumentException("Other cannot be null");
        if (this.unit.getClass() != other.unit.getClass()) throw new IllegalArgumentException("Cross-category not allowed");
        this.unit.validateOperationSupport("division");
        other.unit.validateOperationSupport("division");
        double a = unit.convertToBaseUnit(value);
        double b = other.unit.convertToBaseUnit(other.value);
        if (Math.abs(b) < EPSILON) throw new ArithmeticException("Cannot divide by zero quantity");
        return a / b;
    }
    private void validateOperands(Quantity<U> other, U targetUnit, String op) {
        if (other == null) throw new IllegalArgumentException("Other cannot be null");
        if (this.unit.getClass() != other.unit.getClass()) throw new IllegalArgumentException("Cross-category not allowed");
        if (targetUnit == null) throw new IllegalArgumentException("Target unit cannot be null");
        this.unit.validateOperationSupport(op);
        other.unit.validateOperationSupport(op);
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