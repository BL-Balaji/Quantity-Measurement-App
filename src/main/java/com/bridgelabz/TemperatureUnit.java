package com.bridgelabz;
import java.util.function.Function;
public enum TemperatureUnit implements IMeasurable {
    CELSIUS(v -> v, v -> v, () -> false),
    FAHRENHEIT(f -> (f - 32.0) * 5.0 / 9.0, c -> (c * 9.0 / 5.0) + 32.0, () -> false),
    KELVIN(k -> k - 273.15, c -> c + 273.15, () -> false);
    private final Function<Double,Double> toBase;
    private final Function<Double,Double> fromBase;
    private final SupportsArithmetic arithmeticSupport;
    TemperatureUnit(Function<Double,Double> toBase, Function<Double,Double> fromBase, SupportsArithmetic arithmeticSupport) {
        this.toBase = toBase; this.fromBase = fromBase; this.arithmeticSupport = arithmeticSupport;
    }
    @Override public double convertToBaseUnit(double value) { return toBase.apply(value); }
    @Override public double convertFromBaseUnit(double base) { return fromBase.apply(base); }
    @Override public String getUnitName() { return name(); }
    @Override public String getMeasurementType() { return "TEMPERATURE"; }
    @Override public boolean supportsArithmetic() { return arithmeticSupport.isSupported(); }
    @Override public void validateOperationSupport(String op) {
        throw new UnsupportedOperationException("Temperature does not support " + op);
    }
}