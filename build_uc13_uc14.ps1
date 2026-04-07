# UC13-UC15 Build Script
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

# ========== UC13: Add subtract() to Quantity<U> ==========
$uc13Quantity = @'
package com.bridgelabz;
import java.util.Objects;
public class Quantity<U extends IMeasurable> {
    private final double value;
    private final U unit;
    private static final double EPSILON = 1e-6;
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
        double base = unit.convertToBaseUnit(value);
        return new Quantity<>(Math.round(targetUnit.convertFromBaseUnit(base)*100.0)/100.0, targetUnit);
    }
    public Quantity<U> add(Quantity<U> other) { return add(other, this.unit); }
    public Quantity<U> add(Quantity<U> other, U targetUnit) {
        validateOperands(other, targetUnit, "addition");
        double sum = unit.convertToBaseUnit(value) + other.unit.convertToBaseUnit(other.value);
        return new Quantity<>(Math.round(targetUnit.convertFromBaseUnit(sum)*100.0)/100.0, targetUnit);
    }
    public Quantity<U> subtract(Quantity<U> other) { return subtract(other, this.unit); }
    public Quantity<U> subtract(Quantity<U> other, U targetUnit) {
        validateOperands(other, targetUnit, "subtraction");
        double diff = unit.convertToBaseUnit(value) - other.unit.convertToBaseUnit(other.value);
        return new Quantity<>(Math.round(targetUnit.convertFromBaseUnit(diff)*100.0)/100.0, targetUnit);
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
'@

$uc13Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    private static final double EPS = 1e-2;
    @Test void given10FeetMinus5Feet_shouldBe5Feet() {
        Quantity<LengthUnit> result = new Quantity<>(10.0, LengthUnit.FEET).subtract(new Quantity<>(5.0, LengthUnit.FEET));
        assertEquals(5.0, result.getValue(), EPS);
        assertEquals(LengthUnit.FEET, result.getUnit());
    }
    @Test void given10FeetMinus6Inches_shouldBe9_5Feet() {
        Quantity<LengthUnit> result = new Quantity<>(10.0, LengthUnit.FEET).subtract(new Quantity<>(6.0, LengthUnit.INCH));
        assertEquals(9.5, result.getValue(), EPS);
    }
    @Test void given10FeetMinus5Feet_inInches_shouldBe60() {
        Quantity<LengthUnit> result = new Quantity<>(10.0, LengthUnit.FEET)
            .subtract(new Quantity<>(5.0, LengthUnit.FEET), LengthUnit.INCH);
        assertEquals(60.0, result.getValue(), EPS);
    }
    @Test void givenSubtractResultsInNegative_works() {
        Quantity<LengthUnit> result = new Quantity<>(5.0, LengthUnit.FEET).subtract(new Quantity<>(10.0, LengthUnit.FEET));
        assertEquals(-5.0, result.getValue(), EPS);
    }
    @Test void givenTemperatureSubtract_shouldThrow() {
        assertThrows(UnsupportedOperationException.class, () ->
            new Quantity<>(100.0, TemperatureUnit.CELSIUS).subtract(new Quantity<>(50.0, TemperatureUnit.CELSIUS)));
    }
    @Test void givenSubtractNull_shouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> new Quantity<>(10.0, LengthUnit.FEET).subtract(null));
    }
    @Test void given1LitreAnd1000ML_stillWork() {
        assertEquals(new Quantity<>(1.0, VolumeUnit.LITRE), new Quantity<>(1000.0, VolumeUnit.MILLILITRE));
    }
    @Test void givenSubtract_isImmutable() {
        Quantity<LengthUnit> a = new Quantity<>(10.0, LengthUnit.FEET);
        Quantity<LengthUnit> b = new Quantity<>(5.0, LengthUnit.FEET);
        a.subtract(b);
        assertEquals(10.0, a.getValue(), EPS);
        assertEquals(5.0, b.getValue(), EPS);
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\Quantity.java" $uc13Quantity
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc13Test
UC-Branch "feature/UC13-Subtraction-Operation" "[Balaji]:UC13 - Add subtract() and subtract(other, targetUnit) to Quantity<U>"

# ========== UC14: Add divide() ==========
$uc14Quantity = @'
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
'@

$uc14Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    private static final double EPS = 1e-6;
    @Test void given10FeetDividedBy2Feet_shouldBe5() {
        assertEquals(5.0, new Quantity<>(10.0, LengthUnit.FEET).divide(new Quantity<>(2.0, LengthUnit.FEET)), EPS);
    }
    @Test void given24InchDividedBy2Feet_shouldBe1() {
        assertEquals(1.0, new Quantity<>(24.0, LengthUnit.INCH).divide(new Quantity<>(2.0, LengthUnit.FEET)), EPS);
    }
    @Test void given5FeetDividedBy10Feet_shouldBe0_5() {
        assertEquals(0.5, new Quantity<>(5.0, LengthUnit.FEET).divide(new Quantity<>(10.0, LengthUnit.FEET)), EPS);
    }
    @Test void givenDivideByZero_shouldThrow() {
        assertThrows(ArithmeticException.class, () ->
            new Quantity<>(10.0, LengthUnit.FEET).divide(new Quantity<>(0.0, LengthUnit.FEET)));
    }
    @Test void givenTemperatureDivide_shouldThrow() {
        assertThrows(UnsupportedOperationException.class, () ->
            new Quantity<>(100.0, TemperatureUnit.CELSIUS).divide(new Quantity<>(50.0, TemperatureUnit.CELSIUS)));
    }
    @Test void given10KgDividedBy2Kg_shouldBe5() {
        assertEquals(5.0, new Quantity<>(10.0, WeightUnit.KILOGRAM).divide(new Quantity<>(2.0, WeightUnit.KILOGRAM)), EPS);
    }
    @Test void given10FeetMinus5Feet_shouldBe5Feet() {
        assertEquals(5.0, new Quantity<>(10.0, LengthUnit.FEET).subtract(new Quantity<>(5.0, LengthUnit.FEET)).getValue(), EPS);
    }
    @Test void given0CelsiusAnd32Fahrenheit_shouldBeEqual() {
        assertEquals(new Quantity<>(0.0, TemperatureUnit.CELSIUS), new Quantity<>(32.0, TemperatureUnit.FAHRENHEIT));
    }
    @Test void divisionIsImmutable() {
        Quantity<LengthUnit> a = new Quantity<>(10.0, LengthUnit.FEET);
        Quantity<LengthUnit> b = new Quantity<>(5.0, LengthUnit.FEET);
        a.divide(b);
        assertEquals(10.0, a.getValue(), EPS);
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\Quantity.java" $uc14Quantity
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc14Test
UC-Branch "feature/UC14-Division-Operation" "[Balaji]:UC14 - Add divide(other) to Quantity<U> returning dimensionless ratio"

Write-Host "UC13 and UC14 COMPLETE"
