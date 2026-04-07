# UC3-UC7 Build Script
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

# ========== UC3: Generic LengthUnit enum + QuantityLength (DRY) ==========
$uc3App = @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0 / 12.0);
        private final double toFeetFactor;
        LengthUnit(double f) { this.toFeetFactor = f; }
        public double toFeet(double v) { return v * toFeetFactor; }
    }
    public static final class QuantityLength {
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit, "Unit must not be null");
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            QuantityLength other = (QuantityLength) obj;
            return Double.compare(this.valueInFeet(), other.valueInFeet()) == 0;
        }
        @Override public int hashCode() { return Objects.hash(valueInFeet()); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit.name().toLowerCase() + ")"; }
    }
    public static boolean areFeetEqual(double a, double b) {
        return new QuantityLength(a, LengthUnit.FEET).equals(new QuantityLength(b, LengthUnit.FEET));
    }
    public static boolean areInchesEqual(double a, double b) {
        return new QuantityLength(a, LengthUnit.INCH).equals(new QuantityLength(b, LengthUnit.INCH));
    }
    public static void main(String[] args) {
        QuantityLength q1 = new QuantityLength(1.0, LengthUnit.FEET);
        QuantityLength q2 = new QuantityLength(12.0, LengthUnit.INCH);
        System.out.println("1 ft == 12 in: " + q1.equals(q2));
    }
}
'@

$uc3Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void givenSameFeet_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET));
    }
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
    @Test void given1FeetAnd1Inch_shouldNotBeEqual() {
        assertNotEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                        new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
    @Test void givenSameInches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(5.0, QuantityMeasurementApp.LengthUnit.INCH),
                     new QuantityMeasurementApp.QuantityLength(5.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
    @Test void givenNullUnit_shouldThrowException() {
        assertThrows(NullPointerException.class,
            () -> new QuantityMeasurementApp.QuantityLength(1.0, null));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc3App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc3Test
UC-Branch "feature/UC3-Generic-Quantity-Length" "[Balaji]:UC3 - Introduce LengthUnit enum and QuantityLength class (DRY principle)"

# ========== UC4: Add YARDS and CENTIMETERS ==========
$uc4App = @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
        private final double toFeetFactor;
        LengthUnit(double f) { this.toFeetFactor = f; }
        public double toFeet(double v) { return v * toFeetFactor; }
    }
    public static final class QuantityLength {
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit, "Unit must not be null");
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            QuantityLength other = (QuantityLength) obj;
            return Math.abs(this.valueInFeet() - other.valueInFeet()) < 1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(valueInFeet() * 1e6)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        System.out.println("1 yard == 3 feet: " +
            new QuantityMeasurementApp.QuantityLength(1.0, LengthUnit.YARDS).equals(
            new QuantityMeasurementApp.QuantityLength(3.0, LengthUnit.FEET)));
    }
}
'@

$uc4Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
    @Test void given1YardAnd3Feet_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS),
                     new QuantityMeasurementApp.QuantityLength(3.0, QuantityMeasurementApp.LengthUnit.FEET));
    }
    @Test void given1YardAnd36Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS),
                     new QuantityMeasurementApp.QuantityLength(36.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
    @Test void given2InchesAnd5Centimeters_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(2.0, QuantityMeasurementApp.LengthUnit.INCH),
                     new QuantityMeasurementApp.QuantityLength(5.08, QuantityMeasurementApp.LengthUnit.CENTIMETERS));
    }
    @Test void given1FeetAndBadCentimeters_shouldNotBeEqual() {
        assertNotEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                        new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.CENTIMETERS));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc4App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc4Test
UC-Branch "feature/UC4-Extended-Units-Yards-Centimeters" "[Balaji]:UC4 - Add YARDS and CENTIMETERS to LengthUnit enum"

# ========== UC5: Unit Conversion ==========
$uc5App = @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
        private final double toFeetFactor;
        LengthUnit(double f) { this.toFeetFactor = f; }
        public double toFeet(double v) { return v * toFeetFactor; }
        public double fromFeet(double v) { return v / toFeetFactor; }
    }
    public static final class QuantityLength {
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit, "Unit must not be null");
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        public QuantityLength convertTo(LengthUnit target) {
            Objects.requireNonNull(target, "Target unit must not be null");
            double feet = unit.toFeet(value);
            double converted = target.fromFeet(feet);
            return new QuantityLength(Math.round(converted * 100.0) / 100.0, target);
        }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            QuantityLength other = (QuantityLength) obj;
            return Math.abs(this.valueInFeet() - other.valueInFeet()) < 1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(valueInFeet() * 1e6)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        QuantityLength q = new QuantityLength(1.0, LengthUnit.FEET);
        System.out.println("1 ft in inches: " + q.convertTo(LengthUnit.INCH));
    }
}
'@

$uc5Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1Feet_convertToInches_shouldReturn12() {
        QuantityMeasurementApp.QuantityLength result =
            new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET)
                .convertTo(QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(12.0, result.getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.INCH, result.getUnit());
    }
    @Test void given12Inches_convertToFeet_shouldReturn1() {
        QuantityMeasurementApp.QuantityLength result =
            new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH)
                .convertTo(QuantityMeasurementApp.LengthUnit.FEET);
        assertEquals(1.0, result.getValue(), 1e-2);
    }
    @Test void given1Yard_convertToFeet_shouldReturn3() {
        QuantityMeasurementApp.QuantityLength result =
            new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS)
                .convertTo(QuantityMeasurementApp.LengthUnit.FEET);
        assertEquals(3.0, result.getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc5App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc5Test
UC-Branch "feature/UC5-Unit-Conversion" "[Balaji]:UC5 - Add convertTo() API for unit-to-unit length conversion"

# ========== UC6: Addition (first operand unit) ==========
$uc6App = @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
        private final double toFeetFactor;
        LengthUnit(double f) { this.toFeetFactor = f; }
        public double toFeet(double v) { return v * toFeetFactor; }
        public double fromFeet(double v) { return v / toFeetFactor; }
    }
    public static final class QuantityLength {
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit);
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        public QuantityLength convertTo(LengthUnit target) {
            double converted = target.fromFeet(unit.toFeet(value));
            return new QuantityLength(Math.round(converted*100.0)/100.0, target);
        }
        public QuantityLength add(QuantityLength other) {
            Objects.requireNonNull(other, "Other quantity must not be null");
            double sumFeet = this.valueInFeet() + other.valueInFeet();
            double inThisUnit = this.unit.fromFeet(sumFeet);
            return new QuantityLength(Math.round(inThisUnit*100.0)/100.0, this.unit);
        }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Math.abs(this.valueInFeet() - ((QuantityLength)obj).valueInFeet()) < 1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(valueInFeet()*1e6)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        QuantityLength a = new QuantityLength(1.0, LengthUnit.FEET);
        QuantityLength b = new QuantityLength(12.0, LengthUnit.INCH);
        System.out.println("1 ft + 12 in = " + a.add(b));
    }
}
'@

$uc6Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd1Feet_whenAdded_shouldReturn2Feet() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        assertEquals(2.0, a.add(b).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_whenAdded_shouldReturn2Feet() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(2.0, a.add(b).getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.FEET, a.add(b).getUnit());
    }
    @Test void given3InchesAnd3Inches_whenAdded_shouldReturn6Inches() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(3.0, QuantityMeasurementApp.LengthUnit.INCH);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(3.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(6.0, a.add(b).getValue(), 1e-2);
    }
    @Test void givenAddWithNull_shouldThrowException() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        assertThrows(NullPointerException.class, () -> a.add(null));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc6App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc6Test
UC-Branch "feature/UC6-Length-Addition" "[Balaji]:UC6 - Add addition of two lengths returning result in first operand unit"

# ========== UC7: Addition with target unit ==========
$uc7App = @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0 / 12.0), YARDS(3.0), CENTIMETERS(1.0 / 30.48);
        private final double toFeetFactor;
        LengthUnit(double f) { this.toFeetFactor = f; }
        public double toFeet(double v) { return v * toFeetFactor; }
        public double fromFeet(double v) { return v / toFeetFactor; }
    }
    public static final class QuantityLength {
        private final double value;
        private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value;
            this.unit = Objects.requireNonNull(unit);
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        public QuantityLength convertTo(LengthUnit target) {
            return new QuantityLength(Math.round(target.fromFeet(unit.toFeet(value))*100.0)/100.0, target);
        }
        public QuantityLength add(QuantityLength other) { return add(other, this.unit); }
        public QuantityLength add(QuantityLength other, LengthUnit targetUnit) {
            Objects.requireNonNull(other, "Other must not be null");
            Objects.requireNonNull(targetUnit, "Target unit must not be null");
            double sumFeet = this.valueInFeet() + other.valueInFeet();
            return new QuantityLength(Math.round(targetUnit.fromFeet(sumFeet)*100.0)/100.0, targetUnit);
        }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Math.abs(this.valueInFeet() - ((QuantityLength)obj).valueInFeet()) < 1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(valueInFeet()*1e6)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        QuantityLength a = new QuantityLength(1.0, LengthUnit.FEET);
        QuantityLength b = new QuantityLength(12.0, LengthUnit.INCH);
        System.out.println("1ft+12in in YARDS: " + a.add(b, LengthUnit.YARDS));
    }
}
'@

$uc7Test = @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_addInYards_shouldGiveCorrect() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        QuantityMeasurementApp.QuantityLength result = a.add(b, QuantityMeasurementApp.LengthUnit.YARDS);
        assertEquals(QuantityMeasurementApp.LengthUnit.YARDS, result.getUnit());
        assertEquals(0.67, result.getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addInInches_shouldGive24() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(24.0, a.add(b, QuantityMeasurementApp.LengthUnit.INCH).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addDefaultUnit_shouldGive2Feet() {
        QuantityMeasurementApp.QuantityLength a = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET);
        QuantityMeasurementApp.QuantityLength b = new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(2.0, a.add(b).getValue(), 1e-2);
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc7App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc7Test
UC-Branch "feature/UC7-Addition-With-Target-Unit" "[Balaji]:UC7 - Add addition with explicit target unit specification"

Write-Host "UC3 to UC7 COMPLETE"
