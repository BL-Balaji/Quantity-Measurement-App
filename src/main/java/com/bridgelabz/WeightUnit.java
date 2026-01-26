package com.bridgelabz;
public enum WeightUnit implements IMeasurable {
    KILOGRAM(1.0), GRAM(0.001), POUND(0.45359237);
    private final double conversionFactor;
    WeightUnit(double f) { this.conversionFactor = f; }
    @Override public double convertToBaseUnit(double value) { return value * conversionFactor; }
    @Override public double convertFromBaseUnit(double base) { return base / conversionFactor; }
    @Override public String getUnitName() { return name(); }
    @Override public String getMeasurementType() { return "WEIGHT"; }
}