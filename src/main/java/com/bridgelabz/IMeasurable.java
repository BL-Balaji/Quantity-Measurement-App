package com.bridgelabz;
public interface IMeasurable {
    double convertToBaseUnit(double value);
    double convertFromBaseUnit(double baseValue);
    String getUnitName();
    String getMeasurementType();
    default boolean supportsArithmetic() { return true; }
    default void validateOperationSupport(String op) {
        if (!supportsArithmetic()) throw new UnsupportedOperationException(getUnitName() + " does not support " + op);
    }
    static IMeasurable fromUnitName(String unitName) {
        if (unitName == null || unitName.isBlank()) throw new IllegalArgumentException("Unit name cannot be null or empty");
        String u = unitName.toUpperCase().trim();
        for (LengthUnit x : LengthUnit.values()) if (x.name().equals(u)) return x;
        for (WeightUnit x : WeightUnit.values()) if (x.name().equals(u)) return x;
        for (VolumeUnit x : VolumeUnit.values()) if (x.name().equals(u)) return x;
        for (TemperatureUnit x : TemperatureUnit.values()) if (x.name().equals(u)) return x;
        throw new IllegalArgumentException("Unknown unit: " + unitName);
    }
}