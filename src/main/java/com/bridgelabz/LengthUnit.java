package com.bridgelabz;
public enum LengthUnit {
    FEET(1.0), INCH(1.0/12.0), YARDS(3.0), CENTIMETERS(1.0/30.48);
    private final double conversionFactor;
    LengthUnit(double f) { this.conversionFactor = f; }
    public double convertToBaseUnit(double value) { return value * conversionFactor; }
    public double convertFromBaseUnit(double base) { return base / conversionFactor; }
}