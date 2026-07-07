# SIMDSTDLibCodeGenerator

run the following to generate `SIMD`protocol overloads for all SIMD types. This is a workaround to the compiler currently not picking up the derivatives defined for methods defined on the `SIMD` protocol. `+,-,\*,/` etc.

```
swift run SIMDSTDLibCodeGenerator ../Sources/Differentiation/SIMDSTDLibOverloads/
```
