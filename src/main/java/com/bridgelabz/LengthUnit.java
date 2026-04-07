package com.bridgelabz;
public enum LengthUnit implements IMeasurable {
    FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
    private final double conversionFactor;
    LengthUnit(double f) { this.conversionFactor = f; }
    @Override public double convertToBaseUnit(double value) { return value * conversionFactor; }
    @Override public double convertFromBaseUnit(double base) { return base / conversionFactor; }
    @Override public String getUnitName() { return name(); }
    @Override public String getMeasurementType() { return "LENGTH"; }
}