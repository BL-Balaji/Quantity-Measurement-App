package com.bridgelabz;
public enum WeightUnit {
    KILOGRAM(1.0), GRAM(0.001), POUND(0.45359237);
    private final double f;
    WeightUnit(double f) { this.f = f; }
    public double convertToBaseUnit(double v) { return v*f; }
    public double convertFromBaseUnit(double b) { return b/f; }
}