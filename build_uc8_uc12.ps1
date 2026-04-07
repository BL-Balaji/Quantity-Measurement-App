# UC8-UC15 Build Script
$WorkDir = "d:\Quantity Measurement App"
Set-Location $WorkDir

function Write-FileContent($path, $content) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
}

function UC-Branch($branchName, $commitMsg) {
    git checkout develop 2>&1 | Out-Null
    git checkout -b $branchName 2>&1 | Out-Null
    git add . 2>&1 | Out-Null
    git commit -m $commitMsg 2>&1 | Out-Null
    git push origin $branchName --force 2>&1 | Out-Null
    git checkout develop 2>&1 | Out-Null
    git merge --no-ff $branchName -m "Merge $branchName into develop" 2>&1 | Out-Null
    git push origin develop --force 2>&1 | Out-Null
    Write-Host "DONE: $branchName"
}

# ========== UC8: Refactor LengthUnit to SRP (convertToBaseUnit/convertFromBaseUnit) ==========
$uc8LengthUnit = @'
package com.bridgelabz;
public enum LengthUnit {
    FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
    private final double conversionFactor;
    LengthUnit(double conversionFactor) { this.conversionFactor = conversionFactor; }
    public double convertToBaseUnit(double value) { return value * conversionFactor; }
    public double convertFromBaseUnit(double baseValue) { return baseValue / conversionFactor; }
}
'@

$uc8App = @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit, "Unit must not be null");
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit target) {
            Objects.requireNonNull(target, "Target unit must not be null");
            double base = unit.convertToBaseUnit(value);
            double converted = target.convertFromBaseUnit(base);
            return new QuantityLength(Math.round(converted*100.0)/100.0, target);
        }
        public QuantityLength add(QuantityLength other) { return add(other, this.unit); }
        public QuantityLength add(QuantityLength other, LengthUnit targetUnit) {
            Objects.requireNonNull(other); Objects.requireNonNull(targetUnit);
            double sum = this.unit.convertToBaseUnit(this.value) + other.unit.convertToBaseUnit(other.value);
            return new QuantityLength(Math.round(targetUnit.convertFromBaseUnit(sum)*100.0)/100.0, targetUnit);
        }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (!(obj instanceof QuantityLength other)) return false;
            return Math.abs(unit.convertToBaseUnit(value) - other.unit.convertToBaseUnit(other.value)) < EPS;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        QuantityLength q1 = new QuantityLength(1.0, LengthUnit.FEET);
        QuantityLength q2 = new QuantityLength(12.0, LengthUnit.INCH);
        System.out.println("Equals: " + q1.equals(q2));
        System.out.println("Add: " + q1.add(q2));
        System.out.println("Convert: " + q1.convertTo(LengthUnit.INCH));
    }
}
'@

$uc8Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH));
    }
    @Test void given1Yard3Feet_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.YARDS),
                     new QuantityMeasurementApp.QuantityLength(3.0, LengthUnit.FEET));
    }
    @Test void given1Feet_convertToInches_shouldBe12() {
        assertEquals(12.0, new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET)
            .convertTo(LengthUnit.INCH).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12In_add_shouldBe2Feet() {
        assertEquals(2.0, new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET)
            .add(new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH)).getValue(), 1e-2);
    }
    @Test void givenLengthUnit_convertToBase_isCorrect() {
        assertEquals(1.0, LengthUnit.FEET.convertToBaseUnit(1.0), 1e-6);
        assertEquals(1.0/12.0, LengthUnit.INCH.convertToBaseUnit(1.0), 1e-6);
        assertEquals(3.0, LengthUnit.YARDS.convertToBaseUnit(1.0), 1e-6);
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\LengthUnit.java" $uc8LengthUnit
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc8App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc8Test
UC-Branch "feature/UC8-Refactor-LengthUnit-SRP" "[Balaji]:UC8 - Refactor LengthUnit to standalone SRP class with convertToBaseUnit/convertFromBaseUnit"

# ========== UC9: WeightUnit + QuantityWeight ==========
$uc9WeightUnit = @'
package com.bridgelabz;
public enum WeightUnit {
    KILOGRAM(1.0), GRAM(0.001), POUND(0.45359237);
    private final double conversionFactor;
    WeightUnit(double f) { this.conversionFactor = f; }
    public double convertToBaseUnit(double value) { return value * conversionFactor; }
    public double convertFromBaseUnit(double base) { return base / conversionFactor; }
}
'@

$uc9Weight = @'
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
'@

$uc9App = @'
package com.bridgelabz;
public class QuantityMeasurementApp {
    public static void main(String[] args) {
        QuantityWeight w1 = new QuantityWeight(1.0, WeightUnit.KILOGRAM);
        QuantityWeight w2 = new QuantityWeight(1000.0, WeightUnit.GRAM);
        System.out.println("1kg == 1000g: " + w1.equals(w2));
        System.out.println("1kg in pounds: " + w1.convertTo(WeightUnit.POUND));
        System.out.println("1kg + 1000g: " + w1.add(w2));
    }
}
'@

$uc9Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1KgAnd1000Grams_shouldBeEqual() {
        assertEquals(new QuantityWeight(1.0, WeightUnit.KILOGRAM), new QuantityWeight(1000.0, WeightUnit.GRAM));
    }
    @Test void given1KgAnd1Gram_shouldNotBeEqual() {
        assertNotEquals(new QuantityWeight(1.0, WeightUnit.KILOGRAM), new QuantityWeight(1.0, WeightUnit.GRAM));
    }
    @Test void given1Kg_convertToGram_shouldBe1000() {
        assertEquals(1000.0, new QuantityWeight(1.0, WeightUnit.KILOGRAM).convertTo(WeightUnit.GRAM).getValue(), 1e-2);
    }
    @Test void given1KgAnd1000g_whenAdded_shouldBe2Kg() {
        QuantityWeight result = new QuantityWeight(1.0, WeightUnit.KILOGRAM).add(new QuantityWeight(1000.0, WeightUnit.GRAM));
        assertEquals(2.0, result.getValue(), 1e-2);
        assertEquals(WeightUnit.KILOGRAM, result.getUnit());
    }
    @Test void givenNullUnit_shouldThrow() {
        assertThrows(NullPointerException.class, () -> new QuantityWeight(1.0, null));
    }
    @Test void givenNonFiniteValue_shouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> new QuantityWeight(Double.NaN, WeightUnit.KILOGRAM));
    }
    @Test void given1FeetLength_stillWorks() {
        QuantityMeasurementApp.QuantityLength q = new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET);
        assertEquals(q, new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\WeightUnit.java" $uc9WeightUnit
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityWeight.java" $uc9Weight
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc9App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc9Test
UC-Branch "feature/UC9-Weight-Kilogram-Gram-Pound" "[Balaji]:UC9 - Add WeightUnit enum (KILOGRAM, GRAM, POUND) and QuantityWeight class"

# ========== UC11: VolumeUnit + IMeasurable interface + generic Quantity<U> ==========
$uc11IMeasurable = @'
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
'@

$uc11LengthUnit = @'
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
'@

$uc11WeightUnit = @'
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
'@

$uc11VolumeUnit = @'
package com.bridgelabz;
public enum VolumeUnit implements IMeasurable {
    LITRE(1.0), MILLILITRE(0.001), GALLON(3.78541);
    private final double conversionFactor;
    VolumeUnit(double f) { this.conversionFactor = f; }
    @Override public double convertToBaseUnit(double value) { return value * conversionFactor; }
    @Override public double convertFromBaseUnit(double base) { return base / conversionFactor; }
    @Override public String getUnitName() { return name(); }
    @Override public String getMeasurementType() { return "VOLUME"; }
}
'@

$uc11Quantity = @'
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
'@

$uc11App = @'
package com.bridgelabz;
public class QuantityMeasurementApp {
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value; this.unit = java.util.Objects.requireNonNull(unit);
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit t) {
            return new QuantityLength(Math.round(t.convertFromBaseUnit(unit.convertToBaseUnit(value))*100.0)/100.0, t);
        }
        public QuantityLength add(QuantityLength o) { return add(o, unit); }
        public QuantityLength add(QuantityLength o, LengthUnit t) {
            double sum = unit.convertToBaseUnit(value) + o.unit.convertToBaseUnit(o.value);
            return new QuantityLength(Math.round(t.convertFromBaseUnit(sum)*100.0)/100.0, t);
        }
        @Override public boolean equals(Object obj) {
            if (!(obj instanceof QuantityLength o)) return false;
            return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value)) < EPS;
        }
        @Override public int hashCode() { return java.util.Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        Quantity<VolumeUnit> v1 = new Quantity<>(1.0, VolumeUnit.LITRE);
        Quantity<VolumeUnit> v2 = new Quantity<>(1000.0, VolumeUnit.MILLILITRE);
        System.out.println("1 litre == 1000 ml: " + v1.equals(v2));
        System.out.println("1 gallon in litres: " + new Quantity<>(1.0, VolumeUnit.GALLON).convertTo(VolumeUnit.LITRE));
    }
}
'@

$uc11Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1LitreAnd1000ML_shouldBeEqual() {
        assertEquals(new Quantity<>(1.0, VolumeUnit.LITRE), new Quantity<>(1000.0, VolumeUnit.MILLILITRE));
    }
    @Test void given1GallonConverted_shouldBe3_78Litres() {
        Quantity<VolumeUnit> result = new Quantity<>(1.0, VolumeUnit.GALLON).convertTo(VolumeUnit.LITRE);
        assertEquals(3.79, result.getValue(), 1e-2);
    }
    @Test void given1LitreAnd2Litres_add_shouldBe3() {
        Quantity<VolumeUnit> result = new Quantity<>(1.0, VolumeUnit.LITRE).add(new Quantity<>(2.0, VolumeUnit.LITRE));
        assertEquals(3.0, result.getValue(), 1e-2);
    }
    @Test void given1KgAnd1000g_stillWork() {
        assertEquals(new QuantityWeight(1.0, WeightUnit.KILOGRAM), new QuantityWeight(1000.0, WeightUnit.GRAM));
    }
    @Test void given1FeetAnd12Inches_stillWork() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, LengthUnit.INCH));
    }
    @Test void givenCrossCategory_shouldThrow() {
        Quantity<LengthUnit> l = new Quantity<>(1.0, LengthUnit.FEET);
        Quantity<WeightUnit> w = new Quantity<>(1.0, WeightUnit.KILOGRAM);
        assertThrows(IllegalArgumentException.class, () -> l.add((Quantity)w));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\IMeasurable.java" $uc11IMeasurable
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\LengthUnit.java" $uc11LengthUnit
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\WeightUnit.java" $uc11WeightUnit
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\VolumeUnit.java" $uc11VolumeUnit
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\Quantity.java" $uc11Quantity
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc11App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc11Test
UC-Branch "feature/UC11-Volume-Measurement-Generic-Quantity" "[Balaji]:UC11 - Add VolumeUnit, IMeasurable interface, and generic Quantity<U extends IMeasurable>"

# ========== UC12: TemperatureUnit + SupportsArithmetic ==========
$uc12SupportsArithmetic = @'
package com.bridgelabz;
@FunctionalInterface
public interface SupportsArithmetic {
    boolean isSupported();
}
'@

$uc12TemperatureUnit = @'
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
'@

$uc12Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given0CelsiusAnd32Fahrenheit_shouldBeEqual() {
        assertEquals(new Quantity<>(0.0, TemperatureUnit.CELSIUS), new Quantity<>(32.0, TemperatureUnit.FAHRENHEIT));
    }
    @Test void given100Celsius_convertToFahrenheit_shouldBe212() {
        Quantity<TemperatureUnit> result = new Quantity<>(100.0, TemperatureUnit.CELSIUS).convertTo(TemperatureUnit.FAHRENHEIT);
        assertEquals(212.0, result.getValue(), 1e-2);
    }
    @Test void given0Celsius_convertToKelvin_shouldBe273_15() {
        assertEquals(273.15, new Quantity<>(0.0, TemperatureUnit.CELSIUS).convertTo(TemperatureUnit.KELVIN).getValue(), 1e-2);
    }
    @Test void givenTemperature_addShouldThrow() {
        assertThrows(UnsupportedOperationException.class, () ->
            new Quantity<>(100.0, TemperatureUnit.CELSIUS).add(new Quantity<>(50.0, TemperatureUnit.CELSIUS)));
    }
    @Test void given1LitreAnd1000ML_stillWork() {
        assertEquals(new Quantity<>(1.0, VolumeUnit.LITRE), new Quantity<>(1000.0, VolumeUnit.MILLILITRE));
    }
    @Test void given1KgAnd1000g_stillWork() {
        assertEquals(new QuantityWeight(1.0, WeightUnit.KILOGRAM), new QuantityWeight(1000.0, WeightUnit.GRAM));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\SupportsArithmetic.java" $uc12SupportsArithmetic
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\TemperatureUnit.java" $uc12TemperatureUnit
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc12Test
UC-Branch "feature/UC12-Temperature-Measurement" "[Balaji]:UC12 - Add TemperatureUnit (CELSIUS, FAHRENHEIT, KELVIN) with non-linear conversion and arithmetic restriction"

Write-Host "UC8 to UC12 COMPLETE"
