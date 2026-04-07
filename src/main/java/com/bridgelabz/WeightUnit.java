package com.bridgelabz;
public enum WeightUnit {
    KILOGRAM(1.0), GRAM(0.001), POUND(0.45359237);
    private final double conversionFactor;
    WeightUnit(double f) { this.conversionFactor = f; }
    public double convertToBaseUnit(double value) { return value * conversionFactor; }
    public double convertFromBaseUnit(double base) { return base / conversionFactor; }
}