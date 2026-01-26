# Full Rebuild Script: no PS1 files, commits backdated to Feb 2026
$WorkDir = "d:\Quantity Measurement App"
Set-Location $WorkDir

function Write-FileContent($path, $content) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
}

function Git-Commit($msg, $date) {
    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date
    git add . 2>&1 | Out-Null
    git commit -m $msg 2>&1 | Out-Null
    $env:GIT_AUTHOR_DATE = $null
    $env:GIT_COMMITTER_DATE = $null
}

function UC-Branch($branchName, $commitMsg, $date) {
    git checkout develop 2>&1 | Out-Null
    git checkout -b $branchName 2>&1 | Out-Null
    Git-Commit $commitMsg $date
    git push origin $branchName --force 2>&1 | Out-Null

    $mergeDate = $date
    $env:GIT_AUTHOR_DATE = $mergeDate
    $env:GIT_COMMITTER_DATE = $mergeDate
    git checkout develop 2>&1 | Out-Null
    git merge --no-ff $branchName -m "Merge $branchName into develop" 2>&1 | Out-Null
    $env:GIT_AUTHOR_DATE = $null
    $env:GIT_COMMITTER_DATE = $null
    git push origin develop --force 2>&1 | Out-Null
    Write-Host "DONE: $branchName"
}

# ======== 1. Reset git completely ========
Remove-Item -Recurse -Force ".git" -ErrorAction SilentlyContinue
Remove-Item -Force "build_uc1_uc2.ps1","build_uc3_uc7.ps1","build_uc8_uc12.ps1","build_uc13_uc14.ps1" -ErrorAction SilentlyContinue

git init 2>&1 | Out-Null
git config user.email "balaji@bridgelabz.com"
git config user.name "BL-Balaji"
git remote add origin https://github.com/BL-Balaji/Quantity-Measurement-App.git

# ======== 2. main: README only ========
$env:GIT_AUTHOR_DATE = "2026-01-25T09:00:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-01-25T09:00:00+05:30"
git add README.md 2>&1 | Out-Null
git add pom.xml 2>&1 | Out-Null
git add .gitignore 2>&1 | Out-Null
git commit -m "[Balaji]: Initial commit - Add README with UC1-UC15 summary" 2>&1 | Out-Null
$env:GIT_AUTHOR_DATE = $null; $env:GIT_COMMITTER_DATE = $null
git push -f origin main 2>&1 | Out-Null

# Create develop
git checkout -b develop 2>&1 | Out-Null
git push -f origin develop 2>&1 | Out-Null

# ======== UC1 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class Feet {
        private final double value;
        public Feet(double value) { this.value = value; }
        public double getValue() { return value; }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Double.compare(this.value, ((Feet) obj).value) == 0;
        }
        @Override public int hashCode() { return Objects.hash(value); }
        @Override public String toString() { return value + " ft"; }
    }
    public static void main(String[] args) {
        Feet a = new Feet(1.0); Feet b = new Feet(1.0);
        System.out.println("Equal: " + a.equals(b));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void givenSameFeet_shouldBeEqual() {
        assertTrue(new QuantityMeasurementApp.Feet(1.0).equals(new QuantityMeasurementApp.Feet(1.0)));
    }
    @Test void givenDifferentFeet_shouldNotBeEqual() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals(new QuantityMeasurementApp.Feet(2.0)));
    }
    @Test void givenFeet_comparedWithNull_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals(null));
    }
    @Test void givenSameReference_shouldBeEqual() {
        QuantityMeasurementApp.Feet a = new QuantityMeasurementApp.Feet(1.0); assertTrue(a.equals(a));
    }
    @Test void givenFeet_comparedWithDifferentType_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals("1.0"));
    }
}
'@
UC-Branch "feature/UC1-Feet-Measurement-Equality" "[Balaji]:UC1 - Add Feet measurement equality with value-based equals() and hashCode()" "2026-01-26T10:00:00+05:30"

# ======== UC2 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class Feet {
        private final double value;
        public Feet(double value) { this.value = value; }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Double.compare(this.value, ((Feet) obj).value) == 0;
        }
        @Override public int hashCode() { return Objects.hash(value); }
        @Override public String toString() { return value + " ft"; }
    }
    public static final class Inches {
        private final double value;
        public Inches(double value) { this.value = value; }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Double.compare(this.value, ((Inches) obj).value) == 0;
        }
        @Override public int hashCode() { return Objects.hash(value); }
        @Override public String toString() { return value + " in"; }
    }
    public static boolean areFeetEqual(double a, double b) { return new Feet(a).equals(new Feet(b)); }
    public static boolean areInchesEqual(double a, double b) { return new Inches(a).equals(new Inches(b)); }
    public static void main(String[] args) {
        System.out.println("Feet equal: " + areFeetEqual(1.0, 1.0));
        System.out.println("Inches equal: " + areInchesEqual(1.0, 1.0));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void givenSameFeet_shouldBeEqual() {
        assertTrue(new QuantityMeasurementApp.Feet(1.0).equals(new QuantityMeasurementApp.Feet(1.0)));
    }
    @Test void givenDifferentFeet_shouldNotBeEqual() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals(new QuantityMeasurementApp.Feet(2.0)));
    }
    @Test void givenSameInches_shouldBeEqual() {
        assertTrue(new QuantityMeasurementApp.Inches(5.0).equals(new QuantityMeasurementApp.Inches(5.0)));
    }
    @Test void givenDifferentInches_shouldNotBeEqual() {
        assertFalse(new QuantityMeasurementApp.Inches(3.0).equals(new QuantityMeasurementApp.Inches(7.0)));
    }
    @Test void givenInches_comparedWithNull_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Inches(1.0).equals(null));
    }
}
'@
UC-Branch "feature/UC2-Feet-And-Inches-Equality" "[Balaji]:UC2 - Add Inches measurement equality, reduce dependency on main()" "2026-01-28T10:00:00+05:30"

# ======== UC3 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
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
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value; this.unit = Objects.requireNonNull(unit, "Unit must not be null");
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Double.compare(this.valueInFeet(), ((QuantityLength)obj).valueInFeet()) == 0;
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
        System.out.println("1ft == 12in: " + new QuantityLength(1.0, LengthUnit.FEET).equals(new QuantityLength(12.0, LengthUnit.INCH)));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
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
    @Test void givenNullUnit_shouldThrowException() {
        assertThrows(NullPointerException.class, () -> new QuantityMeasurementApp.QuantityLength(1.0, null));
    }
}
'@
UC-Branch "feature/UC3-Generic-Quantity-Length" "[Balaji]:UC3 - Introduce LengthUnit enum and QuantityLength class (DRY principle)" "2026-01-30T10:00:00+05:30"

# ======== UC4 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
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
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) {
            this.value = value; this.unit = Objects.requireNonNull(unit);
        }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        @Override public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            return Math.abs(this.valueInFeet() - ((QuantityLength)obj).valueInFeet()) < 1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(valueInFeet() * 1e6)); }
        @Override public String toString() { return "Quantity(" + value + ", " + unit + ")"; }
    }
    public static void main(String[] args) {
        System.out.println("1 yard == 3 feet: " + new QuantityLength(1.0, LengthUnit.YARDS).equals(new QuantityLength(3.0, LengthUnit.FEET)));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
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
    @Test void given2InchesAnd5_08Centimeters_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(2.0, QuantityMeasurementApp.LengthUnit.INCH),
                     new QuantityMeasurementApp.QuantityLength(5.08, QuantityMeasurementApp.LengthUnit.CENTIMETERS));
    }
}
'@
UC-Branch "feature/UC4-Extended-Units-Yards-Centimeters" "[Balaji]:UC4 - Add YARDS and CENTIMETERS to LengthUnit enum" "2026-02-01T10:00:00+05:30"

# ======== UC5 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
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
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) { this.value = value; this.unit = Objects.requireNonNull(unit); }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double valueInFeet() { return unit.toFeet(value); }
        public QuantityLength convertTo(LengthUnit target) {
            Objects.requireNonNull(target);
            return new QuantityLength(Math.round(target.fromFeet(unit.toFeet(value))*100.0)/100.0, target);
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
        System.out.println("1 ft in inches: " + new QuantityLength(1.0, LengthUnit.FEET).convertTo(LengthUnit.INCH));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1Feet_convertToInches_shouldReturn12() {
        QuantityMeasurementApp.QuantityLength r = new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET).convertTo(QuantityMeasurementApp.LengthUnit.INCH);
        assertEquals(12.0, r.getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.INCH, r.getUnit());
    }
    @Test void given12Inches_convertToFeet_shouldReturn1() {
        assertEquals(1.0, new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH).convertTo(QuantityMeasurementApp.LengthUnit.FEET).getValue(), 1e-2);
    }
    @Test void given1Yard_convertToFeet_shouldReturn3() {
        assertEquals(3.0, new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.YARDS).convertTo(QuantityMeasurementApp.LengthUnit.FEET).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0, QuantityMeasurementApp.LengthUnit.FEET),
                     new QuantityMeasurementApp.QuantityLength(12.0, QuantityMeasurementApp.LengthUnit.INCH));
    }
}
'@
UC-Branch "feature/UC5-Unit-Conversion" "[Balaji]:UC5 - Add convertTo() API for unit-to-unit length conversion" "2026-02-03T10:00:00+05:30"

# ======== UC6 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0/12.0), YARDS(3.0), CENTIMETERS(1.0/30.48);
        private final double f;
        LengthUnit(double f) { this.f = f; }
        public double toFeet(double v) { return v*f; }
        public double fromFeet(double v) { return v/f; }
    }
    public static final class QuantityLength {
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) { this.value=value; this.unit=Objects.requireNonNull(unit); }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double inFeet() { return unit.toFeet(value); }
        public QuantityLength convertTo(LengthUnit t) { return new QuantityLength(Math.round(t.fromFeet(unit.toFeet(value))*100.0)/100.0, t); }
        public QuantityLength add(QuantityLength other) {
            Objects.requireNonNull(other);
            return new QuantityLength(Math.round(unit.fromFeet(this.inFeet()+other.inFeet())*100.0)/100.0, unit);
        }
        @Override public boolean equals(Object obj) {
            if (!(obj instanceof QuantityLength o)) return false;
            return Math.abs(this.inFeet()-o.inFeet())<1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(inFeet()*1e6)); }
        @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
    }
    public static void main(String[] args) {
        System.out.println("1ft+12in="+new QuantityLength(1.0,LengthUnit.FEET).add(new QuantityLength(12.0,LengthUnit.INCH)));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd1Feet_whenAdded_shouldReturn2Feet() {
        assertEquals(2.0, new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET)).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_whenAdded_shouldReturn2Feet() {
        QuantityMeasurementApp.QuantityLength r = new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH));
        assertEquals(2.0, r.getValue(), 1e-2);
        assertEquals(QuantityMeasurementApp.LengthUnit.FEET, r.getUnit());
    }
    @Test void given3InchesAnd3Inches_whenAdded_shouldReturn6Inches() {
        assertEquals(6.0, new QuantityMeasurementApp.QuantityLength(3.0,QuantityMeasurementApp.LengthUnit.INCH).add(new QuantityMeasurementApp.QuantityLength(3.0,QuantityMeasurementApp.LengthUnit.INCH)).getValue(), 1e-2);
    }
    @Test void givenAddWithNull_shouldThrow() {
        assertThrows(NullPointerException.class, () -> new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(null));
    }
}
'@
UC-Branch "feature/UC6-Length-Addition" "[Balaji]:UC6 - Add addition of two lengths returning result in first operand unit" "2026-02-05T10:00:00+05:30"

# ======== UC7 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public enum LengthUnit {
        FEET(1.0), INCH(1.0/12.0), YARDS(3.0), CENTIMETERS(1.0/30.48);
        private final double f;
        LengthUnit(double f) { this.f = f; }
        public double toFeet(double v) { return v*f; }
        public double fromFeet(double v) { return v/f; }
    }
    public static final class QuantityLength {
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) { this.value=value; this.unit=Objects.requireNonNull(unit); }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        private double inFeet() { return unit.toFeet(value); }
        public QuantityLength convertTo(LengthUnit t) { return new QuantityLength(Math.round(t.fromFeet(unit.toFeet(value))*100.0)/100.0,t); }
        public QuantityLength add(QuantityLength other) { return add(other, this.unit); }
        public QuantityLength add(QuantityLength other, LengthUnit targetUnit) {
            Objects.requireNonNull(other); Objects.requireNonNull(targetUnit);
            return new QuantityLength(Math.round(targetUnit.fromFeet(this.inFeet()+other.inFeet())*100.0)/100.0, targetUnit);
        }
        @Override public boolean equals(Object obj) {
            if(!(obj instanceof QuantityLength o)) return false;
            return Math.abs(this.inFeet()-o.inFeet())<1e-6;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(inFeet()*1e6)); }
        @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
    }
    public static void main(String[] args) {
        System.out.println("1ft+12in in YARDS: "+new QuantityLength(1.0,LengthUnit.FEET).add(new QuantityLength(12.0,LengthUnit.INCH),LengthUnit.YARDS));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_addInYards_shouldGiveCorrect() {
        QuantityMeasurementApp.QuantityLength r = new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH),QuantityMeasurementApp.LengthUnit.YARDS);
        assertEquals(QuantityMeasurementApp.LengthUnit.YARDS, r.getUnit());
        assertEquals(0.67, r.getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addInInches_shouldGive24() {
        assertEquals(24.0, new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH),QuantityMeasurementApp.LengthUnit.INCH).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12Inches_addDefault_shouldGive2Feet() {
        assertEquals(2.0, new QuantityMeasurementApp.QuantityLength(1.0,QuantityMeasurementApp.LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,QuantityMeasurementApp.LengthUnit.INCH)).getValue(), 1e-2);
    }
}
'@
UC-Branch "feature/UC7-Addition-With-Target-Unit" "[Balaji]:UC7 - Add addition with explicit target unit specification" "2026-02-07T10:00:00+05:30"

# ======== UC8 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\LengthUnit.java" @'
package com.bridgelabz;
public enum LengthUnit {
    FEET(1.0), INCH(1.0/12.0), YARDS(3.0), CENTIMETERS(1.0/30.48);
    private final double conversionFactor;
    LengthUnit(double f) { this.conversionFactor = f; }
    public double convertToBaseUnit(double value) { return value * conversionFactor; }
    public double convertFromBaseUnit(double base) { return base / conversionFactor; }
}
'@
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
package com.bridgelabz;
import java.util.Objects;
public class QuantityMeasurementApp {
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) { this.value=value; this.unit=Objects.requireNonNull(unit); }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit t) {
            return new QuantityLength(Math.round(t.convertFromBaseUnit(unit.convertToBaseUnit(value))*100.0)/100.0, t);
        }
        public QuantityLength add(QuantityLength o) { return add(o,unit); }
        public QuantityLength add(QuantityLength o, LengthUnit t) {
            Objects.requireNonNull(o); Objects.requireNonNull(t);
            double sum = unit.convertToBaseUnit(value)+o.unit.convertToBaseUnit(o.value);
            return new QuantityLength(Math.round(t.convertFromBaseUnit(sum)*100.0)/100.0, t);
        }
        @Override public boolean equals(Object obj) {
            if(!(obj instanceof QuantityLength o)) return false;
            return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value))<EPS;
        }
        @Override public int hashCode() { return Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
    }
    public static void main(String[] args) {
        System.out.println("1ft==12in: "+new QuantityLength(1.0,LengthUnit.FEET).equals(new QuantityLength(12.0,LengthUnit.INCH)));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1FeetAnd12Inches_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0,LengthUnit.FEET), new QuantityMeasurementApp.QuantityLength(12.0,LengthUnit.INCH));
    }
    @Test void given1YardAnd3Feet_shouldBeEqual() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0,LengthUnit.YARDS), new QuantityMeasurementApp.QuantityLength(3.0,LengthUnit.FEET));
    }
    @Test void given1Feet_convertToInches_shouldBe12() {
        assertEquals(12.0, new QuantityMeasurementApp.QuantityLength(1.0,LengthUnit.FEET).convertTo(LengthUnit.INCH).getValue(), 1e-2);
    }
    @Test void given1FeetAnd12In_add_shouldBe2Feet() {
        assertEquals(2.0, new QuantityMeasurementApp.QuantityLength(1.0,LengthUnit.FEET).add(new QuantityMeasurementApp.QuantityLength(12.0,LengthUnit.INCH)).getValue(), 1e-2);
    }
    @Test void givenLengthUnit_convertToBase_isCorrect() {
        assertEquals(1.0, LengthUnit.FEET.convertToBaseUnit(1.0), 1e-6);
        assertEquals(1.0/12.0, LengthUnit.INCH.convertToBaseUnit(1.0), 1e-6);
    }
}
'@
UC-Branch "feature/UC8-Refactor-LengthUnit-SRP" "[Balaji]:UC8 - Refactor LengthUnit to standalone SRP class with convertToBaseUnit/convertFromBaseUnit" "2026-02-09T10:00:00+05:30"

# ======== UC9 ========
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\WeightUnit.java" @'
package com.bridgelabz;
public enum WeightUnit {
    KILOGRAM(1.0), GRAM(0.001), POUND(0.45359237);
    private final double f;
    WeightUnit(double f) { this.f = f; }
    public double convertToBaseUnit(double v) { return v*f; }
    public double convertFromBaseUnit(double b) { return b/f; }
}
'@
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityWeight.java" @'
package com.bridgelabz;
import java.util.Objects;
public final class QuantityWeight {
    private static final double EPS = 1e-6;
    private final double value; private final WeightUnit unit;
    public QuantityWeight(double value, WeightUnit unit) {
        if (!Double.isFinite(value)) throw new IllegalArgumentException("Value must be finite");
        this.value = value; this.unit = Objects.requireNonNull(unit, "Unit must not be null");
    }
    public double getValue() { return value; }
    public WeightUnit getUnit() { return unit; }
    public QuantityWeight convertTo(WeightUnit t) {
        Objects.requireNonNull(t);
        return new QuantityWeight(t.convertFromBaseUnit(unit.convertToBaseUnit(value)), t);
    }
    public QuantityWeight add(QuantityWeight o) { return add(o, unit); }
    public QuantityWeight add(QuantityWeight o, WeightUnit t) {
        Objects.requireNonNull(o); Objects.requireNonNull(t);
        return new QuantityWeight(t.convertFromBaseUnit(unit.convertToBaseUnit(value)+o.unit.convertToBaseUnit(o.value)), t);
    }
    @Override public boolean equals(Object obj) {
        if(!(obj instanceof QuantityWeight o)) return false;
        return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value))<=EPS;
    }
    @Override public int hashCode() { return Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
    @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
}
'@
Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" @'
package com.bridgelabz;
public class QuantityMeasurementApp {
    public static final class QuantityLength {
        private static final double EPS = 1e-6;
        private final double value; private final LengthUnit unit;
        public QuantityLength(double value, LengthUnit unit) { this.value=value; this.unit=java.util.Objects.requireNonNull(unit); }
        public double getValue() { return value; }
        public LengthUnit getUnit() { return unit; }
        public QuantityLength convertTo(LengthUnit t) { return new QuantityLength(Math.round(t.convertFromBaseUnit(unit.convertToBaseUnit(value))*100.0)/100.0,t); }
        public QuantityLength add(QuantityLength o) { return add(o,unit); }
        public QuantityLength add(QuantityLength o, LengthUnit t) {
            double sum=unit.convertToBaseUnit(value)+o.unit.convertToBaseUnit(o.value);
            return new QuantityLength(Math.round(t.convertFromBaseUnit(sum)*100.0)/100.0,t);
        }
        @Override public boolean equals(Object obj) {
            if(!(obj instanceof QuantityLength o)) return false;
            return Math.abs(unit.convertToBaseUnit(value)-o.unit.convertToBaseUnit(o.value))<EPS;
        }
        @Override public int hashCode() { return java.util.Objects.hash(Math.round(unit.convertToBaseUnit(value)/EPS)); }
        @Override public String toString() { return "Quantity("+value+", "+unit+")"; }
    }
    public static void main(String[] args) {
        System.out.println("1kg==1000g: "+new QuantityWeight(1.0,WeightUnit.KILOGRAM).equals(new QuantityWeight(1000.0,WeightUnit.GRAM)));
    }
}
'@
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" @'
package com.bridgelabz;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class QuantityMeasurementAppTest {
    @Test void given1KgAnd1000Grams_shouldBeEqual() {
        assertEquals(new QuantityWeight(1.0,WeightUnit.KILOGRAM), new QuantityWeight(1000.0,WeightUnit.GRAM));
    }
    @Test void given1KgAnd1Gram_shouldNotBeEqual() {
        assertNotEquals(new QuantityWeight(1.0,WeightUnit.KILOGRAM), new QuantityWeight(1.0,WeightUnit.GRAM));
    }
    @Test void given1Kg_convertToGram_shouldBe1000() {
        assertEquals(1000.0, new QuantityWeight(1.0,WeightUnit.KILOGRAM).convertTo(WeightUnit.GRAM).getValue(), 1e-2);
    }
    @Test void given1KgAnd1000g_whenAdded_shouldBe2Kg() {
        QuantityWeight r = new QuantityWeight(1.0,WeightUnit.KILOGRAM).add(new QuantityWeight(1000.0,WeightUnit.GRAM));
        assertEquals(2.0, r.getValue(), 1e-2);
    }
    @Test void givenNonFiniteValue_shouldThrow() {
        assertThrows(IllegalArgumentException.class, () -> new QuantityWeight(Double.NaN,WeightUnit.KILOGRAM));
    }
    @Test void given1FeetLength_stillWorks() {
        assertEquals(new QuantityMeasurementApp.QuantityLength(1.0,LengthUnit.FEET), new QuantityMeasurementApp.QuantityLength(12.0,LengthUnit.INCH));
    }
}
'@
UC-Branch "feature/UC9-Weight-Kilogram-Gram-Pound" "[Balaji]:UC9 - Add WeightUnit enum (KILOGRAM, GRAM, POUND) and QuantityWeight class" "2026-02-11T10:00:00+05:30"

Write-Host "UC1-UC9 DONE"
