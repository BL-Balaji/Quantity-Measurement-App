# UC-wise Git Flow Build Script
# Builds UC1-UC15 feature branches, merges each to develop, pushes both

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

# ========== UC1 ==========
$uc1App = @'
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
            Feet other = (Feet) obj;
            return Double.compare(this.value, other.value) == 0;
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

$uc1Test = @'
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
        QuantityMeasurementApp.Feet a = new QuantityMeasurementApp.Feet(1.0);
        assertTrue(a.equals(a));
    }
    @Test void givenFeet_comparedWithDifferentType_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals("1.0"));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc1App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc1Test
UC-Branch "feature/UC1-Feet-Measurement-Equality" "[Balaji]:UC1 - Add Feet measurement equality with value-based equals() and hashCode()"

# ========== UC2 ==========
$uc2App = @'
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
    public static boolean areFeetEqual(double a, double b)  { return new Feet(a).equals(new Feet(b)); }
    public static boolean areInchesEqual(double a, double b){ return new Inches(a).equals(new Inches(b)); }
    public static void main(String[] args) {
        System.out.println("Feet equal: "  + areFeetEqual(1.0, 1.0));
        System.out.println("Inches equal: " + areInchesEqual(1.0, 1.0));
    }
}
'@

$uc2Test = @'
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
    @Test void givenFeet_comparedWithNull_shouldReturnFalse() {
        assertFalse(new QuantityMeasurementApp.Feet(1.0).equals(null));
    }
}
'@

Write-FileContent "$WorkDir\src\main\java\com\bridgelabz\QuantityMeasurementApp.java" $uc2App
Write-FileContent "$WorkDir\src\test\java\com\bridgelabz\QuantityMeasurementAppTest.java" $uc2Test
UC-Branch "feature/UC2-Feet-And-Inches-Equality" "[Balaji]:UC2 - Add Inches measurement equality, reduce dependency on main()"

Write-Host "UC1 and UC2 COMPLETE"
