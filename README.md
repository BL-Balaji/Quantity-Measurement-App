
---

## Use Cases Summary (UC1 → UC15)

### UC1: Feet Measurement Equality
**Goal:** Compare two *Feet* measurements for equality.
**What you learn:** `equals()` basics, value-based equality, null/type safety.

---

### UC2: Feet and Inches Measurement Equality
**Goal:** Add a separate *Inches* equality check (not converting feet↔inch yet).
**What you learn:** Extending tests, better method separation, avoiding main() dependency.

---

### UC3: Generic QuantityLength Class (DRY Principle)
**Goal:** Remove duplication by creating `LengthUnit` enum + `QuantityLength` class.
**What you learn:** DRY, abstraction, encapsulation, scalable design.

---

### UC4: Extended Unit Support (Yards + Centimeters)
**Goal:** Add `YARDS` (1 yard = 3 feet) and `CENTIMETERS` units.
**What you learn:** Scaling design by only changing enum.

---

### UC5: Unit-to-Unit Conversion (Length)
**Goal:** Provide explicit `convertTo(targetUnit)` API.
**What you learn:** API design, base-unit normalization, precision handling.

---

### UC6: Addition of Two Length Units
**Goal:** Add two lengths and return result in **first operand unit**.
**Example:** `1 ft + 12 in = 2 ft`

---

### UC7: Addition with Target Unit Specification
**Goal:** Add two lengths and return result in **explicit target unit**.
**Example:** `1 ft + 12 in` in `YARDS`

---

### UC8: Refactor LengthUnit to Standalone (SRP)
**Goal:** Move conversion responsibility into the unit enum itself.
**What you learn:** SRP, reduced coupling, scalable architecture.

---

### UC9: Weight Measurement Equality, Conversion, and Addition
**Goal:** Add `WeightUnit` enum (KILOGRAM base, GRAM, POUND) + `QuantityWeight` class.
**What you learn:** Multi-category scaling, type safety.

---

### UC11: Volume Measurement + Generic Quantity Class
**Goal:** Add `VolumeUnit` (LITRE, MILLILITRE, GALLON) + `IMeasurable` interface + generic `Quantity<U>`.
**What you learn:** Interface-based abstraction, generics.

---

### UC12: Temperature Measurement
**Goal:** Add `TemperatureUnit` (CELSIUS, FAHRENHEIT, KELVIN).
**What you learn:** Non-linear conversions, arithmetic restrictions.

---

### UC13: Subtraction Operation
**Goal:** Add `subtract(other)` and `subtract(other, targetUnit)` to `Quantity<U>`.

---

### UC14: Division Operation
**Goal:** Add `divide(other)` to `Quantity<U>` returning a dimensionless ratio.

---

### UC15: N-Tier Architecture
**Goal:** Refactor into Controller → Service → Repository → Entity layers.
**Design Patterns:** Singleton, Factory, Facade, Dependency Injection, Interface Segregation.

---

## How to Run Tests
```bash
mvn test
```
